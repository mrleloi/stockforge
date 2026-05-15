---
notification_id: N-2026-04-29-SUMMARY-S9-close-UP08-ratified
level: SUMMARY
session: S9 (PLAN — UP-08 Track 5.5d Ratification)
created_at: 2026-04-29
related_decisions:
  - D-005 (NEW)
  - D-003 (REV-3 amendment)
related_user_prompt: human-workspace/user_prompt/20260429_08.txt
---

# S9 Close — UP-08 Ratified via D-005 (Track 5.5d Self-Learning Pipeline Insertion)

**TL;DR**: UP-08 self-learning pipeline ratified as new sub-track 5.5d via D-005. 3 sub-sessions S10/S11/S12 will ship before S13 (5.5c.3+4+5) + S14 (Track 6 REWRITE). Total Phase 0 budget grew ~2.02M → ~2.44M (+22-23%, user-accepted via AskUserQuestion Round 2 Q5=A).

---

## Picks recorded (5 explicit; 0 defaults absorbed)

| Q | Pick | Choice |
|---|---|---|
| Q1 (slot) | A | Track 5.5d new (parallel to 5.5a/b/c) |
| Q2 (boundary) | A | Separate FS path `agent-workspace/learning-data/` + drift signal D9 |
| Q3 (background-tech) | A | NDJSON queue + cron-via-hook (extends existing pattern) |
| Q4 (opensource-scope) | C | Agent-pick-1 + dogfood (bounded ~120-150K) |
| Q5 (budget; Round 2) | A | Accept ~2.44M total Phase 0 |

All Recommended option. UP-06 NO Silent File-Defaults + UP-04 AskUserQuestion-PRIMARY doctrines respected.

---

## What ships next (S10/S11/S12 = Track 5.5d)

### S10 — 5.5d.1 Boundary + Collection (~120K)
- `agent-workspace/learning-data/` FS tree (write-only path)
- `.gitignore` extension
- `scripts/hooks/component-telemetry.sh` extension (emit learning events to NDJSON queue)
- `scripts/hooks/drift-signals-D1-D8.sh` → renamed `drift-signals-D1-D9.sh` (+D9 = runtime read-path leak detector)
- `.claude/settings.json` permissions update

### S11 — 5.5d.2 Sweeper + Index + First Analysis (~150K)
- `learning-queue-sweeper.sh` (rotation + retention)
- `learning-index-rebuild.sh` (SQLite FTS5 RAG index Phase 0)
- Background-dispatch trigger rule (event-count or N-session threshold)
- First L-1 classification of event corpus

### S12 — 5.5d.3 Karpathy Outer Loop + Agent-Pick-1 Dogfood (~150K)
- `research-scanner` agent dispatch
- Single-tool dogfood (DSPy / LangSmith / llm.c-style autoresearch / etc. — agent picks at S12)
- Karpathy framing artifact (next-experiment design)
- Promotion path closure (≥1 feedback cycle into agent-notes)

---

## Sequence shifts (+3 sessions)

Pre-UP-08 → Post-D-005:
- S10 = 5.5c.3+4+5 → **S13** (try-n-approaches + OTEL + JSONL extension)
- S11 = Track 6 REWRITE → **S14**
- S12 = Track 7 → **S15**
- S13-S16 = Track 8a/8b/9/Final → **S16-S19**

---

## Budget envelope

- D-003 REV-2: ~2.02M (1.5-2M cap accepted via D-003 Round 2 Q8=A)
- **D-005 REV-3: ~2.44M** (+~420K for 5.5d; +22-23% over original cap upper-end)
- Under L-8 25% trigger; explicitly surfaced via Round 2 Q5=A pick + delta_summary frontmatter in D-005

---

## Files written this session

| Path | Status | LOC |
|---|---|---|
| `agent-workspace/memory/observations/decompose-work-up08-S9.md` | NEW | 111 |
| `human-workspace/q-and-a/pending/2026-04-29-006-up08-self-learning-pipeline.md` | NEW (status: answered) | 124 |
| `agent-workspace/memory/decisions/005-up08-track-5.5d-self-learning-pipeline.md` | NEW | 467 |
| `agent-workspace/memory/decisions/003-up06-track-5.5-sync-layer-selfcap.md` | MODIFIED (+REV-3 cross-reference) | +12 |
| `agent-workspace/memory/sync-state.md` | MODIFIED (sync-038 transition + counts) | +5 |
| `agent-workspace/memory/up-intake-log.md` | MODIFIED (UP-08 closed-by-D-005) | +1 |
| `agent-workspace/memory/current-execution.md` | MODIFIED (Phase + Status + Track + Budget + Work Items) | rewritten sections |
| `agent-workspace/session-plans/pending/002-track-5.5-sync-layer-selfcap.md` | MODIFIED (Session table + checklist + 5.5d section + sequence) | +85 |
| `agent-workspace/memory/sessions/2026-04-29-session-9.md` | NEW | ~210 |
| `agent-workspace/memory/checkpoints/latest.md` | OVERWRITTEN (S8 close → S9 close); S8 preserved as `2026-04-29-S8-close.md` | ~165 |
| `human-workspace/notifications/N-2026-04-29-SUMMARY-S9-close-UP08-ratified.md` | NEW (this file) | this |

---

## Pre-flight reminder for S10

S10 is FOCUSED_IMPL (~120K). Do NOT re-grill UP-08 SCOPE (already ratified D-005). Read D-005 § 5.5d.1 + decompose-work observation for D-1/D-2/D-5 portion specs. Smoke-test D9 drift signal BEFORE wiring. Grep all callers of `drift-signals-D1-D8.sh` BEFORE rename (R-S9-1 mitigation).

If S10 watchdog warns approaching 180K wind-down → descope D-5 (D9 rename + new signal) to S10.5 follow-up; ship D-1 + D-2 only. D9 is the priority deliverable.

---

## User actions (none required for S9 close)

- All 5 SCOPE-tier picks recorded via AskUserQuestion. No file edits needed.
- Bundle 006 status: answered (in `human-workspace/q-and-a/pending/`). User can move to `answered/` at convenience; agent does not move per workspace contract.
- If user disagrees with any pick or wants to re-route → drop new prompt in `human-workspace/user_prompt/20260429_09_<slug>.txt`; agent will surface intake at next SessionStart.

---

**S9 close clean. Autonomous flow continues at S10.**
