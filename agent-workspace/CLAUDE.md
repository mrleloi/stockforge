# agent-workspace/ — Contract

> **Audience**: agents working inside `agent-workspace/`.
> **Established**: Decision 002 § Track 1 (Workspace Dualism Foundation).

## Identity

`agent-workspace/` is the **agent-owned execution + memory** layer. Everything here represents **agent state, decisions, plans, observations, learning**. Agents WRITE here freely (within constitution rules); humans READ here but normally do not edit.

This separation exists to prevent two failure modes from orch:
1. **Charter drift via shared-workspace mutation** (orch CF-DOGFOOD-2)
2. **Human cognitive overload from dense session logs** (UP02 §1.3 — "human đối mặt hàng chục spec/document quá tải nếu không sắp xếp khoa học")

The agent owns this directory but must keep it AUDITABLE — every artifact provenance-linked, every decision sourced.

---

## Subdirectories

| Path | Purpose | Lifecycle |
|---|---|---|
| `constitution/` | **IMMUTABLE without explicit user approval**. Charter-tier rules (autonomous-protocol, model-routing, identity-scope, etc.). Track 7 produces drafts in `proposals/`; user explicit approve to move here. | Edit denied by .claude/settings.json; Write only via human approval gate |
| `memory/project.md` | High-level project state; phase tracker; ADRs (last 5). Update on phase boundaries + architectural decisions. | Long-lived; trim to most recent decisions |
| `memory/current-execution.md` | **THE single routing source of truth**. Active phase + active session + autonomous_mode flag + routing table. Read FIRST every session. | Long-lived; updated each session boundary |
| `memory/agent-notes.md` | Learned rules from real experience (post-mortem / drift / user correction). Append-only mostly. | Long-lived |
| `memory/decisions/` | Sequential ADRs (`NNN-<slug>.md`) + `_template.md` + `README.md` index. 12-field schema (Track 2). | Append-only; supersession via status field |
| `memory/sessions/` | One file per session: `YYYY-MM-DD-session-N.md`. What happened, decisions made, files touched. | Append-only |
| `memory/observations/` | Subagent return artifacts (per Track 6 spec). Each subagent writes one observation file describing what it did. | Append; cleaned periodically by aggregator |
| `memory/checkpoints/` | Session handoff state for self-reboot (Track 5). `latest.md` is canonical pointer; timestamped historical files retained. | Append + latest.md updated each checkpoint |
| `memory/patterns-discovered/` | Pattern mining outputs (Track 0 — DONE) + ongoing pattern catalog. | Append; significant patterns promoted to constitution |
| `memory/drift-logs/` | Drift-check (DR1-DR12) results; runs on hook + on-demand. | Time-series append |
| `memory/post-mortems/` | After significant failure or thesis-revoked event: what failed, root cause, prevention rule. | Append |
| `memory/thesis-log/` | Stock-domain thesis exploration entries. Read-only for IMPL sessions. | Append + revisited per calibration |
| `memory/sync-tracker/` | Track 8a output: Confidence Score SQLite + weights.yaml + auto-rendered `_index.md`. | Live updated by hooks |
| `memory/self-awareness/` | Track 9 output: model × effort × thinking profile cards + known-issues + best-practices. | Live updated by Stop-hook aggregator |
| `memory/mistake-log.md` | Track 7 deliverable: structured failure catalog. What went wrong / Root cause / Prevention rule / Severity. | Append; pre-flight read by all agents |
| `session-plans/pending/` | Plans authored, awaiting execution. Phase 0 plan lives here. | Move to `completed/` when done |
| `session-plans/completed/` | Executed plans; archived for reference + retrospective input. | Append |
| `quality-reports/{deterministic,probabilistic,drift-reports}/` | Tier-1/2/3 gate outputs (CLAUDE.md § Quality Gates). | Per-run files |
| `ubiquitous-language/` | DDD glossary + domain-mapping + drift-log. Stockforge stock-domain vocabulary. | Append; canonical via `/drill-me` |
| `calibration/` | Empirical hit-rate data per signal type. Confidence claims MUST trace here (CLAUDE.md hard rule). | Append per thesis post-mortem |
| `research/` | Research notes from `research-scanner` subagent dispatches (e.g., reference-repo studies). | Append |

---

## Contract Rules (BINDING)

1. **Constitution is immutable absent explicit human approval.** `Edit/Write` to `agent-workspace/constitution/**` is in `.claude/settings.json` deny list. Track 7 writes constitution drafts to `proposals/`; user explicit approve moves them.

2. **`memory/decisions/` is append-mostly + supersession-status.** Don't delete decisions; mark `status: superseded-by-D-NNN` to revoke. Sequential numbering (`001`, `002`, ...) — don't reuse numbers.

