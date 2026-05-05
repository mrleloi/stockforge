---
id: D-004-up07-context-threshold-opus47
title: "Recalibrate session-context thresholds for Opus 4.7 (UP-07)"
date: 2026-04-29
status: ACCEPTED
level: SCOPE
author:
  - "Claude Opus 4.7"
  - "user"

source_evidence:
  - path: human-workspace/user_prompt/20260429_07.txt
    quote: |
      "kiểm tra lại độ hiệu quả của 'reboot session ở 250k context session', thực ra con số này
      là lấy từ learning lession của 'phase2' trong 'mdp refactor project', lúc đó sử dụng claude
      cách đây khá lâu."
      "main session claude code chạy opus 4.7, có thể là /effort medium hoặc /effort high, nên
      tôi cho rằng context size 'phù hợp' có thể đã nhiều hơn."
      "điều này có thể làm thay đổi đáng kể chất lượng dự án và budget khi chạy ở chế độ full
      autonomous với nhiều session automation liên tục, đây là một quyết định quan trọng."
  - path: agent-workspace/constitution/session-budgets.md
    section: "## The Quality Cliff (line 1-19) — claims 'Quality cliff at 250K tokens is real. Measured data from 51+ real agent sessions.'"
  - path: scripts/hooks/budget-watchdog.sh
    section: "lines 16-17 — operational defaults WIND_DOWN=200000, CLIFF=230000 (drift vs constitution claim of 250K)"
  - path: claude-code-guide subagent research output (this session)
    section: "Empirical thresholds for Opus 4.7: auto-compact 160-180K; reliable 200-256K; degradation 250K+; cache TTL recently regressed 1h → 5min"

intent_classification:
  primary_intent: SCOPE
  affects_charter: false
  affects_scope: true
  urgency: NORMAL
  complexity_score: 70

options_considered:
  - id: A
    summary: "MID research-recommended band: 180K wind / 220K cliff / 250K hard_cap"
    pros:
      - "Aligns with research empirical data for Opus 4.7 (auto-compact at 160-180K; quality degradation at 250K+)"
      - "Reduces false-positive `/clear` calls vs current 200K wind by deferring action until 180K WIND prep"
      - "Actually slightly TIGHTER than current operational on cliff (230→220) — preempts auto-compact messiness"
      - "Sweet-spot per community + Anthropic API docs research"
    cons:
      - "Lowering cliff 230→220 means earlier reboot — feels like regression"
      - "Auto-compact 160-180K still happens BEFORE wind-down (180K wind) — auto-compact may fire silently before user-visible signal"
  - id: B
    summary: "STATUS-QUO operational: keep 200K/230K/250K"
    pros:
      - "No code/hook change required"
      - "Research validates 200-250K as 'reliable zone'"
    cons:
      - "Constitution drift unfixed (CLAUDE.md says 250K MANDATORY SPLIT but hooks fire at 230K cliff already)"
      - "Misses opportunity to integrate Opus 4.7-specific data"
  - id: C
    summary: "LOOSE per user intuition: 220K/250K/280K"
    pros:
      - "Aligns with user UP-07 hypothesis about Opus 4.7 capacity"
      - "Reduces handoff overhead — fewer reboots"
    cons:
      - "Research explicitly REJECTS this — quality degradation documented at 250K+"
      - "Bets against published Anthropic auto-compact behavior (kicks at 80-90% = 160-180K of 200K window)"
      - "Cache TTL regression (1h → 5min) makes cache-miss penalty worse — holding longer context riskier"
  - id: D
    summary: "ADAPTIVE per session-type: PLAN tighter, IMPL looser"
    pros:
      - "Most surgical — matches threshold to task complexity"
    cons:
      - "Hooks need session-type detection (currently no robust signal)"
      - "Maintenance overhead — 5+ profile triplets to keep tuned"
      - "Premature optimization — no empirical data yet to set per-type values"

chosen: A
chosen_rationale: |
  User picked Option A (MID research-recommended) via AskUserQuestion explicit pick (UP-07
  intake, this session). Research data from claude-code-guide subagent (10 sources cited,
  including Anthropic API docs + community benchmarks) confirms 220K cliff is the empirical
  sweet-spot for Opus 4.7. The 250K rule from older mdp-refactor phase 2 measurements
  pre-dates Opus 4.6/4.7 architectural changes (auto-compact behavior, cache TTL).

  Specifically rejects user's prior intuition (Option C) that "context size phù hợp có thể đã
  nhiều hơn" — research data shows quality degradation BEGINS earlier with Opus 4.7, not later.
  This is a valuable correction surfaced via the very sync infrastructure (D-003 § 5.5b.1)
  that S6 just shipped — first non-trivial drift caught by the new audit pattern.

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-04-29
    via: "UP-07 intake → claude-code-guide background research (10 sources) → 4-question AskUserQuestion bundle"
  - actor: user
    action: ACCEPTED
    at: 2026-04-29
    via: "AskUserQuestion explicit pick — Q1=A (MID), Q2=A (BASIC+correction-rate), Q3=A (update doc to match), Q4=A (empirical N=10)"

