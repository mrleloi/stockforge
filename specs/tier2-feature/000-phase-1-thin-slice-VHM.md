---
spec_id: tier2-000-phase-1-thin-slice-VHM
tier: 2
status: ACCEPTED
version: 1.0
created: 2026-04-30
last_reviewed: 2026-04-30
authors: [Claude Opus 4.7 (S25 sandwich-architect subagent)]
bounded_contexts: [Market Data, Portfolio]
related_specs: [SPEC-2026-04-23-T1-001, SPEC-2026-04-23-001]
ubiquitous_language_terms: [Ticker, As-Of Date, Bar, Position, RiskRule, T+2.5, Room ngoại, Sàn HOSE, VN30, Vốn hóa, Trần, Sàn, Cổ tức]
exemplar_stock: VHM
phase: 1
produces_thesis_output: false
---

# SPEC: Phase 1 Thin-Slice (VHM Exemplar)

> First end-to-end slice. Exercises BC-1 (Market Data) + BC-9 (Portfolio) on a single VN30 stock (VHM) before scaling to VN30 universe in Phase 2.

---

# PART A — BUSINESS SPECIFICATION

## A.1 Context

Phase 0 closed with a 9-BC monorepo skeleton; Phase 1 needs first entities on real data. Charter Month 3 success criteria: (1) Tier 1+2 pipeline for VN30; (2) 50 dossiers; (3) 5 thesis recorded; (4) `/thesis-validate` end-to-end <5min.

Honest framing: Phase 1 ships **scaffolding for the thin-slice on ONE stock (VHM)**, not full VN30. Criterion #4 becomes achievable end-S30 if user runs the slice manually. Criteria #1-3 partially met (1 stock vs VN30; 1 dossier vs 50; 1 exemplar thesis vs 5). Phase 2 finishes the rollout. The slice's value: prove the framework produces useful, calibrated, source-grounded output for one stock before paying engineering cost of scaling to 30+ stocks across 4 tiers and 9 BCs.

## A.2 User & Use Cases

**Primary user**: project owner (self-use). Phase 1 has no external users.

- **UC-1: Ingest 1 year of VHM EOD bars** — `python apps/cli/ingest_vhm.py --start 2025-04-30 --end 2026-04-29 --output ./data/vhm.sqlite` → ≥200 daily Bar rows + reconciliation report.
- **UC-2: Open Position with deterministic risk** — `Position(ticker=VHM, ..., risk_rule=RiskRule(max_pct=0.15))`; system enforces position-sizing in code (Charter Principle 10).
- **UC-3: Compute current value and PnL** — `position.current_value(latest_bar)` returns Money in VND; `pnl_pct(...)` returns Decimal. All numbers from code, not LLM (Charter Principle 9).

## A.3 Business Rules

- **BR-1 Bar invariants** (I-S2 + I-S4): every `Bar` has `period_end ≤ today`, `filing_date ≤ today`, `adjustment_type ∈ {NONE,DIVIDEND,SPLIT,BOTH}`, `source_provider ∈ {VNSTOCK,TCBS,...}`. Construction without these raises.
- **BR-2 Position deterministic risk**: `Position.is_violating_risk(portfolio_total)` returns from `RiskRule` constants; LLM cannot mutate `RiskRule` post-construction (immutable).
- **BR-3 Cross-currency forbidden**: `Money` arithmetic across mixed currencies raises `CurrencyMismatchError` per Rule 5 + I-S6. Phase 1 = VND only.
- **BR-4 Source attribution**: every `Bar` carries `source_provider`. Reconciliation vnstock+TCBS within 1% = HIGH confidence; >1% = flagged + LOW (Rule 4).
- **BR-5 T+2.5 awareness** (informational): `Position.opened_at` = trade-match date; cleared-cash for re-entry T+2 cutoff. Phase 1 does NOT enforce T+2.5 cash gating in code (Phase 2 when intraday/cash-mgmt lands); Bar `period_end` semantics are T+2.5-compatible.

## A.4 Success Criteria

### Quantitative (Charter Month 3 mapping)
| # | Criterion (verbatim) | Phase 1 mapping |
|---|---|---|
| 1 | Tier 1+2 pipeline for VN30 | Tier 1 only on VHM; VN30 + Tier 2 = Phase 2 |
| 2 | 50 dossiers | 1 (VHM exemplar at S30); 50 = Phase 2 |
| 3 | 5 thesis with formal structure | 1 exemplar thesis (S30); 5 = Phase 2 |
| 4 | `/thesis-validate` <5min | Manual end-to-end ENABLED at S30; full slash automation = Phase 2 |

