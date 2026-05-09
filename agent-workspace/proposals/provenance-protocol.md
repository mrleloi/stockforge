# Provenance Protocol — DEFERRED

> **Status**: DEFERRED (D-013 § Deferred ratified 2026-05-01 at S35; re-affirmed S38 batch answered bundle 2026-05-01-001 — "4 OTHER proposals (financial-data-protocol-amendment-VN, invariants-amendment-VN, architecture-amendment, provenance-protocol) were routed to **defer** with explicit re-trigger conditions per D-013").
> **Re-trigger condition**: Phase 3 first thesis ships (per D-013 deferred-list policy — "provenance-protocol formal charter — Phase 3 first thesis ships").
> **Status-field updated**: 2026-05-07 (S124 zombie-cleanup; hook proposal-bundle-advisor was firing false-positive on stale PROPOSAL status).
> **Move-to-constitution**: When re-trigger condition met AND user approves, this file moves to `agent-workspace/constitution/provenance-protocol.md` and becomes binding. Until then, agents SHOULD follow it but it is not enforced by deny-list.
> **Source decisions**: D-002 § Track 2 (REV-2) + Q&A clusters B/C/E (provenance + decision-id format + notification channels) + D-013 (defer-routing).
> **Author**: Claude Opus 4.7, S2 (2026-04-29).

## Purpose

Define **WHEN** and **HOW** decisions, theses, and confidence claims are recorded so that any artifact in this repo can be traced backward to:
1. The human input(s) that motivated it.
2. The agent reasoning that produced it.
3. The verification step(s) that confirmed it.
4. Any downstream artifacts that depend on it.

Without this discipline, autonomous coding accumulates **silent drift** — the failure mode observed in orch (CF-DOGFOOD-2) where agent-decisions overrode human-CRITICAL items because there was no traceability protocol.

---

## Scope

This protocol applies to:

| Artifact type | Storage | Provenance owner |
|---|---|---|
| Architectural decision | `agent-workspace/memory/decisions/D-NNN-*.md` | Agent (must cite) |
| Stock thesis | `agent-workspace/memory/thesis-log/<ticker>-<date>.md` | Agent (must cite source + as-of-date per I-S2) |
| Confidence claim | `agent-workspace/memory/sync-tracker/sync-tracker.db` + auto-rendered `_index.md` | Agent (must trace to historical hit rate) |
| Charter exception / amendment | `human-workspace/decisions/D-H-NNN-*.md` | Human |
| Spec | `specs/**/*.md` | Mixed; agent may author, human approves |
| Pattern claim | `agent-workspace/memory/patterns-discovered/*.md` | Agent (must cite source artifact + path:line) |
| Drift signal | `agent-workspace/memory/drift-logs/<TS>-<signal>.md` | Hook script + agent commentary |
| Post-mortem | `agent-workspace/memory/post-mortems/<incident>.md` | Agent + human review |

---

## When to log a decision

A new entry in `decisions/` is REQUIRED when one of:

1. **CHARTER-touching**: any change that could affect mission, identity NOT-list, autonomous mode rules, or invariants I-S1..I-S35. → Q&A bundle FIRST; decision is the audit of the answered Q&A.
2. **SCOPE-touching**: phase boundary, multi-track plan, BC count change, port-list scope, dependency-direction reversal.
3. **ARCH-touching**: library substitution, schema migration, hook architecture, model-routing change.
4. **IMPL-touching with cross-cutting effect**: decision that affects ≥3 files in different bounded contexts. (Single-file refactors don't need decisions; commit message suffices.)
5. **Reversal**: any time an earlier decision is paused, revoked, or amended (REV-N or supersedes).
6. **User-prompt drop**: every `human-workspace/user_prompt/<file>.txt` triggers either a single decision or a Q&A bundle that resolves to one. NEVER silently absorbed.

If none of the above triggers apply, the action is a **routine implementation choice** — log in session journal, not in decisions/.

---

## How to log a decision

### Step 1 — Author the file

Create `agent-workspace/memory/decisions/D-NNN-<slug>.md` using the canonical template:
- `agent-workspace/memory/decisions/_template.md`

Frontmatter is BINDING (12+ fields). Empty arrays trigger drift detection (`DR-PROV` — unanchored claim).

### Step 2 — Cite source_evidence

Every decision MUST cite at least one upstream source. Acceptable types (in priority order):

1. `human-workspace/user_prompt/<file>.txt` (highest authority)
2. `human-workspace/decisions/D-H-NNN-*.md` (strategic human decision)
3. `human-workspace/q-and-a/answered/<file>.md` (resolved Q&A)
4. `agent-workspace/memory/patterns-discovered/*.md` (mining evidence)
5. `agent-workspace/memory/post-mortems/*.md` (failure-driven learning)
6. `agent-workspace/memory/drift-logs/*.md` (drift signal evidence)
7. `specs/**/*.md` (formal spec clause)
8. `PROJECT_CHARTER.md § X.Y` (charter section)

A decision with `source_evidence: []` is **invalid** and will be flagged by the drift-detector hook (Track 5).

### Step 3 — Determine level

| Level | Self-decide threshold | Q&A required? |
|---|---|---|
| CHARTER | confidence ≥ 0.99 | Almost always YES; charter changes are rare |
| SCOPE | ≥ 0.90 | Often YES if affects phase or BC structure |
| ARCH | ≥ 0.80 | Optional; case-by-case |
| IMPL | ≥ 0.50 | Rarely needed |

Confidence comes from the Confidence Score System (Track 8a) — per-category running estimate. If `sync-tracker.db` does not yet exist (pre-Track 8a), default to "ask if uncertain."

### Step 4 — Approval chain

Append entries to `approval_chain` as the decision moves PROPOSED → ACCEPTED → AMENDED → SUPERSEDED/REVOKED. Never delete prior entries.

### Step 5 — Cross-link

- Update `agent-workspace/memory/decisions/README.md` index table.
- If decision affects existing decisions: update their `superseded_by` or `verified_by` arrays.
- If decision affects code: list paths in `affects.code_paths`.

### Step 6 — Verifier (Tier-2 gate)

For SCOPE+ decisions, dispatch `sandwich-verifier` subagent for adversarial review BEFORE marking ACCEPTED. The verifier checks:
- Does `source_evidence` actually contain what was cited?
- Are `options_considered` exhaustive (or is there a missing option)?
- Does `chosen_rationale` follow from evidence, or is it inference-only?
- Are `affects` lists complete (or are there hidden blast-radius surprises)?

Verifier output is appended to `verified_by` field with mechanism `sandwich-verifier`.

---

## When to log a thesis

Per I-S2 + I-S20, every thesis MUST include:

- `source_url` (or local file path) for every fact cited
- `as_of_date` for every number
- `confidence` traced to historical hit rate, not LLM "feeling certain"
- `bear_case` section explicit (I-S10)

Thesis files live in `agent-workspace/memory/thesis-log/<ticker>-YYYY-MM-DD.md`. Schema details in `specs/tier2-feature/001-validate-investment-thesis.md`.

---

## When to log a confidence claim

Per Track 8a (Confidence Score System):

- Every Q&A answered triggers a category update (LANGUAGE, DOMAIN_UBIQUITOUS, DESIGN_THINKING, SCOPE, DECISION_ROUTING).
- Every decision-correction or revocation drops the relevant category by `-2` or `-3` (asymmetric weights, Q&A A5).
- Hooks (Track 5) auto-update `sync-tracker.db`; agent does NOT manually edit it.

A confidence claim made in narrative ("I am 80% sure that…") is INVALID unless it traces to a `sync-tracker.db` entry or `agent-workspace/calibration/<signal>.md` historical data.

---

## R7 Mitigation: Defer-Cycle Tracking

Per Decision 002 REV-2 § C R7 (msmdp Decision Provenance Chain pattern):

- Each defer of a decision increments `defer_cycles` by 1.
- `defer_cycles > 3` triggers drift-detector alert; mandatory Q&A bundle to either commit or revoke.
- `re_attempt_prereq` field documents what must change for resumption.

This is the deterministic backstop against can-kicking. The agent cannot indefinitely postpone a decision while pretending it's "in progress."

---

## Drift Detection Integration (Track 5 hooks)

Hook scripts (deferred to Track 5 implementation) will scan:

1. **DR-PROV** — any decision with empty `source_evidence`
2. **DR-DEFER** — any decision with `defer_cycles > 3`
3. **DR-CITE** — any thesis or confidence claim missing `source_url` or `as_of_date`
4. **DR-LLM-MATH** — any narrative output containing computed numbers without code-source citation (I-S1)
5. **DR-CHARTER** — any decision marked `level: CHARTER` without `human` in `approval_chain`
6. **DR-ORPHAN** — any `superseded_by: D-NNN` pointing to a non-existent file
7. **DR-DEP** — any `depends_on` cycle (A→B→A)

Each violation produces a `drift-logs/<TS>-DR-<code>.md` entry; agent must triage in next SessionStart.

---

## Tier-Aware Prompting (when to ask vs. when to log)

| Trigger | Confidence | Action |
|---|---|---|
| User-prompt landed; intent unclear | any | Q&A bundle (intent-classifier dispatched) |
| User-prompt landed; intent clear; no charter/scope conflict | high | Decision auto-logged citing user_prompt |
| User-prompt landed; intent clear; charter/scope conflict | any | Q&A bundle FIRST; decision is the audit |
| Pattern mining surfaced amendment | medium | Decision (REV-N or new) citing pattern |
| Drift detected | n/a | Drift log + decision (if remedy is structural) |
| Routine implementation choice | high | Session journal only; no decision |
| ≥ ARCH-tier and confidence < 0.80 | low | Q&A bundle |

---

## Acceptance Process for This Protocol

This document is in `agent-workspace/proposals/`. It moves to `agent-workspace/constitution/` only when:
1. User reviews it explicitly (read-confirm or chat acknowledgment).
2. Track 7 builds the constitution-promotion mechanism.
3. User issues `/promote-proposal provenance-protocol.md` (skill to be built in Track 7) or equivalent verbal authorization.

Until then, this is a **strong recommendation** that agents should follow but is not enforced by deny-list. Once promoted, edits to it require the constitution-amendment process (charter-tier change requiring explicit user prompt + Q&A).

---

## Open Questions for Track 7 Review

1. Should `DR-PROV` be a hard-fail (block PostToolUse) or soft-warn for first 30 days? Recommend SOFT-WARN initially per REV-2 R5 pattern.
2. Should sandwich-verifier dispatch be MANDATORY for SCOPE+ decisions, or autonomous-mode-only? Recommend MANDATORY post-Track 7 (autonomous mode active).
3. Schema for `agent-workspace/calibration/<signal>.md` — defer to Phase 1+ when first thesis lands?
4. Q&A E2 confirmed 12-field schema; does `_template.md` cover all 12 satisfactorily, or are fields missing?
