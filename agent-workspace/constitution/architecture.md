# Architecture Rules — StockForge

> Immutable constitution file. Changes require explicit human approval with rationale.

## Clean Architecture Layers

### Layer Hierarchy (mandatory)

```
interfaces/     (HTTP, CLI, dashboard, alert handlers)
    ↓
application/    (use cases, orchestration, ports)
    ↓
domain/         (pure business logic, zero dependencies)
    ↓
infrastructure/ (adapters: Postgres, Redis, R2, vnstock, FiinPro, scrapers, LLMs)
                — implements application ports
```

### Import Rules (non-negotiable)

- `domain` imports: **nothing** from other layers. Zero framework. Zero IO. Zero Pydantic. Use stdlib `dataclasses` and `enum`.
- `application` imports: only from `domain`. Defines ports (Protocol classes).
- `infrastructure` imports: implements `application` ports. Can import `domain` for types.
- `interfaces` imports: `application` use cases. Never reaches into `infrastructure` or `domain` directly.

### Why This Matters in Stock Domain

- Pure domain enables **deterministic** valuation logic, testable without DB
- Swap data providers (vnstock → FiinPro → SSI) without touching domain
- Backtest the same domain logic on any data source
- LLM adapters in infrastructure stay isolated from analysis logic

---

## Bounded Contexts (9 BCs)

Cross-context communication via shared contracts only.

### BC-1: Market Data
**Responsibility**: Time-series price/volume, foreign flow, intraday data, market microstructure.
**Path**: `packages/domain/market_data/`, `apps/*/market_data/`
**Aggregates**: Quote, Bar, ForeignFlow, OrderBook, MarketRegime
**Storage**: TimescaleDB hypertables

### BC-2: Fundamental
**Responsibility**: Financial reports, ratios, valuation inputs.
**Path**: `packages/domain/fundamental/`
**Aggregates**: FinancialStatement, Ratio, ValuationInput, EarningsRevision
**Storage**: Postgres with point-in-time integrity (each report has filing_date + period_end)

### BC-3: Company Intelligence
**Responsibility**: Company profile, history, leadership, related parties, network relationships.
**Path**: `packages/domain/company_intelligence/`
**Aggregates**: Company, Executive, RelatedParty, OwnershipStructure, CorporateAction
**Storage**: Postgres + graph queries (or Neo4j Phase 3+)

### BC-4: Macro & Policy
**Responsibility**: Macro indicators (GDP, CPI, lãi suất), regulatory documents, policy changes, geopolitical events.
**Path**: `packages/domain/macro/`
**Aggregates**: MacroIndicator, PolicyDocument, RegulatoryEvent, MacroRegime
**Storage**: TimescaleDB + document store

### BC-5: News Stream
**Responsibility**: Mainstream financial news ingestion, claim extraction, sentiment, contradiction detection.
**Path**: `packages/domain/news/`
**Aggregates**: NewsArticle, ExtractedClaim, NewsCluster, NewsSentimentScore
**Storage**: Postgres + R2 for full text + pgvector for semantic search

### BC-6: Influence Network ⭐ (the edge)
**Responsibility**: KOL channel monitoring, recommendation extraction, credibility scoring, calibration.
**Path**: `packages/domain/influence/`
**Aggregates**: Kol, Channel, Recommendation, CredibilityScore, InfluenceCluster
**Storage**: Postgres + R2 for transcripts + calibration database

### BC-7: Crowd Sentiment ⭐ (the edge)
**Responsibility**: Forum/group/comment sentiment, pump pattern detection, narrative lifecycle tracking.
**Path**: `packages/domain/crowd/`
**Aggregates**: SentimentSnapshot, PumpDetection, Narrative, NarrativePhase, CoordinationCluster
**Storage**: Postgres + TimescaleDB for sentiment time-series

