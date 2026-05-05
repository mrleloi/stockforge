---
id: D-008-track-9-self-awareness-reduced
title: Track 9 — Self-Awareness Phase 0 REDUCED scope (state machine + templates + aggregator + diagnostics skill)
date: 2026-04-29
status: ACCEPTED
level: IMPL

author:
  - "Claude Opus 4.7"

source_evidence:
  - path: agent-workspace/memory/decisions/002-phase-0-harness-bootstrap-design.md
    section: "Amendments — REV-2 § B. Track-by-Track Amendments (Track 9 rows: state_machine.py / aggregate hook / hook-diagnostics / thesis-anomaly / daily-thesis / telemetry-analyst / rollup_telemetry.py)"
    quote: "ADD hook event state machine (active/completed/error/abandoned + reactivation) → packages/observability/state_machine.py / REFINE Self-Awareness Agent as deterministic-hooks Guardian + LLM aggregator at session-end ONLY (NOT continuous LLM-Guardian)"
  - path: agent-workspace/memory/decisions/002-phase-0-harness-bootstrap-design.md
    section: "Amendments — REV-3 § C. Track 9 Reduction (5.5c overlap)"
    quote: "Track 9 (Self-Awareness + OTEL) budget reduced to ~80K (was ~120K) since 5.5c absorbs OTEL stack setup + JSONL telemetry extension. Track 9 retained for live profile cards + aggregator hook + telemetry-analyst subagent (separate concerns)"
  - path: agent-workspace/memory/sessions/2026-04-29-session-15.md
    section: "S15-close further reduction context"
    quote: "Track 9 (Self-Awareness) — REDUCED scope (~50K) since S15+S16 absorb most autonomous-protocol + drift-recovery scope (Q-E1+E4 answered means autonomous-protocol covers self-awareness drift detection that Track 9 was originally going to ship)"
  - path: agent-workspace/memory/decisions/003-up06-track-5.5-sync-layer-selfcap.md
    section: "5.5c.5 — JSONL telemetry schema design"
  - path: agent-workspace/memory/self-awareness/jsonl-schema.md
    section: "Stream A + Stream B schema (S13 close)"
    quote: "schema_version: 2; component-telemetry.jsonl + learning-data/events/<UTC-date>.ndjson; failure_mode codes A/B/C/D/H/P/T"
  - path: agent-workspace/memory/self-awareness/otel-design.md
    section: "OTEL stack design (S13 deferred docker)"
  - path: agent-workspace/memory/decisions/007-track-8b-memory-l0-l1-extraction.md
    section: "packages/observability/ library landed (clean_text + extract_l0 + extract_l1 + transcript_cache + __init__)"
    quote: "L1 extraction not auto-fired in Phase 0; Phase 1+ wire-in still needed (logged as carry-over to S19+)"
  - path: agent-workspace/constitution/karpathy-principles.md
    section: "P2 Simplicity First + P3 Surgical Changes"
  - path: PROJECT_CHARTER.md
    section: "Core Principle 4 (Proprietary data moat) + Core Principle 9 (No LLM math)"

intent_classification:
  primary_intent: DECISION
  affects_charter: false
  affects_scope: false
  urgency: NORMAL
  complexity_score: 50

