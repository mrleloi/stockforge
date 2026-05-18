# Constitution + Memory Inventory — StockForge

Audit date: 2026-05-19. Read-only inventory of `agent-workspace/constitution/` (17 files) and `agent-workspace/memory/` (20 top-level files + 14 subdirectories).

---

## 1. Constitution Layer (17 files)

Path: `C:\htdocs\stockforge\agent-workspace\constitution\*.md`. Edit/Write blocked by `.claude/settings.json` deny list; bypass requires explicit user gate. Ratification status carried in YAML frontmatter (`status:` `CHARTER` | `ACCEPTED` | `PROPOSAL` | absent=baseline).

| File | Scope | Key rules enforced | Mutability |
|---|---|---|---|
| `architecture.md` | Clean Architecture + 9 BCs (BC-1..BC-9) + stack lock (Python+TimescaleDB+pgvector+Redis+Claude API) + LLM-substrate-boundary patterns (BP-S43b-1/2/3) | Domain has zero framework deps; cross-BC via `packages/contracts/`; Slash-vs-Skill split (D-018, LOC≤120/150); rich (not anemic) domain; CQRS-light; **No-LLM-Math pattern** | CHARTER (immutable; v1.0 2026-04-23) |
| `autonomous-protocol.md` | Defines `autonomous_mode=true` as ONLY mode; Mode A/B/C/D handoffs; Skill-tool gating; drift self-detect (A+B+C); AskUserQuestion scope; cost-substrate; Mode-E defection ban | Rules 1-10 binding; e.g. Rule 10 forbids "(a)/(b)/(c)" enumeration to user in autonomous loop | CHARTER (D-015 ratified 2026-05-01; D-023 amendment 2026-05-04; D-030 Rule 10 added) |
| `boundaries.md` | 14 hard boundaries (B-1..B-14) + 8 soft boundaries (SB-1..SB-8) | B-1 never modify `PROJECT_CHARTER.md`; B-2 never modify `constitution/*`; B-3 never write `obsidian-vault/raw/`; B-4 commit OK / push human-only; B-11 never override risk rules; B-13 thesis-log append-only | CHARTER (immutable) |
| `coding-principles.md` | AI-first coding rules — types-first, explicit-over-implicit, one-concept-per-file, no LLM math, no Pydantic in domain (D-1..D-4) | <30 LOC functions; domain dataclasses; repositories as Protocols; prompts as data (loaded from `prompts/`); test pyramid; BDD for behavior | CHARTER |
| `decision-discipline.md` | Tier-vs-default-acceptance (CHARTER/SCOPE/ARCH/IMPL); IMPL-tier doctrine (L-S11-2); promotion target priority hook→skill→charter (Q-E3); promotion cadence (5-session OR phase-boundary); lesson-synthesis mandatory at session-end | Rule 4a enforced by `promotion-cycle-trigger.sh`; Rule 4b strict-mode `lesson-synthesis-watchdog.sh` | CHARTER (D-016 ratified 2026-05-01; D-026 Rule 4b added) |
| `drift-signals.md` | DR1-DR12 + DR-S1/S2 stock-specific + tiered coverage map (Tier-A auto / Tier-B manual / Tier-C DB-query) | HIGH: DR1 (domain framework imports), DR2 (no source_url), DR-S1 (LLM math), DR-S2 (no bear case); MEDIUM: DR3 (LLM call no budget), DR4 (prompt outside `prompts/`); LOW: DR-minor-1 `print()` | CHARTER (D-029 reconciliation 2026-05-05) |
| `financial-data-protocol.md` | 16 stock-domain rules: point-in-time integrity, survivorship, adjustment-tagging, source attribution, currency discipline, LLM provenance, sentiment calibration, anti-look-ahead, KOL provenance, backtest reproducibility, hook portability per phase, T+2.5 settlement, room ngoại, Sàn data quality, FX VND-USD, **Rule 16 numeric-field discipline (D-065/I-S1-1)** | Repository pattern enforces (e.g. `get_as_of()`); `EchoValidator` for numeric LLM echo; `ForeignOwnershipState` saturation alert | CHARTER (D-019/D-021 amendments 2026-05-04; D-065 Rule 16 added 2026-05-16) |
| `harness-health-protocol.md` | HH-1..HH-12 empirically-verifiable signals (Stop hook fires, UserPromptSubmit fires, promote-rule cycle, Auto-detect orphans, Tier-1 ceiling, dispatch-pending JSONL freshness, checkpoint freshness, charter md5, mistake-log discipline, firing-test coverage, .session-hooks.log mtime, project/current-execution phase coherence) | 4-color aggregation GREEN/YELLOW/RED-1/RED-2+; `harness-health-self-scan.sh` runs on UserPromptSubmit+SessionStart with <2s budget | CHARTER v1.0 ratified S173; mv-to-constitution at S220 D-048; D-056 Charter Principle 11 ratification |
| `invariants.md` | General invariants I-1..I-52 across data/code/process/privacy/cost/quality | I-1 every claim has source_url; I-10 zero framework deps in domain; I-12 no `Any` in domain; I-23 constitution never modified by agent; I-25 deterministic gates pass; CRITICAL/HIGH/MEDIUM/LOW severity | CHARTER (split out I-S* to `invariants-stockforge.md` at S48l 2026-05-05) |
| `invariants-stockforge.md` | Stock-domain I-S* invariants — I-S1 (No LLM Math, CRITICAL), I-S1-1 (numeric-field discipline), I-S2-S7 (point-in-time, survivorship, adjustment, source, currency, confidence-vs-hit-rate), I-S10-S13 (bear case mandatory, multi-perspective), I-S20-S22 (KOL outcome tracking), I-S26-S65 (post-mortem cadence, scraping ToS, disclaimer, VN settlement) | Schema NOT NULL + repository pattern + critic agent + categorical surrogates over numeric LLM outputs | CHARTER (D-022 VN amendments 2026-05-04) |
| `karpathy-principles.md` | P1 Think-Before-Coding; P2 Simplicity-First; P3 Surgical-Changes; P4 Goal-Driven-Execution | Bias toward caution-over-speed for non-trivial work; conflict ordering P1>P4, P2>P3 | CHARTER (immutable) |
| `memory-routing-tree.md` | Project-memory vs user-memory horizontal routing tree (Q1/Q2/Q3 decision tree) | NEVER write project-substrate to user-memory; NEVER write user-role context to project memory; when ambiguous → project memory canonical | CHARTER (D-024 ratified 2026-05-04) |
| `memory-tiers.md` | Tier 1 immutable bootstrap (≤8K tokens — CLAUDE.md + agent-workspace/CLAUDE.md + current-execution.md + checkpoint/latest.md); Tier 2 just-in-time; Tier 3 explicit-pull (older sessions, decisions/, observations/, drift-logs/, post-mortems/, thesis-log/) | Hard exclusion: `learning-data/{events,archive}/` write-only NDJSON; `tier1-bloat-check.sh` hook enforces ceiling | CHARTER (D-017 ratified 2026-05-01) |
| `portability.md` | L-S208-1 settings.json hook-command portability — NO bash-inline-env-var-prefix in `"command":` (Windows runtime silent-fail); use `bash -c '...'` wrapper instead | Auto-detect by `settings-inline-env-prefix-detector.sh`; pairs with L-S11-1 general Windows portability | PROPOSAL pending Cluster C charter Q&A bundle (companion hook shipped S212; skill subroutine S213) |
| `session-budgets.md` | 8 session types (PLAN/FOCUSED_IMPL/MULTI_TASK_IMPL/VERIFY/RECOVERY/THESIS/INGEST/POST_MORTEM) with budget bands; 250K hard cliff; Mode A/B/C/D dispatch deterministic rules; verifier budget by scope | R-1 never mix PLAN+IMPL; R-2 split >10 tasks; R-3 recovery reverts first; R-6 THESIS read-only on code | CHARTER (D-020 Mode A-D added 2026-05-04) |
| `severity-schema.md` | Unified 4-level CRITICAL/HIGH/MEDIUM/LOW system + artifact-field mapping table + state file schema | CRITICAL auto-blocks autonomous via `.autonomous-BLOCKED` flag; HIGH fires AskUserQuestion within 6h; MEDIUM weekly digest; LOW log only | CHARTER (ratified S310 2026-05-14; enforcement chain via `severity-classifier.sh` + `escalation-engine.sh` + `autonomous-block-enforcer.sh` + `telegram-push.sh`) |
| `vbw-protocol.md` | Verify-Before-Write — 4 checkpoints PRE-SPEC, PRE-TEST, MID-IMPLEMENT (every 5 steps), PRE-COMMIT | Measured impact: 11.1% hallucination → 0%; mandatory before writing specs/tests/code; tools: grep + mypy --strict + Read actual source | CHARTER (immutable; v1.0) |

