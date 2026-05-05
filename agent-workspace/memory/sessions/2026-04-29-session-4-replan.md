# Session 4 (REPLAN) — UP-06 Track 5.5 Scope Amendment

**Date**: 2026-04-29
**Type**: PLAN (no code; scope amendment session per UP-06 directive)
**Mode**: SUPERVISED
**Token spend (self-track estimate)**: ~110-120K (within PLAN 50-80K original budget — overshot due to thorough audit + 2x AskUserQuestion + 5 large artifact writes)
**Real-transcript tokens**: TBD (budget-watchdog hook will record)

---

## Goal

Address `human-workspace/user_prompt/20260429_06.txt` (UP-06) which raised 3 strategic concerns and explicitly directed elevating "sync" to #1 priority. Decide scope amendment direction BEFORE starting Track 6 (originally next on D-002 REV-2 plan).

---

## What happened

### Pre-flight
- Read SessionStart-injected files: `checkpoints/latest.md` (S3 close), `current-execution.md`, `queued-grill-master.md`, `human-workspace/CLAUDE.md`, `agent-workspace/CLAUDE.md`, `CLAUDE.md`, MEMORY.md
- Read UP-06 prompt verbatim
- Audit current state across UP-06's 3 dimensions (drift detection / layer separation / self-upgrade)

### AskUserQuestion Round 1 (4 Qs)
- Q1 routing: **A — Track 5.5 before Track 6 (Recommended)**
- Q2 sync mech multiSelect: **All 4 — periodic grilling + intent-vs-impl-diff agent + sync-state.md + sync Q&A template**
- Q3 layer depth: **C — Full /attach + multi-tenant** (later refined)
- Q4 self-cap: **C — Aggressive Karpathy autoresearch infrastructure**

### AskUserQuestion Round 2 (4 Qs)
- Q5 sequencing: **A — Layer→Sync→Self-Cap, REWRITE Track 6**
- Q6 multi-tenant scope: **D — Skip multi-tenant; only /attach** (refines Round 1 Q3)
- Q7 measurement: **B — OTEL + JSONL hybrid**
- Q8 budget: **A — Accept ~1.5-2M total Phase 0 budget**

### Artifacts produced this session

| Path | Type | Purpose |
|---|---|---|
| `agent-workspace/memory/decisions/003-up06-track-5.5-sync-layer-selfcap.md` | NEW decision | Full Track 5.5 design + budget delta + risk register |
| `agent-workspace/memory/decisions/002-phase-0-harness-bootstrap-design.md` | EDIT (REV-3) | Status → ACCEPTED-REV-3; new approval_chain entry; Amendments § REV-3 with revised session sequencing (14 sessions) |
| `agent-workspace/memory/decisions/README.md` | EDIT | Decision index updated for D-003 + D-002 REV-3 |
| `human-workspace/q-and-a/pending/2026-04-29-004-up06-track-5.5-amendment.md` | NEW (born-answered) | Audit trail of 8-question AskUserQuestion exchange |
| `agent-workspace/session-plans/pending/002-track-5.5-sync-layer-selfcap.md` | NEW master plan | Track 5.5 executable view (5 sub-tracks across S5-S8 per REV-3 numbering) |
| `agent-workspace/session-plans/pending/001-port-from-orch.md` | EDIT | Header → REV-3; Phase Goals add Track 5.5 deliverables; session table revised (was 9, now 14 in REV-3 § D) |
| `agent-workspace/memory/current-execution.md` | EDIT | Active plan + routing table + Current Work Items reflect Track 5.5 |
| `agent-workspace/memory/checkpoints/latest.md` | EDIT (next) | S4-replan close handoff |
| `agent-workspace/memory/sessions/2026-04-29-session-4-replan.md` | NEW (this file) | Session log |
| `human-workspace/notifications/N-2026-04-29-SUMMARY-up06-replan.md` | NEW (next) | Notification to human |

---

## Key Decisions (this session)

### D-003 created — UP-06 Track 5.5 insertion

