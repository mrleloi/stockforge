---
schema_version: 1
created_at: 2026-04-29
updated_at: 2026-05-05
last_check: 2026-05-05
description: |
  Single-source-of-truth audit of human-LLM mutual understanding ("sync state").
  Each item records ONE statement of intent + its current alignment state.

  Per D-003 § 5.5b.2: this file underpins the sync infrastructure ensemble.
  Read by `intent-vs-impl-diff` subagent at audit time; updated by hooks
  (Track 5.5b.3 sync-grilling) + manual entries + drift-log advisory blocks.

source_decision: agent-workspace/memory/decisions/003-up06-track-5.5-sync-layer-selfcap.md
source_intent: human-workspace/user_prompt/20260429_06.txt §1
related_files:
  - agent-workspace/memory/decisions/  (intent corpus — agent side)
  - human-workspace/user_prompt/        (intent corpus — human side)
  - human-workspace/q-and-a/answered/   (explicit picks)
  - agent-workspace/memory/drift-logs/intent-impl-*  (audit outputs)
---

# Sync State

> Living document. Each item = one statement about how this project should work,
> plus its current alignment state between human-stated intent and agent-adopted
> implementation.

## State Enum

| State | Meaning | Confidence |
|---|---|---|
| `confirmed-aligned` | Human explicitly verified via AskUserQuestion or written prompt; current artifact matches | ≥0.8 |
| `assumed-aligned` | Agent inferred from charter/UP/code; never explicitly re-verified by human | 0.5-0.8 |
| `open-question` | Queued for re-grill via `fire_when:` trigger; not yet answered (DH-1 clarification S8: every open-question MUST carry `fire_when:` field — phase, track, session, or condition) | n/a |
| `drift-detected` | `intent-vs-impl-diff` flagged divergence; awaiting remediation | n/a |
| `regression` | Was confirmed-aligned; subsequent audit found drift | n/a |

State transitions:

- `assumed-aligned` → `confirmed-aligned` via AskUserQuestion explicit pick
- `confirmed-aligned` → `regression` via drift audit
- `open-question` → `confirmed-aligned` | `drift-detected` via answered Q&A
- `drift-detected` → `confirmed-aligned` after remediation + re-audit

---

## Items

### Confirmed-Aligned (S1-S5)

