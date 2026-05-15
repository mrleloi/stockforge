---
status: RESOLVED
resolved_at: 2026-05-15
resolved_by: S329 W0-2.1 sandwich-dev
resolved_via: D-059 R1+R2 production fixes committed
---

# python-determinism-check — RESOLVED

S329 W0-2.1 fixed both pre-existing violations:

- R1 `packages/infrastructure/analysis/sqlite_thesis_repository.py:206` — `datetime.now()` replaced with `datetime.now(UTC)`.
- R2 `packages/application/crowd/use_cases/capture_sentiment_snapshot_use_case.py:180` — `random.sample()` replaced with `self.rng.sample()` via constructor-injected `random.Random`.

Hook re-run: OK (0 violations across 343 file(s)) — see `.session-hooks.log` entry at 2026-05-15T16:13:27+07:00.

See ADR: agent-workspace/memory/decisions/059-python-determinism-contract.md
