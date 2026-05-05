---
status: CHARTER
ratified_at: 2026-05-01
ratified_by: Project owner — Q&A 2026-05-01-001 Q2=A explicit pick (S38 FOCUSED_IMPL Bundle 1 charter promote)
ratifying_decision: D-016
source_evidence:
  - agent-notes.md § L-S11-2 (IMPL-tier-resolution-doctrine)
  - observations/queued-grill-master.md § Q-B2 (charter/SCOPE-tier hard block; closed S15 Batch 1)
  - observations/queued-grill-master.md § Q-E2 (promotion frequency; closed S15 Batch 1)
  - observations/queued-grill-master.md § Q-E3 (promotion target priority; closed S15 Batch 1)
  - session-plans/pending/003-S15-track-7-constitution-amendments.md § 2 + § 3
  - decisions/003-up06-track-5.5-sync-layer-selfcap.md § Open Questions (IMPL-tier doctrine)
  - human-workspace/q-and-a/pending/2026-05-01-001-S35-charter-promote-batch.md § Q2=A (explicit pick — Rule 2 + Rule 4a augmentation)
predecessor_proposal: agent-workspace/proposals/decision-discipline.md (S16 draft; moved to constitution at S38)
---

# Decision Discipline — CHARTER

> **Status**: CHARTER (ratified 2026-05-01 at S38 via Q&A 2026-05-01-001 Q2=A). Edits require explicit user prompt + Q&A per `agent-workspace/CLAUDE.md` constitution-amendment process.

## Purpose

Codify how decisions get made, how learned rules get promoted, and where the agent has IMPL-tier discretion vs where the agent MUST surface explicit user picks. Resolves the recurring failure mode of (a) silent default-acceptance on charter-tier scope (UP-06 NO Silent File-Defaults) and (b) churn from over-promoting routine rules to charter when a hook would suffice (Q-E3).

## Rule 1 — Tier-vs-Default-Acceptance (Q-B2 — closed Recommended)

A decision's **tier** determines whether default-acceptance is permissible:

| Tier | Default-acceptance allowed? | Mechanism |
|---|---|---|
| **CHARTER** | NO — MUST require explicit user letter pick | AskUserQuestion with no auto-fallback; SessionEnd does NOT close the question |
| **SCOPE** | NO — MUST require explicit user letter pick | AskUserQuestion with no auto-fallback; born-answered Q&A bundle if user offline |
| **DECISION_ROUTING** | NO (paired with SCOPE per Q-B2 reasoning) | AskUserQuestion explicit pick |
| **ARCH** | YES with caveat — explicit pick preferred; agent default with transparent flag if user unavailable | Document the default in decision file frontmatter |
| **IMPL** | YES — agent decides per L-S11-2 doctrine | Routine implementation choice; log in session journal only |

**Anti-pattern**: bundling a CHARTER-tier item with sub-charter-tier items in one Q&A. Per drift signal D3 (charter-mixed-bundle), this masks silent absorption — the high-tier item gets default-accepted along with low-tier items in a single "OK" reply.

**Why**: Charter/scope/routing decisions reshape the project's identity, layers, or routing fabric. A wrong default here produces silent drift that compounds across sessions. IMPL choices are reversible by single Edit; charter changes are not.

## Rule 2 — IMPL-Tier-Resolution-Doctrine (L-S11-2)

When a SCOPE/CHARTER-level decision is enacted across multiple sessions, the IMPL of any one session has discretion on:

- LOC distribution within budgets specified in the parent decision
- Bundling vs splitting writes (one Edit vs several)
- Final text wording within proposal/skill drafts (subject to identity-scope coherence)
- File-layout decisions surfaced mid-IMPL (path consistency, file split between research vs dogfood, etc.)

**The doctrine**: downstream-alignment cost dominates drafting-text precision. If an IMPL-tier resolution diverges from the parent decision's prose but downstream artifacts (permissions, README, hooks, .gitignore) all align coherently, the **prose is the drafting bug**, not the IMPL. Surface the divergence as a REV-N amendment to the parent decision; do NOT churn downstream.

