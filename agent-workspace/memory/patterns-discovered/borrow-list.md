# Borrow List — Combined 3-Source Master Inventory
**Date**: 2026-04-29
**Format**: actionable port list, sorted by priority for stockforge Phase 0
**Sources**: pattern-mining-{orch,msmdp,refrepos}.md
**Companion**: SYNTHESIS.md

---

## TIER 1 — Port in Phase 0 (must-have for autonomous loop)

### BORROW (verbatim port with rename only)

| # | Name | Source (file) | Purpose | Stockforge destination | Est tokens | Prerequisites |
|---|---|---|---|---|---|---|
| **B-1** | `budget-watchdog.sh` (real-transcript watchdog → `.transcript-tokens`) | orch `scripts/hooks/budget-watchdog.sh` | Defeats Mode C self-track illusion; authoritative real budget for wind-down | `scripts/hooks/budget-watchdog.sh` (or .py rewrite) | 5K | Track 5 |
| **B-2** | `dispatch-jsonl-recorder.sh` + 9-field schema | orch `decisions/023-7.2-dispatch-jsonl-schema.md` + `scripts/hooks/dispatch-jsonl-recorder.sh` | Append-only machine-readable event log for telemetry/calibration | `scripts/hooks/dispatch-jsonl-recorder.{sh,py}` + `agent-workspace/memory/dispatch.jsonl` | 6K | Track 5 |
| **B-3** | `autonomous-stop-watchdog.sh` + `continue-injector.ps1` | orch `scripts/hooks/autonomous-stop-watchdog.sh` + `scripts/hooks/continue-injector.ps1` | Structural Mode-C fix; SendKeys foreground-bypass (4-retry) | `scripts/hooks/autonomous-stop-watchdog.{sh,py}` + Windows continue-injector | 8K | Track 5 |
| **B-4** | `session-self-reboot.{sh,ps1}` + `session-handoff.sh` | orch `scripts/session-self-reboot.{sh,ps1}` + `scripts/session-handoff.sh` | 230K-trigger self-reboot + cross-session handoff | `scripts/session-self-reboot.{sh,ps1}` + `scripts/session-handoff.sh` | 7K | Track 5 |
| **B-5** | Decision template + README index format (NNN-slug.md) | orch `agent-workspace/memory/decisions/README.md` + 43 decision files | Sequential decision-doc discipline; status: active/superseded-by-XXX/ratified | `agent-workspace/memory/decisions/_template.md` + README.md | 3K | Track 2 |
| **B-6** | OTEL single-container stack (3 files verbatim) | refrepos `claude-code-otel/{docker-compose-lgtm.yml, collector-config.yaml, claude-code-dashboard.json}` | Idle ~150-300MB grafana/otel-lgtm:1.4.0; pre-built dashboard for session/cost/token/edit-decision | `docker/otel-stack/{docker-compose-lgtm.yml, collector-config.yaml, claude-code-dashboard.json}` | 4K | Track 9 |
| **B-7** | OTEL env vars (5 lines) | refrepos `claude-code-otel/README` | `CLAUDE_CODE_ENABLE_TELEMETRY=1` + OTLP endpoint config | `.env.example` + `.envrc` | 1K | Track 9 |
| **B-8** | claude-sessions L0 regex extractor (file/cmd/error/FAILURE patterns) | refrepos `claude-sessions/src/memory/extract-l0.ts:5-80` | Microsecond-cost session-end fact extraction (zero LLM) | `packages/observability/extract_l0.py` | 6K | Track 8b |
| **B-9** | claude-sessions L1 prompt (6-category schema, FAILED priority) | refrepos `claude-sessions/src/memory/extract-l1.ts:33-64` | Verbatim-portable LLM prompt; "FAILED APPROACHES" emphasis is killer feature | `.claude/skills/session-memory-l0-l1/SKILL.md` | 3K | Track 8b |
| **B-10** | 15+35 head/tail windowing constants | refrepos `claude-sessions/src/memory/snapshot.ts` | First 15 = setup, last 35 = decisions+next; skip middle | Same skill above | 1K | Track 8b |
| **B-11** | `cleanText` regex (strips system-reminder/command-name/task-notification tags) | refrepos `claude-sessions/src/memory/snapshot.ts:38-49` | Critical: prevent harness chatter polluting memories | Same skill above | 1K | Track 8b |
| **B-12** | `_redact_secrets` regex (API keys, AWS, Bearer, conn strings) | refrepos `claude-code-telegram/src/claude/orchestrator.py:52-80` | Secret redaction for any future log/alert outputs | `packages/utils/secret_redactor.py` | 2K | Track 5 |
| **B-13** | Decision 028 config-style normative format (LOC ceilings, frontmatter, archetype field) | orch `decisions/028-config-style-normative-format.md` | 200/150/120 LOC for agents/skills/commands; canonical `tools` key; archetype required | `agent-workspace/constitution/config-style-guide.md` | 3K | Track 7 |
| **B-14** | spec-compliance-reviewer + code-quality-reviewer + sandwich-verifier subagent definitions | orch `.claude/agents/{spec-compliance-reviewer,code-quality-reviewer,sandwich-verifier}.md` | Two-stage subagent review + opus fresh-context phase-close verifier (~25% productive FAIL rate) | `.claude/agents/{spec-compliance-reviewer,code-quality-reviewer,sandwich-verifier}.md` | 12K | Track 6 |
| **B-15** | mistake-log.md structured format (What / Root cause / Prevention rule / Severity) | msmdp `14-self-evaluation-framework.md` §V + `37-mdp-workflow-integration.md` "Change C" | First-class failure catalog; pre-flight read; 28→3 errors/sprint | `agent-workspace/memory/mistake-log.md` (NEW) | 2K | Track 7 |

