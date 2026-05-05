---
id: D-001-orch-vs-cc-native
title: "Pause Orch, Port Patterns to StockForge"
date: 2026-04-29
status: ACCEPTED
level: SCOPE
author:
  - "Claude Opus 4.7"

source_evidence:
  - path: human-workspace/user_prompt/20260429_01_init.txt
    quote: "tôi đang băn khoăn mình có nên tiếp tục phát triển dự án orch tiếp nữa không để dùng nó coding cho dự án 'stockforge' này"
  - path: C:/htdocs/orch-starter/agent-workspace/memory/decisions/
    section: "12 phases / v2.2.0 / 1470 tests passing — knowledge crystal evidence"

intent_classification:
  primary_intent: DECISION
  affects_charter: false
  affects_scope: true
  urgency: NORMAL
  complexity_score: 70

options_considered:
  - id: A
    summary: "Continue Orch development as-is (Phase 8+) and use it as full daemon for StockForge"
    pros:
      - "Knowledge crystal preserved active"
      - "Multi-project queue ready for future"
    cons:
      - "Tokens spent on Orch instead of StockForge"
      - "Maintenance burden of 1470 tests"
      - "Capabilities now overlap with CC native"
  - id: B
    summary: "Pause Orch, port proven patterns into StockForge"
    pros:
      - "Tokens go directly to StockForge work"
      - "Smaller surface area to maintain"
      - "CC native covers most Orch capabilities"
    cons:
      - "Community/SaaS direction paused"
      - "Re-investment cost if Orch revived later"
  - id: C
    summary: "Continue Orch in parallel for community/SaaS path"
    pros:
      - "Future revenue option preserved"
    cons:
      - "Resource split halts both projects"
      - "Premature productization"

chosen: B
chosen_rationale: |
  For solo personal use on StockForge alone, the marginal value of continuing Orch is low and
  the marginal cost (tokens, maintenance, drift) is real. Community/SaaS remains a SEPARATE
  FUTURE TRACK; not blocking. Knowledge through Orch phases 0-7 is already crystallized;
  no expected breakthrough in phase 8+. Karpathy P2 (Simplicity First) — running Orch as daemon
  adds 1 process + SQLite + NestJS + React UI just to deliver capabilities scripts in
  scripts/hooks/ can provide in ~500 LOC.

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-04-29
    via: "session 1 (S1) — initial response to user_prompt 01"
  - actor: user
    action: ACCEPTED
    at: 2026-04-29
    via: "user_prompt 02+03 + 'ok rồi. continue' chat reply (Round 1+2 Q&A confirmed defaults)"

verified_by:
  - mechanism: manual
    at: 2026-04-29
    result: PASS
  - mechanism: cross-decision-check
    at: 2026-04-29
    result: PASS
    notes: "D-002 builds on this decision; pattern mining (Track 0) confirms port plan viable"

affects:
  charter: false
  spec_files: []
  code_paths:
    - "scripts/**"
    - ".claude/agents/**"
    - ".claude/skills/**"
    - "agent-workspace/constitution/**"
  config_files:
    - ".claude/settings.json"
    - ".gitignore"
  other_decisions:
    - D-002

depends_on: []
supersedes: null
superseded_by: null

defer_cycles: 0
re_attempt_prereq: |
  Orch revival possible only if user-prompt requests community/SaaS team-share path.
  Trigger condition: explicit human direction. No auto-revival.

tags: ["phase-0", "scope", "orch-port", "knowledge-crystal"]
---

# Decision 001 — Orch vs Claude Code Native: Pause Orch, Port Patterns

> Status promoted from PROPOSED → ACCEPTED on 2026-04-29 via Round 1+2 Q&A audit. See `human-workspace/q-and-a/answered/2026-04-29-001-phase0-clusters.md`.

---

## Context

The user authored Orch (`C:\htdocs\orch-starter`) as a side project to manage the autonomous Claude Code coding loop for StockForge. Through 12+ phases, 36+ sessions, and 5 user-prompt interventions (`tasks/feat_01..feat_05`), Orch reached v2.2.0 with 1,470/1,470 tests passing and charter criteria F1-F8, N1-N5, O1-O4, S1-S4 all PASS.

