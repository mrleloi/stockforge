---
id: D-003-up06-track-5.5-sync-layer-selfcap
title: "UP-06 Track 5.5 Insertion — Sync + Layer + Self-Capability Foundation (before Track 6)"
date: 2026-04-29
status: ACCEPTED
level: SCOPE
author:
  - "Claude Opus 4.7"
  - "user"

source_evidence:
  - path: human-workspace/user_prompt/20260429_06.txt
    quote: |
      "biến việc 'sync' thành ưu tiên hàng đầu, giúp llm trở thành second brain thực sự, trong mọi quyết định và hành động"
      "việc chia layer/structure này là một nền tảng quan trọng cho việc 'inject context'"
      "ý tưởng là để upgrade được, nó phải đo lường, tracing được, để đánh giá được độ hiệu quả... giống như 'karpathy autoresearch loop' style"
  - path: agent-workspace/memory/agent-notes.md
    section: "2026-04-29 (UP-06) — NO Silent File-Defaults"
  - path: agent-workspace/memory/decisions/002-phase-0-harness-bootstrap-design.md
    section: "REV-2 + Amendments — Phase 0 11-track design (this decision amends to insert Track 5.5)"
  - path: human-workspace/q-and-a/answered/2026-04-29-004-up06-track-5.5-amendment.md
    section: "Round 1 + Round 2 AskUserQuestion exchanges this session — 8 picks total"

intent_classification:
  primary_intent: SCOPE
  affects_charter: false
  affects_scope: true
  urgency: HIGH
  complexity_score: 90

options_considered:
  - id: A
    summary: "Track 5.5 before Track 6 with Layer→Sync→Self-Cap sequencing + full ambition"
    pros:
      - "Layer manifest first = foundation; sync skills land in proper layer; Track 6 rewrites cleanly post-5.5"
      - "Full sync (4 mechanisms) addresses UP-06 priority directive"
      - "Full Karpathy autoresearch + OTEL+JSONL = aggressive self-upgrade per UP-06 §3"
    cons:
      - "Budget delta +500-800K (Phase 0 ~1.5-2M total vs ~1.3M REV-2)"
      - "4-6 additional sessions before Track 6 work resumes"
  - id: B
    summary: "New Phase 0.5 with full re-plan"
    pros:
      - "Clean audit boundary"
    cons:
      - "1 session re-planning overhead"
      - "Scope creep risk — Phase 0 becomes Phase 0+0.5"
  - id: C
    summary: "Distributed amendments (no new track) — Sync→Track 7, Layer→Track 1 retroactive, Self-Cap→Track 9 expansion"
    pros:
      - "Keeps 11-track plan"
    cons:
      - "Sync has no single owner — fragmented"
      - "Layer retroactive to Track 1 = re-edit shipped artifacts"
  - id: D
    summary: "Continue Track 6 first, defer UP-06 to Track 7+"
    pros:
      - "No plan disruption"
    cons:
      - "Skills port lands in wrong layer — refactor cost when 5.5a ships later"
      - "Sync directive ignored until Track 7 = silent absorption of UP-06 priority"

