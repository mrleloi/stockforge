---
id: D-031
title: S48h — Q-S48g-1 charter-promote agent-workspace/CLAUDE.md § Connection to human-workspace/ 4-condition Auto-mv rule (HH-E.2 Q&A lifecycle contract revision)
status: ACCEPTED
tier: CHARTER
date_proposed: 2026-05-05
date_ratified: 2026-05-05
ratified_by: Project owner — explicit AskUserQuestion ACCEPT pick (S48h 1-Q bundle, Q-S48g-1)
ratifying_session: S48h (Phase 2.5 HH-E Q&A lifecycle contract revision; HH-E.2 ratification + companion hook IMPL same turn)
authoring_agent: Claude Opus 4.7
supersedes: none
superseded_by: none
source_evidence:
  - agent-workspace/proposals/qa-lifecycle-contract-revision-HH-E.2.md  # S48g HH-E.2 proposal draft
  - scripts/hooks/qa-stale-urgent-escalator.sh  # S48g HH-E.1 stale URGENT escalator (smoke detected 3/4 stale bundles)
  - human-workspace/q-and-a/pending/2026-04-29-004-up06-track-5.5-amendment.md  # status: answered-via-askuserquestion (~7 days awaiting mv)
  - human-workspace/q-and-a/pending/2026-05-01-001-S35-charter-promote-batch.md  # status: answered-2026-05-01-via-chat (awaiting user mv)
  - human-workspace/q-and-a/pending/2026-05-01-002-S41-track-F-scope-gates.md  # status: answered-2026-05-01-via-AskUserQuestion (awaiting user mv)
  - human-workspace/q-and-a/pending/2026-05-01-003-S39-track-E-bundle-2-scope-amendments.md  # status: answered-2026-05-04-via-chat (awaiting user mv)
  - agent-workspace/session-plans/pending/009-S48-harness-hardening-middle-phase.md § HH-E.2
  - human-workspace/notifications/urgent.md  # S48g HH-E.1 smoke URGENT entry documenting 3/4 stale state
  - ~/.ccs/instances/.../memory/qa_bundle_all_pending.md (user-memory companion: mega-bundle doctrine)
  - ~/.ccs/instances/.../memory/full_autonomous_no_supervised.md (user-memory companion: no human-only-mv expectation)
  - AskUserQuestion (S48h turn) — 1-Q Q-S48g-1=ACCEPT
options_considered:
  - A: ACCEPT contract revision verbatim (4-condition Auto-mv rule + companion hook IMPL same turn) — chosen
  - B: AMEND (specify wording revisions to status prefixes, wait_until semantics, kill-switch path, or restrict to specific bundle types)
  - C: REJECT (leave human-only-mv contract intact; pending/ continues accumulating answered-via-chat bundles)
chosen_option: A
---

# D-031 — agent-workspace/CLAUDE.md § Connection to human-workspace/ 4-condition Auto-mv rule charter promotion

## Summary

Charter amendment to `agent-workspace/CLAUDE.md` § "Connection to human-workspace/"
section: replace 9-line text (lines 94-102 pre-edit) with expanded 22-line block
adding 4-condition Auto-mv rule allowing agent-mv `q-and-a/pending/` → `q-and-a/answered/`
IFF: (1) frontmatter `status:` starts `answered-|closed-|resolved-`, (2) no `wait_until:`
ISO timestamp > NOW, (3) no global `.auto-mv-paused` kill-switch file, (4) mv via
`scripts/hooks/qa-pending-auto-mover.sh` (S48h IMPL same-turn ship). Net diff +13 LOC.

## Why this charter-tier ratification

Empirical motivation (per S48g HH-E.1 smoke + 4-bundle stale carry-forward observation):

- 4 of 4 pending bundles have frontmatter `status:` starting with `answered-` (verified
  this turn via `head -20 + grep ^status:` on each):
  - `2026-04-29-004-up06-track-5.5-amendment.md` — `answered-via-askuserquestion` (~7 days)
  - `2026-05-01-001-S35-charter-promote-batch.md` — `answered-2026-05-01-via-chat (awaiting user mv to answered/)` (~4 days)
  - `2026-05-01-002-S41-track-F-scope-gates.md` — `answered-2026-05-01-via-AskUserQuestion (awaiting user mv to answered/)` (~4 days)
  - `2026-05-01-003-S39-track-E-bundle-2-scope-amendments.md` — `answered-2026-05-04-via-chat (awaiting user mv to answered/)` (~24h)