During Orch's own development, Claude Code (April 2026) shipped capabilities that overlap heavily with Orch's value proposition:

- Subagent dispatch (`Agent` tool with `subagent_type` + `run_in_background`)
- Mobile remote control (`--rc` flag + claude.ai mobile app)
- Native skills with progressive disclosure
- Hooks (SessionStart/SessionEnd/Stop/PreToolUse/PostToolUse/SubagentStop/UserPromptSubmit)
- Scheduled execution (CronCreate, ScheduleWakeup, /loop skill)
- Plan mode (EnterPlanMode/ExitPlanMode)
- Worktree isolation per agent (EnterWorktree/ExitWorktree)
- Native task tracking (TaskCreate/Update/List)
- /effort modes (low/medium/high/xhigh/max)

The user's question (translated): "Should I continue developing Orch as a tool to support StockForge, or has Claude Code's native system become good enough that Orch is unnecessary for personal use? If unnecessary, what should I port from Orch into StockForge to achieve full-autonomous coding?"

---

## Analysis

### What Orch uniquely offers

| Capability | Status in CC native | Verdict for stockforge |
|---|---|---|
| Multi-project queue dispatch (1 daemon → N projects) | Not native | **Overkill** — stockforge is the only project |
| Auto ccs profile failover on rate-limit | Not native | **Replaceable by bash hook** (~50 LOC) |
| OTEL aggregation across sessions | `CLAUDE_CODE_ENABLE_TELEMETRY=1` exists; no aggregator | **Replaceable by local JSONL logging** |
| Telegram bot interface | claude.ai mobile + `--rc` covers it | **Fully replaced** |
| Web UI dashboard (kanban, live tail, cost chart) | Not native | **Nice-to-have, not blocker** for solo use |
| Token-based auto-reboot via keystroke injection | Not native | **Port script directly** (`session-self-reboot.sh`) |
| Auto-resume from checkpoint after reboot | Not native | **Port pattern** (SessionStart hook reads `checkpoints/latest.md`) |
| Loop-resilience guards (Mode A/B/C) | Not native | **Port hooks directly** (3 small bash scripts) |

### What CC native handles that Orch had to build

- Subagent dispatch — CC has this natively, no daemon needed
- Skills with progressive disclosure
- Hooks pipeline
- Scheduling primitives
- Remote interaction
- Single-project task tracking

### Cost-benefit of continuing Orch development

**Costs of continuing:**
- Phases 8-12+ (self-application bootstrap) require ongoing autonomous sessions on Orch itself
- Every Orch session costs tokens that could go into StockForge
- Maintenance burden compounds (1,470 tests to keep green)
- Drift surface area is now larger than the value-add over CC native

**Benefits of continuing:**
- Phase 1.7 vision (community/SaaS direction) — only realized if user actively pursues team-share path
- Knowledge crystal — patterns learned through real autonomous execution

**Verdict on cost-benefit:** For solo personal use on StockForge alone, the marginal value of continuing Orch is low and the marginal cost is real. The community/SaaS path remains valid as a SEPARATE FUTURE TRACK, but should not block StockForge's own autonomous coding loop.

---

## Decision

**PAUSE active Orch development. PORT the proven patterns into StockForge as scripts/skills/agents/constitution updates. KEEP Orch as a knowledge-crystal repo (read-only reference) and a optional future track for community/SaaS sharing.**

### What "pause" means concretely

- Do NOT continue Phase 8+ in Orch
- Do NOT spawn sessions to add features to Orch
- Do NOT delete Orch — it's a reference and a future-revival option
- Cap Orch sessions at: incidental bug fixes IF used as reference; otherwise read-only

### What "port" means concretely

See companion document: `agent-workspace/session-plans/pending/001-port-from-orch.md`. Summary of port categories:

