---
plan_id: 009-S48-harness-hardening-middle-phase
created: 2026-05-05
created_via: main-session opus47-max (S48 out-of-band post-audit)
phase: 2.5 — Harness Hardening (NEW; insert between Phase 2 close S43e/S43f and Phase 3 IMPL resume at S49)
predecessor: Phase 2 COMPLETE (S31-S43e); Phase 3 entry (S44 master-plan + S45 sub-plan + S46 Track G + S47 Track H DONE)
successor: Phase 3 Track I (S49 NEXT — Bayesian calibration; resumed after Phase 2.5 close)
estimated_sessions: 8 sessions (~28-40h work)
estimated_envelope: ~600K-1M main + ~150-300K subagent (no IMPL, mostly small focused fixes)
trigger: |
  User explicit request 2026-05-05 after auto-/clear+continue happened post-audit-response
  WITHOUT updated checkpoint/handoff. Quote: "harness vừa tự động /clear và continue sau câu
  trả lời của bạn ở trên, mà không có bất kì tracking/handoff nào... tạo thêm một middle phase
  để fix harness đi". Companion docs: `observations/2026-05-05-harness-alignment-audit.md` +
  `observations/2026-05-05-root-cause-3-axes.md` (audit + root cause analysis).
binding_charter_clauses: |
  - Charter Principle 8 (Calibration over confidence) — telemetry repair restores measurability.
  - autonomous-protocol.md (D-015 CHARTER) — Mode-E self-pause defection charter promotion.
  - decision-discipline.md Rule 4b (D-026) — lesson-synthesis mandatory; project.md ritual extension.
  - memory-tiers.md (D-017 CHARTER) — tier1-bloat-check.sh companion hook wiring.
status: PENDING — autonomous_mode currently OFF; user gate before re-enabling autonomous flag.
---

# Phase 2.5 — Harness Hardening (Middle Phase between Phase 2 and Phase 3 Track I)

## Why this phase exists

Audit findings (2026-05-05):
- **Alignment ~70%** với 10 nhóm goal human đã expressed.
- **5 catastrophic recoveries trong 7 ngày** = ~0.7 incident/day = quá cao.
- **3 deep root causes** (DRC-1 Continuous-obligation gap / DRC-2 LLM-vocabulary-vs-regex / DRC-3 Telemetry-broken-at-JOIN).
- **Self-pause Mode-E family** 4 recurrences sau 2 hook-extends → tier-3 escalation overdue.
- **Auto /clear+continue without handoff** (this incident, S48 boundary): budget-watchdog + continue-injector trigger reboot WITHOUT updated checkpoint → user lost visibility into work-in-flight.

Confidence assessment: hiện tại **~3/10** chạy autonomous. Sau Phase 2.5: **~7/10**.

## Hard rules during Phase 2.5

1. **autonomous_mode=false suốt Phase 2.5** — re-enable CHỈ qua user explicit gate sau HH-H + HH-D ratified.
2. **STOCKFORGE_WATCHDOG_DISABLE=1** — auto-reboot tắt; user manually /clear if needed.
3. **No new IMPL on Phase 3 business logic** trong Phase 2.5 — focus chỉ trên harness.
4. **Each track = separate session** per CLAUDE.md never-mix-PLAN-with-IMPL doctrine.
5. **VBW pre-flight Glob-before-Read** trên mỗi target file edit (L-S30-1 doctrine).
6. **Edit not Write cho protected paths** (L-S45-2 + write-vs-edit-guard.sh active).

## Tracks (8 substantive)

### HH-A — Foundation repair (S48b — ~3-4h)

**Goals**: Wire 2 charter-prescribed orphan hooks; refresh stale state files; manifest restore.

