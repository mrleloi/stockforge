# Lite-Detect Patterns — Trivial Whitelist Reference

> Used by `user-prompt-intake/SKILL.md` Step 1.
> Match is case-insensitive, after `.strip()`.

## Whitelist (canonical)

### English

| Pattern | Notes |
|---|---|
| `continue` | Resume current execution |
| `go` | Same |
| `next` | Move to next task in TaskList |
| `yes`, `y` | Affirmative reply to last agent question |
| `ok`, `okay`, `k`, `kk` | Acknowledgment |
| `no`, `n` | Negative reply (CAUTION: re-classify if last agent question was scope-affecting) |
| `stop` | Pause work; wait for next prompt |
| `pause` | Same |
| `resume` | Resume from pause |
| `cancel` | Abort current dispatch |

### Vietnamese

| Pattern | Notes |
|---|---|
| `ok rồi`, `được`, `được rồi`, `xong` | Acknowledgment / "done" |
| `tiếp`, `tiếp tục`, `tiếp đi`, `đi tiếp` | "Continue" |
| `đúng`, `đúng rồi` | "Correct" / affirmative |
| `không`, `kh` | Negative (CAUTION re-classify like English) |

### Mixed

| Pattern | Notes |
|---|---|
| `oki`, `okela` | Slang OK |
| `next move` | Continue |

## Structural matches

- Empty / whitespace-only → TRIVIAL
- Single emoji (1-3 unicode emoji chars total) → TRIVIAL
- Single digit (`1`, `2` … `9`, `0`) → TRIVIAL with note "user picked option"
- Single ASCII char (excluding letters above) → TRIVIAL with note

## Edge cases

### Looks trivial but isn't

- `"ok stop"` → NOT TRIVIAL (compound; "stop" overrides "ok"; classify as DIRECTIVE)
- `"continue but ..."` → NOT TRIVIAL (compound; classify normally)
- `"yes do X"` → NOT TRIVIAL (compound; classify as DIRECTIVE)
- `"không, làm Y"` → NOT TRIVIAL (correction + new directive; classify as CORRECTION)

Rule of thumb: if length > one of the whitelist tokens, treat as non-trivial.

### Looks non-trivial but is

- `"ok rồi. continue"` → TRIVIAL (the user explicitly said this is the "ack and proceed" idiom in `human-workspace/user_prompt/20260429_03.txt`)
- `"ok continue"` → TRIVIAL (same idiom)

These special idioms are documented per-user in `agent-workspace/memory/agent-notes.md` under "User communication idioms."

## "n" / "no" / "không" caveat

A bare `no` after the agent has just asked a charter/scope question MUST be re-classified — dispatching the subagent. The reason: a bare "no" is not a trivial reply when it potentially reverses an in-progress decision. The subagent decides if the "no" is acknowledgment or rejection.

Rule: if the previous agent message was ≥ ARCH-tier question, classify EVEN IF on whitelist.

## Whitelist amendment protocol

To add a pattern:
1. Observe the pattern occurring ≥3 times across separate sessions.
2. Open a Q&A bundle with proposal: `Q-LX1: Add "<pattern>" to trivial whitelist?`
3. User confirms → update this file + bump cache key in main SKILL.md.
4. Do NOT silently extend whitelist.
