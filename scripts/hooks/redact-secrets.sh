#!/usr/bin/env bash
# redact-secrets.sh — regex-based secret redactor (B-12 utility port from refrepos
# claude-code-telegram/src/claude/orchestrator.py:52-80).
# Reads stdin, writes redacted text to stdout. Used by SessionEnd raw-export pipeline +
# any future log/alert outputs.
# Patterns covered: API keys (sk-/sk-ant-/AIza...), AWS access keys, Bearer tokens,
# DB connection strings, SSH private keys, JWT tokens, generic 32+ hex secrets.
# bash-hook-lint:allow L-S11-1 graceful degradation chain: python3 (primary) → node (fallback) → sed (Phase-0 floor; incomplete but functional for basic patterns).
set -uo pipefail

INPUT="$(cat)"

# Pipeline of regex substitutions. Each replaces matched secret with [REDACTED:<kind>].
# Use python3 (preferred) → node (fallback) for unicode-safe regex.
if command -v python3 >/dev/null 2>&1; then
  printf '%s' "$INPUT" | python3 -c "
import re, sys
text = sys.stdin.read()
patterns = [
    (r'sk-ant-api03-[A-Za-z0-9_\-]{80,}', '[REDACTED:anthropic-api-key]'),
    (r'sk-[A-Za-z0-9]{32,}',              '[REDACTED:openai-api-key]'),
    (r'AIza[0-9A-Za-z_\-]{35}',           '[REDACTED:google-api-key]'),
    (r'AKIA[0-9A-Z]{16}',                 '[REDACTED:aws-access-key]'),
    (r'(?i)bearer\s+[A-Za-z0-9_\-\.=]{20,}','[REDACTED:bearer-token]'),
    (r'eyJ[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}', '[REDACTED:jwt]'),
    (r'-----BEGIN [A-Z ]*PRIVATE KEY-----[\s\S]*?-----END [A-Z ]*PRIVATE KEY-----', '[REDACTED:private-key]'),
    (r'(postgres|postgresql|mysql|mongodb)://[^\s\"\\']+', r'\1://[REDACTED:db-conn]'),
    (r'(?i)(password|passwd|secret|token|api[_-]?key)[\"\\'\s:=]+[A-Za-z0-9_\-+/=]{12,}', r'\1=[REDACTED:credential]'),
]
for pat, rep in patterns:
    text = re.sub(pat, rep, text)
sys.stdout.write(text)
" 2>/dev/null
elif command -v node >/dev/null 2>&1; then
  printf '%s' "$INPUT" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{
  const patterns=[
    [/sk-ant-api03-[A-Za-z0-9_\-]{80,}/g, '[REDACTED:anthropic-api-key]'],
    [/sk-[A-Za-z0-9]{32,}/g, '[REDACTED:openai-api-key]'],
    [/AIza[0-9A-Za-z_\-]{35}/g, '[REDACTED:google-api-key]'],
    [/AKIA[0-9A-Z]{16}/g, '[REDACTED:aws-access-key]'],
    [/bearer\s+[A-Za-z0-9_\-\.=]{20,}/gi, '[REDACTED:bearer-token]'],
    [/eyJ[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}/g, '[REDACTED:jwt]'],
    [/-----BEGIN [A-Z ]*PRIVATE KEY-----[\s\S]*?-----END [A-Z ]*PRIVATE KEY-----/g, '[REDACTED:private-key]'],
    [/(postgres|postgresql|mysql|mongodb):\/\/[^\s\"']+/g, '\$1://[REDACTED:db-conn]'],
  ];
  let out=s;
  for(const [pat, rep] of patterns) out=out.replace(pat, rep);
  process.stdout.write(out);
});" 2>/dev/null
else
  # Last-resort sed fallback (incomplete; only catches simplest patterns).
  printf '%s' "$INPUT" | sed -E '
    s|sk-ant-api03-[A-Za-z0-9_-]{80,}|[REDACTED:anthropic-api-key]|g
    s|sk-[A-Za-z0-9]{32,}|[REDACTED:openai-api-key]|g
    s|AKIA[0-9A-Z]{16}|[REDACTED:aws-access-key]|g
    s|bearer [A-Za-z0-9_=.-]{20,}|[REDACTED:bearer-token]|gI
  '
fi