```yaml
items:
  - id: sync-001
    statement: "Phase 0 = Harness Bootstrap; 11 original tracks + Track 5.5 inserted; supervised until Track 7 completes"
    state: confirmed-aligned
    confirmed_at: 2026-04-29T16:30:00+07:00
    confirmation_via: "AskUserQuestion D-003 Round 1+2 (8 explicit picks)"
    related_decisions: [D-002, D-003]
    related_intent: human-workspace/user_prompt/20260429_06.txt §1-3

  - id: sync-002
    statement: "Layer separation is LOGICAL via .claude/manifest.yaml tags, NOT PHYSICAL via subtree (REV-2 IMPL refinement)"
    state: confirmed-aligned
    confirmed_at: 2026-04-29T17:30:00+07:00
    confirmation_via: "AskUserQuestion bundle 005 (1 explicit pick = recommended option A)"
    related_decisions: [D-003 § REV-2]
    related_artifact: .claude/manifest.yaml

  - id: sync-003
    statement: "Sync drift detection is the #1 priority of the harness (UP-06 §1 binding directive)"
    state: confirmed-aligned
    confirmed_at: 2026-04-29
    confirmation_via: "Verbatim user prompt UP-06 §1 + adopted via D-003 chosen=A"
    related_decisions: [D-003]
    related_intent: human-workspace/user_prompt/20260429_06.txt §1

  - id: sync-004
    statement: "Multi-tenant explicitly SKIPPED for Phase 0-5; single-human assumption; peer-share via git-fork only"
    state: confirmed-aligned
    confirmed_at: 2026-04-29
    confirmation_via: "AskUserQuestion D-003 Round 2 Q6=D"
    related_decisions: [D-003 § Q6]
    related_intent: human-workspace/user_prompt/20260429_06.txt §2

  - id: sync-005
    statement: "Measurement stack = OTEL + JSONL hybrid (not JSONL-only, not OTEL-only)"
    state: confirmed-aligned
    confirmed_at: 2026-04-29
    confirmation_via: "AskUserQuestion D-003 Round 2 Q7=B"
    related_decisions: [D-003 § Q7, D-003 § 5.5c.4-5]

  - id: sync-006
    statement: "Phase 0 budget envelope ~1.5-2M tokens accepted for full Track 5.5 ambition"
    state: confirmed-aligned
    confirmed_at: 2026-04-29
    confirmation_via: "AskUserQuestion D-003 Round 2 Q8=A"
    related_decisions: [D-003 § Budget Delta]

  - id: sync-007
    statement: "AskUserQuestion is PRIMARY input surface for ALL Q&A bundles; file-based bundle = audit trail only; >4 questions → multi-batch chain"
    state: confirmed-aligned
    confirmed_at: 2026-04-29T14:05:00+07:00
    confirmation_via: "AskUserQuestion (charter-tier B1; UP-04 directive)"
    related_decisions: [D-002 § Track 4]
    related_artifact: .claude/skills/qa-escalation/SKILL.md § Channel Routing

  - id: sync-008
    statement: "NO Silent File-Defaults: every needed answer surfaced via AskUserQuestion; non-blocking-now → queue with fire_when trigger, not default-after-N-hours"
    state: confirmed-aligned
    confirmed_at: 2026-04-29
    confirmation_via: "Verbatim user correction UP-06 + amendment to UP-04 doctrine"
    related_decisions: [D-003 amendment notes]
    related_artifact: agent-workspace/memory/agent-notes.md "2026-04-29 (UP-06)"

  - id: sync-009
    statement: "Workspace dualism: agent-workspace/ = agent-owned execution+memory; human-workspace/ = human-authored authority; never blur"
    state: confirmed-aligned
    confirmed_at: 2026-04-29
    confirmation_via: "D-002 Track 1 + per-directory CLAUDE.md contracts"
    related_decisions: [D-002 § Track 1]
    related_intent: human-workspace/user_prompt/20260429_02_init.txt §1.1

  - id: sync-010
    statement: "drift-signals-D1-D8.sh: D1 (LOC ceiling) is the PRIMARY high-severity auto-trigger drift; >20% overrun is HIGH"
    state: confirmed-aligned
    confirmed_at: 2026-04-29T15:30:00+07:00
    confirmation_via: "Q-A2 closed via AskUserQuestion (S3 SessionStart)"
    related_artifact: scripts/hooks/drift-signals-D1-D8.sh

  - id: sync-011
    statement: "Charter-tier items NEVER ride mixed-tier default-acceptance bundles; dedicated CHARTER-only bundle with verbatim user phrase quoted"
    state: confirmed-aligned
    confirmed_at: 2026-04-29
    confirmation_via: "S2 audit G1 + agent-notes 'Charter-Tier Items Never Ride Default-Acceptance Bundles'"
    related_artifact: .claude/skills/grill-maximization/references/doctrine-detail.md § Charter-Tier Split Rule

  - id: sync-012
    statement: "Phase 0 setup grants temporal lift on AGENT_OPERATING_MANUAL.md + PROJECT_CHARTER.md deny-edit; restored after Track 7"
    state: confirmed-aligned
    confirmed_at: 2026-04-29
    confirmation_via: "User chat grant during S5-continuation"
    related_artifact: ~/.ccs/instances/.../memory/harness_bootstrap_permission_override.md
```

### Assumed-Aligned (charter-derived; never re-verified explicitly)

