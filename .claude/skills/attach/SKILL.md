---
name: attach
description: Port the Claude Code harness layer from this project to a new project directory. Use when bootstrapping a fresh Claude Code project on the same machine, when peers want to copy the harness, or when verifying layer separation via dry-run. Reads .claude/manifest.yaml; copies harness-tagged artifacts only; excludes stockforge biz + personal layers; generates skeleton CLAUDE.md + manifest at target.
allowed-tools: [Read, Glob, Grep, Bash, Write]
---

# Skill: /attach

## Purpose

Single-command harness port: copy `.claude/skills + agents + commands + hooks` (harness layer) plus `agent-workspace/CLAUDE.md` + `human-workspace/CLAUDE.md` skeletons + manifest.yaml from this project to a target directory. Stockforge biz layer (5 tagged skills + 5 hooks + biz docs) is excluded by default.

## When to Use

- User wants to start a fresh Claude Code project reusing this harness
- Sanity-check layer separation (run `--dry-run`; verify excluded paths)
- Peer asks for the harness; copy to their machine + git init

## When NOT to Use

- Internal restructure of this project — use direct file ops
- Anything that crosses project boundaries (don't `--attach` your own home dir)
- Phase 0 not yet complete — harness skeleton may still be churning; wait until Track 7 ships constitution port

## Inputs

| Arg | Required | Purpose |
|---|---|---|
| `<target-path>` | yes | Absolute or relative path to target project root |
| `--dry-run` | no | Print plan as table; copy nothing |
| `--include-personal` | no | Also copy `.claude/personal/` + `.env` |
| `--include-stockforge` | no | Also copy stockforge-tagged skills + biz docs (dev-mirror use case) |
| `--force` | no | Overwrite existing files at target without prompt |

## Process

1. **Read source manifest** — `Read .claude/manifest.yaml` from the current project. Parse layer tags + attach.default_includes/excludes.
2. **Validate target** — Bash check: target dir exists OR can mkdir parent. If target/CLAUDE.md exists AND no `--force`: abort with clear message.
3. **Build copy plan**:
   - INCLUDE: every path under `harness.skills`, `harness.agents`, `harness.commands`, `harness.hooks`, `harness.docs`
   - INCLUDE (hybrid): `hybrid.hooks` paths — copy + stub out `stockforge_part` lines
   - SKIP: every path under `stockforge.skills`, `stockforge.hooks`, `stockforge.docs` (unless `--include-stockforge`)
   - SKIP: every path under `personal.paths` (unless `--include-personal`)
   - SKIP: workspace state (`agent-workspace/memory/{decisions,sessions,checkpoints,thesis-log,calibration}`, `human-workspace/{user_prompt,decisions,q-and-a,notifications}`, `agent-workspace/raw-sessions`)
4. **Display plan** — always, even non-dry-run. Format: table of (action / path / size / reason).
5. **Stop if `--dry-run`** — exit cleanly after plan display.
6. **Execute copy** — see `references/procedures.md § Copy Steps` for bash one-liners (cp -r preserving structure; sed-replace env vars; hybrid stub).
7. **Generate skeleton at target**:
   - `CLAUDE.md` — minimal pointer to harness baseline + project-specific stub (template: `references/skeleton-templates.md`)
   - `.claude/manifest.yaml` — copy of source manifest with stockforge layer cleared (target re-categorizes own biz)
   - `agent-workspace/memory/current-execution.md` — skeleton routing source
   - Empty skeleton dirs: `agent-workspace/memory/{sessions,decisions,checkpoints,observations}`, `human-workspace/{user_prompt,decisions,q-and-a/{pending,answered,stale},notifications}`
8. **Print success summary** — file count copied + skipped + skeleton paths created.
9. **Suggest next steps** — `cd <target> && git init && claude` then run `/session-start`.

## Validation Pre-Conditions

- Source manifest validates against drift V1-V7 (run `drift-signals-D1-D9.sh` first if uncertain)
- Source `.claude/skills/attach/SKILL.md` is THIS file (skill exists; trivially true)
- Target path is not source path or any ancestor (don't recurse into self)

## Skeleton Output

Target post-/attach has working harness without biz logic. User runs `/session-start` and gets routing scaffold; runs `/session-end` and gets sessions log; etc. All harness commands functional.

What target does NOT get: stockforge biz skills, charter, specs, eval-sets, obsidian vault, accumulated workspace state. Those are the user's own to author for their domain.

## Anti-Patterns

- Never copy `.git/` — target inits its own
- Never copy node_modules / .pytest_cache / __pycache__ — bloat
- Never overwrite target/CLAUDE.md silently — `--force` is explicit
- Never copy across project boundaries that haven't accepted the harness contract — get confirmation first
- Don't copy hybrid hook with stockforge_part code intact — must stub or remove (target may not have stockforge env vars)

## Smoke Test (procedure for first /attach run)

1. Pick scratch target: `/tmp/attach-smoke` (Linux) or `$env:TEMP\attach-smoke` (Windows)
2. Run `--dry-run` — verify plan excludes 5 stockforge skills + 5 stockforge hooks
3. Run actual copy — verify file count matches plan
4. cd target + `claude` + `/session-start` — verify routing skeleton works
5. Diff target/.claude/skills/ vs source — should differ only in stockforge biz skills (5 absent)
6. Cleanup: `rm -rf <scratch>` (manual; skill never destroys)

### Layer-separation assertion smoke (S48l HH-G.3 codified)

Standalone Python harness that DOES NOT create files; validates manifest-level layer separation. Use for portability validation when actual copy not desired (autonomous loops avoid Skill tool prompts per UP-05).

```bash
PYTHONIOENCODING=utf-8 python -c "
import yaml
m = yaml.safe_load(open('.claude/manifest.yaml'))
include, exclude, hybrid = [], [], []
for cat in ['skills','agents','commands','hooks','docs']:
    include += [e['path'] for e in (m.get('harness',{}).get(cat) or [])]
    exclude += [e['path'] for e in (m.get('stockforge',{}).get(cat) or [])]
hybrid += [e['path'] for e in (m.get('hybrid',{}).get('hooks') or [])]
default_includes = next((v.get('default_includes') for v in m.values() if isinstance(v,dict) and 'default_includes' in v), [])

assertions = [
    ('A1', 'agent-workspace/constitution/invariants-stockforge.md' in exclude),
    ('A2', 'agent-workspace/constitution/invariants.md' in default_includes),
    ('A3', 'agent-workspace/constitution/invariants-stockforge.md' not in default_includes),
    ('A4', sum(1 for _ in (m.get('harness',{}).get('skills') or [])) >= 17),
    ('A5', sum(1 for _ in (m.get('stockforge',{}).get('skills') or [])) == 5),
    ('A6', any('drift-signals' in p for p in hybrid)),
    ('A7', 'PROJECT_CHARTER.md' in exclude),
]
errors = [c for c, ok in assertions if not ok]
print('GREEN' if not errors else 'RED ' + ','.join(errors))
"
```

Expected output: `GREEN`. If `RED <ids>`, manifest layer-tagging regressed — investigate before allowing /attach to consumers.

## Constitution Layer Boundary (post-S48l HH-G.2)

Constitution files split into harness vs stockforge per portability validation:

| File | Layer | Notes |
|---|---|---|
| `architecture.md` | harness | DDD + clean architecture patterns; project-agnostic |
| `autonomous-protocol.md` | harness | Mode-A/B/C/D/E discipline + Rule 10 |
| `boundaries.md` | harness | What agent cannot do without human approval |
| `coding-principles.md` | harness | Karpathy + DDD applied; some I-S* refs but pattern-portable |
| `decision-discipline.md` | harness | Tier classification + grill discipline |
| `drift-signals.md` | harness | DR1-DR12 signals + Tiered Coverage Map |
| `financial-data-protocol.md` | harness (flagged `[needs-refactor]`) | Stock-domain content; portability split target post-HH-G |
| `invariants.md` | harness | General invariants I-1..I-52 only (post-S48l split) |
| `invariants-stockforge.md` | **stockforge** | Stock-domain I-S* invariants — NOT copied by /attach |
| `karpathy-principles.md` | harness | P1-P4 four-principles doctrine |
| `memory-routing-tree.md` | harness | 12-field routing schema |
| `memory-tiers.md` | harness | Tier 1/2/3 always-loaded vs JIT vs explicit-pull |
| `session-budgets.md` | harness | Type selection + budget bands |
| `vbw-protocol.md` | harness | Verify-Before-Write checkpoints |

When porting to non-stock projects:
- Target gets 13 harness constitution files (general patterns)
- `invariants-stockforge.md` is excluded — target authors own invariants per their domain
- `financial-data-protocol.md` is currently included but flagged for further split if portability validation fails on a non-finance target

## See Also

- `.claude/manifest.yaml` — single source of truth for layer membership
- `references/procedures.md` — bash one-liners + edge cases
- `references/skeleton-templates.md` — skeleton file content
- D-003 REV-2 — tag-only realization (no `.claude/stockforge/` subtree)
- `agent-workspace/CLAUDE.md` § Subdirectories — what target needs to have empty
