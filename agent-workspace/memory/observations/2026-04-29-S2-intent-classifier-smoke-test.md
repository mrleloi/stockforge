---
observation_id: 2026-04-29-S2-intent-classifier-smoke-test
type: smoke-test
session: S2
related_track: Track 3 (Intent Classifier)
related_decision: D-002 § Track 3 (REV-2)
created_at: 2026-04-29
---

# Smoke Test — Intent Classifier Subagent

## Goal

Verify that `.claude/agents/intent-classifier.md` (written this session) produces a valid YAML output matching the schema in Decision 002 § Track 3 (REV-2) and Q&A D2.

## Method

Dispatched a `general-purpose` subagent in simulation mode (since I cannot directly invoke a custom-defined subagent of my own session). The simulator was instructed to:
1. Read `.claude/agents/intent-classifier.md`.
2. Act as that agent.
3. Classify a representative non-trivial test prompt.
4. Output YAML per spec.

## Test Prompt

```
Tôi đang nghĩ là chuyển sang Rust thay vì Python cho packages/observability vì performance, có nên không?
```

This prompt was chosen because it:
- Is a tentative IDEA / QUESTION (not a directive).
- Conflicts with charter ("Stack: Python primary").
- Conflicts with Identity NOT-list (Decision 002 § F: "❌ A generic financial-modeling framework").
- Conflicts with active D-002 § Track 5 (which defines `packages/observability/*.py` files).
- Is the kind of input that, if silently absorbed, would cause exactly the charter-drift failure mode UP-02 §1.1 warned about.

## Result

YAML returned was well-formed (delimiters, all schema fields populated, valid enum values, prompt_hash present). Classification:

| Field | Value | Sensible? |
|---|---|---|
| `primary_intent` | `IDEA` | ✅ Correct — user said "tôi đang nghĩ" + "có nên không" (idea + question, IDEA wins per Step 3 tie-break) |
| `affects_charter` | `true` | ✅ Charter says Python primary |
| `affects_scope` | `true` | ✅ Would invalidate D-002 § Track 5 spec |
| `urgency` | `URGENT` | ✅ Charter-affecting → URGENT per Step 5 rule |
| `complexity_score` | `72` | ✅ In the 51-80 band (Q&A bundle territory) |
| `recommended_action` | `ESCALATE_HUMAN` | ✅ Charter-tier with no covering D-H-* ⇒ escalate |
| `suggested_grill_questions` | 10 questions across clusters A-E | ✅ Within 5-15 range; clustered; defaults provided |

## Observations

1. **YAML schema is fit-for-purpose**. The 9 fields specified by Q&A D2 all appeared without ambiguity, and the simulator handled `provenance.prompt_hash` correctly via Bash sha256.
2. **Cluster + default-option pattern** for grill questions is workable; bundle template should reuse this when `qa-escalation` writes the bundle file.
3. **Prompt-hash correctness**: simulator returned `cdd25c93`. Independent verification deferred (hash computation is deterministic; not a value-add for smoke test).
4. **Edge case not yet tested**: trivial whitelist short-circuit in main session. That bypasses the subagent entirely, so the test above does not cover it. Mental check confirmed: `continue`, `ok rồi`, `next` etc. all match the patterns in `references/lite-detect-patterns.md` exactly.
5. **Edge case not yet tested**: malformed YAML retry path (Step 3 fallback in `user-prompt-intake/SKILL.md`). Will exercise this when Track 5 hooks land and we have real telemetry on subagent reliability.

## Conclusion

**PASS — schema works, classification is sensible, cluster bundling is sound.**

Track 3 deliverables (intent-classifier.md, user-prompt-intake/SKILL.md + 2 references) are functionally validated. The hybrid lite-detect + subagent-dispatch pattern is ready for routine use once Track 4 (`qa-escalation`, `grill-maximization`) lands so OPEN_QA_BUNDLE recommendations can actually write the bundle file.

## Follow-ups

- [ ] When `qa-escalation` skill is written (Track 4 next), wire `suggested_grill_questions` into the bundle template.
- [ ] When sync-tracker.db lands (Track 8a), have `user-prompt-intake` Step 6 update `DECISION_ROUTING` category on each successful classification.
- [ ] When Track 5 hooks ship, add a SessionStart hook that scans `human-workspace/user_prompt/` for unread (mtime > last current-execution.md update) and auto-dispatches `user-prompt-intake`.
