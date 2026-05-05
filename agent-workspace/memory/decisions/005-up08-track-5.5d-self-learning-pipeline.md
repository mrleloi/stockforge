---
id: D-005-up08-track-5.5d-self-learning-pipeline
title: "UP-08 Track 5.5d Insertion — Self-Learning Pipeline as Write-Heavy Data-ETL Discipline"
date: 2026-04-29
status: ACCEPTED
level: SCOPE
author:
  - "Claude Opus 4.7"
  - "user"

source_evidence:
  - path: human-workspace/user_prompt/20260429_08.txt
    quote: |
      "self-learning/upgrade lại nặng về bài toán 'write', 'index', 'cache', nơi mà thu thập càng nhiều dữ liệu... với chi phí rẻ nhất mà không làm ảnh hưởng tới runtime"
      "thêm sớm vào plan để có đủ data đo lường, tracking từ sớm"
      "việc cô lập và tách biệt các kho data này phải được thiết kế từ đầu, coi harnessing engineering giống như backend engineering/data etl"
      "hoàn toàn có thể tiếp cận theo hướng queue-based và event-driven"
      "kết hợp với idea của karpathy autoresearch, các repo opensource trending và hiệu quả trên github"
  - path: agent-workspace/memory/observations/decompose-work-up08-S9.md
    section: "Decomposition (5 deterministic / 4 LLM / 2 hybrid) + Integration plan + Recommendation"
  - path: human-workspace/q-and-a/pending/2026-04-29-006-up08-self-learning-pipeline.md
    section: "AskUserQuestion Round 1 + Round 2 — 5 explicit picks (Q1-Q5 all Recommended)"
  - path: agent-workspace/memory/decisions/003-up06-track-5.5-sync-layer-selfcap.md
    section: "Existing Track 5.5 architecture (this decision adds 5.5d alongside 5.5a/b/c)"
  - path: PROJECT_CHARTER.md
    section: "Principle 4 (proprietary data moat) + Principle 7 (dogfood mandatory) — UP-08 strengthens both"

intent_classification:
  primary_intent: SCOPE
  affects_charter: false
  affects_scope: true
  urgency: HIGH
  complexity_score: 80

