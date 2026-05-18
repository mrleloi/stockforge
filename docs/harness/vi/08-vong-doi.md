# Chương 8 — Vòng Đời (Lifecycle)

> **Phân khu Diataxis**: Explanation + Reference
> **Thời gian đọc**: ~40 phút
> **Điều kiện tiên quyết**: Chương 3 (Kiến Trúc), Chương 5 (Skills/Commands/Agents)

Lifecycle của harness là *cấu trúc thời gian* — cách session flow, cách plan di chuyển từ authored sang executed, cách quyết định ratify, cách subagent coordinate. Chương này walk lifecycle end-to-end.

Nếu Chương 6 là cơ chế (hooks) và Chương 7 là state (memory), chương này là *quy trình* gắn kết chúng lại.

---

## 8.1 — Session Types

Per [`session-budgets.md`](../../../agent-workspace/constitution/session-budgets.md), harness recognize 8 session type. Mỗi loại có purpose, budget, và ritual riêng biệt.

| Type | Budget (Sonnet) | Budget (Opus) | Purpose |
|---|---|---|---|
| **PLAN** | 50-80K | 150-230K | Architect; produces session plan |
| **FOCUSED_IMPL** | 100-150K | 100-150K† | Dev; 1-3 tasks from plan |
| **MULTI_TASK_IMPL** | 150-250K | 200-330K | Dev; 4-10 tasks |
| **VERIFY** | 30-60K | 80-180K | Verifier; adversarial review |
| **RECOVERY** | 80-150K | 130-230K | Revert + re-plan after failure |
| **THESIS** | 60-100K | 100-180K | Multi-perspective stock analysis |
| **INGEST** | 40-80K | 80-150K | Process new data sources into KB |
| **POST_MORTEM** | 30-50K | 60-100K | Review thesis outcomes; update calibration |

† Dev trên Opus theo kinh nghiệm cho thấy actuals dưới budget (file-bounded work kháng token inflation).

### Hard Rules

- **Không bao giờ mix PLAN và IMPL trong cùng session.** (Session 4 catastrophic failure mode.)
- **THESIS sessions là read-only trên code.** Output đi vào `agent-workspace/memory/thesis-log/`.
- **Per D-004 thresholds**:
  - Wind-down: 180K (auto-prep handoff)
  - Cliff: 220K (auto-reboot qua `session-self-reboot.sh`)
  - Hard cap: 250K (mandatory split)

### Type-Selection Decision Tree

`/session-start` dùng tree này (per [`session-budgets.md`](../../../agent-workspace/constitution/session-budgets.md)):

```
No detailed plan exists?
  → PLAN
Plan exists; 1-3 small tasks?
  → FOCUSED_IMPL
Plan exists; 4-10 tasks?
  → MULTI_TASK_IMPL
Plan exists; >10 tasks?
  → recommend split
Previous session failed/broken?
  → prepend RECOVERY
Need to verify previous session output?
  → schedule VERIFY after main work
Goal is investment thesis on a stock?
  → THESIS (read-only on code)
Goal is data ingest / KOL channels?
  → INGEST
Goal is reviewing past thesis outcomes?
  → POST_MORTEM
```

---

## 8.2 — Session Protocol

Per CLAUDE.md § Session Protocol:

### Start

1. Đọc `agent-workspace/memory/current-execution.md` → resolve active track
2. Đọc `agent-workspace/memory/project.md` → project state
3. Đọc 3 file cuối trong `agent-workspace/memory/sessions/` → recent context
4. Check `agent-workspace/session-plans/pending/` cho matching brief
5. Chạy VBW protocol trước khi viết bất kỳ spec/test/code nào

### End