**Deliverables**:
- [ ] HH-A.1: Wire `vendor-api-probe.sh` SessionStart hook (`.claude/settings.json` matcher `startup|resume`).
- [ ] HH-A.2: Wire `tier1-bloat-check.sh` Stop hook (memory-tiers.md companion per D-017).
- [ ] HH-A.3: Update `project.md` — currently 5 ngày stale (last Apr-30 → reflect Phase 2 COMPLETE + Phase 3 IN PROGRESS S44-S47 DONE).
- [ ] HH-A.4: Move 4 stale Q&A bundles in `human-workspace/q-and-a/pending/` per contract revision (or human batch-close in chat).
- [ ] HH-A.5: Regenerate `manifest.yaml` from FS scan — restore V1 invariant (7 skills + 2 agents + 25 hooks currently untagged).
- [ ] HH-A.6: Smoke test cả 2 wired hooks (vendor-api-probe + tier1-bloat-check) — assert non-zero exit only on real anomaly.

**Success criteria**: 2 charter-prescribed hooks active; manifest V1 invariant 0 untagged; project.md Recent ADRs lists D-022..D-027.

### HH-B — Telemetry repair (S48c — ~5-7h)

**Goals**: Fix JOIN keys; populate failure_mode + tokens_used; audit drift signals; reactivate sync-tracker.

**Deliverables**:
- [ ] HH-B.1: Fix `dispatch-jsonl-recorder.sh` — PreToolUse capture `tool_use_id` + `agent_type` + `model`; SubagentStop emit COMPLETED with same `tool_use_id` (not derived hash). Verify JOIN: `jq -s 'group_by(.tool_use_id) | ...' dispatch.jsonl`.
- [ ] HH-B.2: SubagentStop hook capture `tokens_real` + `duration_ms` + `failure_mode` from transcript JSON sidecar (`${CLAUDE_TRANSCRIPT_PATH}` per docs).
- [ ] HH-B.3: PostToolUse `failure_mode` classification — parse tool_result_text for known patterns (`permission denied`, `timeout`, `error:`, `file not found`, `invalid input`); default `ok` only when stderr empty.
- [ ] HH-B.4: Audit `drift-signals.md` DR1-DR12 vs `drift-signals-D1-D9.sh` implementation. 8 signals never fire (DR1, DR3, DR5, DR7, DR8, DR10, DR11, DR12) — retire dead OR fix detector.
- [ ] HH-B.5: Promote `sync-tracker-update.sh` orphan → wired Stop hook; auto-increment sample_count per session-end based on session theme (extract from session frontmatter).

**Success criteria**: ≥80% dispatch events JOIN-able by `tool_use_id`; ≥30% component-telemetry rows non-null `failure_mode`; subagent burn measurable per dispatch.

### HH-C — Continuous-loop ritual codification (S48d — ~3-5h)

**Goals**: Convert continuous obligations từ session-end ritual (LLM judgment) thành Stop-hook checklist (mechanical).

**Deliverables**:
- [ ] HH-C.1: Stop-hook `session-end-checklist-linter.sh` — verify last session log mentions mistake-log update OR explicit "no mistakes this session". Soft-warn if missing.
- [ ] HH-C.2: Stop-hook `project-md-staleness-check.sh` — diff `project.md` Phase Goals Tracker vs `current-execution.md` Track Status; flag mismatch. Plus mtime delta vs newest ADR.
- [ ] HH-C.3: Stop-hook `profile-template-auto-populate.sh` — emit one card per session for `(model, effort, task_class)` based on session frontmatter.
- [ ] HH-C.4: CLAUDE.md § Session End checklist add 4 explicit steps (mistake-log update / project.md staleness / profile-template / promote-rule trigger).

**Success criteria**: 4 watchdog hooks active; CLAUDE.md updates ratified via deny-lift mini-batch; 0 continuous-loop dormancy events trên next 5 sessions.

### HH-D — Self-pause Tier-3 charter promotion (S48e — ~2-3h)

**Goals**: Promote self-pause Mode-E rule từ hook-tier (recurring 4 lần) lên charter-tier prompt-level.

