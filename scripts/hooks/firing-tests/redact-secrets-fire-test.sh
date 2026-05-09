#!/usr/bin/env bash
# redact-secrets-fire-test.sh — companion firing-test per Phase 3.5 Hard Rule #2 retro-fit
# REAL-STATE-DERIVED per L-S176-1: parent hook is a stdin→stdout regex redactor (utility, not Stop hook),
# called by SessionEnd raw-export pipeline + future log/alert outputs. Critical security utility.
# B-12 utility port from refrepos claude-code-telegram/src/claude/orchestrator.py:52-80.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/redact-secrets.sh"

PASS=0
FAIL=0

run_redact() {
  printf '%s' "$1" | bash "$HOOK" 2>/dev/null
}

assert_contains() {
  local label="$1" out="$2" needle="$3"
  if printf '%s' "$out" | grep -qF "$needle"; then
    echo "  TC $label: PASS"; PASS=$((PASS+1))
  else
    echo "  TC $label: FAIL — needle='$needle' not in output"
    FAIL=$((FAIL+1))
  fi
}

assert_not_contains() {
  local label="$1" out="$2" needle="$3"
  if printf '%s' "$out" | grep -qF "$needle"; then
    echo "  TC $label: FAIL — leaked needle='$needle'"
    FAIL=$((FAIL+1))
  else
    echo "  TC $label: PASS"; PASS=$((PASS+1))
  fi
}

# TC1: anthropic API key → REDACTED:anthropic-api-key (regex requires ≥80 chars after sk-ant-api03-)
ANTH_BODY='AAAA1111BBBB2222CCCC3333DDDD4444EEEE5555FFFF6666GGGG7777HHHH8888IIII9999JJJJKKKKLLLL2222'
input1="log message with sk-ant-api03-${ANTH_BODY} end"
out1=$(run_redact "$input1")
assert_contains "TC1-anthropic-key-redacted" "$out1" "[REDACTED:anthropic-api-key]"
assert_not_contains "TC1-anthropic-key-original-removed" "$out1" "sk-ant-api03-AAAA1111BBBB"

# TC2: openai API key → REDACTED:openai-api-key
input2='openai key sk-AbCdEfGhIjKlMnOpQrStUvWxYz0123456789 in line'
out2=$(run_redact "$input2")
assert_contains "TC2-openai-key-redacted" "$out2" "[REDACTED:openai-api-key]"

# TC3: google API key → REDACTED:google-api-key (regex requires AIza + exactly 35 chars [A-Za-z0-9_\-])
input3='google AIzaSyABCDEFGHIJKLMNOPQRSTUVWXYZ-_012345 something'
out3=$(run_redact "$input3")
assert_contains "TC3-google-key-redacted" "$out3" "[REDACTED:google-api-key]"

# TC4: AWS access key → REDACTED:aws-access-key (AKIA + 16 uppercase alphanumeric)
input4='AWS key AKIAIOSFODNN7EXAMPLE in config'
out4=$(run_redact "$input4")
assert_contains "TC4-aws-key-redacted" "$out4" "[REDACTED:aws-access-key]"

# TC5: bearer token → REDACTED:bearer-token (case-insensitive bearer + 20+ chars)
input5='Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.payload here'
out5=$(run_redact "$input5")
assert_contains "TC5-bearer-token-redacted" "$out5" "[REDACTED:bearer-token]"

# TC6: JWT token → REDACTED:jwt (3 base64 segments separated by dots, 10+ chars each)
input6='token eyJhbGciOiJIUzI1NiI.eyJzdWIiOiIxMjM0NTY3.SflKxwRJSMeKKF3BcL3 verified'
out6=$(run_redact "$input6")
assert_contains "TC6-jwt-redacted" "$out6" "[REDACTED:jwt]"

# TC7: db connection string → REDACTED:db-conn (postgres/postgresql/mysql/mongodb)
input7='conn = postgres://user:password@host:5432/db sqlite is fine'
out7=$(run_redact "$input7")
assert_contains "TC7-db-conn-redacted" "$out7" "[REDACTED:db-conn]"
assert_not_contains "TC7-db-original-removed" "$out7" "user:password@host"

# TC8: clean text → unchanged (no false positive)
input8='this is normal log output without secrets'
out8=$(run_redact "$input8")
if [ "$out8" = "$input8" ]; then
  echo "  TC TC8-clean-text-unchanged: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC8-clean-text-unchanged: FAIL — input mutated"
  FAIL=$((FAIL+1))
fi

TOTAL=$((PASS+FAIL))
echo ""
echo "=== redact-secrets firing-test: PASS=$PASS FAIL=$FAIL ($TOTAL TCs) ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