1. **Hook scripts** (highest leverage, 7 scripts) — budget-watchdog, autonomous-stop-watchdog, dispatch-jsonl-recorder, session-start-bootstrap, component-telemetry, subagent-stop-logger, tool-call-first-lint
2. **Reboot scripts** — session-self-reboot.sh + .ps1 (keystroke injection at 200K/230K thresholds)
3. **Discipline skills** (7 skills) — subagent-driven-development, verification-before-completion, systematic-debugging, research-first, brainstorming, confusion-protocol, spawned-session-mode, observation-file-write-on-return
4. **Subagents** (5 new) — task-implementer, spec-compliance-reviewer, code-quality-reviewer, systematic-debugger, research-scanner, telemetry-analyst
5. **Commands** (5 new) — context-save, context-restore, phase-advance, harness-audit, invariant-check
6. **Constitution files** (3 new) — autonomous-protocol, model-routing, research-protocol; merge reusability-rules content into stockforge's existing files
7. **Memory infrastructure** — checkpoints/, decisions/, escalation.md, .transcript-tokens, .wind-down marker, .autonomous-stop-watchdog.log
8. **CLAUDE.md additions** — Budget Watchdog Protocol, Autonomous Mode + STOP conditions, Self-reboot mechanics, Tool-call-first ordering, Modes A/B/C defense

### What NOT to port

- `packages/core/` — TypeScript/NestJS daemon. StockForge is Python-primary; adapter pattern not needed for single-project.
- `apps/web` — React Web UI dashboard. Solo use → claude.ai mobile is enough.
- `apps/telegram` — Telegram bot. Replaced by `--rc`.
- Multi-project profile.yaml machinery. Overkill.
- `scripts/audit/n6-72h-*.sh`, `scripts/audit/oss-readiness.sh`, etc. — OSS-readiness audits irrelevant for personal stockforge use.

---

## Why (Reasons)

1. **Charter principle "Tight scope"** — Orch was scoped as orchestrator, but for solo single-project use the orchestration value is now mostly absorbed by CC native.
2. **Karpathy P2 (Simplicity First)** — running Orch as a daemon adds 1 process + 1 SQLite + 1 NestJS server + 1 React UI to keep alive, in exchange for capabilities that scripts in stockforge/scripts/ can deliver in ~500 LOC.
3. **Karpathy P3 (Surgical Changes)** — porting only the patterns that actually move the needle (hooks, reboot, skills) is a smaller change than maintaining Orch.
4. **User's own observation** (translated, feat_05): "the cost of each reboot is too high to continue prior work… memory/notes/learning have grown to expensive levels." Solving this is a stockforge-internal optimization, not an orch feature.
5. **Drift control** — Orch's 7+ phases revealed that drift is severe even with great configs. The drift-control mechanisms (drift-check, harness-audit, post-phase verifier) are pattern-level learnings; baking them into stockforge directly is more reliable than indirecting through orch.

---

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| User changes mind, wants Orch for team-share later | Medium | Keep Orch repo intact; revival is `git pull` away |
| Some ported pattern doesn't fit stockforge's Python-primary stack | Low | Hooks/scripts are bash; skills are markdown; subagents are markdown — all framework-agnostic |
| CC native ships a regression that orch had a workaround for | Low | Hooks intercept the same boundaries; workarounds port directly |
| Porting takes longer than expected | Medium | Phase the port: priority 1 (loop-resilience), priority 2 (skills), priority 3 (subagents/commands) |
| New Orch insights missed by stopping development | Low | Knowledge through phases 0-7 is already crystallized in `agent-workspace/`; no expected breakthrough in phase 8+ |

---

## Outcomes

If user confirms:
1. Orch development paused; mark as "reference repo" with a note in its README
2. Execute port roadmap (`session-plans/pending/001-port-from-orch.md`) over 3-5 autonomous sessions
3. Stockforge is then equipped to run full-autonomous loop with Mode A/B/C defenses, real-token watchdog, surgical context injection per subagent

If user rejects:
- Default to user's preferred direction (continue Orch, or merge both, or other)
- This decision document remains as evidence the question was investigated

---

## Open Questions for User

1. Confirm pause Orch? (Y/N)
2. Community/SaaS path — defer indefinitely, defer to specific milestone, or kill?
3. Effort budget for port work — execute in-line as part of stockforge Phase 0, or separate "Phase -1 / harness-bootstrap" track?
4. Any orch capability NOT in port list that you want preserved in stockforge?
