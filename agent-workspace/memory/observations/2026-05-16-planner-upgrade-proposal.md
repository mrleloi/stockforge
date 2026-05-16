---
observation_id: 2026-05-16-planner-upgrade-proposal
type: harness-design-proposal
created_at: 2026-05-16T~19:50 SEAST
author: main session (Opus 4.7 max effort)
trigger: user_prompt 20260516_01.txt § 3 — "skill/agent which create the plan ... number of task, number of agent/subagent that can run at once time ... is not much. i need the planner to be more wiser, it can see the tracking log to learn, improve it self, to decide the more effective plan, more subagent running in parralel without causing any error or wrong direction, the planner make claudecode run faster to achieve the goals"
scope: upgrade planner subagents (sandwich-architect + master-planner) — feedback loop + parallel-dispatch + plan-quality calibration
severity: HIGH (current planners under-utilize parallelism; sandwich pattern is strictly sequential; no learning from past outcomes)
---

# Planner Subagent Upgrade Proposal — 2026-05-16

## TL;DR

**Current state**: planners (sandwich-architect 183 LOC, master-planner 168 LOC) plan blindly from spec + memory. Three rich tracking logs (`dispatch.jsonl` 530 rows + `component-telemetry.jsonl` 3666 rows + `self-awareness/sessions-rollup.tsv` 623 rows) sit UNUSED by planners. Sandwich pattern (architect → dev → verifier) is strictly sequential. Parallel sub-track dispatch happens 0× per recent inspection of S337/S338/S341/S344 (each used 1 dev at a time even when sub-tracks were independent).

**Proposed**: 4 enhancements (E1-E4) — feedback loop reading tracking logs + explicit parallel-dispatch directives in plan format + concurrent sub-track dev agents + per-plan throughput metric. Expected outcome: 30-50% reduction in plan-to-ship wall time for plans with ≥3 independent sub-tracks.

**Cost**: 1-2 sessions (PLAN + IMPL+VERIFY sandwich).

---

## Current state — empirical audit

### Planner templates (file-grep evidence)

| File | LOC | Refs to tracking logs | Refs to parallel dispatch |
|---|---:|---:|---|
| `.claude/agents/sandwich-architect.md` | 183 | 0 | 1 (`line 96`: "test file created in parallel" — example for dev, not directive) |
| `.claude/agents/master-planner.md` | 168 | 0 | 1 (`line 74`: "Identify parallel opportunities" — vague) |
| `.claude/agents/action-guide-planner.md` | 178 | 0 | 0 |
| `.claude/agents/bdd-planner.md` | 163 | 0 | 0 |

**Total parallel-dispatch directives across 692 LOC of planner contracts: 2 vague mentions, 0 concrete instructions.**

### Tracking logs available — sitting unused

