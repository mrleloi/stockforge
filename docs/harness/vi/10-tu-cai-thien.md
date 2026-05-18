# Chương 10 — Tự Cải Thiện

> **Phân khu Diataxis**: Explanation
> **Thời gian đọc**: ~25 phút
> **Điều kiện tiên quyết**: Chương 7 (Bộ Nhớ), Chương 9 (Hệ Thống Chất Lượng)

Harness tự cải thiện. Đây là cái tách nó khỏi static framework. Mỗi session, hệ thống quan sát performance của chính nó, capture lessons, và graduate các lesson có giá trị nhất thành permanent enforcement.

Chương này giải thích continuous learning loop:

- Cách rules emerge từ kinh nghiệm
- Cách rules graduate (inline → skill → hook → constitution)
- Cách rules được retire
- Severity/escalation pipeline như một cơ chế self-improvement
- Karpathy outer loop

---

## 10.1 — Cải Thiện Đến Từ Đâu

Harness recognize năm source của learning:

| Source | What | Capture mechanism |
|---|---|---|
| **User correction** | User flag một mistake của agent verbatim ("không, X", "wrong, X") | `correction-rate-tracker.sh` đếm; agent ghi entry `M-S<N>-<M>` mistake-log |
| **Post-mortem** | Significant failure được investigate retrospectively | Agent ghi vào `agent-workspace/post-mortems/` |
| **Sandwich verifier finding** | Adversarial review surface defect | Verifier trả về FINDING; main session persist vào attestation-log + observation |
| **Drift signal hit** | Deterministic hook bắt violation | Hook append vào `.drift-signals.log`; `drift-rollup-daily.sh` aggregate |
| **Self-observation** | Agent nhận thấy pattern của chính nó (thường trong retrospective) | Agent ghi vào `agent-notes.md` |

Cả năm funnel vào `agent-notes.md` (rules) và `mistake-log.md` (failures). Hai file này là *raw material* của self-improvement.

---

## 10.2 — Promotion Lifecycle

Một learned rule bắt đầu là một inline entry `agent-notes.md`. Nó có thể ở đó mãi mãi (low value, narrow context), hoặc có thể graduate qua ba tier của enforcement.

```
┌──────────────────────────────────────────────────────────────┐
│ TIER 0 — INLINE                                              │
│ Lives in agent-notes.md as a digest entry.                   │
│ Read at session-start (Tier 2 memory).                       │
│ Enforcement: agent self-discipline.                          │
│ Catch-rate: depends on agent attention.                      │
└──────────────────────────────────────────────────────────────┘
                              ↓ promote
┌──────────────────────────────────────────────────────────────┐
│ TIER 1 — SKILL                                               │
│ Codified as a .claude/skills/<name>/SKILL.md procedure.      │
│ Auto-discovered when context matches description.            │
│ Enforcement: LLM-mediated; consistent across sessions.       │
│ Catch-rate: depends on description-discovery match.          │
└──────────────────────────────────────────────────────────────┘
                              ↓ promote
┌──────────────────────────────────────────────────────────────┐
│ TIER 2 — HOOK                                                │
│ Codified as a scripts/hooks/<name>.sh deterministic check.   │
│ Fires on event (SessionStart / Stop / PreToolUse / etc.).    │
│ Enforcement: mechanical; can block (RC=2) or warn.           │
│ Catch-rate: 100% within scope; bounded by event triggers.    │
└──────────────────────────────────────────────────────────────┘
                              ↓ promote
┌──────────────────────────────────────────────────────────────┐
│ TIER 3 — CONSTITUTION                                        │
│ Codified as a rule in agent-workspace/constitution/<file>.md │
│ Immutable; amendments require ratification + cool-down.      │
│ Enforcement: foundational; all lower tiers respect.          │
│ Catch-rate: 100% (principle level).                          │
└──────────────────────────────────────────────────────────────┘
```

### Promotion Triggers

