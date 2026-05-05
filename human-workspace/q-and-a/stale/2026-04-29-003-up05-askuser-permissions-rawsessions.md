---
id: 2026-04-29-003-up05-askuser-permissions-rawsessions
topic: "UP-05 — AskUserQuestion limit / permission auto-grant / session-export-as-raw"
opened_at: 2026-04-29T14:55:00Z
expected_answer_by: 2026-04-30T14:55:00Z
priority: NORMAL
related_decisions:
  - D-002
status: partially-answered          # 4/8 surfaced via AskUserQuestion in same turn
sync_categories:
  - DESIGN_THINKING
  - SCOPE
  - DECISION_ROUTING
provenance:
  triggered_by: agent-workspace/memory/observations/intent-2026-04-29-UP05.md
  source_prompt: human-workspace/user_prompt/20260429_05.txt
  prompt_hash: ef1dbb2d
defer_cycle: 0
research_subagent: claude-code-guide (2026-04-29T14:50Z)

answered:
  - id: Q3.1
    answer: "A: agent-workspace/raw-sessions/<YYYY-MM-DD-session-N>.md"
    answered_via: AskUserQuestion
    answered_at: 2026-04-29T15:05:00Z
  - id: Q3.2
    answer: "A: SessionEnd hook (Track 5 deliverable)"
    answered_via: AskUserQuestion
    answered_at: 2026-04-29T15:05:00Z
  - id: Q3.3
    answer: "A: YAML frontmatter only (defer richer indexing to Phase 1+)"
    answered_via: AskUserQuestion
    answered_at: 2026-04-29T15:05:00Z
  - id: Q3.4
    answer: "A: Full sanitize (B+C — redact secrets + strip system-reminders/harness chatter)"
    answered_via: AskUserQuestion
    answered_at: 2026-04-29T15:05:00Z

pending_in_file:
  - Q2.1   # Skill-tool autonomous policy — default B (supervised-only) applies if not answered by 2026-04-30T14:55Z
  - Q4.1   # Track plan impact — default A (amend Track 5) applies if not answered
---

# Q&A Bundle — UP-05 (AskUserQuestion / Permissions / Raw Sessions)

## Headline

User asks 3 operational concerns: (1) bypass `AskUserQuestion` 4-question limit, (2) auto-grant permissions for autonomous run, (3) session-export-as-raw integration. **Q1 + Q2 answered in chat + already actioned**; Q3 needs design picks (4 questions via `AskUserQuestion`).

**Status update post-UP-06 (2026-04-29T15:30Z)**: 4 design Q (Q3.1-Q3.4) ANSWERED via `AskUserQuestion`. Remaining 2 (Q2.1, Q4.1) re-classified per UP-06 no-silent-default rule:
- **Q2.1** (Skill-tool autonomous policy) → moved to `queued-grill-autonomous-prep.md` with `fire_when: S5 Track 7 autonomous-protocol.md authoring`. Will be re-fired via `AskUserQuestion` THEN.
- **Q4.1** (Track plan impact) → CLOSED-IMPLICIT. The Q3.* design picks (raw-sessions location + trigger + format + sanitization) ARE the Track 5 amendment. No separate decision needed; Q4.1 was redundant.

---

## Cluster Q1 — AskUserQuestion 4-question limit (ANSWERED IN CHAT)

**Research finding** (`claude-code-guide` subagent dispatch):
- Limit is intentional design (`maxItems: 4` in JSONSchema). NO config flag / env var to override.
- Workarounds ranked:
  - **D Hybrid (RECOMMENDED)**: 4 most-critical via `AskUserQuestion` + remaining via file-based async
  - C File-based (existing `qa-escalation` design — current S2 ship)
  - B Sequential burst (4 → wait → 4) — multi-turn UX
  - E Custom MCP server with rich-form UX — overkill Phase 0+
  - A Burst-in-1-turn — ugly UX, not recommended
  - F External tool (Telegram/Streamlit) — out of scope until Phase 4+
- Codified workflow refinement in `qa-escalation/SKILL.md` (multi-batch pattern).

**No question to user — reported as resolved.**

---

## Cluster Q2 — Auto-grant Permissions (PARTIAL FIX APPLIED)

**Research finding**: `--dangerously-skip-permissions` (alias `--permission-mode bypassPermissions`):
- BYPASSES: Read/Edit/Write/Bash/WebFetch/MCP tool prompts
- DOES NOT BYPASS:
  - Writes to `.git`, `.vscode`, `.idea`, `.husky`, `.claude/` (except `commands/agents/skills` subdirs) — by Anthropic design
  - Writes to `.gitconfig`, `.bashrc`, `.zshrc`, `.mcp.json`, `.claude.json`
  - Skill tool execution (always prompts)
  - PreToolUse hooks returning `deny`
- Hooks `{decision: approve}` does NOT override permission system

**Fix applied in this turn**:
- Added `"defaultMode": "bypassPermissions"` to `.claude/settings.json` permissions block.
- Existing `Edit(.claude/settings.json)` in allow list helps for self-edits.

