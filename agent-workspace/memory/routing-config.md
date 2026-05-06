---
config_id: routing-config-2026-05-06
ratifying_session: S65
status: ACTIVE
supersedes: prior-implicit-config (no formal artifact)
last_updated: 2026-05-06 (S65)
---

# Model × Effort × Thinking Routing Config

> Single source of truth cho subagent model selection + main-session effort doctrine.
> Ratified S65 sau user feedback "opus max full quá tốn budget" + correction "main session nên Opus medium vì edge case lớn".

## 1. Main session

| Field | Value | Justification |
|---|---|---|
| Model | **Opus 4.7** | Edge case + workflow novelty hit main FIRST; bad routing decision cascades 200-500K subagent burn |
| Effort default | **medium** | Baseline cho mechanical orchestration (read → decide → dispatch → write memory) |
| Effort escalate `high` | Triggers below | Spec ambiguity / 2+ alts non-obvious / debug stuck >2 attempt / cross-BC interaction |
| Effort escalate `xhigh` | Triggers below | Novel pattern (no mirror precedent) / cross-system reasoning / charter-tier touch |
| Effort escalate `max` | Triggers below | Multi-perspective adversarial > 3 viewpoints / theorem-like proof / hard-bug recurrence ≥3 |
| Effort de-escalate `low` | Triggers below | File ops / mtime check / mechanical mv-rename / pure read-and-cite |

## 2. Subagent matrix

| Subagent | Model (frontmatter) | Effort default | Escalate `xhigh/max` |
|---|---|---|---|
| `sandwich-architect` | **opus** | high | xhigh khi novel architecture; max khi cross-BC contract |
| `master-planner` | **opus** | high | xhigh phase boundaries; max charter-tier scope |
| `sandwich-verifier` | **opus** | high | max ở phase-close VERIFY (last gate) |
| `devils-advocate` | **opus** | high | xhigh khi multi-perspective ≥4 viewpoints |
| `intent-vs-impl-diff` | **opus** | medium | high khi cross-charter-tier audit |
| `spec-author` | **opus** | high | xhigh khi novel domain |
| `lesson-synthesizer` | **opus** *(upgrade S65)* | high | xhigh khi cross-domain pattern cluster ≥5 |
| `drift-detector` | **opus** *(upgrade S65)* | medium | high khi semantic inspection DR7/DR12 |
| `sandwich-dev` | **sonnet** | **high** *(S66 revert from medium per A/B FAIL)* | max khi cross-BC contract / boundary-discipline-critical IMPL |
| `action-guide-planner` | sonnet | medium | — |
| `bdd-planner` | sonnet | medium | high khi pyramid rebalance |
| `ul-auditor` | sonnet | medium | — |
| `research-scanner` | sonnet | medium | — |
| `intent-classifier` | **haiku** *(downgrade S65)* | low | medium khi prompt ambiguous Vietnamese |
| `general-purpose` / `Explore` | haiku/sonnet (per call) | medium | — |

## 3. In-product LLM substrate (RUNTIME, không phải CC harness)

| Use case | Model | Pattern source |
|---|---|---|
| Sentiment classifier (BR-4 categorical) | Haiku 4.5 | per BP-S43b-1 per-role override |
| KOL recommendation extractor | Sonnet 4.6 | D-027 D-026 substrate |
| Counter-narrative bear-points | Sonnet 4.6 | D-032 (g) |
| Pump evidence summary text | Sonnet 4.6 | D-032 (d) |
| Haiku-prefilter + Sonnet-extract pipeline | Haiku → Sonnet | S47 Track-H probe winner |

## 4. Effort auto-escalation hook (proposed; deferred codification)

Pre-action signal detection → emit `effort_recommendation: <level>` in stderr; main session reads + acts.

