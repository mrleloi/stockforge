# StockForge Operational Inventory — Lifecycle, Quality, Workspace

> Documentation audit, 2026-05-19. Snapshot at git `main` HEAD (commit `10b6368`).
> Scope: session lifecycle, plan lifecycle, quality gates, workspace dualism, sandwich pattern.

---

## Topic A — Session Lifecycle

### A.1 Session Types

Eight session types are defined in `CLAUDE.md` § "Session Types" and
`agent-workspace/constitution/session-budgets.md` § "Session Types". Each is paired
with a budget envelope and a strict role boundary.

| Type | Budget (Opus) | Purpose | Role boundary |
|---|---|---|---|
| `PLAN` | 150-230K | Architect persona produces a plan file; never writes production code | `sandwich-architect` subagent (tools: `[Read, Glob, Grep, Write]`) |
| `FOCUSED_IMPL` | 100-150K | Implement 1-3 tasks from an existing plan; no re-plan | `sandwich-dev` subagent or main session |
| `MULTI_TASK_IMPL` | 200-330K | Implement 4-10 tasks; hard 250K cap → split required | `sandwich-dev` or main |
| `VERIFY` | 80-180K | Adversarial review of dev output; fresh-context separate agent | `sandwich-verifier` subagent (`[Read, Glob, Grep, Bash]` — no Write) |
| `RECOVERY` | 130-230K | Revert + re-plan after failure | Main session |
| `THESIS` | 100-180K | Multi-perspective stock analysis; read-only on code; bear case mandatory | Main session |
| `INGEST` | 80-150K | Process new data into KB; every row needs `source_url` + `extracted_at` | Main session |
| `POST_MORTEM` | 60-100K | Review thesis outcomes, update calibration | Main session |

The Opus column was recalibrated empirically across S345-S361 (`CLAUDE.md` §
"Session Types" "Opus-recalibration" note); Opus tokens/task ≈ 2-3× Sonnet for
architect+verifier, ≈ parity for dev. After user directive 2026-05-17 "full opus
+ follow budget", **all 14 subagents run on Opus**; main session must cite the
Opus column when dispatching (prevention rule M-S365-1).

Hard rules from `session-budgets.md`:

- **R-1: Never mix PLAN + IMPL** (Session 4 catastrophic failure).
- **R-2: Plans with >10 tasks MUST split.**
- **R-6: THESIS sessions are read-only on code.**
- **250K hard cap** — projected over → mandatory split.
- Quality cliff measured empirically across 51+ sessions: tasks/100K tokens drops from ~1.0 (focused) to ~0.5 (≥250K) to 0.0 (300K mixed-role).

### A.2 Mode A/B/C/D — Cliff vs Injector Dispatch

`session-budgets.md` § "Mode A/B/C/D" (D-020, ratified 2026-05-04) defines four
deterministic handoff modes keyed on the Opus 4.7 thresholds in D-004
(wind-down 180K / cliff 220K / hard cap 250K):

```
budget < 180K + checkpoint fresh   → Mode D (clean)
budget < 180K + no checkpoint      → Mode A (continue-injector mid-session)
180K ≤ budget < 220K                → Mode C (wind-down; handoff prep)
budget ≥ 220K                      → Mode B (cliff; session-self-reboot fresh ctx)
```

Mode selection is purely deterministic — no agent judgment. The dispatch is
performed by `scripts/hooks/autonomous-stop-watchdog.sh` (Mode A/D) or
`budget-watchdog.sh` → `session-self-reboot.sh` (Mode B/C).

### A.3 Session Protocol

From `CLAUDE.md` § "Session Protocol":

**Start (5 steps)**: read `current-execution.md` (router) → `project.md` (state) →
last 3 `memory/sessions/` files → check `session-plans/pending/` → run VBW before
writing.

