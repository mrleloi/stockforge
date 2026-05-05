---
plan_id: 004-S24-phase-1-thin-slice-plan
session: S24
session_type: PLAN (master-plan output; user picked Option E)
authored_at: 2026-04-30
authored_by: Claude Opus 4.7 (S24 master-planner subagent dispatch)
predecessor: agent-workspace/memory/checkpoints/latest.md (S23 close — Phase 1 entry)
extends: docs/DAY_1_CHECKLIST.md (substantive Phase 1 plan; § A-E)
budget_target: ~80K (PLAN-only; this file is the deliverable)
mode: AUTONOMOUS (full; autonomous_mode=true always per S15-close user correction)
---

# S24 PLAN — Phase 1 Thin-Slice Master Plan (S25 → S30)

> **Goal**: Decompose Phase 1 (Foundation) into a 6-session sequence ending in a working thin-slice that exercises 2 BCs (market_data + portfolio) end-to-end on 1 exemplar stock (VHM), seeds the VN ubiquitous-language glossary, ratifies VN-domain financial-data-protocol amendments via `proposals/`, scaffolds Tier 1 ingestion (vnstock + TCBS), and seeds eval-sets templates so Phase 1 close enables a real /thesis-validate run.
>
> **Constraints binding** (CLAUDE.md hard rules + agent-workspace/CLAUDE.md):
> - Each session ≤150K (FOCUSED_IMPL/MULTI_TASK_IMPL); ≤80K PLAN; ≤60K VERIFY
> - Never mix PLAN + IMPL in same session
> - Sandwich pattern (Architect → Dev → Verifier) for non-trivial work
> - NO LLM math; numbers from code only (Charter Principle 9; I-S1)
> - Every claim has source + as-of date (Charter Principle 1; I-1; I-S5)
> - Constitution edits route through `agent-workspace/proposals/` first; user explicit approve required
> - Domain layer = pure stdlib + dataclasses + Enum (zero framework deps)
> - Cross-BC communication via `packages/contracts/` only
> - Agents never `git commit` unless user explicitly requests
> - Q-D1 (sessions folder scaling) confirmed: keep flat; rely on naming + grep — no migration baked into plan

---

## Phase Goal (Charter Month 3 success criteria — verbatim)

| # | Criterion | Phase 1 close mapping |
|---|---|---|
| 1 | Tier 1 + 2 data pipeline operational for VN30 | Thin-slice scope = Tier 1 only on 1 stock (VHM); VN30-wide Tier 1 + Tier 2 = Phase 2 |
| 2 | 50 companies have basic dossier in wiki | Phase 1 thin-slice = 1 dossier (VHM exemplar); 50-co rollout = Phase 2 |
| 3 | First 5 thesis recorded with formal structure | Phase 1 ships thesis-template + 1 exemplar thesis on VHM (post-mortem-ready); 5 theses = Phase 2 backfill |
| 4 | Can run `/thesis-validate` on a stock end-to-end in <5 minutes | Phase 1 thin-slice ENABLES this on VHM; full automation = Phase 2 |

**Honest framing**: Phase 1 ships the **scaffolding for the thin-slice** (S25-S30). The actual thesis-validate execution + 5-thesis backlog + 50-company rollout = Phase 2 substantive. Charter Month 3 criterion #4 is achievable end of S30 if user runs the slice manually.

---

## Thin-Slice Definition (BC-first-entity strategy)

### Exemplar stock pick: **VHM** (Vinhomes JSC — HOSE)

**Rationale**:
- **VN30 constituent** → matches Charter "First Sub-Scope (locked 6 months)" verbatim
- **Vốn hóa ~150K-180K tỷ VND** → above mid-cap band but VN30-anchored; appropriate for thin-slice exemplar
- **High data coverage** → vnstock + TCBS + Vietstock all carry VHM cleanly; minimizes adapter-layer surprises
- **Mixed signal profile** → real estate sector with foreign-flow exposure exercises Tier 1 BC-1 fields (foreign_buy/foreign_sell) authentically; not a sleepy stock that hides bugs
- **NOT a pump candidate** → keeps thin-slice scope honest (no Tier 4 work in Phase 1)
- **User memory not preloaded** → no confirmation-bias risk for owner per BC-9 PersonalBias contract; if user owns VHM, swap to VIC (sister stock, same data quality) at S25 entry via 1-question bundle

### BC-first-entity picks (2 BCs to seed sub-folder structure)

Per `agent-workspace/memory/checkpoints/latest.md` § "Sub-folder structure DEFERRED" + CLAUDE.md P2 Simplicity, the sub-folder layout (`models/value_objects/events/services/repositories/`) ships with **the first entity per BC**, not speculatively. Phase 1 thin-slice activates 2 BCs:

| BC | First entity | Why this entity, why this BC first |
|---|---|---|
| **BC-1 Market Data** | `Bar` (OHLCV time-series row; TimescaleDB hypertable target) | Exercises Tier 1 deterministic data ingestion + the canonical I-S2/I-S3/I-S4 invariants (point-in-time, survivor-aware, adjustment-tagged); single timeframe (DAILY) keeps scope thin; `Bar` is the atomic unit underlying every other Tier 1 query |
| **BC-9 Portfolio** | `Position` (deterministic; 1 stock, 1 quantity, cost basis) + `RiskRule` (max position size, sector concentration) | Exercises Charter Principle 10 (deterministic risk; LLM cannot override) + Day 1 § B.4 (personal-risk-profile.md placeholder); pairs with BC-1 because position value computation needs Bar data; closes the loop quant → portfolio |

**Why these 2 BCs, not 4**: Phase 1 is foundational. BC-2 (Fundamental), BC-5 (News), BC-8 (Analysis) are Phase 2+ — they ride on top of BC-1 (data substrate) and BC-9 (action substrate). Touching 4 BCs in Phase 1 violates thin-slice and risks Session 4 catastrophic mode.

### Cross-BC contract seed (1 event)

`packages/contracts/events/position_value_computed.py` — emitted by BC-9 when Position re-prices from latest Bar. Exercises the cross-BC contract pattern (architecture.md § Cross-BC Rules) without requiring full event-bus infrastructure (Phase 1 = synchronous in-process per architecture.md § Event Flow Phase 1).

---

## Session Sequence (S25 → S30)

| # | Session | Sub-track focus | Type | Budget | Agent | Predecessor | Successor |
|---|---|---|---|---|---|---|---|
| **S25** | UL Glossary Seed + Phase 1 Spec Frame | Track A | PLAN | ~70-80K | sandwich-architect (subagent dispatch) | S24 (this file) | S26 |
| **S26** | VN-Domain Constitution Proposals | Track B | FOCUSED_IMPL | ~120-140K | main | S25 | S27 |
| **S27** | First Entities — Bar + Position + RiskRule | BC-first | MULTI_TASK_IMPL | ~180-220K | main (Dev half of sandwich) | S26 | S28 |
| **S28** | Tier 1 Ingestion Adapter (VHM) | Track C | FOCUSED_IMPL | ~120-140K | main | S27 | S29 |
| **S29** | Phase 1 Verifier (Sandwich Closure) | sandwich-verify | VERIFY | ~50-60K | sandwich-verifier (subagent dispatch) | S28 | S30 |
| **S30** | Eval-Sets Seed + Thesis Template + Phase 1 Close | Track D + closure | FOCUSED_IMPL | ~100-120K | main | S29 | Phase 2 entry |

