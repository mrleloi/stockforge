---
observation_id: track-A-S240-anti-flake-run2
type: live-dogfood-run
session: S240
phase: 4
track: A
created_at: 2026-05-10T12:00:00Z
related_master_plan: agent-workspace/session-plans/pending/008-S235-phase-4-master-plan.md §S239
related_decision: D-053 (A2 retry-validator promoted production default)
related_predecessor: agent-workspace/memory/observations/track-A-S239-anti-flake-run1.md
status: complete-FAILED-GATE
---

# Track A — S240 Anti-Flake LIVE 5-Ticker Dogfood Run #2

> Master-plan §S239 deliverable: complement Run #1 (S239) for SC-1 GREEN-GATE (anti-flake = BOTH runs ≥4/5 with BVH-only-fail allowed). **VERDICT: GATE FAILED**.

## Dispatch Pattern

Per master plan §S239 (same as S239): 1 sync pilot + 4 parallel `run_in_background=true` subprocess CLI dispatches.

| Ticker | My Dispatch ID | Phantom Dispatch ID | Wall-clock |
|---|---|---|---|
| FPT | be3tovanl (sync pilot) | b30ko1l41 | 2026-05-10 11:30 UTC |
| BID | b7ojtpw59 | bn9j76bbk | 2026-05-10 11:42 UTC |
| BVH | b0rx8vu4d | bs0k226qo | 2026-05-10 11:42 UTC |
| CTG | b2ly8zhl0 | bmseq71w2 | 2026-05-10 11:42 UTC |
| GAS | bsuzggvjh | b5uu8qebh | 2026-05-10 11:42 UTC |

**Phantom-dispatch L-S239-4 recurrence (3rd-instance class)**: 5 additional `validate_thesis` CLI runs fired in parallel from outside this parent-session control during S240 window. AP-23 promote-or-retire MANDATE was already triggered by S239 2nd-instance — this 3rd-instance evidence reinforces PRIORITY 7 governance escalation.

## Results Table — SQLite Source-of-Truth

Per L-S239-3 (validate_thesis CLI rows in SQLite are sole gate-tier evidence; markdown view masks `category=None`):

Query: `SELECT thesis_id, ticker, payload_json -> perspectives -> [role=bull] -> key_points FROM theses WHERE created_at >= '2026-05-10T11:30'`.

| Ticker | thesis_id | bull kps | distinct cats | I-S3 | bull_cost | Notes |
|---|---|---|---|---|---|---|
| BID | 19ba272e334637e0 | 4 | FUNDAMENTAL/MACRO/NARRATIVE/VALUATION | **PASS** ✓ | $0.371 | my b7ojtpw59; bull validation fail attempt 1/3 then recovered; bear 1× timeout but eventually rendered |
| BVH (phantom) | 25ce96707c758d8e | 2 | TECHNICAL | FAIL | $0.943 | bull validation-exhausted (3 attempts empty) |
| BVH (mine) | c88b799d4b52e4c6 | 2 | TECHNICAL | FAIL | $1.007 | bull validation-exhausted (3 attempts empty); same hash as S239 phantom-PASS thesis_id but DIFFERENT content — **S239 BVH PASS was non-replicable single-run anomaly** |
| CTG | 9935d3114fef0acd | 3 | COMPETITIVE/GROWTH/VALUATION | **PASS** ✓ | $0.359 | my b2ly8zhl0 (overwrote phantom CTG row); bull validation fail attempt 1/3 then recovered |
| FPT | NOT-PERSISTED | n/a | n/a | FAIL | n/a | both my be3tovanl + phantom b30ko1l41 hit BearCaseInvariantError exit 2 → SQLite write skipped |
| GAS | NOT-PERSISTED | n/a | n/a | FAIL | n/a | both my bsuzggvjh + phantom b5uu8qebh hit BearCaseInvariantError exit 2 → SQLite write skipped |

**S240 Run #2 Gate Tally (canonical CLI / SQLite source-of-truth)**: **2/5 PASS** (BID + CTG only).

