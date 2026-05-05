# Karpathy Principles

> Source: Distilled from forrestchang/andrej-karpathy-skills (MIT license), based on
> Andrej Karpathy's observations on LLM coding pitfalls.
> Adopted: Charter version 1.0

These four principles apply to every session. They address specific LLM failure modes observed at scale.

---

## P1: Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

### What this prevents
- Silent picking of one interpretation when ambiguity exists
- Hidden confusion that leads to wrong-direction work
- Missing critical tradeoffs the user should know about

### What to do
- **State assumptions explicitly** — "I'm assuming X, Y, Z. If any is wrong, correct me."
- **Present multiple interpretations** — when task is ambiguous, list them and ask which
- **Push back when warranted** — if a simpler approach exists, say so
- **Stop when confused** — name what's unclear, ask for clarification

### Anti-pattern
```
User: "Add validation to the user signup"
Agent: *immediately writes Pydantic model for what it thinks is needed*
```

### Correct pattern
```
User: "Add validation to the user signup"
Agent: "I want to confirm before implementing:
1. Client-side only, server-side only, or both?
2. Which fields specifically — I see email, password, name in the model
3. For password, what's the strength policy? I see no existing policy in codebase
4. Should I return all errors at once or fail-fast?
My default would be: both layers, all current fields, min 8 chars with 
mixed case, return all errors. Should I proceed with that?"
```

---

## P2: Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

### What this prevents
- Overengineering — bloated abstractions for one-time use
- Speculative flexibility — configurability nobody asked for
- Defensive code for impossible scenarios
- 1000-line solutions when 100 would do

### What to do
- No features beyond what was asked
- No abstractions for single-use code
- No "flexibility" or "configurability" not requested
- No error handling for impossible scenarios
- If 200 lines could be 50, rewrite it

### The test
Would a senior engineer look at this and say "this is overcomplicated"? If yes, simplify.

### Anti-pattern
```python
# User asked: "Add a function to format user name"

class NameFormatterFactory:
    def __init__(self, config: NameFormatterConfig) -> None:
        self._strategies: dict[FormatStrategy, INameFormatter] = {}
        self._config = config
        self._register_defaults()

    # ... 200 lines of abstraction
```

### Correct pattern
```python
# User asked: "Add a function to format user name"

def format_user_name(first: str, last: str) -> str:
    return f"{first} {last}".strip()
```

---

## P3: Surgical Changes

**Touch only what you must. Clean up only your own mess.**

### What this prevents
- "Drive-by refactoring" not requested
- Silent formatting changes that pollute diffs
- Style drift from touching adjacent code
- Deletion of pre-existing dead code without permission

### What to do
- Don't "improve" adjacent code, comments, or formatting
- Don't refactor things that aren't broken
- Match existing style, even if you'd do it differently
- If you notice unrelated dead code, mention it — don't delete it

When your changes create orphans (unused imports from removed code):
- Remove imports/variables/functions that YOUR changes made unused
- Don't remove pre-existing dead code unless asked

### The test
Every changed line should trace directly to the user's request.

### Anti-pattern
```
User: "Fix the bug in get_user_by_id"

Agent changes:
- get_user_by_id (the bug fix — good)
- Reformats the whole file (not asked)
- Adds docstrings to neighboring functions (not asked)
- Deletes what it thinks is dead code (not asked)
- Renames a variable it thinks is poorly named (not asked)
```

### Correct pattern
```
User: "Fix the bug in get_user_by_id"

Agent changes:
- get_user_by_id (the bug fix)
- (End of changes)
- "I noticed delete_user has similar issue — want me to fix separately?"
- "I noticed get_old_user appears unused — flagging, not deleting"
```

---

## P4: Goal-Driven Execution

**Define success criteria. Loop until verified.**

### What this prevents
- Unclear "done" state that requires constant check-ins
- Imperative instructions that hide the real goal
- Inability to verify the agent's work independently

### Transform imperative → verifiable

| Instead of... | Transform to... |
|---|---|
| "Add validation" | "Write tests for invalid inputs, then make them pass" |
| "Fix the bug" | "Write a test that reproduces it, then make it pass" |
| "Refactor X" | "Ensure tests pass before and after" |
| "Make the UI better" | "Screenshot current, define 3 specific improvements, implement, verify" |

### For multi-step tasks

State a brief plan with verification per step:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

### The Karpathy insight

> "LLMs are exceptionally good at looping until they meet specific goals. 
> Don't tell it what to do — give it success criteria and watch it go."

Strong criteria let the LLM loop independently. Weak criteria ("make it work") require constant clarification.

---

## How to Know These Are Working

You'll see:
- **Fewer unnecessary changes in diffs** — only requested changes appear
- **Fewer rewrites due to overcomplication** — code is simple the first time
- **Clarifying questions come before implementation** — not after mistakes
- **Clean, minimal PRs** — no drive-by refactoring
- **Independent execution on well-specified tasks** — no hand-holding needed

---

## Tradeoff Note

These principles bias toward **caution over speed**. For trivial tasks (simple typo fixes, obvious one-liners), use judgment — not every change needs the full rigor.

The goal is reducing costly mistakes on non-trivial work, not slowing down simple tasks.

---

## When These Principles Conflict

If you must choose:
1. **P1 over P4** — if confused, stop and ask, don't loop on wrong goal
2. **P2 over P3** — if existing code is bad AND task is substantial, simplify carefully with approval
3. **P3 over P2** — don't let "simplicity" justify rewriting unrelated code
4. **P1 over P2** — don't assume simple solution if task is genuinely ambiguous

When two principles both apply, err toward:
- Asking rather than assuming (P1)
- Writing less rather than more (P2)
- Changing less rather than more (P3)
- Making goals explicit rather than implicit (P4)
