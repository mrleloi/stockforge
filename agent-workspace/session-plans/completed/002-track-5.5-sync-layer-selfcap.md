# Track 5.5 — Sync + Layer + Self-Capability Foundation (Master Plan)

> **Filename**: `002-track-5.5-sync-layer-selfcap.md` (sibling to `001-port-from-orch.md`)
> **Status**: ACTIVE (NEXT — S4 starts here)
> **Source decision**: `agent-workspace/memory/decisions/003-up06-track-5.5-sync-layer-selfcap.md`
> **Amends**: `001-port-from-orch.md` § Session Sequencing (now 14 sessions, was 9)
> **Q&A audit**: `human-workspace/q-and-a/pending/2026-04-29-004-up06-track-5.5-amendment.md` (born-answered)

---

## Purpose

Per D-003: insert NEW Track 5.5 between Track 5 and Track 6, address UP-06 directive ("biến sync thành ưu tiên hàng đầu"). Three sub-tracks executed Layer→Sync→Self-Cap, then rewrite Track 6 layer-aware.

This file is the **executable session-plan view** for Track 5.5 specifically. D-003 is the **strategic rationale**.

---

## Track 5.5 Success Criteria (whole)

Track 5.5 is COMPLETE when ALL of these hold:

- [ ] **5.5a Layer**: `.claude/manifest.yaml` validates; harness/stockforge separation passes drift dry-run; `/attach` smoke-test succeeds on scratch dir
- [ ] **5.5b Sync (4 mechanisms)**:
  - [ ] `intent-vs-impl-diff` subagent dispatchable; produces drift-log on current state with ≤5 hard-drift items
  - [ ] `agent-workspace/memory/sync-state.md` populated with ≥20 confirmed/assumed/open entries
  - [ ] `sync-grilling-trigger.sh` hook fires correctly on dry-run (mock state >threshold)
  - [ ] `grill-maximization/references/sync-bundle-template.md` exists + tested with sample sync questions
- [ ] **5.5c Self-Cap (Karpathy full)**:
  - [x] `decompose-work` skill smoke-tests on real Phase 0 task with correct deterministic-vs-LLM split (DONE S8 + S9 dogfood)
  - [x] `capability-map.md` seeded with ≥10 entries from existing agent-notes (DONE S8 — 19 entries)
  - [ ] `try-n-approaches` skill smoke-tests with 3 parallel subagent dispatch on test case (S13)
  - [ ] OTEL stack: `docker-compose up` brings collector live + Python emitter pushes traces (S13)
  - [ ] JSONL extension: `component-telemetry.sh` writes new schema fields; sample run logged (S13)
  - [x] Promotion path: dry-run identifies ≥3 promotable agent-notes rules (DONE S8 — promote-rule shipped; threshold tuning continues)
- [ ] **5.5d Self-Learning Pipeline (UP-08; per D-005)**:
  - [ ] Data-boundary FS path `agent-workspace/learning-data/` with drift signal D9 enforcement (S10)
  - [ ] `component-telemetry.sh` extended to emit learning events to NDJSON queue; smoke-test parses (S10)
  - [ ] `learning-queue-sweeper.sh` rotates ≥1 sample event end-to-end on dry-run (S11)
  - [ ] `learning-index-rebuild.sh` produces queryable SQLite FTS5 index over ≥10 sample events (S11)
  - [ ] First L-1 classification dispatch categorizes ≥10 events (S11)
  - [ ] research-scanner agent-pick-1 dogfood produces ≥1 measurable insight (S12)
  - [ ] Karpathy outer-loop framing identifies next experiment with measurement plan (S12)
  - [ ] Promote-rule closes ≥1 feedback cycle from 5.5d data (S12)

---

## Session Breakdown (10 sessions S4-S13; UP-06 Track 5.5a/b/c + UP-08 Track 5.5d insertion)

