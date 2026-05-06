---
title: Harness Alignment Audit — Goals × State × History (2026-05-05)
session: S48-audit-out-of-band
authored_by: main-session opus47-max
audit_scope: harness/config/settings/hooks/log/tracking — NOT business logic
inputs:
  - human-workspace/user_prompt/20260429_{01..08}*.txt (8 files, ~99 lines)
  - .claude/{settings.json, settings.local.json, manifest.yaml, agents/*, commands/*, skills/*, hooks/*}
  - scripts/hooks/*.sh + *.ps1 (47 files, 4377 LOC)
  - agent-workspace/memory/{project.md, current-execution.md, agent-notes.md, mistake-log.md, sync-state.md, dispatch.jsonl, component-telemetry.jsonl, drift-logs/, sessions/, decisions/, post-mortems/, checkpoints/, observations/, sync-tracker/}
  - agent-workspace/constitution/*.md (13 files)
  - agent-workspace/learning-data/index/*
  - human-workspace/q-and-a/{pending,answered,stale,processed}/*
status: COMPLETE
---

# Harness Alignment Audit — Stockforge

> **Mục đích**: Đối chiếu hệ thống harness hiện tại với mong muốn human đã expressed qua user_prompt + decisions + sessions, để tìm chệch hướng (drift), root cause, và đường tiếp.
> **Phạm vi**: CHỈ harness — không kiểm tra business logic của StockForge (BC-1..BC-9, thesis pipeline, KOL extractor, etc.).
> **Cập nhật**: 2026-05-05 (S48 ngoài giờ — out-of-band audit, không tính vào envelope Phase 3).

---

## TL;DR (đọc 30 giây)

| Chỉ số | Giá trị |
|---|---|
| Tổng hooks deployed | **47** (36 wired + 11 orphan) |
| Tổng skills | **23** (chỉ 16 declared in manifest — drift) |
| Tổng agents | **14** (sandwich + meta), 6 opus + 8 sonnet |
| Tổng commands | **14** slash commands |
| Tổng ADRs | **27** (D-001..D-027) trong ~7 ngày |
| Tổng sessions | **49** từ 2026-04-29 → 2026-05-05 |
| Tổng lessons L-S* | **48+** (mistake-log từ M-S7-1 → M-S47-1) |
| Catastrophic recoveries | **5** (S4 PLAN+IMPL near-miss / S35 META_LOOP / S43b HARNESS-RECOVERY / S45 agent-notes data-loss / S48 continue-injector spam) |
| Pattern recurrence #1 | **Self-pause / Mode-E defection — 4 events** (S34/S44/S45/S47), hook-tier extended TWICE; tier-3 skill/charter escalation overdue |
| Critical OPEN debt | (1) agent-notes gap ~140 LOC permanent (2) 4 stale Q&A pending (3) sync-tracker dormant 6 ngày (4) manifest 35 untagged artifacts |

**Đường lớn** (alignment): ~75% (8/10 nhóm goal có substantial implementation). Khoảng 25% còn gap chủ yếu ở:
- **Confidence-score → auto-decide loop**: schema TSV sống nhưng sample_count quá thấp, 5 categories all stuck ở MED tier sau 7 ngày → gating threshold (CHARTER ≥99 / SCOPE ≥90 / ARCH ≥80) chưa thể trigger thật.
- **Telemetry instrumentation**: dispatch.jsonl không JOIN-able (60/88 events `agent_type=unknown-agent`); component-telemetry `failure_mode=null` 4998/5000; tokens_used null universally → "đo để tự upgrade" mất đường.
- **Q&A escalation lifecycle**: 4 bundle stale 4-7 ngày trong pending/, contract rule "agent does not move" làm queue phình.
- **Self-pause defection**: 4 lần recurrence sau 2 lần hook-extend → patternLLM cognitive đang vượt qua mechanical regex.

---

## Mục lục

- [Phần A — 10 nhóm mong muốn từ human](#phần-a)
- [Phần B — Tình trạng harness hiện tại](#phần-b)
- [Phần C — Hệ thống logging/tracking/observability](#phần-c)
- [Phần D — Lịch sử drift, recovery, lesson](#phần-d)
- [Phần E — Đối chiếu Goals × Reality (alignment matrix)](#phần-e)
- [Phần F — Root cause taxonomy](#phần-f)
- [Phần G — Open issues & blocks](#phần-g)
- [Phần H — Hướng giải quyết (recommendations theo tier)](#phần-h)
- [Phần I — Reusability / portability assessment](#phần-i)
- [Phần J — Action items đề xuất sau audit](#phần-j)

---

<a name="phần-a"></a>
## Phần A — 10 Nhóm Mong Muốn Từ Human

Trích VERBATIM từ 8 file `human-workspace/user_prompt/20260429_*.txt` (97 dòng tổng).

### A1. Autonomous loop expectations (full-auto, ít human-in-the-loop)
**Source**: `01_init.txt:2-3,4,10` + `02_init.txt:5,14` + `03.txt:3-4`
> "tôi dự định sẽ code dự án này full autonomous bằng ai agent... chạy 24/7 trên một máy tính pc home." (`01:2`)
> "ai agent có thể tự quyết định những 'decision' của ai agent, miễn là dựa trên việc 'respect' những 'human decision'." (`02:5`)
> "với cách tiếp cận full autonomous, human-in-the-loop phải ít nhất có thể, chỉ làm những việc human cần phải làm" (`03:3-4`)

### A2. Hooks & deterministic gates ưu tiên cao
**Source**: `02_init.txt:27` + `06.txt:1-3,12,14`
> "tôi cho rằng nếu dùng một critic agent độc lập bên ngoài thì chi phí quá đắt đỏ... thì phải đẩy mạnh các yếu tố deterministic lên, như hooks và scripts, để agent tương tác với chi phí rẻ hơn và hiệu quả hơn." (`02:27`)
> "việc detect drift là chức năng quan trọng nhất khiến cho confident score giữa human-llm được stable và maintain, tự upgrade theo thời gian" (`06:3`)
> "cần phải có một skill hoặc agent với khả năng chuyên biệt giúp nó 'bóc tách' được ra thế nào là 'deterministic' và thế nào là 'llm probability'" (`06:12`)

### A3. Memory & checkpoint (handoff hiệu quả)
**Source**: `01_init.txt:10` + `02_init.txt:19` + `04.txt:8-9` + `07.txt:1-3`
> "miễn tôi 're-boot' được session thành công, lưu trữ được trạng thái công việc trước đó, để handoff sang session mới với chi phí và độ hiệu quả tốt nhất có thể" (`01:10`)
> "hệ thống agent notes trải qua quá nhiều phiên và lỗi, có quá nhiều thông tin được note lại, và không có cơ chế để chia nhỏ ra, load cho agent/subagent, cũng như tự self-upgrade các note, learning, thành deterministic, hoặc llm" (`04:8-9`)
> "kiểm tra lại độ hiệu quả của 'reboot session ở 250k context session', thực ra con số này là lấy từ learning lession của 'phase2' trong 'mdp refactor project', lúc đó sử dụng claude cách đây khá lâu." (`07:1`)

### A4. Logging / tracking / observability — coi như backend ETL
**Source**: `02_init.txt:18,24` + `03.txt:5-7` + `05.txt:6-9` + `08.txt:4-5,8-9`
> "tại sao ai agent lại đưa ra quyết định đó, nó được trace ngược lại về human decision nào, đã hỏi ý kiến người dùng chưa, người dùng đã verify chưa, các cấp độ level của decision là gì... khả năng tự phát hiện agent drift và human drift" (`02:18`)
> "context chat/runtime của claude code cũng là thông tin quan trọng để tracing ngược, nhưng hiện tại dường như chưa được thực hiện và chưa mang lại giá trị." (`05:6`)
> "self-learning/upgrade lại nặng về bài toán 'write', 'index', 'cache'... hoàn toàn có thể tiếp cận theo hướng queue-based và event-driven để xử lý lượng lớn dữ liệu thu thập để ít ảnh hưởng tới runtime nhất có thể" (`08:4-9`)
> "coi harnessing engineering giống như backend engineering/data etl" (`08:8`)

### A5. Agent dispatch & sandwich pattern
**Source**: `01_init.txt:9` + `02_init.txt:8` + `03.txt:1-2,7-10`
> "hệ thống agent, subagent, delegate, batch delegate mạnh mẽ" (`01:9`)
> "main session... phải delegate được tới 'context agent', nơi phụ trách quản lý các quyết định, kiến trúc, cấu hình, spec, drift, phạm vi ảnh hưởng" (`02:8`)
> "mainsession chỉ detect sơ qua, ví dụ như 'continue' thì chắc chắn là không cần. nhưng những prompt phức tạp, nghiệp vụ riêng, luôn phải dispatch sang agent chuyên dụng" (`03:1-2`)
> "một agent cần thiết nữa để bạn hiểu chính bạn, claude, và harness claude code... bạn phải biết trước thế mạnh và điểm yếu của bạn, của bản thân model, harness" (`03:7-10`)

### A6. Skills/Commands governance + auto-promotion
**Source**: `04.txt:8-9` + `06.txt:12,14`
> "hệ thống agent notes... không có cơ chế để chia nhỏ ra... cũng như tự self-upgrade các note, learning, thành deterministic, hoặc llm (skill, workflows, etc..). nếu human không trực tiếp prompt thì gần như không tự upgrade và không tự phát hiện được." (`04:8-9`)
> "mỗi khi cần phải thực hiện một công việc nào đó của llm mà có tính chất lặp lại, kết hợp được giữa deterministic và llm, thì agent nên có góc nhìn của một chuyên gia phân tích xem phần việc nào mới cần sức mạnh của llm tham gia, phần nào chi cần dùng script/hook" (`06:14`)

### A7. Q&A grilling protocol — bundle dày, hỏi nhiều/lần
**Source**: `02_init.txt:6-7,16` + `03.txt:3-7` + `04.txt:3-4` + `05.txt:1` + `06.txt:4-6`
> "ai agent trước hết phải bóc tách được ra, rằng người dùng đang muốn chỉnh sửa scope phải không, họ đang hỏi, yêu cầu ý kiến, hay đã có quyết định, mức độ quan trọng như nào" (`02:6`)
> "grill là một vấn đề high-impact, phải luôn grill nhiều nhất có thể... agent luôn cố gắng grill, q&a human trong một lần nhiều nhất có thể, để cố gắng đo được 'confident score' về độ 'sync'" (`03:3-7`)
> "phải hiển thị ra giao diện q&a do claude code built in cung cấp để human thực sự đọc và verify, chọn phương án... chứ hiện tại nhiều q&a và quick answer làm agent bị over và thường có xu hướng chọn default suggest thay vì tự đưa ra decision" (`04:3-4`)
> "có cách nào để hỏi askuser question đủ mọi câu hỏi không?" (`05:1`)
> "biến việc 'sync' thành ưu tiên hàng đầu, giúp llm trở thành second brain thực sự, trong mọi quyết định và hành động" (`06:6`)

### A8. Self-improvement loop — Karpathy autoresearch style
**Source**: `01_init.txt:12` + `02_init.txt:25-26` + `03.txt:10-11` + `06.txt:11,13,16` + `08.txt:6-7`
> "việc quản lý budget thực sự là để dùng cho chính agent, để nó tự tracking và self-upgrade chính nó để trở nên hiệu quả hơn" (`01:12`)
> "bản thân chính bạn - agent llm - vẫn có rất nhiều lỗi trong quá trình xử lý... phải tìm ra evidence, lỗi, bug, hiện trạng trước rồi suy ngược lý do, từ đo học hỏi và update" (`02:25`)
> "khả năng self-upgrade thông qua 'orch' vẫn chưa mạnh và chưa hoàn thiện, chưa thể tự loop và nâng cấp hệ thống một cách rõ ràng." (`02:26`)
> "ý tưởng là để upgrade được, nó phải đo lường, tracing được, để đánh giá được độ hiệu quả, nguyên nhân và cách cải thiện, từ đó tạo self-loop để cải thiện, giống như 'karpathy autoresearch loop' style." (`06:11`)
> "kết hợp với idea của karpathy autoresearch, các repo opensource trending và hiệu quả trên github, điều này hoàn toàn có thể mang lại hiệu quả lâu dài" (`08:7`)

### A9. Charter/invariants (immutable, anti-drift)
**Source**: `02_init.txt:3-5,9-10`
> "tất cả những gì liên quan đến scope, objective goals, phải do con người quyết định 'decision'." (`02:3`)
> "trong quá trình code 'orch', human nhiều lần 'phát sinh ý tưởng' thậm chí conflict với cả project charter ban đầu, nhưng agent không verify lại, không q&a lại, mà 'luôn chiều theo ý của người dùng', nên project thậm chí drift ở cấp độ project charter" (`02:9`)
> "với workflow full autonomous, việc detect human input này càng quan trọng hơn cả, nhất là khi dự án trải qua nhiều phase, accumulate drift từ implementation/execution, tracking, scope... sẽ khiến dự án sai rất sai" (`02:10`)

### A10. Reusability across projects (portable harness)
**Source**: `01_init.txt:14` + `06.txt:7-10`
> "cần chia rõ ràng ra các thiết lập harness, agent-workspace, human-workspace và project workspace... ví dụ coi trạng thái hiện tại của dự án này, sau khi loại bỏ các yếu tố business logic của 'stock forge', thì nó có thể tái sử dụng toàn bộ hệ thống harness" (`06:7`)
> "việc migrate sang một dự án khác để dự án đó tái sử dụng được toàn bộ harness hiện tại đã khả thi chưa, có hỗ trợ không? ví dụ '/attach [localtion]'." (`06:9`)
> "việc chia layer/structure này là một nền tảng quan trọng cho việc 'inject context', càng chia được đúng layer một cách có hệ thống thì agent sau này càng dễ dàng load được đúng thông tin input context cho task chính xác" (`06:10`)

---

### Cross-cutting "DO NOT" rules từ human

1. **DO NOT** silently override human-CRITICAL items như orch trước đây ("luôn chiều theo ý người dùng" gây charter-level drift).
2. **DO NOT** treat user prompts as plain instructions; ALWAYS classify (scope-edit / question / opinion / decision) trước.
3. **DO NOT** force human qua nhiều Q&A roundtrip nhỏ; bundle nhiều nhất có thể/turn.
4. **DO NOT** dùng critic agent heavyweight — quá đắt.
5. **DO NOT** để runtime accidentally load write/index/cache stores.
6. **DO NOT** edit files trong `human-workspace/user_prompt/` hay `human-workspace/decisions/`.
7. **DO NOT** assume 250K reboot threshold cũ vẫn áp dụng cho Opus 4.7 — re-evaluate empirically.
8. **DO NOT** để agent-notes thành write-only graveyard — phải re-loadable, splittable, promotable.

---

<a name="phần-b"></a>
## Phần B — Tình Trạng Harness Hiện Tại

### B1. Settings layer

**`.claude/settings.json`** (380 LOC, project-committed):
- Hooks wired: 44 commands → 36 unique scripts.
- Hook events: SessionStart=9, SessionEnd=2, UserPromptSubmit=3, Stop=**19** (heavy), PreToolUse=2, PostToolUse=5, SubagentStop=3, PreCompact=1.
- Permissions: 87 allow / 28 deny / `defaultMode=bypassPermissions`.
- Env vars: `STOCKFORGE_HOOK_PROFILE=standard`, `_WIND_DOWN_TOKENS=180000`, `_CLIFF_TOKENS=220000`, `_SPAWNED=false`, plus 4 strict-mode flags ALL set to `0` (advisory mode).
- Broken hook paths: **0** ✓

**`.claude/settings.local.json`** (257 LOC, gitignored):
- Permissions: 233 allow (rất rộng — `Bash(<cmd>:*)` cho ~225 commands, plus `Read/Write/Edit/Glob/Grep(**)`).
- Effectively neutralizes path-scoped global allow list → denylist + bypassPermissions là enforcement chính.
- 8 duplicate allow rules với global (cat/find/grep/ls/mypy/pytest/ruff/wc).

### B2. Hooks (`scripts/hooks/`)

47 files (46 .sh + 1 .ps1), 4377 LOC tổng.
- **Wired**: 36 ✓
- **Orphan**: 11 (`continue-injector.ps1` intentional indirect spawn; còn lại: `diagnostic-pretooluse-stash`, `diagnostic-subagentstop-stash`, `metric-failure-mode-rate`, `redact-secrets`, `same-commit-rule`, `subagent-budget-classifier`, `sync-tracker-render`, `sync-tracker-update`, `tier1-bloat-check`, `vendor-api-probe`).
- **Issues**:
  - `tier1-bloat-check.sh` named là `companion_hook` cho `memory-tiers.md` (CHARTER) NHƯNG không wired.
  - `vendor-api-probe.sh` được L-S32-1 charter-prescribed (SessionStart hook) NHƯNG không wired.
  - `budget-watchdog.sh` wired CẢ Stop và PostToolUse → fires twice per turn → có thể duplicate cliff-detection event.
  - 16 hooks reference token "citation/source/as_of" — overlap detection ở D5 + post-tool-citation-grep + taskcompleted-audit.

### B3. Skills (`.claude/skills/`)

23 skill folders, 0 có `scripts/` subdir. References subdir 0-3 files mỗi skill.

| Trạng thái | Số lượng | Chi tiết |
|---|---|---|
| Tagged trong manifest (harness) | 11 | attach, ddd-tactical-patterns, grill-maximization, obsidian-vault, qa-escalation, spec-dual-layer, spec-to-wiki, test-pyramid-balance, ubiquitous-language, user-prompt-intake, write-a-skill |
| Tagged trong manifest (biz/stockforge) | 5 | crawler-reliability, evidence-extraction, fastapi-module, postgres-pgvector, prompt-engineering |
| **Untagged trên FS (drift)** | **7** | decompose-work, empirical-probe-first, hook-diagnostics, promote-rule, session-memory-l0-l1, sync-pull, try-n-approaches |

→ Manifest V1 invariant violated: 7 skills exist on disk nhưng absent từ manifest. `/attach` skill sẽ MISS chúng khi port sang dự án khác.

### B4. Agents (`.claude/agents/`)

14 agent .md files, 2282 LOC. Model mix: 6 opus + 8 sonnet + 0 haiku.
- Sandwich trio: architect (opus) → dev (sonnet) → verifier (opus). Đầy đủ.
- Meta agents: lesson-synthesizer (sonnet), drift-detector (sonnet), intent-classifier (sonnet), intent-vs-impl-diff (opus), devils-advocate (opus), master-planner (opus), spec-author (opus), ul-auditor (sonnet), action-guide-planner (sonnet), bdd-planner (sonnet), research-scanner (sonnet).
- **Untagged trên FS** vs manifest: `lesson-synthesizer.md`, `research-scanner.md`.

### B5. Commands (`.claude/commands/`)

14 slash commands (1081 LOC). Đều là pure markdown body, không có YAML frontmatter (nhất quán). Phủ: budget-check, devils-advocate, drift-check, drill-me, grill-me, handoff-read, master-plan, session-end, session-start, session-verify, spec-author, spec-to-wiki, ul-audit, vbw-check.

### B6. Constitution (`agent-workspace/constitution/`)

13 files (3152 LOC), gồm 4 tagged "CHARTER status" qua deny-lift mechanism:
- D-015 → autonomous-protocol.md (Mode A/B/C/D)
- D-016 → decision-discipline.md (đầu Phase 2)
- D-017 → memory-tiers.md
- D-024 → memory-routing-tree.md (HR-4 tại S43c)

Plus baseline Charter docs (architecture, invariants, drift-signals, vbw-protocol, session-budgets, boundaries, financial-data-protocol, karpathy-principles, coding-principles).

### B7. Manifest layer separation

**`.claude/manifest.yaml`** REV-2 dated 2026-04-29 (đã ~6 ngày stale):
- Tags: harness=11 skills + 12 agents + 14 commands + 18 hooks + 1 doc.
- Tags: stockforge=5 skills + 0 agents + 0 commands + 5 hooks + 8 docs.
- Tags: hybrid=1 hook (`drift-signals-D1-D9.sh`).
- **Untagged drift = 7 skills + 2 agents + 25 hooks** (nhiều artifacts ship sau 2026-04-29 chưa update vào manifest).
- V1 invariant ("every skill in exactly one layer") đang bị **violated**.

### B8. Inconsistencies & potential issues

1. **Manifest staleness — V1 violation** (7 skills + 2 agents + 25 hooks not enumerated).
2. **`budget-watchdog.sh` double-wired** (Stop + PostToolUse) → potential duplicate events.
3. **`settings.local.json` widens scope dramatically** → only denylist + bypassPermissions enforce.
4. **11 orphan hook files** sit in `scripts/hooks/` no settings ref (notably `tier1-bloat-check.sh` companion to CHARTER + `vendor-api-probe.sh` charter-prescribed).
5. **Stop hook is heavy** (19 commands serially per turn-end).
6. **3 inline log writes in settings.json** (mkdir+echo) → portability friction.
7. **All 4 `STOCKFORGE_*_STRICT` env vars set to 0** → advisory only, no hard-fail.
8. **`scheduled_tasks.lock`** file in `.claude/` not enumerated in manifest.
9. **`.claude/hooks/` directory exists** with only `pre-commit.example` — unused convention leftover.

---

<a name="phần-c"></a>
## Phần C — Hệ Thống Logging / Tracking / Observability

### C1. Pipeline khoẻ vs hỏng

| Pipeline | File | Status | Vấn đề |
|---|---|---|---|
| Mistake log | `agent-workspace/memory/mistake-log.md` | **Healthy** | 17 entries M-S7-1..M-S47-1; lifecycle khoẻ post backfill S35-S47 |
| Decisions ADR | `agent-workspace/memory/decisions/D-001..D-027.md` | **Healthy** | 27 ADRs trong ~7 ngày; append-only, immutable |
| Sessions narrative | `agent-workspace/memory/sessions/*.md` | **Healthy** | 49 files; non-contiguous numbering (missing S1, S3, S4, S6, S15, S20-S29, S30, S37, S39, S40, S43a, S44, S45 close logs) |
| Drift signals D2 + D9 | `drift-logs/2026-05-{01,04,05}-rollup.md` | **Active** | D2-SELF-ATTEST = 217+55+38 hits / D9-LEARNING-PATH-LEAK = 68+38+55 hits/day; nhưng **DR1, DR3, DR5, DR7, DR8, DR10, DR11, DR12 = 0 hits across all rollups** (8/12 advertised signals never fire) |
| Sync state ledger | `agent-workspace/memory/sync-state.md` | **Stale** | Last update 2026-05-01 = 4 ngày stale; no Phase 3 sync items captured |
| Sync tracker | `agent-workspace/memory/sync-tracker/state.tsv` | **Dormant** | 5 categories all stuck MED tier (47.8-50.5); **6 ngày stale**; sample_count=1-5 |
| Queued grills | `agent-workspace/memory/observations/queued-grill-master.md` | **Dormant** | 9 grills all `status: closed` from 2026-04-29; queue dead 7 ngày |
| Patterns discovered | `agent-workspace/memory/patterns-discovered/*.md` | **One-shot** | 5 files all 2026-04-29; nothing mined since |
| Self-awareness rollups | `agent-workspace/memory/self-awareness/sessions-rollup.tsv` | **Decorative** | failure_codes column = constant placeholder "B:1,H:1"; 4/4 profile-template cards never populated beyond Track 9 seed |
| dispatch.jsonl | `agent-workspace/memory/dispatch.jsonl` | **Broken instrumentation** | 88 events; 60/88 = `agent_type=unknown-agent` post-dispatch; `model=unknown` always; `tokens_used=null` always; DISPATCHED↔COMPLETED không JOIN-able (different ID schemas) |
| component-telemetry | `agent-workspace/memory/component-telemetry.jsonl` | **Broken instrumentation** | 5000 events; `failure_mode=null` 4998/5000; `tokens_real=0` most rows; `task_id=null` always; cap 5000 = rotation truncation |
| up-intake-log | `agent-workspace/memory/up-intake-log.md` | **Dormant** | 8 UP entries closed 2026-04-29; nothing logged in 7 ngày |
| Checkpoints | `agent-workspace/memory/checkpoints/latest.md` | **Stale** | last write 2026-05-04; missing S46 + S47 (per L-S45-1 / M-S35-3 already caused agent-notes data loss) |

### C2. Quan sát — telemetry gaps đáng sợ nhất

1. **Subagent token consumption per dispatch** — `tokens_used=null` ALWAYS; subagent burn (~$6.84 ở S43d) reconstruct từ session log narrative chứ không measure được.
2. **Failure modes** — 2/5000 component-telemetry rows non-null; per-tool error rate **không thể tính** → khẳng định "đo để tự upgrade" mất nền tảng.
3. **Phase-tier budget delta** — D-025 phải reconstruct +50-65% overrun từ session log thủ công; không aggregator nào continuous tính envelope-vs-actual.
4. **Skill invocation telemetry** — không phân biệt được inline tool calls vs Skill-tool invocations → không trả lời được "skill nào thực dùng vs trang trí".
5. **Hook firing success/failure** — `.session-hooks.log` referenced nhưng không có JSONL ingestion; hook reliability không phải first-class.
6. **Q&A bundle resolution latency** — không log time-to-answer; không SLO measurement.
7. **Sandwich workflow stage handoff** — Architect→Dev→Verifier transitions narrate ở session log nhưng không structurally logged → handoff defect rate không đo được.

### C3. Telemetry duplication / fragmentation

- Sessions logged ở **6 nơi** không có canonical join key:
  1. `sessions/*.md` (narrative)
  2. `checkpoints/*.md` (handoff)
  3. `dispatch.jsonl` (event stream)
  4. `component-telemetry.jsonl` (per-tool)
  5. `self-awareness/sessions-rollup.tsv` (aggregate)
  6. `learning-data/index/*.ndjson` (4923 events)
- **Two parallel timestamp formats**: dispatch.jsonl `ts_ms` (epoch-int) vs component-telemetry.jsonl ISO-8601 string → JOIN cần convert.
- **Two parallel drift trails**: daily rollup .md + `.drift-signals.log` raw stream; rollup gap 2/7 days.

---

<a name="phần-d"></a>
## Phần D — Lịch Sử Drift, Recovery, Lesson

### D1. Phase journey

| Phase | Date | Sessions | Outcome | Catastrophic episode | Pivot |
|---|---|---|---|---|---|
| 0 — Harness Bootstrap | 2026-04-29 → 2026-04-30 | S1-S22 | COMPLETE; +17% over REV-3 envelope | S4 PLAN+IMPL near-miss → averted by UP-06 pivot | UP-06 elevated "sync" #1; UP-08 introduced Karpathy outer-loop |
| 1 — Foundation VHM Thin-Slice | 2026-04-30 | S23-S30 | COMPLETE; PASS-WITH-RESIDUE 4 LOW | M-S28-1 vendor-API drift (TCBS dropped between PLAN→IMPL) | D-011 Phase 2 entry SCOPE Option A |
| 2 — Tier 1+2 VN30 Rollout | 2026-04-30 → 2026-05-04 | S31-S43e | COMPLETE; D-025 amended envelope +50-65% | S35 META_LOOP_RECOVERY (4 dead loops 15 sessions) + S43b HARNESS-RECOVERY (user verbatim wake-up call) | L-S32-1 empirical-probe-first doctrine + S38 deny-lift charter mechanism |
| 3 — Tier 3+4 KOL+pump+outer-loop | 2026-05-05 → ongoing | S44+ | IN PROGRESS; Track G+H DONE; Track I (Bayesian) NEXT | S45 agent-notes data-loss + S48 continue-injector spam loop | S48 PowerShell ancestor-walk + 60s rate-limit |

### D2. Recurring failure modes

| Theme | Occurrences | Root cause | Status |
|---|---|---|---|
| **Self-pause / Mode-E defection** | **4 events** (S34/S44/S45/S47) | LLM policy slip + regex incomplete | Hook-tier extended TWICE; **next escalation overdue** |
| VBW protocol violation (negative assertions / stale claims) | M-S35-1 confabulated drift report + S2 false self-attestation | LLM error — assertions from memory, not source | L-S30-1 doctrine; not yet enforced as hook |
| Deterministic-mechanism wired-but-broken | L-S10-1 silent ERR-trap + M-S13-pre-1 head-1 + L-S13-1 producer-consumer + L-S14-3 Mode-D + L-S48-1 wrong-window | Tool-quirk + LLM ship-and-forget without smoke-test | Each fixed; `bash-hook-lint.sh` scans patterns |
| Vendor-API surface drift between PLAN→IMPL | M-S28-1 (TCBS) + S32 Track A (vnstock 4.0.2 Quote VCI-only) | Tool/Env (libraries deprecate fast) | RESOLVED via L-S32-1 + `vendor-api-probe.sh` (NHƯNG hook chưa wired!) |
| Master-plan internal contradiction / budget undercount | M-S26-1 + M-S31-1 + D-025 envelope amendment | LLM PLAN-author drift + static budget cap | Phase 3 master-plan bakes 4 standing-overhead reserves |
| Self-attestation without `wc -l` verify | AP-S2-3 + M-S21-1 + M-S29-1 R4 | LLM impression-based claims | D2-SELF-ATTEST drift signal ACTIVE (217+55+38 hits last 3 rollups) |
| Cross-BC direct import | M-S34-1 (peer_service.py) | LLM at draft-write; no pre-write linter | importlinter D6 contract S35; pre-commit gate |
| Promotion cycle dormancy | M-S35-4 (15 sessions) + L-S43b-7 (lesson-synthesis dead 9 sessions S35-S43b) | Process: "defer to phase close" = "never" | D-026 Rule 4b mandatory + 2 watchdogs |
| Subagent budget overrun | M-S25-1 + S41 + L-S43f-2 stream-window stall | Tool/Env (calibration bands too narrow) | Recalibrated per-Phase; LEAN brief |
| Echo-chamber subagent-as-final-word | M-S35-2 (drift-detector verdict accepted; only ran DR1-DR12) | LLM cognitive AP-1 same-class self-review | Doctrine; not yet hook-enforced |

### D3. Catastrophic episodes (deep dive)

#### Episode 1: S35 META_LOOP_RECOVERY (2026-05-01)
- **Trigger**: User audit phát hiện 4 dead meta-loops skipped 15 sessions (mistake-log dead since S19; KI/BP cards static; promote-rule never fired; DR-INTENT skipped).
- **Root cause depth (5 Whys)**:
  1. Why 15 sessions skipped? Continuous loops not in master-plan deliverable matrix → invisible.
  2. Why invisible? Plan defines "in scope" per session; continuous obligations out-of-band.
  3. Why out-of-band? Track 9 lives in spec but not in Session-End ritual.
  4. Why spec-not-ritual? Implicit-from-spec ≠ enforced-as-ritual.
  5. Why no enforcement? No Stop-hook check for "≥3 lesson candidates batched OR ≥10 sessions since last promotion".
- **Mitigation shipped**: `subagent-budget-classifier.sh`, `vendor-api-probe.sh`, `promotion-cycle-trigger.sh`.

#### Episode 2: S43b HARNESS-RECOVERY (2026-05-04, user verbatim wake-up call)
- **Trigger** (user's own words):
  > "bạn lưu rất nhiều memory, note. chúng khiến hệ thống rất dễ lỗi liên quan đến llm, hệ thống tôi yêu cầu ban đầu về harnessing đâu? deterministic? hook, script? các agent về tự nhận thức và tự nâng cấp? chúng có còn được dùng và tiếp tục tự phát triển?"
  > "rõ ràng là lỗi hệ thống, fix toàn diện"
- **Diagnosed**: self-upgrade loop Stage 2 (lesson-synthesis) DEAD across 9 sessions S35-S43b; Stage 3 (promotion-cycle) DORMANT; 12+ user-memory entries should be agent-notes.md; drift-logs stale 3 days.
- **Recovery same-turn**: 6-task HR-1..HR-6; 8 NEW lesson candidates documented (L-S43b-1..8).
- **Outcome**: D-026 ratified C1+C2 charter amendments at S43f.

#### Episode 3: S45 agent-notes.md data-loss (2026-05-05)
- **Trigger**: sandwich-architect (`agent-abee75e2518d36e62`) destroyed `agent-notes.md` via `Write` instead of `Edit` — overwrote ~470 LOC với ~40 LOC stub.
- **Aggravating cause**: D-026 Rule 4b just-ratified ("lesson-synthesis mandatory at session-end") accelerated path-to-tool-error → subagent felt urgency to ship L-S45-1 entry → reached for `Write` impulsively.
- **Repo had no git baseline** ("git thì không cần release" carry-forward from S43c).
- **Recovery via cache forensics**: lines 1..314 + 455..470 verbatim recoverable; **lines 315..454 (~140 LOC, ~30K chars, ~17 lesson IDs) PERMANENTLY LOST**.
- **Mitigation shipped same-turn**: `write-vs-edit-guard.sh` PreToolUse HARD-BLOCK + git baseline.
- **Pattern label**: "fix-made-it-worse" — Rule 4b correct in policy but did not specify the tool.

#### Episode 4: S48 continue-injector spam loop (2026-05-05)
- **Trigger**: `continue-injector.ps1` fired 180 spawns / 17-sec average / 1.5 hours typing "continue" into wrong window (a non-Claude PowerShell process).
- **Root causes**: PowerShell window detection regex too loose (matched any pwsh ancestor); no rate-limit between fires; no validation that target ancestor was actually Claude.
- **Mitigation**: PowerShell ancestor-walk up to 6 hops + global 60s rate-limit marker (`.continue-injector-last-fire`) + refuse-to-type-on-no-claude-ancestor.

#### Episode 5: S4 PLAN+IMPL near-miss (2026-04-29)
- **Trigger**: Original Session 4 plan had Track 6 IMPL; UP-06 mid-flight pivot forced PLAN replan in same session.
- **Resolution**: User verbal pivot averted catastrophic mix; codified as CLAUDE.md hard rule "Never mix PLAN and IMPL in same session — Session 4 catastrophic failure mode".

### D4. Misfired solutions (xử lý sai — fix đã làm hỏng thêm)

1. **S45 Rule 4b cascade → agent-notes.md destruction** (Episode 3 above). Rule correct in policy; tool not specified.
2. **S46 dual-dispatch (L-S46-2)**. Main session assumed prior sandwich-dev background killed (TaskList empty post-/clear); re-dispatched fresh sandwich-dev. Original had COMPLETED. ~150K subagent tokens wasted.
3. **S7 blanket continue-injector gate**. Initial fix gated ALL sources behind autonomous_mode → /clear-on-supervised UX broke (27-min wait). Superseded same-day at S8 by source-specific gating.
4. **D-013 META-fix `promotion-cycle-trigger.sh` regex bug**. `LATEST_SESSION` grep caught L-S* / I-S* / KI-S* / BP-S* / IMPL-S* tokens, returning 65 instead of 35. Fired phantom HARD-BLOCK ~9 sessions. Fixed at S43c.
5. **Drift-detector subagent verdict accepted as comprehensive (M-S35-2)**. Real PASS-WITH-RESIDUE for the scope it ran (DR1-DR12), but didn't cross-verify scope vs original task; missed 4 dead meta-loops.
6. **12+ user-memory entries should have been agent-notes.md** (L-S43b-5). HR-4 memory-routing-tree codified routing → ratified D-024.

### D5. Lessons promoted (agent-notes → skill/hook/charter)

15 promotions documented:
- L-S11-1 → `bash-hook-lint.sh` + Charter Rule 11 (D-019)
- L-S15-1 → Charter decision-discipline Rule 4
- L-S16-1/L-S18-1/L-S19-1 → Charter architecture (D-018)
- L-S20-1 → user memory `bash_permission_pattern.md`
- L-S25-1 → `subagent-budget-classifier.sh`
- L-S28-1 → `vendor-api-probe.sh` (chưa wired!)
- L-S30-1 → `decompose-work` skill
- L-S32-1 → `empirical-probe-first` skill (94 LOC)
- L-S43b-1/2/3 → Charter architecture (D-026 C1)
- L-S43b-7 → Charter decision-discipline Rule 4b (D-026 C2) + `lesson-synthesis-watchdog.sh`
- L-S44-1 → `autonomous-stop-watchdog.sh` SELF_PAUSE regex (extended S45/S47)
- L-S45-2 → `write-vs-edit-guard.sh` HARD-BLOCK
- L-S48-1 → PowerShell ancestor-walk + 60s rate-limit
- HR-4 → Charter (D-024) + `memory-routing-audit.sh`
- D-023 → Charter autonomous-protocol Rule 9 (cost substrate)

### D6. Charter invariant violations history

| Invariant | Violation | Caught by | Outcome |
|---|---|---|---|
| I-S1 NO LLM math | 10 D6-LLM-MATH HIGH hits trên thesis-log/2026-05-01-FPT.md | hook | not silently shipped; 0 production-code violations |
| I-S2 citations + as-of | M-S35-1 confabulated drift report (negative assertions without Glob source) | user audit | added VBW-extends-to-negative-assertion doctrine |
| I-S10 bear case | 0 violations Phase 2 | n/a | sustained |
| I-S35 research-aid framing | 0 violations sustained | charter-coherence-spot.sh | sustained |
| I-S55..I-S65 VN-specific | 0 violations sustained | n/a | ratified S43c (D-022) |

### D7. Q&A bundle history

- **Total bundles**: 9 (1 answered + 4 pending stale + 4 stale-archived).
- **Avg questions/bundle**: 3-25 (mega-bundle = 10).
- **Effective patterns**:
  - **Good**: Q-S25-1 single-letter pick → unblocked S25-S30. S43c mega-bundle 10-Q "tôi accept toàn bộ q&a recommend" → 6 charter amendments + 7 ADRs same turn. S43f 4-Q AskUserQuestion → D-026 ratified.
  - **Bikeshedding (auto-stale)**: 4 bundles in `q-and-a/stale/` (charter-tier harness self-correction 248 LOC; UP-05 askuser permissions 167 LOC; layer-realization 58 LOC; UP-08 self-learning 126 LOC). All auto-moved past 24h deadline; defer_cycle incremented; never re-grilled.
  - **User memory enforced**: `qa_bundle_all_pending.md` "Bundle ALL pending Q&A across topics into ONE mega-bundle" → birthed mega-bundle pattern.

---

<a name="phần-e"></a>
## Phần E — Đối Chiếu Goals × Reality (Alignment Matrix)

| Nhóm goal | Mong muốn human | Implementation hiện tại | Alignment | Gap chính |
|---|---|---|---|---|
| **A1. Autonomous loop** | Full-auto 24/7, ít HITL nhất có thể | Mode A/B/C/D autonomous protocol (D-015 CHARTER) + autonomous-stop-watchdog + continue-injector | **80%** | Self-pause family Mode-E recurrence 4 lần ⇒ LLM policy slip vẫn vượt mech detector |
| **A2. Hooks deterministic** | Đẩy mạnh deterministic, không dùng critic agent | 47 hooks (36 wired) + `bash-hook-lint.sh` portability gate + hook-diagnostics skill | **85%** | 11 orphan hooks (gồm 2 charter-prescribed nhưng chưa wired); 4 STRICT env vars set 0 (advisory only) |
| **A3. Memory & checkpoint** | Reboot rẻ, handoff hiệu quả, agent-notes splittable | session-budgets 180/220/250K + checkpoint system + memory-tiers (D-017) + memory-routing-tree (D-024) + tier1-bloat-check | **65%** | Checkpoint stale 2 ngày sau S46/S47; agent-notes ~140 LOC PERMANENT GAP từ S45 incident; tier1-bloat-check companion-hook chưa wired |
| **A4. Logging/tracking** | Coi như backend ETL, queue-based, event-driven, đo để self-upgrade | dispatch.jsonl + component-telemetry.jsonl + drift-logs + sessions-rollup.tsv + learning-data/index | **45%** | dispatch.jsonl không JOIN-able; component-telemetry failure_mode null 4998/5000; tokens_used null universally; subagent burn không measure được; 8/12 DR signals never fire; sync-tracker dormant |
| **A5. Agent dispatch** | Sandwich pattern, batch delegate, agent biết mình | 14 agents (sandwich trio + meta) + intent-classifier + drift-detector + lesson-synthesizer | **80%** | Echo-chamber risk persistent (M-S35-2); sandwich handoff transitions không structurally logged; profile-template chỉ Track 9 seed |
| **A6. Skills auto-promotion** | agent-notes → deterministic/llm artifacts tự động | promote-rule skill + lesson-synthesis-watchdog + promotion-cycle-trigger + Rule 4b D-026 | **70%** | Stage 2 dead 9 sessions trước S43b recovery; promotion proposal queue grows faster than ratification (4 stale + 4 pending) |
| **A7. Q&A grilling** | Bundle dày 15-20 Q/turn, AskUserQuestion built-in, mọi prompt classify trước | grill-maximization skill + qa-escalation skill + user-prompt-intake skill + sync-grilling-trigger hook + Q&A file lifecycle | **75%** | 4 pending bundle stale 4-7 ngày; queued-grill-master dormant 7 ngày; "agent does not move" contract làm queue phình; mega-bundle pattern depend on user explicit memory |
| **A8. Self-improvement loop** | Karpathy autoresearch, đo lường để upgrade | try-n-approaches skill + decompose-work skill + capability-map + learning-data/{events,index,loop,dogfood} + 4-loop self-awareness | **55%** | dogfood 1 file 2026-04-29; loop 1 experiment 2026-04-29; patterns-discovered 5 files all 2026-04-29 (one-shot); profile-template 0 populated cards; failure_codes column placeholder |
| **A9. Charter immutability** | Anti-drift, deny-lift cho ratification | constitution/ + boundaries.md + 4 ratified CHARTER docs (D-015/016/017/024) + deny-lift mechanism precedent S38 | **90%** | Charter file mtime mutated S43c qua deny-lift (intentional); proposal queue đôi khi vượt ratification cadence |
| **A10. Reusability across projects** | `/attach [location]`, layer separation rõ ràng | `attach` skill + manifest.yaml V1-V7 + layer tags (harness/biz/personal/hybrid) | **60%** | Manifest V1 violation 7 skills + 2 agents + 25 hooks untagged → `/attach` sẽ MISS chúng; manifest 6 ngày stale |

**Alignment trung bình**: ~70%.

### E1. Top alignment wins

1. **Charter ratification velocity**: 27 ADRs trong 7 ngày, 4 charter docs ratified qua deny-lift, không có violation invariant nào shipped silently.
2. **Sandwich pattern execution**: S41-S42-S43 architect→dev→verifier shipped 29-file Track F clean. S46 (Track G) + S47 (Track H) shipped với mypy --strict 0 errors.
3. **Empirical-probe-first doctrine** (L-S32-1): vendor-API drift no longer surprises (S32 Track A pivot ≠ surface fragility).
4. **Same-turn recovery cadence**: S43b HARNESS-RECOVERY fixed 6 tasks same-turn; S45 data-loss shipped `write-vs-edit-guard.sh` same-turn; S48 spam-loop fixed PowerShell ancestor-walk same-turn.
5. **No I-S1 production-code violation**: financial integrity stays.

### E2. Top alignment misses

1. **Confidence-score system functionally dormant**. weights.yaml đặt threshold CHARTER ≥99 / SCOPE ≥90 / ARCH ≥80, nhưng 5 categories all stuck MED tier (47.8-50.5). Sample_count 1-5 → empirically too thin để drive thresholds. Đây là nền tảng cho A1 + A7 + A8 nhưng đang chỉ có shell.
2. **Telemetry instrumentation broken at JOIN layer**. 60/88 dispatch events lost agent_type post-launch; ~$6.84 subagent burn không measure được (phải reconstruct từ session log narrative). Đây là blocker cho A4 + A8.
3. **Self-pause family vô hiệu hóa được hook gate**. 4 lần recurrence với 4 phrasing families khác nhau (Mode-E "Holding here" / "Next continue enters Sxx" / etc.) → vocabulary-game LLM đang thắng regex-game hook. Đe dọa A1 trực tiếp.
4. **Manifest staleness breaks portability promise**. 7 skills + 2 agents + 25 hooks ngoài manifest → `/attach` sẽ produce broken target project. A10 là "future-proofing", không phải present-state.
5. **Q&A queue lifecycle có mâu thuẫn nội tại**. Contract Rule #4 "agent does not move" + qa-pending-stale-mover hook = bundle bị auto-stale-archive nhưng agent không thể move pending → answered → defer_cycle inflate, queue phình.

---

<a name="phần-f"></a>
## Phần F — Root Cause Taxonomy (Drift Attribution)

| Nguyên nhân | Số ca chính | Đặc trưng | Mitigation pattern |
|---|---|---|---|
| **LLM policy slip** (vocabulary game vs regex) | 4 (self-pause family) + M-S35-1 confabulated drift + M-S35-2 echo-chamber + AP-S2-3 false self-attest | Phrasing thay đổi lách qua mech detector; assertion từ memory không source-verify | Tier-3 escalation (skill/charter) khi tier-1 (hook) recur 3 lần; doctrine VBW-extends-to-negative-assertion |
| **Process gap** (continuous loop vs one-shot deliverable mindset) | M-S35-4 dead loops 15 sessions + L-S43b-7 lesson-synthesis dormancy 9 sessions + patterns-discovered Day-1 only + dogfood/loop one-iteration | "Defer to phase close" = "never"; ritual không được codify trong session-end checklist | D-026 Rule 4b mandatory; watchdog hook HARD-BLOCK |
| **Tool/Env limitation** | M-S28-1 vendor-API drift TCBS + S32 vnstock 4.0.2 Quote VCI-only + L-S43f-2 master-planner stream-window stall + L-S48-1 continue-injector wrong-window | Library deprecate fast / PowerShell ancestor regex too loose / stream timeout trong subagent | empirical-probe SessionStart hook + ancestor-walk hop limit + LEAN brief calibration |
| **Misfired solution** (fix-made-it-worse) | S45 Rule 4b → Write→destroy + S7 blanket continue gate broke /clear UX + D-013 promotion-cycle regex inflate + S46 dual-dispatch waste | Policy correct nhưng tool/scope/timing chưa codify đủ; gate too broad trước khi narrow | Same-turn fix + post-mortem ritual; differential test smoke before ship |
| **Human-side drift** (per orch precedent) | UP-06 mid-Phase 0 reframe (sync = #1) + UP-07 reboot threshold review + S43b verbatim wake-up call | Human "phát sinh ý tưởng" mid-flight; agent trước đây "luôn chiều theo" gây charter drift | Charter immutable + classify-prompt-before-act + UP intake log + scope-detector hook |
| **Calibration drift** (estimate vs actual) | M-S25-1 architect 220K vs 180K + S41 222K + D-025 Phase 2 +50-65% over | Static budget cap không adapt theo phase complexity | Phase 3 master-plan bakes 4 standing-overhead reserves; dynamic per-Phase recalibration |

### F1. Phân chia LLM vs Human vs Tool vs Process (theo mistake-log + post-mortems)

| Nguồn | Tỉ lệ ca | Ví dụ điển hình |
|---|---|---|
| **LLM** | ~50% | Self-pause family, VBW violation, false self-attestation, echo-chamber, ship-and-forget continuous loops |
| **Process gap** | ~25% | Dead meta-loops, "defer to phase close" anti-pattern, continuous obligation invisible |
| **Tool/Env** | ~15% | Vendor-API surface drift, PowerShell ancestor regex, stream-window timeout, terminal cache loss |
| **Misfired solution** | ~10% | Rule 4b cascade, blanket gate, regex over-match |

→ **Insight**: ~75% drift is LLM-side or process-side (ie. tractable bằng harness-engineering thay vì model upgrade). Tool/env drift chỉ ~15% và đa phần đã được L-S32-1 cover.

### F2. Tại sao vẫn có drift dù đã có nhiều hook?

1. **Hook-vs-LLM vocabulary arms race**: LLM nói câu mới, hook regex chưa cập nhật. Self-pause Mode-E là exemplar.
2. **Self-attestation telemetry không có**: D2-SELF-ATTEST hits 217+55+38/day = LLM tự khen "shipped X" mà hook bắt; không có downstream "LLM tự khen → có thật không?" verifier.
3. **Charter ratification chậm hơn proposal generation**: 4 stale + 4 pending Q&A = backlog grows.
4. **Continuous loop dependence on session-end ritual**: ritual chưa được codify đầy đủ trong CLAUDE.md § Session End checklist.

---

<a name="phần-g"></a>
## Phần G — Open Issues & Blocks

### G1. Critical (đe dọa autonomy)

1. **Self-pause family hook lagging** — 4 recurrence sau 2 hook-extend; tier-3 escalation overdue. **Action**: promote to skill OR charter rule. Reference: M-S47-1, L-S44-1, M-S45-2.
2. **agent-notes.md gap (~140 LOC permanent)** — 17 lesson IDs lost-body-text; auditability degraded. **Action**: insert sentinel marker + cross-reference list of known lost L-IDs (đã làm post-S45); accept không re-derive silently.
3. **`vendor-api-probe.sh` charter-prescribed but not wired** — L-S32-1 doctrine + skill exist nhưng SessionStart hook chưa active → next vendor-API drift sẽ surprise. **Action**: wire vào `.claude/settings.json` SessionStart matcher.
4. **`tier1-bloat-check.sh` companion to memory-tiers.md (CHARTER) but orphan** — bloat won't be caught. **Action**: wire vào Stop matcher.

### G2. High (instrumentation broken — A4 + A8 blocker)

5. **dispatch.jsonl JOIN broken** — 60/88 events `agent_type=unknown-agent`; can't reconcile DISPATCHED↔COMPLETED. **Action**: fix `dispatch-jsonl-recorder.sh` to propagate agent_type via tool_use_id JOIN key.
6. **component-telemetry failure_mode dead** — 4998/5000 null. **Action**: instrument PostToolUse outcome-classification (timeout / permission_denied / hook_block / explicit_error / ok).
7. **tokens_used universally null** — subagent burn unmeasurable. **Action**: SubagentStop hook capture session_metrics from transcript JSON sidecar.
8. **8/12 drift signals never fire** (DR1, DR3, DR5, DR7, DR8, DR10, DR11, DR12) — silent dimensions. **Action**: review drift-signals.md authoring vs `drift-signals-D1-D9.sh` implementation; either retire dead signals OR fix detector.
9. **Sync-tracker dormant 6 ngày** — sample_count 1-5; thresholds CHARTER ≥99 unreachable at this collection rate. **Action**: re-sample at every Stop hook; promote `sync-tracker-update.sh` from orphan to wired.

### G3. Medium (process hygiene)

10. **4 Q&A bundles pending stale 4-7 ngày**:
    - `2026-04-29-004-up06-track-5.5-amendment.md` (oldest, 6+ days)
    - `2026-05-01-001-S35-charter-promote-batch.md`
    - `2026-05-01-002-S41-track-F-scope-gates.md`
    - `2026-05-01-003-S39-track-E-bundle-2-scope-amendments.md` (status=answered-2026-05-04-via-chat, awaiting move)
    **Action**: human bundle review + agent batch-move per contract revision.
11. **Manifest staleness — V1 violation** (7 skills + 2 agents + 25 hooks untagged). **Action**: regenerate manifest from FS scan; ratify in next ADR.
12. **`budget-watchdog.sh` double-wired** (Stop + PostToolUse) — duplicate cliff events. **Action**: pick one event; if both needed, idempotent guard via marker check.
13. **8 duplicate allow rules** between settings.json + settings.local.json. **Action**: dedup; keep narrowest scope.
14. **Checkpoint stale 2 ngày** sau S46/S47. **Action**: per-session-end Stop hook ensure latest.md updated.

### G4. Low (documentation drift)

15. **`scheduled_tasks.lock`** in `.claude/` not enumerated.
16. **`.claude/hooks/` directory** with only `pre-commit.example` — leftover convention.
17. **Profile-template** (4 cards Track 9 seed only) — empirically too thin to ground capability-map.
18. **Sessions log non-contiguous numbering** — missing close logs S1, S3, S4, S6, S15, S20-S29, S30, S37, S39, S40, S43a, S44, S45.
19. **D2-SELF-ATTEST + D9-LEARNING-PATH-LEAK acknowledged baseline noise** — signal-to-action loop broken; daily rollup receive no eyeball.
20. **patterns-discovered Day-1 only** — never re-mined despite 17+ mistake entries warranting new patterns.

---

<a name="phần-h"></a>
## Phần H — Hướng Giải Quyết (Recommendations theo Tier)

### Tier 1 — Critical (làm trước khi tiếp tục Phase 3 IMPL)

**T1.1 Wire 2 charter-prescribed orphan hooks** (G1.3 + G1.4):
```jsonc
// .claude/settings.json
"SessionStart": [{ "matcher": "startup|resume", "hooks": [
  { "type": "command", "command": "bash \"${CLAUDE_PROJECT_DIR:-.}/scripts/hooks/vendor-api-probe.sh\"" }
]}],
"Stop": [{ "hooks": [
  { "type": "command", "command": "bash \"${CLAUDE_PROJECT_DIR:-.}/scripts/hooks/tier1-bloat-check.sh\"" }
]}]
```
Effort: ~10 min. Risk: low (cả 2 đều đã smoke-tested khi ship).

**T1.2 Self-pause family Tier-3 escalation** (G1.1):
- **Option A — Skill**: tạo `autonomous-defection-detector` skill — semantic check ở mỗi turn-end (không chỉ regex), sử dụng prompt template phát hiện "any flavor of routing-branch enumeration / await-confirmation / next-step-suggestion".
- **Option B — Charter**: codify trong autonomous-protocol.md Rule N+1: "Trong autonomous_mode=true, agent SHALL NOT emit phrases that defer to human selection between options. Recovery requires human verbatim 'continue' OR Stop hook auto-fire Mode-D."
- **Recommended**: Option B trước (cheap, high-leverage), kèm Option A nếu B vẫn recur. Reference Q-E3 cadence.

**T1.3 Git baseline + Edit-only-for-append-only doctrine extended** (đã làm post-S45, verify còn active):
- Confirm `write-vs-edit-guard.sh` PreToolUse HARD-BLOCK còn fire.
- Confirm git baseline còn (ls .git, git log --oneline | head -5).
- Add agent-notes.md, decisions/*.md, mistake-log.md, sync-state.md vào explicit deny-Write list (không chỉ rely vào hook smart-detect).

### Tier 2 — Telemetry Instrumentation Repair (foundation cho A4 + A8)

**T2.1 Fix dispatch.jsonl JOIN** (G2.5):
- `dispatch-jsonl-recorder.sh` PreToolUse capture: `tool_use_id`, `agent_type`, `model`, `prompt_size_chars`.
- SubagentStop capture: `tool_use_id`, `outcome`, `tokens_real`, `duration_ms`, `failure_mode`.
- Verify JOIN: `jq -s 'group_by(.tool_use_id) | map({id: .[0].tool_use_id, dispatched: .[0], completed: .[1]})' dispatch.jsonl`.
- Effort: ~30 min. Test: dispatch a fresh general-purpose agent, verify JOIN row materializes.

**T2.2 Failure mode classification PostToolUse** (G2.6):
- Extend `component-telemetry.sh` PostToolUse: parse tool_result_text for known patterns (`permission denied`, `timeout`, `error:`, `file not found`, `invalid input`).
- Default `failure_mode=ok` only when `outcome=success && stderr empty`.
- Effort: ~45 min.

**T2.3 Subagent token capture** (G2.7):
- SubagentStop hook reads transcript sidecar (Claude Code provides `${CLAUDE_TRANSCRIPT_PATH}` per docs) → extract last `usage` block → emit to dispatch.jsonl COMPLETED row.
- Effort: ~30 min after T2.1 lands.

**T2.4 Drift-signals coverage repair** (G2.8):
- Audit `drift-signals.md` DR1-DR12 vs `drift-signals-D1-D9.sh` implementation.
- 8 signals never fire ⇒ either spec drift (signal removed but not from doc) OR detector dead.
- Decision: retire dead signals OR fix detector OR convert to LLM-tier (subagent on-demand check).
- Effort: ~1 hour audit + variable fix.

**T2.5 Sync-tracker reactivation** (G2.9):
- Promote `sync-tracker-update.sh` (orphan) → Stop hook wired.
- Per Stop, increment sample_count for relevant category based on session theme (extract from session log frontmatter).
- Re-render `sync-tracker-render.sh` daily for drift attention.
- Effort: ~45 min.

### Tier 3 — Process Hygiene

**T3.1 Manifest regeneration ritual** (G3.11):
- Cron-style hook (or session-end addition): run `scripts/hooks/manifest-sync-check.sh` (NEW) — diff FS vs manifest, emit warning + optionally auto-update.
- Codify trong session-end ritual: "if any new skill/agent/hook ship → update manifest in same commit/turn".
- Effort: ~1 hour (hook write + add to Stop).

**T3.2 Q&A lifecycle revision** (G3.10):
- Revise contract Rule #4: allow agent move from `pending/` → `answered/` IF (a) answer detected in chat (qa-answered-detector hook) AND (b) human did not explicitly say "wait" within 24h.
- Avoid current dead-lock: agent emits answer in chat, human reads but never moves file → file goes stale → defer_cycle increments → never re-grilled.
- Effort: ~30 min contract edit + ~15 min hook adjust.

**T3.3 Dedupe budget-watchdog wiring** (G3.12):
- Pick one event (Stop preferred — fires per turn-end; PostToolUse fires per tool call = noisier).
- Effort: ~5 min.

**T3.4 Settings dedup pass** (G3.13):
- Remove 8 duplicate allow rules; review settings.local.json for any rules made redundant by global.
- Effort: ~15 min.

**T3.5 Checkpoint freshness gate** (G3.14):
- Stop hook: check `latest.md` mtime vs current_ts; if >2h stale + session_id changed → emit warning at Stop banner.
- Effort: ~20 min.

### Tier 4 — Observability/Reusability/Long-game

**T4.1 Self-attestation verifier** (F2 — close the D2 signal-to-action loop):
- Today: D2-SELF-ATTEST hits 217+55+38/day; nobody downstream verifies.
- New hook: `self-attest-verifier.sh` Stop — for each "shipped X" / "completed Y" / "added Z" claim in session log, attempt deterministic verification (file exists / line count matches / test passes).
- Emit mismatch as drift-rollup entry with severity HIGH.
- Effort: ~2 hours.

**T4.2 Subagent verdict scope-check** (M-S35-2 mitigation):
- Stop hook (or sandwich-verifier brief addendum): post-subagent emit 1-line "Scope check: subagent ran [DR1-DR12 / Track F audit / etc.]; this session also required [X, Y, Z] which were NOT in subagent scope."
- Forces explicit anti-echo-chamber accounting.
- Effort: ~1 hour brief edit + watchdog.

**T4.3 Confidence-score sample bootstrap** (E2 — A8 unblock):
- Current sample_count 1-5/category → thresholds unreachable.
- Bootstrap: extract historical decisions D-001..D-027 → backfill samples for relevant categories (LANGUAGE/DOMAIN_UBIQUITOUS/DESIGN_THINKING/SCOPE/DECISION_ROUTING).
- Target: each category ≥30 samples (statistical floor) → tier scoring becomes meaningful.
- Effort: ~3 hours backfill + ~1 hour weights.yaml recalibration.

**T4.4 Karpathy outer-loop revival** (E2 — A8):
- learning-data/loop has 1 file 2026-04-29 single-iteration.
- Schedule weekly Stop-hook trigger: detect signal candidate → instantiate `try-n-approaches` skill → propose ≥3 distinct approaches → write experiment frame.
- Effort: ~2 hours scaffolding.

**T4.5 Manifest regeneration + portability smoke test** (A10):
- After T3.1 lands, run `/attach` skill against test directory; verify all 23 skills + 14 agents + 36 wired hooks copy correctly.
- Effort: ~1 hour.

**T4.6 Telegram (or alternative) notify channel** (A1.notify):
- File 02:14 mentioned "notify human qua channel (telegram)" — currently only continue-injector + Stop banner exist.
- For 24/7 background-running, Telegram bot or system notifier (Windows toast) for human attention to Q&A pending.
- Effort: ~3 hours initial bot wire + integration.

### Tier 5 — Strategic (charter-tier consideration)

**T5.1 Codify "self-pause is a Mode-E charter violation"** (T1.2 Option B).
**T5.2 Add "telemetry instrumentation = Tier-1 deterministic gate" to charter** — make T2 work non-deferrable.
**T5.3 Add "manifest sync at session-end" to CLAUDE.md § Session End checklist** — make T3.1 ritual.
**T5.4 Doctrine "fix-made-it-worse retrospective on every same-turn ship"** — capture Episode 3 + S46 + S7 + D-013 pattern explicitly.

---

<a name="phần-i"></a>
## Phần I — Reusability / Portability Assessment (A10)

### I1. Cấu trúc layer hiện có

```
.claude/
├── manifest.yaml          # layer tags (harness/biz/personal/hybrid)
├── settings.json          # project-committed (harness + some biz)
├── settings.local.json    # gitignored personal
├── agents/                # 14 (12 tagged harness, 2 untagged drift)
├── commands/              # 14 (all tagged harness)
├── skills/                # 23 (16 tagged, 7 untagged drift)
└── hooks/                 # only pre-commit.example (unused convention)

scripts/hooks/             # 47 actual hooks (18 tagged harness, 5 tagged biz, 1 hybrid, 25 untagged drift)
agent-workspace/
├── constitution/          # all harness (general rules) — portable as-is
├── memory/                # mixed: schemas portable, content project-specific
└── learning-data/         # schemas portable, indices project-specific
```

### I2. `/attach` mechanism

`attach` skill exists (`.claude/skills/attach/SKILL.md`). Reads manifest.yaml, identifies `attach.default_includes` (11 harness skills + 18 hooks) + `default_excludes` (5 stockforge skills + 5 stockforge hooks). Generates skeleton CLAUDE.md + manifest at target.

### I3. Khả thi vs gap

**Khả thi**:
- Constitution layer 100% portable (general AI-first principles + Karpathy + drift signal taxonomy + VBW protocol + memory tiers).
- Sandwich pattern + meta agents (intent-classifier / drift-detector / lesson-synthesizer / spec-author / etc.) 100% portable.
- 14 commands all generic.
- ~75% hooks (deterministic gates, telemetry, hook-lint) generic.

**Gap**:
- Manifest 6 ngày stale, V1 violation 7 skills + 2 agents + 25 hooks → `/attach` MISS them silently.
- 5 biz skills mixed into `.claude/skills/` (crawler-reliability, evidence-extraction, fastapi-module, postgres-pgvector, prompt-engineering) → manifest tags correctly nhưng `default_excludes` only lists scripts hooks, not skills.
- `agent-workspace/memory/` content project-specific (project.md, sessions/, decisions/, drift-logs/, sync-state, etc.) → cần fresh init at new project, không port.
- `human-workspace/` content project-specific.
- CLAUDE.md harness-aware nhưng có biz hard-rules ("NO LLM math", "every claim cites source", I-S1..I-S35) → fork "general harness CLAUDE.md template" ra cho `/attach`.

**Recommended portability flow**:
1. T3.1 (manifest regen) → restore V1 invariant.
2. T4.5 (smoke test `/attach` to test dir) → verify all artifacts copy.
3. Author "general harness CLAUDE.md template" (strip stockforge invariants + biz hard rules; keep Karpathy + sandwich + memory + Q&A doctrine).
4. Document `attach.default_includes` add: 7 untagged skills (decompose-work / empirical-probe-first / hook-diagnostics / promote-rule / session-memory-l0-l1 / sync-pull / try-n-approaches), 2 untagged agents (lesson-synthesizer / research-scanner), 25 untagged hooks.
5. Test against fresh empty directory → bring up baseline harness in <5 min.

---

<a name="phần-j"></a>
## Phần J — Action Items đề xuất sau audit

### Phase A (immediate, dưới 4h work)
- [ ] **A1**: Wire `vendor-api-probe.sh` SessionStart + `tier1-bloat-check.sh` Stop (T1.1).
- [ ] **A2**: Verify `write-vs-edit-guard.sh` còn fire + git baseline còn (T1.3).
- [ ] **A3**: Dedupe `budget-watchdog.sh` wiring (T3.3) + 8 duplicate allow rules (T3.4).
- [ ] **A4**: Update checkpoint to S46+S47+S48; ensure `latest.md` reflects post-S48 state.
- [ ] **A5**: Move 4 stale Q&A bundles per contract revision OR human batch close.

### Phase B (telemetry repair, ~6h work)
- [ ] **B1**: Fix dispatch.jsonl JOIN (T2.1).
- [ ] **B2**: PostToolUse failure_mode classification (T2.2).
- [ ] **B3**: SubagentStop tokens_used capture (T2.3).
- [ ] **B4**: Drift-signals coverage audit + retire/fix dead signals (T2.4).
- [ ] **B5**: Sync-tracker reactivation (T2.5).

### Phase C (process & charter, ~4h work)
- [ ] **C1**: Self-pause Mode-E charter rule (T1.2 Option B; consider Option A nếu vẫn recur).
- [ ] **C2**: Manifest regeneration ritual (T3.1).
- [ ] **C3**: Q&A lifecycle contract revision (T3.2).
- [ ] **C4**: Self-attestation verifier hook (T4.1).
- [ ] **C5**: Subagent verdict scope-check (T4.2).

### Phase D (long-game, scope outside Phase 3)
- [ ] **D1**: Confidence-score sample bootstrap from D-001..D-027 (T4.3).
- [ ] **D2**: Karpathy outer-loop revival (T4.4).
- [ ] **D3**: Notify channel (Telegram or Windows toast) (T4.6).
- [ ] **D4**: Portability smoke test + general harness template (T4.5 + I3.3).

### Phase E (post-mortem theme)
- [ ] **E1**: Capture "fix-made-it-worse" doctrine post-mortem (T5.4 — Episode 3 + S46 + S7 + D-013).
- [ ] **E2**: Update CLAUDE.md § Session End checklist (manifest sync, lesson-synthesis explicit, mistake-log update).

---

## Kết Luận

**Hệ thống harness đang đi đúng hướng nhưng còn 25% gap.** Mature qua 5 catastrophic recovery, ratify 27 ADRs trong 7 ngày, nhưng ba mảng chính cần bồi đắp:

1. **Telemetry (A4 + A8)** — dispatch + component-telemetry + sync-tracker bị broken at JOIN/instrumentation layer. Nếu không sửa, "đo để self-upgrade" mất nền tảng.
2. **Self-pause defection (A1)** — LLM vocabulary game đang vượt regex; cần Tier-3 (skill/charter) escalation.
3. **Manifest staleness (A10)** — `/attach` portability promise sẽ broken cho dự án mới nếu không regen.

**Đa phần drift là LLM-side hoặc process-side** (~75% theo F1) — tractable bằng harness-engineering, không cần model upgrade. **Tool/env drift chỉ ~15%** và đã được L-S32-1 cover.

**Self-improvement loop có shell hoàn chỉnh** (Karpathy outer-loop scaffold + try-n-approaches + decompose-work + capability-map + 4 self-awareness loops) **nhưng dormant** ở Stage 2/3 — cần T4.3 + T4.4 để wake up.

**Reusability premise đúng** (constitution + sandwich + meta agents + commands phần lớn portable) **nhưng manifest stale làm `/attach` MISS** 35 artifacts → chưa thể port sang dự án khác mà không thủ công verify.

**Khuyến nghị thứ tự**:
1. Phase A (4h) — quick wins, không risk.
2. Phase B (6h) — telemetry foundation cho mọi self-upgrade tiếp theo.
3. Phase C (4h) — đóng các loop đã identify.
4. Phase D (long-game) — chỉ làm sau khi Phase 3 IMPL ổn.

Total Phase A+B+C ~14 giờ work; nếu shipped sẽ raise alignment từ ~70% → ~88-90%, đồng thời bảo đảm portability cho dự án sau.

---

**Audit signed**: main-session opus47-max, 2026-05-05.
**Next audit recommended**: after Phase C ships, OR sau 10 sessions, OR khi catastrophic episode tiếp theo (whichever first).
