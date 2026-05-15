---
id: D-060-commit-policy-agent-may-commit
title: Agent may git commit; agent must not git push
date: 2026-05-15
status: ACCEPTED
level: SCOPE

author:
  - "user"
  - "Claude Opus 4.7"

source_evidence:
  - path: chat (2026-05-15, project-owner directive — S321)
    quote: "you can commit, save in hard rule, agent can commit, just cannot push. fix. and continue run autonomous mode"

intent_classification:
  primary_intent: DECISION
  affects_charter: false
  affects_scope: true
  urgency: NORMAL
  complexity_score: 20

options_considered:
  - id: A
    summary: "Agent MAY git commit; MUST NOT git push (push is human-only)"
    pros:
      - "unblocks plan 015 Batch E commit-boundary work without a human-action gate"
      - "agent can checkpoint progress with real commits; matches the commit-disciplined project ethos"
    cons:
      - "agent could create incoherent commit history if undisciplined"
  - id: B
    summary: "Keep the prior rule — agent MUST NOT commit, stage only"
    pros:
      - "maximally conservative"
    cons:
      - "user explicitly overrode it"
      - "left plan 015 Batch E hard-blocked on a human commit boundary"

chosen: A
chosen_rationale: |
  Project-owner explicit directive. The prior "agent MUST NOT git commit" CLAUDE.md hard rule was a
  Day-1 conservatism choice that by S320 had become a concrete blocker: plan 015's Batch E (the final
  6 bash-hook-lint violations) sits in 4 working-tree-dirty hooks + 1 untracked file, and plan 015's
  own Mid-Flight Decision noted the agent "cannot itself create the commit boundary" because of the
  no-commit rule. The owner narrowed the authority boundary precisely: commit is allowed, push is not
  — push to remote stays the one human-only action. The deterministic-gates rule and the
  destructive-command-guard remain in force; only the blanket no-commit prohibition is lifted.

approval_chain:
  - actor: user
    action: PROPOSED
    at: 2026-05-15
    via: chat directive (S321)
  - actor: user
    action: ACCEPTED
    at: 2026-05-15
    via: same chat directive ("save in hard rule ... fix")

verified_by:
  - mechanism: manual
    at: 2026-05-15
    result: PASS

affects:
  charter: false
  spec_files: []
  code_paths: []
  config_files:
    - .claude/settings.json
  other_decisions: []

depends_on: []
supersedes: null
superseded_by: null

defer_cycles: 0
re_attempt_prereq: |
  N/A

tags: ["harness", "permissions", "git", "S321"]
---

# Decision 060 — Agent may git commit; agent must not git push

## Context

The original StockForge `CLAUDE.md` hard rule was: "Agents MUST NOT `git commit` unless user
explicitly requests. Stage changes, report, let user decide." This was a Day-1 conservatism choice.
By S320 it had become a concrete blocker: plan 015's Batch E (the final 6 `bash-hook-lint`
violations) sits in 4 working-tree-dirty hooks + 1 untracked file, and plan 015's own Mid-Flight
Decision noted the agent "cannot itself create the boundary" because of the no-commit rule —
forcing a human-action gate on routine harness remediation.

## Decision

Agent MAY `git commit`. Agent MUST NOT `git push` (push to remote is human-only).

### What this means concretely

- `.claude/settings.json` deny-list: `Bash(git commit:*)` removed; `Bash(git push:*)` retained.
- `.claude/settings.json` allow-list: `Bash(git commit:*)` added alongside the other git commands.
- `CLAUDE.md` § Hard Rules (general) and `agent-workspace/CLAUDE.md` Contract Rule 6 updated.
- What does NOT change: the deterministic-gates rule (mypy/pytest/ruff must pass before commit)
  still gates every commit; `destructive-command-guard.sh` (R1) still blocks `git reset --hard`,
  `git checkout -- .`, `git clean`, `git stash`, etc.; `PROJECT_CHARTER.md` and
  `agent-workspace/constitution/**` immutability is unchanged; `git push` stays denied.

## Why (Reasons)

1. Project-owner explicit directive — "user prompt overrides ALL defaults" (CLAUDE.md hard rule).
2. Unblocks plan 015 Batch E without a human-action gate.
3. Keeping `git push` human-only preserves the one irreversible, shared-state action as a human checkpoint.

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Agent creates incoherent commit history | Med | Commit only at coherent checkpoints; the messy S320 working tree (20 staged S319 files + pre-existing dirty hooks + a pre-existing unattributed `settings.json` change) gets a deliberate untangle, not a rushed bulk commit |
| Agent commits non-merge-eligible work | Med | Tier-1 deterministic gates + sandwich-verifier verdicts gate "merge-eligible" before commit (e.g. the S319 staged diff is NOT to be committed until the S321 remediation fixes IMPORTANT-1/2 and re-verifies) |
| Accidental push | Low | `Bash(git push:*)` retained in `.claude/settings.json` deny-list (deterministic block) |

## Open Questions

None — directive was explicit and unambiguous.

## Acceptance Record

- **2026-05-15**: PROPOSED + ACCEPTED by user via chat directive ("you can commit ... save in hard rule ... fix"). Applied same turn (S321): settings.json + CLAUDE.md + agent-workspace/CLAUDE.md.