| # | Session | Sub-track | Type | Budget | Status | Deliverables |
|---|---|---|---|---|---|---|
| S4-replan | Layer Foundation | **5.5a** | FOCUSED_IMPL | ~150K | ✅ DONE | manifest.yaml + tag-only stockforge layer + /attach skill |
| S5 | Sync Part 1 | **5.5b.1+5.5b.2** | FOCUSED_IMPL | ~150K | ✅ DONE | intent-vs-impl-diff agent + sync-state.md schema |
| S6 | Sync Part 2 | **5.5b.3+5.5b.4** | FOCUSED_IMPL | ~150K | ✅ DONE | sync-grilling-trigger hook + sync-bundle-template |
| S7 | (carry-overs) | **5.5b polish** | FOCUSED_IMPL | ~150K | ✅ DONE | sync-state populated; UP-07 D-004 |
| S8 | Self-Cap Part 1 | **5.5c.1+5.5c.2+5.5c.6** | FOCUSED_IMPL+ | ~150-180K | ✅ DONE | decompose-work skill + capability-map.md + promote-rule skill |
| S9 | UP-08 PLAN | **5.5d ratification** | PLAN | ~80-120K | ✅ DONE | D-005 (Track 5.5d insertion) + Q&A bundle 006 |
| **S10 NEXT** | **5.5d Boundary + Collection** | **5.5d.1** | FOCUSED_IMPL | ~120K | ⏭️ NEXT | learning-data/ FS path + telemetry hook extension + drift D9 |
| S11 | 5.5d Sweeper + Index | **5.5d.2** | FOCUSED_IMPL | ~150K | pending | queue-sweeper + index-rebuild hooks + first L-1 classification |
| S12 | 5.5d Karpathy + Dogfood | **5.5d.3** | FOCUSED_IMPL | ~150K | pending | research-scanner agent + agent-pick-1 dogfood + Karpathy framing |
| S13 | Self-Cap Part 2 | **5.5c.3+5.5c.4+5.5c.5** | MULTI_TASK_IMPL | ~220-250K | pending | try-n-approaches skill + OTEL stack + JSONL extension |

After S13 → S14 = Track 6 REWRITE (skills/subagents port layer-aware) per D-002 REV-3 § D + D-005 § Connection to existing plan.

---

## Sub-track Detail

### 5.5a — Layer Foundation (S4, ~150K)

**Goal**: Establish layer manifest + directory structure that separates harness (portable) from stockforge biz logic, enabling /attach skill to migrate harness alone to a new project.

**Deliverables**:
1. **`.claude/manifest.yaml`** — declares scope of every artifact:
   ```yaml
   version: 1
   layers:
     harness:                  # portable across projects
       - .claude/skills/qa-escalation/
       - .claude/skills/grill-maximization/
       - .claude/skills/write-a-skill/
       - .claude/skills/user-prompt-intake/
       - .claude/skills/ubiquitous-language/
       - .claude/skills/spec-dual-layer/
       - .claude/skills/test-pyramid-balance/
       - .claude/skills/ddd-tactical-patterns/
       - .claude/skills/prompt-engineering/
       - .claude/skills/obsidian-vault/
       - .claude/skills/spec-to-wiki/
       - .claude/skills/attach/   # NEW
       - .claude/agents/sandwich-architect.md
       - .claude/agents/sandwich-dev.md
       - .claude/agents/sandwich-verifier.md
       - .claude/agents/spec-author.md
       - .claude/agents/master-planner.md
       - .claude/agents/devils-advocate.md
       - .claude/agents/drift-detector.md
       - .claude/agents/intent-classifier.md
       - .claude/agents/ul-auditor.md
       - .claude/agents/bdd-planner.md
       - .claude/agents/action-guide-planner.md
       - .claude/commands/  (most are dual-use; final categorization in S4)
       - scripts/hooks/ (most are dual-use; categorize per file)
     stockforge:                # biz-specific; stays in fork
       - .claude/skills/evidence-extraction/
       - .claude/skills/postgres-pgvector/
       - .claude/skills/crawler-reliability/
       - .claude/skills/fastapi-module/
       - PROJECT_CHARTER.md
       - specs/
       - eval-sets/
       - obsidian-vault/
     hybrid:                    # parameterized by manifest swap
       - CLAUDE.md
     personal:                  # gitignored; user-tagged
       - .claude/personal/
   policies:
     attach_excludes:
       - .claude/stockforge/
       - .claude/personal/
       - PROJECT_CHARTER.md
       - obsidian-vault/
       - specs/
       - eval-sets/
       - agent-workspace/
       - human-workspace/
   ```
