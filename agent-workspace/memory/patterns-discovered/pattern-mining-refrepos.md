# Pattern Mining — Orch Reference Repos Ecosystem
**Date**: 2026-04-29
**Source**: `C:\htdocs\orch-starter\reference-repos\` + `C:\htdocs\orch-starter\agent-workspace\research\`
**Mission**: Mine patterns from orch's pre-digested research + selected repo source for stockforge Phase 0 Harness Bootstrap (10 tracks).

**Notes used (orch-starter/agent-workspace/research/)**:
- `SYNTHESIS.md` (cross-cutting)
- `claudekit-skills.md` + `claudekit-docs.md` (skills source-of-truth)
- `claude-sessions.md` (memory extraction → Track 8 second-brain)
- `claude-code-agent-monitor.md` (hooks/state machine → Track 9)
- `claude-code-otel.md` (telemetry → Track 9)
- `claude-code-learn.md` (CC internals)
- `claude-code-telegram.md` (feature reference)
- `claudegram.md` (queue/watchdog/session)
- `claude-to-im.md` (DI context, channel adapter)
- `nanoclaw.md` (wake-dedup, stuck detection)
- `praktor.md` (routing, swarm graph)
- `claude-session-dashboard.md` (passive observability)
- `ccs.md` (account switching CLI)
- `phase-7-options-survey.md` (skipped — orch-internal)
- `phase-8-oss-config-patterns.md` (config layering)

**Repos deep-read (selective by orch's flags)**:
- `claude-sessions/src/memory/extract-l0.ts`, `extract-l1.ts`, `snapshot.ts` (verbatim L0/L1 patterns)
- `Claude-Code-Agent-Monitor/plugins/` (plugin manifest + 5 plugin areas: insights, productivity, analytics, devtools, dashboard)
- `Claude-Code-Agent-Monitor/server/` (db.js, hooks routes — overview)
- `claudegram/src/claude/` (request-queue, agent-watchdog, session-manager — overview)
- `claude-code-otel/` (config files inventory)

---

## Executive Summary

1. Orch's research is high-quality and pre-digested — most decisions don't require re-reading the repo source. SYNTHESIS.md alone covers 80% of what stockforge needs. Trust it.
2. **claudekit-skills' progressive-disclosure pattern (SKILL.md ≤150 LOC + references/ + scripts/) is the single highest-leverage refactor** for stockforge. We currently have 12 skills, none follow this pattern; some (e.g. `prompt-engineering`, `crawler-reliability`) likely exceed 200 lines.
3. **`allowed-tools` frontmatter + `quick_validate.py` skill validator** are immediate ports — reduce permission noise and prevent skill drift in CI.
4. **claude-sessions' L0 regex extractor + L1 LLM prompt + 15+35 windowing** is the canonical "second-brain" memory pattern stockforge should adopt for Track 8 (Confidence Score / second-brain) — it directly addresses "extract failed approaches and decisions" which is exactly what calibration tracking requires.
5. **Claude-Code-Agent-Monitor plugins ecosystem** has ready-made observability skills (anomaly-alert, daily-standup, cost-breakdown, hook-diagnostics, productivity-score, workflow-optimizer) we can reskin for stockforge Track 9 (Self-Awareness Agent) — they're effectively LLM-driven Grafana queries.
6. **claude-code-otel docker stack** (single-container `grafana/otel-lgtm:1.4.0`) is the right Track 9 telemetry default. Copy `collector-config.yaml` + `docker-compose-lgtm.yml` + `claude-code-dashboard.json` verbatim under `docker/otel-stack/`.
7. **Hook patterns missing in stockforge**: UserPromptSubmit invariant injector, TaskCompleted audit trail, transcript-cache for incremental JSONL reads. None are in orch already as ports — orch defers them. Stockforge should consider porting now since they're cheap.
8. **Telegram patterns (claudegram, claude-code-telegram, claude-to-im) are Phase 4+ noise** for stockforge — defer until alerts feature lands. Single useful borrow now: `_redact_secrets` regex (claude-code-telegram orchestrator.py:52-80) for any future log/alert outputs.
9. **CCS** is already invoked by stockforge (per `ccs-delegation` skill). No rebuild needed; keep using as-is.
10. **claude-code-learn** is research-grade only (Anthropic IP — no code copy). Useful for understanding hook result schema (decision: approve/deny/modify) and three parallelism levels.

---

## Top 10 BORROW Patterns

Skills, hooks, scripts that should be added to stockforge `.claude/` — verbatim with naming adjustment.

| # | Pattern | Source | Stockforge target | Effort |
|---|---------|--------|-------------------|--------|
| 1 | **Progressive-disclosure skill structure** (SKILL.md ≤150 LOC + `references/` subdir + `scripts/` subdir) | claudekit-skills | Refactor all 12 existing `.claude/skills/*/` | M (12 files × ~30 min) |
| 2 | **`allowed-tools` frontmatter field** (pre-approve tools per skill) | claudekit-skills (Oct 2025 spec) | Add to all 12 SKILL.md frontmatters | L |
| 3 | **`quick_validate.py` skill validator** (frontmatter, name kebab-case, description ≤200 chars, body ≤200 LOC) | claudekit-skills | Port as `scripts/validate_skills.py` + add to `.claude/hooks/pre-commit` | L |
| 4 | **`skill-author` meta-skill** (already exists as `write-a-skill` — extend with stockforge invariants + validator hook) | claudekit-skills `skill-creator` | Update `.claude/skills/write-a-skill/SKILL.md` to embed validator | L |
| 5 | **L0 regex extractor for session JSONL** (files, commands, errors, failures, next_step, decisions) | claude-sessions `src/memory/extract-l0.ts` | New skill: `.claude/skills/session-memory-l0/` (or part of Track 8 second-brain) | L |
| 6 | **L1 extraction prompt** (6-category: profile, preferences, entities, events, cases, patterns; explicit FAILED approaches emphasis) | claude-sessions `src/memory/extract-l1.ts:33-64` | Same skill above; the prompt is verbatim-portable, MIT | T |
| 7 | **15+35 head/tail windowing constants** | claude-sessions `src/memory/snapshot.ts` | Same skill | T |
| 8 | **OTEL docker-compose-lgtm.yml + collector-config.yaml + claude-code-dashboard.json** (single-container grafana/otel-lgtm:1.4.0) | claude-code-otel | Copy to `docker/otel-stack/` for Track 9 | T |
| 9 | **`_redact_secrets` regex (API keys, AWS keys, Bearer tokens, conn strings)** | claude-code-telegram `src/claude/orchestrator.py:52-80` | New utility `packages/utils/secret_redactor.py` for any outbound logs/alerts | L |
| 10 | **UserPromptSubmit hook for invariant injection** (5-line reminder of I-S1 no-LLM-math, I-S2 citations, I-S3 deterministic-risk before each prompt) | claudekit `dev-rules-reminder.cjs` pattern | New `.claude/hooks/inject-invariants.sh` wired in `settings.json` UserPromptSubmit | L |

---

## Top 10 ADAPT Patterns

Patterns from TS/Go references that need Python adaptation (or stockforge-specific reframing).

| # | Pattern | Source | Stockforge adaptation | Effort |
|---|---------|--------|----------------------|--------|
| 1 | **Hook event state machine** (active/completed/error/abandoned + reactivation logic + Stop ≠ session-end nuance) | Claude-Code-Agent-Monitor `server/routes/hooks.js:54-328` | Rewrite as Python module under `packages/observability/state_machine.py` for Track 9 | M |
| 2 | **TranscriptCache** (LRU + mtime+size dual-check, byte-offset incremental reads on append-only JSONL) | Claude-Code-Agent-Monitor `server/lib/transcript-cache.js` (415 LOC) | Port to Python under `packages/observability/transcript_cache.py` for Track 8/9 | M |
| 3 | **Session memory extraction pipeline** (L0 sync inside Stop hook, L1 async fired in dedicated subprocess per claude-sessions design) | claude-sessions `src/memory/` + claudegram session-manager | Track 8 Confidence Score: spawn a separate Claude session for L1 extraction (preserves "no LLM math" by keeping LLM out of stockforge Python core) | M |
| 4 | **Anomaly detection skill** (cost outliers via 2σ, error rate spikes, pattern deviation) | Claude-Code-Agent-Monitor `plugins/ccam-insights/skills/anomaly-alert/` | Stockforge-flavored version: `.claude/skills/thesis-anomaly-detector/` — flags theses where confidence claim diverges from historical hit rate by >2σ | M |
| 5 | **Daily standup skill** (project-grouped completed work, sessions costing >X, top tools used) | Claude-Code-Agent-Monitor `plugins/ccam-productivity/skills/daily-standup/` | Stockforge: `.claude/skills/daily-thesis-summary/` — daily roll-up of theses logged, calibration delta, citations harvested | L |
| 6 | **Wake-dedup promise map** (concurrent spawn race protection) | nanoclaw `src/container-runner.ts:50-92` | Python `asyncio.Lock` + `dict[str, asyncio.Future]` for any future async crawler/extractor pool | L |
| 7 | **Stuck-session decideStuckAction (pure function, two-tier: absolute ceiling + per-claim tolerance)** | nanoclaw `src/host-sweep.ts:70-106` | Watchdog for long-running crawler tasks; `packages/crawlers/watchdog.py` | L |
| 8 | **3-tier routing function (prefix only — no AI tier in daemon)** | praktor `internal/router/router.go:34-77` | If stockforge ever adds chat/Telegram alerts, use prefix routing only (`@portfolio`, `@thesis`); never LLM-routing in daemon code | M |
| 9 | **Token-bucket rate limiter (cost-based + request-based dual limit)** | claude-code-telegram `rate_limiter.py` | For external API calls (CafeF, NDH, FireAnt) — `packages/crawlers/rate_limit.py` | L |
| 10 | **Atomic file writes (write tmp + rename) + Zod-style schema validation on load (Pydantic equivalent)** | claudegram `src/claude/session-history.ts` | For `agent-workspace/memory/` JSON/YAML state files — prevents corrupt-file crashes | L |

---

## Top 5 LEARN Patterns

Architectural concepts to internalize but not directly implement.

| # | Concept | Source | Why it matters for stockforge |
|---|---------|--------|------------------------------|
| 1 | **Hook result schema (decision: approve/deny/modify)** | claude-code-learn (Anthropic source) | If stockforge ever wires PreToolUse hooks for I-S2 enforcement (block writes that don't include citations), the hook handler MUST return this schema correctly — not generic JSON. |
| 2 | **Three parallelism levels in Claude Code (turn-internal, subagent-via-AgentTool, persistent-teammates)** | claude-code-learn `src/utils/swarm/` | Stockforge thesis sessions are read-only; understanding that subagents do NOT share context window justifies the "spawn fresh session for L1 extraction" choice. |
| 3 | **Cross-agent memory pool with hotness scoring (recency × 0.3 + frequency × 0.4 + relevance × 0.3)** | claude-sessions `src/memory/hotness.ts` | If Track 8 second-brain ever expands beyond per-thesis to cross-thesis pattern recognition, this is the right scoring formula. Skip for v1; document for v2. |
| 4 | **DI context via globalThis singleton (avoids framework lock-in for domain layer)** | claude-to-im `src/lib/bridge/context.ts` | Stockforge's domain layer is also framework-free (per CLAUDE.md hard rule). Python equivalent: a small `context.py` in `packages/domain/` exposing `get_stockforge_context()` populated at FastAPI/Streamlit bootstrap. |
| 5 | **Passive vs active observability tradeoff** | claude-session-dashboard | stockforge is naturally active (we control the harness); confirms we should not build a passive `~/.claude/` JSONL scanner. Lock dir + mtime <120s is the canonical liveness signal IF we ever need to detect orphaned sessions. |

---

## Skills not yet in stockforge

Stockforge currently has 12 skills (listed in CLAUDE.md and verified at `.claude/skills/`). Below are skills from the ecosystem worth porting, ordered by value-to-stockforge.

| Skill | Source | Purpose | Cost to port | Priority |
|-------|--------|---------|--------------|----------|
| **`session-memory-l0-l1`** (combine L0 regex + L1 LLM extraction + 15/35 window) | claude-sessions | Track 8 second-brain: every thesis session emits L0 facts + L1 structured memories with explicit FAILED-approaches signal | LOW (verbatim port + Python adaption ~150 LOC) | HIGH |
| **`thesis-anomaly-detector`** | adapted from Claude-Code-Agent-Monitor `anomaly-alert` | Track 9 Self-Awareness: flag theses with confidence diverging >2σ from historical hit rate | MED | HIGH |
| **`daily-thesis-summary`** | adapted from Claude-Code-Agent-Monitor `daily-standup` | Daily auto-rollup: theses logged, calibration delta, citations harvested, drift signals fired | LOW | MED |
| **`hook-diagnostics`** | Claude-Code-Agent-Monitor `plugins/ccam-devtools/skills/hook-diagnostics` | Track 1/9: programmatic check of hook health (which fired, latency, errors) | LOW | MED |
| **`pattern-detect`** | Claude-Code-Agent-Monitor `plugins/ccam-insights/skills/pattern-detect` | Track 8: detect recurring tool sequences in thesis workflow → suggest skill candidates | MED | MED |
| **`session-debug`** | Claude-Code-Agent-Monitor `plugins/ccam-devtools/skills/session-debug` | Track 9: when a session goes wrong, dump structured timeline of events for review | LOW | MED |
| **`workflow-optimizer`** | Claude-Code-Agent-Monitor `plugins/ccam-productivity/skills/workflow-optimizer` | Track 8: analyze tool usage / token spend per phase → recommend phase-budget reallocations | MED | LOW |
| **`cost-breakdown`** | Claude-Code-Agent-Monitor `plugins/ccam-analytics/skills/cost-breakdown` | Track 9: per-session cost split by model/tool, with anomaly flagging | LOW | LOW |
| **`code-simplifier`** (agent, not skill) | claudekit-docs | Optional post-DONE pass for P2 (Simplicity First) review | LOW | LOW |
| **`brainstormer`** (agent — promote existing skill to first-class agent for isolation) | claudekit-docs | Multi-perspective adversarial thesis exploration | LOW | LOW |
| **`mcp-manager`** | claudekit-docs | Isolate MCP tool manifest loading to a subagent → preserves main-session token budget. Stockforge has serena+context7+playwright MCPs loaded; isolating them saves ~10K context per session | MED | LOW (deferred until token pressure shows) |
| **`session-compare`** | Claude-Code-Agent-Monitor `plugins/ccam-insights/skills/session-compare` | Track 8: compare two thesis-sessions on same stock for calibration drift | LOW | LOW |
| **`anomaly-alert`** (already partly above) | Claude-Code-Agent-Monitor | Same as `thesis-anomaly-detector` adaptation | — | — |
| **`template-skill`** (canonical 4-line starting point) | claudekit-skills | Skeleton for new skills | TRIVIAL | LOW |

**Skills explicitly NOT to port** (per orch's claudekit-skills note): the 35 generic web-dev domain skills (React, NestJS, Shopify, Bunny, Stripe, etc.) — they would trigger irrelevantly and bloat context.

---

## Hooks/Scripts not yet in orch nor stockforge

Things even orch didn't pick up — applicability check for stockforge.

| Hook/Script | Source | Purpose | Stockforge applicability |
|-------------|--------|---------|--------------------------|
| **UserPromptSubmit invariant injector** | claudekit `dev-rules-reminder.cjs` (concept) | Inject 5-line reminder of stockforge invariants (I-S1 no-LLM-math, I-S2 citations, I-S3 deterministic risk) before every user prompt | HIGH — directly mitigates LLM forgetting "no number from LLM" rule mid-session. Recommend wiring now. |
| **TaskCompleted audit hook** | claudekit (event taxonomy) | On every TaskCompleted event, auto-grep changed files for I-S1/I-S2 violations | HIGH — automates per-task invariant enforcement. Cheap to add. |
| **PostToolUse → I-S2 citation grep** | claudekit pattern | When LLM writes a number to a markdown/YAML file, hook greps for `source:` and `as_of:` adjacent lines; if missing, flags warning | HIGH — exactly the no-hallucination guardrail stockforge needs. |
| **TeammateIdle / SubagentStop watchdog** | claudekit + Claude-Code-Agent-Monitor | Detect stalled subagents (no output for N minutes) and either kill or inject continuation prompt | MED — relevant for long-running crawler subagents. |
| **`scout-block.cjs` / `.ckignore` enforcer** | claudekit | PreToolUse blocks reads of paths in `.ckignore` (e.g. `.env`, `secrets/`) | MED — stockforge already has gitignored `.env`; an explicit `.sfignore` formalizes it. |
| **`privacy-block.cjs`** (sensitive file blocker) | claudekit | PreToolUse blocks writes to sensitive paths | MED |
| **`PreCompact` hook** | Claude Code spec | Fires before auto-compact — opportunity to dump thesis state before context loss | HIGH — relevant for long thesis sessions. Note: orch's `claudekit-docs.md` lists this as the 9th hook event. |
| **OTEL exporter env auto-set** | claude-code-otel README | One-shot script to set `CLAUDE_CODE_ENABLE_TELEMETRY=1` + OTLP endpoint env in `.envrc` or shell profile | LOW — easy bootstrap for Track 9. |
| **Prometheus scrape job for stockforge custom metrics** | claude-code-otel `prometheus.yml` | Scrape stockforge `/metrics` endpoint when API ships in Phase 2+ | DEFER — Phase 2+. |
| **ccs CLI scripts** | ccs.md | `ccs auth list --json` for programmatic profile enumeration | LOW — already invoked via existing `ccs-delegation` skill. |

---

## Telemetry / Self-Awareness Insights (for Track 9)

Specifically targeting stockforge's Self-Awareness Agent.

### What to BORROW now
1. **Single-container `grafana/otel-lgtm:1.4.0` stack** — copy `docker-compose-lgtm.yml`, `collector-config.yaml`, `claude-code-dashboard.json` from `claude-code-otel/` to `docker/otel-stack/`. Idle RAM ~150-300 MB. One-command up.
2. **Standard env vars for Claude Code telemetry** (verbatim from claude-code-otel README):
   ```
   CLAUDE_CODE_ENABLE_TELEMETRY=1
   OTEL_METRICS_EXPORTER=otlp
   OTEL_LOGS_EXPORTER=otlp
   OTEL_EXPORTER_OTLP_PROTOCOL=grpc
   OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
   ```
3. **Pre-built dashboard** (`claude-code-dashboard.json`) covers session count, lines-of-code, cost.usage by model, token.usage (input/output/cache), code_edit_tool.decision — all relevant for self-awareness.
4. **Hook event taxonomy + state machine** from Claude-Code-Agent-Monitor — Track 9 self-awareness needs to know which hooks fired, in what order, with what latency. Borrow the state-machine code structure (active/completed/error/abandoned + reactivation logic) as a Python rewrite.
5. **TranscriptCache** for incremental JSONL reads — Track 9 will need to scan completed session transcripts efficiently.

### What to ADAPT
- **Anomaly-alert skill** → `thesis-confidence-anomaly` skill: flag theses where post-hoc realized return diverges >2σ from forecast confidence band.
- **Workflow-optimizer skill** → `phase-budget-tuner`: analyze per-phase token/cost/duration → recommend phase-budget rebalancing.

### What to LEARN
- claude-code-learn warns: Claude Code does NOT emit traces, only metrics + logs/events. Track 9 should plan for metrics + logs pipelines, not traces. (Stockforge's own Python services CAN emit traces — separate concern.)
- claudekit-skills' "token variance explains 80% of agent performance variance" — Track 9 should track per-session token consumption with prejudice. This is more important than model choice per se.

### What to SKIP
- Multi-tier OTEL stack (4-container Prometheus+Loki+Grafana+collector) — overkill for solo. Single-container LGTM is right default.
- Langfuse alternative — orch documented this; stockforge doesn't need LLM-specific UI when LGTM dashboard already exists for Claude Code.
- VAPID web push, i18n, D3.js workflow viz — agent-monitor has them, stockforge doesn't need them.

---

## Second-Brain / Memory Insights (for Track 8 — Confidence Score)

Specifically targeting stockforge's Confidence Score / second-brain.

### What to BORROW verbatim (MIT — copy with attribution)

1. **L0 regex extractor** (`extract-l0.ts:5-80`):
   - File-path regex: `/(?:^|[\s\`"'(])([.\w/-]+\.\w{1,10})(?=[\s\`"'),;:]|$)/gm`
   - Bash command extraction from triple-backtick blocks + `$ command` lines
   - Error regex (Error/error/ERROR/exception/FATAL/failed: + 10-120 chars)
   - **Failure-pattern regexes** (the gold here — explicit "didn't work / reverted / didn't help / tried X but" patterns)
   Port to Python — runs in microseconds, zero LLM cost. Wire to a Stop hook for every thesis session.

2. **L1 extraction prompt** (`extract-l1.ts:33-64`): 6-category schema (profile, preferences, entities, events, **cases (with FAILED approaches)**, patterns). The explicit "Pay special attention to: 1. FAILED APPROACHES — extract as cases with WHY it failed" is the single most valuable line for stockforge calibration. Run via separate Claude subprocess (preserves I-S1 — LLM doesn't compute, it categorizes).

3. **15+35 head/tail window**: capture intent (first 15 messages = setup) + final state (last 35 = decisions+next). Skip the middle — irrelevant exchanges.

4. **JSONL `cleanText` regex** (`snapshot.ts:38-49`): strips `<system-reminder>`, `<command-name>`, `<task-notification>` tags before extraction. Critical to avoid polluting memories with harness chatter.

### What to ADAPT (stockforge-specific overlay)

- **Confidence calibration record schema** — stockforge-specific extension on top of L1's `events` and `cases` categories:
  ```yaml
  thesis_id: VHM-2026-04-29-bull
  forecast_confidence: 0.72  # claimed by analyst
  forecast_band: [+8%, +18%]  # claimed return band
  realized_return: ...        # filled at horizon
  hit_rate_at_band: ...       # historical hit rate this analyst on similar setups
  drift_signal: DR1|DR2|...   # if calibration drifts
  failed_approaches: [...]    # extracted via L0/L1
  decisions: [...]            # extracted via L0/L1
  ```
- Store under `agent-workspace/calibration/` (per existing CLAUDE.md reference).

### What to SKIP (per claude-sessions analysis)
- Multi-agent registry (Codex/Qwen/Gemini) — stockforge is Claude-only.
- Cross-session shared memory pool with hotness — overkill for v1; per-thesis point-to-point handoff is enough.
- TUI picker, MCP server, i18n — irrelevant.

### Key insight (mirror orch's finding)
> The L1 prompt's explicit emphasis on FAILED APPROACHES is the killer feature. We would not have invented this from scratch. Stockforge calibration depends on knowing what didn't work, not just what did.

---

## Skip / Not Applicable

Things that look interesting but don't fit stockforge in any phase.

| Pattern | Source | Reason to skip |
|---------|--------|----------------|
| Telegram bot infrastructure (Grammy, sequentialize, cancel-bypass, forum-topic isolation, secret-redact) | claudegram, claude-to-im, claude-code-telegram | Phase 4+ alerts only. Note: keep `_redact_secrets` regex if/when alerts ship. |
| Docker container-per-agent | nanoclaw, praktor | stockforge runs single-host single-user. Subprocess is enough. |
| NATS pub/sub bus | praktor | EventEmitter / Python `asyncio.Queue` is enough for solo. |
| Swarm graph DAG with topological tiers | praktor | v3+ scope. stockforge thesis sessions are sequential and read-only. |
| AI tier-3 routing (LLM classifies messages) | praktor | Violates I-S1 (no LLM in daemon code). Prefix routing only if needed. |
| Vault / encrypted secrets manager | praktor | `.env` + file permissions sufficient. No paid leaks. |
| Two-DB split (inbound/outbound SQLite) | nanoclaw | Solves Docker cross-mount problem stockforge doesn't have. |
| Bun runtime | nanoclaw | Python-first stack. |
| `journal_mode=DELETE` | nanoclaw | Postgres + Redis stack — N/A. |
| Multi-platform Markdown rendering (Feishu/Discord) | claude-to-im | Telegram-only at most. Streamlit is markdown-native. |
| OS-level managed policies (MDM plist / Windows registry) | phase-8-oss-config-patterns | Personal-use; no enterprise scope. |
| File-polling hot-reload | praktor / phase-8 | Daemon restart on config change is fine for solo. |
| Marketplace plugin distribution (`/plugin marketplace`) | claudekit-skills | Solo. Premature optimization. |
| Python venv globally for skills | claudekit-skills | stockforge is `pyproject.toml`-managed; uv/poetry handles env. |
| MCP-dependent sequential-thinking | claudekit-skills | I-S1 invariant: no MCP that adds non-deterministic LLM-math layer. P1 think-first principle suffices. |
| Voice transcription / TTS / Telegraph routing / browser automation / Reddit/Medium/YouTube content scraping | claudegram, claude-code-telegram | Out of charter. (Note: stockforge crawler-reliability skill covers domain-specific scrapers like CafeF/NDH/YouTube — that's separate.) |
| `claude-code-learn` source code | Anthropic IP | Educational understanding only. Zero verbatim copy. |

---

## Open questions / risks for stockforge

1. **Hook result schema correctness**: if stockforge ever wires PreToolUse for I-S2 enforcement (block writes that lack citations), the hook handler MUST return `{decision: approve|deny|modify, message?, additionalContexts?}` per claude-code-learn. Generic JSON returns silently break the gate.

2. **Skill validator integration**: porting `quick_validate.py` is trivial; harder is wiring it into `pre-commit` without breaking existing 12 skills (which currently violate the 150-LOC rule). Recommend: validator accepts a `--soft-warn` flag for first month, then flips to hard-fail.

3. **L0/L1 language detection**: the claude-sessions L0 extractor has Russian comments in regex patterns and *appears* to handle bilingual (Russian "не сработал" + English "didn't work"). For stockforge with Vietnamese sources, we'll need to extend FAILURE_PATTERNS with Vietnamese phrases ("không hoạt động", "không hiệu quả", "đã thử nhưng"). Trivial addition but easy to forget.

4. **Telemetry opt-in**: phase-8-oss-config-patterns recommends opt-in upstream telemetry. For stockforge personal use, all telemetry stays local (single-container OTEL). If we ever publish stockforge as OSS, design opt-in upstream from day 1.

5. **No insider info / no paid leaks**: stockforge has stricter content rules than any of these reference repos. None of the borrowed patterns conflict, but reviewers should re-confirm: nothing borrowed should require paid data sources or insider channels.

---

## File-path index (absolute paths)

**Orch research notes used**:
- `C:\htdocs\orch-starter\agent-workspace\research\SYNTHESIS.md`
- `C:\htdocs\orch-starter\agent-workspace\research\claudekit-skills.md`
- `C:\htdocs\orch-starter\agent-workspace\research\claudekit-docs.md`
- `C:\htdocs\orch-starter\agent-workspace\research\claude-sessions.md`
- `C:\htdocs\orch-starter\agent-workspace\research\claude-code-agent-monitor.md`
- `C:\htdocs\orch-starter\agent-workspace\research\claude-code-otel.md`
- `C:\htdocs\orch-starter\agent-workspace\research\claude-code-learn.md`
- `C:\htdocs\orch-starter\agent-workspace\research\claude-code-telegram.md`
- `C:\htdocs\orch-starter\agent-workspace\research\claudegram.md`
- `C:\htdocs\orch-starter\agent-workspace\research\claude-to-im.md`
- `C:\htdocs\orch-starter\agent-workspace\research\nanoclaw.md`
- `C:\htdocs\orch-starter\agent-workspace\research\praktor.md`
- `C:\htdocs\orch-starter\agent-workspace\research\claude-session-dashboard.md`
- `C:\htdocs\orch-starter\agent-workspace\research\ccs.md`
- `C:\htdocs\orch-starter\agent-workspace\research\phase-8-oss-config-patterns.md`

**Repo source files referenced (verbatim borrow targets)**:
- `C:\htdocs\orch-starter\reference-repos\claude-sessions\src\memory\extract-l0.ts`
- `C:\htdocs\orch-starter\reference-repos\claude-sessions\src\memory\extract-l1.ts`
- `C:\htdocs\orch-starter\reference-repos\claude-sessions\src\memory\snapshot.ts`
- `C:\htdocs\orch-starter\reference-repos\claude-code-otel\docker-compose-lgtm.yml`
- `C:\htdocs\orch-starter\reference-repos\claude-code-otel\collector-config.yaml`
- `C:\htdocs\orch-starter\reference-repos\claude-code-otel\claude-code-dashboard.json`
- `C:\htdocs\orch-starter\reference-repos\Claude-Code-Agent-Monitor\plugins\ccam-insights\skills\anomaly-alert\SKILL.md`
- `C:\htdocs\orch-starter\reference-repos\Claude-Code-Agent-Monitor\plugins\ccam-productivity\skills\daily-standup\SKILL.md`
- `C:\htdocs\orch-starter\reference-repos\Claude-Code-Agent-Monitor\plugins\ccam-devtools\skills\hook-diagnostics\SKILL.md`
- `C:\htdocs\orch-starter\reference-repos\Claude-Code-Agent-Monitor\server\routes\hooks.js`
- `C:\htdocs\orch-starter\reference-repos\Claude-Code-Agent-Monitor\server\lib\transcript-cache.js`

**Stockforge targets to update or create**:
- `C:\htdocs\stockforge\.claude\skills\*\SKILL.md` (refactor for progressive disclosure + add `allowed-tools`)
- `C:\htdocs\stockforge\.claude\skills\session-memory-l0-l1\SKILL.md` (new — Track 8)
- `C:\htdocs\stockforge\.claude\skills\thesis-anomaly-detector\SKILL.md` (new — Track 9)
- `C:\htdocs\stockforge\.claude\skills\daily-thesis-summary\SKILL.md` (new — Track 9)
- `C:\htdocs\stockforge\.claude\skills\hook-diagnostics\SKILL.md` (new — Track 9)
- `C:\htdocs\stockforge\.claude\hooks\inject-invariants.sh` (new — UserPromptSubmit)
- `C:\htdocs\stockforge\.claude\hooks\citation-check.sh` (new — PostToolUse for I-S2)
- `C:\htdocs\stockforge\scripts\validate_skills.py` (new — quick_validate.py port)
- `C:\htdocs\stockforge\docker\otel-stack\docker-compose-lgtm.yml` (copy from claude-code-otel)
- `C:\htdocs\stockforge\docker\otel-stack\collector-config.yaml` (copy)
- `C:\htdocs\stockforge\docker\otel-stack\claude-code-dashboard.json` (copy)
- `C:\htdocs\stockforge\packages\utils\secret_redactor.py` (new — port from claude-code-telegram)
- `C:\htdocs\stockforge\packages\observability\transcript_cache.py` (Python port)
- `C:\htdocs\stockforge\packages\observability\state_machine.py` (Python port for Track 9)

---

*End of pattern-mining-refrepos.md — 12 BORROW + 10 ADAPT + 5 LEARN + 14 candidate skills + 10 hook ideas + Track-8/Track-9 specific guidance.*
