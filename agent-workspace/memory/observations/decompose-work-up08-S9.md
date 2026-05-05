---
observation_id: decompose-work-up08-S9
type: skill-application
created_at: 2026-04-29
session: S9 (PLAN)
skill_invoked: .claude/skills/decompose-work/SKILL.md
target_task: UP-08 self-learning pipeline architecture
related_intent: human-workspace/user_prompt/20260429_08.txt
purpose: dogfood decompose-work skill on UP-08 to inform D-005 plan ordering + identify deterministic floor
---

## Decomposition: UP-08 self-learning / self-upgrade pipeline

**Source task** (UP-08 verbatim): "self-learning/upgrade ... write/index/cache thu thập dữ liệu từ harness/runtime ... background job qua hook định kì ... mining knowledge bên ngoài với indexing nhanh + RAG query ... deterministic step + LLM ... workflow tách biệt với runtime ... karpathy autoresearch + opensource integration ... cô lập data store, harness engineering = backend engineering / data ETL ... queue-based + event-driven background processing"

**Decomposition depth**: shallow (5 deterministic / 4 LLM-required / 2 hybrid)
**Estimated LLM budget saved**: ~80-150K (most data-collection + indexing work is mechanical)

---

### Deterministic portions (5)

| ID | Sub-task | Tool/Script | Expected output | Verification |
|---|---|---|---|---|
| D-1 | Define data-boundary FS layout (paths, .gitignore rules, drift exclusions) | `Write` to `agent-workspace/learning-data/README.md` + `.gitignore` patches | static schema doc + ignore rules | bash check `git check-ignore <new-paths>` PASS |
| D-2 | Hook-based event emission (Stop / PostToolUse / SessionStart pre-hooks → JSONL queue file) | extend `scripts/hooks/component-telemetry.sh` (existing pattern from 5.5c.5) | append-only NDJSON event stream `learning-data/events/YYYY-MM-DD.ndjson` | line-count growth + JSON parse PASS via `node -e` |
| D-3 | Queue-rotation + retention sweeper (cron-like via SessionStart hook) | new `scripts/hooks/learning-queue-sweeper.sh` (~80 LOC) | rotate >7-day events to `archive/`; delete >30-day; size guards | size + retention assertions in smoke-test |
| D-4 | RAG index rebuild trigger (deterministic — runs when N events queued) | `scripts/hooks/learning-index-rebuild.sh` invoking embedding emitter (Phase 1+ pgvector) or local SQLite FTS Phase 0 | index file mtime + count delta | grep `^index_built_at:` line written |
| D-5 | Drift exclusion (runtime read path MUST NOT load `learning-data/`) | extend `drift-signals-D1-D8.sh` with new D9 = "runtime path leak into learning-data/" | violation list (zero on PASS) | `bash drift-signals-D1-D8.sh --signal D9` exit 0 |

---

### LLM-required portions (4)

| ID | Sub-task | Agent/Skill/Inline | Why LLM needed | Calibration cell (capability-map) |
|---|---|---|---|---|
| L-1 | Classify event corpus into improvement categories (drift / retry / mistake-type / promotion-candidate) | inline (sonnet, medium effort) | fuzzy classification with stockforge domain context | model=sonnet effort=medium task_class=classification |
| L-2 | Synthesize patterns across reasoning logs → propose new agent-notes / mistake-log entries | inline (opus, high effort) — periodic background dispatch | multi-source narrative + naming | model=opus effort=high task_class=synthesis |
| L-3 | Karpathy autoresearch loop: pick promising approach + frame next experiment | inline or `try-n-approaches` skill (S10) | judgment under uncertainty + multi-perspective | model=opus effort=high task_class=design |
| L-4 | Opensource-tool evaluation (read repo READMEs, judge fit) — research-scanner subagent | research-scanner subagent (fresh ctx, opus, high) | reading + interpretation + recommendation | model=opus effort=high task_class=synthesis (novel sub-task: tool-survey) |

---

### Hybrid portions (2)

| ID | Sub-task | Gate (deterministic) | Escalation (LLM) | Threshold |
|---|---|---|---|---|
| H-1 | Promotion-candidate detection (events → `agent-notes` rule promotion) | `promote-rule` jaccard cluster ≥3 (deterministic, S8 shipped) | LLM judges promotion target (hook/skill/charter) per Q-E3 priority | cluster size ≥3 + jaccard ≥0.4 |
| H-2 | Background-job trigger rule | event-count threshold or N-session-elapsed (cron-style hook) | LLM decides whether to fire deeper analysis (`try-n-approaches` dispatch) | events ≥100 OR N-sessions ≥5 |

---

### Integration plan

