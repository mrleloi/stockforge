# Sample Bundle — Copy-Paste Skeleton

> Companion to `qa-escalation/SKILL.md`. Use as starter when writing a new bundle.
> Replace ALL `<placeholder>` tokens before writing. Do NOT keep the angle brackets.

```markdown
---
id: <YYYY-MM-DD>-<NNN>-<slug>
topic: "<short topic, ≤80 chars>"
opened_at: <ISO-8601 UTC, e.g. 2026-04-29T11:30:00Z>
expected_answer_by: <ISO-8601 UTC>
priority: <URGENT | NORMAL | LOW>
related_decisions:
  - D-<NNN>
status: pending
sync_categories:
  - <SCOPE | DESIGN_THINKING | LANGUAGE | DOMAIN_UBIQUITOUS | DECISION_ROUTING>
provenance:
  triggered_by: <agent-workspace/memory/observations/intent-<TS>-<hash>.md | session log path>
  source_prompt: <human-workspace/user_prompt/...txt | inline-chat>
  prompt_hash: <sha256[:8]>
defer_cycle: 0
---

# Q&A Bundle — <topic>

## Headline

<2-3 line summary: what decision hinges on this bundle, what defaults apply if unanswered, which Confidence Score categories update.>

## Cluster A — <cluster name>

**Evidence:**
- <path:line or section>
- <path:line or section>

### Q1: <question text>
- A: <option text>
- B: <option text>
- C: <option text>
- D: open answer
- **Default**: <letter>

### Q2: <question text>
- A: …
- B: …
- C: …
- D: open answer
- **Default**: <letter>

…

## Cluster B — <cluster name>

**Evidence:** …

### Q<N>: …

…

## Answer Section (human fills below)

> Reply inline as "QN: <option-letter>" or free prose. Skip questions to accept defaults.
> When done, MOVE this file to `human-workspace/q-and-a/answered/`.
> File-move is the trigger; do not edit-in-place to confirm.

- Q1: 
- Q2: 
- Q3: 
- Q4: 
- Q5: 
- Q6: 
- Q7: 
- Q8: 
- Q9: 
- Q10: 
- Q11: 
- Q12: 
- Q13: 
- Q14: 
- Q15: 

## Notes from human (free text, optional)

<empty — human can add free text>
```

## Notes

- The Answer Section enumerates up to 15 questions by default; if your bundle has more (max 25), extend.
- The "MOVE this file" instruction is the contract trigger — file-system event = state transition.
- The default-letter convention lets human skim-answer ("ok, defaults except Q3=B, Q7=open: <reason>").
- Do NOT include any `<placeholder>` in the final written bundle.
