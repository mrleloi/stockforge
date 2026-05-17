---
severity: HIGH
session: S395
type: BLOCKER-FINDING
blocking: PFP-DONE-7 (Wave 1 MVP READY transition)
authored: 2026-05-17
status: resolved-2026-05-17-via-D-081-S396
resolved_at: 2026-05-17T19:40:00Z
resolution_basis: "ADR D-081 ACCEPTED (BR-6 cap 3.00→6.00); S396 dev shipped fix + 4 thesis re-runs (VHM+HPG+VIC+FPT all status='submitted'; gaps=[]; cumulative cost $17.867547 within user Q1=A authorization); S401 verifier PASS/merge-eligible confirms PFP-DONE-7+8 GREEN × 4; Wave 1 MVP READY. MINOR-1 fix per PCG-S401-3 1st-instance promotion candidate."
---

# S395 Finding: validate_thesis Cost Blocker — PFP-DONE-7 NOT MET

## Summary

Data corpus ingestion COMPLETED SUCCESSFULLY for all 4 tickers × 3 sources. The 3 corpus gaps from S384 (`price_stale`, `fundamentals_stale`, `no_news_90d`) are CLEARED. However, validate_thesis VHM re-run FAILED with `cost_budget_exceeded` ($4.24 > $3.00 hard cap). Thesis NOT persisted to SQLite. PFP-DONE-7 NOT MET.

## Corpus status (READY)

| Ticker | Bars | News (90d) | Fundamentals | Corpus gaps cleared? |
|---|---|---|---|---|
| VHM | 114 bars (PASS) | 3 articles (gap-clear PASS) | 4Q IS+BS+CF (PASS) | YES |
| HPG | 114 bars (PASS) | 1 article (gap-clear PASS) | 4Q IS+BS+CF (PASS) | YES |
| VIC | 114 bars (PASS) | 6 articles (gap-clear PASS) | 4Q IS+BS+CF (PASS) | YES |
| FPT | 114 bars (PASS) | 9 articles (gap-clear PASS) | 4Q IS+BS+CF (PASS) | YES |

Corpus gaps evidence: `thesis-log/2026-05-17-VHM.md` shows `gaps: ['cost_budget_exceeded']` — NOT `['price_stale', 'fundamentals_stale', 'no_news_90d']`.

## Cost-blocker root cause

`packages/application/analysis/use_cases/validate_thesis_phase1.py:189`:
```python
with self._cost_tracker.scoped_budget(limit_usd=Decimal("3.00")) as budget:
```

This is HARDCODED. The `--max-cost-usd` CLI flag is IGNORED (use_case_builder.py:109: `_ = max_cost_usd`).

6-persona V0=6 run via subagent costs ~$4.24 per run (BULL/Haiku retried 2× on non-JSON response; QUANT/Opus + BUFFETT/GRAHAM/TALEB/Opus ran in parallel).

## Decision required

**Option A** (recommended): Increase limit_usd in `validate_thesis_phase1.py:189` to `Decimal("6.00")` or higher. Requires IMPL session touching `packages/**`.

**Option B**: Remove BUFFETT/GRAHAM/TALEB personas from `_build_subagent_agents()` in `apps/_shared/use_case_builder.py` (NOT packages/**; eligible for inline-fix). Would reduce to 3-persona run (~$1-2 total). NOTE: breaks V0=6 persona architecture but valid for dogfood gate.

**Option C**: Accept PARTIAL — corpus READY evidence captured; PFP-DONE-7 deferred to F.5-V2.

## News quality note (non-blocking)

CafeF news per-ticker counts below ≥30 quality floor (VHM=3, HPG=1, VIC=6, FPT=9). The `no_news_90d` gap IS cleared (≥1 article in 90d). The ≥30 floor is plan quality goal, not corpus-gap requirement. Root cause: CafeFScraper.discover() is single-page (no pagination) — ~60 articles per section page, not 800 as assumed.

## Files produced (committed)

- `agent-workspace/memory/observations/data-corpus-ingestion-S395-verification-report.md`
- `agent-workspace/memory/observations/sandwich-dev-S395-data-corpus-ingestion.md`
- `agent-workspace/memory/thesis-log/2026-05-17-VHM.md` (INCOMPLETE; cost_budget_exceeded)
- `data/stockforge.sqlite` (binary; not committed but populated)
