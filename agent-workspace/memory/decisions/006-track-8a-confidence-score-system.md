---
id: D-006-track-8a-confidence-score-system
title: Track 8a Confidence Score System — schema, storage substrate, weights, thresholds
date: 2026-04-29
status: ACCEPTED
level: IMPL

author:
  - "Claude Opus 4.7"

source_evidence:
  - path: agent-workspace/memory/decisions/002-phase-0-harness-bootstrap-design.md
    section: Track 8 — Confidence Score System (System I) + REV-2 § B (Track 8a REFINE — empirical hit rate)
    quote: "5 categories (LANGUAGE, DOMAIN_UBIQUITOUS, DESIGN_THINKING, SCOPE, DECISION_ROUTING); hybrid scale (tier display + 0-100 internal); SQLite storage; tag+recency retrieval"
  - path: human-workspace/q-and-a/answered/2026-04-29-001-phase0-clusters.md
    section: Cluster A (A4 thresholds + A5 asymmetric weights + A6 reversal protocol)
  - path: agent-workspace/memory/agent-notes.md
    section: L-S11-1 Phase 0 hook portability (bash + POSIX only; no python/jq/yq/pip/npm)
  - path: agent-workspace/proposals/financial-data-protocol-amendment.md
    section: Rule 11 (Phase 0 vs Phase 1+ tier doctrine for hook portability)
  - path: agent-workspace/proposals/provenance-protocol.md
    section: "When to log a confidence claim" + Step 3 (confidence comes from sync-tracker.db)
  - path: agent-workspace/memory/checkpoints/latest.md
    section: S16 close — S17 NEXT options (Option B Track 8a recommended)
  - path: PROJECT_CHARTER.md
    section: Core Principles 8 (Calibration over confidence — never claim confidence not earned through hit rate)

intent_classification:
  primary_intent: DECISION
  affects_charter: false
  affects_scope: false
  urgency: NORMAL
  complexity_score: 55

options_considered:
  - id: A
    summary: SQLite + python/sqlite3 module per original D-002 spec
    pros:
      - matches D-002 spec verbatim
      - relational queries cheap (joins, aggregates)
      - schema migrations via ALTER TABLE
    cons:
      - sqlite3 CLI not available in current bash env (verified via `command -v sqlite3` exit 1)
      - requires python runtime; violates L-S11-1 portability (Phase 0 hooks bash+POSIX only)
      - adds 1 NEW L-S11-1 violation on top of 5 pre-existing
  - id: B
    summary: Bash + TSV (tab-separated) flat-file event log + computed state.tsv + flat YAML weights
    pros:
      - bash+awk only — zero python/jq/yq/pip dependencies
      - aligns with L-S11-1 portability (0 NEW violations)
      - aligns with existing learning-data/ NDJSON topology pattern (Track 5.5d)
      - trivially debuggable — humans can read TSV directly
      - migration to SQLite Phase 1+ when python/sqlite3 module ships in Track 8b is straightforward (TSV → SQL INSERT)
    cons:
      - lacks relational query power (joins are bash-awk text processing)
      - schema changes require manual data migration scripts
      - shallow YAML parser (flat key:value only; no nested structures)
  - id: C
    summary: Defer Track 8a entirely until Track 8b ships Python observability (S18+)
    pros:
      - clean dependency ordering (python+sqlite3 available before SQLite-based system)
    cons:
      - blocks Q-E2 phase-boundary cadence (Track 7 IMPL just closed = mid-Phase-0 milestone)
      - blocks Track 8a → Track 9 sequencing (D-002 § Sequencing)
      - Track 8a delivers calibration discipline (charter principle 8); deferring loses time-value of confidence-claim grounding

chosen: B
chosen_rationale: |
  Option B (bash+TSV flat-file MVP) ships the value of Track 8a — categorical scoring,
  asymmetric weights, threshold-driven Q&A escalation — without violating L-S11-1 portability.
  D-002 spec'd "SQLite" but the sub-clauses (weights.yaml + _index.md auto-rendered + sync-pull
  skill) are storage-agnostic. Per D-003 § Open Questions doctrine "Final RAG index choice:
  SQLite FTS5 vs simple bash grep+regex — IMPL-tier; agent picks at S11, subject to drift audit"
  the storage substrate is explicitly IMPL-tier. This is the same pattern. SQLite layered in
  Phase 1+ when python/sqlite3 module ships in Track 8b — TSV → SQL INSERT migration is mechanical.
  Logged as IMPL-S17-1 deviation; D-002 § Track 8 spec auto-amended via this decision document.

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-04-29
    via: agent-workspace/memory/sessions/2026-04-29-session-17.md (S17 IMPL — Track 8a)
  - actor: agent
    action: ACCEPTED
    at: 2026-04-29
    via: IMPL-tier self-decide per D-003 § Open Questions doctrine + autonomous_mode=true (S15-close user correction); subject to drift audit + sandwich-verifier cross-check at Phase 0 closeout

