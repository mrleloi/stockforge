---
id: 2026-04-29-002-charter-tier-harness-self-correction
topic: "Charter-tier interrogation — bottleneck attribution, Q&A UX correction, context augmentation, self-correction"
opened_at: 2026-04-29T13:55:00Z
expected_answer_by: 2026-04-30T13:55:00Z
priority: URGENT
related_decisions:
  - D-002
status: partially-answered                  # 4/16 charter-tier answered via AskUserQuestion in same turn
sync_categories:
  - SCOPE
  - DESIGN_THINKING
  - DECISION_ROUTING
  - LANGUAGE
provenance:
  triggered_by: agent-workspace/memory/observations/intent-2026-04-29-UP04-3e294318.md
  source_prompt: human-workspace/user_prompt/20260429_04.txt
  prompt_hash: 3e294318
defer_cycle: 0
charter_tier_split: true
charter_questions: [CHARTER-A1, B1]

answered:
  - id: CHARTER-A1
    answer: "A: Keep current (Tracks 5+8+9 emergent self-correction is sufficient)"
    answered_via: AskUserQuestion
    answered_at: 2026-04-29T14:05:00Z
  - id: B1
    answer: "A: AskUserQuestion ALL bundles, file = audit only"
    answered_via: AskUserQuestion
    answered_at: 2026-04-29T14:05:00Z
  - id: C1
    answer: "D: Defer with metrics first (decide post Track 8a/8b based on retrieval failure rate)"
    answered_via: AskUserQuestion
    answered_at: 2026-04-29T14:05:00Z
  - id: A1
    answer: "B: Agree — harness gap is the primary driver"
    answered_via: AskUserQuestion
    answered_at: 2026-04-29T14:05:00Z
---

# Q&A Bundle — Charter-Tier Interrogation (UP-04 Audit)

## Headline

Source: `human-workspace/user_prompt/20260429_04.txt` — user questions Phase 0 framework after observing S1+S2 drift despite Opus+max effort. 16 questions across 6 clusters; **2 marked CHARTER-tier with NO safe-default** (must pick explicitly via AskUserQuestion, never absorbed via "ok continue").

**Status update post-UP-06 (2026-04-29T15:30Z)**: 4 charter-tier (CHARTER-A1, B1, C1, A1) ANSWERED via `AskUserQuestion`. Remaining 12 questions (A2/B2/C2/C3/D1/D2/D3/E1/E2/E3/E4) are NOT bundled-with-default-fallback anymore (UP-06 amendment). They are DEFERRED until the relevant future track activates and will be re-fired via `AskUserQuestion` in that session — NOT silently default-applied.

DEFERRAL OWNERSHIP (each question moved to `queued-grill-<topic>.md` with explicit `fire_when:`):
- A2 (drift-leading-indicator) → `queued-grill-drift-detection.md` fire_when: `S3 Track 5 hook authoring`
- B2 (charter/SCOPE block-default) → `queued-grill-decision-discipline.md` fire_when: `S5 Track 7 decision-discipline.md`
- C2 (auto-context loading) → `queued-grill-context-loading.md` fire_when: `S5 Track 7 OR Phase 1 if signal emerges`
- C3 (SessionStart bootstrap ceiling) → `queued-grill-context-loading.md` fire_when: same
- D1/D2/D3 (folder structure / wiki / memory tiers) → `queued-grill-knowledge-architecture.md` fire_when: `S5 Track 7 memory-tiers.md authoring`
- E1/E2/E3/E4 (self-detect / promotion / recovery) → `queued-grill-self-correction.md` fire_when: `S5 Track 7 OR S8 Track 9 self-awareness`

**4 most critical questions** mirrored to `AskUserQuestion` UI in same session for immediate interactive answer:
- CHARTER-A1 (new charter principle / Track 10)
- B1 (Q&A UX route)
- C1 (context augmentation route)
- A1 (bottleneck attribution)

The remaining 12 questions are audit-trail-only here; user can answer-by-edit-file at leisure.

Sync categories updated on answer: SCOPE, DESIGN_THINKING, DECISION_ROUTING, LANGUAGE (4/5 — high-value bundle).

---

## Cluster CHARTER-A — Charter Principle / Track 10 (DEDICATED CHARTER BUNDLE)

**Evidence:**
- `human-workspace/user_prompt/20260429_04.txt` lines 7-9: "không có cơ chế để chia nhỏ ra, load cho agent/subagent, cũng như tự self-upgrade các note, learning, thành deterministic, hoặc llm (skill, workflows, etc..). nếu human không trực tiếp prompt thì gần như không tự upgrade và không tự phát hiện được."
- `agent-workspace/memory/agent-notes.md` § AP-S2-3 (false self-attestation, post-audit)
- Orch `agent-notes.md` lessons: pattern observed in 12+ phases.