3. **`current-execution.md` is the routing source-of-truth.** No skill, agent, or command may hardcode phase paths or session paths from memory; resolve via this file. Stale paths in CLAUDE.md or skills = anti-pattern.

4. **Never edit `obsidian-vault/raw/`.** Immutable. Vault writes only to `wiki/`. (Established in stockforge CLAUDE.md.)

5. **Provenance is mandatory.** Every decision file references its source (human prompt / spec clause / drift detection / agent inference). Every thesis cites source + as-of date (I-S2). Every confidence claim cites historical hit rate (I-S20-equivalent).

6. **Agents never `git commit` in this directory unless user explicitly requests.** Stage only.

7. **`patterns-discovered/` artifacts are READ-ONLY for production code.** Patterns must be promoted to constitution / skills / hook scripts before becoming binding. (Otherwise they're informal notes, not contracts.)

---

## Reading Priority for Agent

Per `agent-workspace/constitution/autonomous-protocol.md` (Track 7) and stockforge `CLAUDE.md` § Session Protocol:

1. **`memory/current-execution.md`** — first; resolve active track
2. **`memory/project.md`** — project state
3. **`memory/checkpoints/latest.md`** if a recent checkpoint exists (within last 24h) — resume context
4. **`memory/agent-notes.md`** — learned rules
5. **`memory/mistake-log.md`** — pre-flight failure catalog
6. **Last 3 files in `memory/sessions/`** — recent context
7. **`session-plans/pending/<active-plan>.md`** — current plan
8. **Relevant constitution files** as task demands (don't load all every session)
9. **Relevant skills + agents + commands** as task demands

---

## Anti-Patterns to Avoid

(From `memory/patterns-discovered/SYNTHESIS.md` § 6, full catalog 23 items. Highest-priority for this directory:)

- **AP-1 Same-agent self-review** — never review your own implementation; dispatch fresh-context verifier
- **AP-2 Self-track wind-down** — `.transcript-tokens` real-transcript is authoritative, not LLM self-track
- **AP-5 Charter-coherence defer overriding user-CRITICAL** — re-read all `user_prompt/*` at every phase entry; never silently defer USER-CRITICAL
- **AP-7 Performative SC ticking** — defer with explicit prerequisites > fire vacuous proposals
- **AP-8 Pre-staged work causing checkpoint drift** — update `current-execution.md` immediately on task complete, not session-end
- **AP-17 Identity drift** — stockforge is AI-first VN stock advisory; not generic financial framework (see `constitution/identity-scope.md` once Track 7 ships)
- **AP-23 Continuous LLM-Guardian** — deterministic hooks = Guardian; LLM Guardian only at session-end aggregation

---

## Connection to human-workspace/

This directory is the agent's domain. Human's domain is `human-workspace/`. The two communicate through:
- Human → Agent: `human-workspace/user_prompt/`, `human-workspace/decisions/`
- Agent → Human: `human-workspace/notifications/`, `human-workspace/q-and-a/pending/`
- Bidirectional: `human-workspace/q-and-a/answered/` — agent writes pending; either human or agent (per Auto-mv rule below) moves resolved bundles to answered/
- Audit trail: this directory's `memory/decisions/` references `human-workspace/` source files via path pointers

**Auto-mv rule (HH-E.2 — D-031 ratification, 2026-05-05)**: Agent MAY mv a bundle from `q-and-a/pending/` to `q-and-a/answered/` IFF ALL of the following hold:

1. **Frontmatter signal**: bundle frontmatter `status:` field value starts with one of: `answered-`, `closed-`, `resolved-`. Examples already in repo: `answered-via-chat`, `answered-via-AskUserQuestion`, `answered-2026-05-04-via-chat`. Detection is deterministic (head -20 of file + grep `^status:`).
2. **No human-veto signal**: bundle frontmatter has NO `wait_until:` ISO-8601 timestamp greater than current epoch — if present, agent MUST defer mv until that timestamp passes. Allows human to override auto-mv per-bundle without contract amendment.
3. **No global pause**: file `human-workspace/q-and-a/.auto-mv-paused` does NOT exist — global kill switch for the auto-mv mechanism (single empty file presence pauses all auto-mv).
4. **Hook validation**: the mv is performed by `scripts/hooks/qa-pending-auto-mover.sh` (Stop hook). Direct manual `mv` invocation by agent (e.g. via Bash tool) is STILL forbidden — only the validated hook path is authorized.

Agent never writes to `human-workspace/` outside the designated `q-and-a/pending/` write channel + the auto-mv rule above + `notifications/` write channel (existing).
