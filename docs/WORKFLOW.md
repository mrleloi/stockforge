# Workflow — StockForge

> How to actually work on this project week-to-week.
> Assumes Day 1 complete.

---

## The Three Loops Recap

**Inner loop** (per-query, minutes): validate thesis on a ticker → get card → decide
**Middle loop** (continuous, hourly/daily): data ingestion, news processing, KOL tracking, reviews
**Outer loop** (weekly, Year 2+): pipeline self-optimization via Karpathy pattern

Day-to-day, you mostly operate in the inner + middle loops. Outer loop is automated.

---

## Weekly Rhythm (Phase 1-2)

### Monday — Week Planning

- Read `agent-workspace/memory/current-execution.md` — what's active?
- Open latest pending session plan
- Estimate week's work in 2-3 focused sessions
- Update project.md if phase-level decisions surfaced

### Tuesday/Thursday — Deep Work Sessions

Block 2-3 hours. Single session per block. Don't multitask.

Choose session type:
- **PLAN** (50-80K) — architect proposes session plan for a feature
- **FOCUSED IMPL** (100-150K) — dev does 1-3 tasks from plan
- **MULTI-TASK IMPL** (150-250K) — dev does 4-10 tasks (higher risk)
- **VERIFY** (30-60K) — verifier reviews recent work adversarially
- **THESIS** (60-100K) — run thesis validation on specific ticker (uses existing code, no code changes)
- **INGEST** (40-80K) — process new data source into KB
- **POST-MORTEM** (30-50K) — review thesis outcomes, update calibration

**Never mix PLAN and IMPL in same session.**

### Wednesday/Friday — Dogfood Sessions

Not coding. Running the tool on real decisions.

- Run thesis validation on 3-5 watchlist tickers
- Review KOL digest (once Phase 2 shipped)
- Review any alerts (pump detections, confluence)
- Log observations in `agent-workspace/memory/agent-notes.md` when the tool surfaces something you didn't think of — or when it misses something

**This is where edge is built.** Coding without dogfood = speculative features that die.

### Friday EOD — Review & Commit