### CHARTER-A1: Should StockForge Phase 0 explicitly add a "Self-Correcting Harness" charter principle + new Track 10 (auto drift-detect + auto agent-notes promotion to skill/hook)?
- A: Keep current — Tracks 5+8+9 emergent self-correction is sufficient (REV-2 plan, no charter touch)
- B: Add NEW charter principle "P5 — Self-Correcting Harness" + new Track 10 + version bump charter v1.0 → v1.1
- C: Refine existing Track 9 spec to explicitly include auto-promotion-to-skill pipeline (no new charter principle, but expanded Track 9 scope)
- D: open answer
- **NO SAFE DEFAULT** — explicit pick required (Charter-Tier Split Rule)

---

## Cluster A — Bottleneck Attribution

**Evidence:** `agent-workspace/memory/drift-logs/2026-04-29-S2-audit.md` — A1 false-attestation + F1 stale-routing + G1 silent-absorption all on Opus+max-effort.

### A1: Where is the dominant failure source per your read?
- A: Model layer (Opus reasoning insufficient — need fresh-context verifier always)
- B: Agent/harness layer (CLAUDE.md + skills + hooks not enforcing — need more deterministic gates)
- C: Human-input layer (objective goals not concrete enough — need stricter prompt template)
- D: Subagent dispatch layer (not enough fresh-context audits between sessions)
- E: open answer / multi-cause prioritization
- **Default**: B (agent's own assessment per chat diagnosis)

### A2: If you had to pick ONE drift indicator to ALWAYS auto-trigger fresh-context audit, which?
- A: LOC ceiling overrun (>20% above declared budget)
- B: Self-attestation contradicting actual file content (the A1 pattern)
- C: Charter-tier item bundled with sub-charter items (silent absorption)
- D: Spec-as-source butterfly (small spec → many file changes)
- E: open answer
- **Default**: B

---

## Cluster B — Q&A UX Correction (CHARTER QUESTION B1)

**Evidence:** UP-04 lines 3-4: "phải hiển thị ra giao diện q&a do claude code built in cung cấp để human thực sự đọc và verify, chọn phương án (có thể phần lớn là suggest), hoặc đưa ra discuss, chứ hiện tại nhiều q&a và quick answer làm agent bị over và thường có xu hướng chọn default suggest thay vì tự đưa ra decision."

### B1: New default Q&A UX route (CHARTER-tier — no safe default):
- A: Switch entirely to Claude Code's `AskUserQuestion` — file-based Q&A becomes archive-only
- B: Hybrid — `AskUserQuestion` for ≤4 questions / charter-tier; file-based for ≥5 questions / non-charter (cognitive-load split)
- C: `AskUserQuestion` PRIMARY for all bundles; file write only as audit trail (not the input surface)
- D: Keep file-based but add MANDATORY notification + one-line summary + "press X to open" shortcut
- E: open answer
- **NO SAFE DEFAULT** — explicit pick required

### B2: Hard rule blocking default-acceptance for charter/SCOPE-tier?
- A: Yes — charter/SCOPE-tier MUST require explicit letter pick, no default-on-silence allowed (already in Charter-Tier Split Rule)
- B: Yes AND extend to all DECISION_ROUTING-tier (more conservative)
- C: No — defaults are fine if questions are well-designed; the bug was Q-S5 framing not the default mechanism
- D: open answer
- **Default**: A

---

## Cluster C — Context Augmentation

**Evidence:** UP-04 line 5: "hệ thống hiện tại đã đủ chưa, dựa trên những learning lession đã biết... có cần thiết phải bổ sung chúng bằng những layer khác, tool khác không (như các knowledge graph repo, các rag local...)... hiện mới chỉ có mcp tool serena, mcp context7 và hệ thống agent memory chúng ta tự build."

### C1: Augmentation route (Phase 0 plan amendment):
- A: Add local RAG (chromadb/lancedb) over `agent-workspace/memory/**` — embedding search across decisions/sessions/notes
- B: Add knowledge-graph (Obsidian wikilinks → graph DB; e.g., DuckDB+Neo4j-lite) — query by entity/concept relations
- C: Both A+B — RAG for fuzzy similarity + KG for structured navigation (heavier Phase 0 scope)
- D: Neither — first prove insufficiency with metrics post-Track-8a; defer augmentation to Phase 1+
- E: open answer
- **Default**: D (mid-conservative — agent's recommended; prove first)

### C2: Auto-context loading mechanism:
- A: UserPromptSubmit hook auto-greps + injects top-5 relevant files (cheap, deterministic)
- B: LLM-based context-selector subagent (per task, fresh ctx, returns file list) — accurate, more cost
- C: Keep manual just-in-time per session protocol (no auto-injection)
- D: Hybrid — auto-inject for routine SessionStart; LLM-selector for complex ad-hoc tasks
- E: open answer
- **Default**: D

### C3: SessionStart auto-loaded bootstrap token ceiling:
- A: ≤6K (msmdp aggressive)
- B: ≤10K (current spec target per SYNTHESIS § 5.1)
- C: ≤20K (allows mistake-log + agent-notes inline)
- D: Adaptive (PLAN ≤8K / IMPL ≤15K / VERIFY ≤6K)
- E: open answer
- **Default**: D

---

## Cluster D — Folder + Spec-Driven Obsidian Scalability

**Evidence:** UP-04 lines 6-7: "liệu thay đổi cấu trúc folder, cùng với cách tiếp cận spec-driven obsidian đang hướng tới có thực sự ổn với agent/subagent khi dự án kéo dài nhiều phase, nhiều session, nhiều tracking memory/log?"

### D1: Sessions folder scalability across 5 phases × ~30 sessions = 150+ files:
- A: Add phase-tier subfolders (`sessions/phase-0/`, `phase-1/`...) — done at Phase 1 entry
- B: Add `YYYY-MM/` buckets across all append-only dirs — auto-archive >90 days
- C: Keep flat; rely on naming + grep — Obsidian backlinks + recency-by-mtime enough
- D: Migrate to SQLite-indexed (sync-tracker.db extension) — flat files but query by tag/phase/recency
- E: open answer
- **Default**: A

### D2: Obsidian raw/wiki at 200+ entities:
- A: Yes, current Karpathy raw/wiki proven; just need disciplined index updates
- B: Add tiered wiki/ — `wiki/tier1-canonical/`, `wiki/tier2-derived/`, `wiki/tier3-thesis/`
- C: Replace with proper KG (DuckDB+pgvector? RDF triplestore?)
- D: open answer
- **Default**: A

### D3: Memory tiers — codify Tier 1 (immutable always-loaded) / Tier 2 (just-in-time) / Tier 3 (explicit pull)?
- A: Yes — add to Track 7 constitution as `memory-tiers.md`
- B: Yes AND add hook to enforce (deny load of Tier 3 without explicit `/pull` command)
- C: Already implicit in CLAUDE.md + autonomous-protocol.md — no new artifact
- D: open answer
- **Default**: A

---

## Cluster E — Self-Detection + Self-Upgrade

**Evidence:** UP-04 lines 7-10 — full self-detect + auto-upgrade discussion + orch agent-notes failure mode.

### E1: How agents auto-detect drift WITHOUT human prompt:
- A: Per-task DA-rule (re-read spec every 5 steps) + checkpoint-vs-current diff hook
- B: Mid-session `/session-verify` auto-fired by Stop hook every N tool calls
- C: Fresh-context drift-auditor subagent dispatched mid-session at random/triggered intervals
- D: All A+B+C (defense in depth)
- E: open answer
- **Default**: D

### E2: Frequency of agent-notes → skill/hook promotion:
- A: Phase-boundary only (manual review by promotion subagent, opus, fresh ctx)
- B: Per-session-end Stop hook scans new agent-notes; dispatches subagent if ≥3 similar entries
- C: Continuous — every new note triggers similarity check vs existing skills/hooks; suggest if pattern repeats
- D: open answer
- **Default**: B

### E3: Promotion target priority order:
- A: New skill in `.claude/skills/<name>/`
- B: New hook script in `scripts/hooks/`
- C: Update existing constitution file
- D: All three are valid; promotion subagent decides per pattern type — but route MUST be **deterministic+hook FIRST, skill SECOND, charter LAST** (cheapest first)
- E: open answer
- **Default**: D

### E4: Recovery flow if drift auto-detected mid-session:
- A: HALT immediately; emit ALERT; require human resume
- B: HALT only if charter-tier; SOFT-WARN otherwise
- C: Open Q&A bundle with detected drift + 3 remediation options; let human pick async
- D: Auto-revert to last clean checkpoint + emit notification (no Q&A)
- E: open answer
- **Default**: C

---

## Answer Section (human fills below)

> Reply inline as `QN: <option-letter>` or free prose. Skip to accept defaults (NOT applicable to CHARTER-A1 + B1 which require explicit pick).
> Charter-tier 4 most-critical (CHARTER-A1, B1, C1, A1) WERE answered via `AskUserQuestion` UI 2026-04-29T14:05Z — recorded in frontmatter `answered:` array. This file is now AUDIT TRAIL.
> When user answers remaining 12 (A2/B2/C2/C3/D1/D2/D3/E1/E2/E3/E4), MOVE this file to `human-workspace/q-and-a/answered/` to trigger processing.

- CHARTER-A1: A (Keep current — Tracks 5+8+9 emergent self-correction sufficient) ✓ via AskUserQuestion
- A1: B (Agree — harness gap is primary driver) ✓ via AskUserQuestion
- A2: 
- B1: A (AskUserQuestion ALL bundles, file = audit only) ✓ via AskUserQuestion
- B2: 
- C1: D (Defer with metrics first) ✓ via AskUserQuestion
- C2: 
- C3: 
- D1: 
- D2: 
- D3: 
- E1: 
- E2: 
- E3: 
- E4: 

## Notes from human (free text, optional)


