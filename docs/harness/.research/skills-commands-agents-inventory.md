# StockForge Harness Inventory: Skills, Commands, Subagents

> Read-only audit, 2026-05-19. Source paths cited absolute. Frontmatter + first ~50 lines of each artifact read.

---

## 1. Skills (`.claude/skills/*/SKILL.md`, 23 total)

Skills are auto-discovered patterns Claude Code may invoke when context matches the `description` frontmatter. Most are LLM-mediated procedures; some are pure inspection helpers. Three categories dominate: (a) **stockforge biz** — DDD, FastAPI, evidence extraction, prompt engineering, postgres-pgvector, crawler reliability, obsidian-vault — encode StockForge's "no LLM math + citation integrity + dual-layer spec" invariants; (b) **harness self-loop** — decompose-work, try-n-approaches, empirical-probe-first, promote-rule, sync-pull, grill-maximization, qa-escalation, user-prompt-intake, session-memory-l0-l1, hook-diagnostics — these are the Karpathy autoresearch + confidence-calibration machinery; (c) **knowledge-base** — write-a-skill, spec-dual-layer, spec-to-wiki, ubiquitous-language, test-pyramid-balance, attach — generic build-the-build-system meta-skills.

| Name | One-line purpose | Trigger / when to invoke | Dispatches / tools | Unique mechanic |
|---|---|---|---|---|
| `attach` | Port harness layer to a new project dir | New CC project, peer copy, layer-separation check | Read, Glob, Grep, Bash, Write | Reads `.claude/manifest.yaml`; honors layer tags (harness/stockforge/personal); supports `--dry-run` |
| `crawler-reliability` | Build reliable scrapers (CafeF/NDH/YouTube/FB) | Implementing scraper, retry logic | (no allowed-tools — default) | VBW-for-scrapers (verify selector vs live DOM); fallback chain pattern |
| `ddd-tactical-patterns` | Apply DDD aggregate/VO/repo correctly in Python dataclasses | New aggregate, repo Protocol, domain event | Read, Glob, Grep, Bash, Edit, Write | Enforces zero-framework domain layer; Protocol in domain / impl in infra |
| `decompose-work` | Split task into deterministic vs LLM portions | Multi-part task ≥3 sub-parts | Read, Glob, Grep, Bash | Karpathy autoresearch foundation; pre-flight VBW (L-S30-1); reads `capability-map.md` |
| `empirical-probe-first` | Probe ALL strategies in multi-option ladder | Plan lists ≥3 strategies for one problem | Read, Glob, Grep, Bash, Write | Writes probe matrix JSON; ADR if pick deviates from recommendation; companion `vendor-api-probe.sh` |
| `evidence-extraction` | Structured claim extraction with citation integrity | Building extractor pipelines | (default tools) | Enforces I-S1 no-LLM-math; every claim needs source_url+extracted_at+confidence |
| `fastapi-module` | FastAPI router conventions (Phase 2+) | New HTTP endpoint, router wiring | (default tools) | Router/DTO/UseCase naming; explicitly says "not for Phase 1" |
| `grill-maximization` | Bundle 15-20 Q&A questions per human touchpoint | Confidence below threshold, multi-decision dependency | Read, Glob, Grep, Write | 8-rule doctrine; tags Confidence Score categories; pairs with `qa-escalation` |
| `hook-diagnostics` | Inspect hook state machine + transcript cache | Hook stuck active, aggregator row missing | Read, Glob, Grep, Bash | Single-session inspection of `packages/observability/` state machine |
| `obsidian-vault` | Manage Obsidian wiki (entities/concepts/sources/thesis/synthesis) | Adding KB note, ingesting source | Read, Glob, Grep, Bash, Edit, Write | Raw/wiki separation; never writes `raw/` (hard deny rule) |
| `postgres-pgvector` | Schema design w/ pgvector + TimescaleDB | New migration, schema design | Read, Glob, Grep, Bash, Edit, Write | Structured-vs-JSONB rules; point-in-time integrity I-S2 |
| `promote-rule` | Cluster agent-notes → propose promotion (hook > skill > charter) | ≥10 new rules since last run | Read, Glob, Grep, Bash, Write | Jaccard similarity clustering; outputs `observations/promotion-proposals-<TS>.md` |
| `prompt-engineering` | LLM prompt design w/ no-LLM-math discipline | Authoring new extractor/analysis prompt | Read, Glob, Grep, Bash, Edit, Write | Mandatory `no_llm_math: true` frontmatter; prompts live in `prompts/`, not inline |
| `qa-escalation` | File-based Q&A bundle protocol (pending/answered/stale) | intent-classifier OPEN_QA_BUNDLE / ESCALATE_HUMAN | Read, Glob, Grep, Write, Bash | AskUserQuestion is the ONLY effective surface; file bundle is audit trail |
| `session-memory-l0-l1` | Extract L0 regex + L1 LLM-mediated memories from JSONL | Post-SessionEnd ingestion | Read, Glob, Grep, Bash | TranscriptCache + cleanText (strip 9 wrapper tags); 15+35 head/tail windowing |
| `spec-dual-layer` | Author specs with Part A (narrative) + Part B (contract) | Tier 2/3 spec authoring | Read, Glob, Grep, Bash, Edit, Write | Section content matrix; B.3 no-LLM-math; B.2 multi-criteria-not-single-score |
| `spec-to-wiki` | Convert raw spec to Obsidian wiki w/ wikilinks | After /spec-author, spec re-gen | (default tools) | First-mention linking; never edit `raw/`; diff-mode preserves human additions |
| `sync-pull` | Pre-flight confidence-score lookup before SCOPE/ARCH/IMPL decision | About to commit non-trivial decision | Read, Glob, Grep, Bash | Reads `sync-tracker/state.tsv` + `weights.yaml`; emits SELF-DECIDE-OK / GRILL / FORCE-GRILL |
| `test-pyramid-balance` | Balance unit/integration/E2E tests | New feature test plan, PR review | Read, Glob, Grep, Bash | Stock-specific cats (backtest point-in-time, LLM-snapshot, calibration) |
| `try-n-approaches` | Generate ≥3 approaches (DEEPEN/BROADEN/ABANDON) + metric | Open question from drift/dogfood | Read, Glob, Grep, Bash, Write | Writes framing artifact to `learning-data/loop/`; metric-function BLOCKING per L-S12-1 |
| `ubiquitous-language` | DDD glossary extraction + maintenance | New BC, term emerges | (default tools) | 6-field schema; passive analysis (paired with /drill-me interactive) |
| `user-prompt-intake` | Hybrid intent classifier (lite-detect + subagent) | Any new user prompt landing | Read, Glob, Grep, Bash, Agent, Write | Trivial whitelist incl. Vietnamese; dispatches `intent-classifier` for non-trivial |
| `write-a-skill` | Create new skills w/ progressive disclosure | Pattern surfaces in 3+ sessions | (default tools) | L-S14-1 (draft 20% under D1 ceiling); description = discoverability surface |

