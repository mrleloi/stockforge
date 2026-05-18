# Chapter 3 — Architecture

> **Diataxis quadrant**: Explanation + Reference
> **Reading time**: ~30 minutes
> **Prerequisites**: Chapter 2 (Mental Model)

This chapter is the system map. It shows what physically exists, how the pieces are layered, and where each kind of work happens.

If you only read one chapter for reference, read this one — it tells you *where to put things*.

---

## The Eight Layers

The harness is organized in eight functional layers, each with a distinct responsibility and a distinct change cadence:

```
┌────────────────────────────────────────────────────────────────────────┐
│  LAYER 8 — APPLICATION                                                  │
│  apps/  packages/  bdd/  specs/  obsidian-vault/wiki/                   │
│  Where the StockForge product lives. The harness governs everything     │
│  below; this is what the harness exists to build.                       │
├────────────────────────────────────────────────────────────────────────┤
│  LAYER 7 — LIFECYCLE                                                    │
│  agent-workspace/master-plans/  agent-workspace/session-plans/          │
│  agent-workspace/memory/sessions/  decisions/  checkpoints/             │
│  Plans, sessions, ADRs, handoffs. The temporal structure.               │
├────────────────────────────────────────────────────────────────────────┤
│  LAYER 6 — MEMORY                                                       │
│  agent-workspace/memory/  human-workspace/  obsidian-vault/raw/         │
│  Persistent state. The "filesystem brain" the agent reads and writes.   │
├────────────────────────────────────────────────────────────────────────┤
│  LAYER 5 — SUBAGENTS                                                    │
│  .claude/agents/  (14 personas)                                         │
│  Fresh-context worker definitions. The personalities you dispatch.      │
├────────────────────────────────────────────────────────────────────────┤
│  LAYER 4 — COMMANDS                                                     │
│  .claude/commands/  (16 slash commands)                                 │
│  User-facing entry points. Thin wrappers over skills or subagents.      │
├────────────────────────────────────────────────────────────────────────┤
│  LAYER 3 — SKILLS                                                       │
│  .claude/skills/  (23 reusable procedures)                              │
│  Auto-discoverable patterns Claude invokes when context matches.        │
├────────────────────────────────────────────────────────────────────────┤
│  LAYER 2 — HOOKS                                                        │
│  scripts/hooks/  (118 scripts) + scripts/hooks/firing-tests/ (115)      │
│  Deterministic event handlers. The mechanical enforcement.              │
├────────────────────────────────────────────────────────────────────────┤
│  LAYER 1 — CONSTITUTION + IDENTITY                                      │
│  PROJECT_CHARTER.md  CLAUDE.md  agent-workspace/constitution/ (17)      │
│  .claude/settings.json (allow/deny/env/hooks wiring)                    │
│  Immutable foundation. Defines what the system is and is not.           │
└────────────────────────────────────────────────────────────────────────┘
```

Lower layers govern upper layers. Constitution rules are checked by Hooks; Hooks are wired in settings.json; Skills, Commands, Subagents respect Constitution; Memory is shaped by Constitution and Hooks; Lifecycle artifacts (plans, sessions, ADRs) record what happened at each layer; the Application layer is what gets built.

### Change Cadence Per Layer

| Layer | Change cadence | Who can change |
|---|---|---|
| 1 — Constitution | Slow (months); cool-down required | Human only (denied to agent) |
| 2 — Hooks | Medium (per significant lesson) | Agent may add; LOC-ceiling enforced |
| 3 — Skills | Medium | Agent may add via `write-a-skill` skill |
| 4 — Commands | Medium-fast | Agent may add |
| 5 — Subagents | Medium | Agent may add via established template |
| 6 — Memory | Fast (every session) | Agent writes; retention hooks enforce caps |
| 7 — Lifecycle | Fast (every session) | Agent writes; lifecycle hooks enforce structure |
| 8 — Application | Fast (per task) | Agent writes per sandwich pattern |

Read top-to-bottom: **deepest layers are slowest to change**.

---

## The Two Workspaces

Above the eight layers there is one more organizing distinction: **workspace dualism**.