2. **Directory restructure**: move 4 stockforge-biz skills (`evidence-extraction`, `postgres-pgvector`, `crawler-reliability`, `fastapi-module`) from `.claude/skills/` to `.claude/stockforge/skills/`. Update Glob references in code/docs.
3. **`.claude/skills/attach/SKILL.md`** + `references/`:
   - Input: target project path + (optional) flags `--include-personal` / `--dry-run`
   - Reads manifest.yaml; copies harness layer (excluding stockforge + personal) to target
   - Writes new `CLAUDE.md` skeleton + manifest.yaml at target
   - Smoke-test: copy to scratch dir, verify skeleton functional
4. **`.gitignore`** extended for personal/ paths
5. **`.claude/settings.json`** permissions adjusted for new paths

**Risks**:
- Skill move breaks references → mitigation: grep for skill paths before move; sandwich-verifier dispatch on manifest before commit
- /attach overwrites target's existing CLAUDE.md → mitigation: --dry-run default; --force flag explicit

**Success**:
- manifest.yaml validates against schema (write schema validator inline)
- 4 stockforge-biz skills moved; SKILL.md cross-refs updated
- /attach smoke-test passes on scratch dir
- D1 drift-signal hook still passes (LOC ceilings respected)

---

### 5.5b — Sync Infrastructure (S5+S6, ~300K)

**Goal**: Build 4-mechanism sync ensemble per UP-06 directive #1.

#### 5.5b.1 — Intent-vs-Implementation Diff Agent (S5, ~80K)

**File**: `.claude/agents/intent-vs-impl-diff.md` (opus, fresh-context)

**Mandate**:
- Input: nothing (subagent reads files directly)
- Reads: all `human-workspace/user_prompt/*.txt` + all `agent-workspace/memory/decisions/*.md` + samples of current artifacts (skills, hooks, settings)
- Produces: `agent-workspace/memory/drift-logs/intent-impl-<TS>.md` with 3-tier classification
  - **aligned**: explicit user-stated intent matches current artifact
  - **drifted-soft**: intent partially addressed; gap exists but not contradicting
  - **drifted-hard**: artifact contradicts user intent (silent absorption / scope creep / direct violation)

**Dispatch triggers**:
- On-demand via `/intent-diff` command (NEW)
- Auto-dispatched at phase-boundary (post-Phase-0 verifier session)

#### 5.5b.2 — Sync-State Artifact (S5, ~70K)

**File**: `agent-workspace/memory/sync-state.md`

**Schema**:
```yaml
items:
  - id: sync-001
    statement: "Phase 0 = Harness Bootstrap, 11+5.5 tracks, supervised until Track 7"
    state: confirmed-aligned
    confirmed_at: 2026-04-29T16:30:00+07:00
    confirmation_via: AskUserQuestion (D-003 Round 1+2)
    related_decisions: [D-002, D-003]
  - id: sync-002
    statement: "..."
    state: assumed-aligned
    last_check: 2026-04-29
    assumption_basis: "agent inference from UP-02 §1.1 — never explicitly verified"
  - id: sync-003
    statement: "..."
    state: open-question
    queued_at: 2026-04-29
    queue_ref: queued-grill-master.md § Q-X
```

**Update sources**:
- Hook on `Write(human-workspace/q-and-a/answered/**)` → mark items confirmed
- Hook on intent-vs-impl-diff agent output → flag drifted items
- Manual entries via `/sync-add` command (NEW, lightweight)

#### 5.5b.3 — Periodic Sync-Grilling Hook (S6, ~70K)

**File**: `scripts/hooks/sync-grilling-trigger.sh` (SessionStart hook)

**Behavior**:
- Read `last_sync_check` from `.session-hooks.log` or sync-state.md
- If elapsed sessions ≥ `STOCKFORGE_SYNC_GRILL_INTERVAL_SESSIONS` (default 3) OR elapsed days ≥ `STOCKFORGE_SYNC_GRILL_INTERVAL_DAYS` (default 7) → emit notification "sync-grilling due; agent should fire AskUserQuestion sync-check"
- Do NOT auto-fire AskUserQuestion (per UP-05 — Skill/Ask tool autonomous-mode policy: only SUPERVISED mode fires)

**Settings.json wiring**: add to `hooks.SessionStart` array

#### 5.5b.4 — Sync-Specialized Q&A Template (S6, ~80K)

**File**: `.claude/skills/grill-maximization/references/sync-bundle-template.md`

**Differs from feature/scope grill**:
- Questions phrased as "do we still understand X the same way?" not "what should we do?"
- Each question references `sync-state.md` item ID
- Multi-batch protocol: 4 questions per Ask call
- Output: updates sync-state.md item states (confirmed/assumed/open transitions)