Khi nào một rule graduate? Per [doctrine AP-23 `agent-notes.md`](12-noi-tai.md#ap-23) và skill `promote-rule`:

**Tier 0 → Tier 1 (Skill)**:
- Cùng một quy trình xuất hiện trong 3+ session
- Manual application reliable nhưng tedious
- LLM judgment required (không đủ deterministic cho hook)

**Tier 1 → Tier 2 (Hook)**:
- Rule có thể phát hiện tĩnh (regex / grep / file-existence)
- Manual hoặc skill-mediated application bắt < hook would
- 2nd-instance threshold met (AP-23: promote on 2nd, not 1st, instance trừ khi cluster pattern)

**Tier 2 → Tier 3 (Constitution)**:
- Rule nâng lên invariant (không có contextual exception)
- Nhiều hook sẽ duplicate nó
- Ảnh hưởng nguyên tắc cốt lõi (charter, BC isolation, financial-data integrity)

### Doctrine AP-23

Per `agent-notes.md`:

> "1st-instance HOLD-FOR-PROMOTION; promote on 2nd. Refinement-of-rule (lesson-about-lesson) is AP-23 RED FLAG: 2nd instance mandates promote-or-retire (not inline accumulation)."

Diễn giải: không promote một rule trên first appearance của nó — nó có thể là one-off. Nhưng nếu nó xuất hiện hai lần, nó là một pattern, và inline accumulation trở thành anti-pattern (AP-23). Tại điểm đó, hoặc promote hoặc retire.

### Cluster-Based Promotion

Cái trên là cho individual rule instances. **Cluster patterns** có thể promote sớm hơn:

> "Cluster count n=4 > threshold n=3 → PROMOTE-NOW (per L-S345-1 honesty-promotion-at-n=3 doctrine)."

Khi 4+ rules share một class (ví dụ, main-session pre-dispatch self-discipline cluster của L-S360-1 + L-S360-2 + L-S365-1 + L-S327-1), tất cả promote together như một single hook covering shared pattern.

---

## 10.3 — Skill `promote-rule`

Cơ chế cho promotion. Sống tại [`.claude/skills/promote-rule/SKILL.md`](../../../.claude/skills/promote-rule/SKILL.md).

### Khi Nó Kích Hoạt

- Periodic: mỗi 5+ session, hoặc
- Forced: `promotion-cycle-trigger.sh` HARD-BLOCK tại SessionStart khi ≥8 lessons mới tích lũy kể từ last `promote-rule` dispatch

Hard-block buộc next session dispatch `promote-rule` trước bất kỳ công việc nào khác.

### Cái Nó Làm

1. Đọc `agent-notes.md` digest entries kể từ last cycle
2. Cluster entries theo **Jaccard similarity** của rule body + context
3. Xác định promotion candidates (clusters với similar root cause)
4. Ghi `observations/promotion-proposals-<TS>.md` list candidates
5. Cho mỗi candidate:
   - Đặt tên cluster
   - Đề xuất promotion target (HOOK / SKILL / CHARTER)
   - Draft artifact (hook script / skill body / constitution amendment)
   - Cite companion firing-test plan nếu HOOK
6. Next session đọc proposals; main session ratify qua AskUserQuestion bundle

### Output Schema

```markdown
## Cluster: <name>

**Instances** (n=4):
- L-S360-1 (2026-05-17): pre-stop fresh-dispatch check
- L-S360-2 (2026-05-17): pre-dispatch budget-honesty check
- L-S365-1 (2026-05-17): orthogonal-knob distinction
- L-S327-1 (2026-05-16): master-ledger COMPLETED weak signal

**Shared pattern**: main-session shortcut applied to dispatch/commit boundary
without empirical cross-check against actual config/completion-signal.

**Proposed promotion**: NEW deterministic hook
`scripts/hooks/main-session-pre-dispatch-discipline.sh` (Stop chain, after
lesson-synthesis-watchdog, before harness-recovery-dod-watchdog).
4 checks share `.transcript-jsonl` parse cost → one hook, four checks,
~150 LOC + companion firing-test ~80 LOC.

**Tier**: 2 (HOOK)
**Promotion candidate**: L-S365+-CLUSTER-1
**Confidence**: 0.85 (above ARCH-tier 0.80 threshold; self-decide eligible)
```

---

## 10.4 — Subagent `lesson-synthesizer`

Stage 2 của self-upgrade loop. Sống tại [`.claude/agents/lesson-synthesizer.md`](../../../.claude/agents/lesson-synthesizer.md).

### Khi Nó Kích Hoạt

- Triggered bởi `lesson-synthesis-watchdog.sh` ALERT (Stop hook)
- Watchdog ALERT khi:
  - Session diff show ≥3 substantive changes
  - Không entry `agent-notes.md` mới được record session này
  - Không "no mistakes this session" attestation present

Watchdog hỏi: "session này thay đổi substantively nhưng record không lesson — đúng không?"

### Cái Nó Làm

Fresh-context dispatch. Đọc:
- Recent session log + observations
- `agent-notes.md` last 200 LOC
- `mistake-log.md` last 100 LOC
- Best-practices catalog (`memory/self-awareness/best-practices.md`)
- Known-issues catalog (`memory/self-awareness/known-issues.md`)

Identify:
- Patterns mới trong work của session này
- Issues mới đã trở thành known
- Best practices mới emerge

Produces (≥1 entry):
- Một entry digest `agent-notes.md` mới (rule)
- Một entry known-issue (KI) mới
- Một entry best-practice (BP) mới

Mỗi entry tag với provenance (session diff line refs, observation file refs).

### Tại Sao Nó Tồn Tại

Không `lesson-synthesizer`, lesson capture relies trên main session attend nó tại session-end. Empirically, điều này fail ~30% thời gian (sessions close không capture lessons sẽ được capture bởi retrospective glance). Watchdog + synthesizer là deterministic answer.

---

## 10.5 — Convention Đặt Tên Lesson

Lessons có IDs:

```
L-S<N>-<M>
```

Trong đó:
- `S<N>` = session ID nơi lesson được author
- `<M>` = sequential trong session đó (1, 2, 3...)

Examples:
- `L-S360-1` — lesson đầu tiên author trong S360
- `L-S360-2` — lesson thứ hai trong S360
- `L-S365+-1` — cluster lesson touch sessions S360-S365

### Cross-Reference

Lesson IDs xuất hiện extensively trong:
- Hook header comments (`# L-S176-1` cited)
- Skill descriptions (description reference lesson)
- Constitution rule rationale
- ADR `intent_classification` field

Điều này tạo **provenance graph**: mỗi rule trace ngược về originating lesson của nó, mà trace ngược về originating session/post-mortem/correction.

---

## 10.6 — Demotion + Retirement

Không phải mọi promoted rule đều xứng đáng sống mãi mãi. Per [Ritual Demotion Doctrine](#10-7--ritual-demotion):

> "Per-session rituals (audit / re-scan / refresh) MUST track catch-rate. Catch-rate = 0 over 3+ consecutive sessions ⇒ promote-to-hook OR demote-to-passive OR retire."

### Demotion Paths

| From → To | Trigger | Mechanism |
|---|---|---|
| HOOK → SKILL | Hook fire nhưng findings consistently low-value | Move logic sang skill; unwire hook |
| SKILL → INLINE | Skill rarely triggers; description không match contexts | Move sang inline `agent-notes.md` digest |
| HOOK → RETIRED | Hook catch-rate = 0 qua 3+ sessions | Delete script + firing-test; archive |
| CONSTITUTION → DEPRECATED | Rule không còn áp dụng (ví dụ, underlying tech changed) | Mark `status: DEPRECATED-BY-D-NNN`; không bao giờ delete |

### Concrete Retirement Examples

Từ `agent-notes.md`:

> **RETIRED-1ST-INSTANCE-DUPLICATE-OF-CHARTER: L-S385-3**
> Context: plan-039 § C candidate 3 — "INCOMPLETE-corpus dogfood = calibrated honesty signal per Charter Principle 6"
> Rule (RETIRED): Promote INCOMPLETE-corpus framing as a template language.
> RETIRE rationale: Charter Principle 6 (Adversarial by default) ALREADY mandates this framing. Promoting to template would just paraphrase existing charter text = inline accumulation per AP-23 RED FLAG.

> **RETIRED-SPECULATIVE-ABSTRACTION: L-S371-1**
> Rule (RETIRED): Factor out common resolver Protocol from VnTickerResolver for reuse.
> RETIRE rationale: Only ONE resolver exists. Sector + persona resolvers are future hypothetical. Creating empty Protocol with one implementation = speculative abstraction per Karpathy P2 "no abstractions for single-use code".

Retirements được documented trong `agent-notes.md` với `## RETIRED-<reason>:` headers. Điều này preserve *tại sao* của retirement.

---

## 10.7 — Ritual Demotion (S99 RCA Layer 5)

Một case cụ thể của demotion: per-session rituals (audits, scans, refresh patterns) chịu **catch-rate accountability**.

### Rule

Per CLAUDE.md § Hard Rules:

> "Ritual demotion (per S99 RCA Layer 5; Q-RCA-5 + Q-RCA-7 = A): per-session rituals (audit / re-scan / refresh) MUST track catch-rate. Catch-rate = 0 over 3+ consecutive sessions ⇒ promote-to-hook OR demote-to-passive OR retire. Refinement-of-rule (lesson-about-lesson) is AP-23 RED FLAG: 2nd instance mandates promote-or-retire (not inline accumulation)."

### Concrete Demotion: L-S310-1 Ritual Demotion

Một example thực. Ritual `sync-grilling-call.sh` kích hoạt trên 3-session cadence. Qua 40 sessions (S270-S309), nó kích hoạt 18 lần với catch-rate 0/18. `ROUTINE-IDLE close ritual` kích hoạt 24 lần với catch-rate 0/24.

Cả hai rituals vượt 3-session threshold 8× và 6×.

User surface gap: "0% product work qua 40 sessions; sync-grilling burning tokens với no value."

L-S310-1 là resulting demotion proposal (BINDING sau user directive):

> "DO NOT invoke `scripts/hooks/sync-grilling-call.sh` on 3-session cadence. Authorized triggers only: (a) user ratifies a pending SCOPE+CHARTER bundle producing NEW divergence; (b) charter ratification opens NEW SCOPE-tier signals; (c) Phase boundary entry; (d) user submits NEW user_prompt with SCOPE-tier directive."
>
> "DO NOT write ROUTINE-IDLE close artifacts when entry delta-check returns ZERO new actionable signal AND no PRIORITY became unblocked. Instead emit one-line state ack."

Ritual không bị delete — nó được **gated** để chỉ kích hoạt trên event-driven triggers, không trên time-cadence.

### Tại Sao Demote, Không Phải Luôn Promote-or-Retire

Đôi khi câu trả lời đúng là *demote*: ritual có value trong một số contexts nhưng không phải tất cả. Gating nó cho event triggers preserve value trong khi loại bỏ busy-work.

---

## 10.8 — Severity Pipeline như Self-Improvement

Severity pipeline (Phase A: classifier → Phase B: engine → Phase C: enforcer → Phase D: push) detailed trong [Chương 6 § 6.6](06-hooks.md#66--the-severity-pipeline). Nhưng nó cũng là một **cơ chế self-improvement**:

- **HIGH** severity items get user attention qua `AskUserQuestion`. User's response là *signal* về cái gì matters.
- **MEDIUM** severity items tích lũy trong weekly digests. Digest reveal patterns over time.
- **Severity dwell-time** (bao lâu một item stay HIGH trước khi resolution) tự nó là một metric.

Per L-S310-1 root cause: Q-INT mega-bundle (một bundle 22-question) ngồi với `askuserquestion_fired: false` cho ~20 hours trong khi loop chạy busy-work. Severity pipeline chưa tồn tại lúc đó — absence của nó enable failure mode.

Sau D-058 / S310 ratification, pipeline đảm bảo HIGH-severity items get escalated trong 6 hours và Telegram-pushed cho visibility ngoài terminal.

### Telegram Push (Phase D)

Setup:
1. Tạo bot qua @BotFather → get token
2. Extract chat_id qua getUpdates
3. Set env vars trong `.claude/settings.local.json`:
   ```
   STOCKFORGE_TELEGRAM_BOT_TOKEN=<token>
   STOCKFORGE_TELEGRAM_CHAT_ID=<id>
   ```
4. Test: `bash scripts/hooks/telegram-push.sh "CRITICAL test"`

Không creds → silent no-op. Idempotency: SHA-keyed per-hour marker ngăn spam.

---

## 10.9 — Karpathy Outer Loop

Overall self-improvement của harness được structure như một Karpathy autoresearch outer loop:

```
┌──────────────────────────────────────────────────────────────┐
│ INNER LOOP — per session                                     │
│ - Read state                                                 │
│ - Apply rules (constitution, agent-notes, skills)            │
│ - Execute work                                               │
│ - Capture outcome (telemetry, observations, lessons)         │
└──────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────┐
│ MIDDLE LOOP — per N sessions                                 │
│ - promote-rule cycle: cluster + promote candidates           │
│ - lesson-synthesizer: capture missed lessons                 │
│ - Verifier patterns: PCG-* promotion candidates              │
└──────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────┐
│ OUTER LOOP — per phase boundary                              │
│ - intent-vs-impl-diff: catch silent absorption                │
│ - Phase close ritual: archive, consolidate                   │
│ - Constitution amendments: charter-tier ratifications         │
│ - Calibration weight adjustments (sync-tracker weights.yaml) │
└──────────────────────────────────────────────────────────────┘
```

### Per Karpathy

Framing đến từ Andrej Karpathy [autoresearch](https://karpathy.ai/) talks. Insight then chốt: **LLMs cực kỳ giỏi looping cho đến khi đạt specific goals**. Outer-loop infrastructure (metric, evaluation, ablation) là cái enable điều này.

Harness áp dụng điều này cho chính nó:
- Inner loop = session
- Middle loop = `promote-rule` cycle
- Outer loop = phase boundary + constitution amendments

Skill `try-n-approaches` ([Chương 5 § 5.2](05-skills-commands-agents.md#52--skills)) frame mọi investigation mới như một Karpathy outer-loop experiment với metric function (BLOCKING per L-S12-1).

---

## 10.10 — Catalog Best-Practices và Known-Issues

Hai append-mostly registry bổ sung cho `agent-notes.md`:

### `best-practices.md` (BP-*)

Positive patterns đã confirm hoạt động. Format:

```markdown
### BP-S<N>-<M>: <name>
**Date**: YYYY-MM-DD
**Context**: <when this BP applies>
**Practice**: <the positive pattern>
**Evidence**: <which sessions confirmed value>
**Severity-of-not-doing**: critical | high | medium | low
**Related**: [[L-S<N>-<M>]] (lesson that promoted to BP)
```

### `known-issues.md` (KI-*)

Quirks / limitations mà harness phải tolerate. Format:

```markdown
### KI-S<N>-<M>: <name>
**Date**: YYYY-MM-DD
**Context**: <where this surfaces>
**Issue**: <the quirk>
**Workaround**: <how the harness compensates>
**Upstream fix expected**: <when, if known>
**Suppression severity**: <where suppressed; typically HIGH→MEDIUM>
**Related**: [[D-NNN]] (ADR that ratified workaround)
```

Example KI: `KI-S49b-1 — Stop hook silent on Windows quirk` (downgrade HH-1 HIGH→MEDIUM).

### Catalog Lifecycle

- Captured bởi `lesson-synthesizer` (Stage 2 của self-upgrade)
- Aggregated bởi `self-awareness-aggregate.sh` (Stop hook)
- Đọc bởi main session tại SessionStart cho context

---

## 10.11 — Một Promotion Thực: L-S310-2 (Severity Pipeline)

Một example canonical của full lifecycle.

### Origin (1st instance — bình thường sẽ HOLD)

User-surfaced harness gap S310. 7 issues identified:
1. Fragmented severity schemas qua Q&A / decision / mistake / notification
2. Không cơ chế BLOCK
3. 48h-only stale escalation
4. Không proactive AskUserQuestion auto-fire
5. Không external channel
6. Orphan notification accumulation
7. Fragmented watchdog hooks không có central severity router

### Cluster recognition

Đây là **7 instances của một class**: harness thiếu unified severity classification + escalation pipeline. Cluster count n=7 > threshold n=3 → PROMOTE-NOW per L-S345-1 doctrine.

### Ratification qua AskUserQuestion (S310 4-Q batch)

- Q1: 4-level schema (CRITICAL/HIGH/MEDIUM/LOW) — A=ACCEPT
- Q2: cả UserPromptSubmit + PreToolUse block aggression — A=ACCEPT
- Q3: 6h HIGH escalation threshold — A=ACCEPT
- Q4: Telegram skeleton-first — A=ACCEPT

### Implementation (ratification → shipped trong cùng turn)

Per L-S310-2:

- `severity-classifier.sh` (Stop late-chain) — Phase A
- `escalation-engine.sh` (Stop + SessionStart + UserPromptSubmit) — Phase B
- `autonomous-block-enforcer.sh` (UserPromptSubmit FIRST + PreToolUse FIRST) — Phase C
- `telegram-push.sh` (skeleton) — Phase D
- 4 companion firing-tests; 26/26 PASS
- D-058 ADR ratified

### Verification (live run)

Live run detected 3 legitimate HIGH items (D-034 charter v1.1 170h / mistake-log carryover / D-053 notification 18h) + 0 CRITICAL. `urgent.md` auto-populated.

### Tại Sao Nó Hoạt Động

Cluster 7-instance biện minh n=3 threshold-skip. 4-question AskUserQuestion bundle cho human 4 distinct decisions với low cognitive load. Shipped pipeline đến cùng firing-tests (Principle 11). Live run produce empirical evidence trong vòng hours.

Đây là canonical promotion: từ user-surfaced gap đến ratified + shipped + verified pipeline trong một single session.

---

## 10.12 — Đọc Tiếp Ở Đâu

- **Cookbook để thêm** một rule / skill / hook mới → [Chương 11 — Cookbook](11-cong-thuc.md)
- **23 anti-patterns** đã promote lên constitution → [Chương 12 — Nội Tại](12-noi-tai.md#anti-patterns)
- **Agent-notes đầy đủ** → [`agent-workspace/memory/agent-notes.md`](../../../agent-workspace/memory/agent-notes.md)
- **Mistake-log đầy đủ** → [`agent-workspace/memory/mistake-log.md`](../../../agent-workspace/memory/mistake-log.md)
- **Calibration data** → [`agent-workspace/calibration/`](../../../agent-workspace/calibration/)
