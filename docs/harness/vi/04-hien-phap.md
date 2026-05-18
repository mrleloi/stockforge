# Chương 4 — Hiến Pháp (Constitution)

> **Phân khu Diataxis**: Reference + Explanation
> **Thời gian đọc**: ~45 phút
> **Điều kiện tiên quyết**: Chương 2 (Mô Hình Tư Duy) cho phần *tại sao*

Constitution là nền tảng bất biến. Mọi thứ ở trên nó có thể thay đổi; constitution chỉ có thể thay đổi qua một quy trình ratification tường minh với cool-down window. Chương này là tham khảo đầy đủ.

Nó tài liệu hóa:

1. **`PROJECT_CHARTER.md`** — 11 nguyên tắc
2. **File identity** (`CLAUDE.md`, các workspace contract)
3. **17 file constitution** tại `agent-workspace/constitution/`
4. **Permissions** tại `.claude/settings.json`
5. **Quy trình amendment**

---

## 4.1 — File Identity (Always-Loaded)

Ba file được nạp tự động vào mỗi session qua cơ chế `CLAUDE.md`. Cùng nhau chúng tiêu thụ **~5-8K token** ([Tier 1 budget theo HH-5](09-he-thong-chat-luong.md#hh-5)).

### `PROJECT_CHARTER.md`

> **Status**: Bất biến v1.1 — thay đổi yêu cầu charter revision tường minh.
> **Revision protocol**: Cool-down 48h + version bump.
> **Lần revision gần nhất**: 2026-05-12 (v1.0 → v1.1, thêm Nguyên tắc 11).

Charter đặt vision, scope, principles, và success criteria. Nó **không** thay đổi với product roadmap — nó chỉ thay đổi khi *bản chất cơ bản* của dự án thay đổi.

| Section | Nó khóa cái gì |
|---|---|
| **Vision** | Hệ thống là gì và không là gì |
| **Core Insight** | Tại sao cấu trúc thị trường chứng khoán Việt Nam biện minh cho cách tiếp cận này |
| **Craft Philosophy** | Self-use trước, commercial sau |
| **11 Principles** | Các quy tắc không thể thương lượng về cách hệ thống vận hành |
| **Four-Tier Signal Architecture** | Hard data / official narrative / influence network / crowd sentiment |
| **First Sub-Scope (6 months)** | VN30 + mid-cap, long-only equity, 1-month+ holds |
| **Honest Boundaries** | Cái hệ thống KHÔNG làm |
| **Success Criteria** | Kết quả đo được tháng 3, 6, 9, 12 |
| **Technical Foundation** | Stack (Python, Postgres, Redis, Claude API) |
| **Anti-Charter** | Cái chúng tôi tường minh từ chối |

### 11 Nguyên Tắc (Tham Khảo)

1. **Evidence grounding** — mọi claim, mọi số phải truy ngược được về source + as-of date.
2. **Structured output over narrative** — multi-criteria assessment, không bao giờ một score buy/sell đơn lẻ.
3. **Adversarial by design** — các perspective bear + bull + critic + quant + behavior + manager.
4. **Proprietary data moat** — mọi tin tức được ingested, mọi KOL recommendation được tracked, mọi thesis được post-mortem'd.
5. **Pattern transfer + local adaptation** — global setups + overlay đặc thù Vietnam.
6. **Human-in-loop is the product** — augment suy nghĩ, không bao giờ thay thế nó.
7. **Dogfood mandatory** — nếu tôi không dùng nó hàng tuần, nó bị giết.
8. **Calibration over confidence** — track độ chính xác của chính mình, không bao giờ claim confidence chưa earn qua hit rate.
9. **No LLM math** — LLM không bao giờ tạo ra số; chỉ deterministic code.
10. **Position sizing & risk management are deterministic** — code-enforced rules; LLM không thể override.
11. **Harness must self-verify firing, not self-attest existence** — mọi hook ship với firing-test; HH-1..HH-12 continuous self-scan.

Các nguyên tắc 9, 10, 11 là **các trụ chịu lực của harness** — chúng định hình hầu hết các hook và quy tắc constitution.

### `CLAUDE.md` (Project Root)

> **Token target**: <2500 (nạp mỗi session).

Đây là project-level always-loaded context. Các section:

- **Identity**: Claude Code là ai trong dự án này
- **Core Principles (Karpathy 4)** — P1 Think Before Coding, P2 Simplicity First, P3 Surgical Changes, P4 Goal-Driven Execution
- **StockForge-Specific Hard Rules** — quy tắc tính toàn vẹn domain
- **Session Protocol** — checklist nghi thức start / end
- **Constitution table** — pointer đến các quy tắc chi tiết
- **Hard Rules (general)** — tính thuần khiết domain framework, BC isolation, VBW protocol, immutability lists, deterministic gates, retention bands
- **Dispatch Rules** — single source of truth
- **Session Types** — 8 type + budget
- **Quality Gates** — 3 tier
- **Common Anti-Patterns** — các sai lầm tần suất cao cần tránh
- **Key References** — chỉ mục pointer file

### `agent-workspace/CLAUDE.md` (Workspace Contract)

Workspace contract của chính agent. Đặt:

- **Identity** — agent-owned execution + memory layer
- **Subdirectory table** — mục đích + lifecycle cho mỗi cái
- **Contract Rules (BINDING)** — 7 quy tắc được đánh số bao gồm ADR discipline, routing source-of-truth, raw/wiki immutability, provenance mandate, phân biệt commit/push
- **Reading Priority** — load order canonical
- **Anti-Patterns** — đặc thù workspace
- **Connection to human-workspace/** — quy tắc auto-mv (HH-E.2 / D-031)

### `human-workspace/CLAUDE.md` (Human Contract)

Định nghĩa cái human sở hữu và write rights hẹp của agent:

- `user_prompt/` — human ghi; agent chỉ đọc
- `decisions/` — human ghi các ratification chính thức
- `q-and-a/` — vòng đời pending/answered/stale (quy tắc auto-mv)
- `notifications/` — agent append urgent.md; human đọc

### `obsidian-vault/CLAUDE.md` (Vault Contract)

Định nghĩa:

- `raw/` — source material bất biến (agent CHỈ ĐỌC; không bao giờ ghi)
- `wiki/` — knowledge base agent-owned
- Các convention wikilink + frontmatter
- Schema (entity types, tag conventions)

---

## 4.2 — 17 File Constitution

Các file này sống tại `agent-workspace/constitution/`. Tất cả đều bị denied edit bởi agent qua [`.claude/settings.json`](#43--permissions). Modification yêu cầu một chu kỳ [proposal → cool-down → ratification](#46--quy-trinh-amendment).

| File | Status | Mục đích |
|---|---|---|
| [`karpathy-principles.md`](#karpathy-principles) | CHARTER | 4 nguyên tắc P áp dụng cho mọi session |
| [`architecture.md`](#architecture) | CHARTER | Layer boundaries, 9 quy tắc BC |
| [`invariants.md`](#invariants) | CHARTER | Invariants chung (I-1..I-54) |
| [`invariants-stockforge.md`](#invariants-stockforge) | CHARTER | Invariants stock-domain (I-S1..I-S65) |
| [`boundaries.md`](#boundaries) | CHARTER | Hard + soft boundaries (B-1..B-N, SB-1..SB-N) |
| [`vbw-protocol.md`](#vbw-protocol) | CHARTER | 4 checkpoint Verify-Before-Write |
| [`drift-signals.md`](#drift-signals) | CHARTER | DR1-DR12 + signal đặc thù stock DR-S |
| [`session-budgets.md`](#session-budgets) | CHARTER | Token budget per-session-type |
| [`autonomous-protocol.md`](#autonomous-protocol) | CHARTER | Quy tắc autonomous-mode (Rules 1-10) |
| [`coding-principles.md`](#coding-principles) | CHARTER | Quy tắc style + structure code-level |
| [`decision-discipline.md`](#decision-discipline) | CHARTER | Schema 12 trường ADR + threshold confidence |
| [`financial-data-protocol.md`](#financial-data-protocol) | CHARTER | 16 quy tắc tính toàn vẹn data stock-domain |
| [`harness-health-protocol.md`](#harness-health-protocol) | CHARTER | Catalog signal self-scan HH-1..HH-12 |
| [`memory-routing-tree.md`](#memory-routing-tree) | CHARTER | Để memory artifact nào ở đâu |
| [`memory-tiers.md`](#memory-tiers) | CHARTER | Tier 1 (always-load) ≤8K; Tier 2 JIT; Tier 3 explicit |
| [`severity-schema.md`](#severity-schema) | CHARTER | Phân loại CRITICAL / HIGH / MEDIUM / LOW |
| [`portability.md`](#portability) | PROPOSAL | Quy tắc cross-platform (Win/Mac/Linux) |

Sự phân chia 15 CHARTER + 1 SCHEMA + 1 PROPOSAL phản ánh việc `portability.md` đang chờ bundle ratification Cluster C. Các quy tắc chức năng trong `portability.md` được thực thi một phần bởi hook (`bash-hook-lint.sh`, `settings-inline-env-prefix-detector.sh`) nhưng chưa binding ở constitution tier.

---

### karpathy-principles

**Source**: forrestchang/andrej-karpathy-skills (MIT). Adopted tại Charter v1.0.

Bốn nguyên tắc. Áp dụng cho mọi session. Address các failure mode đặc thù của LLM.

| Principle | Ngăn ngừa | Cơ chế |
|---|---|---|
| **P1 Think Before Coding** | Silent picking, hidden confusion, missed tradeoffs | State assumptions tường minh; hỏi khi mơ hồ; dừng khi confused |
| **P2 Simplicity First** | Overengineering, speculative flexibility, defensive code cho impossible cases | Code tối thiểu giải quyết bài toán; không abstractions cho code single-use |
| **P3 Surgical Changes** | Drive-by refactoring, thay đổi formatting âm thầm, xóa pre-existing dead code | Mọi dòng thay đổi truy được về task; không "improve" code lân cận |
| **P4 Goal-Driven Execution** | Trạng thái "done" không rõ ràng, công việc không verify được | Transform imperative → verifiable: "add validation" trở thành "viết test cho invalid input, rồi làm chúng pass" |

**Giải quyết xung đột** (khi hai nguyên tắc bất đồng):
- P1 over P4 — nếu confused, dừng và hỏi
- P2 over P3 — nếu code hiện tại tệ VÀ task đáng kể, đơn giản hóa cẩn thận với approval
- P3 over P2 — đừng để "simplicity" biện minh cho việc viết lại code không liên quan
- P1 over P2 — đừng assume giải pháp đơn giản nếu task thực sự mơ hồ

Khi nghi ngờ: hỏi thay vì assume; viết ít hơn thay vì nhiều hơn; thay đổi ít hơn thay vì nhiều hơn; làm goals tường minh thay vì ngầm.

---

### architecture

Định nghĩa **9 bounded context** của StockForge stock domain:

- BC-1: Market Data (prices, volumes, OHLCV)
- BC-2: Fundamental (financial statements, ratios)
- BC-3: Company Intelligence (corporate actions, governance)
- BC-4: Macro (rates, FX, money flow)
- BC-5: News (mainstream financial news)
- BC-6: Influence (KOL channels, recommendations)
- BC-7: Crowd (sentiment, pump detection)
- BC-8: Analysis (thesis, signals, scoring)
- BC-9: Portfolio (positions, risk, P&L)

**Layer boundaries** (Clean Architecture):

- `packages/domain/<bc>/` — Python thuần, **không framework**, không Pydantic, không FastAPI. Dùng dataclasses.
- `packages/application/<bc>/` — use cases, ports (Protocol classes).
- `packages/infrastructure/<bc>/` — adapters (DB, LLM, scraper, HTTP).
- `packages/contracts/` — schemas + events chia sẻ cross-BC.

**BC isolation rule**: không bao giờ direct-import giữa các bounded context. Dùng layer `contracts/`.

**Domain purity rule** (enforced bởi [`drift-signals-D1-D9.sh`](06-hooks.md#drift-signals)): `packages/domain/**` không được `import fastapi`, `import pydantic`, `import sqlalchemy`, v.v.

---

### invariants + invariants-stockforge

Hai file. `invariants.md` chứa các invariant chung (I-1..I-54); `invariants-stockforge.md` chứa các invariant stock-domain (I-S1..I-S65).

**Các invariant stock quan trọng nhất** (được trích dẫn ở khắp nơi):

| ID | Quy tắc | Enforced bởi |
|---|---|---|
| **I-S1** | No LLM math. Mọi số từ deterministic code. | `post-tool-citation-grep.sh`, `taskcompleted-audit.sh` |
| **I-S1-1** | Numeric-field discipline (D-065 amendment) — required precision + units | Code review |
| **I-S2** | Mọi claim cite source + as-of date | `post-tool-citation-grep.sh` |
| **I-S7** | Confidence claims phải cite calibration data | `boundaries.md` B-12 |
| **I-S10** | Thesis phải bao gồm bear case (≥3 specific points) | `drift-signals-D1-D9.sh` D7 |
| **I-S35** | Frame như research aid; không bao giờ "buy/sell/recommendation" | `charter-coherence-spot.sh` |
| **I-S55..I-S65** | VN-specific (T+2.5 settlement, room ngoại, sàn-tier, FX VND-USD) | Code review |

---

### boundaries

Hai tier: **Hard** (không bao giờ vượt mà không có approval tường minh) và **Soft** (yêu cầu lý do tốt; tài liệu trong decision log).

**Hard Boundaries** (B-1..B-14):

| ID | Boundary |
|---|---|
| B-1 | Không bao giờ modify `PROJECT_CHARTER.md` |
| B-2 | Không bao giờ modify `agent-workspace/constitution/*` |
| B-3 | Không bao giờ ghi vào `obsidian-vault/raw/` |
| B-4 | Không bao giờ commit mà không có user request tường minh *(superseded 2026-05-15 bởi D-060: agents MAY commit; agents MUST NOT push)* |
| B-5 | Không bao giờ thực hiện các thao tác phá hoại mà không có approval cùng-session (DELETE FROM, DROP TABLE, rm -rf, force push, xóa branch) |
| B-6 | Không bao giờ deploy lên production mà không có approval |
| B-7 | Không bao giờ disable test hoặc lint để làm CI pass |
| B-8 | Không bao giờ install dependency mới mà không review |
| B-9 | Không bao giờ hardcode secrets, credentials, API keys |
| B-10 | Không bao giờ override các cơ chế an toàn (budget caps, rate limits, retry limits) |
| B-11 | Không bao giờ override position sizing hoặc risk rules |
| B-12 | Không bao giờ claim confidence mà không có calibration data |
| B-13 | Không bao giờ modify thesis-log entry trong quá khứ |
| B-14 | Không bao giờ modify `eval-sets/baseline-results/` |

**Soft Boundaries** (SB-1..SB-N): các quyết định kiến trúc vượt ra ngoài các pattern đã thiết lập, thay đổi API contract, thay đổi security-sensitive, thay đổi cross-BC contract, thay đổi business rule, migration schema phá hoại, thay đổi spec ảnh hưởng downstream, tích hợp data provider mới.

---

### vbw-protocol

Verify-Before-Write. Đo lường được: 11.1% hallucination rate → 0% sau khi adopt.

Bốn checkpoint, áp dụng luôn luôn, không thể skip:

| Checkpoint | Khi nào | Hành động |
|---|---|---|
| **PRE-SPEC** | Trước khi viết bất kỳ specification nào | Đọc source code thật; list methods thật; verify factory signatures; grep trước khi assume "missing"; mark CURRENT vs PROPOSED |
| **PRE-TEST** | Trước khi viết bất kỳ test nào | Verify mọi method call tồn tại từ type defs; verify factory signature; verify import paths; verify base class methods; test một file trước |
| **MID-IMPLEMENT (mỗi 5 step)** | Trong session | Cross-reference với spec; check plan state; review các assumption do convention dẫn xuất; đọc lại task description |
| **PRE-COMMIT** | Trước khi stage changes | Verify diff khớp plan; mypy/pytest/ruff pass; không có D1-D9 drift signal mới |

Protocol được vận hành trong mọi sandwich plan như **STEP 0 — VBW Live Verification**.

---

### drift-signals

Mười hai drift signal (DR1-DR12) cộng với đặc thù stock (DR-S1, DR-S2). Chạy qua command `/drift-check` + auto-fire trên Stop qua [`drift-signals-D1-D9.sh`](06-hooks.md#drift-signals).

**Tiered coverage map** (thêm 2026-05-05 qua D-029):

- **Tier-A — Automated detector** (Stop-hook, mỗi session-end): DR-A1..DR-A5, DR1, DR3, DR6, DR8, DR-S1, DR-S2, cộng DR2, DR5, DR10 từng phần.
- **Tier-B — Manual `/drift-check` command** (semantic, LLM-judgment): DR4 (hardcoded prompt ngoài `prompts/`), DR7 (UL term drift), DR12 (anti-pattern từ `agent-notes.md`).
- **Tier-C — DB-query check** (yêu cầu Postgres): DR9 (synthesis without verifier), DR11 (stale session-handoff).

**HIGH severity signals** (block commit/merge):

- DR1: Domain layer imports framework
- DR2: Evidence không có citation
- DR5: Claim được lưu mà không có metadata bắt buộc
- DR6: Type `Any` trong domain package
- DR-S1: LLM emit số mà không có tool call
- DR-S2: Thesis output không có bear case
- DR-A1: LOC ceiling vượt (>20%)

---

### session-budgets

Token budget per-session-type. Hai cột: Sonnet original + Opus recalibration (theo S345-S361 empirical sample n=10+).

| Session type | Sonnet budget | Opus budget | Mục đích |
|---|---|---|---|
| PLAN | 50-80K | 150-230K | Architect; produces session plan |
| FOCUSED_IMPL | 100-150K | 100-150K† | Dev; 1-3 task từ plan |
| MULTI_TASK_IMPL | 150-250K | 200-330K | Dev; 4-10 task |
| VERIFY | 30-60K | 80-180K | Verifier; adversarial review |
| RECOVERY | 80-150K | 130-230K | Revert + re-plan sau thất bại |
| THESIS | 60-100K | 100-180K | Multi-perspective stock analysis |
| INGEST | 40-80K | 80-150K | Data source → KB |
| POST-MORTEM | 30-50K | 60-100K | Outcome review + calibration update |

† Dev trên Opus cho thấy under-budget actuals (S349=98K, S354=34K, S357=45K) — công việc file-bounded chống lại token inflation.

**Hard caps** (theo D-004 Opus 4.7 recalibration):

- **Wind-down**: 180K (auto-prep handoff)
- **Cliff**: 220K (auto-reboot qua `session-self-reboot.sh`)
- **Hard cap**: 250K (mandatory split)

**Hard rule**: không bao giờ trộn PLAN và IMPL trong cùng session. (Session 4 failure mode catastrophic.)

**Hard rule**: THESIS sessions là read-only trên code. Output đi vào `agent-workspace/memory/thesis-log/`.

---

### autonomous-protocol

Mười quy tắc governing hoạt động autonomous mode:

1. `autonomous_mode = true` là mode DUY NHẤT (không có SUPERVISED bifurcation)
2. Coverage Mode A/B/C/D (Stop-hook handoff modes)
3. Context auto-loader: hybrid deterministic + LLM-selector
4. Bootstrap token ceiling per session type (≤6K-≤20K)
5. Skill-tool trong autonomous mode: gate; thay bằng inline/subagent
6. Drift self-detection: defense-in-depth (per-task + Stop-hook + fresh-context auditor)
7. Drift recovery flow: Q&A bundle async
8. AskUserQuestion chỉ dành cho các quyết định SCOPE/CHARTER thực sự mới
9. Mode-D clean-handoff coverage (checkpoint mtime ≤60s, không A/B/C)
10. Autonomous-mode defection bị cấm (Mode-E habit-pattern hardening; 4-layer defense)

### coding-principles

Style + structure code-level. Chủ đề: SOLID adherence trong Python, Protocol-based DI trong `domain/`, quy tắc async/await, convention error handling, kỷ luật logging, no-bare-except, type hints required, mypy --strict baseline.

### decision-discipline

ADR (Architecture Decision Record) discipline. Chi tiết tại [§ 4.5](#45--cac-nguyen-tac-karpathy-truc-quan).

### financial-data-protocol

16 quy tắc đặc thù cho tính toàn vẹn financial data. Điểm nhấn:

- **Rule 1**: Tất cả price data phải timezone-aware (Vietnam = ICT/Bangkok = UTC+7)
- **Rule 4**: Tất cả fundamental data phải mang `as_of` date khớp report period
- **Rule 12**: VN trade settle T+2.5 — exposure calc phải tôn trọng settlement window
- **Rule 13**: Room ngoại (foreign-owned-room) data phải lấy từ feed chính thức HOSE/HNX
- **Rule 14**: Sàn tier (HOSE/HNX/UPCoM) phải drive các giả định liquidity khác nhau
- **Rule 15**: FX VND-USD phải dùng SBV official rate, không phải market rate
- **Rule 16** (D-065 amendment): Numeric fields phải khai báo precision + units trong glossary; không có implicit conversions

### harness-health-protocol

Catalog 12-signal HH-1..HH-12. Chi tiết tại [Chương 9 § Harness Health](09-he-thong-chat-luong.md#harness-health).

### memory-routing-tree

Để memory artifact nào ở đâu. Decision tree mà agent dùng để route một mảnh state. Branch trên loại artifact (rule learned / decision / observation / thesis / v.v.) → destination directory.

### memory-tiers

Mô hình memory ba-tier:

- **Tier 1** — Always-loaded. Hard cap **≤8K token**. Enforced bởi `tier1-bloat-check.sh`.
- **Tier 2** — Just-in-time (đọc khi signal liên quan fire).
- **Tier 3** — Explicit-pull (đọc chỉ khi tường minh yêu cầu).

`CLAUDE.md` + `agent-workspace/CLAUDE.md` + `human-workspace/CLAUDE.md` + `MEMORY.md` + `project.md` + `current-execution.md` phải tổng ≤8K combined.

### severity-schema

Bốn severity level (D-058 ratification, S310):

| Level | Ví dụ | Hành động |
|---|---|---|
| **CRITICAL** | Stale-checkpoint marker, Q&A age ≥96h, charter-violation marker, ghost-greening marker | Ghi flag `.autonomous-BLOCKED`; URGENT entry; Telegram push |
| **HIGH** | Q&A age ≥6h pending, charter-tier ADR PROPOSED age ≥24h, mistake-log severity=high, notification ALERT-URGENT | URGENT entry; UserPromptSubmit context yêu cầu AskUserQuestion; Telegram push |
| **MEDIUM** | ARCH/SCOPE PROPOSED age ≥12h, notification WARN | Weekly digest |
| **LOW** | Dưới threshold | Chỉ log |

### portability (PROPOSAL — đang chờ Cluster C bundle)

Quy tắc cross-platform. Hiện được enforced một phần qua hook. Chủ đề: bash POSIX-only (không jq/yq/python3 ngoại trừ trong fallbacks), Windows path conversions, line endings (chỉ LF qua .gitattributes), env-prefix gotchas (dùng `env VAR=val cmd` không phải `VAR=val cmd`).

---

## 4.3 — Permissions (`.claude/settings.json`)

Layer enforcement của harness cho các file nào agent có thể read/write/edit, các bash command nào được allowed/denied, và các hook nào fire trên event nào.

### Permission Model

```json
{
  "permissions": {
    "defaultMode": "bypassPermissions",
    "allow": [
      "Bash(ls:*)", "Bash(git status:*)", "Bash(git commit:*)",
      "Bash(python -m pytest:*)", "Bash(mypy:*)", "Bash(ruff:*)",
      "Read(*)",
      "Write(apps/**)", "Write(packages/**)", "Write(specs/**)",
      "Write(agent-workspace/memory/sessions/**)",
      "Write(agent-workspace/memory/decisions/**)",
      "Edit(apps/**)", "Edit(packages/**)",
      "Edit(.claude/agents/**)", "Edit(.claude/skills/**)",
      "Edit(.claude/settings.json)",
      ...
    ],
    "deny": [
      "Write(PROJECT_CHARTER.md)",
      "Write(agent-workspace/constitution/**)",
      "Write(obsidian-vault/raw/**)",
      "Write(eval-sets/baseline-results/**)",
      "Write(human-workspace/user_prompt/**)",
      "Write(human-workspace/decisions/**)",
      "Edit(PROJECT_CHARTER.md)",
      "Edit(AGENT_OPERATING_MANUAL.md)",
      "Edit(agent-workspace/constitution/**)",
      "Bash(git push:*)",
      "Bash(rm -rf:*)",
      "Bash(DROP:*)",
      "Bash(DELETE FROM:*)",
      ...
    ]
  }
}
```

### Quy Tắc Deny Chính

| Pattern | Lý do |
|---|---|
| `Write(PROJECT_CHARTER.md)` | B-1 enforcement |
| `Edit(PROJECT_CHARTER.md)` | B-1 enforcement (Edit cũng bị denied) |
| `Edit(agent-workspace/constitution/**)` | B-2 enforcement |
| `Write(obsidian-vault/raw/**)` | B-3 enforcement |
| `Write(eval-sets/baseline-results/**)` | B-14 enforcement |
| `Write(human-workspace/user_prompt/**)` | Workspace dualism |
| `Write(human-workspace/decisions/**)` | Workspace dualism |
| `Write/Edit(human-workspace/q-and-a/{answered,stale}/**)` | Auto-mv hook là writer duy nhất |
| `Bash(git push:*)` | Agents commit; humans push |
| `Bash(rm -rf:*)` | Mass-deletion defense (R1 of 3) |
| `Bash(DROP:*)` | SQL destructive guard |
| `Bash(DELETE FROM:*)` | SQL destructive guard |

### Environment Variables

```json
"env": {
  "PYTHON_ENV": "development",
  "STOCKFORGE_HOOK_PROFILE": "standard",
  "STOCKFORGE_SPAWNED": "false",
  "STOCKFORGE_WIND_DOWN_TOKENS": "180000",
  "STOCKFORGE_CLIFF_TOKENS": "220000",
  "STOCKFORGE_LOC_STRICT": "0",
  "STOCKFORGE_CITATION_STRICT": "0",
  "STOCKFORGE_DRIFT_STRICT": "0",
  "STOCKFORGE_SAME_COMMIT_STRICT": "0",
  "STOCKFORGE_WATCHDOG_DISABLE": "0",
  "STOCKFORGE_LINT_DOCTRINE_PHASE_0_PORTABILITY": "0"
}
```

Các biến này được đọc bởi hook. Hầu hết là toggle 0/1 strictness cho hành vi warn-vs-block.

### Hooks Wiring

`settings.json` khai báo các hook script nào fire trên event Claude Code nào. Chi tiết tại [Chương 6 § Wiring](06-hooks.md#wiring).

---

## 4.4 — Decision Discipline (ADRs)

ADRs (Architecture Decision Records) sống tại `agent-workspace/memory/decisions/NNN-<slug>.md`. Đánh số tuần tự, không bao giờ dùng lại.

### Schema 12+ Trường

```yaml
---
id: D-NNN
title: <short title>
date: YYYY-MM-DD
status: PROPOSED | ACCEPTED | SHIPPED | SUPERSEDED-BY-D-NNN | REJECTED
level: CHARTER | SCOPE | ARCH | IMPL
author: <agent | human>
source_evidence:
  - <file:line citations>
intent_classification: <one of: CHARTER_AMEND | SCOPE_CHANGE | ARCH_DECISION | IMPL_PICK>
options_considered:
  - id: A
    description: <description>
    pros: [...]
    cons: [...]
  - id: B
    description: ...
chosen: A | B | C | ...
chosen_rationale: <why>
approval_chain: <list of confidence sources>
verified_by: <empirical test / smoke / firing-test / human ratification>
affects: [<files / BCs / artifacts>]
depends_on: [D-NNN, D-MMM]
supersedes: [D-NNN]  # optional
superseded_by: [D-NNN]  # optional, when retired
defer_cycles: 0  # count of times this was deferred
re_attempt_prereq: <if rejected, what unlocks reattempt>
tags: [<keywords>]
---
```

### Threshold Confidence (Self-Decide vs Q&A)

Theo `decision-discipline.md`:

| Level | Confidence threshold | Decision path |
|---|---|---|
| CHARTER | 0.99 | Luôn Q&A bundle + human ratify |
| SCOPE | 0.90 | Q&A bundle nếu <0.90 |
| ARCH | 0.80 | Self-decide nếu ≥0.80 |
| IMPL | 0.50 | Self-decide nếu ≥0.50 |

Confidence đến từ `sync-tracker/state.tsv` (per-category Confidence Score). Dưới threshold → trigger `/grill-me` để build Q&A bundle.

### Defer-Cycle Drift Alert

Nếu `defer_cycles > 3`, R7 mitigation trigger: surface như MEDIUM severity trong escalation pipeline.

---

## 4.5 — Các Nguyên Tắc Karpathy, Trực Quan Hóa

P1, P2, P3, P4 từ `karpathy-principles.md` map lên các hành vi agent quan sát được. Đây là *flowchart của agent* cho bất kỳ task không tầm thường nào:

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  User: "Add X feature"                                      │
│              │                                              │
│              ▼                                              │
│       ┌────────────────────────┐                            │
│       │   P1: Is it ambiguous? │                            │
│       └─────────┬──────────────┘                            │
│            yes  │  no                                       │
│       ┌─────────┴─────────┐                                 │
│       │                   │                                 │
│       ▼                   ▼                                 │
│   ┌────────┐         ┌───────────────────────────┐          │
│   │ ASK    │         │ P4: Frame as verifiable   │          │
│   │ user   │         │ success criteria          │          │
│   │ (mega- │         └──────────┬────────────────┘          │
│   │ bundle)│                    │                           │
│   └────────┘                    ▼                           │
│       │             ┌───────────────────────┐               │
│       │             │ P2: Minimum solution? │               │
│       │             └──────┬────────────────┘               │
│       │                    │                                │
│       │                    ▼                                │
│       │            ┌───────────────────────┐                │
│       │            │ P3: Surgical changes  │                │
│       │            │ only?                 │                │
│       │            └──────┬────────────────┘                │
│       │                   │                                 │
│       │                   ▼                                 │
│       │            ┌───────────────────────┐                │
│       │            │ Execute → verify →    │                │
│       │            │ report                │                │
│       │            └───────────────────────┘                │
│       │                                                     │
│       ▼                                                     │
│   (user answers)                                            │
│       │                                                     │
│       └──── go to P4 with answers                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

Flowchart này là biểu hiện vận hành của `karpathy-principles.md`.

---

## 4.6 — Quy Trình Amendment

Constitution thay đổi qua protocol này:

```
1. PROPOSAL
   Agent identifies a gap or improvement.
   Writes proposal to agent-workspace/proposals/<slug>.md.
   Proposal cites: source evidence, options considered, chosen pick, rationale.
   Status: PROPOSED.

2. COOL-DOWN
   48 hours minimum before any ratification.
   Allows the proposal to be re-read with fresh context.
   `proposal-bundle-advisor.sh` SessionStart hook surfaces ready-to-ratify proposals.

3. RATIFICATION
   User issues explicit approval via AskUserQuestion bundle.
   Agent records ratification in:
     - The proposal's status field (PROPOSED → ACCEPTED)
     - A new ADR in agent-workspace/memory/decisions/NNN-*.md
     - The relevant CHANGELOG row in the proposal

4. MV-TO-CONSTITUTION
   Once ACCEPTED, agent issues a one-time deny-lift:
     - Either: bundle the mv with an existing approved Edit operation
     - Or: temporary deny-lift via .claude/settings.json (then restored)
   The file moves from proposals/ to constitution/.

5. CROSS-REFERENCE UPDATE
   All callers of the old proposal-path are updated to reference the new
   constitution-path. Searches: grep -r "proposals/<slug>" entire repo.
```

Charter revisions đặc biệt (không phải các file constitution) theo `PROJECT_CHARTER.md § Revision Protocol`:

- Rationale được viết với evidence (linked đến session / post-mortem cụ thể)
- Cool-down 48 giờ trước khi commit thay đổi
- Version bump tường minh (v1.0 → v2.0)

---

## 4.7 — Đọc Tiếp Ở Đâu

Nếu bạn muốn:

- **Xem engine hook layered** thực thi các quy tắc constitution → [Chương 6 — Hooks](06-hooks.md)
- **Hiểu các session ratify các quyết định như thế nào** → [Chương 8 — Vòng Đời](08-vong-doi.md)
- **Chạy drift check** bắt các vi phạm constitution → [Chương 9 — Hệ Thống Chất Lượng](09-he-thong-chat-luong.md)
- **Đề xuất một quy tắc constitution mới** → [Chương 14 — Đóng Góp](14-dong-gop.md#proposing-a-rule)
- **Xem danh sách ADR đầy đủ** → [Reference § ADRs](../reference/inventory-decisions.md)