Track 5.5 inserted between Track 5 and Track 6, executed Layer→Sync→Self-Cap, full ambition on Sync (4 mechanisms) + Karpathy autoresearch (OTEL+JSONL hybrid). Multi-tenant DROPPED. Budget delta: ~1.28M → ~2.02M (within user-accepted ~1.5-2M band).

### D-002 REV-3

Amendment recorded in-place (not superseded since intent unchanged: Phase 0 = Harness Bootstrap). Session count 9 → 14. Track 6 budget reduced to ~150K (from ~200K) reflecting layer-aware scope. Track 9 budget reduced to ~80K (from ~120K) reflecting 5.5c absorbs OTEL setup.

---

## What S5 (next session = Track 5.5a Layer Foundation) needs to do

Per `agent-workspace/session-plans/pending/002-track-5.5-sync-layer-selfcap.md` § 5.5a:

1. Author `.claude/manifest.yaml` declaring scope of every artifact
2. Move 4 stockforge-biz skills to `.claude/stockforge/skills/` (`evidence-extraction`, `postgres-pgvector`, `crawler-reliability`, `fastapi-module`)
3. Author `.claude/skills/attach/SKILL.md` + `references/`
4. Update `.gitignore` for personal/non-committed paths
5. Update `.claude/settings.json` permissions for new paths
6. Smoke-test `/attach` on scratch dir
7. Confirm D1 drift-signal still passes post-restructure

Estimated S5 budget: ~150K (FOCUSED_IMPL).

---

## Risks discovered this session

- **R-this**: This session label awkwardness — "S4-replan" because original S4 was Track 6 per D-002 REV-2; new D-002 REV-3 § D names S4 = Layer Foundation. Resolved by calling this session `session-4-replan` and reserving plain `session-4` for the actual S4 (Track 5.5a impl) which by REV-3 numbering becomes S5 in subsequent material. **Note for S5**: be aware that REV-3 § D table says "S4 = Layer Foundation"; this means session log file `2026-04-29-session-4.md` will be the REV-3 S4 = Track 5.5a impl. The "replan" suffix on this file disambiguates.

- **R-CTX-1**: PLAN session overshot original 50-80K budget (~110-120K self-track) due to large amendment artifacts. For future scope-amendment sessions, treat as MULTI_TASK_IMPL (150K) target since artifacts are substantial.

---

## Drift-Watch (S4-replan close)

- DR1 (LOC ceiling): D-003 + Track 5.5 plan files are all >150 LOC body. PLAN-tier files have no LOC ceiling per `loc-ceiling-check.sh` (only `.claude/{agents,skills,commands}` are checked). Status: not a violation.
- DR2 (self-attestation): N/A (no claims about LOC)
- DR-PROV: D-003 has `source_evidence:` with 4 entries. Status: clean.
- DR-DEFER: no defer-cycles incremented.
- DR-CONFIG: settings.json unchanged this session.
- All other DR signals: clean (no code changes; pure docs/decisions).

---

## Carry-over from S3 (still queued)

- **G1 (S2-audit)** — Re-grill Q-S5 charter-tier in S5 Track 7 (now S11 per REV-3): still queued
- **B1 (S2-audit)** — Track 8a "live consumption" success criteria amendment (S6 → S12): still queued
- **G2 (S2-audit)** — Pre-amendment delta summary protocol (Track 7 → S11): still queued

These survive REV-3 sequencing shift (now S11 not S5/S6).

---

## Lesson learned (potential agent-notes entry)

When user prompt is meta-strategic (asking about agent's own design/processes), the right response is:
1. Honest audit FIRST (what we have, what's missing across each dimension user raised)
2. Reframe the user's themes into a coherent pattern (e.g., UP-06's 3 themes all converged on "sync as backbone")
3. AskUserQuestion multi-batch on scope/routing decisions BEFORE proposing implementation
4. Decision document + amendment trail BEFORE any code work begins

This avoided the trap of either (a) silently absorbing UP-06 as "agent will figure it out" or (b) blasting into Track 6 work and ignoring UP-06 directive elevation of sync. Will append to agent-notes if pattern recurs.
