---
status: ACCEPTED (ratified S43c via D-020; frontmatter sync S43f)
proposed_at: 2026-04-29
proposed_by: Claude Opus 4.7 (S16 IMPL — Track 7 ratification)
source_evidence:
  - agent-notes.md § L-S14-4 (autonomous_mode flag + Mode-D clean-handoff coverage; cliff-vs-injector dispatch)
  - session-plans/pending/003-S15-track-7-constitution-amendments.md § 2 + § 4.2
  - decisions/004-up07-context-threshold-opus47.md (Opus 4.7 thresholds 180K/220K/250K)
target_constitution_path: agent-workspace/constitution/session-budgets.md
target_section: NEW § "Mode A/B/C/D — Cliff vs Injector Dispatch"
move_when: user explicit approve; insertion point = after "## Hard Rules" section, before "## When to Escalate"
---

# Session Budgets Amendment — Cliff vs Injector Dispatch

> **Status**: PROPOSAL pending user approval. Codifies the autonomous-loop handoff dispatch logic shipped in S14 (`autonomous-stop-watchdog.sh` + `continue-injector.ps1`) as a budget-discipline clause.

## Append to `session-budgets.md` (NEW section)

---

## Mode A/B/C/D — Cliff vs Injector Dispatch

Per Opus 4.7 thresholds (D-004): wind-down at 180K / cliff at 220K / hard cap at 250K. The autonomous loop's handoff mechanism depends on which threshold the session crossed.

### Mode A — Stop without budget alert

`autonomous-stop-watchdog.sh` writes a minimal continue prompt; user's terminal pulls via `continue-injector.ps1` to resume mid-session. Same context window continues.

### Mode B — Cliff reached (≥220K), session must reboot

`budget-watchdog.sh` triggers `session-self-reboot.sh`. Fresh context window starts; new session reads `checkpoints/latest.md` to resume.

**Reason for fresh-context**: past 220K, transformer attention degrades (per session-budgets.md § Quality Cliff). Continuing in the same context produces "lost in the middle" effect; agent forgets rules. Fresh context is cheaper than degraded output.

### Mode C — Premature wind-down before cliff

`budget-watchdog.sh` flags mode-C event in JSONL telemetry (`failure_mode: C` per D-003 § 5.5c.5 REV-4); handoff prep proceeds; user resumes via continue-injector.

### Mode D — Clean handoff (S14 addition, L-S14-4)

`autonomous-stop-watchdog.sh` recognizes intentional close — checkpoint mtime ≤ 60 seconds AND no A/B/C alert fired. Resume reads `checkpoints/latest.md` cleanly. JSONL `failure_mode: D` (NOT a failure; "D = clean handoff").

### Dispatch Rule

```
budget < 180K + checkpoint fresh                     → Mode D (clean)
budget < 180K + no checkpoint                        → Mode A (continue-injector mid-session)
180K ≤ budget < 220K                                  → Mode C (wind-down; handoff prep)
budget ≥ 220K                                        → Mode B (cliff; session-self-reboot fresh ctx)
```

The choice between continue-injector (same-context resume) vs session-self-reboot (fresh-context restart) is **deterministic per the budget threshold**, not per agent judgment.

## Verifier Budget by Scope (L-S21-1, S21 verifier evidence)

Sandwich-verifier dispatch budget depends on artifact-set scope:

| Scope | Token cap | Use case |
|---|---|---|
| Single-track (1-3 sessions, 1 decision) | 60-80K | Per-track close verification |
| Multi-track (5-10 sessions, 2-3 decisions) | 100-120K | Mid-phase checkpoint review |
| Whole-Phase (≥15 sessions, ≥5 decisions, full artifact set) | **150K** | Phase-boundary final verifier |

**Why 150K for whole-Phase**: S21 verifier covering V1-V10 dimensions across 19 sessions + 8 decisions + 7 proposals + 9 constitution files + 31 hooks + 25 skills + 15 commands + 9 agents + Python library consumed 126K tokens / 89 tool uses / 9.7 minutes. Initial 80K cap forced verdict + V1-V10 covered but at cost of incomplete tail; budget calibration to 150K avoids partial-completion noise.

**Discipline**:
- Pre-dispatch: estimate artifact LOC + count files; if ≥10K LOC + ≥30 files, target whole-Phase budget (150K).
- Mid-dispatch: if verifier returns "partial", accept if verdict + all 10 dimensions covered; do NOT re-dispatch for marginal completeness gain.
- Post-dispatch: log actual tokens + tool uses for future calibration.

**Anti-pattern**: re-dispatching a verifier that delivered verdict + all V1-V10 just because token count exceeded cap. Wasted tokens; output already sufficient.

## End of amendment