**Pairs with grill-maximization SKILL.md**: add new section "Sync Bundle Composition" pointing to this template.

---

### 5.5c — Self-Capability + Karpathy Autoresearch Full (S7+S8, ~400K)

**Goal**: Build full Karpathy autoresearch loop infrastructure per UP-06 §3.

#### 5.5c.1 — `decompose-work` Skill (S7, ~80K)

**File**: `.claude/skills/decompose-work/SKILL.md` + `references/`

**Mandate**:
- Input: free-form task description
- Output: structured analysis
  - **Deterministic portions**: list of sub-tasks doable via script/hook/code (no LLM judgment)
  - **LLM-required portions**: sub-tasks requiring reasoning, creativity, judgment
  - **Integration plan**: how the portions combine (sequence, data flow, escalation rules)

**Reads `capability-map.md`** at decomposition time to ground "what LLM is good at vs not".

#### 5.5c.2 — `capability-map.md` (S7, ~40K)

**File**: `agent-workspace/memory/capability-map.md`

**Living document, sparse cells**:
```yaml
dimensions:
  - model: [opus-4.7, sonnet-4.6, haiku-4.5]
  - effort: [low, medium, high, xhigh, max]
  - task_class: [refactor, design, verification, extraction, synthesis, calibration, ...]
strengths_observed:
  - {model: opus-4.7, task_class: design, effort: high, observation: "...", source: agent-notes-YYYY-MM-DD}
limits_observed:
  - {model: opus-4.7, task_class: math, observation: "I-S1: NO LLM math; deterministic always", source: charter}
```

**Seeded from**:
- existing agent-notes.md entries (clustered by similar pattern)
- Track 0 patterns-discovered/SYNTHESIS.md anti-pattern list
- post-mortems (when they exist)

#### 5.5c.6 — Promotion Path (S7, ~80K)

**File**: `.claude/skills/promote-rule/SKILL.md` (or hybrid hook+agent)

**Mandate**:
- Periodic: scan `agent-notes.md`; cluster similar entries (semantic similarity ≥0.7)
- Cluster of ≥3 similar → propose promotion to skill/hook/constitution
- Priority per Q-E3 (queued-grill-master): hook FIRST, skill SECOND, charter LAST
- Output: proposal in `agent-workspace/memory/observations/promotion-proposals-<TS>.md`

#### 5.5c.3 — `try-n-approaches` Skill (S8, ~80K)

**File**: `.claude/skills/try-n-approaches/SKILL.md`

**Pattern**:
- Given a task + N (default 3)
- Generate N distinct approaches (different framings, tools, decompositions)
- Dispatch N subagents in parallel (`run_in_background: true`)
- Each approach has measurement metric defined upfront
- Compare results → select best → loop-deepen with refined understanding

**Horizontal scaling**: parallel approach exploration
**Vertical scaling**: loop-deepen the best approach

#### 5.5c.4 — OTEL Stack (S8, ~70K)

**Files**:
- `docker/otel-stack/docker-compose.yml` (single-container `grafana/otel-lgtm:1.4.0` per Q-S4 confirm)
- `docker/otel-stack/otel-collector-config.yaml`
- `packages/observability/otel_emitter.py` (instrumented Python emitter)

**Per D-002 REV-2 § amendment**: 3 files copy-verbatim from orch reference; adapt env var prefix.

**Smoke-test**: `docker-compose up` → emit sample trace from Python → verify in collector.

#### 5.5c.5 — JSONL Telemetry Schema Extension (S8, ~50K)

**File**: extend `scripts/hooks/component-telemetry.sh`

**Schema additions**:
```jsonl
{"event": "task_decompose", "task_id": "...", "approach_count": 3, "task_class": "..."}
{"event": "approach_metric", "task_id": "...", "approach_id": "...", "metric": "tokens_used", "value": 12340}
{"event": "approach_outcome", "task_id": "...", "approach_id": "...", "outcome": "succeeded|failed|partial", "evidence": "..."}
```

**Schema doc**: `agent-workspace/memory/self-awareness/jsonl-schema.md`

---

### 5.5d — Self-Learning Pipeline (S10+S11+S12, ~420K) — NEW per D-005 / UP-08

