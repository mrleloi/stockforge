# Troubleshooting — StockForge

> Common issues and how to address them.

---

## Setup Issues

### "Claude Code doesn't recognize my project"

- Verify you're in the project root (where `CLAUDE.md` lives)
- Check `CLAUDE.md` is valid markdown (no BOM, UTF-8)
- Try `/session-start` explicitly

### "Postgres extensions not available"

If `CREATE EXTENSION timescaledb` fails:
- Check docker image includes TimescaleDB. Default in `docker-compose.yml` is `timescale/timescaledb-ha:pg16`
- If using plain `postgres:16`, switch image
- For pgvector: `ankane/pgvector:latest` or include in TimescaleDB-HA image

### "Environment variables not loading"

- Verify `.env` at project root
- Use `python-dotenv` or similar in Python apps
- Check `.env.example` for required keys

---

## Data Pipeline Issues

### "vnstock returning stale data"

- vnstock may be rate-limited or sources upstream changed
- Fall back to TCBS API or VnDirect public
- Add source_provider tag so you can trace which source failed

### "Scraper blocked by source"

- Check robots.txt compliance
- Lower rate limit (increase delay between requests)
- Verify user agent identifies you + contact email
- Consider if source has official API

### "Point-in-time query returning future data"

**Symptom**: backtest shows suspiciously good results.

**Cause**: Look-ahead bias. Some query path bypassing `get_as_of()`.

**Fix**:
1. Grep for `get_latest` or `get_by_period` calls in backtest paths
2. Ensure all backtest queries go through `get_as_of(ticker, as_of_date)`
3. Run test: query for 2022-01-01 — data referenced must have `filing_date <= 2022-01-01`

---

## LLM / Agent Issues

### "Agent is hallucinating numbers"

**Symptom**: Agent output says "approximately 18%" or similar vague numerics.

**Cause**: LLM generating numbers instead of computing.

**Fix** (I-S1 enforcement):
1. Check if agent has proper tool set (compute_* functions)
2. Prompt must say "NEVER state numbers in prose — use tool calls"
3. Add output validator: regex for "approximately|around|roughly" + number → reject
4. Re-run with explicit tool requirement

### "Perspectives converge to same conclusion"

**Symptom**: Bear agent returns bullish points, or vice versa.

**Cause**: Prompt not adversarial enough, or shared context leaking through.

**Fix**:
1. Check each perspective uses separate LLM invocation (not shared conversation)
2. System prompts should be explicitly adversarial ("your job is to find reasons NOT to buy")
3. Each perspective should NOT see others' output

### "Bear case is boilerplate"

**Symptom**: Bear points like "market volatility" or "regulatory risk" without specifics.

**Cause**: Insufficient data context OR prompt not specific enough.

**Fix**:
1. Verify data gatherer provided concrete recent events
2. Prompt: "Focus on specific, material risks — not boilerplate. Each point must reference specific data in the provided context."
3. Validator: reject bear points <50 chars or without citation

### "KOL extraction missing key recommendations"

**Symptom**: You watched the video, KOL clearly said "buy HPG", but system didn't extract.

**Cause**: LLM confidence threshold too strict, or prompt not calibrated for Vietnamese nuances.

**Fix**:
1. Check extraction_confidence — may have been <0.7 (skipped)
2. Review transcript quality — Whisper may have garbled key phrase
3. Refine extractor prompt with Vietnamese-specific phrasings
4. Add to eval set for calibration

### "Claude API rate limited"

- Check current tier limits
- Batch requests where possible
- Use Haiku for high-volume classification (sentiment, low-stakes extraction)
- Reserve Opus for synthesis only
- Implement exponential backoff

### "Session hit token budget before completing"

- Session was too ambitious — split into multiple sessions
- Check `session-budgets.md` for type budgets
- Never mix PLAN + IMPL (always fails budget)

---

## Architecture Drift

### "Domain has framework import"

**Symptom**: Drift signal DR1 fires.

**Cause**: Someone imported FastAPI or Pydantic into `packages/domain/`.

**Fix**:
1. `grep -rn "from fastapi" packages/domain/ --include="*.py"`
2. Move framework-dependent code to `infrastructure/`
3. Define Protocol in `application/` that domain uses, adapter implements

### "Cross-BC direct import"

**Symptom**: Drift signal DR8 fires.

**Cause**: BC-6 directly imports from BC-5 domain.

**Fix**:
1. Define shared types in `packages/contracts/`
2. Communicate via domain events (BC-5 publishes, BC-6 subscribes)
3. Refactor import to use contract

---

## Calibration Issues

### "KOL credibility scores stuck at 0.5"

**Symptom**: All KOLs show bayesian_mean near 0.5 with wide CI.

**Cause**: Insufficient outcome data. Bayesian prior dominates.

