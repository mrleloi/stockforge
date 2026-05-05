---
id: 2026-04-29-006-up08-self-learning-pipeline
topic: "UP-08 SCOPE-tier ratification — self-learning/upgrade pipeline as write-heavy data-ETL discipline distinct from runtime"
opened_at: 2026-04-29T18:00:00Z
expected_answer_by: 2026-04-29T22:00:00Z
priority: HIGH
related_decisions:
  - D-003
sync_categories:
  - SCOPE
  - DECISION_ROUTING
provenance:
  triggered_by: "UP-08 intake mid-S8 (2026-04-29 ~17:41+07); routed to S9 PLAN per CLAUDE.md no-PLAN+IMPL-mix hard rule"
  source_prompt: human-workspace/user_prompt/20260429_08.txt
  prompt_hash: n/a
  decomposition_observation: agent-workspace/memory/observations/decompose-work-up08-S9.md
defer_cycle: 0
status: answered
ask_user_question_call:
  fired_at: 2026-04-29T18:05:00Z (Round 1) + 2026-04-29T18:10:00Z (Round 2 budget)
  picks_count: 5
  channel: "AskUserQuestion (PRIMARY per UP-04 B1=A); this file = audit trail per UP-06 NO Silent File-Defaults doctrine"
  pick_summary: "Q1=A (Track 5.5d new) | Q2=A (Separate FS + drift D9) | Q3=A (NDJSON queue + cron-via-hook) | Q4=C (Agent-pick-1 + dogfood) | Q5=A (Accept ~2.44M budget)"
resulting_decision: D-005
---

# Q&A Bundle 006 — UP-08 Self-Learning Pipeline SCOPE Ratification

## Headline

UP-08 (full quote in `human-workspace/user_prompt/20260429_08.txt`) elevates **self-learning / self-upgrade** as a distinct discipline from runtime: write-heavy + index-heavy + cache-heavy ETL pipeline that collects data from harness/runtime cheaply, processes via background jobs, isolated from runtime read-path. Frames "harness engineering = backend engineering / data ETL". Calls for early integration ("thêm sớm vào plan để có đủ data đo lường") + queue+event-driven + Karpathy autoresearch + opensource-tool integration.

This bundle ratifies SCOPE: where in the plan, what boundary, what execution tech, what research scope. IMPL-tier details (retention duration, dispatch cadence, exact tooling) deferred to per-session decisions.

Decomposition (decompose-work skill dogfood, S9): 5 deterministic / 4 LLM / 2 hybrid portions; **5.5c primitives shipped S8 are necessary but not sufficient** for UP-08. UP-08 adds: (a) data-boundary discipline, (b) queue-rotation infra, (c) periodic background-dispatch trigger rule, (d) opensource-tool research arm.

---

## Cluster A — UP-08 SCOPE Ratification (4 SCOPE-tier picks; AskUserQuestion Round 1)

### Q1 — Where to slot UP-08 in Phase 0 plan?

**Tier**: SCOPE
**Evidence**:
- `agent-workspace/memory/decisions/003-up06-track-5.5-sync-layer-selfcap.md § 5.5c` (existing self-cap tracks: decompose-work + capability-map + try-n-approaches + OTEL + JSONL + promote-rule — foundations for self-learning but NOT the data-boundary/queue/cron infra UP-08 calls for)
- Decomposition observation: 5.5c primitives shipped S8 are foundation; UP-08 adds 4 distinct sub-tracks
- Track 9 was reduced to 80K (D-003 budget table) because 5.5c absorbs OTEL setup; re-elevating it would conflict with reduction rationale
- Phase 1 defer would lose UP-08's explicit "thêm sớm" directive

**Options**:
- A: **NEW Track 5.5d (parallel to 5.5a/b/c, before Track 6)** — matches existing 5.5 sub-track sequencing pattern; reuses 5.5c primitives; clean ownership boundary
- B: **5.5c amendment** — extend self-cap track with new sub-deliverables; muddy completed scope; conflates 2 disciplines
- C: **Track 9 re-elevation** — Track 9 was reduced 120→80K in REV-2 because 5.5c covers OTEL; re-elevation walks that back; Track 9 better reserved for live profile-cards (separate concern)
- D: **Phase 1 defer** — build when real KOL/news data flows (Tier 3+4 ingest); loses the "đủ data đo lường từ sớm" requirement; harness-self-learning data flows in Phase 0 (sessions, agent-notes, mistake-log) — independent of stock data
- **Recommendation**: A (Track 5.5d new)

### Q2 — Data-boundary mechanism (runtime read path MUST NOT load write-heavy stores)

**Tier**: SCOPE
**Evidence**:
- UP-08 §3 verbatim: "việc cô lập và tách biệt các kho data này phải được thiết kế từ đầu"
- UP-08 §3 verbatim: "tránh runtime load nhầm phải những data này (với size có thể rất lớn, mà không hiệu quả)"
- Charter principle 4 (proprietary data moat) + I-S2 (every claim has source + as-of) — boundary discipline aligns

