# Post-Mortems

> After a thesis hits its horizon (or is invalidated), write the review here.
> Filename: `YYYY-MM-DD-{TICKER}-horizon{Nm}.md`.

## Entry shape

```markdown
# Post-Mortem — {TICKER} — horizon {3m/6m/12m}

- **Original thesis**: {link to thesis-log entry}
- **Original grade / confidence**: {A/B/C/D}
- **Original as-of**: {date}
- **Review as-of**: {date}

## Outcome (numbers via code, not LLM)
- Price change: {x%} vs VN-Index {y%}
- Key catalysts realized: {list with dates}
- Key catalysts failed to realize: {list}
- Invalidation triggered: yes/no — if yes, when

## Verdict
- RIGHT / WRONG / PARTIAL — justification

## Calibration impact
- Signal sources that contributed: {list}
- Calibration adjustments proposed for: {KOL / pattern / agent perspective}

## Lessons
- What the system saw correctly:
- What the system missed:
- What to change in the thesis pipeline:

## Bias check
- Was user's gut aligned or contrarian to thesis? Outcome?
- Confirmation bias risk flagged? Yes/no.
```

## Rule

Post-mortems feed the Karpathy outer loop (see `specs/tier2-feature/005-karpathy-outer-loop.md`). Missing post-mortems = broken compounding.
