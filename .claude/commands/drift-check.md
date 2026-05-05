# /drift-check — Run Drift Signals DR1-DR12

> Scan codebase for architectural decay using numbered drift signals. Body delegates execution to the deterministic hook + the `drift-detector` agent (semantic signals).

## When to Use

- End of each session (recommended)
- Before PR merge (required)
- When investigating architectural issues
- Periodically (weekly minimum)

## Input

`$ARGUMENTS` — optional:

- No arg → run all signals
- `high` → run HIGH severity only
- `DR<N>` → run specific signal (e.g., `/drift-check DR1`)

## Process

1. **Load definitions** — read `agent-workspace/constitution/drift-signals.md` for current signal definitions, severity, and remediation guidance. Also read draft proposal `agent-workspace/proposals/drift-signals-amendment-DR-INTENT.md` for DR-INTENT (charter-promotion pending).

2. **Run deterministic signals (DR1-DR9)** — invoke `bash scripts/hooks/drift-signals-D1-D9.sh`. The script handles all regex/grep/sql signals (LOC ceilings, framework imports, citation completeness, hardcoded prompts, claim metadata, `Any` types, cross-BC imports, thesis-without-verifier, learning-data path leaks). Output emits to drift-logs and stdout in the report schema below.

3. **Run semantic signals (DR7 UL drift, DR12 anti-patterns)** — these need LLM inspection. Dispatch the `drift-detector` agent (fresh context, run_in_background) with current artifact set. Agent returns observations file under `agent-workspace/memory/observations/`.

4. **Spec-existence check (DR10)** — extract `SPEC-YYYY-MM-DD-NNN` references via `grep -rhoE` and verify each lives under `specs/`. Report missing.

5. **Stale-handoff check (DR11)** — compare `mtime` of `agent-workspace/memory/project.md` + `current-execution.md` vs latest session log under `agent-workspace/memory/sessions/`. Project.md older than latest session = likely stale.

6. **Intent-layer check (DR-INTENT) — HIGH** — see proposal `agent-workspace/proposals/drift-signals-amendment-DR-INTENT.md`:
   - List all `human-workspace/user_prompt/*.txt`.
   - For each UP-NN: confirm referenced in `agent-workspace/memory/current-execution.md` Active Focus Track or any active session-plan or recent decision ADR.
   - Extract Vietnamese + English imperative directives via `grep -nE 'phải|cần|ưu tiên|luôn |hard rule|must |never |always |silent'` per file.
   - Check `human-workspace/q-and-a/pending/*.md` for entries with `mtime > 24h` (stale).
   - Optionally dispatch `intent-vs-impl-diff` agent for semantic depth.
   - Soft-flag any directive not addressed in current trajectory; hard-flag if a USER-CRITICAL item has been silently deferred.

7. **Aggregate** into the report schema (see "Report Format" below). Severity breakdown: HIGH violations block commit; MEDIUM warns; LOW logs.

7. **Write report** to `agent-workspace/quality-reports/drift-reports/YYYY-MM-DD-HHmm.md`.

8. **Exit code** for CI integration: `0` all-PASS / `1` MEDIUM violations only / `2` HIGH violations (blocks CI).

## Report Format

```markdown
# Drift Check Report — YYYY-MM-DD

## Summary
- Scope: [all | high | DR<N>]
- Total signals run: N
- Passed: X / Warnings: Y (MEDIUM/LOW) / Violations: Z (HIGH — blocks)

## Results
| Signal | Severity | Status | Violations | Details |
|---|---|---|---|---|
| DR1 | HIGH | PASS | 0 | LOC ceilings clean |
| DR2 | HIGH | CHECK | - | DB unavailable, skipped |
| DR3 | MEDIUM | FAIL | 2 | See below |
...

## Violations Detail
### DRn (severity) — title
- File:line — issue + suggested fix

## Recommendations
- Blocking (must fix before commit): [HIGH list]
- Should fix this session: [MEDIUM list]
- Tracked for later: [LOW list]
```

## Auto-Fix (offered, not applied)

For some signals, suggest fixes without applying:

- DR6 (`Any` types) → suggest concrete types (mypy --strict will catch these)
- DR3 (unwrapped LLM calls) → show wrapper pattern from `packages/infrastructure/llm/` shared budget+retry helper

User explicitly approves before any fix is applied.

## Anti-Patterns

- Skipping drift check because "it takes too long" (the hook runs in <2s)
- Ignoring HIGH violations with TODO comments
- Running only some signals regularly — do all periodically

## Do

- Run before every commit
- Fix HIGH immediately
- Track MEDIUM for next session
- Add new signals to `drift-signals.md` + hook when new patterns emerge

## Related

- `agent-workspace/constitution/drift-signals.md` — signal definitions (canonical)
- `agent-workspace/proposals/drift-signals-amendment-DR-INTENT.md` — DR-INTENT pending charter promotion
- `scripts/hooks/drift-signals-D1-D9.sh` — deterministic recipes
- `drift-detector` agent — semantic-signal inspector (DR7, DR12)
- `intent-vs-impl-diff` agent — semantic DR-INTENT auditor
- `/ul-audit` command — DR7 UL term drift specialized check