---

## 2. Commands (`.claude/commands/*.md`, 16 total)

Commands are user-typed slash invocations. Each is a thin wrapper that either delegates to a skill (for procedural substance) or dispatches a subagent (for fresh-context work). They form the user-facing UX surface — most "real work" lives in the skill or agent body. Three families: **session lifecycle** (session-start / session-verify / session-end / handoff-read / budget-check), **planning + spec** (master-plan / spec-author / spec-to-wiki / bdd-planner not present as command), **adversarial / quality** (devils-advocate / drift-check / ul-audit / vbw-check / drill-me / grill-me), and **infrastructure toggles** (autonomous / block). Note: the prior `ccs` + `ccs:continue` + `init` + `review` + `security-review` + others appear in available-skills list but are NOT in `.claude/commands/` — those are CCS/CLI-plugin level, not project commands. Count of 16 files vs the stated 17 confirms: there is no separate `bdd-planner` command file (BDD planning is wholly a subagent, dispatched manually).

| Name | Purpose | Skill / agent invoked | User-visible behavior |
|---|---|---|---|
| `autonomous` | Toggle autonomous mode on/off/status | (no skill — atomic file ops) | Flips `current-execution.md` + `STOCKFORGE_WATCHDOG_DISABLE`; clears stale `.cliff-fired` markers |
| `block` | Human-gate control (status/clear/raise) | (delegates to `block-control.sh`) | Manages `.autonomous-BLOCKED` flag + Telegram push; PreToolUse hook enforces |
| `budget-check` | Report token consumption + projection | (no skill — formula in body) | Status table GREEN/YELLOW/RED/OVER; 180K/220K/250K thresholds |
| `devils-advocate` | Adversarial critique of plan/spec/code/thesis | dispatches `devils-advocate` subagent | Returns multi-dimensional critique (hidden-assumptions / edge-cases / failure-modes / etc) |
| `drift-check` | Run drift signals DR1-DR12 | runs `drift-signals-D1-D9.sh` + dispatches `drift-detector` for DR7/DR12 | Report to `quality-reports/drift-reports/`; exit codes 0/1/2 for CI |
| `drill-me` | Interactive DDD UL extraction | delegates to `ubiquitous-language` skill | One-at-a-time questions; 6-phase sequence (Nouns/Verbs/Lifecycle/Relationships/Conflict/Boundary) |
| `grill-me` | Relentless plan/design interview | delegates to `grill-maximization` skill | Multi-batch AskUserQuestion (4 max); catalog D-N decisions + Q-N open |
| `handoff-read` | Lightweight session-pickup (vs full /session-start) | (no skill) | Reads last session log "Next Session Pickup" + current-execution.md |
| `master-plan` | Decompose goal into phased sessions | dispatches `master-planner` subagent | Writes session plans to `session-plans/pending/NNN-*.md`; sandwich pattern |
| `session-end` | Close session + update memory | (no skill — checklist in body) | Writes session log; updates project.md/current-execution.md; agent-notes append |
| `session-start` | Load state, identify session type, output brief | (no skill — reading priority in body) | Reads current-execution / project / agent-notes / last 3 sessions; budget estimate; waits for user confirm |
| `session-verify` | Mid-session alignment check | (no skill) | Re-reads brief; checks invariants + boundaries + budget + VBW adherence |
| `spec-author` | Create dual-layer spec | dispatches `spec-author` subagent | Writes Tier 2 spec to `specs/tier2-feature/NNN-*.md`; stockforge compliance check |
| `spec-to-wiki` | Convert raw spec to Obsidian wiki | delegates to `spec-to-wiki` skill | Creates `obsidian-vault/wiki/specs/...md`; auto-stub missing wikilink targets |
| `ul-audit` | Audit UL consistency (code vs glossary) | dispatches `ul-auditor` agent + grep checks | Drift report; quick (2min HIGH-only) vs full (10-15min) |
| `vbw-check` | Apply VBW protocol for current task | (delegates to `constitution/vbw-protocol.md`) | Checkpoint matrix (spec/test/code/commit) — block if not ready |

