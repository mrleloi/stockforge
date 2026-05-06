---
status: CHARTER
ratified_at: 2026-05-01
ratified_by: Project owner — Q&A 2026-05-01-001 Q1=A explicit pick (S38 FOCUSED_IMPL Bundle 1 charter promote)
ratifying_decision: D-015
source_evidence:
  - human-workspace/user_prompt/20260429_06.txt § sync directive
  - "S15 close — user correction CHARTER-tier 2026-04-29: full autonomous = ONLY mode; SUPERVISED was fabricated default-until-Track-7 framing, never user-authorized"
  - agent-notes.md § L-S14-4 (autonomous_mode flag + Mode-D clean-handoff coverage)
  - observations/queued-grill-master.md § Q-C2 (auto-context-loader; closed S15 Batch 2 — Hybrid)
  - observations/queued-grill-master.md § Q-C3 (bootstrap token ceiling; closed S15 Batch 2 — Adaptive)
  - observations/queued-grill-master.md § Q-2.1 (skill-tool autonomous policy; closed S15 Batch 2 — gate skills in autonomous loops)
  - observations/queued-grill-master.md § Q-E1 (drift detection; closed S15 Batch 3 — All A+B+C combined)
  - observations/queued-grill-master.md § Q-E4 (drift recovery; closed S15 Batch 3 — Q&A bundle async)
  - "~/.ccs/instances/.../memory/full_autonomous_no_supervised.md (CHARTER-tier user correction memory)"
  - human-workspace/q-and-a/pending/2026-05-01-001-S35-charter-promote-batch.md § Q1=A (explicit pick — promote to charter as-is)
predecessor_proposal: agent-workspace/proposals/autonomous-protocol.md (S16 draft; moved to constitution at S38)
---

# Autonomous Protocol — CHARTER

> **Status**: CHARTER (ratified 2026-05-01 at S38 via Q&A 2026-05-01-001 Q1=A). Edits require explicit user prompt + Q&A per `agent-workspace/CLAUDE.md` constitution-amendment process.

## Purpose

Codify the StockForge autonomous mode as the **only** operating mode. Define what context auto-loads at SessionStart, what bootstrap budgets apply per session type, when AskUserQuestion is appropriate vs anti-pattern, how drift gets detected and recovered without human intervention in the loop, and how the Skill tool's always-prompt design is handled.

## Rule 1 — autonomous_mode = true is the ONLY mode (S15-close user correction, CHARTER-tier)

`autonomous_mode = true` is the steady state. There is **no SUPERVISED bifurcation, no human-in-the-loop default mode, no "until Track 7" gate**. The user (project owner) is the supervisor of last resort, not a step in the per-session loop.

**Context**: A prior framing introduced "SUPERVISED" as a default mode that would lift "after Track 7". This framing was fabricated by agents (originated in agent-notes L-S7/L-S8 commentary as "default until Track 7"); never user-authorized. The user explicit correction at S15 close (2026-04-29):

> "autonomous is full autonomous by you, not me human-in-the-loop, or any 'supervisor' mode? its not my idea!"

This proposal codifies the correction.

**Implications**:
- Routine session handoffs go via Stop hook → Mode A/B/C/D detection → `continue-injector` / `session-self-reboot.sh`. No AskUserQuestion for routine handoffs.
- AskUserQuestion is for **genuinely-new SCOPE/CHARTER decisions only** — not for "what should I do next session?" or "should I close this session?"
- The drift signal `bash-hook-lint.sh § D-IDENTITY` scans LIVE config for `SUPERVISED|autonomous_mode:\s*false|until Track 7` regression and soft-warns. Historical session logs and checkpoints documenting past state are exempt.

## Rule 2 — Mode A/B/C/D Coverage (L-S14-4)

Stop-hook-driven handoff modes:

| Mode | Trigger | Handoff mechanism |
|---|---|---|
| **A** | Stop without checkpoint, no budget alert | `autonomous-stop-watchdog.sh` writes minimal continue prompt; `continue-injector.ps1` resumes mid-session |
| **B** | Stop with budget cliff (≥220K) reached | `budget-watchdog.sh` triggers `session-self-reboot.sh` for fresh-context resume |
| **C** | Premature wind-down (mode-C alert before cliff) | `budget-watchdog.sh` flags + handoff prep; resume via continue-injector |
| **D** | Clean handoff (S14 addition — checkpoint mtime ≤ 60s, no A/B/C) | `autonomous-stop-watchdog.sh` recognizes intentional close; resume reads `checkpoints/latest.md` |