```yaml
items:
  - id: sync-013
    statement: "Stockforge identity = AI-first VN stock advisory; primary user = self + 3-5 trusted peers; NOT a SaaS"
    state: confirmed-aligned
    confirmed_at: 2026-04-30
    confirmation_via: "AskUserQuestion S23 sync-bundle Q1=A (Recommended) — 'Yes, identity unchanged'"
    transition_history:
      - state: assumed-aligned
        at: 2026-04-29
        basis: "PROJECT_CHARTER.md § Vision; never explicitly re-verified post-charter authorship"
      - state: confirmed-aligned
        at: 2026-04-30
        basis: "S23 sync-bundle re_verify_when=Phase 1 entry trigger fired"

  - id: sync-014
    statement: "Self-use first, commercial second; if conflict, self-use wins"
    state: assumed-aligned
    last_check: 2026-04-29
    assumption_basis: "PROJECT_CHARTER.md § Craft Philosophy"
    re_verify_when: "Phase 4 (post-dogfood data accumulation)"

  - id: sync-015
    statement: "9 bounded contexts for stock domain (market_data, fundamental, company_intelligence, macro, news, influence, crowd, analysis, portfolio)"
    state: confirmed-aligned
    confirmed_at: 2026-04-30
    confirmation_via: "AskUserQuestion S23 sync-bundle Q2=A (Recommended) — 'Yes, 9 BCs as-spec'"
    transition_history:
      - state: assumed-aligned
        at: 2026-04-29
        basis: "agent-workspace/constitution/architecture.md (planned); not yet exercised in Phase 1"
      - state: confirmed-aligned
        at: 2026-04-30
        basis: "S23 sync-bundle pre-skeleton ratification (re_verify_when=Phase 1 first BC implementation triggered)"

  - id: sync-016
    statement: "Calibration over confidence; every confidence claim must trace to historical hit rate from calibration database"
    state: confirmed-aligned
    confirmed_at: 2026-04-30
    confirmation_via: "AskUserQuestion S23 sync-bundle Q3=A (Recommended) — 'Yes, Track 8a substrate as-shipped correct'"
    transition_history:
      - state: assumed-aligned
        at: 2026-04-29
        basis: "PROJECT_CHARTER.md principle 8 + I-S20-equivalent invariant"
      - state: confirmed-aligned
        at: 2026-04-30
        basis: "S23 sync-bundle post-Track-8a-ship ratification (re_verify_when=Track 8a S17 D-006 shipped → triggered)"

  - id: sync-017
    statement: "Sandwich pattern (Architect → Dev → Verifier) is the default execution pattern from Day 1"
    state: confirmed-aligned
    confirmed_at: 2026-04-30
    confirmation_via: "AskUserQuestion S23 sync-bundle Q4=A (Recommended) — 'Yes, keep as-practiced'"
    transition_history:
      - state: assumed-aligned
        at: 2026-04-29
        basis: "PROJECT_CHARTER.md § Development approach; partially exercised through S5 but no fresh-context Verifier dispatched yet"
      - state: confirmed-aligned
        at: 2026-04-30
        basis: "S23 sync-bundle post-S21-verifier ratification (re_verify_when=Final verifier S21 shipped PASS-WITH-RESIDUE → triggered)"
```

### Open-Question (queued for re-grill — see `agent-workspace/memory/observations/queued-grill-master.md`)

```yaml
items:
  - id: sync-018
    statement: "Hard rule blocking default-acceptance for charter/SCOPE-tier; potential extension to DECISION_ROUTING-tier"
    state: open-question
    queued_at: 2026-04-29
    queue_ref: queued-grill-master.md § Q-B2
    fire_when: "S11 (Track 7) decision-discipline.md authoring"

  - id: sync-019
    statement: "Auto-context-loading mechanism for SessionStart: hook-based vs LLM-selector vs hybrid"
    state: open-question
    queued_at: 2026-04-29
    queue_ref: queued-grill-master.md § Q-C2
    fire_when: "S11 (Track 7) autonomous-protocol.md authoring"

  - id: sync-020
    statement: "SessionStart bootstrap token ceiling: 6K vs 10K vs 20K vs adaptive"
    state: open-question
    queued_at: 2026-04-29
    queue_ref: queued-grill-master.md § Q-C3
    fire_when: "S11 (Track 7) autonomous-protocol.md authoring"

  - id: sync-021
    statement: "Track 8a Confidence Score 'live consumption' success criteria amendment"
    state: open-question
    queued_at: 2026-04-29
    queue_ref: agent-workspace/memory/drift-logs/2026-04-29-S2-audit.md § B1
    fire_when: "S12 (Track 8a) Confidence Score System implementation"

  - id: sync-022
    statement: "Pre-amendment delta summary protocol for REV-N with ≥10 amendments OR ≥25% budget delta"
    state: open-question
    queued_at: 2026-04-29
    queue_ref: agent-workspace/memory/drift-logs/2026-04-29-S2-audit.md § G2
    fire_when: "S11 (Track 7) decision-discipline.md authoring"

  - id: sync-023
    statement: "Re-grill Q-S5 'small trusted circle = git-fork single-tenant' as charter-tier dedicated bundle"
    state: open-question
    queued_at: 2026-04-29
    queue_ref: agent-workspace/memory/drift-logs/2026-04-29-S2-audit.md § G1
    fire_when: "S11 (Track 7) when identity-scope.md promotes from proposals/ to constitution/"

  - id: sync-024
    statement: "Self-detect-drift mechanism: per-task DA-rule vs Stop-hook periodic vs fresh-context random"
    state: open-question
    queued_at: 2026-04-29
    queue_ref: queued-grill-master.md § Q-E1
    fire_when: "S11 (Track 7) self-application-bootstrap.md OR S14 (Track 9) self-awareness"

  - id: sync-025
    statement: "Skill-tool autonomous mode policy: avoid in autonomous OR SUPERVISED-only OR session-start batch"
    state: open-question
    queued_at: 2026-04-29
    queue_ref: queued-grill-master.md § Q-2.1
    fire_when: "S11 (Track 7) autonomous-protocol.md authoring"
```