options_considered:
  # Composite SCOPE-tier picks across 5 questions; each AskUserQuestion option is a sub-option.
  - id: Q1-A
    summary: "Track 5.5d new (parallel to 5.5a/b/c, before Track 6)"
    pros: ["Reuse 5.5c primitives shipped S8 cleanly", "Match 5.5 sub-track sequencing pattern", "Clean ownership boundary"]
    cons: ["Budget +420K", "3 sub-sessions before Track 6 resumes (now S13+ instead of S10+)"]
  - id: Q1-B
    summary: "5.5c amendment (extend self-cap)"
    pros: ["No new track number"]
    cons: ["Muddy completed scope (5.5c.1+2+6 already shipped S8)", "Conflate 2 disciplines"]
  - id: Q1-C
    summary: "Track 9 re-elevation"
    pros: ["No new track"]
    cons: ["Walks back REV-2 reduction", "Track 9 better reserved for live profile-cards"]
  - id: Q1-D
    summary: "Phase 1 defer"
    pros: ["No Phase 0 budget impact"]
    cons: ["Loses 'thêm sớm' directive", "Harness self-learning data flows ALREADY in Phase 0 (sessions, agent-notes, mistake-log)"]

  - id: Q2-A
    summary: "Separate FS path + drift signal D9"
    pros: ["Hardest enforcement; deterministic boundary", "Match UP-08 verbatim 'thiết kế từ đầu'"]
    cons: ["Adds 1 new path tree + 1 new drift signal"]
  - id: Q2-B
    summary: "Namespace + tagging within existing"
    pros: ["Lightweight"]
    cons: ["Convention not enforcement; agent can accidentally load (S2 drift audit failure mode)"]
  - id: Q2-C
    summary: "Process isolation"
    pros: ["OS-level boundary"]
    cons: ["Over-engineers Phase 0 (no Redis yet); save for Phase 1+"]
  - id: Q2-D
    summary: "Docs-only convention"
    pros: ["Zero code change"]
    cons: ["Weakest enforcement; relies on agent discipline (proven unreliable)"]

  - id: Q3-A
    summary: "NDJSON queue + cron-via-hook"
    pros: ["Extends existing harness pattern (Track 5 hooks, 5.5c.5 telemetry, S8 correction-rate-aggregator)", "Deterministic + cheap"]
    cons: ["Won't scale to >100K events/day; migrate to Redis Phase 1+ if signal warrants"]
  - id: Q3-B
    summary: "Redis pub-sub"
    pros: ["Proper queue infra"]
    cons: ["Redis not provisioned Phase 0; introduces dependency"]
  - id: Q3-C
    summary: "OTEL collector pipeline"
    pros: ["Reuse 5.5c.4 stack"]
    cons: ["OTEL is for traces, not durable queue; conflates concerns"]
  - id: Q3-D
    summary: "Defer impl"
    pros: ["Zero immediate cost"]
    cons: ["Loses early measurement signal"]

  - id: Q4-A
    summary: "Broad scan via research-scanner"
    pros: ["Comprehensive coverage"]
    cons: ["~2-3 dispatches × 80-120K = 250-360K budget; scope creep"]
  - id: Q4-B
    summary: "Narrow 2-3 user-specified"
    pros: ["Bounded; user-driven"]
    cons: ["Requires user to know candidates upfront"]
  - id: Q4-C
    summary: "Agent-pick-1 + dogfood"
    pros: ["Bounded budget ~120-150K", "Cheap-first ordering doctrine", "Broaden later if signal good"]
    cons: ["Single-point bet — risk picking wrong tool first"]
  - id: Q4-D
    summary: "Defer to Phase 1+"
    pros: ["Zero immediate cost"]
    cons: ["Loses UP-08 §3 verbatim opensource integration directive"]

  - id: Q5-A
    summary: "Accept ~2.44M total Phase 0 budget"
    pros: ["Honor UP-08 'thêm sớm' directive", "Under L-8 25% trigger (22-23% delta)", "Track 9 reduction partly offsets"]
    cons: ["~22-23% over upper-end of original 1.5-2M accepted cap"]
  - id: Q5-B
    summary: "Cap 5.5d at ~270K (defer 5.5d.3)"
    pros: ["Stays under 2.5M soft-ceiling"]
    cons: ["Conflicts with Q4=C agent-pick-1 + dogfood pick (would need re-do)"]
  - id: Q5-C
    summary: "Descope Track 9 to 0K"
    pros: ["Save 80K"]
    cons: ["Live profile-cards lose coverage"]
  - id: Q5-D
    summary: "Re-plan whole sequence"
    pros: ["Clean restart"]
    cons: ["1-2 sessions re-planning overhead; delays Track 6+7+8"]

chosen: "Q1=A + Q2=A + Q3=A + Q4=C + Q5=A — Track 5.5d NEW (parallel to 5.5a/b/c) + Separate FS path + drift D9 + NDJSON queue + cron-via-hook + Agent-pick-1 opensource dogfood + Accept ~2.44M total Phase 0 budget"

