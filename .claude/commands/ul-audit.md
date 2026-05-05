# /ul-audit — Audit Ubiquitous Language Consistency

> Check that code identifiers match canonical terms in `agent-workspace/ubiquitous-language/glossary.md`. Body delegates substance to the `ul-auditor` agent (semantic synonym detection) + grep-based deterministic checks.

## When to Use

- After new terms added via `/drill-me`
- Monthly maintenance
- When suspicion of term drift
- Before phase boundary
- After significant refactoring

## Input

`$ARGUMENTS` — depth selector: `quick` (~2 min — HIGH severity stop-list only; pre-commit / end-of-session) or `full` (~10-15 min — all terms, all files, specs, synonym detection; default).

## Process

1. **Load canonical terms** — read `agent-workspace/ubiquitous-language/glossary.md`. Extract every defined term, canonical spelling, and the "Stop List" (terms we explicitly do NOT use).

2. **Scan code for term usage** — for each canonical term, `grep -rn "TermName" packages/ apps/ --include="*.py"` plus case-insensitive variant patterns to catch snake_case / camelCase / PascalCase variants. Map term → variants found → status (OK / DRIFT).

3. **Stop-list check** — for each entry in Stop List (e.g., `Recommendation` when canonical is `KolRecommendation`), grep code identifiers (`class X`, `def x`, `: X`). For each hit, determine if it refers to the canonical concept.

4. **Domain mapping accuracy** — read `agent-workspace/ubiquitous-language/domain-mapping.md`. For each term with code location listed, verify file exists and class/dataclass uses canonical name.

5. **Synonym detection (semantic)** — dispatch `ul-auditor` agent (fresh context, run_in_background) to find concept-level synonyms grep cannot catch (e.g., `Analysis` and `Report` both used for the `Thesis` concept). Agent reads candidate clusters and returns observations.

6. **Spec consistency cross-check** — for each spec in `specs/`: terms used exist in glossary? Same term used consistently within spec? Match terms used in implementing code?

7. **Output audit report** with sections: Summary (canonical terms / files scanned / specs scanned / violations) / Status (`CLEAN` | `DRIFT DETECTED` | `MAJOR DRIFT`) / Term Usage Coverage table / Violations Detail (each numbered V-N with term, canonical, found-at file:line, suggested fix) / Domain Mapping Gaps / Spec Consistency / Recommendations split into Must-Fix (DRIFT), Suggested (consistency), Maintenance.

8. **Suggest fixes — DON'T auto-apply** — propose specific renames and updates per violation. User explicitly approves before any apply.

9. **Log audit** — write report to `agent-workspace/quality-reports/drift-reports/ul-audit-YYYY-MM-DD.md`. Append entry to `agent-workspace/ubiquitous-language/drift-log.md` with date, violations summary, fix status.

## Anti-Patterns

- Skipping audit because "code works anyway"
- Only fixing HIGH violations (MEDIUM accumulates)
- Auto-renaming without user review (breaks intentional distinctions)

## Do

- Run periodically even without complaints
- Fix drift as it emerges (cheap to fix early)
- Update glossary if new terminology is genuinely better — don't silently rename code without glossary update

## Related

- `ul-auditor` agent — semantic synonym detector (step 5)
- `ubiquitous-language` skill — passive analysis (term-definition substance)
- `/drill-me` — interactive extraction (input source for new terms)
- `agent-workspace/ubiquitous-language/glossary.md` — canonical terms
- `agent-workspace/ubiquitous-language/domain-mapping.md` — term → code location
- `agent-workspace/ubiquitous-language/drift-log.md` — change log
