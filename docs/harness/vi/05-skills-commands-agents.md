# Chương 5 — Skills, Commands, và Subagents

> **Phân khu Diataxis**: Reference + Explanation + How-to
> **Thời gian đọc**: ~45 phút
> **Điều kiện tiên quyết**: Chương 3 (Kiến Trúc) cho ngữ cảnh layer

Chương này bao quát ba bề mặt mở rộng hướng người dùng của harness:

- **Skills** — các pattern tự khám phá mà Claude gọi khi context khớp.
- **Commands** — các slash invocation người dùng tự gõ.
- **Subagents** — các worker persona context tươi mới mà bạn dispatch.

Cả ba đều nằm dưới `.claude/` và tuân theo các convention file nhất quán. Chúng khác nhau ở cách được kích hoạt và những gì chúng sở hữu.

---

## 5.1 — Chúng Khác Nhau Như Thế Nào

| Property | Skill | Command | Subagent |
|---|---|---|---|
| **Trigger** | Tự khám phá qua context match | User gõ `/<name>` | Dispatch qua tool `Agent` (thủ công hoặc lập trình) |
| **Context** | Kế thừa session hiện tại | Kế thừa session hiện tại | Context tươi mới — KHÔNG thấy session cha |
| **File location** | `.claude/skills/<name>/SKILL.md` | `.claude/commands/<name>.md` | `.claude/agents/<name>.md` |
| **Body content** | Quy trình tái sử dụng | Wrapper mỏng trên skill hoặc agent | Persona definition + responsibility + I/O contract |
| **Sở hữu gì** | Một *pattern* (làm gì khi X) | Một *shortcut* (làm cái này khi tôi gõ Y) | Một *job* (persona với responsibility cụ thể) |
| **Trần LOC** | ≤120 (D1) | ≤96 (D1) | ≤160 (D1) |
| **Tool grants** | `allowed-tools` frontmatter | Kế thừa tất cả | `tools:` frontmatter (minimal-grant) |
| **Trả về caller** | Không áp dụng (quy trình inline) | Không áp dụng (quy trình inline) | Một observation file + final message |

### Khi Nào Dùng Cái Nào

**Dùng Skill** khi:
- Cùng một quy trình xuất hiện trong 3+ session
- Nó được LLM trung gian (không đủ deterministic cho một hook)
- Nó nên tự kích hoạt khi context khớp (không phải do user gõ)

**Dùng Command** khi:
- User muốn một shortcut gõ được
- Công việc là một wrapper mỏng trên skill hoặc subagent có sẵn
- Body chủ yếu hướng user (welcome message, brief schema)

**Dùng Subagent** khi:
- Công việc cần **fresh context** (ví dụ, adversarial review)
- Persona khác biệt (architect vs verifier — mindset khác nhau)
- Output có cấu trúc và có thể truy vết (một observation cho mỗi dispatch)

### Quy Tắc Chống Trùng Lặp (L-S14-2)

Một skill tên `foo` và một command tên `/foo` không được trùng quy trình. Chọn một: hoặc body skill là canonical và body command chỉ invoke nó, hoặc ngược lại. Trùng lặp tạo ra hai sự thật phân kỳ.

---

## 5.2 — Skills

Skills sống tại `.claude/skills/<name>/SKILL.md`. Chúng được Claude Code tự khám phá: khi context user khớp với `description` trong frontmatter, skill trở nên khả dụng.

### Cấu Tạo Skill

```
.claude/skills/<name>/
├── SKILL.md          # required (≤120 LOC first-draft per L-S14-1)
├── examples/         # optional concrete examples
└── references/       # optional companion docs (no LOC ceiling)
```

### Frontmatter `SKILL.md`

```yaml
---
name: <kebab-case-name>
description: <one-line summary used for discovery match>
allowed-tools: [Read, Glob, Grep, Bash, Write, Edit]  # minimal grant
---
```