chosen: A
chosen_rationale: |
  User explicitly directed in UP-06 §1: "biến việc 'sync' thành ưu tiên hàng đầu". Per UP-06
  doctrine (NO Silent File-Defaults), agent fired AskUserQuestion 2 rounds this session and
  user picked "Track 5.5 before Track 6 (Recommended)" + maximally ambitious sub-options.
  Layer first because Track 6 (skills/subagents port) depends on layer manifest — without
  it, skills land in wrong layer and must be moved later (paying refactor cost twice).
  Full Karpathy autoresearch infrastructure (OTEL+JSONL hybrid) chosen over lightweight
  because UP-06 §3 explicitly references "karpathy autoresearch loop" as the target shape.
  Multi-tenant DROPPED (skip option) per Round 2 — single-human pragmatic; /attach skill
  alone covers portability without permission/auth complexity.

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-04-29
    via: "S4 SessionStart audit + AskUserQuestion Round 1 (4 questions: scope routing / sync mech / layer depth / self-cap)"
  - actor: user
    action: ACCEPTED-ROUND-1
    at: 2026-04-29
    via: "AskUserQuestion picks: A (Track 5.5 before Track 6) / B+C+D+A (all 4 sync mechanisms multiSelect) / C (Full /attach + multi-tenant initially) / C (Aggressive Karpathy)"
  - actor: agent
    action: PROPOSED-ROUND-2
    at: 2026-04-29
    via: "AskUserQuestion Round 2 (4 questions: sequencing / multi-tenant scope / measurement stack / budget delta)"
  - actor: user
    action: ACCEPTED-FINAL
    at: 2026-04-29
    via: "AskUserQuestion picks: A (Layer→Sync→Self-Cap, rewrite Track 6) / D (Skip multi-tenant, /attach only) / B (OTEL+JSONL hybrid) / A (Accept ~1.5-2M total budget)"

verified_by:
  - mechanism: askuserquestion-explicit-pick
    at: 2026-04-29
    result: PASS
    notes: "8 explicit picks across 2 AskUserQuestion rounds; no defaults absorbed. UP-06 NO-Silent-Default rule respected."

affects:
  charter: false
  spec_files: []
  code_paths:
    - ".claude/manifest.yaml"           # NEW (5.5a)
    # - ".claude/stockforge/**"          # SUPERSEDED by REV-2 (tag-only via manifest; no physical subtree)
    - ".claude/skills/attach/**"         # NEW (5.5a)
    - ".claude/skills/sync-grilling/**"  # NEW (5.5b)
    - ".claude/skills/decompose-work/**" # NEW (5.5c)
    - ".claude/skills/try-n-approaches/**" # NEW (5.5c)
    - ".claude/agents/intent-vs-impl-diff.md" # NEW (5.5b)
    - "scripts/hooks/sync-grilling-trigger.sh" # NEW (5.5b)
    - "agent-workspace/memory/sync-state.md"   # NEW (5.5b)
    - "agent-workspace/memory/capability-map.md" # NEW (5.5c)
    - "docker/otel-stack/**"             # NEW (5.5c)
    - "scripts/hooks/component-telemetry.sh"   # MODIFIED (5.5c — JSONL schema extension)
  config_files:
    - ".claude/settings.json"            # hooks block extended for sync-grilling
  other_decisions:
    - D-002                              # AMENDED via REV-3 entry pointing here

depends_on:
  - D-002                                # Phase 0 plan that this amends

supersedes: null
superseded_by: null

defer_cycles: 0
re_attempt_prereq: "N/A — Track 5.5a starts S4 (next session)."

tags: ["phase-0", "track-5.5", "sync", "layer", "self-capability", "karpathy", "scope-amendment", "up-06"]
---

# Decision 003 — UP-06 Track 5.5 Insertion: Sync + Layer + Self-Capability Foundation

> **Status**: ACCEPTED 2026-04-29 via 2x AskUserQuestion explicit picks.
> **Amends**: D-002 Phase 0 design (insert Track 5.5 between Track 5 and Track 6).
> **Q&A audit**: `human-workspace/q-and-a/answered/2026-04-29-004-up06-track-5.5-amendment.md`.

---

## Context

UP-06 (`human-workspace/user_prompt/20260429_06.txt`) raised three strategic concerns and explicitly directed elevating "sync" to the #1 priority of the harness:

1. **Drift detection coverage** — across (a) agent harness config/settings, (b) implementation process (plans, sessions, logs), (c) project (scope, spec, requirements). User specifically observed that "sync questions" between human-LLM about *intent* of harness configuration are missing.
2. **Layer separation** — clear division between harness (reusable across projects), agent-workspace, human-workspace, project-specific. Foundation for "context injection" + portability (e.g., `/attach <new-project>`).
3. **Self-upgrade / Self-test** — Karpathy autoresearch loop style: measure → trace → evaluate → improve. Specifically requires a skill/agent that decomposes work into "deterministic" vs "LLM probability" portions.

