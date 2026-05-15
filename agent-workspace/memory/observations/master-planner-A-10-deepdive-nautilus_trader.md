---
observation_id: master-planner-A-10-deepdive-nautilus_trader
session: S323-A-phase-a-deepdive
agent: general-purpose
date: 2026-05-15
repo: nautilus_trader
repo_path: C:/htdocs/research/nautilus_trader/
fit_level_hypothesis: HIGH
fit_level_empirical: HIGH (confirmed)
license: LGPL-3.0 (LICENSE:1 — "GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007"; per-file headers `Copyright (C) 2015-2026 Nautech Systems Pty Ltd. All rights reserved.` consistently cite LGPL-3.0)
prior_harvest: W0-1 FSM (ported S311 PASS S312); W0-1b re-escalation + 7-col schema (ported S313 PASS S314); W0-2 D-059 Python determinism (S315/S316)
pending_harvest: W0-2.1 (production-code violations fix — 2 confirmed live)
---

## 0. Lost S259 reconstruction — re-survey of prior deep-dive claims

S259 deep-dive observation file was deleted (per `agent-workspace/memory/post-mortems/2026-05-14-mass-deletion-recovery.md` §1b). Re-confirming all source claims by re-reading actual nautilus_trader files:

### 0.1 W0-1 source claim — "8-state observation-lifecycle FSM"

**Status: PARTIALLY-CONFIRMED with adaptation note.**

nautilus_trader does NOT have an "8-state observation lifecycle". The cited source is the **generic FSM substrate + the `ComponentState` / `OrderStatus` enums and their state-transition tables**, which stockforge adapted (down-sampled) to 8 states for the lifecycle of dispatched subagent observations.

Concrete sources re-verified:

1. **Generic FSM substrate** — `C:/htdocs/research/nautilus_trader/nautilus_trader/core/fsm.pyx:41-130`
   - `cdef class FiniteStateMachine` (line 41): generic state-transition-table-driven FSM
   - `__init__` (lines 71-91): takes `dict state_transition_table not None`, `int initial_state`, optional `trigger_parser` + `state_parser` callables
   - `cpdef void trigger(self, int trigger)` (lines 108-129): dict lookup `(state, trigger) -> next_state`; raises `InvalidStateTrigger` if not in table

2. **OrderStatus FSM (14-state)** — `C:/htdocs/research/nautilus_trader/nautilus_trader/model/orders/base.pyx:99-164`
   - `_ORDER_STATE_TABLE` dict (lines 101-164): explicit transition pairs including `INITIALIZED → SUBMITTED`, `SUBMITTED → ACCEPTED`, `ACCEPTED → PARTIALLY_FILLED → FILLED`, with branches for `DENIED`, `REJECTED`, `CANCELED`, `EXPIRED`, `PENDING_UPDATE`, `PENDING_CANCEL`, `TRIGGERED`
   - 14 OrderStatus enum members at `model/enums.py:383-397`

3. **ComponentState FSM (14-state)** — `C:/htdocs/research/nautilus_trader/nautilus_trader/common/component.pyx:1614-1677`
   - `_COMPONENT_STATE_TABLE` (lines 1614-1642): `PRE_INITIALIZED → READY → STARTING → RUNNING → STOPPING → STOPPED → DISPOSING → DISPOSED`, plus `RESETTING`, `RESUMING`, `DEGRADING/DEGRADED`, `FAULTING/FAULTED`
   - `cdef class ComponentFSMFactory` (line 1644): static `get_state_transition_table()` + `cdef create()` factory returning `FiniteStateMachine`

4. **Stockforge adaptation** — `C:/htdocs/stockforge/packages/domain/observation_lifecycle/fsm.py:1-80`
   - Docstring at line 4 explicitly cites: "Source: general-purpose-S259-deepdive-nautilus_trader.md §1.9 and architecture.md:344-403"
   - `class State(StrEnum)` (lines 61-75): 8 states `INITIALIZED, DISPATCHED, IN_FLIGHT, OBSERVATION_WRITTEN, SIDECAR_ATTESTED, RECTIFIED, ORPHANED, RESOLVED`
   - Pure Python dataclass + StrEnum (line 38: "Pure Python dataclass + enum (ZERO framework dependency — architecture.md hard rule)")

