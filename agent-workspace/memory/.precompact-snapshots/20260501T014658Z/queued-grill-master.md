---
observation_id: queued-grill-master
type: deferred-grill-queue
created_at: 2026-04-29T15:30:00Z
last_updated: 2026-04-29 (S15 PLAN — 9 Track-7 triggers fired+closed)
related_user_prompt: human-workspace/user_prompt/20260429_06.txt (chat correction, not file)
policy_basis: agent-notes.md § "2026-04-29 (UP-06) — NO Silent File-Defaults"
---

# Queued Grill — Master Index

> Per UP-06 amendment: questions agent thinks "would be nice to ask but not blocking now" do NOT get bundled with file-only-default fallback. Instead they queue here with explicit `fire_when:` trigger. The relevant future session re-grills via `AskUserQuestion` when condition activates.
>
> SessionStart hook (Track 5 deliverable, S3) MUST read this file + check if any `fire_when:` trigger matches active phase/track. If yes → re-fire via `AskUserQuestion(4)` multi-batch.

## How sessions consume this file

```
On SessionStart (or mid-session pre-track-activate):
1. Read this file's table-of-contents
2. For each entry: parse `fire_when:`
3. If fire_when matches active context → load the question detail + fire AskUserQuestion(≤4 per call)
4. Mark entry as `status: fired` with `fired_at` + `bundle_ref` to the AskUserQuestion outcome
5. Once answered: append `answer:` field + `closed_at`
```

---

## Active Queue

### Q-A2 — Drift Leading Indicator Auto-Trigger

- **fire_when**: S3 Track 5 hook authoring (specifically `drift-signals-D1-D8.sh`)
- **status**: closed
- **fired_at**: 2026-04-29T15:00:00Z (S3 SessionStart, via AskUserQuestion)
- **closed_at**: 2026-04-29T15:30:00Z
- **source**: `human-workspace/q-and-a/pending/2026-04-29-002-charter-tier-harness-self-correction.md` cluster A
- **question**: If you had to pick ONE drift you observed in S1/S2 as the leading indicator that should ALWAYS auto-trigger fresh-context audit, which is it?
- **options**: A: LOC ceiling overrun (>20% above declared budget) / B: Self-attestation contradicting actual file content / C: Charter-tier item bundled with sub-charter items (silent absorption) / D: Spec-as-source butterfly / E: open answer
- **why-needed-in-S3**: drives which signal is wired as the highest-priority alert in `drift-signals-D1-D8.sh`
- **answer**: A (user said "follow your recommend"; agent picked A based on highest empirical firing rate at S2 — qa-escalation 242 + grill-maximization 187 vs ceiling 150). Encoded as D1 (PRIMARY) in `scripts/hooks/drift-signals-D1-D8.sh` with severity HIGH at >20% overrun. B/C/D land as D2/D3/D4 secondary signals in same script.
- **smoke-test-result**: 24 D1 violations detected on first dry-run (pre-existing skills + commands bloat — write-a-skill 163, postgres-pgvector 276, devils-advocate command 250, drift-check 209, master-plan 201, etc.). To be addressed in Track 6 (skill progressive-disclosure refactor) per borrow-list A-12.

### Q-B2 — Hard Block Default for Charter/SCOPE-tier?

- **fire_when**: S5 Track 7 `decision-discipline.md` authoring → fired S15 PLAN 2026-04-29
- **status**: closed
- **fired_at**: 2026-04-29 (S15 PLAN Batch 1)
- **closed_at**: 2026-04-29 (S15 PLAN Batch 1, same turn)
- **source**: bundle 002 cluster B
- **question**: Hard rule blocking default-acceptance for charter/SCOPE-tier?
- **options**: A: Yes, charter/SCOPE-tier MUST require explicit letter pick (already partial in Charter-Tier Split Rule) / B: Yes AND extend to DECISION_ROUTING-tier / C: No, defaults are fine if questions well-designed / D: open answer
- **answer**: A (Recommended) — charter/SCOPE-tier MUST require explicit letter pick. Default-acceptance only allowed for IMPL-tier or below. To be codified in `proposals/decision-discipline.md` § Tier-vs-default-acceptance during S16 IMPL.
- **why-needed-in-S5**: codifies in `decision-discipline.md` whether the hard-block extends beyond charter