### Confirmed-Aligned (S6 close additions)

```yaml
items:
  - id: sync-026
    statement: "Context-threshold band recalibrated for Opus 4.7: 180K wind / 220K cliff / 250K hard_cap (was 200K/230K/250K). Empirical re-evaluation after 10 sessions."
    state: confirmed-aligned
    confirmed_at: 2026-04-29
    confirmation_via: "AskUserQuestion 4-pick (Q1=A MID + Q2=A BASIC+correction-rate + Q3=A update-doc + Q4=A empirical N=10)"
    related_decisions: [D-004]
    related_intent: human-workspace/user_prompt/20260429_07.txt
    related_artifact: scripts/hooks/budget-watchdog.sh + CLAUDE.md line 85

  - id: sync-027
    statement: "Constitution session-budgets.md update queued for Track 7 (S11) per agent-workspace/CLAUDE.md immutability contract; D-004 documents intent to amend"
    state: confirmed-aligned
    confirmed_at: 2026-05-05
    confirmation_via: "AskUserQuestion S48d 4-Q bundle Q3=A — confirmed closure via D-020 (S43c bundle Q3 — Mode A/B/C/D + Verifier Budget by Scope)"
    queued_at: 2026-04-29
    queue_ref: D-004 § Constitution changes
    fire_when: "S11 (Track 7) constitution port — proposals/ flow"
    transition_history:
      - state: open-question
        at: 2026-04-29
        basis: "D-004 amend-intent; queued for Track 7"
      - state: confirmed-aligned
        at: 2026-05-05
        basis: "D-020 (S43c) shipped Mode A/B/C/D + Verifier Budget; S48d AskUserQuestion confirmed closure"
```

### Drift-Detected (S6 first audit baseline)

```yaml
items:
  - id: sync-028
    statement: "First intent-vs-impl-diff drift-log produced agent-workspace/memory/drift-logs/intent-impl-20260429T095024Z.md: 17 aligned / 5 drifted-soft / 3 drifted-hard / 0 regressions. Verdict MINOR-DRIFT."
    state: drift-detected
    detected_at: 2026-04-29T09:50:24Z
    detected_via: intent-vs-impl-diff subagent (Track 5.5b.1 first run)
    severity: minor
    next_action: "S7 pre-flight reads drift-log; remediates 3 drifted-hard items per drift-log Recommendations section"
```

### Regression

(none)

---

### S7-close additions (2026-04-29) — UP-07 follow-up + Track 5.5b.3+4

