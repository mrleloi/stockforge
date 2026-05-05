---
template_version: v1.0
template_for: thesis-log entry
created_at: 2026-04-30 (S30 — Phase 1 close)
schema_source: specs/tier2-feature/001-validate-investment-thesis.md § A.4 + agent-workspace/memory/thesis-log/README.md
binding_invariants: I-S1 (no LLM math) / I-S2 (point-in-time) / I-S5 (source attribution) / I-S6 (currency) / I-S7 (calibrated confidence) / I-S10 (bear case ≥3 points) / I-S11 (multi-perspective) / I-S12 (disagreement surfaced) / I-S35 (research-aid disclaimer)
fills_required_when: composing a new thesis entry; copy this file to `YYYY-MM-DD-{TICKER}-session{N}.md` and replace placeholders
---

# {TICKER} — as of {YYYY-MM-DD}

> **Status**: DRAFT | THESIS_CANDIDATE | INVESTIGATE | WATCH | PASS — research aid only, not financial advice (I-S35).
> **Session**: {N} — {SESSION_TYPE} (THESIS / FOCUSED_IMPL / etc.)
> **Horizon**: {1m | 3m | 6-12m | 2y+} (per personal-risk-profile.md § 1)
> **Grade**: {A | B | C | D} — see Confidence section for calibration tie-back (I-S7)

## Summary
**Recommendation**: `<USER FILL — THESIS_CANDIDATE | INVESTIGATE | WATCH | PASS>`
**Top question to resolve**: `<USER FILL — one-sentence key uncertainty>`

## Trade-Off Matrix
| Dimension | Verdict | Key Evidence (with source) |
|---|---|---|
| Value | `<STRONG | NEUTRAL | WEAK>` | `<finding + source URL + as-of date>` |
| Quality | `<STRONG | NEUTRAL | WEAK>` | `<finding + source>` |
| Growth | `<STRONG | NEUTRAL | WEAK>` | `<finding + source>` |
| Risk | `<STRONG | NEUTRAL | WEAK>` | `<finding + source>` |

## Quant Summary (numbers from code, never LLM — I-S1)

> Every number below has a `-- query: ...` comment showing the deterministic computation. LLM never produces numbers in prose; LLM only interprets numbers code computed.

- **Current price**: `<value>` VND as of `<YYYY-MM-DD>` `<-- query: SELECT close_amount FROM bars WHERE ticker=... ORDER BY period_end DESC LIMIT 1>`
- **52w range**: `<low>` — `<high>` `<-- query: SELECT MIN(close), MAX(close) FROM bars WHERE period_end > date('now','-365 days')>`
- **Fair Value Range** (Phase 1: skip if Tier 2 fundamentals not ingested; Phase 2+ replaces this section):
  - DCF (WACC `<x>%`, g `<y>%`): `<value>`
  - Graham Number: `<value>`
  - Peer multiples (P/E, P/B avg): implied `<value>`
- **Key Ratios (TTM)** (Phase 2+ — requires BC-2 Fundamental ingestion):
  - P/E: `<x>` (sector avg `<y>`, 5-yr own avg `<z>`)
  - P/B: `<x>`
  - ROE: `<x>%` (sector avg `<y>%`)
  - Debt/Equity: `<x>`
- **Margin of Safety** (vs mid fair value): `<x>%` — Phase 1: N/A
- **Volume profile**: avg daily `<value>` `<-- query: SELECT AVG(volume) FROM bars WHERE ticker=...>`
- **Foreign net flow** (last 30d): `<value>` shares `<-- query: SELECT SUM(foreign_buy - foreign_sell) FROM bars WHERE ... LIMIT 30>` (Phase 1: zero if vnstock VCI source — foreign flow lives in different feed)

## Bull Case (≥1 point Phase 1; ≥3 points target)

1. **`<bull point 1>`** — source: `<URL>`, as-of: `<YYYY-MM-DD>`
2. **`<bull point 2>`** — source: `<URL>`, as-of: `<YYYY-MM-DD>`
3. **`<bull point 3>`** — source: `<URL>`, as-of: `<YYYY-MM-DD>`

## Bear Case (mandatory ≥3 distinct points per I-S10 — system refuses to render thesis without)

> If unable to find 3 substantive bear points after examining context, write that explicitly. "No bear case found" is itself a flag — surface the absence honestly per Charter Principle 3 (Adversarial by design).

1. **`<bear point 1>`** — specific risk + grounded evidence — source: `<URL>`, as-of: `<YYYY-MM-DD>`
2. **`<bear point 2>`** — source: `<URL>`, as-of: `<YYYY-MM-DD>`
3. **`<bear point 3>`** — source: `<URL>`, as-of: `<YYYY-MM-DD>`

