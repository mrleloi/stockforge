---
status: ACCEPTED
proposal_id: HH-E.2
created_at: 2026-05-05
created_via: S48g main-session opus47-max (Phase 2.5 HH-E Q&A escalation upgrade)
ratified_at: 2026-05-05
ratified_via_adr: D-031
ratifying_session: S48h
target_file: agent-workspace/CLAUDE.md
binding_charter_clauses:
  - agent-workspace/CLAUDE.md § "Connection to human-workspace/" (current text: "agent writes pending; human moves answered" + "Agent never writes to human-workspace/ outside the designated q-and-a/pending/ channel")
  - autonomous-protocol.md Rule 1 (autonomous_mode=true is the only mode) — implies agent must self-progress lifecycle, not block on human-only manual mv
  - 009-S48-harness-hardening-middle-phase.md § HH-E.2
ratification_path: USER-GATE via AskUserQuestion + direct edit (target NOT in deny list, but charter-tier change requires explicit ACCEPT per Q-B2) — RATIFIED S48h Q-S48g-1=ACCEPT
companion_hooks:
  shipped_pre_S48g:
    - scripts/hooks/qa-answered-detector.sh (SessionStart hook detecting MANUAL mv to answered/; mtime > last-scan)
    - scripts/hooks/qa-pending-stale-mover.sh (SessionStart hook moving pending/ bundles to stale/ — UNIDIRECTIONAL stale archival)
  shipped_S48g (HH-E.1):
    - scripts/hooks/qa-stale-urgent-escalator.sh (Stop hook emitting URGENT to notifications/urgent.md when pending/ bundles >48h)
  proposed_post_ratify (S48h IMPL):
    - scripts/hooks/qa-pending-auto-mover.sh (Stop hook scanning pending/ frontmatter; if status starts with "answered-" AND no "wait_until:" > NOW → mv to answered/)
companion_user_memory:
  - ~/.ccs/instances/.../memory/qa_bundle_all_pending.md (mega-bundle doctrine; current contract makes mega-bundle lifecycle painful for autonomous mode)
  - ~/.ccs/instances/.../memory/full_autonomous_no_supervised.md (no human-in-the-loop bifurcation — should imply no human-only mv either)
---

# Q&A Lifecycle Contract Revision — Allow Agent Auto-mv Pending → Answered

## Why this proposal exists

Per `009-S48-harness-hardening-middle-phase.md` § HH-E.2 + S48f checkpoint empirics:

**Current contract** (`agent-workspace/CLAUDE.md` lines 99-102):
> Bidirectional: `human-workspace/q-and-a/answered/` (agent writes pending; human moves answered)
>
> Agent never writes to `human-workspace/` outside the designated `q-and-a/pending/` channel.

**Empirical failure mode** (4-bundle stale carry-forward verified S48g HH-E.1 smoke test):
- 3 of 4 pending bundles >48h stale (ages 92h / 99h / 140h) per `qa-stale-urgent-escalator.sh` first run
- All 3 stale bundles already have frontmatter `status: answered-...-via-chat (awaiting user mv to answered/)` — meaning the Q&A is logically resolved; only the file move is pending
- User has been answering inline in chat (per `autonomous_continue_no_self_pause` + `qa_bundle_all_pending` doctrines) but the manual mv ceremony is friction-heavy and routinely skipped
- Cumulative: human-only-mv contract creates lifecycle debt that compounds session-over-session, eventually flooding the `pending/` directory + drowning genuinely-open Q&A in stale-resolved noise

**Why charter-tier (not just hook)**: hooks can perform the mv mechanically once authorized, but the AUTHORIZATION itself ("agent MAY write to answered/") is a contract-level boundary change. Without amendment, any hook that performs the mv would violate `agent-workspace/CLAUDE.md` line 102 ("Agent never writes to `human-workspace/` outside ... `q-and-a/pending/` channel").

## Proposed contract revision (verbatim insert text)

Replace `agent-workspace/CLAUDE.md` lines 94-102 (current "Connection to human-workspace/" section) with the following expanded text:

```markdown
## Connection to human-workspace/

This directory is the agent's domain. Human's domain is `human-workspace/`. The two communicate through:
- Human → Agent: `human-workspace/user_prompt/`, `human-workspace/decisions/`
- Agent → Human: `human-workspace/notifications/`, `human-workspace/q-and-a/pending/`
- Bidirectional: `human-workspace/q-and-a/answered/` — agent writes pending; either human or agent (per Auto-mv rule below) moves resolved bundles to answered/
- Audit trail: this directory's `memory/decisions/` references `human-workspace/` source files via path pointers

**Auto-mv rule (HH-E.2 — D-NNN ratification)**: Agent MAY mv a bundle from `q-and-a/pending/` to `q-and-a/answered/` IFF ALL of the following hold:

1. **Frontmatter signal**: bundle frontmatter `status:` field value starts with one of: `answered-`, `closed-`, `resolved-`. Examples already in repo: `answered-via-chat`, `answered-via-AskUserQuestion`, `answered-2026-05-04-via-chat`. Detection is deterministic (head -20 of file + grep `^status:`).
2. **No human-veto signal**: bundle frontmatter has NO `wait_until:` ISO-8601 timestamp greater than current epoch — if present, agent MUST defer mv until that timestamp passes. Allows human to override auto-mv per-bundle without contract amendment.
3. **No global pause**: file `human-workspace/q-and-a/.auto-mv-paused` does NOT exist — global kill switch for the auto-mv mechanism (single empty file presence pauses all auto-mv).
4. **Hook validation**: the mv is performed by `scripts/hooks/qa-pending-auto-mover.sh` (Stop hook, ships post-ratify in S48h IMPL phase). Direct manual `mv` invocation by agent (e.g. via Bash tool) is STILL forbidden — only the validated hook path is authorized.

Agent never writes to `human-workspace/` outside the designated `q-and-a/pending/` write channel + the auto-mv rule above + `notifications/` write channel (existing).
```