---

## 3. Subagents (`.claude/agents/*.md`, 14 total)

All 14 agents declare `model: opus` (per user 2026-05-17 directive "full opus + follow budget"). Tools are minimal-grant: most have Read/Glob/Grep + sometimes Write/Edit/Bash. Persona-tool-mismatch is intentional in 2 cases — verifier has NO Write (PCG-S401-4 enforcement so main session is sole author), and master-planner/spec-author Write only their plan/spec artifact. Three classes: **planners** (master-planner, sandwich-architect, action-guide-planner, bdd-planner, spec-author), **executors** (sandwich-dev — only one), **auditors / fresh-eyes** (devils-advocate, drift-detector, ul-auditor, intent-vs-impl-diff, lesson-synthesizer, sandwich-verifier, intent-classifier, research-scanner).

| Name | Persona / role | Tools | Dispatched by | Output contract |
|---|---|---|---|---|
| `action-guide-planner` | Pragmatic lead dev — turn session brief into concrete next actions | Read, Glob, Grep | Manual / session-start follow-up | File-read order + modify list + skill activations + verification steps |
| `bdd-planner` | Senior QA / test architect — pyramid balance | Read, Glob, Grep, Write | Manual (post `/spec-author`) | BDD scenarios + integration cases + unit cases + pyramid check |
| `devils-advocate` | Experienced skeptic — find flaws | Read, Glob, Grep | `/devils-advocate` | Multi-dim critique: hidden assumptions / edge / failure / alternatives / 2nd-order |
| `drift-detector` | Structural integrity inspector | Read, Glob, Grep, Bash | `/drift-check` | Semantic DR7 (UL drift) + DR12 (anti-pattern); writes to `observations/` |
| `intent-classifier` | Cool-headed triage — YAML verdict | Read, Glob, Grep | `user-prompt-intake` skill | YAML w/ primary_intent + recommended_action + suggested_grill_questions |
| `intent-vs-impl-diff` | Adversarial cross-checker (human intent vs impl) | Read, Glob, Grep, Bash, Write | On-demand / phase-boundary | Drift-log at `drift-logs/intent-impl-<TS>.md`; aligned/drifted-soft/drifted-hard tiers |
| `lesson-synthesizer` | Pattern miner — Stage 2 of self-upgrade loop | Read, Glob, Grep, Bash, Write, Edit | `lesson-synthesis-watchdog` ALERT | ≥1 new KI/BP/agent-notes entry w/ session-diff evidence + L-S{NN}-N ID |
| `master-planner` | Senior tech lead — decompose goal into sessions | Read, Glob, Grep, Write | `/master-plan` | Session plans at `session-plans/pending/NNN-*.md`; sandwich pattern + budgets |
| `research-scanner` | Repo cartographer — opensource fit-for-stockforge | Read, Glob, Grep, WebFetch | Manual (agent-pick-1 dogfood) | ≤5-page report w/ repo URL + SHA + as-of for every claim; ONE winner |
| `sandwich-architect` | Senior architect — plans IMPL sessions | Read, Glob, Grep, Write | PLAN session type | Detailed execution plan; never writes prod code; reads `.planner-stats.tsv` |
| `sandwich-dev` | Focused implementer — executes architect's plan | Read, Glob, Grep, Write, Edit, Bash | FOCUSED_IMPL / MULTI_TASK_IMPL | Working code + tests + verification; baseline-capture mandatory (STEP 0.10) |
| `sandwich-verifier` | Skeptical fresh-context reviewer | Read, Glob, Grep, Bash | VERIFY session type | Inline text findings (NO Write per PCG-S401-4); main session persists |
| `spec-author` | BA + DDD Designer | Read, Glob, Grep, Write | `/spec-author` | Dual-layer spec to `specs/tier2-feature/NNN-*.md` |
| `ul-auditor` | Detail-obsessed DDD practitioner — synonym / drift detection | Read, Glob, Grep, Bash | `/ul-audit` | Drift report w/ V-N violations; suggests but never auto-renames |

