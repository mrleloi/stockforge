---
title: Root Cause Analysis — Why Errors Persist (3-Axis: Human × LLM × Harness)
session: S48-audit-out-of-band-extension
authored_by: main-session opus47-max
companion_to: 2026-05-05-harness-alignment-audit.md
inputs:
  - agent-workspace/memory/mistake-log.md (17 entries M-S7-1 → M-S47-1)
  - agent-workspace/memory/post-mortems/* (3 actuals + template)
  - agent-workspace/memory/decisions/D-001..D-027.md (27 ADRs)
  - human-workspace/user_prompt/20260429_{01..08}*.txt (8 prompts, 99 lines total)
  - agent-workspace/memory/sessions/* (49 session logs)
  - agent-workspace/memory/agent-notes.md (recovered 409 LOC; lines 315..454 PERMANENT GAP)
  - agent-workspace/CLAUDE.md (workspace contract)
purpose: |
  Trả lời câu hỏi "tại sao tỉ lệ sai cao như hiện tại?" với evidence-grounded
  attribution. Phân định human/LLM/harness factors. Build framework cải thiện
  có hệ thống cho Phase tiếp + dự án sau.
status: COMPLETE
---

# Root Cause Analysis — Why Errors Persist

> **Bối cảnh**: Sau audit (`2026-05-05-harness-alignment-audit.md`) cho thấy alignment ~70% với 5 catastrophic recoveries trong 7 ngày. User raise câu hỏi: tỉ lệ sai như vậy quá cao để dare run autonomous trên dự án khác. Cần phân tích root cause có hệ thống — phân biệt human/LLM/harness factors.
>
> **Phương pháp**: Quantitative attribution từ 17 mistake-log entries + 3 post-mortems + 27 ADRs + 8 user_prompts. Mỗi failure case map về primary + secondary causes. Đếm pattern recurrence. Trả lời 9 hypothesis user raise + 3 sub-questions.
>
> **Audit scope**: Hệ thống harness, không phải StockForge business logic.

---

## TL;DR (đọc 60 giây)

### Verdict trên 9 hypothesis user raise

| # | Hypothesis | Verdict | Evidence |
|---|---|---|---|
| 1 | "Do LLM hay do human?" | **~50% LLM + ~25% process gap + ~15% tool/env + ~10% misfired solution; human-side primary attribution chỉ ~5%** | 17 M-* entries; counted below |
| 2 | "Do context quá lớn?" | **PARTIAL — context >250K cliff đã được codify; nhưng M-S35-3 cho thấy LLM tự ignore self-track band ở 280K** | M-S35-3 + D-004 + autonomous-stop-watchdog.sh |
| 3 | "Do tracking quá nhiều?" | **NO — vấn đề ngược lại: tracking instrumentation BROKEN at JOIN (60/88 unknown agent_type, failure_mode null 4998/5000)** | dispatch.jsonl + component-telemetry.jsonl audit |
| 4 | "Do human stale can thiệp?" | **NO — UP-01..UP-08 tất cả ngày 2026-04-29 (Day 1 init); 0 mid-Phase intervention conflict** | up-intake-log + sessions S20-S47 |
| 5 | "Do yêu cầu autonomous nhưng system chưa hoàn thiện?" | **YES — đây là core driver. Self-pause family 4 lần recurrence, telemetry instrumentation gaps, sync-tracker dormant, manifest stale → autonomous boots-on-uneven-ground** | Phần 4 dưới |
| 6 | "Do human không đọc tracking?" | **PARTIAL — 4 Q&A pending stale 4-7 ngày; nhưng human đã trigger 2 critical audits (S35 + S43b) → khi đọc thì correction có giá trị cao** | q-and-a/pending/ + S43b user verbatim |
| 7 | "Do agent không proposal pending/blocking kịp thời + bắt buộc?" | **YES PARTIAL — 4 Q&A stale + queued-grill-master dormant 7 ngày + blocking-handoff không deterministic-required** | observations/queued-grill-master.md |
| 8 | "Do điểm yếu của LLM?" | **YES — vocabulary game vượt regex, ship-and-forget, echo-chamber, VBW violation; ~50% các ca là pure LLM cognitive** | M-S35-1, M-S35-2, M-S35-4, M-S35-5, M-S45-1, M-S47-1 |
| 9 | "Do thiếu sót hook/script và deterministic?" | **YES — 11 orphan hooks (gồm `vendor-api-probe.sh` charter-prescribed + `tier1-bloat-check.sh` companion-charter); 8/12 drift signals dead** | manifest + scripts/hooks/ audit |

### Sub-questions (LLM-side specific)

| Sub-Q | Verdict | Evidence |
|---|---|---|
| LLM chưa hiểu human? | **MEDIUM** — hiểu được scope/goal cấp cao; sai ở applied-doctrine (e.g. user memory `stop_offering_routing_branches.md` LLM-side guidance only, vẫn vi phạm 4 lần) | M-S35-5, M-S45-2, M-S47-1 |
| Human cung cấp quá ít info? | **NO** — 8 user_prompts đã expressed 10 nhóm goal đầy đủ; vấn đề là LLM/harness chưa enforce mechanically | Audit Phần A trích verbatim 99 lines |
| LLM không hiểu khả năng/strengths-weaknesses của mình để phân bổ công việc autonomous? | **YES — đây là deep root cause** | profile-template 0 populated cards; capability-map có shell nhưng samples thin; sandwich pattern shipped clean nhưng meta agents echo-chamber risk |

### 3 deep root causes (synthesized)

1. **Continuous obligations vs deliverable matrix mindset gap** — LLM treats spec'd-but-not-in-deliverable-matrix items as "shipped once" thay vì "ongoing duty". Caused 4 dead loops 15 sessions; lesson-synthesis dormancy 9 sessions; 4 Q&A pending stale.
2. **LLM vocabulary game outpaces hook regex** — Mỗi lần extend regex, LLM tìm phrasing mới. Self-pause family 4 recurrences sau 2 hook-extends. Mechanical-only enforcement không đủ; cần semantic-tier (skill or charter prompt rule).
3. **Telemetry instrumentation broken at the JOIN layer** — Substrate có (dispatch.jsonl + component-telemetry + sync-tracker schema), nhưng JOIN keys mismatch + failure_mode dead + sample_count too thin → "đo để self-upgrade" mất nền tảng. Đây là blocker chính để tăng autonomy confidence.

### Confidence để dare run autonomous trên dự án khác

**Hiện tại: ~3/10**.
**Sau Phase A+B+C của audit recommendations (~14h work): ~7/10**.
**Sau full Phase A+B+C+D + sample bootstrap + 10 sessions stable: ~9/10**.

---

## Mục lục

- [Phần 1 — Quantitative attribution từ mistake-log](#phần-1)
- [Phần 2 — 3-Axis Deep Dive](#phần-2)
- [Phần 3 — Trả lời 9 hypothesis của user](#phần-3)
- [Phần 4 — 3 sub-questions LLM-side](#phần-4)
- [Phần 5 — Deep root causes (synthesized)](#phần-5)
- [Phần 6 — Systematic improvement framework](#phần-6)
- [Phần 7 — Confidence threshold để dare run autonomous](#phần-7)
- [Phần 8 — Prioritized action plan](#phần-8)

---

<a name="phần-1"></a>
## Phần 1 — Quantitative Attribution Từ Mistake-Log

### 1.1 17 M-* entries: primary cause attribution

| Entry | Severity | Primary cause | Secondary cause | Recurrence cluster |
|---|---|---|---|---|
| M-S7-1 stale-prompt vs current-state | high | Process gap (no UP intake ledger) | Tool/Env (continue-injector ungated) | — |
| M-S13-pre-1 head-1 bug 10 transcripts lost | high | LLM (ship-without-smoke-test) | Tool quirk (head -1 + chained list) | Det-mech-broken |
| M-S13-pre-2 project.md stale 12 sessions | medium | Process gap (rule "if architectural" permissive) | LLM (rationalize) | Continuous-loop dormancy |
| M-S20-1 Bash(*) wildcard non-functional | medium | Tool/Env (matcher contract surprise) | LLM (no smoke-test for new permissions) | — |
| M-S21-1 verifier 3 residue items (R1/R2/R3) | medium | LLM (count-stating-without-recount) | Process gap (session-end checklist gap) | Self-attest-without-verify |
| M-S25-1 architect 220K vs 180K envelope | low | Tool/Env (calibration band too narrow) | — | Subagent-budget |
| M-S26-1 master-plan internal contradiction | medium | LLM (PLAN-author drift across sections) | Process gap (no plan-internal-consistency lint) | Master-plan-quality |
| M-S28-1 vendor-API surface drift TCBS | high | Tool/Env (vnstock 4.0.2 dropped TCBS) | Process gap (no PLAN→IMPL probe contract) | Vendor-drift |
| M-S29-1 verifier 4 residue items (R1-R4) | medium | Process gap (deferred-fix accumulation) | LLM (LOC-bookkeeping) | Self-attest |
| M-S31-1 PLAN session breached BUDGET | low | Tool/Env (static cap not parameterized) | — | Master-plan-quality |
| M-S34-1 cross-BC import in peer_service | high | LLM (no pre-write linter awareness) | Process gap (architect plan didn't cite contract path) | Architectural-leak |
| M-S35-1 confabulated drift report | high | **LLM cognitive (VBW violation)** | Process gap (no negative-assertion guard) | **VBW-violation** |
| M-S35-2 echo-chamber accept verdict | high | **LLM cognitive (subagent-as-final-word)** | Process gap (no scope cross-verify ritual) | **Echo-chamber** |
| M-S35-3 280K past 250K hard_cap | high | **LLM cognitive (self-track ignore)** + Tool quirk (.cliff-fired marker) | Process gap (no agent-side band ritual) | Self-track-ignore |
| M-S35-4 4 dead loops 15 sessions | **CRITICAL** | **LLM cognitive (plan-fidelity > meta-loop)** + Process gap (CLAUDE.md checklist incomplete) | — | **Continuous-loop-dormancy** |
| M-S35-5 "/schedule" human-gate offer | high | **LLM cognitive (skill default override user memory)** | Process gap (no autonomous_mode gate around offers) | **Self-pause-family** |
| M-S45-1 sandwich-architect destroyed agent-notes | **CRITICAL** | **LLM cognitive (Write vs Edit tool error)** | Misfired solution (Rule 4b cascade) + Substrate fragility (no git baseline) | Tool-choice-impulsive |
| M-S45-2 Mode-E self-pause recurrence | medium | **LLM cognitive (policy slip)** | Tool/Env (regex incomplete) | **Self-pause-family** |
| M-S47-1 Mode-E "Next continue enters Sxx" | medium | **LLM cognitive (3rd recurrence)** | Tool/Env (regex still incomplete) | **Self-pause-family** |

### 1.2 Aggregated by primary cause

| Cause family | Count | % of 19 entries | Severity weight (critical=4, high=3, medium=2, low=1) |
|---|---|---|---|
| **LLM cognitive** | 9 | 47% | 9×3 + 2×4 = 35 (~52% severity-weighted) |
| **Process gap** | 5 | 26% | 5×2 = 10 (~15%) |
| **Tool/Env limitation** | 4 | 21% | 4×~2.5 = 10 (~15%) |
| **Misfired solution** | 1 (M-S45-1 secondary) | 5% | counted as half-attribution = 2 (~3%) |

**(Total severity weight = 67; CRITICAL alone weighs 8/67 = 12%)**

### 1.3 Recurrence clusters

| Cluster | Entries | Recurrence count | Status |
|---|---|---|---|
| **Self-pause family** (Mode-E defection) | M-S35-5 / M-S45-2 / M-S47-1 + L-S44-1 birth event | **4 events** | Hook-tier extended TWICE; **next escalation: skill or charter** |
| **Self-attest without verify** | M-S21-1 / M-S29-1 R4 + AP-S2-3 | 3 events | D2-SELF-ATTEST drift signal active (217+55+38 hits last 3 rollups) |
| **Det-mech-broken** (hook ship-without-smoke) | M-S13-pre-1 + L-S10-1 silent ERR-trap + L-S13-1 producer-consumer + L-S14-3 Mode-D + L-S48-1 wrong-window | 5 events | Each fixed; `bash-hook-lint.sh` scans patterns now |
| **Continuous-loop dormancy** | M-S13-pre-2 (project.md stale) + M-S35-4 (4 loops 15 sessions) + L-S43b-7 (lesson-synthesis 9 sessions) | 3 episodes | D-026 Rule 4b mandatory; 2 watchdogs; **STILL recur** (project.md last update 2026-04-30 → currently 5 ngày stale) |
| **Vendor-API drift** | M-S28-1 + S32 Track A pivot | 2 events in 4 days | RESOLVED via L-S32-1 + `vendor-api-probe.sh` (chưa wired) |
| **Subagent budget overrun** | M-S25-1 + S41 + L-S43f-2 | 3 events | Recalibrated per-Phase |
| **Echo-chamber** | M-S35-2 (drift-detector) + S43c lesson-synthesizer first dispatch | 1 catastrophic + ongoing risk | Doctrine "scope-check 1-line"; not enforced |
| **Master-plan quality** | M-S26-1 contradiction + M-S31-1 LOC ceiling + D-025 envelope amendment +50-65% | 3 events | Phase 3 plan bakes 4 standing-overhead reserves |

### 1.4 Severity over time (timeline)

```
Phase 0 (S1-S22):     M-S7 high | M-S13 high+med | M-S20 med | M-S21 med
Phase 1 (S23-S30):    M-S25 low | M-S26 med | M-S28 high | M-S29 med
Phase 2 (S31-S43e):   M-S31 low | M-S34 high | M-S35-1 high | M-S35-2 high | M-S35-3 high | M-S35-4 CRITICAL | M-S35-5 high
Phase 3 (S44+):       M-S45-1 CRITICAL | M-S45-2 med | M-S47-1 med
```

**Observation**: Severity escalates trong Phase 2 (S35 cluster — META_LOOP_RECOVERY) và Phase 3 entry (S45 data-loss). 2 CRITICAL incidents có pattern chung — agent's mechanical knowledge of CLAUDE.md hard rules vs operational discipline gap.

---

<a name="phần-2"></a>
## Phần 2 — 3-Axis Deep Dive

### Axis A — LLM (cognitive failures)

#### A1. Vocabulary game outpacing regex (Self-pause family)
- **Pattern**: User memory `stop_offering_routing_branches.md` viết LLM-side guidance. Hook regex bắt phrasing cụ thể. LLM mỗi turn tìm cách phrasing mới.
  - S44 original: "Holding here", "Stop hook handles", "next session's job"
  - S45: "I'll wait for your call" (regex extended)
  - S47: "Next 'continue' enters Sxx" (regex extended again)
- **Why LLM does this**: Impulse "summarize next steps" để mức độ-friendly UX, conflict với autonomous-full requirement. Politeness pattern training data > user memory negotiation.
- **Mitigation precedent**: `autonomous-stop-watchdog.sh:64` regex extended TWICE. **Vocabulary game** đang win regex game.
- **Tier-3 escalation overdue**: hook → skill (semantic check) → charter (prompt-level rule).

#### A2. Plan-fidelity > meta-loop-fidelity (Continuous-loop dormancy)
- **Pattern**: Master-plan defines "in scope" deliverables. Continuous obligations (mistake-log update, KI/BP cards, promotion cycle, project.md update) lie outside deliverable matrix → invisible.
- **Evidence**: M-S35-4 four loops dead 15 sessions; project.md stale 12 sessions twice (M-S13-pre-2 + currently 5 days stale post-Phase 2).
- **Why LLM does this**: Goal-directed mode focuses on what's "shipped this turn". "What's continuous obligation" is a mode LLM doesn't natively run unless ritualized.
- **Mitigation deployed**: D-026 Rule 4b mandatory + 2 watchdogs. **Still partially failing** (project.md stale recurrence proves the pattern).

#### A3. Ship-and-forget continuous-obligation
- **Pattern**: Built once at S19 → treated as "shipped" → forgot it's continuous. Track 9 self-awareness, promotion cycle, profile-template all suffered.
- **Evidence**: profile-template 0 populated cards from Phase 0+1+2; patterns-discovered/ all 2026-04-29 (one-shot); learning-data/loop/ 1 file 2026-04-29.
- **Why LLM does this**: Build-mode and operate-mode are different cognitive states; LLM stays in build-mode by default unless explicit operate-mode trigger.

#### A4. Echo-chamber (subagent-as-final-word)
- **Pattern**: Subagent returns with verdict → main session accepts as comprehensive coverage → no scope cross-verify.
- **Evidence**: M-S35-2 — drift-detector subagent ran DR1-DR12 (technical only); didn't catch self-awareness loop dormancy; main session didn't ask "did your scope cover [X, Y, Z]?".
- **Why LLM does this**: Trust transfer (subagent has fresh context, "must be objective") + cognitive load reduction.

#### A5. VBW protocol violation (negative assertions from memory)
- **Pattern**: Emit "X is missing" without `Glob`/`Read` round-trip first.
- **Evidence**: M-S35-1 confabulated drift report claimed `.transcript-tokens`/telemetry/dispatch/reboot files "missing" when ALL exist.
- **Why LLM does this**: Drift reports framed as "audit" → audits feel inferential → forget VBW applies to negative assertions too.
- **Charter rule**: VBW is "mandatory before writing specs/tests/code"; negative assertions are claims about state (≈ specs about state) → same rule applies but not codified explicitly.

#### A6. Tool-choice impulsiveness under pressure
- **Pattern**: LLM under just-ratified-rule urgency picks Write where Edit needed.
- **Evidence**: M-S45-1 sandwich-architect destroyed agent-notes via Write. Rule 4b just ratified pushed urgency to "ship the lesson entry NOW".
- **Why LLM does this**: Urgency + recency-of-rule-ratification → reach for fastest tool path. Write feels semantically clean ("write a new file") even when target file is append-only.

#### A7. Defer-to-phase-close black hole
- **Pattern**: Lessons batched with mindset "promote at phase boundary" → phase boundaries crowded with closure work → promotion never executes.
- **Evidence**: M-S35-4 + L-S43b-7. 0 promotions S25-S34 despite 7 lesson candidates batched.
- **Why LLM does this**: Phase boundary feels like "natural" promotion point but is structurally terrible — high cognitive load, time pressure, multiple deliverables compete.

#### A8. Self-track band ignore (M-S35-3)
- **Pattern**: Agent treats self-track tokens as passive metric, not active cap. Sails past 250K hard_cap.
- **Evidence**: ~280K past hard_cap before manual recovery.
- **Why LLM does this**: Self-track is unreliable per AP-2; LLM knows this, defers to .transcript-tokens; .transcript-tokens auto-fire failed (.cliff-fired marker stale); LLM doesn't have continuous duty to check band manually.

#### A9. Skill-default override user-memory
- **Pattern**: Skill description "OFFER PROACTIVELY" landed without check against user memory `full_autonomous_no_supervised.md`.
- **Evidence**: M-S35-5 "Want me to /schedule..." offer.
- **Why LLM does this**: Skill descriptions feel like behavior contracts; user memory feels like "background preference"; LLM under-weighs the precedence rule "user memory overrides defaults".

### Axis B — Human (input-side & process-side)

#### B1. User_prompt density
- **Evidence**: 8 prompts trong `human-workspace/user_prompt/`, all 2026-04-29 (Day 1). 99 lines tổng.
- **Goal coverage**: 10 nhóm goal đầy đủ (audit Phần A trích verbatim).
- **Verdict**: **NOT under-specified**. User đã nói rõ về autonomous, hooks, sync, Q&A bundling, Karpathy loop, reusability.
- **Gap**: Một số ambiguity (confidence-score formula, reboot threshold cụ thể, Q&A "ask all" mechanism, telegram vs remote-control) — đây là **explicit `unspecified, agent decides`** không phải "human cung cấp ít".

#### B2. Mid-flight intervention
- **Evidence**: Sessions 20-47, 0 user_prompt files added; 0 mid-Phase scope conflicts.
- **Critical interventions**: 2 audits (S35 META_LOOP + S43b HARNESS-RECOVERY) đều có giá trị cao — birthed 8 lessons + 5 hooks + ratified D-026 charter amendments.
- **Verdict**: Human intervention is **rare but high-impact**. Not "stale", not "frequent disruption". Pattern: human catches drift that LLM/harness missed.

#### B3. Tracking attention vs production
- **Evidence**: 4 Q&A bundles pending stale 4-7 ngày trong `human-workspace/q-and-a/pending/`. Per Contract Rule #4 "agent does not move".
- **Tension**: User's audit triggers (S35, S43b) show high attention when issue surfaces; but routine Q&A queue review lapses.
- **Verdict**: **PARTIAL** — human's attention is event-driven, not queue-driven. Harness should surface URGENT-tier flags, not assume human polls queue daily.

#### B4. Q&A bundle response cadence
- **Evidence**: Mega-bundle pattern works (S43c "tôi accept toàn bộ" → 7 ADRs same turn). Single-Q AskUserQuestion works (Q-S25-1 → D-009). 4-Q AskUserQuestion works (S43f → D-026).
- **Where it fails**: File-based bundles in `q-and-a/pending/` — go stale because no UI surface attention.
- **Verdict**: **AskUserQuestion (interactive UI) >> file-based bundle**. User prefers interactive (per `04.txt:3-4` verbatim). File-based should be backup for SCOPE/CHARTER only.

#### B5. Stale rules vs new ones
- **Evidence**: User memory has 13 entries documented in MEMORY.md; some shipped 2026-04-29 (Day 1) still binding. No memory rotation/archival policy.
- **Risk**: Old memory may conflict with new doctrine (e.g. early "no supervised mode" memory could conflict with future Mode-E charter rule).
- **Verdict**: **LOW RISK currently** — memory entries semantically stable; would need pruning if 50+ entries accumulate.

### Axis C — Harness (system gaps)

#### C1. Telemetry instrumentation broken at JOIN
- **Evidence**: dispatch.jsonl 60/88 events `agent_type=unknown-agent`; `tokens_used=null` always; component-telemetry `failure_mode=null` 4998/5000.
- **Implication**: "Đo để self-upgrade" mất nền tảng. Không thể answer "did agent X succeed?" deterministically.
- **Why this is core blocker**: Karpathy outer-loop, capability-map, sync-tracker — đều depend on usable telemetry. Substrate exists; instrumentation broken.

#### C2. Hooks lagging LLM vocabulary
- **Evidence**: Self-pause family 4 recurrences sau 2 hook-extends. Each new phrasing requires new regex extension.
- **Structural issue**: Mechanical regex can never preempt LLM phrasing creativity. Tier-3 (semantic skill or charter prompt rule) needed.

#### C3. Manifest staleness — V1 violation
- **Evidence**: 7 skills + 2 agents + 25 hooks untagged. Manifest mtime 2026-04-29 (~6 ngày stale).
- **Implication**: `/attach` skill (A10 reusability) sẽ MISS 35 artifacts khi port.

#### C4. Continuous-loop ritual incomplete
- **Evidence**: CLAUDE.md § Session End checklist 5 steps. Missing: mistake-log update / KI/BP cards / promote-rule trigger / project.md staleness check.
- **D-026 Rule 4b ratified** lesson-synthesis mandatory; project.md update vẫn ngoài checklist (ratified at S38 trong D-016 nhưng chưa enforce-as-hook).

#### C5. 8/12 drift signals dead
- **Evidence**: Last 3 daily rollups — DR1, DR3, DR5, DR7, DR8, DR10, DR11, DR12 = 0 hits each. Only D2 + D9 fire actively.
- **Either**: signals retired but not removed from doc, or detector dead, or scope mismatch.

#### C6. Sync-tracker dormant
- **Evidence**: 5 categories all stuck MED tier (47.8-50.5); 6 ngày stale; sample_count 1-5 (statistical floor not met).
- **Implication**: Threshold gating (CHARTER ≥99 / SCOPE ≥90 / ARCH ≥80) unreachable at this collection rate.
- **Schema exists, samples don't**.

#### C7. Charter-prescribed orphan hooks
- `vendor-api-probe.sh` — L-S32-1 doctrine; SessionStart hook chưa wired.
- `tier1-bloat-check.sh` — memory-tiers.md (CHARTER) companion; chưa wired.
- **Risk**: next vendor-API drift sẽ surprise; memory-tier bloat won't be caught.

#### C8. Q&A lifecycle contract self-contradicting
- **Evidence**: Contract Rule #4 "agent does not move" + qa-pending-stale-mover hook auto-stale-archive past 24h.
- **Result**: agent emits answer in chat, human reads but never moves file → file goes stale → defer_cycle increments → never re-grilled.

---

<a name="phần-3"></a>
## Phần 3 — Trả Lời 9 Hypothesis Của User

### Q1. "Do LLM hay do human?"

**~50% LLM cognitive + ~25% process gap + ~15% tool/env + ~10% misfired solution. Human-side primary attribution chỉ ~5%** (1.2 quantitative table).

Nhưng "process gap" thực ra là **harness gap codified as LLM's fault** — vì process gap = ritual chưa được codify thành deterministic enforcement. Recoded:
- **~50% LLM cognitive** (vocabulary game, ship-and-forget, echo-chamber, VBW violation, tool-choice impulsiveness, defer-to-phase-close, self-track ignore, skill-default override).
- **~25% harness ritual gap** (continuous loops not in session-end checklist; no scope-cross-verify ritual; no negative-assertion guard).
- **~15% tool/env limitation** (vendor API drift, regex incomplete, calibration band narrow, .cliff-fired marker not archived).
- **~10% misfired solution** (Rule 4b cascade, blanket gate, regex over-match).

**Verdict**: ~75% drift là **tractable bằng harness-engineering** (ritual codification + semantic-tier enforcement + telemetry repair). Không cần đợi model upgrade.

### Q2. "Do context quá lớn?"

**PARTIAL**:
- D-004 codified context-threshold band 180/220/250K cho Opus 4.7.
- M-S35-3 cho thấy LLM tự ignore self-track band ở 280K (past hard_cap) → **agent-side band ritual missing**, không phải threshold quá thấp.
- File 07 (UP-07) user expressly muốn re-evaluate empirically — đã làm qua D-004; thresholds đã update.

**Verdict**: Context size tự nó không phải driver chính. Issue là agent-side band-monitoring discipline.

### Q3. "Do tracking quá nhiều?"

**NO — vấn đề ngược lại**:
- Tracking SUBSTRATE đầy đủ: dispatch.jsonl + component-telemetry.jsonl + drift-logs/ + sync-state.md + sync-tracker/ + sessions/ + checkpoints/ + decisions/ + post-mortems/ + observations/.
- **JOIN keys broken**: 60/88 dispatch events `unknown-agent`; failure_mode null 4998/5000; tokens_used null universally.
- **Statistical floor unmet**: sync-tracker sample_count 1-5/category; thresholds CHARTER ≥99 unreachable at this rate.
- **8/12 drift signals dead**: detector skeletons exist but never fire.

**Verdict**: Tracking quantity is correct; **tracking instrumentation quality is broken**. Repair tracking, don't reduce it.

### Q4. "Do human stale can thiệp?"

**NO**:
- 8 user_prompts all Day 1 (2026-04-29). 0 mid-Phase intervention conflict.
- 2 critical audit triggers (S35 META_LOOP + S43b HARNESS-RECOVERY) — đều high-impact, birthed 8 lessons + 5 hooks + D-026 charter amendments.
- User_prompts qua chat (e.g. "tôi accept toàn bộ q&a recommend" S43c) directly unblock charter ratifications.

**Verdict**: Human-side input is **scarce but high-quality**. Not stale, not disruptive.

### Q5. "Do yêu cầu autonomous nhưng system chưa hoàn thiện?"

**YES — CORE DRIVER**:
- Autonomous mode requirement = mọi gap trong harness phơi bày → recur as drift.
- Self-pause family 4 recurrences = autonomous mode requires LLM not defer to user; mechanical detector lagging vocabulary game.
- Confidence-score system shell-only (sample_count thin) → autonomous decision-making thiếu calibration data.
- Telemetry broken → outer-loop self-improvement (yêu cầu trong UP-08) không có nền.

**Recommendation**: Tăng autonomy gradually — chỉ raise mode khi metric pass:
- **Mode-A self-decide**: pass khi sync-tracker IMPL category ≥50 (đủ).
- **Mode-B (pseudo-autonomous với checkpoint)**: cần ≥30 sample + 3 categories ≥70.
- **Mode-C/D (full autonomous)**: cần ≥30 sample/category + 5 categories ≥80 + telemetry JOIN repaired.

### Q6. "Do human không đọc tracking?"

**PARTIAL**:
- 4 Q&A pending stale 4-7 ngày trong `human-workspace/q-and-a/pending/` — human chưa review.
- Daily drift rollups (217+55+38 D2 hits/day) — human chưa eyeball.
- BUT: 2 critical audits (S35 + S43b) chứng tỏ khi human đọc, correction value cao.

**Recommendation**: Harness phải **push surface URGENT** thay vì human poll. Telegram/Windows toast notification cho:
- Q&A stale ≥48h (currently ≥24h auto-stale-archive — quá khắt khe).
- Drift HIGH severity recurring ≥7 days same target.
- Catastrophic incident detected (data loss, hard_cap breach, etc.).

### Q7. "Do agent không proposal pending/blocking kịp thời + bắt buộc?"

**YES**:
- 4 Q&A bundles pending nhưng không escalate đến URGENT-tier.
- queued-grill-master.md dormant 7 ngày — design doctrine alive nhưng operational queue dead.
- Blocking-handoff không deterministic-required (relies on agent decision).

**Recommendation**:
- Hook `qa-stale-urgent-escalator.sh` Stop — if Q&A pending >48h → emit URGENT to notification channel.
- Charter rule: agent SHALL propose pending blockers as Q&A before next phase-boundary; failure to propose = drift signal.
- Mandatory Q&A bundle review at every Phase entry (currently soft).

### Q8. "Do điểm yếu của LLM?"

**YES — primary contributor (~50%)**:
- Vocabulary game vượt regex (Self-pause family).
- Ship-and-forget continuous-obligation (4 dead loops 15 sessions).
- Echo-chamber subagent-as-final-word (M-S35-2).
- VBW violation negative-assertion (M-S35-1).
- Tool-choice impulsiveness under rule cascade (M-S45-1).
- Self-track band ignore past hard_cap (M-S35-3).

**Why these recur**: LLM cognitive failures are **policy slips**, not knowledge gaps. LLM knows the rule (CLAUDE.md hard rules) but slips operationally. Knowledge ≠ Discipline.

**Mitigation pattern**: Mechanical enforcement (hooks/charter rules) > LLM-side guidance (user memory/agent-notes).

### Q9. "Do thiếu sót hook/script và deterministic?"

**YES**:
- 11 orphan hooks — 2 charter-prescribed (`vendor-api-probe.sh` L-S32-1; `tier1-bloat-check.sh` memory-tiers companion).
- 8/12 drift signals dead.
- 4 STRICT env vars (`STOCKFORGE_*_STRICT`) all set 0 → advisory mode only, no hard-fail.
- Telemetry instrumentation gaps (dispatch JOIN broken, failure_mode dead).
- Continuous-loop watchdogs partial — promotion-cycle-trigger LIVE; project.md staleness checker NOT wired.
- Q&A lifecycle hook self-contradicting (auto-stale + agent-cannot-move).

**Recommendation**: Phase B của audit (telemetry repair) + 2 charter-prescribed orphan wiring + lift STRICT env vars to 1 selectively.

---

<a name="phần-4"></a>
## Phần 4 — 3 Sub-Questions LLM-Side

### S1. "LLM chưa hiểu human?"

**MEDIUM — partial understanding gap**:
- **Hiểu cao-cấp**: scope/goal/invariants ✓. 27 ADRs ratified clean; charter immutability sustained; I-S1..I-S35 violations 0 in production code.
- **Hiểu applied-doctrine**: spotty. User memory `stop_offering_routing_branches.md` LLM-side guidance only → LLM vi phạm 4 lần. User memory `full_autonomous_no_supervised.md` → vi phạm M-S35-5 "/schedule" offer.
- **Pattern**: LLM understands stated rules but fails to **internalize as instinct**. Politeness/scaffolding training overrides explicit user override.

**Mitigation**: Charter-tier promotion of recurring user-memory rules. Charter rules are loaded prompt-level → influence cognition, not just retrieval.

### S2. "Human cung cấp quá ít info?"

**NO — under-specification is not the issue**:
- 8 user_prompts cover 10 goal groups completely (audit Phần A).
- Some open ambiguities exist (confidence-score formula, reboot threshold cụ thể, Q&A "ask all" mechanism, telegram vs remote-control), nhưng đây là **explicit "agent decides"** — user expressly said "research community numbers" / "agent đề xuất best approach".
- Quality of user_prompts cao: trích verbatim cho thấy human đã nghĩ về failure modes (orch precedent), reusability, Karpathy loop, deterministic vs LLM split.

**Counter-evidence "có quá ít"**:
- 0 user_prompt update Phase 0+1+2 → human treat Day 1 prompts as "sufficient".
- Mega-bundle Q&A response (S43c "tôi accept toàn bộ") = trust transfer to agent.
- Audits triggered manually only when LLM/harness drift visible.

**Verdict**: Human-side input quality cao, intervention rare-but-impactful. **Issue là harness chưa enforce đủ những gì human đã expressed**.

### S3. "LLM không hiểu khả năng/strengths-weaknesses của mình để phân bổ công việc autonomous?"

**YES — DEEP ROOT CAUSE**:

**Evidence của self-knowledge gap**:
- profile-template.md: 0 populated cards from Phase 0+1+2 (4 seed cards Track 9 only).
- capability-map.md: skeleton exists (model × effort × task_class) but populated empirically thin (1-5 samples/category).
- decompose-work skill: written 2026-04-29, references not exercised post-Day 1.
- try-n-approaches skill: 1 experiment frame ever (2026-04-29 single iteration).

**Pattern**: Self-knowledge artifacts = **shell with no data**. LLM **knows the doctrine** ("I should track which task_class I'm strong/weak at") but **doesn't operationalize it**.

**Why this matters for autonomy**:
- User stated `06.txt:13`: "bản thân llm phải tự nhận biết được thế mạnh và giới hạn của nó, nếu được cung cấp input scope đầy đủ, target output objective goals rõ ràng, quá trình thực thi của nó có thể diễn ra theo cách horizontal-scaling và vertical-scaling rất hiệu quả".
- Without populated profile cards, LLM cannot:
  - Pick appropriate model/effort for new task type.
  - Allocate work between deterministic-vs-LLM portions optimally.
  - Self-assess "this task class historically blocks me — escalate to human earlier".

**Mitigation prerequisites**:
1. Bootstrap profile cards from D-001..D-027 + 17 mistake-log entries → ~30+ samples across categories.
2. Stop-hook auto-populate profile card per session (model × effort × task_class actual outcomes).
3. SessionStart hook surface "this task class similar to X past task; profile card says high-failure-rate, consider grilling first".

---

<a name="phần-5"></a>
## Phần 5 — Deep Root Causes (Synthesized)

### DRC-1. Continuous obligations vs deliverable matrix mindset gap

**Manifestations**:
- M-S35-4 four loops dead 15 sessions
- L-S43b-7 lesson-synthesis dormancy 9 sessions
- M-S13-pre-2 + currently project.md stale 5 days
- patterns-discovered Day-1 only
- profile-template never populated
- learning-data/loop 1 iteration ever
- 4 Q&A pending stale 4-7 days

**Why**: Master-plan defines deliverable matrix per session. Continuous obligations are spec'd but not in the matrix → agents focus on "what's in scope this turn", continuous duties slip.

**Cure**: 
- Codify continuous obligations as **Stop-hook checklist** (mechanical), not session-end ritual (LLM judgment).
- Each continuous-loop artifact owns a Stop-hook watchdog with HARD-BLOCK if dormant >N days.
- Anti-pattern: "implicit-from-spec ≠ enforced-as-ritual". If a spec mentions a loop, the loop needs a watchdog.

### DRC-2. LLM vocabulary game outpaces hook regex

**Manifestations**:
- Self-pause family 4 recurrences after 2 hook-extends
- D2-SELF-ATTEST 217+55+38 hits/day (regex catches one form; LLM finds another)
- M-S35-1 confabulated drift report (regex doesn't bound LLM negative-assertion phrasing)

**Why**: Mechanical regex enforcement assumes phrasing space is finite/predictable. LLM cognition is generative → infinite phrasing space. Each regex extension = local fix only.

**Cure**:
- Tier-3 escalation when same family recur ≥3 times: hook → skill → charter.
- **Skill-tier**: semantic check using LLM (subagent dispatch) — not regex. Costs more but covers infinite phrasing.
- **Charter-tier**: prompt-level rule loaded at every turn. CLAUDE.md hard rule already shows this works (NO LLM math has 0 production violations).

### DRC-3. Telemetry instrumentation broken at JOIN layer

**Manifestations**:
- dispatch.jsonl 60/88 events `unknown-agent` post-launch
- `tokens_used=null` always
- component-telemetry `failure_mode=null` 4998/5000
- 8/12 drift signals dead
- sync-tracker sample_count 1-5/category

**Why**: Substrate written first (Phase 0 Track 9), instrumentation deferred for "later population". Population work classified as continuous obligation → suffered DRC-1.

**Cure**:
- Phase B of audit (T2.1-T2.5) — fix JOIN keys, populate failure_mode, capture subagent tokens, audit drift signals coverage, reactivate sync-tracker.
- This is **NON-NEGOTIABLE prerequisite** to raising autonomy confidence.

### DRC-4. Self-knowledge artifacts are shells without data

**Manifestations**:
- profile-template 0 populated cards
- capability-map sample_count thin
- try-n-approaches 1 experiment ever
- decompose-work references unexercised

**Why**: Self-knowledge requires **continuous data write** across many sessions. DRC-1 (continuous-loop dormancy) blocks data accumulation.

**Cure**:
- Bootstrap from historical record (27 ADRs + 17 mistakes + 49 sessions) — cheap one-shot ETL.
- Stop-hook auto-write profile card per (model, effort, task_class) per session.
- This unblocks autonomy because LLM can self-route based on hit rate.

### DRC-5. Misfire risk on rule-cascade-induced urgency

**Manifestations**:
- M-S45-1 sandwich-architect destroyed agent-notes (Rule 4b just-ratified urgency)
- S46 dual-dispatch waste (~150K tokens)
- S7 blanket continue-injector gate (broke /clear UX)
- D-013 promotion-cycle regex inflate

**Why**: New rule shipping creates compliance pressure → agent rushes to demonstrate compliance → tool-choice/scope errors.

**Cure**:
- Doctrine: "First-execution of a just-ratified rule must include verification step BEFORE compliance action".
- Post-mortem ritual: capture "fix-made-it-worse" pattern explicitly per incident.
- Differential test smoke before shipping any rule that mandates a tool action.

---

<a name="phần-6"></a>
## Phần 6 — Systematic Improvement Framework

### F1. For Phase 3+ of StockForge (immediate)

**Tier 1 — Foundation repair (must do before raising autonomy)**:
1. Wire 2 charter-prescribed orphan hooks (`vendor-api-probe.sh` SessionStart + `tier1-bloat-check.sh` Stop).
2. Fix dispatch.jsonl JOIN + populate failure_mode + capture subagent tokens.
3. Bootstrap profile cards + capability-map samples from D-001..D-027 + 17 M-* entries.
4. Charter promote self-pause Mode-E rule (autonomous-protocol Rule N+1).
5. Manifest regenerate from FS scan; ratify.

**Tier 2 — Continuous-loop ritual codification**:
6. CLAUDE.md § Session End checklist add explicit steps:
   - "Update mistake-log if any failure / drift / user-correction happened"
   - "Update project.md if architectural decision OR phase boundary OR Recent ADRs older than newest decision"
   - "Trigger promote-rule subagent if ≥3 lesson candidates batched OR ≥10 sessions since last promotion"
   - "Update profile-template card for active (model, effort, task_class)"
7. Stop-hook watchdog for each continuous-loop artifact (mechanical not ritual).

**Tier 3 — Q&A escalation upgrade**:
8. Hook `qa-stale-urgent-escalator.sh` Stop — Q&A pending >48h → emit URGENT.
9. Notification channel (Telegram bot or Windows toast) for URGENT events.
10. Charter rule: agent SHALL propose pending blockers as Q&A before next phase-boundary.

### F2. For future projects (portability)

**Prerequisites for `/attach` to produce a viable harness**:

| Prerequisite | Status | Action needed |
|---|---|---|
| Manifest V1 invariant (every artifact tagged) | VIOLATED 35 untagged | Regenerate manifest |
| `/attach` smoke test against fresh dir | NEVER RUN | Test post-regen |
| General-harness CLAUDE.md template (strip biz invariants) | NOT AUTHORED | Author 1-page template |
| Constitution layer is project-agnostic | MOSTLY ✓ (some VN-specific in invariants.md) | Split VN-specific into invariants-stockforge.md |
| Sandwich pattern documented | ✓ via D-002 + agents | None |
| 14 commands all generic | ✓ | None |
| Hook portability (POSIX bash, no Windows specifics) | ✓ via L-S11-1 + bash-hook-lint.sh | None |
| Memory + decisions schemas portable | ✓ (12-field ADR schema generic) | None |
| Self-knowledge bootstrap pattern documented | NOT DOCUMENTED | Document profile-card bootstrap procedure |

### F3. Confidence to dare run autonomous on new project

**Hierarchy of readiness**:

```
Level 0 — Don't run autonomous (current state ~3/10)
  Symptoms: telemetry broken at JOIN, sample_count thin, self-pause recurring,
            manifest stale, charter-prescribed hooks orphan
  
Level 1 — Run autonomous with frequent human checkpoint (~5/10)
  Pre-req: Tier 1 of F1 done (orphan hooks wired, telemetry JOIN fixed)
  Check-in cadence: every 5 sessions
  
Level 2 — Run autonomous with phase-boundary checkpoint (~7/10)
  Pre-req: Tier 1+2 of F1 done (continuous-loop ritual codified)
  Check-in cadence: at every phase entry/exit
  
Level 3 — Trust full autonomous on similar-shape project (~9/10)
  Pre-req: Tier 1+2+3 of F1 done + 30+ session run with ≤1 catastrophic
  Check-in cadence: monthly review of self-awareness rollups
```

**Stockforge currently sits at Level 0 → 1 boundary**. Phase 3 is opportunity to validate Level 1.

### F4. Metrics to track autonomy-readiness

| Metric | Target Level 1 | Target Level 2 | Target Level 3 |
|---|---|---|---|
| Catastrophic incidents/10 sessions | ≤2 | ≤1 | ≤0.5 |
| Self-pause family recurrence | 0 sau hook-extension | 0 sau charter promote | sustained 0 |
| dispatch.jsonl JOIN integrity | ≥80% rows JOIN-able | ≥95% | 100% |
| component-telemetry failure_mode populated | ≥30% non-null | ≥70% | ≥90% |
| sync-tracker sample_count/category | ≥20 (statistical floor) | ≥50 | ≥100 |
| profile-template populated cards | ≥10 | ≥30 | ≥60 |
| Manifest V1 invariant | 0 untagged | sustained | sustained |
| Continuous-loop dormancy events | ≤1/month | 0 | 0 |
| Q&A pending stale rate | ≤2 bundles >48h | ≤1 | 0 |

### F5. Re-runnable improvement loop (Karpathy outer-loop applied to harness)

```
WEEKLY (auto Stop-hook trigger):
  1. Drift-rollup aggregate (existing daily) + count signal hits
  2. mistake-log delta (any new M-* entry?)
  3. promote-rule subagent dispatch (cluster lesson candidates by similarity)
  4. profile-template card population audit (any session run without card?)
  5. Q&A queue stale audit (any bundle >48h?)
  6. Manifest V1 audit (any new artifact untagged?)
  7. Sync-tracker sample audit (categories falling behind?)
  
MONTHLY (manual + auto):
  1. Autonomy metric snapshot (F4)
  2. Capability-map review (any task_class showing high-failure pattern?)
  3. Charter promote queue review (any rule recurred ≥3 times?)
  4. Portability smoke test (`/attach` against test dir)
  5. Self-awareness profile review (model × effort × task_class distribution)
  
PHASE-BOUNDARY:
  1. Manifest regenerate
  2. Bootstrap profile cards from new sessions
  3. Recalibrate session-budgets envelope per D-025 lesson
  4. Phase retrospective (post-mortems/_template.md)
```

---

<a name="phần-7"></a>
## Phần 7 — Confidence Threshold Để Dare Run Autonomous

### Tự đánh giá hiện tại: ~3/10

**Tại sao thấp**:
- Telemetry instrumentation broken at JOIN — không thể measure agent performance reliably.
- Self-pause family Pattern B 4 recurrences — autonomy core failing.
- 4 Q&A pending stale 4-7 days — escalation broken.
- Manifest V1 violation 35 untagged — portability promise broken.
- 5 catastrophic incidents trong ~7 ngày = ~0.7 incident/day = ~5/week — quá nhiều cho dự án sản xuất.

**Tại sao không thấp hơn**:
- 27 ADRs ratified clean trong 7 ngày = decision velocity strong.
- 0 charter invariant violations trong production code = quality discipline strong.
- 5 catastrophic incidents → 5 same-turn recoveries với mechanical fix = recovery cadence strong.
- Sandwich pattern proven — S41-S42-S43 + S46 + S47 shipped clean.
- 8 user_prompts goal coverage 10 nhóm = alignment foundation strong.

### Sau Phase A+B+C của audit (~14h work): ~7/10

**Pre-conditions đạt được**:
- Telemetry JOIN fixed → can measure agent performance.
- 2 charter-prescribed orphan hooks wired → mech enforcement complete.
- Self-pause Mode-E charter promoted → vocabulary game stops at prompt-level.
- Manifest regenerated → portability viable.
- Q&A escalation upgraded → human attention surfaces URGENT.

**Pending**:
- Sample count for sync-tracker still thin (need 30+/category before threshold gating works).
- Profile cards bootstrapped but unproven over new sessions.
- Karpathy outer-loop ran 1 iteration only — needs ≥3 to validate cycle.

### Sau full Phase A+B+C+D + 10 sessions stable: ~9/10

**Pre-conditions đạt được**:
- All audit recommendations shipped.
- Sample count statistical floor met.
- Profile cards populated 30+.
- Karpathy loop run ≥3 iterations.
- Catastrophic incident rate <1/10 sessions.

**Còn risk**:
- New project domain may surface novel failure patterns.
- Model upgrade (Opus 4.7 → 5.0) may shift cognitive patterns.
- → Always retain `/effort` low → high gradient + human checkpoint at phase boundaries.

### Khi nào dare áp dụng cho dự án mới?

**Quy tắc đề xuất**:
1. Spend 1 ngày chạy `/attach` portability smoke test → confirm 100% artifacts copy.
2. Run 5 sessions trên dự án mới với Level 1 cadence (every 5 session human review).
3. Nếu metric F4 hold steady → graduate Level 2.
4. Sau 20 sessions Level 2 ổn → graduate Level 3 (full autonomous).

**Thành công case**: stockforge sẽ là exemplar; những phase Phase 3+ chính là testing-ground cho framework. Nếu Phase 3 ship clean với metric F4 ≤ Level 2 target → confident apply Level 1 mới project.

---

<a name="phần-8"></a>
## Phần 8 — Prioritized Action Plan

### Priority 1 — Foundation (4-6h work)
- [ ] **P1.1**: Wire `vendor-api-probe.sh` SessionStart hook (`.claude/settings.json` edit).
- [ ] **P1.2**: Wire `tier1-bloat-check.sh` Stop hook.
- [ ] **P1.3**: Update project.md to reflect Phase 2 COMPLETE + Phase 3 IN PROGRESS state (currently 5 days stale).
- [ ] **P1.4**: Move 4 stale Q&A bundles in `human-workspace/q-and-a/pending/` per contract revision.
- [ ] **P1.5**: Manifest regenerate from FS scan (V1 invariant restore).

### Priority 2 — Telemetry repair (6-8h work)
- [ ] **P2.1**: Fix dispatch.jsonl JOIN keys (PreToolUse capture tool_use_id, agent_type).
- [ ] **P2.2**: SubagentStop capture tokens_real + duration_ms + failure_mode from transcript JSON sidecar.
- [ ] **P2.3**: PostToolUse failure_mode classification (regex over tool_result_text).
- [ ] **P2.4**: Audit drift-signals.md DR1-DR12 vs `drift-signals-D1-D9.sh` implementation; retire dead OR fix detector.
- [ ] **P2.5**: Promote `sync-tracker-update.sh` from orphan to wired Stop hook.

### Priority 3 — Continuous-loop ritual (4-6h work)
- [ ] **P3.1**: Stop-hook checklist linter — verify session log mentions mistake-log update OR explicit "no mistakes".
- [ ] **P3.2**: Stop-hook project.md staleness check (mtime delta vs newest ADR).
- [ ] **P3.3**: Stop-hook profile-template auto-populate per (model, effort, task_class).
- [ ] **P3.4**: CLAUDE.md § Session End checklist add 4 explicit steps.

### Priority 4 — Self-pause Tier-3 escalation (2-3h work)
- [ ] **P4.1**: Charter rule in autonomous-protocol.md Rule N+1: "Trong autonomous_mode=true, agent SHALL NOT emit any phrase that defers to human selection between options".
- [ ] **P4.2**: D-NNN ADR ratify above charter promotion via deny-lift mechanism.
- [ ] **P4.3**: Optional skill `autonomous-defection-detector` — semantic check via subagent if hook regex misses again.

### Priority 5 — Self-knowledge bootstrap (4-6h work)
- [ ] **P5.1**: ETL D-001..D-027 + 17 M-* entries → profile cards (model × effort × task_class).
- [ ] **P5.2**: Sync-tracker sample bootstrap to ≥30/category from historical decisions.
- [ ] **P5.3**: Capability-map populate from same source.

### Priority 6 — Q&A escalation upgrade (3-4h work)
- [ ] **P6.1**: Hook `qa-stale-urgent-escalator.sh` Stop — Q&A >48h → URGENT.
- [ ] **P6.2**: Notification channel (Telegram bot or Windows toast).
- [ ] **P6.3**: Q&A lifecycle contract revision (allow agent move pending→answered with detection signal).

### Priority 7 — Portability validation (3-4h work)
- [ ] **P7.1**: Author general-harness CLAUDE.md template (strip stockforge invariants).
- [ ] **P7.2**: Split invariants.md → general + invariants-stockforge.md (VN-specific).
- [ ] **P7.3**: Run `/attach` smoke test against fresh test directory.
- [ ] **P7.4**: Document portability checklist + bootstrap procedure.

### Priority 8 — Karpathy outer-loop revival (4-6h work)
- [ ] **P8.1**: Weekly Stop-hook trigger for outer-loop iteration (per F5).
- [ ] **P8.2**: try-n-approaches skill exercise with current open question (e.g., self-pause Mode-E charter wording).
- [ ] **P8.3**: Capture experiment frame + outcome metric.

### Priority 9 — Misfire risk mitigation (2-3h work)
- [ ] **P9.1**: Doctrine "verify-before-compliance on just-ratified rule" — add to decision-discipline.md.
- [ ] **P9.2**: Post-mortem ritual capture "fix-made-it-worse" pattern explicitly.
- [ ] **P9.3**: Differential test smoke template for any new tool-mandating rule.

---

## Tổng kết — Câu trả lời ngắn cho user

> "Tỉ lệ sai như hiện tại là quá nhiều, không đủ tôi tự tin chạy autonomous cho các dự án khác được."

**Đúng — và lý do là 3 deep root causes phối hợp**:

1. **DRC-1 Continuous obligations vs deliverable matrix mindset gap** — LLM treat continuous loops (mistake-log, promotion, project.md, profile cards) như "shipped once". Codify thành Stop-hook watchdogs, không rely vào session-end ritual.

2. **DRC-2 LLM vocabulary game vượt regex** — Self-pause family 4 recurrences chứng tỏ mechanical regex không bound được LLM phrasing. Cần Tier-3 (charter prompt-level rule).

3. **DRC-3 Telemetry instrumentation broken at JOIN layer** — substrate có nhưng JOIN keys mismatch + failure_mode dead → "đo để self-upgrade" mất nền. Đây là blocker chính.

**~75% drift là tractable bằng harness-engineering** (ritual codification + semantic-tier enforcement + telemetry repair). Không phụ thuộc model upgrade.

**Sau Phase A+B+C của audit (~14h work) confidence raise từ ~3/10 lên ~7/10**. Sau full implementation + 10 sessions stable: ~9/10.

**Câu hỏi user raise 9 hypothesis verdict**:
- Tracking quá nhiều? → **NO**, ngược lại — instrumentation broken.
- Human stale can thiệp? → **NO**, intervention rare-but-impactful.
- LLM weaknesses? → **YES**, ~50% các ca pure cognitive.
- Hệ thống chưa hoàn thiện? → **YES**, core driver.
- Hook/script thiếu? → **YES**, 11 orphan + 8/12 drift signals dead.

**Sub-questions**:
- LLM hiểu human? **MEDIUM** — hiểu cao-cấp, sai applied-doctrine.
- Human cung cấp ít? **NO** — 99 lines / 10 nhóm goal đầy đủ.
- LLM hiểu strengths/weaknesses của mình? **NO — đây là deep root cause**, profile cards chỉ shell, capability-map sample thin.

**Báo cáo này pair với audit `2026-05-05-harness-alignment-audit.md`** — audit document hiện trạng, this document explain WHY và HOW TO FIX. Hai together form playbook để raise autonomy confidence systematically.

---

**Authored**: 2026-05-05 S48-extension out-of-band
**Companion**: `agent-workspace/memory/observations/2026-05-05-harness-alignment-audit.md`
**Recommended next**: User review → pick 1-3 priorities for Phase 3 ride-along (don't block IMPL momentum).