`description` là *bề mặt khám phá*. Một description mơ hồ có nghĩa là skill không bao giờ tự kích hoạt. Viết nó dẫn đầu bằng hành động cốt lõi và bao gồm các từ khóa domain mà user có thể đề cập.

**Description tệ**: "Helps with data extraction."

**Description tốt**: "Extract structured claims from VN news articles with citation integrity. Use when ingesting CafeF / NDH / VietnamBiz content; enforces I-S1 no-LLM-math + I-S2 source+as_of date."

### Các Section Body của SKILL.md

Mỗi skill nên bao gồm:

1. **Purpose** — một đoạn mô tả skill làm gì
2. **When to use** — các trigger cụ thể
3. **When NOT to use** — các non-trigger cụ thể
4. **Process / Content** — chính quy trình
5. **Anti-patterns** — 3+ ví dụ xấu cụ thể
6. **Related** — link đến các skill khác

### Progressive Disclosure (L-S14-1)

Target first-draft: **20% dưới trần** (skill ≤120 LOC, dự trữ 20-40 LOC cho amendment). Một skill draft AT trần sẽ vi phạm D1 trong vòng 2-3 amendment.

Khi nội dung phình ra: trích các sub-section chủ đề vào `references/<topic>.md` (không có trần D1) và thay thế nội dung inline bằng một pointer một dòng.

### Catalog 23 Skills

Ba họ skill:

#### Family A — Stockforge Business Logic (7 skills)

| Skill | Purpose | Trigger |
|---|---|---|
| [`crawler-reliability`](../../../.claude/skills/crawler-reliability/SKILL.md) | Build reliable scrapers (CafeF/NDH/YouTube/FB) | Implementing scraper, retry logic |
| [`ddd-tactical-patterns`](../../../.claude/skills/ddd-tactical-patterns/SKILL.md) | Apply DDD aggregate/VO/repo in Python dataclasses | New aggregate, repo Protocol, domain event |
| [`evidence-extraction`](../../../.claude/skills/evidence-extraction/SKILL.md) | Structured claim extraction with citation integrity | Building extractor pipelines |
| [`fastapi-module`](../../../.claude/skills/fastapi-module/SKILL.md) | FastAPI router conventions (Phase 2+) | New HTTP endpoint, router wiring |
| [`obsidian-vault`](../../../.claude/skills/obsidian-vault/SKILL.md) | Manage Obsidian wiki (entities/concepts/sources) | Adding KB note, ingesting source |
| [`postgres-pgvector`](../../../.claude/skills/postgres-pgvector/SKILL.md) | Schema design with pgvector + TimescaleDB | New migration, schema design |
| [`prompt-engineering`](../../../.claude/skills/prompt-engineering/SKILL.md) | LLM prompt design with no-LLM-math discipline | Authoring new extractor/analysis prompt |

#### Family B — Harness Self-Loop (10 skills)

| Skill | Purpose | Trigger |
|---|---|---|
| [`decompose-work`](../../../.claude/skills/decompose-work/SKILL.md) | Split task into deterministic vs LLM portions | Multi-part task ≥3 sub-parts |
| [`empirical-probe-first`](../../../.claude/skills/empirical-probe-first/SKILL.md) | Probe ALL strategies in multi-option ladder | Plan lists ≥3 strategies for one problem |
| [`grill-maximization`](../../../.claude/skills/grill-maximization/SKILL.md) | Bundle 15-20 Q&A questions per human touchpoint | Confidence below threshold |
| [`hook-diagnostics`](../../../.claude/skills/hook-diagnostics/SKILL.md) | Inspect hook state machine + transcript cache | Hook stuck active, aggregator row missing |
| [`promote-rule`](../../../.claude/skills/promote-rule/SKILL.md) | Cluster agent-notes → propose promotion | ≥10 new rules since last run |
| [`qa-escalation`](../../../.claude/skills/qa-escalation/SKILL.md) | File-based Q&A bundle protocol | intent-classifier OPEN_QA_BUNDLE |
| [`session-memory-l0-l1`](../../../.claude/skills/session-memory-l0-l1/SKILL.md) | Extract L0 regex + L1 LLM memories from JSONL | Post-SessionEnd ingestion |
| [`sync-pull`](../../../.claude/skills/sync-pull/SKILL.md) | Pre-flight confidence-score lookup | About to commit non-trivial decision |
| [`try-n-approaches`](../../../.claude/skills/try-n-approaches/SKILL.md) | Generate ≥3 approaches + metric function | Open question from drift/dogfood |
| [`user-prompt-intake`](../../../.claude/skills/user-prompt-intake/SKILL.md) | Hybrid intent classifier (lite-detect + subagent) | Any new user prompt landing |

