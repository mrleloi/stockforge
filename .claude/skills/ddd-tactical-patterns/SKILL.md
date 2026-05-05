---
name: ddd-tactical-patterns
description: Apply DDD tactical patterns (aggregate, entity, value object, repository, domain event, anti-corruption layer) correctly in Python/dataclasses code. Use when designing or implementing domain models, repositories, or cross-bounded-context communication in StockForge's 9 BCs.
allowed-tools: [Read, Glob, Grep, Bash, Edit, Write]
---

# Skill: DDD Tactical Patterns

## Purpose

Apply Domain-Driven Design tactical patterns correctly in StockForge's Python stack. Domain layer is pure Python (`packages/domain/`) — dataclasses only, NO Pydantic, NO framework imports. Persistence + transport translate at the edges.

## When to Use

- Designing a new aggregate
- Implementing repository Protocol for a new entity
- Creating domain events
- Building anti-corruption layer between BCs
- Deciding: entity vs value object vs aggregate root?

## When NOT to Use

- Simple CRUD with no business rules — plain function is fine
- Infrastructure-layer utilities — DDD is a domain-layer doctrine
- UI / presentation components — keep them framework-aware
- Phase 1 prototype scripts — domain-layer rigor is Phase 2+

## Key Decisions

### Entity vs Value Object

| | Entity | Value Object |
|---|---|---|
| Identity | Has ID | None |
| Lifecycle | Mutable | Immutable (`frozen=True`) |
| Equality | By ID | By all fields |
| Question | "Which one?" | "What is it?" |
| Examples | `Thesis`, `KolRecommendation`, `PumpDetection` | `Ticker`, `Money`, `Period`, `ThesisId`, `CredibilityScore` |

### Aggregate vs Entity

**Aggregate** = cluster of entities + value objects with a single root entity enforcing invariants. External code only touches the aggregate root.

Rule: **aggregate boundary = transaction boundary = consistency boundary**. One aggregate per transaction.

Example: `Thesis` aggregate contains `BearCase`, `BullCase`, `Catalyst` list — `BearCase` is never loaded or mutated independently of its `Thesis`.

### Repository Placement

- **Protocol** lives in `packages/domain/<bc>/repositories/<name>_repository.py` — pure typing, no framework imports
- **Implementation** lives in `packages/infrastructure/<bc>/persistence/<name>_postgres_repository.py` — translates between domain ↔ rows

## Aggregate Rules

1. **Constructors validate** — `__post_init__` enforces invariants; impossible states unrepresentable
2. **State changes via methods** — no public attribute mutation from outside
3. **Methods emit events** — every state change appends to `_events: list[DomainEvent]`
4. **Return copies of collections** — don't leak mutable internals (`return list(self._catalysts)`)
5. **Validate in methods** — raise specific domain errors (`InvariantViolation`, `InvalidStateError`)
6. **Use `@classmethod` factories** — `create()` for new instances, `reconstruct()` for repository hydration

## Cross-BC Communication

NEVER import directly across bounded contexts. Use **contracts** in `packages/contracts/`:

- BC A publishes `events/<bc-a>_events.py` defining the event shape
- BC B subscribes to that contract; never imports BC A's domain
- Translation between domain event ↔ contract event happens at the publish boundary

If you find yourself writing `from packages.domain.<bc-a>` inside `packages/domain/<bc-b>/` — STOP, route via contract instead.

## Anti-Corruption Layer (ACL)

When integrating with an external system (vnstock, FiinPro, scrapers), put translation in `packages/infrastructure/<bc>/external/<source>_adapter.py`:

- Validate required external fields → raise `MissingFieldError` early
- Transform external schema → domain value objects (`Ticker.from_str`, `Money.vnd`)
- Domain layer never sees raw external dict

The adapter is the only place that knows the external schema. If the external schema changes, only the adapter changes.

## Common Mistakes

- **Anemic Model**: state mutation lives in service, model is a data bag. Symptom: `thesis.status = 'active'` from outside the aggregate.
- **Entity-as-VO**: giving a VO an ID, or making an entity `frozen=True`. Pick one.
- **Aggregate too large**: every transaction loads + locks the whole tree. If load + save thrashes, split.
- **Aggregate too small**: invariants span aggregates and become eventually-consistent when they should be transactional. If you find yourself wrapping two repository saves in one application service, the aggregate boundary is wrong.
- **Repository leaks raw rows**: caller deals with `dict[str, Any]`. Always hydrate to domain object inside repo.
- **Cross-BC import**: `from packages.domain.kol_tracking.kol import Kol` inside `packages/domain/analysis/` — replace with contract.

## Validation Pre-Conditions

- Aggregate root inherits `AggregateRoot` mixin → has `_events` list + `get_events()` + `clear_events()`
- Value object is `@dataclass(frozen=True)` + `__post_init__` validation
- Repository Protocol methods are `async`
- No `from fastapi`, `from pydantic`, `from sqlalchemy` in `packages/domain/**`
- No cross-BC imports (`from packages.domain.<other_bc>` from inside another BC's domain)

## Smoke Test

For task "model a KOL recommendation as an aggregate":

Expected output shape:
- `KolRecommendation(AggregateRoot)` — root entity with id (`KolRecommendationId` VO), kol_id (`KolId` VO), ticker (`Ticker` VO), action (enum), recommended_at, source_url, confidence (`CredibilityScore` VO derived)
- Value objects: `KolRecommendationId`, `KolId`, `Ticker`, `CredibilityScore` — all frozen dataclasses with validation
- Repository Protocol in `packages/domain/kol_tracking/repositories/`; implementation NOT in domain
- `KolRecommendation.create()` factory + `submit()` method emitting `KolRecommendationSubmittedEvent`
- Cross-BC: `analysis` BC subscribes to a contract version of the event, NOT the domain event directly

If proposal includes all of the above and no Pydantic / FastAPI imports in domain → skill is functional.

## See Also

- `references/code-templates.md` — full Python templates (aggregate root, VO, repository, ACL, anemic vs rich)
- `spec-dual-layer` SKILL.md — specs that drive these implementations
- `fastapi-module` SKILL.md — wire DI for repositories at the edge (Phase 2+)
- `postgres-pgvector` SKILL.md — persistence schema for these aggregates
- `agent-workspace/constitution/architecture.md` — 9 BC list + boundary rules