```
stockforge/
├── agent-workspace/         ← AGENT owns this. Human reads, rarely edits.
│   ├── constitution/        ← (read-only to agent)
│   ├── memory/              ← agent writes freely
│   ├── master-plans/        ← agent writes per /master-plan
│   ├── session-plans/       ← agent writes per architect
│   ├── proposals/           ← agent writes; awaits human ratification
│   ├── ubiquitous-language/ ← agent writes via /drill-me
│   ├── calibration/         ← agent appends per post-mortem
│   ├── research/            ← agent writes per research-scanner
│   ├── post-mortems/        ← agent writes after significant failure
│   └── quality-reports/     ← agent writes per gate run
│
└── human-workspace/         ← HUMAN owns this. Agent has narrow write rights.
    ├── user_prompt/         ← human writes; agent reads (cannot edit)
    ├── decisions/           ← human writes formal ratifications
    ├── q-and-a/
    │   ├── pending/         ← agent writes when asking; auto-mv to answered/
    │   ├── answered/        ← either side moves (per auto-mv rule)
    │   └── stale/           ← hooks move >48h items
    └── notifications/
        └── urgent.md        ← agent appends; human reads
```

The dualism was born from a real failure in a sister project: shared-workspace mutation caused [charter drift](12-internals.md#cf-dogfood-2). The split makes provenance traceable — every file's owner is explicit, every cross-boundary communication is a named channel.

See [Chapter 8 § Workspace Dualism](08-lifecycle.md#workspace-dualism) for the auto-mv rule details.

---

## File-Level Layout (Top to Bottom)

This is the canonical layout. Memorize the names; they appear in every chapter.

```
stockforge/
│
├── PROJECT_CHARTER.md                        ← L1: vision + 11 principles (immutable)
├── CLAUDE.md                                  ← L1: always-loaded project instructions
├── AGENT_OPERATING_MANUAL.md                 ← L1: living operations doc
├── SPEC_TEMPLATE.md                           ← L1: dual-layer spec template
│
├── .claude/                                   ← Claude Code convention dir
│   ├── settings.json                          ← L1: permissions + env + hooks wiring
│   ├── settings.local.json                    ← L1: local (gitignored) overrides
│   ├── manifest.yaml                          ← L1: harness metadata
│   ├── skills/  (23 dirs each w/ SKILL.md)    ← L3: skills
│   ├── commands/  (16 *.md)                   ← L4: slash commands
│   ├── agents/  (14 *.md)                     ← L5: subagent personas
│   └── hooks/  (1 example)                    ← L2: pre-commit example (not Claude Code hooks)
│
├── scripts/
│   ├── hooks/  (118 *.sh)                     ← L2: Claude Code event hooks
│   │   └── firing-tests/  (115 *.sh)          ← L2: companion firing tests
│   ├── drift-check/                           ← L2: drift CLI runners
│   ├── session-handoff.sh                     ← L2: handoff utility
│   ├── session-self-reboot.sh                 ← L2: cliff auto-reboot
│   ├── sync-tracker-bootstrap.py              ← L2: confidence-score bootstrap
│   └── recover-agent-notes.py                 ← L2: agent-notes recovery
│
├── agent-workspace/
│   ├── CLAUDE.md                              ← L1: workspace contract
│   ├── constitution/  (17 *.md)               ← L1: immutable rules
│   ├── memory/                                ← L6
│   │   ├── project.md
│   │   ├── current-execution.md               ← L7: routing source-of-truth
│   │   ├── agent-notes.md                     ← L6: learned rules
│   │   ├── mistake-log.md                     ← L6: failure catalog
│   │   ├── capability-map.md
│   │   ├── personal-risk-profile.md
│   │   ├── sync-state.md
│   │   ├── boot-summary.md
│   │   ├── routing-config.md
│   │   ├── component-telemetry.jsonl
│   │   ├── cost-ledger.tsv
│   │   ├── dispatch.jsonl
│   │   ├── attestation-log.tsv
│   │   ├── up-intake-log.md
│   │   ├── MEMORY.md                          ← user auto-memory index
│   │   ├── sessions/                          ← L7: append-only session logs
│   │   ├── decisions/                         ← L7: ADRs D-001..D-NNN
│   │   ├── observations/                      ← L6: subagent return artifacts
│   │   ├── checkpoints/                       ← L7: handoff state
│   │   ├── drift-logs/                        ← L9: drift detection results
│   │   ├── post-mortems/                      ← L6: failure post-mortems
│   │   ├── patterns-discovered/               ← L6: pattern mining outputs
│   │   ├── self-awareness/                    ← L6: model profile cards
│   │   ├── sync-tracker/                      ← L9: confidence-score store
│   │   ├── indexes/                           ← L6: rendered indexes
│   │   ├── etl-queue/                         ← L6: pending memory ETL
│   │   ├── handoff-logs/                      ← L7: handoff history
│   │   ├── telemetry-archive/                 ← L6: rotated telemetry
│   │   └── thesis-log/                        ← L8: stock thesis records
│   │
│   ├── master-plans/                          ← L7: phase-level plans
│   ├── session-plans/
│   │   ├── pending/                           ← L7: not-yet-executed plans
│   │   └── completed/                         ← L7: executed plans
│   ├── proposals/                             ← L1: pre-ratification drafts
│   ├── ubiquitous-language/                   ← L6: DDD glossary
│   ├── calibration/                           ← L6: hit-rate data
│   ├── research/                              ← L6: research notes
│   ├── post-mortems/                          ← L6: cross-cutting post-mortems
│   ├── role-packs/                            ← L6: role context packs
│   ├── learning-data/                         ← L6: learning loop datasets
│   ├── raw-sessions/                          ← L7: exported transcripts
│   ├── thesis-log/                            ← L8: cross-link to memory/thesis-log
│   └── quality-reports/
│       ├── deterministic/                     ← L9: tier-1 outputs
│       ├── probabilistic/                     ← L9: tier-2 outputs
│       └── drift-reports/                     ← L9: drift run reports
│
├── human-workspace/
│   ├── user_prompt/                           ← L1: human-written prompts
│   ├── decisions/                             ← L1: human ratifications
│   ├── q-and-a/
│   │   ├── pending/                           ← L4: agent asks
│   │   ├── answered/                          ← L4: resolved
│   │   └── stale/                             ← L4: >48h unanswered
│   └── notifications/
│       └── urgent.md                          ← L4: severity escalations
│
├── obsidian-vault/
│   ├── raw/                                   ← L6: immutable source material
│   ├── wiki/                                  ← L8: agent-owned knowledge
│   ├── CLAUDE.md                              ← L1: vault contract
│   └── .obsidian/
│
├── specs/                                     ← L8: living specs
│   ├── tier1-strategic/
│   ├── tier2-feature/
│   └── tier3-task/
│
├── bdd/                                       ← L8: BDD test catalog
├── packages/                                  ← L8: monorepo packages (9 BCs)
│   ├── domain/  (BC-1..BC-9)                  ← pure Python; no framework
│   ├── application/                           ← use cases, ports (Protocol)
│   ├── infrastructure/                        ← adapters (DB, LLM, scraper)
│   ├── contracts/                             ← cross-BC schemas + events
│   └── _shared/                               ← shared utilities
│
├── apps/                                      ← L8: deployable apps
│   ├── dashboard/                             ← Streamlit (Phase 1-2)
│   ├── api/                                   ← FastAPI gateway (Phase 2+)
│   └── workers/                               ← Background workers
│
├── tests/                                     ← L8
├── eval-sets/                                 ← L8: eval ground truth
├── templates/                                 ← L8: project templates
├── prompts/                                   ← L8: LLM prompt library
├── data/                                      ← L8: data working dir
└── docs/
    ├── DAY_1_CHECKLIST.md                     ← L1: first-time guide
    └── harness/                               ← (this book)
        ├── en/
        ├── vi/
        ├── reference/
        ├── assets/
        └── IA.md
```

The depth of `agent-workspace/memory/` is intentional. Each subdirectory has a single, narrow purpose. The harness avoids dumping into one big `memory/notes.md` because **structure is what makes the memory queryable**.

---

## Data Flow — A Single Session, End to End

Here is what happens, step by step, when you run one session:

```
USER opens claude → SessionStart hooks fire (22 of them)
  │
  ├─ single-claude-instance-lock.sh acquires .claude-instance.lock
  ├─ essential-routing-fields-verifier.sh validates current-execution.md
  ├─ working-memory-budget-audit.sh measures Tier-1 load (must be ≤8K per HH-5)
  ├─ session-start-bootstrap.sh emits checkpoint additionalContext
  ├─ vendor-api-probe.sh checks Anthropic API reachable
  ├─ qa-pending-stale-mover.sh moves >48h Q&A bundles
  ├─ qa-answered-detector.sh re-classifies status= changes
  ├─ sync-grilling-trigger.sh checks 38-session / 7-day grilling threshold
  ├─ learning-queue-sweeper.sh promotes pending lessons
  ├─ ghost-work-audit.sh checks for in-flight subagent orphans
  ├─ proposal-bundle-advisor.sh checks 48h cool-down on proposals
  ├─ checkpoint-marker-cleanup-resume.sh clears markers + surfaces next_action
  ├─ in-flight-subagent-watcher.sh checks for unattended dispatches
  ├─ session-start-scan-unattested-observations.sh checks for orphan obs
  ├─ idle-escape-detector.sh checks for routine-idle loop pattern
  ├─ phase-status-coherence.sh diffs project.md ↔ current-execution.md
  ├─ harness-health-self-scan.sh runs HH-1..HH-12 catalog
  ├─ idle-state-advisory.sh aggregates idle signals
  ├─ escalation-engine.sh acts on .severity-state.tsv rows
  └─ continue-injector-spawn.sh dispatches PowerShell continue (if /clear)
  │
USER types prompt → UserPromptSubmit hooks fire (13 of them)
  │
  ├─ block-control.sh check-prompt (auto-clears on "approved" reply)
  ├─ autonomous-block-enforcer.sh (denies tools if BLOCKED flag set)
  ├─ escalation-engine.sh (re-checks severity state)
  ├─ userprompt-invariants-injector.sh (injects I-S1/I-S2/I-S35 reminders)
  ├─ stale-prompt-detector.sh (flags >24h old references)
  ├─ correction-rate-tracker.sh (counts user corrections per turn)
  ├─ in-flight-subagent-watcher.sh (orphan check)
  ├─ hook-firing-counter.sh (tallies hook fires this turn)
  ├─ effort-escalation-detector.sh (recommends ladder up/down)
  ├─ idle-escape-detector.sh UserPromptSubmit (routine-idle escape)
  ├─ phase-status-coherence.sh UserPromptSubmit (drift check)
  ├─ harness-health-self-scan.sh UserPromptSubmit (12-signal re-scan, cached)
  └─ idle-state-advisory.sh UserPromptSubmit
  │
LLM thinks → tool call (e.g., Edit) → PreToolUse hooks fire (9 of them)
  │
  ├─ destructive-command-guard.sh (deny rm -rf, drop table, etc.)
  ├─ pre-dispatch-architect-commit-guard.sh (no auto-commit by architect)
  ├─ pre-commit-pytest-regression-guard.sh (tests pass before commit)
  ├─ autonomous-block-enforcer.sh (BLOCKED flag denies tool)
  ├─ dispatch-jsonl-recorder.sh (records Agent calls to dispatch.jsonl)
  ├─ write-vs-edit-guard.sh (L-S45-2: protect append-only memory files)
  ├─ checkpoint-write-end-turn-watchdog.sh (after checkpoint write = end turn)
  ├─ pre-dispatch-adr-number-check.sh (verify ADR number not in use)
  └─ effort-escalation-detector.sh
  │
Tool executes → PostToolUse hooks fire (10 of them, filtered)
  │
  ├─ budget-watchdog.sh (transcript JSONL token sum; 180K / 220K / 250K)
  ├─ python-determinism-check.sh (Edit|Write|MultiEdit only; R1-R4 patterns)
  ├─ atomic-write-check.sh (atomic temp+replace pattern)
  ├─ html-separator-check.sh (no <hr> / *** / --- in production)
  ├─ path-safety-check.sh (P1-P5 sandbox/UNC/traversal)
  ├─ dispatch-jsonl-recorder.sh (post-call telemetry)
  ├─ component-telemetry.sh (per-tool JSONL)
  ├─ post-tool-citation-grep.sh (I-S2 citation enforcement)
  ├─ loc-ceiling-check.sh (D1 LOC ceiling per category)
  └─ checkpoint-write-marker.sh (mark .checkpoint-written-<sid>)
  │
SUBAGENT dispatched → SubagentStop hooks fire when it returns
  │
  ├─ subagent-stop-logger.sh
  ├─ post-dev-dispatch-attestation-check.sh
  ├─ component-telemetry.sh
  ├─ dispatch-jsonl-recorder.sh (FIFO match: DISPATCHED + COMPLETED)
  └─ cost-ledger-recorder.sh (USD cost per dispatch)
  │
SESSION ends → Stop chain fires (50+ hooks)
  │
  [see Chapter 6 § Stop chain for full sequence; the most important are]
  ├─ tracking-retention.sh (retention caps; auto-archive)
  ├─ budget-watchdog.sh (final tally)
  ├─ pre-checkpoint-close-verifier.sh (handoff state valid)
  ├─ drift-signals-D1-D9.sh (run drift catalog)
  ├─ severity-classifier.sh (Phase A of severity pipeline)
  ├─ escalation-engine.sh (Phase B)
  ├─ session-end-checklist-linter.sh (mistake-log discipline)
  ├─ cost-ledger-recorder.sh (final USD)
  ├─ promotion-cycle-trigger.sh (≥8 lessons → block until promote-rule)
  └─ daily-backup.sh (out-of-tree backup, idempotent per day)
```

This is one session. Every layer participated. The Application work (your code edit) sat at the top; the Hooks layer wrapped every tool call; the Constitution informed which hooks blocked or warned; the Memory layer recorded everything; the Lifecycle layer (session log) appended the receipt.

---

## Where to Put New Things

When you want to add something to the harness, ask: **what kind of thing is it?** Then place it in the right layer.

| What you're adding | Where it goes | Mechanism |
|---|---|---|
| A reusable LLM-mediated procedure (3+ sessions used it) | Layer 3 — `.claude/skills/<name>/SKILL.md` | Use [`write-a-skill`](05-skills-commands-agents.md#write-a-skill) skill |
| A user-typed shortcut for a common action | Layer 4 — `.claude/commands/<name>.md` | New command file |
| A fresh-context persona (architect, verifier, etc.) | Layer 5 — `.claude/agents/<name>.md` | New agent file w/ frontmatter |
| A deterministic check that should fire on event X | Layer 2 — `scripts/hooks/<name>.sh` + firing-test | New hook + wire in settings.json |
| A new immutable rule | Layer 1 — `agent-workspace/proposals/<name>.md` → constitution after ratification | Propose, cool-down, ratify, mv |
| A new persistent memory artifact type | Layer 6 — `agent-workspace/memory/<subdir>/` | New subdir + add to MEMORY.md |
| A new ADR | Layer 7 — `agent-workspace/memory/decisions/NNN-<slug>.md` | Sequential number + 12-field schema |
| A new feature (code) | Layer 8 — `packages/<bc>/` or `apps/<app>/` | Sandwich pattern (architect → dev → verifier) |
| A new spec | Layer 8 — `specs/tier{1,2,3}-*/NNN-<slug>.md` | `/spec-author` command |
| New scraper / data adapter | Layer 8 — `packages/infrastructure/` | Use [`crawler-reliability`](05-skills-commands-agents.md#crawler-reliability) skill |

If you do not know which layer a thing belongs in, ask the agent: it will route you using [`memory-routing-tree.md`](../../../agent-workspace/constitution/memory-routing-tree.md).

---

## The Stack From Below

If you read this chapter top-to-bottom, you read the application layer first. Now read it bottom-to-top.

**Layer 1 (Constitution)** says: "These are the rules. They do not change without ratification."

**Layer 2 (Hooks)** says: "I will check the rules every time anything happens. If you violate one, I will block or warn or escalate."

**Layer 3 (Skills)** says: "When the context looks like X, here is the procedure."

**Layer 4 (Commands)** says: "When the user types `/X`, run this procedure."

**Layer 5 (Subagents)** says: "When you need fresh context, dispatch one of these personas."

**Layer 6 (Memory)** says: "Here is the state of the world. Read me before acting; update me after."

**Layer 7 (Lifecycle)** says: "Here are the rituals of starting, planning, executing, verifying, and closing."

**Layer 8 (Application)** says: "And this — finally — is the product."

Every chapter of this book is a deeper look at one of these layers.

- **Layer 1** → [Chapter 4](04-constitution.md)
- **Layer 2** → [Chapter 6](06-hooks.md)
- **Layers 3, 4, 5** → [Chapter 5](05-skills-commands-agents.md)
- **Layer 6** → [Chapter 7](07-memory-system.md)
- **Layer 7** → [Chapter 8](08-lifecycle.md)
- **Cross-cutting** → [Chapter 9 — Quality](09-quality-system.md), [Chapter 10 — Self-Improvement](10-self-improvement.md)
