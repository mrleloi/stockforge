---
name: test-pyramid-balance
description: Balance unit, integration, and E2E tests properly in Python/pytest. Use when deciding what test to write, reviewing test coverage, or rebalancing skewed test suite. Covers test pyramid shape, BDD vs unit tests, when to use what. Includes stock-domain-specific test categories.
allowed-tools: [Read, Glob, Grep, Bash]
---

# Skill: Test Pyramid Balance

## Purpose

Not all tests are equal. Wrong mix = slow suite, fragile tests, or false confidence. Encodes the layer decisions + stock-domain-specific test categories that prevent the most expensive mistake (testing LLM output content + LLM-computed numbers).

## When to Use

- Deciding what test to write for a new feature
- Reviewing PR test coverage
- Rebalancing a skewed suite (red flags below)
- Authoring a thesis/extractor module — what counts as testable?

## When NOT to Use

- Test-free prototype scripts (Phase 1 spike code)
- Pure UI snapshot tests for Streamlit dashboards (visual regression is its own discipline)

## The Pyramid

```
          /\
         /E2E\        Few (~10-20 in MVP)
        /------\      Slow, expensive, flaky
       /Integra-\     Some (~100-300)
      / tion    \     Medium speed, real systems
     /------------\
    /    Unit      \  Many (~1000+)
   /----------------\ Fast, focused, numerous
```

## Test Layer Decision Table

| Layer | Target | Speed | Deps | Use for |
|---|---|---|---|---|
| **Unit** (`packages/*/tests/`) | Pure domain logic, VOs, services | <10ms | None | Business rules, value object constraints, state transitions, edge cases in domain |
| **Integration** (`apps/*/tests/`, `packages/*/tests/integration/`) | Use cases + adapters | <500ms | Real DB (testcontainers), Redis; mocked external APIs | Repository implementations, event publish/subscribe, queries (incl. point-in-time integrity) |
| **E2E / BDD** (`bdd/features/*.feature`) | Critical user journeys | seconds | Full stack | Happy path of core features, cross-component workflows |

See `references/test-examples.md` for ready-to-paste pytest + gherkin templates.

## Stock-Specific Test Categories

### Domain Tests (`pytest packages/domain/`)
Pure logic, no LLM, no DB. Validate value object invariants (Ticker, Money, Period), aggregate invariants (Thesis requires bear case), state transitions.

### Backtest Tests (`pytest tests/backtest/`)
Replay historical data; verify decisions. **MUST verify point-in-time integrity** — backtest paths use `filing_date <= as_of` filter (I-S2). Never use "latest" fundamental data.

### LLM Extractor Snapshot Tests
Test **structure**, not LLM creativity. Assert that every extracted claim has `source_url`, `extracted_at`, `confidence ∈ [0,1]`. Do NOT assert on specific LLM phrasing — too fragile, and assertions on LLM-generated numbers would violate I-S1.

### Calibration Tests
Given known historical outcomes, score functions should converge. Asserts `0.65 ≤ kol.credibility_score ≤ 0.75` for 7/10 hits, etc. Used to detect calibration drift.

## The 70-20-10 Guideline

For a mature codebase:
- **70% unit** — fast, numerous, cover domain logic
- **20% integration** — verify adapters work
- **10% E2E/BDD** — critical flows end-to-end

In MVP: closer to 50-40-10 may be acceptable. But don't let integration tests dominate — they're slow and brittle.

## Coverage Targets

- **Domain layer** (`packages/domain/`) — 100% unit coverage. Nothing touches IO; no excuse.
- **Application layer** (`packages/application/`) — 80% integration coverage. Use cases tested end-to-end with real DB.
- **Infrastructure** (`packages/infrastructure/`) — adapter contract tests. Each adapter has integration test verifying it meets Protocol.

## Anti-Patterns

### Don't test LLM-generated text content
Asserting `"NPL" in result.bear_case` is fragile — LLM might phrase it differently. Test the **domain invariant** instead: `thesis.bear_case.is_substantive()`.

### Don't test LLM math (it shouldn't exist)
A test like `assert result.pe_ratio == 12.5` after `llm.analyze(...)` is a charter violation (I-S1). Code computes; LLM only interprets. Test the code: `assert compute_pe(price, eps) == pytest.approx(12.5)`.

### Don't invert the pyramid
Integration tests > unit tests in count = ice-cream cone, not pyramid. Slow, brittle, hides domain bugs.

### Don't skip BDD for top user flows
If the top 3 user flows aren't covered by BDD scenarios, the team can't refactor with confidence.

### Don't smear domain rules across integration tests
If domain invariants are only verified through DB-backed integration tests, debugging is slow + the unit layer is empty (red flag).

## Detecting Imbalance — Red Flags

- Integration tests > unit tests in count (inverted pyramid)
- Unit-layer suite > 5 min (too many slow tests at unit layer)
- E2E > 20% of tests (expensive, brittle)
- No BDD scenarios for top 3 user flows
- Domain rules only verified through integration tests (slow, hard to debug)
- Tests asserting on LLM-generated text content or LLM-computed numbers (fragile, charter violation)

## Validation Pre-Conditions

- Suite distribution within ~70/20/10 (or trending toward it)
- Domain layer has 100% unit coverage; no integration test substitutes for missing unit coverage
- Backtest paths filter on `filing_date` (grep — `Grep "filing_date" tests/backtest/`)
- LLM extractor tests assert on structure (`source_url`, `extracted_at`), NOT on text content

## Smoke Test

For task "thesis-validation use case has integration coverage":

Expected output:
- 1 integration test in `apps/api/tests/test_validate_thesis_integration.py` that uses real Postgres via testcontainers + mocks event bus
- Test asserts: persistence (`from_db.status == ThesisStatus.ACTIVE`), event emitted (`ThesisCreated` in published_events)
- Domain invariants (substantive bear case) tested separately as **unit** tests in `packages/domain/analysis/tests/test_thesis.py`

If proposal places domain-invariant tests in unit layer + use-case-with-DB in integration layer + BDD for the user-facing flow → pyramid is balanced.

## See Also

- `references/test-examples.md` — full pytest + gherkin templates (unit, integration, BDD, snapshot, calibration, anti-pattern)
- `spec-dual-layer` SKILL.md § B.9 — test requirements section in specs
- `ddd-tactical-patterns` SKILL.md — what's worth unit testing
- `fastapi-module` SKILL.md — integration test setup (Phase 2+)