**Total Phase 1 envelope**: ~640-860K (vs Phase 0 cumulative ~2.95M — about 22-29% of Phase 0 size, consistent with thin-slice discipline).

**Sandwich pattern coverage**: S25 (Architect PLAN) → S26+S27+S28 (Dev IMPL) → S29 (Verifier). S30 is Track D closure (eval-sets templates + thesis template only, mechanical work; no fresh substrate).

**Critical path**: S25 → S26 → S27 → S28 → S29 → S30 (linear; no parallelism in Phase 1 thin-slice — every session has hard dependency on prior session output).

---

## S25 — UL Glossary Seed + Phase 1 Spec Frame

### Meta
- **Session type**: PLAN
- **Agent**: sandwich-architect subagent (dispatched via Task tool from main session)
- **Budget envelope**: ~70-80K (PLAN target per session-budgets.md)
- **Predecessor**: S24 (this master plan); S23 close checkpoint
- **Successor**: S26 (executes the spec authored here)
- **Decision tier**: SCOPE — glossary terms are scope-level vocabulary; spec frame is IMPL-tier subject to S26 ratification

### Goal (1-2 sentences)
Run `/drill-me "Vietnam stock market value investing with KOL tracking"` (per Day 1 § D.1) to produce `agent-workspace/ubiquitous-language/glossary.md` v1.0 with ≥30 VN-stock terms (Ticker, Thesis, KOL, Credibility Score, Narrative Phase, T+2.5 settlement, Room ngoại, Đội lái, Mua chủ động, etc.); compose a thin-slice spec at `specs/tier2-feature/000-phase-1-thin-slice-VHM.md` that frames S26-S30 deliverables.

### Pre-flight reads (≤5 files; priority-ordered)
1. `agent-workspace/memory/checkpoints/latest.md` (S23 close — preconditions confirmed)
2. `specs/tier1-strategic/001-four-tier-signal-architecture.md` § B.1 + B.6 (Tier 1 sources + storage; already read S23, refresh tactically)
3. `specs/tier2-feature/001-validate-investment-thesis.md` § A (PART A — Business Specification; thin-slice frame anchor)
4. `agent-workspace/constitution/architecture.md` § Bounded Contexts BC-1 + BC-9 (sub-folder layout)
5. `.claude/skills/ubiquitous-language/SKILL.md` (drill-me + glossary-emit procedure)

### Deliverables (3-7 items; each with file path + LOC ceiling)
1. **`agent-workspace/ubiquitous-language/glossary.md`** ≤300 LOC — ≥30 VN-stock terms; each entry: term + definition + source + as-of date + BC mapping (per Charter "every claim has source")
2. **`specs/tier2-feature/000-phase-1-thin-slice-VHM.md`** ≤200 LOC — thin-slice spec following SPEC_TEMPLATE.md; covers: (a) goal, (b) scope (BC-1 Bar + BC-9 Position + BC-9 RiskRule for VHM only), (c) success criteria mapping to S26-S30, (d) explicit out-of-scope (no Tier 2-4, no full VN30, no LLM extraction in Phase 1)
3. **`agent-workspace/memory/decisions/D-009-VHM-thin-slice-exemplar.md`** ≤120 LOC — 12-field schema; ACCEPTED via SCOPE-tier (thin-slice exemplar pick); source_evidence: Charter § First Sub-Scope + Phase 1 Month 3 + this plan
4. **`agent-workspace/ubiquitous-language/_drill-me-transcript-S25.md`** ≤150 LOC — drill-me dialogue artifact (per `.claude/skills/ubiquitous-language/SKILL.md` audit-trail requirement)
5. **Update `agent-workspace/memory/current-execution.md`** § Routing Table — add `"phase 1 thin-slice spec"` row pointing to deliverable #2; add S25 → S30 sequence pointer

### Success criteria (3-7 testable bullets)
- [ ] glossary.md has ≥30 terms; each has source + as-of (grep `as-of:` finds ≥30 matches)
- [ ] glossary.md includes the 8 critical VN-domain terms: T+2.5, Room ngoại, Đội lái, Mua chủ động, Bán chủ động, Sàn HOSE/HNX/UPCoM, Phiên ATO/ATC, Tỷ giá USD/VND (exact spellings — fuzzy-match on Vietnamese acceptable)
- [ ] thin-slice spec frontmatter includes spec_id + tier:2 + bounded_contexts:[Market Data, Portfolio]
- [ ] thin-slice spec § "Out of scope" enumerates ≥5 items (Tier 2/3/4, full VN30, LLM extraction, news ingestion, KOL tracking)
- [ ] D-009 file has all 12 schema fields populated (per D-006/D-007/D-008 template)
- [ ] Deterministic gates pass (no D1 regression; current-execution.md § Track status updated)
- [ ] AskUserQuestion bundle (1 question only; SCOPE-tier): "VHM as exemplar OK, or swap to VIC/VPB?" — user response folds into D-009 status field

### Decision tier
**SCOPE** — exemplar pick affects 5 sessions; user gets 1-question veto opportunity at S25 entry per `agent-workspace/constitution/decision-discipline.md` (proposals/) Q-B2 doctrine: "charter/SCOPE-tier MUST require explicit letter pick".

### Carry-overs from prior session (S23/S24)
- Q-D1 (sessions folder scaling): RESOLVED — keep flat; bake into glossary.md naming convention (no sub-folders for term files)
- Q-D2 (Obsidian wiki scaling): RESOLVED — Karpathy raw/wiki pattern preserved; glossary.md drives the disciplined index for ubiquitous-language only (separate from /wiki content)
- 7 proposals at `agent-workspace/proposals/` still pending user explicit approve — S25 does NOT touch them; if S26 wants `decision-discipline.md` codified before VN-domain proposals land, raise as Q at S25 entry

### Open questions (queued-grill candidates with `fire_when:` triggers)
| ID | Question | fire_when |
|---|---|---|
| Q-S25-1 | VHM vs VIC vs VPB exemplar | S25 SessionStart (1-question bundle, SCOPE-tier) |
| Q-S25-2 | Glossary sub-folder vs flat | RESOLVED via Q-D1; not fired |
| Q-S25-3 | Should glossary.md include Tier 3-4 terms (KOL, Đội lái, etc.) even though they're Phase 2+ scope? | S25 mid-session if drill-me surfaces uncertainty (recommend YES — vocabulary anchor for Phase 2 anyway) |

---

## S26 — VN-Domain Constitution Proposals (Track B)

