---
profile_version: v0-template
created_at: 2026-04-30 (S26 IMPL — Phase 1 Track B)
last_filled_at: <USER FILL — date you complete this profile>
schema_source: docs/DAY_1_CHECKLIST.md § B.5 + master-plan 004 § S26 deliverable #3
binding_status: TEMPLATE — values are USER FILL placeholders; system reads `<USER FILL>` literally and skips enforcement until replaced with concrete values
fills_required_by: S30 (Phase 1 close) at the latest; thesis-template references this file
---

# Personal Risk Profile — Template

> **What this is**: structured capture of the project owner's personal risk tolerance and trading discipline. The system reads this file to enforce risk rules deterministically per Charter Principle 10 (deterministic risk; LLM cannot override).
>
> **What this is NOT**: financial advice, charter exclusions, or LLM-generated content. Charter exclusions (no derivatives / no shorting / no insider info) live in `PROJECT_CHARTER.md` § Honest Boundaries — they bind the system regardless of this profile. This profile binds owner-personal preferences ABOVE the charter floor.
>
> **How to fill**: replace each `<USER FILL>` block with concrete values. Optional: add free-text notes under any section. Do NOT add LLM-generated content here — every value MUST be user-authored.

---

## 1. Holding Period Preference

**Minimum holding period (post-thesis-entry)**: `<USER FILL — e.g., 1 month / 3 months / 6 months>`

**Preferred holding period (long-form thesis)**: `<USER FILL — e.g., 6-24 months per Charter>`

**Maximum holding period before mandatory thesis review**: `<USER FILL — e.g., 12 months>`

**Notes**: `<USER FILL — e.g., "Match Charter holding band 1m-24m; comfort zone 6-12m; review Q-end">`

---

## 2. Position Sizing Rules

**Maximum % of portfolio in single Ticker**: `<USER FILL — e.g., 0.10, 0.15>` (Charter ceiling = 0.15 per § First Sub-Scope)

**Maximum % of portfolio in single Sector**: `<USER FILL — e.g., 0.30>` (Charter implicit ceiling = 0.30; can tighten)

**Maximum number of concurrent open Positions**: `<USER FILL — e.g., 6, 10>`

**Minimum cash reserve % of portfolio**: `<USER FILL — e.g., 0.10>` (T+2.5 settlement floor + opportunistic dry powder)

**Position-sizing method**: `<USER FILL — Kelly fraction × N, equal-weight, conviction-weighted, other>`

**Notes**: `<USER FILL — e.g., "Equal-weight at first; revisit after 12-thesis hit-rate sample">`

---

## 3. Stop-Loss Philosophy

**Stop-loss trigger type**: `<USER FILL — choose one or describe hybrid: thesis-invalidation, fixed-pct-decline, ATR-multiple, none>`

**If fixed-pct-decline**: trigger at `<USER FILL — e.g., -15%, -20%>` from cost basis

**Thesis-invalidation criteria** (always applicable regardless of pct stop): `<USER FILL — e.g., "core thesis fact violated, e.g., management change, regulatory action, fundamentals reversal">`

**Sell-into-strength rule** (optional): `<USER FILL — e.g., "trim 25% at +30%, +60%, +100% from cost"; or "no — thesis-driven only">`

**Notes**: `<USER FILL>`

---

## 4. Dividend Preference

**Dividend yield as a thesis criterion**: `<USER FILL — required, preferred, neutral, avoid (growth-only)>`

**Minimum dividend yield (if required/preferred)**: `<USER FILL — e.g., 5% gross VN-domestic>`

**Dividend reinvestment policy**: `<USER FILL — auto-reinvest into same Ticker, pool to opportunistic, distribute>`

**Cổ tức kế hoạch vs Cổ tức thực** (planned vs actual dividend) — preference: `<USER FILL — e.g., "trust actual ≥1 prior; ignore planned-only">`

**Notes**: `<USER FILL>`

---

## 5. Sector Exclusions

> Per master-plan 004 § S26 Q-S26-3 default: empty sector exclusion list. Charter-level exclusions (no derivatives / no shorting) are NOT listed here — they bind globally.

**Sectors permanently excluded from thesis universe**: `<USER FILL — empty list OR specific sectors e.g., "tobacco, alcohol, weapons-related">`

**Sectors temporarily excluded (reason + review date)**: `<USER FILL — empty OR e.g., "BĐS until credit-tightening cycle ends; review 2026-Q3">`

**Sectors over-weighted (positive bias to monitor for confirmation)**: `<USER FILL — empty OR e.g., "ngân hàng — long-term overweight; require explicit bear-case rigor per BC-9 PersonalBias">`

**Notes**: `<USER FILL>`

---

## 6. Maximum Portfolio Drawdown Tolerance

**Drawdown level that triggers full thesis review**: `<USER FILL — e.g., -10%, -15% portfolio peak-to-trough>`

**Drawdown level that triggers position-reduction**: `<USER FILL — e.g., -20%>`

**Drawdown level that triggers dogfood pause / external coach consult**: `<USER FILL — e.g., -25%>`

**Time-window for drawdown measurement**: `<USER FILL — rolling 3 months / calendar quarter / since portfolio start>`

**Notes**: `<USER FILL — e.g., "Behavioral guard rail: -15% triggers 2-week trade-pause + cold-read of latest 3 thesis">`

---

## 7. Profile Audit Trail (append-only)

| Date | Section changed | Rationale |
|---|---|---|
| `<USER FILL>` | `<USER FILL>` | `<USER FILL>` |

> System binds whatever values are in this file at time of thesis evaluation. Changing values mid-thesis must be audited here per Charter Principle 6 (Human-in-loop is the product) — drift toward looser limits during drawdowns is the documented behavioral failure mode.