D-003 § 5.5c.5 REV-4 documents the matching `failure_mode` 8-code expansion (`B|C|D|E|H|R|T|null`) in JSONL telemetry.

## Rule 3 — Context Auto-Loader Mechanism (Q-C2 — closed Hybrid)

**Hybrid**: deterministic auto-load for routine SessionStart; LLM-selector for complex.

- **Auto** (deterministic, hook-driven): SessionStart hook runs `session-start-bootstrap.sh` which reads `current-execution.md` + `checkpoints/latest.md` + last-session log. No LLM token cost; fixed budget.
- **LLM-selector** (subagent-driven, on-demand): for sessions where context selection requires judgment (e.g., entering a new bounded context, picking which spec to follow), dispatch a small subagent (`general-purpose` or task-specific) to select files and return a list before the main agent starts work.

**Anti-pattern**: greedy auto-load of all candidate files (~50K+ at SessionStart). Per Rule 4 budgets, that blows the bootstrap ceiling.

## Rule 4 — Bootstrap Token Ceiling Per Session Type (Q-C3 — closed Adaptive)

| Session type | Bootstrap ceiling |
|---|---|
| PLAN | ≤8K |
| FOCUSED_IMPL | ≤15K |
| MULTI_TASK_IMPL | ≤20K |
| VERIFY | ≤6K |
| THESIS | ≤10K |
| INGEST | ≤8K |
| POST_MORTEM | ≤6K |

**Bootstrap** = everything loaded by SessionStart hook + first-turn-mandated reads (CLAUDE.md, current-execution.md, checkpoint, plan file). Files read later as the session unfolds are NOT bootstrap.

## Rule 5 — Skill-Tool in Autonomous Mode (Q-2.1 — closed)

The Anthropic-designed Skill tool ALWAYS prompts for user approval on first invocation per session. In a fully autonomous loop (no human at terminal), this is a blocker.

**Policy**: gate autonomous loops to NOT call Skill. Replace with:
- Inline procedure (copy the skill body into the running prompt)
- Subagent dispatch via Agent tool (subagent runs the procedure with full context)
- Hook-emitted notification asking user to invoke the skill manually next time they're at terminal

**Exception**: SessionStart-only Skill tool calls accepted by user once per session at start, before autonomous loop begins.

## Rule 6 — Drift Self-Detection (Q-E1 — closed All A+B+C combined)

Defense-in-depth matching the stockforge multi-perspective principle:

- **A — Per-task DA-rule**: every ≥5 tool calls or ≥10K tokens, agent re-reads its current spec/plan/checkpoint and self-asks "am I still aligned?" before next action.
- **B — Stop-hook `/session-verify`**: Stop hook auto-fires `/session-verify` skill (read-only audit) every Nth Stop event; results land in `drift-logs/`.
- **C — Fresh-context drift-auditor subagent**: dispatched at random intervals (probabilistic) AND on triggered intervals (every Nth session boundary); independent context = independent verdict.

All three run in parallel. Disagreement between A/B/C surfaces the disagreement itself as a drift signal.

## Rule 7 — Drift Recovery Flow (Q-E4 — closed Q&A async)

When drift auto-detected mid-session:

1. Agent does NOT halt. Continues current task to a coherent boundary.
2. Agent opens a Q&A bundle in `human-workspace/q-and-a/pending/<TS>-drift-detected.md` listing: detected drift category + 3 remediation options.
3. Notification emitted (`human-workspace/notifications/`) so user sees on next terminal touch.
4. Session continues; on next SessionStart, agent reads any answered Q&A bundle and applies user-picked remediation.

Matches UP-06 NO-Silent-Default doctrine + the mobile-remote use case where user reads Q&A async between coding bursts.

**Anti-pattern**: HALT-and-wait blocks the autonomous loop while user is offline. Hard-revert to last clean checkpoint loses in-progress work the user might still want; user-pick async preserves both options.

## Rule 8 — AskUserQuestion Scope (charter-tier per Rule 1)

**Use AskUserQuestion when**:
- Genuinely-new SCOPE-tier or CHARTER-tier decision surfaces mid-session
- Multiple approaches each have ≥0.3 confidence and the wrong pick blocks subsequent work
- Drift remediation requires user pick between 3 options (per Rule 7)

**Do NOT use AskUserQuestion for**:
- Routine session handoffs ("ready for next session?")
- IMPL-tier choices (agent decides per Rule 2 of `decision-discipline.md`)
- Confirming agent intent ("about to write file X — proceed?") — that's friction without value
- Asking the user to read agent's own draft ("did I get this right?") — use sandwich-verifier instead