verified_by:
  - mechanism: askuserquestion-explicit-pick
    at: 2026-04-29
    result: PASS
    notes: "4 explicit picks; no defaults absorbed. UP-06 NO-Silent-Default rule respected."

affects:
  charter: false
  spec_files: []
  code_paths:
    - "scripts/hooks/budget-watchdog.sh"           # MODIFIED: defaults 200K→180K wind, 230K→220K cliff
    - "scripts/hooks/autonomous-stop-watchdog.sh"  # MODIFIED: WIND_DOWN_THR default 200K→180K
    - "scripts/hooks/correction-rate-tracker.sh"   # NEW (S7 deliverable per Q2=A scope)
  config_files:
    - "CLAUDE.md"                                  # MODIFIED: 250K rule → explicit 3-tier band
    - "agent-workspace/constitution/session-budgets.md" # PROPOSAL queued for Track 7 (S11) per constitution write protocol
  other_decisions:
    - D-002                                        # AMENDED implicitly — Track 5 hooks ported with 200K/230K defaults from orch; now 180K/220K
    - D-003                                        # NOT AMENDED — Track 5.5 unaffected by threshold change

depends_on:
  - D-003                                          # Sync infrastructure that surfaced this drift via S6 first run

supersedes: null
superseded_by: null

defer_cycles: 0
re_attempt_prereq: "N/A — applied this session."

tags: ["phase-0", "operational", "context-threshold", "opus-4.7", "up-07", "constitution-drift-fix"]
---

# Decision 004 — Recalibrate Session-Context Thresholds for Opus 4.7

> **Status**: ACCEPTED 2026-04-29 via 4-question AskUserQuestion explicit picks.
> **Source**: UP-07 (`human-workspace/user_prompt/20260429_07.txt`).

---

## Summary

| Variable | Old | New | Source |
|---|---|---|---|
| `WIND_DOWN_TOKENS` | 200,000 | **180,000** | `budget-watchdog.sh` env default |
| `CLIFF_TOKENS` | 230,000 | **220,000** | `budget-watchdog.sh` env default |
| `HARD_CAP` (doc) | 250,000 | **250,000** (unchanged; explicit 3-tier band) | `CLAUDE.md` hard rule |

**Plus**: add `correction-rate` tracking to telemetry (S7 deliverable per Q2=A).
**Plus**: re-evaluate empirically after 10 sessions of new-band data (Q4=A).

---

## Context

### Drift discovered

UP-07 questioned whether the 250K reboot threshold inherited from "mdp refactor phase 2" (older Claude project) still fits Opus 4.7. Investigation revealed:

1. **Internal drift**: `CLAUDE.md` and `agent-workspace/constitution/session-budgets.md` claim "250K MANDATORY SPLIT" but `scripts/hooks/budget-watchdog.sh` operational defaults are 200K wind / 230K cliff. The constitution lagged operational reality.

