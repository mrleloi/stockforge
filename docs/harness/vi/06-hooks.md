# Chương 6 — Hooks

> **Phân khu Diataxis**: Reference + Explanation + How-to
> **Thời gian đọc**: ~60 phút
> **Điều kiện tiên quyết**: Chương 3 (Kiến Trúc) cho ngữ cảnh layer; Chương 4 (Hiến Pháp) cho ngữ cảnh rule

Hooks là layer thực thi deterministic của harness. Chúng là các shell script kích hoạt trên các event lifecycle của Claude Code và **thực thi logic non-LLM** — checks, audits, blocks, escalations, telemetry.

Đây là chương lớn nhất trong sách vì hooks là component lớn nhất. **118 hook script** + **115 firing-test companion** + **9 event được wire**. Chúng là cái khiến harness *thực thi* thay vì *gợi ý*.

Nếu bạn chỉ đọc một section của chương này, hãy đọc [§ 6.6 — The Severity Pipeline](#66--the-severity-pipeline). Đó là cascade chịu lực.

---

## 6.1 — Mô Hình Event

Claude Code kích hoạt hook event tại các thời điểm được định nghĩa rõ ràng. Harness wire hook script vào các event này qua `.claude/settings.json`:

| Event | Wired hook count | Fired when |
|---|---|---|
| **SessionStart** | 22 | New session begins (`claude` launched, `/clear`, or resume) |
| **SessionEnd** | 3 | Session terminates |
| **UserPromptSubmit** | 13 | User submits a prompt (after every Enter) |
| **PreToolUse** | 9 | Before any tool call (Bash, Read, Write, Edit, Agent, etc.) |
| **PostToolUse** | 10 | After any tool call |
| **Stop** | 50+ | LLM completes a turn (the end of every assistant response) |
| **SubagentStop** | 5 | A dispatched subagent completes |
| **PreCompact** | 1 | Before automatic context compaction |
| **Notification** | 0 (intentionally empty) | Reserved for future use |

Tổng wired-invocation count: **~113** (một số hook kích hoạt trên nhiều event).
Tổng physical script: **118** (một số là CLI utility được tái sử dụng bởi wired hook).

### Hooks Có Thể Làm Gì

Một hook là shell script nhận stdin JSON (tool call context) và trả về:

- **stdout** → được inject làm context bổ sung vào turn tiếp theo của LLM (`hookSpecificOutput.additionalContext`)
- **stderr** → được log nhưng LLM không thấy
- **exit code 0** → success; cho phép tool tiếp tục
- **exit code 2** → DENY tool call (chỉ PreToolUse)
- **exit code non-zero (other)** → điển hình được log dưới dạng warning

Contract này nhỏ nhưng mạnh mẽ. Với nó, bạn có thể:

- Block các thao tác destructive
- Inject reminder vào context của LLM
- Audit và rotate file state
- Compute và lưu telemetry
- Trigger external service (Telegram, v.v.)

---

## 6.2 — 17 Danh Mục Hook

118 hook chia thành 17 danh mục theo mục đích:

| # | Category | Count | Purpose |
|---|---|---|---|
| 1 | Bootstrap / Session Lifecycle | ~8 | Session entry/exit setup |
| 2 | Governance / Hard-Block | ~12 | PreToolUse guards (RC=2 deny) |
| 3 | Determinism / Financial-Data Integrity | ~7 | Stock-domain invariants |
| 4 | Watchdog / Severity & Escalation | ~8 | Severity pipeline (D-058) |
| 5 | Telemetry / Recording | ~10 | Append-only event logs |
| 6 | Drift Detection | ~7 | Pattern-match regression catchers |
| 7 | Rotation / Housekeeping | ~9 | Daily/weekly archival |
| 8 | Lint / Quality | ~8 | Static-lint scanners |
| 9 | Q&A Lifecycle | ~5 | Pending → answered → stale |
| 10 | Sync-Tracker (Confidence Score) | ~5 | Track 8a per-category confidence |
| 11 | Learning Loop | ~5 | Karpathy autoresearch outer-loop |
| 12 | Checkpoint / Handoff Continuity | ~6 | /clear boundary continuity |
| 13 | Budget / Context Management | ~5 | Real-token tracking |
| 14 | Coherence / Integrity | ~6 | Cross-file invariant checks |
| 15 | Bootstrap-summary / Index Render | ~4 | Aggregate into cheap-load summaries |
| 16 | Spawn / Cross-Process | ~3 | Detached Windows processes |
| 17 | Diagnostic (Unwired) | ~4 | Forensic / one-shot RC investigation |

Tổng: ~118. Một số hook span nhiều category (ví dụ, `harness-health-self-scan.sh` vừa là Watchdog vừa là Drift; `effort-escalation-detector.sh` vừa là Budget vừa là Lint).

---

## 6.3 — Stop Chain (50+ Hooks)

Event Stop kích hoạt khi LLM hoàn thành một turn. Stop chain là chain lớn nhất trong harness vì end-of-turn là khi hầu hết các ritual xảy ra: log rotation, drift detection, severity classification, cost ledgering, retention enforcement.

Chain (theo execution order, đã rút gọn):

```
1.  Inline echo to .session-hooks.log
2.  pre-clear-handoff-guard.sh          ← block if un-handed-off work
3.  tracking-retention.sh                ← cap enforcement + auto-archive
4.  telemetry-rotate.sh                  ← weekly TSV rotation
5.  session-hooks-log-rotate.sh
6.  urgent-md-rotate.sh                  ← size-triggered (4KB)
7.  dispatch-pending-rotation.sh         ← 12h archive
8.  auto-reboot-handoff-verify.sh        ← HH-H.4 outer fence
9.  budget-watchdog.sh                   ← final tally
10. autonomous-stop-watchdog.sh          ← Mode A/B/C/D detector
11. pre-checkpoint-close-verifier.sh     ← M-S67-3 pattern
12. taskcompleted-audit.sh               ← I-S1 + I-S2 sweep
13. charter-coherence-spot.sh            ← I-S35 framing check
14. adr-empirical-close-verify-spot-check.sh
15. drift-signals-D1-D9.sh               ← run drift catalog
16. sync-tracker-auto-update.sh          ← HH-B.5 Stop wrapper
17. correction-rate-aggregator.sh
18. learning-index-rebuild.sh
19. bash-hook-lint.sh                    ← producer-consumer integrity
20. file-pattern-hook-pre-flight-lint.sh
21. learning-loop-metric-check.sh        ← L-S12-1
22. research-scanner-output-validator.sh
23. self-awareness-aggregate.sh          ← sessions-rollup.tsv
24. profile-template-auto-populate.sh    ← HH-C.3
25. planner-feedback-loop.sh
26. lesson-synthesis-watchdog.sh         ← Stage 1 self-upgrade
27. severity-classifier.sh               ← PHASE A of severity pipeline
28. dogfood-the-promotion.sh
29. stop-finding-frontmatter-validator.sh
30. project-integrity-watchdog.sh        ← R2 mass-deletion
31. python-determinism-check.sh
32. atomic-write-check.sh
33. html-separator-check.sh
34. path-safety-check.sh
35. observation-orphan-detector.sh
36. escalation-engine.sh                 ← PHASE B of severity pipeline
37. pending-queue-escalator.sh
38. index-registry-renderer.sh
39. qa-stale-urgent-escalator.sh
40. qa-pending-auto-mover.sh             ← D-031 auto-mv
41. session-end-checklist-linter.sh      ← HH-C.1 mistake-log discipline
42. memory-routing-audit.sh
43. project-md-adr-staleness.sh
44. tier1-bloat-check.sh                 ← HH-5 ≤8K enforcement
45. promotion-cycle-trigger.sh           ← ≥8 lessons HARD-BLOCK
46. harness-recovery-dod-watchdog.sh
47. drift-rollup-daily.sh                ← idempotent per day
48. drift-signals-log-rotate.sh          ← MUST run AFTER rollup
49. cost-ledger-recorder.sh              ← USD tally
50. bootstrap-summary-renderer.sh        ← boot-summary.md ~2K
51. scheduled-drift-detector-trigger.sh
52. memory-etl-processor.sh
53. tool-call-first-lint.sh              ← strict-profile only
54. firing-test-spawn-context-lint.sh    ← AP-23 + L-S247-1
55. daily-backup.sh                      ← R3 mass-deletion recovery
```

### Order Coupling

Một số hook phụ thuộc vào hook khác chạy trước. Quan trọng nhất:

- **`drift-signals-log-rotate.sh` PHẢI chạy SAU `drift-rollup-daily.sh`** — same-day rotate-before-rollup sẽ zero file rollup của hôm nay.
- **`qa-pending-auto-mover.sh` PHẢI chạy SAU `qa-stale-urgent-escalator.sh`** — escalate stale bundle trước; chỉ sau đó auto-mv các bundle đã answered/closed.
- **`severity-classifier.sh` PHẢI chạy TRƯỚC `escalation-engine.sh`** — escalation đọc output của classifier.
- **`lesson-synthesis-watchdog.sh` PHẢI chạy TRƯỚC `promotion-cycle-trigger.sh`** — promotion check đọc state của synthesis.

Thứ tự wiring trong `.claude/settings.json` phản ánh điều này. Reorder thủ công sẽ phá cascade.

---

## 6.4 — SessionStart Chain (22 Hooks)

Event SessionStart kích hoạt khi Claude Code bắt đầu session mới. Chain thiết lập các prerequisite session:

```
1. inline mkdir + echo SessionStart row
2. single-claude-instance-lock.sh           ← prevent phantom-dispatch race
3. essential-routing-fields-verifier.sh     ← validate current-execution.md
4. working-memory-budget-audit.sh           ← Tier-1 ≤8K check
5. session-start-bootstrap.sh               ← emit checkpoint additionalContext
6. vendor-api-probe.sh                       ← check Anthropic API reachable
7. qa-pending-stale-mover.sh                ← move >48h Q&A bundles
8. qa-answered-detector.sh                  ← re-classify status= changes
9. sync-grilling-trigger.sh                 ← check 38-session / 7-day threshold
10. learning-queue-sweeper.sh                ← promote pending lessons
11. ghost-work-audit.sh                     ← in-flight subagent orphan check
12. proposal-bundle-advisor.sh              ← 48h cool-down ready check
13. checkpoint-marker-cleanup-resume.sh     ← surface next_action
14. in-flight-subagent-watcher.sh           ← unattended dispatch check
15. session-start-scan-unattested-observations.sh
16. idle-escape-detector.sh SessionStart    ← routine-idle pattern
17. phase-status-coherence.sh SessionStart  ← project.md ↔ current-execution.md
18. harness-health-self-scan.sh SessionStart ← HH-1..HH-12 catalog
19. idle-state-advisory.sh SessionStart
20. escalation-engine.sh SessionStart       ← act on .severity-state.tsv
21. continue-injector-spawn.sh              ← dispatch /clear continue (last in chain)
22. component-telemetry.sh                  ← inline .* matcher
```

### Quy Tắc Last-Position của `continue-injector-spawn.sh`

Hook này được wire **last** trong SessionStart chain vì nó spawn một detached PowerShell process qua `Start-Process`. Trên Windows theo kinh nghiệm, spawn này cắt phần còn lại của SessionStart chain. Đặt nó cuối có nghĩa là việc cắt không còn suppress các hook downstream.

Đây là một trong nhiều vết sẹo Windows-portability trong harness; xem [§ 6.10 — Vết Sẹo Windows Portability](#610--vết-sẹo-windows-portability).

---

## 6.5 — UserPromptSubmit Chain (13 Hooks)

Kích hoạt trên mỗi user prompt:

```
1.  block-control.sh check-prompt           ← auto-clear on "approved" reply
2.  autonomous-block-enforcer.sh            ← BLOCKED flag enforcement
3.  escalation-engine.sh UserPromptSubmit   ← re-act on severity state
4.  userprompt-invariants-injector.sh       ← inject I-S1/I-S2/I-S35 reminders
5.  stale-prompt-detector.sh                ← flag >24h old references
6.  correction-rate-tracker.sh              ← count user corrections per turn
7.  in-flight-subagent-watcher.sh           ← orphan check
8.  hook-firing-counter.sh                  ← tally per-turn fires
9.  effort-escalation-detector.sh           ← recommend /effort ladder
10. idle-escape-detector.sh UserPromptSubmit
11. phase-status-coherence.sh UserPromptSubmit
12. harness-health-self-scan.sh UserPromptSubmit (cached if <5min)
13. idle-state-advisory.sh UserPromptSubmit
```

Stop chain chạy sau mỗi assistant turn kết thúc; UserPromptSubmit chain chạy sau mỗi user turn kết thúc. Cùng nhau chúng bracket mỗi turn.

---

## 6.6 — Severity Pipeline (D-058)

Severity pipeline là hệ thần kinh trung tâm của harness. Bốn phase, fan-out qua các event:

```
┌──────────────────────────────────────────────────────────────────┐
│ DETECTORS (drift, dogfood, frontmatter, orphan, etc.)            │
│   ↓ append to .session-hooks.log + .drift-signals.log            │
│                                                                  │
│ PHASE A — severity-classifier.sh (Stop, late-chain)              │
│   ↓ scans across artifact types                                  │
│   ↓ emits normalized rows to .severity-state.tsv                 │
│   ↓ levels: CRITICAL / HIGH / MEDIUM / LOW                       │
│                                                                  │
│ PHASE B — escalation-engine.sh (Stop + SessionStart +            │
│           UserPromptSubmit; multi-cadence)                        │
│   ↓ reads .severity-state.tsv                                    │
│   ↓ CRITICAL → write .autonomous-BLOCKED + URGENT + Telegram     │
│   ↓ HIGH → URGENT + UserPromptSubmit context + Telegram          │
│   ↓ MEDIUM → weekly digest                                       │
│   ↓ LOW → log only                                               │
│                                                                  │
│ PHASE C — autonomous-block-enforcer.sh (PreToolUse +             │
│           UserPromptSubmit; FIRST in chain)                       │
│   ↓ reads .autonomous-BLOCKED flag                               │
│   ↓ PreToolUse: deny Edit/Write/Bash/MultiEdit/Agent (RC=2)      │
│   ↓ Read/Glob/Grep allowed for diagnostic                        │
│   ↓ UserPromptSubmit: loud BLOCKED context via stdout            │
│   ↓ Override: STOCKFORGE_FORCE_AUTONOMOUS=1 (logged)             │
│                                                                  │
│ PHASE D — telegram-push.sh (called by escalation-engine for       │
│           CRITICAL/HIGH only)                                     │
│   ↓ reads $STOCKFORGE_TELEGRAM_BOT_TOKEN +                       │
│     $STOCKFORGE_TELEGRAM_CHAT_ID from settings.local.json        │
│   ↓ idempotency: SHA-keyed per-hour marker                       │
│   ↓ DRY_RUN mode for testing                                     │
└──────────────────────────────────────────────────────────────────┘
```

### Điều Gì Xảy Ra Nếu Bạn Xóa Một Phase

Cascade dễ vỡ. Xóa bất kỳ phase nào sẽ mở một gap:

- **Xóa `severity-classifier.sh`**: escalation-engine thấy state rỗng → không có escalation → silent regression của mọi drift class. Auto-block path đi dark.
- **Xóa `escalation-engine.sh`**: severity rows tích lũy nhưng không bao giờ escalate; `.autonomous-BLOCKED` không bao giờ được ghi → main session tiếp tục chạy qua những thứ đáng lẽ phải hard-block.
- **Xóa `autonomous-block-enforcer.sh`**: BLOCKED flag được set nhưng tool calls không bị deny — gate chỉ trở thành advisory. Deadlock mode S316 (cần `rm` thủ công) quay lại.
- **Xóa `telegram-push.sh`**: blocks vẫn hoạt động; user chỉ không nhận push notifications. (Xóa ít tác động nhất.)

### Severity Schema (D-058 / S310 Ratification)

| Level | Triggers | Action |
|---|---|---|
| **CRITICAL** | Stale-checkpoint marker, Q&A age ≥96h, charter-violation marker, ghost-greening marker, mistake-log severity=critical | Write `.autonomous-BLOCKED` flag; URGENT entry to `urgent.md`; Telegram push |
| **HIGH** | Q&A age ≥6h pending, charter-tier ADR PROPOSED age ≥24h, mistake-log severity=high, notification ALERT-URGENT keyword | URGENT entry; UserPromptSubmit additionalContext demanding `AskUserQuestion`; Telegram push |
| **MEDIUM** | ARCH/SCOPE PROPOSED age ≥12h, notification WARN | Weekly `digest-<YYYY-Www>.md` |
| **LOW** | Below thresholds | Log only |

**Filters** (skip những cái này dù pattern khớp):
- Bundles có status `answered/closed/resolved`
- Files đặt tên `_template.md`, `README.md`, `TEMPLATE.md`, `index.md`
- `urgent.md`, `digest-*.md` (self-loop prevention)

---

## 6.7 — Hook Deep-Dives Tiêu Biểu

Các hook quan trọng nhất, được giải thích.

### `single-claude-instance-lock.sh` — Governance / SessionStart

**Purpose**: Ngăn **phantom-dispatch race condition** khi nhiều instance `claude.exe` đồng thời chia sẻ `current-execution.md` và mỗi cái dispatch cùng một active task.

**Origin**: Cluster M-S238-2, L-S239-4, L-S240-5 — 4 sự cố "hai parent đều chạy autonomous-mode, đều dispatch sandwich-verifier, composite observation file với nội dung dư thừa".

**Mechanism**: Lock file `.claude-instance.lock` format `claude_pids=<csv>:created=<epoch>:session_id=<sid_or_unknown>`. Điều kiện block là **cả hai**:
1. Staleness floor: `now - created < 7200s`
2. Liveness: bất kỳ PID lưu trữ nào vẫn alive trong `tasklist` hiện tại VÀ không phải `claude.exe` duy nhất

Cleaned bởi inline SessionEnd `rm -f` (settings.json:248).

**Empirical RC discovery** (lock-rc-probe.sh): `$PPID == 1` trong spawned hook context (strategy `c` ancestor-walk fail); `session_id` từ stdin JSON LÀ đáng tin cậy.

**Severity**: BLOCK (exit non-zero).

### `destructive-command-guard.sh` — Governance / PreToolUse

**Purpose**: Block CLASSES destructive command tại PreToolUse, áp dụng cho CẢ main session VÀ mọi subagent.

**Origin**: Sự cố mass-deletion 2026-05-14 — ~2688 file bị phá hủy bởi thao tác `find -newer` / git trong cửa sổ thực thi subagent; transcript 0-byte để lại command chính xác không thể khôi phục.

**Mechanism**: Đọc Bash command từ stdin JSON `tool_input.command`, khớp với các pattern destructive, narrow safe-allowlist. Override: `STOCKFORGE_ALLOW_DESTRUCTIVE=1` (logged to mistake-log).

**Cặp với**: `daily-backup.sh` (R3) và `project-integrity-watchdog.sh` (R2) là three-prong mass-deletion prevention.

**Severity**: HARD BLOCK (exit RC=2).

### `write-vs-edit-guard.sh` — Governance / PreToolUse

**Purpose**: Thực thi **doctrine L-S45-2** sinh ra từ sandwich-architect data-loss 2026-05-05.

**Origin**: Một subagent gọi `Write` trên `agent-workspace/memory/agent-notes.md` thay vì `Edit`, ghi đè destructively ~470 LOC accumulated learned rules với stub ~40 LOC (~140 dòng mất vĩnh viễn).

**Mechanism**: Cho file dưới `agent-workspace/memory/{agent-notes,project,mistake-log}.md` và `agent-workspace/{constitution,proposals,session-plans}/**/*.md`, append/insert qua `Edit` ONLY. `Write` reserved cho file thực sự mới (existence-check qua `Glob` trước).

**Severity**: HARD BLOCK (exit RC=2).

### `budget-watchdog.sh` — Watchdog / PostToolUse + Stop

**Purpose**: Track real token consumption từ transcript JSONL; auto-trigger reboot tại cliff.

**Mechanism**: Đọc transcript JSONL qua `node`, sum real token usage từ records `usage`, auto-trigger `session-self-reboot.sh` tại các threshold.

**Defaults** (per D-004 — UP-07 Opus 4.7 recalibration):
- `STOCKFORGE_WIND_DOWN_TOKENS=180000`
- `STOCKFORGE_CLIFF_TOKENS=220000`
- `STOCKFORGE_HARD_CAP=250000`

ORCH_* legacy fallback envs được preserve cho migration.

**Mode-C guard** (Stop-only): block premature turn-end khi LLM cite budget pressure nhưng real tokens dưới threshold — emit decision JSON ra stdout.

**Atomic noclobber markers**: `.cliff-fired`, `.wind-down`.

**Defense-in-depth**: honors `.auto-reboot-PRE-BLOCKED-stale-checkpoint` marker từ `auto-reboot-handoff-verify.sh`.

**Severity**: BLOCK tại cliff; warn tại wind-down.

### `harness-health-self-scan.sh` — Watchdog / SessionStart + UserPromptSubmit

**Purpose**: Continuous harness-health verification (Charter Principle 11).

**Mechanism**: Chạy catalog 12-signal HH-1..HH-12 codified trong [`harness-health-protocol.md`](../../../agent-workspace/constitution/harness-health-protocol.md).

**Cheap-first signal ordering**:
1. HH-7 (checkpoint mtime)
2. HH-11 (log mtime)
3. HH-8 (md5)
4. HH-1 (Stop fires ≥1/session)
5. HH-2 (UserPromptSubmit ≤10min)
6. HH-9 (mistake-log freshness)
7. HH-3 (promote-rule ≤10d)
8. HH-6 (multi-file mtime + tail)
9. HH-4 (auto-detect orphans ≤2)
10. HH-10 (firing-test orphans ≤2)
11. HH-5 (delegated hook)
12. HH-12 (project.md Phase == current-execution.md Phase)

**Caching**: 5-min same-session cache qua `.harness-health-cache-${SID}`.

**KI suppression**: KI-S49b-1 downgrade HH-1 HIGH→MEDIUM trên Windows Stop-not-firing quirk.

**Aggregation states**: GREEN / YELLOW / RED-1 / RED-2.

**Severity**: info; luôn RC=0 (informational).

### `escalation-engine.sh` — Severity / Stop + SessionStart + UserPromptSubmit

**Purpose**: Phase B của unified severity/escalation system.

**Mechanism**: Đọc `.severity-state.tsv` (produced by `severity-classifier.sh`) và hành động theo severity row.

**Multi-cadence design**: severity surface tại ba cửa sổ khác nhau (turn end, new session, prompt arrival) để dù user dismiss một prompt, event tiếp theo re-fire.

**Severity**: ghi `.autonomous-BLOCKED` flag (tách biệt với exit code).

### `dispatch-jsonl-recorder.sh` — Telemetry / PreToolUse + SubagentStop + PostToolUse

**Purpose**: Per-Agent-call telemetry recording.

**Origin**: D-023 v2 schema + HH-B.1/B.2 telemetry.

**Mechanism**:
- `PreToolUse(Agent)` ghi `DISPATCHED` row + sidecar keyed by `tool_use_id`.
- `SubagentStop` ghi `COMPLETED` row với **FIFO-matched** `tool_use_id` (HH-B.1 thay thế regex `agentId: <hex>` bị hỏng; filter by `parent_session_id`, tìm `DISPATCHED` oldest không có `COMPLETED` matching) và đọc `transcript_path` để populate `tokens_real` + `duration_ms` + `failure_mode` (HH-B.2).

Ported từ orch v2.2.0 với map stockforge subagent_type→model.

**Severity**: telemetry-only (RC=0).

### `python-determinism-check.sh` — Determinism / PostToolUse + Stop

**Purpose**: Thực thi 4 pattern non-determinism bị cấm trong Python production code.

**Origin**: Ported từ doctrine DST `nautilus_trader` (SHA `dd49f70`, ADR D-059).

**Banned patterns** trong `packages/**/*.py` + `apps/**/*.py`:
- **R1**: `datetime.now()` không có timezone arg → ERR
- **R2**: `random.random()/randint()/secrets.token_*()` bên ngoài `__main__` hoặc `test_*.py` → ERR
- **R3**: Heuristic giả định Dict iteration order → WARN
- **R4**: `time.time()` trong `packages/domain/**` → ERR

**Companion ports cùng cadence**:
- `atomic-write-check.sh` (TradingAgents AW-R1..R4 atomic temp-replace)
- `html-separator-check.sh` (TradingAgents HTML entry separator)
- `path-safety-check.sh` (Vibe-Trading P1-P5 sandbox/UNC/zone)

Cả bốn thực thi **Charter Principle 11** trên Python-primary stack. Violations land trong `.severity-state.tsv` là HIGH.

### `drift-signals-D1-D9.sh` — Drift / Stop

**Purpose**: Composite drift detector chạy 9 grep-based signals.

**Tier-A signals**: DR-A1 LOC ceiling overrun (PRIMARY per Q-A2), DR-A2 self-attestation mâu thuẫn với nội dung file thực tế, DR-A3 Charter/SCOPE bundled với sub-charter items, DR-A4 confidence claim không có calibration metadata, DR-A5 runtime-path-leak vào write-only learning-data tree, DR1 domain layer import framework, DR3 LLM call không có retry/budget wrapper, DR6 `Any` type trong domain package, DR8 cross-BC direct import.

**D9** = runtime-path-leak. **D10** = no `import anthropic` / `ANTHROPIC_API_KEY` (ported to `no-anthropic-sdk-d10.sh`).

**Output**: Append violations vào `.drift-signals.log`, sau đó `drift-rollup-daily.sh` promote chúng lên `drift-logs/YYYY-MM-DD-rollup.md` (idempotent per day), sau đó `drift-signals-log-rotate.sh` rotate hàng tuần.

### `tracking-retention.sh` — Rotation / Stop

**Purpose**: Thực thi retention cap trên tracking files; auto-migrate over-cap rows.

**Origin**: S99 RCA Layer 1 retention guard (Q-RCA-1 = A).

**Caps**:
- `current-execution.md` ≤ 5 sessions / ≤ 200 LOC (AUTO-MIGRATES oldest session row to archive)
- `agent-notes.md` digest only / ≤ 700 LOC
- `mistake-log.md` digest only / ≤ 200 LOC
- `component-telemetry.jsonl` ≤ 10 MB (handled by `telemetry-rotate.sh`)

Empirically validated qua S132/S133/S134 manual instances. WARN-only (RC=0); auto-migrate branch là cơ chế deterministic, không phải block.

### `cost-ledger-recorder.sh` — Telemetry / Stop + SubagentStop

**Purpose**: Append-only USD cost ledger per session + subagent dispatch.

**Origin**: S65 user request "tracking cost real not estimate" + I-S1 NO LLM math (awk compute, không phải LLM).

**Schema** (TSV):
```
timestamp \t session_id \t actor \t model \t tokens_in \t tokens_out \t cache_read \t cache_create \t cost_usd \t hook_event
```

**Pricing table** (Anthropic public 2025-2026):
- opus: $15 / $75 per MTok in/out
- sonnet: $3 / $15
- haiku: $0.80 / $4
- cache_read = 10% input
- cache_create = 125% input

**Severity**: telemetry-only (RC=0).

### `checkpoint-write-end-turn-watchdog.sh` + `checkpoint-write-marker.sh` — Continuity Pair

**Purpose**: Thực thi **rule L-S49b-4** — "checkpoint write = end turn".

**Origin**: M-S49b-2 — LLM tiếp tục thực thi action SAU khi ghi checkpoint, gây duplicate dispatch qua `/clear` boundary + mất subagent work.

**Mechanism**:
- `checkpoint-write-marker.sh` (PostToolUse) kích hoạt sau bất kỳ Edit/Write/MultiEdit; nếu file là `checkpoints/latest.md`, ghi session-scoped marker `.checkpoint-written-<session_id>` (và cũng `.fresh-resume-pending-<session_id>` nếu `autonomous_mode=true`).
- `checkpoint-write-end-turn-watchdog.sh` (PreToolUse) đọc marker; nếu set, deny bất kỳ tool call non-exempt nào sau đó với RC=2.
- Marker cleared trên SessionStart bởi `checkpoint-marker-cleanup-resume.sh`, cái cũng surface autonomous-resume `next_action` lên LLM của session mới qua system-reminder.

**Thay thế** cơ chế Mode-D SendKeys "continue" đã bị thu hồi.

**Severity**: HARD BLOCK (exit RC=2).

### `daily-backup.sh` — Rotation / Stop

**Purpose**: R3 của mass-deletion prevention 2026-05-14.

**Mechanism**: Mỗi ngày dương lịch một lần, compress critical directories vào `$STOCKFORGE_BACKUP_DIR` (default `<project-parent>/stockforge-backups/`) **out-of-tree**.

**Retention**: 14 ngày.

**Includes**: `agent-workspace/`, `scripts/`, `.claude/`, `packages/`, `bdd/`, `specs/`, root `*.md`.

**Excludes**: `.git`, `node_modules`, `__pycache__`, `.*_cache`, forensic dirs, chính backup dir.

**Idempotency**: per-day marker.

**Severity**: RC=0 luôn.

---

## 6.8 — 3-Prong Mass-Deletion Defense

Vào 2026-05-14, một mass deletion dựa trên recency (S316 verifier window) đã phá hủy ~2688 file. Recovery yêu cầu `git clone` + `git checkout HEAD --`. Phản ứng của harness là 3-prong defense:

| Prong | Role | Hook |
|---|---|---|
| **R1 — Prevention** | Block destructive commands tại PreToolUse | `destructive-command-guard.sh` |
| **R2 — Detection** | Detect mass-deletion-in-progress tại Stop; ghi `.autonomous-BLOCKED` trực tiếp | `project-integrity-watchdog.sh` |
| **R3 — Recovery** | Out-of-tree 14-day backup, daily idempotent | `daily-backup.sh` |

Xóa bất kỳ prong nào sẽ mở lại failure mode tại một layer khác (R1 = prevention, R2 = detection, R3 = recovery).

---

## 6.9 — Firing-Test Discipline (Nguyên Tắc 11)

Per Charter Principle 11: **mọi hook ship với một firing-test companion**.

### Convention

`scripts/hooks/firing-tests/` chứa **115 file `*-fire-test.sh`** cộng với `run-all.sh`.

**Naming rule** (enforced bởi `harness-health-self-scan.sh` HH-10): cho mỗi `scripts/hooks/<name>.sh` phải có một companion `scripts/hooks/firing-tests/<name>-fire-test.sh`.

**Tolerance**: HH-10 kích hoạt chỉ khi **orphans > 2** (current state: 118 hook − 115 fire-test = 3 missing; HH-10 kích hoạt tại HH-10-FIRING-TEST-ORPHAN MEDIUM).

### Cấu Trúc Firing-Test

Mỗi fire-test:

```bash
#!/usr/bin/env bash
# <hook-name>-fire-test.sh
# SPAWN-CONTEXT: <form>  ← required for bash-c / stdin-redirect / env-wrap-B hooks
set -uo pipefail

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT
export CLAUDE_PROJECT_DIR="$TEMPDIR"

# Pipe synthetic stdin JSON simulating the hook event payload
echo '{"session_id":"test-sid", ...}' | bash "$HOOK_PATH" PreToolUse

# Assert observable state changes
[ -f "$TEMPDIR/expected-marker" ] || { echo "FAIL"; exit 1; }
grep -q "expected log entry" "$TEMPDIR/.session-hooks.log" || { echo "FAIL"; exit 1; }

echo "PASS"
exit 0
```

### `SPAWN-CONTEXT` Marker

`firing-test-spawn-context-lint.sh` (per AP-23 + L-S247-1) yêu cầu mỗi fire-test khai báo `# SPAWN-CONTEXT: <form>` để lint biết liệu các form arg-passing non-default có ship với companion test hay không.

- **Form-A** (env-prefix `VAR=val bash ...`): broken trên Windows; deprecated
- **Form-B** (env-wrap `env VAR=val bash ...`): yêu cầu marker
- **Form-C** (positional-arg `bash hook.sh ARG1`): exempt
- **bash-c** (`bash -c "..."`): yêu cầu marker
- **stdin-redirect** (`... < file`): yêu cầu marker

### `run-all.sh` Orchestrator

```bash
PER_TEST_TIMEOUT="${FIRING_TEST_TIMEOUT:-30}"
for test in "$SCRIPT_DIR"/*-fire-test.sh; do
  timeout "$PER_TEST_TIMEOUT" bash "$test" >/dev/null 2>&1
  rc=$?
  ...
done
echo "=== firing-test suite: ${PASS}/${TOTAL} PASS (elapsed ${ELAPSED}s) ==="
```

**KHÔNG** auto-wired vào Stop hook (sẽ làm chậm mỗi turn). Chạy thủ công post-hook-edit hoặc qua `bash scripts/hooks/firing-tests/run-all.sh`. Trả về 0 chỉ khi ALL pass; timeout phát hiện (`rc=124`) được liệt kê riêng.

### Tại Sao HH-10 Đếm Presence, Không Phải Pass

HH-10 bắt anti-pattern **hook-without-fire-test**; `run-all.sh` bắt **fire-test-fails** trong edit cycles. Chúng bổ sung cho nhau, không thừa.

---

## 6.10 — Vết Sẹo Windows Portability

Hooks layer mang một bề mặt Windows-compatibility đáng kể:

- **`single-claude-instance-lock.sh`** PID resolution: `$PPID == 1` trong spawned hook context; dùng `tasklist //V` thay vì `ps`.
- **`continue-injector-spawn.sh`** trích ra last-of-chain để né PowerShell `Start-Process` truncation của SessionStart (sự cố S183/S184).
- **`settings-inline-env-prefix-detector.sh`** bắt pattern `VAR=val cmd` fail im lặng trong Claude Code Windows hook runtime (S208 → 2-day production dormancy của HH-1/idle-escape/phase-status-coherence).
- **`bash-hook-lint.sh`** thực thi L-S11-1 (Phase 0 bash + POSIX only; không python/jq/yq).
- **`firing-test-spawn-context-lint.sh`** bắt Form-A/B env-wrap defect pass trên Linux nhưng fail trên Windows executor.
- **KI-S49b-1 suppression** trong `harness-health-self-scan.sh` HH-1 downgrade HIGH→MEDIUM khi Stop hook theo kinh nghiệm không kích hoạt trên Windows quirks.

Các vết sẹo này là lý do bash hook phải tuân theo các portability rule nghiêm ngặt — xem [`portability.md`](../../../agent-workspace/constitution/portability.md).

---

## 6.11 — Unwired CLI Utilities

Một số script trong `scripts/hooks/` không phải là Claude Code event hook mà là utility được wired hook tái sử dụng:

| Utility | Called by |
|---|---|
| `redact-secrets.sh` | `session-export-raw.sh` |
| `telegram-push.sh` | `escalation-engine.sh`, `block-control.sh` |
| `sync-tracker-update.sh`, `sync-tracker-render.sh` | `sync-tracker-auto-update.sh`, `sync-grilling-call.sh` |
| `continue-injector.ps1` | `continue-injector-spawn.sh` |
| `block-control.sh raise/clear/status/check-prompt` | CLI subcommand interface |
| `dispatch-jsonl-backfill.sh` | One-shot CLI utility (S180 backfill task) |
| `lock-rc-probe.sh` | Unwired; giữ cho RC investigation tương lai |
| `diagnostic-pretooluse-stash.sh`, `diagnostic-subagentstop-stash.sh` | Forensic stdin capture (unwired) |
| `metric-failure-mode-rate.sh` | Unwired; tính failure-mode rate (S12 framing) |

Xóa bất kỳ cái nào sẽ silently break wired-hook gọi chúng.

---

## 6.12 — Checklist Tác Giả Hook

Khi thêm hook mới:

- [ ] Chọn event đúng (SessionStart? Stop? PreToolUse?)
- [ ] Viết script dưới `scripts/hooks/<name>.sh`
- [ ] Header comment: purpose, trigger, severity, origin (ADR / lesson ID)
- [ ] `set -uo pipefail` + `trap 'exit 0' ERR` (hầu hết hook không nên block)
- [ ] Cheap-first ordering cho multi-check hooks
- [ ] Idempotency markers nếu Stop-tier (hour-bucket / day-bucket)
- [ ] Same-session caching nếu UserPromptSubmit-tier
- [ ] Honor `STOCKFORGE_HOOK_PROFILE=strict` cho warn-vs-block
- [ ] Viết firing-test companion tại `scripts/hooks/firing-tests/<name>-fire-test.sh`
- [ ] `SPAWN-CONTEXT:` marker nếu non-default arg form
- [ ] ≥3 test case cover positive + negative + edge
- [ ] Wire trong `.claude/settings.json` (event đúng, order đúng vs dependencies)
- [ ] Chạy `bash scripts/hooks/firing-tests/<name>-fire-test.sh` — phải PASS
- [ ] Chạy `bash scripts/hooks/firing-tests/run-all.sh` — phải show không regression
- [ ] Document trong [Reference § Hooks](../reference/inventory-hooks.md) (hoặc chạy `/harness-docs sync`)
- [ ] Xác minh production firing trong `.session-hooks.log` trong session thực tiếp theo (Principle 11)

---

## 6.13 — Đọc Tiếp Ở Đâu

- **Các memory artifact** hooks đọc và viết → [Chương 7 — Hệ Thống Bộ Nhớ](07-he-thong-bo-nho.md)
- **Các lifecycle event** hooks chi phối → [Chương 8 — Vòng Đời](08-vong-doi.md)
- **Các quality check** hooks thực thi → [Chương 9 — Hệ Thống Chất Lượng](09-he-thong-chat-luong.md)
- **Cách rules trở thành hook** → [Chương 10 — Tự Cải Thiện](10-tu-cai-thien.md)
- **Viết hook của riêng bạn** → [Chương 11 § Viết Một Hook](11-cong-thuc.md#viet-mot-hook)
- **Inventory đầy đủ hook** → [Reference § Hooks](../reference/inventory-hooks.md)