**End (9 steps)**: update `project.md` if architectural decisions; write
`memory/sessions/YYYY-MM-DD-session-N.md`; update `current-execution.md`; append
new learned rules to `agent-notes.md`; ensure thesis-log entry exists; update
`mistake-log.md` (or explicitly state "no mistakes this session" — enforced by
`session-end-checklist-linter.sh`); verify Phase Goals coherence if new ADR;
auto-hooks then populate self-awareness profile cards (`profile-template-auto-populate.sh`)
and HARD-BLOCK at next SessionStart if ≥8 new lessons (`promotion-cycle-trigger.sh`).

### A.4 Real Session-Log Anatomy (S407, S408, S400 inspected)

A session log carries 4 layered structures: YAML frontmatter, prose summary,
verification block, mistakes attestation. Real shape from
`agent-workspace/memory/sessions/2026-05-17-session-407.md` (MULTI_TASK_IMPL,
sandwich-dev executing plan-044):

```markdown
---
session: S407
date: 2026-05-17
type: MULTI_TASK_IMPL
model: Claude Opus 4.7
plan: 044-S406-phase-gprime-g4-vhm-annual-report-dogfood-and-bc2-integration
phase: G-prime
sub_track: G.4 VHM PDF dogfood + BC-2 integration smoke
budget_target: 130-180K Opus
---

# S407 — Phase G.4 VHM PDF Dogfood + BC-2 Integration IMPL

## Summary
Executed plan-044 D1-D6 sub-tracks ...

## Tasks Completed
- [x] STEP 0.1 G.3 contract VBW ...
- [x] D1 apps/cli/_vnd_money_parser.py (58 LOC)
- [x] D2 apps/cli/_pdf_cell_mapper.py (191 LOC; 36-entry bilingual lookup)
- [x] D3 apps/cli/ingest_pdf_fundamentals.py (280 LOC; full pipeline CLI)
... (D4–D6, MODIFIED line)

## Verification
- mypy --strict (--explicit-package-bases): CLEAN on all new source + test files
- pytest packages/ tests/: 1185 passed, 1 skipped, 0 failures (baseline 1178 + 7 new)
- ruff check + ruff format: CLEAN
- import anthropic grep: ZERO matches in new files (D-050 CHARTER preserved)
- CLI --help: PASS

## Decisions Made
- DD-3 K.2.c CHARTER-TIER FLAG: NOT-FIRED (ADDITIVE-ONLY-DEFAULT; ZERO schema migration V0)
- DD-2 SourceProvider: SCRAPED_OTHER (existing enum; no new enum value needed V0)
... 

## Files Touched
New: apps/cli/_vnd_money_parser.py, apps/cli/_pdf_cell_mapper.py, ...
Modified (ADDITIVE): packages/infrastructure/fundamental/__init__.py

## Mistakes This Session
No mistakes this session. (All quality gates passed on first/second attempt; ...)

## Handoff
S408 sandwich-verifier AP-1 should:
1. Verify D-050 CHARTER (Grep "import anthropic" across ALL new files)
2. Verify K.2.c NOT-FIRED in ADR D-083
...
```

VERIFY-type logs (e.g. `2026-05-17-session-408.md`) add fields
`agent_id` + `duration_ms` + `parent_session` + `verdict` + `merge_eligible` +
`authored_inline_by`. They report **V1-V12 grid results**, CRITICAL/IMPORTANT/MINOR
counts, **promotion candidates** (`PC-1`/`PC-2`/...), and **compliance attestations**
against `AP-1` (fresh-context), `AP-23` (promotion discipline), `D-060` (no
verifier commits), `D4.A` (persona override — no Write).

The "no mistakes" line is load-bearing: `session-end-checklist-linter.sh` blocks
if neither a `M-S<N>-<M>` entry nor an explicit "no mistakes this session"
statement appears. Recent sessions 397, 399, 400, 401, 403, 404, 407, 408 all
contain one or the other.

---

## Topic B — Plan Lifecycle

### B.1 Master Plans