#### Family C — Knowledge-Base (6 skills)

| Skill | Purpose | Trigger |
|---|---|---|
| [`attach`](../../../.claude/skills/attach/SKILL.md) | Port harness layer to a new project dir | New CC project, peer copy |
| [`spec-dual-layer`](../../../.claude/skills/spec-dual-layer/SKILL.md) | Author specs with Part A + Part B | Tier 2/3 spec authoring |
| [`spec-to-wiki`](../../../.claude/skills/spec-to-wiki/SKILL.md) | Convert raw spec to Obsidian wiki | After /spec-author |
| [`test-pyramid-balance`](../../../.claude/skills/test-pyramid-balance/SKILL.md) | Balance unit/integration/E2E tests | New feature test plan |
| [`ubiquitous-language`](../../../.claude/skills/ubiquitous-language/SKILL.md) | DDD glossary extraction + maintenance | New BC, term emerges |
| [`write-a-skill`](../../../.claude/skills/write-a-skill/SKILL.md) | Create new skills with progressive disclosure | Pattern surfaces in 3+ sessions |

### Pruning Skill

Hàng quý: bất kỳ skill nào không được kích hoạt trong 3 tháng — đánh giá (vẫn còn liên quan? description cần sửa? deprecate?). Mỗi skill được load tiêu tốn token context.

---

## 5.3 — Commands

Commands sống tại `.claude/commands/<name>.md`. Chúng là các slash invocation người dùng gõ. Hầu hết là wrapper mỏng ủy quyền cho một skill hoặc dispatch một subagent.

### Cấu Tạo Command

```markdown
# /<name> — <One-line purpose>

> Optional aside.

## When to Use
<concrete triggers>

## Input
<optional $ARGUMENTS>

## Steps
1. <numbered>
2. ...

## Output Schema
<what the user sees>

## Anti-Patterns
<3+ concrete bad examples>

## Related
<links>
```

### Catalog 16 Commands

Lưu ý: 16 commands, không phải 17 — không có command file `bdd-planner` (chỉ subagent tồn tại; BDD planning được dispatch thủ công).

#### Session Lifecycle (5 commands)

| Command | Purpose | Invokes |
|---|---|---|
| [`/session-start`](../../../.claude/commands/session-start.md) | Load state, identify session type, output brief | (không skill — reading priority trong body) |
| [`/session-verify`](../../../.claude/commands/session-verify.md) | Mid-session alignment check | (không skill) |
| [`/session-end`](../../../.claude/commands/session-end.md) | Close session + update memory | (không skill — checklist trong body) |
| [`/handoff-read`](../../../.claude/commands/handoff-read.md) | Lightweight session-pickup (vs full /session-start) | (không skill) |
| [`/budget-check`](../../../.claude/commands/budget-check.md) | Report token consumption + projection | (không skill) |

#### Planning + Spec (3 commands)

| Command | Purpose | Invokes |
|---|---|---|
| [`/master-plan`](../../../.claude/commands/master-plan.md) | Decompose goal into phased sessions | `master-planner` subagent |
| [`/spec-author`](../../../.claude/commands/spec-author.md) | Create dual-layer spec | `spec-author` subagent |
| [`/spec-to-wiki`](../../../.claude/commands/spec-to-wiki.md) | Convert raw spec to Obsidian wiki | `spec-to-wiki` skill |