**Deliverables**:
- [ ] HH-D.1: Author `agent-workspace/proposals/autonomous-protocol-amendment-mode-E.md` — charter Rule N+1: "Trong autonomous_mode=true, agent SHALL NOT emit any phrase that defers to human selection between options OR enumerates next-trigger conditions ('Next continue does X')".
- [ ] HH-D.2: D-NNN ADR ratify charter promotion via deny-lift mechanism (S38 precedent).
- [ ] HH-D.3: (Optional) Skill `autonomous-defection-detector` — subagent semantic check post-Stop nếu hook regex tiếp tục miss.

**Success criteria**: charter Rule N+1 ratified; first session post-ratify verify 0 self-pause family hits; promote-rule subagent run dispatched lessons L-S44-1 / M-S45-2 / M-S47-1.

### HH-E — Q&A escalation upgrade (S48f — ~3-4h)

**Goals**: URGENT-tier surface mechanism + revise lifecycle contract.

**Deliverables**:
- [ ] HH-E.1: Hook `qa-stale-urgent-escalator.sh` Stop — Q&A pending >48h emit URGENT log entry to `human-workspace/notifications/urgent.md`.
- [ ] HH-E.2: Revise contract Rule #4 in `agent-workspace/CLAUDE.md` — allow agent move pending → answered IF (a) qa-answered-detector hook signals + (b) human did not say "wait" within 24h.
- [ ] HH-E.3: (Optional) Telegram bot OR Windows toast notification cho URGENT events — configurable channel.

**Success criteria**: Q&A queue stale rate ≤1 bundle >48h sustained; auto-mv successfully fires on detected answers; 4 currently-stale bundles processed.

### HH-F — Self-knowledge bootstrap (S48g — ~4-6h)

**Goals**: Bootstrap profile cards + sync-tracker samples từ historical record để LLM tự nhận biết strengths/weaknesses.

**Deliverables**:
- [ ] HH-F.1: ETL `D-001..D-027` + 17 M-* entries → profile cards. Target: ≥30 cards across `(model × effort × task_class)`.
- [ ] HH-F.2: Sync-tracker sample bootstrap — extract historical decisions matched với category schema → ≥30 samples/category (statistical floor met).
- [ ] HH-F.3: Capability-map populate from same source — task_class hit rate per (model, effort) tuple.
- [ ] HH-F.4: Recalibrate `weights.yaml` thresholds nếu sample distribution suggest revision.

**Success criteria** (S48k HH-F.4 amended; original aspirational gates preserved with rationale):
- ✅ ACHIEVED S48j: 5 sync-tracker categories ≥30 samples each (31/32/30/30/30).
- ✅ ACHIEVED S48k (re-framed from original "MED → MED_HIGH transition"): ≥3 categories above 50.0 (MED tier baseline) — 4/5 achieved (DOMAIN_UBIQUITOUS 56.7 / DESIGN_THINKING 54.8 / LANGUAGE 51.4 / SCOPE 50.7; DECISION_ROUTING 49.5 below threshold due to M-S45-1 -2.0 substrate-loss correction). **Original "MED → MED_HIGH (70+)" criterion DEFERRED Phase 1+** per Charter Principle 8 (Calibration over confidence): weight rebalance (q_and_a +0.1→+0.3, charter +0.2→+0.5, correctness +0.5→+1.0) would push ceiling ~+15 to score 65-72 borderline, but charter@0.5/event lacks empirical event-outcome correlation evidence; goalpost inflation rejected. Re-evaluate after Phase 1+ when decision-outcome calibration data accumulates (per D-006 weights.yaml runtime config knob doctrine).
- ❌ DEFERRED S48l+ (HH-F.1 partial 6/30 cards): ≥30 profile cards across (model × effort × task_class). Sample data only supports 6-8 well-populated cards pre-Phase-3 dogfood. Auto-populate hook HH-C.3 will accumulate cards organically — no manual ETL push.
- ✅ ACHIEVED S48k: capability-map.md renders task_class × model recommendations (`agent-workspace/memory/self-awareness/capability-map.md`; sourced from state.tsv + 6 profile cards + 153-row events.tsv).

### HH-G — Portability validation (S48h — ~3-4h)

**Goals**: Verify `/attach` skill produces viable harness on fresh test directory.