`agent-workspace/master-plans/` contains the top-tier roadmaps. Only one currently
exists: `2026-05-15-wave-1-research-integration.md` — the Wave 1 plan to mine 15
reference repos in `C:/htdocs/research/` for stockforge integration patterns.
Master plans are dispatched by the `master-planner` subagent (per its frontmatter
`author: master-planner subagent (dispatched from S322 main session)`), are
ratified via AskUserQuestion bundles (the file lists `ratification_gate: ≤4
AskUserQuestion items below`), and cover 16-22 sessions in budget envelope. The
file declares a `provenance_summary` block citing every binding source read at
authoring time (charter, constitution, prior post-mortems, decisions, research
notes).

Master plans **do not produce code**. They decompose into per-phase **sub-plans**
that land in `agent-workspace/session-plans/`.

### B.2 Session Plans — Lifecycle Directories

- `agent-workspace/session-plans/pending/` — authored, awaiting execution.
- `agent-workspace/session-plans/completed/` — executed; moved here on close.

Move is performed at IMPL session end (e.g. session 399 log records
`MOVED: agent-workspace/session-plans/pending/043-*.md → completed/043-*.md`).

### B.3 Plan Numbering Convention

Plans use a monotonically-incrementing 3-digit prefix
(`NNN-S<session>-<slug>.md`), with `NNN` reserved at authoring time. Current
high water mark: `046-S402-harness-stabilization-sweep-N2.md`. Gaps in the
sequence exist for historical reasons (some early Phase 1-3 plans). The `S<N>`
embedded in the filename is the **session in which the plan was authored**, not
the session that executes it. Plan-044 was authored at S406, executed at S407,
verified at S408.

### B.4 Plan Template Structure (from plan-044 and plan-045)

Plans are large (700-1100 LOC) and follow a consistent shape:

**Frontmatter (extensive YAML, often 30-60 fields):**

- `plan_id`, `target_session`, `type` (`FOCUSED_IMPL`/`OPERATIONAL`/...),
  `budget` (per-stage envelopes), `phase`, `track`
- `parent_plan` / `parent_master_plan` / `predecessor` / `successor`
- `architect`, `dispatched_by`, `authored`, `authoring_agent`, `executing_agent`, `status`
- `pre_flight_active` — list of active hooks/holds (e.g. `R1 destructive-command-guard.sh`)
- `depends_on` — every binding precondition file cited with `:line` numbers (VBW
  verified at authoring; re-verified at IMPL STEP 0)
- `binding_decisions` — decisions baked into the plan that dev cannot deviate
  from (typically 15-25 entries)
- `hard_rules_acknowledged` — restated invariants (no production code in PLAN
  session, no commits by architect, no charter writes, etc.)

**Body sections (recurring across all recent plans):**

- `A. Scope` — IN-scope deliverables, file-by-file
- `B. Out-of-scope` — DEFERRED items, each tagged with `Trigger:` for AP-7
  anti-vacuous-defer discipline
- `C. STEP 0 — VBW Live Verification` — sub-steps the dev MUST re-run at session
  entry to confirm cited line numbers still hold
- `D. Architecture Decisions (DDs)` — per-decision `Decision` / `Rationale` /
  `Alternative considered`
- `E.` — Sub-track decomposition (D1, D2, ... ; one per file/deliverable)
- `F.` — File scope (NEW / MODIFIED / OUT-of-scope explicit list)
- `G.` — DoD with **per-category LOC ceilings** (L-S397-1: core code vs tests
  vs docs vs ADR) + `PASS-N` smoke criteria
- `H.` — Risks + Mitigations (`RM-<sub-plan>-N`)
- `I.` through `N.` — Open questions, parallelism, dispatch sequencing

Real frontmatter excerpt from
`agent-workspace/session-plans/completed/044-S406-phase-gprime-g4-vhm-annual-report-dogfood-and-bc2-integration.md`:

```yaml
plan_id: 044-S406-phase-gprime-g4-vhm-annual-report-dogfood-and-bc2-integration
target_session: S407 (sandwich-dev FOCUSED_IMPL executing D1-D6; ... by sandwich-verifier AP-1 at S408)
type: FOCUSED_IMPL (6 sub-tracks D1-D6; PLAN session this file; ...)
phase: G-prime (Theme J — BC-2 Fundamental Data PDF + table extraction; ...)
parent_plan: agent-workspace/session-plans/pending/040-S391-phase-gprime-master-plan.md (PHASE-MASTER-PLAN ...)
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md § 5.5 + § 6.4.4
predecessor: 043-S398-phase-gprime-g3-claude-vision-adapter-and-echo-validator.md (G.3 SHIPPED at S399 ... VERIFIED PASS at S400; D-082 ACCEPTED ...)
successor: S407 sandwich-dev ... → S408 sandwich-verifier AP-1 (Phase G-prime CLOSE candidate ...)
status: pending-execution
binding_decisions:
  - "PHASE 1b CONSUMED + COLD-START DECLARED for task_class='pdf-dogfood-bc2-integration-plan' ..."
  - "G.4 USES G.3 ADAPTER ONLY (NOT G.2 winner-library adapter per RM3 BLOCK) ..."
  - "DD-3 schema-migration DECISION = ADDITIVE-ONLY-DEFAULT (per K.2.c CHARTER-TIER FLAG default ...)"
  ...
```

Plan-045 (`045-S393-data-corpus-ingestion-operational-plan.md`) demonstrates the
`type: OPERATIONAL` variant — no new production code; uses existing CLIs as data
runners; ships thesis-log artifacts. Its frontmatter additionally records
`status: COMPLETED 2026-05-17 S396 — corpus ingestion DONE` showing post-close
status overwrite.

---

## Topic C — Quality Gates

### C.1 Three Tiers (CLAUDE.md § "Quality Gates")

| Tier | Trigger | Author | Block on fail? |
|---|---|---|---|
| **Tier 1 — Deterministic** | Per commit | Automated hooks (`mypy --strict`, `pytest`, `ruff`, drift-signals HIGH, dependency cycle check) | YES (auto-block) |
| **Tier 2 — Probabilistic** | Per merge | Separate agent (spec alignment, architecture boundaries, UL consistency, code review, calibration drift) | Soft block (requires sign-off) |
| **Tier 3 — Human** | Per phase boundary or strategic decision | Human (architectural decisions, API contracts, eval regression, thesis quality review) | YES |

### C.2 Quality-Reports Directory — Empty in Practice

The directories `agent-workspace/quality-reports/{deterministic,probabilistic,drift-reports}/`
exist but **contain only `.gitkeep` files** at the current snapshot. The actual
quality-gate evidence lives at:

- **Deterministic results** — embedded in every IMPL/VERIFY session log under
  `## Verification` (pytest counts, mypy CLEAN, ruff CLEAN, grep checks).
- **Drift signal rollups** — `agent-workspace/memory/drift-logs/YYYY-MM-DD-rollup.md`,
  generated by `scripts/hooks/drift-rollup-daily.sh`. Example
  `2026-05-17-rollup.md`:

  ```
  - Total signals today: 959
  - HIGH: 434 / MEDIUM: 525 / LOW: 0
  - Distinct files referenced: 21
  - Signal breakdown:
      346 D1-LOC-CEILING
      244 D5-MISSING-CITATION
      165 D7-NO-BEAR-CASE
      126 D2-SELF-ATTEST
      59 D6-LLM-MATH
      19 DR3-LLM-NO-RETRY
  ```

- **Probabilistic verifier output** — captured in VERIFY-type session logs
  (`2026-05-17-session-408.md` etc.) and detailed observation files at
  `agent-workspace/memory/observations/sandwich-verifier-S<N>-*.md`.

