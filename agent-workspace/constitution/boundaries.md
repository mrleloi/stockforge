# Boundaries

> Things the agent cannot do without explicit human approval.

## Hard Boundaries (never cross without explicit approval)

### B-1: Never modify `PROJECT_CHARTER.md`
Charter is immutable for ~3 months. Changes require explicit human revision with version bump.

### B-2: Never modify `agent-workspace/constitution/*`
Constitution files are immutable to agent. Human-only edits. Changes have architectural impact.

### B-3: Never write to `obsidian-vault/raw/`
Raw source materials are immutable. Agent READS only. All agent writes go to `wiki/`.

### B-4: Never commit without explicit user request
Stage changes (`git add`), report what's done, let user decide commit.
User prompt overrides: if user says "commit", then do. Default = stage only.

### B-5: Never perform destructive operations without same-session approval
Includes: DELETE FROM, DROP TABLE, `rm -rf`, force push, branch deletion, data truncation.
Even in dev/local environments — ask first.

### B-6: Never deploy to production without approval
Staging deploys allowed with plan adherence. Production requires explicit human authorization.

### B-7: Never disable tests or lints to make CI pass
If tests fail, fix the code or the test. Don't silence. Don't comment out.
If lint conflicts with requirement, discuss before disabling rule.

### B-8: Never install new dependencies without review
`pyproject.toml` / `requirements*.txt` changes reviewed before install. New deps have real cost (size, security, maintenance).

### B-9: Never hardcode secrets, credentials, API keys
Use env vars + `.env.local` (gitignored). If you see a secret in code, flag immediately.

### B-10: Never override safety mechanisms
Budget caps, rate limits, retry limits exist for reasons. Don't bypass "because it's annoying".

### B-11: Never override position sizing or risk rules
`RiskRule` and `PortfolioConfig` parameters (max position size, sector concentration limits, stop loss thresholds) are set by human. Agent cannot modify these values or route around them in code — even during backtesting. See `invariants.md` I-S1.

### B-12: Never claim confidence without calibration data
Do not emit phrases like "high confidence" or "strong signal" in any thesis, alert, or output unless the claim traces to `calibration/` data with `n_samples`, `hit_rate`, `lookback_period`. Qualitative LLM belief ≠ calibrated confidence. See `invariants.md` I-S7.

### B-13: Never modify past thesis-log entries
Files already committed in `agent-workspace/memory/thesis-log/` are append-only historical records. Do not edit past entries. Add a new post-mortem entry if updating outcome data.

### B-14: Never modify `eval-sets/baseline-results/`
Baseline eval results are reference points for regression detection. Any change invalidates comparisons. Human-only modification.

---

## Soft Boundaries (require good reason to cross, document in decision log)

### SB-1: Architectural decisions beyond established patterns
If a problem doesn't fit existing patterns → escalate for architectural decision.
Don't invent new patterns silently.

### SB-2: API contract changes
Breaking changes to HTTP/event/RPC contracts → escalate.
Non-breaking additions (new optional field) OK with documentation.

### SB-3: Security-sensitive changes
Auth logic, permission checks, token handling, input sanitization → human review.

### SB-4: Cross-BC contract changes
Changes to `packages/contracts/` affect multiple BCs. Careful review.

### SB-5: Business rule changes
Changes that alter how users experience the product → human decides strategically.

### SB-6: Schema migrations (destructive)
Drop column, drop table, rename column with data impact → human review.
Additive migrations (new columns, new tables) OK with review.

### SB-7: Spec changes that affect downstream
If spec change invalidates existing tests or triggers cascade → escalate.

### SB-8: New data provider integration
Adding a new paid data source (FiinPro tier upgrade, TCBS API, SSI API) has cost and ToS implications. Review before integrating.

---

## Escalation Format

When boundary hit:

```
BOUNDARY ESCALATION

Category: [Hard / Soft]
Boundary: [B-N or SB-N]

Context: [what I was trying to do]
Trigger: [what crossed the boundary]
Attempted alternative: [if tried]

Proposed options:
1. [Option A with tradeoff]
2. [Option B with tradeoff]
3. [Option C with tradeoff]

Recommendation: [preferred option with rationale]

Awaiting human decision.
```

---

## What Agent CAN Do Freely

To avoid over-cautious paralysis, agent can freely:

- Write code in `apps/` and `packages/` following specs
- Write tests
- Update documentation in `docs/`
- Update `agent-workspace/memory/sessions/` (session logs)
- Update `agent-workspace/memory/project.md` (with care)
- Update `agent-workspace/memory/current-execution.md`
- Append to `agent-workspace/memory/agent-notes.md` (learned rules)
- Create new files in appropriate locations per conventions
- Run tests, linters, type checkers (`pytest`, `mypy --strict`, `ruff`)
- Use git to check status, diff, log (read ops)
- Use git to stage changes (`git add`)
- Read any file in project
- Ask questions when unclear
- Suggest improvements (don't implement unilaterally)
- Write new entries to `agent-workspace/memory/thesis-log/` (new files only, never edit past)

---

## User Override

**User prompt overrides ALL defaults and boundaries.**

If user explicitly says:
- "Commit this" → commit (despite B-4 default)
- "Skip the tests" → skip (despite quality gates)
- "Just do X quickly" → do X with reduced rigor

User is in charge. Defaults protect against slippage when user is ambiguous. Explicit direction wins.

---

## Boundary Violations — Consequences

First violation: warning, document in `agent-notes.md`, reinforce training
Repeated: stronger constraint (add to drift signals)
Systematic: escalate to charter revision

The goal is not to punish but to identify patterns where boundaries are unclear or insufficient.
