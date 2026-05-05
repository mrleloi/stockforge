---
id: D-002-phase-0-harness-bootstrap-design
title: "Phase 0 Harness Bootstrap Design (11 tracks + Track 5.5, REV-3)"
date: 2026-04-29
status: ACCEPTED-REV-3
level: SCOPE
author:
  - "Claude Opus 4.7"
  - "user"

source_evidence:
  - path: human-workspace/user_prompt/20260429_01_init.txt
    section: "initial scope — orch evaluation"
  - path: human-workspace/user_prompt/20260429_02_init.txt
    section: "§1.1-1.4 — workspace dualism / provenance / intent / Q&A / sync ladder / Obsidian / pattern mining"
  - path: human-workspace/user_prompt/20260429_03.txt
    section: "Q3-Q5 — hybrid intent classifier / pattern mining 3 sources / grill maximization / Confidence Score / Self-Awareness"
  - path: agent-workspace/memory/patterns-discovered/SYNTHESIS.md
    section: "18+ amendments + 12 risks + 23 anti-patterns + 5 user-decision items"
  - path: agent-workspace/memory/patterns-discovered/borrow-list.md
    section: "Tier 1 + Tier 2 actionable port queue"
  - path: human-workspace/q-and-a/answered/2026-04-29-001-phase0-clusters.md
    section: "Round 1+2 Q&A — 28 questions answered (clusters A-F + Q1-Q7)"

intent_classification:
  primary_intent: DECISION
  affects_charter: false
  affects_scope: true
  urgency: NORMAL
  complexity_score: 95

options_considered:
  - id: A
    summary: "Original 8-track port-from-orch plan (pre-mining)"
    pros:
      - "Smaller scope"
    cons:
      - "Skips workspace dualism / provenance / intent classifier / Q&A doctrine — all user-CRITICAL from UP-02/UP-03"
  - id: B
    summary: "10-track design (initial proposal — workspace + provenance + intent + Q&A + port + constitution + Confidence Score + Self-Awareness + 1 buffer)"
    pros:
      - "Covers all user requirements UP-01/02/03"
    cons:
      - "Pre-mining; missed amendments surfaced by Track 0 synthesis"
  - id: C
    summary: "11-track REV-2 (10 + Track 8 split into 8a Confidence Score + 8b Memory L0/L1 extraction)"
    pros:
      - "Incorporates 30+ pattern-mining amendments"
      - "OTEL stack included per Q-S4"
      - "Identity NOT-list canonical per Q-S5"
    cons:
      - "Larger budget (~1.3M main)"

