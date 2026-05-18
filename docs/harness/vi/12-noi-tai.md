# Chương 12 — Nội Tại (Internals)

> **Phân khu Diataxis**: Explanation (cái *why* đằng sau cái *what*)
> **Thời gian đọc**: ~30 phút
> **Điều kiện tiên quyết**: Chương 6-10

Chương này cover internals — các quyết định thiết kế, tại sao hệ thống có hình dạng như vậy, 23 anti-pattern được đặt tên, những gì đã thử và bị bỏ. Đọc chương này là optional cho việc *sử dụng* harness; bắt buộc cho việc *đóng góp* cho nó.

---

## 12.1 — Tại Sao Nhiều Hook Đến Vậy?

Phản ứng đầu tiên phổ biến: 118 hook script có vẻ thái quá.

Câu trả lời là empirical. Mỗi hook trace tới một failure mode cụ thể đã bị bắt (hoặc lẽ ra phải bị bắt). Harness không bắt đầu với 118 hook — nó tích lũy chúng qua ~400 session dogfood.

Sự tiến triển:

| Period | Số lượng hook xấp xỉ | Tại sao hook được thêm |
|---|---|---|
| Phase 0 (session 1-22) | ~20 | Bootstrap, session lifecycle, governance cơ bản |
| Phase 1 (session 23-30) | ~30 | Product đầu tiên, drift detection cơ bản |
| Phase 2 (session 31-43) | ~50 | Multi-tier quality gates xuất hiện |
| Phase 2.5 (session 44-49) | ~70 | Harness hardening; 8 HH-* track |
| Phase 3 (session 44-65) | ~80 | Memory tier discipline; retention |
| Phase 3.5 (session 50-250) | ~100 | Empirical-firing discipline; HH-1..HH-12 |
| Phase 4 (session 251-400+) | ~118 | Severity pipeline; mass-deletion defense; calibration |

