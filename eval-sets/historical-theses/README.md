# Historical Theses — Eval Set

> See `SEED.md` for the format you personally populate.
> System uses these as a retrospective backtest of thesis validation quality.

## Files

- `SEED.md` — your hand-populated ground truth.
- `idea-*.md` / `thesis-*.md` — individual entries (one per thesis). Optional; may keep everything in SEED.md until volume warrants splitting.

## Quality gate

Before the eval-set is used by `/session-verify`:
- ≥10 entries covering ≥3 sectors.
- Each entry has an **honest** outcome field (even for wrong calls).
- At least 1 entry where your original call was WRONG — otherwise the eval set is biased toward your wins.