### BC-8: Analysis & Thesis
**Responsibility**: Multi-perspective adversarial analysis, thesis lifecycle, post-mortem.
**Path**: `packages/domain/analysis/`
**Aggregates**: Thesis, BearAnalysis, BullAnalysis, Synthesis, PostMortem, Catalyst
**Storage**: Postgres + Markdown files in `agent-workspace/memory/thesis-log/`

### BC-9: Portfolio & Action
**Responsibility**: Watchlist, alerts, position sizing, risk management, personal bias tracking.
**Path**: `packages/domain/portfolio/`
**Aggregates**: Watchlist, Position, RiskRule, Alert, PersonalBias, Decision
**Storage**: Postgres + append-only Decision log

### Cross-BC Rules

- **Never direct import** between BCs. Cross-BC types live in `packages/contracts/`.
- **Cross-BC events** defined in `packages/contracts/events/`
- **Cross-BC commands** defined in `packages/contracts/commands/`
- Common cross-BC events: `NewsArticleIngested`, `KolRecommendationExtracted`, `PumpDetected`, `ThesisCreated`, `AlertTriggered`

---

## Stack Locked (Phase 1-3)

### Primary: Python

- **Python 3.11+** (strict typing with mypy --strict)
- **dataclasses** for domain entities (no Pydantic in domain)
- **Pydantic v2** in interfaces/infrastructure layers only
- **FastAPI** for HTTP gateway (Phase 2+)
- **Dramatiq** or **Prefect** for background workers
- **Click** for CLI tooling

### Data Stack

- **Postgres 16** with extensions:
  - **TimescaleDB** (time-series for prices, sentiment over time)
  - **pgvector** (embeddings for semantic search)
  - **pg_trgm** (Vietnamese fuzzy text search)
- **Redis** (cache + pub/sub + queue broker)
- **Cloudflare R2** (S3-compatible, raw content storage)
- **DuckDB** (ad-hoc analytics, backtesting fast scans)

### LLM

- **Primary**: Claude API
  - Sonnet 4.6+ for routine extraction, classification
  - Opus 4.7+ for thesis synthesis, multi-perspective adversarial
- **Embeddings**: OpenAI text-embedding-3-small (works for Vietnamese)
- **Whisper**: for YouTube/podcast transcription (local or OpenAI API)
- **OSS fallback (Phase 4+)**: Llama 3.3 70B via Ollama for cost reduction

### LLM Substrate Boundary

The boundary where deterministic Python code calls into a non-deterministic LLM
is a **failure-prone seam** — Phase 2 (S43b) surfaced 3 distinct failure modes
and shipped 3 mitigation patterns. Future LLM-perspective adapters (BC-8 today;
any BC tomorrow that adds LLM extraction or classification) MUST adopt these
patterns:

- **Per-role model override** (BP-S43b-1): adapters expose `role_model_overrides`
  so cost/latency-sensitive roles (e.g., Bull perspective) can downgrade Opus → Haiku
  without touching call sites. Reference: `claude_llm_perspective_adapter.py`.
- **Prose-tolerant JSON extractor** (BP-S43b-2): never call naive `json.loads`
  on LLM output; use the 3-tier extractor (fenced block → first-`{` heuristic →
  best-effort recovery). Reference: `subagent_transport.py:55-118`.
- **Gatherer-wired deterministic compute** (BP-S43b-3): numbers come from code
  (Charter Principle 9 / I-S1) — wire deterministic services (RatioService,
  TaService, etc.) through the gatherer that prepares LLM context, not through
  the LLM agent itself.

Known failure modes catalogued: KI-S43b-1 (sonnet pairing 300s subprocess timeout),
KI-S43b-2 (LLM JSON in prose preamble), KI-S43b-3 (Windows cp1252 encoding crash).
See `agent-workspace/memory/self-awareness/{known-issues,best-practices}.md`.
**Ratifying decision**: D-026 (S43e — bundled C1+C2 deny-lift cycle).

### Frontend

- **Phase 1-2**: Streamlit (rapid personal dashboard)
- **Phase 3+**: Next.js 14 with shadcn/ui (only if SaaS path activated)
- Always include: TradingView lightweight charts integration