```yaml
items:
  - id: sync-029
    statement: "continue-injector.ps1 gated by autonomous_mode flag in current-execution.md; SUPERVISED mode skips spawn (verified hook log: SKIPPED continue-injector autonomous_mode=false)."
    state: confirmed-aligned
    confirmed_at: 2026-04-29
    confirmation_via: "smoke-test S7 — bash session-start-bootstrap.sh with autonomous_mode=false → log SKIPPED"
    related_artifact: scripts/hooks/session-start-bootstrap.sh lines 109-148
    related_intent: chat correction (S7 SessionStart) + mistake-log § M-S7-1 root-cause L2

  - id: sync-030
    statement: "stale-prompt-detector.sh wired as UserPromptSubmit hook; greps user prompt for UP-N/D-NNN/Track-N/SN refs; cross-checks up-intake-log.md + decisions/ + current-execution.md; emits warning if reference is CLOSED. 4 smoke tests passed."
    state: confirmed-aligned
    confirmed_at: 2026-04-29
    confirmation_via: "smoke-test S7 — UP-07 closed warning emitted; D-004 ACCEPTED warning emitted; clean S7-ref + trivial 'continue' → no warning"
    related_artifact: scripts/hooks/stale-prompt-detector.sh + agent-workspace/memory/up-intake-log.md
    related_intent: chat correction (S7) + mistake-log § M-S7-1 root-cause L3+L4

  - id: sync-031
    statement: "correction-rate-tracker.sh wired as UserPromptSubmit hook (D-004 § Tracking Instrumentation Q2=A commitment); Vietnamese + English correction patterns logged JSONL with bucket_50k. Smoke-test logged 2 entries with proper schema."
    state: confirmed-aligned
    confirmed_at: 2026-04-29
    confirmation_via: "smoke-test S7 — VI 'không phải, sai rồi' matched + EN 'wrong, stop' matched + .correction-rate.log JSONL valid"
    related_artifact: scripts/hooks/correction-rate-tracker.sh + agent-workspace/memory/.correction-rate.log
    related_decisions: [D-004]
    related_intent: D-004 § Tracking Instrumentation

  - id: sync-032
    statement: "sync-grilling-trigger.sh wired as SessionStart hook (Track 5.5b.3 = D-003 § 5.5b.3); thresholds 3 sessions / 7 days; non-blocking notification only (no auto-fire AskUserQuestion). Smoke-test: last_check=today → not-due correctly logged."
    state: confirmed-aligned
    confirmed_at: 2026-04-29
    confirmation_via: "smoke-test S7 — sessions=0/3 days=0/7 last_check=2026-04-29 → not due"
    related_artifact: scripts/hooks/sync-grilling-trigger.sh + .claude/skills/grill-maximization/references/sync-bundle-template.md

  - id: sync-033
    statement: "D-S7-1 RESOLVED: env-var override located in .claude/settings.json env block (STOCKFORGE_WIND_DOWN_TOKENS=200000 + STOCKFORGE_CLIFF_TOKENS=230000); updated to 180000/220000 per D-004 same session. Effective from next /clear or session start."
    state: confirmed-aligned
    detected_at: 2026-04-29T17:19+07:00
    fixed_at: 2026-04-29T17:30+07:00
    detected_via: S7 smoke-test of correction-rate-tracker.sh — watchdog log printed wind_down=200000
    fixed_via: ".claude/settings.json env block edit (S7 close, post-checkpoint write)"
    severity: medium-resolved
    verification: "Pending — verify after next session start that watchdog log shows wind_down=180000 cliff=220000"
    related_decisions: [D-004]
```

---

### S8 additions (2026-04-29) — DH-1/DH-2/DH-3 closures from S6 drift-log

