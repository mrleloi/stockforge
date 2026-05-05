# Phase 0 — Harness Bootstrap (11 Tracks + Track 5.5, REV-3)

> **Filename note**: kept as `001-port-from-orch.md` for stability; content updated 2026-04-29 REV-3 to reflect Track 5.5 insertion per Decision 003 + D-002 REV-3 amendment. Old 8-track "port roadmap" superseded → 11-track REV-2 → 11+5.5-track REV-3.

**Status**: ACTIVE (REV-3)
**Phase**: 0 (Harness Bootstrap)
**Mode**: AUTONOMOUS (full; autonomous_mode=true always — per user correction S15 close 2026-04-29; "SUPERVISED until Track 7" was a fabricated default never user-authorized)
**Source decisions**: `agent-workspace/memory/decisions/002-phase-0-harness-bootstrap-design.md` (REV-3) + `003-up06-track-5.5-sync-layer-selfcap.md` (NEW)
**Track 5.5 detail**: `agent-workspace/session-plans/pending/002-track-5.5-sync-layer-selfcap.md`
**Q&A audit**: `human-workspace/q-and-a/answered/2026-04-29-001-phase0-clusters.md` + `human-workspace/q-and-a/pending/2026-04-29-004-up06-track-5.5-amendment.md` (born-answered)
**Synthesis**: `agent-workspace/memory/patterns-discovered/SYNTHESIS.md`
**Borrow list**: `agent-workspace/memory/patterns-discovered/borrow-list.md`

---

## Phase Goals (Success Criteria)

Phase 0 is COMPLETE when ALL of these hold (final verifier S9 attests):

- [ ] **Track 0** ✅ DONE: 5 files in `agent-workspace/memory/patterns-discovered/` (3 mining + SYNTHESIS + borrow-list)
- [ ] **Track 1**: workspace dualism contract files + permissions enforce + smoke test pass
- [ ] **Track 2**: decision template + provenance protocol draft (12-field schema + defer-cycles counter); existing decisions reformatted
- [ ] **Track 3**: intent-classifier subagent functional; trivial-whitelist + mini-LLM-fallback heuristic; user prompt routing works
- [ ] **Track 4**: Q&A escalation channel operational; Grill Maximization doctrine documented; SessionStart hooks scan answered/+stale/
- [ ] **Track 5**: 10+ hook scripts + reboot scripts + drift-signal greps wired; Same-Commit Rule pre-commit; charter-coherence-spot-check; manually-induced 230K transcript triggers reboot
- [ ] **Track 5.5a (NEW)**: `.claude/manifest.yaml` validates; harness/stockforge separation; `/attach` smoke-test passes
- [ ] **Track 5.5b (NEW)**: 4-mechanism Sync ensemble (intent-vs-impl-diff agent + sync-state.md + periodic grilling hook + sync-bundle-template)
- [ ] **Track 5.5c (NEW)**: Self-Cap Karpathy full (decompose-work skill + capability-map.md + try-n-approaches skill + OTEL stack + JSONL schema extension + promote-rule)
- [ ] **Track 6 (REWRITE)**: 8 discipline skills + 3 subagents (spec-compliance, code-quality, +audit sandwich-verifier) + 12 existing skills refactored to progressive-disclosure + Mandates A-E in sandwich-architect; layer-aware per 5.5a manifest
- [ ] **Track 7**: 10+ constitution files (autonomous-protocol / model-routing / mode-routing / user-intent-coherence / self-application-bootstrap / identity-scope / config-style-guide / mistake-log / decision-discipline / thesis-anti-patterns / spec-authority); CLAUDE.md updated; AUTONOMOUS_MODE activates
- [ ] **Track 8a**: Confidence Score SQLite + index + weights.yaml; smoke test scoring 5 Q&As; empirical-hit-rate grounding
- [ ] **Track 8b**: L0/L1 extraction (Python port) + VN FAILURE_PATTERNS extension + cleanText regex + TranscriptCache
- [ ] **Track 9**: OTEL single-container stack live + Self-Awareness DB + profile cards + 3 telemetry skills + Stop-hook aggregator; 3 sample sessions captured
- [ ] **Final verify (S9)**: `sandwich-verifier` opus reviews entire Phase 0 → APPROVED or APPROVED_WITH_CONCERNS

---

## Session Sequencing (REV-3 — 14 sessions)

> Reflects D-002 REV-3 § D (Revised Session Sequencing) post-Track-5.5 insertion.

