# Chương 7 — Hệ Thống Bộ Nhớ

> **Phân khu Diataxis**: Reference + Explanation
> **Thời gian đọc**: ~40 phút
> **Điều kiện tiên quyết**: Chương 3 (Kiến Trúc), Chương 4 (Hiến Pháp § memory-tiers)

Hệ thống bộ nhớ là state persistent của harness — *filesystem brain* mà agent đọc tại SessionStart và update tại SessionEnd. Chương này là canonical reference: mỗi file là gì, mỗi directory là gì, ai ghi vào nó, ai đọc nó, và retention nào áp dụng.

Nếu Chương 6 là *các bộ phận chuyển động*, chương này là *state mà chúng vận hành trên đó*.

---

## 7.1 — Mô Hình Bộ Nhớ Ba Tầng

Per [`memory-tiers.md`](../../../agent-workspace/constitution/memory-tiers.md):

| Tier | Cái gì load | Hard cap | Loaded khi nào |
|---|---|---|---|
| **Tier 1** | Identity + routing luôn-loaded | ≤8K tokens combined | Mỗi SessionStart, mỗi session |
| **Tier 2** | Just-in-time (đọc khi tín hiệu liên quan kích hoạt) | None — per artifact | Khi skill / hook / task tham chiếu nó |
| **Tier 3** | Explicit-pull (chỉ đọc khi được yêu cầu tường minh) | None | Yêu cầu thủ công của user, audit, post-mortem |

**Tier 1 contents** (≤8K combined):
- `CLAUDE.md` (project root, ~2500 tokens)
- `agent-workspace/CLAUDE.md` (~1500 tokens)
- `human-workspace/CLAUDE.md` (~500 tokens)
- `agent-workspace/memory/MEMORY.md` (user auto-memory index, ~500 tokens)
- `agent-workspace/memory/project.md` (~1500 tokens)
- `agent-workspace/memory/current-execution.md` (≤200 LOC inline, ~1000 tokens)

Total target: ~7500 tokens. Hard ceiling thực thi bởi `tier1-bloat-check.sh` (Stop chain).

**Tại sao điều này quan trọng**: Tier 1 là chi phí của *mỗi* session, trả trước bất kỳ công việc nào. Bloat ở đây cộng dồn qua mỗi session trong vòng đời dự án.

---

## 7.2 — Memory Routing Tree

Per [`memory-routing-tree.md`](../../../agent-workspace/constitution/memory-routing-tree.md), agent dùng decision tree để route state mới đến artifact đúng:

```
What kind of state am I writing?
│
├── A rule earned through experience? 
│   → agent-workspace/memory/agent-notes.md (digest entry, ≤700 LOC)
│
├── A failure I observed?
│   → agent-workspace/memory/mistake-log.md (digest entry, ≤200 LOC)
│   → For root-cause analysis: agent-workspace/memory/post-mortems/<date>-<slug>.md
│
├── A decision I just made?
│   → agent-workspace/memory/decisions/NNN-<slug>.md (ADR, 12-field schema)
│
├── A subagent's return artifact?
│   → agent-workspace/memory/observations/<subagent>-<sid>-<TS>.md
│
├── Session log?
│   → agent-workspace/memory/sessions/YYYY-MM-DD-session-N.md
│
├── Checkpoint state for next session?
│   → agent-workspace/memory/checkpoints/latest.md (canonical)
│   → agent-workspace/memory/checkpoints/<sid>-close.md (timestamped historical)
│
├── A drift detection result?
│   → agent-workspace/memory/drift-logs/YYYY-MM-DD-rollup.md
│
├── Telemetry row (deterministic, append-only)?
│   → agent-workspace/memory/dispatch.jsonl (per-Agent-call)
│   → agent-workspace/memory/cost-ledger.tsv (per-session USD)
│   → agent-workspace/memory/attestation-log.tsv (verifier verdicts)
│   → agent-workspace/memory/component-telemetry.jsonl (per-tool)
│
├── Self-awareness profile data?
│   → agent-workspace/memory/self-awareness/profiles/<model>-<effort>-<task_class>.md
│   → agent-workspace/memory/self-awareness/sessions-rollup.tsv
│
├── Confidence Score event?
│   → agent-workspace/memory/sync-tracker/events.tsv
│   → agent-workspace/memory/sync-tracker/state.tsv (derived)
│
├── A pattern that worked well?
│   → agent-workspace/memory/patterns-discovered/<pattern-name>.md
│
└── A thesis entry (stock domain)?
    → agent-workspace/memory/thesis-log/<TS>-<ticker>.md
```

