# Chương 3 — Kiến Trúc

> **Phân khu Diataxis**: Explanation + Reference
> **Thời gian đọc**: ~30 phút
> **Điều kiện tiên quyết**: Chương 2 (Mô Hình Tư Duy)

Chương này là bản đồ hệ thống. Nó cho thấy cái gì tồn tại vật lý, các thành phần được layered như thế nào, và mỗi loại công việc xảy ra ở đâu.

Nếu bạn chỉ đọc một chương cho mục đích tham khảo, hãy đọc chương này — nó cho bạn biết *để các thứ ở đâu*.

---

## Tám Tầng (Layers)

Harness được tổ chức trong tám tầng chức năng, mỗi tầng có một trách nhiệm riêng biệt và một change cadence riêng biệt:

```
┌────────────────────────────────────────────────────────────────────────┐
│  LAYER 8 — APPLICATION                                                  │
│  apps/  packages/  bdd/  specs/  obsidian-vault/wiki/                   │
│  Where the StockForge product lives. The harness governs everything     │
│  below; this is what the harness exists to build.                       │
├────────────────────────────────────────────────────────────────────────┤
│  LAYER 7 — LIFECYCLE                                                    │
│  agent-workspace/master-plans/  agent-workspace/session-plans/          │
│  agent-workspace/memory/sessions/  decisions/  checkpoints/             │
│  Plans, sessions, ADRs, handoffs. The temporal structure.               │
├────────────────────────────────────────────────────────────────────────┤
│  LAYER 6 — MEMORY                                                       │
│  agent-workspace/memory/  human-workspace/  obsidian-vault/raw/         │
│  Persistent state. The "filesystem brain" the agent reads and writes.   │
├────────────────────────────────────────────────────────────────────────┤
│  LAYER 5 — SUBAGENTS                                                    │
│  .claude/agents/  (14 personas)                                         │
│  Fresh-context worker definitions. The personalities you dispatch.      │
├────────────────────────────────────────────────────────────────────────┤
│  LAYER 4 — COMMANDS                                                     │
│  .claude/commands/  (16 slash commands)                                 │
│  User-facing entry points. Thin wrappers over skills or subagents.      │
├────────────────────────────────────────────────────────────────────────┤
│  LAYER 3 — SKILLS                                                       │
│  .claude/skills/  (23 reusable procedures)                              │
│  Auto-discoverable patterns Claude invokes when context matches.        │
├────────────────────────────────────────────────────────────────────────┤
│  LAYER 2 — HOOKS                                                        │
│  scripts/hooks/  (118 scripts) + scripts/hooks/firing-tests/ (115)      │
│  Deterministic event handlers. The mechanical enforcement.              │
├────────────────────────────────────────────────────────────────────────┤
│  LAYER 1 — CONSTITUTION + IDENTITY                                      │
│  PROJECT_CHARTER.md  CLAUDE.md  agent-workspace/constitution/ (17)      │
│  .claude/settings.json (allow/deny/env/hooks wiring)                    │
│  Immutable foundation. Defines what the system is and is not.           │
└────────────────────────────────────────────────────────────────────────┘
```

Các tầng thấp hơn quản lý các tầng cao hơn. Các quy tắc Constitution được check bởi Hooks; Hooks được wired trong settings.json; Skills, Commands, Subagents tôn trọng Constitution; Memory được định hình bởi Constitution và Hooks; các artifact Lifecycle (plans, sessions, ADRs) ghi lại những gì xảy ra ở mỗi tầng; tầng Application là cái được xây.

### Change Cadence Per Layer

