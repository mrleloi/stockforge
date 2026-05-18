# Reference — ADRs Inventory

> **Audited**: 2026-05-19
> **Source**: `agent-workspace/memory/decisions/NNN-*.md` (90+ files)
> **Maintainer**: Run `/harness-docs sync decisions` to regenerate

ADRs are sequential, never reused. 12+ field YAML frontmatter. Append-only; supersession via `status: SUPERSEDED-BY-D-NNN`.

See [Chapter 4 § 4.4](../en/04-constitution.md#44--decision-discipline-adrs) and [Chapter 7 § 7.7](../en/07-memory-system.md#77--architecture-decision-records-decisions).

---

## ADR Schema (Frontmatter)

```yaml
---
id: D-NNN
title: <short title>
date: YYYY-MM-DD
status: PROPOSED | ACCEPTED | SHIPPED | SUPERSEDED-BY-D-NNN | REJECTED
level: CHARTER | SCOPE | ARCH | IMPL
author: <agent | human>
source_evidence:
  - <file:line citations>
intent_classification: CHARTER_AMEND | SCOPE_CHANGE | ARCH_DECISION | IMPL_PICK
options_considered:
  - id: A
    description: <description>
    pros: [...]
    cons: [...]
  - id: B
    ...
chosen: A | B | C | ...
chosen_rationale: <why>
approval_chain: <list of confidence sources>
verified_by: <empirical test / smoke / firing-test / human ratification>
affects: [<files / BCs / artifacts>]
depends_on: [D-NNN, D-MMM]
supersedes: [D-NNN]  # optional
superseded_by: [D-NNN]  # optional, when retired
defer_cycles: 0
re_attempt_prereq: <if rejected>
tags: [<keywords>]
---
```

---

## Most-Referenced ADRs (Selected)

These are the most-cited ADRs across the harness; full list in `agent-workspace/memory/decisions/`.

| ADR | Date | Title | Status |
|---|---|---|---|
| D-001 | 2026-04 | Initial harness bootstrap | ACCEPTED |
| D-002 | 2026-04 | Workspace dualism (agent + human) | ACCEPTED |
| D-003 | 2026-04 | dispatch.jsonl v2 schema (failure_mode 8-code expansion) | ACCEPTED |
| D-004 | 2026-04 | Budget thresholds + correction rate instrumentation | ACCEPTED |
| D-005 | 2026-04 | Runtime-path-leak prevention (write-only learning-data tree) | ACCEPTED |
| D-006 | 2026-04 | Track 8a Confidence Score (bash+TSV substrate) | ACCEPTED |
| D-009 | 2026-04-30 | VHM as Phase 1 thin-slice exemplar | ACCEPTED |
| D-010 | 2026-04-30 | VN-domain constitution amendment proposals (Rules 12-15) | ACCEPTED |
| D-011 | 2026-04-30 | Phase 2 entry: Tier 1+2 VN30 rollout | ACCEPTED |
| D-023 | 2026-05 | dispatch.jsonl v2 schema + HH-B.1/B.2 telemetry | ACCEPTED |
| D-027 | 2026-05 | BC-6 Influence Network architecture | ACCEPTED |
| D-029 | 2026-05-05 | Drift-signals reconciliation (Tiered Coverage Map) | ACCEPTED |
| D-030 | 2026-05-05 | autonomous-protocol.md Rule 10 (Mode-E defection forbidden) | ACCEPTED |
| D-031 | 2026-05-05 | HH-E.2 auto-mv 4-condition rule | ACCEPTED |
| D-032 | 2026-05-06 | BC-7 Crowd Sentiment + Pump Detection architecture | ACCEPTED |
| D-033 | 2026-05-07 | T5 Harness Health Protocol (12-signal catalog) | ACCEPTED + MV-COMPLETE |
| D-034 | 2026-05-07 | T8 Charter Revision v1.1 PROPOSAL | SUPERSEDED-BY-D-056 |
| D-035 | 2026-05-07 | T6 harness-health-self-scan.sh hook | ACCEPTED |
| D-036 | 2026-05-07 | HH-G portability close | ACCEPTED |
| D-037 | 2026-05-07 | M-S171-1 prevention hooks | ACCEPTED |
| D-040 | 2026-05-07 | Boot-summary renderer trim + file-pattern-hook-pre-flight-lint | ACCEPTED |
| D-041 | 2026-05-07 | HH-6 dispatch-pending sidecar sweep + 6 firing-tests | ACCEPTED |
| D-042 | 2026-05-07 | continue-injector spawn extraction (Windows fix) | ACCEPTED |
| D-043 | 2026-05-07 | S186 UserPromptSubmit chain truncation fix | ACCEPTED |
| D-044 | 2026-05-07 | S188 chain-stop discrimination H-c fix | SHIPPED-REJECTED |
| D-045 | 2026-05-08 | HH-H.1 stale-checkpoint guard relaxation (300s→1800s) | ACCEPTED |
| D-048 | 2026-05-11 | T5 mv-to-constitution one-time deny-lift | ACCEPTED |
| D-052 | 2026-05-12 | Ghost-greening cluster RCA + adr-empirical-close-verify-spot-check | ACCEPTED |
| D-053 | 2026-05-12 | E4 Fresh-Context Verifier ARCH+CHARTER tier proposal | DEFERRED |
| D-056 | 2026-05-12 | Charter v1.1 Principle 11 ratification | ACCEPTED |
| D-058 | 2026-05-14 | Severity / escalation / block / Telegram system | ACCEPTED |
| D-059 | 2026-05-14 | Python determinism contract (R1-R4 banned patterns) | PROPOSED |
| D-060 | 2026-05-15 | Agents MAY commit; agents MUST NOT push | ACCEPTED |
| D-061 | 2026-05-15 | Q-INT mega-bundle ratification | ACCEPTED |
| D-062 | 2026-05-15 | TradingAgents atomic temp-file-replace doctrine (W0-3) | PROPOSED + REMEDIATED-S334 |
| D-063 | 2026-05-15 | TradingAgents HTML-comment separator doctrine (W0-4) | PROPOSED + REMEDIATED-S334 |
| D-064 | 2026-05-15 | Vibe-Trading path-safety 5-invariant (W0-5) | PROPOSED + VERIFIED-S333 |
| D-065 | 2026-05-16 | Theme G I-S1-1 Numeric-Field Discipline | ACCEPTED |
| D-066 | 2026-05-16 | BC-5 Crawler Adapter Contract (Phase D Theme L) | PROPOSED |
| D-067 | 2026-05-16 | (SKIPPED — inline trap doesn't warrant new ADR) | — |
| D-068 | 2026-05-16 | Pending-queue-escalator (PENDING-tier severity) | ACCEPTED |
| D-079..D-082 | 2026-05-17 | (Wave 1 ADRs ≥12-field floor compliance) | ACCEPTED |
| D-081 | 2026-05-17 | BR-6 cap-recalibration (4-ticker thesis re-run) | ACCEPTED |
| D-082 | 2026-05-17 | Claude vision PDF adapter + EchoValidator (G.3) | ACCEPTED |
| D-083 | 2026-05-19 | BC-2 PDF→Fundamental shape contract (G.4) | PROPOSED |

---

## Notes

- This is a curated selection. Full inventory grows continuously.
- **D-067 was skipped** intentionally (inline trap didn't warrant a new ADR; sequential numbering preserved as a placeholder).
- **D-053 deferred** — re-attempt prereq: post-Phase 4 wave 1 completion.
- **D-044 rejected** at production verification — example of empirical-test discipline.

---

## Sequential Numbering Rules

- Numbers are never reused. If an ADR is found to be a duplicate of an earlier one, mark `status: SUPERSEDED-BY-D-NNN`.
- Hook `pre-dispatch-adr-number-check.sh` (PreToolUse) prevents collision when subagents author ADRs in parallel.
- Defer-cycles > 3 raises drift alert (R7 mitigation).

---

## Confidence Threshold Path (Per Tier)

| Tier | Threshold | Decision path | Cool-down |
|---|---|---|---|
| CHARTER | 0.99 | Always AskUserQuestion + human ratify | 48h |
| SCOPE | 0.90 | AskUserQuestion if <0.90 | 24h |
| ARCH | 0.80 | Self-decide if ≥0.80 | 12h |
| IMPL | 0.50 | Self-decide if ≥0.50 | 0h |

---

## See Also

- [Chapter 4 § Decision Discipline](../en/04-constitution.md#44--decision-discipline-adrs)
- [Chapter 7 § ADRs](../en/07-memory-system.md#77--architecture-decision-records-decisions)
- [Chapter 11 § Recipe 11 — Run an ADR Through the Lifecycle](../en/11-cookbook.md#recipe-11--run-an-adr-through-the-lifecycle)
- [Full ADRs at `agent-workspace/memory/decisions/`](../../../agent-workspace/memory/decisions/)