The empty `quality-reports/` tree is therefore an architectural placeholder; the
operational pipeline routes deterministic gate output into session logs and
drift output into `drift-logs/` rollups.

### C.3 Drift Signals — DR1 through DR12 + Stock-Specific

`agent-workspace/constitution/drift-signals.md` defines twelve generic signals
plus stock-specific ones (DR-S*). Each is assigned to a tier:

**Tier-A — Automated (Stop-hook `drift-signals-D1-D9.sh`, every session-end):**
DR-A1 LOC ceiling, DR-A2 self-attestation drift, DR-A3 charter-bundled-with-sub-charter,
DR-A4 confidence without calibration, DR-A5 runtime-path-leak,
DR1 domain-imports-framework, DR3 LLM-call-no-retry, DR6 `Any`-in-domain,
DR8 cross-BC-direct-import, DR-S1 LLM-numeric-no-tool, DR-S2 thesis-no-bear-case,
DR2/DR5/DR10 (partial detection).

**Tier-B — Manual `/drift-check`:** DR4 hardcoded-prompt, DR7 UL-term-drift,
DR12 anti-pattern-from-agent-notes.

**Tier-C — DB query:** DR9 synthesis-no-verifier, DR11 stale-session-handoff.

**HIGH severity (blocks commit/merge)**: DR1, DR2, DR5, DR6, DR7, DR8, DR9,
DR-S1, DR-S2.

**MEDIUM**: DR3, DR4, DR10, DR12. **LOW**: DR11, DR-minor-*.

The two stock-specific signals are charter-load-bearing:

- **DR-S1**: LLM emitted a number without a tool call → violates I-S1
  (No LLM Math). Real money lost in finance hallucination.
- **DR-S2**: Thesis output without a substantive bear case → violates I-S10
  (Single-perspective thesis is an anti-pattern).

### C.4 VBW Protocol — Verify Before Write

`agent-workspace/constitution/vbw-protocol.md` distills the protocol from
measured failure analysis: pre-VBW baseline 11.1% hallucination on
methods/signatures, post-adoption 0%. Four checkpoints, none skippable:

1. **PRE-SPEC** — read actual source; list methods from code, not memory;
   mark items CURRENT vs PROPOSED.
2. **PRE-TEST** — verify every method call exists; type-check one file before
   writing a batch.
3. **MID-IMPLEMENT (every 5 steps)** — cross-reference against spec; re-read
   recent edits for convention-derived assumptions.
4. **PRE-COMMIT** — grep to verify imports; re-read diff; run mypy and tests.

Failure mode example documented in the protocol: agent wrote `enable_kill_switch()`
/`disable_kill_switch()` from convention; actual API is `toggle_kill_switch()`.
The plan structure (`STEP 0 — VBW Live Verification` section in every plan)
operationalizes this — dev re-reads cited `file:line` references at IMPL session
entry before D1 begins. Plan-044 § C lists 5 sub-steps including STEP 0.4
"COLD-PROBE on synthetic minimal-PDF" for full-pipeline verification
(L-S395-1 doctrine).

---

## Topic D — Workspace Dualism

### D.1 The Two-Workspace Contract

`agent-workspace/CLAUDE.md` and `human-workspace/CLAUDE.md` codify a hard
separation introduced by Decision 002 § Track 1. The split exists to prevent
two failure modes inherited from the sister project `orch`:

1. **Charter drift via shared-workspace mutation** (orch CF-DOGFOOD-2 post-mortem).
2. **Human cognitive overload from dense session logs**.

| Workspace | Owner | Agent writes | Agent reads |
|---|---|---|---|
| `agent-workspace/` | Agent | YES (freely, within constitution) | YES |
| `human-workspace/` | Human | NO — except `q-and-a/pending/` + `notifications/` | YES (authoritative) |

### D.2 `agent-workspace/` Subdirectories (14 listed)