User-provided directive: **"biến việc sync thành ưu tiên hàng đầu, giúp llm trở thành second brain thực sự."**

### Audit at decision time (S3 close)

**Drift detection — present**: D1-D8 hooks (S3 ship), `/drift-check`, `drift-detector` subagent, `/ul-audit`, `charter-coherence-spot.sh`, `post-tool-citation-grep.sh`, `taskcompleted-audit.sh`.

**Drift detection — missing**:
- "Sync drift" (human-LLM mutual understanding of harness intent)
- Intent-vs-implementation semantic diff (UP-NN vs current artifacts)
- Periodic auto-fired sync re-grilling (no "you haven't asked me about X for N sessions" trigger)
- Cross-session drift comparison

**Layer separation — present**: workspace dualism (`human-workspace/` vs `agent-workspace/`), constitution immutable, contracts.

**Layer separation — missing**: harness vs stockforge biz logic still entangled in `.claude/`; no manifest; no `/attach` skill; no global/personal/committed/non-committed layer rules.

**Self-upgrade — present**: `agent-notes.md`, `patterns-discovered/`, `mistake-log` (S5), telemetry hooks, Track 9 placeholder.

**Self-upgrade — missing**: deterministic-vs-LLM decomposer skill, capability-map artifact, Karpathy autoresearch loop framework, formal promotion path (`agent-notes` → `skill`/`hook`/`constitution`).

---

## Decision

**Insert Track 5.5 between Track 5 and Track 6 of D-002 Phase 0 plan, with three sub-tracks executed Layer → Sync → Self-Cap, then rewrite Track 6 based on the new layer manifest.**

### Sub-track 5.5a — Layer Foundation (~150K, 1 session = S4)

**Goals**:
- Author `.claude/manifest.yaml` — schema declaring scope of each artifact (`harness` portable / `stockforge` biz-specific / `hybrid` / `personal` non-committed)
- Directory restructure: move stockforge-biz skills/agents to `.claude/stockforge/` subtree; keep portable harness skills/agents/commands in `.claude/` root
- Author `/attach` skill — copies harness layer (excluding `.claude/stockforge/`) to a target project path
- Define layer rules: global (machine-wide) / personal (user-tagged, gitignored) / committed (in-repo) / non-committed (in-repo but gitignored)
- **NOT multi-tenant** (per Round 2 Q6=D) — single human assumption; future peer-share via git-fork

**Files affected**:
- `.claude/manifest.yaml` (NEW)
- `.claude/stockforge/skills/<biz-skill>/` (MOVE: candidates include `evidence-extraction`, `postgres-pgvector`, `crawler-reliability`, `fastapi-module`; final categorization happens in S4)
- `.claude/skills/attach/SKILL.md` + `references/` (NEW)
- `.gitignore` extended for personal/non-committed paths
- `.claude/settings.json` permissions adjusted for new paths

**Success**: manifest validates; restructured tree passes drift-signals-D1-D8 dry-run; `/attach` smoke-test copies harness to scratch dir + reproduces working CLAUDE.md skeleton.

### Sub-track 5.5b — Sync Infrastructure (~300K, 2 sessions = S5+S6)

**5.5b.1 — Intent-vs-Implementation Diff Agent (semantic, fresh-context)**
- New subagent `.claude/agents/intent-vs-impl-diff.md`
- Reads all `human-workspace/user_prompt/*.txt` + `agent-workspace/memory/decisions/*.md` + samples current artifacts
- Produces `agent-workspace/memory/drift-logs/intent-impl-<TS>.md` listing: aligned / drifted-soft / drifted-hard items
- Dispatched on-demand (mid-session) AND auto-dispatched at phase-boundary