1. Update `agent-workspace/memory/project.md` (nếu có architectural decision)
2. Ghi `agent-workspace/memory/sessions/YYYY-MM-DD-session-N.md`
3. Update `agent-workspace/memory/current-execution.md` (status, next session)
4. Nếu learned rule emerge → append vào `agent-workspace/memory/agent-notes.md`
5. Nếu thesis logged session này → đảm bảo entry trong `agent-workspace/memory/thesis-log/`
6. Update `agent-workspace/memory/mistake-log.md` với entry `M-S<N>-<M>` mới HOẶC explicitly state "no mistakes this session" trong session log (enforced bởi `session-end-checklist-linter.sh`)
7. Nếu một NEW ADR landed session này → verify `project.md` Phase Goals Tracker vẫn match `current-execution.md` Active Focus Track Phase status (enforced bởi `phase-status-coherence.sh` UserPromptSubmit cadence + `project-md-adr-staleness.sh` Stop cadence)
8. **(auto)** Stop-hook `profile-template-auto-populate.sh` append sample row vào matching `agent-workspace/memory/self-awareness/profiles/<model>-<effort>-<task_class>.md` card
9. **(auto)** Stop-hook `promotion-cycle-trigger.sh` HARD-BLOCK tại next SessionStart nếu ≥8 lessons mới tích lũy kể từ `promote-rule` dispatch cuối — schedule một `promote-rule` subagent dispatch trong session tiếp theo nếu blocked

---

## 8.3 — Plan Lifecycle

Plans sống đời two-stage: authored (pending/) → executed (completed/).

### Master Plans vs Session Plans

| Tier | Location | Scope | Lifespan |
|---|---|---|---|
| **Master plan** | `agent-workspace/master-plans/` | Phase-level (months) | Long-lived; archived per phase |
| **Session plan** | `agent-workspace/session-plans/pending/` then `completed/` | Session-level (1-3 sessions of work) | Active while in pending; archived on completion |

### Naming Convention

```
NNN-S<authoring-session>-<slug>.md
```

Example: `045-S395-vhm-thesis.md`.

Current high water mark: **046**.

### Plan Body (Authored bởi Architect)

Một plan điển hình là 700-1100 LOC và tuân theo các section A-N. Heavy YAML frontmatter:

```yaml
---
id: <NNN>
authored_at: <ISO-8601>
authoring_session: S<N>
session_type: FOCUSED_IMPL  # what type of session executes this
estimated_duration_min: 45
estimated_budget_tokens: 130000
estimated_cost_usd: 1.50
target_substrate: code | data | both
depends_on:
  - plan-NNN: file:line citation
  - D-NNN: ADR title
binding_decisions:
  - <decision>
hard_rules_acknowledged:
  - <CLAUDE.md rule>
  - <constitution rule>
parallel_with: [D2, D3]  # if sub-tracks can parallelize
---
```

### Body Sections (Canonical A-N Structure)

```markdown
## A — Scope
[what this plan accomplishes]

## B — Out-of-Scope
[explicit non-goals; what's deferred to other plans]

## C — VBW STEP 0 (Live Verification)
[verifications the dev must perform before writing any code]

## D — Sub-Tracks (D1, D2, D3, ...)
[each sub-track with: goal, files, success criteria, LOC ceiling]

## E — Architecture Decisions
[any ADRs this plan proposes]

## F — File Scope
[exhaustive list of files to create/modify with size estimates]

## G — Coordination Rules
[parallel-eligible flags; file-collision avoidance]

## H — DoD (Definition of Done) Per Sub-Track
[per-D# acceptance criteria; per-category LOC ceilings]

## I — Risk Mitigations (RM1..RMN)
[named risks + mitigation plans]

## J — Cost Attestation
[budget vs cap reconciliation]

## K — Stop-Findings
[any unresolved issues that block; STOP-AND-ASK gates]

## L — Companion Artifacts
[firing-tests, observations, ADRs to be written]

## M — Compliance Attestation
[hard rules respected]

## N — Out-of-Plan Items
[bookkeeping notes carried forward]
```

### State Transitions

```
authored (in pending/)
  ↓ session starts to execute
in-progress (dev session active)
  ↓ dev session completes
attesting (verifier session active)
  ↓ verifier returns PASS or PASS-WITH-CONCERNS
shipped (completed/) ← mv from pending/ to completed/
  ↓ if FAIL
remediation-needed (still in pending/; defects logged)
  ↓ defects fixed
re-attesting → ... → shipped
```