Pattern (defer to next promote-rule cycle if ≥3 escalation events observed):
```bash
# scripts/hooks/effort-escalation-detector.sh (proposed)
# Triggers (any-of):
# - prompt regex match: "ambiguous|unclear|novel|first time|debugging|stuck|charter"
# - 2+ alternatives mentioned in current turn
# - cross-BC import detected
# - any in-flight M-S<N>-<M> recurrence (HR-1 lesson watchdog)
```

## 5. A/B test plan (BEFORE locking permanently)

| Test | Sample window | Pass criterion | Result |
|---|---|---|---|
| `sandwich-dev` Sonnet medium for S52 (Track J 30+ tests) | S52 1 dispatch | test-PASS rate ≥ S46+S47 baseline (100%); 0 regression in suite | **❌ FAILED at S66** — 8 FAIL in S53 territory + scope-creep S52→S53 + false-attestation observation. M-S66-1 cataloged. **Revert to Sonnet max for sandwich-dev** (S46+S47 baseline). Sonnet medium retained for action-guide-planner / bdd-planner / ul-auditor / research-scanner only. |
| `lesson-synthesizer` Opus high vs prior Sonnet | Next 3 dispatches | New entries reach charter-promotion-eligible threshold (currently ~60% per HR-1) | TBD |
| `drift-detector` Opus medium vs prior Sonnet | Next 3 dispatches | Catches ≥1 NEW signal current Sonnet misses (semantic DR7/DR12) | TBD |
| `intent-classifier` Haiku low vs prior Sonnet | Next 10 dispatches | Classification accuracy ≥95% on Vietnamese prompts (manual sample-3% audit) | TBD |

## 6. Profile-card rebuild plan

- Mark all 6 existing profile cards `status: BIASED-PRE-REBUILD` (S48k tracking gap admission)
- Telemetry hook `component-telemetry.sh` audit + fix gaps
- Rebuild profile cards with **honest provenance** post-S52 (10+ samples per cell minimum) — not 100% hit-rate claims with N=2

## 7. Provenance

- User pick S65 turn (chat 2026-05-06): main = Opus medium; effort full ladder; harness parallel; meta-cognitive limit acknowledgment
- Anthropic published pricing (input/output per MTok)
- Community pattern: Sonnet primary for code-gen, Opus for reasoning/safety-net
- Profile cards retired status (BIASED-PRE-REBUILD) — historical artifact only

## 8. Update lifecycle

- After S52 + S53 + S55 sandwich-dev cycles: re-eval Sonnet medium decision
- After 3 lesson-synthesizer dispatches: re-eval Opus high decision
- After 1 phase boundary completion: A/B test results consolidate → permanent lock OR adjust
- This file = ACTIVE single source of truth; updates supersede via `last_updated:` field bump

## 9. Harness burst status (S65)

**harness_burst_complete: 2026-05-06 (S65)** — Plan 010 D1-D7 all shipped:

| Deliverable | Status | Firing-test |
|---|---|---|
| D1 pre-dispatch-adr-number-check | ✅ | 8/8 PASS |
| D2 cost-ledger-recorder | ✅ | 8/8 PASS |
| D3 bootstrap-summary-renderer | ✅ | 10/10 PASS |
| D4 effort-escalation-detector | ✅ | 12/12 PASS |
| D5 scheduled-drift-detector-trigger | ✅ | 6/6 PASS |
| D6 memory-etl-processor + queue | ✅ | 8/8 PASS |
| D7 profile cards mark BIASED-PRE-REBUILD-S65 | ✅ | N/A |

Cumulative: 52/52 firing-tests PASS. BC-6 regression 150/150 PASS UNCHANGED. bash-hook-lint clean.

**Hooks registered in `.claude/settings.json`**:
- PreToolUse: D1 + D4
- UserPromptSubmit: D4
- Stop: D2 + D3 + D5 + D6
- SubagentStop: D2

**Memory rule codified**: `harness_priority_one.md` (user feedback memory — harness upgrade > product work).

**Next harness work**: Profile-card rebuild triggered when cost-ledger.tsv accumulates ≥10 sessions per session-type cell (estimated ~1-2 phases out).