**Carry-over examples**: D-005 REV-1 ratifies IMPL-S11-2 (path layout) + IMPL-S12-1 (dogfood file split) per this doctrine.

**Anti-pattern**: rewriting the parent decision's prose to match every IMPL nudge. The decision is shipped; the amendment is the audit trail.

### Rule 2 sub-clause: Storage Substrate is IMPL-Tier When Portability Binds (L-S17-1, D-006 IMPL-S17-1 evidence)

When an upstream decision (D-NNN) names specific storage technology ("SQLite" / "Postgres" / "Redis" / specific DB) but Phase 0 portability rules (e.g., L-S11-1 bash+POSIX-only) constrain the runtime environment, **the storage substrate is IMPL-tier**.

**Pre-flight**: verify named tech availability via `command -v <tool>`. If unavailable AND portability binds:
1. Pick portable substrate (e.g., bash+TSV instead of SQLite)
2. Ship MVP; author NEW IMPL-tier decision (D-NNN) documenting deviation
3. Cite source decision + portability constraint (L-NN-N) + Phase N+ migration plan
4. Original spec stands as migration target; NO upstream REV needed

**Example (D-006 IMPL-S17-1)**: D-002 § Track 8 named SQLite; S17 pre-flight `command -v sqlite3` exit 1; resolved via bash+TSV; D-006 documents deviation; SQLite migration deferred Phase 1+.

**Anti-pattern**: blindly invoking unavailable tool because spec said so — adds portability debt without progress. Or: defer entire track until tool lands — forfeits time-value of dependent work.

### Rule 2 sub-clause: Master-Plan Internal Contradiction Resolution (L-S26-1, S35 charter-promote augmentation)

When a master-plan contains internal contradictions (e.g., abstract count in Track Catalog conflicts with explicit per-session deliverable text in Session Breakdown), **prefer the deliverable explicit text** — it carries higher decision-density and is closer to actual execution. Document the divergence as `IMPL-S{N}-*` deviation in session log; do NOT churn the master-plan to fix the abstract count mid-execution.

**Why**: deliverable text is what dev sessions actually consume; abstract counts are summary/budget framing. Drift between the two = drafting bug; the deliverable wins because it has been verified at deeper specification.

**Anti-pattern**: blocking session entry to fix master-plan contradiction. The session ships per deliverable text; master-plan amendment lands at phase-close retrospective.

## Rule 3 — Promotion Target Priority (Q-E3 — closed Recommended)

When an `agent-notes.md` entry becomes promotable (Rule 4 below), promotion target priority is **cheapest first**:

1. **Hook FIRST** (`scripts/hooks/<name>.sh`) — deterministic check, runs without LLM cost
2. **Skill SECOND** (`.claude/skills/<name>/SKILL.md`) — encodes procedural discipline; LLM-loaded but specific
3. **Charter LAST** (`agent-workspace/constitution/<name>.md`) — heaviest lift; requires user explicit approve

**Rule of thumb**: if the rule can be expressed as `grep` or `wc` on a known set of files, it's a hook. If it requires judgment or free-form authoring, it's a skill. If it shapes identity, layers, or invariants, it's charter.

**Anti-pattern**: promoting every learned rule to charter. Charter is for invariants; rules and reflexes belong in hooks/skills.

**Examples**:
- L-S11-1 Phase 0 portability → HOOK (`bash-hook-lint.sh` § L-S11-1 check)
- L-S14-1 first-draft compression reserve → SKILL (`write-a-skill/SKILL.md` § Best practices)
- L-S14-4 autonomous_mode + Mode-D coverage → CHARTER (`autonomous-protocol.md` § Mode A/B/C/D)

## Rule 4 — Promotion Frequency (Q-E2 — closed Recommended)

Promotion runs **at phase boundaries only**, not continuously. Manual review by `promote-rule` skill (or fresh-context promotion subagent) at phase boundary; not per-session-end.

**Why phase-boundary**: per-session promotion produces churn (small batches, low signal). Phase-boundary clusters ≥10 entries lets similarity grouping work. Continuous promotion-on-every-note triggers thrash.

**Trigger**: ≥10 new agent-notes since last promotion run, OR phase-boundary checkpoint, whichever first.