Routing tree là canonical. Nếu bạn không tìm thấy route, bạn hoặc đã phát hiện route bị thiếu (đề xuất bổ sung) hoặc đang cố lưu thứ không thuộc về memory.

---

## 7.3 — Reference Subdirectory Memory

Tất cả path tương đối với `agent-workspace/memory/`.

### Top-Level Files

| File | Purpose | Mutability | Retention |
|---|---|---|---|
| `MEMORY.md` | User auto-memory index (one-line per memory file) | Editable | Dòng sau 200 truncated |
| `project.md` | High-level project state; phase tracker; last 5 ADRs | Editable | Trim về các quyết định gần nhất |
| `current-execution.md` | **THE routing source-of-truth**. Active phase + active session + autonomous_mode flag + routing table | Editable | ≤5 session inline; cũ hơn vào archive (auto-archive qua `tracking-retention.sh`) |
| `agent-notes.md` | Learned rules earned through real experience | Append-mostly | Digest only / ≤700 LOC |
| `mistake-log.md` | Failure catalog: cái gì sai / root cause / prevention | Append-mostly | Digest only / ≤200 LOC |
| `capability-map.md` | Per-task_class agent capability profile | Editable | Updated per profile-template-auto-populate.sh |
| `personal-risk-profile.md` | User's risk tolerance + bias profile | Editable | Human-curated |
| `sync-state.md` | Sync-tracker narrative state | Editable | Updated per sync-grilling fire |
| `boot-summary.md` | Auto-rendered cheap-load summary cho next-session reboot | Auto-render | Recomputed mỗi Stop |
| `routing-config.md` | Memory routing config (per memory-routing-tree.md) | Editable | Stable |
| `up-intake-log.md` | User prompt intake events (intent classification log) | Append-only | Long-lived |
| `component-telemetry.jsonl` | Per-tool JSONL telemetry | Append-only | ≤10 MB (weekly rotate) |
| `cost-ledger.tsv` | Per-session + per-dispatch USD cost ledger | Append-only | Long-lived |
| `dispatch.jsonl` | Per-Agent-call telemetry (DISPATCHED + COMPLETED) | Append-only | Long-lived |
| `attestation-log.tsv` | Sandwich-verifier verdicts (PASS / PASS-WITH-CONCERNS / FAIL) | Append-only | Long-lived |
| `.session-hooks.log` | Hook firing log (mọi hook event) | Append-only | Weekly rotate qua session-hooks-log-rotate.sh |
| `.severity-state.tsv` | Severity classifier output (rebuilt mỗi Stop) | Atomic-rewrite | Replaced mỗi Stop |
| `.harness-health.log` | Harness-health detection log | Append-only | Long-lived |
| `.drift-signals.log` | Drift detection raw output | Append-only | Weekly rotate qua drift-signals-log-rotate.sh |
| `.harness-health-cache-<sid>` | Same-session HH cache (5-min TTL) | Auto | Cleared giữa các session |
| `.claude-instance.lock` | Single-instance lock file | Auto | Cleared tại SessionEnd |
| `.cliff-fired`, `.wind-down` | Budget threshold markers (noclobber) | Auto | Per-session |

### Subdirectories