| # | Session | Tracks | Type | Budget |
|---|---|---|---|---|
| **S1** ✅ DONE | Bootstrap kickoff | Track 0 + design REV-2 | FOCUSED_IMPL | ~210K main + 180K bg |
| **S2** ✅ DONE | Workspace + Provenance + Intent + Q&A | Tracks 1, 2, 3, 4 | MULTI_TASK_IMPL | ~150K |
| **S3** ✅ DONE | Loop-resilience hooks | Track 5 | FOCUSED_IMPL | ~120K |
| **S4** NEXT | **Layer Foundation** | **Track 5.5a** (manifest + restructure + /attach skill) | FOCUSED_IMPL | ~150K |
| S5 | Sync Part 1 | Track 5.5b.1+5.5b.2 (intent-vs-impl-diff agent + sync-state.md) | FOCUSED_IMPL | ~150K |
| S6 | Sync Part 2 | Track 5.5b.3+5.5b.4 (periodic grilling hook + sync-bundle-template) | FOCUSED_IMPL | ~150K |
| S7 | Self-Cap Part 1 | Track 5.5c.1+5.5c.2+5.5c.6 (decompose-work + capability-map + promote-rule) | FOCUSED_IMPL | ~200K |
| S8 | Self-Cap Part 2 | Track 5.5c.3+5.5c.4+5.5c.5 (try-n-approaches + OTEL stack + JSONL extension) | MULTI_TASK_IMPL | ~200K |
| S9 | Skills + Subagents port REWRITE | Track 6 (layer-aware) | MULTI_TASK_IMPL | ~150K |
| S10 | Constitution + Mid-verifier | Track 7 + sandwich-verifier on 1-6 + 5.5 | VERIFY+IMPL | ~150K |
| S11 | Confidence Score | Track 8a | FOCUSED_IMPL | ~120K |
| S12 | Memory L0/L1 extraction | Track 8b | FOCUSED_IMPL | ~120K |
| S13 | Self-Awareness | Track 9 (reduced — 5.5c absorbs OTEL setup) | FOCUSED_IMPL | ~80K |
| S14 | Final Phase 0 verifier | Whole-phase opus verifier | VERIFY | ~80K |

Total: ~2.02M tokens (was REV-2 ~1.3M; user accepted ~1.5-2M band per UP-06 Q8=A).

**Track 0 status**: ✅ COMPLETE per Q-S2 = close. Hand-off artifacts:
- `agent-workspace/memory/patterns-discovered/SYNTHESIS.md`
- `agent-workspace/memory/patterns-discovered/borrow-list.md`
- 3 source mining reports

---

## Track-by-Track Detail

For full track specifications including BORROW/ADAPT/LEARN port lists per track, see:
- `agent-workspace/memory/decisions/002-phase-0-harness-bootstrap-design.md` § Track Specifications
- `agent-workspace/memory/decisions/002-phase-0-harness-bootstrap-design.md` § Amendments REV-2 (track-by-track delta)
- `agent-workspace/memory/decisions/002-phase-0-harness-bootstrap-design.md` § Amendments REV-3 (Track 5.5 insertion summary)
- `agent-workspace/memory/decisions/003-up06-track-5.5-sync-layer-selfcap.md` (Track 5.5 strategic rationale)
- `agent-workspace/session-plans/pending/002-track-5.5-sync-layer-selfcap.md` (Track 5.5 executable detail)
- `agent-workspace/memory/patterns-discovered/borrow-list.md` (port queue sorted by priority)

This file is the **whole-phase session-plan view**; `002-track-5.5-...md` is the **Track 5.5 executable view**; the decision files are the **strategic-rationale view**; the borrow-list is the **port queue**.

---

## Open Items / Deferred to Phase 1+

- **F (Sync ladder full formalization)**: extend `/grill-me` v2 to track sync state across language→ubiquitous→design→goals
- **G (Obsidian wiki visualization full)**: graph view, dashboards, decision tree rendering
- **H (Deep pattern mining / self-evolution loop)**: telemetry-analyst RULE-1..N
- **Telegram/Slack bot**: defer Phase 4+ when signal alerts ready
- **Worker mailbox / multi-project queue**: explicitly out of scope per Identity NOT-list
- **Multi-tenancy**: Phase 6+ only with re-charter

---

## Critical Risks (per REV-2 § C)

| ID | Risk | Mitigation Track |
|---|---|---|
| R1 | Self-track inflation → premature wind-down | Track 5 |
| R5 | Skill validator hard-fail breaks day 1 | Track 6 (--soft-warn 30d) |
| R7 | Multi-cycle defer can-kicking | Track 2 (cycle_count + alert >3) |
| R8 | Continuous LLM-Guardian cost | Track 9 (deterministic-hook Guardian) |
| R9 | L0/L1 polluted by harness chatter | Track 8b (cleanText regex first) |
| R10 | Hook result schema breakage | Track 5 (schema doc) |
| R12 | Spec-as-Source butterfly effect | Tracks 6+7 (sandwich + same-commit) |
