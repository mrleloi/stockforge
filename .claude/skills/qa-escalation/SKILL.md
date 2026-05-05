---
name: qa-escalation
description: File-based Q&A protocol — composes bundle file in human-workspace/q-and-a/pending/, tracks lifecycle (pending → answered → stale → processed), creates URGENT notification when needed. Use when intent classifier recommends OPEN_QA_BUNDLE / ESCALATE_HUMAN, or grill-maximization has a bundle ready to write. Pairs with grill-maximization (composes content) + Track 5 hooks (auto-move stale).
allowed-tools: [Read, Glob, Grep, Write, Bash]
---

# Skill: Q&A Escalation

## When to Use

1. `intent-classifier` returns `recommended_action: OPEN_QA_BUNDLE` or `ESCALATE_HUMAN`.
2. `grill-maximization` has questions clustered + ready to surface.
3. Agent confidence below threshold for a level (CHARTER 0.99 / SCOPE 0.90 / ARCH 0.80).
4. A deferred decision needs reactivation (`defer_cycles > 3`).

**Do not** use for inline clarification ("did you mean X?") — that's chat.

## Channel Routing (BINDING — per UP-06 amend, 2026-04-29)

**`AskUserQuestion` is the ONLY effective input surface. File bundle is pure audit trail.**

- Every question agent NEEDS answered MUST be surfaced via `AskUserQuestion`. No exceptions.
- Limit 1-4 questions per call → bundles >4 questions REQUIRE multi-batch:
  - **Within-turn chain**: fire `AskUserQuestion(4)` → tool returns user's picks → fire next `AskUserQuestion(4)` in same response → repeat until N exhausted.
  - **Across-turn chain**: fire batch 1 → end turn → next turn fire batch 2 (use this when batch needs reflection or different context).
- File `human-workspace/q-and-a/pending/<bundle>.md` is AUDIT only — captures questions + answers + provenance for tracing. NEVER assumed user will edit. Mobile-remote scenario explicitly cannot depend on file edit.
- **NEVER** apply "default after N hours if user didn't answer". That's silent absorption (orch CF-DOGFOOD-2 pattern). If a question is needed → ask via Ask. If not needed → don't include. No middle ground.
- Charter-tier questions: explicit-pick options only (no `(Recommended)` tag without charter-framing in question text + each option must commit user to a concrete branch).
- For questions that become relevant only when a future track activates: queue in `agent-workspace/memory/observations/queued-grill-<topic>.md` with explicit `fire_when:` trigger. Do NOT bundle as "file-only with default".

## Why

Source: D-002 § Track 4 REV-2 + Q&A C2/C3/E1. Prevents orch CF-DOGFOOD-2 (silent absorption of charter-affecting prompts). File-based escalation is visible + auditable.

## File Layout (BINDING)

```
human-workspace/q-and-a/
├── pending/      # Agent writes here. Open bundles awaiting reply.
├── answered/     # Human moves here w/ answers. Agent reads.
└── stale/        # Hook auto-moves bundles past expected_answer_by.
```

Permissions (per `.claude/settings.json` + `human-workspace/CLAUDE.md`):
- `Write(human-workspace/q-and-a/pending/**)` — ALLOWED
- `Write(human-workspace/q-and-a/{answered,stale}/**)` — DENIED (only human / hook moves files in)

## Filename Convention

`<YYYY-MM-DD>-<NNN>-<topic-slug>.md`
- `NNN` = zero-padded sequence within the day
- `topic-slug` = lowercase ASCII + hyphens, ≤ 60 chars

Example: `2026-04-29-001-phase-0-clusters.md`.

## YAML Frontmatter Schema (BINDING)

```yaml
---
id: <YYYY-MM-DD>-<NNN>-<slug>          # matches filename
topic: "<short topic, ≤80 chars>"
opened_at: <ISO-8601 UTC>
expected_answer_by: <ISO-8601 UTC>     # +24h NORMAL / +4h URGENT / +72h LOW
priority: URGENT | NORMAL | LOW
related_decisions: [D-NNN, ...]
status: pending                         # pending | answered | timeout | processed
sync_categories:                        # ≥2 to be worth the human-touch cost
  - SCOPE | DESIGN_THINKING | LANGUAGE | DOMAIN_UBIQUITOUS | DECISION_ROUTING
provenance:
  triggered_by: <observation file or session log path>
  source_prompt: <user_prompt path | inline-chat>
  prompt_hash: <sha256[:8]>
defer_cycle: 0                          # increment on reopen (R7 mitigation)
---
```