**Fix**:
- This is expected early (<20 evaluations per KOL)
- Wait for more outcomes
- Verify outcome scheduler is running (cron enabled)
- Verify reviews are being completed (check `outcome_reviews` table)

### "Pump detection triggering on everything"

**Symptom**: 10+ pump warnings per day, all false.

**Cause**: Thresholds too low.

**Fix**:
1. Tune `PumpPhaseClassifier` thresholds
2. Require multi-signal agreement (single signal insufficient)
3. Validate against historical labeled pumps — measure precision
4. Don't deploy rule until precision >0.5 on holdout

### "Pump detection never triggers"

**Symptom**: No warnings even during obvious market events.

**Cause**: Thresholds too strict, or signal sources not producing data.

**Fix**:
1. Check each signal input has data (sentiment snapshots updating?)
2. Lower thresholds gradually
3. Validate on historical pump — system should detect it retroactively

---

## Quality Gate Failures

### "mypy --strict failing"

- `Any` in domain code → violates I-12. Replace with proper types.
- Missing type hints → add explicit types
- Never use `# type: ignore` to silence — fix the type

### "pytest failing"

- Run with `-v` for detail
- For integration tests: check DB is running + migrated
- For LLM tests: use snapshot fixtures, not live calls

### "drift-signals HIGH"

- Stop current work
- Read drift report in `agent-workspace/quality-reports/drift-reports/`
- Address before continuing

### "Eval set regression"

- Run `/calibration-report` to see what degraded
- Revert recent changes one-by-one
- Likely cause: prompt change, threshold change, or new bug

---

## Performance / Cost

### "Thesis validation costing >$5"

- Check which perspective is consuming most tokens
- Verify data gatherer isn't over-fetching
- Use Sonnet for perspectives, Opus only for Quant + Synthesizer
- If still expensive: thesis card too verbose, simplify

### "Daily LLM budget ($10) exceeded early"

- Check what triggered: batch extraction, large transcription?
- Move high-volume tasks to Haiku
- Cache LLM calls when possible (same input = same output)
- Set stricter daily cap temporarily

### "Scraper + transcription slow"

- YouTube rate limits are strict — use yt-dlp
- Whisper local on decent GPU = ~5x realtime
- Whisper API faster but costs more
- Skip transcription for non-target content (use metadata only for first pass)

---

## Personal Usage

### "I'm not dogfooding consistently"

**Red flag**. If not using weekly, the feature dies.

**Fix**:
1. Set explicit reminder (calendar block) for Wed/Fri dogfood
2. Start tiny: 1 ticker/week is acceptable
3. If still not using: feature isn't valuable yet, that's the real signal

### "Output feels generic"

**Cause**: Possibly insufficient data, or prompts too abstract.

**Fix**:
1. Review what data each perspective had access to — was it sufficient?
2. Check eval set: does output vary between clearly-different tickers?
3. Refine prompts with Vietnamese market specificity

### "I keep disagreeing with system"

**Good** (mostly). This is adversarial by design.

But also check:
1. Is system wrong for a reason you could articulate?
2. Would your reason be detectable as a rule?
3. Add to agent-notes.md as learned rule

If you ALWAYS disagree: system probably has wrong frame. Reconsider.

### "I followed system, lost money"

**Expected sometimes.** System is advisory. 65% hit rate = 35% wrong.

Review:
1. Did system give HIGH confidence or LOW?
2. Did you follow blindly or think independently?
3. Was this within expected hit rate, or outlier?

Post-mortem honestly. Calibrate expectations.

---

## Emergency Recovery

### "Everything is broken"

1. `git status` — what changed?
2. `git diff` — review changes
3. `git stash` — save work-in-progress
4. `git checkout last-known-good-tag` — revert to working state
5. Investigate changes one by one

### "Database corrupted"

1. Don't `docker-compose down -v` unless you have backup
2. Try `pg_dump` to salvage
3. Restore from R2 backup (if configured)

### "Lost several days of work"

- This shouldn't happen with git discipline
- If it did: post-mortem — what went wrong with workflow?
- Add to agent-notes: "commit more frequently" or similar

---

## Getting Help

- Search `agent-workspace/memory/agent-notes.md` — may have answer
- Search `agent-workspace/memory/drift-logs/` — similar issue before?
- Search `agent-workspace/memory/post-mortems/` — similar outcome before?
- Re-read relevant spec — often answer is there
- If truly stuck: document the issue carefully + post-mortem later

---

## Prevention

Best troubleshooting = not needing it.

- Follow Day 1 checklist thoroughly
- Use VBW protocol religiously (prevents most bugs)
- Don't skip post-mortems
- Commit often, small commits
- Test before assuming it works

Last updated: 2026-04-23