| File | Lines | What it contains | Currently consumed by |
|---|---:|---|---|
| `agent-workspace/memory/dispatch.jsonl` | 530 | Every Agent dispatch: agentId, subagent_type, duration_ms, outcome, tokens_real, task_id | Stop-hook `correction-rate-aggregator.sh` reads for rollup; planners never read |
| `agent-workspace/memory/component-telemetry.jsonl` | 3666 | Per-hook + per-agent telemetry | `self-awareness-aggregate.sh` rolls up to profiles/*.md; planners never read |
| `agent-workspace/memory/self-awareness/sessions-rollup.tsv` | 623 | Session-level rollup: session_id, task_class, model, effort, tokens, outcome, mistakes | `profile-template-auto-populate.sh` appends rows; planners never read |

### Sandwich-pattern parallelism — recent sessions

| Session | Plan sub-tracks (independent) | Dev dispatches | Wall time |
|---|---:|---:|---|
| S337 (Phase D Theme L) | D1+D2+D3+D4 (some independent: D1 ABC vs D2 primitives vs D3 adapter could be 2 parallel) | 1 sequential dev | ~25 min |
| S341 (Harness Sweep) | D1+D2+D3+D5+D6+D7 (most independent) | 1 sequential dev | ~20 min |
| S344 (NDH adapter — in flight as of this writing) | D1+D2+D3+D4+D5 (D1+D2+D3 mostly independent) | 1 sequential dev | TBD |

**Observation**: every recent multi-track plan dispatched a SINGLE dev to handle all sub-tracks. The Claude Code Agent tool supports up to 3-4 parallel background dispatches per the harness profile (per `claude-code-guide` docs + observed dispatch.jsonl row spacing). This capability is dormant.

---

## Proposed enhancements

### E1. Planner consumes tracking logs (read-before-plan)

**Add to sandwich-architect.md + master-planner.md, Phase 1: Comprehend** (currently reads spec + constitution + code):

```markdown
### Phase 1: Comprehend

(existing) Read:
- Target spec completely (Part A + B)
- Relevant constitution files
- Existing code in affected bounded contexts

### Phase 1b (NEW): Self-Calibration from Tracking Logs

Read (last 30 rows each):
- `agent-workspace/memory/dispatch.jsonl`
- `agent-workspace/memory/self-awareness/sessions-rollup.tsv`
- `agent-workspace/memory/mistake-log.md` (last 200 LOC digest)

Extract:
- For task_class similar to current target: average duration_ms + outcome distribution + failure_mode frequency
- For model+effort similar to current dispatch context: average tokens_real vs estimated
- For coordination-rule pattern similar: any file-collision incidents recorded
- For sandwich pattern: was there parallel dispatch? Did it succeed?

Use to:
- Set REALISTIC budget per sub-track (not boilerplate; ground in actual durations)
- Flag sub-tracks with historically-high failure_mode → add specific RM entry
- Identify safe parallelization opportunities → mark sub-tracks `parallel_with: [D2, D3]`
```

### E2. Explicit parallel-dispatch directive in plan format

**Add new field to plan template** (master-planner.md § Phase 6 + sandwich-architect plan output):

```markdown
## Sub-track D1: NDH adapter implementation
- **parallel_with**: [D2, D3]  ← NEW field
- **blocks_on**: []              ← NEW field (empty = no dependency)
- **coordination_paths_exclusive**: [...]  ← NEW (per-sub-track scope)
```

Architect identifies INDEPENDENT sub-tracks by analyzing file-path overlap:
- If sub-track X writes to `path/to/A.py` and sub-track Y writes to `path/to/B.py` (no overlap) → can parallel
- If both touch same file → must sequence

Dev session (or main session orchestrating) reads `parallel_with` field and dispatches multiple sub-track agents in ONE Agent-tool message (per Claude Code parallel-dispatch convention).

### E3. Concurrent sub-track dev agents

**Add to sandwich-dev.md persona**:

```markdown
## Parallelism Discipline

If plan declares `parallel_with: [D2, D3]` for sub-track D1:
- Main session (orchestrator) dispatches up to 3 dev subagents in single Agent-tool message (parallel background)
- Each dev gets a NARROWED plan slice: only its own sub-track + shared context
- Each dev's coordination_paths_exclusive list is enforced via destructive-command-guard awareness
- Devs do NOT cross-coordinate; main session integrates returns
- If any parallel dev fails → main session preserves successes + queues sequential retry for failed slice
```

**Max ceiling**: 3 parallel dev subagents per plan (matches harness profile; over-parallelism risks rate-limit + context-window fragmentation).

### E4. Throughput metric + post-plan calibration

**Add to sessions-rollup.tsv schema** (new columns):

```
session_id | task_class | model | effort | tokens | outcome | mistakes |
  + plan_id | sub_track_count | parallel_dispatched | wall_min_estimated | wall_min_actual | parallel_savings_min
```

**Post-VERIFY hook** `planner-feedback-loop.sh` (NEW; Stop cadence):
- Reads sessions-rollup last 5 rows for current plan_id
- Computes: `parallel_savings_min = (sub_track_count × avg_per_track_min) - wall_min_actual`
- Writes back to `agent-workspace/memory/.planner-stats.tsv`:
  ```
  task_class | sample_size | avg_wall_min | parallel_hit_rate | parallel_savings_avg
  ```
- Architect reads `.planner-stats.tsv` in Phase 1b above

**Calibration loop closes**: architect learns from past plans → better future estimates → more accurate budget + more aggressive parallel → less wall time → measured by feedback hook → architect learns more.

---

## Concrete examples (what plan-022 would have looked like with these upgrades)

### Without upgrades (current plan-022, as authored S343)

```markdown
## Sub-track decomposition (D1..D5)
- D1: NDH adapter implementation
- D2: HTML parser internals
- D3: Unit tests
- D4: Registry wire + CLI smoke
- D5: ADR amendment

(no parallel directives; dev executes D1 → D2 → D3 → D4 → D5 sequentially)
Recommended S344 dev budget: 100-150K Sonnet FOCUSED_IMPL, single session.
```

### With upgrades (hypothetical plan-022-prime)

```markdown
## Sub-track decomposition (D1..D5)

- D1: NDH adapter implementation
  - parallel_with: []
  - blocks_on: []
  - coordination_paths_exclusive: [packages/infrastructure/news/crawler_adapters/ndh_adapter.py]
  - estimated_wall_min: 12 (per sessions-rollup task_class=adapter-impl avg)

- D2: HTML parser internals (lives INSIDE ndh_adapter.py per architecture)
  - parallel_with: []
  - blocks_on: [D1]
  - merged into D1 by architect rationale (single-file coupling makes parallel pointless)

- D3: Unit tests
  - parallel_with: [D4]  ← INDEPENDENT (different file path)
  - blocks_on: [D1]
  - coordination_paths_exclusive: [tests/infrastructure/news/crawler_adapters/test_ndh_adapter.py]
  - estimated_wall_min: 8

- D4: Registry wire + CLI smoke
  - parallel_with: [D3]  ← INDEPENDENT
  - blocks_on: [D1]
  - coordination_paths_exclusive: [packages/infrastructure/news/__init__.py, apps/cli/ingest_news_ndh.py]
  - estimated_wall_min: 6

- D5: ADR amendment (small Markdown edit; can parallel with anything post-D1)
  - parallel_with: [D3, D4]
  - blocks_on: [D1]
  - estimated_wall_min: 3

Recommended S344 dispatch:
  Phase 1 (sequential): D1 dev — 12 min
  Phase 2 (parallel): D3 dev + D4 dev + D5 dev — max(8,6,3) = 8 min
  Total wall: 20 min (vs current sequential estimate ~29 min — 31% faster)
```

### Throughput projection

Across recent 5 sessions (S337/S338/S341/S342/S344-in-flight), 4 had ≥2 parallelizable sub-tracks:
- Conservative: 25% wall-time reduction per multi-track session
- Aggressive: 50% reduction for sessions with 3-5 independent sub-tracks

---

## Implementation plan

### Files to modify

1. `.claude/agents/sandwich-architect.md` (+50 LOC: Phase 1b + sub-track parallel fields)
2. `.claude/agents/master-planner.md` (+30 LOC: Phase 1b + plan format)
3. `.claude/agents/sandwich-dev.md` (+30 LOC: Parallelism Discipline section)
4. `.claude/agents/action-guide-planner.md` (+10 LOC: cross-reference)
5. `agent-workspace/memory/self-awareness/sessions-rollup.tsv` schema extension (back-compat default for legacy rows)

### New files

1. `scripts/hooks/planner-feedback-loop.sh` (~120 LOC; Stop cadence)
2. `agent-workspace/memory/.planner-stats.tsv` (auto-generated; back-compat fresh on first run)
3. Fire-tests for new hook (~6 TC)

### Fire-tests required

- Architect's Phase 1b reads dispatch.jsonl + sessions-rollup (mocked content; assert architect plan output cites past task_class metric)
- Plan format with `parallel_with` field validated by lint (no cycles; max 3 parallel; coordination paths disjoint)
- planner-feedback-loop produces `.planner-stats.tsv` row per VERIFY-DONE plan
- Parallel-dev dispatch: simulate 3 dispatches in single Agent-tool message; assert all complete; assert main integrates

Target: 10-12 firing-test cases.

### Risks

| Risk | Probability | Impact | Mitigation |
|---|---|---|---|
| Architect over-parallelizes; causes file-collision conflict | Medium | High (corrupted state) | Lint-validate `coordination_paths_exclusive` MUST be disjoint across parallel sub-tracks; refuse plan otherwise |
| Tracking-log read adds 5-10 sec to architect Phase 1 | Low | Low | Cap reads at last 30 rows each (cheap) |
| Parallel devs hit Claude Code rate-limit | Low | Medium | Cap at 3 concurrent; fall back to sequential on rate-limit error |
| Architect overrides cool-down with stale calibration data | Medium | Medium | Calibration data age-decayed (rows >30 days half-weighted; >90 days dropped) |
| Tracking-log read introduces new architect failure modes | Low | Medium | Phase 1b reads inside `|| true` guard; missing logs → fallback to current behavior |

---

## Effort + sequencing

| Phase | Effort | Owner |
|---|---|---|
| PLAN (architect) — refine this proposal | 60-80K Opus | sandwich-architect |
| IMPL (dev) — 5 file edits + 1 new hook + schema + fire-tests | 100-140K | sandwich-dev |
| VERIFY (verifier) | 40-60K Opus | sandwich-verifier |
| Total | ~1.5-2 sessions | — |

---

## Open questions (for user; defer until Item-4 complete)

1. **Q-PL1**: Max parallel dev ceiling — 3 (conservative) or 4 (aggressive)? Recommendation: 3 initially; raise to 4 after stable.
2. **Q-PL2**: Should architect's Phase 1b be MANDATORY (every plan) or OPT-IN (architect skips when target is simple/single-track)? Recommendation: mandatory for ≥3 sub-tracks; skipped for FOCUSED_IMPL with 1-2.
3. **Q-PL3**: Sessions-rollup schema extension is breaking — keep legacy column order + append new ones (back-compat) or full re-design? Recommendation: append (minimum disruption).
4. **Q-PL4**: Feedback loop hook cadence — Stop (per-session) or weekly cron (per-batch)? Recommendation: Stop, but with debounce so it only runs once per plan_id when VERIFY-DONE detected.

---

## What I did NOT do (scope discipline)

- **Did not modify any agent template** — proposal stage; needs PLAN session
- **Did not write the new hook** — implementation deferred
- **Did not run dispatch.jsonl analytics** — would be the architect's job under E1; outside this proposal's read budget
- **Did not propose ADR yet** — D-068 candidate (planner-feedback-loop architecture); appropriate at IMPL tier post-architect refinement

## Compliance attestation

- harness_priority_one ✓ (planner is harness infra; product-impact when planners ship better plans faster)
- 0 charter / 0 constitution writes
- 0 production code changes
- 0 commits
- AP-1 N/A (no fresh-context dispatch; user reviews proposal first)
- D-060 N/A
- Observation persisted at `agent-workspace/memory/observations/` per Track 6
- Source citations: `.claude/agents/{sandwich-architect,master-planner,sandwich-dev,action-guide-planner,bdd-planner}.md` + dispatch.jsonl/component-telemetry/sessions-rollup line counts + recent plan-020/plan-021/plan-022 sub-track structures + Claude Code Agent-tool parallel-dispatch convention
