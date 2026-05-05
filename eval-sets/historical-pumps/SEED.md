# Historical Pump Patterns — Seed File

> Populate with 3-10 pump cycles you witnessed in VN market history.
> This is training/validation data for BC-7 (spec 003) pump detection.

## Purpose

- Evaluation set for pump phase classifier
- Historical analog library for new pump detections
- Pattern library source — repeated structures become detectable rules

## Format

```markdown
## {TICKER or GROUP_NAME} — {PERIOD}

### Overview
- **Type**: {coordinated_pump | momentum_cycle | narrative_driven | short_squeeze | retail_frenzy}
- **Narrative claimed**: {what was the story}
- **Narrative actual**: {what was the reality, if different}

### Phase Timeline (approximate)

| Phase | From | To | Notable signals | Price |
|---|---|---|---|---|
| PRE_PUMP | {date} | {date} | {signals you noticed or in retrospect} | {price range} |
| PUMP | {date} | {date} | {signals} | {price} |
| DISTRIBUTION | {date} | {date} | {signals} | {price} |
| DUMP | {date} | {date} | {signals} | {price} |

### Evidence of coordination (if applicable)
- {e.g., "multiple KOLs mentioned within same week", "forum posts had similar talking points"}

### Subsequent outcome
- **6 months post-peak**: {price}
- **12 months post-peak**: {price}
- **Outcome category**: {recovered | permanent_loss | delisted | suspended}

### Lessons
- {What would have signaled this to you earlier}
- {What features were hardest to detect at the time}

### System detection hypothesis
- Which signals (T1/T2/T3/T4) would have triggered detection?
- Which phase would have been detectable first?
- Estimated confidence level that could be achieved
```

---

## Example

## FLC (and related) — Nov 2021 to Jan 2022

### Overview
- **Type**: coordinated_pump with insider involvement
- **Narrative claimed**: "real estate recovery + cryptocurrency diversification"
- **Narrative actual**: pre-planned distribution by connected parties, eventually exposed

### Phase Timeline (approximate)

| Phase | From | To | Notable signals | Price |
|---|---|---|---|---|
| PRE_PUMP | Sep-Oct 2021 | early Nov 2021 | Quiet accumulation, low volume | 11-13k |
| PUMP | mid Nov 2021 | Dec 2021 | Volume spike, KOL mentions, FB group hype | 13-22k |
| DISTRIBUTION | Dec 2021 | early Jan 2022 | High volume flat price, novice posts dominant | 20-24k |
| DUMP | Jan 10-20, 2022 | Feb 2022 | Triggered by trading violation exposé | 24k → 11k crash |

### Evidence of coordination
- Multiple FB groups promoted the stock with similar talking points within same week
- Known figures appeared on YouTube interviews simultaneously
- Forum F319 threads had repetitive pro-FLC narratives

### Subsequent outcome
- **6 months post-peak**: price at 3-5k, down 80%+
- **12 months post-peak**: trading halted, regulatory action ongoing
- **Outcome category**: eventual delisting + criminal charges against main operator

### Lessons
- Volume pattern (rising gradual accumulation → sudden spike) was detectable
- KOL mention clustering was detectable in retrospect
- Official narrative had weak fundamentals — T1+T2 weak was a warning
- Dismissing concerns as "haters hating" was common response from bulls

### System detection hypothesis
- T1: volume pattern + price acceleration would trigger PRE_PUMP → PUMP classification
- T3: KOL cluster mentions (if calibrated) would add confidence
- T4: forum coordination score likely 0.7-0.9 range
- Estimated detectable confidence at PUMP phase: 0.7-0.8

---

## Your Pump Cases (FILL IN)

Add 3-10 cases you witnessed. Include:
- Clear pumps (coordination evident)
- Ambiguous cases (narrative cycle vs pump — the boundary matters)
- Failed pumps (pumps that didn't sustain — useful for precision)
- Recent cases (2023-2025, most relevant data)
- Historical cases (2018-2022, for cycle variety)

---

## Notes on Labeling

**Be honest about your information at the time.** You may have missed signals that are obvious in retrospect — note those separately.

**Don't name individuals** as perpetrators. Describe patterns, not persons.

**"I thought this was a pump but it wasn't"** cases are ALSO valuable — they improve system precision.

**Update annotations as system catches similar pumps** — feedback loop.
