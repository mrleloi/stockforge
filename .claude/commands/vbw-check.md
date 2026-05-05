# /vbw-check — Apply Verify-Before-Write Protocol

> Explicit invocation of VBW protocol for current task. Body delegates checkpoint definitions to `agent-workspace/constitution/vbw-protocol.md` (canonical).

## When to Use

- Before writing any spec / test / new code
- Before commit
- When uncertain about existing code structure
- When following convention but haven't verified

## Input

`$ARGUMENTS`: `spec` / `test` / `code` / `commit` (which checkpoint). If no arg → ask user.

## Process

1. **Identify target** — read user's current task; determine what's about to be written.

2. **Load protocol** — read `agent-workspace/constitution/vbw-protocol.md` for full checkpoint definitions.

3. **Execute checkpoint** per matrix below.

4. **Output checklist status** with each item PASS/FAIL. Fail any → report specifically what's missing.

5. **Block if not ready** — don't proceed; report specifics; suggest fix; wait for fix or user override.

## Checkpoint Coverage Matrix

| Checkpoint | Key verifications |
|---|---|
| **spec** | Read ACTUAL source for entities mentioned; list real methods (not from memory); verify factory/constructor signatures from code; grep to check feature already exists; mark items CURRENT vs PROPOSED; all glossary terms exist; no LLM-math in B.3 pseudocode (per I-S1) |
| **test** | Every method I'm about to call exists (with file:line); factory/classmethod signatures verified; import paths verified by file-existence check; base class methods read from source; ONE test file first then run mypy + pytest before more |
| **code** | Spec loaded; architecture layer identified (domain / application / infrastructure / interfaces); BC identified (one of 9); existing patterns scanned (am I reinventing?); ports/Protocols verified; relevant invariants listed (esp. I-S1 no LLM math); drift signals to avoid (DR1 domain framework imports, DR6 `Any` types); domain uses dataclasses only — no Pydantic |
| **commit** | All imports in changed files exist; all method calls resolve; pytest passes locally; `mypy --strict` clean; `ruff check` clean; `/drift-check high` clean; every changed line traces to task (P3); no speculative additions (P2); no print/debug; no TODOs without owner+date; no LLM math; no Pydantic in domain. **Agent does NOT auto-commit per CLAUDE.md hard rule** — user explicitly approves |

Full per-checkpoint template (with verbose tickbox forms): `agent-workspace/constitution/vbw-protocol.md`.

## When VBW Feels Like Overkill

For trivial tasks (typo fixes, comment updates), the spirit applies but full ceremony may not.

**Quick mode** allowed when: change < 5 LOC, same-file, clear intent, no method calls or new imports introduced.

**Full protocol required** for: new specs / new tests / new features / cross-BC changes / anything involving shared types.

## Integration with Other Commands

- Run before any major code generation
- Pair with `/session-verify` for ongoing alignment
- Required implicitly by `/spec-author` and major subagents (sandwich-architect, sandwich-dev)

## Anti-Patterns

- Treating VBW as bureaucracy ("I just need to ship") — VBW exists because writing-from-memory is the top failure mode (Session 4 catastrophic mode)
- Running VBW but ignoring failed checks
- Skipping `commit` checkpoint because tests passed (drift-check is separate)

## Do

- Run before writing
- Surface every fail item explicitly to user
- Use Quick mode honestly — only for genuinely trivial changes
- Treat user override as a deliberate decision, log it

## Related

- `agent-workspace/constitution/vbw-protocol.md` — canonical checkpoint definitions
- `/session-verify` — mid-session alignment partner
- `/drift-check` — invoked at commit checkpoint
- `agent-workspace/constitution/invariants.md` — I-S1 no-LLM-math + I-S2 source+as_of (referenced in checkpoints)