| Directory | Purpose | Naming convention | Lifecycle |
|---|---|---|---|
| `sessions/` | Một file mỗi session | `YYYY-MM-DD-session-N.md` | Append-only; ~257+ files |
| `decisions/` | ADRs tuần tự | `NNN-<slug>.md` + `_template.md` + `README.md` | Append-only; supersession qua status field; 90+ files |
| `observations/` | Subagent return artifacts | `<subagent-type>-S<sid>-<TS>.md` | Append; cleaned định kỳ bởi aggregator |
| `checkpoints/` | Session handoff state | `latest.md` (canonical) + `YYYY-MM-DD-S<sid>-close.md` (historical) | Append + latest.md updated mỗi checkpoint |
| `patterns-discovered/` | Pattern mining outputs (Track 0) | `<pattern-name>.md` + `SYNTHESIS.md` | Append; pattern quan trọng promote lên constitution |
| `drift-logs/` | Drift-check results | `YYYY-MM-DD-rollup.md` | Time-series append |
| `post-mortems/` | Post-mortem cho failure quan trọng | `YYYY-MM-DD-<incident-name>.md` | Append |
| `thesis-log/` | Stock-domain thesis entries | `<TS>-<ticker>.md` | Append; revisited per calibration |
| `sync-tracker/` | Confidence Score store | `state.tsv`, `events.tsv`, `weights.yaml`, `_index.md` | Live-updated bởi hooks |
| `self-awareness/` | Model x effort x task_class profile cards | `profiles/<model>-<effort>-<task_class>.md` + `sessions-rollup.tsv` | Live-updated bởi Stop-hook aggregator |
| `indexes/` | Rendered manifest TSVs | `<type>.tsv` | Recomputed bởi index-registry-renderer.sh |
| `etl-queue/` | Pending memory ETL operations | `<TS>-<op>.yaml` + `processed/` subdir | Drained bởi memory-etl-processor.sh |
| `handoff-logs/` | Handoff history | `YYYY-MM-DD-S<sid>-handoff.md` | Append |
| `telemetry-archive/` | Rotated telemetry files | `<TS>.gz` | Append; periodic prune |
| `session-hooks-archive/` | Rotated `.session-hooks.log` files | `<week>.log` | Append; periodic prune |
| `drift-signals-archive/` | Rotated `.drift-signals.log` files | `<week>.log` | Append; periodic prune |
| `.precompact-snapshots/` | PreCompact state dumps | `YYYYMMDDTHHMMSSZ/` | Auto; periodic prune |
| `.dispatch-pending-archive/` | Archived dispatch.jsonl pending rows | `<TS>.jsonl` | Periodic rotation (12h) |

---

## 7.4 — Routing Source-of-Truth (`current-execution.md`)

File này LÀ single routing source-of-truth. Mỗi session bắt đầu bằng việc đọc nó. Mỗi session kết thúc bằng việc update nó.

### Structure

```markdown
# Current Execution — Routing Source of Truth

> **autonomous_mode**: true | false
> **Retention**: last 5 sessions inline; older sessions archived to
> `current-execution-archive-YYYY-MM-DD-S<from>-to-S<to>.md`

## Active Focus

[narrative paragraph: current phase, current track, what's next]

## Active Sub-Track

[detailed table: sub-track / status / next session]

## Session Log (most recent first)

### S<N> — <DATE> — <TYPE> — <STATUS>
**Goal**: ...
**Dispatched**: <agent>
**Result**: ...
**Carry-forward**: ...

### S<N-1> — ...
[similar]

## Routing Table

| Symbol | Resolves to |
|---|---|
| `session N` | active session per Active Focus |
| `phase X` | active phase per Phase Goals Tracker |
| `wave 1` | per master plan §6 |

## Coordination Rules (active)

[file/dir avoidance lists when subagents are working in parallel]
```

### Hard Rules

