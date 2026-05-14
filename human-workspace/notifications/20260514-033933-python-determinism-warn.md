# python-determinism-check — ALERT

Determinism violations detected: 2

  - R2 [ERR]: packages/application/crowd/use_cases/capture_sentiment_snapshot_use_case.py — random/secrets non-determinism (1 occurrence(s)) outside __main__ block — use seeded RNG per-test fixture
  - R1 [ERR]: packages/infrastructure/analysis/sqlite_thesis_repository.py — datetime.now() without timezone (1 occurrence(s)) — use datetime.now(timezone.utc)

## Fix guidance

See ADR: agent-workspace/memory/decisions/059-python-determinism-contract.md
