# Drift Signals — DR1 through DR12 + Stock-Specific

> Numbered, severity-assigned, scriptable checks for architectural decay.
> Run via `/drift-check` command.

## How to Use

```bash
# Run all signals
/drift-check

# Run specific severity only
/drift-check high

# Run specific signal
/drift-check DR1
```

Results written to `agent-workspace/quality-reports/drift-reports/YYYY-MM-DD-N.md`.

---

## HIGH Severity (blocks commit/merge)

### DR1: Domain layer imports framework
**What**: `packages/domain/**` imports from FastAPI, SQLAlchemy, Pydantic, psycopg2, or any framework/IO library.
**Why**: Breaks Clean Architecture. Domain must be framework-agnostic. See `invariants.md` I-10.
**Check**:
```bash
grep -rn "from fastapi" packages/domain/ --include="*.py"
grep -rn "from pydantic" packages/domain/ --include="*.py"
grep -rn "from sqlalchemy" packages/domain/ --include="*.py"
grep -rn "import psycopg" packages/domain/ --include="*.py"
grep -rn "from redis" packages/domain/ --include="*.py"
```
**Fix**: Move framework-dependent code to `infrastructure/`. Define a Protocol in domain/application, implement adapter in infrastructure.

### DR2: Evidence without citation
**What**: Claim record in database has null or empty `source_url`.
**Why**: Invariant I-1 violation. Hallucination risk.
**Check**:
```sql
SELECT id, text FROM claims WHERE source_url IS NULL OR source_url = '';
```
**Fix**: Backfill or delete. Add NOT NULL constraint.

### DR5: Claim stored without required metadata
**What**: Claim missing `source_url`, `extracted_at`, or `confidence`.
**Why**: Data integrity invariants (I-1, I-2). See `invariants.md`.
**Check**:
```sql
SELECT id FROM claims 
WHERE source_url IS NULL 
   OR extracted_at IS NULL 
   OR confidence IS NULL;
```
**Fix**: Backfill or re-extract.

### DR6: `Any` type in domain package
**What**: `: Any`, `cast(Any`, or `-> Any` in `packages/domain/**` (excluding test files).
**Why**: Invariant I-12. Type safety undermined.
**Check**:
```bash
grep -rn ": Any\|cast(Any\|-> Any" packages/domain/ \
  --include="*.py" | grep -v "test_\|_test.py"
```
**Fix**: Use proper types. If genuinely dynamic, use `object` with isinstance guards or a typed union.

### DR7: UL term drift (code vs glossary)
**What**: Identifier in code doesn't match canonical term in `ubiquitous-language/glossary.md`.
**Why**: DDD integrity. Code and business language diverge.
**Check**: Requires `/ul-audit` command (semantic check, not pure grep).
**Example**:
- Glossary defines term "Thesis"
- Code uses `Analysis`, `Report`, or `Study` for same concept
**Fix**: Rename to match glossary, OR update glossary to reflect new term (rare).

### DR8: Cross-BC direct import
**What**: Bounded context imports from another BC's domain or application layer directly.
**Why**: Invariant I-11. Breaks BC boundaries. See `invariants.md`.
**Check**:
```bash
# Check no direct cross-BC imports in domain
for BC in market_data fundamental company_intelligence macro news influence crowd analysis portfolio; do
  grep -rn "from packages.domain." packages/domain/$BC/ \
    --include="*.py" | grep -v "packages/domain/$BC/"
done
```
**Fix**: Move cross-BC types to `packages/contracts/`. Import contracts instead.

### DR9: Synthesis output without verifier step
**What**: Thesis or synthesis record created without passing through claim verifier.
**Why**: Invariant I-50. Hallucination risk.
**Check**: 
```sql
SELECT t.id FROM theses t
LEFT JOIN verifier_runs vr ON vr.thesis_id = t.id
WHERE vr.id IS NULL AND t.status = 'active';
```
**Fix**: Re-run verifier for affected theses.

### DR-S1: LLM emitted a number without tool call
**What**: LLM output text contains a numeric value (percentage, ratio, price) not traced to a deterministic tool call result.
**Why**: Invariant I-S1 (No LLM Math). Finance numbers from LLM = hallucination risk = real money.
**Check**: Output validator; grep LLM response logs for patterns like `approximately \d+%`, `around \d`, `estimated \d+`.
**Fix**: Ensure all numeric outputs route through tool calls. Review prompt for accidental numeric output encouragement.