> **Source decision**: `agent-workspace/memory/decisions/005-up08-track-5.5d-self-learning-pipeline.md`
> **Q&A audit**: `human-workspace/q-and-a/pending/2026-04-29-006-up08-self-learning-pipeline.md` (5 picks across 2 AskUserQuestion rounds)
> **Decomposition**: `agent-workspace/memory/observations/decompose-work-up08-S9.md`
> **Why**: UP-08 frames self-learning/upgrade as **write-heavy data-ETL discipline** distinct from runtime read-heavy pipeline. Calls for queue+event-driven background processing, isolated data stores, harness-engineering-as-backend-engineering. 5.5c primitives (decompose-work + capability-map + promote-rule) shipped S8 are **necessary but not sufficient** — 5.5d adds boundary + queue + index + outer loop infrastructure.

**Goals (whole 5.5d)**:
1. Establish **data-boundary** discipline: separate FS path `agent-workspace/learning-data/` (write-only); drift signal D9 prevents runtime read-path leak; future Postgres `learning_*` schema namespace
2. Build **collection layer**: extend existing `component-telemetry.sh` to emit learning events as NDJSON to queue file; cron-via-hook trigger pattern (matches Track 5 + 5.5c.5 + S8 correction-rate-aggregator)
3. Build **processing layer**: queue rotation/retention sweeper + RAG index rebuild trigger; first L-1 classification of event corpus into improvement categories
4. Build **outer loop**: Karpathy autoresearch framing + opensource agent-pick-1 dogfood (research-scanner subagent); first feedback closing loop into agent-notes / capability-map / promote-rule

**Sub-tracks (3 sessions)**:

#### 5.5d.1 — Boundary + Collection Foundation (S10, ~120K)
- Author `agent-workspace/learning-data/README.md` documenting boundary discipline
- Create dir tree: `learning-data/{events/, index/, archive/, dogfood/, loop/}` with `.gitkeep`
- Extend `.gitignore` for `learning-data/events/` + `archive/` (gitignored); track `index/` optionally
- Extend `scripts/hooks/component-telemetry.sh` (+15-30 LOC): emit learning event line to `learning-data/events/YYYY-MM-DD.ndjson` after existing telemetry block
- Add **D9 drift signal** to `scripts/hooks/drift-signals-D1-D8.sh` → rename `drift-signals-D1-D9.sh` (+25 LOC + caller updates): flags any runtime read-path code that loads `learning-data/`
- Update `.claude/settings.json` permissions: deny direct read of `learning-data/events/` from main session (write-only via hook); allow `learning-data/index/` read (RAG query path)

**Success**: `learning-data/` tree exists with permissions + drift detection; `component-telemetry.sh` smoke-test emits parseable NDJSON learning event; D9 detects 0 violations on current codebase (boundary clean from start); `git check-ignore agent-workspace/learning-data/events/test.ndjson` returns PASS.