#### Adversarial + Quality (6 commands)

| Command | Purpose | Invokes |
|---|---|---|
| [`/devils-advocate`](../../../.claude/commands/devils-advocate.md) | Adversarial critique of plan/spec/code/thesis | `devils-advocate` subagent |
| [`/drift-check`](../../../.claude/commands/drift-check.md) | Run drift signals DR1-DR12 | `drift-signals-D1-D9.sh` + `drift-detector` for DR7/DR12 |
| [`/drill-me`](../../../.claude/commands/drill-me.md) | Interactive DDD UL extraction | `ubiquitous-language` skill |
| [`/grill-me`](../../../.claude/commands/grill-me.md) | Relentless plan/design interview | `grill-maximization` skill |
| [`/ul-audit`](../../../.claude/commands/ul-audit.md) | Audit UL consistency (code vs glossary) | `ul-auditor` subagent + grep checks |
| [`/vbw-check`](../../../.claude/commands/vbw-check.md) | Apply VBW protocol for current task | `vbw-protocol.md` constitution |

#### Infrastructure Toggles (2 commands)

| Command | Purpose | Invokes |
|---|---|---|
| [`/autonomous`](../../../.claude/commands/autonomous.md) | Toggle autonomous mode on/off/status | (atomic file ops) |
| [`/block`](../../../.claude/commands/block.md) | Human-gate control (status/clear/raise) | `block-control.sh` |

### Các Section Body Command Thông Dụng

Mỗi command nên có:

- **When to Use** — điều kiện trigger cụ thể
- **Input** — `$ARGUMENTS` (hoặc stdin) command nhận
- **Steps** — quy trình đánh số
- **Brief Schema / Output Schema** — cái user thấy
- **Error Handling** — nó fail gracefully như thế nào
- **Anti-Patterns** — ví dụ xấu cụ thể
- **Related** — các command / skill khác

### Tại Sao Commands Mỏng

Một command nên chủ yếu *định tuyến* — đến một skill, đến một subagent, đến một script. Body của file command chủ yếu là **prose hướng user**: khi nào invoke, user có thể mong đợi gì, edge case.

Công việc thực — quy trình đạt được goal — sống trong một skill (cho quy trình tái sử dụng) hoặc một subagent (cho task fresh-context).

---

## 5.4 — Subagents

Subagents sống tại `.claude/agents/<name>.md`. Chúng là *personas* với các responsibility khác biệt, được dispatch qua tool `Agent`. Mỗi cái chạy trong **fresh context** — subagent không kế thừa transcript của session cha.

### Cấu Tạo Subagent

```markdown
---
name: <kebab-case-name>
description: <one-line summary; matched against task at dispatch time>
model: opus | sonnet | haiku
tools: [Read, Glob, Grep, Write, Edit, Bash]  # minimal grant
---

# Subagent: <Title>

## Persona
<who this agent is>

## Responsibility
<what they own>

## Input
<what dispatch must provide>

## Process
### Phase 1: Comprehend
### Phase 2: ...

## Output Contract
<structured return format>

## Anti-Patterns
<what this agent must NOT do>
```

### Fresh Context

Đây là đặc tính then chốt. Khi bạn dispatch một subagent, nó khởi đầu với:

- System prompt + persona definition (file này)
- Prompt bạn đưa cho nó
- Tools bạn cấp
- **Không gì khác từ cuộc trò chuyện của bạn**

Điều này khiến chúng lý tưởng cho:
- **Adversarial review** — verifier không thể hợp lý hóa suy luận của architect nếu nó chưa bao giờ thấy nó
- **Parallel work** — nhiều subagent trên các task độc lập, không có shared state
- **Context isolation** — các thao tác đọc nặng không làm ô nhiễm session cha

### Catalog 14 Subagents