### DR-S2: Thesis output without bear case
**What**: A thesis record in `thesis-log/` or BC-8 output missing a substantive bear case.
**Why**: Invariant I-S10. Single-perspective thesis is an anti-pattern (charter principle).
**Check**:
```sql
SELECT id, ticker FROM theses WHERE bear_case IS NULL OR bear_case = '';
```
```bash
grep -rL "bear_case\|bear case\|Bear Case" agent-workspace/memory/thesis-log/*.md
```
**Fix**: Re-run thesis workflow with critic agent enforcing bear case requirement.

---

## MEDIUM Severity (warning, fix in current/next session)

### DR3: LLM call without retry/budget
**What**: Direct API call to Claude/OpenAI without budget cap or retry logic.
**Why**: Cost runaway risk. Reliability.
**Check**:
```bash
grep -rn "anthropic.Anthropic\|client.messages.create" packages/infrastructure/ \
  --include="*.py" | grep -v "with_budget\|with_retry\|budget_aware"
```
**Fix**: Wrap with `with_budget()` and `with_retry()` helpers.

### DR4: Hardcoded prompt outside prompts directory
**What**: Long prompt strings embedded in business logic code instead of loaded from `prompts/` directory.
**Why**: Version control + A/B testing + optimization require prompts as data.
**Check**:
```bash
# Heuristic: strings >500 chars in Python files outside prompts/
grep -rEn '"""[^"]{500,}"""' packages/application/ \
  --include="*.py" | grep -v "prompts/"
```
**Fix**: Extract prompt to `prompts/<name>.md`. Load via `load_prompt(name)`.

### DR10: Spec referenced doesn't exist
**What**: Code or documentation references a spec ID (e.g., SPEC-2026-04-001) but file doesn't exist.
**Why**: Stale references lead agents in circles.
**Check**:
```bash
grep -rn "SPEC-[0-9]\{4\}-[0-9]\{2\}-[0-9]\{3\}" . --include="*.py" --include="*.md" \
  | while read ref; do
      # Parse and verify file exists
    done
```
**Fix**: Update reference or restore spec file from git.

### DR12: Anti-pattern from agent-notes.md
**What**: Code contains pattern previously flagged as anti-pattern in `agent-workspace/memory/agent-notes.md`.
**Why**: Avoid repeating past mistakes. Use institutional memory.
**Check**: Semantic, requires inspection of agent-notes.md rules.
**Fix**: Apply the documented fix from the original rule.

---

## LOW Severity (logged, address at phase boundary)

### DR11: Stale session-handoff
**What**: `agent-workspace/memory/current-execution.md` or `project.md` references completed work as "in progress".
**Why**: Confuses next session start.
**Check**:
```bash
# Compare status in files with git commit history
git log --since="7 days ago" --name-only | grep -E "\.(py|md)$"
# vs
grep "in_progress\|pending" agent-workspace/memory/project.md
```
**Fix**: Update state files to reflect actual progress.

### DR-minor-1: print() in production code
**What**: `print(` calls in `packages/` or `apps/` (excluding tests and CLI tools).
**Why**: Use structured logger (`structlog`). Invariant I-13.
**Check**:
```bash
grep -rn "print(" packages/ apps/ \
  --include="*.py" | grep -v "test_\|_test.py\|/tests/\|cli.py"
```
**Fix**: Replace with `logger.info(...)` / `logger.error(...)` via structlog.

### DR-minor-2: Missing staleness propagation
**What**: Data surfaced to dashboard/alerts without staleness metadata (`as_of`, `extracted_at`).
**Why**: Invariant I-5. User must always see data age.
**Check**:
```bash
grep -rn "def get_\|def fetch_\|def query_" packages/application/ \
  --include="*.py" | xargs -I{} grep -L "as_of\|extracted_at\|staleness"
```
**Fix**: Add staleness metadata to query results; UI must display "as of [date]".

---

## Adding New Drift Signals

When a new failure pattern emerges:

1. Document it in `agent-workspace/memory/agent-notes.md` with example
2. If detectable via grep/script, add to this file with DR<N> number
3. Add to `/drift-check` command or script
4. Assign severity based on impact
5. Update this documentation

Stock-specific signals (DR-S*) have especially high bar to remove — they guard against real money risk.

---

## Automation Target

By Phase 3:
- All HIGH signals run in pre-commit hook
- All signals run in CI
- Dashboard showing drift trends over time

For now (Phase 1-2):
- Run `/drift-check` manually at session end
- Focus on HIGH severity violations
- MEDIUM and LOW logged but not blocking