#### 5.5d.2 — Sweeper + Index + First Analysis (S11, ~150K)
- Author `scripts/hooks/learning-queue-sweeper.sh` (~80 LOC): rotate >7-day events to `archive/`; delete >30-day archive; size guards
- Author `scripts/hooks/learning-index-rebuild.sh` (~60-100 LOC): when N events queued (deterministic threshold) → rebuild SQLite FTS5 index over event NDJSON (Phase 0; pgvector Phase 1+)
- Wire both hooks: sweeper to SessionStart hook (cron-style); index-rebuild to Stop hook with event-count gate
- Background-dispatch trigger rule (H-2): event-count ≥100 OR session-count ≥5 since last analysis → emit notification "background analysis ready"
- First **L-1 classification** dispatch: classify event corpus into improvement categories (drift / retry / mistake-type / promotion-candidate). Use sonnet medium effort (capability-map row #5 grounded)
- Output: `agent-workspace/memory/learning-data/index/categories-<TS>.md` (deterministic-first index; LLM-classification appended)

**Success**: sweeper rotates ≥1 sample event end-to-end on dry-run; index produces queryable SQLite FTS5 db with ≥10 sample events indexed; first L-1 classification structured per template.

#### 5.5d.3 — Karpathy Outer Loop + Agent-Pick-1 Opensource Dogfood (S12, ~150K)
- Author `.claude/agents/research-scanner.md` (or reuse if shipped earlier): subagent reads README + recent commits of opensource repos and reports fit-for-stockforge with provenance
- **Agent-pick-1 dogfood**: pick the single most-aligned opensource self-learning/Karpathy/autoresearch repo (candidates: DSPy, LangSmith, llm.c-style autoresearch, openai/swarm, or other emerging). Selection criterion: maximally aligned with stockforge's "harness self-learning from sessions/agent-notes/mistake-log" use case
- Dogfood the picked tool: integrate enough to produce 1 measurable insight; document in `agent-workspace/memory/learning-data/dogfood/<tool>.md`
- L-3 **Karpathy outer loop framing**: given dogfood + 5.5d.2 first-analysis output, frame next experiment (deepen/broaden/abandon? what measurement?). Use `try-n-approaches` skill if shipped in S13 ahead of S12; else inline framing in S12
- **Promotion path closure**: surface ≥1 promotable agent-notes rule from the dogfood loop (closes first cycle of capability-map → promote-rule → 5.5d feedback)

**Success**: research-scanner produces ≤5-page report with provenance; dogfood produces ≥1 measurable insight; Karpathy framing identifies next experiment with explicit measurement plan; promote-rule run identifies ≥1 candidate from new agent-notes.

---

## After Track 5.5 → S13 = 5.5c.3+4+5 → S14 = Track 6 REWRITE

Sequence after 5.5d closure (per D-005 § Connection to existing plan):
- **S13** (was S10 pre-UP-08): 5.5c.3+4+5 — try-n-approaches + OTEL stack + JSONL extension (~220-250K)
- **S14** (was S11): Track 6 REWRITE — Discipline Skills + Subagents Port + progressive-disclosure refactor; layer-aware via 5.5a manifest
- **S15+**: Track 7 constitution → Track 8a Confidence → Track 8b Memory → Track 9 Self-Awareness → Final verifier

Track 6 detail: see `agent-workspace/memory/decisions/002-phase-0-harness-bootstrap-design.md` § Track Specifications + REV-2 § B Track-by-Track Amendments.

---

## Risks (whole Track 5.5)

| ID | Risk | Mitigation |
|---|---|---|
| T5.5-R1 | 5.5a manifest gets categorization wrong → Track 6 refactor cost | Smoke-test /attach BEFORE moving production skills; sandwich-verifier dispatch on manifest before S5 starts |
| T5.5-R2 | 5.5b intent-diff agent produces noise (false drift) | Tune threshold via initial dry-run on current state; require ≥0.7 confidence in drift classification |
| T5.5-R3 | 5.5b periodic grilling annoys user | Configurable threshold; default 3 sessions / 7 days; explicit "sync now" override |
| T5.5-R4 | 5.5c.4 OTEL setup fails on Windows / docker version mismatch | Verify orch-starter's setup works on stockforge env first; fallback to JSONL-only if blocked |
| T5.5-R5 | Self-cap measurement adds tool overhead per task → context bloat | Sample only; measurement opt-in via skill flag; default OFF for trivial tasks |
| T5.5-R6 | Total budget overshoots ~2M | Per-session budget watchdog (Track 5 hook) + checkpoint after each sub-track; descope OTEL to design-doc if 5.5c overshoots |
| T5.5-R7 | Multi-tenant skip creates regret | Documented escape hatch — git-fork single-tenant remains valid; revisit if peer-share materializes |
| T5.5-R8 | Track 9 self-awareness overlap with 5.5c → duplicate work | Track 9 budget reduced to ~80K; retains live profile cards + aggregator hook (separate concerns) |

---

## Pre-flight for S4 (Track 5.5a entry)

1. Read `agent-workspace/memory/checkpoints/latest.md` (will be updated at end of S4-reshape session)
2. Read this file (002-track-5.5-sync-layer-selfcap.md) § 5.5a
3. Read `agent-workspace/memory/decisions/003-up06-track-5.5-sync-layer-selfcap.md` § 5.5a Layer Foundation
4. Run inventory: `wc -l .claude/skills/*/SKILL.md` to confirm post-restructure D1 drift status
5. Begin 5.5a tasks per § 5.5a above

Estimated S4 SessionStart load: ~30-40K tokens.

---

## Open Items / Deferred to Phase 1+

(Unchanged from 001-port-from-orch.md)
- F (Sync ladder full formalization)
- G (Obsidian wiki visualization full)
- H (Deep pattern mining / self-evolution loop)
- Telegram/Slack bot
- Worker mailbox / multi-project queue (out of scope per Identity NOT-list)
- Multi-tenancy (Phase 6+ only with re-charter; UP-06 Q6=D confirmed skip)
