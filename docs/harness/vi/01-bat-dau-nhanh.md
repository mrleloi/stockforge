# Chương 1 — Bắt Đầu Nhanh

> **Phân khu Diataxis**: Tutorial (học qua làm)
> **Thời gian đọc**: ~30 phút thực hành
> **Điều kiện tiên quyết**: Claude Code đã cài đặt, repository này đã clone, Python 3.11+, có shell access

Chương này đưa bạn từ "Tôi chưa từng thấy harness này" đến "Tôi đã chạy hoàn chỉnh một session qua nó". Bạn sẽ:

1. Bootstrap một session.
2. Quan sát harness nạp context.
3. Dispatch một sandwich-pattern subagent.
4. Quan sát một hook fire.
5. Đóng session một cách gọn gàng.

Nếu có gì trong output làm bạn ngạc nhiên, đó là cố ý — mục tiêu là *nhìn thấy* harness, không chỉ đọc về nó.

---

## Bước 1 — Mở một Session

Trong terminal ở project root:

```bash
cd /c/htdocs/stockforge
claude
```

Claude Code khởi động. Đằng sau hậu trường, harness đã fire **22 SessionStart hook** tuần tự rồi. Bạn có thể verify bằng cách tail hook log:

```bash
tail -30 agent-workspace/memory/.session-hooks.log
```

Bạn sẽ thấy các entry như:

```
[2026-05-19T01:05:12+07:00] SessionStart session=abc... cwd=/c/htdocs/stockforge profile=standard
[2026-05-19T01:05:12+07:00] single-claude-instance-lock: acquired lock pid=...
[2026-05-19T01:05:13+07:00] essential-routing-fields-verifier: OK current-execution.md autonomous_mode=true
[2026-05-19T01:05:13+07:00] working-memory-budget-audit: under-ceiling 17320B/20480B
[2026-05-19T01:05:13+07:00] session-start-bootstrap: latest checkpoint loaded
...
[2026-05-19T01:05:14+07:00] continue-injector-spawn: skipped (not /clear path)
```

Mỗi dòng trong số này là một hook báo cáo về. Không cái nào trong số đó block session. Nếu có cái nào block, bạn sẽ thấy một error context thay vào đó.

**Điều vừa xảy ra**: harness đã verify workspace ở trạng thái known-good, nạp file routing (`agent-workspace/memory/current-execution.md`), đo working-memory load, check các Q&A bundle cũ, scan các subagent in-flight từ session trước, và audit 12 health signal. Tất cả trước khi Claude chào hỏi.

---

## Bước 2 — Gõ `/session-start`

```
/session-start
```