**TIER 1 BORROW total: ~64K tokens**

### ADAPT (port with stockforge-specific adaptation)

| # | Name | Source | What to adapt | Destination | Est tokens | Prerequisites |
|---|---|---|---|---|---|---|
| **A-1** | Effort routing D1-D6 framework | orch `decisions/032-effort-routing.md` | Subscription-quota → Claude API rate-limit headroom; concurrency caps unchanged (≤4 agents/≤2 opus/≤1 opus-max) | `agent-workspace/memory/decisions/NNN-effort-routing.md` + `.claude/skills/effort-routing/SKILL.md` | 8K | Track 7 |
| **A-2** | UserPromptSubmit invariant injector | refrepos `claudekit/dev-rules-reminder.cjs` (concept) | Inject 5-line reminder of stockforge I-S1 (no-LLM-math), I-S2 (citations), I-S3 (deterministic risk) before each prompt | `.claude/hooks/inject-invariants.sh` + settings.json wiring | 3K | Track 5 |
| **A-3** | PostToolUse citation grep (I-S2 enforcement) | refrepos pattern from claudekit | When LLM writes number to MD/YAML, grep adjacent lines for `source:` and `as_of:`; flag missing | `.claude/hooks/citation-check.sh` | 4K | Track 5 |
| **A-4** | TaskCompleted audit hook | refrepos pattern | Auto-grep changed files for I-S1/I-S2 violations on task close | `.claude/hooks/task-completed-audit.sh` | 4K | Track 5 |
| **A-5** | PreCompact hook (dump thesis state before context loss) | refrepos pattern | Persist active thesis YAML before auto-compact | `.claude/hooks/pre-compact-thesis-dump.sh` | 3K | Track 5 |
| **A-6** | charter-coherence-spot-check | orch `scripts/verify/charter_coherence_spot_check.*` | Greps for "buy/sell/recommend" without "thesis exploration" framing; LLM-output numerics without code-source citation | `scripts/verify/charter_coherence_spot_check.py` | 5K | Track 5 |
| **A-7** | rollup_telemetry deterministic aggregator + telemetry-analyst subagent | orch `scripts/utilities/rollup-telemetry.ts` + `.claude/agents/telemetry-analyst.md` | TS→Python rewrite; stockforge RULES: source-failure, thesis-bear-case-missing, calibration-drift | `scripts/utilities/rollup_telemetry.py` + `.claude/agents/telemetry-analyst.md` | 8K | Track 9 |
| **A-8** | Phase-N-complete.md retrospective template (§A-§I) | orch `phase-{1..11}-complete.md` consistent template | Stockforge phases (research→ingest→thesis→calibration→portfolio→publish); SC scorecard adapted to per-thesis | `agent-workspace/memory/phase-N-complete.md` template | 3K | Track 7 |
| **A-9** | Sandwich-architect Mandates A-E (pre-write VBW dry-run, staged-index, awk-range self-match, ≥10 incremental Edits) | orch `.claude/agents/sandwich-architect.md` + `decisions/037-sc39-retry-verdict-v2.6.md` | Stockforge: pre-write VBW + staged-index for data files + source-citation grep + multi-perspective coverage check | `.claude/agents/sandwich-architect.md` | 6K | Track 6 |
| **A-10** | Skill self-test discipline (sibling test.md + Stop-hook sampling) | orch `phase-0-4-meta-retrospective.md` proposal #10 | For each `.claude/skills/<name>/SKILL.md` add `<name>.test.md` with assertions block | All 12 stockforge skills + `scripts/skills_self_test.py` | 10K | Track 6 |
| **A-11** | `validate_skills.py` skill validator | refrepos `claudekit-skills/quick_validate.py` | Frontmatter/kebab-case-name/description ≤200ch/body ≤200 LOC; `--soft-warn` first 30 days | `scripts/validate_skills.py` + pre-commit hook | 3K | Track 6 |
| **A-12** | Progressive-disclosure skill structure | refrepos claudekit-skills | SKILL.md ≤150 LOC + `references/` subdir + `scripts/` subdir; refactor all 12 existing | All `.claude/skills/<name>/` | 30K (12 skills × 2.5K) | Track 6 |
| **A-13** | `allowed-tools` frontmatter field | refrepos claudekit-skills (Oct 2025 spec) | Pre-approve tools per skill; reduces permission noise | All 12 SKILL.md frontmatters | 2K | Track 6 |
| **A-14** | Hook event state machine (active/completed/error/abandoned + reactivation) | refrepos `Claude-Code-Agent-Monitor/server/routes/hooks.js:54-328` | Python rewrite for Track 9 self-awareness | `packages/observability/state_machine.py` | 8K | Track 9 |
| **A-15** | TranscriptCache (LRU + mtime+size dual-check + byte-offset incremental reads) | refrepos `Claude-Code-Agent-Monitor/server/lib/transcript-cache.js` (415 LOC) | Python port; foundation for L0/L1 extraction | `packages/observability/transcript_cache.py` | 8K | Track 8b |
| **A-16** | thesis-anomaly-detector skill | refrepos `Claude-Code-Agent-Monitor/plugins/ccam-insights/skills/anomaly-alert/` | Stockforge-flavored: flags theses where confidence claim diverges >2σ from historical hit rate | `.claude/skills/thesis-anomaly-detector/SKILL.md` | 4K | Track 9 |
| **A-17** | daily-thesis-summary skill | refrepos `Claude-Code-Agent-Monitor/plugins/ccam-productivity/skills/daily-standup/` | Daily auto-rollup: theses logged, calibration delta, citations harvested, drift signals | `.claude/skills/daily-thesis-summary/SKILL.md` | 3K | Track 9 |
| **A-18** | hook-diagnostics skill | refrepos `Claude-Code-Agent-Monitor/plugins/ccam-devtools/skills/hook-diagnostics/` | Programmatic hook health check (which fired, latency, errors) | `.claude/skills/hook-diagnostics/SKILL.md` | 3K | Tracks 5+9 |
| **A-19** | Drift-signal grep scripts (D1-D8 hook-runnable) | msmdp `14-self-evaluation-framework.md` §I | Stockforge has DR1-DR12 human-checked; convert to grep-runnable scripts via msmdp pattern | `scripts/drift-checks/*.py` | 6K | Track 5 |
| **A-20** | session-handoff.md structured format (5 sections: summary/pending-per-agent/notes-with-root-cause/quality-gate) | msmdp `26-multi-agent-sandwich-workflow.md` §3.3 | Refine `current-execution.md` format; explicit "Pending: Architect" vs "Pending: Dev" lists | `agent-workspace/memory/current-execution.md` template | 2K | Track 1+2 |
| **A-21** | Local-first agent mailbox (`.context/agent-mailbox/{inbox,outbox,shared-state,budget,discussion-log}.md`) | msmdp `20-multi-agent-communication.md` §4 | Stockforge `agent-workspace/observations/` + `agent-workspace/sync-tracker/` adopt mailbox file format | `agent-workspace/observations/{inbox,outbox,shared-state,budget,discussion-log}.md` | 4K | Track 1+8 |
| **A-22** | VBW protocol granular checkpoints (Pre-Spec / Pre-Test / Mid-Implement-every-5-steps / Post-Implement) + 5 rules (VBW/CCF/SYA/DA/TBA) | msmdp `18-ai-agent-self-governance.md` | Stockforge has `vbw-check` command; adopt more granular checkpoint structure + DA (Drift Anchor every 5 steps) | `agent-workspace/constitution/vbw-protocol.md` refinement | 4K | Track 7 |
| **A-23** | Same-Commit Rule (spec ↔ code coupling, pre-commit hook) | msmdp `04-spec-driven-development.md` "Spec Maintenance" | Pre-commit detects spec/code mismatch; Charter exempt (immutable per CLAUDE.md) | `.claude/hooks/pre-commit-spec-coupling.sh` | 3K | Track 5+7 |
| **A-24** | PBI template (Directive + Context Pointer + Verification Pointer + Refinement Rule) | msmdp `04-spec-driven-development.md` §"PBI Cho Agent" | Adapt to thesis tasks: "Directive: explore PNJ", "Context Pointer: specs/thesis/methodology.md", "Verification Pointer: PNJ scenarios", "Refinement Rule: halt if data unavailable" | `tasks/_template.md` | 2K | Track 7 |
| **A-25** | .claudeignore + layered context loading | refrepos `25-token-context-optimization.md` §3.1, §5.2-3 | Exclude `obsidian-vault/raw/`, `eval-sets/`, deep `agent-workspace/memory/sessions/`. Load order: constitution → current-execution → BC spec → source on-demand | `.claudeignore` + CLAUDE.md context-loading section | 3K | Track 7 |
| **A-26** | Identity emoji + role prefix per agent + budget caps | msmdp `20-multi-agent-communication.md` §1, §3 | Stockforge agents get visual identity + per-interaction budget caps (questions/files/tokens); Guardian halts on breach | `.claude/agents/*.md` frontmatter additions | 4K | Track 6+7 |
| **A-27** | thesis-anti-patterns.md catalog (A-thesis1: single-perspective, A-thesis2: LLM-numbers, A-thesis3: confidence without calibration, A-thesis4: portfolio conflict) | msmdp `14-self-evaluation-framework.md` §III pattern | Stockforge stock-domain version of msmdp anti-behavior catalog | `agent-workspace/constitution/thesis-anti-patterns.md` | 3K | Track 7 |

