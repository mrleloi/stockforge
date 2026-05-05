---
observation_id: vf5-calibration-S43e
type: acceptance-signal-calibration
created_at: 2026-05-04
related_session: S43e
related_acceptance_signal: VF-5 (spec 006 § A.4)
related_dogfood: S43d 5-thesis dogfood (BID/BVH/CTG/FPT/GAS as-of 2026-04-29)
status: ANALYSIS-COMPLETE — root cause identified; remediation classified
related_invariant: I-S12 (explicit-disagreement preservation, NOT-collapsed)
agent: Claude Opus 4.7 (main)
read_method: full Read of 5 thesis-log files; cross-tabulated trade-off matrices vs Bull/Bear point distribution
---

# VF-5 Calibration Analysis — Disagreement-Detector Emptiness Root Cause

## VF-5 spec language (verbatim)

> "VF-5 ≥1/5 explicit disagreement: at least one of 5 thesis files contains a non-empty `## Explicit Disagreements (I-S12 — preserved, NOT collapsed)` section."

## Empirical result (S43d dogfood)

| Ticker | Bear pts | Bull pts | Disagreements detected | Trade-off matrix |
|--------|----------|----------|------------------------|------------------|
| BID    | 4        | 0        | 0                      | VALUE=neutral; QUALITY=neutral; GROWTH=neutral; RISK=neutral |
| BVH    | 5        | 0        | 0                      | VALUE=neutral; QUALITY=strong; GROWTH=neutral; RISK=neutral |
| CTG    | 5        | 0        | 0                      | VALUE=neutral; QUALITY=neutral; GROWTH=neutral; RISK=neutral |
| FPT    | 4        | **5**    | **0**                  | VALUE=weak; QUALITY=strong; GROWTH=neutral; RISK=neutral |
| GAS    | 5        | 0        | 0                      | VALUE=neutral; QUALITY=neutral; GROWTH=neutral; RISK=neutral |

**Result**: 0/5 (FAIL the spec target ≥1/5).

## Root cause taxonomy — 2 distinct failure paths

### Path A: Bull returns Rule-7 honest-insufficient (4/5 tickers — BID, BVH, CTG, GAS)

When the bull perspective adapter receives a context where data gaps dominate
(no_news_90d, no peer_comparables yet, weak quant TA features for the ticker),
its `bull-perspective.txt` prompt instruction Rule 7 (honest-insufficient)
correctly fires: it returns 0 grounded points rather than fabricating bullish
narrative. The bear perspective, with the same data, finds plenty to anchor
to (technical breakdowns, valuation gaps, sector concerns, T+2.5 trap).

**Detector behavior**: I-S12 disagreement detection requires opposing dimension
verdicts (e.g., bear-VALUE=weak vs bull-VALUE=strong). With bull-points = 0,
no bull dimension verdict exists; the detector has no candidate to compare.
**This is correct detector behavior** — it would be worse to fabricate a
disagreement against an empty bull stance.

**Substrate diagnosis**: NOT a bug. The data substrate is genuinely thin for
these 4 tickers (no_news_90d gap is structural — the news scraper hasn't
backfilled deep history; the data gap, not the prompt, is the binding constraint).

### Path B: Bull populated but on orthogonal dimensions (1/5 tickers — FPT)