## Rule 9 — Cost Substrate (D-023, ratified 2026-05-04)

Any deferred-on-cost LLM path (S43a Stage B; R6 CafeF live; Q-S41-1 Opus dogfood; future thesis-validation runs) MUST first attempt subagent-dispatch substrate (Claude Code Agent tool) before requiring real $ via `ANTHROPIC_API_KEY`. Subagent dispatch is billed against the Claude Code subscription = zero marginal cost beyond subscription.

**Why charter (not skill/hook)**: this reframes how the agent thinks about "blocked-on-cost" — touches identity (StockForge = self-funded research aid; `ANTHROPIC_API_KEY` direct = dependency creep that conflicts with single-person-self-funded scope).

**Decision tree when an LLM call is contemplated**:

1. Can this run via Agent tool (subagent dispatch) within the current Claude Code session? If YES → use subagent. Cost-substrate satisfied.
2. If subagent cannot run it (e.g. requires dedicated production endpoint with custom auth, or requires thousands of parallel calls beyond subagent dispatch capacity) → escalate to user via Q&A bundle with explicit cost estimate; do NOT silently allocate `ANTHROPIC_API_KEY` budget.
3. Hard-block: "needs API key for routine LLM call" framing requires explicit user authorization per call class; not an implicit default.

**Surfaced 2026-05-01 mid-S38** from user verbatim: *"sao lại cần key api? tìm cách chạy free đi. ví dụ dùng claude code, tạo subagent chạy."* Codified as charter to bind future cost framing.

**Companion**: Q9 spec amendment patterns shift "$X estimated" cost-profile lines toward "$0 marginal via subagent substrate" once a feature ships its production substrate.

## Rule 10 — Autonomous-Mode Defection Forbidden (D-030, ratified 2026-05-05; S48e/S48f charter promotion of L-S44/M-S47-1 cluster)

In `autonomous_mode = true` (the only mode per Rule 1), agent SHALL NOT emit any phrase that:

- (a) **Defers to human selection between options** — enumerated as "(a)/(b)/(c)/(d) — which?" or
  semantic equivalents ("Would you prefer X, Y, or Z?", "Pick one of: ...", "What's your preference?").
- (b) **Enumerates next-trigger conditions** — "Next continue does X", "Holding here until you...",
  "Will resume when you...", "Awaiting your signal", "On your go".
- (c) **Self-pauses at session/PLAN boundaries** — "Ready for next session?", "Should I proceed to...",
  "Type continue when ready", "Let me know when to start".

**Allowed exceptions** (NOT defections):
- AskUserQuestion calls for genuinely-new SCOPE/CHARTER decisions (per Rule 8).
- Reporting completion ("Phase X done; Y next per checkpoint") — descriptive, not deferring.
- Asking clarification on ambiguous user prompt (legitimate Q surfaced by user-prompt-intake skill).

**Why charter-tier (not just hook)**: hook detects post-emission. Charter prevents emission at
prompt-binding layer. The Mode-E recurrence pattern (4× across S40/S43/S44/S47/S48 after 2 hook
extensions) demonstrates that hook-only enforcement is insufficient for habit-pattern violations.

**Anti-pattern (S44 origin)**: 5 successive Stop-hook fires logged Mode-D firing continue-injector
→ user had to type "continue" themselves AND issue verbal correction because the self-pause loop
produced no progress. User correctly diagnosed this as harness/deterministic gap (detector missing),
NOT LLM willpower failure. Charter rule shifts the binding from "willpower" to "context-loaded
identity rule".

**Enforcement layers** (defense-in-depth per Rule 6):
- Layer 1 (prompt): this Rule 10 (always-loaded via Tier 1 constitution).
- Layer 2 (hook): autonomous-stop-watchdog.sh § 3 SELF_PAUSE_HIT regex (already shipped pre-S48d).
- Layer 3 (hook escalation): if Mode-E hit count exceeds 1 per N sessions, emit URGENT to
  notifications/ for human review (post-S48f wiring).
- Layer 4 (subagent): optional `autonomous-defection-detector` skill — semantic check via fresh-
  context subagent post-Stop if Layer 2 regex misses prose-rephrased violations (HH-D.3 deferred).

---

## Acceptance Process (HISTORICAL — superseded by S38 ratification)

Originally a proposal-acceptance gate. After S38 ratification (2026-05-01 via D-015 + Q&A 2026-05-01-001 Q1=A), this section is historical. Future amendments to this charter follow `decision-discipline.md` Rule 1 + the S38 deny-lift mechanism precedent.