- 3 of 4 ≥48h stale per S48g HH-E.1 first run (URGENT entry written to `human-workspace/notifications/urgent.md` 2026-05-05 03:54 UTC).
- All 4 bundles are LOGICALLY resolved (Q&A answered inline in chat or via AskUserQuestion) — only the file move ceremony is pending.
- User has been answering inline per `autonomous_continue_no_self_pause` + `qa_bundle_all_pending` user-memory rules but the manual mv ceremony is friction-heavy and routinely skipped.
- Cumulative: human-only-mv contract creates lifecycle debt that compounds session-over-session, eventually flooding `pending/` directory + drowning genuinely-open Q&A in stale-resolved noise.

**Why charter-tier (not just hook)**: hooks can perform the mv mechanically once authorized, but the AUTHORIZATION itself ("agent MAY write to answered/") is a contract-level boundary change. Without amendment, any hook performing the mv would violate the pre-edit `agent-workspace/CLAUDE.md` line 102 ("Agent never writes to `human-workspace/` outside ... `q-and-a/pending/` channel"). This is the same pattern as D-018 (architecture slash-vs-skill split), D-019 (financial-data Hook Portability), D-023 (Cost Substrate), D-026 (decision-discipline Rule 4b), D-028 (CLAUDE.md Session End ritual extension), D-029 (drift-signals Tiered Coverage Map), D-030 (autonomous-protocol Rule 10): a contract-level rule reframes what the agent IS PERMITTED to do.

## Verbatim insert (as applied)

Pre-edit lines 94-102 (9 lines):
```markdown
## Connection to human-workspace/

This directory is the agent's domain. Human's domain is `human-workspace/`. The two communicate through:
- Human → Agent: `human-workspace/user_prompt/`, `human-workspace/decisions/`
- Agent → Human: `human-workspace/notifications/`, `human-workspace/q-and-a/pending/`
- Bidirectional: `human-workspace/q-and-a/answered/` (agent writes pending; human moves answered)
- Audit trail: this directory's `memory/decisions/` references `human-workspace/` source files via path pointers

Agent never writes to `human-workspace/` outside the designated `q-and-a/pending/` channel.
```

Post-edit (22 lines; +13 LOC net):
```markdown
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
```

## Implementation

**Charter edit** (target NOT in deny list; no deny-lift cycle needed — distinct from D-018..D-030 which targeted `agent-workspace/constitution/**`):
- `agent-workspace/CLAUDE.md` lines 94-102 (9 LOC) → expanded to 22 LOC; net +13 LOC.
- D9 zero-residue verified pre/post: only `agent-workspace/CLAUDE.md` md5 changed
  (`a4bab98e395a732f4484e314e10c8ba0` → `2af399be3923c19f41ccaaa3948451ea`); all 13
  constitution files md5 IDENTICAL pre/post (architecture / autonomous-protocol /
  boundaries / coding-principles / decision-discipline / drift-signals /
  financial-data-protocol / invariants / karpathy-principles / memory-routing-tree /
  memory-tiers / session-budgets / vbw-protocol).

**Companion hook ship same-turn** (per proposal § "Companion hook design sketch"):
- `scripts/hooks/qa-pending-auto-mover.sh` — Stop hook, bash + POSIX (L-S11-1),
  idempotent per session via `.qa-auto-mv-fired-<SID>` marker, scans `pending/*.md`
  frontmatter, mv qualifying bundles to `answered/`, respects all 3 deterministic
  veto signals (status prefix, wait_until, .auto-mv-paused). Pipefail-bracket pattern
  per L-S48d-1 (lesson from S48d HH-C.3 first iteration).
- Wired into `.claude/settings.json` Stop chain after `qa-stale-urgent-escalator.sh`
  (the HH-E.1 hook ships URGENT entries for unresolved-status pending bundles; the
  HH-E.2 hook resolves answered-status pending bundles — non-overlapping concerns,
  ordering preserves correct semantics).

**Smoke validation** (post-hook ship, this turn):
- Smoke 1 (auto-mv): expect 4 bundles auto-resolved (all 4 have `status: answered-...`).
- Smoke 2 (idempotent re-run on same SESSION_ID): expect 0 mv (marker blocks duplicate).
- Smoke 3 (kill switch): touch `.auto-mv-paused`, fresh SESSION_ID, expect 0 mv.

**Proposal closure**:
- `agent-workspace/proposals/qa-lifecycle-contract-revision-HH-E.2.md` frontmatter
  `status: PROPOSAL` → `status: ACCEPTED`; `ratified_at: 2026-05-05`; `ratified_via_adr: D-031`.

## Provenance chain

1. S48f checkpoint (2026-05-05) — 4 carry-forward stale Q&A bundles flagged as friction
   point under autonomous-full mode where AskUserQuestion mega-bundles answered inline
   in chat but human-only-mv ceremony skipped.
