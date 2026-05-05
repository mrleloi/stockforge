# sync-tracker — Confidence Score System (Track 8a deliverable)

> **Status**: Track 8a IMPL shipped S17 (2026-04-29). See D-006.
> **Storage substrate**: bash + TSV flat-file MVP per IMPL-S17-1; SQLite migration deferred to Phase 1+ (see D-006 § Open Questions).

## Files

| File | Purpose | Updated by |
|---|---|---|
| `events.tsv` | Append-only event log (TSV; header row + per-event rows) | `scripts/hooks/sync-tracker-update.sh` |
| `state.tsv` | Computed per-category state (5 rows; one per category) | `scripts/hooks/sync-tracker-update.sh` |
| `weights.yaml` | Tunable weights + thresholds + tier mapping (flat key:value) | manual edit (humans tune) |
| `_index.md` | Auto-rendered human-readable view | `scripts/hooks/sync-tracker-render.sh` |
| `README.md` | This file | manual |

## Categories (5)

LANGUAGE / DOMAIN_UBIQUITOUS / DESIGN_THINKING / SCOPE / DECISION_ROUTING

Initial score: 50 (mid-range; neither earned confidence nor accumulated correction debt).

## Tier display

```
score >= 90  →  HIGH-CONFIDENCE  (🟢 ≥0.90 hit-rate; self-decide IMPL/ARCH freely)
score 70-89  →  MED-HIGH         (🟢 0.70-0.89; self-decide IMPL; grill SCOPE+)
score 50-69  →  MED              (🟡 0.50-0.69; grill ARCH+; self-decide IMPL with citation)
score 30-49  →  MED-LOW          (🟠 0.30-0.49; grill SCOPE+ mandatory; IMPL with double-check)
score 0-29   →  MUST-GRILL       (🔴 <0.30; grill ALL decisions until score recovers)
```

## Thresholds (per-decision-class)

| Class | Threshold | Below-threshold action |
|---|---|---|
| CHARTER | 99 | MUST grill via AskUserQuestion (charter-tier letter pick) |
| SCOPE | 90 | MUST grill via AskUserQuestion |
| ARCH | 80 | SHOULD grill; if self-decide, double-cite source_evidence |
| IMPL | 50 | OK to self-decide; subject to drift audit |

## How to use

**Before a decision**: invoke `sync-pull` skill (or read `_index.md` directly). Check the relevant category's score vs threshold. Above → self-decide; below → grill.

**On a Q&A resolution**: hook auto-fires `sync-tracker-update.sh` with delta = +0.1 (q_and_a_resolution).

**On a correction or revocation**: agent emits event to `sync-tracker-update.sh` with negative delta + sets `must_grill_remaining=5` for the affected category.

**On Stop hook**: `sync-tracker-update.sh` re-renders `_index.md`.

## Schema (events.tsv columns; tab-separated)

```
ts                category   event_type                  delta   decision_id  source_evidence    reason
2026-04-29T...    SCOPE      decision_correctness        +0.5    D-006        D-006-§-Decision   smoke
```

(See D-006 § Decision for canonical event_type definitions.)

## Migration to SQLite (Phase 1+)

When Track 8b ships python + sqlite3 module (S18+), TSV → SQL INSERT is mechanical. Schema:

```sql
CREATE TABLE events (
  event_id INTEGER PRIMARY KEY AUTOINCREMENT,
  ts TEXT NOT NULL,
  category TEXT NOT NULL,
  event_type TEXT NOT NULL,
  delta REAL NOT NULL,
  decision_id TEXT,
  source_evidence TEXT,
  reason TEXT
);
CREATE TABLE state (
  category TEXT PRIMARY KEY,
  current_score REAL NOT NULL,
  sample_count INTEGER NOT NULL,
  last_updated_ts TEXT NOT NULL,
  must_grill_remaining INTEGER NOT NULL
);
```

Migration: `awk -F'\t' 'NR>1 {printf "INSERT INTO events ..."}' events.tsv | sqlite3 sync-tracker.db`.