chosen_rationale: |
  All 5 picks are user-Recommended-option-accepted via 2 rounds of AskUserQuestion (Round 1: 4 SCOPE
  questions on slot/boundary/tech/research-scope; Round 2: 1 budget acceptance question). Per UP-06
  NO Silent File-Defaults + UP-04 AskUserQuestion-PRIMARY doctrines, no defaults absorbed; every
  SCOPE-tier choice has an explicit user pick.

  Track 5.5d as NEW sub-track (Q1=A) is the cleanest insertion: it parallels existing 5.5a/b/c
  sequencing pattern, reuses 5.5c primitives shipped S8 (decompose-work + capability-map +
  promote-rule + correction-rate-aggregator pattern + JSONL telemetry topology), and keeps
  ownership boundaries clean. Alternatives B/C amend completed scope or walk back REV-2 reductions.

  Separate FS path + drift signal D9 (Q2=A) is the hardest enforceable boundary, matching UP-08
  verbatim "thiết kế từ đầu". Without D9, runtime path leak into write-heavy stores becomes a
  silent failure mode (akin to S2 drift audit pattern).

  NDJSON queue + cron-via-hook (Q3=A) extends the existing harness pattern (Track 5 hooks +
  5.5c.5 component-telemetry + S8 correction-rate-aggregator) with no new infra. Defers
  Redis dependency to Phase 1+ where stockforge already provisions it for stock-data caching.

  Agent-pick-1 + dogfood (Q4=C) bounds research budget at ~120-150K vs 250-360K for broad scan;
  honors UP-08 §3 opensource integration directive without scope-creep; broadens later if
  the dogfood signals genuine fit.

  Accept ~2.44M Phase 0 budget (Q5=A): delta is +22-23% over upper-end of 1.5-2M cap; under
  L-8 25% trigger but flagged with explicit Delta Summary in this frontmatter (per L-8 limit);
  Track 9 reduction (120→80K) partly offsets via 5.5d.3 absorbing Karpathy autoresearch portion.

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-04-29T18:00:00Z
    via: "decompose-work skill dogfood (S9 PLAN) + Q&A bundle 006 authoring"
  - actor: agent
    action: ASKED-ROUND-1
    at: 2026-04-29T18:05:00Z
    via: "AskUserQuestion 4-question round 1 (slot/boundary/tech/research-scope)"
  - actor: user
    action: ACCEPTED-ROUND-1
    at: 2026-04-29T18:05:00Z
    via: "AskUserQuestion picks: Q1=A (Track 5.5d new) | Q2=A (Separate FS + D9) | Q3=A (NDJSON + cron) | Q4=C (Agent-pick-1 + dogfood) — all Recommended option"
  - actor: agent
    action: ASKED-ROUND-2
    at: 2026-04-29T18:10:00Z
    via: "AskUserQuestion 1-question round 2 (budget envelope; triggered by ~22-23% delta + L-8 capability-map limit)"
  - actor: user
    action: ACCEPTED-FINAL
    at: 2026-04-29T18:10:00Z
    via: "AskUserQuestion pick: Q5=A (Accept ~2.44M) — Recommended option"

verified_by:
  - mechanism: askuserquestion-explicit-pick
    at: 2026-04-29
    result: PASS
    notes: "5 explicit picks across 2 AskUserQuestion rounds; no defaults absorbed; UP-06 NO Silent File-Defaults + UP-04 AskUserQuestion-PRIMARY both respected. Bundle 006 = audit trail."

affects:
  charter: false
  spec_files: []
  code_paths:
    - "agent-workspace/learning-data/**"                  # NEW (5.5d.1) write-only path
    - "agent-workspace/learning-data/README.md"           # NEW (5.5d.1) boundary doc
    - "agent-workspace/learning-data/events/**"           # NEW (5.5d.1) NDJSON event stream
    - ".gitignore"                                        # MODIFIED (5.5d.1) learning-data exclusions
    - "scripts/hooks/component-telemetry.sh"              # MODIFIED (5.5d.1) emit learning events
    - "scripts/hooks/learning-queue-sweeper.sh"           # NEW (5.5d.2) rotation + retention
    - "scripts/hooks/learning-index-rebuild.sh"           # NEW (5.5d.2) index trigger
    - "scripts/hooks/drift-signals-D1-D8.sh"              # MODIFIED (5.5d.1) add D9 = runtime-path-leak (effectively D1-D9)
    - ".claude/agents/research-scanner.md"                # NEW (5.5d.3) opensource-tool dogfood agent
    - "agent-workspace/memory/learning-data/index/**"     # NEW (5.5d.2) RAG index files (SQLite FTS Phase 0; pgvector Phase 1+)
  config_files:
    - ".claude/settings.json"                             # hooks block + permissions for learning-data path
  other_decisions:
    - D-003                                               # AMENDED via REV-3 entry pointing here

depends_on:
  - D-003                                                 # Track 5.5 master amendment that this extends
  - "5.5c primitives shipped S8: decompose-work + capability-map + promote-rule"
  - "5.5c.5 JSONL telemetry topology (component-telemetry.sh existing)"
  - "S8 correction-rate-aggregator pattern (cron-via-Stop-hook reference)"

supersedes: null
superseded_by: null

defer_cycles: 0
re_attempt_prereq: "N/A — Track 5.5d.1 starts S10 (after current S9 PLAN close)."

tags: ["phase-0", "track-5.5d", "self-learning", "data-etl", "write-heavy", "queue", "boundary", "drift-d9", "scope-amendment", "up-08", "karpathy-autoresearch", "opensource-dogfood"]

