# Thesis Log

> Append-only log of every investment thesis produced by the system.
> One file per thesis. Filename: `YYYY-MM-DD-{TICKER}-session{N}.md`.

## Rules

- **Append-only.** Never edit a past thesis. Corrections go in a new follow-up thesis with back-reference.
- **Must have bear case** (I-S10).
- **Must cite sources + as-of dates** on every number (I-S1, I-S2).
- **Must declare confidence grade** tied to calibration data (I-S7).
- **Must be framed as exploration**, not advice (I-S35).

## Minimum entry shape

```markdown
# {TICKER} — {as-of YYYY-MM-DD}

- **Session**: N
- **Horizon**: 1m / 3m / 6-12m / 2y+
- **Grade**: A / B / C / D  (tied to calibration record: {link})
- **Thesis summary**: 1-2 sentences.

## Bull case
1. {claim} — source: {url}, as-of: {date}
2. ...

## Bear case
1. {claim} — source: {url}, as-of: {date}
2. ...

## Catalysts watched
- {catalyst} — expected by {date}

## Invalidation triggers
- {condition that kills the thesis}

## Risk & position sizing (per deterministic rules)
- {position size %, sector exposure after add, stop level}

## Disclaimer
Research aid only. Not financial advice.
```

## Post-mortem link

When horizon elapses, add a post-mortem file under `agent-workspace/memory/post-mortems/` and link from the thesis entry.