verified_by:
  - mechanism: smoke-test
    at: 2026-04-29
    result: PASS
    note: 5-event smoke test scoring all 5 categories; _index.md renders; mockup decision below SCOPE threshold (0.90) flagged must-grill (S17 § Smoke test)

affects:
  charter: false
  spec_files: []
  code_paths:
    - scripts/hooks/sync-tracker-update.sh
    - scripts/hooks/sync-tracker-render.sh
    - .claude/skills/sync-pull/SKILL.md
  config_files:
    - agent-workspace/memory/sync-tracker/weights.yaml
    - agent-workspace/memory/sync-tracker/events.tsv
    - agent-workspace/memory/sync-tracker/state.tsv
    - agent-workspace/memory/sync-tracker/_index.md
    - agent-workspace/memory/sync-tracker/README.md
  other_decisions:
    - D-002 (Track 8a SQLite spec — auto-amended via IMPL-S17-1 deviation; not a REV; D-002 spec retained as Phase 1+ migration target)

depends_on:
  - D-002

supersedes: null
superseded_by: null

defer_cycles: 0
re_attempt_prereq: |
  N/A

tags: ["phase-0", "harness", "track-8a", "confidence-score", "calibration", "IMPL"]
---

# Decision 006 — Track 8a Confidence Score System

## Context

Per Charter Principle 8 (Calibration over confidence): "system tracks its own accuracy across signal types, never claims confidence it hasn't earned through hit rate." The mechanism for this is the Confidence Score System spec'd in D-002 § Track 8 (post-REV-2 split into Track 8a + Track 8b).

D-002 § Track 8 deliverables:
- 5-category scoring (LANGUAGE / DOMAIN_UBIQUITOUS / DESIGN_THINKING / SCOPE / DECISION_ROUTING)
- per-category 0-100 internal score + tier display (LOW/MED/HIGH ladder per Q&A A2 default; REFINED post-REV-2 to ground in empirical hit rate)
- per-decision-class thresholds (CHARTER 0.99 / SCOPE 0.90 / ARCH 0.80 / IMPL 0.50; per Q&A A4)
- asymmetric weights (correction -2; revocation -3; charter-match +0.2; per Q&A A5)
- 6-step reversal protocol (per Q&A A6)
- SessionStart auto-load top-10 + on-demand `/sync-pull` skill
- Storage: SQLite + weights.yaml + auto-rendered `_index.md`

The S17 IMPL needs to ship a working Confidence Score System. The constraint surfaced in pre-flight: `command -v sqlite3` returns exit 1 — sqlite3 CLI is not available in this bash environment. Python with sqlite3 module IS available system-wide, but invoking python from `scripts/hooks/*.sh` violates L-S11-1 (Phase 0 portability rule: bash + POSIX only; no python/jq/yq/pip/npm).

## Analysis

Option-space:

- **A (SQLite + python)**: matches D-002 verbatim but adds 1 NEW L-S11-1 violation. Pre-existing 5 violations (autonomous-stop-watchdog, qa-pending-stale-mover, redact-secrets, session-export-raw, subagent-stop-logger) are documented carry-overs; adding a 6th without deferring storage-tier upgrade goes the wrong direction.

- **B (bash + TSV + flat YAML)**: storage-substrate-agnostic. Delivers all functional aspects of D-002 § Track 8 (5 categories, asymmetric weights, thresholds, reversal protocol, tier display, _index.md, sync-pull skill) using tab-separated event log + computed state. weights.yaml stays as named, parsed as flat key:value (no nested YAML). Migration to SQLite Phase 1+ when Track 8b ships python/sqlite3 module is mechanical (TSV → SQL INSERT).

- **C (defer Track 8a)**: blocks Q-E2 phase-boundary cadence + Track 8a → Track 9 sequencing. Forfeits time-value of calibration discipline.

Per D-003 § Open Questions doctrine, "Final RAG index choice: SQLite FTS5 vs simple bash grep+regex — IMPL-tier; agent picks at S11, subject to drift audit" — the storage substrate question for Track 8a is the same pattern (IMPL-tier; agent picks; subject to audit).

**Choose B**.

## Decision

### Storage substrate (IMPL-S17-1 deviation from D-002 § Track 8)