`constitution/` (immutable absent human approval), `memory/project.md`,
`memory/current-execution.md` (THE routing source of truth — read FIRST every
session), `memory/agent-notes.md`, `memory/decisions/`, `memory/sessions/`,
`memory/observations/`, `memory/checkpoints/`, `memory/patterns-discovered/`,
`memory/drift-logs/`, `memory/post-mortems/`, `memory/thesis-log/`,
`memory/sync-tracker/`, `memory/self-awareness/`, `memory/mistake-log.md`,
`session-plans/{pending,completed}/`, `quality-reports/`, `ubiquitous-language/`,
`calibration/`, `research/`.

### D.3 `human-workspace/` Subdirectories (6)

| Path | Writer | Purpose |
|---|---|---|
| `user_prompt/` | Human only — immutable post-creation | Mid-flight scope drops; `YYYYMMDD_NN_<slug>.txt` |
| `decisions/` | Human only | Human strategic decisions; `D-H-<NNN>-<slug>.md` |
| `q-and-a/pending/` | **Both** (agent posts; human answers) | Q&A bundles per Grill Maximization (15-20 questions/bundle, max 25) |
| `q-and-a/answered/` | Human (manual mv) OR auto-mv hook | Resolved bundles; archive forever |
| `q-and-a/stale/` | Hook moves | Bundles past `expected_answer_by` |
| `notifications/` | Agent | INFO / SUMMARY / ALERT pushes to human |

### D.4 Auto-mv Rule (HH-E.2 / D-031)

Agent MAY mv a bundle `q-and-a/pending/` → `q-and-a/answered/` IFF **all four**
conditions hold (per `agent-workspace/CLAUDE.md`:102-108):

1. Frontmatter `status:` starts with `answered-`, `closed-`, or `resolved-`.
2. No `wait_until:` ISO-8601 timestamp greater than current epoch (per-bundle
   human veto).
3. Global pause file `human-workspace/q-and-a/.auto-mv-paused` does NOT exist.
4. The mv is performed by `scripts/hooks/qa-pending-auto-mover.sh` (Stop hook).
   **Direct `mv` invocation by agent is forbidden** — only the validated hook
   path is authorized.

### D.5 Communication Channels

- **Human → Agent**: `user_prompt/` (immutable; full re-read at every phase
  entry per AP-5) and `decisions/`.
- **Agent → Human**: `notifications/` (INFO/SUMMARY/ALERT) and
  `q-and-a/pending/` (only when something is genuinely above ARCH-tier
  confidence threshold or charter-affecting).
- **Bidirectional**: `q-and-a/answered/` (agent writes pending, human writes
  answers, hook or human moves).

The `human-workspace/CLAUDE.md` self-check before writing a pending bundle:
*"Is this question genuinely something the human must decide?... If the answer
to any is 'I'm not sure' — DON'T write the bundle."*

---

## Topic E — Sandwich Pattern

### E.1 The Three Personas

Defined under `.claude/agents/`:

- **`sandwich-architect.md`** — model: opus; tools: `[Read, Glob, Grep, Write]`.
  Plans only. Never writes production code. Phase 1b mandatory if plan has ≥3
  sub-tracks (reads `.planner-stats.tsv` + `sessions-rollup.tsv` +
  `dispatch.jsonl` + `mistake-log.md` for empirical calibration).
- **`sandwich-dev.md`** — model: opus; tools: `[Read, Glob, Grep, Write, Edit, Bash]`.
  Executes plan as-written. Does NOT re-plan; flags issues to human instead of
  silently deviating. STEP 0.10 mandates baseline-capture of any CLI/script
  before editing.
- **`sandwich-verifier.md`** — model: opus; tools: `[Read, Glob, Grep, Bash]`
  ONLY — **no Write or Edit**. Fresh context (AP-1). Returns findings inline;
  main session inline-persists per M-S397-1 canonical pattern. Persona
  override codified in plan-046 D4.A explicitly: *"Do NOT Write
  report/summary/findings/analysis .md files. Return findings directly as your
  final assistant message — the parent agent reads your text output, not files
  you create."*