**Deliverables**:
- [ ] HH-G.1: Author general-harness `CLAUDE.md` template — strip stockforge invariants (I-S1..I-S65 VN-specific + financial-data-protocol + thesis pipeline references); keep Karpathy + sandwich + memory + Q&A doctrine.
- [ ] HH-G.2: Split `invariants.md` → general invariants + `invariants-stockforge.md` (VN-specific + financial); manifest tags.
- [ ] HH-G.3: Run `/attach` smoke test against `C:/htdocs/test-harness-portability/` fresh dir; verify all 23 skills + 14 agents + 36 wired hooks copy correctly.
- [ ] HH-G.4: Document portability checklist + bootstrap procedure in `attach` skill references.

**Success criteria**: `/attach` produces working harness baseline ở test dir; harness CLAUDE.md template <2.5K tokens portable; 100% non-stockforge artifacts copy successfully.

### HH-H — Auto /clear+continue safety (S48i — ~2-3h, NEW track for current incident)

**Goals**: Eliminate auto-/clear+continue WITHOUT handoff. Make checkpoint update DETERMINISTIC pre-condition for any auto-reboot.

**Deliverables**:
- [ ] HH-H.1: Edit `scripts/session-self-reboot.sh` — refuse to fire UNLESS `checkpoints/latest.md` mtime within last 5 minutes (forces checkpoint write before reboot).
- [ ] HH-H.2: Pre-reboot hook `pre-clear-handoff-guard.sh` (existing? verify) — wired as PreCompact OR triggered at wind-down threshold; emit checkpoint snapshot if stale.
- [ ] HH-H.3: Edit `continue-injector.ps1` `source=clear` branch — gate qua autonomous_mode (currently unconditional fire); allow override via env var `STOCKFORGE_FORCE_CONTINUE_ON_CLEAR=1` for explicit user /clear flow.
- [ ] HH-H.4: Add Stop-hook `auto-reboot-handoff-verify.sh` — if `.cliff-fired` OR `.wind-down-fired` markers about-to-fire AND `checkpoints/latest.md` >2h stale → BLOCK reboot, emit URGENT.
- [ ] HH-H.5 (NEW S48e — surfaced via M-S48e-1): fix session-self-reboot double-keystroke (`/new` typed as `//nneeww`). Root cause: `budget-watchdog.sh` wired to BOTH `Stop` + `PostToolUse` hook chains in `.claude/settings.json` (lines 235 + 332); near 220K cliff, both fire `session-self-reboot` BEFORE `.cliff-fired` idempotency marker writes = TOCTOU double-spawn. Fix: (a) add idempotency to `session-self-reboot.sh` — refuse to fire if `.session-self-reboot-fired-<TS-bucket>` marker exists within last 60s (mirror continue-injector.ps1 L-S48-1 rate-limit pattern); (b) `budget-watchdog.sh` writes `.cliff-fired` marker BEFORE spawning session-self-reboot, defer marker-clear until session-self-reboot completes successfully.

**Success criteria**: 0 auto-reboot incidents without preceding checkpoint update; user-facing visibility ("checkpoint saved at YYYY-MM-DD HH:MM, rebooting") logged before any /clear; survival drill — manually trigger cliff threshold, verify checkpoint write precedes /clear.

## Dependency graph

```
HH-A (foundation) ─┐
                   ├─→ HH-C (ritual) ─┐
HH-B (telemetry) ──┘                  ├─→ HH-F (self-knowledge bootstrap)
                                      │
HH-D (Mode-E charter) ────────────────┤
                                      │
HH-H (auto-reboot safety) ─→ HH-E (Q&A escalation) ─→ HH-G (portability test)
```

**Critical path**: HH-A → HH-B → HH-F (telemetry must restore before sample bootstrap is meaningful). HH-D + HH-H independent. HH-G last (validates everything together).

## Re-enable autonomous_mode gate (post-Phase 2.5)