**TIER 1 ADAPT total: ~144K tokens**

### LEARN (concept only, internalize in CLAUDE.md or constitution)

| # | Name | Source | Concept summary | Where to encode |
|---|---|---|---|---|
| **L-1** | Tool-call-first ordering rule (TURN-END DISCIPLINE) | orch `autonomous-protocol.md` lines 277-385 | When dispatching after `<task-notification>`, structure assistant response with `Agent` tool_use FIRST. Defeats Mode B API mid-stream truncation | `agent-workspace/constitution/autonomous-protocol.md` (NEW — port verbatim with stockforge path subs) |
| **L-2** | Run-in-background mandatory for Agent dispatches | orch `agent-notes.md` line 31-33 | Foreground stalls runtime; `<task-notification>` only fires for background | `CLAUDE.md` Hard Rules + autonomous-protocol.md MUST rule |
| **L-3** | Hook commands prefix `${CLAUDE_PROJECT_DIR:-.}` + `mkdir -p` | orch `agent-notes.md` line 36-38 | Relative paths break from subagent cwds | All `scripts/hooks/*.{sh,py}` (universal prefix rule, encoded in hook authoring guide) |
| **L-4** | USER-CRITICAL severity tier + phase-entry user_prompt re-read | orch `constitution/user-intent-coherence.md` + `decisions/040` | Severity above "important"; cannot defer to next phase without explicit user-override; multi-cycle defer FORBIDDEN absent user re-grant | `agent-workspace/constitution/user-intent-coherence.md` (NEW) |
| **L-5** | Self-application as Phase 0 deliverable (NOT deferred CF) | orch `decisions/039`+`040` (4-cycle CF-DOGFOOD-2 lesson) | Encode self-application from day 1; stockforge-codes-stockforge; calibration → source-weighting feedback wired Phase 0 | `agent-workspace/constitution/self-application-bootstrap.md` (NEW) |
| **L-6** | Identity discipline / scope discipline | orch `decisions/042`→`043` reversal (Phase 13 narrowing) | Stockforge identity = AI-first VN stock advisory. Don't drift into adjacent framework features. Explicit NOT-list | `agent-workspace/constitution/identity-scope.md` (NEW) |
| **L-7** | Three-mode loop-break taxonomy (Mode A/B/C) named with structural fixes | orch `phase-0-4-meta-retrospective.md` § Mode A/B/C analysis | A=narrate-without-tool / B=API truncation / C=self-track illusion. Each has structural fix (tool-call-first / continue-injector / `.transcript-tokens` watchdog) | `agent-workspace/constitution/autonomous-protocol.md` § DEFEATING FAILURE MODES |
| **L-8** | Two-stage subagent review pattern (sonnet impl → sonnet spec-compliance → sonnet code-quality → opus sandwich-verifier at phase close) | orch project-complete.md "What Worked Well" | Highest-value quality gate; ~25% opus FAIL rate is system working, not noise | `CLAUDE.md` Quality Gates section refinement |
| **L-9** | Calibration over confidence (verifier productive failure rate) | orch `phase-0-4-meta-retrospective.md` §4.3 | Don't suppress verifier-FAIL rate by tuning down adversarial mode; tune only on false positives | `CLAUDE.md` Hard Rules + `agent-workspace/calibration/` README |
| **L-10** | Document-And-Move decision discipline | orch `autonomous-protocol.md` Rule 7 + Decision 027 | One paragraph per decision (Context/Options/Choice/Why), then move on. But: ≥200-word user prompt with new dimensions = re-author plan, NOT silently advance | `agent-workspace/constitution/decision-discipline.md` (or merge into provenance-protocol.md) |
| **L-11** | Multi-cycle structural-defer admissibility test | orch `decisions/033` + §L5 | Admissible IF: re-attempt prerequisites enumerated + supersession-target = future binding decision + NOT USER-CRITICAL. >3 cycles flag the gate | Same constitution file; encode 3-cycle alert |
| **L-12** | Performative-vs-actionable verdict discipline | orch `decisions/025-7.7-sc39-defer.md` | Self-evolution loop on signal-thin data = "performative theater". DEFER with explicit re-attempt prerequisites better than firing vacuous proposals | Same constitution file |
| **L-13** | Independence audit when authoring defers | orch `decisions/040` §E.2 | When deferring item A blocked by item B, prove dependency real (not architectural conflation) | Same constitution file |
| **L-14** | Lost-in-the-Middle empirical curve (Liu 2023) | msmdp `25-token-context-optimization.md` §2.1 | LLMs lose accuracy mid-context. Critical rules at TOP; fresh state at BOTTOM; spec/source middle only if compact | `CLAUDE.md` ordering enforcement + skill writing guide |
| **L-15** | Quadratic Attention Cost (32K→128K = 16× compute, not 4×) + quality decreases per token at long context | msmdp `25` §2.2-3 | 250K mandatory split rule = empirical, not paranoia | `CLAUDE.md` 250K rule already exists; reinforce reasoning |
| **L-16** | "Spec is God" cascading-failure framing | msmdp `22-spec-integrity-agent-operations.md` §1.2 | Spec corruption is exponentially worse than code bugs in multi-agent world. Don't lower bar to spec change | `agent-workspace/constitution/spec-authority.md` (or merge into existing) |
| **L-17** | The 80/20 Inversion (humans 20%, agents 80% of time) | msmdp `22` §1.1 | Pain points come from agents' 80%. Instrument the 80%, not optimize the 20% | `CLAUDE.md` philosophy section |
| **L-18** | "Regression to Mean" warning vs L4/L5 autonomy | msmdp `05-agentic-sdlc.md` §"L3 Fighter Jet" | Without human strategic intent, agents pick generic boilerplate. Full-autonomous needs SHARP human-set boundaries (charter, invariants, drift signals) | `CLAUDE.md` Identity section + Charter footnote |
| **L-19** | Hook result schema correctness (`{decision: approve\|deny\|modify}`) | refrepos claude-code-learn (Anthropic source) | Generic JSON returns silently break gates. Hook handlers MUST follow schema | Hook authoring guide |
| **L-20** | Three parallelism levels in Claude Code (turn-internal / subagent-via-AgentTool / persistent-teammates) | refrepos claude-code-learn | Subagents do NOT share context window — justifies "spawn fresh session for L1 extraction" | Architecture decisions doc |
| **L-21** | Spec dual-layer (Blueprint + Contract) confirms stockforge spec-dual-layer skill is on track | msmdp `04-spec-driven-development.md` | Validates current direction; PBI 4-part format is refinement | `.claude/skills/spec-dual-layer/SKILL.md` refinement |
| **L-22** | Levels of Autonomy (L0-L5 SAE map) — target L3 ("Fighter Jet": human steers + intervenes; agent executes maneuvers) | msmdp `05-agentic-sdlc.md` | Validates stockforge full-autonomous-but-with-human-checkpoint model | CLAUDE.md philosophy + Charter footnote |
| **L-23** | "Catch errors at cheapest gate" cost-tier table | msmdp `06-context-gates.md` Tier 2 | Tier 1 (deterministic) cheap; Tier 2 (probabilistic separate-agent) medium; Tier 3 (human) expensive. Push errors LEFT | `CLAUDE.md` Quality Gates section refinement |
| **L-24** | Token variance explains 80% of agent performance variance | refrepos claudekit-skills | Track per-session token consumption with prejudice; more important than model choice | `.claude/skills/effort-routing/SKILL.md` + Self-Awareness profile cards |