### Meta
- **Session type**: FOCUSED_IMPL
- **Agent**: main (Dev role; not yet sandwich-Dev because no architect output to consume — proposals are author-only work)
- **Budget envelope**: ~120-140K (FOCUSED_IMPL; under 150K cap with margin for the 4-file authoring + provenance log)
- **Predecessor**: S25 (glossary + thin-slice spec inform VN-domain rules)
- **Successor**: S27 (proposals don't gate S27 — they ride parallel; constitution edits land in `proposals/` and require explicit user approve before BC code can reference them)
- **Decision tier**: CHARTER (constitution amendments) — but routed via `proposals/`, so this session ratifies DRAFTS, not constitution itself; user moves drafts to constitution/ via separate explicit-approve step

### Goal (1-2 sentences)
Author 2 NEW proposals at `agent-workspace/proposals/` codifying VN-domain financial-data-protocol amendments (T+2.5 settlement, Room ngoại foreign-ownership cap, sàn-specific rules HOSE/HNX/UPCoM, FX VND-USD discipline) and invariants.md I-S55-I-S65 expansion (10 new VN-specific invariants); update Day 1 § B.5 personal-risk-profile.md placeholder template at `agent-workspace/memory/personal-risk-profile.md` (NEW; user fills in S30+).

### Pre-flight reads (≤5 files; priority-ordered)
1. `agent-workspace/constitution/financial-data-protocol.md` (current 10 rules; identify insertion points for VN-domain amendments)
2. `agent-workspace/constitution/invariants.md` § I-S1..I-S54 (existing stock-specific invariants; identify next-available IDs starting I-S55)
3. `specs/tier2-feature/000-phase-1-thin-slice-VHM.md` (S25 output — frames which VN-domain rules are binding for thin-slice)
4. `agent-workspace/proposals/financial-data-protocol-amendment.md` (S16 existing draft — additive, not replacement; this S26 work appends NEW amendment block, doesn't overwrite)
5. `docs/DAY_1_CHECKLIST.md` § B.1 + B.5 (financial-data-protocol customization + personal-risk-profile sections)

### Deliverables (3-7 items; each with file path + LOC ceiling)
1. **`agent-workspace/proposals/financial-data-protocol-amendment-VN.md`** ≤200 LOC — NEW proposal file (separate from existing S16 amendment to keep author audit clean); covers Rules 12-15: Rule 12 (T+2.5 settlement timing for VN equities), Rule 13 (Room ngoại foreign-ownership cap detection), Rule 14 (Sàn HOSE vs HNX vs UPCoM data-quality tiering), Rule 15 (FX VND/USD point-in-time integrity for cross-currency calc — extends Rule 5 with VN specifics)
2. **`agent-workspace/proposals/invariants-amendment-VN.md`** ≤180 LOC — NEW proposal file; defines I-S55 through I-S65 (10 new VN-specific invariants); examples: I-S55 T+2.5 cleared cash, I-S56 foreign-room saturation alert, I-S57 ATO/ATC phase identification, I-S58 dividend ex-date adjustment in VN convention, I-S59 listing-status (HOSE/HNX/UPCoM) tagging, I-S60 lot-size 100-share rule, I-S61 ceiling/floor 7%/10%/15% per sàn, I-S62 trading-suspension event handling, I-S63 corporate-action ex-rights tagging, I-S64 vnstock vs TCBS reconciliation tolerance ≥1%, I-S65 source-fallback chain order
3. **`agent-workspace/memory/personal-risk-profile.md`** ≤120 LOC — NEW file; placeholder template per Day 1 § B.5 with sections: holding period preference, position sizing rules, stop-loss philosophy, dividend preference, sector exclusions, max drawdown tolerance; **user fills in actual values at S30 or later** — this session ships SHAPE only, not content
4. **`agent-workspace/memory/decisions/D-010-VN-domain-constitution-proposals.md`** ≤140 LOC — 12-field schema; status ACCEPTED-as-PROPOSAL (not constitution); source_evidence: existing constitution + Day 1 + Charter Phase 1 + glossary.md S25 output; explicit "user approve required to move to constitution/" status guard
5. **Update `agent-workspace/memory/project.md`** § Recent Architectural Decisions — append D-010 entry (push D-006 off the 5-entry rolling window; oldest entry archived per project.md update-cadence rule)

### Success criteria (3-7 testable bullets)
- [ ] 2 NEW files at `agent-workspace/proposals/`; both have `status: PROPOSAL` frontmatter + `target_constitution_path:` + `move_when: user explicit approve` (matching format of existing 7 proposals)
- [ ] financial-data-protocol-amendment-VN.md Rules 12-15 reference glossary.md terms by exact spelling (T+2.5, Room ngoại, etc.)
- [ ] invariants-amendment-VN.md uses I-S55-I-S65 (sequential continuation; no gaps; no overlap with I-S1-I-S54)
- [ ] personal-risk-profile.md is template-only (every section has `<USER FILL>` placeholder; no actual user values inserted)
- [ ] D-010 file has all 12 schema fields populated; status = ACCEPTED-as-PROPOSAL (NOT ACCEPTED — distinct status to flag the user-approve gate)
- [ ] Deterministic gates pass (no D1 regression)
- [ ] **8 proposals total at `agent-workspace/proposals/`** post-S26 (was 7; +2 from S26 = 9, BUT existing S16 financial-data-protocol-amendment.md is folded into financial-data-protocol-amendment-VN.md per "additive append" decision = 8 net) — verify count via `ls agent-workspace/proposals/*.md | wc -l = 8`
- [ ] No edits to `agent-workspace/constitution/**` (deny-listed; if attempt, verify hook denies)

### Decision tier
**CHARTER (via PROPOSAL gate)** — proposals are CHARTER-tier in target but ratified at SCOPE-tier in `proposals/`; final move to constitution/ requires user explicit letter-pick per Q-B2 doctrine. S26 ratifies the SCOPE side only.

### Carry-overs from prior session (S25)
- glossary.md vocabulary feeds Rules 12-15 (Room ngoại definition lives in glossary, referenced from financial-data-protocol-amendment-VN.md)
- thin-slice spec § Out-of-scope confirms which invariants are binding for Phase 1 vs deferred to Phase 2 (e.g., I-S62 trading-suspension is Phase 2 because requires real-time data)
- Q-S25-3 if YES (Tier 3-4 terms in glossary): I-S65 source-fallback chain references KOL terms but doesn't enforce them (deferred enforcement)

### Open questions (queued-grill candidates)
| ID | Question | fire_when |
|---|---|---|
| Q-S26-1 | T+2.5 settlement for derivatives differs from cash equity — separate Rule? | S26 mid-session (likely defer to Phase 3 derivatives spec; recommend NO separate Rule for Phase 1) |
| Q-S26-2 | Should I-S57 (ATO/ATC phase) be enforced in Phase 1 or deferred? Phase 1 thin-slice = EOD only, no intraday. | S26 mid-session — recommend defer enforcement to Phase 2 intraday adapter; document I-S57 in invariants but mark `binding_phase: 2+` |
| Q-S26-3 | personal-risk-profile.md template — sectors_excluded list: empty default, or seed with charter "no derivatives, no shorting" implicit exclusions? | S26 mid-session — recommend EMPTY (user fills); charter exclusions live in Charter, not personal profile |

---

## S27 — First Entities (Bar + Position + RiskRule)

### Meta
- **Session type**: MULTI_TASK_IMPL
- **Agent**: main (Dev half of sandwich; S29 Verifier closes)
- **Budget envelope**: ~180-220K (MULTI_TASK_IMPL; 2 BCs × ~3-4 files each + 2 contract files + tests = ~10-14 files; provisioned for the rich domain model build)
- **Predecessor**: S26 (proposals inform but don't gate; S27 references existing constitution + S25 spec)
- **Successor**: S28 (ingestion adapter consumes Bar entity)
- **Decision tier**: IMPL — entity design is downstream of architecture.md spec; substrate decisions (e.g., dataclass vs class for rich domain model) IMPL-tier per D-003 doctrine

### Goal (1-2 sentences)
Ship `packages/domain/market_data/{models,value_objects,events,services,repositories}/` with `Bar` entity (rich, with behavior; OHLCV + adjustment_type + source_provider + filing_date + foreign flow fields per BC-1 spec) AND `packages/domain/portfolio/{models,value_objects,events,services,repositories}/` with `Position` entity + `RiskRule` value object (max position size, sector concentration, stop-loss; deterministic per Charter Principle 10); seed `packages/contracts/events/position_value_computed.py` cross-BC event; ship pytest suite ≥40 tests covering invariants + happy-path + 5+ failure paths.

### Pre-flight reads (≤5 files; priority-ordered)
1. `agent-workspace/constitution/architecture.md` § BC-1 + BC-9 + § Folder Conventions + § Domain Model Rules (Rich, Not Anemic) + § Forbidden Patterns
2. `agent-workspace/constitution/financial-data-protocol.md` Rules 1-10 (current; **NOT** the proposals — those aren't ratified yet)
3. `agent-workspace/constitution/invariants.md` § I-S1-I-S10 (data integrity invariants binding for Bar) + § I-S20+ (calibration; informs RiskRule)
4. `specs/tier2-feature/000-phase-1-thin-slice-VHM.md` § B (Technical scope; S25 output)
5. `packages/observability/__init__.py` + `packages/observability/state_machine.py` (Phase 0 reference patterns for pure-stdlib + dataclass + Enum + frozen module structure — mimic this style)

### Deliverables (3-7 items; each with file path + LOC ceiling)

**BC-1 Market Data**:
1. **`packages/domain/market_data/value_objects/ticker.py`** ≤80 LOC — `Ticker` value object; immutable; validates VN ticker format (3-letter HOSE/HNX/UPCoM; numeric UPCoM allowed); `__post_init__` validation
2. **`packages/domain/market_data/value_objects/money.py`** ≤80 LOC — `Money` value object; default VND; cross-currency raises `CurrencyMismatchError` per Rule 5
3. **`packages/domain/market_data/value_objects/adjustment_type.py`** ≤40 LOC — `AdjustmentType` Enum (NONE | DIVIDEND | SPLIT | BOTH) + `SourceProvider` Enum (VNSTOCK | TCBS | VIETSTOCK | MANUAL)
4. **`packages/domain/market_data/models/bar.py`** ≤140 LOC — `Bar` rich entity; OHLCV + volume + foreign_buy + foreign_sell + period_end + filing_date + adjustment_type + source_provider; `__post_init__` enforces I-S2 (filing_date ≤ today), I-S4 (adjustment_type not None), I-S6 (Money currency); methods: `is_stale(as_of)`, `apply_split(ratio)` returns new Bar
5. **`packages/domain/market_data/repositories/bar_repository.py`** ≤60 LOC — `BarRepository` Protocol (NOT impl); methods: `get_as_of(ticker, as_of_date)`, `get_latest(ticker)`, `get_range_adjusted(ticker, start, end)`; explicitly NO `get_all()` per Rule 1 enforcement
6. **`packages/domain/market_data/__init__.py`** extend ≤50 LOC — barrel exports

**BC-9 Portfolio**:
7. **`packages/domain/portfolio/value_objects/risk_rule.py`** ≤100 LOC — `RiskRule` immutable; max_position_pct (default 0.15 per Charter), max_sector_concentration_pct (default 0.30), stop_loss_pct, holding_period_min_months (1), holding_period_pref_min_months (6); `__post_init__` validates (0 ≤ pct ≤ 1)
8. **`packages/domain/portfolio/models/position.py`** ≤140 LOC — `Position` rich entity; ticker + quantity + avg_cost + opened_at + risk_rule_snapshot; methods: `current_value(latest_bar)`, `pnl_pct(latest_bar)`, `is_violating_risk(portfolio_total)`, `_events: list[PositionValueComputed]`
9. **`packages/domain/portfolio/__init__.py`** extend ≤40 LOC

**Contracts**:
10. **`packages/contracts/events/position_value_computed.py`** ≤60 LOC — frozen dataclass; ticker + position_id + computed_value + as_of + source_bar_id (cross-BC reference)
11. **`packages/contracts/__init__.py`** ≤20 LOC — barrel

**Tests**:
12. **`packages/domain/market_data/test_bar.py`** ≤180 LOC — ≥20 tests (constructor invariants, adjustment math, staleness, currency, source attribution, foreign flow validation)
13. **`packages/domain/portfolio/test_position.py`** ≤140 LOC — ≥15 tests (open/close, PnL, risk-rule violation detection, event emission)
14. **`packages/contracts/test_position_value_computed.py`** ≤60 LOC — ≥5 tests (frozen, eq+hash, serialization)

**Total**: 14 files; ~1,250 LOC; ≥40 tests.

### Success criteria (3-7 testable bullets)
- [ ] All 14 files ship at exact paths listed; each ≤ ceiling LOC
- [ ] `pytest packages/domain/ packages/contracts/` reports **≥40 PASS in <2s** (per Phase 0 observability baseline 82 tests in 0.17s)
- [ ] `mypy --strict packages/domain/ packages/contracts/` exits 0
- [ ] `ruff check packages/domain/ packages/contracts/` exits 0
- [ ] No framework imports in `packages/domain/**` (grep `from fastapi|from pydantic|import django` returns 0)
- [ ] No direct cross-BC imports (grep `from packages.domain.market_data` in `portfolio/` and vice versa returns 0; cross-BC types come from `packages.contracts`)
- [ ] D1 baseline still 0 (no new files exceed CLAUDE.md ceilings)
- [ ] **Sandwich pattern partial**: S27 is Dev half; S29 is Verifier half. S25 PLAN was the Architect half (thin-slice spec).

### Decision tier
**IMPL** — entity field choices, method signatures, dataclass-vs-frozen are IMPL-tier (per D-003 doctrine "implementation choices are IMPL-tier; subject to drift audit + verifier"). If S27 surfaces a substrate question that affects multiple BCs (e.g., "should we use msgspec instead of dataclass for performance?"), escalate to ARCH-tier via Q&A bundle, do NOT silently decide.

### Carry-overs from prior session (S26)
- proposals/ amendments NOT yet ratified — S27 references existing constitution + invariants only; if VN-domain rule (e.g., T+2.5) needs enforcement in Bar entity, fall back to existing Rule 1 (point-in-time) which subsumes it
- glossary.md vocabulary used for ticker validation regex + sector enum (sectors discovered via S25 drill-me)
- Q-S26-2 (I-S57 ATO/ATC phase deferred): S27 Bar entity does NOT include intraday phase field; can add Phase 2

### Open questions (queued-grill candidates)
| ID | Question | fire_when |
|---|---|---|
| Q-S27-1 | RiskRule defaults: 15% max_position vs Charter "5-15% per stock" — pick midpoint 10%? | S27 mid-session — recommend 15% (Charter ceiling) as default; user can tighten in personal-risk-profile.md |
| Q-S27-2 | Sector enum: discovered via S25 glossary or hard-coded VN-standard 11 sectors (BĐS, NH, BL, etc.)? | S27 entry (read S25 glossary first; if glossary covers, use; else hard-code 11 ICB Level-1 sectors) |
| Q-S27-3 | Position cost basis: weighted average vs FIFO vs LIFO? | S27 mid-session — recommend weighted average for Phase 1 (simplest; deterministic; matches retail VN broker convention); FIFO for tax accounting deferred |

---

## S28 — Tier 1 Ingestion Adapter (VHM)

### Meta
- **Session type**: FOCUSED_IMPL
- **Agent**: main
- **Budget envelope**: ~120-140K (FOCUSED_IMPL; adapter + 1 stock × 1 timeframe = focused scope; vnstock library docs may need fetching)
- **Predecessor**: S27 (consumes Bar repository Protocol from S27)
- **Successor**: S29 (Verifier reviews S26+S27+S28 jointly)
- **Decision tier**: IMPL

### Goal (1-2 sentences)
Ship `packages/infrastructure/market_data/vnstock_adapter.py` (Bar-emitting adapter wrapping vnstock library) + `packages/infrastructure/market_data/tcbs_adapter.py` (backup; same Bar Protocol; reconciliation tolerance per Rule 4); CLI tool at `apps/cli/ingest_vhm.py` that pulls 1 year DAILY bars for VHM and persists to local SQLite (TimescaleDB deferred to Phase 2 — local SQLite proves the adapter contract); 90+ days of VHM bars on disk + reconciliation report (vnstock vs TCBS divergence rows).

### Pre-flight reads (≤5 files; priority-ordered)
1. `packages/domain/market_data/repositories/bar_repository.py` (S27 output — Protocol the adapters implement)
2. `packages/domain/market_data/models/bar.py` (S27 output — Bar dataclass shape)
3. `agent-workspace/constitution/architecture.md` § Layer Hierarchy + Folder Conventions § infrastructure
4. `agent-workspace/constitution/financial-data-protocol.md` Rule 4 (Source Attribution) + Rule 5 (Currency)
5. vnstock library docs — fetch via context7 MCP if version-current docs needed

### Deliverables (3-7 items; each with file path + LOC ceiling)
1. **`packages/application/market_data/ports/bar_provider_port.py`** ≤50 LOC — port Protocol (application-layer; abstracts adapter)
2. **`packages/infrastructure/market_data/vnstock_adapter.py`** ≤180 LOC — implements `BarProviderPort`; methods: `fetch_daily(ticker, start, end)` returns `list[Bar]`; uses vnstock library; sets `source_provider=VNSTOCK`; respects rate limits (default 1 req/sec); `pyproject.toml` extension to add vnstock dep
3. **`packages/infrastructure/market_data/tcbs_adapter.py`** ≤180 LOC — same Protocol; uses TCBS public API; sets `source_provider=TCBS`; backup source for reconciliation
4. **`packages/infrastructure/market_data/reconciliation_service.py`** ≤120 LOC — pure logic; takes 2 lists of Bars, returns `ReconciledBar` view per Rule 4 (within 1% = HIGH confidence; outside = LOW + flag); zero LLM
5. **`packages/infrastructure/market_data/sqlite_bar_repository.py`** ≤140 LOC — implements `BarRepository` Protocol (S27); SQLite local; schema: `(ticker, period_end, filing_date, ingested_at, ohlcv, foreign_flow, adjustment_type, source_provider)`; index on (ticker, period_end)
6. **`apps/cli/ingest_vhm.py`** ≤100 LOC — Click CLI; `ingest_vhm.py --start 2025-04-30 --end 2026-04-29 --output ./data/vhm.sqlite`; orchestrates vnstock_adapter + tcbs_adapter + reconciliation + sqlite_bar_repository
7. **`packages/infrastructure/market_data/test_adapters.py`** ≤200 LOC — ≥15 tests; **fixture-based** (recorded vnstock + TCBS responses; NO live API calls in test suite per Phase 0 observability discipline); reconciliation logic gets ≥5 dedicated tests

**Pyproject extension**:
8. **`pyproject.toml`** append — `[tool.poetry.dependencies]` or equivalent: `vnstock = "^X.Y"`, `requests = "^2.31"`, `click = "^8.1"`; **no production framework deps in domain** (re-verify domain layer tests still pass after install)

**Total**: 7 code files + 1 config edit; ~970 LOC.

### Success criteria (3-7 testable bullets)
- [ ] `python apps/cli/ingest_vhm.py --start 2025-04-30 --end 2026-04-29 --output ./data/vhm.sqlite` exits 0 with ≥200 daily bars on disk (1 year of VN trading days ≈ 250)
- [ ] Reconciliation report at `./data/vhm-reconciliation.md` shows: total_rows, rows_within_1pct, rows_outside_1pct, sample_divergences (≤5 examples)
- [ ] `pytest packages/infrastructure/market_data/` reports **≥15 PASS, 0 FAIL** with fixture-only (no network)
- [ ] No vnstock or requests import inside `packages/domain/**` (grep returns 0)
- [ ] D1 baseline still 0; mypy + ruff still clean
- [ ] Bar entities loaded from SQLite roundtrip cleanly through Bar dataclass (test: open SQLite, hydrate Bar, assert all invariants hold)
- [ ] Reconciliation service handles "vnstock missing day, TCBS has day" gracefully (logged, not crashed)

### Decision tier
**IMPL** — adapter library choice (vnstock vs scraping vs FiinPro) is locked by Charter § Data Sources; adapter implementation details IMPL-tier.

### Carry-overs from prior session (S27)
- BarRepository Protocol contract is binding (S28 SQLite impl must satisfy without modification to Protocol)
- Cross-BC contract `position_value_computed.py` not yet exercised — S30 picks up
- Q-S27-2 sector resolution: if S27 used hard-coded 11 sectors, S28 ingestion does NOT add sector field to Bar (sector lives on Company entity, BC-3, deferred Phase 2)

### Open questions
| ID | Question | fire_when |
|---|---|---|
| Q-S28-1 | TimescaleDB vs SQLite for Phase 1: skip TSDB, use SQLite. Confirm? | S28 entry (recommend SQLite for thin-slice; TSDB Phase 2 when VN30-wide ingestion lands; rationale: dependency footprint + Docker complexity not justified for 1 stock) |
| Q-S28-2 | vnstock rate limit unknown — start at 1 req/sec, or scan library to find documented limit? | S28 mid-session via context7 MCP fetch of vnstock docs |
| Q-S28-3 | If reconciliation flags >5% rows divergent for VHM, is that a Phase 1 blocker or Phase 2 issue? | S28 mid-session — recommend log + continue (do not block); Phase 2 reconciliation hardening |

---

## S29 — Phase 1 Verifier (Sandwich Closure)

### Meta
- **Session type**: VERIFY
- **Agent**: sandwich-verifier subagent (separate context per CLAUDE.md hard rule "same-agent self-review = echo chamber")
- **Budget envelope**: ~50-60K (VERIFY target per session-budgets.md; whole-Phase 1 verifier per L-S21-1 candidate but Phase 1 is smaller scope than Phase 0, 60K should fit; if exceeds, escalate per L-S21-1 doctrine to 80-100K)
- **Predecessor**: S28 (final IMPL session before verifier)
- **Successor**: S30 (closure session; consumes verifier verdict)
- **Decision tier**: read-only (verifier emits findings, doesn't decide)

### Goal (1-2 sentences)
Adversarial review of S26-S28 deliverables (constitution proposals, BC-1 + BC-9 first entities, Tier 1 ingestion adapter); verify zero LLM-math creep, zero charter violations, zero direct cross-BC imports; verify Bar entity satisfies I-S1..I-S10 invariants by construction; confirm reconciliation service is pure-logic (no LLM); produce PASS / PASS-WITH-RESIDUE / FAIL verdict gating S30 closure.

### Pre-flight reads (≤5 files; priority-ordered)
1. `agent-workspace/memory/checkpoints/latest.md` (S28 close — verifier's input snapshot)
2. `specs/tier2-feature/000-phase-1-thin-slice-VHM.md` (S25 spec — verifier checks S26-S28 output against this)
3. `agent-workspace/constitution/architecture.md` + `invariants.md` + `financial-data-protocol.md` (binding rules to verify against)
4. `agent-workspace/proposals/financial-data-protocol-amendment-VN.md` + `invariants-amendment-VN.md` (S26 output — verifier confirms PROPOSAL status, not constitution; verifies no premature reference from S27/S28 code)
5. `apps/cli/ingest_vhm.py` smoke run output `./data/vhm-reconciliation.md` (S28 evidence; verifier may re-run)

### Deliverables (3-7 items)
1. **`agent-workspace/memory/observations/sandwich-verifier-S29-phase1-final.md`** ≤300 LOC — full verifier return text mirror (per Track 6 spec); 10 V-dimensions covered: V1 spec alignment, V2 LLM-math creep (grep "approximately" or "around" in production code → 0 hits required), V3 cross-BC import sanity, V4 invariant enforcement (Bar I-S2/I-S4/I-S6), V5 deterministic risk (RiskRule no LLM), V6 source attribution (every Bar has source_provider), V7 test pass rate, V8 mypy/ruff clean, V9 D1 baseline 0, V10 charter-immutability (no edits to constitution/)
2. **`agent-workspace/memory/checkpoints/phase-1-thin-slice-S29-verdict.md`** ≤150 LOC — checkpoint with verdict; if PASS-WITH-RESIDUE, enumerate residue items + suggested S30 touch-on-pass fixes
3. **Update `agent-workspace/memory/current-execution.md`** — append S29 row with verdict + S30 next-action

### Success criteria (3-7 testable bullets)
- [ ] Verifier verdict in {PASS | PASS-WITH-RESIDUE | FAIL}
- [ ] V2 LLM-math creep: 0 hits in `packages/domain/` and `packages/infrastructure/` for natural-language number patterns ("approximately", "around", "roughly", "~ X%")
- [ ] V3 cross-BC import: grep `from packages.domain.<bc1>` inside `packages/domain/<bc2>/` returns 0 for all BC pairs
- [ ] V4 invariant enforcement: pytest can construct invalid Bar (filing_date in future, mixed currency, missing adjustment_type) and assertion-error fires for each
- [ ] V7 test count: ≥55 tests total (S27 ≥40 + S28 ≥15) all PASS
- [ ] V10 constitution immutability: md5 of `agent-workspace/constitution/*.md` files matches Phase 0 close baseline (no drift)
- [ ] If FAIL: gate S30; require RECOVERY session before Phase 2 entry

### Decision tier
**read-only** — verifier produces findings; verdict drives S30 scope but verifier does not decide architecture.

### Carry-overs from prior sessions (S25-S28)
- All S25-S28 deliverables enter verifier's review surface
- 7+1=8 proposals at `agent-workspace/proposals/` (S26 added 2 net) confirmed STATUS=PROPOSAL not constitution
- Verifier MAY rerun `apps/cli/ingest_vhm.py` smoke (network-permitting); if rerun fails because vnstock changed, log as carry-over for S30 (not S29 blocker)

### Open questions
| ID | Question | fire_when |
|---|---|---|
| Q-S29-1 | If PASS-WITH-RESIDUE, do residue items go to S30 or queued for Phase 2? | S29 verifier-return time (recommend touch-on-pass at S30 if cosmetic; defer to Phase 2 only if material) |
| Q-S29-2 | Verifier-budget 60K vs L-S21-1 calibrated 150K — Phase 1 smaller, so 60K should fit; if exceeds, what's the protocol? | S29 mid-session; if verifier reports >70K consumed, dispatch a budget escalation per session-budgets.md `When to Escalate` |

---

## S30 — Eval-Sets Seed + Thesis Template + Phase 1 Close

### Meta
- **Session type**: FOCUSED_IMPL
- **Agent**: main
- **Budget envelope**: ~100-120K (FOCUSED_IMPL; mostly templating + closure docs + 1 thesis exemplar entry)
- **Predecessor**: S29 (verdict gates S30 scope)
- **Successor**: Phase 2 entry (separate master plan, NOT this file's scope)
- **Decision tier**: SCOPE (Phase 1 closure ceremony; Phase 2 entry boundary)

### Goal (1-2 sentences)
Ship eval-sets seed templates per Day 1 § B.2-B.4 (`eval-sets/historical-theses/seed.md`, `eval-sets/labeled-kol-recommendations/seed-kols.md`, `eval-sets/labeled-pumps/seed.md` — all template-only, user fills); thesis template at `agent-workspace/memory/thesis-log/_template.md` + 1 exemplar VHM thesis entry (read-only on real data; per session-budgets.md "THESIS sessions are read-only on code" — this is a template-and-exemplar exercise, not a real thesis); Phase 1 close checkpoint + project.md phase-boundary update; first thesis post-mortem placeholder (real post-mortem pending 6-month outcome per I-S26).

### Pre-flight reads (≤5 files; priority-ordered)
1. `agent-workspace/memory/checkpoints/phase-1-thin-slice-S29-verdict.md` (S29 output — gates S30 scope)
2. `docs/DAY_1_CHECKLIST.md` § B.2-B.4 (eval-sets seed format)
3. `agent-workspace/constitution/invariants.md` § I-S10-I-S13 (thesis adversarial invariants — bear-case mandatory, multi-perspective, etc.) + § I-S26 (post-mortem schedule)
4. `agent-workspace/memory/personal-risk-profile.md` (S26 template — verify USER FILL still empty; if user filled, fold into thesis template)
5. `specs/tier2-feature/001-validate-investment-thesis.md` § A (thesis card structure; informs thesis-template.md)

### Deliverables (3-7 items; each with file path + LOC ceiling)
1. **`eval-sets/historical-theses/seed.md`** ≤120 LOC — Day 1 § B.2 template; 5 placeholder entries with `<USER FILL>` for ticker / as-of / decision / rationale / outcome
2. **`eval-sets/labeled-kol-recommendations/seed-kols.md`** ≤100 LOC — Day 1 § B.3 template; 10 placeholder KOL entries
3. **`eval-sets/labeled-pumps/seed.md`** ≤100 LOC — Day 1 § B.4 template; 5 placeholder pump entries
4. **`agent-workspace/memory/thesis-log/_template.md`** ≤180 LOC — thesis card template per spec 001 § A; sections: ticker, as-of, bull case (≥3 points), bear case (≥3 points; mandatory per I-S10), valuation range (deterministic; references Bar data), catalysts, what-to-investigate-next, confidence (with `n_samples` + `hit_rate` placeholders per I-S7), source list with as-of dates
5. **`agent-workspace/memory/thesis-log/2026-04-30-VHM-exemplar.md`** ≤200 LOC — 1 exemplar thesis on VHM (read-only on real data; uses S28 ingested Bar data; no LLM math — every number sourced from code via SQL queries on `./data/vhm.sqlite`); demonstrates the template
6. **`agent-workspace/memory/post-mortems/_template.md`** ≤120 LOC — post-mortem template per I-S26 (6-month outcome review schedule); placeholder for VHM-exemplar post-mortem due 2026-10-30
7. **Phase 1 close checkpoint**: update `agent-workspace/memory/checkpoints/latest.md` + `agent-workspace/memory/project.md` § Current Phase + `agent-workspace/memory/current-execution.md` § Active Focus Track → "Phase 2 entry next"

### Success criteria (3-7 testable bullets)
- [ ] 3 eval-sets seed files at exact paths; each has frontmatter + ≥5 placeholder entries with `<USER FILL>` markers
- [ ] thesis-log/_template.md has bear-case section (mandatory per I-S10); grep "bear case" finds ≥3 references in template
- [ ] VHM-exemplar thesis: every number traceable to a SQL query in the file (audit comment `-- query: ...`); grep for naked numbers without code-trace returns 0 (subject to S29-style verifier discipline at S30 self-review)
- [ ] Phase 1 close checkpoint marks Phase 1 = COMPLETE with deliverables enumerated
- [ ] project.md § Phase Goals Tracker: Phase 1 status updated DONE; date filled
- [ ] D1 baseline still 0
- [ ] **Charter Month 3 criterion #4** ("Can run /thesis-validate on a stock end-to-end in <5 minutes"): Honest mapping — Phase 1 close ENABLES the manual run via VHM-exemplar evidence; full automation deferred to Phase 2 (`/thesis-validate` slash command implementation)

### Decision tier
**SCOPE** — Phase 1 closure boundary; user gets phase-boundary AskUserQuestion: "Phase 1 closed; ready to enter Phase 2 (Tier 1+2 VN30 rollout) or pause for dogfood?"

### Carry-overs from prior sessions
- S29 verdict: if PASS-WITH-RESIDUE, S30 starts with residue cleanup (touch-on-pass) before templates
- S26 personal-risk-profile.md: if user filled it during S26-S29 window, S30 thesis template references actual values; else stays placeholder
- S25 glossary.md feeds template terminology (every thesis entry must use UL-canonical spelling per ubiquitous-language discipline)

### Open questions
| ID | Question | fire_when |
|---|---|---|
| Q-S30-1 | Should VHM-exemplar thesis be saved as actual thesis (counts toward Charter Month-3 "5 thesis recorded") or marked exemplar/draft? | S30 mid-session — recommend EXEMPLAR (not real thesis) to preserve audit cleanliness; 5-thesis count = Phase 2 backfill |
| Q-S30-2 | Phase 2 master plan: author at S30 close, or separate session S31? | S30 close (recommend separate session; Phase 2 needs PLAN session of its own per CLAUDE.md "never mix PLAN+IMPL") |

---

## Budget Delta vs Phase 0 Reference (~2.95M)

| Session | Type | Budget envelope | Cumulative |
|---|---|---|---|
| S25 | PLAN | 70-80K | 75K |
| S26 | FOCUSED_IMPL | 120-140K | 205K |
| S27 | MULTI_TASK_IMPL | 180-220K | 405K |
| S28 | FOCUSED_IMPL | 120-140K | 535K |
| S29 | VERIFY | 50-60K | 590K |
| S30 | FOCUSED_IMPL | 100-120K | 700K |

**Phase 1 envelope estimate**: **~640-860K** (single point estimate ~700K)

**Vs Phase 0 ~2.95M**: Phase 1 is ~22-29% the size of Phase 0, consistent with thin-slice discipline.

**Vs Charter Phase 1 implicit budget**: Charter doesn't enumerate token budget per phase, but Month 3 success criteria are scoped narrower than the full thin-slice ambition; this 700K envelope is conservative because it includes 2 BCs of substantive code (S27 ~200K alone is heaviest single session).

**Hard cap watch**:
- S27 at 220K is approaching the 250K MULTI_TASK_IMPL ceiling — if pre-flight context load exceeds 30K, S27 must split into S27a (BC-1 only) + S27b (BC-9 only). Plan caveat: monitor at S27 entry; if projected > 230K, raise budget escalation per session-budgets.md.
- S29 at 60K is at the VERIFY ceiling — Phase 1 is smaller surface than Phase 0 so should fit, but L-S21-1 candidate flags whole-Phase verifiers may need 80-150K; if so, S29 escalates within session.

---

## Ratification Path

Per `agent-workspace/CLAUDE.md` Contract Rule 1 (constitution immutable absent explicit human approval) + Q-B2 doctrine (charter/SCOPE-tier MUST require explicit letter pick):

| Decision | Tier | Ratification path |
|---|---|---|
| **This master plan (file 004-S24-...md)** | **IMPL** | ACCEPTED-via-IMPL-tier — agent autonomous; no user-approve required; S25 starts upon next user "continue" or session-start |
| **VHM exemplar pick (D-009)** | **SCOPE** | S25 SessionStart 1-question bundle (Q-S25-1); user explicit pick required; default = VHM if user picks Recommended |
| **VN-domain proposals (S26 deliverables)** | **CHARTER (target)** | Land in `proposals/`; user explicit-approve later moves to constitution; S27-S28-S29 proceed without waiting for ratification (proposals are reference-only until promoted) |
| **First-entity sub-folder structure (S27)** | **IMPL** | ACCEPTED-via-IMPL-tier per architecture.md spec §  Folder Conventions (locked at S15 D-002); S27 ships with no user-gate |
| **vnstock + TCBS adapter library choice (S28)** | **IMPL** | locked by Charter § Data Sources; S28 ships per spec; FiinPro deferred Phase 2-3 |
| **Phase 1 close → Phase 2 entry (S30)** | **SCOPE** | S30 close AskUserQuestion: "Phase 1 closed; enter Phase 2 or pause?"; user picks |

**Total user-approve gates in Phase 1**: 2 (Q-S25-1 VHM exemplar + Phase 1 → 2 boundary at S30 close). VN-domain proposals are 0-blocker for Phase 1 progress (they're DRAFTS only).

**Default assumption if user does not respond**: Per autonomous_mode=true + Q-B2 (charter/SCOPE explicit only), Q-S25-1 stalls if user doesn't pick; the ARCH/IMPL machinery proceeds with Recommended (VHM) if user explicit picks Recommended OR explicitly defers to autonomous (which equals VHM); else session HALTS at S25 entry and posts to `human-workspace/q-and-a/pending/`.

---

## Risks (with mitigation)

| # | Risk | Severity | Mitigation |
|---|---|---|---|
| R1 | S27 budget overrun (>220K projected) | MEDIUM | Pre-flight projection at S27 entry; split into S27a + S27b if >230K |
| R2 | vnstock library breaking change between authoring and S28 execution | LOW | Pin version in pyproject.toml; context7 MCP fetch for current docs |
| R3 | VHM data quality issue (missing trading days, suspension, etc.) | MEDIUM | Reconciliation service handles gracefully; if >5% rows divergent, log + continue (Q-S28-3) |
| R4 | User chooses VIC/VPB instead of VHM at Q-S25-1 | LOW | All 3 candidates (VHM/VIC/VPB) have identical data quality + Tier 1 coverage; thin-slice spec swaps cleanly |
| R5 | Phase 1 verifier (S29) finds material violation (FAIL verdict) | MEDIUM | RECOVERY session before S30; revert + re-plan per session-budgets.md R-3 |
| R6 | LLM-math creep (V2 verifier check fails) | HIGH if undetected, LOW per discipline | S27/S28 production code has zero LLM calls; only S30 thesis-exemplar might call LLM but uses tool-call pattern (numbers from code, LLM interprets only) per I-S1 |
| R7 | Constitution drift (V10 verifier check) | LOW | settings.json deny-list blocks Edit/Write to `agent-workspace/constitution/`; agent attempts to edit fail loudly |
| R8 | Q-D2 wiki disciplined-index drift over Phase 1 | LOW | spec-to-wiki skill (already in skill catalog) drives wiki updates; glossary.md indexed at S25 |
| R9 | 7+ existing proposals never get user-approved → Phase 2 starts with 8+ proposals stale | MEDIUM | S30 close checkpoint surfaces proposal queue as Phase 2 entry blocker (recommend Phase 2 PLAN session begins with proposals review batch) |
| R10 | Sandwich pattern partial (S25 Architect + S27 Dev + S29 Verifier) — S26 + S28 are not sandwich-coordinated | LOW | S26 = constitution authoring (procedural; verifier-friendly via grep checks); S28 = adapter (verifier-checkable via fixture tests); both surface in S29 review |

---

## Files Created by This Plan (S24 deliverable)

1. `agent-workspace/session-plans/pending/004-S24-phase-1-thin-slice-plan.md` (this file)

That's it for S24. All session files (S25-S30 plans NOT yet authored as separate files — this master plan IS the directive; per Q-D1 keep-flat resolution, S25-S30 may author per-session plans inline at their entry OR consume this master plan directly).

**Optional follow-up**: if user prefers per-session plan files (e.g., `005-S25-...md`, `006-S26-...md`, etc.), they can be authored at S25 entry by the architect subagent. This master plan supports either pattern.

---

## Connection to Charter + AOM + Constitution

| Source | Section | How this plan honors |
|---|---|---|
| `PROJECT_CHARTER.md` § Phase 1 (Month 3) | All 4 success criteria | Phase 1 close (S30) maps to criterion #4 (manual end-to-end on VHM); criteria #1-3 partially met (1 stock thin-slice vs VN30; 1 dossier vs 50; 1 exemplar thesis vs 5) — Phase 2 finishes the rollout |
| Charter § Core Principles | All 10 | Honored throughout: P1 evidence (Bar source_provider), P2 structured (no single buy/sell score), P3 adversarial (S29 verifier + bear-case mandatory in thesis template), P4 proprietary data moat (SQLite VHM data starts the moat), P9 NO LLM math (verifier V2 check), P10 deterministic risk (RiskRule code-enforced) |
| `docs/DAY_1_CHECKLIST.md` | § A.4 (financial-data-protocol) + § B.1 (customize) + § B.2-B.4 (eval-sets) + § B.5 (personal-risk-profile) + § D.1 (drill-me) | Track A=S25 (D.1), Track B=S26 (A.4 + B.1 + B.5), Track D=S30 (B.2-B.4) |
| `specs/tier1-strategic/001-four-tier-signal-architecture.md` | § B.1 (Tier 1) | S28 ingestion adapter exercises Tier 1 sources spec |
| `agent-workspace/constitution/architecture.md` | § BCs + Folder Conventions + Domain Model Rules | S27 ships first sub-folder structure for BC-1 + BC-9 per spec |
| `agent-workspace/CLAUDE.md` | Contract Rules 1-7 | All honored; Rule 1 (constitution immutable) preserved via proposals/ routing; Rule 6 (no commit) preserved |

---

## Self-Track Token Estimate (S24 = this plan)

This plan ~700 LOC of markdown + ~5 reads of source files (Charter, Day 1, current-execution, checkpoint, strategic spec, financial-data-protocol, architecture, invariants, S15 PLAN reference, S23 close):

- Pre-flight reads ~30K (5 files × 4-8K each)
- Plan composition ~25K (700 LOC × ~35 tokens/line)
- Tool overhead ~15K
- **S24 self-track estimate**: ~70-80K (within PLAN ~80K target)

---

## End of Plan

> Next action: User runs `/session-start` (or types "continue" if autonomous) → S25 SessionStart fires Q-S25-1 (VHM exemplar) AskUserQuestion bundle → S25 PLAN executes per § S25 above.