**5.5b.2 — Sync-State Artifact**
- `agent-workspace/memory/sync-state.md` schema:
  - `confirmed-aligned` items (confirmed-via-AskUserQuestion + date)
  - `assumed-aligned` items (agent inferred but never explicitly verified)
  - `open-question` items (queued in observations or pending Q&A)
  - `drift-detected` items (from intent-vs-impl agent)
- Updated by hooks + manual entries + intent-vs-impl agent output

**5.5b.3 — Periodic Sync-Grilling Hook**
- `scripts/hooks/sync-grilling-trigger.sh` (SessionStart hook)
- Reads `last_sync_check` timestamp; if N sessions or M days elapsed → emit notification → agent fires AskUserQuestion sync-check next turn
- Threshold values configurable via `STOCKFORGE_SYNC_GRILL_INTERVAL_SESSIONS` env (default 3) and `_DAYS` (default 7)

**5.5b.4 — Sync-Specialized Q&A Template**
- `.claude/skills/grill-maximization/references/sync-bundle-template.md`
- Differs from feature/scope grills: questions phrased as "do we still understand X the same way?" not "what should we do about X?"
- Pairs with grill-maximization SKILL.md's bundle composer

**Success**: intent-vs-impl agent run on current state produces ≤5 drifted-hard items (proving early UP-NN alignment); sync-state.md populated with ≥20 entries; periodic-grilling hook fires successfully on dry-run with mock state.

### Sub-track 5.5c — Self-Capability + Karpathy Autoresearch Full (~400K, 2-3 sessions = S7+S8)

**5.5c.1 — `decompose-work` Skill (deterministic-vs-LLM-probability decomposer)**
- New skill `.claude/skills/decompose-work/SKILL.md`
- Input: task description (free-form)
- Output: structured analysis listing parts that are deterministic (script/hook/code) vs parts requiring LLM (reasoning/creative/judgment), plus integration plan
- Pairs with capability-map.md to inform "what LLM is good at vs not"

**5.5c.2 — `capability-map.md` Artifact**
- `agent-workspace/memory/capability-map.md`
- Living document: LLM strengths/limits per dimension (model × effort × task_class)
- Updated via promotion path: `agent-notes.md` entry → similarity-grouped → promoted to capability-map
- Read by `decompose-work` skill at decomposition time

**5.5c.3 — `try-n-approaches` Skill (Karpathy autoresearch loop)**
- New skill `.claude/skills/try-n-approaches/SKILL.md`
- Pattern: given a task, generate N approaches → evaluate via measurement framework → deepen most promising → loop
- Horizontal scaling (N parallel approaches via subagent dispatch) + vertical scaling (loop-deepen the best)

**5.5c.4 — OTEL Stack (formal traces)**
- `docker/otel-stack/docker-compose.yml` (collector + simple Jaeger or local file exporter)
- `packages/observability/otel_emitter.py` for instrumented Python code
- Hook integration: `component-telemetry.sh` extended to emit OTEL traces in addition to JSONL

**5.5c.5 — JSONL Telemetry Schema Extension**
- Extend `scripts/hooks/component-telemetry.sh` JSONL output with new fields: `task_id`, `approach_id`, `metric`, `outcome`
- Schema document at `agent-workspace/memory/self-awareness/jsonl-schema.md`

**5.5c.6 — Promotion Path Formalization**
- New skill `.claude/skills/promote-rule/SKILL.md` (or hook + agent combo)
- Reads `agent-notes.md` periodically; clusters similar entries; proposes promotion to skill/hook/constitution per Q-E3 priority (hook first, skill second, charter last)

**Success**: `decompose-work` smoke-test on a real Phase 0 task produces correct deterministic-vs-LLM split; `try-n-approaches` runs 3 parallel subagents on a thesis-exploration test case; OTEL traces visible in collector; capability-map.md has ≥10 seed entries from existing agent-notes; promotion path runs dry-run identifying ≥3 promotable rules.