## Explicit Disagreements (preserved, NOT collapsed per I-S12)

> When bull and bear reach opposite conclusions on a topic with equal conviction, list the disagreement here. Do NOT vote-average to "HOLD" — surface tension explicitly.

- `<topic>`: bull says `<X>`; bear says `<Y>`. Resolution: pending `<what investigation would settle it>`.
- OR: "No substantive disagreements — perspectives align on `<dimension>`."

## Catalysts Watched (what could trigger re-rating)

- `<catalyst>` — expected by `<YYYY-MM-DD>` — likelihood `<HIGH | MEDIUM | LOW>` — source: `<URL>`

## Risks (what could invalidate thesis)

- `<risk>` — impact `<HIGH | MEDIUM | LOW>` — monitoring via `<source / metric>`

## Invalidation Triggers (thesis dies if any of these)

- `<condition>` — e.g., "P/E exceeds 25x while ROE drops below 12%"
- `<condition>` — e.g., "Foreign-room saturation > 95% sustained for 30 days"
- `<condition>` — e.g., "Management change impacting capital allocation discipline"

## Risk & Position Sizing (deterministic per Charter Principle 10)

> Numbers below come from RiskRule + personal-risk-profile.md, NOT from LLM. LLM cannot override.

- **Max position size**: `<value>%` of portfolio (per personal-risk-profile.md § 2 OR RiskRule default 0.15)
- **Sector exposure after add**: `<value>%` (must stay ≤ personal-risk-profile.md § 2 sector cap)
- **Stop level**: `<value>%` decline from cost OR `<thesis-invalidation>` (per personal-risk-profile.md § 3)
- **Holding period target**: `<months>` (per personal-risk-profile.md § 1)
- **T+2.5 cash check**: `<cleared | pending — entry holds until cash settled>`

## Confidence (calibrated, not LLM-felt — I-S7)

- **Calibration grade**: `<A | B | C | D>`
- **n_samples**: `<integer — count of similar prior theses with outcome data>` (Phase 1: 0 — no calibration baseline yet; Phase 2+ once 5-thesis backfill complete)
- **hit_rate**: `<X.YY>` (Phase 1: N/A; Phase 2+ from calibration database)
- **lookback_period**: `<months>` (Phase 2+)
- **Phase 1 heuristic** (until calibration ready): HIGH = all 3 perspectives strong + agree / MEDIUM = mixed but grounded / LOW = disagreement OR limited evidence

## Reasoning Trace

> How did we arrive at this recommendation? Cite which perspectives support what claim. This is the audit trail.

`<USER FILL — narrative paragraph(s) connecting trade-off matrix → recommendation>`

## Sources Cited (every URL + as-of date)

| # | Source | As-of | Used For |
|---|---|---|---|
| 1 | `<URL>` | `<YYYY-MM-DD>` | `<which claim it supports>` |
| 2 | `<URL>` | `<YYYY-MM-DD>` | `<which claim>` |

## Personal Bias Check (Charter Principle 6 + I-S22)

- **Do I (the user) own this stock?**: `<yes / no>` — if yes, confirmation bias risk HIGH; bear-case rigor must be extra
- **Do I have a public position on this?**: `<yes / no>` — if yes, sunk-cost / consistency bias risk
- **Sector overweight bias?**: `<from personal-risk-profile.md § 5>`
- **Recent gut-vs-system divergence on similar setups?**: `<see thesis-log history>`

## Data Freshness

- **Price data staleness**: `<green <24h | yellow <7d | red >7d>` — last bar at `<YYYY-MM-DD>`
- **Fundamentals**: `<as of period_end YYYY-MM-DD, filed YYYY-MM-DD>` — Phase 2+
- **News**: most recent at `<YYYY-MM-DD>` — Phase 2+

## Post-Mortem Schedule (I-S26)

> Auto-scheduled review at horizon close. Do not skip — missing post-mortems break compounding (calibration depends on outcome data).

- **Horizon close**: `<as_of + horizon_months YYYY-MM-DD>`
- **Post-mortem file**: `agent-workspace/memory/post-mortems/<YYYY-MM-DD>-{TICKER}-horizon{Nm}.md`
- **Cron alert**: BC-8 schedules at horizon - 7 days

---

## Disclaimer (I-S35 mandatory)

*This is a research aid, not financial advice. Decisions and responsibility are yours. Numbers come from code with verified data; narrative comes from LLM interpretation. Past performance does not predict future results. The Vietnamese stock market is structurally volatile — position sizing per personal-risk-profile.md is non-negotiable.*

[Archive thesis ID: `<UUID>`]