| Layer | Change cadence | Ai có thể thay đổi |
|---|---|---|
| 1 — Constitution | Chậm (tháng); yêu cầu cool-down | Chỉ human (bị denied cho agent) |
| 2 — Hooks | Trung bình (mỗi lesson đáng kể) | Agent có thể thêm; LOC-ceiling enforced |
| 3 — Skills | Trung bình | Agent có thể thêm qua skill `write-a-skill` |
| 4 — Commands | Trung bình-nhanh | Agent có thể thêm |
| 5 — Subagents | Trung bình | Agent có thể thêm qua template đã thiết lập |
| 6 — Memory | Nhanh (mỗi session) | Agent ghi; retention hook thực thi caps |
| 7 — Lifecycle | Nhanh (mỗi session) | Agent ghi; lifecycle hook thực thi structure |
| 8 — Application | Nhanh (mỗi task) | Agent ghi theo sandwich pattern |

Đọc từ trên xuống dưới: **các tầng sâu nhất thay đổi chậm nhất**.

---

## Hai Workspace

Phía trên tám tầng có thêm một phân biệt tổ chức nữa: **workspace dualism**.

```
stockforge/
├── agent-workspace/         ← AGENT owns this. Human reads, rarely edits.
│   ├── constitution/        ← (read-only to agent)
│   ├── memory/              ← agent writes freely
│   ├── master-plans/        ← agent writes per /master-plan
│   ├── session-plans/       ← agent writes per architect
│   ├── proposals/           ← agent writes; awaits human ratification
│   ├── ubiquitous-language/ ← agent writes via /drill-me
│   ├── calibration/         ← agent appends per post-mortem
│   ├── research/            ← agent writes per research-scanner
│   ├── post-mortems/        ← agent writes after significant failure
│   └── quality-reports/     ← agent writes per gate run
│
└── human-workspace/         ← HUMAN owns this. Agent has narrow write rights.
    ├── user_prompt/         ← human writes; agent reads (cannot edit)
    ├── decisions/           ← human writes formal ratifications
    ├── q-and-a/
    │   ├── pending/         ← agent writes when asking; auto-mv to answered/
    │   ├── answered/        ← either side moves (per auto-mv rule)
    │   └── stale/           ← hooks move >48h items
    └── notifications/
        └── urgent.md        ← agent appends; human reads
```