options_considered:
  - id: A
    summary: "Full Track 9 port — state_machine.py + aggregator + hook-diagnostics + thesis-anomaly-detector + daily-thesis-summary + telemetry-analyst subagent + rollup_telemetry.py + OTEL docker stack"
    pros:
      - "Closes Track 9 with all REV-2 § B amendments shipped"
      - "Thesis-side skills available for Phase 1+ thesis sessions"
      - "OTEL Grafana dashboards visible immediately"
    cons:
      - "Budget ~120-150K (was REV-2 estimate); exceeds REDUCED ~50K target per S15-close"
      - "thesis-anomaly + daily-thesis skills consume thesis data NOT YET PRESENT in Phase 0 (zero thesis logged); Phase 1+ ships thesis pipeline"
      - "telemetry-analyst LLM subagent re-introduces continuous LLM-Guardian cost concern (UP02 §1.4) that REV-2 § B explicitly REFINEd away"
      - "rollup_telemetry.py duplicates component-telemetry.sh + metric-failure-mode-rate.sh + learning-index-rebuild.sh that already shipped S13"
      - "OTEL docker stack adds infra dependency (Grafana container) before any thesis events emit; Phase 1+ when first thesis lands"
  - id: B
    summary: "REDUCED Phase 0 port — state_machine.py + self-awareness/ template seeds + aggregator hook + hook-diagnostics skill (only)"
    pros:
      - "Fits REDUCED ~50K target per S15-close"
      - "Karpathy P2 (Simplicity First): only Phase-0-applicable deliverables; defers thesis-side skills to when thesis data exists (P3 Surgical)"
      - "state_machine.py extends packages/observability/ (consumes S18 deliverable as planned per REV-2 § B Track 9 dependency on Track 8b)"
      - "Aggregator hook is deterministic bash+awk (UP02 §1.4 cost concern preserved; matches REV-2 § B REFINE: deterministic-hooks Guardian)"
      - "hook-diagnostics skill ≤150 LOC consumes packages/observability/state_machine + transcript_cache (parser plug-in pattern from S18 SKILL.md design)"
      - "Self-awareness templates seed Phase 1+ profile cards without auto-render (caller-fills pattern same as L1 dispatch wire-in IMPL-S18-1)"
    cons:
      - "thesis-anomaly + daily-thesis + telemetry-analyst + rollup_telemetry + OTEL docker deferred to Phase 1+"
      - "Profile cards stay markdown templates (no auto-rendering yet); Phase 1+ aggregator can promote to JSON/SQLite"
  - id: C
    summary: "Defer Track 9 entirely; absorb to Phase 1+; close Phase 0 with state of S18"
    pros:
      - "Lowest token spend in Phase 0"
      - "Phase 1+ has thesis events to populate self-awareness data anyway"
    cons:
      - "Leaves Phase 0 with NO state_machine.py — packages/observability/ caller cannot reason about hook-event lifecycle"
      - "Track 9 dependency on packages/observability/ (per REV-2 § B Track 9 row A-14) breaks if not shipped now"
      - "Phase 0 final verifier (S20) would flag Track 9 as 'unclosed' — adds rework"

chosen: B
chosen_rationale: |
  Option B fits REDUCED ~50K budget per S15-close and respects Karpathy P2 + P3:
  state_machine.py is the ONLY genuinely Phase-0-applicable Track 9 deliverable (other Track 9
  amendments require thesis data or live-traffic OTEL infra not yet present). Aggregator hook
  preserves REV-2 § B REFINE doctrine (deterministic-hooks Guardian; LLM aggregator session-end
  ONLY — NOT continuous). hook-diagnostics skill follows S18 session-memory-l0-l1 SKILL.md
  pattern: ≤150 LOC + consumes packages/observability/. Template seeds for self-awareness/
  follow IMPL-S18-1 caller-fills pattern. Thesis-side amendments (anomaly + daily-thesis +
  telemetry-analyst + rollup_telemetry) defer to Phase 1+ when thesis data exists. OTEL docker
  defers per same Phase 1+ dependency on emitted thesis events. Closure of Track 9 is achieved
  for Phase 0 envelope without re-introducing Phase 1+ scope creep.

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-04-29
    via: "S19 SessionStart — checkpoint S18-close recommendation Option B Track 9"
  - actor: agent
    action: ACCEPTED
    at: 2026-04-29
    via: "IMPL-tier self-decide per D-003 Open Questions doctrine + autonomous_mode=true (Charter Principle 6 + 8 satisfied via deterministic substrate; non-charter scope; reversible if drift-audit catches)"
    notes: "Autonomous mode + IMPL-tier rule applies — no AskUserQuestion required for non-charter, non-SCOPE storage/library decisions. Subject to drift audit + S20 sandwich-verifier cross-check."

verified_by:
  - mechanism: pytest-state-machine
    at: 2026-04-29
    result: PASS
    notes: "≥10 tests covering 4 states + 5 transitions + invalid-transition rejection + reactivation flow"
  - mechanism: aggregator-smoke-test
    at: 2026-04-29
    result: PASS
    notes: "3-event simulation in dispatch.jsonl + .transcript-tokens; aggregator emits sessions-rollup.tsv row"
  - mechanism: drift-signals-D1-D9
    at: 2026-04-29
    result: PASS
    notes: "D1 baseline holds (hook-diagnostics SKILL.md ≤150); 0 NEW L-S11-1 / 0 NEW D9 / 0 D-IDENTITY findings"

affects:
  charter: false
  spec_files: []
  code_paths:
    - "packages/observability/state_machine.py"
    - "packages/observability/__init__.py"
    - "packages/observability/tests/test_state_machine.py"
    - "agent-workspace/memory/self-awareness/README.md"
    - "agent-workspace/memory/self-awareness/profile-template.md"
    - "agent-workspace/memory/self-awareness/known-issues.md"
    - "agent-workspace/memory/self-awareness/best-practices.md"
    - "scripts/hooks/self-awareness-aggregate.sh"
    - ".claude/skills/hook-diagnostics/SKILL.md"
  config_files: []
  other_decisions: []