## Anti-Flake Gate Verdict

| Run | Tally | Pragmatic gate ≥4/5 |
|---|---|---|
| S239 Run #1 | 4/5 (FPT/CTG/BVH/GAS canonical CLI; BID inline-only) | PASS-PRAGMATIC ✓ |
| S240 Run #2 | **2/5** (BID + CTG only) | **FAIL** ✗ |

**Anti-flake gate (SC-1 GREEN) requires BOTH runs ≥4/5. → SC-1 GREEN CANNOT FIRE on these results.** Phase 4 Track A close BLOCKED.

## Failure Mode Taxonomy (S240 surfaced)

1. **Bear/quant 300s timeout cascade** (DOMINANT mode S240): 3 of 5 tickers hit ≥1 bear timeout. Compounded with bull retry latency under parallel-fanout, BearCaseInvariantError fires exit 2 and SQLite write skipped. Master-plan **R-P4-3 risk REALIZED** ("if compounded retry latency causes parallel-fanout cascade timeout, escalate").

2. **BVH content-gap PERSISTS** (RECONFIRMED): Both BVH attempts in S240 produced 2 bull kps TECHNICAL-only (oversold RSI + SMA200-above mechanical signals). Zero news in 90d, no peer comparables, stale price 5.5d are structural. S239 phantom-BVH 5-cat PASS was non-replicable single-run anomaly. **L-S239-1 retracted**: "BVH-content-gap-NOT-persistent" was wrong; the S236 finding "BVH content-gap persistent" stands. The pragmatic-gate "BVH-only-fail allowed" framing is now empirically grounded.

3. **A2 retry-validator works for bull but no equivalent for bear/quant**: Bull recovers via 3-attempt retry (per D-053). Bear/quant have no retry — single 300s timeout → empty bear → BearCaseInvariantError → exit 2 → no SQLite persist. This asymmetry was hidden in S239 by phantom-dispatch sequential ordering; surfaces in S240 parallel-fanout.

4. **BID cost-cap-breach NOT recurring**: S239 BID $3.18 cost-cap-breach was anomaly (compounded 3-attempt validation-exhausted + bear/quant cascade). My S240 BID cost only $0.371 with 4 kps PASS. So S239 BID was not a "BID-class prompt fragility" — it was a one-off cascade artifact.

5. **Phantom-dispatch ECHO** (AP-23 3rd-instance): 5 phantom CLI dispatches fired this session matching my ticker list (b30ko1l41 / bn9j76bbk / bs0k226qo / bmseq71w2 / b5uu8qebh). Parent-session did NOT initiate these. PRIORITY 7 governance escalation REINFORCED.

## Lessons Surfaced (L-S240-*)

**L-S240-1** (parallel-fanout-bear-timeout-cascade): Bear/quant LLM (sonnet-4-6) saturates under 5+ parallel CLI dispatches in same ~10min window. 300s timeout fires cascadingly. Bull A2 retry-validator successfully recovers most cases (bull pass-rate ≈3-4/5 across runs); bear has no retry layer → cascade timeout → BearCaseInvariantError → exit 2 → SQLite skip. **Architecture gap**: bear-quant should also have retry-validator OR fall-through-to-degraded-bear (e.g. emit explicit "bear: insufficient-data" tagged perspective rather than empty). Phase 4 backlog item.

**L-S240-2** (BVH-content-gap-permanent — L-S239-1 retraction): S239 phantom BVH 5-cat PASS was anomalous; S240 reconfirms S236 finding "BVH content-gap structural" (zero news, no peers, stale price). **Implication**: pragmatic gate ≥4/5 with BVH-only-fail allowed is the correct frame; S239 L-S239-1 retracted.

