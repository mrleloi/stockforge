---
proposal_id: drift-signals-amendment-DR-INTENT
type: charter-amendment-draft
status: PROPOSED
created_at: 2026-05-01
session: S35 (META_LOOP_RECOVERY)
target_file: agent-workspace/constitution/drift-signals.md
target_section: HIGH Severity (insert after DR-S2)
source_evidence:
  - agent-workspace/memory/post-mortems/2026-05-01-self-awareness-promotion-skip.md § "Drift-check scope blind to human-intent layer"
  - human-workspace/user_prompt/20260429_06.txt (UP-06: "biến sync thành ưu tiên hàng đầu")
  - CLAUDE.md SYNTHESIS § 6 anti-pattern AP-5
  - 8 user_prompts existed since project start; never re-read at phase boundary across 15 sessions S20-S34
ratification_required: SCOPE-tier (charter amendment) per Q-B2 doctrine — explicit user pick required
---

# Proposal — Add DR-INTENT to drift-signals.md

## Why

`/drift-check` skill currently runs DR1-DR12 — all technical signals (LOC, framework imports, claim citations, cross-BC, LLM-math, etc.). Zero coverage on human-intent layer.

Empirical evidence (S35 audit 2026-05-01):
- 8 user_prompts in `human-workspace/user_prompt/` (UP-01..UP-08)
- 15 sessions S20-S34 — agent never re-read all 8 at any phase boundary
- Q&A pending bundle `2026-04-29-004-up06-track-5.5-amendment.md` stale 3+ days without sweep
- AP-5 (charter-coherence defer overriding USER-CRITICAL) materialized as 4 dead meta-loops

Without a deterministic intent-layer drift signal, agent silently drifts from user direction — exactly the failure mode `human-workspace/CLAUDE.md` § Reading Priority point 1 was designed to prevent ("All `user_prompt/*.txt` — every prompt, not just most recent").

## Proposed Charter Insertion

Add after `### DR-S2: Thesis output without bear case` in `agent-workspace/constitution/drift-signals.md` (HIGH section):

```markdown
### DR-INTENT: Active trajectory drifts from human-stated intent
**What**: `agent-workspace/memory/current-execution.md` § Active Focus Track + Goals does not reference / addresses every directive in `human-workspace/user_prompt/*.txt`.
**Why**: AP-5 (CLAUDE.md SYNTHESIS § 6 — "Charter-coherence defer overriding user-CRITICAL"). Technical drift signals DR1-DR12 cover code; DR-INTENT covers human-intent layer. Surfaced from S35 post-mortem 2026-05-01: 8 user_prompts existed, none re-read at phase boundary across 15 sessions S20-S34.
**Check** (deterministic):
\`\`\`bash
# 1. List all user_prompts
ls human-workspace/user_prompt/*.txt 2>/dev/null

# 2. Extract directive keywords from each (Vietnamese + English imperative phrases)
for f in human-workspace/user_prompt/*.txt; do
  echo "=== $f ==="
  grep -nE 'phải|cần|ưu tiên|luôn |hard rule|must |never |always |silent' "$f"
done

# 3. Check Q&A pending bundles for stale (>24h)
find human-workspace/q-and-a/pending/ -name "*.md" -mtime +1 2>/dev/null

# 4. Cross-check current-execution.md mentions each UP-NN ID
for n in 01 02 03 04 05 06 07 08; do
  grep -q "UP-$n" agent-workspace/memory/current-execution.md \
    || echo "WARN: UP-$n not referenced in current-execution.md"
done
\`\`\`

**Check** (semantic, optional): dispatch `intent-vs-impl-diff` agent (already exists in `.claude/agents/`) with the user_prompt set + current-execution.md + active session-plan; agent returns soft-drift list with verbatim citations.

**Fix**: At every phase boundary AND every 5 sessions, re-read all user_prompts; for any directive not addressed in current trajectory:
  (a) Update plan to address, OR
  (b) Write decision file documenting deferral with re-trigger condition, OR
  (c) Escalate via AskUserQuestion.

**Severity**: HIGH — intent-layer drift is the highest-cost drift (silently invalidates entire trajectory).
**Trigger frequency**: Every phase boundary (mandatory); every 5 sessions (recommended); every Q&A pending sweep (auto via stale-mover hook).
```

## Practical Application BEFORE Charter Promotion

This proposal is binding-effective immediately via skill update — `.claude/commands/drift-check.md` extended to invoke DR-INTENT alongside DR1-DR12. Charter promotion (this proposal → constitution file) requires SCOPE-tier user-gate per Q-B2.

## Skill Extension (already shipped S35 D5)

`.claude/commands/drift-check.md` now includes DR-INTENT step:
1. Run `bash scripts/hooks/drift-signals-D1-D9.sh` (technical)
2. Run intent-check sequence above (deterministic Vietnamese + English keyword extraction)
3. Optionally dispatch `intent-vs-impl-diff` agent for semantic depth
4. Aggregate report under `agent-workspace/quality-reports/drift-reports/<TS>.md`

## Risk

- False positives: user_prompt may be obsolete or superseded; check decisions/ for supersession ADRs.
- Vietnamese keyword grep may miss synonyms; semantic agent fills gap.
- Non-blocking via skill — won't fail CI; report-only signal.

## Promotion Path

1. **Now (S35)**: Skill `.claude/commands/drift-check.md` updated to call DR-INTENT (effective immediately).
2. **Phase 2 close (~S43)**: User SCOPE-tier review of this proposal alongside other 9 proposals batched in `promote-rule-S35.md` observation; promote to constitution if validated.
3. **Phase 3+**: Add as deterministic Stop-hook check (auto-fire every session-end).

## Re-trigger Condition

If 3 sessions pass without DR-INTENT firing despite a fresh user_prompt landing → escalate to user as evidence skill is being skipped.