depends_on:
  - D-002   # REV-2 § B Track 9 amendments + REV-3 § C reduction
  - D-003   # Open Questions doctrine — IMPL-tier self-decide
  - D-007   # packages/observability/ library (state_machine extends)

supersedes: null
superseded_by: null

defer_cycles: 0
re_attempt_prereq: "N/A — single-cycle resolution per IMPL-tier self-decide"

tags: ["phase-0", "track-9", "self-awareness", "state-machine", "aggregator", "diagnostics", "reduced-scope"]
---

# D-008 — Track 9 Self-Awareness Phase 0 REDUCED scope

> Status: ACCEPTED via IMPL-tier self-decide per D-003 § Open Questions doctrine + autonomous_mode=true (S15-close confirmed). Subject to drift audit + S20 sandwich-verifier cross-check at Phase 0 closeout.

---

## Decision

Phase 0 ships REDUCED Track 9 — 4 deliverables only:

1. **`packages/observability/state_machine.py`** — pure-Python hook event state machine. 4 states (`active` / `completed` / `error` / `abandoned`) + 5 valid transitions + reactivation flow. Dataclasses-only (no framework dependency per Charter rule). Exposes `HookEventState` + `HookEvent` + `transition()` + `is_terminal()` API.

2. **`agent-workspace/memory/self-awareness/`** — template seeds:
   - `README.md` — directory contract + Phase 0 vs Phase 1+ boundary
   - `profile-template.md` — schema for `<model>-<effort>.md` profile cards (Phase 1+ aggregator fills)
   - `known-issues.md` — append-only failure catalog seed (3 known-issue stub entries)
   - `best-practices.md` — append-only learned-rule catalog seed (3 rule stub entries)

3. **`scripts/hooks/self-awareness-aggregate.sh`** — Stop hook (≤180 LOC, bash+awk only per L-S11-1 portability discipline). Reads `dispatch.jsonl` + `.transcript-tokens` + `.session-hooks.log` → emits aggregated row to `agent-workspace/memory/self-awareness/sessions-rollup.tsv`. NOT continuous-LLM-Guardian (matches REV-2 § B REFINE doctrine).

4. **`.claude/skills/hook-diagnostics/SKILL.md`** ≤150 LOC D1. Consumes `packages/observability/state_machine.py` + `transcript_cache.py`. Diagnostic skill for hook event introspection. allowed-tools=[Read, Glob, Grep, Bash].

Plus `packages/observability/tests/test_state_machine.py` ≥10 tests (raises observability test count from 62 to ≥72).

---

## Why this scope (not full Track 9)

Per S15-close + REV-3 § C: S15 PLAN + S16 IMPL absorbed autonomous-protocol scope that REV-2 originally allocated to Track 9. Track 5.5c.5 shipped JSONL telemetry schema (`self-awareness/jsonl-schema.md`) and Track 5.5c.4 shipped OTEL design (`self-awareness/otel-design.md`). component-telemetry.sh + metric-failure-mode-rate.sh + learning-index-rebuild.sh already cover the rollup_telemetry.py concern (S13).

Track 9 deferred to Phase 1+ (with thesis data as prerequisite):
- `thesis-anomaly-detector` skill — needs thesis events to detect anomalies on
- `daily-thesis-summary` skill — needs daily thesis stream
- `telemetry-analyst` subagent — Phase 1+ when LLM dispatch wires (per IMPL-S18-1 caller-fills doctrine)
- `rollup_telemetry.py` Python rewrite — component-telemetry.sh covers Phase 0
- OTEL docker stack — Phase 1+ when thesis events emit at sustained rate

Phase 0 final verifier (S20) cross-checks this scope reduction against REV-2 § B + REV-3 § C amendments.

---

## state_machine.py contract (concrete)

States + transitions per REV-2 § B Track 9 row A-14:

```
states     = {active, completed, error, abandoned}
transitions:
  active     → completed     (normal completion)
  active     → error         (tool failure / exception)
  active     → abandoned     (timeout / interrupt / no-op)
  error      → active        (reactivation — retry from caller)
  abandoned  → active        (reactivation — retry from caller)
  completed  → (terminal)    (no further transitions)
```

5 forward + 2 reactivation = 7 valid transitions; all others raise `InvalidTransitionError`.

Module exports (per `__init__.py` extension):
- `HookEventState` (Enum)
- `HookEvent` (dataclass: hook_name, started_at, current_state, transitions_log)
- `transition(event, new_state)` — validate + apply
- `is_terminal(state)` — completed only
- `InvalidTransitionError` (exception)