### Workers

- **Python workers**: Dramatiq (async tasks), Prefect (scheduled DAGs)
- **Schedule examples**:
  - Hourly: news ingestion, sentiment refresh
  - Daily 16:00: market data EOD update, screener run
  - Daily 18:00: KOL channel scan
  - Weekly Sun: pattern recalibration
  - Monthly: thesis post-mortem batch

### Infrastructure

- **Monorepo**: pnpm workspaces (even Python apps benefit from it for shared tooling), or Hatch + uv if going pure Python
- **Deploy (early)**: Single VPS (Hetzner) — personal use
- **Deploy (scale, if needed)**: Modal/Fly.io for workers, Hetzner dedicated for DB
- **Observability**: Sentry + simple Grafana for metrics

---

## Folder Conventions

### Per Bounded Context

```
packages/domain/<bc_name>/
├── models/           # Entity classes (rich, with behavior)
├── value_objects/    # Immutable values (Money, Ticker, Period, etc.)
├── events/           # Domain events
├── services/         # Domain services (stateless logic)
├── repositories/     # Repository protocols (Protocol classes)
└── __init__.py       # Public barrel export

packages/application/<bc_name>/
├── use_cases/        # One class per use case
├── ports/            # Protocols to infrastructure
├── commands/         # Command handlers
├── queries/          # Query handlers
└── __init__.py

packages/infrastructure/<bc_name>/
├── persistence/      # Postgres adapters
├── external/         # vnstock, FiinPro, scrapers
├── messaging/        # Event publishers
└── __init__.py

apps/api/<bc_name>/
├── routers/          # FastAPI routers
├── dto/              # Request/response DTOs (Pydantic)
└── deps.py           # Dependency injection
```

### File Naming (Python conventions)

- Entities: `company.py`, `thesis.py`, `kol.py`
- Value objects: `ticker.py`, `money.py`, `period.py`, `as_of_date.py`
- Events: `kol_recommendation_extracted.py`, `pump_detected.py`
- Use cases: `validate_thesis_use_case.py`, `extract_kol_recommendation_use_case.py`
- Repositories: `kol_repository.py` (Protocol), `kol_postgres_repository.py` (impl)
- Routers: `kols_router.py`

---

## Domain Model Rules

### Rich, Not Anemic

Domain models must have behavior. Not just dataclasses with field access.

**Anti-pattern (anemic)**:
```python
@dataclass
class Thesis:
    id: str
    ticker: str
    raw_text: str
    status: str
# Logic lives in service... wrong
```

**Correct (rich)**:
```python
@dataclass
class Thesis:
    id: ThesisId
    ticker: Ticker
    bull_case: BullCase
    bear_case: BearCase
    catalysts: list[Catalyst]
    confidence: ConfidenceScore
    status: ThesisStatus = ThesisStatus.DRAFT
    _events: list[DomainEvent] = field(default_factory=list)

    def submit(self) -> None:
        if self.status != ThesisStatus.DRAFT:
            raise InvalidStateError("Can only submit draft theses")
        if not self.bear_case.is_substantive():
            raise InvariantViolation("Thesis must include substantive bear case (charter principle)")
        self.status = ThesisStatus.ACTIVE
        self._events.append(ThesisSubmittedEvent(self.id, self.ticker, datetime.utcnow()))
```

### Invariants Enforced in Constructors / `__post_init__`

Every domain object validates its invariants at construction. Invalid states are unrepresentable.

**Stock-specific examples**:
- `Money` cannot be constructed with negative VND (positive only; for losses use signed wrappers)
- `Ratio` like P/E ≥ 0; if EPS < 0 → store as None with reason
- `Recommendation` must have ticker + direction + timeframe + extracted_at + source_url
- `PumpDetection` must specify phase (incubation/emerging/distribution/dump) with confidence

---

## Event-Driven Rules

