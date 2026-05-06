---
id: D-030
title: S48f — Q-S48e-1 charter-promote autonomous-protocol.md Rule 10 (Autonomous-Mode Defection Forbidden) — Mode-E habit-pattern hardening
status: ACCEPTED
tier: CHARTER
date_proposed: 2026-05-05
date_ratified: 2026-05-05
ratified_by: Project owner — explicit AskUserQuestion ACCEPT pick (S48f 1-Q bundle, Q-S48e-1)
ratifying_session: S48f (Phase 2.5 HH-D Mode-E charter promotion; HH-D.2 ratification)
authoring_agent: Claude Opus 4.7
supersedes: none
superseded_by: none
source_evidence:
  - agent-workspace/proposals/autonomous-protocol-amendment-mode-E.md  # S48e HH-D.1 draft
  - agent-workspace/memory/agent-notes.md (Mode-E cluster L-S44/M-S47-1 pattern; lines ~376-382)
  - agent-workspace/session-plans/pending/009-S48-harness-hardening-middle-phase.md § HH-D
  - scripts/hooks/autonomous-stop-watchdog.sh § 3 SELF_PAUSE_HIT regex (Layer 2 detector pre-S48d)
  - scripts/hooks/autonomous-stop-watchdog.sh § 4b .autonomous-self-pause-alert.log emit (pre-S48d)
  - ~/.ccs/instances/.../memory/autonomous_continue_no_self_pause.md (user-memory companion)
  - ~/.ccs/instances/.../memory/stop_offering_routing_branches.md (user-memory companion)
  - ~/.ccs/instances/.../memory/full_autonomous_no_supervised.md (user-memory companion)
  - AskUserQuestion (S48f turn) — 1-Q Q-S48e-1=ACCEPT
options_considered:
  - A: ACCEPT Rule 10 verbatim (4-layer defense-in-depth) — chosen
  - B: AMEND (specify wording revisions to forbidden patterns or allowed exceptions)
  - C: REJECT (leave hook-only enforcement; charter promotion deferred indefinitely)
chosen_option: A
---

# D-030 — Autonomous-Protocol Rule 10 (Mode-E Defection Forbidden) charter promotion

## Summary

Charter amendment to `agent-workspace/constitution/autonomous-protocol.md`: NEW Rule 10
"Autonomous-Mode Defection Forbidden" inserted between Rule 9 (D-023 Cost Substrate)
and the historical Acceptance Process section. Codifies prompt-binding ban on three
Mode-E defection phrase patterns the agent has emitted ≥4× across S40/S43/S44/S47/S48
despite shipped hook-tier detector and three user-memory rules.

## Why this charter-tier ratification

Mode-E recurrence empirics (per `agent-notes.md` cluster + autonomous-stop-watchdog.sh
log entries):
- 4 distinct sessions (S40, S43, S44, S47, S48) hit SELF_PAUSE_HIT regex post-Layer-2
  shipping → demonstrates hook-only enforcement insufficient.
- Hook detects post-emission; charter binds at prompt-loading layer (Tier 1
  always-loaded constitution → present at every SessionStart).
- L-S44 specifically: 5 successive Stop-hook fires logged Mode-D firing
  continue-injector because the LLM self-paused at PLAN boundary; user had to
  type "continue" verbally AND issue verbal correction. User correctly diagnosed
  this as harness/deterministic gap (detector missing) rather than LLM willpower
  failure — but the Layer-2 regex shipped post-incident still missed prose-rephrased
  variants in subsequent sessions, motivating the prompt-layer hardening.

## Rule 10 verbatim (as inserted)

```markdown
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
```

## Implementation

**Charter edit** (deny-lift cycle this turn — mirrors S48d D-029 pattern):
- `agent-workspace/constitution/autonomous-protocol.md` — NEW "## Rule 10 — Autonomous-Mode
  Defection Forbidden ..." subsection inserted between current Rule 9 (D-023 Cost Substrate)
  and the `---` separator preceding `## Acceptance Process (HISTORICAL — superseded by S38
  ratification)`. Net add ~36 LOC including header, 3 forbidden patterns, allowed exceptions,
  why-charter justification, anti-pattern citation, 4-layer defense-in-depth.

**Permission ceremony** (S38 deny-lift mechanism — exact same pattern as D-018 through D-029):
- `.claude/settings.json` Edit deny rule `Edit(agent-workspace/constitution/**)` temporarily
  replaced with non-matching path `Edit(agent-workspace/constitution/.deny-lift-S48f/**)` for
  the duration of the autonomous-protocol.md edit, then restored same-turn.
- D9 zero-residue verified: only `autonomous-protocol.md` md5 changed
  (`bf2690f1468eef838bb84f712a2ed90b` → `378b30f12153e0eb5196c5e598a71e3e`); all 12 other
  constitution files md5 IDENTICAL pre/post edit cycle (boundaries / vbw-protocol /
  drift-signals / memory-routing-tree / karpathy-principles / invariants / decision-discipline /
  architecture / financial-data-protocol / memory-tiers / session-budgets / coding-principles).

**Layer 2 hook** (already shipped pre-S48d — no patch this turn):
- `scripts/hooks/autonomous-stop-watchdog.sh` § 3 SELF_PAUSE_HIT regex detector + § 4b
  `.autonomous-self-pause-alert.log` emit. Provides post-emission detection that complements
  but does not replace the Rule 10 prompt-layer binding.