delta_summary:
  trigger: "L-8 capability-map limit — REV-N with ≥10 amendments OR ≥25% budget delta needs explicit Delta Summary. UP-08 delta = +22-23% (under 25% trigger, but material; surfaced explicitly per UP-06 NO Silent File-Defaults)."
  budget_before: "~2.02M (D-003 REV-2)"
  budget_after: "~2.44M (D-005 REV-3 = D-003 + 5.5d ~420K)"
  delta_percent: "+22-23%"
  delta_absolute: "+~420K"
  user_acceptance: "AskUserQuestion Round 2 Q5=A explicit pick at 2026-04-29T18:10:00Z"
---

# Decision 005 — UP-08 Track 5.5d Insertion: Self-Learning Pipeline as Write-Heavy Data-ETL

> **Status**: ACCEPTED 2026-04-29 via 5 explicit AskUserQuestion picks (4 SCOPE Round 1 + 1 budget Round 2).
> **Extends**: D-003 (Track 5.5 master amendment) by adding sibling sub-track 5.5d alongside 5.5a/b/c.
> **Q&A audit**: `human-workspace/q-and-a/pending/2026-04-29-006-up08-self-learning-pipeline.md`.
> **Decomposition**: `agent-workspace/memory/observations/decompose-work-up08-S9.md`.

---

## Context

UP-08 (`human-workspace/user_prompt/20260429_08.txt`) raises a foundational distinction the existing
plan didn't articulate: **runtime is read-heavy + reasoning + delegating; self-learning/upgrade is
write-heavy + indexing + caching**. They are different disciplines with different data shapes,
different cost profiles, and different boundaries. Conflating them in shared storage causes runtime
to load write-only data accidentally (size + irrelevance penalty).

User-provided framing: **"harness engineering = backend engineering / data ETL"**. This reframes
self-learning from a feature into a sub-system with its own boundary, queue topology, indexing
strategy, and background-processing rules.

### Audit at decision time (S9 PLAN, post-S8 close)

**5.5c primitives shipped S8 (DONE — necessary but not sufficient for UP-08)**:
- `decompose-work` skill (deterministic vs LLM split)
- `capability-map.md` (model × effort × task_class grounding)
- `promote-rule` skill (agent-notes → hook/skill/charter promotion path)
- `correction-rate-aggregator.sh` (cron-via-Stop-hook digest pattern)
- 5.5c.5 JSONL telemetry (component-telemetry.sh — pattern to extend)
- S8 capability-map L-1..L-12 (limits to respect, esp. L-1 NO LLM math + L-3 verification)

**Missing from 5.5c (to ship in 5.5d)**:
- Data-boundary discipline (separate FS path + drift signal D9)
- Queue rotation + retention infrastructure (sweeper hook)
- Index rebuild trigger (RAG-style query target — SQLite FTS Phase 0; pgvector Phase 1+)
- Periodic background-dispatch rule (event-count or N-session threshold)
- Karpathy outer loop framing (try-n-approaches consumer; first dogfood)
- Opensource-tool research arm (research-scanner agent-pick-1 + dogfood)

---

## Decision

**Insert Track 5.5d as new sub-track parallel to 5.5a/b/c, executed across 3 sub-sessions
(5.5d.1 + 5.5d.2 + 5.5d.3) in S10/S11/S12, before remaining 5.5c.3+4+5 (now S13) and Track 6
REWRITE (now S14).**

### Sub-track 5.5d.1 — Boundary + Collection Foundation (~120K, 1 session = S10)

**Goals**:
- Define data-boundary FS layout: `agent-workspace/learning-data/` (write-only), with subdirs `events/` (NDJSON), `index/` (RAG), `archive/` (rotated).
- Author `agent-workspace/learning-data/README.md` documenting boundary discipline (read path MUST NOT load this tree).
- Extend `.gitignore` for `learning-data/` (events/archive gitignored; index/ tracked optionally).
- Extend `scripts/hooks/component-telemetry.sh` to emit learning events to `learning-data/events/YYYY-MM-DD.ndjson` (append-only NDJSON).
- Add D9 drift signal to `scripts/hooks/drift-signals-D1-D8.sh` (rename to D1-D9): flags any runtime read-path code that loads `learning-data/`.
- `.claude/settings.json` permissions: deny direct read of `learning-data/events/` from main session (write-only via hook); allow `learning-data/index/` read (RAG query path).