**Pre-condition checklist** (ALL must pass before autonomous_mode → true again):
- [ ] HH-A all 6 deliverables shipped + smoke green.
- [ ] HH-B JOIN integrity ≥80%.
- [ ] HH-C 4 watchdog hooks active + 5 sessions clean of continuous-loop dormancy.
- [ ] HH-D charter Rule N+1 ratified + first 5 sessions post-ratify show 0 self-pause hits.
- [ ] HH-E Q&A queue stale rate ≤1 bundle >48h.
- [ ] HH-F sync-tracker samples ≥30/category ✅ (S48j) + ≥3 categories above 50.0 MED-tier baseline ✅ (S48k 4/5) + capability-map.md rendered ✅ (S48k). Profile cards ≥30 DEFERRED Phase 1+ (auto-populate hook accumulation; manual ETL not warranted per S48i 6/30 honest baseline). MED → MED_HIGH (70+) tier graduation DEFERRED Phase 1+ (per S48k HH-F.4 amendment + Charter Principle 8 calibration-over-goalpost-inflation).
- [ ] HH-G `/attach` smoke test passes on test-dir.
- [ ] HH-H survival drill PASS — manual cliff trigger writes checkpoint before /clear.
- [ ] User explicit ratification — "autonomous_mode re-enable approved" via AskUserQuestion gate.

## Out of scope (Phase 2.5 will NOT do)

- Phase 3 Track I (Bayesian calibration) IMPL — resume at S49 post-2.5.
- Phase 3 Track J/K/L/M IMPL.
- BC-7 sentiment / BC-9 outer-loop IMPL.
- Stockforge thesis pipeline extensions.
- Charter substantive amendments beyond Mode-E + Rule 4b extensions.

## Recommended session sequence

| Session | Track(s) | Type | Envelope | Notes |
|---|---|---|---|---|
| S48b | HH-A | FOCUSED_IMPL | ~80-120K | Quick wins; orphan wiring + manifest regen |
| S48c | HH-B | FOCUSED_IMPL | ~120-180K | Telemetry repair foundation; hardest track |
| S48d | HH-C | FOCUSED_IMPL | ~80-120K | Watchdog hook authoring + CLAUDE.md updates |
| S48e | HH-D | PLAN+IMPL split (separate sessions if charter scope is heavy) | ~80-100K | Charter promote via deny-lift |
| S48f | HH-E | FOCUSED_IMPL | ~80-120K | Q&A lifecycle revision |
| S48g | HH-F | MULTI_TASK_IMPL | ~150-200K | Bootstrap ETL — the longest single session |
| S48h | HH-G | FOCUSED_IMPL | ~80-120K | Portability test + general template |
| S48i | HH-H | FOCUSED_IMPL | ~80-120K | Auto-reboot safety (current incident root fix) |

**Total envelope estimate**: ~750K-1.1M main + ~100-200K subagent (mostly hook authoring, no heavy IMPL).

## Companion documents

- Audit: `agent-workspace/memory/observations/2026-05-05-harness-alignment-audit.md`
- Root cause: `agent-workspace/memory/observations/2026-05-05-root-cause-3-axes.md`
- This plan: `agent-workspace/session-plans/pending/009-S48-harness-hardening-middle-phase.md`
- Charter ref: `agent-workspace/constitution/autonomous-protocol.md` (Mode A/B/C/D/E)

## Open user gates

- **Q-2.5-1** (SCOPE): Approve Phase 2.5 insertion between Phase 2 close and Phase 3 Track I? Recommended: A (yes — needed before autonomous re-enable).
- **Q-2.5-2** (SCOPE): Approve all 8 tracks scope OR pick subset? Recommended: A (all 8 — each addresses an audit gap).
- **Q-2.5-3** (CHARTER): Pre-approve Mode-E charter promotion concept (final wording at HH-D.1)? Recommended: A (concept yes — wording user-gate at HH-D).
- **Q-2.5-4** (IMPL): Notification channel preference for HH-E.3 — Telegram bot / Windows toast / file-only? Recommended: file-only (simplest) + Windows toast (best UX) — agent decides empirically.