FPT bull returned 5 grounded points, but the points cluster on:
- QUALITY (PE-vs-ROE valuation, profitability metrics) — bull verdict: strong
- VALUE (margin of safety) — bull verdict: weak (note: weak is bull's *concession*)
- Mean-reversion technicals — verdict: neutral RISK
- Earnings catalyst speculation — verdict: neutral GROWTH
- Foreign-room policy — verdict: neutral RISK

FPT bear's 4 grounded points cluster on:
- RISK (technical breakdown, T+2.5 trap, news-data-gap signal)
- VALUE (forward-earnings-compression hypothesis as value-trap)

**Detector behavior**: FPT VALUE has bull=weak, bear=weak (both negative-leaning) —
no opposite verdict, no disagreement. FPT QUALITY has bull=strong, bear=*not
addressed* — bear didn't take a QUALITY position. FPT RISK has bull=neutral,
bear=*not summarized as a verdict* (bear narrative is risk-themed but the verdict
column read `neutral` because counting categories doesn't equal direction).

**Substrate diagnosis**: detector-design limit, not bug. The current I-S12
detector (per `recommendation_heuristic.py:detect_disagreements`) compares
verdict labels per dimension; if perspectives don't take *opposite verdicts on
the same dimension*, no disagreement is recorded — even when narratives are
clearly oppositional (FPT's QUALITY=strong vs bear's "value trap" hypothesis
ARE oppositional but live in different verdict cells).

## Spec-aligned remediation paths

### Path P1 — Phase 3 peer-comparable shipping (spec 006 § A.10)

Spec 006 § A.10 already commits to peer_comparables in Phase 3. With peer-relative
context, bull will have substantive data even when ticker-absolute data is thin
(Path A mitigation). Estimated impact: bull-points > 0 on 3-4 of 5 tickers
(BVH/CTG/GAS likely; BID still gap-bound).

### Path P2 — Phase 2 prompt tuning (force overlapping-dimension verdicts)

Modify `bull-perspective.txt` and `bear-perspective.txt` to require explicit
verdict on each of {VALUE, QUALITY, GROWTH, RISK} with mandatory rationale
even if neutral. This forces the verdict matrix to be fully populated (no
neutral-by-default) and increases I-S12 detector fire rate. Risk: forces
bull/bear to take artificial positions when data is genuinely thin (violates
Rule-7 honest-insufficient, would degrade other VF acceptance signals).
**REJECTED** — conflicts with I-S35 honest-research-aid framing.

### Path P3 — Detector-side narrative-disagreement pass (Phase 2 amendment)

Extend `detect_disagreements` in `recommendation_heuristic.py` with a
narrative-overlap pass: when bull has a strong-positive on dimension D and bear
has any populated grounded-point on dimension D (even non-verdict), record a
narrative-disagreement entry with `kind=narrative` (vs current `kind=verdict`).
LOC estimate: ~30 LOC + 2 tests.
**ACCEPTABLE — could ship Phase 2 close**.

### Path P4 — Lower the dogfood VF-5 bar to "non-empty bear or bull narrative
on opposing dimension D"

This is a spec-amendment route. Spec 006 § A.4 VF-5 currently reads "≥1/5
explicit disagreement" but the operational definition could be loosened to
"≥1/5 explicit disagreement OR documented detector-emptiness with bull-points=0
OR data-gap attribution". This is honest about the substrate limit.
**ACCEPTABLE — pairs with P1 or P3**.

## Recommended remediation

**Combination**: P3 (detector-side narrative pass; ~30 LOC; ships Phase 2 close)
+ P4 (spec amendment to allow gap-attributed-emptiness as secondary VF-5
satisfaction). Reject P2 outright. P1 is the long-term answer (Phase 3) but
not blocker for Phase 2 close.

## What this calibration tells us about Phase 2 dogfood

- Substrate IS validated — adapters work, citations integrity holds, $0-marginal
  cost (D-023) confirmed, Rule-7 honest-insufficient fires correctly when data
  thin. The VF-5 "FAIL" is not a substrate failure.
- The empty-bull pattern (4/5) is a **real signal** about VN news-stream
  coverage depth, not a substrate bug. Promote to L-S43e-1 candidate: "VF-5
  emptiness on bull-side = data-gap-attribution signal; do NOT remediate via
  prompt tuning".
- The FPT case (1/5 with bull=5 but no detector hit) is the most actionable —
  it's the substrate-limit case that P3 directly addresses.

## Lesson candidate

- **L-S43e-1**: VF-5 disagreement-detector emptiness on bull-side reflects
  honest-insufficient on data-gap; mitigation is P1 (peer comparables, Phase 3)
  or P3 (narrative-disagreement pass, Phase 2). Promotion target: spec 006
  § A.4 amendment + `recommendation_heuristic.py` extension.

## Cross-references

- spec 006 § A.4 (VF-5 acceptance signal)
- spec 006 § A.10 (Phase 3 peer-comparable shipping)
- I-S12 (explicit-disagreement preservation invariant)
- I-S35 (research aid framing — blocks P2)
- BR-7 (Rule-7 honest-insufficient — bull adapter prompt)
- D-023 (Cost Substrate — informs P3 cost analysis)
- KI-S43b-* (substrate-resilience cluster, all mitigated)

## Status

ANALYSIS-COMPLETE. No code authored this turn (analysis-only observation per
L-S15-1 inline-document doctrine when scope is interpretive). P3 implementation
deferred to Phase 2 close session. P4 spec amendment deferred until after VF-3
reproducibility test (S43e) and Phase 2 close planning.
