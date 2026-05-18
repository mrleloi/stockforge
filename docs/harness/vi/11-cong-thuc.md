# Chương 11 — Công Thức (Cookbook)

> **Phân khu Diataxis**: How-to (giải quyết vấn đề)
> **Thời gian đọc**: ~45 phút (hoặc nhảy thẳng tới công thức bạn cần)
> **Điều kiện tiên quyết**: Chương 3 (Kiến Trúc) để có context về layer

Chương này là một tập hợp các công thức. Mỗi công thức là một quy trình hoàn chỉnh cho một task lặp lại. Dùng chương này khi bạn có một công việc cụ thể cần làm và muốn con đường ngắn nhất từ vấn đề tới giải pháp.

Các công thức giả định bạn đã hiểu *concepts*; nếu chưa, hãy theo cross-reference quay lại chương explanation tương ứng.

---

## Bảng Công Thức

- [Recipe 1 — Write a New Skill](#recipe-1--write-a-new-skill)
- [Recipe 2 — Write a New Slash Command](#recipe-2--write-a-new-slash-command)
- [Recipe 3 — Write a New Subagent](#recipe-3--write-a-new-subagent)
- [Recipe 4 — Write a New Hook](#recipe-4--write-a-new-hook)
- [Recipe 5 — Run a Sandwich Cycle](#recipe-5--run-a-sandwich-cycle)
- [Recipe 6 — Audit for Drift](#recipe-6--audit-for-drift)
- [Recipe 7 — Recover from an Incident](#recipe-7--recover-from-an-incident)
- [Recipe 8 — Dispatch Parallel Agents](#recipe-8--dispatch-parallel-agents)
- [Recipe 9 — Set Up Telegram Alerts](#recipe-9--set-up-telegram-alerts)
- [Recipe 10 — Promote a Rule](#recipe-10--promote-a-rule)
- [Recipe 11 — Run an ADR Through the Lifecycle](#recipe-11--run-an-adr-through-the-lifecycle)
- [Recipe 12 — Add a New Constitution Rule](#recipe-12--add-a-new-constitution-rule)
- [Recipe 13 — Archive an Old Session](#recipe-13--archive-an-old-session)
- [Recipe 14 — Debug a Silent Hook](#recipe-14--debug-a-silent-hook)
- [Recipe 15 — Run a THESIS Session](#recipe-15--run-a-thesis-session)

---

## Recipe 1 — Write a New Skill

**Khi nào dùng**: Bạn đã nhận diện một pattern xuất hiện 3+ session và muốn formalize nó để các session tương lai tự động discover và apply.

**Điều kiện tiên quyết**:
- Pattern là LLM-mediated (không đủ deterministic để thành hook)
- Nó tái sử dụng được (không phải one-off)
- Nó chưa được document như một constitution rule

**Quy trình**:

1. **Chọn kebab-case name** thể hiện hành động. Ví dụ: `evidence-extraction`, `try-n-approaches`, `crawler-reliability`.

2. **Tạo directory**:
   ```bash
   mkdir -p .claude/skills/<name>/{examples,references}
   ```

3. **Viết `SKILL.md`** với cấu trúc:
   ```markdown
   ---
   name: <name>
   description: <one-line discovery match — lead with action verb + keywords>
   allowed-tools: [Read, Glob, Grep, Bash, Write, Edit]
   ---

   # Skill: <Title>

   ## Purpose
   <one paragraph>

   ## When to Use
   - Trigger 1
   - Trigger 2

   ## When NOT to Use
   - Non-trigger 1
   - Non-trigger 2

   ## Process / Content
   <the actual procedure — steps, examples>

   ## Anti-Patterns
   - 3+ concrete bad examples

   ## Related Skills
   - [[other-skill]]
   ```

4. **Mục tiêu ≤120 LOC** (theo L-S14-1). Nếu nội dung vượt quá, extract sang `references/<topic>.md`.

5. **Viết `description`** một cách cẩn thận — đó là discovery match. Bắt đầu bằng action verb cốt lõi. Bao gồm domain keywords. Ví dụ:
   - **Xấu**: "Helps with X."
   - **Tốt**: "Extract structured claims from VN news articles with citation integrity. Use when ingesting CafeF / NDH / VietnamBiz content; enforces I-S1 no-LLM-math + I-S2 source+as_of date."

6. **Test trigger**: trong một session mới, đề cập đến thứ gì đó match với description. Verify skill trở nên available.

7. **Document**: thêm vào [Reference § Skills](../reference/inventory-skills.md) hoặc chạy `/harness-docs sync`.

---

## Recipe 2 — Write a New Slash Command

**Khi nào dùng**: User muốn một typed shortcut cho một action thông thường. Command nên là thin wrapper.

**Anti-pattern**: duplicate procedure giữa một skill `<name>` và một command `/<name>` (L-S14-2). Chọn một canonical implementation; cái kia invoke.

**Quy trình**:

1. **Chọn kebab-case name**.

2. **Tạo file** tại `.claude/commands/<name>.md`.

3. **Dùng template này**:
   ```markdown
   # /<name> — <One-line purpose>

   > Optional aside.

   ## When to Use
   <concrete triggers>

   ## Input
   <optional $ARGUMENTS or stdin>

   ## Steps
   1. <numbered>
   2. ...

   ## Output Schema
   <what the user sees>

   ## Error Handling
   <how it fails gracefully>

   ## Anti-Patterns
   - 3+ concrete bad examples

   ## Related
   - <links to skill / subagent / other commands>
   ```

4. **Giữ ≤96 LOC** (ceiling D1 cho commands).

5. **Nếu delegate sang skill**: body nói "delegates to `<skill-name>` skill" với minimal restatement.

6. **Nếu dispatch một subagent**: body nói "dispatches `<agent-name>` subagent" với prompt template.

7. **Document**.

---

## Recipe 3 — Write a New Subagent

**Khi nào dùng**: Bạn cần một persona làm việc trong **fresh context** (không inherit transcript của parent session). Trường hợp phổ biến: adversarial review, planning, calibration analysis.

**Quy trình**:

1. **Chọn kebab-case name**.

2. **Tạo file** tại `.claude/agents/<name>.md`.

3. **Frontmatter**:
   ```yaml
   ---
   name: <name>
   description: <one-line summary; matched against task at dispatch time>
   model: opus  # or sonnet / haiku
   tools: [Read, Glob, Grep, Write, Edit, Bash]  # minimal grant
   ---
   ```

4. **Các section trong body**:
   ```markdown
   # Subagent: <Title>

   ## Persona
   <who this agent is; mindset>

   ## Responsibility
   <what they own>

   ## Input
   <what the dispatch must provide>

   ## Process
   ### Phase 1: Comprehend
   ### Phase 2: ...

   ## Output Contract
   <structured return format>

   ## Anti-Patterns
   <what this agent must NOT do>
   ```

5. **Giữ ≤160 LOC** (ceiling D1 cho agents).

6. **Minimal-grant tools**: chỉ những gì agent cần. Verifier KHÔNG nên có Write (theo PCG-S401-4).

7. **Test bằng cách dispatch**: trong một session, dispatch qua `Agent(subagent_type='<name>', prompt='<test prompt>')` và verify agent hành xử theo persona.

8. **Document**.

---

## Recipe 4 — Write a New Hook

**Khi nào dùng**: Bạn có một rule statically detectable (regex / grep / file-existence check), và rule đã xuất hiện 2+ lần (theo ngưỡng promotion AP-23).

**Quy trình**:

1. **Chọn đúng event**: SessionStart? Stop? PreToolUse? PostToolUse? UserPromptSubmit? Xem [Chương 6 § 6.1](06-hooks.md#61--the-event-model).

2. **Tạo script** tại `scripts/hooks/<name>.sh`:
   ```bash
   #!/usr/bin/env bash
   # <name>.sh — <one-line purpose>
   # Trigger: <event> (per .claude/settings.json:<line>)
   # Origin: <lesson ID> / <ADR>
   # Severity: <info | warn | block (RC=2)>
   # <other meta>
   set -uo pipefail
   trap 'exit 0' ERR  # most hooks should not block on internal error

   PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
   SID="${CLAUDE_SESSION_ID:-unknown}"
   TS="$(date -Iseconds)"

   # <checks here>

   exit 0  # or non-zero if blocking
   ```

3. **Idempotency markers** (nếu Stop-tier): dùng hour-bucket hoặc day-bucket markers để tránh duplicate work qua các Stop fire nhanh.

4. **Same-session caching** (nếu UserPromptSubmit-tier): cache kết quả trong `.<hook>-cache-${SID}` với TTL.

5. **Tôn trọng env `STOCKFORGE_HOOK_PROFILE`**: warn-only mặc định; strict mode block.

6. **Viết firing-test** tại `scripts/hooks/firing-tests/<name>-fire-test.sh`:
   ```bash
   #!/usr/bin/env bash
   # <name>-fire-test.sh — companion firing test
   # SPAWN-CONTEXT: positional  ← required if non-default arg form
   set -uo pipefail

   TEMPDIR=$(mktemp -d)
   trap "rm -rf $TEMPDIR" EXIT
   export CLAUDE_PROJECT_DIR="$TEMPDIR"

   # TC1: positive case
   # <setup synthetic stdin or files>
   echo '{"session_id":"test","tool_input":{"command":"safe"}}' | bash "$HOOK_PATH"
   rc=$?
   [ $rc -eq 0 ] || { echo "TC1 FAIL: expected RC=0, got $rc"; exit 1; }
   echo "TC1 PASS"

   # TC2: negative case (should block)
   echo '{"session_id":"test","tool_input":{"command":"rm -rf /"}}' | bash "$HOOK_PATH"
   rc=$?
   [ $rc -eq 2 ] || { echo "TC2 FAIL: expected RC=2, got $rc"; exit 1; }
   echo "TC2 PASS"

   # TC3..N: edge cases

   echo "ALL PASS"
   exit 0
   ```

7. **Wire trong `.claude/settings.json`** tại đúng event + order:
   ```json
   "Stop": [
     {
       "hooks": [
         ...,
         {
           "type": "command",
           "command": "bash \"${CLAUDE_PROJECT_DIR:-.}/scripts/hooks/<name>.sh\""
         },
         ...
       ]
     }
   ]
   ```
   Chú ý order coupling (ví dụ: phải chạy SAU `severity-classifier.sh`).

8. **Verify**:
   ```bash
   bash scripts/hooks/firing-tests/<name>-fire-test.sh
   bash scripts/hooks/firing-tests/run-all.sh  # full regression
   ```

9. **Verify production firing** (Principle 11): trong session thật tiếp theo, check `.session-hooks.log` thấy hook firing. KHÔNG declare done cho đến khi có production evidence.

10. **Document**.

---

## Recipe 5 — Run a Sandwich Cycle

**Khi nào dùng**: Bạn có một feature hoặc refactor cần implementation. Sandwich pattern là canonical cho non-trivial work (>30 LOC change, nhiều file, cần planning).

**Quy trình**:

### Session 1 — Master Plan (Optional)

Nếu work là multi-phase, chạy `/master-plan` trước:

```
/master-plan <high-level goal>
```

Cái này dispatch subagent `master-planner`. Output: `agent-workspace/session-plans/pending/NNN-S<sid>-<slug>.md`.

### Session 2 — Architect (PLAN session)

```
/session-start
```

Verify session type là PLAN. Sau đó dispatch architect:

```
Dispatch sandwich-architect for plan-NNN
```

Architect đọc master plan, chạy Phase 1b self-calibration nếu ≥3 sub-tracks, produce detailed sub-plan với D1..DN task, file scope, DoD, RM1..RMN.

End session. Sub-plan giờ nằm trong `pending/`.

### Session 3 — Dev (FOCUSED_IMPL hoặc MULTI_TASK_IMPL)

```
/session-start
```

Verify session type là FOCUSED_IMPL (1-3 task) hoặc MULTI_TASK_IMPL (4-10 task). Dispatch dev:

```
Dispatch sandwich-dev for plan-NNN
```

Dev chạy STEP 0 VBW re-verification, implement D1..DN, chạy mypy/pytest/ruff, viết session log với verification block.

End session.

### Session 4 — Verifier (VERIFY session)

```
/session-start
```

Verify session type là VERIFY. Dispatch verifier:

```
Dispatch sandwich-verifier for plan-NNN (S<dev-sid> output)
```

Verifier chạy V1..V12 grid trong fresh context, return verdict inline. Main session persist findings vào `attestation-log.tsv` + observation.

Nếu PASS hoặc PASS-WITH-CONCERNS (merge-eligible): mv plan từ `pending/` sang `completed/`.

Nếu FAIL: để trong pending/; dispatch dev session mới với remediation D' task.

End session.

---

## Recipe 6 — Audit for Drift

**Khi nào dùng**: Bạn nghi ngờ harness hoặc code đã drift khỏi constitution; discipline định kỳ; post-incident audit.

**Quy trình**:

1. **Chạy automatic drift catalog**:
   ```
   /drift-check
   ```
   Cái này chạy `drift-signals-D1-D9.sh` + dispatch subagent `drift-detector` cho semantic DR7 + DR12.

2. **Chạy harness health self-scan** (trong fresh session qua SessionStart):
   ```bash
   tail -50 agent-workspace/memory/.harness-health.log
   ```
   Tìm các entry HH-N FAIL.

3. **Chạy sync-grilling** (nếu 38 session / 7 ngày đã trôi):
   ```
   /sync-pull
   /grill-me  # if SELF-DECIDE-OK = false
   ```

4. **Phase coherence**:
   ```bash
   tail -30 agent-workspace/memory/.session-hooks.log | grep phase-status-coherence
   ```
   Tìm các entry RED HIGH.

5. **Audit constitution coherence**:
   ```
   /devils-advocate  # adversarial review of recent ADRs vs constitution
   ```

6. **Đọc drift rollups**:
   ```bash
   ls -la agent-workspace/memory/drift-logs/ | tail -10
   ```
   Đọc rollup mới nhất.

7. **Thực hiện action**: mỗi item surface lên → hoặc fix (immediate), ADR (pending), hoặc retire (nếu false positive).

---

## Recipe 7 — Recover from an Incident

**Khi nào dùng**: Mass deletion, corrupted state, lost work, broken automation.

**Response theo severity**:

### Mass File Deletion

1. **Stop tất cả session ngay lập tức** (close Claude).

2. **Check git state**:
   ```bash
   git status
   git log --oneline -20
   ```
   Nếu file uncommitted: hy vọng chúng có trong daily-backup tại `<project-parent>/stockforge-backups/`.

3. **Restore từ backup**:
   ```bash
   ls <project-parent>/stockforge-backups/  # find most recent backup
   tar -xzf <project-parent>/stockforge-backups/<DATE>.tar.gz -C /tmp/restore/
   # compare /tmp/restore/ vs current; copy missing files back
   ```

4. **Restore từ git**:
   ```bash
   git checkout HEAD -- <path>  # restore staged file
   git log --all --diff-filter=D -- <path>  # find when path was deleted
   git checkout <commit>^ -- <path>  # restore from before deletion
   ```

5. **Document incident**:
   - Viết `agent-workspace/post-mortems/YYYY-MM-DD-<incident-name>.md`
   - Update `mistake-log.md` với entry `M-S<N>-<M>`
   - Nếu có prevention rules mới: viết vào `agent-notes.md`
   - Nếu có hook mới được propose: queue cho cycle `promote-rule`

### Corrupted `current-execution.md`

1. **Restore từ checkpoint**:
   ```bash
   cat agent-workspace/memory/checkpoints/latest.md
   # If latest.md is also corrupted:
   ls agent-workspace/memory/checkpoints/ | tail -5
   # Restore from most recent valid timestamp file
   ```

2. **Chạy `/session-start`**:
   ```
   /session-start
   ```
   Bootstrap đọc từ `current-execution.md`; nếu restored đúng, session resume.

### Broken Hook Causing False Block

1. **Check `urgent.md`**:
   ```bash
   cat human-workspace/notifications/urgent.md
   ```

2. **Xác định hook đang block**:
   ```bash
   tail -100 agent-workspace/memory/.session-hooks.log | grep -i block
   ```

3. **Verify bằng firing-test**:
   ```bash
   bash scripts/hooks/firing-tests/<hook>-fire-test.sh
   ```

4. **Nếu hook broken**: tạm thời unwire bằng cách comment out trong `.claude/settings.json`. Document như defer-cycle ADR. Fix trong session tiếp.

5. **Clear block**:
   ```
   /block clear
   ```
   Hoặc manual: `rm agent-workspace/memory/.autonomous-BLOCKED`.

### Lost Subagent Work

1. **Check observation file**:
   ```bash
   ls -la agent-workspace/memory/observations/ | tail -10
   ```
   Subagent có thể đã viết observation ngay cả khi message của nó bị mất.

2. **Check dispatch.jsonl**:
   ```bash
   tail -20 agent-workspace/memory/dispatch.jsonl
   ```
   Tìm row COMPLETED cho orphan.

3. **Check raw session export**:
   ```bash
   ls agent-workspace/raw-sessions/ | tail -5
   ```
   `session-export-raw.sh` archive transcripts; có thể đã capture subagent IO.

---

## Recipe 8 — Dispatch Parallel Agents

**Khi nào dùng**: Bạn có nhiều task độc lập. Parallel dispatch tiết kiệm wall-clock time nhưng đòi hỏi coordination.

**Quy trình**:

1. **Verify task là independent**: không shared file write; không depend vào output của nhau.

2. **Viết coordination rules** vào `current-execution.md`:
   ```markdown
   **Coordination rule (S<N> active)**: main session avoids
   `<files agent 1 touches>`,
   `<files agent 2 touches>`.
   ```

3. **Dispatch tất cả agents parallel** (single message, multiple Agent tool calls):
   ```python
   Agent(subagent_type='sandwich-dev', prompt='...', run_in_background=True)
   Agent(subagent_type='research-scanner', prompt='...', run_in_background=True)
   Agent(subagent_type='ul-auditor', prompt='...', run_in_background=True)
   ```

4. **Tiếp tục với work khác** trong khi agent chạy. Harness sẽ notify bạn khi mỗi cái hoàn thành.

5. **Khi hoàn thành**: đọc mỗi observation file. Persist findings. Move artifacts.

6. **Clear coordination rules** khỏi `current-execution.md` khi parallel cluster done.

---

## Recipe 9 — Set Up Telegram Alerts

**Khi nào dùng**: Bạn muốn CRITICAL/HIGH severity item được push lên điện thoại.

**Quy trình**:

1. **Tạo Telegram bot**:
   - Mở Telegram → message `@BotFather`
   - `/newbot` → đặt tên bot
   - Copy bot token

2. **Lấy chat_id của bạn**:
   - Gửi một message tới bot
   - `curl https://api.telegram.org/bot<TOKEN>/getUpdates`
   - Tìm `"chat":{"id":<NUMBER>` trong response

3. **Set env vars** trong `.claude/settings.local.json` (gitignored):
   ```json
   "env": {
     "STOCKFORGE_TELEGRAM_BOT_TOKEN": "<token>",
     "STOCKFORGE_TELEGRAM_CHAT_ID": "<chat_id>"
   }
   ```

4. **Test trong DRY_RUN mode** trước:
   ```bash
   STOCKFORGE_TELEGRAM_DRY_RUN=1 bash scripts/hooks/telegram-push.sh "TEST: harness alert"
   ```

5. **Test live**:
   ```bash
   bash scripts/hooks/telegram-push.sh "HIGH: live test from harness"
   ```

6. **Verify** message đã đến. Check `agent-workspace/memory/.session-hooks.log` cho dòng log push.

Pipeline giờ tự động push CRITICAL + HIGH qua `escalation-engine.sh`.

---

## Recipe 10 — Promote a Rule

**Khi nào dùng**: Bạn thấy một rule (trong `agent-notes.md`) đã xuất hiện 2+ lần và đáng được promote lên hook/skill/constitution.

**Quy trình**:

1. **Dispatch subagent `promote-rule`**:
   ```
   Dispatch promote-rule for agent-notes cluster review
   ```

2. **Đọc proposal** tại `agent-workspace/memory/observations/promotion-proposals-<TS>.md`.

3. **Cho mỗi candidate**, quyết định:
   - **HOOK**: rule statically detectable. Ship như `scripts/hooks/<name>.sh` + firing-test.
   - **SKILL**: rule là một procedure lặp lại. Ship như `.claude/skills/<name>/SKILL.md`.
   - **CONSTITUTION**: rule lên tới invariant. Viết proposal vào `agent-workspace/proposals/`.
   - **RETIRE**: rule duplicate của charter / skill / hook đã có. Document retirement trong `agent-notes.md`.

4. **AskUserQuestion nếu charter-tier**: charter promotions cần ratification.

5. **Implement** path đã chọn (xem Recipe 1, 4, hoặc 12).

6. **Update `agent-notes.md`**: mark các entry gốc là `PROMOTED-TO-<artifact>` để tránh re-promotion.

---

## Recipe 11 — Run an ADR Through the Lifecycle

**Khi nào dùng**: Bạn có một decision cần record formally.

**Quy trình**:

1. **Xác định tier**: CHARTER / SCOPE / ARCH / IMPL. Theo [`decision-discipline.md`](../../../agent-workspace/constitution/decision-discipline.md).

2. **Xác định confidence**: đọc `agent-workspace/memory/sync-tracker/state.tsv` cho category liên quan. Nếu dưới threshold, trigger `/grill-me` trước.

3. **Lấy số ADR tiếp theo**:
   ```bash
   ls agent-workspace/memory/decisions/ | grep -E '^[0-9]{3}-' | sort | tail -1
   # next = max + 1
   ```

4. **Viết ADR** tại `agent-workspace/memory/decisions/NNN-<slug>.md` dùng `_template.md`:
   ```yaml
   ---
   id: D-NNN
   title: <short title>
   date: YYYY-MM-DD
   status: PROPOSED
   level: CHARTER | SCOPE | ARCH | IMPL
   ...
   ---
   ```

5. **Cool-down**: theo tier (CHARTER 48h, SCOPE 24h, ARCH 12h, IMPL 0h).

6. **Ratify**: nếu CHARTER/SCOPE, AskUserQuestion bundle. Nếu ARCH/IMPL, self-decide trên threshold.

7. **Flip status** PROPOSED → ACCEPTED trong ADR.

8. **Implement** ADR (companion code / hook / skill ship).

9. **Verify**: sandwich-verifier run pick up clause verification của ADR.

10. **Flip status** ACCEPTED → SHIPPED khi verification pass.

11. **Nếu sau này bị superseded**: ADR gốc `status: SUPERSEDED-BY-D-NNN`. Không bao giờ xóa.

---

## Recipe 12 — Add a New Constitution Rule

**Khi nào dùng**: Một rule đã lên tới charter tier — nó là invariant, không contextual.

**Quy trình**:

1. **Viết proposal** tại `agent-workspace/proposals/<slug>.md`:
   ```markdown
   ---
   status: PROPOSED
   tier: CHARTER
   ratification_path: AskUserQuestion bundle
   cool_down_hours: 48
   target_file: agent-workspace/constitution/<file>.md
   ---

   # Proposal: <title>

   ## Background
   ## Proposed Rule
   ## Options Considered
   ## Recommendation
   ## Companion Artifacts
   ```

2. **Cool-down**: 48h tối thiểu. SessionStart hook `proposal-bundle-advisor.sh` surface proposal sẵn sàng.

3. **AskUserQuestion bundle**: present options + recommendation. Capture user pick.

4. **Viết ADR** (theo Recipe 11) ratify proposal.

5. **MV proposal sang constitution**: cần one-time deny-lift vì `agent-workspace/constitution/**` nằm trong deny list. Hoặc:
   - Bundle mv với một Edit đã được approved
   - Tạm thời lift deny trong `settings.json`, mv, restore deny

6. **Cross-reference update**: grep cho `proposals/<slug>` khắp repo; update tất cả sang `constitution/<file>`.

7. **Update `project.md` Recent ADRs section** với link sang ADR mới.

---

## Recipe 13 — Archive an Old Session

**Khi nào dùng**: `current-execution.md` vượt cap 5-session / 200-LOC. `tracking-retention.sh` nên auto-migrate, nhưng đôi khi cần manual archive.

**Quy trình**:

1. **Xác định session range** cần archive:
   ```bash
   head -200 agent-workspace/memory/current-execution.md
   # Find oldest section: "## S<N> — ..."
   ```

2. **Tạo archive file**:
   ```
   agent-workspace/memory/current-execution-archive-YYYY-MM-DD-S<from>-to-S<to>.md
   ```

3. **Cut + paste** các section session cũ từ `current-execution.md` vào archive.

4. **Verify** `current-execution.md` giờ ≤200 LOC và có 5 session mới nhất.

5. **Check cap**:
   ```bash
   wc -l agent-workspace/memory/current-execution.md
   ```

---

## Recipe 14 — Debug a Silent Hook

**Khi nào dùng**: Một hook đã wire nhưng `.session-hooks.log` không thấy entry nào từ nó.

**Quy trình**:

1. **Verify wiring**:
   ```bash
   grep "<hook>" .claude/settings.json
   ```

2. **Verify script executable**:
   ```bash
   ls -la scripts/hooks/<hook>.sh
   ```

3. **Chạy firing-test**:
   ```bash
   bash scripts/hooks/firing-tests/<hook>-fire-test.sh
   ```

4. **Nếu firing-test pass nhưng production silent**: failure mode kinh điển của Principle 11. Check:
   - **SPAWN-CONTEXT**: firing-test có exercise đúng spawn topology mà Claude Code dùng không? Form-A (`VAR=val bash ...`) fail âm thầm trên Windows.
   - **PPID assumption**: hook chạy như Claude Code subprocess thường có `$PPID=1`, không phải parent claude.exe PID.
   - **Environment variables**: `$CLAUDE_PROJECT_DIR` có thể khác giữa test và production.

5. **Dùng `lock-rc-probe.sh`** như diagnostic:
   ```bash
   bash scripts/hooks/lock-rc-probe.sh
   ```

6. **Check output `firing-test-spawn-context-lint.sh`**:
   ```bash
   bash scripts/hooks/firing-test-spawn-context-lint.sh
   ```

7. **Fix phổ biến**: đổi wiring từ `VAR=val bash ...` sang `env VAR=val bash ...`.

8. **Verify trong session thật tiếp theo**: check `.session-hooks.log`.

---

## Recipe 15 — Run a THESIS Session

**Khi nào dùng**: Bạn muốn làm multi-perspective adversarial analysis trên một cổ phiếu.

**Quy trình**:

1. **Mở Claude trong session MỚI** (để context sạch cho analysis):
   ```bash
   claude
   ```

2. **Xác định session type tường minh**:
   ```
   /session-start --type THESIS <ticker>
   ```

3. **Harness đảm bảo**:
   - Read-only mode trên code (no Edit/Write vào `packages/`, `apps/`)
   - Output đi vào `agent-workspace/memory/thesis-log/`
   - Charter Principle 3 (adversarial by design) áp dụng — bear case bắt buộc
   - Charter Principle 9 (no LLM math) áp dụng — tất cả số từ `vnstock` / SQLite

4. **Workflow**:
   - Đọc `agent-workspace/memory/thesis-log/` cho thesis trước về ticker này
   - Đọc `obsidian-vault/wiki/entities/<ticker>.md` cho research trước
   - Dispatch deterministic computations sang Python tools (no LLM math)
   - Frame như research aid, không phải "buy/sell" (theo I-S35)

5. **Output**: thesis entry tại `thesis-log/<TS>-<ticker>.md`:
   ```yaml
   ---
   thesis_id: <hex>
   ticker: <TICKER>
   as_of: <YYYY-MM-DD>
   dogfood_session: S<N>
   ---

   # Thesis: <TICKER>

   ## Bull Case (≥3 specific points)
   ...

   ## Bear Case (≥3 specific points; I-S10 enforced)
   ...

   ## Quant Snapshot
   [from deterministic tools]

   ## Position Sizing Recommendation
   [per deterministic risk rules; LLM cannot override]

   ## Calibration
   [hit rate from prior thesis on this ticker]
   ```

6. **Verify**:
   - I-S10 bear case ≥3 points
   - I-S2 mỗi claim có source + as-of
   - I-S35 framing: "thesis exploration", không phải "buy/sell recommendation"

7. **End session** bình thường. Thesis giờ nằm trong log.

---

## Đọc Tiếp Ở Đâu

- **Tại sao các pattern này hoạt động** → [Chương 12 — Nội Tại](12-noi-tai.md)
- **Inventory artifact đầy đủ** → [Chương 13 — Tham Khảo](13-tham-khao.md)
- **Đóng góp cho harness** → [Chương 14 — Đóng Góp](14-dong-gop.md)