Sự lưỡng tính (dualism) được sinh ra từ một thất bại thật trong một dự án chị em: mutation shared-workspace gây ra [charter drift](12-noi-tai.md#cf-dogfood-2). Sự phân chia làm provenance trở nên truy được — owner của mọi file là tường minh, mọi giao tiếp xuyên biên giới là một kênh có tên.

Xem [Chương 8 § Workspace Dualism](08-vong-doi.md#workspace-dualism) cho chi tiết quy tắc auto-mv.

---

## File-Level Layout (Từ Trên Xuống Dưới)

Đây là layout canonical. Ghi nhớ tên; chúng xuất hiện trong mọi chương.

```
stockforge/
│
├── PROJECT_CHARTER.md                        ← L1: vision + 11 principles (immutable)
├── CLAUDE.md                                  ← L1: always-loaded project instructions
├── AGENT_OPERATING_MANUAL.md                 ← L1: living operations doc
├── SPEC_TEMPLATE.md                           ← L1: dual-layer spec template
│
├── .claude/                                   ← Claude Code convention dir
│   ├── settings.json                          ← L1: permissions + env + hooks wiring
│   ├── settings.local.json                    ← L1: local (gitignored) overrides
│   ├── manifest.yaml                          ← L1: harness metadata
│   ├── skills/  (23 dirs each w/ SKILL.md)    ← L3: skills
│   ├── commands/  (16 *.md)                   ← L4: slash commands
│   ├── agents/  (14 *.md)                     ← L5: subagent personas
│   └── hooks/  (1 example)                    ← L2: pre-commit example (not Claude Code hooks)
│
├── scripts/
│   ├── hooks/  (118 *.sh)                     ← L2: Claude Code event hooks
│   │   └── firing-tests/  (115 *.sh)          ← L2: companion firing tests
│   ├── drift-check/                           ← L2: drift CLI runners
│   ├── session-handoff.sh                     ← L2: handoff utility
│   ├── session-self-reboot.sh                 ← L2: cliff auto-reboot
│   ├── sync-tracker-bootstrap.py              ← L2: confidence-score bootstrap
│   └── recover-agent-notes.py                 ← L2: agent-notes recovery
│
├── agent-workspace/
│   ├── CLAUDE.md                              ← L1: workspace contract
│   ├── constitution/  (17 *.md)               ← L1: immutable rules
│   ├── memory/                                ← L6
│   │   ├── project.md
│   │   ├── current-execution.md               ← L7: routing source-of-truth
│   │   ├── agent-notes.md                     ← L6: learned rules
│   │   ├── mistake-log.md                     ← L6: failure catalog
│   │   ├── capability-map.md
│   │   ├── personal-risk-profile.md
│   │   ├── sync-state.md
│   │   ├── boot-summary.md
│   │   ├── routing-config.md
│   │   ├── component-telemetry.jsonl
│   │   ├── cost-ledger.tsv
│   │   ├── dispatch.jsonl
│   │   ├── attestation-log.tsv
│   │   ├── up-intake-log.md
│   │   ├── MEMORY.md                          ← user auto-memory index
│   │   ├── sessions/                          ← L7: append-only session logs
│   │   ├── decisions/                         ← L7: ADRs D-001..D-NNN
│   │   ├── observations/                      ← L6: subagent return artifacts
│   │   ├── checkpoints/                       ← L7: handoff state
│   │   ├── drift-logs/                        ← L9: drift detection results
│   │   ├── post-mortems/                      ← L6: failure post-mortems
│   │   ├── patterns-discovered/               ← L6: pattern mining outputs
│   │   ├── self-awareness/                    ← L6: model profile cards
│   │   ├── sync-tracker/                      ← L9: confidence-score store
│   │   ├── indexes/                           ← L6: rendered indexes
│   │   ├── etl-queue/                         ← L6: pending memory ETL
│   │   ├── handoff-logs/                      ← L7: handoff history
│   │   ├── telemetry-archive/                 ← L6: rotated telemetry
│   │   └── thesis-log/                        ← L8: stock thesis records
│   │
│   ├── master-plans/                          ← L7: phase-level plans
│   ├── session-plans/
│   │   ├── pending/                           ← L7: not-yet-executed plans
│   │   └── completed/                         ← L7: executed plans
│   ├── proposals/                             ← L1: pre-ratification drafts
│   ├── ubiquitous-language/                   ← L6: DDD glossary
│   ├── calibration/                           ← L6: hit-rate data
│   ├── research/                              ← L6: research notes
│   ├── post-mortems/                          ← L6: cross-cutting post-mortems
│   ├── role-packs/                            ← L6: role context packs
│   ├── learning-data/                         ← L6: learning loop datasets
│   ├── raw-sessions/                          ← L7: exported transcripts
│   ├── thesis-log/                            ← L8: cross-link to memory/thesis-log
│   └── quality-reports/
│       ├── deterministic/                     ← L9: tier-1 outputs
│       ├── probabilistic/                     ← L9: tier-2 outputs
│       └── drift-reports/                     ← L9: drift run reports
│
├── human-workspace/
│   ├── user_prompt/                           ← L1: human-written prompts
│   ├── decisions/                             ← L1: human ratifications
│   ├── q-and-a/
│   │   ├── pending/                           ← L4: agent asks
│   │   ├── answered/                          ← L4: resolved
│   │   └── stale/                             ← L4: >48h unanswered
│   └── notifications/
│       └── urgent.md                          ← L4: severity escalations
│
├── obsidian-vault/
│   ├── raw/                                   ← L6: immutable source material
│   ├── wiki/                                  ← L8: agent-owned knowledge
│   ├── CLAUDE.md                              ← L1: vault contract
│   └── .obsidian/
│
├── specs/                                     ← L8: living specs
│   ├── tier1-strategic/
│   ├── tier2-feature/
│   └── tier3-task/
│
├── bdd/                                       ← L8: BDD test catalog
├── packages/                                  ← L8: monorepo packages (9 BCs)
│   ├── domain/  (BC-1..BC-9)                  ← pure Python; no framework
│   ├── application/                           ← use cases, ports (Protocol)
│   ├── infrastructure/                        ← adapters (DB, LLM, scraper)
│   ├── contracts/                             ← cross-BC schemas + events
│   └── _shared/                               ← shared utilities
│
├── apps/                                      ← L8: deployable apps
│   ├── dashboard/                             ← Streamlit (Phase 1-2)
│   ├── api/                                   ← FastAPI gateway (Phase 2+)
│   └── workers/                               ← Background workers
│
├── tests/                                     ← L8
├── eval-sets/                                 ← L8: eval ground truth
├── templates/                                 ← L8: project templates
├── prompts/                                   ← L8: LLM prompt library
├── data/                                      ← L8: data working dir
└── docs/
    ├── DAY_1_CHECKLIST.md                     ← L1: first-time guide
    └── harness/                               ← (this book)
        ├── en/
        ├── vi/
        ├── reference/
        ├── assets/
        └── IA.md
```

Độ sâu của `agent-workspace/memory/` là cố ý. Mỗi subdirectory có một mục đích đơn lẻ, hẹp. Harness tránh đổ vào một `memory/notes.md` lớn duy nhất bởi vì **structure là cái làm memory query được**.

---

## Data Flow — Một Session Duy Nhất, Từ Đầu Đến Cuối

Đây là cái xảy ra, từng bước một, khi bạn chạy một session:

```
USER opens claude → SessionStart hooks fire (22 of them)
  │
  ├─ single-claude-instance-lock.sh acquires .claude-instance.lock
  ├─ essential-routing-fields-verifier.sh validates current-execution.md
  ├─ working-memory-budget-audit.sh measures Tier-1 load (must be ≤8K per HH-5)
  ├─ session-start-bootstrap.sh emits checkpoint additionalContext
  ├─ vendor-api-probe.sh checks Anthropic API reachable
  ├─ qa-pending-stale-mover.sh moves >48h Q&A bundles
  ├─ qa-answered-detector.sh re-classifies status= changes
  ├─ sync-grilling-trigger.sh checks 38-session / 7-day grilling threshold
  ├─ learning-queue-sweeper.sh promotes pending lessons
  ├─ ghost-work-audit.sh checks for in-flight subagent orphans
  ├─ proposal-bundle-advisor.sh checks 48h cool-down on proposals
  ├─ checkpoint-marker-cleanup-resume.sh clears markers + surfaces next_action
  ├─ in-flight-subagent-watcher.sh checks for unattended dispatches
  ├─ session-start-scan-unattested-observations.sh checks for orphan obs
  ├─ idle-escape-detector.sh checks for routine-idle loop pattern
  ├─ phase-status-coherence.sh diffs project.md ↔ current-execution.md
  ├─ harness-health-self-scan.sh runs HH-1..HH-12 catalog
  ├─ idle-state-advisory.sh aggregates idle signals
  ├─ escalation-engine.sh acts on .severity-state.tsv rows
  └─ continue-injector-spawn.sh dispatches PowerShell continue (if /clear)
  │
USER types prompt → UserPromptSubmit hooks fire (13 of them)
  │
  ├─ block-control.sh check-prompt (auto-clears on "approved" reply)
  ├─ autonomous-block-enforcer.sh (denies tools if BLOCKED flag set)
  ├─ escalation-engine.sh (re-checks severity state)
  ├─ userprompt-invariants-injector.sh (injects I-S1/I-S2/I-S35 reminders)
  ├─ stale-prompt-detector.sh (flags >24h old references)
  ├─ correction-rate-tracker.sh (counts user corrections per turn)
  ├─ in-flight-subagent-watcher.sh (orphan check)
  ├─ hook-firing-counter.sh (tallies hook fires this turn)
  ├─ effort-escalation-detector.sh (recommends ladder up/down)
  ├─ idle-escape-detector.sh UserPromptSubmit (routine-idle escape)
  ├─ phase-status-coherence.sh UserPromptSubmit (drift check)
  ├─ harness-health-self-scan.sh UserPromptSubmit (12-signal re-scan, cached)
  └─ idle-state-advisory.sh UserPromptSubmit
  │
LLM thinks → tool call (e.g., Edit) → PreToolUse hooks fire (9 of them)
  │
  ├─ destructive-command-guard.sh (deny rm -rf, drop table, etc.)
  ├─ pre-dispatch-architect-commit-guard.sh (no auto-commit by architect)
  ├─ pre-commit-pytest-regression-guard.sh (tests pass before commit)
  ├─ autonomous-block-enforcer.sh (BLOCKED flag denies tool)
  ├─ dispatch-jsonl-recorder.sh (records Agent calls to dispatch.jsonl)
  ├─ write-vs-edit-guard.sh (L-S45-2: protect append-only memory files)
  ├─ checkpoint-write-end-turn-watchdog.sh (after checkpoint write = end turn)
  ├─ pre-dispatch-adr-number-check.sh (verify ADR number not in use)
  └─ effort-escalation-detector.sh
  │
Tool executes → PostToolUse hooks fire (10 of them, filtered)
  │
  ├─ budget-watchdog.sh (transcript JSONL token sum; 180K / 220K / 250K)
  ├─ python-determinism-check.sh (Edit|Write|MultiEdit only; R1-R4 patterns)
  ├─ atomic-write-check.sh (atomic temp+replace pattern)
  ├─ html-separator-check.sh (no <hr> / *** / --- in production)
  ├─ path-safety-check.sh (P1-P5 sandbox/UNC/traversal)
  ├─ dispatch-jsonl-recorder.sh (post-call telemetry)
  ├─ component-telemetry.sh (per-tool JSONL)
  ├─ post-tool-citation-grep.sh (I-S2 citation enforcement)
  ├─ loc-ceiling-check.sh (D1 LOC ceiling per category)
  └─ checkpoint-write-marker.sh (mark .checkpoint-written-<sid>)
  │
SUBAGENT dispatched → SubagentStop hooks fire when it returns
  │
  ├─ subagent-stop-logger.sh
  ├─ post-dev-dispatch-attestation-check.sh
  ├─ component-telemetry.sh
  ├─ dispatch-jsonl-recorder.sh (FIFO match: DISPATCHED + COMPLETED)
  └─ cost-ledger-recorder.sh (USD cost per dispatch)
  │
SESSION ends → Stop chain fires (50+ hooks)
  │
  [see Chapter 6 § Stop chain for full sequence; the most important are]
  ├─ tracking-retention.sh (retention caps; auto-archive)
  ├─ budget-watchdog.sh (final tally)
  ├─ pre-checkpoint-close-verifier.sh (handoff state valid)
  ├─ drift-signals-D1-D9.sh (run drift catalog)
  ├─ severity-classifier.sh (Phase A of severity pipeline)
  ├─ escalation-engine.sh (Phase B)
  ├─ session-end-checklist-linter.sh (mistake-log discipline)
  ├─ cost-ledger-recorder.sh (final USD)
  ├─ promotion-cycle-trigger.sh (≥8 lessons → block until promote-rule)
  └─ daily-backup.sh (out-of-tree backup, idempotent per day)
```

Đây là một session. Mọi layer đều tham gia. Công việc Application (file edit của bạn) ngồi trên đỉnh; layer Hooks bao quanh mọi tool call; Constitution thông tin cho hook nào block hay warn; layer Memory ghi lại mọi thứ; layer Lifecycle (session log) append biên nhận.

---

## Để Các Thứ Mới Ở Đâu

Khi bạn muốn thêm điều gì đó vào harness, hỏi: **đó là loại thứ gì?** Sau đó đặt nó vào đúng layer.

| Cái bạn đang thêm | Nó đi đâu | Cơ chế |
|---|---|---|
| Một quy trình LLM-mediated dùng lại được (3+ session đã dùng nó) | Layer 3 — `.claude/skills/<name>/SKILL.md` | Dùng skill [`write-a-skill`](05-skills-commands-agents.md#write-a-skill) |
| Một lối tắt user-typed cho hành động chung | Layer 4 — `.claude/commands/<name>.md` | File command mới |
| Một persona fresh-context (architect, verifier, v.v.) | Layer 5 — `.claude/agents/<name>.md` | File agent mới với frontmatter |
| Một check deterministic nên fire trên event X | Layer 2 — `scripts/hooks/<name>.sh` + firing-test | Hook mới + wire trong settings.json |
| Một quy tắc bất biến mới | Layer 1 — `agent-workspace/proposals/<name>.md` → constitution sau khi ratification | Propose, cool-down, ratify, mv |
| Một loại memory artifact persistent mới | Layer 6 — `agent-workspace/memory/<subdir>/` | Subdir mới + thêm vào MEMORY.md |
| Một ADR mới | Layer 7 — `agent-workspace/memory/decisions/NNN-<slug>.md` | Số tuần tự + schema 12 trường |
| Một tính năng mới (code) | Layer 8 — `packages/<bc>/` hoặc `apps/<app>/` | Sandwich pattern (architect → dev → verifier) |
| Một spec mới | Layer 8 — `specs/tier{1,2,3}-*/NNN-<slug>.md` | Command `/spec-author` |
| Scraper / data adapter mới | Layer 8 — `packages/infrastructure/` | Dùng skill [`crawler-reliability`](05-skills-commands-agents.md#crawler-reliability) |

Nếu bạn không biết một thứ thuộc về layer nào, hỏi agent: nó sẽ route bạn bằng [`memory-routing-tree.md`](../../../agent-workspace/constitution/memory-routing-tree.md).

---

## Stack Nhìn Từ Dưới

Nếu bạn đọc chương này từ trên xuống dưới, bạn đọc tầng application trước. Bây giờ đọc nó từ dưới lên trên.

**Layer 1 (Constitution)** nói: "Đây là các quy tắc. Chúng không thay đổi mà không ratification."

**Layer 2 (Hooks)** nói: "Tôi sẽ check các quy tắc mỗi khi bất cứ điều gì xảy ra. Nếu bạn vi phạm một cái, tôi sẽ block hoặc warn hoặc escalate."

**Layer 3 (Skills)** nói: "Khi context trông như X, đây là quy trình."

**Layer 4 (Commands)** nói: "Khi người dùng gõ `/X`, chạy quy trình này."

**Layer 5 (Subagents)** nói: "Khi bạn cần context tươi mới, dispatch một trong các persona này."

**Layer 6 (Memory)** nói: "Đây là state của thế giới. Đọc tôi trước khi hành động; cập nhật tôi sau."

**Layer 7 (Lifecycle)** nói: "Đây là các nghi thức (ritual) của bắt đầu, lập kế hoạch, thực thi, verify, và đóng."

**Layer 8 (Application)** nói: "Và đây — cuối cùng — là sản phẩm."

Mỗi chương của cuốn sách này là cái nhìn sâu hơn về một trong các layer này.

- **Layer 1** → [Chương 4](04-hien-phap.md)
- **Layer 2** → [Chương 6](06-hooks.md)
- **Layers 3, 4, 5** → [Chương 5](05-skills-commands-agents.md)
- **Layer 6** → [Chương 7](07-he-thong-bo-nho.md)
- **Layer 7** → [Chương 8](08-vong-doi.md)
- **Cross-cutting** → [Chương 9 — Chất Lượng](09-he-thong-chat-luong.md), [Chương 10 — Tự Cải Thiện](10-tu-cai-thien.md)