1. **Phase 1 (boundary design)**: D-1 + D-5 ship — paths, `.gitignore`, drift signal. Cheap, foundation.
2. **Phase 2 (collection layer)**: D-2 ships — hook-based emit. Extends existing 5.5c.5 JSONL pattern (no new infra).
3. **Phase 3 (processing layer)**: D-3 + D-4 ship — sweeper + index rebuild. Deterministic, cron-via-hook (not Redis Phase 0).
4. **Phase 4 (gates)**: H-1 + H-2 ship — deterministic gates for when LLM analysis fires.
5. **Phase 5 (LLM analysis)**: L-1..L-4 dispatched per gate. Outputs: new agent-notes / mistake-log / capability-map cells / opensource-tool dogfood targets.
6. **Phase 6 (Karpathy outer loop)**: L-3 + L-4 feed back into harness improvements; measure via existing OTEL+JSONL (5.5c.4+5).

---

### Risks + fallbacks

| Risk | Likelihood | Fallback |
|---|---|---|
| Data-boundary leak: runtime SessionStart hook reads `learning-data/` accidentally | Medium | D-5 drift signal + explicit deny in `.claude/settings.json` permissions |
| Queue file size explosion (NDJSON unbounded) | High | D-3 retention + per-day rotation; size guard before hook emits |
| LLM background dispatch (L-2/L-3) blows budget | Medium | Phase-boundary cron only (not per-session); explicit dispatch budget cap; defer to dedicated session type |
| Opensource-tool research scope creep | High | Cap research-scanner to N=1 tool agent-pick + dogfood; defer broad scan to Phase 1+ |
| 5.5c primitives (OTEL, capability-map, promote-rule) insufficient → re-design | Low | Already shipped + smoke-tested S8; gaps surface as new capability-map cells |
| Karpathy autoresearch over-engineered for current scale | Medium | Start with single-loop dogfood (S10 try-n-approaches); descope outer loop to Phase 1+ if signal weak |

---

### Capability-map grounding

- **Cells consulted**:
  - Strength row #1 (opus high design — multi-mechanism ensemble): supports L-3 Karpathy framing.
  - Strength row #5 (sonnet low intent-classification): supports L-1 event classification (lower effort tier than L-2/3).
  - Limit row L-1 (NO LLM math): all queue counts, retention, similarity = deterministic.
  - Limit row L-3 (false self-attestation): D-2/D-3/D-4 verification mandatory; never trust "I emitted N events".
  - Limit row L-5 (qa-input-channel): UP-08 SCOPE-tier picks via AskUserQuestion (not file-only).
- **Gaps**:
  - `task_class=tool-survey` (L-4 opensource research) NOT in vocabulary. Propose new entry post-S9.
  - `task_class=event-stream-classification` (L-1) is sub-flavor of `classification`; may need entry if pattern repeats.
- **Limits respected**: I-S1 (no LLM math) ✓ via D-1..D-5 doing all numbers | I-S2 (provenance) ✓ via event NDJSON having `source` + `as_of` fields | UP-04 B1 (AskUserQuestion PRIMARY) ✓ via S9 Q&A bundle ratification.

---

### Recommendation

**Default execution path** (if user approves SCOPE):
- **S10 (or new 5.5d1)**: D-1 + D-2 + D-5 + H-1 wiring (boundary + collection + drift signal). Reuses 5.5c primitives. ~150K.
- **S11 (or 5.5d2)**: D-3 + D-4 + H-2 + first L-1/L-2 dispatch (sweeper + index + first analysis). ~150-200K.
- **S12+ (or 5.5d3)**: L-3 + L-4 (Karpathy + opensource research). Phase-boundary cron. ~150K.

**If budget tight**: descope L-4 (opensource research) → defer to Phase 1+; keep L-1..L-3 (in-house autoresearch).
**Never descope**: D-1/D-5 boundary + drift signal — without these, runtime contamination is silent and irrecoverable.

**Key insight from decomposition**: 5.5c primitives (OTEL+JSONL+capability-map+promote-rule shipped S8) are **necessary but not sufficient** for UP-08. UP-08 adds (a) data-boundary discipline, (b) queue-rotation infra, (c) periodic background-dispatch trigger rule, (d) opensource-tool research arm. Each is a separable sub-track.

---

### Skill smoke-test result (S9 second run after S8 dogfood)

- Decomposition produced 5 deterministic / 4 LLM / 2 hybrid (total 11 portions; matches "deep enough" without over-decomposing).
- Capability-map grounding cited 5 cells (3 strengths + 2 limits) — within spec ranges.
- Identified 1 novel task_class (`tool-survey`) for capability-map promotion path.
- **Validation**: skill produces actionable Phase-ordered plan. PASS. (Earlier S8 smoke-test was self-task on promote-rule; this is first cross-task validation.)
