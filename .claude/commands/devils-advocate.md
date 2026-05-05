# /devils-advocate — Adversarial Critique

> Invoke devils-advocate subagent to find flaws in current approach.

## When to Use

- Before committing to a major design decision
- When a plan feels "too good" — suspicious of blind spots
- After extended work — fresh eyes on what's been built
- Before surfacing thesis or analysis output to user
- When investment thesis needs stress-testing
- When hypothesis needs scrutiny before acting on it

## Input

`$ARGUMENTS` — target to critique:
- Spec path (e.g., `specs/tier2-feature/001-validate-investment-thesis.md`)
- Code module (e.g., `packages/domain/analysis/`)
- Architectural decision (paste or reference)
- Investment thesis (stated in prompt or path to thesis-log entry)

## Process

### 1. Gather Target Context

Load the target thoroughly:
- If spec: read full spec including Part A, B, C
- If code: read module + related tests
- If decision: gather rationale, alternatives considered
- If thesis: gather all evidence, claims, sources

### 2. Invoke `devils-advocate` Subagent

Spawn the subagent (`.claude/agents/devils-advocate.md`) with:
- Target content (paths or pasted text)
- Relevant constitution / invariants for grounding
- Budget: 15–25K tokens

The agent's persona, multi-dimensional critique process (Hidden Assumptions / Edge Cases / Failure Modes / Alternatives / Historical Precedent / Second-Order Effects / StockForge-Specific), and full output template are defined in `.claude/agents/devils-advocate.md` — do NOT duplicate them here.

### 3. Present Critique to User

Don't forward raw subagent output. Add a thin summary on top:

```markdown
# Devil's Advocate Found [N] Concerns

## Summary
[2-3 sentence honest summary]

## Must Address (HIGH severity)
- [Issue 1]
- [Issue 2]

## Should Consider (MEDIUM)
- [...]

## Might Be OK (LOW, noted for awareness)
- [...]

[Full critique from subagent]

## Your Call
- Address HIGH issues?
- Accept and proceed (document rationale)?
- Reconsider the approach?
```

### 4. Handle Response

User may:
- Accept critique and adjust → iterate
- Accept critique but proceed anyway → document rationale in `agent-workspace/memory/agent-notes.md`
- Reject critique → document why in same file

Critique is **input**, not mandate. User decides.

## When to Override Critique

Sometimes devils-advocate finds theoretical problems that don't matter in practice:
- Edge case at scale we'll never hit
- Failure mode mitigated by other mechanism
- "What if" concern not worth addressing preemptively

Document overrides in `agent-workspace/memory/agent-notes.md`:

```markdown
## YYYY-MM-DD — Devils Advocate Override — [target]

**Concern raised**: [what]
**Why overridden**: [reason]
**Conditions to revisit**: [what would change our mind]
```

This creates institutional memory — if the concern becomes real later, we know we saw it coming.

## Anti-Patterns

**Don't**:
- Skip this for "obvious" decisions (those are often the most wrong)
- Use this as a second opinion when you want validation (it's designed to disagree)
- Dismiss critique as "not understanding our context" (could be true, could be denial)
- Run this and ignore output (waste of tokens)
- Skip the StockForge-specific checks (finance + LLM = real money risk)
- Re-author analysis dimensions or output format here — they live in the agent file

**Do**:
- Run on major decisions and thesis outputs
- Take critique seriously even when uncomfortable
- Document override rationale when proceeding anyway
- Use for adversarial rehearsal before acting on investment decisions

## See Also

- `.claude/agents/devils-advocate.md` — full critique process + output template
- `.claude/agents/sandwich-verifier.md` — narrower verifier scoped to implementation
- `agent-workspace/memory/agent-notes.md` — override log
