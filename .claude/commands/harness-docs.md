# /harness-docs — Maintain the Harness Framework Book

> Wrapper for the `harness-docs-maintainer` skill. Keeps `docs/harness/` in sync
> with the live harness.

## When to Use

- After adding / removing / renaming a skill, command, subagent, or hook
- After ratifying a constitution amendment
- On quarterly cadence (full audit)
- Before any major PR that touches `.claude/` or `scripts/hooks/` or `agent-workspace/constitution/`

## Input

```
/harness-docs <mode>
```

Where `<mode>` is one of:

| Mode | Action |
|---|---|
| `sync` | Detect drift + regenerate inventory files |
| `drift` | Detect drift; report only; no writes |
| `validate` | Verify all internal links resolve |
| `audit` | Dispatch `harness-docs-auditor` subagent for fresh-context full chapter audit |

Default (no arg): `drift`.

## Steps

1. **Determine mode** from `$ARGUMENTS`; default `drift`.
2. **Invoke the skill** `harness-docs-maintainer` with mode arg.
3. **For `sync` mode**: skill regenerates inventory files in `docs/harness/reference/`.
4. **For `drift` and `validate` modes**: skill writes report to `docs/harness/.research/drift-report-YYYY-MM-DD.md`.
5. **For `audit` mode**: dispatch [`harness-docs-auditor`](../agents/harness-docs-auditor.md) subagent.
6. **Display summary** of findings + recommended next actions.

## Output Schema

```markdown
# /harness-docs <mode> — <DATE>

## Diff Summary
| Layer | Live | Docs | Diff |
|---|---|---|---|

## New Artifacts
## Removed Artifacts
## Description Drift
## Broken Links
## Prose Count Drift

## Recommended Actions
1. ...

(Full report at docs/harness/.research/drift-report-<DATE>.md)
```

## Error Handling

- `docs/harness/` missing → CRITICAL — book not initialized; refuse to run; instruct user to init
- `.claude/` missing → CRITICAL — not a harness project
- Inventory file missing → recommend running `sync` first
- File permission denied → log + report; don't crash

## Anti-Patterns

- Running this command in CI without considering write impact (sync mode writes files)
- Treating drift output as exhaustive — chapter prose audit needs `harness-docs-auditor` subagent
- Editing inventory files manually + running sync immediately (sync overwrites)
- Running quarterly audit without first running `drift` to scope the work

## Related

- Skill: [`harness-docs-maintainer`](../skills/harness-docs-maintainer/SKILL.md)
- Subagent: [`harness-docs-auditor`](../agents/harness-docs-auditor.md)
- Book: [`docs/harness/`](../../docs/harness/README.md)
- Chapter 14 § Keeping the Book in Sync: [`docs/harness/en/14-contributing.md#keeping-the-book-in-sync`](../../docs/harness/en/14-contributing.md#keeping-the-book-in-sync)
