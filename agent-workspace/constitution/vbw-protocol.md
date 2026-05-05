# VBW Protocol — Verify-Before-Write

> **Source**: Distilled from measured failure analysis in prior projects.
> **Baseline before VBW**: 11.1% hallucination rate on methods/signatures.
> **After VBW adoption**: 0%.

## The Core Problem

LLMs tend to write code from **memory/convention** rather than from **verified source**.

When agent "knows" a common pattern (DDD conventions, CRUD methods, common APIs), the brain auto-completes from convention without cross-referencing actual implementation.

Observed failure modes:
- Writing methods that don't exist: `enable_kill_switch()` (agent invented from "kill switch" mention)
- Wrong argument counts: `create(4 args)` when actual is `create(6-7 args)`
- Method name from convention: `clear_domain_events` vs actual `clear_events`
- Import paths guessed from pattern

**Result**: Code looks right, doesn't match reality, breaks silently or at runtime.

---

## The Protocol

Four checkpoints. Applied always. Cannot skip.

### Checkpoint 1: PRE-SPEC

Before writing any specification:

```
□ READ the ACTUAL source code — not from memory
□ LIST all methods of the relevant entity — from code, not assumption
□ VERIFY factory method signature — exact param count and types
□ CHECK if feature already exists — grep before assuming "missing"
□ MARK spec items as CURRENT (exists in code) vs PROPOSED (to implement)
```

**Example violation** (don't do this):
```
Task: "Write spec for Instrument kill switch"
Agent: *writes spec describing enable_kill_switch() / disable_kill_switch()*
Reality: Those methods don't exist. Actual method is toggle_kill_switch().
```

**Correct application**:
```
Task: "Write spec for Instrument kill switch"
Agent actions:
1. grep -r "kill_switch" packages/ --include="*.py"
2. Open actual Instrument entity file
3. List actual methods: toggle_kill_switch(), is_kill_switch_active()
4. Note: no enable/disable separately — it's a toggle
5. Write spec matching actual methods
6. If proposing new methods, clearly mark PROPOSED
```

### Checkpoint 2: PRE-TEST

Before writing any test:

```
□ VERIFY every method call exists — check type definitions
□ VERIFY factory signature — exact params from reading create() source
□ VERIFY import paths — grep for actual file location
□ VERIFY base class methods — read entity/aggregate base, not assume
□ TEST one file first — type check before writing more
```

**Example violation**:
```
Agent writes 3 test files in batch, all call clear_domain_events().
Reality: Method is clear_events() in base class.
Result: All 3 files fail mypy. Waste ~10K tokens to fix.
```

**Correct application**:
```
Before writing tests:
1. Open entity base class (packages/domain/shared/entity.py)
2. List actual methods: get_events(), clear_events(), add_domain_event()
3. Write first test file
4. Type check: mypy --strict path/to/test_file.py
5. Only when green, write next test file
```

### Checkpoint 3: MID-IMPLEMENT (Every 5 Steps)

During implementation session:

```
□ Cross-reference against spec — still aligned?
□ Check state of plan — still on track?
□ Review recent edits for convention-derived assumptions
□ Re-read task description (5 minutes of re-read saves hours of wrong direction)
```

**Red flags that trigger mid-implement check**:
- Wrote 3+ files in a row without running tests
- Made assumption about API not verified from code
- Feel "pretty sure" about something not confirmed
- In doubt about file path or method name

### Checkpoint 4: PRE-COMMIT

Before committing any change:

```
□ All claims in code match actual imports — grep to verify
□ All tests describe actual behavior — re-read
□ Any "obvious" method exists? — grep to verify
□ Run mypy --strict — do types actually check?
□ Run relevant tests — do they actually pass?
□ Re-read diff — does every changed line trace to task?
```

---

## Tools for Verification

### grep

```bash
# Does this method exist?
grep -r "method_name" packages/ --include="*.py"

# Does this import path work?
ls -la packages/domain/path/to/file.py

# Is this entity used elsewhere?
grep -rn "SomeEntity" packages/ --include="*.py"
```

### Type check

```bash
# Check types on entire domain package
mypy --strict packages/domain/

# Check specific file
mypy --strict packages/domain/path/to/file.py
```

### Read the actual source

```
- Open the file
- Read the class definition
- Note actual method signatures (including __post_init__ for dataclasses)
- Don't skim — actually read
```

---

## When VBW Feels Like Overkill

The protocol is overkill for:
- Trivial one-liner fixes
- Typo corrections
- Comment updates
- Obvious renames

But even here, the **spirit** applies: don't assume, verify.

The protocol is **essential** for:
- Writing new tests
- Writing new specs
- Modifying code you didn't write
- Crossing bounded context boundaries
- Anything touching shared types
- Anything involving cross-cutting changes

---

## Training the Habit

### First week
Apply ALL checkpoints explicitly. Write them out. Check them off.

### Second week
Checkpoints become intuitive. Still apply, but faster.

### Month 2+
VBW becomes default behavior. You notice immediately when skipping it.

### Anti-pattern to avoid
"I've done this 100 times, I know the pattern" — this is exactly when you'll write wrong code.
Every new context has its own details. Verify.

---

## Measurement

To know if VBW is working:

- **Before VBW**: X hallucination errors per 100 LOC
- **After VBW**: should approach 0

Track via:
- Grep for broken imports in recent commits
- Count "attribute does not exist" / "unexpected keyword argument" errors in session logs
- Note in `agent-notes.md` when hallucination caught before commit

---

## Related

- `drift-signals.md` — runtime detection of hallucination patterns
- `karpathy-principles.md` — P1 (Think Before Coding) complements VBW
- `.claude/commands/vbw-check.md` — explicit command to run protocol
