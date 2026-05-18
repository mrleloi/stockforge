---
level: WARN
status: pending
---

# python-determinism-check — ALERT

Determinism violations detected: 6

  - R1 [ERR]: apps/_shared/crawl/rate_limiter.py — datetime.now() without timezone (1 occurrence(s)) — use datetime.now(timezone.utc)
  - R1 [ERR]: apps/_shared/entities/vn_ticker_resolver.py — datetime.now() without timezone (1 occurrence(s)) — use datetime.now(timezone.utc)
  - R1 [ERR]: apps/cli/extract_vn_claims.py — datetime.now() without timezone (1 occurrence(s)) — use datetime.now(timezone.utc)
  - R1 [ERR]: apps/cli/resolve_vn_tickers.py — datetime.now() without timezone (1 occurrence(s)) — use datetime.now(timezone.utc)
  - R1 [ERR]: apps/cli/score_vn_sentiment.py — datetime.now() without timezone (1 occurrence(s)) — use datetime.now(timezone.utc)
  - R1 [ERR]: apps/cli/tokenize_vn_text.py — datetime.now() without timezone (1 occurrence(s)) — use datetime.now(timezone.utc)

## Fix guidance
- R1: replace `datetime.now()` with `datetime.now(timezone.utc)`
- R2: use seeded RNG in test fixtures; no bare `random.*` / `secrets.token_*` in production paths
- R3: use `OrderedDict` if iteration order matters; avoid `list(d.keys())[N]` index patterns
- R4: domain layer must be pure functions; remove `time.time()` from `packages/domain/**`

See ADR: agent-workspace/memory/decisions/059-python-determinism-contract.md