### Q-C2 — Auto-Context-Loading Mechanism

- **fire_when**: S5 Track 7 `autonomous-protocol.md` authoring OR Phase 1 if signal emerges → fired S15 PLAN 2026-04-29
- **status**: closed
- **fired_at**: 2026-04-29 (S15 PLAN Batch 2)
- **closed_at**: 2026-04-29 (S15 PLAN Batch 2, same turn)
- **source**: bundle 002 cluster C
- **question**: Should agents have a "minimum context" auto-loader hook, OR keep manual just-in-time loading?
- **options**: A: UserPromptSubmit hook auto-greps + injects top-5 relevant files (cheap, deterministic) / B: LLM-based context-selector subagent / C: Keep manual just-in-time / D: Hybrid (auto for routine SessionStart; LLM-selector for complex) / E: open answer
- **answer**: D (Recommended in S15 reframe) — Hybrid: auto for routine SessionStart; LLM-selector for complex. To be codified in `proposals/autonomous-protocol.md` § Context-loading mechanism during S16 IMPL.

### Q-C3 — SessionStart Bootstrap Token Ceiling

- **fire_when**: S5 Track 7 `autonomous-protocol.md` authoring → fired S15 PLAN 2026-04-29
- **status**: closed
- **fired_at**: 2026-04-29 (S15 PLAN Batch 2)
- **closed_at**: 2026-04-29 (S15 PLAN Batch 2, same turn)
- **source**: bundle 002 cluster C
- **question**: Target ceiling for SessionStart auto-loaded bootstrap?
- **options**: A: ≤6K (msmdp aggressive) / B: ≤10K (current spec target) / C: ≤20K (allows mistake-log + agent-notes inline) / D: Adaptive (PLAN ≤8K / IMPL ≤15K / VERIFY ≤6K) / E: open answer
- **answer**: D (Recommended) — Adaptive: PLAN ≤8K / IMPL ≤15K / VERIFY ≤6K. To be codified in `proposals/autonomous-protocol.md` § Bootstrap ceiling per session type during S16 IMPL.

### Q-D1 — Sessions Folder Scaling

- **fire_when**: Phase 1 entry (when S20+ approaches in any phase)
- **status**: closed
- **fired_at**: 2026-04-30 (S24 entry AskUserQuestion bundle Q2)
- **closed_at**: 2026-04-30 (same turn)
- **source**: bundle 002 cluster D
- **question**: Does the flat-tree `agent-workspace/memory/sessions/` scale across 5 phases × ~30 sessions = 150+ files?
- **options**: A: Add phase-tier subfolders (sessions/phase-N/) / B: YYYY-MM/ buckets across all append-only dirs + auto-archive >90 days / C: Keep flat; rely on naming + grep / D: Migrate to SQLite-indexed (sync-tracker.db extension) / E: open answer
- **answer**: C (Recommended) — Keep flat; rely on naming + grep. YYYY-MM-DD-session-N.md naming carries phase implicitly via date; Bash glob handles ~1000 files comfortably. Migrate to SQLite only when >500 sessions actually degrade performance. Codified as `sync-039` confirmed-aligned in `sync-state.md`. re_verify_when: sessions/ count exceeds 200 OR grep performance painful.

### Q-D2 — Obsidian Wiki Scaling at 200+ Entities