Tất cả 14 agent khai báo `model: opus` (per user 2026-05-17 directive "full opus + follow budget").

#### Planner Personas (5 agents)

| Agent | Persona | Tools | When Dispatched |
|---|---|---|---|
| [`action-guide-planner`](../../../.claude/agents/action-guide-planner.md) | Pragmatic lead dev — turn brief into next actions | Read, Glob, Grep | Manual / session-start follow-up |
| [`bdd-planner`](../../../.claude/agents/bdd-planner.md) | Senior QA — test pyramid balance | Read, Glob, Grep, Write | Manual (post `/spec-author`) |
| [`master-planner`](../../../.claude/agents/master-planner.md) | Senior tech lead — decompose goal into sessions | Read, Glob, Grep, Write | `/master-plan` |
| [`sandwich-architect`](../../../.claude/agents/sandwich-architect.md) | Senior architect — plans IMPL sessions | Read, Glob, Grep, Write | PLAN session type |
| [`spec-author`](../../../.claude/agents/spec-author.md) | BA + DDD designer — dual-layer spec | Read, Glob, Grep, Write | `/spec-author` |

#### Executor Persona (1 agent)

| Agent | Persona | Tools | When Dispatched |
|---|---|---|---|
| [`sandwich-dev`](../../../.claude/agents/sandwich-dev.md) | Focused implementer — executes architect's plan | Read, Glob, Grep, Write, Edit, Bash | FOCUSED_IMPL / MULTI_TASK_IMPL |

#### Auditor / Fresh-Eyes Personas (8 agents)

| Agent | Persona | Tools | When Dispatched |
|---|---|---|---|
| [`devils-advocate`](../../../.claude/agents/devils-advocate.md) | Experienced skeptic | Read, Glob, Grep | `/devils-advocate` |
| [`drift-detector`](../../../.claude/agents/drift-detector.md) | Structural integrity inspector | Read, Glob, Grep, Bash | `/drift-check` (for DR7/DR12) |
| [`intent-classifier`](../../../.claude/agents/intent-classifier.md) | Cool-headed triage | Read, Glob, Grep | `user-prompt-intake` skill |
| [`intent-vs-impl-diff`](../../../.claude/agents/intent-vs-impl-diff.md) | Adversarial cross-checker (intent vs impl) | Read, Glob, Grep, Bash, Write | On-demand / phase-boundary |
| [`lesson-synthesizer`](../../../.claude/agents/lesson-synthesizer.md) | Pattern miner — Stage 2 self-upgrade | Read, Glob, Grep, Bash, Write, Edit | `lesson-synthesis-watchdog` ALERT |
| [`research-scanner`](../../../.claude/agents/research-scanner.md) | Repo cartographer — opensource fit | Read, Glob, Grep, WebFetch | Manual (research dogfood) |
| [`sandwich-verifier`](../../../.claude/agents/sandwich-verifier.md) | Skeptical fresh-context reviewer | Read, Glob, Grep, Bash | VERIFY session type |
| [`ul-auditor`](../../../.claude/agents/ul-auditor.md) | Detail-obsessed DDD — synonym / drift detection | Read, Glob, Grep, Bash | `/ul-audit` |

### No-Write Override của Sandwich Verifier

[`sandwich-verifier.md`](../../../.claude/agents/sandwich-verifier.md) cố ý thiếu `Write` trong tools grant. Đây là theo **PCG-S401-4** — một cluster 3 sự cố (S397/S400/S401) nơi dispatch brief yêu cầu agent Write findings, nhưng persona cấm điều đó. Pattern bây giờ được codify:

- Verifier trả về findings **inline dưới dạng text** trong final message.
- Main session đọc text của verifier và persist xuống disk dưới authorship của main.
- Điều này giữ vai trò verifier thuần advisory và bảo toàn traceability.

### Chi Phí Dispatch

Mỗi dispatch subagent:

