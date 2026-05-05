---
name: session-memory-l0-l1
description: Extract structured memories (L0 quick metadata + L1 deep) from a Claude Code session JSONL transcript. L0 is pure regex (file paths, commands, errors, failures incl. Vietnamese phrases, next step). L1 ships the prompt builder + response parser + 15+35 head/tail windowing — caller dispatches the LLM (no auto-invoke in Phase 0). Plus cleanText harness-stripper + TranscriptCache (mtime+size dual-check + LRU). Use when ingesting a session for memory promotion, computing what files/commands/failures the session touched, or preparing an offline LLM extraction.
allowed-tools: [Read, Glob, Grep, Bash]
---

# Session Memory L0/L1 Extraction

> **Status**: Phase 0 library port per D-007 + D-002 REV-2 § A.
> **Source repo**: `C:/htdocs/orch-starter/claude-sessions/src/memory/` (TS originals).
> **Module**: `packages/observability/`.

## Purpose

Transform a raw Claude Code session JSONL transcript into structured signals:

- **L0 (deterministic)**: file paths touched / shell commands run / error messages / failure phrases / inferred next step. Pure regex. Runs in milliseconds; safe to fire on every SessionEnd.
- **L1 (LLM-mediated)**: structured memory candidates across 6 categories (profile / preferences / entities / events / cases / patterns). Caller dispatches the LLM with the provided prompt; parser validates the response.
- **TranscriptCache**: speeds repeat reads of the same transcript (mtime + size dual-check; LRU eviction; full re-parse on grow/shrink/rewrite).
- **cleanText**: strips 9 Claude Code harness wrapper tags before extraction so memories aren't polluted with system-reminder / command-name / task-notification boilerplate.

## When to Use

1. **SessionEnd ingestion** — port a just-completed session's JSONL into the memory layer (Phase 1+ wire-in).
2. **Calibration data prep** — need to know which files/commands/failures the session touched, no LLM call needed.
3. **Offline L1 extraction** — assemble the LLM prompt, dispatch via your own client, feed response back through the validator.
4. **Repeat-read scenario** — telemetry hooks reading the same transcript multiple times benefit from `TranscriptCache`.

## When NOT to Use

1. **Real-time** during the active session — the JSONL is mid-write; use post-SessionEnd.
2. **Token usage / compaction telemetry** — out-of-scope. See `Claude-Code-Agent-Monitor/server/lib/transcript-cache.js` for that.
3. **Sentiment / market analysis on session content** — wrong layer. This module does Claude Code session telemetry only, not stock-domain analysis.

## API Quick Reference

```python
from packages.observability import (
    # L0 — pure regex
    extract_l0_from_jsonl,        # parse JSONL lines → L0Data
    extract_l0_from_messages,     # if you already have messages
    extract_file_paths,
    extract_commands,
    extract_errors,
    extract_failures,             # incl. Vietnamese phrases per D-002 REV-2 § A
    extract_next_step,
    # L1 — prompt + parser + windowing
    build_extraction_prompt,      # str → feed to LLM caller
    parse_llm_response,           # validate response → list[MemoryCandidate]
    extract_messages_from_jsonl,  # 15+35 head/tail windowing
    HEAD_COUNT, TAIL_COUNT,
    # Caching + cleaning
    TranscriptCache,
    clean_text,
)
```

## Examples

### Example 1 — L0 quick metadata

```python
from pathlib import Path
from packages.observability import extract_l0_from_jsonl

lines = Path("session.jsonl").read_text(encoding="utf-8").splitlines()
l0 = extract_l0_from_jsonl(lines, project="stockforge")

print(l0["files"])      # files touched
print(l0["commands"])   # bash commands run
print(l0.get("failures", []))  # incl. "không hoạt động" / "thất bại" etc.
print(l0.get("next_step"))     # last assistant's next step marker
```

### Example 2 — L1 prompt build for offline LLM dispatch

```python
from packages.observability import (
    build_extraction_prompt,
    extract_messages_from_jsonl,
    parse_llm_response,
)

# 15+35 head/tail windowing automatically applied for sessions > 50 messages.
messages = extract_messages_from_jsonl("session.jsonl")
prompt = build_extraction_prompt(messages)

# Dispatch via your own client (Anthropic SDK, claude CLI, batch API, etc.).
response_text = my_llm_client.complete(prompt)

# Validate + filter.
candidates = parse_llm_response(response_text)
for c in candidates:
    print(c["category"], "/", c["name"], "—", c["content"])
```

### Example 3 — TranscriptCache for repeat reads

```python
from packages.observability import TranscriptCache, extract_l0_from_jsonl

def parse_l0(content: str):
    return extract_l0_from_jsonl(content.splitlines(), project="stockforge")

cache = TranscriptCache(parse_l0, max_entries=100)

# First call parses; subsequent calls hit cache unless mtime+size changed.
l0 = cache.extract("session.jsonl")
l0_again = cache.extract("session.jsonl")  # cache hit; parser not invoked

print(cache.size)     # 1
print(cache.stats())  # {"entries": 1, "paths": [...]}
```

## Inputs

- **Transcript path**: absolute path to a Claude Code JSONL transcript.
- **Project name**: identifier (string). Used as `L0Data.project` field. Stockforge canonical: `"stockforge"`.

## Outputs

| Function | Returns |
|---|---|
| `extract_l0_from_jsonl(lines, project)` | `L0Data` — TypedDict with files / commands / errors / failures / next_step |
| `extract_messages_from_jsonl(path)` | `list[ChatMessage]` — windowed (HEAD+TAIL=50) |
| `build_extraction_prompt(messages)` | `str` — prompt ready for LLM dispatch |
| `parse_llm_response(text)` | `list[MemoryCandidate]` — validated; invalid candidates dropped |
| `clean_text(text)` | `str` — stripped of 9 harness wrapper tags |
| `TranscriptCache(parser).extract(path)` | parser's return type or `None` |

## Source Schema Pointer

- D-007 — `agent-workspace/memory/decisions/007-track-8b-memory-l0-l1-extraction.md`
- D-002 REV-2 § A — original Track 8b spec
- TS source — `C:/htdocs/orch-starter/claude-sessions/src/memory/{extract-l0,extract-l1,snapshot}.ts`
- TranscriptCache origin — `C:/htdocs/orch-starter/Claude-Code-Agent-Monitor/server/lib/transcript-cache.js`

## Anti-Patterns

1. **Don't auto-invoke L1 from inside a hook**. L1 dispatch is Phase 1+ via Anthropic SDK or claude CLI. Hooks call L0 only — fast, deterministic.
2. **Don't skip cleanText**. Without it, every L0 file-path extractor will pull paths out of `<system-reminder>` blocks (false positives) and L1 prompts will be polluted with harness boilerplate.
3. **Don't parameterize FAILURE_PATTERNS at runtime**. The 11 patterns (RU + EN + VN) are stockforge-binding per D-002 REV-2 § A § B-8. Modify by editing `extract_l0.py` and running the test suite.
