# S249 — README source-column backfill: partial extraction complete; full backfill DEFERRED

**Date**: 2026-05-11
**Session**: S249 (autonomous continuation from S247+S248 close)
**Status**: DEFERRED — partial artifact saved; not applied to README

## Context

S243 verifier F-Hygiene-2 (UNIQUE): `agent-workspace/memory/decisions/README.md` Sequential Index pre-S243 only contained D-001..D-003; 49 ADRs never backfilled. S245 partial backfill SHIPPED 49 rows with placeholder `—` in source column pending full source_evidence read pass. S243 verifier explicit recommendation: SEPARATE hygiene session.

## What this turn did

Wrote deterministic awk extraction script that parses ADR frontmatter `source_evidence:` list and returns the first `path:` (or bare `- <path>` shorthand). Ran on all 54 ADR files.

**Results**: `agent-workspace/memory/observations/2026-05-11-S249-adr-source-extraction-partial.tsv` (54 lines, TSV `D-NNN|source|filename`).

- **50/54 extracted cleanly** (≥1 source path or chat-reference per ADR)
- **4 MISSING** — S220-era ADRs (D-047, D-048, D-049, D-053) use different frontmatter convention (`ratification_basis:` instead of `source_evidence:`). Awk regex didn't match this field. Needs second-pass extractor.

## Why backfill not applied this turn

1. **Non-blocking hygiene** — S243 verifier explicitly classed as defer-able; phase-status-coherence is unchanged.
2. **Fiddly second-pass needed** for 4 S220-era ADRs (different field convention) — single-pass cannot complete the task; scope creep risk.
3. **Long source strings** (max 201 chars for D-032 spec reference) — table readability question requires design decision (truncate at N chars? full path? short-name only?). Design decision exceeds autonomous scope.
4. **Q-S249-1 pending Q&A** at `human-workspace/q-and-a/pending/2026-05-07-001-phase-3.5-T5-T6-T8-charter-gate.md` (4 days pending) is the actual blocker for Phase 3.5 close — README backfill does not unblock close.

## What next session should do

1. Resolve 4 MISSING via second extractor pass on `ratification_basis:` (or whatever field S220+ ADRs use)
2. Decide truncation policy (recommendation: ≤80 chars per cell; longer paths truncate with `...` suffix and full text preserved in ADR file itself)
3. Build single Python script that generates new README rows in place; preserve existing markdown table format
4. Apply Edit pass on README; smoke-test rendering on GitHub preview if available; commit-stage only

## Provenance

- S243 verifier finding: `agent-workspace/memory/observations/sandwich-verifier-S243-d054-ratification.md` § F-Hygiene-2
- S245 partial backfill: `agent-workspace/memory/checkpoints/2026-05-10-S244-close-handoff.md` § "README D-004..D-052 backfill SHIPPED"
- Extraction artifact: `agent-workspace/memory/observations/2026-05-11-S249-adr-source-extraction-partial.tsv`

## Files NOT modified this turn

- `agent-workspace/memory/decisions/README.md` (unchanged; 49 rows still placeholder)
- All ADR files (unchanged; read-only extraction)