### Acceptance Signals
- `pytest packages/domain/ packages/contracts/ packages/infrastructure/` ≥55 PASS in <3s.
- `./data/vhm.sqlite` ≥200 rows; reconciliation `./data/vhm-reconciliation.md` enumerates divergences.
- S29 verifier verdict ∈ {PASS | PASS-WITH-RESIDUE} → S30 closure unblocked.

## A.5 Scope

### In Scope (Phase 1)
- BC-1 Market Data: `Bar` entity + `Ticker`/`Money`/`AdjustmentType`/`SourceProvider` value objects + `BarRepository` Protocol + SQLite implementation
- BC-9 Portfolio: `Position` entity + `RiskRule` value object
- 1 cross-BC contract event: `position_value_computed`
- Tier 1 ingestion adapter (vnstock primary + TCBS backup + reconciliation)
- 1 exemplar thesis (VHM, read-only on real ingested data)
- Templates only: eval-sets seed, thesis-log/_template.md, post-mortems/_template.md, personal-risk-profile.md

### Explicitly Out of Scope
1. **Tier 2 (Fundamental + News extraction)** — Phase 2; no P/E/P/B/ROE pipeline; no LLM claim extraction.
2. **Tier 3 (KOL/Influence)** — Phase 2-3; no transcription; no calibration DB.
3. **Tier 4 (Crowd/Pump)** — Phase 2-3; no forum scraping; no Đội lái detection.
4. **Full VN30 universe** — only VHM. Phase 2 ≥30 tickers.
5. **LLM extraction in production data path** — Phase 2+. S30 exemplar thesis uses LLM for narrative interpretation only; numbers from code via tool calls (I-S1).
6. **News ingestion** (CafeF/NDH/VietnamBiz) — Phase 2+.
7. **Real-time/intraday** — Phase 1 = EOD only; no ATO/ATC; no Mua chủ động/Bán chủ động.
8. **Multi-currency portfolio** — VND only.
9. **TimescaleDB** — Phase 1 = local SQLite; TSDB Docker stack = Phase 2.
10. **`/thesis-validate` slash-command automation** — manual run at S30; full automation = Phase 2.

## A.6 Key Decisions & Tradeoffs

- **D.6.1 Exemplar = VHM** (vs VIC, VPB): high data coverage; non-banking baseline; sector signal; not a pump candidate; user-explicit (Q-S25-1). See D-009.
- **D.6.2 SQLite (vs TimescaleDB) for Phase 1**: 1 stock × 250 rows; zero-infra. Bar dataclass + repo Protocol unchanged on Phase 2 substrate swap.
- **D.6.3 Domain Protocol + infrastructure SQLite impl** (vs direct SQLite in domain — forbidden): architecture.md mandates zero framework deps in `packages/domain/`.

## A.7 Risks & Mitigations

| Risk | Severity | Mitigation |
|---|---|---|
| vnstock breaking change | LOW | Pin version; context7 fetch at S28 |
| VHM data quality | MED | Reconciliation handles; >5% logged not fatal (Phase 2 hardening) |
| Q-S25-1 swap to VIC/VPB | LOW | Same data quality; spec swaps clean; D-009 status updates |
| LLM-math creep | HIGH if undetected | S29 V2 grep `approximately\|around\|~ %` → 0 in production |
| Constitution drift | LOW | settings.json deny-list; VN-domain rules route via S26 proposals |

## A.8 Dependencies

- **Upstream**: architecture.md § BC-1+BC-9; financial-data-protocol Rules 1-10 (NOT yet S26 VN amendments); invariants.md § I-S1..I-S10; spec-T1-001 § B.1; glossary.md v1.0 (S25 same-session).
- **Downstream**: S26 proposals reference glossary; S27 first entities; S28 adapter; S29 verifier; S30 thesis template + exemplar.
- **External**: vnstock library (pinned), TCBS Open API (rate-limited), Vietstock public refs.

## A.9 Glossary Check

All terms defined in `agent-workspace/ubiquitous-language/glossary.md` v1.0 (S25 same-session): Ticker, Bar, Position, RiskRule, As-Of Date, T+2.5, Room ngoại, Sàn HOSE, VN30, Vốn hóa, Cổ tức, Trần, Sàn, Source Provider.

## A.10 Data Provenance

| Number | Value | Source | As-Of |
|---|---|---|---|
| max_position_pct default | 0.15 | PROJECT_CHARTER.md § First Sub-Scope | 2026-04-30 |
| max_sector_concentration_pct | 0.30 | Charter implicit | 2026-04-30 |
| Reconciliation tolerance | 1% | financial-data-protocol Rule 4 | 2026-04-30 |
| VN trading days/year | ~250 | HOSE annual calendar | 2026-04-30 |
| Phase 1 token envelope | ~640-860K | session-plans/pending/004-S24 § Budget Delta | 2026-04-30 |