- Spawn fresh context (~1-3K bootstrap)
- Đọc persona file của nó (~1-2K)
- Đọc các input liên quan (varies)
- Tốn Anthropic API token tại rate model của agent
- Log trong `agent-workspace/memory/dispatch.jsonl`
- Chi phí USD log trong `agent-workspace/memory/cost-ledger.tsv`

Cho PLAN (Opus): điển hình 150-230K token; ~$2-4 USD mỗi dispatch.
Cho VERIFY (Opus): điển hình 80-180K token; ~$1-2 USD mỗi dispatch.
Cho lesson-synthesizer (Opus): điển hình 60-100K token.

---

## 5.5 — Năm Pipeline Canonical

Skills, commands, và subagents tổ hợp lại thành các pipeline nhận biết được. Harness có năm pattern canonical:

### Pipeline 1 — Sandwich Workflow (cái chịu lực)

```
/session-start
   ↓ (no plan exists yet)
/master-plan <goal>
   ↓ dispatches master-planner
   ↓ writes session-plans/pending/NNN-S<sid>-<slug>.md
next session loads plan
   ↓ session type detected as PLAN
sandwich-architect dispatched
   ↓ reads plan + constitution + relevant code
   ↓ writes detailed sub-plan (D1..DN tasks)
next session loads sub-plan
   ↓ session type detected as FOCUSED_IMPL / MULTI_TASK_IMPL
sandwich-dev dispatched
   ↓ implements D1..DN
   ↓ runs mypy/pytest/ruff
   ↓ writes session log with verification
next session loads dev observation
   ↓ session type detected as VERIFY
sandwich-verifier dispatched
   ↓ fresh-context review
   ↓ returns verdict (PASS / PASS-WITH-CONCERNS / FAIL) inline
main session persists verifier's findings to attestation-log.tsv
/session-end
```

### Pipeline 2 — Knowledge-Base

```
/drill-me
   ↓ interactive UL extraction
   ↓ uses ubiquitous-language skill
   ↓ updates agent-workspace/ubiquitous-language/glossary.md
/spec-author <feature>
   ↓ dispatches spec-author subagent
   ↓ writes specs/tier2-feature/NNN-*.md
/spec-to-wiki <spec-path>
   ↓ uses spec-to-wiki skill
   ↓ writes obsidian-vault/wiki/specs/...md
/ul-audit
   ↓ dispatches ul-auditor subagent
   ↓ checks code vs glossary
   ↓ writes drift report
```

### Pipeline 3 — Self-Upgrade Loop (Karpathy autoresearch)

```
Drift surfaces signal (DR1-DR12 hook fires)
   ↓
try-n-approaches skill
   ↓ frames experiment (≥3 approaches: DEEPEN / BROADEN / ABANDON)
   ↓ writes framing artifact to learning-data/loop/
   ↓ defines metric function (BLOCKING per L-S12-1)
executes approaches
   ↓ outcomes accumulate in agent-notes.md
promote-rule skill
   ↓ clusters via Jaccard similarity
   ↓ writes observations/promotion-proposals-<TS>.md
   ↓ proposes promotion: inline → skill → hook → constitution
lesson-synthesizer agent
   ↓ when lesson-synthesis-watchdog ALERTs
   ↓ fills KI / BP entries with session-diff evidence
   ↓ assigns L-S{NN}-N ID
```

Parallel: `decompose-work` quyết định det-vs-LLM split cho mỗi bước; `empirical-probe-first` từ chối stale-evidence recommendations TRƯỚC commit.

### Pipeline 4 — Calibration / Q&A

```
User submits prompt
   ↓
user-prompt-intake skill (lite-detect)
   ↓ trivial whitelist (incl. Vietnamese)
   ↓ non-trivial → dispatch intent-classifier
intent-classifier subagent
   ↓ YAML verdict: primary_intent / recommended_action / suggested_grill_questions
if recommended_action == "OPEN_QA_BUNDLE":
   sync-pull skill
   ↓ reads sync-tracker/state.tsv + weights.yaml
   ↓ emits SELF-DECIDE-OK / GRILL / FORCE-GRILL
if GRILL:
   grill-maximization skill
   ↓ bundles 15-20 Qs per touchpoint
   ↓ writes to human-workspace/q-and-a/pending/<bundle>.md
   ↓ AskUserQuestion (≤4 per call; the BINDING surface)
qa-escalation skill
   ↓ pending → answered → stale lifecycle
   ↓ auto-mv hook moves resolved bundles
```

