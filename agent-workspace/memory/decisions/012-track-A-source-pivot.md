---
id: D-012-track-A-source-pivot
title: Track A — R2 closure via SSI iBoard direct (A3 strategy); TCBS public API permanently retired
date: 2026-04-30
status: ACCEPTED
level: IMPL

author:
  - "Claude Opus 4.7"
  - session: S32

source_evidence:
  - path: agent-workspace/session-plans/pending/005-S31-phase-2-master-plan.md
    section: "Track A — R2 Closure (BLOCKER for Track B); Strategy options A1/A2/A3/A4"
    quote: "A1 Discover working TCBS endpoint / A2 Pivot to DNSE or KBS via vnstock 4.0.2 alternate sources / A3 SSI / VnDirect public API direct (skip vnstock wrapper; httpx adapter à la TcbsAdapter) / A4 Accept SCOPE-tier deviation. Recommended A2 first."
  - path: agent-workspace/memory/checkpoints/phase-1-thin-slice-S29-verdict.md
    section: "R2 (LOW) — TCBS 404 → live smoke 248 SINGLE_SOURCE rows only"
  - path: agent-workspace/memory/decisions/008-track-9-self-awareness-reduced.md
    section: (precedent for IMPL-tier 12-field decision schema)
  - path: agent-workspace/constitution/financial-data-protocol.md
    section: "Rule 4: Source Attribution & Reconciliation"
    quote: "If only one source: that's the truth. ... If sources agree (within 1% tolerance): truth = average, confidence = HIGH"
  - path: data/vn30-coverage-S32.md
    section: "Backend probe summary"
  - path: data/vhm-reconciliation.md
    section: "Window 2025-04-30 → 2026-04-29; 248 HIGH, 0 LOW, 0 SINGLE_SOURCE"
  - path: data/vn30-probe-ssi.json
    section: "SSI iBoard 30/30 VN30 coverage"

related_user_prompt: SessionStart hook auto-resume (S32 entry per master-plan 005 § S32; user "continue" 2026-04-30 establishing autonomous-mode loop)

binding_phase: 2 (Phase 2 IMPL — Track A; supersedes IMPL-S28-3 deferred-Phase-2 disposition)

related_decisions:
  - D-011 (Phase 2 entry SCOPE-tier — Track A is first IMPL session of Phase 2)
  - IMPL-S28-1 (vnstock 4.0.2 dropped TCBS as Quote source — primary anchor for ladder)
  - IMPL-S28-3 (TCBS smoke-run 404 → Phase 2 hardening item; D-012 closes this carry)

---

## Decision

**Track A R2 closure executed via Strategy A3 — SSI iBoard direct httpx
adapter.** Ship a NEW `SsiAdapter` (`packages/infrastructure/market_data/
ssi_adapter.py`) implementing `BarProviderPort` against `https://iboard-api.
ssi.com.vn/statistics/charts/history`. Pair with existing `VnstockAdapter`
(VCI source) for Rule 4 dual-source reconciliation. Retire `TcbsAdapter`
to graceful-fail archive role; do not delete (preserve test coverage +
re-enablable if TCBS restores public endpoint in a future Phase).

`apps/cli/ingest_vhm.py` rewired: VnstockAdapter (primary VCI) +
SsiAdapter (primary alternate iBoard) + TcbsAdapter (graceful-fail
archive). Reconciliation runs over Vnstock × SSI; TCBS output ignored.

---

## Options considered

### Option A1 — TCBS endpoint archaeology (REJECTED)

Probe v1/v2 paths, alternate endpoint names, alternate base hosts. All
four URL variants tested (`apipubaws.tcbs.com.vn/stock-insight/{v1,v2}/
stock/{bars,bars-long-term}`) return HTTP 404 with identical body
length 44 — the entire `stock-insight` family appears retired, not
just one endpoint. No public TCBS replacement endpoint identified
within S32 budget. **REJECTED**: dead-end probe, indefinite engineering
debt.

### Option A2 — vnstock alternate Quote source backends (REJECTED)

vnstock 4.0.2 `Quote(symbol, source=...)` enumerated backends: VCI /
TCBS / MSN / DNSE / SSI / FMARKET. Empirical probe results:

- VCI: constructs + fetches successfully (10 rows for VHM 10-day window)
- MSN: constructs but `RetryError[ConnectionError]` on `.history()` —
  endpoint behind a connection block in the host network
- TCBS / DNSE / SSI / FMARKET: `ValueError` on `Quote()` construction —
  these source identifiers were deprecated as Quote backends in 4.0.2
  per IMPL-S28-1 anchor

Effective vnstock surface: VCI-only. Not enough for Rule 4 dual-source.
**REJECTED**: identical to current single-source state.

### Option A3 — SSI public iBoard API direct (PICKED)

`https://iboard-api.ssi.com.vn/statistics/charts/history` is a
TradingView-compatible chart-history endpoint that the SSI iBoard web
client uses for retail price chart rendering. Probe results:

- HTTP 200 across all 30 VN30 tickers
- Payload shape: `{"code":"SUCCESS","data":{"t":[...],"o":[...],
  "h":[...],"l":[...],"c":[...],"v":[...]}}` — TradingView shape
- 248 trading-day rows per ticker for 2025-04-30 → 2026-04-29 window
- Prices in **thousand VND** (matches VnstockAdapter convention; no
  unit-conversion delta)
- No advertised rate-limit; 0.3 RPS observed clean across 30 tickers

