# Chapter 2 — Mental Model

> **Diataxis quadrant**: Explanation (understanding-oriented)
> **Reading time**: ~20 minutes
> **Prerequisites**: Quickstart (Chapter 1) or any prior exposure to Claude Code

This chapter introduces the **five big ideas** that the harness is built around. Every artifact in the system — every hook, every constitution rule, every agent persona — exists to serve one or more of these ideas.

If you understand the five, the 200+ moving parts become readable.

---

## Idea 1 — The User Is a Director, Claude Code Is the Team

Before the harness existed, "using an LLM to code" looked like: human types prompt, LLM types code, human edits and pastes the result, repeat. This pattern caps out fast. Past 4-5 hours of work, the human becomes the bottleneck reviewing every line.

The harness encodes a different model:

> **The user writes specs, sets direction, makes architectural calls, ratifies decisions, and reviews outcomes.
> Claude Code writes code, tests, routine specs, dispatches subagents, runs verification, and reports.
> The two meet at well-defined ratification points, not at every line.**

This decomposition is not metaphor. It is enforced by file permissions ([`.claude/settings.json`](../../../.claude/settings.json) allow/deny), by session protocol ([`session-start` ↔ `session-end`](08-lifecycle.md#session-protocol)), by [boundaries](04-constitution.md#boundaries) (`B-1: Never modify PROJECT_CHARTER.md`), and by the [Q&A bundle](08-lifecycle.md#qa-bundle) lifecycle.

When the user types a goal, the harness assumes the user wants a director's report — a brief, a plan, a confirmation prompt — not a thousand lines of unverified code dumped into the repo.

### Consequences

- The agent **asks before doing** when the answer changes scope or commits charter-tier resources. ([AskUserQuestion is for SCOPE/CHARTER decisions only](04-constitution.md#autonomous-protocol).)
- The agent **proposes, does not impose**. New rules go to `agent-workspace/proposals/` first; ratification moves them to `agent-workspace/constitution/`.
- The agent **dispatches itself** when work needs fresh context. The user sees a notification, not a wall of tokens.

### Why This Matters

The single biggest cause of failed AI-assisted projects is **drift between intent and implementation**. The director/team split, enforced by harness mechanisms, is the structural answer.

---

## Idea 2 — The Sandwich Pattern Beats Single-Agent Past 200K Tokens

In **Session 4 of this project** (the post-mortem is in `agent-workspace/memory/post-mortems/`), a single agent tried to plan, implement, and verify a multi-track feature in one session. The session crossed 200,000 tokens and collapsed: the plan drifted from the implementation, the implementation drifted from the spec, and the verifier (same agent, same context) signed off on broken work.

The failure rate at that scale, measured empirically, was about **20% catastrophic**.

The fix was the **sandwich pattern**:

```
┌─────────────────────────────────────────────────────────────────┐
│ SESSION 1  —  ARCHITECT  (50-80K Sonnet / 150-230K Opus)        │
│  sandwich-architect subagent reads spec + constitution +         │
│  existing code → writes detailed plan to session-plans/pending/  │
│  NEVER writes production code.                                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ SESSION 2  —  DEV  (100-150K)                                    │
│  sandwich-dev subagent reads plan + relevant files → writes      │
│  code + tests per plan. NEVER re-plans.                          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ SESSION 3  —  VERIFIER  (30-60K Sonnet / 80-180K Opus)           │
│  sandwich-verifier subagent reads plan + diff → reports verdict  │
│  (PASS / PASS-WITH-CONCERNS / FAIL). FRESH CONTEXT — has NEVER   │
│  seen the architect's or dev's reasoning. Adversarial by design. │
└─────────────────────────────────────────────────────────────────┘
```

The three agents share *artifacts* (plan, code, ADRs) but **not context**. The verifier sees the same evidence the architect saw but reconstructs the conclusion independently. Disagreement between architect's intent and verifier's reading is itself the bug signal.

### Why Three Sessions and Not One

The decomposition closes three failure modes simultaneously:

1. **Plan/impl drift**: architect cannot drift mid-stream because architect's session ended before implementation began.
2. **Echo-chamber verification**: verifier cannot rationalize the architect's mistakes because verifier never read them.
3. **Context exhaustion**: each session stays well within budget because the work it owns is bounded.

### Where the Pattern Lives in Code

- Architect persona: [`.claude/agents/sandwich-architect.md`](../../../.claude/agents/sandwich-architect.md)
- Dev persona: [`.claude/agents/sandwich-dev.md`](../../../.claude/agents/sandwich-dev.md)
- Verifier persona: [`.claude/agents/sandwich-verifier.md`](../../../.claude/agents/sandwich-verifier.md)
- Plan template: [`agent-workspace/session-plans/pending/`](../../../agent-workspace/session-plans/pending/) (read any recent plan, e.g., `045-S395-plan-vhm-thesis.md`)

### Where It Breaks

The pattern fails when:

- Dispatch briefs cite paths that do not exist (architect VBW catches this — see [STEP 2.X](05-skills-commands-agents.md#sandwich-architect-mechanics)).
- Verifier is asked to write findings that contradict its no-Write persona (the [PCG-S401-4](12-internals.md#pcg-s401-4) cluster).
- Main session re-plans during dev (forbidden by [Hard Rule "Never mix PLAN and IMPL in same session"](04-constitution.md#hard-rules)).

These edge cases are why the pattern needs the surrounding harness, not just the three personas.

---

## Idea 3 — The Constitution Is Immutable; Everything Else Evolves

The harness draws a hard line between **immutable** and **mutable** artifacts:

| Layer | Mutability | Modification protocol |
|---|---|---|
| `PROJECT_CHARTER.md` | Immutable for ~3 months | Explicit human revision + version bump + 48h cool-down |
| `agent-workspace/constitution/*.md` | Immutable to agent | Human only, denied by `.claude/settings.json` |
| Skills, commands, agents | Mutable | Agent may edit; LOC ceilings enforced by hooks |
| Plans, sessions, observations | Append-only | Never delete; supersede via status field |
| Production code (`packages/`, `apps/`) | Mutable | Agent edits per plan; sandwich pattern applies |
| Memory routing (`current-execution.md`) | Mutable | Agent updates on session boundaries |
| Configuration (`.claude/settings.json`) | Mutable | Agent may edit allow/deny/hooks |

### Why This Hierarchy

Without it, the agent could silently change its own rules. Drift would compound. After 50 sessions, the system would be incoherent.

With it:

- The charter sets vision and principles. It changes when *the project* changes, not when the agent has a clever idea.
- The constitution encodes ratified decisions. It changes through an explicit ADR process with cool-down windows.
- Skills, commands, agents, hooks evolve freely — but always in service of the constitution.
- Memory accumulates state. Old state is archived, never destroyed.

### The Charter Principles (Verbatim)

The 11 principles from [`PROJECT_CHARTER.md`](../../../PROJECT_CHARTER.md):

1. **Evidence grounding** — every claim, every number traceable to source + as-of date.
2. **Structured output over narrative** — multi-criteria assessment, never single "buy/sell" score.
3. **Adversarial by design** — bear + bull + critic + quant + behavior + manager perspectives.
4. **Proprietary data moat** — every news ingested, every KOL recommendation tracked.
5. **Pattern transfer + local adaptation** — global setups + Vietnam-specific overlays.
6. **Human-in-loop is the product** — augment thinking, never replace it.
7. **Dogfood mandatory** — if I don't use it weekly for real decisions, it gets killed.
8. **Calibration over confidence** — system tracks its own accuracy, never claims confidence it hasn't earned.
9. **No LLM math** — LLM never generates numbers. All calculations through deterministic code.
10. **Position sizing & risk management are deterministic** — code-enforced.
11. **Harness must self-verify firing, not self-attest existence** — every hook ships with a firing-test; `harness-health-self-scan.sh` verifies signal-set HH-1 through HH-12 on every UserPromptSubmit + SessionStart.

Principles 9, 10, 11 are the **harness load-bearers**. Every hook and constitution file ultimately serves at least one of them.

---

## Idea 4 — The Harness Must Self-Verify Firing, Not Self-Attest Existence

This is **Charter Principle 11**, and it deserves its own section because it is non-obvious and load-bearing.

### The Bug Class

In Phase 2.5 of the project, the harness was audited and declared "8 of 8 tracks green". Fourteen sessions later, three empirical failures surfaced — all detected by user push, not by the harness's own self-check:

1. **`autonomous-stop-watchdog.sh`** was wired in the Stop chain. The smoke test passed. But logs showed **zero `Stop session=` entries across 10 turns**. The hook script existed; it never fired.
2. **`promote-rule` backlog** accumulated 6+ sessions of unprocessed agent-notes entries. Why? The trigger was Stop-hook-dependent (see #1).
3. **Auto-detect orphans**: ~20 agent-notes entries tagged `Auto-detect: yes` had no companion hook script shipped. The tag was a promise; the implementation never landed.

In each case, the system was structurally complete (file present, smoke test green, ritual closure ticked) but **empirically broken** (hook silent in production logs).

### The Principle

> *"Ritual closure of a track (file existence + smoke-test exit 0) is forbidden until empirical-firing evidence (production log entry / artifact / telemetry row from real session activity) is captured."*
> — Charter Principle 11

### How It Is Enforced

- Every hook ships with a **companion firing-test** at `scripts/hooks/firing-tests/<hook-name>-fire-test.sh`. Naming is mandatory.
- The continuous hook [`harness-health-self-scan.sh`](06-hooks.md#harness-health-self-scan) runs **12 signals (HH-1 through HH-12)** on every `UserPromptSubmit` and `SessionStart`, checking whether expected hooks have actually emitted in the `.session-hooks.log` within thresholds.
- [`harness-health-protocol.md`](../../../agent-workspace/constitution/harness-health-protocol.md) codifies the signals at constitution tier.
- Drift between *expected fires* and *observed fires* is itself a harness drift signal that escalates through the severity pipeline.

### What This Means For You

When you add a hook, the work is not done when the hook script exists. The work is done when the firing-test passes AND the production log shows the hook firing in real-session conditions. Anything less is what Principle 11 forbids.

This principle is the reason there are 115 firing-tests for 118 hooks (the 3 missing are tracked at HH-10).

---

## Idea 5 — Calibration Over Confidence

The fifth idea is the deepest. It is borrowed from the [Bridgewater principles](https://www.principles.com/) and the [Karpathy autoresearch](https://karpathy.ai/) framing.

> **A confidence claim is only valid if it traces to a historical hit rate. Otherwise, the claim is hallucinated belief, not evidence.**

The harness operationalizes this in several places:

| Mechanism | What it tracks | Where it lives |
|---|---|---|
| `personal-risk-profile.md` | User's risk tolerance + historical bias | `agent-workspace/memory/` |
| `calibration/` | Per-signal hit rate, KOL accuracy | `agent-workspace/calibration/` |
| `sync-tracker/state.tsv` | Per-category confidence score (Q-RCA-1) | `agent-workspace/memory/sync-tracker/` |
| `dispatch.jsonl` | Per-agent-dispatch outcome distribution | `agent-workspace/memory/` |
| `mistake-log.md` | Failure catalog with root cause + prevention rule | `agent-workspace/memory/` |
| `agent-notes.md` | Rules earned through real experience | `agent-workspace/memory/` |
| `attestation-log.tsv` | Sandwich-verifier verdicts (PASS / PASS-WITH-CONCERNS / FAIL) | `agent-workspace/memory/` |

### The Boundary

[Boundary B-12](04-constitution.md#boundaries) says:

> *"Never claim confidence without calibration data. Do not emit phrases like 'high confidence' or 'strong signal' in any thesis, alert, or output unless the claim traces to `calibration/` data with `n_samples`, `hit_rate`, `lookback_period`."*

This boundary, like Principle 11, is structural. The agent cannot say "I am highly confident" by default. It can only say "I am highly confident, with hit rate X over Y samples in window Z" — and the X/Y/Z must come from real data, not LLM judgment.

### Why It Matters for the Harness

The harness is itself a series of bets ("this hook will catch class X of failure"). The promote-rule lifecycle ([Chapter 10](10-self-improvement.md)) is calibration-over-confidence applied to the harness itself: every rule must have a catch-rate, and rules with zero catch-rate over 3+ sessions are demoted or retired.

---

## How the Five Ideas Compose

The five ideas are not independent. They reinforce each other:

```
        Director/Team
              ↓
       (split work between
        spec-author and
        code-writer)
              ↓
        Sandwich Pattern
              ↓
       (each session bounded;
        verifier independent)
              ↓
       Constitution Immutable
              ↓
       (ratified decisions
        do not silently drift)
              ↓
       Principle 11 (Self-Verify)
              ↓
       (verify rules ACTUALLY
        fire in production)
              ↓
       Calibration Over Confidence
              ↓
       (each rule's effectiveness
        is measured, not believed)
```

Remove any one, and the others weaken:

- Without the **director/team split**, the agent does everything and the human reviews everything — bottleneck restored.
- Without the **sandwich pattern**, single-agent sessions past 200K collapse — drift restored.
- Without **constitution immutability**, the agent silently rewrites its own rules — coherence lost.
- Without **Principle 11**, the harness becomes a stage set: scripts exist, nothing fires — invisible regression.
- Without **calibration**, every rule lives forever regardless of value — ritual bloat.

The five together form a coherent system. Each chapter that follows is a deeper look at how that coherence is engineered.

---

## What This Chapter Did Not Cover

- **What the harness physically looks like** — file layout, layer composition. → [Chapter 3](03-architecture.md)
- **The specific immutable rules** — every constitution file. → [Chapter 4](04-constitution.md)
- **How sessions actually flow** — session types, plan lifecycle, sandwich choreography. → [Chapter 8](08-lifecycle.md)
- **How drift is detected** — DR1-DR12, HH-1-HH-12. → [Chapter 9](09-quality-system.md)
- **How rules are promoted** — `agent-notes.md` → skill → hook → constitution. → [Chapter 10](10-self-improvement.md)

If you wanted a *system map*, continue to [Chapter 3](03-architecture.md). If you wanted the *rule book*, jump to [Chapter 4](04-constitution.md).
