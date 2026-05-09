# /attach — Procedures

> Bash one-liners and edge cases for the `/attach` skill.
> Read on-demand when SKILL.md procedure points here.

## Reading Manifest

```bash
SOURCE_MANIFEST="$CLAUDE_PROJECT_DIR/.claude/manifest.yaml"
[ -f "$SOURCE_MANIFEST" ] || { echo "ERROR: source manifest missing"; exit 1; }
```

For YAML parsing without `yq`: use Python one-liner via `python -c "import yaml; ..."` or grep-based extraction. Prefer `yq` if available (`yq --version`).

## Building the Plan (Python, since yaml parsing is non-trivial in pure bash)

```bash
python <<'PY'
import yaml, json, sys, os

src = os.environ['CLAUDE_PROJECT_DIR'] + "/.claude/manifest.yaml"
with open(src) as f:
    m = yaml.safe_load(f)

include = []
exclude = []

# Harness layer — always copy
for category in ["skills", "agents", "commands", "hooks", "docs"]:
    for entry in (m.get("harness", {}).get(category) or []):
        include.append(entry["path"])

# Stockforge layer — skip unless --include-stockforge
for category in ["skills", "agents", "commands", "hooks", "docs"]:
    for entry in (m.get("stockforge", {}).get(category) or []):
        exclude.append(entry["path"])

# Hybrid — copy with stub note
hybrid_paths = []
for entry in (m.get("hybrid", {}).get("hooks") or []):
    hybrid_paths.append(entry["path"])

# Personal — skip unless --include-personal
for path in (m.get("personal", {}).get("paths") or []):
    exclude.append(path)

print(json.dumps({"include": include, "exclude": exclude, "hybrid": hybrid_paths}, indent=2))
PY
```

## Validating Target

```bash
TARGET="$1"
TARGET_ABS="$(realpath -m "$TARGET")"
SOURCE_ABS="$(realpath "$CLAUDE_PROJECT_DIR")"

# Reject self-target
if [[ "$TARGET_ABS" == "$SOURCE_ABS" || "$SOURCE_ABS" == "$TARGET_ABS"/* ]]; then
    echo "ERROR: target must not be source or ancestor"
    exit 1
fi

# Create target if missing
mkdir -p "$TARGET_ABS"

# Check existing CLAUDE.md
if [ -f "$TARGET_ABS/CLAUDE.md" ] && [ "$FORCE" != "true" ]; then
    echo "ERROR: $TARGET_ABS/CLAUDE.md exists; pass --force to overwrite"
    exit 1
fi
```

## Copy Steps

```bash
# Per-path copy preserving structure
for path in "${INCLUDE[@]}"; do
    src="$SOURCE_ABS/$path"
    dst="$TARGET_ABS/$path"
    [ ! -e "$src" ] && { echo "WARN: missing source: $path"; continue; }
    mkdir -p "$(dirname "$dst")"
    cp -r "$src" "$dst"
done

# Hybrid hooks: copy + stub stockforge_part
for path in "${HYBRID[@]}"; do
    src="$SOURCE_ABS/$path"
    dst="$TARGET_ABS/$path"
    mkdir -p "$(dirname "$dst")"
    # Copy then comment-out stockforge-specific blocks (manual stub markers in the hook file)
    sed 's/^# === STOCKFORGE_PART_START ===$/# === STOCKFORGE_PART_STUBBED ===/;
         /STOCKFORGE_PART_STUBBED/,/STOCKFORGE_PART_END/ s/^/#  /' "$src" > "$dst"
done
```

