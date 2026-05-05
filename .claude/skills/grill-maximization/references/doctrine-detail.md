# Doctrine Detail — D1 / D7 / D8 + Standard Skeleton

> Companion to `grill-maximization/SKILL.md`. Detail extracted to keep SKILL.md ≤150 LOC.

## D1 — Bundle Size (full table)

| Tier | Count | When |
|---|---|---|
| Mini bundle | 3-5 questions | One discrete decision-point, low ambiguity |
| **Standard bundle** | **15-20 questions** | **Default. Use this unless reason to deviate.** |
| Max bundle | 25 questions | Phase boundary, charter discussion, or multi-track design |
| Split bundle | > 25 → split into 2 sequential | Don't single-bundle past 25; cognitive load too high |

**Default to standard.** Mini bundles are a code smell — usually means you skipped grill-up.

## D7 — Evidence Anchoring (format example)

Every cluster references the source evidence that provoked it. Format inline at the top of each cluster section:

```yaml
clusters:
  - id: A
    name: Performance budget
    evidence:
      - human-workspace/user_prompt/20260429_03.txt §Q5 — "tracking và provenance"
      - agent-workspace/memory/patterns-discovered/SYNTHESIS.md § R1 (token inflation)
    questions: [...]
```

Or in markdown bundle body:

```markdown
## Cluster A — Performance budget

**Evidence:**
- `human-workspace/user_prompt/20260429_03.txt §Q5`
- `agent-workspace/memory/patterns-discovered/SYNTHESIS.md § R1`

### Q1: …
```

## D8 — Confidence Score Categories (taxonomy)

A bundle MUST target ≥ 2 of these 5 categories to be worth the human-touch cost. If only 1, consider deferring or merging with another open bundle.

| Category | Grill type |
|---|---|
| `LANGUAGE` | Terminology — words, idioms, communication conventions |
| `DOMAIN_UBIQUITOUS` | Domain meaning — what does "thesis", "KOL", "credibility-score" mean exactly? |
| `DESIGN_THINKING` | Architectural / pattern — DDD, BC boundaries, hook design, schema |
| `SCOPE` | Phase / charter — what's in/out, NOT-list, identity boundaries |
| `DECISION_ROUTING` | Escalation / classifier accuracy — when to ask vs decide, threshold tuning |

## Standard Bundle Skeleton

```markdown
---
id: 2026-04-29-002-rust-vs-python-observability
topic: Rust vs Python for packages/observability
opened_at: 2026-04-29T09:00:00Z
expected_answer_by: 2026-04-30T09:00:00Z   # +24h NORMAL / +4h URGENT / +72h LOW
priority: URGENT                            # URGENT | NORMAL | LOW
related_decisions: [D-002]
status: pending
sync_categories: [SCOPE, DESIGN_THINKING, LANGUAGE]
provenance:
  triggered_by: agent-workspace/memory/observations/intent-<TS>-<hash>.md
  source_prompt: human-workspace/user_prompt/<file>.txt
  prompt_hash: <sha256[:8]>
defer_cycle: 0
---

# Q&A Bundle — Rust vs Python for packages/observability

## Headline

Pending decision: stack split for observability layer. If unanswered by EOD 2026-04-30,
default = stay Python, log IDEA in backlog. Bundle updates SCOPE + DESIGN_THINKING + LANGUAGE
Confidence Scores.

## Cluster A — Performance budget

**Evidence:**
- `human-workspace/user_prompt/20260429_03.txt §Q5`
- `agent-workspace/memory/patterns-discovered/SYNTHESIS.md § R1`

### Q1: <question>
- A: …
- B: …
- C: …
- D: open answer
- **Default**: A

### Q2: …
[…]

## Cluster B — Charter implications
[…]

## Cluster C — Toolchain readiness
[…]

## Answer Section (human fills below)

> Reply inline using "QN: <option-letter>" or free prose. Skip questions to accept defaults.
> Move file to `human-workspace/q-and-a/answered/` when done.

- Q1: 
- Q2: 
- …

## Notes from human (free text, optional)
```

For a fuller library of skeletons (mini / standard / max), see `bundle-examples.md`.

## Charter-Tier Split Rule (audit finding G1, 2026-04-29)

When a bundle would mix CHARTER-tier (threshold 0.99) + SCOPE-tier (0.90) decisions: **SPLIT into two bundles**. The CHARTER bundle:

- Has ONLY charter-affecting questions.
- Does NOT use safe agent-defaults that auto-resolve via "ok continue" shortcuts.
- Each question requires explicit user-letter pick or open-answer prose.
- Notification ALERT mandatory regardless of NORMAL/URGENT priority.
- Approval chain entry includes `actor: user`, `action: ACCEPTED-CHARTER`, `at: <ISO>`, `via: <bundle-file>`, AND a quoted user phrase from the answered file (verbatim acknowledgment of the charter implication).

This rule was retroactively codified after the S1 Round-3 Q-S5 absorption pattern (Q-S5 "small trusted circle = git-fork single-tenant" was charter-tier but bundled with 4 SCOPE-tier items and accepted via "ok continue" — silent absorption).

Apply this rule from S3 onward. Re-grill outstanding charter-tier items in Track 7 (S5).
