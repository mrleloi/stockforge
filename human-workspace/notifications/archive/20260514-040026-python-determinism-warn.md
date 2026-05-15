# python-determinism-check — ALERT

Determinism violations detected: 1

  - R1 [ERR]: packages/infrastructure/analysis/sqlite_thesis_repository.py — datetime.now() without timezone (1 occurrence(s)) — use datetime.now(timezone.utc)

## Fix guidance
- R1: replace `datetime.now()` with `datetime.now(timezone.utc)`
- R2: use seeded RNG in test fixtures; no bare `random.*` / `secrets.token_*` in production paths
- R3: use `OrderedDict` if iteration order matters; avoid `list(d.keys())[N]` index patterns
- R4: domain layer must be pure functions; remove `time.time()` from `packages/domain/**`

See ADR: agent-workspace/memory/decisions/059-python-determinism-contract.md