```yaml
items:
  - id: sync-034
    statement: "DH-1 closure: open-question state requires `fire_when:` field (phase|track|session|condition). State enum table updated S8. Doctrine: queue with fire_when, never default-after-N-hours (UP-06 NO-Silent-Default). Track 5.5b.4 sync-bundle-template enforces this in composer."
    state: confirmed-aligned
    confirmed_at: 2026-04-29
    confirmation_via: "S8 schema clarification edit; closes DH-1 from drift-log intent-impl-20260429T095024Z"
    related_artifact: agent-workspace/memory/sync-state.md State Enum table
    related_intent: S6 drift-log § DH-1 + UP-06 §1 NO-Silent-Default doctrine

  - id: sync-035
    statement: "UP-06 §3 Karpathy autoresearch ensemble (decompose-work + capability-map + try-n-approaches + OTEL + JSONL ext + promote-rule) is committed for Track 5.5c (S8+S9). D-003 Round 1 Q4=C 'Aggressive Karpathy' explicit pick is the binding intent."
    state: confirmed-aligned
    confirmed_at: 2026-04-29
    confirmation_via: "AskUserQuestion D-003 Round 1 Q4=C (Aggressive Karpathy)"
    related_decisions: [D-003]
    related_intent: human-workspace/user_prompt/20260429_06.txt §3 + S6 drift-log § DH-2 closure

  - id: sync-036
    statement: "decompose-work skill + capability-map.md + promote-rule skill = S8 deliverables (5.5c.1+2+6); try-n-approaches + OTEL stack + JSONL extension = S9 deliverables (5.5c.3+4+5). Construction in progress; not all artifacts exist yet."
    state: confirmed-aligned
    confirmed_at: 2026-05-05
    confirmation_via: "AskUserQuestion S48d 4-Q bundle Q4=A — all 6 artifacts shipped per S9-S22 history (now visible in .claude/skills/ + agent-workspace/memory/)"
    last_check: 2026-04-29
    assumption_basis: "D-003 § 5.5c sub-track schedule + 002-track-5.5-sync-layer-selfcap.md § Sub-track Detail"
    re_verify_when: "S9 close (when 5.5c.3+4+5 ship)"
    related_decisions: [D-003]
    transition_history:
      - state: assumed-aligned
        at: 2026-04-29
        basis: "D-003 § 5.5c provisional"
      - state: confirmed-aligned
        at: 2026-05-05
        basis: "S48d AskUserQuestion confirmed all 6 artifacts shipped per S9-S22 ship history"

  - id: sync-037
    statement: "DH-3 closure: S2-drift bottleneck attributed to harness deterministic layer not-yet-wired (pre-S3 fortification gap). User UP-04 §1 verbatim diagnostic + bundle-002 § A1=B explicit pick = aligned attribution. Tracks 3-5 closed the gap via deterministic hooks port (drift-signals D1-D8, qa-pending-stale-mover, charter-coherence-spot, etc.)."
    state: confirmed-aligned
    confirmed_at: 2026-04-29T14:05:00+07:00
    confirmation_via: "AskUserQuestion bundle-002 § A1 (B pick) + S8 retroactive sync entry per drift-log Recommendation 5"
    related_decisions: [bundle-002]
    related_intent: human-workspace/user_prompt/20260429_04.txt §1 + S6 drift-log § DH-3

  - id: sync-038
    statement: "UP-08 RATIFIED via D-005 (S9 PLAN): Track 5.5d Self-Learning Pipeline = write-heavy data-ETL discipline parallel to 5.5a/b/c. NEW sub-track over 3 sub-sessions (5.5d.1 boundary+collection / 5.5d.2 sweeper+index+first-analysis / 5.5d.3 Karpathy+agent-pick-1+dogfood). Boundary: separate FS path agent-workspace/learning-data/ + drift signal D9. Background-tech: NDJSON queue + cron-via-hook (extends existing pattern). Opensource: agent-pick-1 + dogfood scope. Budget delta +~420K → Phase 0 total ~2.44M (user-accepted +22-23% over original 1.5-2M cap)."
    state: confirmed-aligned
    confirmed_at: 2026-04-29T18:10:00Z
    confirmation_via: "AskUserQuestion bundle-006 Round 1 + Round 2 — 5 explicit picks (Q1=A, Q2=A, Q3=A, Q4=C, Q5=A all Recommended)"
    related_decisions: [D-005, D-003 REV-3]
    related_intent: human-workspace/user_prompt/20260429_08.txt entire file
    user_directive_phrase: "keep full autonomous"
    transition_history:
      - state: open-question
        at: 2026-04-29 (S8 close intake)
      - state: confirmed-aligned
        at: 2026-04-29T18:10:00Z (S9 PLAN ratification)
```

---

## Update Protocol

**Manual entry**: append to relevant section above with new `id: sync-NNN` (next sequential).

**Via answered Q&A** (Track 5.5b.4 future): when bundle moved to `q-and-a/answered/`, hook scans for `sync-state-ref:` field in answered file and transitions matching item's state to `confirmed-aligned`.

**Via intent-vs-impl-diff agent** (S6 deliverable): drift-log's `## Sync-State Update Recommendations` section enumerates state transitions; main session applies after human review.

**Via sync-grilling-trigger** (5.5b.3 = S7): when N sessions or M days elapsed, hook signals "sync-grilling due"; main session fires AskUserQuestion sync-check; answers update items.

## Notes

