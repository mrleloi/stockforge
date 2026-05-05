# /grill-me — Relentless Plan/Design Interview

> Interrogates user about a plan/design until every decision branch is resolved. Body delegates question-bank substance to the `grill-maximization` skill (multi-batch + AskUserQuestion 4-question max).

## When to Use

- Before starting implementation of non-trivial feature
- When plan feels vague ("we'll figure it out")
- When multiple paths exist and you haven't chosen
- Before `/spec-author` for complex features

## Contrast with `/drill-me`

- `/drill-me` — domain language extraction (DDD focus, builds glossary)
- `/grill-me` — design interrogation (makes implicit decisions explicit)

Both are interactive interviews. Different targets.

## Process

1. **Ask user what's being grilled** — feature idea / architectural decision / spec draft / implementation approach.

2. **Identify decision tree** — scan for stated decisions, implicit decisions (assumed not articulated), open branches ("TBD"), unaddressed edge cases, unplanned failure modes.

3. **Ask structured questions** — ONE at a time, wait for answer, adapt next. Categories (with stockforge tilt): Architecture (BC ownership, failure cascade, source of truth, write/read responsibility) / Interface (edge case returns, invalid input, retry policy, partial results) / Data (primary key, null semantics, soft-delete, timezone) / Failure modes (worst-case blast radius, detection, recovery — manual/auto, stuck states) / Scale (10 concurrent stocks? 100K news/day query latency? rethink threshold) / Testing (happy path, hardest edge, no-live-API approach) / **StockForge-specific** (bear case present per I-S10? any LLM-computed numbers — charter violation per I-S1? source + as_of-date for every claim per I-S2? hallucination blast radius on real-money decision?). Full question bank: `.claude/skills/grill-maximization/SKILL.md` § "Question categories".

4. **Don't accept vague answers** — `"we'll handle it later"` → "handle how? when?"; `"should be fine"` → "what makes you confident?"; `"standard approach"` → "point me to where we've done this before".

5. **Surface tradeoffs** — for each decision: "Going with [A] gets [benefit] but pays [cost] — aware of that?" / "What's the alternative?" / "Who else tried [A]; what happened?"

6. **Catalog decisions** as they emerge — D-N entries with: question asked / options considered / decision / rationale / tradeoff. Decisions deferred → DD-N entries with revisit condition + working assumption. Unanswered → Q-N entries needing external input + action needed.

7. **Done when** — every edge case has decision or explicit deferral; no "we'll see" answers remain unless deferred; tradeoffs surfaced and accepted; user visibly more confident in plan.

8. **Output summary** — Grilled item / duration / Decisions Made (N) / Decisions Deferred (M) / Open Questions (P) / Confidence Level (1-5) / Suggested Next Steps (5: proceed to `/spec-author` or `/master-plan`; 3-4: address top Q-N; 1-2: grill more, different angle) / Artifacts path (`agent-workspace/memory/patterns-discovered/grill-YYYY-MM-DD-[plan].md`).

## Mindset

The griller's job is NOT to suggest answers — it's to surface hidden assumptions and force explicit choices. `"I don't know"` is a valid answer; it just means deferral or external input, not avoidance. Be skeptical. Be thorough. Be kind — this is productive, not adversarial.

## Anti-Patterns

- Asking questions you already know the answer to (waste)
- Accepting vague answers politely (defeats purpose)
- Grilling when user just wants to ship (wrong timing)
- Asking 10 questions at once (overwhelming — use 4-question batches per `grill-maximization` skill)
- Skipping the stockforge-specific question family (finance domain has real stakes)

## Do

- One question, wait, follow up
- Push on vague answers
- Flag when you can't progress further
- End with concrete artifact (decisions list)

## Related

- `grill-maximization` skill — bundling discipline (15-20 questions per touchpoint, max 25); full question bank
- `/drill-me` — paired-purpose for domain language extraction
- `/spec-author` — natural follow-up when grilling concludes with high confidence
- `qa-escalation` skill — file-based Q&A protocol when grilling needs async human input