The mandate that verifier MUST be a separate agent comes from `session-budgets.md`:
*"Must be separate agent. Same-agent review = echo chamber."* This is also
anti-pattern AP-1 in `agent-workspace/CLAUDE.md` § Anti-Patterns.

### E.2 Real Sandwich Trace — Phase G-prime G.3 + G.4 (sessions 392-408)

Tracing the plan-043 → plan-044 sequence from session logs:

```
G.3 sub-track
─────────────
S398   sandwich-architect  → plan-043 (ClaudeVisionPdfTableExtractor + EchoValidator)
S399   sandwich-dev        → IMPL D1-D5 (5 sub-tracks; 51 new tests; ADR D-082 PROPOSED)
                              commit b736640 (+1525 insertions, 11 files)
                              pytest 1178/1; mypy CLEAN; ruff CLEAN; ZERO import anthropic
S400   sandwich-verifier   → VERIFY (~120K Opus; agent a18214d3d72b99c53)
                              VERDICT: PASS / merge-eligible
                              0 CRITICAL / 0 IMPORTANT / 3 MINOR; D-082 → ACCEPTED
                              G.3 done; G.4 dispatch UNBLOCKED

G.4 sub-track
─────────────
S405   sandwich-architect  → CRASH at 64K output token cap (M-S405-1)
                              prevention rule L-S405-1 named
S406   sandwich-architect  → plan-044 retry (success; OUTPUT cap honored)
S407   sandwich-dev        → IMPL D1-D6 (CLI + mapper + parser + 7 integration tests
                              + thesis-log TEMPLATE-V0 + ADR D-083 PROPOSED-AT-IMPL)
                              commit 6a67bee
                              pytest 1185/1 (1178 baseline + 7 new); ZERO regressions
S408   sandwich-verifier   → VERIFY (~101K Opus; agent a6a53e1826fb7a16b)
                              VERDICT: PASS-WITH-CONCERNS / merge-eligible
                              0 CRITICAL / 3 IMPORTANT / 5 MINOR; D-083 → ACCEPTED
                              Phase G-prime 3/4 sub-plans SHIPPED+VERIFIED
                              (G.2 reserves carry-forward on RM3 user-action)
```

### E.3 Verifier Verdict Schema

Verifier verdicts use a small enum: `PASS` / `PASS-WITH-CONCERNS` / `FAIL`. Both
PASS and PASS-WITH-CONCERNS are merge-eligible; the distinction is process-tier
not architecture-tier. Each verdict carries:

- A V1-V12 grid (V1-V10 historically; V11-V12 added at G-prime per dispatch
  briefs). Each V<N> is PASS or PASS-WITH-NUANCE or FAIL.
- A finding budget: CRITICAL / IMPORTANT / MINOR counts (CRITICAL > 0 = FAIL).
- Promotion candidates (`PC-<session>-<N>`) for lessons that may need
  promotion to hook / skill / charter on 2nd-instance recurrence (AP-23).

### E.4 Real ADR Excerpt — D-083 (the close-out of the sandwich)

`agent-workspace/memory/decisions/083-vhm-pdf-dogfood-and-bc2-integration.md`
shows what an ACCEPTED IMPL-tier ADR looks like at sandwich close:

```yaml
---
id: D-083
title: "VHM PDF Dogfood + BC-2 SqliteFundamentalRepository Integration (Phase G.4)"
status: ACCEPTED
severity: LOW
date: 2026-05-17
phase: G-prime
proposed_at: 2026-05-17T22:00:00+07:00
accepted_at: 2026-05-17T23:55:00+07:00
acceptance_basis: "S408 sandwich-verifier PASS-WITH-CONCERNS / merge-eligible
  (agent a6a53e1826fb7a16b; 0 CRITICAL / 3 IMPORTANT / 5 MINOR; concerns are
  process-discipline not architecture); IMPL-tier auto-ratifies per parent
  plan-040 § DD-8 + severity-schema. pytest 1185/1 EXACT match + mypy --strict
  + ruff CLEAN + ZERO import anthropic empirically verified. K.2.c NOT-FIRED
  confirmed (ADDITIVE-ONLY-DEFAULT preserved; ZERO schema mods ...)."
sub_track: "G.4 — VHM annual-report dogfood + BC-2 integration smoke"
session: S407
authored_by: "sandwich-dev S407 (Claude Opus 4.7; MULTI_TASK_IMPL; plan-044 IMPL)"
depends_on:
  - D-080 (PdfTableExtractorPort ABC + ExtractedFinancialStatement + PdfSource — G.1 ACCEPTED)
  - D-082 (ClaudeVisionPdfTableExtractor + EchoValidator + Rule 16 mode #2 — G.3 ACCEPTED)
  - D-050 (anthropic_api_to_subagent CHARTER — ZERO import anthropic; subscription billing)
  - D-059 (Python determinism contract ...)
  - D-064 (path-safety 5-invariant ...)
  - D-065 (Rule 16 mode #2 ...)
supersedes: ""
superseded_by: ""
revisit_trigger: |
  (a) BC-9 Outer-Loop consumer requires source_pdf_url/page in citation surface
      → Phase 2 entry ADDITIVE migration of FinancialStatement schema (DD-3 deferred fields);
  (b) G.2 unblocked (RM3 resolved) → G.4-V2 PLAN session for per-adapter comparison;
  (c) n≥20 extracted FS records → Charter Principle 8 calibration regime entry;
  (d) IS smoke PASS → BS+CF expansion at Phase G-prime-V2 OR Phase 2 entry ...
---
```

The 13-field frontmatter exceeds the 12-field floor mandated by L-S389-2; the
body provides DD-1 through DD-7 with the same `Decision` / `Rationale` /
`Alternative considered` triplet pattern as plan-044's § D, plus a `K.2.c
CHARTER-TIER FLAG STATUS: NOT-FIRED` attestation that closes the parent plan's
gating question.

Compare against `agent-workspace/memory/decisions/_template.md`, which is the
larger canonical 12-field schema (with `intent_classification`,
`options_considered`, `approval_chain`, `verified_by`, `affects`, `defer_cycles`,
`tags` blocks). Recent IMPL-tier ADRs (D-080, D-082, D-083) use a streamlined
variant focused on the operational fields (status, severity,
acceptance_basis, depends_on, revisit_trigger); the full template's
optional sections are largely vestigial for IMPL-tier decisions but retained
for CHARTER/SCOPE/ARCH-tier work.

---

## Cross-references

- `CLAUDE.md` (project root) — Session Types, Quality Gates, Hard Rules, Session Protocol
- `agent-workspace/constitution/session-budgets.md` — quality cliff, R-1..R-6, Mode A/B/C/D
- `agent-workspace/constitution/drift-signals.md` — DR1..DR12 + DR-S1/S2 + tier map
- `agent-workspace/constitution/vbw-protocol.md` — four checkpoints
- `agent-workspace/CLAUDE.md` — workspace contract + auto-mv rule + reading priority
- `human-workspace/CLAUDE.md` — write boundaries + self-check
- `agent-workspace/memory/decisions/_template.md` — full ADR schema (12+ fields)
- `.claude/agents/sandwich-{architect,dev,verifier}.md` — persona contracts
- Real sessions: `2026-05-17-session-{397,399,400,401,403,404,407,408}.md`
- Real plans: `session-plans/completed/043-S398-*`, `044-S406-*`, `045-S393-*`, `046-S402-*`
- Real ADRs: `decisions/{080,081,082,083}-*.md`
- Drift rollups: `agent-workspace/memory/drift-logs/2026-05-17-rollup.md`
