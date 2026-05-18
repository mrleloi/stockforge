# Chapter 13 — Reference

> **Diataxis quadrant**: Reference (information lookup)
> **Reading time**: ~10 minutes (used for lookup, not reading)
> **Prerequisites**: any chapter

This chapter is the reference index. It points to the inventory files in `docs/harness/reference/` where the detailed catalogs live.

The split between this chapter and the inventory files is intentional:
- **This chapter** is curated — short, navigable, links out
- **Inventory files** are exhaustive — generated/synced with the live system

When the harness changes, run `/harness-docs sync` (see [Chapter 14 § Keeping the Book in Sync](14-contributing.md#keeping-the-book-in-sync)) to regenerate the inventory files.

---

## 13.1 — Quick Reference Card

The fastest way to find anything.

| Looking for | Go to |
|---|---|
| A specific skill | [Reference § Skills](../reference/inventory-skills.md) |
| A specific slash command | [Reference § Commands](../reference/inventory-commands.md) |
| A specific subagent | [Reference § Subagents](../reference/inventory-agents.md) |
| A specific hook script | [Reference § Hooks](../reference/inventory-hooks.md) |
| A constitution rule | [Reference § Constitution](../reference/inventory-constitution.md) |
| A memory file / directory | [Reference § Memory](../reference/inventory-memory.md) |
| A specific ADR | [Reference § ADRs](../reference/inventory-decisions.md) |
| The 11 charter principles | [Chapter 4 § The 11 Principles](04-constitution.md#the-11-principles-reference) |
| Drift signals DR1-DR12 | [Chapter 9 § Drift Signals](09-quality-system.md#93--drift-signals-dr1-dr12) |
| Harness health HH-1..HH-12 | [Chapter 9 § Harness Health](09-quality-system.md#94--harness-health-signals-hh-1hh-12) |
| Anti-patterns AP-1..AP-23 | [Chapter 12 § 23 Anti-Patterns](12-internals.md#122--the-23-anti-patterns-ap-1ap-23) |
| Session types + budgets | [Chapter 4 § session-budgets](04-constitution.md#session-budgets) |
| The 9 bounded contexts | [Chapter 4 § architecture](04-constitution.md#architecture) |

---

## 13.2 — Top-Level File Index

### Project Root

| File | What | Reference |
|---|---|---|
| `PROJECT_CHARTER.md` | Vision + 11 principles (immutable) | [Chapter 4 § 4.1](04-constitution.md#41--identity-files-always-loaded) |
| `CLAUDE.md` | Always-loaded project context | [Chapter 4 § 4.1](04-constitution.md#41--identity-files-always-loaded) |
| `AGENT_OPERATING_MANUAL.md` | Living operations doc | reference only |
| `SPEC_TEMPLATE.md` | Dual-layer spec template | reference only |

### `.claude/`

| File / Dir | What | Reference |
|---|---|---|
| `settings.json` | Permissions + env + hooks wiring | [Chapter 4 § 4.3](04-constitution.md#43--permissions-claudesettingsjson) |
| `settings.local.json` | Local (gitignored) overrides | [Chapter 4 § 4.3](04-constitution.md#43--permissions-claudesettingsjson) |
| `manifest.yaml` | Harness metadata | reference only |
| `skills/` (23 dirs) | Skills | [Chapter 5 § 5.2](05-skills-commands-agents.md#52--skills), [Reference](../reference/inventory-skills.md) |
| `commands/` (16 *.md) | Slash commands | [Chapter 5 § 5.3](05-skills-commands-agents.md#53--commands), [Reference](../reference/inventory-commands.md) |
| `agents/` (14 *.md) | Subagent personas | [Chapter 5 § 5.4](05-skills-commands-agents.md#54--subagents), [Reference](../reference/inventory-agents.md) |
| `hooks/pre-commit.example` | Pre-commit example (not Claude Code hook) | reference only |

### `scripts/hooks/`

| File / Dir | What | Reference |
|---|---|---|
| `*.sh` (118 scripts) | Claude Code event hooks | [Chapter 6](06-hooks.md), [Reference](../reference/inventory-hooks.md) |
| `firing-tests/` (115 *-fire-test.sh) | Companion firing tests | [Chapter 6 § 6.9](06-hooks.md#69--the-firing-test-discipline-principle-11) |
| `firing-tests/run-all.sh` | Test orchestrator | [Chapter 6 § 6.9](06-hooks.md#69--the-firing-test-discipline-principle-11) |

### `agent-workspace/`

| File / Dir | What | Reference |
|---|---|---|
| `CLAUDE.md` | Workspace contract | [Chapter 4 § 4.1](04-constitution.md#41--identity-files-always-loaded) |
| `constitution/` (17 *.md) | Immutable rules | [Chapter 4 § 4.2](04-constitution.md#42--the-17-constitution-files), [Reference](../reference/inventory-constitution.md) |
| `memory/` | Persistent state | [Chapter 7](07-memory-system.md), [Reference](../reference/inventory-memory.md) |
| `master-plans/` | Phase-level plans | [Chapter 8 § 8.3](08-lifecycle.md#83--the-plan-lifecycle) |
| `session-plans/{pending,completed}/` | Session-level plans | [Chapter 8 § 8.3](08-lifecycle.md#83--the-plan-lifecycle) |
| `proposals/` | Pre-ratification drafts | [Chapter 4 § 4.6](04-constitution.md#46--amendment-process) |
| `ubiquitous-language/` | DDD glossary | [Chapter 5 § Pipeline 2](05-skills-commands-agents.md#pipeline-2--knowledge-base) |
| `calibration/` | Hit-rate data | [Chapter 2 § Idea 5](02-mental-model.md#idea-5--calibration-over-confidence) |
| `quality-reports/{deterministic,probabilistic,drift-reports}/` | Quality gate outputs | [Chapter 9 § 9.7](09-quality-system.md#97--quality-reports) |
| `research/` | Research notes | reference only |
| `post-mortems/` | Cross-cutting post-mortems | reference only |
| `role-packs/` | Role context packs | reference only |
| `learning-data/{events,dogfood,loop,index,archive}/` | Learning loop datasets | reference only |
| `raw-sessions/` | Exported transcripts | reference only |
| `thesis-log/` | Cross-link to memory/thesis-log | reference only |

### `human-workspace/`

| File / Dir | What | Reference |
|---|---|---|
| `CLAUDE.md` | Human contract | [Chapter 4 § 4.1](04-constitution.md#41--identity-files-always-loaded) |
| `user_prompt/` | Human-written prompts | [Chapter 8 § 8.6](08-lifecycle.md#86--workspace-dualism) |
| `decisions/` | Human ratifications | [Chapter 8 § 8.6](08-lifecycle.md#86--workspace-dualism) |
| `q-and-a/{pending,answered,stale}/` | Q&A bundles | [Chapter 8 § 8.7](08-lifecycle.md#87--the-qa-bundle-mega-pattern) |
| `notifications/urgent.md` | Severity escalations | [Chapter 6 § 6.6](06-hooks.md#66--the-severity-pipeline) |

### `obsidian-vault/`

| File / Dir | What | Reference |
|---|---|---|
| `CLAUDE.md` | Vault contract | reference only |
| `raw/` | Immutable source material | reference only |
| `wiki/` | Agent-owned knowledge | reference only |
| `.obsidian/` | Obsidian config | reference only |

### Application Layer

| File / Dir | What | Reference |
|---|---|---|
| `packages/{domain,application,infrastructure,contracts,_shared}/` | Monorepo (9 BCs) | [Chapter 4 § architecture](04-constitution.md#architecture) |
| `apps/{dashboard,api,workers}/` | Deployable apps | reference only |
| `specs/{tier1-strategic,tier2-feature,tier3-task}/` | Living specs | reference only |
| `bdd/` | BDD test catalog | reference only |
| `tests/` | Top-level tests | reference only |
| `eval-sets/{thesis-labeled,baseline-results}/` | Eval ground truth | reference only |
| `templates/` | Project templates | reference only |
| `prompts/` | LLM prompt library | reference only |
| `data/` | Data working dir | reference only |

---

## 13.3 — Memory File Quick Reference

The most-accessed memory files:

| File | When read | When written |
|---|---|---|
| `current-execution.md` | Every SessionStart (FIRST) | On session boundary + task complete |
| `project.md` | Every SessionStart | On architectural decision |
| `agent-notes.md` | When task relates to past lesson | On session-end if new lesson |
| `mistake-log.md` | At session-start (pre-flight) | On session-end (or M-S<N>-NONE attestation) |
| `MEMORY.md` | Tier 1 always-loaded | When user-memory entry added |
| `checkpoints/latest.md` | On SessionStart bootstrap | On checkpoint write (PostToolUse-triggered) |
| `sessions/YYYY-MM-DD-session-N.md` | Recent 3 read at SessionStart | At session-end |
| `decisions/NNN-*.md` | On ADR cite from plan | When new decision made |
| `observations/<subagent>-S<N>-<TS>.md` | When subagent dispatch completes | By subagent on return |
| `dispatch.jsonl` | By telemetry hooks | PreToolUse(Agent) + SubagentStop |
| `cost-ledger.tsv` | At budget audit | Stop + SubagentStop |
| `.session-hooks.log` | When debugging hook silence | Every hook fire |

---

## 13.4 — Hook Event Quick Reference

| Event | Hook count | When fires | Most important hooks |
|---|---|---|---|
| SessionStart | 22 | New session | `single-claude-instance-lock`, `session-start-bootstrap`, `harness-health-self-scan`, `continue-injector-spawn` (last) |
| SessionEnd | 3 | Session terminates | `session-export-raw` |
| UserPromptSubmit | 13 | Every user prompt | `block-control check-prompt`, `autonomous-block-enforcer`, `userprompt-invariants-injector` |
| PreToolUse | 9 | Before any tool call | `destructive-command-guard`, `write-vs-edit-guard`, `checkpoint-write-end-turn-watchdog`, `autonomous-block-enforcer` |
| PostToolUse | 10 | After any tool call | `budget-watchdog`, `python-determinism-check`, `atomic-write-check`, `dispatch-jsonl-recorder`, `checkpoint-write-marker` |
| Stop | 50+ | Every assistant turn | `tracking-retention`, `drift-signals-D1-D9`, `severity-classifier`, `escalation-engine`, `session-end-checklist-linter`, `cost-ledger-recorder`, `daily-backup` |
| SubagentStop | 5 | Subagent completes | `subagent-stop-logger`, `dispatch-jsonl-recorder`, `cost-ledger-recorder` |
| PreCompact | 1 | Before auto-compact | `precompact-thesis-state-dump` |
| Notification | 0 (intentional) | — | — |

---

## 13.5 — Environment Variables Reference

Defined in `.claude/settings.json` `env` block. Read by hooks.

| Variable | Default | Purpose |
|---|---|---|
| `PYTHON_ENV` | `development` | Python environment marker |
| `STOCKFORGE_HOOK_PROFILE` | `standard` | Hook strictness profile (`standard` or `strict`) |
| `STOCKFORGE_SPAWNED` | `false` | Marks session spawned by `session-self-reboot.sh` |
| `STOCKFORGE_WIND_DOWN_TOKENS` | `180000` | Token threshold for handoff prep |
| `STOCKFORGE_CLIFF_TOKENS` | `220000` | Token threshold for auto-reboot |
| `STOCKFORGE_LOC_STRICT` | `0` | LOC ceiling: 0=warn, 1=block |
| `STOCKFORGE_CITATION_STRICT` | `0` | I-S2 citation: 0=warn, 1=block |
| `STOCKFORGE_DRIFT_STRICT` | `0` | Drift signals: 0=warn, 1=block |
| `STOCKFORGE_SAME_COMMIT_STRICT` | `0` | Same-commit rule: 0=warn, 1=block |
| `STOCKFORGE_WATCHDOG_DISABLE` | `0` | Disable autonomous-stop-watchdog: 0=enabled, 1=disabled |
| `STOCKFORGE_LINT_DOCTRINE_PHASE_0_PORTABILITY` | `0` | Phase 0 portability lint: 0=warn, 1=block |
| `STOCKFORGE_HH_H1_THRESHOLD_S` | `1800` | HH-H.1 checkpoint mtime threshold (seconds) |
| `STOCKFORGE_HOOK_BUDGET_USD` | `<varies>` | Per-hook USD budget cap |
| `STOCKFORGE_FORCE_AUTONOMOUS` | `0` | Bypass autonomous-block-enforcer (logged) |
| `STOCKFORGE_FORCE_CONTINUE_ON_CLEAR` | `0` | Force continue-injector spawn on `/clear` |
| `STOCKFORGE_ALLOW_DESTRUCTIVE` | `0` | Bypass destructive-command-guard (logged) |
| `STOCKFORGE_TELEGRAM_BOT_TOKEN` | (unset) | Telegram bot token (in settings.local.json) |
| `STOCKFORGE_TELEGRAM_CHAT_ID` | (unset) | Telegram chat ID (in settings.local.json) |
| `STOCKFORGE_TELEGRAM_DRY_RUN` | `0` | Skip live Telegram push |
| `STOCKFORGE_BACKUP_DIR` | `<project-parent>/stockforge-backups/` | Daily backup destination |
| `FIRING_TEST_TIMEOUT` | `30` | Per-fire-test timeout (seconds) |

---

## 13.6 — Severity Schema Quick Reference

Per [`severity-schema.md`](../../../agent-workspace/constitution/severity-schema.md):

| Level | Triggers | Action |
|---|---|---|
| **CRITICAL** | Stale-checkpoint marker, Q&A age ≥96h, charter-violation marker, ghost-greening marker | `.autonomous-BLOCKED` + URGENT + Telegram |
| **HIGH** | Q&A age ≥6h, charter-tier ADR PROPOSED ≥24h, mistake-log severity=high, ALERT-URGENT keyword | URGENT + UserPromptSubmit context + Telegram |
| **MEDIUM** | ARCH/SCOPE PROPOSED ≥12h, notification WARN | Weekly digest |
| **LOW** | Below thresholds | Log only |

---

## 13.7 — Glossary Pointer

For terminology, see [Chapter 15 — Glossary](15-glossary.md).

The most important terms (memorize these):

- **harness** — the framework documented in this book
- **sandwich pattern** — architect → dev → verifier choreography across 3 sessions
- **VBW** — Verify-Before-Write protocol (4 checkpoints)
- **AP-N** — anti-pattern N (23 named)
- **DR-N / DR-A-N / DR-S-N** — drift signal N
- **HH-N** — harness health signal N (12 catalogued)
- **L-S<N>-<M>** — lesson learned in session N, sequence M
- **M-S<N>-<M>** — mistake recorded in session N, sequence M
- **D-NNN** — ADR number NNN (sequential)
- **BC-N** — bounded context N (9 in stock domain)
- **I-S<N>** — invariant N (general or stock-specific)
- **B-N / SB-N** — hard boundary / soft boundary N
- **Karpathy P1-P4** — Think Before / Simplicity / Surgical / Goal-Driven
- **Tier 1 / Tier 2 / Tier 3** — quality gates (deterministic / probabilistic / human) OR memory tiers (always-loaded / JIT / explicit)

---

## 13.8 — Inventory Files

The detailed inventories live as separate reference files. Each is regenerable from the live system via `/harness-docs sync`.

- [`../reference/inventory-skills.md`](../reference/inventory-skills.md) — 23 skills, full table
- [`../reference/inventory-commands.md`](../reference/inventory-commands.md) — 16 commands
- [`../reference/inventory-agents.md`](../reference/inventory-agents.md) — 14 subagents
- [`../reference/inventory-hooks.md`](../reference/inventory-hooks.md) — 118 hooks grouped by event + category
- [`../reference/inventory-constitution.md`](../reference/inventory-constitution.md) — 17 constitution files
- [`../reference/inventory-memory.md`](../reference/inventory-memory.md) — memory files + directories
- [`../reference/inventory-decisions.md`](../reference/inventory-decisions.md) — all ADRs D-001..D-NNN

---

## 13.9 — Where to Read Next

- **Adding new artifacts** → [Chapter 14 — Contributing](14-contributing.md)
- **Definitions of terms** → [Chapter 15 — Glossary](15-glossary.md)
