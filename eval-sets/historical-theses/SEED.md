# Historical Theses — Seed File

> Populate this with 5-10 stocks you've had strong opinions on.
> Each entry is a "past thesis" that serves as evaluation data.
> You fill this based on your actual investment history + market observation.

## Purpose

These historical theses become:
1. **Eval set for system quality** — when we backtest thesis validation on these dates, does the system agree with what actually happened?
2. **Calibration baseline** — compare system confidence to outcome
3. **Pattern seed** — patterns you noticed become candidates for pattern library

## Format

Copy the template below for each thesis. Be honest — including thesis that were wrong.

## Template

```markdown
## {TICKER} — {AS_OF_DATE}

**Your call at the time**: {THESIS_CANDIDATE | WATCH | PASS | AVOID}
**Your conviction**: {HIGH | MEDIUM | LOW}

### Bull case (at the time)
1. {Point} — {evidence you had}
2. ...

### Bear case (at the time)
1. {Point} — {evidence you had}
2. ...

### What actually happened
- **6 months**: {price change} vs VN-Index {benchmark}
- **12 months**: {price change} vs VN-Index {benchmark}
- **Narrative path**: {how the story evolved}
- **Catalysts that mattered**: {what actually drove the move}
- **Catalysts that didn't**: {what you expected but didn't happen}

### Your call was: {RIGHT | WRONG | PARTIAL}

### Lessons
- {Lesson 1}
- {Lesson 2}

### Applicable patterns (if any)
- {Pattern name}: {why this case exemplifies it}
```

---

## Example (you fill in with YOUR actual history)

## HPG — 2023-01-15

**Your call at the time**: PASS
**Your conviction**: MEDIUM

### Bull case (at the time)
1. P/B at 5-year low — cyclical value
2. Dividend yield 6%+
3. Iron ore price stabilizing

### Bear case (at the time)
1. Global steel oversupply from China
2. Real estate sector stress in VN affecting demand
3. Quality concerns with governance (related-party transactions)
4. Rising US rates pressuring foreign flow

### What actually happened
- **6 months**: +18% vs VN-Index +4%
- **12 months**: +35% vs VN-Index +12%
- **Narrative path**: steel cycle turned faster than expected due to China stimulus; governance concerns did not materialize as catalyst
- **Catalysts that mattered**: China property stimulus Q2-Q3 2023, iron ore price recovery
- **Catalysts that didn't**: real estate sector stress, governance scandal

### Your call was: WRONG (significantly underperformed by avoiding)

### Lessons
- Cyclical bottoms can reverse on external macro catalysts I wasn't tracking
- I overweighted governance risk vs macro cycle signal
- I should have either taken a starter position or set price alerts

### Applicable patterns
- "Cyclical bottom with external catalyst": value + cyclical + contrarian macro move

---

## Your Theses (FILL IN)

Add 5-10 of your own below. Diverse outcomes — include wrong calls, right calls, mixed.