### Track 6 — REWRITE (post-5.5, 1 session = S9)

**Original scope unchanged**: Discipline Skills + Subagents Port (B-14 from orch) + progressive-disclosure refactor of 12 existing skills + 13 commands (24 D1 LOC violations).

**Adjustment**: skills/subagents/commands now categorized by `manifest.yaml` (5.5a). New subagents from 5.5b (intent-vs-impl-diff) and 5.5c (decompose-work paired agent if needed) integrated. The progressive-disclosure refactor target list may shift if 5.5a moves files into `.claude/stockforge/`.

---

## Budget Delta

| Phase 0 segment | REV-2 estimate | REV-3 estimate (this) |
|---|---|---|
| Tracks 0-5 (already shipped through S3) | ~470K | ~470K (actuals) |
| **Track 5.5a** Layer | — | **~150K** (NEW) |
| **Track 5.5b** Sync (2 sessions) | — | **~300K** (NEW) |
| **Track 5.5c** Self-Cap full (2-3 sessions) | — | **~400K** (NEW) |
| Track 6 (skills+subagents port + refactor) | ~200K | ~150K (rewrite scope-aware via 5.5a) |
| Track 7 (constitution port + CLAUDE.md) | ~150K | ~150K |
| Track 8a (Confidence Score) | ~120K | ~120K |
| Track 8b (Memory L0/L1 extraction) | ~120K | ~120K |
| Track 9 (Self-Awareness + OTEL — overlap with 5.5c) | ~120K | ~80K (reduced — 5.5c covers OTEL setup) |
| Final verifier S-final | ~80K | ~80K |
| **TOTAL** | **~1.28M** | **~2.02M** |

User accepted "~1.5-2M total" via Round 2 Q8=A. Estimate lands at ~2.02M; within accepted band.

---

## Why (Reasons)

1. **UP-06 §1 directive elevation of sync is binding** (UP-NN files have higher priority than charter principles per `agent-workspace/CLAUDE.md` Reading Priority — "decisions/*.md are above charter principles").

2. **Layer-first sequencing reduces refactor cost** — Track 6 (skills port) lands cleanly after manifest exists; otherwise skills move twice (once into `.claude/`, once again into `.claude/stockforge/`).

3. **Sync 4-mechanism ensemble is defense-in-depth** — periodic grilling catches scheduled drift; intent-diff agent catches semantic drift; sync-state.md provides single-source-of-truth audit; sync Q&A template ensures questions are well-formed for "understanding" vs "implementation". Single mechanism would leave gaps.

4. **Aggressive Karpathy autoresearch matches stockforge mission** — financial advisory requires multi-perspective + measurement-driven calibration (charter principles). The autoresearch loop framework operationalizes both.

5. **OTEL+JSONL hybrid provides scale headroom** — JSONL alone suffices for current scale; OTEL adds standard tooling for future externalization (peer-share, cloud telemetry). Cost is ~200K one-time setup vs forever-locked-in custom.

6. **Multi-tenant explicitly skipped** to avoid scope creep. `/attach` covers project portability; if peer-share happens later, git-fork single-tenant pattern remains cleanest.

