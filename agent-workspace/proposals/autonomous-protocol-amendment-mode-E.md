---
status: ACCEPTED
proposal_id: HH-D.1
ratified_at: 2026-05-05
ratified_via: S48f main-session opus47-max — 1-Q AskUserQuestion Q-S48e-1=ACCEPT
ratifying_adr: agent-workspace/memory/decisions/030-S48f-charter-promote-autonomous-protocol-rule-10-mode-E.md
created_at: 2026-05-05
created_via: S48e main-session opus47-max (Phase 2.5 HH-D Mode-E charter promotion)
target_file: agent-workspace/constitution/autonomous-protocol.md
binding_charter_clauses:
  - autonomous-protocol.md Rule 1 — autonomous_mode=true is the ONLY mode (D-015)
  - decision-discipline.md Rule 4b — lesson-synthesis mandatory (D-026)
  - 009-S48-harness-hardening-middle-phase.md § HH-D — Self-pause Tier-3 charter promotion
ratification_path: USER-GATE via AskUserQuestion + deny-lift cycle (S38 mechanism)
companion_hooks_already_shipped:
  - scripts/hooks/autonomous-stop-watchdog.sh § 3 (SELF_PAUSE_HIT regex detector; pre-S48d)
  - scripts/hooks/autonomous-stop-watchdog.sh § 4b (.autonomous-self-pause-alert.log emit)
companion_user_memory:
  - ~/.ccs/instances/.../memory/autonomous_continue_no_self_pause.md
  - ~/.ccs/instances/.../memory/stop_offering_routing_branches.md
  - ~/.ccs/instances/.../memory/full_autonomous_no_supervised.md
---

# Autonomous Protocol Amendment — Rule 10 (Mode-E Defection Prohibition)

## Why this proposal exists

Per agent-notes documented Mode-E hits across S40/S43/S44/S47/S48 (≥4 recurrences after
two hook-tier extensions of `autonomous-stop-watchdog.sh`), the agent continues to emit
self-pause phrases despite:
- Hook-tier deterministic detector regex shipped pre-S48d (autonomous-stop-watchdog.sh § 3)
- User-memory rule `autonomous_continue_no_self_pause.md` codifying LLM-side policy
- User-memory rule `stop_offering_routing_branches.md` codifying option-enumeration ban
- User-memory rule `full_autonomous_no_supervised.md` codifying mode-uniqueness

The hook detects but cannot PREVENT — by the time the regex matches, the defective
phrase is already in the agent's output. Prevention requires prompt-level binding via
charter rule that the agent reads at every SessionStart bootstrap (per memory-tiers.md
constitution/ Tier 1 + autonomous-protocol.md being always-loaded).

This proposal codifies Rule 10 to harden the LLM-side defection ban into the same
context-loaded substrate that Rules 1-9 already govern.

## Proposed Rule 10 (verbatim insert text)

```markdown
## Rule 10 — Autonomous-Mode Defection Forbidden (S48e charter promotion of L-S44/M-S47-1 cluster)

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
```

## Insertion point

Append as Rule 10 in `agent-workspace/constitution/autonomous-protocol.md` after current Rule 9
(line 141 — after § "Companion: Q9 spec amendment patterns ..." paragraph) and before current
"## Acceptance Process (HISTORICAL ...)" section (line 144).

## Diff size estimate

- Net add: ~32 LOC (header + 3 forbidden patterns + allowed exceptions + why-charter + enforcement layers).
- autonomous-protocol.md current size ~146 LOC → post-amendment ~178 LOC.
- Tier 1 budget impact: ~125 tok added (well within 8K ceiling — Tier 1 currently ~120K, this is 0.1%).

## Ratification paths

| Pick | Action | Effect |
|---|---|---|
| **A: ACCEPT (Recommended)** | Apply Rule 10 verbatim via deny-lift cycle next session (S48f); D-NNN ADR ratify | Closes Phase 2.5 HH-D track; fulfills 4-recurrence charter promotion criterion |
| **B: AMEND** | User specifies wording revisions (e.g. add/remove forbidden patterns; tighten exceptions) | Re-draft proposal next session |
| **C: REJECT** | Leave hook-only enforcement (autonomous-stop-watchdog.sh § 3); document why charter not warranted | Mode-E recurrences continue tracked; charter promotion deferred indefinitely |

## What this proposal does NOT include

- HH-D.3 optional `autonomous-defection-detector` skill (subagent semantic check) — deferred; depends on Layer 2 regex empirical false-negative rate (TBD over Phase 3 S49+ sessions).
- Edits to `autonomous-stop-watchdog.sh` — already shipped pre-S48d per agent-notes; no further hook patch this proposal.
- New M-* mistake-log entries enumerating each Mode-E hit — those are session-log artifacts not constitution material.

## Bundle opportunity (per L-S43f-1 doctrine)

This proposal can pair with any other queued constitution amendment (none currently queued post-S48d
ratifications). If S48f introduces another charter-tier proposal (e.g., from HH-E.2 contract revision)
the deny-lift cycle could batch both in a single AskUserQuestion bundle.

## Drift watch (post-ratification)

- D9 charter md5: autonomous-protocol.md WILL CHANGE (intentional via D-NNN ratify).
- D-INTENT measurement: count Mode-E hits per next 5 sessions in autonomous-stop-watchdog.sh log; success criterion = 0 hits (per `009-S48-harness-hardening-middle-phase.md` § HH-D success criteria).
- DR-PROV: ratifying ADR will cite this proposal + agent-notes Mode-E excerpt (lines 376-382) + 4-recurrence count source.
