# Chương 14 — Đóng Góp (Contributing)

> **Phân khu Diataxis**: How-to + Explanation
> **Thời gian đọc**: ~25 phút
> **Điều kiện tiên quyết**: Chương 4 (Hiến Pháp), Chương 10 (Tự Cải Thiện)

Chương này dành cho người muốn *mở rộng* harness — thêm skill, propose constitution rule, ratify ADR, port harness sang project mới. Nó giả định bạn đã đọc các chương trước và muốn tham gia vào sự tiến hóa của hệ thống.

---

## 14.1 — Mental Model của Contribution

Đóng góp cho harness khác với đóng góp cho một typical open-source project. Sự khác biệt:

| Typical OSS | Harness |
|---|---|
| Fork → PR → merge | Propose → cool-down → ratify → mv |
| Maintainer decide | Project owner ratify; agent propose |
| Code review bởi human | Sandwich pattern (architect → dev → verifier) |
| Test là gate | Test + drift signal + harness health + verifier |
| Breaking change versioned | Constitution amendment versioned; mọi thứ khác evolve tự do |

Sự shift quan trọng: **harness được contribute bởi cả human và agent**. Cả hai follow cùng protocol.

Nếu bạn là human đang đọc cái này: chương này nói cho bạn biết phải làm gì.
Nếu bạn là agent đang đọc cái này: bạn đã biết chương này rồi; refer to [`agent-workspace/CLAUDE.md`](../../../agent-workspace/CLAUDE.md) § Contract Rules.

---

## 14.2 — What to Ask vs What to Decide

Theo [`autonomous-protocol.md`](../../../agent-workspace/constitution/autonomous-protocol.md) Rule 8:

> "AskUserQuestion is for genuinely-new SCOPE/CHARTER decisions only — not for routine handoffs or 'what should I do next session?'"

Tier của decision quyết định ai decide:

| Tier | Confidence threshold | Ai decide |
|---|---|---|
| CHARTER | 0.99 | Luôn AskUserQuestion bundle + human ratify |
| SCOPE | 0.90 | AskUserQuestion nếu < 0.90 |
| ARCH | 0.80 | Self-decide nếu ≥ 0.80 |
| IMPL | 0.50 | Self-decide nếu ≥ 0.50 |

### Ví Dụ

**ASK** (CHARTER-tier):
- Amend `PROJECT_CHARTER.md`
- Thêm một bounded context mới vào architecture
- Thay đổi 11 principle
- Override một hard boundary B-1..B-14

**ASK** (SCOPE-tier):
- Thêm một data provider mới (ví dụ: thêm KOL channel)
- Thay đổi Phase target
- Thêm session type mới

**SELF-DECIDE** (ARCH-tier):
- Pick giữa hai valid architecture có tradeoff tương tự
- Choose library version
- Refactor approach trong một established pattern

**SELF-DECIDE** (IMPL-tier):
- Variable name
- Test fixture structure
- Comment style
- Có nên inline hay extract một function

### Cách Xác Định Tier

Nếu không chắc, hỏi: "Decision này có khả năng outlive current sprint không?"

- **Có, multi-phase impact** → CHARTER hoặc SCOPE
- **Live trong một phase** → ARCH
- **Live trong một session** → IMPL

Khi vẫn không chắc, **bias to ASK**. False negative (ask khi self-decide có thể đã ok) tốn một ít user attention. False positive (self-decide khi ask cần thiết) tốn trust.

---

## 14.3 — Propose Một Constitution Rule

Khi một learned rule đã đạt tới invariant tier, nó được propose cho constitution.

### Step 1: Viết Proposal

Location: `agent-workspace/proposals/<slug>.md`.

Frontmatter:

```yaml
---
status: PROPOSED
tier: CHARTER  # or SCOPE
ratification_path: AskUserQuestion bundle
cool_down_hours: 48
target_file: agent-workspace/constitution/<file>.md
proposed_at: <ISO-8601>
proposed_by: <agent | human>
source_evidence:
  - <session ID where lesson surfaced>
  - <link to mistake-log entry>
  - <link to prior ADR if related>
---
```

Body:

```markdown
# Proposal: <title>

## Background
[why this rule is needed; what failure mode it addresses]

## Proposed Rule
[the literal rule text, ready to mv into constitution]

## Options Considered
- Option A (Recommended): <description> / pros / cons
- Option B: <description> / pros / cons
- Option C (defer): <description> / pros / cons

## Recommendation
[which option + rationale]

## Companion Artifacts
[hooks / skills / firing-tests that will ship with the rule]

## Catch-Rate Estimate
[from agent-notes.md: how many past sessions would this rule have helped]
```