**Options**:
- A: **Separate FS path + DB schema namespace + drift signal D9** — `agent-workspace/learning-data/` (write-only); `.gitignore` rules; new D9 in `drift-signals-D1-D8.sh` flagging runtime path leak; future Postgres `learning_*` schema namespace. **Hardest enforcement; deterministic boundary**.
- B: **Namespace + tagging within existing FS/DB** — `agent-workspace/memory/learning/` subfolder + frontmatter tag `learning-only: true`; lightweight; relies on convention, not enforcement
- C: **Process isolation (separate worker processes + queue intermediary)** — OS-level boundary; matches eventual Redis/queue infra in Phase 1+; over-engineers Phase 0 (no Redis yet)
- D: **Docs-only convention** — rules in CLAUDE.md + agent-notes only; no code enforcement; weakest; relies on agent discipline (proven unreliable per S2 drift audit + UP-06 NO-Silent-Default doctrine)
- **Recommendation**: A (separate FS path + drift signal)

### Q3 — Background-processing tech for Phase 0

**Tier**: SCOPE
**Evidence**:
- UP-08 §4 verbatim: "tiếp cận theo hướng queue-based và event-driven"
- Existing harness pattern: Track 5 hooks (deterministic shell scripts), 5.5c.5 JSONL component-telemetry, correction-rate-aggregator (S8) — all cron-via-hook style
- Charter Tech Stack: Redis is Phase 1+ (not yet provisioned)
- 5.5c.4 OTEL stack designed for traces, not job queue

**Options**:
- A: **Queue files (NDJSON) + cron-via-hook trigger** — extends existing pattern; deterministic; cheap; no new infra; matches `correction-rate-aggregator.sh` topology
- B: **Redis pub-sub** — proper queue infra; requires Redis up Phase 1+; introduces dependency; overkill for current event volume
- C: **OTEL collector pipeline** — extends 5.5c.4; conflates traces + job queue; OTEL designed for ephemeral observability, not durable queue
- D: **Defer impl to Phase 1+** — write design doc now; build when Redis comes online; loses "thêm sớm" directive + early-measurement signal
- **Recommendation**: A (NDJSON queue + cron-via-hook)

### Q4 — Opensource-tool research scope

**Tier**: SCOPE
**Evidence**:
- UP-08 §3 verbatim: "kết hợp với idea của karpathy autoresearch, các repo opensource trending và hiệu quả trên github"
- Existing pattern: research-scanner subagent (orch-style; available via dispatch but not yet exercised in stockforge)
- Budget concern: PLAN session ~80-120K; broad scan = 2-3 sessions of subagent dispatch
- UP-06 §3 cheap-first ordering doctrine

**Options**:
- A: **Broad scan via research-scanner** — survey top trending repos for self-learning/karpathy/autoresearch/RAG-on-logs; comprehensive but ~2-3 dispatches × ~80-120K each
- B: **Narrow to 2-3 user-specified repos** — user names them now; agent dogfoods each; bounded budget; requires user to know the candidates
- C: **Agent-pick-1 + dogfood** — agent picks the single most-aligned repo per UP-08 directive (e.g., DSPy or LangSmith or similar); dogfoods; reports back; broaden later if signal good
- D: **Defer to Phase 1+ research budget** — UP-08 research arm waits; build in-house Karpathy loop first; revisit after dogfood data accumulates
- **Recommendation**: C (agent-pick-1 + dogfood)

---

## Answer Section (post-AskUserQuestion picks)

- Q1 (slot): **A — Track 5.5d new** (Recommended pick)
- Q2 (boundary): **A — Separate FS path + drift D9** (Recommended pick)
- Q3 (background-tech): **A — NDJSON queue + cron-via-hook** (Recommended pick)
- Q4 (opensource-scope): **C — Agent-pick-1 + dogfood** (Recommended pick)
- Q5 (budget; Round 2): **A — Accept ~2.44M** (Recommended pick)

## Notes from human

(no free-text added; all 5 picks via Recommended option)

## Audit trail

Round 1 (4 questions) fired at 2026-04-29T18:05:00Z; user picked all 4 Recommended within seconds.

Round 2 budget question fired at 2026-04-29T18:10:00Z because Track 5.5d adds ~420K → Phase 0 total ~2.44M (+22-23% over upper-end of D-003 Round 2 accepted 1.5-2M cap). Per L-8 capability-map limit ("REV-N with ≥10 amendments OR ≥25% budget delta needs explicit Delta Summary headline") + UP-06 NO Silent File-Defaults, budget pick MUST be explicit. User picked A (Accept ~2.44M; Recommended).

Per UP-04 B1=A, AskUserQuestion is PRIMARY input channel; this file is audit trail. No defaults absorbed.

Resulting decision: **D-005** (UP-08 Track 5.5d Insertion); D-003 amended REV-3 with 1-line cross-reference.