### Pipeline 5 — Quality Gates

```
Per-commit (Tier 1 deterministic):
   - mypy --strict
   - pytest
   - ruff
   - drift-signals-D1-D9.sh
   - dependency cycle check
Per-merge (Tier 2 probabilistic):
   - /vbw-check (VBW protocol)
   - /drift-check (semantic DR7/DR12 via drift-detector)
   - /devils-advocate (pre-merge adversarial review)
   - intent-vs-impl-diff at phase boundary
Per-phase (Tier 3 human):
   - Architectural decisions (CHARTER-tier ratify)
   - API contracts (SCOPE-tier ratify)
   - Eval regression sign-off
   - Thesis quality review
```

---

## 5.6 — Cơ Chế Sandwich Architect

Vì sandwich pattern chịu lực, persona architect xứng đáng được xem xét kỹ hơn. File [`sandwich-architect.md`](../../../.claude/agents/sandwich-architect.md) (~600 LOC) định nghĩa quy trình 5-phase:

### Phase 1: Comprehend

Đọc:
- Target spec hoàn chỉnh (Part A + B)
- Các file constitution liên quan (architecture, invariants)
- Code hiện có trong các bounded context bị ảnh hưởng
- Các ADR hoặc note liên quan

Áp dụng VBW Protocol — xác minh source so với memory.

### Phase 1b: Self-Calibration (bắt buộc nếu ≥3 sub-tracks)

Đọc (cap 30 dòng cuối mỗi file per DD-2):
- `agent-workspace/memory/.planner-stats.tsv`
- `agent-workspace/memory/self-awareness/sessions-rollup.tsv`
- `agent-workspace/memory/dispatch.jsonl`
- `agent-workspace/memory/mistake-log.md`

Trích cho similarity task_class hiện tại:
- Average duration_ms + outcome distribution + failure_mode frequency
- Cho model+effort tương tự dispatch context hiện tại: tokens_real vs estimated
- Cho coordination-rule pattern: bất kỳ sự cố file-collision nào được ghi lại

Dùng để:
- Đặt budget THỰC TẾ mỗi sub-track (không phải boilerplate)
- Flag các sub-track có failure-mode frequency cao
- Xác định cơ hội parallelization an toàn

Cold-start: nếu sample_size < 3 cho task_class hiện tại, gracefully degrade về budget mặc định; flag là "cold-start". KHÔNG block plan authoring.

### Phase 2: Architecture Decisions

Cho implementation này:
- Bounded context nào sở hữu cái này?
- Aggregate nào bị ảnh hưởng?
- Cần entity/value object mới không?
- Database changes?
- API changes?
- Events để publish/subscribe?

Document các quyết định tường minh.

### STEP 2.X — Dispatch-Brief Path Verification (L-S392-1)

Cho MỖI file path được đề cập trong dispatch brief:
1. Chạy Glob hoặc Read để xác minh path tồn tại
2. Nếu path KHÔNG tồn tại: KHÔNG cite path đó; grep correct path thực tế từ mistake-log / observation evidence
3. Cite parent plan/spec verbatim với file:line reference
4. Nếu brief chứa text được diễn giải khác primary source, DÙNG primary source + document deviation

Anti-example: Dispatch brief S392 cite `packages/_shared/pdf/pdf_table_extractor_port.py` (không tồn tại); architect VBW tìm thấy canonical tại `packages/application/fundamental/pdf_table_extractor_port.py`.

### STEP 2.Y — Operational-Track Full-Pipeline Cold-Probe (L-S395-1)