| Artifact | Format | Path |
|---|---|---|
| Event log (append-only) | TSV (tab-separated) | `agent-workspace/memory/sync-tracker/events.tsv` |
| Computed state snapshot | TSV (tab-separated) | `agent-workspace/memory/sync-tracker/state.tsv` |
| Tunable weights + thresholds | flat YAML (key:value, awk-parseable) | `agent-workspace/memory/sync-tracker/weights.yaml` |
| Auto-rendered human view | Markdown | `agent-workspace/memory/sync-tracker/_index.md` |
| Layer README | Markdown | `agent-workspace/memory/sync-tracker/README.md` |

### Categories (5; from D-002 § Track 8)

| Category | Definition | Initial score |
|---|---|---|
| LANGUAGE | Vietnamese ↔ English term translation accuracy in agent output | 50 |
| DOMAIN_UBIQUITOUS | Stockforge stock-domain ubiquitous-language consistency | 50 |
| DESIGN_THINKING | DDD tactical patterns + architecture coherence | 50 |
| SCOPE | Phase / track / session scope-boundary discipline | 50 |
| DECISION_ROUTING | Tier-aware Q&A vs self-decide vs grill choices | 50 |

Initial score = 50 (mid-range; agent has neither earned high confidence nor accumulated correction debt at session start).

### Tier display (REFINED per D-002 REV-2: empirical hit rate, not LOW/MED/HIGH ladder)

```
score >= 90  →  HIGH-CONFIDENCE  (display: "🟢 hit-rate ≥0.90 — self-decide IMPL/ARCH freely")
score 70-89  →  MED-HIGH         (display: "🟢 hit-rate 0.70-0.89 — self-decide IMPL; grill SCOPE+")
score 50-69  →  MED              (display: "🟡 hit-rate 0.50-0.69 — grill ARCH+; self-decide IMPL with citation")
score 30-49  →  MED-LOW          (display: "🟠 hit-rate 0.30-0.49 — grill SCOPE+ mandatory; IMPL with double-check")
score 0-29   →  MUST-GRILL       (display: "🔴 hit-rate <0.30 — grill ALL decisions including IMPL until score recovers")
```

### Thresholds (per-decision-class; from Q&A A4)

| Decision class | Threshold (score / 100) | Action below threshold |
|---|---|---|
| CHARTER | 99 | MUST grill via AskUserQuestion(charter-tier letter pick) |
| SCOPE | 90 | MUST grill via AskUserQuestion |
| ARCH | 80 | SHOULD grill; if self-decide, double-cite source_evidence |
| IMPL | 50 | OK to self-decide; subject to drift audit |

### Weights (asymmetric per Q&A A5; tunable in `weights.yaml`)

| Event type | Delta | Notes |
|---|---|---|
| `decision_correctness_+0.5` | +0.5 | decision matches what was right |
| `charter_match_+0.2` | +0.2 | output aligns with charter principle |
| `q_and_a_resolution_+0.1` | +0.1 | Q&A bundle answered cleanly |
| `drift_signal_-0.3` | -0.3 | drift detector raised flag |
| `decision_correction_-2` | -2.0 | user corrected the decision |
| `decision_revocation_-3` | -3.0 | decision revoked entirely |
| `thesis_revocation_-1` | -1.0 | thesis post-mortem flagged thesis was wrong |

(Delta values are score-points on the 0-100 scale.)

### Reversal protocol (6-step per Q&A A6)

1. Log revocation event in `events.tsv` (delta = -3 or -2 depending on severity).
2. Drop category score immediately by delta.
3. Revert if reversible (revoke decision in `decisions/` via `status: SUPERSEDED-BY-D-NNN` or `status: REVOKED`).
4. Append post-mortem to `agent-workspace/memory/post-mortems/<incident>.md`.
5. Set affected category to "must-grill" mode for N=5 next interactions (forced grill regardless of score).
6. After N=5 grill-cycles, reassess; if no further corrections, lift must-grill flag.

### Skill: `sync-pull`

`.claude/skills/sync-pull/SKILL.md` — on-demand skill agents invoke before SCOPE+ decisions OR when uncertain. Reads `state.tsv` + recent events; surfaces relevant category scores + tier display + threshold-vs-current. Output guides "self-decide vs grill" choice.

### Hook integration

- `scripts/hooks/sync-tracker-update.sh` — appends event to `events.tsv`, recomputes `state.tsv`, calls render hook. Invoked on Stop / Q&A-answered / drift events.
- `scripts/hooks/sync-tracker-render.sh` — generates `_index.md` from current state. Idempotent.

Both bash+awk only; 0 NEW L-S11-1 violations.

### What this means concretely

