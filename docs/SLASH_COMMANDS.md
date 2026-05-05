# Slash Commands — StockForge

> Commands available in Claude Code sessions.
> Custom commands live in `.claude/commands/`.

---

## Session Lifecycle

### `/session-start`
Load context at start of session.
- Reads `current-execution.md`, `project.md`, last 3 session logs
- Identifies active track + phase
- Proposes next action based on state

### `/session-end`
Close out session cleanly.
- Prompts for session summary
- Writes to `agent-workspace/memory/sessions/`
- Updates `current-execution.md`
- Reminds to commit/stage

### `/handoff-read`
Read handoff notes from last session (without full session-start).

### `/handoff-write`
Write handoff notes mid-session if stopping temporarily.

---

## Planning

### `/master-plan <goal>`
Architect session → breaks goal into session plans.
Example: `/master-plan "implement Phase 1 thin slice"`

### `/plan-feature <spec_id>`
Plan sessions for a specific spec.
Example: `/plan-feature SPEC-2026-04-23-002`

### `/estimate <task>`
Quick token estimate for a task before committing to session.

---

## Thesis Workflow (core inner loop)

### `/validate-thesis <ticker> [as_of]`
Full 6-perspective thesis validation (3 in Phase 1).
Example: `/validate-thesis HPG`
Cost: ~$1.30, 5 min.

### `/quick-check <ticker>`
Fast Quant + Behavior only triage.
Cost: ~$0.50, 30 sec.

### `/pre-decision <ticker> <action>`
Bear + Behavior + Manager, looking for disqualifiers.
Example: `/pre-decision HPG "buying 10% position"`

### `/thesis-history <ticker>`
Show all past thesis for this ticker + outcomes if reviewed.

### `/record-decision <ticker> <action> <size> <price> <reason>`
Log decision to BC-9 portfolio for bias tracking.

---

## KOL & Crowd (Phase 2+)

### `/kol-digest`
Today's KOL recommendation digest (once Phase 2 shipped).

### `/kol-profile <kol_id>`
Browse specific KOL: credibility, track record, recent calls.

### `/ticker-sentiment <ticker>`
Current crowd sentiment + narrative phase + pump detection status.

### `/narrative-status [narrative_id]`
All active narratives + phases; or specific narrative lifecycle.

### `/confluence-today`
All confluence detections from last 24h.

### `/pump-warnings-active`
Active pump warnings across all tracked tickers.

---

## Data Ingestion

### `/ingest-channel <channel_id>`
Run ingestion manually on a channel (normally scheduled).

### `/ingest-news [source]`
Manual news ingestion trigger.

### `/refresh-universe`
Update stock universe from exchange data.

### `/backfill <ticker> <from_date> <to_date>`
Historical backfill for a ticker.

---

## Post-Mortem & Calibration

### `/post-mortem-batch`
Run all due outcome reviews (thesis, KOL recs, pumps).
Typical: first Sunday of month.

### `/post-mortem <thesis_id>`
Post-mortem specific thesis (if you want to review manually).

### `/calibration-report`
Current calibration state: KOL credibilities, pump detection metrics, thesis hit rate.

### `/personal-bias-report`
Your personal biases based on decision history.

---

## Drift & Quality

### `/drill-me <concept>`
Seed ubiquitous language for a domain concept.
Example: `/drill-me "Vietnam banking sector analysis"`

### `/drift-check [severity]`
Run drift signals. Optional severity: HIGH | MEDIUM | LOW.

### `/invariants-check`
Check all I-* and I-S* invariants for violations.

### `/vbw-check`
Explicitly run VBW protocol checkpoints on current work.

---

## Dev Workflow

### `/implement <task_id>`
Focused implementation of single task from session plan.

### `/verify <what>`
Separate-context verifier review.
Example: `/verify "last 3 commits"`

### `/test <scope>`
Run tests for scope.
Example: `/test "BC-6"` or `/test "all"`

### `/refactor <target>`
Controlled refactoring with invariant checks.

---

## Spec & Documentation

### `/spec-new <tier> <name>`
Create new spec from template.
Tier: 1 (strategic) | 2 (feature) | 3 (task)

### `/spec-review <spec_id>`
Critique a spec before/after implementation.

### `/glossary-update <term>`
Add or refine glossary term.

### `/wiki-create <entity_type> <name>`
Create wiki page in obsidian-vault/wiki/.
Entity types: company, industry, person, kol, pattern, narrative, thesis, concept, synthesis.

---

## Karpathy Outer Loop (Year 2+)

### `/outer-loop-status`
What's the outer loop currently considering? Recent proposals?

### `/outer-loop-review <report_id>`
Review specific weekly optimization report.

### `/outer-loop-approve <mutation_id> <rationale>`
Approve a proposed mutation for deployment.

### `/outer-loop-reject <mutation_id> <rationale>`
Reject a proposed mutation.

### `/outer-loop-rollback <change_id>`
Manually rollback a deployed change.

### `/outer-loop-propose <experiment>`
User-proposed experiment for next outer-loop cycle.

---

## Portfolio & Alerts (Phase 4+)

### `/watchlist-add <ticker>`
Add ticker to watchlist.

### `/watchlist-show`
Current watchlist + signals.

### `/position-open <ticker> <size> <price>`
Log position entry.

### `/position-close <ticker> <price>`
Log position exit.

### `/alert-setup <ticker> <condition>`
Set custom alert.
Example: `/alert-setup HPG "price < 22000 OR pump_warning"`

---

## Emergency

### `/stop`
Halt agent's current work. Useful if drift detected mid-session.

### `/rollback-session`
Undo session's writes (if agent went wrong direction).

### `/escalate <reason>`
Explicit escalation point. Stops automation, alerts human.

---

## Command Discovery

### `/commands`
List all available commands.

### `/help <command>`
Detail on specific command.

---

## Notes

- Commands are in `.claude/commands/` — view source to understand exactly what each does
- Custom commands can be added by you (stock-specific workflow discoveries)
- When in doubt: `/session-start` always works
