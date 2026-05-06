#!/usr/bin/env bash
# effort-escalation-detector.sh — recommend effort level bump based on prompt signals
# Hooks: UserPromptSubmit + PreToolUse (Agent only)
# Per routing-config.md § 4 + S65 user directive "tận dụng full effort ladder"
# Output: stderr "effort_recommendation: <level> | reason: <text>" (advisory; non-blocking)
#
# Detection ladder (deterministic regex match):
#   medium → high:    spec ambiguity / 2+ alternatives / debug stuck / cross-BC / blocker / unclear
#   high → xhigh:     novel pattern / cross-system / charter-tier touch / first-time / no precedent
#   xhigh → max:      multi-perspective adversarial 3+ viewpoints / theorem-like / recurring M-S<N>-<M>
#   any → low:        pure file-ops / mtime check / mechanical mv / pure read-and-cite

set -uo pipefail
trap 'exit 0' ERR

PAYLOAD="$(cat 2>/dev/null || true)"
[ -n "$PAYLOAD" ] || exit 0

eval "$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{
  try {
    const p=JSON.parse(s),q=v=>JSON.stringify(String(v||''));
    console.log('HOOK_EVENT='+q(p.hook_event_name));
    console.log('TOOL_NAME='+q(p.tool_name));
    let prompt='';
    if (p.prompt) prompt = p.prompt;
    else if (p.tool_input && p.tool_input.prompt) prompt = p.tool_input.prompt;
    console.log('PROMPT='+q(prompt));
  } catch { console.log('HOOK_EVENT=\"\"'); }
});" 2>/dev/null || echo 'HOOK_EVENT=""')"

[ "${HOOK_EVENT:-}" = "UserPromptSubmit" ] || \
  { [ "${HOOK_EVENT:-}" = "PreToolUse" ] && [ "${TOOL_NAME:-}" = "Agent" ]; } || exit 0
[ -n "${PROMPT:-}" ] || exit 0

# Kill switch
[ "${EFFORT_DETECTOR_DISABLE:-0}" = "1" ] && exit 0

# Lowercase prompt for case-insensitive match
PROMPT_LC="$(printf '%s' "$PROMPT" | tr '[:upper:]' '[:lower:]')"

LEVEL=""
REASONS=()

# === Level: max ===
# Multi-perspective adversarial 3+
if printf '%s' "$PROMPT_LC" | grep -qE 'bear.*bull.*critic|3\+ viewpoints|multi-perspective.*adversarial|six perspectives|five perspectives|four perspectives'; then
  LEVEL="max"
  REASONS+=("multi-perspective adversarial ≥3 viewpoints")
fi
# Theorem-like or proof-required
if printf '%s' "$PROMPT_LC" | grep -qE 'prove .* invariant|formal verification|exhaustive case analysis|all edge cases must'; then
  LEVEL="max"
  REASONS+=("theorem-like proof required")
fi
# Recurring M-S<N>-<M> (recurrence ≥3)
if printf '%s' "$PROMPT" | grep -qE 'recurr|3rd time|third time|again[!.]|same .* failure'; then
  LEVEL="max"
  REASONS+=("recurring failure pattern")
fi

# === Level: xhigh (if not already max) ===
if [ -z "$LEVEL" ]; then
  if printf '%s' "$PROMPT_LC" | grep -qE 'novel|first time|no precedent|never before|no.*mirror|brand new|unprecedented'; then
    LEVEL="xhigh"
    REASONS+=("novel pattern (no precedent)")
  elif printf '%s' "$PROMPT_LC" | grep -qE 'cross-system|cross-bc reasoning|charter.tier|charter[- ]amend|invariant.*touch|constitution[- ]edit'; then
    LEVEL="xhigh"
    REASONS+=("cross-system or charter-tier touch")
  fi
fi

# === Level: high (if not already xhigh/max) ===
if [ -z "$LEVEL" ]; then
  if printf '%s' "$PROMPT_LC" | grep -qE 'ambiguous|unclear|spec gap|stuck|cannot proceed|debug|debugging|blocker'; then
    LEVEL="high"
    REASONS+=("ambiguity / debug / blocker signal")
  elif printf '%s' "$PROMPT_LC" | grep -qE 'cross-bc'; then
    LEVEL="high"
    REASONS+=("cross-BC interaction")
  else
    # 2+ alternatives detection (count distinct pattern hits; deterministic)
    ALT_HITS=0
    for pat in 'alternative' 'option [a-z]' '\([a-z]\)' ; do
      if printf '%s' "$PROMPT" | grep -qiE "$pat" 2>/dev/null; then
        ALT_HITS=$((ALT_HITS+1))
      fi
    done
    if [ "$ALT_HITS" -ge 2 ]; then
      LEVEL="high"
      REASONS+=("multiple alternatives mentioned (non-trivial tradeoff)")
    fi
  fi
fi

# === Level: low ===
if [ -z "$LEVEL" ]; then
  if printf '%s' "$PROMPT_LC" | grep -qE '^(continue|status|list|show|read )|^(ls|cat|grep)$|mtime check|mechanical (mv|rename|copy)|pure read'; then
    LEVEL="low"
    REASONS+=("mechanical / read-only operation")
  fi
fi

# Emit recommendation if level detected
if [ -n "$LEVEL" ]; then
  REASON_STR="${REASONS[*]}"
  printf 'effort_recommendation: %s | reason: %s\n' "$LEVEL" "$REASON_STR" >&2
fi

exit 0