---

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Track 5.5 budget overshoots ~2M | Medium | Per-session budget watchdog (Track 5 hook) auto-reboots at 80% cliff. If 5.5c overshoots, descope c.4 OTEL to "design-only" + defer collector docker to Track 9. |
| Layer manifest 5.5a gets entire restructure wrong → cascading rework | Medium | Smoke-test `/attach` on scratch dir BEFORE moving any production skill; sandwich-verifier dispatch (fresh ctx) on manifest before S5 starts. |
| Sync grilling hook fires too often (annoying) | Low | Configurable threshold; default 3 sessions OR 7 days OR explicit user "sync now" command. Easy to tune. |
| Karpathy autoresearch over-engineered for current scale | Medium | Start with `try-n-approaches` skill smoke-test on real task; if signal weak, descope OTEL to design-doc-only. |
| Multi-tenant skip creates future regret if peer-share happens | Low | Documented escape hatch: git-fork single-tenant remains valid pattern; revisit if peer-share materializes (unlikely Phase 0-5). |
| 5.5c overlap with Track 9 self-awareness creates duplicate work | Low | Track 9 budget reduced to 80K (was 120K) reflecting 5.5c absorbs OTEL setup. Track 9 retained for live profile cards + aggregator hook (separate concern). |

---

## Open Questions

None blocking S4 start. Deferred design decisions (within 5.5a..c sub-tracks):
- Final categorization of which skills are `harness` vs `stockforge` (5.5a S4 decision)
- Sync grilling threshold defaults (5.5b S5+S6 decision)
- Approach-count cap for `try-n-approaches` (5.5c S7+S8 decision)

These are IMPL-tier (≤0.5 confidence threshold) — agent decides; subject to drift audit.

---

## Amendments (append-only)

### REV-2 (2026-04-29, S5-continuation) — Layer realization: tag-only via manifest (not physical move)

**Source**: AskUserQuestion fired in S5-continuation pre-flight when agent discovered 2 material costs of physical move not surfaced in S4-replan plan:
- Claude Code Skill tool only auto-discovers `.claude/skills/*/SKILL.md` — physical move to `.claude/stockforge/skills/` would lose auto-suggest of biz skills
- `AGENT_OPERATING_MANUAL.md` lines 581-593 hard-code old paths AND was deny-edit per settings.json (user later granted temporal Phase-0 override; orthogonal to layer-realization decision)

**User pick**: A (Tag-only via manifest) via 1 explicit AskUserQuestion pick (recommended option).

**Rationale**: D-003 § Open Questions explicitly delegated "Final categorization of which skills are harness vs stockforge" as IMPL-tier (≤0.5 confidence threshold; agent decides; subject to drift audit). The IMPL detail of "physical move vs tag-only" is downstream of categorization. Surfaced via AskUserQuestion per UP-06 NO-Silent-Default doctrine — user picked option that preserves auto-discovery + avoids AOM drift.

**Q&A audit**: `human-workspace/q-and-a/pending/2026-04-29-005-track-5.5a-layer-realization.md` (born-answered).

**Affects**:
- `.claude/manifest.yaml` — restructure `stockforge.skills_to_move:` → `stockforge.skills:` (no `target:` field; paths stay at `.claude/skills/`); update `attach.default_excludes` to list 5 individual stockforge skill paths instead of `.claude/stockforge/` directory wildcard
- `.claude/stockforge/skills/` subtree — NOT created (was in original D-003 affects.code_paths; now superseded)
- `AGENT_OPERATING_MANUAL.md` lines 581-593 — STAY VALID (paths unchanged); no AOM update needed for this amendment
- D-003 affects.code_paths — `.claude/stockforge/**` removed from new-paths list

**Why this matters going forward**:
- /attach skill (next Track 5.5a deliverable) reads manifest.yaml; per-path exclusion logic lists stockforge skill paths individually rather than glob `.claude/stockforge/`
- Layer separation is now LOGICAL (per manifest field), not PHYSICAL (per directory tree). Tradeoff: tree doesn't visually show separation; manifest is authoritative
- Future stockforge biz skills added: tag in manifest as `stockforge.skills`, place file at `.claude/skills/<name>/`; auto-discovery preserved
- Drift signal V1 still valid: every `.claude/skills/*/SKILL.md` path appears in exactly one layer (harness OR stockforge, not both)

**Status transition**: D-003 ACCEPTED → ACCEPTED-REV-2. No supersession (intent unchanged: insert Track 5.5; sub-track deliverables unchanged; only impl realization detail refined).