**Files affected**:
- NEW `agent-workspace/learning-data/README.md`
- NEW `agent-workspace/learning-data/.gitkeep` files for events/index/archive subdirs
- MODIFIED `.gitignore` (+5 lines)
- MODIFIED `scripts/hooks/component-telemetry.sh` (+15-30 LOC: emit learning event after existing telemetry block)
- MODIFIED `scripts/hooks/drift-signals-D1-D8.sh` → renamed `drift-signals-D1-D9.sh` (+25 LOC: D9 runtime-path-leak signal + script rename + caller updates)
- MODIFIED `.claude/settings.json` (permissions block)

**Success**:
- `learning-data/` tree exists; permissions block runtime read of `events/`
- `component-telemetry.sh` smoke-test emits learning event line; NDJSON parses
- D9 drift signal detects 0 violations on current codebase (boundary clean from start)
- `git check-ignore agent-workspace/learning-data/events/test.ndjson` returns PASS

### Sub-track 5.5d.2 — Sweeper + Index + First Analysis (~150K, 1 session = S11)

**Goals**:
- Author `scripts/hooks/learning-queue-sweeper.sh` (~80 LOC): rotate >7-day events to `archive/`; delete >30-day archive; enforce size guards.
- Author `scripts/hooks/learning-index-rebuild.sh` (~60-100 LOC): when N events queued (deterministic threshold) → rebuild index. Phase 0: SQLite FTS5 on event NDJSON. Phase 1+: swap to pgvector with embedding emitter.
- Wire both hooks: `learning-queue-sweeper.sh` to SessionStart hook (cron-style); `learning-index-rebuild.sh` to Stop hook with event-count gate.
- Background-dispatch trigger rule (H-2 from decomposition): event-count threshold (≥100 events) OR session-count threshold (≥5 sessions since last analysis) → emit notification "background analysis ready; agent fires next turn".
- First L-1 dispatch: classify event corpus into improvement categories (drift / retry / mistake-type / promotion-candidate). Use sonnet medium effort (capability-map row #5 grounded).
- Output: `agent-workspace/memory/learning-data/index/categories-<TS>.md` (deterministic-first index; LLM-classification appended).

**Files affected**:
- NEW `scripts/hooks/learning-queue-sweeper.sh`
- NEW `scripts/hooks/learning-index-rebuild.sh`
- MODIFIED `.claude/settings.json` (hooks block: SessionStart + Stop additions)
- NEW `agent-workspace/memory/learning-data/index/categories-<TS>.md` (first analysis output)

**Success**:
- Sweeper rotates ≥1 sample event end-to-end on dry-run
- Index rebuild produces queryable SQLite FTS5 db with ≥10 sample events indexed
- First L-1 classification run categorizes ≥10 sample events; output structured per template
- Background-dispatch trigger fires correctly on dry-run with mock 100-event state

### Sub-track 5.5d.3 — Karpathy Outer Loop + Opensource Agent-Pick-1 Dogfood (~150K, 1 session = S12)

**Goals**:
- Author `.claude/agents/research-scanner.md` (or reuse existing if shipped earlier in 5.5b/c): subagent that reads README + recent commits of opensource repos and reports fit-for-stockforge with provenance.
- Agent-pick-1 dogfood: pick the single most-aligned opensource self-learning/Karpathy/autoresearch repo (candidates: DSPy, LangSmith, llm.c-style autoresearch, openai/swarm, or other emerging). Selection criterion: maximally aligned with stockforge's "harness self-learning from sessions/agent-notes/mistake-log" use case.
- Dogfood the picked tool: integrate enough to produce 1 measurable insight (e.g., "X agent-notes cluster pattern was missed by promote-rule but flagged by tool Y"); document insight in `agent-workspace/memory/learning-data/dogfood/<tool>.md`.
- L-3 Karpathy outer loop framing: given dogfood data + 5.5d.2 first-analysis output, frame next experiment (deepen/broaden/abandon? what measurement?). Use `try-n-approaches` skill (5.5c.3 — to be shipped S13; if not shipped, inline framing).
- Promotion path: surface ≥1 promotable agent-notes rule from the dogfood loop (closing first cycle of cap-map → promote-rule → capability-map → 5.5d feedback).

**Files affected**:
- NEW `.claude/agents/research-scanner.md` (if not already shipped)
- NEW `agent-workspace/memory/learning-data/dogfood/<picked-tool>.md` (insight artifact)
- NEW `agent-workspace/memory/learning-data/loop/<TS>-experiment-frame.md` (Karpathy framing)
- POTENTIALLY MODIFIED `agent-workspace/memory/agent-notes.md` (+1 entry from dogfood loop closure)
- POTENTIALLY MODIFIED `agent-workspace/memory/capability-map.md` (+1 cell per UP-08 task_class proposal e.g. `tool-survey`)

**Success**:
- research-scanner dispatch produces ≤5-page report on agent-pick-1 with provenance (repo URL + commit SHA + as-of)
- Dogfood produces ≥1 measurable insight documented
- Karpathy framing identifies next experiment with explicit measurement plan
- Promote-rule run identifies ≥1 candidate from new agent-notes (closes first feedback loop)

---

## Budget Delta

| Phase 0 segment | REV-2 (D-003) | REV-3 (D-005, this) |
|---|---|---|
| Tracks 0-5 + 5.5a + 5.5b (shipped through S7) | ~770K | ~770K (actuals) |
| 5.5c.1+2+6 (shipped S8) | absorbed in 5.5c ~400K | ~150-180K (actuals) |
| 5.5c.3+4+5 (S13 — was S9 pre-UP-08) | absorbed in 5.5c ~400K | ~220-250K |
| **5.5d.1 Boundary + Collection** (NEW, S10) | — | **~120K** |
| **5.5d.2 Sweeper + Index + First Analysis** (NEW, S11) | — | **~150K** |
| **5.5d.3 Karpathy + Agent-pick-1 + dogfood** (NEW, S12) | — | **~150K** |
| Track 6 REWRITE (S14, was S10/S11) | ~150K | ~150K |
| Track 7 constitution (S15) | ~150K | ~150K |
| Track 8a Confidence Score (S16) | ~120K | ~120K |
| Track 8b Memory L0/L1 (S17) | ~120K | ~120K |
| Track 9 Self-Awareness (S18) | ~80K | ~80K (or reduce if 5.5d.3 absorbs) |
| Final verifier (S19) | ~80K | ~80K |
| **TOTAL** | **~2.02M** | **~2.44M** |

User explicitly accepted ~2.44M via AskUserQuestion Round 2 Q5=A (2026-04-29T18:10:00Z).

**Delta vs original D-003 R2 Q8=A acceptance** (1.5-2M cap): +22-23% over upper-end (under L-8 25% trigger, but explicitly surfaced in delta_summary frontmatter per UP-06 NO Silent File-Defaults).

---

## Why (Reasons)

1. **UP-08 directive elevation matches charter principles 4 + 7 + 8**: proprietary data moat
   (compound learning data over time), dogfood mandatory (use system weekly to validate),
   calibration over confidence (measure → trace → evaluate → improve = Karpathy autoresearch).

2. **Layer-separation discipline already established by D-002 + D-003 5.5a**: extending it to
   write-heavy stores is consistent. UP-08 §3 verbatim "thiết kế từ đầu" matches Layer Foundation
   design intent.

3. **5.5c primitives are foundation, not full system**: shipped S8 primitives (decompose-work +
   capability-map + promote-rule + JSONL telemetry + correction-rate-aggregator pattern) are
   ingredients. UP-08 adds the recipe (boundary + queue + index + outer loop) that turns
   ingredients into a functioning self-learning sub-system.

4. **Cheap-first ordering preserved**: 5.5d.1 (boundary + collection) is mostly mechanical —
   3 hooks + 1 README + 1 .gitignore patch. 5.5d.2 builds on it with index infra. 5.5d.3 is
   the sole LLM-heavy sub-session (Karpathy framing + agent-pick-1 dogfood). Pattern matches
   decompose-work skill output.

5. **NDJSON queue + cron-via-hook fits existing harness pattern**: Track 5 hooks + 5.5c.5
   component-telemetry + S8 correction-rate-aggregator already use this topology. No new infra;
   migrate to Redis Phase 1+ if event volume warrants.

6. **Agent-pick-1 + dogfood bounds research budget**: 120-150K vs 250-360K for broad scan.
   Honors UP-08 §3 opensource integration directive without scope creep. Broaden later if
   the picked tool signals real fit.

7. **Drift signal D9 prevents silent failure**: without explicit drift detection, runtime
   reading `learning-data/` becomes a recurring bug (size penalty + relevance dilution).
   D9 makes the boundary enforceable via deterministic hook (Tier 1 quality gate).

---

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Boundary leak: runtime SessionStart hook reads `learning-data/` accidentally | Medium | D9 drift signal + `.claude/settings.json` permission deny + smoke-test on every Track 5.5d session |
| NDJSON queue size explosion (>100K events/day) | Medium-Low (Phase 0 volume low) | 5.5d.2 sweeper enforces 7-day rotation + 30-day archive purge + size guards |
| Background LLM dispatch (5.5d.2 L-1, 5.5d.3 L-3) blows budget | Medium | Phase-boundary cron only (not per-session); explicit dispatch budget cap; defer to dedicated sessions when needed |
| Opensource agent-pick-1 picks wrong tool first | Medium | Documented as single-shot; if signal weak → broaden to Q4-A scan in 5.5d.4 follow-up (out of scope this decision; would need ratification) |
| Karpathy outer loop over-engineered for current scale | Medium | Start with single-loop dogfood (5.5d.3); descope outer loop to Phase 1+ if signal weak |
| 5.5d budget overshoots (3 sessions × actual >150K each) | Medium | Per-session budget watchdog (D-004 thresholds 180K/220K/250K); auto-reboot on cliff; descope 5.5d.3 if 5.5d.1+2 already at ceiling |
| Track 6 REWRITE further delayed (now S14) | Low | Pre-existing 24 D1 LOC violations carry-over; no NEW violations from 5.5d.1-3 expected (boundary docs + hook scripts under D1 ceilings); track-6 still has clean target list |

---

## Open Questions (deferred to per-session decisions, IMPL-tier)

- Final RAG index choice: SQLite FTS5 Phase 0 vs DuckDB FTS vs simple bash grep+regex — IMPL-tier; agent picks at S11, subject to drift audit
- Event NDJSON schema fields: must include `ts`, `source` (which hook), `event_type`, `payload`, `as_of` per I-S2 — exact schema set at S10
- Sweeper retention numbers: 7-day rotation + 30-day purge are first-pass; tune at S11 dry-run
- Background-dispatch threshold: 100 events / 5 sessions are first-pass; tune at S11 smoke-test
- Karpathy framing artifact format: TBD at S12 based on `try-n-approaches` skill output (5.5c.3 — may ship S13 before S12, or inline in S12 if not yet shipped)
- Opensource agent-pick-1 candidate: agent-pick at S12 SessionStart based on then-current capability-map + research-scanner dispatch result

These are IMPL-tier per D-003 § Open Questions doctrine — agent decides; subject to drift audit + sandwich-verifier cross-check.

---

## Connection to existing plan (sequence updates)

**Pre-D-005 sequence (per D-003 + S8 close)**:
- S9 = PLAN UP-08 (this session)
- S10 = 5.5c.3+4+5 (try-n-approaches + OTEL + JSONL ext)
- S11 = Track 6 REWRITE
- S12 = Track 7 constitution
- S13 = Track 8a
- S14 = Track 8b
- S15 = Track 9
- S16 = Final verifier

**Post-D-005 sequence**:
- S9 = PLAN UP-08 ✓ (this session, closing soon)
- **S10 = 5.5d.1 Boundary + Collection** (NEW)
- **S11 = 5.5d.2 Sweeper + Index + First Analysis** (NEW)
- **S12 = 5.5d.3 Karpathy + Agent-pick-1 + dogfood** (NEW)
- S13 = 5.5c.3+4+5 (was S10)
- S14 = Track 6 REWRITE (was S11)
- S15 = Track 7 constitution (was S12)
- S16 = Track 8a (was S13)
- S17 = Track 8b (was S14)
- S18 = Track 9 (was S15)
- S19 = Final verifier (was S16)

Sequence shifts +3 (S10..S16 → S13..S19). All prior carry-overs remain (queued-grill items, Q&A bundles 002-005 in pending/, S6 audit items, etc.).

---

## Acceptance Record

- **2026-04-29T17:41+07**: UP-08 intake mid-S8 (file dropped at `human-workspace/user_prompt/20260429_08.txt`)
- **2026-04-29T18:00:00Z**: PROPOSED by Claude Opus 4.7 (S9 PLAN — decompose-work skill dogfood + Q&A bundle 006 authoring)
- **2026-04-29T18:05:00Z**: ASKED-ROUND-1 by agent (4 SCOPE-tier AskUserQuestion picks)
- **2026-04-29T18:05:00Z**: ACCEPTED-ROUND-1 by user (Q1=A, Q2=A, Q3=A, Q4=C — all Recommended)
- **2026-04-29T18:10:00Z**: ASKED-ROUND-2 by agent (1 budget-acceptance AskUserQuestion pick; triggered by L-8 capability-map limit + UP-06 NO Silent File-Defaults)
- **2026-04-29T18:10:00Z**: ACCEPTED-FINAL by user (Q5=A — Recommended; ~2.44M)

Status transitioned PROPOSED → ACCEPTED in same session via 5 AskUserQuestion explicit picks across 2 rounds (no defaults absorbed; UP-06 NO-Silent-Default + UP-04 AskUserQuestion-PRIMARY both respected).

---

## Amendments (append-only)

### REV-1 (2026-04-29, S15 PLAN → S16 IMPL ratification) — Path layout consistency (IMPL-S11-2 + IMPL-S12-1 + IMPL-S14-1 carry-over)

**Source**: S10/S11/S12 IMPL-tier resolutions + S14 carry-over. See `agent-workspace/memory/sessions/2026-04-29-session-11.md` IMPL-S11-2 + `2026-04-29-session-12.md` IMPL-S12-1 + `2026-04-29-session-14.md` IMPL-S14-1. Composed in S15 PLAN file `agent-workspace/session-plans/pending/003-S15-track-7-constitution-amendments.md` § 1.2; ratified S16 IMPL.

**Issue 1 — Internal path inconsistency**: § 5.5d.1 deliverables listed `agent-workspace/learning-data/{events,index,archive}/`; § 5.5d.2 deliverables listed `agent-workspace/memory/learning-data/index/categories-<TS>.md` (note: spurious `memory/` prefix). S10 IMPL aligned to § 5.5d.1 layout (downstream artifacts: permissions, README, gitkeep, .gitignore, hooks all consistent). § 5.5d.2 prose treated as drafting bug per IMPL-S11-2 doctrine (downstream-alignment cost dominates drafting-text precision).

**Issue 2 — Dogfood file split** (surfaced at S12, IMPL-S12-1): research-survey output and dogfood-insight output occupy distinct file purposes. S12 IMPL chose two files: `learning-data/dogfood/<tool>-research-report-<TS>.md` for research-scanner output (provenance log + scoring + bear case) and `learning-data/dogfood/<tool>.md` for dogfood-insight artifact (post-integration measurable insight). D-005 § 5.5d.3 prose collapses both into single `<tool>.md` filename — that's a drafting collapse, not the right shape.

**Issue 3 — Track 6 secondary carry-over** (S14, IMPL-S14-1): skill `.claude/skills/spec-to-wiki/SKILL.md` (227 LOC) remained a D1 violation after Track 6 primary closure. Per L-S14-2 (skill-vs-command duplication multiplier), it's a separate refactor task — not blocking, scheduled S16 OPTIONAL or S17 dedicated.

**Decision**:
1. **§5.5d.1 layout is canonical**: `agent-workspace/learning-data/{events,index,archive,dogfood,loop}/`. Prose elsewhere referring to `agent-workspace/memory/learning-data/...` is treated as a drafting error and superseded.
2. **§5.5d.2 prose**: corrected path = `agent-workspace/learning-data/index/categories-<TS>.md` (no `memory/` prefix).
3. **Dogfood file split** (§5.5d.3): two distinct files per purpose — `learning-data/dogfood/<tool>-research-report-<TS>.md` (research-scanner output) and `learning-data/dogfood/<tool>.md` (dogfood-insight artifact).
4. **S14 Track 6 secondary carry-over**: skill `.claude/skills/spec-to-wiki/SKILL.md` (227 LOC) acknowledged as residual D1 violation; non-blocking for D-005 5.5d scope; tracked separately under Track 6 secondary closure (S16 optional / S17 dedicated).

**Why this matters going forward**:
- Permissions, README, .gitignore, all hooks already aligned to § 5.5d.1 layout — REV-1 ratifies the alignment rather than churning to "fix" the prose.
- Two-file dogfood pattern is the production shape used by `research-scanner.md` agent + `research-scanner-output-validator.sh` hook (which scans `agent-pick-*-research-report-*.md`).
- D1 baseline = 16 violations after S14 (5 skills + 10 commands + 1 agent); REV-1 does NOT reduce this count (Track 6 secondary is independent).

**Status transition**: D-005 ACCEPTED → ACCEPTED-REV-1 (path consistency + carry-over acknowledgment; no scope change).
