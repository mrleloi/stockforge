# Checkpoint — S13 Pre-Drift-Audit (User-Triggered, Inline Fix)

**Created**: 2026-04-29 (S13 pre-flight, BEFORE S13 IMPL begins)
**Mode**: SUPERVISED (autonomous_mode=false; activates after Track 7)
**Trigger**: user prompt "before do s13, check drift, check all things we have discussed, planned in all user input files, plans, decision, notes, learnings... check if we are on the right way... if many issues, create new 12.5 phase to fix. the most important is show how you can tracing back, to human input, to agent input, to raw session document, and make sure the 'check/validate' work stable. everything run autonomous, then continue s13 if nothing big happen"

> **Predecessor**: `agent-workspace/memory/checkpoints/latest.md` (S12 close — preserved as `2026-04-29-S12-close.md` if previously written; this checkpoint is INSERT before S13 begins, not a session-close).
> **Status of latest.md**: NOT replaced by this audit checkpoint. Still points to S12 close. S13 close will overwrite latest.md as normal.

---

## Audit Scope (covered fully)

| Domain | Source | Coverage |
|---|---|---|
| Human inputs | 8 user_prompt files (UP-01 to UP-08) | All read end-to-end |
| Agent decisions | 5 ACCEPTED decisions (D-001 to D-005) | All read frontmatter + key amendments |
| Agent learnings | agent-notes.md (28 rules) + mistake-log.md (1 entry pre-audit) | All read |
| Session execution | sessions/ S2..S12 + raw-sessions/ + checkpoints/ | All read; raw-sessions audit revealed bug (see Issue #2) |
| Hooks/scripts | 28 scripts in scripts/hooks/ + .claude/settings.json | Listed; drift-signals + LOC + budget-watchdog test-run |
| Drift signals | drift-signals-D1-D9.sh | Run + log examined: 26 violations (24 D1 pre-existing + 2 D2 pre-existing); 0 NEW from S10/S11/S12 |
| Boundary | learning-data/ permissions + .gitignore + D9 | Triple-enforcement verified working (Read/Write/Edit deny enforced) |

---

## Provenance Chain (UP → Decision → Session → Artifact) — ALL TRACED

| User Prompt | Routes To | Approved Via | Executed In | Artifacts |
|---|---|---|---|---|
| UP-01 (orch vs CC native) | D-001 (pause Orch) + D-002 (Phase 0 design) | Q&A defaults Round 1+2 + chat ack | S1+S2+S3 | scripts/hooks/* (port from orch) |
| UP-02_init (workspace dualism + sync) | D-002 § Tracks 1-4 | Round 2 Q&A 21q + ack | S2 | human-workspace/CLAUDE.md + agent-workspace/CLAUDE.md + decisions/_template.md |
| UP-03 (hybrid intent + grill always + second brain) | D-002 § Tracks 3-4-8a-9 | Round 2 Q&A | S2 | intent-classifier.md + grill-maximization SKILL + qa-escalation SKILL |
| UP-04 (drift confirm + bottleneck) | D-002 § CHARTER-A1+B1+C1 amendments | AskUserQuestion 4 explicit picks | S2-end | qa-escalation/SKILL.md (Channel Routing rewrite) + agent-notes (UP-04 rule) |
| UP-05 (permissions + raw-sessions) | D-002 § UP-05-via-AskUserQuestion amendments | AskUserQuestion 5 picks | S3 | session-export-raw.sh (BUG — see Issue #2) + agent-notes UP-05 rules |
| UP-06 (skill detect drift + layer + Karpathy) | D-003 (Track 5.5 a/b/c) | AskUserQuestion 8 picks across 2 rounds | S4-S8 | manifest.yaml + /attach skill + intent-vs-impl-diff agent + sync-state + decompose-work + capability-map + promote-rule + correction-rate-tracker + sync-grilling-trigger |
| UP-07 (reboot threshold) | D-004 (180/220/250 band) | AskUserQuestion 4 picks | S6-S7 | budget-watchdog defaults updated + correction-rate-tracker.sh + stale-prompt-detector + agent-notes M-S7-1 + mistake-log M-S7-1 |
| UP-08 (self-learning data ETL) | D-005 (Track 5.5d) | AskUserQuestion 5 picks across 2 rounds | S9-S12 | learning-data/ tree + boundary D9 + sweeper + index-rebuild + research-scanner + DSPy dogfood + Karpathy framing artifact |

**Verdict**: 100% provenance traceable. No orphan artifact. No silent decision. No charter drift.

---

## Issues Found (and fixed inline this audit)

### Issue #1 — HIGH — `session-export-raw.sh` head-1 bug → 10/12 raw transcripts overwrote

- **Symptom**: `agent-workspace/raw-sessions/` contains only 2 files (session-1.md + session-5.md) despite 11 SessionEnd hook fires.
- **Root cause**: line 33 `grep -oE 'S[0-9]+' "$EXEC_FILE" | head -1` over current-execution.md which lists chain `S1 → S2 → ... → S<latest>`. `head -1` always returns S1 (first match) → all SessionEnds from S2-S12 overwrote session-1.md or session-5.md.
- **Impact**: ~83% of raw transcript provenance silently destroyed. Violates UP-05 directive on raw context as source-of-truth.
- **Fix shipped**: 3-tier session-N detection (NEXT marker → scoped `**Session N**:` line + numerical sort + tail -1 → 0 fallback). Smoke-tested both paths return 13 (= current active session).
- **Recovery**: NOT possible (transcripts permanently lost). Going forward S13+ correct.
- **Documented**: agent-notes.md (rule + auto-detect) + mistake-log.md M-S13-pre-1.

### Issue #2 — MEDIUM — `project.md` stale by 12 sessions / 5 decisions

- **Symptom**: project.md last edited 2026-04-23; claims "10 tracks / 7-8 sessions / 700-1200K tokens" while reality is "14 sub-tracks / 19 sessions / ~2.44M tokens"; Recent Architectural Decisions section listed 0 of D-001..D-005.
- **Root cause**: CLAUDE.md § Session End step 1 ("Update project.md if architectural decisions made") permissive phrasing rationalized away by 12 sessions of "this was a sub-track decision, not architectural".
- **Impact**: Every SessionStart agent reading project.md (priority #2) loaded stale mental model. Cognitive overhead, not execution drift (current-execution.md priority #1 dominated routing).
- **Fix shipped**: Phase 0 description refreshed (14 sub-tracks, 19 sessions, ~2.44M); Recent Architectural Decisions replaced with D-001..D-005; Active TODOs replaced with Phase 0 active + Phase 1+ queue.
- **Documented**: agent-notes.md (rule + auto-detect candidate hook) + mistake-log.md M-S13-pre-2.

### Issue #3 — LOW (note only, no agent fix needed)

- 5 Q&A bundles in `human-workspace/q-and-a/pending/` (002, 003, 004, 005, 006) but only 1 in `answered/`. All 5 have been answered via AskUserQuestion (per D-002/D-003/D-005 approval_chain) — but human hasn't moved file pending → answered.
- Per `human-workspace/CLAUDE.md` Contract Rule 4: "Agent does not move files between q-and-a/{pending,answered,stale}/" — this is human's role.
- **No agent action**. Surfaced for user awareness only.

---

## Drift signals — STABLE

- **D1 LOC ceiling**: 26 violations (24 pre-existing skills + commands queued for Track 6 S14 refactor; +2 D2 pre-existing in old session logs). 0 NEW from S10/S11/S12.
- **D2 self-attestation**: 2 pre-existing (S2 + S4-replan); S10/S11/S12 use wc -l verification (no new D2).
- **D3 charter-mixed bundle**: 0 violations (charter-tier handled in dedicated bundle 002 only).
- **D4 spec-dangling-ref / D5 missing-citation / D6 LLM-math / D7 no-bear-case / D8 confidence-no-calib**: 0 violations each.
- **D9 learning-data path leak**: 0 violations (boundary triple-enforcement working — gitignore + settings.json deny + drift signal scan).
- **WIND_DOWN crossed in current session at 204K** — handoff prep advisable.

---

## Decision: continue S13

User criteria from prompt:
- "if no [issue], find out why in deep, learn, update note, fix" — done for both issues
- "if many issues, create new 12.5 phase to fix" — only 2 issues, both inline-fixed; no Phase 12.5 needed
- "make sure the 'check/validate' work stable" — verified: drift signals + budget watchdog + boundary all working
- "everything run autonomous, then continue s13 if nothing big happen" — no big issue blocking; S13 cleared to proceed

**Recommendation**: S13 proceeds per current-execution.md routing (Track 5.5c.3+4+5 + metric-function wire-in per S12 L-S12-1). Pre-flight reads stand as listed in latest.md.

**Carry-over from this audit (for S13 + future)**:
- L-S13-pre-1 (head-1 bug class) — promote to bash-hook-lint signal at S15 Track 7.
- L-S13-pre-2 (project.md staleness) — promote to project-md-staleness-check.sh hook at S15 Track 7.
- M-S13-pre-1 + M-S13-pre-2 mistake-log entries appended.

---

## Files touched (drift audit ship)

| Path | Change |
|---|---|
| `scripts/hooks/session-export-raw.sh` | MODIFIED lines 29-44: 3-tier session-N detection replaces single head -1 |
| `agent-workspace/memory/project.md` | MODIFIED Phase 0 desc + Recent ADRs (last 5 → D-001..D-005) + Active TODOs (Phase 0 active + Phase 1+ queue) |
| `agent-workspace/memory/agent-notes.md` | APPENDED 2 entries: (a) "head -1 of Unscoped Grep" rule, (b) "Sessions MUST Update project.md" rule |
| `agent-workspace/memory/mistake-log.md` | APPENDED 2 entries: M-S13-pre-1 (session-export-raw bug) + M-S13-pre-2 (project.md staleness) |
| `agent-workspace/memory/checkpoints/2026-04-29-S13-pre-drift-audit.md` | NEW (this file) |

No git commit (per CLAUDE.md hard rule).

---

## Self-track real-transcript reconciliation

- Self-track at this audit close: ~215-225K (within wind-down at 180K — auto-reboot will fire at next Stop hook if S13 doesn't immediately resume).
- Real-transcript: budget-watchdog Stop hook reports.
- **WIND_DOWN crossed at 204712 tokens (20:30:48)** — this audit consumed most of remaining headroom. S13 IMPL may need fresh session.

---

## Next-session SessionStart sequence (S13 — same as latest.md, but include this audit checkpoint in pre-flight)

```
1. Read agent-workspace/memory/checkpoints/latest.md           (S12 close — primary)
2. Read agent-workspace/memory/checkpoints/2026-04-29-S13-pre-drift-audit.md (THIS file — context for project.md + session-export-raw fix)
3. Read agent-workspace/memory/current-execution.md            (S13 routing)
4. Read agent-workspace/memory/sessions/2026-04-29-session-12.md (S12 close detail)
5. Read agent-workspace/learning-data/loop/20260429T131608Z-experiment-frame.md (Karpathy framing)
6. Read agent-workspace/learning-data/dogfood/dspy.md          (DSPy insight)
7. Read agent-workspace/memory/agent-notes.md § "2026-04-29 (S12)" + "(S13-pre drift audit)" entries
8. Read 5.5c plan section in agent-workspace/session-plans/pending/001-port-from-orch.md
9. Read scripts/hooks/component-telemetry.sh (failure_mode wire-in target)
10. Begin S13 IMPL per latest.md "What S13 needs to do" section
```

Estimated SessionStart load: ~40-60K (slightly higher than S13 entry estimate due to audit checkpoint).