Khi tác giả OPERATIONAL plans (data ingestion / cost-bearing pipeline / multi-ticker batch), STEP 0 PHẢI bao gồm FULL-pipeline cold-probe (KHÔNG chỉ wire-probe) TRƯỚC khi bulk operational work commit resources:

1. Single-ticker dry-run của toàn bộ pipeline end-to-end
2. Assert cost ≤ BR-N cap (cite BR rule cụ thể theo ID + current cap value)
3. Assert quality threshold (ví dụ ≥N article mỗi ticker cho sentiment; ≥N statement mỗi ticker cho fundamentals)
4. Surface bất kỳ architectural blocker nào AT PLAN time, không phải at IMPL time
5. Nếu cold-probe surface blocker: STOP-AND-ASK qua STOP-FINDING trong human-workspace/notifications/

### Phase Closure Attestation Vocabulary (L-S385-2)

Plans PHẢI dùng một trong:
- **DONE**: code + data substrates cả hai đều ready
- **CODE-DONE-DATA-PENDING**: code ready; data pending; gate marked CODE-READY-DATA-PENDING
- **DATA-DONE-CODE-PENDING**: hiếm; data ready nhưng code chưa wired
- **PENDING**: cả hai không ready
- **BLOCKED-BY-\<X\>**: blocker tường minh

Flat "DONE" attestation khi data PENDING = anti-pattern.

### Phase 3: File-Level Planning

List mọi file sẽ được tạo hoặc sửa đổi, với:
- Purpose
- Size estimate (LOC)
- Methods/functions
- Dependencies

### Phase 4: Risk Mitigations (RM1..RMN)

Cho mỗi risk có thể xác định, viết một entry RM đặt tên prevention measure.

### Phase 5: DoD Per Sub-Track

Mỗi sub-track có DoD (Definition of Done) riêng với trần LOC per-category và verification criteria.

---

## 5.7 — Anti-Patterns Thông Dụng

| Anti-pattern | Cái gì sai | Fix |
|---|---|---|
| Vague skill description | Không trigger đáng tin cậy | Dẫn đầu bằng hành động cốt lõi; include domain keywords |
| Skill drafted AT D1 ceiling | Vi phạm D1 sau amendment đầu tiên | 20% dưới ceiling (L-S14-1) |
| Code dumps in SKILL.md | Bloat Tier 1 budget | Đẩy sang `examples/` hoặc `references/` |
| Duplicate `<name>` skill và `/<name>` command | Hai sự thật phân kỳ (L-S14-2) | Chọn một canonical; cái kia invoke |
| Subagent dispatched without fresh-context need | Lãng phí ~5-10K bootstrap token | Dùng skill nếu context có thể được kế thừa |
| Verifier asked to Write findings | Vi phạm persona; persistence broken | Main session persist từ inline text |
| Architect re-plans during dev session | Mix PLAN + IMPL | Tách session; không bao giờ mix |
| Sandwich-dev re-architects | Drift khỏi plan | Dev chỉ execute plan; flag issues, không fix architecturally |
| Master plan written without VBW | Cite paths không tồn tại | STEP 2.X path verification |
| Architect cold-probes wire only | Bỏ lỡ operational blocker | STEP 2.Y full-pipeline cold-probe |
| Plan marks "DONE" when data pending | Misleading state | Dùng vocabulary: CODE-DONE-DATA-PENDING |

---

## 5.8 — Đọc Tiếp Ở Đâu

- **Deterministic enforcement** của các quy tắc này → [Chương 6 — Hooks](06-hooks.md)
- **Cách build skill / command / subagent của riêng bạn** → [Chương 11 — Cookbook](11-cong-thuc.md)
- **Inventory đầy đủ** với mọi artifact → [Reference § Skills](../reference/inventory-skills.md)
- **Cách các persona tương tác qua các session** → [Chương 8 — Lifecycle](08-vong-doi.md)
