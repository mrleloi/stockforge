---
name: user-prompt-intake
description: Hybrid intent classifier — main session lite-detects trivial prompts, dispatches intent-classifier subagent for complex ones. Use whenever a new user prompt lands (chat or file in human-workspace/user_prompt/) and you need to route the work. Built for full-autonomous loop where every prompt must be classified before action.
allowed-tools: [Read, Glob, Grep, Bash, Agent, Write]
---

# Skill: User Prompt Intake (Hybrid Intent Classification)

## When to Use

Every time **any** of these happen:
1. A new file lands in `human-workspace/user_prompt/YYYYMMDD_NN_*.txt`.
2. A user chat message that could affect scope, decisions, ideas, or charter (i.e. anything beyond a continuation token).
3. SessionStart finds unread prompts (compare file mtime vs last `current-execution.md` update).

**Do not use** for inline tool output, hook messages, or system reminders. Those are not user prompts.

## Why This Skill Exists

Source: `agent-workspace/memory/decisions/002-phase-0-harness-bootstrap-design.md` § Track 3 (REV-2) + Q&A D1 = D (hybrid: main session lite-detect + subagent for complex).

Two failure modes to prevent:
1. **Silently absorbing user prompts** — orch CF-DOGFOOD-2 / UP-02 §1.1: agent never verified, treated charter-conflicting prompts as routine, drifted at charter level.
2. **Burning Opus budget on trivial replies** — every "ok continue" spending 5K context to "interpret" wastes 80% of intake budget.

The hybrid pattern: cheap heuristic on main, sonnet subagent for the rest.

## Procedure

### Step 1 — Lite-detect trivial (main session, ~50 tokens)

If the prompt matches the trivial whitelist exactly (case-insensitive, trimmed):

```
continue, go, next, yes, ok, okay, ok rồi, được, được rồi, xong,
stop, pause, resume, cancel, k, kk, no, không, đúng, đúng rồi,
tiếp, tiếp tục, đi tiếp, tiếp đi
```

Plus structural matches:
- Single-emoji message
- Single-digit number (`1`, `2`, …)
- Empty string / whitespace-only
- Single character

→ Treat as `primary_intent: TRIVIAL`, action `HANDLE_TRIVIAL`. Continue current execution per `current-execution.md`. **Do NOT dispatch subagent.**

If the prompt is short (< 5 words) but not on the whitelist, still dispatch — small ambiguous prompts have caused drift.

### Step 2 — Dispatch intent-classifier (non-trivial)

```
Agent({
  description: "Classify user prompt intent",
  subagent_type: "intent-classifier",
  prompt: <the verbatim prompt OR the path to the user_prompt file>
})
```

Include in your dispatcher prompt:
- The prompt text (or `Read` the file and inline its content).
- Pointer to `agent-workspace/memory/current-execution.md` for active-phase context.
- Pointer to `agent-workspace/memory/decisions/README.md` for decision-history context.

Do NOT pre-classify. Let the subagent do the classification cleanly on fresh context.

### Step 3 — Parse YAML response

The subagent returns a single YAML block. Extract these fields:
- `primary_intent`
- `affects_charter`, `affects_scope`
- `urgency`, `complexity_score`
- `recommended_action`
- `human_intent_summary`
- `suggested_grill_questions`
- `provenance`

If the subagent's YAML is malformed, dispatch ONCE more with explicit "your previous output was not valid YAML, retry" — if it fails again, fall back to `recommended_action: ESCALATE_HUMAN` and post the issue.

### Step 4 — Log the classification

Write `agent-workspace/memory/observations/intent-<UTC-TS>-<prompt-hash>.md` with the YAML + a 1-paragraph dispatcher commentary (your reasoning for whether you'll follow the recommendation).

### Step 5 — Route

Map `recommended_action` → action:

| Recommended | Dispatcher action |
|---|---|
| `HANDLE_TRIVIAL` | Continue current execution per `current-execution.md`. |
| `HANDLE_INLINE` | Execute inline. Log a Decision (level: IMPL) only if cross-cutting. |
| `OPEN_QA_BUNDLE` | Invoke `qa-escalation` skill with `suggested_grill_questions` as seed. |
| `OPEN_DECISION_LOG` | Author `agent-workspace/memory/decisions/D-NNN-<slug>.md` from the canonical template; cite the prompt. |
| `ESCALATE_HUMAN` | Write `human-workspace/notifications/N-<TS>-ALERT-<slug>.md` + open Q&A bundle. Pause work that depends on the answer. |
| `LOG_IDEA_DEFER` | Append to `agent-workspace/memory/ideas-backlog.md` with prompt hash + summary. |

**Override rule**: dispatcher MAY override the recommendation if it has a specific reason. Document the override in the observation log (`override_reason`).

### Step 6 — Update Confidence Score (Track 8a, when online)

If `agent-workspace/memory/sync-tracker/sync-tracker.db` exists:
- Increment the matching category counter (LANGUAGE / DOMAIN_UBIQUITOUS / DESIGN_THINKING / SCOPE / DECISION_ROUTING).
- The hook `scripts/hooks/sync-tracker-update.sh` (Track 5) handles this when wired; until then, manual append to `sync-tracker/_index.md` is fine.

If the DB doesn't exist yet (pre-Track 8a), skip silently.

## Anti-Patterns (don't)

- **Skip Step 1 and dispatch every prompt.** Wasteful; lite-detect catches 60-70% per orch traffic stats.
- **Skip Step 2 and self-classify.** Main session has accumulated bias from current work; classifier subagent's value comes from fresh context.
- **Trust subagent's recommendation blindly.** It's a recommendation, not a directive. Verify against current-execution / charter.
- **Move fast and skip Step 4.** No observation log = no audit trail = drift risk.
- **Open a Q&A bundle for every uncertain prompt.** Use Grill Maximization — 15-20 question bundle, not 5 small drips. Bundle scoping is in `grill-maximization` skill.

## Trivial Whitelist Maintenance

The whitelist in Step 1 will need refinement after first 30 days of real traffic. If the agent observes a recurring trivial pattern that's NOT on the list, propose an addition via Q&A bundle — do NOT silently extend the whitelist.

## See Also

- `references/lite-detect-patterns.md` — full whitelist + examples + edge cases
- `references/dispatch-template.md` — copy-paste dispatcher prompt template
- Subagent: `.claude/agents/intent-classifier.md`
- Skill: `qa-escalation` (the receiving skill for `OPEN_QA_BUNDLE`)
- Skill: `grill-maximization` (bundle composition doctrine)
- Decision: `D-002 § Track 3` (REV-2)
- Source prompt: `human-workspace/user_prompt/20260429_03.txt` § Q3 (hybrid pattern confirmed)