2. S48g HH-E.1 (this checkpoint's predecessor turn) — `qa-stale-urgent-escalator.sh`
   shipped + smoke 2/2 GREEN → empirical verification: 3/4 stale bundles all have
   `status: answered-...via-chat (awaiting user mv)` → contract gap evident.
3. S48g HH-E.2 (same predecessor turn) — proposal authored to
   `proposals/qa-lifecycle-contract-revision-HH-E.2.md` (~115 LOC under D1 ceiling)
   per `009-S48-...md` § HH-E.2; deferred ratification to S48h per CLAUDE.md never-mix
   doctrine + budget discipline (S48d+S48e+S48f+S48g cumulative ~280-340K over 250K
   hard_cap; S48g session-self-reboot delivered fresh-context S48h budget).
4. S48h (this turn) — HH-E.2 ratification: 1-Q AskUserQuestion fired Q-S48g-1; user
   picked A=ACCEPT (Recommended) explicitly per Q-B2 charter-tier mandatory-letter rule.
5. Direct Edit cycle this turn → 4-condition Auto-mv rule inserted verbatim into
   `agent-workspace/CLAUDE.md` § Connection-to-human-workspace section → D9 zero-residue
   verified → companion hook shipped same turn → this ADR authored.

## Trade-offs accepted

| Concern | Acceptance rationale |
|---|---|
| **agent-workspace/CLAUDE.md grows +13 LOC (~50 tok always-loaded)** | Negligible budget impact; agent-workspace/CLAUDE.md is loaded on `agent-workspace/` work only (not every session boundary). Hardening high-friction lifecycle pattern justifies. |
| **Agent gains write permission to `human-workspace/q-and-a/answered/`** | Gated by 4 deterministic conditions enforced via Bash hook (no LLM judgment). Hook itself is in version control + reviewable. Kill switch file `.auto-mv-paused` allows global pause without contract amendment. Per-bundle veto via `wait_until:` field. |
| **Loss of human-mv as accountability signal** | Frontmatter status field now serves as accountability signal: who-answered + when + via-which-channel. Audit trail strictly improved (file mtime preserved on `mv`; Bash log entry added per `qa-auto-mv.log`). |
| **Hook FN/FP risk** | FN (status: answered-... but should NOT mv) — kill switch + wait_until escape hatches. FP (status: NOT answered-... but mv'd anyway) — deterministic regex `^answered-|^closed-|^resolved-` cannot match other prefixes. Empirical FN/FP rate measured per Drift Watch below. |

## Drift watch

- D9 charter md5: `agent-workspace/CLAUDE.md` CHANGED (intentional via this ADR);
  all 13 constitution/*.md md5 UNCHANGED (verified pre/post via
  `md5sum agent-workspace/constitution/*.md agent-workspace/CLAUDE.md` + diff).
- D-INTENT: ALIGNED (4-condition rule inserted verbatim from proposal § "Proposed
  contract revision (verbatim insert text)" with only the proposal-internal `D-NNN`
  placeholder substituted to `D-031` and `(ships post-ratify in S48h IMPL phase)`
  parenthetical removed since hook ships THIS turn — substantive text identical).
- DR-PROV: this ADR cites proposal + 4 source bundles + S48g HH-E.1 smoke + URGENT
  notification entry + user-memory companions + AskUserQuestion turn.
- D-INTENT measurement post-ratification (per proposal § Drift watch): count
  `pending/` bundles still stale >48h after 5 sessions; success criterion = ≤1 bundle
  >48h sustained per `009-S48-...md` § HH-E success criteria. S48h baseline (this turn,
  pre-hook-fire): 4/4 with `status: answered-...` matching mv condition; expected
  drop to 0/0 after first Stop fire post-S48h close. If stale count regrows in S49+,
  investigate FN (status field changed format that doesn't match regex).

## Companion handoff

S48h closes Phase 2.5 HH-E track main goals (HH-E.1 stale URGENT escalator S48g + HH-E.2
contract revision + companion auto-mv hook S48h both DONE; HH-E.3 optional notification
channel — Telegram/toast — DEFERRED contingent on user-felt friction with file-only
URGENT mechanism). Phase 2.5 remaining tracks per `009-S48-...md`:
- HH-F self-knowledge bootstrap (S48i)
- HH-G portability validation (S48j)
- HH-H auto-/clear-handoff safety + HH-H.5 session-self-reboot idempotency (S48k)

Bundle opportunity per L-S43f-1: no charter-tier proposals currently queued post-S48h
ratification. If HH-F.1 surfaces a memory-tiers.md amendment proposal, batch with HH-F
deliverables in 2-Q AskUserQuestion at S48i.

---

## Ratification record

User explicit ACCEPT via 1-Q AskUserQuestion bundle (S48h turn 2026-05-05). No
amendments requested. Contract revision shipped verbatim from proposal § "Proposed
contract revision (verbatim insert text)" with only D-NNN→D-031 substitution and the
proposal-internal "(ships post-ratify in S48h IMPL phase)" parenthetical streamlined
to drop the future-tense scaffolding (hook ships this turn).