**Reconstruction note**: The original S259 claim of "8-state FSM ported from nautilus_trader" is technically that the **FSM substrate** was ported (the `(state, trigger) → next_state` table-driven pattern), not the 8 specific states. The 14-state OrderStatus / ComponentState were collapsed/renamed to fit stockforge's 8 observation-lifecycle phases.

### 0.2 W0-1b source claim — "re-escalation + col7 last_transition_at schema"

**Status: NOT directly from nautilus_trader.** The 7-column TSV schema and `is_orphan_candidate()` rule using `col7 = last_transition_at` (not `col1 = detected_ts`) is a stockforge-specific fix per `agent-workspace/session-plans/.../013-S313-wave-0-W0-1b-orphan-reescalate-and-schema-fix.md` D2+D3 (cited at `packages/domain/observation_lifecycle/fsm.py:44`). Nautilus FSM doesn't track "age" — its events fire from external triggers via `MessageBus`. The re-escalation pattern is original to stockforge's harness substrate (not borrowed code; borrowed the FSM-table pattern only).

### 0.3 W0-2 source claim — "Python determinism / no-naive-datetime doctrine"

**Status: CONFIRMED.** Sources re-verified:

1. **DST doctrine document** — `C:/htdocs/research/nautilus_trader/docs/concepts/dst.md:1-200`
   - Title (line 1): "DST" = Deterministic Simulation Testing
   - Banned patterns enumerated (lines 119-136): seed-controlled runtime, banned wall-clock reads
   - Static enforcement (lines 138-180): pre-commit hook `.pre-commit-hooks/check_dst_conventions.sh`

