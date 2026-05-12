# Decision Log — StockForge

> **Status**: Track 2 deliverable per Decision 002 § Track 2 (REV-2).
> **Schema source**: [_template.md](_template.md) — every decision file MUST start with the canonical frontmatter.
> **Last updated**: 2026-05-12 (S253 — D-056 added: charter v1.1 Principle 11 ratification)

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
| [D-056](056-S253-charter-v1.1-principle-11-ratified.md) | PROJECT_CHARTER.md v1.0 → v1.1 APPLIED — Principle 11 (Harness must self-verify firing) ratified at S253 | CHARTER | ACCEPTED | 2026-05-12 | proposals/charter-revision-v1.1-harness-self-verify-firing.md + Q-P4-3 S251 AskUserQuestion |
| [D-054](054-bear-quant-retry-validator-symmetry.md) | Bear/Quant retry-validator symmetry (B5 asymmetric budget) | IMPL | ACCEPTED | 2026-05-10 | observations/track-A-S240-anti-flake-run2.md (L-S240-1) |
| [D-053](053-S237-bull-A2-retry-validator-promote.md) | Bull A2 retry-validator promoted to production default | IMPL | ACCEPTED | 2026-05-10 | Q-P4-1-AUTO-PICK |
| [D-052](052-S229-anthropic-sdk-codepath-full-removal.md) | Delete anthropic SDK code-paths + drop pyproject dependency | ARCH | ACCEPTED | 2026-05-09 | via D-050 (S227 systemic refactor) |
| [D-051](051-S228-news-extractor-subagent-refactor.md) | BC-5 news extractor — flip default transport from anthropic SDK to claude CLI subagent | ARCH | ACCEPTED | 2026-05-09 | via D-050 (S227 systemic refactor) |
| [D-050](050-S227-anthropic-to-subagent-systemic.md) | Replace ANTHROPIC_API_KEY with Claude Code subagent dispatch (systemic) | CHARTER | ACCEPTED | 2026-05-09 | chat 2026-05-09 (S227 AskUserQuestion) |
| [D-049](049-S220-L-S208-1-portability-promoted-to-constitution.md) | charter-L-S208-1-settings-portability.md promoted to agent-workspace/constitution/portabilit... | — | ratified | — | L-S208-1 ratification (S220 deny-lift cycle) |
| [D-048](048-S220-T5-harness-health-protocol-promoted-to-constitution.md) | harness-health-protocol.md promoted from agent-workspace/proposals/ to agent-workspace/const... | — | ratified | — | via D-033 (T5 protocol; M-S173-1 deny-lift) |
| [D-047](047-S220-charter-v1.1-principle-11-ratified.md) | PROJECT_CHARTER.md v1.0 → v1.1 ratified — Principle 11 (Harness must self-verify firing) ins... | — | ratified | — | via D-034 (charter v1.1 cool-down) |
| [D-046](046-S190-hook5-stderr-redirect.md) | S190 chain-stop discrimination at #5/#6 boundary — H-a non-destructive stderr-redirect-to-lo... | SCOPE | H-a-REJECTED-FORMAL-AT-3-OF... | 2026-05-09 | decisions/044-S188-hook5-stdout-fix.md |
| [D-045](045-S189-hh-h1-threshold-relaxation.md) | S189 HH-H.1 stale-checkpoint guard threshold relaxation 300s→1800s — autonomous-loop revival... | SCOPE | ACCEPTED-AND-SHIPPED | 2026-05-08 | .auto-reboot-BLOCKED-stale-checkpoint (S188) |
| [D-044](044-S188-hook5-stdout-fix.md) | S188 chain-stop discrimination at #5/#6 boundary — H-c additive stdout JSON fix to hook-firi... | SCOPE | SHIPPED-PENDING-PRODUCTION-... | 2026-05-07 | checkpoints/2026-05-07-S187-archive.md |
| [D-043](043-S186-userprompt-stdout-fix.md) | S186 UserPromptSubmit hook chain truncation Option D empirical-test fix — minimal stdout JSO... | SCOPE | ACCEPTED-AND-SHIPPED | 2026-05-07 | checkpoints/latest.md (S186) |
| [D-042](042-S184-continue-injector-spawn-extraction.md) | S184 continue-injector spawn extraction restores SessionStart hook chain on Windows | SCOPE | ACCEPTED-AND-SHIPPED | 2026-05-07 | checkpoints/latest.md (S184) |
| [D-041](041-S181-HH-6-HH-10-batch-cleanup.md) | S181 HH-6 dispatch-pending sidecar sweep + HH-10 6 companion firing-tests batch ship | SCOPE | ACCEPTED-AND-SHIPPED | 2026-05-07 | checkpoints/latest.md (S181) |
| [D-040](040-S180-renderer-trim-and-file-pattern-lint-ship.md) | Boot-summary renderer trim (per-line truncation knob) + file-pattern-hook-pre-flight-lint ho... | SCOPE | ACCEPTED-AND-SHIPPED | 2026-05-07 | notifications/working-memory-budget-OVER-2026-05-07.md |
| [D-039](039-S179-file-pattern-hook-batch-fix.md) | File-pattern hook batch fix per L-S176-1 retro-fit (sync-tracker glob FIX, bootstrap-summary... | SCOPE | ACCEPTED-AND-SHIPPED | 2026-05-07 | observations/2026-05-07-S178-file-pattern-hook-compliance-audit.md |
| [D-038](038-S176-HH-C2-staleness-watchdog-misfire-fix-proposal.md) | HH-C.2 staleness watchdog misfire fix — Option E (retire Check A, fix Check B glob, rename, ... | SCOPE | ACCEPTED-AND-SHIPPED | 2026-05-07 | observations/2026-05-07-S176-HH-C2-misfire-root-cause.md |
| [D-037](037-S175-M-S171-1-prevention-hooks.md) | M-S171-1 prevention hooks (idle-escape-detector + phase-status-coherence) shipped with compa... | SCOPE | ACCEPTED-AND-SHIPPED | 2026-05-07 | mistake-log.md (M-S171-1) |
| [D-036](036-S174-HH-G-portability-close.md) | HH-G portability close (general-harness CLAUDE.md template + /attach smoke runner + companio... | SCOPE | ACCEPTED-AND-SHIPPED | 2026-05-07 | checkpoints/latest.md (S174) |
| [D-035](035-S173-T6-harness-health-self-scan-hook.md) | T6 — harness-health-self-scan.sh continuous hook (impl + firing-test + production-firing evi... | CHARTER | ACCEPTED-AND-SHIPPED | 2026-05-07 | q-and-a/pending/2026-05-07-001-phase-3.5-T5-T6-T8-charter-gate.md |
| [D-034](034-S173-T8-charter-revision-v1.1-principle-11-proposal.md) | T8 — Charter Revision v1.0 → v1.1 PROPOSAL (Principle 11 — Harness Self-Verify Firing) — Coo... | CHARTER | PROPOSED | 2026-05-07 | q-and-a/pending/2026-05-07-001-phase-3.5-T5-T6-T8-charter-gate.md |
| [D-033](033-S173-T5-harness-health-protocol-charter-promote.md) | T5 — Harness Health Protocol charter-tier authoring (12-signal catalog HH-1..HH-12) | CHARTER | ACCEPTED | 2026-05-07 | q-and-a/pending/2026-05-07-001-phase-3.5-T5-T6-T8-charter-gate.md |
| [D-032](032-S51-BC-7-architecture-crowd-sentiment.md) | BC-7 Crowd Sentiment + Pump Detection architecture (Tracks J+K) | — | ACCEPTED | — | specs/tier2-feature/003-crowd-sentiment-pump-detection.md |
| [D-031](031-S48h-charter-promote-qa-lifecycle-auto-mv-HH-E.2.md) | S48h — Q-S48g-1 charter-promote agent-workspace/CLAUDE.md § Connection to human-workspace/ 4... | — | ACCEPTED | — | proposals/qa-lifecycle-contract-revision-HH-E.2.md |
| [D-030](030-S48f-charter-promote-autonomous-protocol-rule-10-mode-E.md) | S48f — Q-S48e-1 charter-promote autonomous-protocol.md Rule 10 (Autonomous-Mode Defection Fo... | — | ACCEPTED | — | proposals/autonomous-protocol-amendment-mode-E.md |
| [D-029](029-S48d-charter-promote-drift-signals-reconciliation.md) | S48d — Q-S48c-1 charter-promote drift-signals.md Tiered Coverage Map (DR1-DR12 ↔ D1-D9 recon... | — | ACCEPTED | — | proposals/drift-signals-reconciliation.md |
| [D-028](028-S48d-CLAUDE-md-session-end-ritual-extension.md) | S48d — HH-C.4 CLAUDE.md § Session End ritual extension (5 → 9 steps; codifies HH-C.1+2+3 wat... | — | ACCEPTED | — | proposals/claude-md-session-end-extension-HH-C.4.md |
| [D-027](027-S45-BC-6-architecture-influence-network.md) | BC-6 Influence Network architecture (Tracks G+H+I) | — | ACCEPTED | — | specs/tier2-feature/002-influence-network-tracking.md |
| [D-026](026-S43e-charter-promote-bundle-C1-C2.md) | S43e charter-promote bundle — C1 architecture LLM substrate boundary + C2 decision-disciplin... | — | ACCEPTED | — | proposals/architecture-amendment-C1-llm-substrate-boundary.md |
| [D-025](025-S43d-phase-2-envelope-amendment.md) | Phase 2 token-budget envelope amendment — calibration delta after Track F dogfood | IMPL | ACCEPTED | 2026-05-04 | q-and-a/pending/2026-05-01-003-S39-track-E-bundle-2-scope-amendments.md |
| [D-024](024-S43c-HR-4-charter-promote-memory-routing-tree.md) | Promote HR-4 memory-routing-tree.md from proposals/ to constitution/ + wire memory-routing-a... | CHARTER | ACCEPTED | 2026-05-04 | proposals/memory-routing-tree.md |
| [D-023](023-S43c-charter-amend-autonomous-protocol-cost-substrate.md) | Amend constitution/autonomous-protocol.md with NEW Rule 9 — Cost Substrate (subagent-first, ... | CHARTER | ACCEPTED | 2026-05-04 | q-and-a/pending/2026-05-01-003-S39-track-E-bundle-2-scope-amendments.md |
| [D-022](022-S43c-charter-promote-invariants-VN.md) | Append Vietnam-Domain Invariants I-S55..I-S65 to constitution/invariants.md | CHARTER | ACCEPTED | 2026-05-04 | q-and-a/pending/2026-05-01-003-S39-track-E-bundle-2-scope-amendments.md |
| [D-021](021-S43c-charter-promote-financial-data-protocol-VN.md) | Append Vietnam-Domain Rules 12-15 to constitution/financial-data-protocol.md | CHARTER | ACCEPTED | 2026-05-04 | q-and-a/pending/2026-05-01-003-S39-track-E-bundle-2-scope-amendments.md |
| [D-020](020-S43c-charter-promote-session-budgets-mode-abcd.md) | Append Mode A/B/C/D dispatch + Verifier Budget by Scope to constitution/session-budgets.md | CHARTER | ACCEPTED | 2026-05-04 | q-and-a/pending/2026-05-01-003-S39-track-E-bundle-2-scope-amendments.md |
| [D-019](019-S43c-charter-promote-financial-data-protocol-rule-11.md) | Append Rule 11 (Hook Portability Per Phase) to constitution/financial-data-protocol.md | CHARTER | ACCEPTED | 2026-05-04 | q-and-a/pending/2026-05-01-003-S39-track-E-bundle-2-scope-amendments.md |
| [D-018](018-S43c-charter-promote-architecture-amendment.md) | Promote architecture-amendment.md (Slash Command vs Skill split + companions) to constitutio... | CHARTER | ACCEPTED | 2026-05-04 | q-and-a/pending/2026-05-01-003-S39-track-E-bundle-2-scope-amendments.md |
| [D-017](017-S38-charter-promote-memory-tiers.md) | Promote memory-tiers.md to constitution + author tier1-bloat-check.sh hook | CHARTER | ACCEPTED | 2026-05-01 | q-and-a/pending/2026-05-01-001-S35-charter-promote-batch.md |
| [D-016](016-S38-charter-promote-decision-discipline.md) | Promote decision-discipline.md to constitution + Rule 2 sub-clause (L-S26-1) + Rule 4a phase... | CHARTER | ACCEPTED | 2026-05-01 | q-and-a/pending/2026-05-01-001-S35-charter-promote-batch.md |
| [D-015](015-S38-charter-promote-autonomous-protocol.md) | Promote autonomous-protocol.md from proposal to constitution (CHARTER ratification) | CHARTER | ACCEPTED | 2026-05-01 | q-and-a/pending/2026-05-01-001-S35-charter-promote-batch.md |
| [D-014](014-track-F-architecture.md) | Track F architecture — BC-8 Analysis 3-perspective thesis pipeline (Phase 2) | ARCH | ACCEPTED | 2026-05-01 | session-plans/pending/005-S31-phase-2-master-plan.md |
| [D-013](013-S35-meta-loop-recovery-promote-routing.md) | S35 META_LOOP_RECOVERY — Promote-rule routing outcomes (3 charter PENDING-USER-GATE; 4 hooks... | SCOPE-tier (3 charter promo... | ACCEPTED (charter subset ra... | 2026-05-01 | post-mortems/2026-05-01-self-awareness-promotion-skip.md |
| [D-012](012-track-A-source-pivot.md) | Track A — R2 closure via SSI iBoard direct (A3 strategy); TCBS public API permanently retired | IMPL | ACCEPTED | 2026-04-30 | session-plans/pending/005-S31-phase-2-master-plan.md |
| [D-011](011-phase-2-entry-tier1-tier2-vn30-rollout.md) | Phase 2 entry — Tier 1+2 VN30 rollout (mainstream news + fundamentals + working TCBS / DNSE ... | SCOPE (phase boundary; user... | ACCEPTED | 2026-04-30 | PROJECT_CHARTER.md |
| [D-010](010-VN-domain-constitution-proposals.md) | VN-domain constitution amendment proposals (Rules 12-15 + I-S55-I-S65 + personal-risk-profil... | CHARTER (target) ratified a... | ACCEPTED-as-PROPOSAL | 2026-04-30 | PROJECT_CHARTER.md |
| [D-009](009-VHM-thin-slice-exemplar.md) | VHM as Phase 1 thin-slice exemplar | SCOPE | ACCEPTED | 2026-04-30 | PROJECT_CHARTER.md |
| [D-008](008-track-9-self-awareness-reduced.md) | Track 9 — Self-Awareness Phase 0 REDUCED scope (state machine + templates + aggregator + dia... | IMPL | ACCEPTED | 2026-04-29 | decisions/002-phase-0-harness-bootstrap-design.md |
| [D-007](007-track-8b-memory-l0-l1-extraction.md) | Track 8b — Session Memory L0/L1 Extraction module (packages/observability/) | IMPL | ACCEPTED | 2026-04-29 | decisions/002-phase-0-harness-bootstrap-design.md |
| [D-006](006-track-8a-confidence-score-system.md) | Track 8a Confidence Score System — schema, storage substrate, weights, thresholds | IMPL | ACCEPTED | 2026-04-29 | decisions/002-phase-0-harness-bootstrap-design.md |
| [D-005](005-up08-track-5.5d-self-learning-pipeline.md) | UP-08 Track 5.5d Insertion — Self-Learning Pipeline as Write-Heavy Data-ETL Discipline | SCOPE | ACCEPTED | 2026-04-29 | human-workspace/user_prompt/20260429_08.txt |
| [D-004](004-up07-context-threshold-opus47.md) | Recalibrate session-context thresholds for Opus 4.7 (UP-07) | SCOPE | ACCEPTED | 2026-04-29 | human-workspace/user_prompt/20260429_07.txt |
| [D-003](003-up06-track-5.5-sync-layer-selfcap.md) | UP-06 Track 5.5 — Sync + Layer + Self-Capability Foundation | SCOPE | ACCEPTED | 2026-04-29 | human-workspace/user_prompt/20260429_06.txt |
| [D-002](002-phase-0-harness-bootstrap-design.md) | Phase 0 Harness Bootstrap Design (11 tracks + Track 5.5) | SCOPE | ACCEPTED-REV-3 | 2026-04-29 | human-workspace/user_prompt/20260429_01_init.txt |
| [D-001](001-orch-vs-cc-native.md) | Pause Orch, Port Patterns to StockForge | SCOPE | ACCEPTED | 2026-04-29 | human-workspace/user_prompt/20260429_01_init.txt |

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