- **Không skill, agent, hoặc command nào được hardcode phase path từ memory.** Resolve qua file này.
- **Auto-archive** tại >200 LOC HOẶC >5 session inline (qua `tracking-retention.sh`).
- **Update ngay khi task complete**, không phải session-end (AP-8 prevention).
- **`autonomous_mode` flag**: parsed bởi `session-start-bootstrap.sh` để gate `continue-injector` spawn. Awk parse chính xác trên field này điều khiển autonomous loop.

---

## 7.5 — Learned Rules (`agent-notes.md`)

`agent-notes.md` là institutional memory của harness về rule học được qua kinh nghiệm.

### Format

```markdown
### YYYY-MM-DD: [Short rule name]
**Context**: What situation triggered learning this
**Rule**: The actionable rule
**Anti-example**: What was done wrong
**Correct example**: What should be done instead
**Severity**: critical | high | medium | low
**Auto-detect**: yes/no — can a drift signal catch this?
```

### Retention

**Cap**: 700 LOC (digest only). `tracking-retention.sh` warn khi vượt.

Các rule cũ archive vào `agent-notes-archive-YYYY-MM-DD.md`.

### Lifecycle

1. **Capture**: rule earned trong session → ghi dưới dạng digest entry tại session-end (per `session-end-checklist-linter.sh`).
2. **Cluster**: mỗi 5+ session, subagent `promote-rule` dispatched. Cluster rules theo Jaccard similarity. Xác định promotion candidates.
3. **Promote** (3 tier):
   - **HOOK promotion**: rule có thể phát hiện tĩnh → ship dưới dạng `scripts/hooks/<name>.sh` + companion firing-test.
   - **SKILL promotion**: rule là một quy trình tái diễn → ship dưới dạng `.claude/skills/<name>/SKILL.md`.
   - **CHARTER promotion**: rule nâng lên invariant → đề xuất constitution amendment.
4. **Retire**: rule retired khi 3+ consecutive session show catch-rate 0 HOẶC khi superseded.

### Auto-Detect Tag

Field `Auto-detect: yes` là một **lời hứa**: nó nói "rule này nên ship dưới dạng deterministic hook". Nếu 20+ rule tag `Auto-detect: yes` mà không có matching hook script, **HH-4** kích hoạt MEDIUM severity. Đây là một bề mặt Phase 2.5 đã bắt ~20 orphan như vậy.

---

## 7.6 — Failure Catalog (`mistake-log.md`)

`mistake-log.md` là catalog failure có cấu trúc. Format:

```markdown
### M-S<N>-<M>: Short mistake name
**Date**: YYYY-MM-DD
**Severity**: critical | high | medium | low
**What went wrong**: ...
**Root cause**: ...
**Prevention rule**: ...
**Status**: open | closed | superseded-by-L-<NN>-N
```

### Naming

- `M-S<N>-<M>` trong đó:
  - `S<N>` = session ID nơi mistake xảy ra (ví dụ, `S360`)
  - `<M>` = sequential trong session đó (1, 2, 3...)

- `M-S<N>-NONE`: explicit "no mistakes this session" attestation

### Retention

**Cap**: 200 LOC (digest only). `tracking-retention.sh` enforce.

Entry cũ archive vào `mistake-log-archive-YYYY-MM-DD.md`.

### Discipline

`session-end-checklist-linter.sh` (Stop hook) enforce: mỗi session PHẢI hoặc record ít nhất một entry `M-S<N>-<M>` HOẶC explicitly state `M-S<N>-NONE` trong session log. Silent omission được xem như drift.

---

## 7.7 — Architecture Decision Records (`decisions/`)