2. **External drift**: `claude-code-guide` background research surfaced two material Opus 4.7 specifics:
   - **Auto-compact** activates at 80-90% utilization = **160-180K** (within Opus 4.7's 200K headline window). Higher band thresholds risk silent auto-compact firing before user-visible signal.
   - **Cache TTL regressed 1h → 5min** (recent Anthropic change documented in The Register / XDA articles). Cost arithmetic for holding long context is now worse than when 250K rule was set.

3. **Quality data for Opus 4.7**: Research cites quality regression BEGINNING at 250K+ (sharp degradation), not loosening as user UP-07 hypothesized. Opus 4.7 launch-week regression (issue #34685 / #53459) further argues for tighter, not looser, threshold.

### What stays unchanged

- **Hard cap remains 250K** — preserves "MANDATORY SPLIT" semantic from session-budgets.md but now explicitly DOCUMENTED as the upper failsafe (not the operational trigger).
- **51+ session data backing the 250K claim** is not invalidated — it shows quality cliff exists; it does not pin the cliff to exactly 250K for current models. New empirical data (Q4=A re-evaluation) will refine.

---

## Decision

**Adopt Option A: MID research-recommended band.**

### Three-tier explicit band (replaces single "250K MANDATORY SPLIT")

```
< 180K       NORMAL — proceed without budget concern
180-220K     WIND_DOWN  — auto-prep handoff state; defer non-critical loads; finalize current task
220-250K     CLIFF      — auto-reboot fires (session-self-reboot.sh); MANDATORY handoff
> 250K       HARD_CAP   — emergency split; should never happen if cliff fires correctly
```

### Operational changes (S6, this session)

1. `scripts/hooks/budget-watchdog.sh` defaults: `WIND_DOWN=180000`, `CLIFF=220000`
2. `scripts/hooks/autonomous-stop-watchdog.sh` `WIND_DOWN_THR` default: 180000
3. `CLAUDE.md` hard rule replaced: "250K projected → MANDATORY SPLIT" → "180K wind / 220K cliff / 250K hard_cap (operational thresholds in budget-watchdog.sh)"

### Constitution changes (Track 7 queued)

- `agent-workspace/constitution/session-budgets.md` — proposal for Track 7 (S11) to update:
  - Quality Cliff section: keep "cliff exists" claim; replace fixed-250K language with 3-tier band
  - Each session-type budget (PLAN/FOCUSED_IMPL/etc.) reviewed against new band
  - "If estimated > 250K → SPLIT required" → "If estimated > 220K → SPLIT required (cliff threshold)"

Constitution edit defers to Track 7 per `agent-workspace/CLAUDE.md` Contract Rule 1 ("immutable absent explicit human approval"). User Q3=A pick approves the change but constitution authoring channel is Track 7's `proposals/` flow.

### Tracking instrumentation (Q2=A; S7 scope)

NEW hook: `scripts/hooks/correction-rate-tracker.sh` (UserPromptSubmit hook)

Detects user-correction patterns in submitted prompt:
- Vietnamese: "không phải", "sai rồi", "stop", "không đúng", "ngừng"
- English: "no", "wrong", "incorrect", "stop", "don't"

Logs to `agent-workspace/memory/.correction-rate.log` JSONL with:
- `ts`, `tokens_at_correction` (from .transcript-tokens), `prompt_hash`, `pattern_matched`, `bucket_50k`

Aggregator at session-end (Stop hook): summarize correction count per 50K bucket. Feeds Q4=A empirical re-evaluation after 10 sessions.

**Scope**: hook scaffold + JSONL schema in S7 (Track 5.5b.3). Aggregator dashboard + re-evaluation criteria definition deferred to S9 (Track 5.5c metrics).

### Re-evaluation criteria (Q4=A)

Empirical re-evaluation triggered when:
- 10+ sessions completed under new threshold band, OR
- Correction-rate per 50K-bucket exceeds 3× baseline observed in S1-S5 sessions, OR
- External event: Anthropic publishes Opus 4.8+ or cache TTL changes

When triggered: dispatch fresh-context drift-detector + intent-vs-impl-diff subagents on accumulated telemetry; propose new band via AskUserQuestion.

---

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| 220K cliff fires too aggressively → frequent reboots → handoff overhead spike | Medium | Watch correction-rate trend; if reboots add >15% wall-clock without quality benefit, escalate via re-evaluation criterion 2 (3× baseline correction rate) |
| Auto-compact firing at 160-180K silently before wind-down (180K) | Medium | Wind-down at 180K = upper edge of auto-compact band; signals "approaching auto-compact, prep handoff". User should consider /compact OR /clear at this point. Document in CLAUDE.md. |
| Constitution drift NOT actually fixed because session-budgets.md update is queued for Track 7 | High | Document the queue explicitly in D-004 + sync-state.md (sync-026 below). Make S11 (Track 7) pre-flight read this decision. |
| User regrets tighter band — wants Option C loose (research-rejected) | Low | Q4=A empirical re-evaluation provides defined revision path. Until then, hold band per data. |
| New `correction-rate-tracker.sh` hook misses Vietnamese-specific correction idioms | Medium | Initial pattern list reviewed at S7 ship; agent-notes appendable for new patterns; promotion-rule skill (Track 5.5c) eventually catches |

---

## What S7 inherits from this decision

S7 plan (`002-track-5.5-sync-layer-selfcap.md § 5.5b.3 + 5.5b.4`) needs amendment:
- Add `correction-rate-tracker.sh` to S7 deliverables (small ~80 LOC)
- Reference D-004 in pre-flight reads
- Sync-state.md sync-026 (added this session) is a starting point for next sync grilling round

---

## Acceptance Record

- **2026-04-29**: PROPOSED by Claude Opus 4.7 (UP-07 intake + research)
- **2026-04-29**: ACCEPTED by user via 4-question AskUserQuestion (Q1-Q4 all = A recommended option)

Status transitioned PROPOSED → ACCEPTED in same session via AskUserQuestion explicit picks (no defaults absorbed; UP-06 NO-Silent-Default rule respected).