---

## Aggregator hook contract (concrete)

`scripts/hooks/self-awareness-aggregate.sh` — Stop hook trigger:
- INPUT: `agent-workspace/memory/dispatch.jsonl` + `agent-workspace/memory/.transcript-tokens` + `agent-workspace/memory/.session-hooks.log` + `agent-workspace/memory/component-telemetry.jsonl` (if exists)
- COMPUTE (deterministic bash+awk only):
  - `session_id` (from latest .session-hooks.log entry)
  - `session_n` (parsed from latest sessions/2026-*-N.md filename if present)
  - `tokens_real` (from .transcript-tokens)
  - `tools_used` (count from dispatch.jsonl)
  - `subagents_dispatched` (count Task tool entries)
  - `failure_modes` (sum count by code from component-telemetry.jsonl failure_mode field)
  - `wall_clock_minutes` (mtime delta of dispatch.jsonl)
- OUTPUT: append row to `agent-workspace/memory/self-awareness/sessions-rollup.tsv` (TSV header on first run)
- BEST-EFFORT: errors suppressed via `|| true` (never blocks Stop hook pipeline)

NO LLM dispatch in Phase 0. Phase 1+ telemetry-analyst subagent reads sessions-rollup.tsv as input.

---

## hook-diagnostics skill contract (concrete)

`.claude/skills/hook-diagnostics/SKILL.md` ≤150 LOC. Frontmatter: name + description + allowed-tools=[Read, Glob, Grep, Bash]. Sections:
- Purpose
- When to Use (3 cases: hook event lifecycle introspection / aggregator output reading / state-machine validation)
- When NOT to Use (2 cases: prod alerting / cross-session pattern mining → use Phase 1+ telemetry-analyst)
- 3 Examples (state-machine usage / aggregator output read / dispatch.jsonl event grep)
- API Quick Reference
- Anti-Patterns

---

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| state_machine.py not consumed by any Phase 0 caller (premature ship) | hook-diagnostics skill consumes it; Phase 1+ aggregator + telemetry-analyst extend |
| Aggregator schema drifts from JSONL schema v2 | `self-awareness/jsonl-schema.md` is source-of-truth; aggregator references field-by-field |
| sessions-rollup.tsv unbounded growth | Phase 1+ rotation policy; Phase 0 expected ≤30 sessions × 1 row = ≤30 lines |
| hook-diagnostics SKILL.md drift over 150 D1 ceiling | progressive-disclosure pattern (companion-via-references per L-S16-1 if needed) |
| Reactivation transitions ambiguous (active → completed → active?) | only `error` and `abandoned` reactivate; `completed` is terminal |
| Aggregator runs but emits empty TSV (no events in dispatch.jsonl) | header-only + warning to .session-hooks.log; Phase 1+ alerting |

---

## Open Questions (Phase 1+ deferral)

1. **Profile card auto-render**: Phase 1+ when telemetry-analyst subagent reads sessions-rollup.tsv + component-telemetry.jsonl → fills profile-template.md per (model × effort) pair. Phase 0 ships TEMPLATE only.

2. **OTEL docker stack ship**: Phase 1+ when thesis events emit at sustained rate (≥10/day). Design doc `self-awareness/otel-design.md` is the schema; docker-compose.yml + Grafana dashboards land Phase 1+.

3. **thesis-anomaly-detector + daily-thesis-summary skills**: Phase 1+ when thesis log has ≥5 entries (Charter Month 3 success criterion). Phase 0 has zero thesis events.

4. **telemetry-analyst subagent**: Phase 1+ when Anthropic SDK client wires + LLM dispatch budget defined. UP02 §1.4 cost concern preserved by deferring continuous LLM aggregation.

5. **rollup_telemetry.py Python rewrite**: Phase 1+ if profiling shows component-telemetry.sh + metric-failure-mode-rate.sh insufficient. Phase 0 expects them adequate.

---

## References

- D-002 § Amendments REV-2 § B (Track 9 amendments) + REV-3 § C (reduction)
- D-003 § 5.5c.5 (JSONL schema produced) + § Open Questions (IMPL-tier doctrine)
- D-007 (packages/observability/ library — state_machine extends)
- `agent-workspace/memory/self-awareness/jsonl-schema.md` (S13 close — schema_version 2)
- `agent-workspace/memory/self-awareness/otel-design.md` (S13 close — docker deferred)
- S15-close session log § "Estimated S19 budget" (~50K REDUCED basis)
- Charter Principle 4 (Proprietary data moat) + 6 (Human-in-loop) + 9 (No LLM math)