---

## TIER 2 — Defer to Phase 1+ (nice-to-have)

### BORROW

| # | Name | Source | Purpose | Destination | Phase |
|---|---|---|---|---|---|
| **T2-B-1** | Token-bucket rate limiter (cost+request dual limit) | refrepos `claude-code-telegram/rate_limiter.py` | External API calls (CafeF, NDH, FireAnt) | `packages/crawlers/rate_limit.py` | Phase 2 |
| **T2-B-2** | Atomic file writes (tmp+rename) + Pydantic schema validation | refrepos `claudegram/src/claude/session-history.ts` | Prevent corrupt-file crashes for memory state | Memory layer files | Phase 1+ |

### ADAPT

| # | Name | Source | Adaptation | Destination | Phase |
|---|---|---|---|---|---|
| **T2-A-1** | Tenancy model file-level isolation | orch `decisions/029-tenancy-model-file-level.md` | Per-user thesis namespaces; shared sources read-only | `agent-workspace/users/<id>/` + tenancy constitution | Phase 6+ |
| **T2-A-2** | Wake-dedup promise map | refrepos `nanoclaw/src/container-runner.ts:50-92` | Concurrent spawn race protection (Python asyncio.Lock + dict[str, Future]) | Async crawler/extractor pools | Phase 2+ |
| **T2-A-3** | Stuck-session decideStuckAction | refrepos `nanoclaw/src/host-sweep.ts:70-106` | Watchdog for long-running crawler tasks | `packages/crawlers/watchdog.py` | Phase 2+ |
| **T2-A-4** | 3-tier prefix routing | refrepos `praktor/internal/router/router.go:34-77` | If chat/Telegram alerts ship, prefix-only (`@portfolio`, `@thesis`); never LLM-routing in daemon | If alerts feature lands | Phase 4+ |
| **T2-A-5** | workflow-optimizer skill / phase-budget-tuner | refrepos `Claude-Code-Agent-Monitor` | Analyze tool usage / token spend per phase → recommend phase-budget rebalancing | `.claude/skills/phase-budget-tuner/` | Phase 1+ |
| **T2-A-6** | pattern-detect skill | refrepos `Claude-Code-Agent-Monitor` | Detect recurring tool sequences → suggest skill candidates | `.claude/skills/pattern-detect/` | Phase 1+ |
| **T2-A-7** | session-debug skill | refrepos `Claude-Code-Agent-Monitor` | Dump structured timeline of events on session-gone-wrong | `.claude/skills/session-debug/` | Phase 1+ |
| **T2-A-8** | session-compare skill | refrepos `Claude-Code-Agent-Monitor` | Compare two thesis-sessions on same stock for calibration drift | `.claude/skills/session-compare/` | Phase 1+ |
| **T2-A-9** | cost-breakdown skill | refrepos | Per-session cost split by model/tool, anomaly flagging | `.claude/skills/cost-breakdown/` | Phase 1+ |
| **T2-A-10** | mcp-manager skill | refrepos claudekit-docs | Isolate MCP tool manifest loading to subagent (saves ~10K context) | `.claude/skills/mcp-manager/` | Phase 1+ (when token pressure shows) |
| **T2-A-11** | Cross-agent memory pool with hotness scoring (recency 0.3 + freq 0.4 + relevance 0.3) | refrepos `claude-sessions/src/memory/hotness.ts` | If Track 8 second-brain expands beyond per-thesis to cross-thesis | Phase 2+ |
| **T2-A-12** | Sync ladder full formalization (G in deferred T2) | UP02 §1.2 + Decision 002 § Open Items | Extend `/grill-me` to track sync state across language→ubiquitous→design→goals; skill `/grill-me-sync` | Phase 1+ |
| **T2-A-13** | Obsidian visualization full | UP02 §1.3 | Graph view, dashboards, decision tree rendering | Phase 1+ |
| **T2-A-14** | Deep pattern mining (telemetry-analyst-style RULE-1..N self-evolution) | UP02 §1.4 + orch §A1 | SC-39-style scaffolding | Phase 1+ |