- New layer `agent-workspace/memory/sync-tracker/` with 5 file types (events.tsv / state.tsv / weights.yaml / _index.md / README.md).
- New skill `sync-pull` (≤150 LOC D1 ceiling).
- 2 new bash hooks (each ≤180 LOC bash-hook-lint budget).
- D-002 § Track 8 SQLite-spec is **auto-amended** via this decision; original SQLite spec retained as Phase 1+ migration target (when python/sqlite3 module ships via Track 8b).
- D1 baseline UNCHANGED at 16 (sync-tracker hooks ≤180 LOC; sync-pull skill ≤150 LOC).
- 0 NEW L-S11-1 violations (sync-tracker hooks bash+POSIX clean).

### What this does NOT change

- Charter principle 8 (Calibration over confidence) — fully honored.
- D-002 § Track 8 functional spec (5 categories / asymmetric weights / thresholds / reversal protocol / sync-pull skill) — fully delivered.
- D-005 § Track 5.5d learning-data topology — sync-tracker is a sibling layer; both feed independent NDJSON/TSV streams; no cross-leak.
- Any existing decision (D-001 .. D-005) — unchanged.

## Why (Reasons)

1. **L-S11-1 portability is binding.** Phase 0 harness must run bash+POSIX in any bash-equipped env. Adding python+sqlite3 dependency for Track 8a deepens portability debt without forward-progress benefit; bash+TSV ships the same value with zero new debt.

2. **D-002 storage-substrate is IMPL-tier per D-003 doctrine.** "Final RAG index choice: SQLite FTS5 vs simple bash grep+regex — IMPL-tier; agent picks; subject to drift audit." Same pattern applies here.

3. **Charter Principle 8 calibration discipline ships now, not next session.** Track 8a is the mechanism that grounds confidence claims in historical hit rate (REV-2 refinement). Deferring forfeits time-value.

4. **Migration to SQLite Phase 1+ is mechanical.** TSV → SQL INSERT is a 30-LOC bash loop. When Track 8b ships python+sqlite3 module (S18), the upgrade path is clear. No "lock-in" risk.

5. **Aligns with existing learning-data NDJSON topology.** Track 5.5d uses NDJSON event queue; sync-tracker uses TSV event queue. Both bash-portable; both POSIX-friendly. Cross-layer aggregation Phase 1+ is straightforward.

6. **Q-E2 phase-boundary cadence.** Track 7 IMPL just closed (S16) = mid-Phase-0 milestone. Track 8a in S17 matches the "phase-boundary promotion" cadence answered in Q-E2 (closed S15 Batch 1).

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| TSV concurrent-write race (multiple hooks update events.tsv simultaneously) | Low (Phase 0 single-agent) | Use `flock`-style append with `>>` atomic-on-most-fs; document Phase 1+ concurrency upgrade in D-006 § Open Questions |
| Shallow YAML parser breaks on nested weights.yaml structure | Low | Document parser limitation in weights.yaml header comment; nested structures require migration to jq/python (Phase 1+) |
| state.tsv recomputation O(N) over events.tsv grows slow at >10K events | Medium (Phase 0 expected <100 events) | Document recompute budget; add windowed-tail computation in `sync-tracker-update.sh` (only re-process last K events vs full replay) Phase 1+ |
| _index.md auto-render drifts from state.tsv (stale) | Low | Render hook chained to update hook (single shell pipeline); add staleness check via mtime comparison in `sync-tracker-render.sh` |
| Deviation from D-002 surprises future auditor | Low-Med | This file IS the auditor record; cite this from D-002 (no D-002 REV needed since D-006 = downstream impl detail per IMPL-tier doctrine) |
| Migration to SQLite when Track 8b ships gets deferred indefinitely | Medium | Add Phase 1+ migration task to current-execution.md "Carry-over to Phase 1+" section; revisit at Phase 0 close |

## Open Questions

(None blocking S17 IMPL.)

Phase 1+ open items:
- When Track 8b ships python+sqlite3, migrate sync-tracker to SQLite (1-day task); update D-006 with REV-1 noting migration.
- Concurrency upgrade: if multi-agent or multi-session writes emerge, switch from append to flock+rewrite or migrate to SQLite WAL mode.
- Scaling: events.tsv beyond 10K rows triggers windowed recompute; design Phase 1+.

## Amendments (append-only)

(none yet — D-006 is fresh as of S17 close)

## Acceptance Record

- **2026-04-29**: PROPOSED by Claude Opus 4.7 (S17 IMPL pre-flight)
- **2026-04-29**: ACCEPTED via IMPL-tier self-decide per D-003 § Open Questions doctrine + autonomous_mode=true (S15-close user correction); subject to drift audit + sandwich-verifier cross-check at Phase 0 closeout
- **2026-04-29**: VERIFIED via 5-event smoke test (PASS — all 5 categories scored; _index.md renders; below-threshold flag fires)
