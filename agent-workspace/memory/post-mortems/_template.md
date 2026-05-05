---
template_version: v1.0
template_for: post-mortem entry
created_at: 2026-04-30 (S30 — Phase 1 close)
schema_source: agent-workspace/memory/post-mortems/README.md + invariants.md § I-S26
binding_invariants: I-S1 (no LLM math) / I-S5 (source attribution) / I-S7 (calibration tied to hit rate) / I-S22 (personal bias tracking) / I-S26 (post-mortem required at 6m) / I-S35 (research-aid disclaimer)
fills_required_when: thesis horizon elapses (3m / 6m / 12m); copy this file to `YYYY-MM-DD-{TICKER}-horizon{Nm}.md` and replace placeholders
---

# Post-Mortem — {TICKER} — horizon {3m | 6m | 12m}

> **What this is**: review of a thesis after horizon elapses. Feeds the Karpathy outer loop (spec 005). Missing post-mortems = broken compounding (calibration depends on outcome data per I-S7). Per I-S26 every thesis older than 6 months MUST have a post-mortem entry.

## Reference

- **Original thesis**: `agent-workspace/memory/thesis-log/<YYYY-MM-DD>-{TICKER}-session{N}.md`
- **Original grade / confidence**: `<A | B | C | D>` (from thesis § Confidence)
- **Original recommendation**: `<THESIS_CANDIDATE | INVESTIGATE | WATCH | PASS>`
- **Original as-of**: `<YYYY-MM-DD>`
- **Review as-of**: `<YYYY-MM-DD>`
- **Horizon elapsed**: `<3m | 6m | 12m>` (per personal-risk-profile.md § 1 minimum holding period)

## Outcome (numbers via code, never LLM — I-S1)

> Every number below has a `-- query: ...` SQL trace. Charter Principle 9: code computes, LLM interprets. If position was actually taken, query the portfolio book; if exemplar/observed-only, query the bars table.

- **Price change**: `<x%>` (from `<entry_price>` to `<review_price>`) `<-- query: SELECT (review.close / entry.close - 1) * 100 FROM ...>`
- **Vs VN-Index benchmark**: `<y%>` (relative outperformance: `<x%-y%>`) `<-- query: same period close ratio for VN-Index>`
- **Max drawdown during holding**: `<z%>` `<-- query: (entry_close / MIN(close after entry)) - 1>`
- **Time to peak**: `<days>` after entry `<-- query: ARG MIN over period>`
- **Volume profile during holding**: avg `<volume>` vs prior 90d `<volume>` ratio `<x.x>`x

## Catalysts — Realized vs Failed

| Catalyst | Expected by | Realized? | Date | Impact |
|---|---|---|---|---|
| `<catalyst 1>` | `<YYYY-MM-DD>` | `<YES | NO>` | `<actual date>` | `<HIGH | MED | LOW>` |
| `<catalyst 2>` | `<YYYY-MM-DD>` | `<YES | NO>` | `<actual date>` | `<HIGH | MED | LOW>` |

## Invalidation Triggers — Fired or Not

| Trigger | Fired? | When | What was the response? |
|---|---|---|---|
| `<trigger 1>` | `<YES | NO>` | `<YYYY-MM-DD>` | `<exited / held / re-thesis>` |
| `<trigger 2>` | `<YES | NO>` | `<YYYY-MM-DD>` | `<action>` |

## Verdict

**`<RIGHT | WRONG | PARTIAL>`**

Justification: `<USER FILL — narrative paragraph; reference specific perspective claims that did/didn't hold>`

## What the System Saw Correctly

- `<finding 1>` — perspective: `<BULL | BEAR | QUANT | OTHER>` — confidence at thesis-time: `<HIGH/MED/LOW>`
- `<finding 2>` — perspective + confidence
- `<finding 3>` — perspective + confidence

## What the System Missed

- `<miss 1>` — root cause: `<missing data tier (T1/T2/T3/T4) | wrong perspective weighting | absent calibration>`
- `<miss 2>` — root cause
- `<miss 3>` — root cause

## What to Change in the Thesis Pipeline

- **Prompt change** (perspective agent): `<which agent + what change to system prompt>` OR "no change needed"
- **Data tier addition**: `<which Tier (T1/T2/T3/T4) had a gap; what feed to add>` OR "no change"
- **Pattern library entry**: `<should this case become a labeled pattern in patterns-discovered/>` OR "no — too idiosyncratic"
- **RiskRule adjustment**: `<should max_position_pct or sector cap shift>` OR "no change"

## Calibration Impact (I-S7 + I-S20)

- **Signal sources that contributed**: `<list — e.g., "Bull P/E ratio analysis HIT", "Bear governance concern MISS">`
- **KOL recommendations referenced** (Phase 2+): `<list of KOL channels + their calls + accuracy>`
- **Calibration database update proposed for**: `<KOL handle | pattern name | perspective agent>` — `<+/- delta to credibility score>`
- **Pattern hit rate revision**: `<pattern name>` from `<x.xx>` (n=<old>) to `<y.yy>` (n=<new>)

## Bias Check (Charter Principle 6 + I-S22)

- **User's gut at thesis-time**: `<aligned | contrarian | neutral>` to system recommendation
- **User's gut outcome**: `<right | wrong | partial>` (independent of system)
- **Confirmation bias risk flag**: `<YES | NO>` — was user already long this stock when thesis ran?
- **Anchoring bias**: did the original entry price anchor stop-loss decisions inappropriately during holding?
- **Sunk-cost / consistency bias**: did user hold past invalidation trigger because of public position?
- **Net behavioral lesson**: `<USER FILL — what to watch for next time>`

## Personal Risk Profile Drift Check

> Per personal-risk-profile.md § 7 audit trail rule: "drift toward looser limits during drawdowns is the documented behavioral failure mode."

- **Position size at entry**: `<x%>` of portfolio
- **Position size at review**: `<y%>` (after price moves; would-be after rebalance)
- **Stop-loss adjustments mid-holding**: `<list with dates + rationale>` OR "none"
- **Did user violate any personal-risk-profile.md rule?**: `<NO | YES — which rule, when, why>`

## Lessons (append to agent-notes.md if generally applicable)

1. `<lesson — generalizable rule, not stock-specific>`
2. `<lesson>`
3. `<lesson>`

## Pattern-Library Candidate

- **Should this case become a labeled pattern?**: `<YES | NO>`
- If YES: pattern name `<descriptive label>`; add entry to `agent-workspace/memory/patterns-discovered/<pattern-name>.md`
- Pattern signature (≥3 features): `<list>`

## Charter Calibration

- **Was the recommendation framing honest?**: `<YES | NO>` — i.e., framed as "thesis exploration" / "consideration" per Charter Honest Boundaries, not as "buy/sell"
- **Did the bear case contain ≥3 substantive points (I-S10)?**: `<YES | NO>` — verify by reviewing original thesis
- **Was disagreement surfaced (I-S12) rather than collapsed?**: `<YES | NO>`
- **Were all numbers from code (I-S1)?**: `<YES | NO>` — verify by checking thesis Quant Summary `-- query:` audit trail
- **Was every claim source-attributed (I-S5)?**: `<YES | NO>`

---

## Disclaimer (I-S35 mandatory)

*This post-mortem is an audit of past research, not new financial advice. Numbers reflect what `data/<ticker>.sqlite` (or equivalent ingested store) contains as-of the review date. The post-mortem feeds calibration — the system updates its own confidence in signal sources based on this outcome data. Per I-S26 missing post-mortems break compounding; per I-S22 every entry must include the bias check section.*

[Archive post-mortem ID: `<UUID>` — feeds calibration database]
