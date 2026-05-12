#!/usr/bin/env bash
# firing-test-spawn-context-lint.sh — AP-23 "harness-firing-test-gap" prevention.
# Stop hook. Scans .claude/settings.json for three classes of spawn-context defects:
#
#   Pass 1 — Form-B env-wrap detection (NEW, closes S247 gap):
#     Regex `"command":\s*"env\s+[A-Z_][A-Z_0-9]*=` — env VAR=val cmd pattern.
#     Sibling to settings-inline-env-prefix-detector.sh which catches Form-A only.
#
#   Pass 2 — Non-default arg-passing missing companion firing-test:
#     Hooks using bash-c, stdin-redirect, or env-wrap-B must have a companion
#     firing-test in scripts/hooks/firing-tests/<basename>-fire-test.sh.
#     Positional-arg (Form-C) is safe in Windows executor — only Form-A/B/bash-c/
#     stdin-redirect require strict enforcement here.
#
#   Pass 3 — Missing SPAWN-CONTEXT marker in companion firing-test:
#     For hooks using Form-A/B/bash-c/stdin-redirect, the firing-test MUST
#     contain a `# SPAWN-CONTEXT:` marker block (forces author to mentally model
#     Windows spawn topology). Root cause of all 6 AP-23 instances.
#
# WARN-only (exit 0); informational. Phase 3.5 / S248 deliverable. L-S247-1 promotion
# target: promote to BLOCKING after 5 sessions of clean state per S99 ritual-demotion.
# Per CLAUDE.md hard rule: hook ships with companion firing-test
# (scripts/hooks/firing-tests/firing-test-spawn-context-lint-fire-test.sh).
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
mkdir -p "$PROJECT_DIR/agent-workspace/memory" 2>/dev/null || true
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
SETTINGS="$PROJECT_DIR/.claude/settings.json"
FIRE_TEST_DIR="$PROJECT_DIR/scripts/hooks/firing-tests"
TS="$(date -Iseconds)"
NAME="firing-test-spawn-context-lint"

[ ! -f "$SETTINGS" ] && { echo "[$TS] $NAME: SKIP settings.json-missing" >> "$HOOK_LOG"; exit 0; }

TOTAL_VIOLATIONS=0

# ─── Pass 1: Form-B env-wrap detection ────────────────────────────────────────
# Regex: command-string value that starts with `env VAR=val ...` pattern.
# `env [A-Z_][A-Z_0-9]*=` is the telltale of Form-B env-wrap.
FORM_B_PATTERN='"command":[[:space:]]*"env[[:space:]]+[A-Z_][A-Z_0-9]*='

FORM_B_HITS=$(grep -nE "$FORM_B_PATTERN" "$SETTINGS" 2>/dev/null || true)
if [ -n "$FORM_B_HITS" ]; then
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    HOOK_NAME=$(printf '%s' "$line" | grep -oE 'scripts/hooks/[^"]+\.sh' | head -1 | xargs basename 2>/dev/null || echo "unknown")
    echo "[$TS] $NAME: state=WARN class=AP-23 hook=$HOOK_NAME form=env-wrap-B reason=form-B" >> "$HOOK_LOG"
    TOTAL_VIOLATIONS=$((TOTAL_VIOLATIONS + 1))
  done <<< "$FORM_B_HITS"
fi

# ─── Pass 2 + Pass 3: Non-default arg-passing inventory ───────────────────────
# Forms requiring strict check (not safe in Claude Code Windows executor):
#   bash-c       : `bash -c '...'`
#   stdin-redir  : `... <<< ...` or `bash ... < file`
#   env-wrap-B   : already caught in Pass 1 (skip to avoid double-count)
# Form-C (positional-arg) is safe; requires firing-test but NOT SPAWN-CONTEXT marker.
# Form-A (inline-env-prefix) is caught by sibling detector; skip here (no double-count).