**L-S240-3** (anti-flake gate def needs amendment): As currently defined ("≥4/5 in BOTH runs"), the gate requires ≥4/5 single-run reliability. Empirical evidence (S239: 4/5; S240: 2/5) shows single-run reliability is ≈40-80% with high variance under parallel-fanout. Either:
(a) **AMEND gate to ≥4/5 cumulative across runs** (S239+S240 union: BID/CTG/FPT/GAS PASS at least once = 4/5 cumulative, BVH-only-fail allowed = SC-1 GREEN under union-rule); OR
(b) **Investigate root-cause bear timeout + retry architecture, then re-run after fix** (Phase 4 backlog priority); OR
(c) **Sequence runs with cooling period to avoid parallel-fanout** — single ticker at a time with 5min lapse. Master-plan should pick one explicitly.

**L-S240-4** (BID prose-emit failure mode NOT BID-class): S239 had BID $3.18 cap-breach + 3-attempt validation-exhausted; S240 BID PASSED on first attempt with $0.37. So BID is not structurally fragile — S239 was tail-event of cascade.

**L-S240-5** (phantom-dispatch 3rd-instance — PRIORITY 7 governance unblocking required NOW): The phantom CLI dispatches recur consistently across S238 (M-S238-2), S239 (L-S239-4), and S240 (this row). 3-instance count is well past AP-23 promote-or-retire MANDATE. The ROOT CAUSE investigation (audit `dispatch.jsonl` + `scheduled_tasks.lock` + check for external-channel originator) MUST happen before further dogfood runs — phantom dispatches are corrupting cost telemetry + SQLite UPSERT semantics + creating ghost rows.

## Cost Tracking

| Ticker | bull_cost (mine) | full thesis cost (mine) | within $3 cap |
|---|---|---|---|
| FPT | n/a (bear-fail) | exit 2 — partial cost ~$1-2 | YES |
| BID | $0.371 | $1.444 | YES ✓ |
| BVH | $1.007 | $1.929 | YES ✓ |
| CTG | $0.359 | $1.337 | YES ✓ |
| GAS | n/a (bear-fail) | exit 2 — partial cost ~$1-2 | YES |
| **Subtotal Run #2 (3 persisted CLI runs)** | $1.737 | $4.710 | YES |

Imputed total (all 10 dispatches: 5 mine + 5 phantom): ~$10-15 (each run $1-2 imputed). Within $7.50-15.00 envelope from S239 plan.

## Pre-existing Caveats (carried forward from S239)

- Bear/quant 300s timeout — **NOW ESCALATED from caveat to dominant fail-mode** (L-S240-1).
- Phantom-dispatch governance — **NOW 3rd-instance escalation** (L-S240-5).

## S240 Final Status

- **2/5 PASS** via canonical CLI (BID + CTG); 3/5 FAIL (FPT/BVH/GAS).
- **Anti-flake gate (S239 + S240) FAILED**. SC-1 GREEN does NOT fire.
- Phase 4 Track A close BLOCKED.
- **5 lessons surfaced** (L-S240-1..5).
- 0 mistakes this session (per AP-23 — calibration findings ≠ agent-execution mistakes).
- 0 production code edits. 0 ADR. 0 settings.json. 0 hooks. 0 charter writes. 0 git commits.

## Recommended NEXT Actions (S241+)

1. **PRIORITY 1 (BLOCKING)**: Bear/quant retry-validator architecture (L-S240-1). Mirror A2 pattern for bear+quant. Phase 4 mid-stream IMPL session needed.
2. **PRIORITY 2 (BLOCKING)**: Phantom-dispatch root-cause investigation (L-S240-5; PRIORITY 7 governance) — audit `dispatch.jsonl` + `scheduled_tasks.lock` + check Stop-hook/scheduled-task originators. Without this, future dogfood runs are corrupted.
3. **PRIORITY 3 (decision-tier)**: Master-plan §S239 acceptance gate AMENDMENT (L-S240-3 options a/b/c) — escalate to user as SCOPE-tier decision.
4. **PRIORITY 4** (parallelizable): Track B 3-platform LIVE smoke (master-plan §S240) — does NOT depend on Track A close.
