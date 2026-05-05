# Bundle Examples — 3 Worked Cases

> Companion to `grill-maximization/SKILL.md`. Use as starter templates.

## Example 1 — MINI bundle (3-5 questions, ARCH-tier, single cluster)

Use case: agent must pick a Python timeseries library for `packages/market_data` and is below ARCH 0.80 threshold.

```markdown
---
id: 2026-05-02-001-timeseries-lib
topic: Timeseries library for packages/market_data
opened_at: 2026-05-02T11:00:00Z
expected_answer_by: 2026-05-03T11:00:00Z
priority: NORMAL
related_decisions: []
status: pending
sync_categories: [DESIGN_THINKING]
---

# Q&A Bundle — Timeseries Library Choice

## Headline

ARCH-tier choice for market_data BC. Default if unanswered: stick with `pandas + pyarrow` (charter-coherent). Updates DESIGN_THINKING category.

## Cluster A — Library fit

**Evidence:** `agent-workspace/memory/patterns-discovered/borrow-list.md § Tier 2 — DataFrame ops`

### Q1: Primary library for VN30 OHLCV daily?
- A: pandas (mainstream, Python-primary, charter-coherent)
- B: polars (faster, less mature in VN community)
- C: TimescaleDB SQL only (skip in-memory frame, query on demand)
- D: open answer
- **Default**: A

### Q2: Where do we draw the line between "compute in pandas" vs "compute in SQL"?
- A: All multi-row aggregation in SQL; pandas only for plotting + per-row UI
- B: Pandas for analyst exploration; SQL for production
- C: Hybrid — depends on hot-path benchmarks
- D: open answer
- **Default**: A

### Q3: Backtest engine library?
- A: vectorbt (battle-tested, but TS-heavy for our taste)
- B: in-house lightweight (control + audit) 
- C: zipline (less actively maintained)
- D: open answer
- **Default**: B

## Answer Section
- Q1:
- Q2:
- Q3:
```

## Example 2 — STANDARD bundle (15-20 questions, SCOPE-tier, multiple clusters)

Use case: phase boundary for Phase 1 (Project Setup), 4 cross-cutting questions per cluster.

```markdown
---
id: 2026-05-15-001-phase-1-kickoff
topic: Phase 1 (Project Setup) kickoff design
opened_at: 2026-05-15T08:00:00Z
expected_answer_by: 2026-05-16T08:00:00Z
priority: URGENT
related_decisions: [D-002, D-005, D-006]
status: pending
sync_categories: [SCOPE, DESIGN_THINKING, DOMAIN_UBIQUITOUS, DECISION_ROUTING]
---

# Q&A Bundle — Phase 1 Kickoff

## Headline

Phase 1 (Project Setup, was old Phase 0) entry. 17 questions across 4 clusters. Default if not answered: proceed with Charter + Day 1 Checklist. Updates 4 Confidence Score categories.

## Cluster A — Monorepo skeleton

**Evidence:** `PROJECT_CHARTER.md § Stack` + `agent-workspace/memory/project.md § Active TODOs`

### Q1: Package manager?
- A: uv (recommended; fast)
- B: hatch (modern, simpler)
- C: poetry (mainstream, slower)
- D: open answer
- **Default**: A

### Q2: Python version pin?
- A: 3.13 (latest)
- B: 3.12 (mature)
- C: 3.11 (LTS-feel)
- D: open answer
- **Default**: B

### Q3: Domain layer dataclasses vs Pydantic?
- A: Pure dataclasses (constitution requires zero-framework)
- B: attrs
- C: Pydantic with `model_config = ConfigDict(frozen=True)`
- D: open answer
- **Default**: A

### Q4: Cross-BC contract format?
- A: Python protocols + dataclass DTOs
- B: JSON schema in shared `packages/contracts/`
- C: Protobuf (overkill for solo)
- D: open answer
- **Default**: A

## Cluster B — Universe + watchlist

**Evidence:** `eval-sets/` (currently empty)

### Q5: Initial universe?
- A: VN30
- B: VN30 + VNINDEX
- C: HOSE all + HNX top 50
- D: open answer
- **Default**: A

### Q6: Watchlist seed (5 stocks for thesis testing)?
- A: HPG, FPT, VNM, VCB, MWG (large-cap diversified)
- B: User-supplied list
- C: Defer to Phase 2 (skip seed)
- D: open answer
- **Default**: B

### Q7: Survivorship-aware historical data — start year?
- A: 2010 (15 years)
- B: 2015 (10 years)
- C: 2020 (5 years)
- D: open answer
- **Default**: B

### Q8: Tier 3 KOL channels — initial 10?
- A: User-supplied list (default expected)
- B: Agent-research top 10 by reach
- C: Defer
- D: open answer
- **Default**: A

## Cluster C — Constitution customization

**Evidence:** `agent-workspace/constitution/financial-data-protocol.md` + Charter

### Q9: Personal risk tolerance for Phase 4 (thesis system)?
- A: Conservative (1% portfolio per thesis, max 5 concurrent)
- B: Moderate (3% / 8 concurrent)
- C: Aggressive (5% / 15 concurrent)
- D: open answer
- **Default**: A

### Q10: Holding period floor?
- A: 1 month (charter says 1+)
- B: 3 months
- C: 6 months (long-term value tilt)
- D: open answer
- **Default**: A

### Q11: Stop-loss policy?
- A: -7% from entry (deterministic; LLM can't override per charter)
- B: -10%
- C: ATR-based dynamic
- D: open answer
- **Default**: A

### Q12: Sector concentration cap?
- A: 25% per sector
- B: 35%
- C: 50%
- D: open answer
- **Default**: A

## Cluster D — Calibration data seeding

**Evidence:** `agent-workspace/calibration/` (empty)

### Q13: How many historical theses for calibration baseline?
- A: 5 (per Charter Active TODOs)
- B: 10
- C: 20
- D: open answer
- **Default**: A

### Q14: Backfill window for KOL outcome tracking?
- A: 6 months
- B: 12 months
- C: 24 months (matches survivorship year)
- D: open answer
- **Default**: A

### Q15: Initial confidence-bucket count for Confidence Score per category?
- A: 3 buckets (low/med/high) — Charter LOW/MED/HIGH
- B: 5 buckets (1-5 stars)
- C: 10 buckets (0.1 increments)
- D: open answer
- **Default**: A

### Q16: Auto-trigger post-mortem on revoked thesis?
- A: Yes, mandatory
- B: Optional with prompt
- C: Defer to Phase 5
- D: open answer
- **Default**: A

### Q17: Calibration-report cadence?
- A: Weekly auto-generate
- B: Monthly
- C: On-demand only
- D: open answer
- **Default**: B

## Answer Section
[…]
```

## Example 3 — MAX bundle (25 questions, CHARTER-tier, full grill)

Reserved for charter-amendment proposals. Same structure as standard but 5-6 clusters of 4-5 questions. Don't compose pre-emptively; only when actual charter-tier decision pending.

Skeleton:

```markdown
---
id: <YYYY-MM-DD>-NNN-charter-amendment-<topic>
topic: Charter amendment — <topic>
priority: URGENT
related_decisions: [<charter-affecting>]
sync_categories: [SCOPE, DECISION_ROUTING, ...]
---

## Cluster A — Identity / Mission delta
## Cluster B — Invariant delta
## Cluster C — Phase plan delta
## Cluster D — NOT-list delta
## Cluster E — Acceptance criteria
```

A max bundle should reach the user with a written notification (`human-workspace/notifications/N-<TS>-ALERT-<slug>.md`) — don't rely on file-watch alone for charter-tier work.