Bundle without ALL fields → INVALID; rejected by Track 5 verifier hook (when wired). Until then, agent self-validates.

## Procedure (compact)

1. **Compose** — receive headline + clusters + 15-20 Q&As + sync_categories from `grill-maximization`. Validate count (15-20 std; 3-5 mini; ≤25 max; split if more).
2. **Filename + frontmatter** — see `references/procedures.md` § Step 2 for bash one-liners.
3. **Write file** (audit trail) — body = headline + clusters + Answer Section. Template in `references/sample-bundle.md`. File is NOT the input surface — see § Channel Routing.
4. **Notification** (URGENT only) — also write `human-workspace/notifications/N-<TS>-ALERT-<slug>.md`. Template in `references/procedures.md` § Step 4.
5. **Surface via `AskUserQuestion` (ONLY input surface)** — fire questions in batches of ≤4. For >4 questions: chain multiple `AskUserQuestion` calls within same turn (or across turns). Charter-tier questions get NO safe-default options. NEVER stop at "4 critical via Ask, rest via file-default" — every needed answer must come via Ask.
6. **Update related decision(s)** — append `approval_chain: actor: agent / action: AWAITING_QA_BUNDLE / via: <bundle>` for each `D-NNN`. Increment `defer_cycles` if amending an ACCEPTED decision.
7. **Log** — append to `agent-workspace/memory/sessions/<latest>.md`: `Opened Q&A bundle: <file> (<priority>; <N>Q; <categories>)`.
8. **Wait or continue** — when user answers via `AskUserQuestion`, immediately update bundle file in-place with answers + provenance. Continue non-dependent work; block only decisions waiting on this bundle.

## Reading Answered Bundles

When SessionStart detects files in `answered/`:
- Parse `Q<N>:` lines for human replies; missing → apply documented default.
- Append `approval_chain: actor: user / action: ANSWERED` to related decisions.
- Update Confidence Score (`sync-tracker.db`, Track 8a) per `sync_categories`.
- Set frontmatter `status: processed`. Write observation `qa-answered-<bundle-id>.md`.

Detail + edge cases: `references/lifecycle-state-machine.md`.

## Stale Bundle Handling

Track 5 SessionStart hook auto-moves `pending/*` past `expected_answer_by` → `stale/`. When agent finds stale bundles:
1. Apply documented defaults for each question.
2. `defer_cycles += 1` on related decisions.
3. If `defer_cycle > 3` → escalate via URGENT notification (R7 mitigation).

## Schema Migration Note

S1 bundle `human-workspace/q-and-a/answered/2026-04-29-001-phase0-clusters.md` predates this schema lock-in (S2). Its frontmatter (`priority: high`, custom fields `mode`/`question_count`) is **grandfathered noncompliant**. Do NOT retroactively edit (it's in `answered/` which is Write-deny). Treat as legacy; new bundles MUST follow this schema.

## Anti-Patterns (don't)

- **Edit-in-place in pending/** — supersede via new bundle with `supersedes: <old>`.
- **Multiple URGENT in same hour** — bundle them (Grill Maximization).
- **Forget `defer_cycle`** — R7 mitigation depends on this field.
- **Auto-move pending → answered** — agent never moves; only humans (or stale hook).
- **Skip URGENT notification** — file alone may not be visible.
- **Repeat questions across bundles** — check `pending/` first; expand existing rather than open second.

## See Also

- `grill-maximization` — composes content
- `user-prompt-intake` — produces trigger via `intent-classifier`
- `references/procedures.md` — full bash/templates for Steps 2-4
- `references/lifecycle-state-machine.md` — 4-state machine + edge cases
- `references/sample-bundle.md` — copy-paste skeleton
- D-002 § Track 4 REV-2 + Q&A C2/C3/E1
- `human-workspace/CLAUDE.md` — binding contract (agent NEVER writes user_prompt/decisions/)