chosen: C
chosen_rationale: |
  Pattern mining (Track 0) surfaced 18+ structural amendments AND mining itself was a Track 0
  pre-design step per the original plan. Including amendments now is cheaper than ad-hoc
  retrofits later (msmdp lesson: pre-design refinement saves 2-3× cost vs. mid-flight rework).
  Track 8 SPLIT (Q-S1) keeps Confidence Score focused on sync-tracker while allowing parallel
  port of the high-leverage claude-sessions L0/L1 + cleanText + TranscriptCache patterns —
  these are independently valuable and would otherwise force a Phase 1 retrofit.

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-04-29
    via: "session 1 (S1) — Round 1+2 Q&A bundle"
  - actor: user
    action: ACCEPTED
    at: 2026-04-29
    via: "chat reply 'ok rồi. continue' (Round 1+2 default acceptance)"
  - actor: agent
    action: AMENDED-REV-2
    at: 2026-04-29
    via: "Track 0 synthesis-driven Round 3 Q-S1..Q-S5"
  - actor: user
    action: ACCEPTED-REV-2
    at: 2026-04-29
    via: "chat reply 'ok continue' confirming Q-S1=B / Q-S2=close / Q-S3=A / Q-S4=A / Q-S5=NOT-list (NOTE: Q-S5 is charter-tier; per S2 audit G1, dedicated re-grill scheduled S5 Track 7 — see queued-items observation)"
  - actor: user
    action: CONFIRMED-CHARTER-VIA-ASKUSERQUESTION
    at: 2026-04-29T14:05:00Z
    via: "AskUserQuestion explicit pick (no default-shortcut). Bundle: human-workspace/q-and-a/pending/2026-04-29-002-charter-tier-harness-self-correction.md"
    answers:
      CHARTER-A1: "A — Keep current; no new charter principle / no Track 10. Self-correction stays emergent across Tracks 5+8+9."
      B1: "A — AskUserQuestion is PRIMARY for ALL bundles; file becomes audit-only. Codified in qa-escalation/SKILL.md § Channel Routing."
      C1: "D — Defer context augmentation (RAG/KG); decide post Track 8a/8b based on retrieval failure metrics."
      A1: "B — Bottleneck = harness deterministic layer not yet wired (pre-S3 fortification gap). Confirms agent diagnosis."
  - actor: user
    action: CONFIRMED-UP05-VIA-ASKUSERQUESTION
    at: 2026-04-29T15:05:00Z
    via: "AskUserQuestion explicit pick. Bundle: human-workspace/q-and-a/pending/2026-04-29-003-up05-askuser-permissions-rawsessions.md. Source prompt: human-workspace/user_prompt/20260429_05.txt (hash ef1dbb2d)."
    answers:
      Q3.1: "A — agent-workspace/raw-sessions/<YYYY-MM-DD-session-N>.md (agent-owned)"
      Q3.2: "A — SessionEnd hook auto-fires /export equivalent (Track 5 deliverable, S3)"
      Q3.3: "A — YAML frontmatter only (id / session_n / related_decisions / hash / token_count); richer indexing deferred Phase 1+"
      Q3.4: "A — Full sanitize (B+C: _redact_secrets + cleanText system-reminder/harness chatter strip)"
      Q2.1: "RE-QUEUED to queued-grill-master.md fire_when: S5 Track 7 autonomous-protocol.md (UP-06 NO-silent-default rule)"
      Q4.1: "CLOSED-IMPLICIT — subsumed by Q3.* picks (raw-sessions = Track 5 amendment)"
  - actor: user
    action: CHARTER-AMEND-UP06
    at: 2026-04-29T15:30:00Z
    via: "chat directive (not via AskUserQuestion since user was correcting the policy itself): 'tôi sẽ không vào file q&a để trả lời, ví dụ như tôi đang remote-control từ mobile thì sao. cần phải làm cho q&a thực sự hiệu quả chứ không phải làm cho có'"
    amends:
      B1_refinement: |
        AskUserQuestion is the ONLY effective input surface (not just PRIMARY). File-based bundle is
        pure audit trail; NEVER assumed user will edit (mobile-remote scenario explicitly cannot).
        Multi-batch chain (within-turn or across-turn) for any bundle >4 questions.
        NO "default applies after N hours" semantic — that's silent absorption in disguise.
        Questions not blocking now → queue in queued-grill-master.md with fire_when trigger; never
        bundle them as deferred-default.
    affects_files:
      - .claude/skills/qa-escalation/SKILL.md (§ Channel Routing rewritten)
      - .claude/skills/grill-maximization/SKILL.md (§ No-Silent-Default Rule added)
      - agent-workspace/memory/agent-notes.md (UP-06 rule added)
      - agent-workspace/memory/observations/queued-grill-master.md (CREATED — 11 deferred questions migrated from bundles 002+003)
      - human-workspace/q-and-a/pending/2026-04-29-002-... (status updated; deferral-defaults removed)
      - human-workspace/q-and-a/pending/2026-04-29-003-... (Q2.1 re-queued, Q4.1 closed-implicit)
  - actor: user
    action: AMENDED-REV-3
    at: 2026-04-29
    via: "AskUserQuestion 2 rounds (8 explicit picks total) — see D-003 + human-workspace/q-and-a/answered/2026-04-29-004-up06-track-5.5-amendment.md. Source prompt: human-workspace/user_prompt/20260429_06.txt."
    amends:
      track_5_5_insertion: |
        Insert NEW Track 5.5 (Sync + Layer + Self-Capability Foundation) between Track 5 and
        Track 6, executed Layer→Sync→Self-Cap. Track 6 rewrites post-5.5 to consume layer
        manifest. Detail in D-003. Budget delta ~1.28M → ~2.02M (within user-accepted ~1.5-2M
        band).
    affects_files:
      - .claude/manifest.yaml (NEW)
      - .claude/stockforge/** (NEW subtree — biz-specific skills/agents/commands)
      - .claude/skills/{attach,sync-grilling,decompose-work,try-n-approaches}/** (NEW)
      - .claude/agents/intent-vs-impl-diff.md (NEW)
      - scripts/hooks/sync-grilling-trigger.sh (NEW)
      - agent-workspace/memory/{sync-state.md,capability-map.md} (NEW)
      - docker/otel-stack/** (NEW)
      - agent-workspace/session-plans/pending/002-track-5.5-sync-layer-selfcap.md (NEW master plan)

verified_by:
  - mechanism: pattern-mining
    at: 2026-04-29
    result: PASS
    notes: "Track 0 — 3 sources mined; SYNTHESIS.md + borrow-list.md produced; informed REV-2 amendments"
  - mechanism: cross-decision-check
    at: 2026-04-29
    result: PASS
    notes: "D-001 dependency satisfied; consistent with D-002 scope"

affects:
  charter: false
  spec_files: []
  code_paths:
    - "agent-workspace/**"
    - ".claude/agents/**"
    - ".claude/skills/**"
    - ".claude/commands/**"
    - "scripts/hooks/**"
    - "scripts/session-self-reboot.{sh,ps1}"
    - "scripts/session-handoff.sh"
    - "packages/observability/**"
    - "docker/otel-stack/**"
    - "human-workspace/CLAUDE.md"
    - "agent-workspace/CLAUDE.md"
  config_files:
    - ".claude/settings.json"
    - ".gitignore"
    - "CLAUDE.md"
  other_decisions:
    - D-003   # to-be-written: Confidence Score System schema (Track 8a deliverable)
    - D-004   # to-be-written: Self-Awareness Agent schema (Track 9 deliverable)

depends_on:
  - D-001   # pause-orch must be ACCEPTED to authorize the port

supersedes: null
superseded_by: null

defer_cycles: 0
re_attempt_prereq: "N/A — currently in active execution (S2)."

tags: ["phase-0", "harness", "bootstrap", "scope", "rev-3", "11-tracks-plus-5.5", "scope-locked"]
---

# Decision 002 — Phase 0 Harness Bootstrap Design (11 Tracks, REV-2)

> Status: ACCEPTED-REV-2 (2026-04-29). REV-2 amendments live in § Amendments below; original ACCEPTED text retained for audit.
> Q&A audit: `human-workspace/q-and-a/answered/2026-04-29-001-phase0-clusters.md`.
> Supersedes initial 8-track plan in `session-plans/pending/001-port-from-orch.md` (filename retained).

---

## Context

Per `human-workspace/user_prompt/20260429_02_init.txt` and `_03.txt`, the user articulated 7 intertwined system requirements driving how StockForge will run full-autonomously:

| # | System | Source clause | Tier |
|---|---|---|---|
| **A** | Workspace dualism (human/agent separation + provenance) | UP02 §1.1, §1.3 | T1 |
| **B** | Provenance tracking (level + source + verifier + dependencies) | UP02 §1.1, §1.3 | T1 |
| **C** | Intent classifier (hybrid: main lite + subagent for complex) | UP02 §1.1 + UP03 Q3 | T1 |
| **D** | Q&A escalation + Grill Maximization doctrine | UP02 §1.1 + UP03 Q5 | T1 |
| **E** | Loop-resilience port from orch (hooks, scripts, skills, subagents, constitution) | derived | T1 |
| **I** | Confidence Score (sync tracker / second brain) | UP03 Q5 | T1 |
| **J** | Self-Awareness Agent (model × effort × thinking telemetry) | UP03 §after-Q5 | T1 |

Plus deferred T2:
| **F** | Sync ladder formalization | UP02 §1.2 | T2 (Phase 1+) |
| **G** | Obsidian wiki visualization layer | UP02 §1.3 | T2 (Phase 1+) |
| **H** | Deep pattern mining (telemetry-analyst style) | UP02 §1.4 | T2 (Phase 1+) |

The orch sister project (`C:\htdocs\orch-starter`) reached v2.2.0 via 12 phases of autonomous execution. The user observed in UP02 §1.1: "agent không verify lại, không q&a lại, mà luôn chiều theo ý của người dùng, nên project thậm chí drift ở cấp độ project charter." This is a charter-level drift observation that informs the entire design.

---

## Decision

**Phase 0 = Harness Bootstrap = 10 tracks, executed in supervised mode until Track 7 completes (then autonomous mode activates).**

### Phase numbering update (this decision)

| Old | New | Description |
|---|---|---|
| — | **Phase 0 (NEW)** | Harness Bootstrap |
| Phase 0 | Phase 1 | Project Setup (Day 1 Checklist) |
| Phase 1 | Phase 2 | Foundation (Tier 1+2 ingestion) |
| Phase 2 | Phase 3 | Edge Sources (Tier 3+4) |
| Phase 3 | Phase 4 | Multi-perspective adversarial agents |
| Phase 4 | Phase 5 | Compounding outer loop |

Updated in `agent-workspace/memory/project.md` + `current-execution.md` (this turn). `CLAUDE.md` references will be updated in Track 7.

---

## Track Specifications

### Track 0 — Pattern Mining (3 sources, parallel)
- **Goal**: Extract BORROW / ADAPT / LEARN / SKIP patterns from 3 evidence sources before designing remaining tracks
- **Sources**: 
  1. Orch knowledge crystal: `C:\htdocs\orch-starter\agent-workspace\memory\decisions\` + `agent-notes.md` + `phase-N-complete.md` (1..7) + `post-mortems\`
  2. ms-mdp-admin phase2_workflow: `C:\htdocs\labci\ms-mdp-admin_refactor\tasks\refactor_phase2\phase2_workflow\` (38 docs; deep-read 10, skim rest)
  3. Orch reference-repos: `C:\htdocs\orch-starter\reference-repos\` + existing notes in `C:\htdocs\orch-starter\agent-workspace\research\`
- **Mechanism**: 3 general-purpose agents in `run_in_background: true`, parallel
- **Output**: 3 files in `agent-workspace/memory/patterns-discovered/pattern-mining-{orch,msmdp,refrepos}.md` + `SYNTHESIS.md` + `borrow-list.md`
- **Synthesis step**: separate opus agent (fresh context) reads 3 mining reports, produces `SYNTHESIS.md` + `borrow-list.md`
- **Dependency**: none (kicks off immediately, parallel with Tracks 1-2 if possible)
- **Est tokens**: 3 × 50K (parallel, bg) + 30K synthesis = ~180K
- **Success**: 5 files produced; each pattern categorized; synthesis identifies top-20 BORROW + adaptations needed for stockforge Python stack
- **Risk**: Subagent doesn't comply with output schema → mitigation: explicit output structure in prompt + verifier

### Track 1 — Workspace Dualism Foundation
- **Goal**: Establish folder contract between human-workspace/ and agent-workspace/; no agent writes to human-workspace except q-and-a/pending/ (agent's questions); no human edits to agent-workspace except via user_prompt drops
- **Output**: 
  - Folder structure created (already done this turn via mkdir)
  - `human-workspace/CLAUDE.md` — contract rules for human-workspace
  - `agent-workspace/CLAUDE.md` — contract rules for agent-workspace
  - Update `.gitignore` for `.dotfiles` markers
  - Update `.claude/settings.json` permissions to enforce contract (allow `Write(human-workspace/q-and-a/pending/**)`, deny `Write(human-workspace/user_prompt/**)`)
- **Dependency**: Track 0 (in case mining surfaces structural insights)
- **Est tokens**: 30K
- **Success**: contract files exist; permissions enforce; smoke test: agent attempt to write `human-workspace/user_prompt/foo.txt` is denied

### Track 2 — Provenance Schema + Decision Log (System B)
- **Goal**: Schema for decisions/, integration with agent-notes, drift detection hooks
- **Schema**: Per Q&A E2 confirmed (12-field decision-id format with level/source/intent_classification/options/chosen/verified_by/affects/depends_on/status/etc)
- **Output**: 
  - `agent-workspace/memory/decisions/_template.md` — canonical decision template
  - `agent-workspace/constitution/provenance-protocol.md` — when/how to log decisions (will be DRAFT here; constitution edit needs approval — see Track 7)
  - Migration: existing decisions 001 + 002 reformatted to schema (this decision is the seed reference)
- **Dependency**: Track 1
- **Est tokens**: 50K
- **Success**: every decision file follows template; agent-notes references decision IDs; drift-detector can scan for unanchored claims

### Track 3 — User Prompt Intake + Hybrid Intent Classifier (System C)
- **Goal**: Whenever user drops a file in `human-workspace/user_prompt/` or types in chat, agent classifies intent; trivial → handle in main; complex → dispatch `intent-classifier` subagent
- **Lite-detect heuristic** (Q&A D1 = D): trivial whitelist (~15 patterns: "continue", "go", "next", "yes", "ok", "ok rồi", "stop", short single-word) + mini-classification fallback if no match
- **Subagent output schema** (Q&A D2 confirmed): primary_intent, affects_charter, affects_scope, urgency, complexity_score, recommended_action, human_intent_summary, suggested_grill_questions, provenance
- **Output**:
  - `.claude/agents/intent-classifier.md` (sonnet, fresh context, ~5K per dispatch)
  - `.claude/skills/user-prompt-intake/SKILL.md` (main session protocol)
  - `agent-workspace/memory/observations/intent-<TS>.md` — every classification logged
- **Dependency**: Tracks 1, 2
- **Est tokens**: 60K
- **Success**: drop a test prompt; intent-classifier returns YAML; main session uses output to route work

### Track 4 — Q&A Escalation + Grill Maximization (System D)
- **Channel** (Q&A C2 confirmed): file-based `human-workspace/q-and-a/{pending,answered,stale}/<TS>-<topic>.md` with YAML frontmatter (id, topic, opened_at, expected_answer_by, priority, related_decisions, status)
- **Bundle size cap** (Q&A C1 = B): 15-20 questions per turn target; max 25; if more, split into 2 sequential bundles
- **Doctrine** (Q&A C3 confirmed): if no reply in 24h → continue work non-blocking-by-Q&A, pause work blocked-by-Q&A; flag urgent cuts to 4h
- **Notification** (Q&A E1 confirmed): file-based primary + claude.ai mobile realtime; Telegram defer (not built in Phase 0)
- **Output**:
  - `.claude/skills/grill-maximization/SKILL.md`
  - `.claude/skills/qa-escalation/SKILL.md`
  - SessionStart hook scans `human-workspace/q-and-a/answered/` for new replies → moves to `processed/` after agent reads
  - SessionStart hook flags `pending/` items past expected_answer_by → moves to `stale/`
- **Dependency**: Tracks 1, 2
- **Est tokens**: 50K
- **Success**: open a test Q&A bundle; user fills inline answers; agent reads on next session and updates decisions referenced

### Track 5 — Loop-Resilience Port from orch (System E.1: hooks/scripts)
- **Sources**: `C:\htdocs\orch-starter\scripts\hooks\` + `scripts\session-self-reboot.{sh,ps1}` + `scripts\session-handoff.sh`
- **Files to port**: budget-watchdog, autonomous-stop-watchdog, dispatch-jsonl-recorder, session-start-bootstrap, component-telemetry, subagent-stop-logger, tool-call-first-lint
- **Adjustments**: ORCH_* env prefix → STOCKFORGE_* (with ORCH_* fallback for migration); paths verified for stockforge dir structure; node parsing fallback to jq/python if node missing
- **Output**: 
  - `scripts/hooks/*.sh` (7 scripts)
  - `scripts/session-self-reboot.{sh,ps1}` + `scripts/session-handoff.sh`
  - `.claude/settings.json` updated with hooks section
  - `agent-workspace/memory/.transcript-tokens` + `.session-hooks.log` + `.wind-down` + `.autonomous-stop-watchdog.log` markers wired
- **Dependency**: Tracks 1, 2 (workspace structure must exist for hook outputs)
- **Est tokens**: 80K
- **Success**: SessionStart fires bootstrap hook; PostToolUse logs to dispatch.jsonl; manually-induced 230K transcript triggers session-self-reboot.sh

### Track 6 — Discipline Skills + Subagents Port (System E.2: skills/agents)
- **Skills to port** (8): subagent-driven-development, verification-before-completion, systematic-debugging, research-first, confusion-protocol, brainstorming, spawned-session-mode, observation-file-write-on-return
- **Subagents to port** (5 selected, skip telemetry-analyst/research-scanner — defer to Phase 1+): task-implementer, spec-compliance-reviewer, code-quality-reviewer, systematic-debugger, intent-classifier (built in Track 3)
- **Stack adaptations**: TypeScript/NestJS examples in skills replaced with Python/FastAPI; cross-references repointed to stockforge constitution
- **Output**: `.claude/skills/<8 dirs>/SKILL.md` + sibling `*.test.md` + `references/` where applicable; `.claude/agents/<5 files>.md`
- **Dependency**: Track 5 (skills reference hook outputs)
- **Est tokens**: 120K
- **Success**: `Skill` tool can invoke each by name; test docs assertions hold; sample subagent dispatch returns structured YAML

### Track 7 — Constitution + CLAUDE.md Updates
- **Files to write**: 
  - `agent-workspace/constitution/autonomous-protocol.md` (port from orch, adapted)
  - `agent-workspace/constitution/model-routing.md` (port from orch, with stockforge subagent table)
  - Update `CLAUDE.md` (add Autonomous Mode section, Budget Watchdog Protocol, Tool-call-first ordering, Modes A/B/C, Subagent dispatch table, Effort mode discretion, Spawned-session-mode pointer)
- **Important**: Constitution writes need user approval (Edit/Write to `agent-workspace/constitution/**` is in deny list). This Track will produce the files in `agent-workspace/proposals/` first, then user reviews + approves move to constitution/
- **Dependency**: Tracks 5, 6 (mechanisms must exist before constitution codifies them)
- **Est tokens**: 60K
- **Success**: 2 new constitution files (post-approval); CLAUDE.md ≤3500 tokens; sample autonomous loop reads autonomous-protocol on startup

### Track 8 — Confidence Score System (System I)
- **Schema** (per Decision 003 — to be written next turn): 5 categories (LANGUAGE, DOMAIN_UBIQUITOUS, DESIGN_THINKING, SCOPE, DECISION_ROUTING); hybrid scale (tier display + 0-100 internal); SQLite storage; tag+recency retrieval; SessionStart auto-load top-10 + on-demand `/sync-pull` skill
- **Thresholds** (Q&A A4 = D): per-decision-class — CHARTER 0.99, SCOPE 0.90, ARCH 0.80, IMPL 0.50
- **Update events** (Q&A A5): asymmetric weights (correction -2; revocation -3; charter-match +0.2; etc); weights tunable
- **Reversal protocol** (Q&A A6): 6-step (log revocation → drop score → revert if reversible → post-mortem → category to "must-grill" mode for N interactions)
- **Output**:
  - `agent-workspace/memory/sync-tracker/sync-tracker.db` (SQLite schema)
  - `agent-workspace/memory/sync-tracker/_index.md` (auto-rendered from DB for human reading)
  - `agent-workspace/memory/sync-tracker/weights.yaml` (tunable)
  - `.claude/skills/sync-pull/SKILL.md`
  - `scripts/hooks/sync-tracker-update.sh` (hook on Q&A answered events)
- **Dependency**: Tracks 4 (Q&A channel feeds score updates), 5 (hooks)
- **Est tokens**: 100K
- **Success**: smoke test — answer 5 Q&As; categories scored; mockup decision below SCOPE threshold triggers Q&A bundle automatically

### Track 9 — Self-Awareness Agent (System J)
- **Schema** (per Decision 004 — to be written next turn): 5 dimensions (model, tier, effort, thinking, task_class); source = telemetry 0.4 + user_feedback 0.5 + self-assessment 0.1; SQLite source + markdown profile cards rendered; per-session aggregation + realtime for failures
- **Output**:
  - `agent-workspace/memory/self-awareness/self-awareness.db`
  - `agent-workspace/memory/self-awareness/profiles/<model>-<effort>.md` (auto-rendered)
  - `agent-workspace/memory/self-awareness/known-issues.md`
  - `agent-workspace/memory/self-awareness/best-practices.md`
  - `.claude/agents/self-awareness-analyst.md` (opus, fresh context, dispatched per session-end)
  - `scripts/hooks/self-awareness-aggregate.sh` (Stop hook)
- **Dependency**: Tracks 5 (telemetry hooks)
- **Est tokens**: 100K
- **Success**: 3 sample sessions captured; profile card auto-generated; agent's next session reads profile cards before dispatching subagents (model routing influenced)

---

## Sequencing & Dependencies

```
Track 0 (background, parallel)              [start immediately]
  ├─ orch mining (~50K, bg)
  ├─ msmdp mining (~50K, bg)
  └─ refrepos mining (~50K, bg)
  → Synthesis (~30K, opus, fresh)            [after all 3 return]

Track 1 (foundation)                          [in parallel with Track 0 if budget allows]
  └─ Track 2 (provenance)
       ├─ Track 3 (intent classifier)
       └─ Track 4 (Q&A escalation)

Track 5 (loop-resilience hooks)               [parallel with Track 3-4 OK]
  └─ Track 6 (skills + subagents)
       └─ Track 7 (constitution + CLAUDE.md)
            └─ AUTONOMOUS_MODE activated

Track 8 (Confidence Score)                    [needs 4, 5]
Track 9 (Self-Awareness)                      [needs 5]
```

Recommended session breakdown (Q&A E4 = B confirmed: sequential per cluster + verifier subagent + user reviews final each cluster):

| Session | Tracks | Type | Budget |
|---|---|---|---|
| S1 | Dispatch Track 0 (bg) + Tracks 1, 2 | FOCUSED_IMPL | 100K main + 180K bg |
| S2 | Track 0 synthesis + Track 3 + Track 4 | MULTI_TASK_IMPL | 150K |
| S3 | Track 5 | FOCUSED_IMPL | 100K |
| S4 | Track 6 | MULTI_TASK_IMPL (subagent-driven) | 200K (heavy) |
| S5 | Track 7 + verifier on Tracks 1-6 | VERIFY+IMPL | 130K |
| S6 | Track 8 | FOCUSED_IMPL | 130K |
| S7 | Track 9 + final verifier | VERIFY+IMPL | 130K |

Total: ~940K main + 180K bg = ~1.1M tokens.

---

## Risk & Mitigation

| Risk | Mitigation |
|---|---|
| Track 0 agents return low-quality mining (subagent context bias) | Explicit output schema + verifier reads after; if poor, re-dispatch with refined prompt |
| Phase 0 itself drifts (meta-drift) | This decision document + Q&A audit + verifier checkpoint each cluster |
| Scope creep into Tracks 8/9 (ambitious systems) | MVP-only spec; defer "deep" features (sync ladder full, Obsidian visualization full, deep pattern mining) to Phase 1+ |
| User changes mind mid-Phase | user_prompt drop in human-workspace; intent-classifier (once built) handles; until then, supervised mode + manual handling |
| Constitution writes blocked by deny-list | Track 7 produces drafts in `agent-workspace/proposals/`; user explicit approve to move to constitution/ |
| Token budget overrun in S4 | Sub-divide via subagent-driven-development pattern; if still over, split S4a/S4b |

---

## Open Items Deferred to Phase 1+

- **F (Sync ladder full formalization)**: extend /grill-me v2 to track sync state across language→ubiquitous→design→goals; implement skill `/grill-me-sync` 
- **G (Obsidian visualization full)**: graph view, dashboards, decision tree rendering
- **H (Deep pattern mining)**: telemetry-analyst-style RULE-1..RULE-N self-evolution; full SC-39-style scaffolding
- **Telegram bot** (Q&A E1 alternative): only build when stockforge has signal alerts to push (Phase 4+)
- **Worker mailbox / multi-project queue**: explicitly out of scope (Phase 0 of orch had this; stockforge doesn't need it)

---

## Acceptance Record

This decision became ACCEPTED upon user reply "ok rồi. continue" (2026-04-29) after Round 1 + Round 2 Q&A.

Round 1 Q&A: 7 questions in `agent-workspace/memory/decisions/001-orch-vs-cc-native.md` § "Open Questions for User" — all defaults accepted.
Round 2 Q&A: 21 questions in user_prompt 02 + 03 response — all defaults accepted (Cluster A all defaults, Cluster B B2=E B3=C B4=per-session, Cluster C C1=B C3=B 24h, Cluster D D1=D, Cluster E all confirmed, Cluster F all confirmed).

Audit artifact: `human-workspace/q-and-a/answered/2026-04-29-001-phase0-clusters.md`.

---

## Amendments — REV-2 (2026-04-29)

**Trigger**: Pattern Mining (Track 0) completed; synthesis surfaced 18+ amendments to original 10-track design.

**Authorization**: User reply "ok continue" 2026-04-29 confirming Q-S1=B / Q-S2=close / Q-S3=A in-place amend / Q-S4=A include OTEL / Q-S5=identity NOT-list.

**Source artifacts**:
- `agent-workspace/memory/patterns-discovered/SYNTHESIS.md` — full amendment list (Sections 3, 5, 7, 8)
- `agent-workspace/memory/patterns-discovered/borrow-list.md` — actionable port queue (15 BORROW + 27 ADAPT + 24 LEARN + 25 SKIP)
- `agent-workspace/memory/patterns-discovered/pattern-mining-{orch,msmdp,refrepos}.md` — source evidence

### A. Track 8 SPLIT (Q-S1 = B)

Track 8 (Confidence Score System) is split into two sub-tracks, both feeding the same `agent-workspace/memory/sync-tracker/sync-tracker.db`:

- **Track 8a — Confidence Score System** (per original Track 8 spec)
- **Track 8b — Session Memory L0/L1 Extraction** (NEW)
  - Port `claude-sessions` L0 regex (`extract-l0.ts:5-80`) verbatim → `packages/observability/extract_l0.py`
  - Port `claude-sessions` L1 prompt (`extract-l1.ts:33-64`) verbatim with VN extension
  - Port 15+35 head/tail windowing
  - Port `cleanText` regex (strips system-reminder/command-name/task-notification harness chatter — CRITICAL or memories pollute)
  - Port `TranscriptCache` (LRU + mtime+size dual-check + byte-offset incremental reads) → `packages/observability/transcript_cache.py`
  - **EXTEND L0 FAILURE_PATTERNS with VN phrases**: "không hoạt động", "không hiệu quả", "đã thử nhưng", "không khả thi", "thất bại"
  - Output: `.claude/skills/session-memory-l0-l1/SKILL.md`

### B. Track-by-Track Amendments

| Track | Amendment | Type | Source |
|---|---|---|---|
| **Track 5** | ADD `UserPromptSubmit` invariant injector hook (5-line I-S1/I-S2/I-S3 reminder per prompt) | ADD | U1 / A-2 |
| **Track 5** | ADD `PostToolUse` citation grep hook (number → require `source:` + `as_of:`) | ADD | U2 / A-3 |
| **Track 5** | ADD `PreCompact` thesis-state dump hook | ADD | U3 / A-5 |
| **Track 5** | ADD `TaskCompleted` audit hook (auto-grep I-S1/I-S2 violations) | ADD | U4 / A-4 |
| **Track 5** | ADD drift-signal grep scripts (D1-D8 hook-runnable, replace human-checked DR1-DR12) | ADD | A-19 |
| **Track 5** | ADD `_redact_secrets` regex utility | ADD | B-12 |
| **Track 5** | ADD Same-Commit Rule pre-commit hook (spec ↔ code coupling; charter exempt) | ADD | A-23 |
| **Track 5** | ADD charter-coherence-spot-check (greps "buy/sell/recommend" without "thesis exploration") | ADD | A-6 |
| **Track 6** | ADD `validate_skills.py` (frontmatter / kebab-case / ≤200ch desc / ≤200 LOC body) — `--soft-warn` first 30 days | ADD | U5 / A-11 |
| **Track 6** | REFINE all 12 existing skills to progressive-disclosure (≤150 LOC SKILL.md + `references/` + `scripts/`) | REFINE | U6 / A-12 |
| **Track 6** | ADD `allowed-tools` frontmatter field to all skills | ADD | A-13 |
| **Track 6** | ADD sibling `*.test.md` for all skills (5 H2 + 3 numbered assertions + ≥3 named failure modes + ≤80 LOC) | ADD | A-10 |
| **Track 6** | ADD subagents: spec-compliance-reviewer, code-quality-reviewer (port from orch); AUDIT existing sandwich-verifier against orch's Mandates A-E | ADD/AUDIT | U7 / B-14 |
| **Track 6** | REFINE existing sandwich-architect with Mandates A-E (Pre-write VBW dry-run / staged-index / awk-range self-match / Prisma flag freshness / incremental Edits ≥10 for content >200 LOC) | REFINE | A-9 |
| **Track 6** | ADD identity emoji + role prefix + per-interaction budget caps to all agent frontmatters | ADD | A-26 |
| **Track 7** | ADD `mistake-log.md` (What went wrong / Root cause / Prevention rule / Severity) | ADD | U8 / B-15 |
| **Track 7** | ADD `mode-routing.md` Mode A/B/C named taxonomy with structural fixes per mode | ADD | U9 / L-7 |
| **Track 7** | ADD `user-intent-coherence.md` + USER-CRITICAL severity tier | ADD | U10 / L-4 |
| **Track 7** | ADD `self-application-bootstrap.md` (Phase 0 self-app deliverable, NOT deferred CF) | ADD | U11 / L-5 |
| **Track 7** | ADD `identity-scope.md` (canonical NOT-list — see § F below) | ADD | U12 / L-6 |
| **Track 7** | ADD `config-style-guide.md` (LOC ceilings 200/150/120 for agents/skills/commands; canonical `tools` key; archetype required) | ADD | B-13 |
| **Track 7** | REFINE VBW protocol with granular checkpoints (Pre-Spec / Pre-Test / Mid-Implement-every-5-steps / Post-Implement) + 5 rules (VBW/CCF/SYA/DA/TBA) | REFINE | A-22 |
| **Track 7** | ADD `thesis-anti-patterns.md` (A-thesis1: single-perspective / A-thesis2: LLM-numbers / A-thesis3: confidence-without-calibration / A-thesis4: portfolio-conflict) | ADD | A-27 |
| **Track 7** | ADD `.claudeignore` + layered context loading discipline (`obsidian-vault/raw/`, `eval-sets/`, deep `agent-workspace/memory/sessions/`) | ADD | A-25 |
| **Track 7** | ADD `decision-discipline.md` (Document-And-Move + multi-cycle-defer admissibility + independence audit + 3-cycle alert) | ADD | L-10/L-11/L-13 |
| **Track 7** | ADD PBI 4-part template (Directive + Context Pointer + Verification Pointer + Refinement Rule) | ADD | A-24 |
| **Track 7** | ADD spec-authority hierarchy (Charter immutable; below-charter Same-Commit Rule) | ADD | D6 |
| **Track 8a** | REFINE Confidence Score: ground in **empirical hit rate**, NOT qualitative LOW/MED/HIGH ladder | REFINE | U13 / D3 |
| **Track 8b (NEW)** | Port claude-sessions L0+L1+windowing+cleanText+TranscriptCache (see § A above) | NEW | B-8/B-9/B-10/B-11/A-15 |
| **Track 9** | ADD OTEL single-container `grafana/otel-lgtm:1.4.0` stack (3 files copy-verbatim to `docker/otel-stack/`) — Q-S4 confirmed include | ADD | U16 / B-6/B-7 |
| **Track 9** | ADD skills: `thesis-anomaly-detector` / `daily-thesis-summary` / `hook-diagnostics` | ADD | U17 / A-16/A-17/A-18 |
| **Track 9** | REFINE Self-Awareness Agent as **deterministic-hooks Guardian + LLM aggregator at session-end ONLY** (NOT continuous LLM-Guardian) — addresses UP02 §1.4 cost concern | REFINE | U18 / D5 / R8 |
| **Track 9** | ADD `rollup_telemetry.py` (Python rewrite of orch TS aggregator) + telemetry-analyst subagent | ADD | A-7 |
| **Track 9** | ADD hook event state machine (active/completed/error/abandoned + reactivation) → `packages/observability/state_machine.py` | ADD | A-14 |

### C. Risk Register Updates (added to original Decision 002 § Risk & Mitigation)

| Risk | Mitigation | Phase |
|---|---|---|
| R1: Self-track inflation > 1.35× real → premature wind-down | `.transcript-tokens` watchdog + log inflation ratio time series; alert at >1.5× | Track 5 |
| R5: Skill validator hard-fail breaks 12 existing skills day 1 | `--soft-warn` flag for first 30 days, then hard-fail | Track 6 |
| R7: Multi-cycle defer drifts into can-kicking | Provenance schema: `re_attempt_prereq` + `cycle_count`; alert at >3 cycles | Track 2 |
| R8: Continuous LLM-Guardian cost prohibitive (UP02 §1.4) | Deterministic-hook Guardian + LLM aggregator only at session-end | Track 9 |
| R9: L0/L1 extraction polluted by harness chatter | Port `cleanText` regex BEFORE L0/L1 | Track 8b |
| R10: Hook result schema incorrectness silently breaks gates | Document `{decision: approve\|deny\|modify}` schema in hook authoring guide | Track 5 |
| R12: Spec-as-Source butterfly effect (tiny spec → 50 files) | NEVER 100% generation from spec without code-level review; sandwich pattern protects | Tracks 6+7 |

### D. Revised Session Sequencing (was 7-8, now 9 sessions)

| # | Session | Tracks | Type | Budget |
|---|---|---|---|---|
| S1 (DONE) | Bootstrap kickoff | Track 0 (3 mining + synthesis + borrow-list) + design refinement | FOCUSED_IMPL | ~210K main + 180K bg (consumed) |
| S2 (NEXT) | Workspace + provenance + intake + Q&A | Tracks 1, 2, 3, 4 (intent-classifier + Q&A escalation) | MULTI_TASK_IMPL | 150-200K |
| S3 | Loop-resilience hooks | Track 5 (10+ hooks + reboot scripts + drift-signal greps) | FOCUSED_IMPL | 130K |
| S4 | Skills + subagents port | Track 6 (port + refactor 12 skills + 3 subagents + Mandates A-E) | MULTI_TASK_IMPL (subagent-driven) | 200K |
| S5 | Constitution + verifier | Track 7 (10+ constitution files) + sandwich-verifier on Tracks 1-6 | VERIFY+IMPL | 150K |
| S6 | Confidence Score | Track 8a | FOCUSED_IMPL | 130K |
| S7 | Memory L0/L1 extraction | Track 8b | FOCUSED_IMPL | 120K |
| S8 | Self-Awareness + OTEL | Track 9 | MULTI_TASK_IMPL | 150K |
| S9 | Final Phase 0 verifier | sandwich-verifier whole-Phase | VERIFY | 80K |

Total: ~1.3M main + 180K bg = ~1.5M tokens. Increase from REV-1 (940K main) reflects amendments scope (~30 ADDs + ~10 REFINEs).

### E. Confirmed User Decisions (Round 3 Q-S1..Q-S5)

- **Q-S1**: B — Track 8 SPLIT into 8a (Confidence Score) + 8b (Memory L0/L1)
- **Q-S2**: CLOSE Track 0 — no further mining required; 3 sources fully covered
- **Q-S3**: A — in-place amend Decision 002 with REV-2 marker (this section)
- **Q-S4**: A — INCLUDE OTEL stack (single-container LGTM) in Phase 0 Track 9
- **Q-S5**: CONFIRMED identity NOT-list (see § F below); "small trusted circle" = git-fork single-tenant approach

### F. Identity NOT-List (canonical, per Q-S5)

**Stockforge IS**:
- AI-first VN stock advisory for personal use + small trusted circle (3-5 peers via git fork)
- Python-primary single-tenant single-instance system
- Research-aid framing — "thesis exploration", NOT financial advice
- Compounding edge through proprietary data + calibration + adversarial-by-default discipline

**Stockforge is NOT**:
- ❌ A generic AI advisor (must be VN-stock-specific; no generic Bloomberg-clone)
- ❌ A multi-tenant SaaS (Phase 0-5 explicitly single-tenant; Phase 6+ requires re-charter)
- ❌ A Telegram/Slack bot platform (alerts deferred Phase 4+; mobile claude.ai sufficient until then)
- ❌ A generic financial-modeling framework (no vectorbt-clone, no portfolio-optimizer-as-product)
- ❌ An insider-info aggregator (charter principle — public sources only)
- ❌ An automated trade execution system (charter principle — manual execution)
- ❌ An LLM-math computation engine (I-S1)
- ❌ A high-frequency trading system (charter scope — 1-month minimum holding)
- ❌ A licensed financial advice provider (charter scope)

This list is codified into `agent-workspace/constitution/identity-scope.md` in Track 7.

### G. Closure Statement

REV-2 preserves Decision 002 spirit + budget envelope. All 30+ amendments are within Phase 0 Harness Bootstrap scope (mining was a pre-design refinement step per Track 0 spec). User-original objectives from UP01-UP03 fully addressed.

Hand-off to S2: read `agent-workspace/memory/checkpoints/latest.md` for next-session resume context.

---

## Amendments — REV-3 (2026-04-29)

**Trigger**: UP-06 (`human-workspace/user_prompt/20260429_06.txt`) explicitly directs elevating "sync" to #1 priority + raises 3 strategic concerns (drift detection coverage, layer separation, self-upgrade Karpathy autoresearch loop).

**Authorization**: User via 2x `AskUserQuestion` (8 explicit picks total) 2026-04-29 — Round 1: Track 5.5 before Track 6 / 4 sync mechanisms multiSelect / Full multi-tenant initially / Aggressive Karpathy. Round 2: Layer→Sync→Self-Cap sequencing / Skip multi-tenant /attach only / OTEL+JSONL hybrid / Accept ~1.5-2M total budget.

**Source artifacts**:
- `human-workspace/user_prompt/20260429_06.txt` — UP-06 verbatim
- `agent-workspace/memory/decisions/003-up06-track-5.5-sync-layer-selfcap.md` — full Track 5.5 design
- `human-workspace/q-and-a/answered/2026-04-29-004-up06-track-5.5-amendment.md` — Q&A audit trail
- `agent-workspace/memory/agent-notes.md` § "2026-04-29 (UP-06) NO Silent File-Defaults" — doctrine basis

### A. NEW Track 5.5 — Sync + Layer + Self-Capability Foundation (between Track 5 and Track 6)

Detailed in D-003. Three sub-tracks executed sequentially:

| Sub-track | Title | Sessions | Budget |
|---|---|---|---|
| **5.5a** | Layer Foundation (manifest + restructure + /attach skill, NO multi-tenant) | S4 | ~150K |
| **5.5b** | Sync Infrastructure (intent-vs-impl-diff agent + sync-state.md + periodic grilling hook + sync Q&A template) | S5+S6 | ~300K |
| **5.5c** | Self-Capability + Karpathy Autoresearch Full (decompose-work skill + capability-map.md + try-n-approaches skill + OTEL stack + JSONL extension + promotion path) | S7+S8 | ~400K |

### B. Track 6 REWRITE (post-5.5)

Track 6 scope unchanged (Discipline Skills + Subagents Port + progressive-disclosure refactor of 24 LOC violations). Adjustment: skills/subagents now categorized via `manifest.yaml` (5.5a) and may move to `.claude/stockforge/` subtree. Budget reduced to ~150K (was ~200K) reflecting layer-aware scope.

### C. Track 9 Reduction (5.5c overlap)

Track 9 (Self-Awareness + OTEL) budget reduced to ~80K (was ~120K) since 5.5c absorbs OTEL stack setup + JSONL telemetry extension. Track 9 retained for live profile cards + aggregator hook + telemetry-analyst subagent (separate concerns).

### D. Revised Session Sequencing (was 9, now 14 sessions)

| # | Session | Tracks | Type | Budget |
|---|---|---|---|---|
| S1 (DONE) | Bootstrap kickoff | Track 0 + design refinement | FOCUSED_IMPL | ~210K main + 180K bg |
| S2 (DONE) | Workspace + provenance + intake + Q&A | Tracks 1, 2, 3, 4 | MULTI_TASK_IMPL | ~150K |
| S3 (DONE) | Loop-resilience hooks | Track 5 | FOCUSED_IMPL | ~120K |
| **S4 (NEXT)** | **Layer Foundation** | **Track 5.5a (manifest + restructure + /attach skill)** | **FOCUSED_IMPL** | **~150K** |
| S5 | Sync Part 1 | Track 5.5b.1+5.5b.2 (intent-vs-impl-diff agent + sync-state.md) | FOCUSED_IMPL | ~150K |
| S6 | Sync Part 2 | Track 5.5b.3+5.5b.4 (periodic grilling hook + sync Q&A template) | FOCUSED_IMPL | ~150K |
| S7 | Self-Cap Part 1 | Track 5.5c.1+5.5c.2+5.5c.6 (decompose-work + capability-map + promotion path) | FOCUSED_IMPL | ~200K |
| S8 | Self-Cap Part 2 | Track 5.5c.3+5.5c.4+5.5c.5 (try-n-approaches + OTEL stack + JSONL extension) | MULTI_TASK_IMPL | ~200K |
| S9 | Skills + subagents port REWRITE | Track 6 (layer-aware) | MULTI_TASK_IMPL | ~150K |
| S10 | Constitution + verifier | Track 7 + sandwich-verifier on prior Tracks | VERIFY+IMPL | ~150K |
| S11 | Confidence Score | Track 8a | FOCUSED_IMPL | ~120K |
| S12 | Memory L0/L1 extraction | Track 8b | FOCUSED_IMPL | ~120K |
| S13 | Self-Awareness | Track 9 (reduced) | FOCUSED_IMPL | ~80K |
| S14 | Final Phase 0 verifier | sandwich-verifier whole-Phase | VERIFY | ~80K |

Total: ~2.02M (was REV-2 ~1.3M; user accepted ~1.5-2M band).

### E. Confirmed User Decisions (Round 1 + Round 2 — 8 picks)

- **Q1 (Round 1)**: A — Track 5.5 before Track 6 (Recommended)
- **Q2 (Round 1)**: B+C+D+A multiSelect — All 4 sync mechanisms (intent-diff agent + sync-state + sync-Q&A template + periodic grilling)
- **Q3 (Round 1)**: C initially — Full /attach + multi-tenant (later refined)
- **Q4 (Round 1)**: C — Aggressive Karpathy autoresearch infrastructure
- **Q5 (Round 2)**: A — Layer→Sync→Self-Cap sequencing, REWRITE Track 6 post-5.5
- **Q6 (Round 2)**: D — SKIP multi-tenant; only `/attach` skill (refines Round 1 Q3)
- **Q7 (Round 2)**: B — OTEL+JSONL hybrid measurement stack
- **Q8 (Round 2)**: A — Accept ~1.5-2M total Phase 0 budget

### F. Closure Statement (REV-3)

REV-3 preserves Decision 002 scope (Phase 0 = Harness Bootstrap) but expands track count from 11 to 14 sub-tracks via Track 5.5 insertion. Budget delta ~+700K acknowledged by user. UP-06 directive "biến sync thành ưu tiên hàng đầu" addressed via 4-mechanism Sync infrastructure + intent-diff agent + periodic re-grilling.

Hand-off to S4: read `agent-workspace/memory/checkpoints/latest.md` (will be updated post-this-amendment) + `D-003` + `agent-workspace/session-plans/pending/002-track-5.5-sync-layer-selfcap.md`.