### Domain Events

- Every state change emits a domain event
- Events are past-tense facts (`KolRecommendationExtracted`, not `ExtractKolRecommendation`)
- Events belong to the aggregate that created them
- Cross-BC events use shared contract types

### Event Flow

**Phase 1**: Synchronous in-process (simple pub/sub via Redis or in-memory)
**Phase 2+**: Dramatiq queue for async processing
**Phase 3+**: Consider event-driven across BCs with proper broker (Redis Streams or NATS)

### Critical Stock-Domain Events

```python
@dataclass(frozen=True)
class KolRecommendationExtracted:
    kol_id: KolId
    ticker: Ticker
    direction: Direction        # BUY | HOLD | SELL | WATCH
    timeframe: Timeframe
    confidence_extracted: float # how sure LLM is about extraction (NOT recommendation strength)
    source_url: str
    source_type: SourceType     # YOUTUBE_VIDEO | FACEBOOK_POST | etc
    published_at: datetime
    extracted_at: datetime

@dataclass(frozen=True)
class PumpDetected:
    ticker: Ticker
    phase: PumpPhase
    phase_confidence: float
    contributing_signals: list[SignalSnapshot]
    detected_at: datetime

@dataclass(frozen=True)
class NarrativePhaseChanged:
    narrative_id: NarrativeId
    from_phase: NarrativePhase
    to_phase: NarrativePhase
    affected_tickers: list[Ticker]
    detected_at: datetime
```

---

## Testing Architecture

### Test Pyramid

```
           E2E / BDD (slowest, fewest)
          - Full thesis workflow
         - Backtest end-to-end
        Integration
       - Use case tests with real DB
      - Adapter tests (vnstock, scrapers)
     - LLM extractor tests with snapshots
    Unit (fastest, most)
   - Pure domain logic
  - Value objects (Ticker validation, Money math)
 - Domain services (valuation formulas)
- Pump detection rules
```

### Stock-Specific Test Categories

- **Domain tests**: pure logic, no LLM, no DB. `pytest packages/domain/`
- **Backtest tests**: replay historical data, verify decisions. `pytest tests/backtest/`
- **LLM extractor snapshot tests**: input text → expected structured output. Cached for reproducibility.
- **Calibration tests**: KOL credibility scores converge correctly given outcome data.

### Location

- Unit tests: co-located `test_*.py` next to source
- Integration tests: `apps/*/tests/`
- BDD: `bdd/features/*.feature` + Python step definitions
- Backtest: `tests/backtest/`

---

## Non-Negotiable Patterns

### 1. Repository Pattern
All DB access through repositories defined as Protocols in domain, implemented in infrastructure.

### 2. Use Case Pattern
Application layer is use cases, one per business operation. No "service" god-classes.

### 3. DTO at Boundary
HTTP layer uses Pydantic DTOs. Never expose domain entities directly in API responses.

### 4. Mapper Layer
Between DTO ↔ Domain ↔ Persistence. Keep boundaries clean.

### 5. CQRS (light)
Commands (writes) and queries (reads) use different paths. Not full event sourcing — just separation.

### 6. ⭐ No-LLM-Math Pattern
LLM never returns numeric output as content. LLM returns either:
- Structured tool call to a deterministic Python function that does the math
- Classification labels (categorical, not numerical)
- Free text reasoning (qualitative only)

If LLM output contains a number, that number must trace to a tool call result.

### 7. ⭐ Point-in-Time Integrity Pattern
Every fundamental data row has `filing_date` (when it became known) AND `period_end` (what period it represents). Backtest queries must filter `WHERE filing_date <= as_of_date` to avoid look-ahead bias.

### 8. ⭐ Source Citation Pattern
Every claim, every extracted recommendation, every sentiment score has `source_url` + `extracted_at` + `extractor_version`. Ungrounded statements = hallucination = bug.

---

## Forbidden Patterns

