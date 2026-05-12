# Decision Log — StockForge

> **Status**: Track 2 deliverable per Decision 002 § Track 2 (REV-2).
> **Schema source**: [_template.md](_template.md) — every decision file MUST start with the canonical frontmatter.
> **Last updated**: 2026-04-29 (S2)

This directory is **append-only with supersession**. Decisions are never deleted; they are marked `SUPERSEDED-BY-D-NNN` or `REVOKED` and remain on disk as the audit trail.

---

## Status Legend

| Status | Meaning |
|---|---|
| `PROPOSED` | Authored by agent; awaiting user confirmation. Open Q&A bundle may exist. |
| `ACCEPTED` | User confirmed (via chat phrase, `user_prompt/` file, or `q-and-a/answered/` reply). Decision is binding. |
| `SUPERSEDED-BY-D-NNN` | A later decision replaced this one. Pointer in `superseded_by` field. The replacement decision's `supersedes` field points back. |
| `REVOKED` | Reversed without replacement. Triggers post-mortem (`agent-workspace/memory/post-mortems/`). 6-step protocol from Q&A A6 applies. |

A decision may also carry `REV-N` amendments (in-place edits) — see [Amendments Convention](#amendments-convention) below.

---

## Decision Levels (per Q&A A4 thresholds)

| Level | Confidence threshold to self-decide without Q&A | Examples |
|---|---|---|
| `CHARTER` | 0.99 | Identity scope, mission rewrite, autonomous mode activation |
| `SCOPE` | 0.90 | Phase plan, multi-track design, BC count, port-list scope |
| `ARCH` | 0.80 | Library choice, schema design, hook architecture |
| `IMPL` | 0.50 | File layout inside a track, naming, refactor pass |

If agent confidence is below threshold for a level, it MUST open a Q&A bundle in `human-workspace/q-and-a/pending/` rather than self-decide.

---

## Sequential Index

> Newest first. Number is monotonic; never reused.

| ID | Title | Level | Status | Date | Source prompt(s) |
|---|---|---|---|---|---|
| [D-003](003-up06-track-5.5-sync-layer-selfcap.md) | UP-06 Track 5.5 — Sync + Layer + Self-Capability Foundation | SCOPE | ACCEPTED | 2026-04-29 | UP-06 |
| [D-002](002-phase-0-harness-bootstrap-design.md) | Phase 0 Harness Bootstrap Design (11 tracks + Track 5.5) | SCOPE | ACCEPTED-REV-3 | 2026-04-29 | UP-01/02/03/06 |
| [D-001](001-orch-vs-cc-native.md) | Pause Orch, Port Patterns to StockForge | SCOPE | ACCEPTED | 2026-04-29 | UP-01 |

---

## Amendments Convention

When a decision is **partially** revised after acceptance, the change is recorded **in-place** as `REV-N` (Q&A Q-S3 = A confirmed). The decision's `status` field becomes e.g. `ACCEPTED-REV-2`, and a new section `## Amendments` accumulates change history.

When a decision is **wholly** replaced, do NOT amend — author a new decision file `D-NNN` with `supersedes: D-MMM`, and set the original's `status: SUPERSEDED-BY-D-NNN` and `superseded_by: D-NNN`.

Rule of thumb:
- ≤30% content change, scope/intent unchanged → amend in-place (REV-N)
- > 30% content change, or scope/intent changed → new decision file with supersedes pointer

---

## Naming Convention

`<NNN>-<kebab-case-slug>.md` where `NNN` is zero-padded 3-digit (`001`, `002`, ... `999`).

Slug rules:
- ≤ 60 chars
- Lower-case ASCII + hyphens only
- Verb-leading when describing a change (`pause-orch`, `split-track-8`); noun-leading when describing a system (`provenance-protocol`, `confidence-score-system`)

---

## Provenance Discipline (binding)

Every decision MUST cite its `source_evidence`. An empty `source_evidence: []` triggers a drift-detector flag (`DR-PROV` — to be wired in Track 5 hooks).

Acceptable source types:
1. `human-workspace/user_prompt/<file>.txt` — user's explicit direction
2. `human-workspace/decisions/<file>.md` — user's strategic decision
3. `human-workspace/q-and-a/answered/<file>.md` — user's reply to Q&A bundle
4. `agent-workspace/memory/patterns-discovered/*.md` — pattern mining result
5. `agent-workspace/memory/post-mortems/<file>.md` — failure-driven learning
6. `agent-workspace/memory/drift-logs/<file>.md` — drift signal evidence
7. `specs/**/*.md` — formal spec clause
8. Charter section reference (`PROJECT_CHARTER.md § X.Y`)

Decisions that derive from agent inference alone (no upstream evidence) MUST tag `level: IMPL` AND state inference chain in `chosen_rationale`.

---

## R7 Mitigation: Defer-Cycle Tracking

Per Decision 002 REV-2 § C R7 (msmdp Decision Provenance Chain pattern):

- Each time a decision is paused, postponed, or rolled forward, increment `defer_cycles` by 1.
- `defer_cycles > 3` → drift-detector raises alert; human Q&A bundle required to either commit or revoke.
- `re_attempt_prereq` documents what must change before the decision can be resumed (e.g. "blocker on D-XYZ resolution", "user feedback on Q-S5", "telemetry data after 1 month").

This prevents the **can-kicking** anti-pattern observed during ms-mdp-admin Phase 2 workflow review.

---

## Reading Order for New Agents

1. This file (overview + legend)
2. [_template.md](_template.md) (canonical schema)
3. Latest 5 decisions, newest first
4. Any decision referenced by `current-execution.md` "Routing Table"

For provenance audits or drift checks: use the `source_evidence` graph — start from a recent decision, traverse backward via `depends_on` and forward via `superseded_by`.
