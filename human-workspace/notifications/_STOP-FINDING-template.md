---
type: STOP-FINDING
session: S<N>
created_at: <ISO8601>
trigger: <brief-id-or-pattern-slug>
severity: <CRITICAL | HIGH | MEDIUM | LOW>
severity_note: ""
charter_tier_surface: <true | false>
requires_human_decision: <true | false>
status: <pending | answered-via-chat | answered-via-AskUserQuestion | resolved-<YYYY-MM-DD>-via-<source> | closed | superseded>
k2a_status: <NOT-FIRED | FIRED-at-S<N> | N/A>
---

# STOP-FINDING: <Title>

## Summary
<2-3 sentences describing what was found and why it blocks.>

## Current state
- <bullet: what exists today>
- <bullet: what was attempted>

## Blocker
<What is blocked and why. Be specific.>

## Decision required
<What the human must decide. Provide lettered options with pros/cons:>

**A)** <option A> — Pro: ... Con: ...
**B)** <option B> — Pro: ... Con: ...

## Resolution
<Filled in when status flips to resolved-*. Who decided what and when.>