ADRs là canonical record của mọi quyết định được thực hiện. Sequential numbering, không bao giờ tái sử dụng. Schema YAML frontmatter 12+ field được detail trong [§ Chương 4 — Decision Discipline](04-hien-phap.md#44--decision-discipline-adrs).

### Subdirectory Structure

```
decisions/
├── _template.md           ← canonical schema
├── README.md              ← index + conventions
├── 001-<slug>.md
├── 002-<slug>.md
├── ...
└── NNN-<slug>.md          ← 90+ files
```

### Sequential Numbering Rule

Numbers không bao giờ tái sử dụng. Nếu bạn tác giả ADR và phát hiện nó nên merge vào một cái cũ hơn, mark ADR mới `status: SUPERSEDED-BY-D-NNN` và link.

### Pre-Dispatch Number Check

`pre-dispatch-adr-number-check.sh` (PreToolUse) đọc next-expected ADR number từ `decisions/` directory listing. Nếu dispatched architect cite ADR number đã tồn tại, hook flag nó. Ngăn collision drift.

### Defer-Cycle Tracking

Field `defer_cycles` trong frontmatter track bao nhiêu lần ADR này được defer. Nếu `defer_cycles > 3`, R7 mitigation trigger: surface là MEDIUM severity trong escalation pipeline.

### Confidence Thresholds

Per `decision-discipline.md`:

| Level | Threshold | Path |
|---|---|---|
| CHARTER | 0.99 | Luôn Q&A bundle + human ratify |
| SCOPE | 0.90 | Q&A bundle nếu <0.90 |
| ARCH | 0.80 | Self-decide nếu ≥0.80 |
| IMPL | 0.50 | Self-decide nếu ≥0.50 |

Confidence đến từ `sync-tracker/state.tsv` per-category Confidence Score.

---

## 7.8 — Subagent Observations (`observations/`)

Mỗi dispatch subagent trả về tối đa một observation file. Naming convention:

```
<subagent-type>-S<sid>-<TS>.md
```

Examples:
- `sandwich-architect-S395-2026-05-17T14-32-00Z.md`
- `sandwich-verifier-S401-2026-05-17T22-15-00Z.md`
- `lesson-synthesizer-S365-2026-05-17T10-08-00Z.md`

### Frontmatter

```yaml
---
session_id: S<N>
subagent: <type>
dispatched_at: <ISO-8601>
returned_at: <ISO-8601>
duration_ms: <int>
tokens_used: <int>
tool_calls: <int>
outcome: PASS | PASS-WITH-CONCERNS | FAIL | DEFER
attestation_row: <attestation-log.tsv row index, if applicable>
---
```

### Body Structure

Per-subagent. Sandwich-verifier observations điển hình có:

```markdown
## Verdict
PASS-WITH-CONCERNS | merge-eligible

## V1 — Acceptance criteria check
- D1: PASS
- D2: PASS
- ...

## V2 — Verification grid
...

## CRITICAL Findings
(none)

## IMPORTANT Findings
F1: ...
F2: ...

## MINOR Findings
F3-F7: ...

## Promotion Candidates
PCG-V<sid>-1: ...
```

### Orphan Detection

`observation-orphan-detector.sh` (Stop hook) check observations mà dispatch.jsonl row chưa bao giờ nhận matching COMPLETED. Orphan flag tại HIGH sau threshold.

---

## 7.9 — Session Logs (`sessions/`)

Một file mỗi session. Naming: `YYYY-MM-DD-session-<N>.md`. 257+ files at last count.

### Standard Body

```markdown
---
session: <N>
type: PLAN | FOCUSED_IMPL | MULTI_TASK_IMPL | VERIFY | RECOVERY | THESIS | INGEST | POST-MORTEM
model: opus | sonnet | haiku
plan: <pending plan reference if applicable>
---

# Session <N> — <DATE> — <TYPE>

## Goal
[from session brief]

## What Happened
[narrative]

## Files Touched
- `path/to/file1` — what changed
- `path/to/file2` — what changed

## Decisions Made
- D-NNN PROPOSED (see decisions/NNN-*.md)

## Mistakes This Session
- M-S<N>-1: ...
- M-S<N>-2: ...
OR
- M-S<N>-NONE: explicit no-mistakes attestation

## Verification
- mypy --strict: PASS
- pytest: 1178/1 PASS (baseline 1127+1)
- ruff: CLEAN
- bash-hook-lint: CLEAN

## Carry-Forward
[what next session inherits]

## Handoff
[checkpoint file written; next_action stated]
```

### Hook Enforcement

- `session-end-checklist-linter.sh`: enforce sự hiện diện của section "Mistakes This Session" (per HH-C.1).
- `taskcompleted-audit.sh`: scan vi phạm I-S1 (no LLM math) + I-S2 (citations) trong session prose.
- `charter-coherence-spot.sh`: scan vi phạm I-S35 (research-aid framing).

---

## 7.10 — Checkpoints (`checkpoints/`)

Checkpoints mang session-handoff state cho cross-session continuity.

### Files

- `latest.md` — **canonical pointer**. Luôn là checkpoint gần nhất. Đọc bởi bootstrap session tiếp theo.
- `YYYY-MM-DD-S<sid>-close.md` — timestamped historical close.

### Body `latest.md`

```markdown
# Checkpoint — S<N> close — YYYY-MM-DD HH:MM SEAST

## Current Phase
[from current-execution.md]

## Active Track
[narrative]

## Last Action
[what just completed]

## Next Action (for resume)
[concrete next step the LLM should take on resume]

## Open Items
[any pending Q&A bundles, pending dispatches, etc.]

## Context Pointers
- session-plans/pending/NNN-*.md (active plan)
- specs/tier2-feature/NNN-*.md (active spec)
- last 3 session logs
```

### Hook Enforcement

- `checkpoint-write-marker.sh` (PostToolUse): mark `.checkpoint-written-<sid>` sau bất kỳ Edit/Write vào `latest.md`.
- `checkpoint-write-end-turn-watchdog.sh` (PreToolUse): deny bất kỳ tool call non-exempt nào tiếp theo khi marker được set (rule "checkpoint write = end turn").
- `checkpoint-marker-cleanup-resume.sh` (SessionStart): clear markers + surface `next_action` lên session mới.
- `pre-checkpoint-close-verifier.sh` (Stop): validate `latest.md` internally consistent trước khi cho phép close.
- `auto-reboot-handoff-verify.sh` (Stop): HH-H.4 outer fence — verify checkpoint freshness cho auto-reboot.

---

## 7.11 — Telemetry Files

Append-only structured logs.

### `dispatch.jsonl`

Per-Agent-call telemetry. Hai row mỗi dispatch:
- `DISPATCHED` (ghi bởi PreToolUse(Agent))
- `COMPLETED` (ghi bởi SubagentStop, FIFO-matched bởi `tool_use_id`)

Schema (excerpt):
```json
{
  "event": "DISPATCHED" | "COMPLETED",
  "ts": "<ISO-8601>",
  "tool_use_id": "<id>",
  "parent_session_id": "<sid>",
  "agent_type": "sandwich-architect",
  "model": "claude-opus-4-7",
  "tokens_real": 188432,
  "duration_ms": 286000,
  "outcome": "PASS",
  "failure_mode": null
}
```

Origin: D-023 v2 schema + HH-B.1/B.2.

### `cost-ledger.tsv`

Per-session + per-dispatch USD cost.

Schema:
```
timestamp \t session_id \t actor \t model \t tokens_in \t tokens_out \t cache_read \t cache_create \t cost_usd \t hook_event
```

Pricing table (Anthropic public 2025-2026):
- opus: $15 in / $75 out per MTok
- sonnet: $3 in / $15 out per MTok
- haiku: $0.80 in / $4 out per MTok
- cache_read = 10% input cost
- cache_create = 125% input cost

Computed bởi `cost-ledger-recorder.sh` (Stop + SubagentStop).

### `attestation-log.tsv`

Sandwich-verifier verdicts.

Schema:
```
ts \t session_id \t verifier_session_id \t plan_id \t verdict \t critical_count \t important_count \t minor_count \t merge_eligible
```

Append-only. Used by `harness-recovery-dod-watchdog.sh` (Stop) để detect un-attested completions.

### `component-telemetry.jsonl`

Per-tool JSONL telemetry. Capture mọi tool call qua các session.

### `up-intake-log.md`

User prompt intake events (intent classification log).

Record cho mỗi prompt:
- Trivial-whitelist match (yes/no)
- `intent-classifier` verdict (nếu dispatched)
- Resulting action (ví dụ, OPEN_QA_BUNDLE)

---

## 7.12 — Sync-Tracker (Confidence Score)

Subdirectory `sync-tracker/` implement hệ thống Confidence Score (Track 8a, D-006).

### Files

- `weights.yaml` — per-category weights cho Confidence Score computation
- `events.tsv` — append-only event log (mỗi grill / answer / drift event)
- `state.tsv` — derived per-category Confidence Score (re-rendered từ events)
- `_index.md` — auto-rendered human-readable view

### Categories

Categories defined trong `weights.yaml`. Điển hình:
- SCOPE
- DECISION_ROUTING
- LANGUAGE (UL)
- INVARIANTS
- CALIBRATION
- ...

### Cách Sử Dụng

Trước bất kỳ quyết định non-trivial nào, skill `sync-pull` đọc `state.tsv`:
- Nếu Confidence Score ≥ threshold (per `weights.yaml`) → SELF-DECIDE-OK
- Nếu không → GRILL (build Q&A bundle)
- Nếu rất thấp → FORCE-GRILL

Threshold per category là cái gate self-decide vs human-ratify.

### Sync-Grilling

`sync-grilling-trigger.sh` (SessionStart) kích hoạt khi:
- 38 session đã trôi qua kể từ `last_check` trong `sync-state.md`, HOẶC
- 7 ngày đã trôi qua kể từ `last_check`

Khi triggered, agent xem xét kích hoạt một sync-bundle `AskUserQuestion` (4 question max) per template tại `.claude/skills/grill-maximization/references/sync-bundle-template.md`.

**Catch-rate discipline** (per CLAUDE.md): nếu sync-grilling kích hoạt 3+ consecutive session với catch-rate 0 (không có SCOPE-tier divergence mới), ritual là candidate cho demotion-to-passive hoặc retire.

---

## 7.13 — Self-Awareness (`self-awareness/`)

Per-model, per-effort-level, per-task-class profile cards.

### Files

- `profiles/<model>-<effort>-<task_class>.md` — profile card (một cái cho mỗi combination)
- `sessions-rollup.tsv` — per-session aggregate

### Cấu Trúc Profile Card

```markdown
---
model: claude-opus-4-7
effort: max
task_class: <one of: planning, focused-impl, multi-task-impl, verify, recovery, thesis, ingest, post-mortem>
sample_size: <int>
---

## Empirical Statistics

| Sample | Tokens (real) | Duration | Outcome |
|---|---|---|---|
| 1 | 188K | 286s | PASS |
| 2 | 224K | 340s | PASS-WITH-CONCERNS |
| ... |

## Known Issues
- KI-<id>: ...

## Best Practices
- BP-<id>: ...

## Cost Profile
[per-dispatch USD distribution]
```

### Auto-Population

`profile-template-auto-populate.sh` (Stop hook) append một sample row vào matching profile card sau mỗi session. Bootstrap là automatic; card phình ra theo thời gian.

Used by sandwich-architect cho **Phase 1b self-calibration** (xem [Chương 5 § Cơ Chế Sandwich Architect](05-skills-commands-agents.md#sandwich-architect-mechanics)).

---

## 7.14 — Retention Policies

Per [CLAUDE.md § Tracking Retention (S99 RCA Layer 1; Q-RCA-1 = A)]:

| File | Cap | Action when over |
|---|---|---|
| `current-execution.md` | ≤5 sessions inline / ≤200 LOC | Auto-migrate oldest session row to archive |
| `agent-notes.md` | digest only / ≤700 LOC | WARN |
| `mistake-log.md` | digest only / ≤200 LOC | WARN |
| `component-telemetry.jsonl` | ≤10 MB | Weekly rotate qua `telemetry-rotate.sh` |
| `.session-hooks.log` | varies | Weekly rotate qua `session-hooks-log-rotate.sh` |
| `.drift-signals.log` | varies | Weekly rotate qua `drift-signals-log-rotate.sh` |
| `dispatch.jsonl` | unbounded | Periodic 12h archive of pending rows qua `dispatch-pending-rotation.sh` |
| `cost-ledger.tsv` | unbounded | Long-lived |
| `attestation-log.tsv` | unbounded | Long-lived |
| `urgent.md` | 4KB | Size-triggered rotate qua `urgent-md-rotate.sh` |

Working-memory budget per `agent-workspace/proposals/memory-tiers.md` § Tier 1 = ≤ 20 KB combined cho routine load.

Cap breaches: WARN-only qua `tracking-retention.sh` Stop hook; manual archive vào dated file.

---

## 7.15 — Workspace Dualism Boundary

Memory sống trong **`agent-workspace/memory/`**. Đối tác do human sở hữu sống trong **`human-workspace/`**:

| Agent reads | Human writes |
|---|---|
| `agent-workspace/memory/personal-risk-profile.md` ← | (human curates) |
| (agent writes) → | `human-workspace/notifications/urgent.md` |
| ← | `human-workspace/user_prompt/*.txt` (agent reads only) |
| (agent writes to pending) | `human-workspace/q-and-a/answered/*.md` (human or agent via auto-mv) |
| (agent reads) | `human-workspace/decisions/*.md` (human writes formal ratifications) |

Dualism ngăn [orch CF-DOGFOOD-2 failure mode](12-noi-tai.md#cf-dogfood-2): shared-workspace mutation gây charter drift.

---

## 7.16 — Memory Anti-Patterns

| Anti-pattern | Cái gì sai | Fix |
|---|---|---|
| Tier 1 bloat | Mỗi session trả overhead | `tier1-bloat-check.sh`; trích sang Tier 2 |
| Skip `current-execution.md` read tại SessionStart | Hardcoded path drift | Đọc trước per Reading Priority |
| Direct edit của constitution files | B-2 violation | Dùng proposal → ratification cycle |
| Write nơi Edit là cần thiết (L-S45-2) | Destructive overwrite của append-only files | `write-vs-edit-guard.sh` block |
| Update `current-execution.md` chỉ tại session-end | AP-8 pre-staged work drift | Update khi task complete, không phải khi close |
| ADR number collision | Hai ADR cùng number | `pre-dispatch-adr-number-check.sh` |
| Silent dispatch.jsonl orphan | Subagent COMPLETED không bao giờ ghi | `observation-orphan-detector.sh` |
| Hooks đọc quá nhiều memory files | UserPromptSubmit chain slowdown | Cheap-first ordering + same-session caching |
| ROUTINE-IDLE close ritual khi không có signal | Busy-work loops (L-S310-1) | Demote ritual; emit one-line state ack |

---

## 7.17 — Đọc Tiếp Ở Đâu

- **Cách session flow qua memory** → [Chương 8 — Vòng Đời](08-vong-doi.md)
- **Cách memory được verify** → [Chương 9 — Hệ Thống Chất Lượng](09-he-thong-chat-luong.md)
- **Cách rules emerge từ memory** → [Chương 10 — Tự Cải Thiện](10-tu-cai-thien.md)
- **Inventory đầy đủ memory** → [Reference § Memory](../reference/inventory-memory.md)