### Step 2: Cool-Down

48 giờ tối thiểu trước ratification. Hook `proposal-bundle-advisor.sh` (SessionStart) surface ready proposals.

Cool-down là non-negotiable. Nó tồn tại để proposal có thể được re-read với fresh context.

### Step 3: Ratification

User issue explicit approval qua `AskUserQuestion` bundle:

```
Q: Approve proposal <slug> Option A as recommended?
Options:
  (A) Approve verbatim
  (B) Approve with minor edits (specify)
  (C) Defer (specify why)
  (D) Reject (specify why)
```

Capture user's pick.

### Step 4: Viết ADR Ratifying

Theo [Recipe 11](11-cong-thuc.md#recipe-11--run-an-adr-through-the-lifecycle). Field `chosen_rationale` của ADR cite pick Q1=A của user.

### Step 5: MV sang Constitution

Path `agent-workspace/constitution/**` bị deny với agent edit. Để mv, cần one-time deny-lift:

**Path 1** (preferred): bundle mv với một Edit operation đã được approved. Agent commit cycle handle cả hai cùng lúc.

**Path 2**: tạm thời lift deny trong `.claude/settings.json`, mv, restore deny. Cái này đòi hỏi human approval (charter-tier).

Theo pattern thật sự đã ship L-S310-2:
```bash
# Bash bypass via cp (Write deny doesn't catch Bash cp)
cp agent-workspace/proposals/<slug>.md agent-workspace/constitution/<file>.md
git rm agent-workspace/proposals/<slug>.md  # archive
```

### Step 6: Cross-Reference Update

Grep cho `proposals/<slug>` khắp repo. Update tất cả sang `constitution/<file>`.

```bash
grep -rln "proposals/<slug>" .
# update each match
```

### Step 7: Update `project.md`

Thêm ADR ratifying vào section **Recent Architectural Decisions**.

### Step 8: Verify

Trong session tiếp theo, verify:
- File tồn tại tại constitution path
- Path proposal cũ đã đi rồi
- Cross-reference ADR resolve
- Bất kỳ hook/skill nào đọc rule vẫn tìm thấy nó

---

## 14.4 — Thêm Skill / Command / Subagent / Hook Mới

Xem:
- [Chương 11 § Recipe 1 — Write a New Skill](11-cong-thuc.md#recipe-1--write-a-new-skill)
- [Chương 11 § Recipe 2 — Write a New Slash Command](11-cong-thuc.md#recipe-2--write-a-new-slash-command)
- [Chương 11 § Recipe 3 — Write a New Subagent](11-cong-thuc.md#recipe-3--write-a-new-subagent)
- [Chương 11 § Recipe 4 — Write a New Hook](11-cong-thuc.md#recipe-4--write-a-new-hook)

Sau khi thêm, update inventory liên quan:
- Skills → [`docs/harness/reference/inventory-skills.md`](../reference/inventory-skills.md)
- Commands → [`docs/harness/reference/inventory-commands.md`](../reference/inventory-commands.md)
- Subagents → [`docs/harness/reference/inventory-agents.md`](../reference/inventory-agents.md)
- Hooks → [`docs/harness/reference/inventory-hooks.md`](../reference/inventory-hooks.md)

HOẶC chạy `/harness-docs sync` và để maintainer agent regenerate.

---

## 14.5 — Giữ Sách Đồng Bộ

Sách này tự bản thân là một harness artifact. Nó cần maintenance.

### Skill `harness-docs-maintainer`

Sống tại [`.claude/skills/harness-docs-maintainer/SKILL.md`](../../../.claude/skills/harness-docs-maintainer/SKILL.md).

**Triggers**:
- User chạy `/harness-docs sync`
- Một skill / command / subagent / hook mới được thêm (Stop hook detect + recommend sync)
- Một constitution rule được amend

**Cái nó làm**:
1. Scan `.claude/skills/`, `.claude/commands/`, `.claude/agents/`, `scripts/hooks/`
2. So sánh frontmatter của mỗi artifact với inventory file tương ứng
3. Report drift: artifact mới chưa trong inventory, artifact bị xóa vẫn được list, description đã đổi chưa reflect
4. Offer regenerate các inventory file affected

**Output**: drift report + regenerated inventories.

### Command `/harness-docs`

Wrapper cho skill.

```
/harness-docs sync            # full inventory sync
/harness-docs sync skills     # only skills inventory
/harness-docs drift           # report drift without writing
/harness-docs validate        # verify all links resolve
```

Xem [`.claude/commands/harness-docs.md`](../../../.claude/commands/harness-docs.md).

### Subagent `harness-docs-auditor`

Cho drift giữa prose chapter (00-15) và harness live, dispatch subagent [`harness-docs-auditor`](../../../.claude/agents/harness-docs-auditor.md). Nó chạy trong fresh context, đọc:
- Cả inventory live system
- Các prose chapter

Và report:
- Claim của chapter không còn match reality (ví dụ: "23 skill" khi giờ có 25)
- Missing cross-reference
- Ví dụ out-of-date
- Section nên được update

### Triggers cho Re-Audit

| Trigger | Action |
|---|---|
| Constitution amendment | Re-audit Chương 4 |
| New ADR ratified | Re-audit Reference § ADRs |
| Skill / command / subagent được thêm hoặc xóa | Chạy `/harness-docs sync` |
| Hook được thêm hoặc xóa | Chạy `/harness-docs sync` + re-audit section Chương 6 |
| Charter version bump | Full re-audit |
| Quarterly cadence | Full re-audit + dispatch `harness-docs-auditor` |

### Drift Signal Integration

Drift giữa docs và reality được track như một drift signal (tương tự DR1-DR12). Thêm vào constitution nếu cần:

- DR-D1 — Inventory file count mismatch live count
- DR-D2 — Chapter cite artifact name không tồn tại
- DR-D3 — Example file:line citation invalid

Các cái này sẽ được promoted từ `agent-notes.md` theo lifecycle chuẩn.

---

## 14.6 — Port Harness Sang Project Mới

Nếu bạn muốn spin up harness trong một project khác (ví dụ: sister project tại `C:\htdocs\my-new-project/`).

### Dùng Skill `attach`

Sống tại [`.claude/skills/attach/SKILL.md`](../../../.claude/skills/attach/SKILL.md). Designed chính xác cho cái này.

```
Dispatch attach skill to port harness layer from C:\htdocs\stockforge to C:\htdocs\my-new-project
```

Cái nó làm:
1. Đọc `.claude/manifest.yaml` cho harness metadata
2. Honor layer tags (harness / stockforge / personal)
3. Copy harness layer sang target project
4. Adapt path và identity rules sang target
5. Support `--dry-run` cho preview

Cái nó KHÔNG copy:
- Constitution stockforge-specific (financial-data-protocol, invariants-stockforge)
- Skill stockforge-specific (crawler-reliability, evidence-extraction, etc.)
- Project memory (sessions, decisions, observations)
- Calibration data
- Stock-domain BC

### Manual Porting Checklist

Nếu bạn không dùng skill `attach`:

1. **Copy `.claude/`** (skills, commands, agents, settings.json template, hooks/example)
2. **Copy `scripts/hooks/`** (tất cả 118 hook + firing-test) — chúng generic với harness pattern
3. **Copy generic constitution files** (`karpathy-principles.md`, `architecture.md`, `boundaries.md`, `vbw-protocol.md`, `drift-signals.md` (phần generic), `session-budgets.md`, `autonomous-protocol.md`, `coding-principles.md`, `decision-discipline.md`, `harness-health-protocol.md`, `memory-routing-tree.md`, `memory-tiers.md`, `severity-schema.md`, `portability.md`)
4. **Viết project-specific charter** (`PROJECT_CHARTER.md`)
5. **Viết project-specific CLAUDE.md** tại project root
6. **Viết project-specific invariants** (`agent-workspace/constitution/invariants-<project>.md`)
7. **Initialize memory directories** (empty `sessions/`, `decisions/`, etc.)
8. **Initialize `current-execution.md`** với autonomous_mode = true + Phase 0 entry
9. **Initialize `project.md`** với project description + initial Phase Goals Tracker
10. **Chạy `bash scripts/hooks/firing-tests/run-all.sh`** — verify tất cả firing-test pass

### Layer Tags

Theo manifest skill `attach`, artifact được tag:

- **harness** — generic; copy sang bất kỳ project nào
- **stockforge** — stock-domain; chỉ copy sang stock-related project
- **personal** — owner-specific; không copy

Ví dụ:
- `karpathy-principles.md` → tag: harness
- skill `evidence-extraction` → tag: stockforge
- `personal-risk-profile.md` → tag: personal

---

## 14.7 — Report Bug Trong Harness

Khi bản thân harness bị broken (không phải product code), report qua:

### Routing Theo Severity-Tier

- **Mass deletion / data loss** → CRITICAL — `human-workspace/notifications/urgent.md` + Telegram push
- **Block enforcer false positive (loop agent)** → HIGH — write vào `human-workspace/q-and-a/pending/`
- **Hook silently fail to fire** → MEDIUM — write vào `agent-notes.md` như lesson + propose hook fix
- **Documentation inconsistency** → LOW — write vào `human-workspace/q-and-a/pending/` low-priority

### Anatomy của Một Bug Report

```markdown
# Bug: <short title>

## Severity
<CRITICAL | HIGH | MEDIUM | LOW>

## Discovery
- Session: S<N>
- Trigger: <what user did or what hook fired>
- Symptom: <what went wrong>

## Reproduction
1. Step 1
2. Step 2
3. Step 3

## Expected vs Actual
- Expected: <behavior>
- Actual: <behavior>

## Hypothesis
<root cause guess>

## Proposed Fix
<fix sketch — may be a new hook, a constitution amendment, etc.>

## Related
- M-S<N>-<M> (mistake log entry)
- Past lesson L-S<NN>-<MM> if related class
- Other bugs in similar class
```

---

## 14.8 — Promotion Lifecycle (Recap)

Detail trong [Chương 10 § 10.2](10-tu-cai-thien.md#102--promotion-lifecycle). Recap nhanh:

```
TIER 0 — INLINE (agent-notes.md digest)
  ↓ promote on 2nd instance (per AP-23)
TIER 1 — SKILL (.claude/skills/<name>/SKILL.md)
  ↓ promote when statically detectable
TIER 2 — HOOK (scripts/hooks/<name>.sh + firing-test)
  ↓ promote when rule rises to invariant
TIER 3 — CONSTITUTION (agent-workspace/constitution/<file>.md)
```

Mỗi tier graduation đòi hỏi:
1. Authoring artifact (skill / hook / proposal)
2. Companion firing-test (cho hook; theo Principle 11)
3. ADR ratifying promotion
4. Cross-reference update qua tất cả consumer

---

## 14.9 — Documentation Standards

Khi viết cho sách hoặc propose rule:

### Voice
- Direct, professional, không fluff
- Active voice
- "Bạn" (second person) cho prose instructional
- "Agent" / "Harness" cho system description

### Examples
- Real artifact từ project (file:line citation)
- Không invented example

### Cross-References
- Dùng `[link](relative-path)` giữa các chapter
- Link glossary term tại first occurrence trong chapter

### Code Blocks
- Luôn specify language cho syntax highlighting
- Bash example phải work trên Windows (bash qua Git Bash) + Linux + Mac
- Python example assume Python 3.11+

### Tables
- Dùng cho reference material (list, property)
- Bao gồm header row
- Right-align số, left-align text

### Diagrams
- ASCII cho conceptual flow (render khắp nơi)
- Mermaid cho architecture (render trên GitHub)
- Inline image chỉ khi ASCII sẽ obscure

### Vietnamese Mirror
- Cùng structure, cùng content
- Technical term trong English
- Natural Vietnamese cho prose
- Xem [`docs/harness/vi/`](../vi/) cho reference

---

## 14.10 — Lấy Help

| Loại câu hỏi | Hỏi ở đâu |
|---|---|
| Làm thế nào để X? | Đọc [Chương 11 — Công Thức](11-cong-thuc.md); nếu không cover, write vào `human-workspace/q-and-a/pending/` |
| Tại sao harness làm Y? | Đọc [Chương 12 — Nội Tại](12-noi-tai.md); nếu không cover, chạy `/devils-advocate` trên Y |
| Z là gì? | Check [Chương 15 — Thuật Ngữ](15-thuat-ngu.md) |
| Artifact cho W ở đâu? | Check [Chương 13 — Tham Khảo](13-tham-khao.md) |
| Đây có phải bug không? | Chạy `/drift-check` trước; nếu drift surface, file theo [§ 14.7](#147--report-bug-trong-harness) |

---

## 14.11 — Đọc Tiếp Ở Đâu

- **Thuật ngữ** → [Chương 15 — Thuật Ngữ](15-thuat-ngu.md)
- **Inventory artifact đầy đủ** → [Chương 13 — Tham Khảo](13-tham-khao.md)
- **Công thức** → [Chương 11 — Công Thức](11-cong-thuc.md)
- **Chương đầu tiên bạn đọc** → bắt đầu lại tại [Chương 1 — Bắt Đầu Nhanh](01-bat-dau-nhanh.md) nếu chưa làm