---

### REV-3 (2026-04-29, S9 PLAN) — UP-08 Track 5.5d insertion (sibling sub-track addition)

**Source**: UP-08 intake mid-S8; SCOPE-tier amendment authored as standalone D-005 to keep D-003 audit trail clean.

**Cross-reference**: see `agent-workspace/memory/decisions/005-up08-track-5.5d-self-learning-pipeline.md` (Track 5.5d added parallel to 5.5a/b/c; +~420K budget; sequence shifts +3 sessions; user-accepted via 5 AskUserQuestion picks across 2 rounds).

**Status transition**: D-003 ACCEPTED-REV-2 → ACCEPTED-REV-3 (additive amendment via sibling decision; no D-003 content change).

---

### REV-4 (2026-04-29, S15 PLAN → S16 IMPL ratification) — § 5.5c.5 `failure_mode` 8-code expansion

**Source**: S13 wire-in actuals + S14 Mode-D extension; documented in `agent-workspace/memory/sessions/2026-04-29-session-13.md` IMPL-S13-1 + `2026-04-29-session-14.md` L-S14-4 (autonomous_mode + Mode-D clean-handoff). Composed in S15 PLAN file `agent-workspace/session-plans/pending/003-S15-track-7-constitution-amendments.md` § 1.1; ratified S16 IMPL.

**Existing prose** (D-003 § 5.5c.5 JSONL Telemetry Schema Extension): mentions `failure_mode` field with 3-code prose (`B = build/runtime error / H = harness rejection / null = no failure detected`).

**Reality at S13 wire-in + S14 Mode-D**: 8-code expansion shipped via `correlate_failure_mode()` in `scripts/hooks/component-telemetry.sh` + `autonomous-stop-watchdog.sh`:

| Code | Meaning |
|---|---|
| `B` | Build/runtime error (Stop hook signals API/runtime exception) |
| `C` | Premature wind-down (budget-watchdog mode-C alert before cliff) |
| `D` | Clean handoff (S14 addition — checkpoint mtime ≤ 60s, no A/B/C) |
| `E` | Eval/test failure (deferred — placeholder for Phase 1+ test harness) |
| `H` | Harness rejection (PreToolUse deny exit code 2) |
| `R` | Retry/escalation (drift signal HIGH triggered re-dispatch) |
| `T` | Timeout (Bash timeout exceeded, hook killed) |
| `null` | No failure detected this event (success case) |

**Decision**: D-003 § 5.5c.5 prose updated to enumerate 8 codes (B/C/D/E/H/R/T/null) with semantics per S13 implementation + S14 Mode-D addition. The `mode_d` row reflects clean-handoff recovery (autonomous-stop-watchdog.sh extension shipped S14, paired with `continue-injector.ps1` for mid-session resume).

**Why append vs rewrite**: D-003 § 5.5c.5 is shipped scope; rewriting would obscure the wire-in date + Mode-D timing. Append-only preserves audit trail per `agent-workspace/CLAUDE.md` § Constitution rule on supersession.

**Status transition**: D-003 ACCEPTED-REV-3 → ACCEPTED-REV-4 (additive prose refinement; no scope change).

---

## Acceptance Record

- **2026-04-29**: PROPOSED by Claude Opus 4.7 (S4 SessionStart audit + AskUserQuestion Round 1)
- **2026-04-29**: ACCEPTED-ROUND-1 by user via AskUserQuestion picks (4 picks)
- **2026-04-29**: PROPOSED-ROUND-2 by agent (4 follow-up questions)
- **2026-04-29**: ACCEPTED-FINAL by user via AskUserQuestion picks (4 picks; total 8 picks across both rounds)

Status transitioned PROPOSED → ACCEPTED in same session via AskUserQuestion explicit picks (no defaults absorbed; UP-06 NO-Silent-Default rule respected).