---

## 4. Cross-Cutting Observations

### A. The Sandwich Pipeline (canonical workflow)

`/session-start` → (no plan exists?) → `/master-plan` → dispatches **`master-planner`** → writes `session-plans/pending/NNN-*.md` → next session loads plan → `sandwich-architect` (PLAN type) → `sandwich-dev` (IMPL type) → `sandwich-verifier` (VERIFY type) → `/session-end`. The `architect / dev / verifier` triad is the load-bearing structural pattern; user repeatedly cites Session 4 as the failure mode that justified the split (PLAN + IMPL must never share a session).

### B. The Knowledge-Base Pipeline

`/drill-me` (interactive UL) → `ubiquitous-language` skill → `glossary.md` → `/spec-author` → `spec-author` agent → `specs/tier2-feature/` → `/spec-to-wiki` → `spec-to-wiki` skill → `obsidian-vault/wiki/specs/`. Companion: `/ul-audit` → `ul-auditor` agent → drift report. The `obsidian-vault` skill is the substrate.

### C. The Self-Upgrade Loop (Karpathy autoresearch)

Drift surfaces signal → `try-n-approaches` (skill) → frames experiment → executes → outcomes accumulate in `agent-notes.md` → `promote-rule` (skill) clusters → proposes promotion (hook > skill > charter) → `lesson-synthesizer` (agent) fills KI/BP entries when watchdog ALERTs. Parallel: `decompose-work` decides det-vs-LLM split for every step; `empirical-probe-first` rejects stale-evidence recommendations BEFORE commit.

### D. The Calibration / Confidence Loop

`sync-pull` (skill) reads `sync-tracker/state.tsv` → emits SELF-DECIDE-OK vs GRILL → if GRILL, `grill-maximization` (skill) bundles 15-20 Qs → `qa-escalation` (skill) writes to `human-workspace/q-and-a/pending/` AND fires AskUserQuestion (the binding surface). Pre-step: `user-prompt-intake` (skill) lite-detects trivial / dispatches `intent-classifier` (agent).