### Rule 4a — Phase-Boundary Trigger Enforcement (S35 META-skip prevention; charter-promote augmentation)

The promote-cycle MUST run **every 5 sessions** OR at phase boundary, whichever comes first. Without this enforcement, the META-skip recurs (S20-S34 went 15 sessions without promotion run because Rule 4 was interpreted as "phase boundary only" instead of "phase boundary OR every 5 sessions").

**Mechanism**: hook `scripts/hooks/promotion-cycle-trigger.sh` (shipped at S35 D4) emits SessionStart soft-warning if `(current_session_N - last_promotion_run_session_N) ≥ 5`. The agent MUST acknowledge the warning by either (a) running `/promote-rule` skill that session OR (b) explicitly defer to next session with reason logged in current-execution.md.

**Anti-pattern**: silently dismissing the soft-warning across multiple sessions without action — that IS the META-skip pattern.

### Rule 4b — Lesson-synthesis mandatory at session-end (S43e charter-promote)

Every session whose work produces ANY of the following triggers MUST append at
least one new entry to `agent-workspace/memory/self-awareness/known-issues.md`
OR `agent-workspace/memory/self-awareness/best-practices.md` OR
`agent-workspace/memory/agent-notes.md` BEFORE the checkpoint `latest.md` is
written:

  (a) ≥1 user correction (verbatim or paraphrased)
  (b) ≥1 deferred-fix item (R-N / DEFER-S*-N)
  (c) ≥1 substrate gap discovered (hook missing, contract unenforced, etc.)
  (d) ≥1 charter-tier or SCOPE-tier decision authored
  (e) ≥1 META_LOOP recovery action

The entry MUST cite at minimum: (i) verbatim trigger evidence; (ii) the rule it
codifies; (iii) anti-example (what the rule prevents); (iv) auto-detect path
(hook / skill / charter). Sessions producing zero triggers (e.g., rote refactor
sessions) are exempt and SHOULD record `lesson_synthesis: NA-no-triggers` in
their session log.

**Enforcement** (paired hook upgrade — flipped at S43e ratification):
  - `scripts/hooks/lesson-synthesis-watchdog.sh` is in STRICT mode (exit 2 on
    dormancy detection branch).
  - Strict mode auto-clears once the next session writes a qualifying entry
    (LESSON_TOTAL > 0 → no alert → exit 0).
  - Loop is finite: ≤1 hard-block per dormancy episode (single Stop-hook firing
    per episode; user/agent adds entry; subsequent firing clears).

**Cross-references**: KI-S35-5, BP-S35-1, KI-S43b-5, BP-S43b-4, L-S43b-7.
**Supersedes**: nothing (additive to Rule 4).
**Companion**: Rule 4 promote-rule cadence remains 5-session OR phase-boundary;
this rule shortens the *upstream* feedback latency that feeds Rule 4.
**Ratifying decision**: D-026 (S43e — bundled C1+C2 deny-lift cycle).

## Rule 5 — Provenance Required on Every Decision

Every entry in `agent-workspace/memory/decisions/` MUST cite at least one upstream source per `proposals/provenance-protocol.md` (or constitution version once promoted). A decision with empty `source_evidence:` is a drift signal (DR-PROV) and will be flagged.

## Anti-Patterns Catalogued

- **Performative SC ticking** (AP-7) — defer with explicit prerequisites > fire vacuous proposals.
- **Charter-coherence defer overriding user-CRITICAL** (AP-5) — re-read all `human-workspace/user_prompt/*` at every phase entry; never silently defer USER-CRITICAL items.
- **Bundling CHARTER with sub-charter** (D3 drift signal) — separate bundles required per Rule 1.
- **Promoting routine rules to charter** — Rule 3 priority forces hook/skill first.

## Acceptance Process

This proposal moves to `agent-workspace/constitution/decision-discipline.md` when:
1. User reviews and explicitly approves (chat acknowledgment, or `/promote-proposal decision-discipline.md` skill once that exists).
2. Once promoted, edits to it require the constitution-amendment process (charter-tier change with explicit user prompt + Q&A).

Until then, this is a **strong recommendation** — agents SHOULD follow it but it is not enforced by deny-list.