Mỗi Phase lớn introduce failure mode mới đòi hỏi mechanical enforcement mới. Pattern: **một rule learned trong `agent-notes.md` trở thành hook chỉ sau instance thứ hai**, theo [doctrine AP-23](#ap-23).

Nếu chúng ta xóa hook ngẫu nhiên, hệ thống sẽ không trở nên đơn giản hơn — nó sẽ trở nên nguy hiểm hơn. Harness ở Pareto front: mỗi hook xứng đáng được giữ.

Tuy vậy, một số hook là demotion candidate. Theo [Chương 10 § 10.7 Ritual Demotion](10-tu-cai-thien.md#107--ritual-demotion-s99-rca-layer-5), hook với catch-rate 0 qua 3+ session liên tiếp được đánh giá để demote-to-passive hoặc retire. Đây là active discipline, không phải frozen state.

---

## 12.2 — 23 Anti-Pattern (AP-1..AP-23)

Anti-pattern là các failure mode được đặt tên mà harness ngăn chặn cụ thể. Chúng được document trong `agent-workspace/memory/patterns-discovered/SYNTHESIS.md` và được cite xuyên suốt cuốn sách này.

### Anti-Pattern Tần Suất Cao

| ID | Tên | Là gì | Prevention |
|---|---|---|---|
| **AP-1** | Same-agent self-review | Architect/dev/verifier là một single agent | Fresh-context sandwich pattern |
| **AP-2** | Self-track wind-down | LLM cite token; `.transcript-tokens` mới là authoritative | Guard Mode-C của `budget-watchdog.sh` |
| **AP-3** | Speculative abstraction | Factor out Protocol cho code single-use | Karpathy P2; retire reflexively |
| **AP-5** | Charter-coherence defer overriding user-CRITICAL | Âm thầm defer các item user-CRITICAL | Re-read `user_prompt/*` tại mỗi phase entry |
| **AP-6** | LLM math output | LLM generate số mà nó tính | DR-S1 + `taskcompleted-audit.sh` |
| **AP-7** | Performative SC ticking | Vacuous "approve" attestations | Defer with explicit prereqs > vacuous approve |
| **AP-8** | Pre-staged work causing checkpoint drift | Update file lúc session-end, không phải lúc task complete | Update on task complete |
| **AP-9** | Single-perspective thesis | Thesis không có bear case | I-S10 + DR-S2 + `taskcompleted-audit.sh` |
| **AP-10** | Confidence without calibration | "High confidence" không có hit-rate evidence | B-12 + DR-A4 |
| **AP-11** | Confirmation bias in stock picks | Recommend stock user đã sở hữu | Portfolio check trước recommendation |
| **AP-12** | Overfit to recent backtest | Performance 2021-2022 ≠ prediction 2024 | Cross-period validation required |
| **AP-13** | Greedy auto-load | Loading 50K+ file tại SessionStart | Hybrid auto-load + LLM-selector (theo Rule 3) |
| **AP-14** | Hardcoded phase paths in skills | Skill cite `phase-3` literal | Resolve qua `current-execution.md` |
| **AP-15** | Duplicated skill body in command | Skill `<name>` + command `/<name>` đều chứa procedure | L-S14-2; chọn một canonical |
| **AP-16** | Inline accumulation past 2nd instance | Không promote rule ở lần xuất hiện thứ 2 | AP-23 RED FLAG; promote-or-retire |
| **AP-17** | Identity drift | Treat stockforge như generic framework | Reference `identity-scope.md` |
| **AP-18** | Stop-hook-Windows quirk hides everything | Stop không bao giờ fire; tất cả 50 Stop-chain hook silent | T2 migration sang UserPromptSubmit; HH-1 KI-S49b-1 |
| **AP-19** | Hook ships without firing-test | Track close declare GREEN; hook không verified | HH-10 + Charter Principle 11 |
| **AP-20** | Auto-detect tag without companion hook | 20 rule `Auto-detect: yes`; 0 hook shipped | HH-4 orphan check |
| **AP-21** | Mixed PLAN + IMPL session | Session 4 catastrophic failure | Hard rule; sandwich pattern enforce |
| **AP-22** | Q&A bundle silent past 24h | "Wait for user-readiness" busy-loop | UP-06 NO-Silent-Default + `qa-stale-urgent-escalator.sh` |
| **AP-23** | Continuous LLM-Guardian / inline accumulation past 2nd instance | LLM check tại mỗi step thay vì deterministic hook | Deterministic hook = Guardian; LLM Guardian chỉ tại session-end aggregation |

### Anti-Pattern Tần Suất Thấp Hơn

(AP-4 đã được reserve; document như duplicate của AP-3 và bị drop.)

### Pattern AP-23 (Được Cite Nhiều Nhất)

AP-23 xứng đáng có subsection riêng vì nó được reference nhiều hơn bất kỳ anti-pattern nào khác. Nó nói:

> "Nếu một rule đã được observe N+1 lần (với N ≥ 2), và chúng ta sắp thêm một entry refinement-of-rule thay vì promote sang deterministic hook, đó là AP-23. Rule đã graduate khỏi inline accumulation. Hoặc promote (sang hook / skill / constitution) hoặc retire (nếu duplicate của artifact đã có)."

Threshold instance thứ 2 là bright line. Dưới nó, rule có thể nằm inline (có thể one-off). Tại hoặc trên đó, accumulation past inline là anti-pattern.

**Cluster exception**: khi 3+ rule chia sẻ một class (cùng root cause, cùng prevention), promote toàn bộ cluster như một artifact duy nhất ngay cả khi individual instances là 1st-instance.

---

## 12.3 — Tại Sao Sandwich (Không Phải Single-Agent-With-Discipline)

Một counter-proposal hợp lý: "Tại sao không một single agent tự discipline để plan trước, implement sau, verify thứ ba?"

**Câu trả lời empirical**: nó không work past ~200K token. Session 4 đo trực tiếp điều này:

- Single agent attempt PLAN + IMPL + VERIFY trong một session
- Vượt 200K token
- Plan drift khỏi implementation (LLM bắt đầu "improve" plan giữa chừng)
- Implementation drift khỏi spec (LLM quên edge case nêu ở turn sớm hơn)
- Verifier (cùng agent, cùng context) sign off trên broken work

Failure rate tại scale đó ~20%. Không phải "occasional bugs" — *catastrophic* loss đòi hỏi full rollback.

**Câu trả lời mechanistic**: context window không phải bottleneck. *Attention* mới là. LLM attend không cân đối với recent context. Past 200K, early-context details (spec, plan) bị out-attended bởi recent-context details (implementation đang tiến hành). Cái này không được giải bằng context window dài hơn; nó được giải bằng *bounding* context vào work mà session đó own.

**Câu trả lời cấu trúc của sandwich pattern**:

- Context của architect: spec + constitution + các plan past tương tự. Plan được viết.
- Context của dev: plan + code-to-touch. Implementation được viết.
- Context của verifier: plan + implementation diff. Verdict được viết.

Attention của mỗi agent tập trung vào scope riêng. **Không agent nào phải attend đồng thời cả plan và implementation**. Drift mode trở nên impossible về mặt cấu trúc.

### Tại Sao Fresh Context Cụ Thể

Liệu một agent có thể chạy tuần tự (plan, rồi implement, rồi verify) với `/clear` giữa các phase không?

Hai vấn đề:
1. **Persona conflict**: mindset architect ≠ mindset dev ≠ mindset verifier. Đọc persona file tại mỗi phase entry là wasteful; tốt hơn là có ba persona file riêng biệt.
2. **Echo chamber**: ngay cả với `/clear`, một single agent vừa *recently* viết plan mang theo stylistic và assumption-level priors vào verification. Một fresh-context verifier không có những priors đó.

Fresh-context verifier là *adversarial* layer. AP-1 cấm same-agent self-review.

---

## 12.4 — Tại Sao Severity Pipeline (Không Chỉ `urgent.md`)

Trước D-058 / S310, harness có file `notifications/urgent.md` tích lũy WARN. Vấn đề: không ai đọc nó. Item chất đống; user không thấy chúng.

Severity pipeline giải quyết bằng cách:

1. **Classify** item thành 4 tier (CRITICAL / HIGH / MEDIUM / LOW) để attention proportional.
2. **Escalate** theo tier:
   - CRITICAL → block autonomous + Telegram push
   - HIGH → demand AskUserQuestion + Telegram push
   - MEDIUM → weekly digest
   - LOW → log only
3. **Enforce** block qua PreToolUse hook (tool call bị deny khi flag set).
4. **Push** externally (Telegram) để user thấy CRITICAL/HIGH ngoài terminal.

Thiết kế cascading đảm bảo các item *quan trọng nhất* nhận được surface *aggressive nhất*, và các item *trivial* không spam.

### Tại Sao Multi-Cadence Phase B

`escalation-engine.sh` fire trên Stop + SessionStart + UserPromptSubmit. Ba window khác nhau. Đây là intentional:

- **Stop**: cuối mỗi turn — re-check thường xuyên.
- **SessionStart**: new session entry — đảm bảo user thấy state khi resume.
- **UserPromptSubmit**: mỗi prompt — cho LLM context để respond appropriately.

Single-cadence (Stop only) là design gốc. Root cause của S310 là single-cadence cho phép Q-INT mega-bundle ngồi silent 20 giờ: Stop fire nhưng user không quay lại trong 20 giờ. SessionStart re-fire đảm bảo resumption surface state.

---

## 12.5 — Tại Sao Hai Workspace (`agent-workspace/` + `human-workspace/`)

Workspace dualism sinh ra từ **post-mortem orch CF-DOGFOOD-2** (orch là sister project tại `C:\htdocs\orch-starter`).

### Điều Đã Xảy Ra Trong Orch

Orch có một shared workspace duy nhất. Agent có thể write bất cứ đâu. Theo thời gian:

- Agent âm thầm thay đổi charter rules để fit với understanding hiện tại
- Intent của human (`user_prompt`) và interpretation của agent drift
- Decisions được ratify bởi agent inline trở nên không phân biệt được với decision ratify bởi human
- Audit trail của who-said-what trở nên impossible

Failure mode được đặt tên **CF-DOGFOOD-2**: charter drift qua shared-workspace mutation.

### Câu Trả Lời Dualism

Split workspace:

- **Domain của agent**: `agent-workspace/`. Agent write freely; human đọc nhưng hiếm khi edit.
- **Domain của human**: `human-workspace/`. Human write; agent có narrow write right vào specific channel.

Split được enforce bởi deny rules trong `.claude/settings.json`. Direct write vào `human-workspace/user_prompt/` bị deny; agent không thể âm thầm modify intent gốc của human.

### Communication Channels

Cross-boundary communication xảy ra qua named channels (theo [Chương 8 § 8.6](08-vong-doi.md#86--workspace-dualism)):

- Human → Agent: `user_prompt/`, `decisions/` (agent chỉ đọc)
- Agent → Human: `q-and-a/pending/`, `notifications/urgent.md` (agent write)
- Auto-mv: pending → answered qua hook (`qa-pending-auto-mover.sh`) với điều kiện tường minh

Rule auto-mv (4 điều kiện; HH-E.2 / D-031) là subtle nhất. Nó cho phép agent MOVE Q&A bundle sang `answered/` mà không phá vỡ rule human-only-writes-to-answered, vì move được thực hiện bởi một validated hook với deterministic conditions, không phải bởi agent trực tiếp.

---

## 12.6 — Tại Sao Constitution File Là Immutable Với Agent

Counter-proposal hợp lý: "Tại sao không cho agent edit constitution file? Job của agent là learn và adapt."

**Trả lời**: agent learning xảy ra trong `agent-notes.md`. *Promotion* của một learned rule lên constitution đòi hỏi một step explicit human-ratified.

Không có gate này:

- Agent có thể âm thầm rewrite Charter Principle 8 ("Calibration over confidence") thành "Calibration when convenient"
- Agent có thể âm thầm extend `boundaries.md` để relax B-11 (position sizing override)
- Agent có thể âm thầm delete một invariant dưới áp lực ship

**Constitution là *contract*** giữa human và hệ thống. Contract không phải đơn phương modifiable.

Quy trình amendment (proposal → cool-down 48h → ratification → mv) cố ý chậm. Slowness là feature, không phải bug.

---

## 12.7 — Tại Sao Hook Dùng Bash (Không Phải Python / TypeScript)

Một số hook shell out sang Python (`python3` là fallback cho math `date -d`). Tại sao không Python primary?

**Trả lời**: portability + speed + dependency simplicity.

- **Portability**: bash + POSIX coreutils tồn tại trên mọi dev machine + CI runner. Python availability vary (đặc biệt `python3` vs `python`).
- **Speed**: hook execution nằm trong hot path của mọi event. Python startup (~50-200ms) compound qua 118 hook. Bash là ~5-20ms.
- **Dependency simplicity**: bash zero install. Python đòi hỏi version pinning + virtualenv discipline.

**Exception**: `recover-agent-notes.py`, `sync-tracker-bootstrap.py`. Đây là one-shot CLI utilities, không phải hot-path hook. Python phù hợp.

**Ràng buộc**: theo L-S11-1 (Phase 0 portability), hook script không được depend vào `jq`, `yq`, hay Python (trừ như fallback). Tất cả structured-data parsing trong hook dùng `awk`, `grep`, `sed`. Cái này cap complexity nhưng đảm bảo portability.

### Vết Sẹo Portability Windows

Ràng buộc bash-only cộng với Windows compatibility tạo ra surface area substantial được document trong [Chương 6 § 6.10](06-hooks.md#610--windows-portability-scars). Ví dụ:

- `$PPID == 1` trong spawned hook context (dùng `tasklist //V` không phải `ps`)
- `VAR=val bash ...` fail âm thầm (phải dùng `env VAR=val bash ...`)
- PowerShell `Start-Process` truncate SessionStart chain (move spawning hook sang vị trí cuối)
- KI-S49b-1 Stop-not-firing quirk (HH-1 KI suppression)

Nếu chúng ta Linux-only, harness sẽ nhỏ hơn ~20%.

---

## 12.8 — Tại Sao 12-Field ADR Schema (Không Phải 4)

Minimal ADR pattern (theo bài viết gốc 2011 của Michael Nygard) có 4 field: Title, Status, Context, Decision. Tại sao harness require 12+?

**Trả lời**: 4-field schema dành cho *recording* decision. Harness cần *operate* trên decision. Cái đó đòi hỏi nhiều structure hơn.

Field mà harness consume:

- `id` — cho cross-reference và stable URL
- `level` (CHARTER / SCOPE / ARCH / IMPL) — cho tier-appropriate confidence threshold
- `source_evidence` — cho audit trail
- `intent_classification` — cho routing
- `options_considered` — cho retrospective ("tại sao không B?")
- `chosen` + `chosen_rationale` — cho understanding
- `approval_chain` — cho ratification provenance
- `verified_by` — cho closure proof (Principle 11)
- `affects` — cho impact tracking
- `depends_on` — cho ordering
- `supersedes` / `superseded_by` — cho revision graph
- `defer_cycles` — cho R7 drift alert
- `re_attempt_prereq` — cho resurrection logic
- `tags` — cho grep

Bỏ bất kỳ field nào sẽ cripple một hook hoặc skill cụ thể. Schema dense vì nó phục vụ nhiều consumer.

---

## 12.9 — Cái Gì Đã Thử Và Bỏ

Không phải mọi harness experiment đều ship. Một số ví dụ đã retire:

### Mode-E Self-Pause

**Là gì**: agent tự pause trong autonomous mode khi cảm thấy "unsure".

**Tại sao fail**: unsure-detection của agent không reliable (correlate với rare phrasing hơn là uncertainty thật). Tạo habit pattern pausing phá hủy reliability của autonomous-loop.

**Retired**: 2026-05-04 (S43) qua Tier-3 charter promotion. Rule 10 của `autonomous-protocol.md` codify "Autonomous-Mode Defection Forbidden" 4-layer defense.

### Mode-D SendKeys "continue" Mechanism

**Là gì**: PowerShell SendKeys để inject "continue" vào session tiếp sau `/clear`.

**Tại sao fail**: brittle trên Windows, race với hook execution, đôi khi miss.

**Retired**: 2026-05-XX. Thay thế bởi 3-hook checkpoint marker mechanism ([Chương 8 § 8.8](08-vong-doi.md#88--continuity-across-clear-and-auto-reboot)).

### Greedy Auto-Loader (50K+ File Tại SessionStart)

**Là gì**: SessionStart hook attempt pre-load tất cả file relevant có thể nghĩ ra.

**Tại sao fail**: blow bootstrap ceiling; degrade mọi session.

**Retired**: Rule 4 của `autonomous-protocol.md` codify per-session-type ceiling (≤6K-≤20K). Auto-loader thay bằng hybrid (deterministic + LLM-selector).

### `ccs:continue` Và Các Command Level CCS Khác

**Là gì**: command sống tại CCS (Claude Code Subagent) plugin level, không phải project level.

**Tại sao không được adopt**: chúng conflict với command riêng của project và property visibility-into-state.

**Status**: không phải part của harness; ignored.

### Single-Cadence Severity (Stop Only)

**Là gì**: design D-058 gốc fire `escalation-engine.sh` chỉ trên Stop.

**Tại sao fail**: không surface state khi session resume; 20-hour Q-INT silent period là root cause của L-S310-1 demotion.

**Retired**: superseded bởi multi-cadence design (Stop + SessionStart + UserPromptSubmit).

---

## 12.10 — So Sánh Với Các Pattern Khác

Harness này so với các AI-coding pattern khác trong field thế nào?

### vs Cursor / Aider / etc.

Các tool đó optimize trải nghiệm *editor* — chúng assume human in the loop review mỗi change. Harness optimize cho operation **autonomous**: human review tại session/phase boundary, không phải tại mỗi line.

### vs Agent Framework (AutoGPT, AgentGPT, etc.)

Các framework đó nhấn mạnh **agent autonomy** với weak external structure. Harness nhấn mạnh **agent autonomy within strong external structure**. 17 constitution file + 118 hook là "external structure" — chúng constrain freedom của agent để giảm variance.

### vs Sandwich-Free LangChain / LangGraph

LangGraph support multi-agent workflow tương tự sandwich. Harness thêm:
- **Persona file** (`.claude/agents/<name>.md`) như canonical worker definition
- **Fresh-context guarantee** qua Agent tool dispatch
- **Verifier no-Write** enforcement (PCG-S401-4)
- **Coordination rule** qua `current-execution.md`

### vs Test-Driven Development (TDD)

TDD là một discipline; harness là một hệ thống *enforce* discipline. Mối quan hệ:

- TDD nói "write test first". `pre-commit-pytest-regression-guard.sh` của harness enforce "test pass trước commit".
- TDD nói "red, green, refactor". Sandwich pattern của harness (architect plan, dev implement, verifier refactor qua Tier-2 review) là multi-session analog.

### vs SRE / DevOps Discipline

Harness mượn nhiều từ SRE pattern:

- **Severity tier** (CRITICAL / HIGH / MEDIUM / LOW) ← SRE incident severity
- **Defense-in-depth** (3-prong mass-deletion defense) ← SRE redundant safety nets
- **Postmortems** ← SRE blameless postmortems
- **Calibration** (sync-tracker confidence score) ← SRE error budget

---

## 12.11 — Failure Mode Mà Harness Không Bắt Được

Honesty matters here. Harness bắt được rất nhiều. Nó không bắt:

### LLM Reasoning Failures Trong Một Tool Call Duy Nhất

Nếu LLM viết một function compile và pass test nhưng implement sai algorithm, harness thấy một green commit. Defense: sandwich-verifier review diff cho logical correctness; không hoàn hảo.

### Long-Horizon Strategic Drift

Nếu *direction* của project sai (ví dụ: build VN stock tool khi market structure thay đổi), không hook nào bắt nó. Defense: PROJECT_CHARTER.md set direction; AskUserQuestion CHARTER-tier ratification khi scope shift.

### Adversarial External Changes

Nếu library `vnstock` đổi API âm thầm, code break tại runtime. Defense: `vendor-api-probe.sh` check API reachability; không full API contract testing.

### Human Mistakes Mà Agent Không Reach Được

Nếu human commit `agent-workspace/constitution/karpathy-principles.md` với error, agent đọc error. Defense: charter revision protocol đòi hỏi explicit version bump + rationale.

### Cost Surprise

Nếu một sandwich-architect trên Opus consume 300K token unexpectedly, `cost-ledger.tsv` record cost nhưng không prevent. Defense: `budget-watchdog.sh` warn tại 180K wind-down + 220K cliff; subagent budget classifier flag envelope Architect/Verifier.

### Cascading Test Removal

Nếu một test bị delete (không chỉ disable), `pre-commit-pytest-regression-guard.sh` thấy ít test pass hơn nhưng không flag deletion. Defense: `loc-ceiling-check.sh` bắt sudden file size change; không hoàn hảo.

Các gap đã biết này được document trong `agent-workspace/memory/.harness-gaps.md` (informal log) và surface qua [Chương 14 § Đóng Góp](14-dong-gop.md) cho community input.

---

## 12.12 — Đọc Tiếp Ở Đâu

- **Công thức cho task thông thường** → [Chương 11 — Công Thức](11-cong-thuc.md)
- **Inventory artifact đầy đủ** → [Chương 13 — Tham Khảo](13-tham-khao.md)
- **Mở rộng harness** → [Chương 14 — Đóng Góp](14-dong-gop.md)
- **Thuật ngữ** → [Chương 15 — Thuật Ngữ](15-thuat-ngu.md)