**PICKED**: lowest implementation cost (one new ~180-LOC adapter
mirroring TcbsAdapter pattern), highest live coverage (100% VN30),
preserves existing BarProviderPort contract, no domain or contracts
layer changes required.

### Option A4 — SCOPE waiver to single-source (NOT INVOKED)

Reserved for fallback if A1+A2+A3 all fail. A3 met success criterion
on first probe; A4 unused.

---

## Implementation summary

| File | Change | LOC |
|---|---|---|
| `packages/infrastructure/market_data/ssi_adapter.py` | NEW | 180 |
| `packages/infrastructure/market_data/__init__.py` | EDIT — export SsiAdapter + SsiApiError; re-document module deliverables | 30 → 36 |
| `packages/infrastructure/market_data/tcbs_adapter.py` | EDIT — module docstring deprecation note (D-012 cross-ref) | 191 → 197 |
| `apps/cli/ingest_vhm.py` | EDIT — wire SsiAdapter as primary alternate; preserve TcbsAdapter graceful-fail | 127 → 144 |
| `packages/infrastructure/market_data/test_adapters.py` | EDIT — +13 SsiAdapter tests + 3 cross-source reconciliation tests | 290 → 449 |
| `data/vn30-coverage-S32.md` | NEW — coverage probe + smoke results | 95 |
| `data/vn30-probe-ssi.json` | NEW (data artifact) — raw 30/30 SSI probe | 35 |
| `agent-workspace/memory/decisions/012-track-A-source-pivot.md` | NEW (this file) | ~165 |

Test results:
- 16 NEW PASS (`TestSsiAdapter` 13 + `TestCrossSourceReconciliation` 3)
- 198 PASS total (was 182; +16; 0 regressions)
- 0 mypy --strict --explicit-package-bases errors on changed files
- 0 ruff errors across `packages/` + `apps/`
- D1 baseline still 0

Live smoke (`ingest_vhm` 1-year backfill):
- 248 vnstock bars + 248 SSI bars = 496 rows persisted
- Reconciliation: **248 HIGH, 0 LOW, 0 SINGLE_SOURCE** — was 248 SINGLE_SOURCE pre-S32
- TCBS still 404 (graceful-fail logged, not blocking)

---

## Why not refactor VnstockAdapter to parameterize the source backend

S31 master-plan § Track A Recommended A2 first (vnstock alternate
sources). Empirical probe rejected this — only VCI works, so a
parameterized VnstockAdapter would still produce single-source output
in practice. Keeping VnstockAdapter hardcoded to VCI matches the
"what the adapter actually fetches" semantic; adding a `source` param
that only works for one value would be deceptive.

If MSN (or future re-enabled backends) become reachable in a later
Phase, parameterization remains a low-risk additive change at that
point — not premature now.

---

## Why TCBS adapter retained (not deleted)

1. **Test fixtures still pass** (5 TcbsAdapter tests cover error paths
   that document the contract; deletion would lose those probes).
2. **Re-enablable**: if TCBS publishes a working public endpoint in
   the future, swapping the URL constant + verifying response shape
   restores the path with zero domain or test churn.
3. **Audit trail**: graceful-fail wiring in `ingest_vhm.py` keeps
   "TCBS reachable?" as an observable per-run signal — silent
   removal would mask future endpoint resurrection.
4. **Module docstring updated** with explicit `DEPRECATED at S32 per
   D-012` banner so future readers cannot accidentally treat it as
   live infrastructure.

---

## Implications for S33+ (Track B VN30 expansion)

- `apps/cli/ingest_vn30.py` (NEW at S33) MUST use VnstockAdapter +
  SsiAdapter pair; do not wire TcbsAdapter into the VN30 path
- Default `--rate-limit-rps 0.3` (vnstock guest tier 20 req/min cap)
- Handle vnstock `Rate Limit Exceeded` payload via retry-once-after-30s
- SSI iBoard rate limit not advertised; observed clean at 0.3 RPS for
  30-ticker probe; default 1 RPS with backoff-on-429 acceptable
- Extension to fundamentals (S34 BC-2): SSI iBoard does NOT expose
  fundamental statements; vnstock `Finance` API + Vietstock public
  scrape remain the candidates per master-plan § Track C; D-012 does
  not pre-decide fundamentals strategy

---

## Drift / DR sweep

- **DR1**: 0 (no skill / command / agent files touched at S32)
- **DR4 SPEC-DANGLING-REF**: 0 (D-012 references existing files only)
- **DR9**: 1 pre-existing carry-over unchanged (`metric-failure-mode-rate.sh`)
- **DR-PROV**: every S32 artifact maps to user "continue" + master-plan
  005 § S32 Track A + S29 R2 residue + financial-data-protocol Rule 4
- **DR-CONFIG**: 0 (no settings.json edits)
- **DR-IDENTITY**: stockforge identity preserved
- **LLM-math creep grep**: 0 hits in NEW + EDITED files (D-012 + ssi_adapter +
  ingest_vhm + tests use only Decimal arithmetic + array indexing)

---

## Carry-over for S33

- VCI guest-tier rate limit (20 req/min) is a hard ceiling; ingest_vn30
  must respect it
- TCBS adapter graceful-fail wiring stays in CLI but drops out of
  reconciliation — VN30 ingestion runs over VCI × SSI only
- Sàn-tier reconciliation tolerance (HOSE ±1% / HNX ±2% / UPCoM ±5%
  per amendment-VN Rule 14) still IMPL-config; VN30 = HOSE-only so
  per-Sàn dispatch deferred until first non-HOSE ticker enters scope