- **fire_when**: Phase 1 entry OR when wiki/ count > 100 entities (whichever first)
- **status**: closed
- **fired_at**: 2026-04-30 (S24 entry AskUserQuestion bundle Q3)
- **closed_at**: 2026-04-30 (same turn)
- **source**: bundle 002 cluster D
- **question**: Does Obsidian raw/wiki Karpathy pattern scale at 200+ entities?
- **options**: A: Yes, current pattern proven; just need disciplined index updates / B: Add tiered wiki/ (tier1-canonical/tier2-derived/tier3-thesis) / C: Replace with KG (DuckDB+pgvector? RDF triplestore?) / D: open answer
- **answer**: A (Recommended) — Yes, current pattern proven; just need disciplined index updates. spec-to-wiki skill enforces wikilink convention; periodic _index.md re-render via hook. KG migration only if Obsidian text-search becomes inadequate for cross-entity thesis synthesis. Codified as `sync-040` confirmed-aligned in `sync-state.md`. re_verify_when: wiki/ entity count exceeds 200 AND _index.md staleness > 1 week.

### Q-D3 — Memory Tier Codification

- **fire_when**: S5 Track 7 `memory-tiers.md` authoring (Track 7 amendment per REV-2) → fired S15 PLAN 2026-04-29
- **status**: closed
- **fired_at**: 2026-04-29 (S15 PLAN Batch 1)
- **closed_at**: 2026-04-29 (S15 PLAN Batch 1, same turn)
- **source**: bundle 002 cluster D
- **question**: Codify Tier 1 (immutable always-loaded) / Tier 2 (just-in-time) / Tier 3 (explicit pull)?
- **options**: A: Yes — add `memory-tiers.md` to constitution / B: Yes AND add hook to enforce / C: Already implicit in CLAUDE.md + autonomous-protocol — no new artifact / D: open answer
- **answer**: A (Recommended) — Yes, add `memory-tiers.md` to constitution as formal artifact codifying always-loaded vs just-in-time vs explicit-pull tiers. To be drafted in `proposals/memory-tiers.md` during S16 IMPL.

### Q-E1 — Self-Detect-Drift Mechanism

- **fire_when**: S5 Track 7 `self-application-bootstrap.md` authoring OR S8 Track 9 self-awareness implementation (whichever first) → fired S15 PLAN 2026-04-29
- **status**: closed
- **fired_at**: 2026-04-29 (S15 PLAN Batch 3)
- **closed_at**: 2026-04-29 (S15 PLAN Batch 3, same turn)
- **source**: bundle 002 cluster E
- **question**: How agents auto-detect drift WITHOUT human prompt?
- **options**: A: Per-task DA-rule (re-read spec every 5 steps) + checkpoint-vs-current diff hook / B: Mid-session `/session-verify` auto-fired by Stop hook every N tool calls / C: Fresh-context drift-auditor subagent dispatched mid-session at random/triggered intervals / D: All A+B+C / E: open answer
- **answer**: D (Recommended) — All A+B+C combined; defense-in-depth matches stockforge multi-perspective principle. To be codified in `proposals/autonomous-protocol.md` § Self-detect-drift mechanism during S16 IMPL.

### Q-E2 — Agent-Notes Promotion Frequency

- **fire_when**: S5 Track 7 OR S8 Track 9 → fired S15 PLAN 2026-04-29
- **status**: closed
- **fired_at**: 2026-04-29 (S15 PLAN Batch 1)
- **closed_at**: 2026-04-29 (S15 PLAN Batch 1, same turn)
- **source**: bundle 002 cluster E
- **question**: How often does agent-notes → skill/hook/deterministic promotion run?
- **options**: A: Phase-boundary only (manual review by promotion subagent, opus, fresh ctx) / B: Per-session-end Stop hook scans new agent-notes; dispatches subagent if ≥3 similar entries / C: Continuous — every new note triggers similarity check / D: open answer
- **answer**: A (Recommended) — Phase-boundary only; manual review by promotion subagent. Cheapest; matches stockforge phase cadence. To be codified in `proposals/decision-discipline.md` § Promotion frequency during S16 IMPL.

### Q-E3 — Promotion Target Priority