LLM never generates these numbers. Code computes; config holds defaults.

## A.11 Adversarial Check

N/A for thin-slice as a whole — `produces_thesis_output: false`. The S30 VHM exemplar carries inline A.11 (bear case ≥3 distinct points per I-S10) via thesis-log/_template.md schema.

---

# PART B — AGENT CONTRACT

## B.1 Deliverables Sequence (S26 → S30)

| Session | Scope | Files (per master-plan 004 § per-session) |
|---|---|---|
| S26 | VN-domain proposals | `agent-workspace/proposals/financial-data-protocol-amendment-VN.md`, `proposals/invariants-amendment-VN.md`, `memory/personal-risk-profile.md` template, D-010 |
| S27 | First entities BC-1+BC-9 | `packages/domain/market_data/{value_objects,models,repositories}/`, `packages/domain/portfolio/{value_objects,models}/`, `packages/contracts/events/position_value_computed.py`, ≥40 tests |
| S28 | Tier 1 ingestion adapter | `packages/infrastructure/market_data/{vnstock_adapter,tcbs_adapter,reconciliation_service,sqlite_bar_repository}.py`, `apps/cli/ingest_vhm.py`, ≥15 tests, `./data/vhm.sqlite` ≥200 rows |
| S29 | sandwich-verifier review | `agent-workspace/memory/observations/sandwich-verifier-S29-phase1-final.md`, `memory/checkpoints/phase-1-thin-slice-S29-verdict.md` |
| S30 | Eval-sets + thesis exemplar + Phase 1 close | `eval-sets/{historical-theses,labeled-kol-recommendations,labeled-pumps}/seed*.md`, `memory/thesis-log/_template.md`, `memory/thesis-log/2026-04-30-VHM-exemplar.md`, `memory/post-mortems/_template.md`, Phase 1 close checkpoint |

## B.2 Affected Bounded Contexts

- **BC-1 Market Data**: NEW value objects (`Ticker`, `Money`, `AdjustmentType`, `SourceProvider`); NEW entity `Bar`; NEW Protocol `BarRepository`.
- **BC-9 Portfolio**: NEW value object `RiskRule`; NEW entity `Position` (with `_events`).
- **Cross-BC contract**: NEW event `position_value_computed` (`packages/contracts/events/`).

## B.3 Domain Events Emitted

```python
# packages/contracts/events/position_value_computed.py
@dataclass(frozen=True)
class PositionValueComputed:
    ticker: Ticker
    position_id: PositionId
    computed_value: Money         # VND only Phase 1
    as_of: date
    source_bar_id: BarId          # cross-BC reference
    computed_at: datetime
```

Phase 1: synchronous in-process per architecture.md § Event Flow Phase 1.

## B.4 Implementation Constraints

**MUST**: `packages/domain/**` zero framework imports (dataclasses + stdlib); cross-BC types via `packages/contracts/`; every Bar has `source_provider` + `as_of`; every numeric output from code, never LLM (I-S1); VBW protocol at S26-S28 entry.
**MUST NOT**: direct cross-BC import; LLM call in production data path (S28 adapter); Pydantic in `packages/domain/**`; edit `agent-workspace/constitution/**` (deny-listed; route via S26 proposals).
**SHOULD**: match Phase 0 `packages/observability/` style (frozen dataclasses, Enum, pure stdlib); Click for CLI at S28; pin external library versions.

## B.5 Acceptance (S29 verifier surface)

S29 dimensions: V1 spec alignment; V2 LLM-math creep = 0; V3 cross-BC import = 0 violations; V4 invariant enforcement (Bar I-S2/I-S4/I-S6 raise on construction); V5 deterministic risk; V6 source attribution non-null; V7 ≥55 tests PASS; V8 mypy --strict + ruff clean; V9 D1 baseline = 0; V10 constitution md5 unchanged.

PASS or PASS-WITH-RESIDUE → S30 closure. FAIL → RECOVERY before S30.

---

# PART C — PROVENANCE & REVIEW

## C.1 Authoring History

| Date | Author | Change | Rationale |
|---|---|---|---|
| 2026-04-30 | Claude Opus 4.7 (S25 sandwich-architect) | Initial v1.0 | Phase 1 entry; master-plan 004 § S25 deliverable #2; Q-S25-1=VHM Recommended |

## C.2 Decision Provenance

- A.6.1 VHM exemplar: D-009 ACCEPTED (this session)
- A.6.2 SQLite vs TSDB: master-plan 004 § Q-S28-1 + Charter § Technical Foundation
- A.6.3 Domain Protocol vs direct SQLite: architecture.md § Layer Hierarchy invariant