## What this proposal does NOT change

- Agent STILL forbidden from writing to `human-workspace/user_prompt/`, `human-workspace/decisions/`, `human-workspace/q-and-a/answered/` directly via Bash/Edit/Write tools (only the authorized hook may perform the auto-mv).
- Agent STILL forbidden from writing to `human-workspace/q-and-a/pending/` directly via Bash mv to override status field (status remains source of truth for resolution detection).
- The 4 stale bundles currently in pending/ MUST go through the new mechanism (HH-E.2 ratify → S48h hook ship → next Stop fire detects `status: answered-...` → auto-mv); not retroactive bulk-clean.
- Existing `qa-answered-detector.sh` SessionStart hook unchanged (continues detecting manual user moves; agent-mv events also detected since the hook compares mtime vs last-scan regardless of who performed the mv).

## Companion hook `qa-pending-auto-mover.sh` (S48h IMPL design sketch)

Defer implementation to S48h post-ratify. Design contract:
- Stop hook (priority: late chain — after `qa-stale-urgent-escalator.sh` shipped this turn).
- Bash + POSIX per L-S11-1.
- Idempotent per session via marker `agent-workspace/memory/.qa-auto-mv-fired-<SID>`.
- Scans `human-workspace/q-and-a/pending/*.md`:
  - Reads frontmatter `status:` (head -25 + grep).
  - If matches `^answered-|^closed-|^resolved-` → check `wait_until:` field: if absent or ISO timestamp < NOW → mark for mv.
  - Checks global `.auto-mv-paused` kill switch.
- For each bundle marked: `mv` to `answered/`; emit log entry to `agent-workspace/memory/.qa-auto-mv.log`; soft-warn count to stderr.
- Exit 0 (soft-warn; non-blocking Stop chain).

## Ratification paths

| Pick | Action | Effect |
|---|---|---|
| **A: ACCEPT (Recommended)** | Apply contract revision verbatim via direct Edit (target NOT in deny list); author D-NNN ratifying ADR; flip proposal status PROPOSAL → ACCEPTED. Schedule S48h IMPL of `qa-pending-auto-mover.sh`. | Closes Phase 2.5 HH-E.2; HH-E.3 hook unblocked for S48h IMPL ship; 4 currently-stale bundles auto-resolved next Stop fire. |
| **B: AMEND** | User specifies wording revisions (e.g., add/remove status prefixes, tighten wait_until semantics, change kill-switch path, restrict to specific bundle types). Re-draft proposal next session. | Contract NOT applied this session; HH-E.2 deferred. |
| **C: REJECT** | Leave human-only-mv contract intact. Document why agent-mv not warranted (e.g., loss-of-audit-trail concern, prefer manual ceremony for accountability). | 4 currently-stale bundles + future answered-via-chat bundles continue to accumulate in pending/; HH-E.1 URGENT fires every Stop until human manually clears. |

## Why charter-tier (D-018..D-029 precedent)

Same pattern as D-018 (architecture slash-vs-skill split), D-019 (financial-data Hook Portability), D-023 (Cost Substrate), D-026 (decision-discipline Rule 4b), D-028 (CLAUDE.md ritual extension): a contract-level rule reframes what the agent IS PERMITTED to do. Hook-only enforcement is downstream — without contract authorization, the hook's mv would itself constitute a charter violation.

## Bundle opportunity (per L-S43f-1 doctrine)

This proposal can pair with any other queued constitution amendment. Currently no other charter-tier proposals queued post-S48f D-030 ratification. If S48g surfaces additional charter-tier work (e.g., HH-F.1/F.2 self-knowledge bootstrap might surface a memory-tiers.md amendment), bundle.

## Drift watch (post-ratification)

- D9 charter md5: `agent-workspace/CLAUDE.md` WILL CHANGE (intentional via D-NNN ratify); note this is `agent-workspace/CLAUDE.md` NOT root `CLAUDE.md` — verify mtime + content of correct file post-edit.
- D-INTENT measurement post-S48h hook ship: count pending/ bundles still stale >48h after 5 sessions; success criterion = ≤1 bundle >48h sustained per `009-S48-...md` § HH-E success criteria.
- DR-PROV: ratifying ADR will cite this proposal + S48g HH-E.1 smoke test stale-bundle empirics + 4-bundle carry-forward observation S48f.

## What this proposal does NOT include

- HH-E.3 optional notification channel (Telegram bot OR Windows toast for URGENT) — stays optional; ship contingent on user-felt friction with file-only URGENT mechanism.
- Retroactive cleanup of 4 currently-stale bundles via bash one-liner mv — agent waits for ratified hook to perform mv per the new contract path (preserves audit trail consistency).
- Modification to `qa-answered-detector.sh` (SessionStart hook) — stays unchanged; continues detecting actual answered/ folder mtime changes regardless of who performed the mv.
- Changes to root `CLAUDE.md` (Claude Code project instructions) — only `agent-workspace/CLAUDE.md` (agent-workspace contract) is the ratification target.