- Item IDs are append-only; never reuse a sync-NNN.
- For corrections, use status field `superseded-by: sync-NNN` (not deletion).
- Counts (post-S9 D-005 ratification): 22 confirmed (sync-038 transitioned) + 6 assumed + 9 open-question + 1 drift-detected = 38 total entries.
- Counts (post-S23 Phase 1 entry sync-bundle): 26 confirmed (sync-013/015/016/017 transitioned) + 2 assumed (sync-014, 036) + 9 open-question + 1 drift-detected = 38 total entries.
- Counts (post-S24 entry Q-D1+Q-D2 closures): 28 confirmed (sync-039+040 added) + 2 assumed (sync-014, 036) + 9 open-question + 1 drift-detected = 40 total entries.
- Counts (post-S25 entry Q-S25-1 VHM closure): 29 confirmed (sync-041 added) + 2 assumed (sync-014, 036) + 9 open-question + 1 drift-detected = 41 total entries.
- Counts (post-S48d 4-Q bundle Q3+Q4 closures 2026-05-05): 31 confirmed (sync-027 + sync-036 transitioned) + 1 assumed (sync-014 only) + 8 open-question + 1 drift-detected = 41 total entries.

---

### S25 entry additions (2026-04-30) — Q-S25-1 VHM exemplar pick (master-plan substrate)

```yaml
items:
  - id: sync-041
    statement: "Phase 1 thin-slice exemplar stock = VHM (Vinhomes JSC — HOSE; VN30; vốn hóa ~150-180K tỷ VND); locked for sessions S25→S30 (BC-1 Bar + BC-9 Position+RiskRule + Tier 1 ingestion + 1 thesis exemplar). Swap-out only allowed on listing/data-coverage failure or Phase 2 PLAN entry."
    state: confirmed-aligned
    confirmed_at: 2026-04-30
    confirmation_via: "AskUserQuestion S25 entry Q-S25-1=VHM (Recommended) — SCOPE-tier user-gate"
    transition_history:
      - state: assumed-aligned
        at: 2026-04-30
        basis: "master-plan 004 § Thin-Slice Definition recommendation; provisional pending user gate"
      - state: confirmed-aligned
        at: 2026-04-30
        basis: "S25 entry user explicit pick"
    related_decisions: [D-009]
    related_intent: "agent-workspace/session-plans/pending/004-S24-phase-1-thin-slice-plan.md § S25 § Open questions § Q-S25-1"
    re_verify_when: "Phase 2 PLAN entry OR if VHM data coverage degrades / stock delists"
```

### S24 entry additions (2026-04-30) — Q-D1 + Q-D2 queued-grill closures

```yaml
items:
  - id: sync-039
    statement: "agent-workspace/memory/sessions/ flat-tree scales adequately for 5 phases × ~30 sessions; rely on YYYY-MM-DD-session-N.md naming + grep/glob; no migration to phase-N/ subfolders or YYYY-MM/ buckets needed at this scale."
    state: confirmed-aligned
    confirmed_at: 2026-04-30
    confirmation_via: "AskUserQuestion S24 entry Q2=C (Recommended) — 'Keep flat; rely on naming + grep'"
    transition_history:
      - state: queued
        at: 2026-04-29
        basis: "queued-grill-master.md § Q-D1 fire_when=Phase 1 entry"
      - state: confirmed-aligned
        at: 2026-04-30
        basis: "S24 entry AskUserQuestion bundle re-fire on Phase 1 entry trigger"
    related_intent: queued-grill-master.md § Q-D1
    re_verify_when: "When sessions/ count exceeds 200 OR grep performance becomes painful"

  - id: sync-040
    statement: "Obsidian raw/wiki Karpathy pattern proven scalable for 200+ entities; need disciplined index updates (spec-to-wiki skill enforces wikilink convention; periodic _index.md re-render); no KG migration nor tiered wiki/ split needed unless concrete pain emerges."
    state: confirmed-aligned
    confirmed_at: 2026-04-30
    confirmation_via: "AskUserQuestion S24 entry Q3=A (Recommended) — 'Yes, current pattern proven; just need disciplined index updates'"
    transition_history:
      - state: queued
        at: 2026-04-29
        basis: "queued-grill-master.md § Q-D2 fire_when=Phase 1 entry OR wiki/ count > 100 entities"
      - state: confirmed-aligned
        at: 2026-04-30
        basis: "S24 entry AskUserQuestion bundle re-fire on Phase 1 entry trigger"
    related_intent: queued-grill-master.md § Q-D2
    re_verify_when: "When wiki/ entity count exceeds 200 AND _index.md staleness > 1 week"
```