Đây là một [slash command](05-skills-commands-agents.md#commands). Nó là một wrapper mỏng làm việc mà bạn sẽ phải làm thủ công nếu không có nó: nạp file routing, xác định session type, ước tính budget, tra cứu các plan khớp, và sản xuất một brief.

Output sẽ trông giống như:

```markdown
# Session Brief — 2026-05-19 Session N

## Goal
[Inferred from current-execution.md active focus]

## Session Type
[PLAN | FOCUSED_IMPL | ... | THESIS] — chosen via decision tree in
agent-workspace/constitution/session-budgets.md

## Context Budget Estimate
- Fixed overhead: 12K / Variable: 25K / Working: 60K → Total: ~97K (of 250K cap)

## Status Check
- Active phase: Phase 4 — Multi-perspective (Wave 1 Phase D NDH adapter)
- Recent sessions (last 3):
  - S407 — plan-044 G.4 IMPL SHIPPED
  - S408 — plan-044 G.4 VERIFY PASS-WITH-CONCERNS
  - S409 — this one
- Pending from last session: none

## Files Loaded / Skills Relevant / Constraints Active
[Lists]

## Proposed Next Actions
1. ...
2. ...

Ready to proceed? Confirm or adjust.
```

**Điều vừa xảy ra**: agent đã nạp sáu file bộ nhớ theo thứ tự ưu tiên (theo [Reading Priority](../../../agent-workspace/CLAUDE.md)), xác định rằng bạn đang ở giữa Phase 4, ước tính bao nhiêu context budget session sẽ tiêu, và sản xuất một brief mà *bạn* có thể sanity-check trước khi bất kỳ công việc thật nào bắt đầu.

Đây là pattern harness ở dạng vi mô: **deterministic loading + structured proposal + human confirmation gate**.

---

## Bước 3 — Dispatch một Sandwich Architect

Giả sử mục tiêu của bạn là thêm một tính năng nhỏ. Kỷ luật của harness nói rằng: **không bao giờ plan và implement trong cùng một session**. Plan trước, implement sau.

Gõ:

```
/master-plan add support for VPB ticker to the thesis runner
```

Command `/master-plan` dispatch subagent [`master-planner`](05-skills-commands-agents.md#master-planner) trong một context tươi mới. Bạn sẽ thấy một notification như:

```
Async agent launched successfully.
agentId: ab7f3a9d...
```

Agent giờ đang làm việc song song. Nó đọc:

- Charter (`PROJECT_CHARTER.md`)
- Phase đang chạy (`current-execution.md`)
- Các file constitution liên quan
- Các plan hiện có trong `session-plans/pending/`
- Các plan trong quá khứ tương tự trong `session-plans/completed/`

Sau ~2-5 phút, bạn nhận được notification hoàn tất:

```
<task-notification>
<status>completed</status>
<summary>Master plan written to session-plans/pending/NNN-S<sid>-vpb-thesis.md</summary>
</task-notification>
```

Đọc plan mới. Nó sẽ ~700-1100 dòng, có cấu trúc gồm các section A-N, với VBW step zero, các sub-track, file scope, DoD, và risk. **Architect không viết bất kỳ production code nào**. Đó là một session riêng.

**Điều vừa xảy ra**: bạn đã chứng kiến [sandwich pattern](08-vong-doi.md#sandwich-pattern) bắt đầu. Step 1 trong 3 (architect) đã hoàn tất. Step 2 (dev) và Step 3 (verifier) tiếp theo trong session riêng của chúng, mỗi cái với context của riêng nó.

---

## Bước 4 — Quan Sát một Hook Block Bạn

Thử làm điều gì đó mà harness không cho phép:

```
git push origin main
```

Bạn sẽ bị block. Output:

```
[BLOCK] git push is in the .claude/settings.json deny list.
Agents MAY commit; agents MUST NOT push.
See agent-workspace/CLAUDE.md § Contract Rule 6.
```

Block đến từ PreToolUse hook [`destructive-command-guard.sh`](06-hooks.md#destructive-command-guard) đọc quy tắc deny trong settings.json trước khi công cụ Bash chạy.

Thử cái khác:

```
rm -rf agent-workspace/
```

Cũng bị block. Lần này block đến từ cùng hook khớp pattern `rm -rf`. Hook này được viết vào ngày 2026-05-14 để phản ứng trực tiếp với một **sự cố mass-deletion thực sự** đã mất ~2688 file. Post-mortem ở tại [`agent-workspace/post-mortems/2026-05-14-mass-deletion-recovery.md`](../../../agent-workspace/post-mortems/2026-05-14-mass-deletion-recovery.md).

**Điều vừa xảy ra**: bạn đã trải nghiệm [defense-in-depth](06-hooks.md#defense-in-depth). Deny list bắt *categories* các command phá hoại, không phải các instance cụ thể. Có 118 guard như vậy được xếp lớp trên 9 hook event.

---

## Bước 5 — Quan Sát Stop Chain Fire

Kết thúc session của bạn với `/session-end` hoặc đơn giản gõ `exit`. Harness fire Stop chain của nó — **hơn 50 hook** tuần tự:

```bash
tail -60 agent-workspace/memory/.session-hooks.log
```

Bạn sẽ thấy các entry như:

```
[2026-05-19T01:35:42+07:00] Stop session=abc...
[2026-05-19T01:35:42+07:00] pre-clear-handoff-guard: OK
[2026-05-19T01:35:42+07:00] tracking-retention: current-execution.md=180 LOC (cap 200) PASS
[2026-05-19T01:35:42+07:00] budget-watchdog: tokens=97000 / 250000 (38%) — under wind-down threshold
[2026-05-19T01:35:43+07:00] charter-coherence-spot: 0 violations
[2026-05-19T01:35:43+07:00] adr-empirical-close-verify-spot-check: no new ADRs this session
[2026-05-19T01:35:43+07:00] drift-signals-D1-D9: PASS (0 high / 0 medium)
[2026-05-19T01:35:44+07:00] sync-tracker-auto-update: 1 event recorded
[2026-05-19T01:35:44+07:00] cost-ledger-recorder: 0.0247 USD ledgered
[2026-05-19T01:35:45+07:00] severity-classifier: 0 CRITICAL / 0 HIGH / 1 MEDIUM (stale-checkpoint)
[2026-05-19T01:35:45+07:00] escalation-engine: MEDIUM → digest only
[2026-05-19T01:35:45+07:00] session-end-checklist-linter: PASS
[2026-05-19T01:35:46+07:00] daily-backup: SKIP (already backed up today)
```

Cái bạn đang quan sát là **end-of-session checklist** của harness chạy deterministic. Nó:

- Verify bạn không có công việc chưa handed-off (`pre-clear-handoff-guard`)
- Rotate các file tracking nếu vượt cap (`tracking-retention`)
- Tính dollar cost của session bạn (`cost-ledger-recorder`)
- Phát hiện bất kỳ vi phạm drift signal nào (`drift-signals-D1-D9`)
- Phân loại severity của bất kỳ pending item nào (`severity-classifier`)
- Quyết định có escalate đến bạn không (`escalation-engine`)
- Lint xem bạn đã ghi nhận mistake hoặc attest zero (`session-end-checklist-linter`)

Nếu bất kỳ check nào tạo ra severity CRITICAL hoặc HIGH, bạn sẽ thấy một notification `urgent.md` và (nếu được cấu hình) một Telegram message.

**Điều vừa xảy ra**: session đã đóng gọn gàng. Harness đã ghi mọi thứ vào đĩa mà session tiếp theo cần: một `current-execution.md` đã cập nhật, một session log mới tại `agent-workspace/memory/sessions/2026-05-19-session-N.md`, một checkpoint tại `agent-workspace/memory/checkpoints/latest.md`, và telemetry append-only.

---

## Cái Bạn Vừa Thấy

Trong 30 phút, bạn đã quan sát:

| Layer | Ví dụ |
|---|---|
| **Hooks** | 22 SessionStart + 50+ Stop fire theo thứ tự |
| **Commands** | `/session-start`, `/master-plan`, `/session-end` |
| **Subagents** | `master-planner` được dispatch vào context tươi mới |
| **Memory** | `current-execution.md`, session log, checkpoint |
| **Constitution** | Deny list `boundaries.md` (push, rm -rf) |
| **Severity system** | classifier → escalation engine → notification |
| **Cost tracking** | dollar amount log per session |
| **Drift detection** | 9 signal chạy tự động khi đóng |

Đây là toàn bộ framework ở dạng thu nhỏ. Mỗi chương tiếp theo là cái nhìn sâu hơn về một trong các layer này.

---

## Đi Đâu Tiếp Theo

Chọn dựa trên cái bạn muốn làm:

| Nếu bạn muốn... | Đọc |
|---|---|
| Hiểu *tại sao* harness có hình dạng này | [Chương 2 — Mô Hình Tư Duy](02-mo-hinh-tu-duy.md) |
| Xem bản đồ hệ thống tổng quan | [Chương 3 — Kiến Trúc](03-kien-truc.md) |
| Học các quy tắc bất biến | [Chương 4 — Hiến Pháp](04-hien-phap.md) |
| Thêm skill/command/subagent của riêng bạn | [Chương 11 — Công Thức](11-cookbook.md) |
| Audit harness cho drift | [Chương 9 — Hệ Thống Chất Lượng](09-he-thong-chat-luong.md) |
| Đọc từ đầu đến cuối | Tiếp tục đến [Chương 2](02-mo-hinh-tu-duy.md) |

---

## Xử Lý Sự Cố

Nếu bất kỳ bước nào ở trên thất bại:

**`/session-start` báo "current-execution.md missing"** — harness đang ở trạng thái hư hỏng. Xem [Chương 11 § Phục Hồi](11-cookbook.md#recovery-from-incident).

**Hook log trống** — hook có thể chưa được wired. Check `.claude/settings.json` có block `hooks` được điền không. Nếu có, chạy `bash scripts/hooks/firing-tests/run-all.sh` để verify các hook script chạy được. (Xem [Chương 6 § Firing-Tests](06-hooks.md#firing-tests).)

**`/master-plan` trả về ngay lập tức mà không có plan nào được viết** — dispatch subagent thất bại. Check `agent-workspace/memory/dispatch.jsonl` để tìm hàng failure. Xem [Chương 6 § Telemetry](06-hooks.md#telemetry).

**Bạn thấy `[BLOCK]` trên mọi command** — flag autonomous-block được set. Đọc `human-workspace/notifications/urgent.md` để biết lý do, giải quyết nó, rồi `/block clear`.

Cho bất kỳ thứ gì khác, xem [Thuật Ngữ](15-thuat-ngu.md) và [Tham Khảo](13-tham-khao.md).