# Extract all hook command strings from settings.json using python for reliable JSON parse.
# Emit one line per command: <shape_class> <basename_or_empty> <full_command>
HOOK_INVENTORY=$(python3 - "$SETTINGS" 2>/dev/null <<'PYEOF' || true
import json, sys, re, os

def classify(cmd):
    cmd = cmd.strip()
    # Form-B env-wrap
    if re.match(r'^env\s+[A-Z_][A-Z_0-9]*=', cmd):
        return 'env-wrap-B'
    # Form-A inline-env-prefix (sibling detector handles; note only)
    if re.match(r'^[A-Z_][A-Z_0-9]*=', cmd):
        return 'inline-env-A'
    # bash -c '...' (any variant)
    if re.match(r'^bash\s+-c\s+', cmd):
        return 'bash-c'
    # stdin redirect
    if re.search(r'<<<|<\s*\S+', cmd):
        return 'stdin-redirect'
    # positional-arg: bash "script.sh" arg
    m = re.match(r'^bash\s+"[^"]+\.sh"\s+\S', cmd)
    if m:
        return 'positional-arg'
    # default: bash "script.sh" (no extra args)
    return 'default'

def extract_basename(cmd):
    m = re.search(r'scripts/hooks/([^/"]+\.sh)', cmd)
    if m:
        return os.path.basename(m.group(1))
    return ''

try:
    data = json.load(open(sys.argv[1]))
    hooks = data.get('hooks', {})
    for event, groups in hooks.items():
        if not isinstance(groups, list):
            continue
        for group in groups:
            for hook in group.get('hooks', []):
                if hook.get('type') == 'command':
                    cmd = hook.get('command', '')
                    shape = classify(cmd)
                    bn = extract_basename(cmd)
                    print(f"{shape}\t{bn}\t{cmd[:120]}")
except Exception as e:
    print(f"ERROR\t\tparse-error: {e}")
PYEOF
)

if [ -z "$HOOK_INVENTORY" ]; then
  echo "[$TS] $NAME: SKIP inventory-empty (python3 unavailable or parse-error)" >> "$HOOK_LOG"
  # still exit cleanly — WARN-only
else
  # Strict-check forms: these require both firing-test AND SPAWN-CONTEXT marker
  STRICT_FORMS="bash-c stdin-redirect env-wrap-B"

  while IFS=$'\t' read -r shape basename cmd_snippet; do
    [ "$shape" = "default" ] && continue
    [ "$shape" = "inline-env-A" ] && continue  # sibling detector handles
    [ "$shape" = "ERROR" ] && continue
    [ "$shape" = "positional-arg" ] && continue  # safe in Windows executor; no marker needed

    # At this point shape is bash-c, stdin-redirect, or env-wrap-B
    hook_name="${basename:-unknown}"
    fire_test_name="${basename%-fire-test.sh}"  # strip if already has suffix
    # Derive fire-test path
    if [ -n "$basename" ]; then
      fire_test_base="${basename%.sh}-fire-test.sh"
      fire_test_path="$FIRE_TEST_DIR/$fire_test_base"
    else
      fire_test_path=""
    fi

    # Pass 2: firing-test must exist
    if [ -z "$fire_test_path" ] || [ ! -f "$fire_test_path" ]; then
      echo "[$TS] $NAME: state=WARN class=AP-23 hook=$hook_name form=$shape reason=no-firing-test" >> "$HOOK_LOG"
      TOTAL_VIOLATIONS=$((TOTAL_VIOLATIONS + 1))
      continue
    fi

    # Pass 3: firing-test must have SPAWN-CONTEXT marker
    if ! grep -qF '# SPAWN-CONTEXT:' "$fire_test_path" 2>/dev/null; then
      echo "[$TS] $NAME: state=WARN class=AP-23 hook=$hook_name form=$shape reason=no-spawn-marker" >> "$HOOK_LOG"
      TOTAL_VIOLATIONS=$((TOTAL_VIOLATIONS + 1))
    fi
  done <<< "$HOOK_INVENTORY"
fi

# ─── Summary ──────────────────────────────────────────────────────────────────
if [ "$TOTAL_VIOLATIONS" -eq 0 ]; then
  echo "[$TS] $NAME: state=GREEN violations=0" >> "$HOOK_LOG"
else
  echo "[$TS] $NAME: state=WARN violations=$TOTAL_VIOLATIONS class=AP-23 (spawn-context lint)" >> "$HOOK_LOG"
fi

exit 0
