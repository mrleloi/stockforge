---
name: fastapi-module
description: Implement FastAPI routers following StockForge conventions. Use when creating a new HTTP endpoint, adding routes, wiring dependency injection, configuring Pydantic DTOs. Covers router boundaries, provider patterns, testing setup. Phase 2+ only — Phase 1 uses Streamlit dashboard directly.
---

# Skill: FastAPI Module

## Purpose

Consistent FastAPI router structure across StockForge's HTTP gateway (Phase 2+).

> Phase 1 uses Streamlit for the personal dashboard. FastAPI is for Phase 2+ public API or when a proper HTTP interface is needed for workers.

## When to Use

- Creating a new HTTP endpoint or adding routes
- Wiring dependency injection / Pydantic DTOs
- Setting up router-level test scaffolding

## When NOT to Use

- Phase 1 work (use Streamlit directly)
- Domain layer logic (use `ddd-tactical-patterns` skill — domain has zero framework dependency)

## Module Layout

```
apps/api/<bc_name>/
├── routers/<resource>_router.py    # one router per resource
└── dto/<resource>_dto.py            # Pydantic Request/Response + Mapper
packages/application/<bc_name>/use_cases/<verb>_<resource>_use_case.py
packages/domain/<bc_name>/repositories/<resource>_repository.py     # Protocol port
packages/infrastructure/<bc_name>/persistence/<resource>_postgres_repository.py  # adapter
```

## Naming Conventions

| Type | Pattern | Example |
|---|---|---|
| Router | `<resource>_router.py` | `theses_router.py` |
| DTO request | `<Action><Resource>Request` | `CreateThesisRequest` |
| DTO response | `<Resource>Response` | `ThesisResponse` |
| Use case | `<Verb><Resource>UseCase` | `ValidateThesisUseCase` |
| Mapper | `<Resource>Mapper` | `ThesisMapper` |

## Router Template (skeleton)

```python
from fastapi import APIRouter, Depends, status
from typing import Annotated

router = APIRouter(prefix="/theses", tags=["analysis"])

def get_validate_thesis_use_case(
    db: Annotated[DatabaseClient, Depends(get_db)],
    event_bus: Annotated[EventBus, Depends(get_event_bus)],
) -> ValidateThesisUseCase:
    return ValidateThesisUseCase(
        thesis_repo=ThesisPostgresRepository(db),
        event_bus=event_bus,
    )

@router.post("/", response_model=ThesisResponse, status_code=status.HTTP_201_CREATED)
async def create_thesis(
    request: CreateThesisRequest,
    use_case: Annotated[ValidateThesisUseCase, Depends(get_validate_thesis_use_case)],
) -> ThesisResponse:
    result = await use_case.execute(
        ticker=request.ticker,
        bull_case_text=request.bull_case,
        bear_case_text=request.bear_case,
    )
    return ThesisMapper.to_response(result)
```

## DTO + Mapper Rules (Pydantic v2 — interfaces layer ONLY)

- **Request**: `BaseModel` + `@field_validator` for normalization (`ticker.strip().upper()`) and substantive-content checks (e.g., bear case ≥50 chars per I-S10).
- **Response**: `BaseModel` with primitive types (`str`, `int`, `datetime` → ISO string). No domain objects exposed.
- **Mapper**: static `to_response(domain_obj) -> ResponseDTO`. Mapping happens at boundary, not in use case.

## Port + Adapter

- **Port** (`Protocol` in `packages/domain/<bc>/repositories/`): defines async interface (`save`, `find_by_id`).
- **Adapter** (in `packages/infrastructure/<bc>/persistence/`): concrete implementation injected at router DI.

Never skip the Protocol indirection — it's what enables fakes in tests + swap of persistence later.

## App Factory

`apps/api/main.py`: `create_app()` returns `FastAPI` configured with title/version, then `app.include_router(<bc>_router, prefix="/api/v1")` per BC.

## Testing Setup

Use `fastapi.testclient.TestClient` + `app.dependency_overrides[get_<x>_use_case] = lambda: mock_use_case` for per-test injection. Mock `AsyncMock(spec=UseCase)`. Assert HTTP status + that `mock_use_case.execute.assert_called_once()`.

## Router Boundary Rules

- **Never import** another BC's router module directly
- **Never import** `packages/domain/<otherBc>/` from this router
- Cross-BC integration goes via: domain events (publish/subscribe), HTTP calls if service boundary required, or shared kernel (`packages/contracts/`)

## Anti-Patterns

- Business logic in routers (use cases own it)
- Importing repositories directly in routers (use case mediates)
- Pydantic models in domain layer (domain uses dataclasses)
- Mixing use cases from multiple BCs in one router
- Skipping Protocol/port for "simple" repos

## Do

- One router per BC resource
- Thin routers, thick use cases
- Protocol/adapter everywhere for testability
- Pydantic DTOs at HTTP boundary only
- Validate inputs at DTO level

## Related

- `ddd-tactical-patterns` — domain models this router consumes
- `postgres-pgvector` — repository implementation patterns
