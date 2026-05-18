# Chapter 10 — Self-Improvement

> **Diataxis quadrant**: Explanation
> **Reading time**: ~25 minutes
> **Prerequisites**: Chapter 7 (Memory), Chapter 9 (Quality System)

The harness improves itself. This is what separates it from a static framework. Every session, the system observes its own performance, captures lessons, and graduates the most valuable lessons into permanent enforcement.

This chapter explains the continuous learning loop:

- How rules emerge from experience
- How rules graduate (inline → skill → hook → constitution)
- How rules are retired
- The severity/escalation pipeline as a self-improvement mechanism
- The Karpathy outer loop

---

## 10.1 — Where Improvements Come From

The harness recognizes five sources of learning:

| Source | What | Capture mechanism |
|---|---|---|
| **User correction** | User flags an agent mistake verbatim ("không, X", "wrong, X") | `correction-rate-tracker.sh` counts; agent writes `M-S<N>-<M>` mistake-log entry |
| **Post-mortem** | Significant failure investigated retrospectively | Agent writes to `agent-workspace/post-mortems/` |
| **Sandwich verifier finding** | Adversarial review surfaces defect | Verifier returns FINDING; main session persists to attestation-log + observation |
| **Drift signal hit** | Deterministic hook catches violation | Hook appends to `.drift-signals.log`; `drift-rollup-daily.sh` aggregates |
| **Self-observation** | Agent notices its own pattern (often during retrospective) | Agent writes to `agent-notes.md` |

All five funnel into `agent-notes.md` (rules) and `mistake-log.md` (failures). These two files are the *raw material* of self-improvement.

---

## 10.2 — The Promotion Lifecycle

A learned rule begins as an inline `agent-notes.md` entry. It may stay there forever (low value, narrow context), or it may graduate through three tiers of enforcement.

```
┌──────────────────────────────────────────────────────────────┐
│ TIER 0 — INLINE                                              │
│ Lives in agent-notes.md as a digest entry.                   │
│ Read at session-start (Tier 2 memory).                       │
│ Enforcement: agent self-discipline.                          │
│ Catch-rate: depends on agent attention.                      │
└──────────────────────────────────────────────────────────────┘
                              ↓ promote
┌──────────────────────────────────────────────────────────────┐
│ TIER 1 — SKILL                                               │
│ Codified as a .claude/skills/<name>/SKILL.md procedure.      │
│ Auto-discovered when context matches description.            │
│ Enforcement: LLM-mediated; consistent across sessions.       │
│ Catch-rate: depends on description-discovery match.          │
└──────────────────────────────────────────────────────────────┘
                              ↓ promote
┌──────────────────────────────────────────────────────────────┐
│ TIER 2 — HOOK                                                │
│ Codified as a scripts/hooks/<name>.sh deterministic check.   │
│ Fires on event (SessionStart / Stop / PreToolUse / etc.).    │
│ Enforcement: mechanical; can block (RC=2) or warn.           │
│ Catch-rate: 100% within scope; bounded by event triggers.    │
└──────────────────────────────────────────────────────────────┘
                              ↓ promote
┌──────────────────────────────────────────────────────────────┐
│ TIER 3 — CONSTITUTION                                        │
│ Codified as a rule in agent-workspace/constitution/<file>.md │
│ Immutable; amendments require ratification + cool-down.      │
│ Enforcement: foundational; all lower tiers respect.          │
│ Catch-rate: 100% (principle level).                          │
└──────────────────────────────────────────────────────────────┘
```

### Promotion Triggers

