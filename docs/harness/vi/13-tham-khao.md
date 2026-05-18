# Chương 13 — Tham Khảo (Reference)

> **Phân khu Diataxis**: Reference (tra cứu thông tin)
> **Thời gian đọc**: ~10 phút (dùng để tra cứu, không phải đọc)
> **Điều kiện tiên quyết**: bất kỳ chương nào

Chương này là reference index. Nó point tới các inventory file trong `docs/harness/reference/` nơi các catalog chi tiết sống.

Split giữa chương này và inventory file là intentional:
- **Chương này** là curated — ngắn, navigable, link ra ngoài
- **Inventory file** là exhaustive — generated/synced với hệ thống live

Khi harness thay đổi, chạy `/harness-docs sync` (xem [Chương 14 § Giữ Sách Đồng Bộ](14-dong-gop.md#keeping-the-book-in-sync)) để regenerate inventory file.

---

## 13.1 — Quick Reference Card

Cách nhanh nhất để tìm bất cứ thứ gì.

| Đang tìm | Đi tới |
|---|---|
| Một skill cụ thể | [Reference § Skills](../reference/inventory-skills.md) |
| Một slash command cụ thể | [Reference § Commands](../reference/inventory-commands.md) |
| Một subagent cụ thể | [Reference § Subagents](../reference/inventory-agents.md) |
| Một hook script cụ thể | [Reference § Hooks](../reference/inventory-hooks.md) |
| Một constitution rule | [Reference § Constitution](../reference/inventory-constitution.md) |
| Một memory file / directory | [Reference § Memory](../reference/inventory-memory.md) |
| Một ADR cụ thể | [Reference § ADRs](../reference/inventory-decisions.md) |
| 11 charter principle | [Chương 4 § The 11 Principles](04-hien-phap.md#the-11-principles-reference) |
| Drift signals DR1-DR12 | [Chương 9 § Drift Signals](09-he-thong-chat-luong.md#93--drift-signals-dr1-dr12) |
| Harness health HH-1..HH-12 | [Chương 9 § Harness Health](09-he-thong-chat-luong.md#94--harness-health-signals-hh-1hh-12) |
| Anti-patterns AP-1..AP-23 | [Chương 12 § 23 Anti-Patterns](12-noi-tai.md#122--23-anti-pattern-ap-1ap-23) |
| Session types + budgets | [Chương 4 § session-budgets](04-hien-phap.md#session-budgets) |
| 9 bounded contexts | [Chương 4 § architecture](04-hien-phap.md#architecture) |

---

## 13.2 — Top-Level File Index

### Project Root

| File | Là gì | Reference |
|---|---|---|
| `PROJECT_CHARTER.md` | Vision + 11 principle (immutable) | [Chương 4 § 4.1](04-hien-phap.md#41--identity-files-always-loaded) |
| `CLAUDE.md` | Project context always-loaded | [Chương 4 § 4.1](04-hien-phap.md#41--identity-files-always-loaded) |
| `AGENT_OPERATING_MANUAL.md` | Living operations doc | reference only |
| `SPEC_TEMPLATE.md` | Dual-layer spec template | reference only |

### `.claude/`

| File / Dir | Là gì | Reference |
|---|---|---|
| `settings.json` | Permissions + env + hooks wiring | [Chương 4 § 4.3](04-hien-phap.md#43--permissions-claudesettingsjson) |
| `settings.local.json` | Local (gitignored) overrides | [Chương 4 § 4.3](04-hien-phap.md#43--permissions-claudesettingsjson) |
| `manifest.yaml` | Harness metadata | reference only |
| `skills/` (23 dir) | Skills | [Chương 5 § 5.2](05-skills-commands-agents.md#52--skills), [Reference](../reference/inventory-skills.md) |
| `commands/` (16 *.md) | Slash command | [Chương 5 § 5.3](05-skills-commands-agents.md#53--commands), [Reference](../reference/inventory-commands.md) |
| `agents/` (14 *.md) | Subagent persona | [Chương 5 § 5.4](05-skills-commands-agents.md#54--subagents), [Reference](../reference/inventory-agents.md) |
| `hooks/pre-commit.example` | Pre-commit example (không phải Claude Code hook) | reference only |

### `scripts/hooks/`

| File / Dir | Là gì | Reference |
|---|---|---|
| `*.sh` (118 script) | Claude Code event hook | [Chương 6](06-hooks.md), [Reference](../reference/inventory-hooks.md) |
| `firing-tests/` (115 *-fire-test.sh) | Companion firing test | [Chương 6 § 6.9](06-hooks.md#69--the-firing-test-discipline-principle-11) |
| `firing-tests/run-all.sh` | Test orchestrator | [Chương 6 § 6.9](06-hooks.md#69--the-firing-test-discipline-principle-11) |

### `agent-workspace/`

| File / Dir | Là gì | Reference |
|---|---|---|
| `CLAUDE.md` | Workspace contract | [Chương 4 § 4.1](04-hien-phap.md#41--identity-files-always-loaded) |
| `constitution/` (17 *.md) | Immutable rule | [Chương 4 § 4.2](04-hien-phap.md#42--the-17-constitution-files), [Reference](../reference/inventory-constitution.md) |
| `memory/` | Persistent state | [Chương 7](07-he-thong-bo-nho.md), [Reference](../reference/inventory-memory.md) |
| `master-plans/` | Phase-level plan | [Chương 8 § 8.3](08-vong-doi.md#83--the-plan-lifecycle) |
| `session-plans/{pending,completed}/` | Session-level plan | [Chương 8 § 8.3](08-vong-doi.md#83--the-plan-lifecycle) |
| `proposals/` | Pre-ratification draft | [Chương 4 § 4.6](04-hien-phap.md#46--amendment-process) |
| `ubiquitous-language/` | DDD glossary | [Chương 5 § Pipeline 2](05-skills-commands-agents.md#pipeline-2--knowledge-base) |
| `calibration/` | Hit-rate data | [Chương 2 § Idea 5](02-mo-hinh-tu-duy.md#idea-5--calibration-over-confidence) |
| `quality-reports/{deterministic,probabilistic,drift-reports}/` | Quality gate output | [Chương 9 § 9.7](09-he-thong-chat-luong.md#97--quality-reports) |
| `research/` | Research note | reference only |
| `post-mortems/` | Cross-cutting post-mortem | reference only |
| `role-packs/` | Role context pack | reference only |
| `learning-data/{events,dogfood,loop,index,archive}/` | Learning loop dataset | reference only |
| `raw-sessions/` | Transcript export | reference only |
| `thesis-log/` | Cross-link sang memory/thesis-log | reference only |

### `human-workspace/`

| File / Dir | Là gì | Reference |
|---|---|---|
| `CLAUDE.md` | Human contract | [Chương 4 § 4.1](04-hien-phap.md#41--identity-files-always-loaded) |
| `user_prompt/` | Prompt do human viết | [Chương 8 § 8.6](08-vong-doi.md#86--workspace-dualism) |
| `decisions/` | Human ratification | [Chương 8 § 8.6](08-vong-doi.md#86--workspace-dualism) |
| `q-and-a/{pending,answered,stale}/` | Q&A bundle | [Chương 8 § 8.7](08-vong-doi.md#87--the-qa-bundle-mega-pattern) |
| `notifications/urgent.md` | Severity escalation | [Chương 6 § 6.6](06-hooks.md#66--the-severity-pipeline) |

### `obsidian-vault/`

| File / Dir | Là gì | Reference |
|---|---|---|
| `CLAUDE.md` | Vault contract | reference only |
| `raw/` | Immutable source material | reference only |
| `wiki/` | Knowledge do agent own | reference only |
| `.obsidian/` | Obsidian config | reference only |

### Application Layer

| File / Dir | Là gì | Reference |
|---|---|---|
| `packages/{domain,application,infrastructure,contracts,_shared}/` | Monorepo (9 BC) | [Chương 4 § architecture](04-hien-phap.md#architecture) |
| `apps/{dashboard,api,workers}/` | Deployable app | reference only |
| `specs/{tier1-strategic,tier2-feature,tier3-task}/` | Living spec | reference only |
| `bdd/` | BDD test catalog | reference only |
| `tests/` | Top-level test | reference only |
| `eval-sets/{thesis-labeled,baseline-results}/` | Eval ground truth | reference only |
| `templates/` | Project template | reference only |
| `prompts/` | LLM prompt library | reference only |
| `data/` | Data working dir | reference only |

---

## 13.3 — Memory File Quick Reference

Các memory file được access nhiều nhất:

| File | Khi đọc | Khi viết |
|---|---|---|
| `current-execution.md` | Mỗi SessionStart (ĐẦU TIÊN) | Tại session boundary + task complete |
| `project.md` | Mỗi SessionStart | Khi có architectural decision |
| `agent-notes.md` | Khi task liên quan tới lesson past | Tại session-end nếu có lesson mới |
| `mistake-log.md` | Tại session-start (pre-flight) | Tại session-end (hoặc attestation M-S<N>-NONE) |
| `MEMORY.md` | Tier 1 always-loaded | Khi user-memory entry được thêm |
| `checkpoints/latest.md` | Tại SessionStart bootstrap | Tại checkpoint write (PostToolUse-triggered) |
| `sessions/YYYY-MM-DD-session-N.md` | 3 file gần nhất đọc tại SessionStart | Tại session-end |
| `decisions/NNN-*.md` | Khi ADR được cite từ plan | Khi new decision được làm |
| `observations/<subagent>-S<N>-<TS>.md` | Khi subagent dispatch complete | Bởi subagent khi return |
| `dispatch.jsonl` | Bởi telemetry hook | PreToolUse(Agent) + SubagentStop |
| `cost-ledger.tsv` | Tại budget audit | Stop + SubagentStop |
| `.session-hooks.log` | Khi debug hook silence | Mỗi hook fire |

---

## 13.4 — Hook Event Quick Reference

| Event | Số hook | Khi fire | Hook quan trọng nhất |
|---|---|---|---|
| SessionStart | 22 | New session | `single-claude-instance-lock`, `session-start-bootstrap`, `harness-health-self-scan`, `continue-injector-spawn` (cuối) |
| SessionEnd | 3 | Session terminate | `session-export-raw` |
| UserPromptSubmit | 13 | Mỗi user prompt | `block-control check-prompt`, `autonomous-block-enforcer`, `userprompt-invariants-injector` |
| PreToolUse | 9 | Trước mọi tool call | `destructive-command-guard`, `write-vs-edit-guard`, `checkpoint-write-end-turn-watchdog`, `autonomous-block-enforcer` |
| PostToolUse | 10 | Sau mọi tool call | `budget-watchdog`, `python-determinism-check`, `atomic-write-check`, `dispatch-jsonl-recorder`, `checkpoint-write-marker` |
| Stop | 50+ | Mỗi assistant turn | `tracking-retention`, `drift-signals-D1-D9`, `severity-classifier`, `escalation-engine`, `session-end-checklist-linter`, `cost-ledger-recorder`, `daily-backup` |
| SubagentStop | 5 | Subagent complete | `subagent-stop-logger`, `dispatch-jsonl-recorder`, `cost-ledger-recorder` |
| PreCompact | 1 | Trước auto-compact | `precompact-thesis-state-dump` |
| Notification | 0 (intentional) | — | — |

---

## 13.5 — Environment Variables Reference

Defined trong block `env` của `.claude/settings.json`. Đọc bởi hook.

| Variable | Default | Mục đích |
|---|---|---|
| `PYTHON_ENV` | `development` | Python environment marker |
| `STOCKFORGE_HOOK_PROFILE` | `standard` | Hook strictness profile (`standard` hoặc `strict`) |
| `STOCKFORGE_SPAWNED` | `false` | Mark session spawned bởi `session-self-reboot.sh` |
| `STOCKFORGE_WIND_DOWN_TOKENS` | `180000` | Token threshold cho handoff prep |
| `STOCKFORGE_CLIFF_TOKENS` | `220000` | Token threshold cho auto-reboot |
| `STOCKFORGE_LOC_STRICT` | `0` | LOC ceiling: 0=warn, 1=block |
| `STOCKFORGE_CITATION_STRICT` | `0` | I-S2 citation: 0=warn, 1=block |
| `STOCKFORGE_DRIFT_STRICT` | `0` | Drift signals: 0=warn, 1=block |
| `STOCKFORGE_SAME_COMMIT_STRICT` | `0` | Same-commit rule: 0=warn, 1=block |
| `STOCKFORGE_WATCHDOG_DISABLE` | `0` | Disable autonomous-stop-watchdog: 0=enabled, 1=disabled |
| `STOCKFORGE_LINT_DOCTRINE_PHASE_0_PORTABILITY` | `0` | Phase 0 portability lint: 0=warn, 1=block |
| `STOCKFORGE_HH_H1_THRESHOLD_S` | `1800` | HH-H.1 checkpoint mtime threshold (giây) |
| `STOCKFORGE_HOOK_BUDGET_USD` | `<varies>` | Per-hook USD budget cap |
| `STOCKFORGE_FORCE_AUTONOMOUS` | `0` | Bypass autonomous-block-enforcer (logged) |
| `STOCKFORGE_FORCE_CONTINUE_ON_CLEAR` | `0` | Force continue-injector spawn on `/clear` |
| `STOCKFORGE_ALLOW_DESTRUCTIVE` | `0` | Bypass destructive-command-guard (logged) |
| `STOCKFORGE_TELEGRAM_BOT_TOKEN` | (unset) | Telegram bot token (trong settings.local.json) |
| `STOCKFORGE_TELEGRAM_CHAT_ID` | (unset) | Telegram chat ID (trong settings.local.json) |
| `STOCKFORGE_TELEGRAM_DRY_RUN` | `0` | Skip live Telegram push |
| `STOCKFORGE_BACKUP_DIR` | `<project-parent>/stockforge-backups/` | Daily backup destination |
| `FIRING_TEST_TIMEOUT` | `30` | Per-fire-test timeout (giây) |

---

## 13.6 — Severity Schema Quick Reference

Theo [`severity-schema.md`](../../../agent-workspace/constitution/severity-schema.md):

| Level | Triggers | Action |
|---|---|---|
| **CRITICAL** | Stale-checkpoint marker, Q&A age ≥96h, charter-violation marker, ghost-greening marker | `.autonomous-BLOCKED` + URGENT + Telegram |
| **HIGH** | Q&A age ≥6h, charter-tier ADR PROPOSED ≥24h, mistake-log severity=high, ALERT-URGENT keyword | URGENT + UserPromptSubmit context + Telegram |
| **MEDIUM** | ARCH/SCOPE PROPOSED ≥12h, notification WARN | Weekly digest |
| **LOW** | Dưới threshold | Log only |

---

## 13.7 — Glossary Pointer

Cho terminology, xem [Chương 15 — Thuật Ngữ](15-thuat-ngu.md).

Các term quan trọng nhất (memorize những cái này):

- **harness** — framework được document trong sách này
- **sandwich pattern** — choreography architect → dev → verifier xuyên 3 session
- **VBW** — Verify-Before-Write protocol (4 checkpoint)
- **AP-N** — anti-pattern N (23 được đặt tên)
- **DR-N / DR-A-N / DR-S-N** — drift signal N
- **HH-N** — harness health signal N (12 catalogued)
- **L-S<N>-<M>** — lesson learned trong session N, sequence M
- **M-S<N>-<M>** — mistake recorded trong session N, sequence M
- **D-NNN** — ADR number NNN (sequential)
- **BC-N** — bounded context N (9 trong stock domain)
- **I-S<N>** — invariant N (general hoặc stock-specific)
- **B-N / SB-N** — hard boundary / soft boundary N
- **Karpathy P1-P4** — Think Before / Simplicity / Surgical / Goal-Driven
- **Tier 1 / Tier 2 / Tier 3** — quality gate (deterministic / probabilistic / human) HOẶC memory tier (always-loaded / JIT / explicit)

---

## 13.8 — Inventory Files

Các inventory chi tiết sống dưới dạng separate reference file. Mỗi cái regenerable từ hệ thống live qua `/harness-docs sync`.

- [`../reference/inventory-skills.md`](../reference/inventory-skills.md) — 23 skill, bảng đầy đủ
- [`../reference/inventory-commands.md`](../reference/inventory-commands.md) — 16 command
- [`../reference/inventory-agents.md`](../reference/inventory-agents.md) — 14 subagent
- [`../reference/inventory-hooks.md`](../reference/inventory-hooks.md) — 118 hook group theo event + category
- [`../reference/inventory-constitution.md`](../reference/inventory-constitution.md) — 17 constitution file
- [`../reference/inventory-memory.md`](../reference/inventory-memory.md) — memory file + directory
- [`../reference/inventory-decisions.md`](../reference/inventory-decisions.md) — tất cả ADR D-001..D-NNN

---

## 13.9 — Đọc Tiếp Ở Đâu

- **Thêm artifact mới** → [Chương 14 — Đóng Góp](14-dong-gop.md)
- **Định nghĩa các term** → [Chương 15 — Thuật Ngữ](15-thuat-ngu.md)