NOTE: hybrid hook files must use literal `# === STOCKFORGE_PART_START ===` and `# === STOCKFORGE_PART_END ===` markers for the stub mechanism to work. See `drift-signals-D1-D9.sh` (currently the only hybrid hook; renamed from D1-D8 in S10 per D-005 § 5.5d.1) — markers must be added in the hybrid refactor done at /attach skill consumption time, not now (S5 doesn't refactor that hook). Open item: M2 in manifest.yaml § open_items.

## Settings.json env-var rewrite

```bash
# Replace STOCKFORGE_* with TARGET_PROJECT_PREFIX_*
TARGET_PREFIX="${TARGET_PROJECT_PREFIX:-MYPROJECT}"
sed "s/STOCKFORGE_/${TARGET_PREFIX}_/g" \
    "$SOURCE_ABS/.claude/settings.json" \
    > "$TARGET_ABS/.claude/settings.json"
```

User can pass `TARGET_PROJECT_PREFIX=ACME` env var; defaults to `MYPROJECT`.

## Skeleton Generation

```bash
# CLAUDE.md skeleton — see references/skeleton-templates.md
cat "$CLAUDE_PROJECT_DIR/.claude/skills/attach/references/skeleton-templates.md" \
    | sed -n '/^## CLAUDE.md/,/^## /p' \
    | tail -n +3 | sed '$d' \
    > "$TARGET_ABS/CLAUDE.md"

# manifest.yaml — copy + reset stockforge layer to empty
python <<PY
import yaml
with open("$SOURCE_ABS/.claude/manifest.yaml") as f:
    m = yaml.safe_load(f)
# Clear stockforge biz layer; target re-categorizes own
m["stockforge"]["skills"] = []
m["stockforge"]["hooks"] = []
m["stockforge"]["docs"] = []
m["created_at"] = "$(date +%Y-%m-%d)"
m["updated_at"] = "$(date +%Y-%m-%d)"
m["revision"] = "fresh-from-attach"
with open("$TARGET_ABS/.claude/manifest.yaml", "w") as f:
    yaml.safe_dump(m, f, sort_keys=False)
PY

# Empty skeleton dirs
for d in agent-workspace/memory/{sessions,decisions,checkpoints,observations,patterns-discovered,drift-logs,post-mortems,thesis-log} \
         human-workspace/{user_prompt,decisions,q-and-a/{pending,answered,stale},notifications}; do
    mkdir -p "$TARGET_ABS/$d"
done
```

## Edge Cases

| Case | Handling |
|---|---|
| Target on different drive (Windows) | `realpath -m` works; cp works cross-drive |
| Symlinks in source | `cp -rL` to deref OR `cp -r` to copy symlink — choose `-rL` (deref by default) |
| Permissions: target read-only | Abort with clear error; don't try chmod |
| Source missing manifest.yaml | Fatal — `/attach` requires manifest |
| `personal/` exists at source but `--include-personal` not set | Skip silently (verbose log entry) |
| Hybrid hook lacks STOCKFORGE_PART markers | Warn + copy verbatim (let user fix at target) |
| settings.json schema differs (Anthropic version mismatch) | Copy as-is; let target /init handle migrations |

## Smoke Test Procedure

```bash
SCRATCH="$(mktemp -d -t attach-smoke-XXXXXX)"
echo "Scratch: $SCRATCH"

# Dry-run
bash <(cat <<'INNER'
# Pseudo-code — replace with actual /attach invocation
echo "Plan would copy: <list>"
echo "Plan would skip: <list>"
INNER
)

# Actual copy
# (run the procedure above)

# Verify exclusions
test ! -d "$SCRATCH/.claude/skills/crawler-reliability" && echo "PASS: stockforge skill excluded"
test ! -d "$SCRATCH/.claude/skills/evidence-extraction" && echo "PASS: stockforge skill excluded"
test -d "$SCRATCH/.claude/skills/grill-maximization" && echo "PASS: harness skill copied"
test -d "$SCRATCH/.claude/skills/attach" && echo "PASS: /attach copies itself (so target can re-attach further)"

# Cleanup
echo "Cleanup: rm -rf $SCRATCH (manual; skill never destroys)"
```

## HH-G.4 Portability Validation Checklist (post-S174 close)

Use this checklist to pre-flight any /attach invocation OR consume as smoke-test
source-of-truth when investigating drift in the harness vs stockforge layer split.
Closed S174 per Q4=A user-pick (Phase 2.5 HH-G residue → Phase 3.5 alignment).

### Pre-flight (before /attach)

- [ ] **VBW**: Read `.claude/manifest.yaml` end-to-end; confirm REV-3 timestamp + V1-V7 schema
- [ ] **VBW**: Read `templates/general-harness/CLAUDE.md` (HH-G.1 deliverable); confirm <2.5K tokens portable
- [ ] **VBW**: Read `.claude/skills/attach/SKILL.md` § "Layer-separation assertion smoke" (A1-A7)
- [ ] **HEALTH**: Run `scripts/hooks/attach-portability-smoke.sh` against real project; confirm `state=GREEN`
- [ ] **HEALTH**: Run `scripts/hooks/firing-tests/attach-portability-smoke-fire-test.sh`; confirm 7/7 PASS

### During /attach

- [ ] Exclusion list honored: 5 stockforge skills (`crawler-reliability`, `evidence-extraction`, `postgres-pgvector`, `fastapi-module`, `prompt-engineering`) NOT copied
- [ ] Exclusion list honored: 5 stockforge hooks (`userprompt-invariants-injector.sh`, `post-tool-citation-grep.sh`, `precompact-thesis-state-dump.sh`, `taskcompleted-audit.sh`, `charter-coherence-spot.sh`) NOT copied
- [ ] Exclusion list honored: stockforge docs (`PROJECT_CHARTER.md`, `AGENT_OPERATING_MANUAL.md`, project-`CLAUDE.md`, `obsidian-vault/`, `specs/`, `eval-sets/`, `apps/`, `packages/`, `bdd/`, `agent-workspace/constitution/invariants-stockforge.md`) NOT copied
- [ ] Inclusion list honored: 18 harness skills + 14 agents + 14 commands + ≥30 harness hooks + 13 harness constitution files copied
- [ ] HH-G.1 template lands at `<target>/templates/general-harness/CLAUDE.md` and is consumed as the basis for the target's project-CLAUDE.md skeleton (per `references/skeleton-templates.md` § CLAUDE.md)
- [ ] settings.json env-var rewrite: all `STOCKFORGE_` → `<TARGET_PREFIX>_` (default `MYPROJECT`)
- [ ] Hybrid hook (`drift-signals-D1-D9.sh`): stockforge_part stubbed via `STOCKFORGE_PART_START` / `STOCKFORGE_PART_END` markers

### Post-/attach validation (target side)

- [ ] `<target>/CLAUDE.md` exists (skeleton from HH-G.1 template via `skeleton-templates.md` extraction)
- [ ] `<target>/.claude/manifest.yaml` exists with `stockforge.skills/.hooks/.docs` cleared (target re-categorizes own biz)
- [ ] `<target>/agent-workspace/memory/{sessions,decisions,checkpoints,observations}/` empty skeleton dirs
- [ ] `<target>/human-workspace/{user_prompt,decisions,q-and-a/{pending,answered,stale},notifications}/` empty skeleton dirs
- [ ] `cd <target> && claude` + `/session-start` returns clean routing scaffold (no stockforge biz leak in autoload)
- [ ] `<target>/scripts/hooks/attach-portability-smoke.sh` runs `state=GREEN` on the post-/attach state (target re-targets own manifest)

### Known-issues to suppress

- **HH-G hybrid hook stubs**: `drift-signals-D1-D9.sh` D5/D6/D7/D8 lines need `STOCKFORGE_PART_START`/`END` markers added in source before /attach can stub them. Manifest open_item M2.
- **Personal layer empty**: `.claude/personal/` reserved but not populated; `--include-personal` flag is no-op until a user actually drops content there. Manifest open_item M3.
- **needs-refactor skills** (4 listed in manifest.harness.skills): `test-pyramid-balance`, `ubiquitous-language`, `ddd-tactical-patterns`, `obsidian-vault` mention stockforge categories/paths but pattern is portable. Refactor target post-HH-G.

### Re-validation triggers

Re-run `attach-portability-smoke.sh` whenever:
- A new file lands in `.claude/skills/`, `.claude/agents/`, `.claude/commands/`, `scripts/hooks/`, or `agent-workspace/constitution/` (new artifact may need explicit layer tag)
- `manifest.yaml` is edited (REV-N bump)
- `templates/general-harness/CLAUDE.md` is edited (HH-G.1 content drift)
- A hybrid hook is added or modified (`hybrid.hooks` membership changes)

If smoke flips to RED, /attach is blocked until investigation closes the regression.