- Read `agent-workspace/memory/sessions/` for this week
- Update `agent-workspace/memory/project.md` if architectural decisions made
- Update `current-execution.md` (what's next)
- Stage + commit work (`git add` then your decision on commit)

### Weekend — Low-touch

- Maybe review thesis log
- Maybe read research papers / others' analyses (input to wiki)
- Don't force sessions — burnout is bug-class

---

## Monthly Rhythm

### First Sunday of Month — Outcome Reviews

Run post-mortem batch:
```
/post-mortem-batch
```

This evaluates outcomes of:
- Thesis with 1m/3m/6m/12m review windows due
- KOL recommendations with windows due
- Pump detections with windows due

Each outcome feeds calibration database. Over time, this is the moat.

### Mid-Month — Eval Set Review

- Add 2-3 new theses to historical-theses eval set (from real recent decisions)
- Add any new KOL recommendations you noticed
- Label any new pumps that completed cycles
- Review 2 random thesis outputs for quality regressions

### End of Month — Phase Check

- Am I on track for phase goals? (see project.md)
- What's drifted? What's on track?
- Do I need to adjust scope or timeline?

---

## Per-Feature Workflow (The Sandwich)

Every significant feature goes through three sessions minimum:

### Session 1: Architect (PLAN)

Output: session plan in `agent-workspace/session-plans/pending/NNN-feature-name.md`

Architect agent (/master-plan or /plan-feature):
- Reads relevant spec
- Breaks into tasks
- Identifies risks
- Estimates session count + tokens
- Does NOT write code

### Session 2-N: Dev (IMPL)

Output: working code + tests

Dev agent:
- Reads session plan
- Applies VBW protocol (verify source before writing)
- Implements tasks
- Updates spec if reality diverges
- Does NOT review own work adversarially

### Session N+1: Verifier (VERIFY)

Output: verification report + fix list

Verifier agent (separate context):
- Reads spec + recent commits
- Adversarially reviews
- Checks invariants
- Runs drift signals
- Reports issues

Only when verifier passes → feature is "done".

---

## Per-Thesis Workflow (Inner Loop)

When evaluating a stock:

### Quick Check First (<30 seconds, <$0.50)

```
/quick-check HPG
```

Runs Quant + Behavior perspectives only. Output:
- Rough fair value triangulation
- Current narrative phase
- Any red flags

Decide: worth deeper investigation?

### Full Thesis Validation (~5 min, ~$1.30)

```
/validate-thesis HPG
```

Runs all 6 perspectives (or 3 in Phase 1) + synthesizer. Output:
- Full thesis card (see spec 001)
- Archive in thesis-log

### Pre-Decision Challenge (optional, before acting)

```
/pre-decision HPG "I'm about to buy 10% position"
```

Runs Bear + Behavior + Manager only, looking for disqualifiers.

### Record Decision (after action)

```
/record-decision HPG buy 10% 28500 "based on thesis X"
```

Logs to BC-9 for bias tracking.

---

## Handling Failures

### Hallucination detected

1. Stop current work
2. Log in `agent-workspace/memory/drift-logs/`
3. Identify root cause:
   - Missing constraint in prompt?
   - Ungrounded reasoning chain?
   - Missing invariant check?
4. Fix + add drift signal if detectable
5. Add to eval set as negative example

### Thesis was wrong

Post-mortem template:
```markdown
## Thesis HPG-2026-01-15 — 3 month review
**Original recommendation**: THESIS_CANDIDATE
**Actual outcome**: -15% vs VN-Index +2%
**What was wrong**:
- Bear perspective identified governance issue that proved pivotal
- But synthesizer weighted it MODERATE when it should have been CRITICAL
**Lesson**:
- Governance red flags in specific pattern (related-party + capex cycle) deserve higher weight
**Action**:
- Added to agent-notes.md as new rule
- Proposed outer-loop mutation (Year 2): weight governance signal +20% when pattern matches
```

### KOL calibration surprises you

When a KOL you "knew" was good shows low credibility:
- Investigate: is data wrong, or was your intuition wrong?
- Often: intuition wrong. Memorable hits overshadow invisible misses.
- Trust the data, but review outcome evaluation logic if consistently surprising

---

## Anti-Patterns to Avoid

### "I'll just skip Day 1 and start coding"
Charter misalignment compounds. 3 hours saved Day 1 = 30 hours wasted Phase 2.

### "I don't need to run post-mortems"
No post-mortem = no calibration = no edge compounding. The whole point is post-mortem.

### "Outcome tracking can wait"
Every day it waits, the data gap grows. Track from Day 1.

### "I'll add tests later"
Financial code without tests = money loss waiting. Tests are part of done.

### "It's just for me, security doesn't matter"
Your portfolio data, API keys, KOL tracking data are sensitive. Treat like production.

### "Just vibe-code this small thing"
Vibe-code = speculative feature = dies. If not worth writing spec, not worth building.

### "Let me optimize everything before shipping Phase 1"
Shipped basic version beats unshipped perfect version. Dogfood drives truth.

### "The LLM said so, it must be right"
LLMs hallucinate. Verify every claim against source. That's why invariants exist.

---

## Tooling Discipline

- `claude` — primary interface. Single concurrent session usually.
- `docker-compose up -d` — local infra; leave running
- `python -m pytest` — run tests before commit
- `mypy --strict packages/` — type check before commit
- `ruff check .` — lint before commit
- Pre-commit hook runs all three

### When Infrastructure Breaks

1. `docker-compose logs` first — usually self-evident
2. `docker-compose restart` often fixes
3. `docker-compose down && docker-compose up -d` if restart insufficient
4. Keep DB volumes — don't `docker-compose down -v` unless you mean to wipe

---

## When to Escalate to Human (Yourself)

Agent will escalate (stop and ask you) when:
- Budget cap approaching ($5/thesis, $25/session, $10/day)
- Destructive operation proposed
- Constitution file needs modification
- Charter conflict detected
- Novel pump pattern (no historical analog)
- Calibration drift >20%
- 3+ retries on deterministic gate failures

You should escalate yourself to "planning mode" when:
- Haven't dogfed in >7 days (features built without use = dead features)
- 3+ consecutive sessions feel aimless
- Have accumulated >10 uncommitted experimental changes
- Are tempted to skip review steps
- Feel rushed (rush = bugs)

---

## Signals You're On Track

- You consult system before taking positions
- Bear case genuinely changes your mind ≥monthly
- KOL credibility data contradicts your intuition ≥monthly
- Thesis-log grows steadily (1+/week)
- Post-mortems produce real learnings (not "market was volatile")
- The tool feels like a peer advisor, not a toy

---

## Signals Something's Wrong

- You're not using the tool for real decisions
- Every session feels like infrastructure, no feature work
- Thesis outputs feel generic / same-ish across tickers
- You stopped running post-mortems because "too busy"
- KOL data has never surprised you (= probably wrong)
- Pump detection never triggers OR triggers on everything

When these appear: take a step back. Read charter. Re-align.

Last updated: 2026-04-23