### LEARN

| # | Name | Source | Concept | Where to encode (later) |
|---|---|---|---|---|
| **T2-L-1** | DI context via singleton (avoid framework lock-in) | refrepos `claude-to-im/src/lib/bridge/context.ts` | Python `context.py` in `packages/domain/` exposing `get_stockforge_context()` populated at FastAPI/Streamlit bootstrap | When FastAPI/Streamlit ships |
| **T2-L-2** | Passive vs active observability tradeoff | refrepos `claude-session-dashboard` | stockforge naturally active; lock-dir + mtime-<120s liveness signal IF orphan-detection ever needed | Phase 2+ |
| **T2-L-3** | OS-level managed policies (MDM plist / Windows registry) | refrepos `phase-8-oss-config-patterns` | Personal-use; no enterprise scope. Document only IF stockforge becomes enterprise | Never (per identity scope) |

---

## SKIP — Explicit non-applicability

| # | Name | Source | Why not applicable to stockforge |
|---|---|---|---|
| **S-1** | Telegram bot infrastructure (Grammy, sequentialize, cancel-bypass, forum-topic isolation) | claudegram, claude-to-im, claude-code-telegram | Phase 4+ alerts only. Single useful borrow = `_redact_secrets` regex (B-12) for any future log/alert outputs |
| **S-2** | Docker container-per-agent | nanoclaw, praktor | Single-host single-user; subprocess sufficient |
| **S-3** | NATS pub/sub bus | praktor | EventEmitter / Python asyncio.Queue sufficient for solo |
| **S-4** | Swarm graph DAG with topological tiers | praktor | v3+ scope; thesis sessions sequential and read-only |
| **S-5** | AI tier-3 routing (LLM classifies messages) in daemon | praktor | Violates I-S1 (no LLM in daemon code). Prefix routing only |
| **S-6** | Vault / encrypted secrets manager | praktor | `.env` + file permissions sufficient. No paid leaks |
| **S-7** | Two-DB split (inbound/outbound SQLite) | nanoclaw | Solves Docker cross-mount problem stockforge doesn't have |
| **S-8** | Bun runtime | nanoclaw | Python-first stack |
| **S-9** | `journal_mode=DELETE` | nanoclaw | Postgres + Redis stack — N/A |
| **S-10** | Multi-platform Markdown rendering (Feishu/Discord) | claude-to-im | Telegram-only at most. Streamlit is markdown-native |
| **S-11** | File-polling hot-reload | praktor / phase-8 | Daemon restart on config change is fine for solo |
| **S-12** | Marketplace plugin distribution (`/plugin marketplace`) | claudekit-skills | Solo. Premature optimization |
| **S-13** | Python venv globally for skills | claudekit-skills | stockforge is `pyproject.toml`-managed; uv/poetry handles env |
| **S-14** | MCP-dependent sequential-thinking | claudekit-skills | Violates I-S1 (no MCP that adds non-deterministic LLM-math layer). P1 think-first principle suffices |
| **S-15** | Voice transcription / TTS / Telegraph routing / browser-automation / Reddit/Medium/YouTube content scraping | claudegram, claude-code-telegram | Out of charter. (stockforge's `crawler-reliability` skill covers domain-specific scrapers separately) |
| **S-16** | `claude-code-learn` source code | Anthropic IP | Educational understanding only. Zero verbatim copy |
| **S-17** | Multi-tier OTEL stack (4-container Prometheus+Loki+Grafana+collector) | refrepos claude-code-otel alternative | Overkill for solo. Single-container LGTM is right default (B-6) |
| **S-18** | Langfuse alternative | refrepos claude-code-otel mentions | LGTM dashboard sufficient for Claude Code; stockforge doesn't need LLM-specific UI |
| **S-19** | VAPID web push, i18n, D3.js workflow viz | refrepos agent-monitor | Not needed for solo single-user |
| **S-20** | Multi-agent registry (Codex/Qwen/Gemini) | refrepos claude-sessions | Stockforge is Claude-only |
| **S-21** | TUI picker, MCP server, i18n in claude-sessions | refrepos | Irrelevant |
| **S-22** | telemetry-analyst opus (was reversed to sonnet by orch Decision 021) | orch §CE2 | Don't escalate model tier on speculative complexity. Stockforge: thesis-verifier IS opus (real adversarial); thesis-classifier IS sonnet (deterministic) |
| **S-23** | vi.useFakeTimers approach for cross-platform timing tests | orch §CE6 (reversed) | Use informational-reporter pattern (push durations to module-scope array, log p99/median in afterAll, no hard threshold) |
| **S-24** | Multi-cycle ENABLE_RETRY loop (5-cycle SC-39 chain) | orch §CE4 | Don't continue iterating; re-examine the gate at >3 cycles |
| **S-25** | PM/BA agents (msmdp 6-agent enterprise team) | msmdp §A1 | Stockforge single-user; user IS the PM. Collapse to Architect/Builder/Verifier/Guardian (3-4 agents) |

---

## Cross-cutting Notes

**Sequencing constraint**: TIER 1 ports follow Decision 002 track sequencing (1→2→{3,4,5}→6→7→{8,9}). Within each track, BORROW items go before ADAPT items (verbatim is cheaper than adaptation), LEARN items are encoded last as constitution writes (Track 7).

**Token estimate validation**: TIER 1 BORROW (~64K) + TIER 1 ADAPT (~144K) = ~208K total port tokens, distributed across Tracks 1-9. Plus LEARN encoding ~30K (constitution writes Track 7). Total ~240K against Decision 002 estimated ~940K main session budget. Headroom adequate.

**Vietnamese-domain extensions** (refrepos OQ3): L0 FAILURE_PATTERNS extend with VN phrases ("không hoạt động", "không hiệu quả", "đã thử nhưng"). Add as part of B-8 port (Track 8b).

**Compliance check** (refrepos OQ5): every borrowed pattern re-confirmed by Track 7 verifier — no paid sources, no insider channels.

**END borrow-list.md** — ~6K tokens.
