---
name: grill-maximization
description: Doctrine for bundling Q&A questions to the human at maximum density per turn (15-20 target, max 25), so each human-in-the-loop touchpoint is information-rich. Use when composing a Q&A bundle for human-workspace/q-and-a/pending/, or when deciding whether to ask one question or wait and bundle. Built on the principle that human-in-the-loop time is the scarcest resource in autonomous coding.
allowed-tools: [Read, Glob, Grep, Write]
---

# Skill: Grill Maximization

## When to Use

1. `intent-classifier` returns `recommended_action: OPEN_QA_BUNDLE` / `ESCALATE_HUMAN` with `suggested_grill_questions ≥ 5`.
2. Agent confidence below threshold (CHARTER 0.99 / SCOPE 0.90 / ARCH 0.80).
3. Multiple downstream decisions converge on a single human-input dependency — bundle them.
4. Pre-flight before phase boundary or multi-track plan — grill once, deeply.

**Do not** drip 1-2 questions every few minutes. That is the anti-pattern this skill prevents.

## Why

UP-03 §Q5: "phải luôn cố gắng grill, q&a human trong một lần nhiều nhất có thể, để cố gắng đo được confident score về độ sync giữa human và agent."
D-002 § Q&A C1 = B: target 15-20 / max 25 / split if more.

Compounding effects:
1. **Sync-rate maximization** — denser bundles produce more Confidence Score (Track 8a) signal per touch.
2. **Reduced human cognitive load** — 1× full-context bundle beats 5× partial drips.
3. **Audit trail richness** — bundles preserve the full reasoning chain.

## Doctrine (8 rules)

- **D1 — Bundle Size** — Mini 3-5 / **Standard 15-20** (default) / Max 25 / Split if >25. Detail + examples in `references/doctrine-detail.md`.
- **D2 — Cluster Discipline** — group by topic (`A`, `B`, `C`...). 3-7 questions per cluster, 3-5 clusters per standard bundle. No clustering = checklist, not grill.
- **D3 — Option Defaults** — every Q has 3-4 options + `D: open answer` + safe agent-default (what agent picks if user defers). Lets human skim-answer ("ok defaults except Q3=B").
- **D4 — Question Quality** — each Q must (a) be answerable in ≤1 paragraph, (b) commit to a clear branch per answer, (c) provide options/scope (not bare yes/no), (d) tie to source_evidence/affects_charter/affects_scope/risk. Failing all four = filler; cut.
- **D5 — Bundle Headline** — 2-3 lines stating: which decision(s) hinge on this; what defaults if ignored; which Confidence Score categories update. Without it, human can't triage which bundle to answer first.
- **D6 — Grill Up, Don't Grill Down** — when in doubt: ASK if it could change the decision branch, ASK if it reveals user-preference applicable elsewhere; DON'T ASK if purely confirmatory. Better to over-grill 5 min than under-grill 3 sessions.
- **D7 — Evidence Anchoring** — every cluster references the source evidence (file:line / section). Without evidence, questions feel arbitrary; human distrusts and defers. Format example in `references/doctrine-detail.md`.
- **D8 — Confidence Score Hooks** — bundle MUST tag ≥2 of 5 categories (`LANGUAGE / DOMAIN_UBIQUITOUS / DESIGN_THINKING / SCOPE / DECISION_ROUTING`). 1 category alone = not worth human-touch cost; defer or merge.

## Procedure

1. Collect candidate Qs from `intent-classifier.suggested_grill_questions` + your additions.
2. Cluster (D2). 3-7 / cluster, 3-5 clusters / standard bundle.
3. Write headline (D5).
4. For each Q add options + safe-default (D3) + evidence anchor (D7).
5. Cut filler per D4 quality bar.
6. Validate count 15-25 (split if >25).
7. Tag Confidence Score categories (D8); ≥2 required.
8. Hand off to `qa-escalation` skill, which writes the file.

## Anti-Patterns (don't)

- **Drip mode**: 2-3 Qs every 30 minutes. Catastrophic for human focus + Confidence Score (each mini-touch is too noisy for sync signal).
- **Filler padding**: scaling to 20 with confirmatory/trivial Qs to hit target. Better 12 sharp than 20 dull.
- **Yes/no without options**: forces open prose for every reply; slow + inconsistent.
- **No evidence anchor**: questions feel arbitrary; human defers indefinitely.
- **Single-cluster sprawl**: 20 Qs in 1 cluster = checklist, not structured grill. Re-cluster.
- **No `expected_answer_by`**: implies "whenever" → never gets answered. Always set deadline.

## Charter-Tier Bundling Caveat (S2 audit finding G1)

When a bundle mixes CHARTER-tier (threshold 0.99) and SCOPE-tier (0.90) items: **split**. Charter-tier items must NOT ride a single "ok defaults" shortcut alongside scope-tier items. Each charter-tier item gets its own explicit confirmation question (no safe agent-default for `D: open answer`-only fields). Otherwise charter scope is silently absorbed — exactly the orch CF-DOGFOOD-2 pattern UP-02 §1.1 warned about.

## No-Silent-Default Rule (UP-06 amend, 2026-04-29)

If a question is NEEDED for agent to proceed → MUST be surfaced via `AskUserQuestion` (multi-batch as needed). NEVER use file bundle as "user might answer here" with default-after-24h fallback. Mobile-remote scenario means user often cannot edit file at all.

For questions agent thinks "would be nice to ask but not blocking now" → DO NOT include in current bundle. Instead queue in `agent-workspace/memory/observations/queued-grill-<topic>.md` with `fire_when: <track-or-condition>` trigger. The relevant future session re-grills via Ask when condition activates.

Result: every question in a Q&A bundle is one user MUST answer via Ask before agent continues that branch. Bundle question count = AskUserQuestion call count × 4 (rounded up). No "padding" with file-only-deferred questions.

## Multi-Batch Composition (L-S15-1, S15 PLAN evidence)

When a bundle exceeds AskUserQuestion's 4-question hard limit, split into multiple sequential calls within the SAME session turn. Pack densely: prefer **4+3+2** (9 Qs across 3 calls) over 4+4+1 — the 1-Q tail wastes context overhead vs grouping 2 sharper Qs.

**Pattern (S15 PLAN closed 9 queued-grill items via 3 batches)**: Batch 1 (4 governance) + Batch 2 (3 autonomous-protocol inputs) + Batch 3 (2 drift signal mechanics).

**Rule**: minimum 3 Qs per batch when splitting; only the last batch may carry 1-2 if total count forces it. Total bundle target still D1 standard (15-20).

**Why**: each AskUserQuestion call has setup overhead (system reminder + options serialization + user comprehension cost). Larger batches amortize; below 3, overhead dominates.

## Standard Bundle Skeleton

See `references/doctrine-detail.md` § Standard Bundle Skeleton + `references/bundle-examples.md` for 3 worked examples (mini, standard, max).

## See Also

- `qa-escalation` — writes the bundle from this skeleton; tracks lifecycle.
- `user-prompt-intake` — produces input list of `suggested_grill_questions`.
- `references/doctrine-detail.md` — D1 size table / D7 evidence format / D8 category taxonomy / standard skeleton.
- `references/bundle-examples.md` — 3 worked examples.
- D-002 § Track 4 REV-2; UP-03 §Q5.