- **God services** — single class with 20+ methods doing everything
- **Anemic domain models** — data bags with logic in services
- **Direct cross-BC imports** — must go via contracts
- **Raw SQL in domain** — use repository abstraction
- **Framework leaks into domain** — no FastAPI, no Pydantic in `packages/domain`
- **`Any` types** in domain code (mypy --strict enforces)
- **LLM returning numbers** — must come from code with traceable inputs
- **Hardcoded position sizes** — must come from PortfolioConfig + RiskRules
- **Silent ignoring of stale data** — staleness must propagate to UI/output
- **Single-perspective thesis** — must include bear case explicitly

---

## Slash Command vs Skill — Responsibility Split (D-018, ratified 2026-05-04)

Slash commands (`.claude/commands/<name>.md`) and skills (`.claude/skills/<name>/SKILL.md`) overlap in form (both are markdown procedure files) but should NOT overlap in responsibility. Per L-S14-2 (skill-vs-command duplication multiplier), duplicating procedure between a `/foo` command and a `foo` skill multiplies maintenance cost AND creates drift between the two when one updates and the other doesn't.

### Responsibility Split

| Concern | Slash Command | Skill |
|---|---|---|
| **Trigger** | User explicit invocation: `/<name>` | Auto-discovered by Claude Code via `description:` keyword match |
| **Audience** | User-facing workflow (command sequence to execute) | Agent-facing procedure (rules to follow when context matches) |
| **Body shape** | "When user types `/<name>`, do these N steps" — imperative checklist | "When working in context X, follow this discipline" — declarative rules |
| **Reusability** | Single workflow tied to a slash invocation | Reusable across many tasks that match the description |
| **LOC ceiling** | 120 (per drift-signals D1) | 150 (per drift-signals D1) |

### Anti-Pattern: Duplicated Body

If `/<name>` command and `<name>` skill both exist with overlapping body content, the skill MUST be the source of truth and the command body MUST delegate (e.g., the command body says "invokes `<name>` skill via Skill tool" or copy-references the skill's authoritative rules).

### Boundary Heuristics

- If the procedure runs once per user invocation → slash command
- If the procedure runs across many tasks based on context auto-match → skill
- If both apply: skill carries the body; command is the entry point

### Companion: SKILL.md exceeds ceiling — split to `references/<topic>.md`

Per drift-signals D1 (SKILL.md ≤150 LOC). When body genuinely needs more, split to `references/<topic>.md` companion files; SKILL.md keeps high-density rules + delegates detail. When NOT to split: prose-paraphrase compression keeps body ≤ ceiling without losing content. Phase 0 portability: fewer files = less drift surface.

### Companion: Cross-Locale Pattern Extension (L-S18-1)

Porting regex/keyword/lexicon from source repo: SYNTAX is locale-agnostic, CONTENT isn't. Pre-flight checklist when porting locale-sensitive pattern sets: (1) list patterns in source; (2) translate to Vietnamese (stockforge user is VN-speaking); (3) add target-locale patterns alongside source-locale (bilingual; don't replace); (4) test on locale-specific corpus before declaring port complete.

### Companion: Telemetry Rollup — Deterministic Aggregator Before LLM Guardian (L-S19-1)

For session-level telemetry rollup, prefer deterministic Stop-hook aggregator (bash + awk; ~zero LLM tokens; auditable) over continuous LLM Guardian (~1-5K tokens/poll; non-deterministic; expensive). Reserve LLM analysis for end-of-phase batch interpretation, not real-time aggregation. AP-23 already catalogues continuous LLM-Guardian as anti-pattern.

---

## Evolution Protocol

Architecture can evolve. When it does:
1. Document the why in `agent-workspace/memory/agent-notes.md`
2. Update this file with version bump
3. Run `/drift-check` across codebase to assess impact
4. Create migration plan if breaking

Do NOT silently diverge from these rules. Either follow them, or change them explicitly.

Last modified: 2026-04-23 (v1.0 initial — adapted from IdeaForge for stock domain)