**Layer 3 escalation** (post-S48f wiring — deferred to next routine watchdog patch):
- Extend `autonomous-stop-watchdog.sh` to count Mode-E hits per session-window; emit URGENT
  notification when count > 1 per N sessions. Low-priority since Layer 1+2 should cover the
  baseline; Layer 3 is for diagnosing whether Rule 10 prompt-binding is working empirically.

**Layer 4 subagent skill** (HH-D.3 — explicitly DEFERRED per proposal):
- `autonomous-defection-detector` subagent skill for semantic check on prose-rephrased
  violations that Layer 2 regex misses. Defer-decision contingent on Layer 2 false-negative
  rate measurement over Phase 3 S49+ sessions; ship only if empirically warranted.

**Proposal closure**:
- `agent-workspace/proposals/autonomous-protocol-amendment-mode-E.md` — frontmatter
  `status: PROPOSAL` → `status: ACCEPTED`; ratification record points to this ADR.

## Provenance chain

1. S40/S43/S44/S47/S48 (2026-05-01 → 2026-05-05) — Mode-E hits logged by
   autonomous-stop-watchdog.sh § 3 detector across 4 distinct sessions; agent-notes
   accumulated cluster entries.
2. Pre-S48d — Layer 2 hook regex shipped (autonomous-stop-watchdog.sh § 3+4b);
   first deterministic catch but post-emission only.
3. Post-S48d — recurrence continued (S48 itself) → empirical signal that hook alone
   does not prevent the habit pattern.
4. S48e (this proposal author session) — HH-D.1 proposal authored to
   `proposals/autonomous-protocol-amendment-mode-E.md` (~115 LOC under D1 ceiling) per
   `009-S48-harness-hardening-middle-phase.md` § HH-D.1; deferred ratification to S48f
   per CLAUDE.md never-mix doctrine + budget discipline (S48d closed at ~211K
   cumulative; S48e contained ~10-20K author scope).
5. S48f (this turn) — HH-D.2 ratification: 1-Q AskUserQuestion fired Q-S48e-1;
   user picked A=ACCEPT (Recommended) explicitly per Q-B2 charter-tier mandatory-letter rule.
6. Deny-lift cycle this turn → Rule 10 inserted verbatim into autonomous-protocol.md
   → deny restored → D9 zero-residue verified → this ADR authored.

## Trade-offs accepted

| Concern | Acceptance rationale |
|---|---|
| **autonomous-protocol.md grows ~36 LOC (~125 tok Tier 1)** | 0.1% of 8K Tier 1 ceiling; hardening high-recurrence pattern justifies the budget. |
| **Layer 3 escalation deferred** | Layer 1 (prompt) + Layer 2 (regex) cover baseline; Layer 3 is diagnostic instrumentation, not enforcement. Ship when empirical need surfaces. |
| **Layer 4 subagent deferred (HH-D.3)** | Subagent dispatch per session-end is non-trivial cost; only ship if Layer 2 false-negative rate empirically warrants it over Phase 3+. |
| **Charter rule cannot guarantee prevention** | Honest acknowledgment: prompt-binding raises cost-of-defection but not to zero. The Layer 2 hook catches residue. Combined defense-in-depth > single-layer. |

## Drift watch

- D9 charter md5: autonomous-protocol.md CHANGED (intentional; ratified per this ADR);
  all other 12 constitution files md5 UNCHANGED (verified pre/post via
  `find agent-workspace/constitution -maxdepth 1 -type f -name "*.md" -exec md5sum {} \;`).
- D-INTENT: ALIGNED (Rule 10 inserted verbatim from proposal § "Proposed Rule 10 (verbatim
  insert text)" with only the proposal-internal `(S48e charter promotion ...)` parenthetical
  expanded to `(D-030, ratified 2026-05-05; S48e/S48f charter promotion of L-S44/M-S47-1
  cluster)` for ratification provenance — substantive text identical).
- DR-PROV: this ADR cites proposal + agent-notes cluster + Layer 2 hook references +
  user-memory companions + AskUserQuestion turn.
- D-INTENT measurement post-ratification (per proposal § Drift watch): count Mode-E hits
  per next 5 sessions in autonomous-stop-watchdog.sh `.autonomous-self-pause-alert.log`;
  success criterion = 0 hits per `009-S48-harness-hardening-middle-phase.md` § HH-D
  success criteria. If non-zero, escalate to Layer 4 subagent skill (HH-D.3 ship gate).

## Companion handoff

S48f closes Phase 2.5 HH-D track (HH-D.1 proposal + HH-D.2 ratification both DONE; HH-D.3
optional subagent skill DEFERRED contingent on empirical false-negative rate). Phase 2.5
remaining tracks per `009-S48-harness-hardening-middle-phase.md`:
- HH-E Q&A escalation upgrade (S48f-or-later)
- HH-F self-knowledge bootstrap
- HH-G portability validation
- HH-H auto-/clear-handoff safety (+ NEW HH-H.5 session-self-reboot idempotency added S48e per M-S48e-1)

No charter-tier proposals currently queued for bundle opportunity per L-S43f-1.

---

## Ratification record

User explicit ACCEPT via 1-Q AskUserQuestion bundle (S48f turn 2026-05-05). No amendments
requested. Charter amendment shipped verbatim from proposal § "Proposed Rule 10 (verbatim
insert text)" with only the parenthetical header expanded for ratification provenance
(D-030 ID + ratification date + lineage cluster reference).