**Hard limits remaining** (Anthropic-designed, cannot bypass):
- `Skill` tool ALWAYS prompts → if skills are needed in autonomous loop, this is a structural blocker
- `.git`, `.husky`, `.vscode`, `.idea` writes still prompt → batch any such changes for end-of-session manual sign-off
- PreToolUse hooks (Track 5) must NOT return non-zero codes → audit hook scripts when wired in S3

### Q2.1: For autonomous run, how to handle remaining `Skill` tool prompts?
- A: Avoid Skill calls in autonomous mode (replace skills with inline procedures + agent dispatch)
- B: Run Skill calls only in SUPERVISED mode; gate autonomous loops to NOT call skills
- C: Batch Skill calls at session-start under explicit user approval (one-time per session)
- D: Accept the friction — autonomous loop pauses on Skill prompt, waits for user; not deal-breaker
- E: open answer
- **Default**: B (safer; aligns with "autonomous mode activates after Track 7" in current-execution.md)

---

## Cluster Q3 — Session-Export-as-Raw Integration (NEW DESIGN — 4 QUESTIONS VIA `AskUserQuestion`)

**User proposal** (UP-05 §2): Claude Code session chat/runtime IS source-of-truth for both agent + human; valuable for tracing, decision-making, debugging, brainstorming. Use `/export` → save .txt (treat as .md). Organize/link/reference raw store. Especially valuable in autonomous mode where agents/subagents trade context.

### Q3.1: Where do exported session transcripts live?
- A: `agent-workspace/raw-sessions/<YYYY-MM-DD-session-N>.md` — agent-owned, agent-managed
- B: `obsidian-vault/raw/sessions/<YYYY-MM-DD-session-N>.md` — append to existing immutable raw vault
- C: `human-workspace/raw-sessions/<file>.md` — human-owned audit trail
- D: Split — agent exports to `agent-workspace/raw-sessions/`, then sandwich-verifier promotes selected sessions to `obsidian-vault/raw/sessions/` post-review
- E: open answer
- **Default**: A (simplest; respects current workspace dualism contract)

### Q3.2: Auto-export trigger?
- A: SessionEnd hook auto-fires `/export` equivalent (via Track 5)
- B: Manual on-demand only (user runs `/export` when wanted)
- C: Auto-export on every checkpoint write (so each S close auto-exports)
- D: Hourly cron during autonomous mode (frequent snapshots)
- E: open answer
- **Default**: A (deterministic; aligns with Track 5 hook port plan)

### Q3.3: Indexing + linking pattern?
- A: YAML frontmatter only (id, session_n, related_decisions, related_observations, hash)
- B: Obsidian wikilinks ([[D-002]], [[2026-04-29-session-2]]) — auto-cross-referenced
- C: SQLite index (sync-tracker.db extension table `raw_sessions`)
- D: All three — frontmatter for canonical ID + wikilinks for visual + SQLite for query
- E: open answer
- **Default**: A (start minimalist; B+C added in Phase 1+ if signal emerges)

### Q3.4: Privacy/redaction before export?
- A: Verbatim export (no redaction)
- B: Redact secrets via Track 5 `_redact_secrets` hook only
- C: Strip system-reminders + harness chatter (claude-sessions `cleanText` pattern from Track 8b)
- D: Both B+C — full sanitization pipeline before write
- E: open answer
- **Default**: D (max safety; matches Track 8b L0/L1 extraction discipline)

---

## Cluster Q4 — Implications for Track Plan

### Q4.1: Should Q3 (raw-sessions integration) become a NEW track in Phase 0 plan, or amend existing Track 5/8b?
- A: Amend Track 5 — add SessionEnd auto-export hook; Track 8b L0/L1 already handles cleanText so no new artifact
- B: Amend Track 8b — extend memory L0/L1 spec to include full transcript export, not just L0/L1 summaries
- C: NEW Track 11 — "Session Transcript Knowledge Base" (separate concern from L0/L1 summaries)
- D: open answer
- **Default**: A (smallest scope expansion; reuses existing Track 5 hook infrastructure)

---

## Answer Section (human fills below)

> Reply inline as `QN: <option-letter>` or free prose. Skip to accept defaults.
> Q3.1-Q3.4 ALSO surfaced via `AskUserQuestion` UI in same turn for explicit pick.
> When done, MOVE this file to `human-workspace/q-and-a/answered/`.

- Q2.1:        DEFERRED (queued-grill-autonomous-prep.md; fire_when S5 Track 7 — NOT default-applied)
- Q3.1: A (agent-workspace/raw-sessions/) ✓ via AskUserQuestion
- Q3.2: A (SessionEnd hook) ✓ via AskUserQuestion
- Q3.3: A (YAML frontmatter only) ✓ via AskUserQuestion
- Q3.4: A (Full sanitize B+C) ✓ via AskUserQuestion
- Q4.1:        CLOSED-IMPLICIT (subsumed by Q3.* picks — Track 5 amendment is the answer)

## Notes from human (free text, optional)