When does a rule graduate? Per [`agent-notes.md` AP-23 doctrine](12-internals.md#ap-23) and the `promote-rule` skill:

**Tier 0 → Tier 1 (Skill)**:
- Same procedure appears in 3+ sessions
- Manual application is reliable but tedious
- LLM judgment is required (not deterministic enough for hook)

**Tier 1 → Tier 2 (Hook)**:
- Rule is statically detectable (regex / grep / file-existence)
- Manual or skill-mediated application catches < hook would
- 2nd-instance threshold met (AP-23: promote on 2nd, not 1st, instance unless cluster pattern)

**Tier 2 → Tier 3 (Constitution)**:
- Rule rises to invariant (no contextual exception)
- Multiple hooks would otherwise duplicate it
- Affects core principle (charter, BC isolation, financial-data integrity)

### The AP-23 Doctrine

Per `agent-notes.md`:

> "1st-instance HOLD-FOR-PROMOTION; promote on 2nd. Refinement-of-rule (lesson-about-lesson) is AP-23 RED FLAG: 2nd instance mandates promote-or-retire (not inline accumulation)."

In English: don't promote a rule on its first appearance — it might be a one-off. But if it appears twice, it is a pattern, and inline accumulation becomes anti-pattern (AP-23). At that point, either promote or retire.

### Cluster-Based Promotion

The above is for individual rule instances. **Cluster patterns** can promote earlier:

> "Cluster count n=4 > threshold n=3 → PROMOTE-NOW (per L-S345-1 honesty-promotion-at-n=3 doctrine)."

When 4+ rules share a class (e.g., main-session pre-dispatch self-discipline cluster of L-S360-1 + L-S360-2 + L-S365-1 + L-S327-1), all promote together as a single hook covering the shared pattern.

---

## 10.3 — The `promote-rule` Skill

The mechanism for promotion. Lives at [`.claude/skills/promote-rule/SKILL.md`](../../../.claude/skills/promote-rule/SKILL.md).

### When It Fires

- Periodic: every 5+ sessions, or
- Forced: `promotion-cycle-trigger.sh` HARD-BLOCKs at SessionStart when ≥8 new lessons accumulated since last `promote-rule` dispatch

The hard-block forces the next session to dispatch `promote-rule` before any other work.

### What It Does

1. Reads `agent-notes.md` digest entries since last cycle
2. Clusters entries by **Jaccard similarity** of rule body + context
3. Identifies promotion candidates (clusters with similar root cause)
4. Writes `observations/promotion-proposals-<TS>.md` listing candidates
5. For each candidate:
   - Names the cluster
   - Proposes promotion target (HOOK / SKILL / CHARTER)
   - Drafts the artifact (hook script / skill body / constitution amendment)
   - Cites companion firing-test plan if HOOK
6. The next session reads the proposals; main session ratifies via AskUserQuestion bundle

### Output Schema

```markdown
## Cluster: <name>

**Instances** (n=4):
- L-S360-1 (2026-05-17): pre-stop fresh-dispatch check
- L-S360-2 (2026-05-17): pre-dispatch budget-honesty check
- L-S365-1 (2026-05-17): orthogonal-knob distinction
- L-S327-1 (2026-05-16): master-ledger COMPLETED weak signal

**Shared pattern**: main-session shortcut applied to dispatch/commit boundary
without empirical cross-check against actual config/completion-signal.

**Proposed promotion**: NEW deterministic hook
`scripts/hooks/main-session-pre-dispatch-discipline.sh` (Stop chain, after
lesson-synthesis-watchdog, before harness-recovery-dod-watchdog).
4 checks share `.transcript-jsonl` parse cost → one hook, four checks,
~150 LOC + companion firing-test ~80 LOC.

**Tier**: 2 (HOOK)
**Promotion candidate**: L-S365+-CLUSTER-1
**Confidence**: 0.85 (above ARCH-tier 0.80 threshold; self-decide eligible)
```

---

## 10.4 — The `lesson-synthesizer` Subagent

Stage 2 of the self-upgrade loop. Lives at [`.claude/agents/lesson-synthesizer.md`](../../../.claude/agents/lesson-synthesizer.md).

### When It Fires

- Triggered by `lesson-synthesis-watchdog.sh` ALERT (Stop hook)
- The watchdog ALERTs when:
  - Session diff shows ≥3 substantive changes
  - No new `agent-notes.md` entry recorded this session
  - No "no mistakes this session" attestation present

The watchdog asks: "this session changed substantively but recorded no lesson — is that right?"

### What It Does

Fresh-context dispatch. Reads:
- Recent session log + observations
- `agent-notes.md` last 200 LOC
- `mistake-log.md` last 100 LOC
- Best-practices catalog (`memory/self-awareness/best-practices.md`)
- Known-issues catalog (`memory/self-awareness/known-issues.md`)

Identifies:
- New patterns in this session's work
- New issues that became known
- New best practices that emerged

Produces (≥1 entry):
- A new `agent-notes.md` digest entry (rule)
- A new known-issue (KI) entry
- A new best-practice (BP) entry

Each entry tagged with provenance (session diff line refs, observation file refs).

### Why It Exists

Without `lesson-synthesizer`, the lesson capture relies on the main session attending to it at session-end. Empirically, this fails ~30% of the time (sessions close without capturing lessons that would have been captured by a retrospective glance). The watchdog + synthesizer is the deterministic answer.

---

## 10.5 — Lesson Naming Convention

Lessons have IDs:

```
L-S<N>-<M>
```

Where:
- `S<N>` = session ID where lesson was authored
- `<M>` = sequential within that session (1, 2, 3...)

Examples:
- `L-S360-1` — first lesson authored in S360
- `L-S360-2` — second lesson in S360
- `L-S365+-1` — cluster lesson that touches sessions S360-S365

### Cross-Reference

Lesson IDs appear extensively in:
- Hook header comments (`# L-S176-1` cited)
- Skill descriptions (description references the lesson)
- Constitution rule rationale
- ADR `intent_classification` field

This creates a **provenance graph**: every rule traces back to its originating lesson, which traces back to its originating session/post-mortem/correction.

---

## 10.6 — Demotion + Retirement

Not every promoted rule deserves to live forever. Per the [Ritual Demotion Doctrine](#10-7--ritual-demotion):

> "Per-session rituals (audit / re-scan / refresh) MUST track catch-rate. Catch-rate = 0 over 3+ consecutive sessions ⇒ promote-to-hook OR demote-to-passive OR retire."

### Demotion Paths

| From → To | Trigger | Mechanism |
|---|---|---|
| HOOK → SKILL | Hook fires but findings consistently low-value | Move logic to skill; unwire hook |
| SKILL → INLINE | Skill rarely triggers; description doesn't match contexts | Move to inline `agent-notes.md` digest |
| HOOK → RETIRED | Hook catch-rate = 0 over 3+ sessions | Delete script + firing-test; archive |
| CONSTITUTION → DEPRECATED | Rule no longer applies (e.g., underlying tech changed) | Mark `status: DEPRECATED-BY-D-NNN`; never delete |

### Concrete Retirement Examples

From `agent-notes.md`:

> **RETIRED-1ST-INSTANCE-DUPLICATE-OF-CHARTER: L-S385-3**
> Context: plan-039 § C candidate 3 — "INCOMPLETE-corpus dogfood = calibrated honesty signal per Charter Principle 6"
> Rule (RETIRED): Promote INCOMPLETE-corpus framing as a template language.
> RETIRE rationale: Charter Principle 6 (Adversarial by default) ALREADY mandates this framing. Promoting to template would just paraphrase existing charter text = inline accumulation per AP-23 RED FLAG.

> **RETIRED-SPECULATIVE-ABSTRACTION: L-S371-1**
> Rule (RETIRED): Factor out common resolver Protocol from VnTickerResolver for reuse.
> RETIRE rationale: Only ONE resolver exists. Sector + persona resolvers are future hypothetical. Creating empty Protocol with one implementation = speculative abstraction per Karpathy P2 "no abstractions for single-use code".

Retirements are documented in `agent-notes.md` with `## RETIRED-<reason>:` headers. This preserves the *why* of retirement.

---

## 10.7 — Ritual Demotion (S99 RCA Layer 5)

A specific case of demotion: per-session rituals (audits, scans, refresh patterns) are subject to **catch-rate accountability**.

### The Rule

Per CLAUDE.md § Hard Rules:

> "Ritual demotion (per S99 RCA Layer 5; Q-RCA-5 + Q-RCA-7 = A): per-session rituals (audit / re-scan / refresh) MUST track catch-rate. Catch-rate = 0 over 3+ consecutive sessions ⇒ promote-to-hook OR demote-to-passive OR retire. Refinement-of-rule (lesson-about-lesson) is AP-23 RED FLAG: 2nd instance mandates promote-or-retire (not inline accumulation)."

### Concrete Demotion: L-S310-1 Ritual Demotion

A real example. The `sync-grilling-call.sh` ritual fired on a 3-session cadence. Over 40 sessions (S270-S309), it fired 18 times with catch-rate 0/18. The `ROUTINE-IDLE close ritual` fired 24 times with catch-rate 0/24.

Both rituals exceeded the 3-session threshold by 8× and 6×.

The user surfaced the gap: "0% product work across 40 sessions; sync-grilling burning tokens with no value."

L-S310-1 was the resulting demotion proposal (BINDING after user directive):

> "DO NOT invoke `scripts/hooks/sync-grilling-call.sh` on 3-session cadence. Authorized triggers only: (a) user ratifies a pending SCOPE+CHARTER bundle producing NEW divergence; (b) charter ratification opens NEW SCOPE-tier signals; (c) Phase boundary entry; (d) user submits NEW user_prompt with SCOPE-tier directive."
>
> "DO NOT write ROUTINE-IDLE close artifacts when entry delta-check returns ZERO new actionable signal AND no PRIORITY became unblocked. Instead emit one-line state ack."

The ritual was not deleted — it was **gated** to fire only on event-driven triggers, not on time-cadence.

### Why Demote, Not Always Promote-or-Retire

Sometimes the right answer is *demote*: the ritual has value in some contexts but not all. Gating it to event triggers preserves value while eliminating busy-work.

---

## 10.8 — The Severity Pipeline as Self-Improvement

The severity pipeline (Phase A: classifier → Phase B: engine → Phase C: enforcer → Phase D: push) is detailed in [Chapter 6 § 6.6](06-hooks.md#66--the-severity-pipeline). But it is also a **self-improvement mechanism**:

- **HIGH** severity items get user attention via `AskUserQuestion`. User's response is *signal* about what matters.
- **MEDIUM** severity items accumulate in weekly digests. The digest reveals patterns over time.
- **Severity dwell-time** (how long an item stays HIGH before resolution) is itself a metric.

Per L-S310-1 root cause: the Q-INT mega-bundle (a 22-question bundle) sat with `askuserquestion_fired: false` for ~20 hours while the loop ran busy-work. The severity pipeline did not exist yet — its absence enabled the failure mode.

After D-058 / S310 ratification, the pipeline ensures HIGH-severity items get escalated within 6 hours and Telegram-pushed for visibility outside the terminal.

### Telegram Push (Phase D)

Setup:
1. Create bot via @BotFather → get token
2. Extract chat_id via getUpdates
3. Set env vars in `.claude/settings.local.json`:
   ```
   STOCKFORGE_TELEGRAM_BOT_TOKEN=<token>
   STOCKFORGE_TELEGRAM_CHAT_ID=<id>
   ```
4. Test: `bash scripts/hooks/telegram-push.sh "CRITICAL test"`

Without creds → silent no-op. Idempotency: SHA-keyed per-hour marker prevents spam.

---

## 10.9 — The Karpathy Outer Loop

The harness's overall self-improvement is structured as a Karpathy autoresearch outer loop:

```
┌──────────────────────────────────────────────────────────────┐
│ INNER LOOP — per session                                     │
│ - Read state                                                 │
│ - Apply rules (constitution, agent-notes, skills)            │
│ - Execute work                                               │
│ - Capture outcome (telemetry, observations, lessons)         │
└──────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────┐
│ MIDDLE LOOP — per N sessions                                 │
│ - promote-rule cycle: cluster + promote candidates           │
│ - lesson-synthesizer: capture missed lessons                 │
│ - Verifier patterns: PCG-* promotion candidates              │
└──────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────┐
│ OUTER LOOP — per phase boundary                              │
│ - intent-vs-impl-diff: catch silent absorption                │
│ - Phase close ritual: archive, consolidate                   │
│ - Constitution amendments: charter-tier ratifications         │
│ - Calibration weight adjustments (sync-tracker weights.yaml) │
└──────────────────────────────────────────────────────────────┘
```

### Per Karpathy

The framing comes from Andrej Karpathy's [autoresearch](https://karpathy.ai/) talks. The key insight: **LLMs are exceptionally good at looping until they meet specific goals**. The outer-loop infrastructure (metric, evaluation, ablation) is what enables this.

The harness applies this to itself:
- Inner loop = session
- Middle loop = `promote-rule` cycle
- Outer loop = phase boundary + constitution amendments

`try-n-approaches` skill ([Chapter 5 § 5.2](05-skills-commands-agents.md#52--skills)) frames every new investigation as a Karpathy outer-loop experiment with a metric function (BLOCKING per L-S12-1).

---

## 10.10 — Best-Practices and Known-Issues Catalogs

Two append-mostly registries that complement `agent-notes.md`:

### `best-practices.md` (BP-*)

Positive patterns confirmed to work. Format:

```markdown
### BP-S<N>-<M>: <name>
**Date**: YYYY-MM-DD
**Context**: <when this BP applies>
**Practice**: <the positive pattern>
**Evidence**: <which sessions confirmed value>
**Severity-of-not-doing**: critical | high | medium | low
**Related**: [[L-S<N>-<M>]] (lesson that promoted to BP)
```

### `known-issues.md` (KI-*)

Quirks / limitations the harness must tolerate. Format:

```markdown
### KI-S<N>-<M>: <name>
**Date**: YYYY-MM-DD
**Context**: <where this surfaces>
**Issue**: <the quirk>
**Workaround**: <how the harness compensates>
**Upstream fix expected**: <when, if known>
**Suppression severity**: <where suppressed; typically HIGH→MEDIUM>
**Related**: [[D-NNN]] (ADR that ratified workaround)
```

Example KI: `KI-S49b-1 — Stop hook silent on Windows quirk` (downgrades HH-1 HIGH→MEDIUM).

### Catalog Lifecycle

- Captured by `lesson-synthesizer` (Stage 2 of self-upgrade)
- Aggregated by `self-awareness-aggregate.sh` (Stop hook)
- Read by main session at SessionStart for context

---

## 10.11 — A Real Promotion: L-S310-2 (Severity Pipeline)

A canonical example of full lifecycle.

### Origin (1st instance — would normally HOLD)

User-surfaced harness gap S310. 7 issues identified:
1. Fragmented severity schemas across Q&A / decision / mistake / notification
2. No BLOCK mechanism
3. 48h-only stale escalation
4. No proactive AskUserQuestion auto-fire
5. No external channel
6. Orphan notification accumulation
7. Fragmented watchdog hooks with no central severity router

### Cluster recognition

These were **7 instances of one class**: harness lacks a unified severity classification + escalation pipeline. Cluster count n=7 > threshold n=3 → PROMOTE-NOW per L-S345-1 doctrine.

### Ratification via AskUserQuestion (S310 4-Q batch)

- Q1: 4-level schema (CRITICAL/HIGH/MEDIUM/LOW) — A=ACCEPT
- Q2: both UserPromptSubmit + PreToolUse block aggression — A=ACCEPT
- Q3: 6h HIGH escalation threshold — A=ACCEPT
- Q4: Telegram skeleton-first — A=ACCEPT

### Implementation (ratification → shipped in same turn)

Per L-S310-2:

- `severity-classifier.sh` (Stop late-chain) — Phase A
- `escalation-engine.sh` (Stop + SessionStart + UserPromptSubmit) — Phase B
- `autonomous-block-enforcer.sh` (UserPromptSubmit FIRST + PreToolUse FIRST) — Phase C
- `telegram-push.sh` (skeleton) — Phase D
- 4 companion firing-tests; 26/26 PASS
- D-058 ADR ratified

### Verification (live run)

Live run detected 3 legitimate HIGH items (D-034 charter v1.1 170h / mistake-log carryover / D-053 notification 18h) + 0 CRITICAL. `urgent.md` auto-populated.

### Why It Worked

The 7-instance cluster justified n=3 threshold-skip. The 4-question AskUserQuestion bundle gave humans 4 distinct decisions with low cognitive load. The shipped pipeline came with firing-tests (Principle 11). The live run produced empirical evidence within hours.

This is the canonical promotion: from user-surfaced gap to ratified + shipped + verified pipeline in a single session.

---

## 10.12 — Where to Read Next

- **The cookbook for adding** a new rule / skill / hook → [Chapter 11 — Cookbook](11-cookbook.md)
- **The 23 anti-patterns** that promoted to constitution → [Chapter 12 — Internals](12-internals.md#anti-patterns)
- **The full agent-notes** → [`agent-workspace/memory/agent-notes.md`](../../../agent-workspace/memory/agent-notes.md)
- **The full mistake-log** → [`agent-workspace/memory/mistake-log.md`](../../../agent-workspace/memory/mistake-log.md)
- **Calibration data** → [`agent-workspace/calibration/`](../../../agent-workspace/calibration/)