---

## 2. Memory Layer Inventory

Path: `C:\htdocs\stockforge\agent-workspace\memory\`. Mix of editable state files, append-only journals, telemetry streams, subagent return artifacts.

### 2A. Top-level files

| File | Purpose | Mutability | Retention | Primary reader |
|---|---|---|---|---|
| `project.md` | High-level project state, Phase Goals Tracker (Phase 0-5), last 5 ADRs inline | Editable (phase-boundary + ADR landing) | Keep last 5 ADRs inline; older summarized | All agents; Tier 2 just-in-time |
| `current-execution.md` | THE single routing source of truth: active phase/track, autonomous_mode flag, recent session summaries (last 5 sessions inline) | Editable per session | ≤5 sessions inline / ≤200 LOC; older to `current-execution-archive-YYYY-MM-DD-S<from>-to-S<to>.md` (`tracking-retention.sh`) | All agents at SessionStart (Tier 1) |
| `agent-notes.md` | Learned rules from real experience (post-mortem/drift/user correction); promote-rule consumer | Append-mostly | Digest only ≤700 LOC; archive `agent-notes-archive-YYYY-MM-DD.md` | `promote-rule` subagent; lesson-synthesis-watchdog |
| `mistake-log.md` | Structured failure catalog M-S<N>-<M> entries: what / root cause / prevention / severity / fix path | Append-only | Digest only ≤200 LOC; archive `mistake-log-archive-YYYY-MM-DD.md` | Pre-flight read by all agents (Tier 2); session-end-checklist-linter |
| `capability-map.md` | Living document: model × effort × task_class → confidence/limit observations; sparse cells | Append-only (cell-level transitions annotated) | Long-lived; growing | `decompose-work` skill; `promote-rule` writer; `try-n-approaches` S9 consumer |
| `sync-state.md` | Sync-grilling narrative log (5 categories: LANGUAGE / DOMAIN_UBIQUITOUS / DESIGN_THINKING / SCOPE / DECISION_ROUTING); per-session delta entries | Append + last-check field edit | Long-lived | Sync-grilling cadence hooks; `sync-pull` skill on-demand |
| `dispatch.jsonl` | Subagent dispatch lifecycle events (DISPATCHED / COMPLETED) keyed on `dispatch_id` | Append-only NDJSON | Long-lived; backfilled by `dispatch-jsonl-backfill.sh`; backup `.backfill-backup-YYYYMMDDHHMMSS` retained | `in-flight-subagent-watcher.sh`; `dispatch-jsonl-recorder.sh` |
| `cost-ledger.tsv` | TSV cost ledger: timestamp / session_id / actor / model / tokens_in / tokens_out / cache_read / cache_create / cost_usd / hook_event | Append-only | Long-lived (~888 rows current) | `cost-ledger-recorder.sh`; `budget-watchdog.sh` |
| `attestation-log.tsv` | Sandwich attestation: ts / dispatch_id / observation_passed / empirical_passed / divergence / verdict | Append-only | Long-lived (~34 rows) | `post-dev-dispatch-attestation-check.sh`; `dogfood-the-promotion.sh` |
| `personal-risk-profile.md` | User-fill template: holding period, position sizing, sector limits, stop loss, risk rules (above charter floor) | User-editable; values bind RiskRule code | Long-lived | Phase 1+ portfolio/risk-management code; thesis-template consumer |
| `routing-config.md` | Model × effort × thinking config: main session = Opus 4.7 medium; subagent matrix (architect/verifier/dev/etc.) | Editable (S65 ratification) | Long-lived | Main session at dispatch time; orchestration logic |
| `boot-summary.md` | Auto-rendered compact bootstrap context (last 5 ADRs + last 3 mistakes + in-flight dispatches); TTL 1h | Auto-rendered (`bootstrap-summary-renderer.sh`) | Stale > 1h → fall back to full chain | Reboot/SessionStart |
| `component-telemetry.jsonl` | NDJSON per-event component telemetry: ts / component_type / component_name / trigger / outcome / tokens_real / duration_ms / session_id / failure_mode / cache_read_tokens / cache_creation_tokens | Append-only | ≤10 MB; weekly rotate `telemetry-rotate.sh`; 4-week retention | `component-telemetry.sh`; `self-awareness-aggregate.sh`; `metric-failure-mode-rate.sh` |
| `up-intake-log.md` | Append-only ledger of `human-workspace/user_prompt/*.txt` intake + resolution status (UP-NN → closed-by-D-NNN) | Append + status field edit | Long-lived | `stale-prompt-detector.sh` UserPromptSubmit hook |

Archives (also at top level): `current-execution-archive-*.md` (4), `agent-notes-archive-*.md` (1), `mistake-log-archive-*.md` (1).

### 2B. Subdirectories

| Path | Purpose | Naming convention | Lifecycle |
|---|---|---|---|
| `checkpoints/` (32 files) | Session handoff state for self-reboot. `latest.md` canonical; timestamped historical archives | `YYYY-MM-DD-S<N>-close.md` + `latest.md` pointer | Append + `latest.md` updated each checkpoint; Track 5 deliverable |
| `decisions/` (90+ ADRs) | Sequential ADRs with 12-field schema + supersession-via-status | `NNN-<kebab-case-slug>.md` (zero-padded 3-digit) + `_template.md` + `README.md` | Append-only; supersede via `status:` field — never delete |
| `sessions/` (257 files) | One per session: what happened, decisions made, files touched | `YYYY-MM-DD-session-N.md` | Append-only; Tier 3 explicit-pull (older than last 3) |
| `observations/` (212 files) | Subagent return artifacts — each subagent dispatch writes one observation describing what it did | Mostly `YYYY-MM-DD-S<N>-<topic>.md` + `promote-rule-S<N>-*.md` (HH-3 watched) | Append; periodic aggregation; `session-start-scan-unattested-observations.sh` checks attestation |
| `drift-logs/` (17 files) | Drift-check outputs (DR1-DR12 + DR-S*); auto + on-demand | `YYYY-MM-DD-<topic>.md` + `<DATE>-rollup.md` | Time-series append; `drift-rollup-daily.sh` Stop hook; `drift-signals-log-rotate.sh` |
| `post-mortems/` (7 files) | After significant failure or thesis-revoked event; RCA + prevention rule | `YYYY-MM-DD-<topic>.md` or `YYYY-MM-DD-{TICKER}-horizon{Nm}.md` | Append; Tier 3 |
| `patterns-discovered/` (6 files) | Pattern mining outputs (Track 0 DONE) + ongoing catalog (AP-1..AP-23) | `SYNTHESIS.md` + per-pattern files | Append; READ-ONLY for production code; patterns promoted via `promote-rule` |
| `self-awareness/` (28 files) | Model × effort × task_class profile cards + `known-issues.md` + `best-practices.md` + telemetry rollup TSV | `profiles/<model>-<effort>-<task_class>.md` + `sessions-rollup.tsv` + schema/design docs | Live updated by Stop-hook `self-awareness-aggregate.sh`; `profile-template-auto-populate.sh` |
| `sync-tracker/` (5 files) | Track 8a Confidence Score System: `events.tsv` (append-only) + `state.tsv` (computed 5 rows) + `weights.yaml` (manual tune) + `_index.md` (auto-rendered) + `README.md` | Per-file fixed | Live updated by hooks `sync-tracker-update.sh` + `sync-tracker-render.sh` |
| `indexes/` (4 files) | Registry TSV indexes for cross-reference | `decision-registry.tsv` + `hook-registry.tsv` + `lesson-registry.tsv` + `mistake-registry.tsv` | Auto-rendered by `index-registry-renderer.sh` |
| `etl-queue/` (243 files) | ETL job queue for memory promotion pipeline | `<priority>-<timestamp>-<slug>-complete.job` + `processed/` subdir + `README.md` | FIFO queue; `memory-etl-processor.sh` consumes; `learning-queue-sweeper.sh` |
| `handoff-logs/` (130 files) | Auto-cliff handoff event logs | `auto-cliff-<unix_ms>.log` | Append per handoff; budget-watchdog driven |
| `telemetry-archive/` (2 files) | Rotated weekly telemetry archives | dated rotation | 4-week retention per `telemetry-rotate.sh` |
| `thesis-log/` (50 files) | Stock-domain thesis exploration entries — append-only historical records (B-13 enforced) | `YYYY-MM-DD-{TICKER}.md` | Append; READ-ONLY for IMPL sessions; never edit past entries; revisited per calibration |

Additional non-canonical: `.dispatch-pending-archive/`, `.precompact-snapshots/`, `drift-signals-archive/`, `session-hooks-archive/` (rotation destinations). Hundreds of `.cache-*` / `.fired-*` / `.marker-*` flag files (transient hook state, not user-facing memory).

---

## 3. Decision Discipline (ADR) Deep-Dive

ADRs land in `agent-workspace/memory/decisions/NNN-<slug>.md`. Sequential numbering, never reused. Currently 90+ decisions (D-001 through D-074+ as of S375 2026-05-17, with several `S2X0+` slots reserved for the historical promotion chain).

**Status legend** (per `decisions/README.md`):
- `PROPOSED` — authored, awaiting user confirmation
- `ACCEPTED` — user confirmed; binding
- `SUPERSEDED-BY-D-NNN` — pointer-based supersession; original stays on disk
- `REVOKED` — reversed without replacement; triggers post-mortem (6-step protocol)

**Decision levels with confidence thresholds**:
- `CHARTER` 0.99 (identity/mission/autonomous-mode)
- `SCOPE` 0.90 (phase plan / multi-track / BC count)
- `ARCH` 0.80 (library / schema / hook architecture)
- `IMPL` 0.50 (file layout / naming / refactor pass)

Below threshold → MUST open Q&A bundle.

**Amendments**: in-place `REV-N` for ≤30% content change with scope unchanged (status becomes e.g. `ACCEPTED-REV-2`); new file for >30% or scope shift (with `supersedes:` pointer).

### Canonical 12+ field schema (verbatim from `decisions/_template.md`)

```yaml
id: D-NNN-slug                         # sequential; never reused
title: <human-readable title>          # short, declarative
date: YYYY-MM-DD                       # creation date (initial PROPOSED)
status: PROPOSED                       # PROPOSED | ACCEPTED | SUPERSEDED-BY-D-NNN | REVOKED
level: IMPL                            # CHARTER | SCOPE | ARCH | IMPL (thresholds 0.99/0.90/0.80/0.50)

author:                                # who proposed
  - "Claude Opus 4.7"                  # model identity
  # - "user"                           # add when user-authored

source_evidence:                       # every claim must trace; empty = INSUFFICIENT-EVIDENCE flag
  - path: human-workspace/user_prompt/YYYYMMDD_NN_<slug>.txt
    quote: "<verbatim user phrase>"
  - path: agent-workspace/memory/patterns-discovered/SYNTHESIS.md
    section: <section anchor>

intent_classification:                 # omit if not from user prompt
  primary_intent: <SCOPE | DECISION | QUESTION | IDEA | CORRECTION | TRIVIAL>
  affects_charter: false
  affects_scope: false
  urgency: NORMAL                      # URGENT | NORMAL | LOW
  complexity_score: 0                  # 0-100

options_considered:
  - id: A
    summary: <option name + 1-line description>
    pros: []
    cons: []
  - id: B
    summary: <option name + 1-line description>
    pros: []
    cons: []

chosen: A                              # which option id; NEW if amended later
chosen_rationale: |
  <one paragraph: why this option, what it optimizes, what it sacrifices>

approval_chain:                        # captures human-in-the-loop touchpoints
  - actor: agent
    action: PROPOSED
    at: YYYY-MM-DD
    via: <session log or chat>
  - actor: user
    action: ACCEPTED                   # or DEFERRED | REJECTED | AMENDED
    at: YYYY-MM-DD
    via: <chat reply phrase | user_prompt path | q-and-a path>

verified_by:                           # append as new verifications happen; do not delete
  - mechanism: <drift-check | post-mortem | smoke-test | sandwich-verifier | manual>
    at: YYYY-MM-DD
    result: PASS                       # PASS | FAIL | PARTIAL

affects:                               # blast radius
  charter: false
  spec_files: []
  code_paths: []
  config_files: []
  other_decisions: []                  # downstream D-IDs

depends_on: []                         # upstream D-IDs that must be ACCEPTED
supersedes: null                       # D-ID this replaces
superseded_by: null                    # set when this is replaced

defer_cycles: 0                        # R7 mitigation: detect can-kicking
re_attempt_prereq: |
  <if status==DEFERRED or REVOKED, what must be true for re-attempt?>
  Default: N/A
# >3 defer_cycles → drift-detector raises alert (per REV-2 § C R7)

tags: []                               # free-form
```

Body sections recommended (not binding): `## Context`, `## Analysis`, `## Decision`, `### What this means concretely`, `## Why (Reasons)`, `## Risks & Mitigations`, `## Open Questions`, `## Amendments (append-only)`, `## Acceptance Record`.

**Provenance discipline** (binding): every decision MUST cite source_evidence. Acceptable types — user_prompt/, human-workspace decisions/, q-and-a/answered/, patterns-discovered/, post-mortems/, drift-logs/, specs/, charter section reference. Agent-inference-only decisions MUST tag `level: IMPL` AND state inference chain in `chosen_rationale`.

**R7 defer tracking**: each pause increments `defer_cycles`; >3 raises alert. Prevents can-kicking observed in prior projects.

---

## 4. Memory Tiers + Routing Tree

Two complementary charters codify memory access discipline:

**`constitution/memory-tiers.md`** (vertical tiering within project memory; D-017 ratified 2026-05-01):

- **Tier 1 — Immutable Always-Loaded (bootstrap)** ≤8K tokens: `CLAUDE.md`, `agent-workspace/CLAUDE.md`, `current-execution.md`, `checkpoints/latest.md` (if ≤24h fresh). Auto-injected by `session-start-bootstrap.sh`. Ceiling enforced by `tier1-bloat-check.sh` Stop hook.
- **Tier 2 — Just-In-Time**: `PROJECT_CHARTER.md`, `AGENT_OPERATING_MANUAL.md`, `project.md`, `agent-notes.md`, `mistake-log.md`, last 3 sessions, active session-plan, the SPECIFIC constitution file the task touches, specific spec, specific skill.
- **Tier 3 — Explicit Pull**: older sessions/, specific historical `decisions/<NNN>-*.md`, `observations/`, `drift-logs/`, `post-mortems/`, `learning-data/index/` (RAG-queryable), `thesis-log/` (THESIS-only per CLAUDE.md), `obsidian-vault/wiki/<entity>.md`, `eval-sets/baseline-results/`.
- **Hard exclusion (deny-listed)**: `learning-data/{events,archive}/` — write-only NDJSON queue per D-005; settings.json `permissions.deny` enforces.

**Boundary rules**: Tier 1 never exceeds bootstrap ceiling per session type (autonomous-protocol Rule 4 — PLAN ≤8K, MULTI_TASK_IMPL ≤20K, etc.); Tier 3 stays Tier 3 (no auto-promotion); recency-window is strict mtime (`find sessions/ -name '*.md' | sort -r | head -3`); never load `obsidian-vault/raw/` (deny-listed).

**`constitution/memory-routing-tree.md`** (horizontal scope routing; D-024 ratified 2026-05-04):

Decision tree (first match wins):
1. Stockforge-specific lesson? → `agent-workspace/memory/agent-notes.md` (project memory canonical)
2. User-role / cross-project / machine-paths? → user-memory dir (`C:\Users\PC\.ccs\instances\nathanleewindy\projects\C--htdocs-stockforge\memory\`)
3. Ambiguous? → BOTH (project-memory canonical for deterministic hook visibility)

Hard rules: NEVER write project-substrate to user-memory (starves hook chain); NEVER write user-role context to project memory; when ambiguous, project memory wins. Companion `memory-routing-audit.sh` hook (DRAFTED, 93 LOC, smoke-tested, gated on ratification).

---

## 5. Cross-Cutting — Constitution → Enforcing Hook

114 hook scripts live in `C:\htdocs\stockforge\scripts\hooks\` (excluding firing-tests/ subdir + `.bak-S348` backups). Selected rule → hook mapping:

| Constitution rule | Enforcing hook(s) | Phase / event |
|---|---|---|
| `severity-schema.md` § 4 enforcement chain | `severity-classifier.sh` (Stop late) → `escalation-engine.sh` (Stop+SessionStart+UserPromptSubmit) → `autonomous-block-enforcer.sh` (UserPromptSubmit FIRST + PreToolUse FIRST) → `telegram-push.sh` | Multi-event chain |
| `memory-tiers.md` Tier 1 ≤8K | `tier1-bloat-check.sh` | Stop |
| `memory-routing-tree.md` project-vs-user | `memory-routing-audit.sh` (DRAFTED, ratification-gated) | Stop |
| `harness-health-protocol.md` HH-1..HH-12 | `harness-health-self-scan.sh` | UserPromptSubmit + SessionStart |
| `decision-discipline.md` Rule 4a (5-session cadence) | `promotion-cycle-trigger.sh` | SessionStart |
| `decision-discipline.md` Rule 4b (lesson-synthesis mandatory) | `lesson-synthesis-watchdog.sh` (strict mode RC=2) | Stop |
| `drift-signals.md` Tier-A (DR-A1..DR-A5 + DR1/3/6/8/D5/D6/D7) | `drift-signals-D1-D9.sh` | Stop |
| `autonomous-protocol.md` Rule 2 Mode A/B/C/D | `autonomous-stop-watchdog.sh` + `budget-watchdog.sh` + `session-self-reboot.sh` + `continue-injector-spawn.sh` + `continue-injector.ps1` | Stop |
| `autonomous-protocol.md` Rule 10 Mode-E defection | `autonomous-stop-watchdog.sh` § 3 SELF_PAUSE_HIT regex | Stop |
| `boundaries.md` B-1 charter immutability + `harness-health-protocol.md` HH-8 | `charter-coherence-spot.sh` + md5 baseline `.charter-md5-baseline` | Stop |
| `boundaries.md` B-5/B-9 destructive ops | `destructive-command-guard.sh` (after 2026-05-14 mass-deletion incident) | PreToolUse |
| `boundaries.md` post-2026-05-14 file integrity | `project-integrity-watchdog.sh` + `daily-backup.sh` | Stop |
| `coding-principles.md` § 14/D-019 hook portability | `bash-hook-lint.sh` | Stop |
| `portability.md` L-S208-1 settings.json inline-env-prefix | `settings-inline-env-prefix-detector.sh` | Stop |
| `financial-data-protocol.md` Rule 16 numeric-field discipline (planned) | `numeric-field-discipline-check.sh` (planned per D-065) | PreToolUse |
| `financial-data-protocol.md` W0-3/W0-4/W0-5 substrate | `atomic-write-check.sh` + `html-separator-check.sh` + `path-safety-check.sh` | PostToolUse |
| CLAUDE.md § Session End ritual step 6 | `session-end-checklist-linter.sh` | Stop |
| CLAUDE.md § Session End ritual step 7 (D-038 retired Check A) | `phase-status-coherence.sh` (UserPromptSubmit cadence) + `project-md-adr-staleness.sh` (Stop) | UserPromptSubmit + Stop |
| CLAUDE.md § Session End ritual step 8 | `profile-template-auto-populate.sh` | Stop |
| CLAUDE.md § Session End ritual step 9 | `promotion-cycle-trigger.sh` (HARD-BLOCK at SessionStart if ≥8 new lessons since last run) | Stop+SessionStart |
| CLAUDE.md tracking retention (S99 RCA) | `tracking-retention.sh` (WARN-only) + `telemetry-rotate.sh` | Stop daily |
| ANTHROPIC_API_KEY ban (memory rule + D-050 systemic) | `no-anthropic-sdk-d10.sh` | PreToolUse |
| Stale prompt detection | `stale-prompt-detector.sh` | UserPromptSubmit |
| Sub-plan completion coherence | `sub-plan-completion-coherence.sh` + `pre-checkpoint-close-verifier.sh` | Stop |
| Sandwich attestation discipline | `post-dev-dispatch-attestation-check.sh` + `dogfood-the-promotion.sh` + `adr-empirical-close-verify-spot-check.sh` | Stop |
| Q&A lifecycle (HH-E.2 auto-mv) | `qa-pending-auto-mover.sh` + `qa-stale-urgent-escalator.sh` + `qa-pending-stale-mover.sh` + `qa-answered-detector.sh` | Stop |
| Subagent budget classification | `subagent-budget-classifier.sh` + `subagent-stop-logger.sh` | SubagentStop |
| Dispatch tracking | `dispatch-jsonl-recorder.sh` + `dispatch-jsonl-backfill.sh` + `dispatch-pending-rotation.sh` + `pre-dispatch-architect-commit-guard.sh` + `pre-dispatch-adr-number-check.sh` | Multi-event |
| Sync-tracker Confidence Score | `sync-tracker-update.sh` + `sync-tracker-render.sh` + `sync-tracker-auto-update.sh` + `sync-grilling-call.sh` + `sync-grilling-trigger.sh` | Stop |
| Cost ledger | `cost-ledger-recorder.sh` | Stop |
| Component telemetry | `component-telemetry.sh` + `self-awareness-aggregate.sh` + `metric-failure-mode-rate.sh` | Stop |
| Drift detection rollup | `drift-rollup-daily.sh` + `scheduled-drift-detector-trigger.sh` + `drift-signals-log-rotate.sh` | Stop daily |
| Bootstrap context render | `bootstrap-summary-renderer.sh` + `session-start-bootstrap.sh` | SessionStart |
| Checkpoint write discipline | `checkpoint-write-marker.sh` + `checkpoint-write-end-turn-watchdog.sh` + `checkpoint-marker-cleanup-resume.sh` + `auto-reboot-handoff-verify.sh` + `pre-clear-handoff-guard.sh` | Stop |
| Idle escape | `idle-escape-detector.sh` + `idle-state-advisory.sh` | UserPromptSubmit |

Pattern: nearly every binding constitution rule has an empirical-firing hook (per `harness-health-protocol.md` § 1 doctrine: "harness must self-verify firing, not self-attest existence"). Hooks aggregate state into TSV/JSONL streams which the LLM consumes at session boundaries. The deterministic guardian + LLM-aggregator-at-session-end split was ratified in D-008 + D-002 REV-2 § B (NOT continuous LLM Guardian, an AP-23 anti-pattern).

---

**End of inventory.** Sources: 17 files in `agent-workspace/constitution/*.md`; 20 top-level + 14 subdirectories in `agent-workspace/memory/`; 114 production hooks in `scripts/hooks/`. Last reviewed 2026-05-19.
