---
id: QA-2026-04-29-001
topic: "Phase 0 Harness Bootstrap — design Q&A clusters A through F"
opened_at: 2026-04-29T15:30:00+07:00
answered_at: 2026-04-29T16:45:00+07:00
priority: high
related_decisions:
  - D-001 (orch vs CC native — pause orch confirmed)
  - D-002 (Phase 0 Harness Bootstrap design — 10 tracks)
status: answered
mode: bundled (per Grill Maximization doctrine)
question_count: 21
---

# Round 1 + Round 2 Q&A — Phase 0 Design

## Round 1 — initial 7 questions
After analyzing user_prompt/20260429_01_init.txt + reading orch v2.2.0, agent proposed pause-orch + port roadmap with 7 design questions:

| Q | Topic | User answer |
|---|---|---|
| Q1 | Notification channel for Q&A escalation | Default D (file-based primary + claude.ai mobile + Telegram defer) — implicit confirm via "ok rồi. continue" |
| Q2 | Provenance schema (12-field) | Default confirm |
| Q3 | Intent classifier mode | **Hybrid**: main session lite-detect (e.g., "continue" trivial) + dispatch to `intent-classifier` subagent for complex/high-impact prompts |
| Q4 | Pattern mining timing | **Làm ngay**, expanded sources to 3: orch + ms-mdp-admin/phase2_workflow + orch reference-repos |
| Q5 | Charter re-verify | Pivot to: **Grill Maximization doctrine** + **Confidence Score** (live "second brain", measurable sync) + **Self-Awareness Agent** (track strengths/weaknesses across model × effort × thinking) |
| Q6 | Workspace dualism structure | Default confirm |
| Q7 | Execution mode | Default B (sequential per cluster + verifier subagent + user review final each cluster) |

## Round 2 — 21 questions (post UP02+UP03)

After user_prompt 02 + 03 introduced 3 major new systems (Confidence Score, Self-Awareness Agent, Grill Maximization doctrine), agent grilled 21 questions in 6 clusters:

### Cluster A — Confidence Score System (System I) — 6 questions, all defaults

| Q | Topic | Default | Confirmed |
|---|---|---|---|
| A1 | 5 categories | LANGUAGE, DOMAIN_UBIQUITOUS, DESIGN_THINKING, SCOPE, DECISION_ROUTING | ✓ |
| A2 | Score scale | D = Hybrid tier display + 0-100 internal | ✓ (D) |
| A3 | "Live" implementation | SQLite storage + tag+recency retrieval + SessionStart auto-load top-10 + on-demand /sync-pull | ✓ |
| A4 | Decision threshold | D = Hybrid B+C: per-decision-class (CHARTER 0.99 / SCOPE 0.90 / ARCH 0.80 / IMPL 0.50) | ✓ |
| A5 | Score update events | Asymmetric weights (correction -2; revocation -3; charter-match +0.2; weights tunable) | ✓ |
| A6 | Reversal protocol | 6-step (log revocation → drop score → revert if reversible → post-mortem → category to "must-grill") | ✓ |

### Cluster B — Self-Awareness Agent (System J) — 4 questions

| Q | Topic | Default | Confirmed |
|---|---|---|---|
| B1 | Tracking dimensions | model × tier × effort × thinking × task_class (sparse cells) | ✓ |
| B2 | Source of truth | E = Combine self_assessment 0.1 + user_feedback 0.5 + telemetry 0.4 | ✓ (E) |
| B3 | Output format | C = SQLite source + markdown profile cards rendered | ✓ (C) |
| B4 | Update cadence | Per-session aggregate (Stop hook) + realtime for high-impact failures | ✓ (per-session) |

### Cluster C — Grill Maximization (System D update) — 3 questions

| Q | Topic | Default | Confirmed |
|---|---|---|---|
| C1 | Bundle size cap | B = target 15-20, max 25, split if more | ✓ (B) |
| C2 | Channel | File-based `human-workspace/q-and-a/{pending,answered,stale}/<TS>-<topic>.md` with YAML frontmatter | ✓ |
| C3 | Timeout / escalation | B 24h = continue non-blocking work; pause blocked work; urgent flag cuts to 4h | ✓ (B 24h) |

### Cluster D — Intent Classifier hybrid (System C update) — 2 questions

| Q | Topic | Default | Confirmed |
|---|---|---|---|
| D1 | Lite-detect heuristic | D = trivial whitelist (~15 patterns) + mini-LLM classification fallback | ✓ (D) |
| D2 | Subagent output schema | YAML with primary_intent, affects_charter, affects_scope, urgency, complexity, recommended_action, human_intent_summary, suggested_grill_questions, provenance | ✓ |

### Cluster E — Round 1 confirmations — 4 questions

| Q | Topic | Default | Confirmed |
|---|---|---|---|
| E1 | Q1 — notification channel | File-based primary + claude.ai mobile realtime; Telegram defer | ✓ |
| E2 | Q2 — provenance schema | 12-field decision-id format | ✓ |
| E3 | Q6 — workspace dualism | Structure proposed (human-workspace/{user_prompt,decisions,q-and-a,notifications}; agent-workspace/...) | ✓ |
| E4 | Q7 — execution mode | Mode B (sequential per cluster + verifier + user reviews final each cluster) | ✓ |

### Cluster F — Pattern Mining scope (System H / Track 0) — 2 questions

| Q | Topic | Default | Confirmed |
|---|---|---|---|
| F1 | Mining depth | DEEP for orch + reference-repos targeted (claudegram, claudekit-skills, claude-code-learn, claude-sessions); SELECTIVE DEEP for ms-mdp-admin (00-index + 10 chosen docs deep, skim rest) | ✓ |
| F2 | Output structure | 3 mining files + SYNTHESIS.md + borrow-list.md, all in `agent-workspace/memory/patterns-discovered/` (allowed write path); 3 parallel research-scanner-style subagents | ✓ |

## User confirmation message (verbatim)

> "ok rồi. continue"

(2026-04-29; equivalent to Vietnamese "tự hoàn thiện" autonomous-mode trigger phrase per orch's `autonomous-protocol.md` § "When This Applies"; however, autonomous_mode in stockforge does NOT activate until Track 7 of Phase 0 completes — current mode = SUPERVISED.)

## Provenance trail

- 2026-04-29 turn 1: Agent reads UP01 (orch evaluation) → produces D-001 (PROPOSED, pause orch + port roadmap) + 7 Q&A
- 2026-04-29 turn 2: User UP02 (workspace dualism, provenance, intent, Q&A escalation, sync ladder, Obsidian, mining) → Agent grills 7 questions
- 2026-04-29 turn 3: User UP03 (hybrid intent, mining now 3 sources, grill max, Confidence Score, Self-Awareness) → Agent grills 21 questions in 6 clusters
- 2026-04-29 turn 4 (this artifact): User "ok rồi. continue" → Agent updates D-001 ACCEPTED, writes D-002 (Phase 0 design), this Q&A audit, dispatches Track 0