- **fire_when**: S5 Track 7 OR S8 Track 9 (paired with E2) → fired S15 PLAN 2026-04-29
- **status**: closed
- **fired_at**: 2026-04-29 (S15 PLAN Batch 1)
- **closed_at**: 2026-04-29 (S15 PLAN Batch 1, same turn)
- **source**: bundle 002 cluster E
- **question**: When agent-note becomes promotable, where does it land?
- **options**: A: New skill in `.claude/skills/<name>/` / B: New hook script in `scripts/hooks/` / C: Update existing constitution file / D: All three valid; promotion subagent decides per pattern type — but priority MUST be hook FIRST, skill SECOND, charter LAST (cheapest first) / E: open answer
- **answer**: D (Recommended; rephrased as "Hook FIRST, skill SECOND, charter LAST") — cheapest deterministic check first; skill encodes procedural discipline; charter amendment heaviest. To be codified in `proposals/decision-discipline.md` § Promotion target priority during S16 IMPL.

### Q-E4 — Auto-Detected-Drift Recovery Flow

- **fire_when**: S5 Track 7 (`autonomous-protocol.md` recovery section) OR S8 Track 9 (paired with E1) → fired S15 PLAN 2026-04-29
- **status**: closed
- **fired_at**: 2026-04-29 (S15 PLAN Batch 3)
- **closed_at**: 2026-04-29 (S15 PLAN Batch 3, same turn)
- **source**: bundle 002 cluster E
- **question**: If drift auto-detected mid-session, recovery flow?
- **options**: A: HALT immediately; emit ALERT; require human resume / B: HALT only if charter-tier; SOFT-WARN otherwise / C: Open Q&A bundle with detected drift + 3 remediation options; let human pick async / D: Auto-revert to last clean checkpoint + emit notification / E: open answer
- **answer**: C (Recommended) — Open Q&A bundle with detected drift + 3 remediation options; let human pick async. Matches UP-06 NO-Silent-Default + mobile-remote use case. To be codified in `proposals/autonomous-protocol.md` § Drift recovery flow during S16 IMPL.

### Q-2.1 — Skill-Tool Autonomous Mode Policy

- **fire_when**: S5 Track 7 `autonomous-protocol.md` authoring → fired S15 PLAN 2026-04-29
- **status**: closed
- **fired_at**: 2026-04-29 (S15 PLAN Batch 2)
- **closed_at**: 2026-04-29 (S15 PLAN Batch 2, same turn)
- **source**: `human-workspace/q-and-a/pending/2026-04-29-003-up05-askuser-permissions-rawsessions.md` cluster Q2
- **question**: For autonomous run, how to handle Skill tool prompts (Anthropic-designed always-prompt)?
- **options**: A: Avoid Skill calls in autonomous mode (replace with inline procedures + agent dispatch) / B: Skill calls only in SUPERVISED mode; gate autonomous loops to NOT call skills / C: Batch Skill calls at session-start under explicit user approval (one-time per session) / D: Accept friction — pause on Skill prompt; not deal-breaker / E: open answer
- **answer**: B (Recommended) — Skill calls only in SUPERVISED mode; gate autonomous loops to NOT call skills (replace with inline procedures or subagent dispatch). Matches existing agent-notes UP-05 rule. To be codified in `proposals/autonomous-protocol.md` § Skill-tool policy in autonomous mode during S16 IMPL.

---

## Closed (after answer)

(none yet — append entries here as questions get fired + answered)

---

## Implementation Note for SessionStart Hook (Track 5, S3)

Hook script `scripts/hooks/session-start-bootstrap.sh` (Track 5 deliverable) MUST include:

```bash
# Check queued-grill triggers
QUEUED_GRILL_FILE="agent-workspace/memory/observations/queued-grill-master.md"
ACTIVE_PHASE=$(awk '/^\*\*Phase\*\*:/ {print $2}' agent-workspace/memory/current-execution.md)
ACTIVE_TRACK=$(awk '/^\*\*Active plan\*\*/' agent-workspace/memory/current-execution.md)

# For each ### Q-* section, parse fire_when and check match
# If match → emit notification: "queued-grill ready: <Q-id>; consider firing AskUserQuestion in this session"
# Do NOT auto-fire — surface to agent who decides timing
```

This keeps the queue auditable + actionable without LLM-Guardian continuous polling.
