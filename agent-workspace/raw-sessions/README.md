# raw-sessions/ — Claude Code Session Transcript Archive

> **Created**: 2026-04-29 per UP-05 Q3.1=A (user confirmed via AskUserQuestion).
> **Owner**: agent (write) + Track 5 SessionEnd hook (auto-export).

## Purpose

Persist verbatim (sanitized) Claude Code session transcripts as raw source-of-truth knowledge — for tracing, deepdive, debugging, brainstorming, self-upgrade signal mining. Especially valuable in autonomous mode when agents/subagents trade context continuously.

## Naming

`<YYYY-MM-DD>-session-<N>.md` — date + session number. Multi-export same session: append `-<seq>` (e.g. `2026-04-29-session-2-1.md`, `…-2-2.md` for incremental exports during long autonomous run).

## Frontmatter Schema (BINDING per UP-05 Q3.3=A)

```yaml
---
id: <YYYY-MM-DD-session-N>           # matches filename
session_n: <N>
exported_at: <ISO-8601 UTC>
related_decisions: [D-NNN, ...]      # extracted from session log
related_observations: [obs-IDs, ...]
related_qa_bundles: [bundle-IDs, ...]
token_count_self_track: <N>           # from .transcript-tokens
hash: <sha256[:8]>                    # idempotency on re-export
sanitization:
  redacted_secrets: <count>
  stripped_chatter_lines: <count>
---
```

## Sanitization (BINDING per UP-05 Q3.4=A)

Pre-export pipeline (Track 5 hook `session-export-raw.sh`):
1. **Redact secrets** — `_redact_secrets.sh` regex (Anthropic API key / GitHub PAT / paths-with-creds / .env-like patterns)
2. **Strip chatter** — `cleanText` regex (system-reminder blocks / command-name tags / task-notification metadata / harness chatter)
3. Write to `<filename>` with the sanitized content + frontmatter prepended

## Indexing (UP-05 Q3.3=A: minimalist)

- Frontmatter is canonical. Discovery via `Glob agent-workspace/raw-sessions/*.md` + `Grep frontmatter fields`.
- Wikilinks + SQLite extension table DEFERRED to Phase 1+ (decide based on retrieval-failure metrics from Track 8a Confidence Score, post-S6).

## Trigger (UP-05 Q3.2=A: SessionEnd hook)

Track 5 deliverable `scripts/hooks/session-export-raw.sh` (S3) auto-fires on `Stop` / `SessionEnd` event. No manual `/export` call needed.

If hook fails (e.g., harness mid-crash), agent on next SessionStart can detect missing export by:
- Compare `agent-workspace/memory/sessions/<latest>.md` mtime vs `raw-sessions/<corresponding-export>.md` mtime
- If session log newer than export → re-fire hook OR notify human

## Permissions

- `Write(agent-workspace/raw-sessions/**)` — ALLOW (added 2026-04-29 in `.claude/settings.json`)
- `Edit(agent-workspace/raw-sessions/**)` — ALLOW
- After a transcript is written, sanitization re-run is allowed but should be RARE (only if regex updated). Log every re-sanitize in `agent-workspace/memory/observations/raw-session-resanitize-<id>.md`.

## What does NOT belong here

- Decision artifacts (`agent-workspace/memory/decisions/`)
- Session structured logs (`agent-workspace/memory/sessions/`)
- Observation files (`agent-workspace/memory/observations/`)
- Q&A bundles (`human-workspace/q-and-a/`)

This dir is RAW VERBATIM (post-sanitize) only. Curated artifacts live in their respective dirs.

## Future (Phase 1+)

If retrieval-failure metrics show grep-based discovery fails, consider:
- Wikilink injection from frontmatter
- SQLite extension table `raw_sessions(id PK, path, related_decisions[], hash, token_count, sanitization_meta)` in `agent-workspace/memory/sync-tracker/sync-tracker.db`
- Embedding-based RAG layer (chromadb/lancedb) over this dir + `memory/`

These are deferred per UP-04 C1 = D (defer with metrics).
