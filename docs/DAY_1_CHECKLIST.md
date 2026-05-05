# Day 1 Checklist — StockForge

> Complete this before writing any code.
> Target duration: 3-5 hours (longer than IdeaForge because finance requires more care upfront).
> Critical: do not skip to coding. Investment here pays 10x later.

---

## Phase A — Understand the Vision (90-120 min)

### A.1 Read Project Charter
**File**: `PROJECT_CHARTER.md`
**Time**: 30 min
**Why**: Immutable vision. Everything flows from this. If you disagree with something, revise the charter now — it's much harder later.

- [ ] Read all sections
- [ ] Understand the **Four-Tier Signal Architecture** (core insight)
- [ ] Confirm you agree with Core Principles (non-negotiable)
- [ ] Confirm you agree with Honest Boundaries (what system does NOT do)
- [ ] Confirm Success Criteria feel achievable for your life circumstances

### A.2 Read Strategic Signal Architecture Spec
**File**: `specs/tier1-strategic/001-four-tier-signal-architecture.md`
**Time**: 30-40 min
**Why**: This is the single most important architectural document. Every other spec builds on it.

- [ ] Understand each tier's role, lead time, and reliability profile
- [ ] Understand the combinatorial patterns (early opportunity, likely top, manufactured pump, forgotten value)
- [ ] Understand why single-tier approaches fail for VN market

### A.3 Skim Agent Operating Manual
**File**: `AGENT_OPERATING_MANUAL.md`
**Time**: 30-40 min
**Why**: Understand how agents operate.

Focus sections:
- [ ] Section 1 — Mental Model
- [ ] Section 2 — Workspace Architecture
- [ ] Section 3 — Obsidian Integration
- [ ] Section 5 — Skills Catalog (skim)
- [ ] Section 10 — Session Protocols

### A.4 Read Financial Data Protocol
**File**: `agent-workspace/constitution/financial-data-protocol.md`
**Time**: 20 min
**Why**: Stock-specific data integrity rules. Read carefully — these rules prevent real money loss.

- [ ] Understand point-in-time integrity (look-ahead bias)
- [ ] Understand survivorship bias awareness
- [ ] Understand No-LLM-Math rule (I-S1)
- [ ] Understand source attribution and reconciliation
- [ ] Acknowledge: backtest discipline is non-negotiable

### A.5 Read Constitution Invariants
**File**: `agent-workspace/constitution/invariants.md`
**Time**: 15 min

- [ ] Focus on stock-specific invariants (I-S1 through I-S54)
- [ ] Understand severity levels
- [ ] Understand violation handling

---

## Phase B — Prepare Your Context (60-90 min)

### B.1 Customize Financial Data Protocol

**File**: `agent-workspace/constitution/financial-data-protocol.md`

Adjust if needed (but rarely):
- [ ] Risk tolerance parameters (if any reference)
- [ ] Budget caps (if different from defaults)

### B.2 Seed Historical Theses

Create `eval-sets/historical-theses/seed.md` with 5 stocks you've watched and what you'd have done:

- [ ] Pick 5 stocks you have strong opinions on (real experience)
- [ ] For each: ticker, as-of date, would you have bought/avoided, why, what happened
- [ ] This becomes initial eval set for measuring system quality

Example:
```markdown
## HPG — 2023-01-01
**My call**: AVOID
**Why**: High leverage, steel cycle uncertain, governance mediocre
**What happened**: Stock went up 30% by year-end
**My call was**: WRONG (missed cyclical recovery + inventory restock)
**Lesson**: Don't confuse fundamental concerns with timing. Cycle timing mattered more.
```

### B.3 Seed KOL List

Create `eval-sets/labeled-kol-recommendations/seed-kols.md` with 10 Vietnamese finance KOLs you know:

- [ ] List 10 KOLs by name + primary channel URL
- [ ] For each: YouTube/FB/Telegram, your gut estimate of quality
- [ ] Notes: sectors they cover, style (fundamental/technical/narrative), any known bias

Example:
```markdown
## KOL: [Channel Name]
- Platform: YouTube
- URL: https://youtube.com/@...
- Est subscribers: 150K
- Style: Mixed fundamental+narrative
- Sectors: Banking, real estate
- Gut credibility (before calibration): 6/10
- Notes: Often reacts to mainstream news rather than leads
```

### B.4 Seed Historical Pumps

Create `eval-sets/labeled-pumps/seed.md` with 3-5 pumps you remember:

- [ ] Ticker + approx dates
- [ ] What you remember about the cycle
- [ ] Eventual outcome

Example:
```markdown
## FLC Group — 2021-11 to 2022-01
**Type**: Coordinated pump by connected parties
**Narrative**: "real estate boom + cryptocurrency tie-in"
**Peak phase**: Dec 2021, massive volume + FOMO posts on forums
**Dump**: Jan 2022 after 77 TPS trading violations exposed
**Subsequent outcome**: Multi-year trading halt, eventual delisting
**My observation**: [what you noticed at the time]
```

### B.5 Define Personal Risk Profile

Create `agent-workspace/memory/personal-risk-profile.md`:

- [ ] Holding period preference (months/years)
- [ ] Position sizing rules (max % per stock, max % per sector)
- [ ] Stop-loss philosophy (thesis-invalidation vs percentage)
- [ ] Dividend preference
- [ ] Sector exclusions (if any — e.g., "never BĐS during credit tightening")
- [ ] Maximum portfolio drawdown tolerance

---

## Phase C — Environment Setup (60-90 min)

### C.1 Install Prerequisites

- [ ] Claude Code: `claude --version` should work
- [ ] Python 3.11+: `python --version`
- [ ] Docker: `docker --version`
- [ ] Git: `git --version`
- [ ] Obsidian (optional but recommended for wiki browsing)
- [ ] DBeaver or similar DB client

### C.2 Set Up Local Infrastructure

- [ ] Copy `.env.example` to `.env` and fill in:
  - `ANTHROPIC_API_KEY` (required)
  - `OPENAI_API_KEY` (for embeddings)
  - Database credentials (for docker-compose)
- [ ] Run `docker-compose up -d` to start Postgres + Redis
- [ ] Verify Postgres has TimescaleDB + pgvector extensions:
  ```sql
  CREATE EXTENSION IF NOT EXISTS timescaledb;
  CREATE EXTENSION IF NOT EXISTS vector;
  CREATE EXTENSION IF NOT EXISTS pg_trgm;
  ```

### C.3 Verify Claude Code Integration

- [ ] Open `stockforge/` in Claude Code: `cd stockforge && claude`
- [ ] Type: `/session-start` — should load context successfully
- [ ] Type: `/handoff-read` — should read memory files

---

## Phase D — First Agent Interactions (45-60 min)

### D.1 Run First Drill-Me

Goal: seed ubiquitous language for Vietnamese stock domain.

```
/drill-me "Vietnam stock market value investing with KOL tracking"
```

Expected output:
- Proposed glossary terms (Ticker, Thesis, KOL, Credibility Score, Narrative Phase, etc.)
- Q&A to clarify domain nuances
- Final glossary saved to `agent-workspace/ubiquitous-language/glossary.md`

- [ ] Complete drill-me session
- [ ] Review output in glossary file
- [ ] Adjust any terms that don't match your mental model

### D.2 Master Plan for Phase 1

```
/master-plan "implement Phase 1 thin slice — thesis validation for VN30 with Tier 1+2 data"
```

Expected output:
- Session plan files in `agent-workspace/session-plans/pending/`
- Each session plan: clear scope, estimated tokens, success criteria

- [ ] Review generated session plans
- [ ] Adjust scope if too ambitious (smaller is fine)
- [ ] Commit the plans to version control

### D.3 Update current-execution.md

- [ ] Update `agent-workspace/memory/current-execution.md`:
  - Phase: 1 (Foundation)
  - Active plan: path to first session plan from master-plan
  - Status: ready

---

## Phase E — Commit & Baseline (30 min)

### E.1 Git Initialize

- [ ] `git init` (if not already)
- [ ] `git add .`
- [ ] `git commit -m "StockForge starter kit + Day 1 customization"`

### E.2 Create Baseline Reference

Create `agent-workspace/memory/sessions/00-day-1-baseline.md`:

- [ ] What you read
- [ ] What you seeded in eval-sets
- [ ] What decisions you made (deviations from defaults)
- [ ] What's your current expectation for Phase 1 completion

### E.3 Set Expectations Correctly

Before starting Phase 1, acknowledge:

- [ ] **This is a 12-24 month project** for meaningful edge
- [ ] **Phase 1 (3 months) produces basic thesis validator** — not yet edge
- [ ] **Edge compounds through data accumulation, not through clever code**
- [ ] **Dogfood is the only validation** — if I don't use weekly, feature dies
- [ ] **I am responsible for all investment decisions** — system is advisor only

---

## What's Next After Day 1

Start Phase 1:
1. Open first pending session plan
2. Type `/session-start` to load context
3. Begin first work session (probably PLAN type for first session)
4. Follow the sandwich pattern: Architect → Dev → Verifier

**Reading order of specs**:
1. `specs/tier1-strategic/001-four-tier-signal-architecture.md` (already read in Phase A.2)
2. `specs/tier2-feature/001-validate-investment-thesis.md` (start with this for Phase 1)
3. `specs/tier2-feature/002-influence-network-tracking.md` (Phase 2)
4. `specs/tier2-feature/003-crowd-sentiment-pump-detection.md` (Phase 2)
5. `specs/tier2-feature/004-multi-perspective-adversarial-agents.md` (Phase 3 expansion)
6. `specs/tier2-feature/005-karpathy-outer-loop.md` (Year 2)

---

## Completion Confirmation

Check all boxes in Phase A-E above. Then:

- [ ] I have completed Day 1 checklist
- [ ] I understand the vision and constraints
- [ ] I have seeded initial eval data (theses, KOLs, pumps)
- [ ] My environment is working
- [ ] I know what Phase 1 looks like
- [ ] I am ready to build

If any item above is unchecked, address before starting Phase 1. Shortcuts here compound into confusion later.

Last updated: 2026-04-23