2. **Pre-commit hook (the actual enforcement)** — `C:/htdocs/research/nautilus_trader/.pre-commit-hooks/check_dst_conventions.sh:1-50`
   - Lines 4-16: 6 explicit ban rules — Rule 1: "No direct std::time::Instant::now(), std::time::SystemTime::now(), or chrono::Utc::now() reads"; Rule 2: "No raw RNG entries… without cfg gating"; Rule 3: unbiased `tokio::select!`; Rule 4: raw thread spawning
   - Line 34: `ALLOW_MARKER="dst-ok"` inline exception marker (1:1 parallel with stockforge's W0-2 hook design)

3. **UTC enforcement helper** — `C:/htdocs/research/nautilus_trader/nautilus_trader/core/datetime.pyx:217-301`
   - `cpdef bint is_datetime_utc(datetime dt)` (line 217): "Return a value indicating whether the given timestamp is timezone aware UTC."
   - `cpdef bint is_tz_naive(time_object)` (line 262): explicit naive-tz detector
   - `cpdef datetime as_utc_timestamp(datetime dt)` (line 280): "Ensure the given timestamp is tz-aware UTC." Localizes naive to UTC, converts non-UTC to UTC

4. **Clock abstraction (the "no datetime.now()" enabler)** — `C:/htdocs/research/nautilus_trader/nautilus_trader/common/component.pyx:129-236`
   - `cdef class Clock` (line 129): abstract base, `cpdef datetime utc_now()` (line 226) always tz-aware via `pd.Timestamp(self.timestamp_ns(), tz=pytz.utc)` (line 236)
   - `cdef class TestClock(Clock)` (line 622) + `cdef class LiveClock(Clock)` (line 838): only call sites that actually source "now". All production code injects a `Clock` dependency instead of calling `datetime.now()` directly.

**Audit evidence**: Grep across the entire `nautilus_trader/` Python package found only **3 `datetime.now(` call sites total** (`adapters/interactive_brokers/parsing/instruments.py:1047-1050` — all 3 use `tz=datetime.UTC`, none naive). The discipline is real and enforced at scale.

### 0.4 Other patterns claimed in S259 — still accurate?

Patterns plausibly cited in the lost S259 file that remain valid sources:
- **Event-driven architecture** (Pub/Sub + Req/Rep) — `docs/concepts/architecture.md:17-23` lists explicitly
- **Crash-only design** — `docs/concepts/architecture.md:62-80`
- **Fixed-precision arithmetic for Price/Quantity/Money** — `model/objects.pyx:91-170` (Quantity uses uint64/uint128 raw storage; 16-decimal precision; no float arithmetic in domain types). This is a direct enabler of stockforge's "NO LLM math" charter rule (Principle 10).

---

## 1. Repo Summary

NautilusTrader is an **open-source, production-grade, Rust-native event-driven trading engine** with Python control-plane bindings via PyO3 (migrating from Cython). The README (`C:/htdocs/research/nautilus_trader/README.md:30-44`) frames it as: "research, deterministic simulation, and live execution within a single event-driven architecture", with "the same execution semantics and deterministic time model… in both research and live systems" — i.e., research-to-live parity is the central design goal.

Key facts:
- **License**: LGPL-3.0 (LICENSE:1-30; per-file headers consistent)
- **Languages**: Rust core (24 crates in `crates/`) + Python bindings (Cython `.pyx/.pxd` + PyO3) under `nautilus_trader/`
- **Stockforge-relevant Python sub-packages**: `core/` (FSM, datetime, uuid), `common/` (Clock, MessageBus, Component, Throttler), `model/` (Price/Quantity/Money + Order/Position + FSM tables), `risk/` (deterministic risk engine), `backtest/` (BacktestEngine), `indicators/` (technical indicator interface), `trading/` (Strategy base class), `data/` (DataEngine + TimeRangeGenerator), `portfolio/`
- **Scale**: 24 Rust crates + 22 Python sub-packages; mature, broad adapter coverage (AX, Betfair, Binance, Coinbase, BitMEX, Bybit, Databento, Deribit, dYdX, Hyperliquid, Interactive Brokers, Kraken, OKX, Polymarket, Tardis — `README.md:103-122`)

---

## 2. Architecture / Design Patterns

The framework employs (per `docs/concepts/architecture.md:17-23`):

- **Domain-Driven Design (DDD)** — bounded contexts visible in package layout (`model/`, `risk/`, `portfolio/`, `execution/`, `trading/`)
- **Event-driven architecture** — central `MessageBus` (`common/component.pyx:2215+`) with Pub/Sub, Req/Rep, point-to-point endpoints; topic wildcards `*` and `?`
- **Messaging patterns** — explicit Pub/Sub topic hierarchies (e.g., `events.order.*`, `events.position.*` subscribed by `RiskEngine` at `risk/engine.pyx:190-191`)
- **Ports and Adapters (Hexagonal)** — `Strategy` (`trading/strategy.pyx:109+`) is the domain port; venue adapters in `adapters/binance/`, `adapters/ib/`, etc. plug into the same `ExecutionClient` interface
- **Crash-only design** — `docs/concepts/architecture.md:62-80`: "Startup and crash recovery share the same code path"; "Idempotent operations"; "Fail-fast for unrecoverable errors"

High-level: **Rust core for deterministic hot path** (matching engine, FSM, time-event accumulator) + **Python control plane for strategy logic + orchestration**. Strategies are pure Python (`cdef class Strategy(Actor)` at `trading/strategy.pyx:109`), business logic stays accessible while critical execution semantics are bitwise-reproducible (per DST contract).

---

## 3. Components / Features candidate for StockForge adoption

### 3.1 Event-driven MessageBus pattern (Theme M candidate — DEFERRED past Wave 1)
- **Source**: `nautilus_trader/common/component.pyx:2215-2340`
- **What**: Generic pub/sub + req/rep + point-to-point endpoint registry; wildcard topic patterns; backing-database hook (Redis-compatible); decoupled producer/consumer
- **Stockforge fit**: BC-1 ↔ BC-8 ↔ BC-9 event flow ("Phase 2+ consider event-driven across BCs with proper broker" — charter). Direct architectural template. Not Wave 1 (per master-plan § 4.10 Theme M deferred).
- **Risk**: Heavy (3000+ LOC, threading model, Redis dependency). Don't port wholesale; extract the topic-wildcard subscription resolution + endpoint dispatcher concepts; build stockforge-sized equivalent.

### 3.2 Strategy/Indicator interface boundaries (BC-8 indicators)
- **Strategy base** — `trading/strategy.pyx:109-200`: thin abstract base over `Actor`; `oms_type`, `external_order_claims`, lifecycle hooks; OMS types `HEDGING` / `NETTING`
- **Indicator base** — `indicators/base.pyx:21-78`: abstract `cpdef void handle_quote_tick / handle_trade_tick / handle_bar`; `has_inputs` + `initialized` ready flags; `cpdef void _reset()` for stateful reset
- **Stockforge fit**: BC-8 (Analysis & Thesis) needs perspective-as-class structure. The `Indicator` pattern (input handler + initialized flag + reset) maps cleanly to "perspective inputs → claim score" with deterministic reset for backtest.

### 3.3 BacktestEngine architecture (Charter Month-12 criterion)
- **Source**: `nautilus_trader/backtest/engine.pyx:217-280`
- **What**: `TimeEventAccumulator_API` heap-based event scheduling; deterministic clock via `TestClock`; venue simulation via `SimulatedExchange`; result aggregation via `BacktestResult`
- **Stockforge fit**: Charter Month-12 success criterion "demonstrable alpha vs VN-Index on dogfood portfolio" requires a backtest engine. Nautilus's architecture (heap-priority time events + deterministic clock injection + venue simulation) is a proven blueprint. Adapt: replace tick-level simulation with bar-level (VN market data granularity is end-of-day for most retail signals).
- **Risk**: Don't try to port the Rust `TimeEventAccumulator` (Cython FFI); reimplement in pure Python with `heapq` (Python stdlib). The architectural shape transfers, the FFI does not.

### 3.4 Risk engine deterministic-rules pattern (Charter Principle 10)
- **Source**: `nautilus_trader/risk/engine.pyx:77-200, 569-628`
- **What**: Pre-trade checks via `_check_order` → `_check_order_price` → `_check_order_quantity` → `_check_orders_risk` chain. **Every rejection is code-driven, never an LLM call.** Three `TradingState` modes: `ACTIVE / REDUCING / HALTED`. Throttlers via `common/component.pyx Throttler` enforce `max_order_submit_rate`. Per-instrument `max_notional_per_order` dict (line 180).
- **Stockforge fit**: **Direct match to charter Principle 10** ("Position sizing & risk management are deterministic — code-enforced rules, LLM cannot override"). The pattern: structured `RiskEngineConfig` → loaded rules → check chain that returns `False` (denied) with `_deny_order` reason logging. Port to BC-9 (Portfolio & Action) directly.
- **Code-port viability**: HIGH. The pattern is generic; the Cython-specific types (`cdef class`, `cpdef bint`) translate cleanly to Python `class` + type hints + `bool`.

### 3.5 W0-2.1 fix guidance from nautilus_trader's own production-code style

Nautilus already does W0-2.1 right at scale — across the entire `nautilus_trader/` Python package, only 3 `datetime.now(` call sites exist (all in `adapters/interactive_brokers/parsing/instruments.py:1047-1050`, all `tz=datetime.UTC`). The discipline: **inject a `Clock` and call `clock.utc_now()`**, never call `datetime.now()` directly.

Stockforge pending violations (re-confirmed live):
- `packages/application/crowd/use_cases/capture_sentiment_snapshot_use_case.py:114` — `default_factory=lambda: lambda: datetime.now(UTC)` (R2 main-block-context heuristic miss)
- `packages/infrastructure/analysis/sqlite_thesis_repository.py:206` — `else datetime.now()` (R1 bare-parens — naive datetime, the worse case)

**Fix pattern** (mirror nautilus): inject a `clock: Callable[[], datetime]` parameter (use case constructor) or `Clock` port (repository). Call `clock()` / `clock.utc_now()`. Default factory in tests via fixture; production wires `datetime.now(UTC)` once at the composition root. Single-source-of-now.

---

## 4. Per-BC Mapping

| BC | Match strength | Sources | Notes |
|---|---|---|---|
| **BC-1 Market Data** | HIGH | `nautilus_trader/data/`, `nautilus_trader/model/data.pyx` (QuoteTick, TradeTick, Bar), `nautilus_trader/persistence/` | Bar/tick canonical types; `TimeRangeGenerator` from `data/engine.py`; high-precision time-series doctrine (nanosecond UNIX timestamps). Direct architectural fit. |
| **BC-9 Portfolio & Action** | HIGH | `nautilus_trader/portfolio/`, `nautilus_trader/risk/engine.pyx`, `nautilus_trader/backtest/engine.pyx` | Backtest engine arch (Month-12 criterion); deterministic risk-engine rules pattern (Principle 10); position lifecycle (`model/position.pyx`). |
| **BC-8 Analysis & Thesis** | MEDIUM | `nautilus_trader/indicators/base.pyx`, `nautilus_trader/trading/strategy.pyx` | Indicator interface boundary (input handler → state → reset) maps to perspective-as-class. Strategy actor lifecycle pattern transfers, but BC-8 needs multi-perspective adversarial (not single-decision OMS) — adapt, don't copy. |
| **Harness substrate (cross-cutting)** | HIGH | `nautilus_trader/core/fsm.pyx`, `nautilus_trader/common/component.pyx Clock`, `docs/concepts/dst.md` + `check_dst_conventions.sh` | Theme F: FSM substrate (W0-1 done); Clock-injection doctrine (W0-2 done); pre-commit hook discipline pattern (W0-2.1 pending fix only — 2 violations live). |
| **BC-2/3/4/5/6/7 (data/news/macro/influence/crowd/reports)** | LOW | n/a | nautilus is asset-class-agnostic but information-flow agnostic. No claim-extraction, no source-citation, no calibration tracking. These BCs source from TradingAgents / extraction-frameworks, not nautilus. |

---

## 5. Honest Fit Assessment

**Empirical FIT: HIGH** — confirms master-plan § 4.10 hypothesis.

What nautilus_trader uniquely provides to stockforge:
1. **Deterministic time + FSM substrate** for the harness layer (W0-1, W0-2 already harvested; W0-2.1 pending mechanical fix)
2. **Risk-engine pattern** (BC-9; charter Principle 10 enabler — high-confidence port candidate for Wave 2+)
3. **Backtest-engine architectural blueprint** (BC-9; Month-12 criterion enabler — Wave 2+ blueprint, not direct port due to Cython/Rust FFI)
4. **MessageBus event-driven topology** (Theme M; Phase 2+ candidate — DEFERRED, ADR-first before any code touches BCs)

Candidate new themes (deferred Theme M elements that could feed a future Wave):
- **Theme M-1 (Wave 2 candidate)**: Deterministic risk-engine port — chain-of-checks pattern + TradingState modes + Throttler. Direct Principle 10 implementation. LOW risk (pure Python translation of cdef class).
- **Theme M-2 (Wave 2-3 candidate)**: BC-1 ↔ BC-9 minimal event-bus — extract topic-wildcard + endpoint registry from `common/component.pyx MessageBus` (lines 2215-2400). Drop Redis backing and threading complexity. Pure Python pub/sub for in-process event flow.
- **Theme M-3 (Wave 3+ candidate)**: Backtest engine skeleton — heapq-based time-event scheduler + injected `Clock` + venue simulator. Bar-granularity (not tick) for VN market. Month-12 criterion enabler.

What nautilus_trader does **NOT** provide:
- Anything related to information extraction, claim citation, source provenance, sentiment, or thesis synthesis. BC-2 through BC-7 do not source from this repo.
- LLM integration patterns. Nautilus is a deterministic engine; the AI layer is out-of-scope per their ROADMAP (`README.md:140-142`: "UI dashboards, distributed orchestration, and built-in AI/ML tooling are out of scope").

---

## 6. License + Attribution

**License**: LGPL-3.0 (LICENSE:1-2 confirms "GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007").

**LGPL implications for stockforge**:
- LGPL allows linking from non-(L)GPL applications, so stockforge using nautilus_trader as a library (e.g., via pip) is fine for a closed-source product — IF stockforge ever distributes binaries (charter says single-tenant + 3-5 trusted peers, so distribution is likely zero or minimal).
- Modifications to LGPL-covered code must themselves be LGPL'd and contributed back upstream OR shipped with source. **Implication**: if we *copy* code from nautilus_trader into stockforge, the copied code remains LGPL-3.0 and must be attributed + source-available.
- The cleanest pattern: **pip-install nautilus_trader as a dependency** rather than vendoring code, when we adopt e.g. the FSM substrate or Clock pattern. Existing W0-1 port re-implemented from scratch (pure Python dataclass, not Cython) — that's a derivative work in concept but not in code, and the docstring already attributes the source (`fsm.py:4` cites "Source: general-purpose-S259-deepdive-nautilus_trader.md §1.9").
- For Wave 2+ theme M-1 (risk engine), **strongly recommend re-implementing the pattern in pure Python from the architectural shape**, not copying Cython code line-by-line. Attribution in module docstring is mandatory.

**Per-file copyright header** (consistent across all files inspected): `Copyright (C) 2015-2026 Nautech Systems Pty Ltd. All rights reserved. // Licensed under the GNU Lesser General Public License Version 3.0`.

**Attribution mandatory for any code-port**: cite `nautilus_trader/<file>:<line-range>` in stockforge module docstring (precedent already set in `packages/domain/observation_lifecycle/fsm.py:4`).

---

## 7. Risks / Anti-patterns to avoid

### 7.1 Over-port risk (P2 violation candidate)
Nautilus is a **general-purpose multi-venue multi-asset algo-trading framework**; stockforge is a **single-tenant Vietnamese stock advisory** for a project owner + 3-5 trusted peers. The framework is 24 Rust crates + 22 Python sub-packages. Porting more than the minimum architectural shape violates Karpathy Principle 2 (Simplicity First) — "If 200 lines could be 50, rewrite."

**Specific risks**:
- Don't port `Throttler`, `ExecutionAlgorithm`, `EmulatedOrder`, `ContingencyType` (OCO/OUO/OTO orders), `TrailingStopMarket/Limit`, `AccountType`-multi-asset abstractions. These exist for venue heterogeneity stockforge doesn't have.
- Don't port the Rust FFI layer (PyO3, Cython `.pyx`). Pure Python is mandatory for stockforge per `architecture.md` (charter: domain layer has ZERO framework dependency).
- Don't adopt high-precision (128-bit Money) — single VN-market, single currency, Decimal sufficient.

### 7.2 LGPL surface-area risk
If we ever distribute a binary that statically links nautilus_trader (or vendors its code), LGPL obligations attach. **Mitigation**: keep nautilus as a `pip install` dependency only (dynamic link); never vendor code; cite-by-pattern (architectural reference) for code we write ourselves.

### 7.3 Premature event-driven adoption
The MessageBus is elegant, but BC integration in stockforge is currently file-and-function-based, not event-based. Premature migration to events = AP-1 (Speculative complexity) + AP-7 (Performative ticking). Theme M deferral past Wave 1 is correct.

### 7.4 Backtest scope creep
Nautilus's `BacktestEngine` supports tick-level multi-venue parallel backtests with order-book reconstruction. Stockforge needs **end-of-day bar-level single-venue VN-Index backtests** to demonstrate alpha (Month-12 criterion). 100x simpler scope. Don't import the complexity envelope.

### 7.5 DST contract is Rust-only
The DST contract in `docs/concepts/dst.md` applies to the Rust `tokio` runtime, not the Python control plane. Python-side determinism in stockforge (W0-2) is structurally analogous (ban `datetime.now()`, ban `time.time()` in domain, mandate UTC-aware) but does NOT inherit nautilus's enforcement strength. Stockforge's W0-2 hook (`scripts/hooks/python-determinism-check.sh`) is the local equivalent.

### 7.6 No insight into Vietnamese market specifics
Nautilus has zero VN market knowledge: no HOSE/HNX/UPCOM venue support, no T+2 settlement, no foreign-ownership-room awareness, no Vietnamese-language sentiment. All VN-domain logic must come from elsewhere (BC-2 → BC-7 source repos). Don't expect nautilus to fill any of those gaps.

---

Self-attestation: every claim cites a specific file in the repo.