### E. The Quality Gate Chain

`/vbw-check` (per-commit) + `/drift-check` (per-session) → `drift-detector` (agent for semantic DR7/DR12) + `drift-signals-D1-D9.sh` (deterministic DR1-DR9). `/devils-advocate` → `devils-advocate` agent (pre-merge or pre-thesis). `intent-vs-impl-diff` runs at phase boundary to catch silent absorption (orch CF-DOGFOOD-2 pattern).

### F. Dependency Clusters

1. **Stockforge biz cluster**: `ddd-tactical-patterns` + `evidence-extraction` + `prompt-engineering` + `postgres-pgvector` + `fastapi-module` + `crawler-reliability` — all enforce I-S1/I-S2 (no-LLM-math + citation integrity).
2. **Harness self-loop cluster**: `decompose-work` + `try-n-approaches` + `promote-rule` + `sync-pull` + `empirical-probe-first` — Karpathy autoresearch machinery; all reference `capability-map.md`.
3. **Q&A escalation cluster**: `grill-maximization` + `qa-escalation` + `user-prompt-intake` + `intent-classifier` (agent) — full prompt-intake → bundle → human-gate pipeline.
4. **Observability cluster**: `session-memory-l0-l1` + `hook-diagnostics` + `lesson-synthesizer` (agent) — all consume `packages/observability/` + telemetry TSVs.

### G. Drift / Staleness Observations

1. **Command count mismatch**: 16 command files on disk vs 17 listed in available-skills banner. Diff: no `bdd-planner` command file (only the agent exists). The runtime list includes CCS plugin + initial-setup commands (`ccs`, `init`, `review`, `security-review`, `simplify`, `loop`, etc.) that are NOT under `.claude/commands/`. Worth noting for "what's project-owned vs harness-plugin".
2. **Verifier-Write tension**: `sandwich-verifier.md` documents a 3-incident cluster (S397/S400/S401) where dispatch briefs asked the agent to Write when persona forbids it. Explicit precedent is now codified — main session persists from inline text. Suggests other dispatch briefs may have similar drift; an audit of `Task` dispatcher prompts would surface them.
3. **`spec-to-wiki` and `evidence-extraction` skills lack `allowed-tools` frontmatter** — they get default tool set. Inconsistent with newer skills which always declare. Could be intentional (early skills) or drift.
4. **Recent S408 + plan-044** trail visible in commit log; matches recently-active S397-S408 codification (sandwich-verifier persona override is dated PCG-S401-4 plan-046). Harness is undergoing high-velocity self-modification — drift-staleness risk is real, especially in skill descriptions referencing "Phase 0" / "Phase 1" boundaries that have moved.
5. **`fastapi-module` says "Phase 2+ only"** while project is currently at Phase 0 / Phase G work — skill is dormant by design, but human readers may misread it as broken.
6. **Skill descriptions reference dated lesson IDs liberally** (L-S12-1, L-S14-1, L-S28-1, L-S30-1, L-S32-1, L-S382-1, PCG-S401-4, M-S397-1, etc.) — strong provenance but high coupling to memory layer; if `agent-notes.md` gets rotated under the 700-LOC cap (CLAUDE.md retention rule), descriptions may dangle. Promote-rule cycle should be monitoring this.

### H. What's Missing (gap inventory)

- No `bdd-planner` command (only the agent exists) — workflow says "spec-author → bdd-planner → master-plan" but middle step is manual subagent dispatch.
- No `thesis-author` command/agent yet despite charter's THESIS session type and `thesis-log/` reference. THESIS work currently routes through generic `/session-start --type THESIS`.
- No `phase-boundary` command despite "phase-boundary" being a documented trigger for multiple skills (`promote-rule`, `intent-vs-impl-diff`).
- `research-scanner` is the only agent with WebFetch tool — singleton, could justify a generic-research command.

---

*Generated 2026-05-19. Source paths (absolute) cited inline:*
*Skills: `C:\htdocs\stockforge\.claude\skills\<name>\SKILL.md`*
*Commands: `C:\htdocs\stockforge\.claude\commands\<name>.md`*
*Agents: `C:\htdocs\stockforge\.claude\agents\<name>.md`*