`mv` từ `pending/` sang `completed/` là **canonical "done" signal**. Hooks consume signal này:
- `harness-recovery-dod-watchdog.sh` check plans stuck trong pending/ lâu hơn 5 session
- `sub-plan-completion-coherence.sh` check tính nhất quán giữa plan status và `current-execution.md` claim

---

## 8.4 — Sandwich Pattern (Choreography)

Sandwich pattern — architect → dev → verifier — là canonical workflow. Cơ chế chi tiết trong [Chương 5 § Cơ Chế Sandwich Architect](05-skills-commands-agents.md#sandwich-architect-mechanics); ở đây là choreography qua các session.

### Phase 1: Architect (PLAN session)

```
USER: /master-plan <feature>
  ↓
main session dispatches master-planner subagent
  ↓ (fresh context)
master-planner reads:
  - PROJECT_CHARTER.md
  - current-execution.md (active phase)
  - relevant constitution files
  - existing plans in pending/ and completed/
master-planner returns:
  - session-plans/pending/NNN-*.md (the master plan)
  - one observation file (dispatch artifact)
  ↓
main session reads observation, persists outcome
  ↓
USER: /session-end → SessionEnd hooks fire
  ↓
NEXT SESSION: /session-start
  ↓ /session-start reads pending/NNN-*.md → detects PLAN required for sub-tracks
  ↓
main session dispatches sandwich-architect subagent
  ↓ (fresh context, Opus 150-230K)
architect reads:
  - master plan
  - relevant code in affected BCs
  - calibration data (Phase 1b self-calibration if ≥3 sub-tracks)
architect produces:
  - sub-plan (D1..DN tasks)
  - dispatch artifact
```

### Phase 2: Dev (FOCUSED_IMPL or MULTI_TASK_IMPL session)

```
NEXT SESSION: /session-start
  ↓ reads sub-plan from pending/
  ↓ detects FOCUSED_IMPL or MULTI_TASK_IMPL type
main session dispatches sandwich-dev subagent
  ↓ (fresh context, Opus 100-330K)
dev reads:
  - sub-plan
  - relevant code (per File Scope section)
dev executes STEP 0 VBW re-verification
dev implements D1..DN per plan
dev runs:
  - mypy --strict
  - pytest
  - ruff
  - bash-hook-lint (if hooks touched)
dev writes:
  - session log with verification block
  - any new ADRs to decisions/NNN-*.md
  - mistake-log entry OR M-S<N>-NONE attestation
dev's session ends; plan stays in pending/
```

### Phase 3: Verifier (VERIFY session)

```
NEXT SESSION: /session-start
  ↓ detects pending VERIFY for the prior IMPL session
main session dispatches sandwich-verifier subagent
  ↓ (fresh context, Opus 80-180K)
  ↓ NO Write tool grant (per PCG-S401-4)
verifier reads:
  - sub-plan
  - dev session log
  - all files touched per File Scope
  - relevant tests
verifier runs V1..V12 verification grid:
  - V1 acceptance criteria check
  - V2 dev handoff notes check
  - V3 charter compliance
  - V4 architecture compliance
  - V5 regression (firing-tests + pytest + mypy/ruff re-run)
  - V6 integration smoke
  - V7..V12 per-plan-specific
verifier returns inline text:
  - verdict (PASS / PASS-WITH-CONCERNS / FAIL)
  - CRITICAL / IMPORTANT / MINOR finding counts
  - promotion candidates
main session persists verifier's findings to:
  - attestation-log.tsv (one row)
  - observation file (under main's authorship per PCG-S401-4)
main session decides:
  - PASS → mv plan-NNN from pending/ to completed/
  - PASS-WITH-CONCERNS → mv if merge-eligible; log defects
  - FAIL → leave in pending/; dispatch new dev session with remediation
```

### Tại Sao Ba Fresh Context

- **Context của Architect** được lấp đầy bởi: spec, constitution, calibration data, code.
- **Context của Dev** được lấp đầy bởi: plan, code-to-touch, test runner.
- **Context của Verifier** được lấp đầy bởi: plan, diff, test results.

Mỗi cái **scoped vào job của nó**. Combined, chúng giữ ~400-700K tokens của material liên quan — far more hơn bất kỳ session đơn lẻ nào có thể carry. Và vì mỗi cái là fresh-context, không cái nào có thể rationalize mistake của cái khác.

### Vấn Đề Coordination

Khi parallel sandwich session chạy (ví dụ, hai dev session trên sub-plan độc lập), section **Coordination Rules** của `current-execution.md` list file-collision avoidance:

```markdown
**Coordination rule (S315 active)**: main session avoids
`scripts/hooks/python-determinism-check.sh`,
firing-test,
`decisions/059-*`,
`.claude/settings.json` (W0-2 wire-up section),
`sessions/session-315.md`.
```

Hooks (`destructive-command-guard.sh`, `write-vs-edit-guard.sh`) enforce một số của các quy tắc này; coordination rules là soft layer của explicit avoidance.

---

## 8.5 — Decision Discipline trong Thực Tiễn

ADRs được tác giả như một phần của plan. Lifecycle:

### State Transitions

```
PROPOSED (author writes ADR; status PROPOSED)
  ↓ cool-down per tier
  ↓ CHARTER: 48h
  ↓ SCOPE: 24h
  ↓ ARCH: 12h
  ↓ IMPL: 0h (auto)
  ↓
ACCEPTED (user ratifies via AskUserQuestion OR auto for IMPL tier)
  ↓ implementation lands
  ↓
SHIPPED (companion code/hook/file landed; verified)
  ↓ if later superseded
  ↓
SUPERSEDED-BY-D-NNN (status changes; never deleted)
```

### Per-Tier Decision Path

| Tier | Confidence threshold | Decision path | Cool-down |
|---|---|---|---|
| **CHARTER** | 0.99 | Luôn AskUserQuestion bundle + human ratify | 48h |
| **SCOPE** | 0.90 | AskUserQuestion nếu <0.90 | 24h |
| **ARCH** | 0.80 | Self-decide nếu ≥0.80 | 12h |
| **IMPL** | 0.50 | Self-decide nếu ≥0.50 | 0h |

### Approval Chain Field

```yaml
approval_chain:
  - source: sync-tracker/state.tsv (Confidence Score: 0.92)
  - source: human-workspace/user_prompt/<file>.txt § directive
  - source: master-plan / phase entry
  - source: AskUserQuestion <bundle-id> Q1=A
```

### Pre-Dispatch ADR Number Check

`pre-dispatch-adr-number-check.sh` (PreToolUse) ngăn ADR number collision khi nhiều subagent cố tác giả ADRs trong parallel sessions. Đọc `decisions/` directory listing; nếu dispatched architect brief cite một number đã được dùng, hook flag nó.

---

## 8.6 — Workspace Dualism

Domain của agent là `agent-workspace/`. Domain của human là `human-workspace/`. Chúng communicate qua các channel tường minh.

### Channels

| Direction | Channel | Purpose |
|---|---|---|
| Human → Agent | `human-workspace/user_prompt/<file>.txt` | Prompt mới có thể reshape scope |
| Human → Agent | `human-workspace/decisions/<file>.md` | Formal ratifications |
| Agent → Human | `human-workspace/q-and-a/pending/<bundle>.md` | Questions awaiting answer |
| Bidirectional | `human-workspace/q-and-a/answered/<bundle>.md` | Resolved Q&A (auto-mv from pending/) |
| Agent → Human | `human-workspace/notifications/urgent.md` | Severity escalations |

### Permission Boundaries

| Channel | Agent can | Hooks enforce |
|---|---|---|
| `user_prompt/` | Read only | `Write/Edit(user_prompt/**)` denied trong settings.json |
| `decisions/` | Read only | `Write/Edit(decisions/**)` denied |
| `q-and-a/pending/` | Write + Edit | Per agent-workspace/CLAUDE.md auto-mv rule |
| `q-and-a/answered/` | Auto-mv only qua hook | `Write/Edit(answered/**)` denied to agent direct |
| `q-and-a/stale/` | Auto-mv only qua hook | `Write/Edit(stale/**)` denied |
| `notifications/urgent.md` | Append (qua Edit) | Permitted explicitly |

### Auto-Mv Rule (HH-E.2 / D-031 — 2026-05-05 ratified)

Agent MAY mv một bundle từ `q-and-a/pending/` sang `q-and-a/answered/` IFF **TẤT CẢ** điều sau giữ vững:

1. **Frontmatter signal**: bundle frontmatter `status:` field value bắt đầu với một trong: `answered-`, `closed-`, `resolved-`. Examples đã trong repo: `answered-via-chat`, `answered-via-AskUserQuestion`, `answered-2026-05-04-via-chat`. Detection là deterministic (head -20 của file + grep `^status:`).
2. **No human-veto signal**: bundle frontmatter KHÔNG có `wait_until:` ISO-8601 timestamp lớn hơn current epoch. Nếu present, agent PHẢI defer mv cho đến khi timestamp đó passes. Cho phép human override auto-mv per-bundle không cần contract amendment.
3. **No global pause**: file `human-workspace/q-and-a/.auto-mv-paused` KHÔNG tồn tại. Sự hiện diện file rỗng đơn pause TẤT CẢ auto-mv (global kill switch).
4. **Hook validation**: mv được thực hiện bởi `scripts/hooks/qa-pending-auto-mover.sh` (Stop hook). Direct manual `mv` invocation bởi agent (ví dụ, qua Bash tool) VẪN bị cấm — chỉ validated hook path là authorized.

### Stale Q&A Lifecycle

`qa-pending-stale-mover.sh` (SessionStart) move Q&A bundle qua `wait_until:` sang `stale/`.

`qa-stale-urgent-escalator.sh` (Stop) escalate >48h pending sang URGENT (HIGH severity trong pipeline).

---

## 8.7 — Q&A Bundle Mega-Pattern

Khi agent cần human input, nó bundle questions per skill `grill-maximization`.

### Tại Sao Bundle

Single-question prompts thrash context của human. Bundling:
- Giảm round-trips
- Surface decision dependencies (Q3 phụ thuộc Q1's answer)
- Buộc agent commit vào một state của pending questions

### Bundle Anatomy

```markdown
---
bundle_id: <YYYY-MM-DD-NNN>
authored_at: <ISO-8601>
authoring_session: S<N>
status: pending | answered-<source>-<date> | closed | stale
wait_until: <ISO-8601, optional>
intent_classification: SCOPE | CHARTER | ARCH | IMPL
priority: critical | high | medium | low
askuserquestion_fired: false | true (set when AskUserQuestion called)
---

# Q&A Bundle <id> — <topic>

## Context
[what prompted this bundle]

## Q1 — <short title> (<CHARTER | SCOPE | ARCH | IMPL>)
**Decision needed**: <one sentence>
**Options**:
- (A) <option> — recommended, because <rationale>
- (B) <option> — fallback, because <rationale>
- (C) <option> — defer, because <rationale>
**Agent's lean**: A (confidence 0.75)
**Why this matters now**: <consequence of delay>

## Q2 — ...
[similar]

## Q3 — ...
[similar; can be up to ~20 questions in mega-bundle]
```

### `AskUserQuestion` Binding Surface

Quyết định binding thực tế xảy ra qua tool `AskUserQuestion`, displays UI prompt:
- Max 4 questions per call
- Mỗi question có 2-4 options (5th "Other" auto-added)
- User pick per question

**Bundling logic**: nếu bundle có >4 questions, agent pick highest-priority 4 cho first `AskUserQuestion` call; questions còn lại chờ follow-up calls.

### Mega-Bundle Rule

Per `qa_bundle_all_pending` user memory: bundle TẤT CẢ pending Q&A qua các topic vào MỘT mega-bundle; không bao giờ piecemeal. Mỗi Q phải có lettered options.

---

## 8.8 — Continuity Qua `/clear` và Auto-Reboot

Harness preserve continuity qua hai boundary:
- `/clear` — user thủ công reset session
- Auto-reboot — `session-self-reboot.sh` trigger tại cliff (220K) hoặc wind-down (180K)

### Checkpoint Mechanism (3-Hook Choreography)

```
[during session]
  ↓ Edit/Write to checkpoints/latest.md
checkpoint-write-marker.sh (PostToolUse)
  ↓ writes .checkpoint-written-<sid>
  ↓ if autonomous_mode=true: also writes .fresh-resume-pending-<sid>
  ↓
[LLM tries to do anything else]
checkpoint-write-end-turn-watchdog.sh (PreToolUse)
  ↓ marker present → DENY tool call (RC=2)
  ↓ stderr: "checkpoint written; end turn"
  ↓
[user types /clear or auto-reboot fires]
  ↓ new session begins
  ↓ SessionStart fires
checkpoint-marker-cleanup-resume.sh (SessionStart)
  ↓ clears .checkpoint-written-<sid>
  ↓ reads checkpoints/latest.md "Next Action"
  ↓ surfaces next_action to LLM via system-reminder
  ↓ LLM resumes from documented next step
```

Ba hook tạo thành một continuity machine. Xóa bất kỳ cái nào và class M-S49b-2 duplicate-dispatch re-open.

### Auto-Reboot Modes

`autonomous-stop-watchdog.sh` detect bốn mode:

| Mode | Trigger | Handoff |
|---|---|---|
| **A** | Stop without checkpoint, no budget alert | `continue-injector` resume mid-session |
| **B** | Stop with budget cliff reached | `session-self-reboot.sh` for fresh-context resume |
| **C** | Premature wind-down (before cliff) | Handoff prep; resume qua continue-injector |
| **D** | Clean handoff (checkpoint mtime ≤60s) | Resume reads `checkpoints/latest.md` |

**D-003 § 5.5c.5 REV-4** document matching `failure_mode` 8-code expansion (`B|C|D|E|H|R|T|null`) trong JSONL telemetry.

### Mode-D vs SendKeys

Mode-D originally dùng Windows SendKeys để inject `continue` vào session mới. Điều này đã bị thu hồi (per user memory `autonomous_continue_no_self_pause.md`) ủng hộ cơ chế checkpoint marker.

---

## 8.9 — Một Session Thực, Có Chú Thích

Bên dưới là excerpt từ một session log thực (S407 — plan-044 G.4 IMPL):

```markdown
---
session: 407
type: FOCUSED_IMPL
model: claude-opus-4-7
plan: agent-workspace/session-plans/pending/044-S395-vhm-thesis.md
---

# Session 407 — 2026-05-19 — FOCUSED_IMPL

## Goal
Implement plan-044 G.4 — VHM PDF dogfood + BC-2 SqliteFundamentalRepository integration.

## What Happened
sandwich-dev background dispatch (agentId a82bab00b64f2dade, ~38min Opus,
3.2M tokens, 1 commit 28984c3).

D1-D6 all SHIPPED per dev self-report:
- D1: VHM 2024 PDF download via wget (10.5MB; HOSE-listed)
- D2: PDF→text extraction via pdfplumber
- D3: Claude vision adapter consumed PDF input
- D4: BC-2 SqliteFundamentalRepository persist
- D5: 12 fundamental statements persisted (VHM 2020-2024)
- D6: VHM thesis re-run; cost $4.71 (under $6 cap)

Verification:
- mypy --strict: PASS
- pytest: 1180/1 PASS (baseline 1178+2; +2 G.4 tests)
- ruff: CLEAN

## Files Touched
- packages/infrastructure/fundamental/vhm_pdf_dogfood.py — NEW (108 LOC)
- packages/infrastructure/fundamental/sqlite_fundamental_repository.py — +24 LOC
- tests/infrastructure/fundamental/test_vhm_pdf_dogfood.py — NEW (52 LOC)
- agent-workspace/memory/decisions/083-*.md — NEW ADR D-083 PROPOSED

## Decisions Made
- D-083 PROPOSED — BC-2 PDF→Fundamental shape contract; auto-accepted at IMPL tier

## Mistakes This Session
- M-S407-NONE (no mistakes; clean session)

## Verification (re-run by main)
- mypy --strict: PASS (1178+2 = 1180 cells)
- pytest: 1180/1 PASS
- ruff: CLEAN
- bash-hook-lint: CLEAN
- companion firing-tests: 7/7 PASS for new hook (atomic-write-check)

## Carry-Forward
- Verifier dispatch (S408) needed to attest D1-D6
- D-083 PROPOSED → flip to ACCEPTED on verifier PASS

## Handoff
checkpoints/latest.md written. Next action: dispatch sandwich-verifier S408
for plan-044 G.4 attestation.
```

Đây là canonical session log shape. Mỗi section được enforce bởi một hook hoặc required bởi session-end checklist.

---

## 8.10 — Phase Lifecycle (Macro)

Vượt ra ngoài session và plan, harness tổ chức công việc thành **Phases** (long-running, multi-month).

### Phase Goals Tracker (trong project.md)

```markdown
| Phase | Target | Status | Started | Completed |
|---|---|---|---|---|
| 0 — Harness Bootstrap | ... | DONE | 2026-04-29 | 2026-04-30 |
| 1 — Foundation VHM | ... | DONE | 2026-04-30 | 2026-04-30 |
| 2 — Foundation Tier 1+2 | ... | DONE | 2026-04-30 | 2026-05-04 |
| 2.5 — Harness Hardening | ... | DONE | 2026-05-05 | 2026-05-07 |
| 3 — Tier 3+4 KOL + outer-loop | ... | PAUSED | 2026-05-05 | - |
| 3.5 — Harness Deepening | ... | DONE | 2026-05-05 | 2026-05-12 |
| 4 — Multi-perspective | ... | IN PROGRESS | 2026-05-12 | - |
| 5 — Compounding | ... | NOT STARTED | - | - |
```

### Phase Entry Ritual

Khi entering phase mới:
1. Author master plan (qua `/master-plan` → `master-planner` subagent)
2. Update `current-execution.md` Active Focus + Phase Goals Tracker
3. Trigger `intent-vs-impl-diff` để verify không có silent absorption từ phase trước
4. AskUserQuestion nếu bất kỳ SCOPE-tier sub-decision nào surface

### Phase Close Ritual

Khi closing phase:
1. Update `project.md` Phase Goals Tracker (Status: DONE, Completed: date)
2. Archive Active Focus narrative vào phase-close observation
3. Trigger `promote-rule` để consolidate accumulated agent-notes
4. Chạy `harness-health-self-scan.sh` cho state attestation

`phase-status-coherence.sh` continuously check rằng `project.md` match `current-execution.md`. Drift escalate sang MEDIUM.

---

## 8.11 — Lifecycle Anti-Patterns

| Anti-pattern | Cái gì sai | Fix |
|---|---|---|
| Mix PLAN và IMPL trong cùng session | Session 4 failure mode | Hard rule; không bao giờ |
| Single-agent self-review (echo chamber) | Verifier rationalize architect | Tách agent cho Tier 2 gate |
| Skip checkpoint write trước /clear | Lost continuity (M-S49b-2) | checkpoint-write-end-turn-watchdog.sh enforce |
| Plan stays in pending/ post-verify | Stuck-plan drift | `harness-recovery-dod-watchdog.sh` flag |
| Update current-execution.md chỉ tại end | Pre-staged work drift (AP-8) | Update khi task complete |
| ROUTINE-IDLE close ritual khi không có signal | Busy-work loop (L-S310-1) | Demote ritual; one-line state ack |
| Authored "DONE" plan khi data pending | Misleading state (L-S385-2) | Dùng vocabulary CODE-DONE-DATA-PENDING |
| ADR PROPOSED với cool-down không honored | Charter-tier rush | `proposal-bundle-advisor.sh` enforce |
| Q&A bundle pending >24h không action | Silent default | `qa-stale-urgent-escalator.sh` escalate |

---

## 8.12 — Đọc Tiếp Ở Đâu

- **Các quality gate** mà lifecycle events trigger → [Chương 9 — Hệ Thống Chất Lượng](09-he-thong-chat-luong.md)
- **Cách learned rules emerge từ sessions** → [Chương 10 — Tự Cải Thiện](10-tu-cai-thien.md)
- **Cách chạy một sandwich cycle** → [Chương 11 § Chạy Sandwich Cycle](11-cong-thuc.md#run-a-sandwich-cycle)
- **Lifecycle pitfalls thông dụng** → [Chương 12 — Nội Tại § Anti-Patterns](12-noi-tai.md#anti-patterns)
