# /session-verify — Mid-Session Alignment Check

> Lightweight check to verify current work still aligns with session brief and invariants.

## When to Use

- Every 30 minutes during long sessions
- After completing a major subtask
- When feeling uncertain about direction
- Before starting a significantly different task within same session

## Steps

### 1. Re-read Session Brief

Find the session brief output from `/session-start` earlier.
Re-read the original goal and success criteria.

### 2. Check Alignment

Ask:
- Is current work still aligned with stated goal?
- Have I drifted into related but different territory?
- Am I solving the right problem?

### 3. Check Constitution Compliance

Quick scan against:
- `invariants.md` — any invariant being violated?
- `boundaries.md` — crossing any boundary without approval?
- `karpathy-principles.md` — following P1-P4?
- Stock-specific: Is THESIS session touching code? Is IMPL session making investment claims?

### 4. Check Budget

Run equivalent of `/budget-check`:
- Current context consumption estimate
- Remaining budget for session type
- Projection: can I finish planned work?

### 5. Check VBW Adherence

Have I applied VBW Protocol for recent work?
- Pre-spec checkpoint applied before writing specs?
- Pre-test checkpoint before writing tests?
- Read actual source rather than memory?

### 6. Output Status Report

```markdown
# Session Verify — [time]

## Goal Alignment
[ALIGNED | DRIFT DETECTED | SIGNIFICANT DRIFT]
Original goal: [from session brief]
Current work: [what's actually happening now]
Delta: [any deviation and why]

## Constitution Check
- Invariants: [OK | violations: list]
- Boundaries: [OK | crossed: list]
- Karpathy principles: [OK | concerns: list]
- Stock-specific (I-S1 no LLM math): [OK | at risk]
- Stock-specific (I-S3 bear case): [OK | missing]

## Budget Status
- Estimated used: X K of Y K target
- Pace: [on track | ahead | behind]
- Projection: [can finish | should split | should stop]

## VBW Adherence
- Recent work verified against source: [yes | partially | no]

## Recommendation
[CONTINUE | ADJUST COURSE | STOP AND REGROUP]

[If adjustment needed, specific suggestions]
```

### 7. Wait for User Decision

If drift detected or recommendation is not CONTINUE, pause for user input.

---

## What Counts as Drift

**Acceptable variance**:
- Needed to fix a small bug discovered en route
- Read an extra file to understand context
- Had to update a test because of a spec clarification

**Real drift (flag it)**:
- Working on a different feature than planned
- Refactoring beyond what task requires (P3 violation)
- Adding speculative features (P2 violation)
- Solving a different problem than stated
- THESIS session writing code (session type mismatch)
- IMPL session making investment claims (domain mismatch)

---

## Quick Mode

If time is tight, abbreviated version:

```
Quick verify:
- Goal: [original] → Still pursuing? [Y/N]
- Budget: ~X K used → On track? [Y/N]
- Any invariant violations detected? [Y/N]
- LLM math snuck in anywhere? [Y/N]

Status: [OK | ADJUST]
```

Use in rapid iteration, full version at major checkpoints.
