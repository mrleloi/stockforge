# Agent Notes — Learned Rules

> Append-mostly. Each rule earned through real experience (post-mortem, drift detection, user correction).
> Rules here have higher status than convention but lower than constitution.

## Rule Format

Use this template:

```markdown
### YYYY-MM-DD: [Short rule name]
**Context**: What situation triggered learning this
**Rule**: The actionable rule
**Anti-example**: What was done wrong
**Correct example**: What should be done instead
**Severity**: critical | high | medium | low
**Auto-detect**: yes/no — can a drift signal catch this?
```

---

## Initial Rules (from charter design)

### 2026-04-23: LLM Never Outputs Numbers
**Context**: Stock domain risk — LLM-generated numbers in finance lead to real money loss
**Rule**: LLM never returns numerical values as natural-language output. All numbers come from deterministic Python functions invoked via tool use. LLM only interprets results.
**Anti-example**:
```
LLM output: "Based on my analysis, the company's ROE is approximately 18%, P/E is around 12, and intrinsic value is roughly 95,000 VND per share."
```
**Correct example**:
```
LLM tool calls:
  compute_roe(net_income=2_345B, equity=13_120B) → 17.87%
  compute_pe(price=85_000, eps=7_054) → 12.05
  compute_intrinsic_value_dcf(...) → 94_523 VND
LLM output: "ROE = 17.87% (FY2024), P/E = 12.05 (TTM), DCF intrinsic value = 94,523 VND. Versus current price 85,000 VND, suggests ~11% margin of safety."
```
**Severity**: critical
**Auto-detect**: yes — regex for "approximately", "around", "roughly" + numbers in LLM output

### 2026-04-23: Bear Case Required for Every Thesis
**Context**: Confirmation bias is the #1 retail investor mistake
**Rule**: Every thesis output must include substantive bear case (≥3 distinct points, each grounded in evidence). System refuses to render thesis without it.
**Anti-example**: Thesis with bull case + risks section that says "market volatility, regulatory changes" (boilerplate)
**Correct example**: Bear case with specific points like "Q3 inventory turnover dropped 23% YoY suggesting demand weakness", "Major competitor X launched directly competitive product Y in March 2026", "Net working capital deterioration of 15% indicates cash flow strain"
**Severity**: high
**Auto-detect**: yes — bear case length + specificity check

### 2026-04-23: Confidence Requires Calibration Data
**Context**: LLM "confidence" is qualitative; user reads numerical values
**Rule**: Any "X% confidence" or "high/medium/low confidence" claim must trace to historical hit rate from calibration database. Include `n_samples`, `lookback_period`, `hit_rate` metadata.
**Anti-example**: "70% confidence this is a buy"
**Correct example**: "Confidence: MEDIUM (signal pattern: cyclical_bottom_with_dividend; historical n=23 cases since 2018; hit rate 65% over 12 months; lookback=78 months)"
**Severity**: high
**Auto-detect**: partial — flag confidence claims without metadata

### 2026-04-23: Source Provider Disagreement Surfaced
**Context**: vnstock vs FiinPro vs TCBS sometimes disagree on same data point
**Rule**: When sources disagree by >1%, output shows divergence explicitly. Never silently pick one.
**Anti-example**: "Revenue Q3 2024: 35,000 tỷ" (silent average or arbitrary pick)
**Correct example**: "Revenue Q3 2024: 35,000 tỷ ± 200 tỷ (vnstock: 35,000 / FiinPro: 35,200 / TCBS: 34,800; reconciled with HIGH confidence)"
**Severity**: medium
**Auto-detect**: no (requires source metadata in output template)

---

## Add New Rules Here

### 2026-04-29: Q&A Bundle Skeleton MUST Carry `defer_cycle` Field
**Context**: While drafting `qa-escalation/references/sample-bundle.md` in S2, I initially omitted `defer_cycle` from the bundle frontmatter — caught on review against Decision 002 § Track 2 R7 mitigation.
**Rule**: Every Q&A bundle file in `human-workspace/q-and-a/pending/` MUST include `defer_cycle: 0` at creation, and increment on every reopening / supersession. SessionStart hook (Track 5) keys can-kicking detection off this field.
**Anti-example**: Bundle with frontmatter `id / topic / opened_at / expected_answer_by / priority / status` — passes superficial validation but R7 mitigation is invisible.
**Correct example**: Bundle frontmatter includes `defer_cycle: 0` from creation; every Decision in `related_decisions:` also has `defer_cycles` field syncronized.
**Severity**: medium
**Auto-detect**: yes — Track 5 `qa-pending-stale-mover.sh` hook should reject bundles missing the field.

### 2026-04-29: User Communication Idiom — "ok rồi. continue" / "ok continue" = Trivial Acknowledgment
**Context**: User in `human-workspace/user_prompt/20260429_03.txt` and via chat replies repeatedly used the idiom "ok rồi. continue" or "ok continue" as the standard "I accept the proposed defaults; proceed" signal in Q&A round acceptance flows.
**Rule**: Treat both phrases as TRIVIAL acknowledgment in lite-detect (`user-prompt-intake/references/lite-detect-patterns.md`). Do NOT dispatch intent-classifier on these. They specifically mean "accept all defaults of the most recent agent-proposed bundle / decision".
**Anti-example**: Spending 5K context to classify "ok continue" via subagent — wasteful and misses the user's stable communication idiom.
**Correct example**: Lite-detect short-circuits these to `primary_intent: TRIVIAL` + `recommended_action: HANDLE_TRIVIAL`. Continue per `current-execution.md`.
**Severity**: low (efficiency, not correctness)
**Auto-detect**: yes — already covered in lite-detect whitelist as "special idiom" entry.

### 2026-04-29: Hooks Invoked by Harness Shell Don't Traverse Claude Permission Model
**Context**: While designing Q&A escalation in S2, I encountered a tension: `Write(human-workspace/q-and-a/answered/**)` is deny-listed for the agent (only humans move files there), but Track 5 hooks may need to write `status: processed` flag inside answered files.
**Rule**: Hooks invoked by Claude Code harness (configured in `.claude/settings.json` `hooks` section) execute as shell scripts OUTSIDE the agent's tool-permission model. The deny-list applies to the agent's Write/Edit tool calls, not to hook scripts. Therefore hook scripts CAN write to deny-listed paths, but should still respect the spirit (don't pretend to be human-authored content).
**Anti-example**: Refusing to write a Track 5 hook that updates `status: processed` because "the agent can't write to answered/".
**Correct example**: Hook script writes the `status: processed` flag; agent's tool calls remain blocked. If unsure, prefer sidecar files (`<bundle>.processed`) over in-place edits to keep audit trail crisp.
**Severity**: medium
**Auto-detect**: no (design-time consideration)

### 2026-04-29 (post-audit): AP-S2-3 — False Self-Attestation on Measurable Properties
**Context**: In S2 session log "verifier-lite pass" I claimed: "SKILL.md bodies are 130-160 LOC each…within target". Adversarial drift audit (background `general-purpose` subagent) measured actual LOC and found `qa-escalation` = 242 (+61% over) and `grill-maximization` = 187 (+25% over). My self-attestation was wrong by ~25-61%, while feeling confident.
**Rule**: For any property that can be measured deterministically (LOC, byte count, presence-of-field, file-exists), VERIFY with the actual command (`wc -l`, `Glob`, `Grep`) before writing the verifier-lite claim. Do NOT estimate from memory of "what I just wrote feels about right."
**Anti-example**: "manual count: SKILL.md bodies are 130-160 LOC each…within target" written without running `wc -l`.
**Correct example**: Run `wc -l <file>` for each verified item; quote the actual number. If above ceiling, either trim or document the overrun + grace flag explicitly.
**Severity**: high (this is the same anti-pattern as orch's CF-DOGFOOD-2 self-attestation — agent claims compliance based on impression, not verification)
**Auto-detect**: yes — Track 5 hook can grep session logs for `LOC|line count|bodies are.*LOC` claims and require accompanying `wc -l` command in the same session log.

### 2026-04-29 (post-audit): Charter-Tier Items Never Ride Default-Acceptance Bundles
**Context**: In Round-3 Q&A the agent bundled Q-S1..Q-S5 together. Q-S5 ("small trusted circle = git-fork single-tenant") is identity-tier (locks Phase 0-5 architecture, threshold 0.99). The other 4 (Q-S1..Q-S4) were SCOPE-tier (threshold 0.90). User's "ok continue" reply absorbed all 5 via the safe-defaults shortcut. This is exactly the orch CF-DOGFOOD-2 pattern UP-02 §1.1 warned about.
**Rule**: When composing a Q&A bundle, if ANY question is CHARTER-tier (threshold 0.99), split it into a dedicated CHARTER-only bundle. The CHARTER bundle has: explicit-pick options only (no safe agent-defaults), no `D: open answer`-only fields, ALERT notification regardless of priority, and `approval_chain` requires verbatim user phrase quoted in the answered file (not just `ACCEPTED via "ok continue"`).
**Anti-example**: 5 mixed-tier questions in one bundle accepted via "ok continue".
**Correct example**: 4 SCOPE questions in one bundle (defaults OK); 1 CHARTER question in a separate dedicated bundle with explicit confirmation.
**Severity**: high (charter scope drift is the most damaging drift type)
**Auto-detect**: yes — drift-detector grep for bundles where ≥1 `level: CHARTER` field appears alongside other levels in the same `related_decisions:` array.

### 2026-04-29 (UP-06): NO Silent File-Defaults — Every Needed Answer via AskUserQuestion Multi-Batch
**Context**: User in chat after UP-05 turn explicitly corrected: "tôi sẽ không vào file q&a để trả lời, ví dụ như tôi đang remote-control từ mobile thì sao. cần phải làm cho q&a thực sự hiệu quả chứ không phải làm cho có". Agent had been writing bundles with N>4 questions, firing 4 via `AskUserQuestion`, then claiming "rest will default after 24h if user doesn't edit file". This is exactly the orch CF-DOGFOOD-2 silent-absorption pattern in disguise — for mobile-remote users especially, file-edit is not a real channel.
**Rule**: Every question agent NEEDS answered MUST be surfaced via `AskUserQuestion`. For >4 questions: multi-batch chain (within-turn `Ask(4) → Ask(4) → ...` or across-turn). Bundle file = pure audit trail; NEVER an input surface with default-after-N-hours fallback. If a question is "would be nice but not blocking now" → DO NOT bundle as deferred-default; instead queue in `agent-workspace/memory/observations/queued-grill-<topic>.md` with `fire_when: <track-or-condition>` trigger. Re-grill via Ask when condition activates.
**Anti-example**: Write 16-question bundle, fire 4 via `Ask`, mark remaining 12 with "default applies after 24h if user doesn't edit file". Mobile-remote user never edits file → defaults silently absorb 12 decisions agent never explicitly verified.
**Correct example**: 16-question bundle → fire 4 via `Ask` → user answers → fire next 4 via `Ask` → ... 4 batches total OR drop questions that aren't truly blocking now (queue them with `fire_when:`). Bundle file logs all 16 with answers from each Ask round; NO "default" semantic.
**Severity**: critical (mobile-remote primary use case; silent absorption is the pattern user explicitly corrected for the third time in this project — UP-02 §1.1, UP-04 G1, UP-06 here).
**Auto-detect**: yes — drift-detector greps Q&A bundle frontmatter for `pending_in_file:` array OR "default applies" string; flag any bundle that has unanswered questions without matching `AskUserQuestion` call OR `queued-grill-*.md` follow-up.

### 2026-04-29 (UP-05): AskUserQuestion 4-Question Limit is Intentional; Multi-Batch is the Workaround
**Context**: User asked if 4-question limit on `AskUserQuestion` could be bypassed via setting/script/repo. `claude-code-guide` subagent research (2026-04-29) confirmed: limit is intentional design (`maxItems: 4` JSONSchema constraint); NO config flag / env var / hidden setting overrides it.
**Rule**: For bundles >4 questions, use multi-batch pattern: fire 4 most-critical via `AskUserQuestion` in same turn → record answers → fire next 4 via second `AskUserQuestion` call (or queue file-based for async). Never try to `AskUserQuestion` >4 in one call; tool will reject. The B1=A policy (AskUserQuestion-primary) still holds — multi-batch is the implementation, not a violation.
**Anti-example**: Try to fire 16-question bundle in one `AskUserQuestion` call (will fail with validation error).
**Correct example**: 16-question bundle → 4 batches × 4 questions → 4 sequential `AskUserQuestion` calls (or 4 batches across 4 turns) + file audit trail with all 16.
**Severity**: low (workflow detail, not correctness)
**Auto-detect**: yes — drift-detector greps for `AskUserQuestion` calls with >4 questions in tool-input (will already fail at runtime; this is belt-and-suspenders).

### 2026-04-29 (UP-05): `--dangerously-skip-permissions` Has Hard-Limit Exceptions (Anthropic-Designed)
**Context**: User reported autonomous loop breaks when `--dangerously-skip-permissions` flag is set but Claude Code still prompts on certain operations. Research via `claude-code-guide` confirmed.
**Rule**: `--dangerously-skip-permissions` (alias `bypassPermissions` mode) does NOT bypass: (a) writes to `.git/.husky/.vscode/.idea/.claude/` (except `commands/agents/skills` subdirs), (b) writes to `.gitconfig/.bashrc/.zshrc/.mcp.json/.claude.json`, (c) `Skill` tool execution (always prompts), (d) PreToolUse hooks returning `deny` (exit code 2). Hook `{decision: approve}` does NOT override permission system. These are Anthropic-designed limits and CANNOT be bypassed.
**Anti-example**: Designing autonomous loop that calls `Skill` tool every N steps; loop will pause indefinitely waiting for approval.
**Correct example**: For autonomous mode, replace `Skill` calls with inline procedures (read SKILL.md content + execute manually) OR gate skill calls to SUPERVISED mode (per UP-05 Q2.1 default policy). Batch any `.git/.claude/` settings changes for end-of-session manual sign-off.
**Severity**: high (autonomous mode breaker if not respected)
**Auto-detect**: partial — drift-detector can grep autonomous-mode session for `Skill(` invocations or writes to protected paths; flag.

### 2026-04-29 (UP-04): AskUserQuestion is PRIMARY Q&A Channel (per B1 charter-tier confirmation)
**Context**: User in `human-workspace/user_prompt/20260429_04.txt` explicitly criticized file-based Q&A (S2 design): "phải hiển thị ra giao diện q&a do claude code built in cung cấp để human thực sự đọc và verify... hiện tại nhiều q&a và quick answer làm agent bị over và thường có xu hướng chọn default suggest thay vì tự đưa ra decision". Charter-tier B1 answered "A: AskUserQuestion ALL bundles, file = audit only" via AskUserQuestion 2026-04-29T14:05Z.
**Rule**: The Claude Code built-in `AskUserQuestion` tool is the PRIMARY input surface for ALL Q&A bundles. File-based bundle in `human-workspace/q-and-a/pending/<file>.md` becomes audit-trail-only. Every bundle MUST surface its 1-4 most-critical questions via `AskUserQuestion`; bundles >4 questions split into batches. Charter-tier questions ALWAYS via `AskUserQuestion` (never file-only-with-default-acceptance).
**Anti-example**: Writing a 16-question bundle to `human-workspace/q-and-a/pending/` and waiting for human to file-edit. Encourages default-pick shortcut; agent over-defers; sync rate drops.
**Correct example**: Write 16-question file (audit trail) AND fire `AskUserQuestion` with top-4 critical questions in same turn. Update bundle frontmatter `answered:` array as user picks. Remaining 12 questions follow-up via second `AskUserQuestion` batch or async file-edit if user defers.
**Severity**: high (encoded in `qa-escalation/SKILL.md § Channel Routing` as BINDING)
**Auto-detect**: yes — drift-detector greps for `Write(human-workspace/q-and-a/pending/**)` calls without accompanying `AskUserQuestion` tool use in the same session log; flag if missing.

### 2026-04-29 (S3 — Track 5 Loop-Resilience Port): grep -c with || fallback double-counts zero
**Context**: While testing `scripts/hooks/drift-signals-D1-D8.sh` D3 (charter-mixed bundle detection), bash error fired: `[: 0\n0: integer expression expected`. Root cause: `VAR=$(grep -cE 'pattern' "$f" 2>/dev/null || echo 0)` — when grep finds zero matches, grep -c PRINTS "0" AND exits 1, so `|| echo 0` ALSO fires, appending another "0". Variable becomes "0\n0", failing integer comparison.
**Rule**: For `grep -c` capture in bash: do NOT use `|| echo N` fallback (grep already prints 0 on zero matches). Use `|| true` to swallow exit code, then validate with `[[ "$VAR" =~ ^[0-9]+$ ]] || VAR=0` for safety. Same pattern applies to `wc -l`, `awk count`, etc. — any tool that prints numeric output AND exits non-zero on no-match.
**Anti-example**: `COUNT=$(grep -cE 'pattern' "$f" 2>/dev/null || echo 0)` — captures "0\n0" on zero matches.
**Correct example**: `COUNT=$(grep -cE 'pattern' "$f" 2>/dev/null || true); [[ "$COUNT" =~ ^[0-9]+$ ]] || COUNT=0`.
**Severity**: low (caught by smoke test; doesn't escape to production)
**Auto-detect**: yes — Track 9 hook-diagnostics skill can grep hook scripts for `grep -c.*\|\| echo` pattern.

### 2026-04-29 (S7 — UP-07 follow-up): Stale-Prompt Reference Check Before Acting
**Context**: Post-/clear in S7 SessionStart, user submitted "continue UP-07 work — check if claude-code-guide research returned + synthesize options + fire AskUserQuestion" referencing work CLOSED in S6 via D-004. Agent had no deterministic detection; was forced to fire clarifying AskUserQuestion, blocking autonomous flow. Full RCA in `agent-workspace/memory/mistake-log.md § M-S7-1`.
**Rule**: When user prompt references `UP-[0-9]+`, `D-[0-9]+`, `Track [0-9]+(\.[0-9a-z]+)?`, or `S[0-9]+`, the `stale-prompt-detector.sh` UserPromptSubmit hook cross-checks `up-intake-log.md` + `decisions/*.md` + `current-execution.md`. If hook emits "STALE-PROMPT DETECTOR" warning in additionalContext: agent MUST first surface closure status (1-2 sentences citing linked decision/session) before any action. Only re-do work if user explicitly picks "redo" via AskUserQuestion or unambiguous text. Per UP-06 NO-Silent-Default + this RCA.
**Anti-example**: Receive "continue UP-07 work" post-/clear → silently dispatch claude-code-guide subagent again + duplicate the AskUserQuestion sequence + re-ship D-004 (waste 30-50K tokens; risk superseding ACCEPTED decision without rationale).
**Correct example**: Receive same prompt → hook injects warning "UP-07 CLOSED via D-004" → agent surfaces "UP-07 đã closed at S6 via D-004 (180K/220K/250K threshold band ACCEPTED). Bạn muốn (a) confirm + move to S7, (b) revisit with new research, (c) other?" via AskUserQuestion → proceed per pick.
**Severity**: high (in autonomous mode this would block infinite loop, since no human to clarify; deterministic hook detection is the only viable Guardian per AP-23).
**Auto-detect**: yes — `scripts/hooks/stale-prompt-detector.sh` is the auto-detector itself. Drift signal: ANY UserPromptSubmit to a prompt matching the regex without invoking this hook = drift.

### 2026-04-29 (S7 — UP-07 follow-up): Continue-Injector Gated by autonomous_mode [SUPERSEDED by S8 entry below]
**Context**: `scripts/hooks/continue-injector.ps1` SendKeys "continue" + Enter to fresh TUI on every SessionStart (verified 3 log files same day). Designed for autonomous mode (no human → injector starts loop). But ungated firing in SUPERVISED mode caused race conditions with user typing + re-triggered work-already-done flows.
**Rule**: `session-start-bootstrap.sh` MUST grep `autonomous_mode` field from `agent-workspace/memory/current-execution.md` BEFORE spawning continue-injector. Spawn ONLY if `autonomous_mode=true`. In SUPERVISED mode (default until Track 7), log "SKIPPED continue-injector" and exit.
**Anti-example**: Hook unconditionally spawns injector → user types "continue UP-07 work..." simultaneously with injector typing "continue" → race condition: which prompt reaches LLM first? Both submitted? Confused state.
**Correct example**: Hook reads autonomous_mode → false (current) → skip spawn. User types prompt at their pace. Logged: `SessionStart-bootstrap SKIPPED continue-injector (autonomous_mode=false)`.
**Severity**: medium (race condition rarely produces wrong outcome but creates user confusion + adds non-deterministic noise).
**Auto-detect**: yes — drift-detector greps session-start-bootstrap.sh for unconditional `Start-Process.*continue-injector` without preceding `autonomous_mode` check.
**Superseded-by**: 2026-04-29 (S8 mid-session) entry below — source-specific gating chosen over blanket gate.

### 2026-04-29 (S8 mid-session — user complaint "no continue, why? fix"): Source-Specific Continue-Injector Gating
**Context**: S7 blanket gate (autonomous_mode=true required) made `/clear` UX broken — user `/clear`-ed at 17:51:55, expected checkpoint resume; injector skipped at 17:51:57; user manually typed at 18:18:59 (27-min wait). Race-condition concern from S7 was about `startup` (claude first-run, user likely typing) — does NOT apply to `/clear` (explicit user action with predictable ~5s window) or `resume` (user just invoked `claude --resume`, expects continuation).
**Rule**: `session-start-bootstrap.sh` source-specific gating:
- `source=clear` → fire continue-injector UNCONDITIONALLY (low race risk; user just cleared and expects auto-resume from checkpoints/latest.md)
- `source=resume` → fire continue-injector UNCONDITIONALLY (user invoked claude --resume; expects continuation)
- `source=startup` → fire ONLY if `autonomous_mode=true` (preserve S7 race-fix; user opening fresh claude likely has prompt in mind)
**Why safe in SUPERVISED**: stale-prompt-detector.sh line 26 short-circuits on bare "continue" prompt (regex `^[[:space:]]*(continue|ok|yes|y|n|no|done)[[:space:]]*$`) → no spurious stale-warning. Agent reads SessionStart additionalContext + checkpoint to determine next action; "continue" is just the wake-up trigger.
**Anti-example**: Hook gates ALL sources behind autonomous_mode → user `/clear`-s mid-session expecting checkpoint resume → silent 27-min hang waiting for user to manually re-prompt → autonomous flow effectively broken in supervised mode.
**Correct example**: Hook reads source=clear → spawn injector unconditionally → fresh TUI receives "continue" 2.5s after /clear → agent reads checkpoint + queued-grill-master + current-execution.md → resumes at next_action. Logged: `SessionStart-bootstrap spawned continue-injector (source=clear (explicit user action))`.
**Severity**: high (UX-blocking; user explicitly complained — broken auto-resume = broken supervised-mode autonomy).
**Auto-detect**: yes — drift-detector greps session-start-bootstrap.sh for the `case "$SOURCE" in clear) ... ;;` block; absence = drift back to S7 blanket gate.

### 2026-04-29 (post-audit): Pre-Amendment Delta Summary Mandatory for Large REV-N
**Context**: REV-2 added 30+ amendments + budget delta 940K→1.3M tokens (+38%) — user "ok continue" approved both. The agent never explicitly surfaced "you are ratifying 30+ amendments and +38% budget" in headline form. UP-02 §1.3 warned: "human đối mặt hàng chục spec/document quá tải nếu không sắp xếp khoa học".
**Rule**: For any REV-N that adds ≥10 amendments OR increases budget by ≥25% OR adds tracks OR changes sequencing — author a "Delta Summary" block at the top of the Q&A bundle headline AND in the notification body. Make the magnitude visible before requesting approval.
**Anti-example**: REV-2 amendments tucked inside D-002 § Amendments, with budget increase noted on line 466.
**Correct example**: Q&A bundle headline starts with `## REV-N Delta Summary` block listing amendments_added / budget_delta / sequencing_delta / track_delta / what_user_commits_to / what_user_can_revert.
**Severity**: medium
**Auto-detect**: partial — drift-detector compares D-NNN status fields (REV-N) against presence of `Delta Summary` block in any related Q&A bundle.

### 2026-04-29 (S10 — Track 5.5d.1): Bash Hook ERR-Trap Silent Failure (set -uo pipefail + trap ERR + `[ x ] && Y`)
**Context**: `scripts/hooks/component-telemetry.sh` had been silently bricked since S8 ship. JSONL telemetry stream did not exist on disk despite hook being wired in `.claude/settings.json` for SessionStart/PostToolUse/SubagentStop. Discovered in S10 D-2 smoke test when the new `learning-data/events/*.ndjson` also didn't write. Root cause traced via `bash -x`: 3 patterns trip the `trap 'exit 0' ERR` trap when LHS is FALSE — `[ "$TOKENS_REAL" -lt 0 ] && TOKENS_REAL=0` (line 111), `([ x ] || [ y ]) && Z=0` (line 124), `[ "$PAYLOAD_DECISION" = "deny" ] && FAILURE_MODE='"H"'` (line 226). Plus `local session="$1" ts_file="...${session}"` (line 115) trips `set -u` because `session` is unbound at parse-time of `ts_file` in the same `local` declaration. Git Bash on Windows appears to fire ERR on `[ x ] && Y` even though Bash manual exempts conditional context — empirical not theoretical guidance.
**Rule**: Bash hook scripts running with `set -uo pipefail` + `trap 'exit 0' ERR` (or any non-noop ERR trap) MUST: (a) use `if [ x ]; then Y; fi` instead of `[ x ] && Y` when LHS may be FALSE; (b) split `local A=$1 B=$A` into separate `local` declarations to avoid same-line cross-references under `set -u`; (c) verify smoke-test produces ACTUAL file writes — not just "exit 0" return code, which the trap can fake.
**Anti-example**: `[ "$VAR" -lt 0 ] && VAR=0` (LHS often FALSE → ERR fires → silent exit 0 → script appears to succeed but does nothing). Same: `local a="$1" b="${MEMORY_DIR}/.x-${a}"` (b uses a before a is set; `set -u` fires).
**Correct example**: `if [ "$VAR" -lt 0 ]; then VAR=0; fi` and `local a="$1"; local b="${MEMORY_DIR}/.x-${a}"` (separate declarations).
**Severity**: HIGH (bricked telemetry stream for ~3-4 sessions undetected; "shipped S8" claim was vacuous).
**Auto-detect**: candidate for new drift signal D10 or extension to existing `loc-ceiling-check.sh`. Proposed scan: any `scripts/hooks/*.sh` with `trap '.*' ERR` + `set -.*u.*` AND containing pattern `\[ .* \] &&` (single-line conditional) OR `local \w+=.*\$\{?\w+\}?.*\w+=.*\$\1` (same-line cross-ref). Promote to deterministic check at S15 Track 7 if S11/S12 surfaces more occurrences.

### 2026-04-29 (S10 — Track 5.5d.1): Glob + Read + Bash File-Ops All Honor Boundary Deny — Triple-Enforcement
**Context**: After adding `Read(agent-workspace/learning-data/events/**)` to `.claude/settings.json` deny + gitignore'ing the same paths, agent attempted to verify file content via 3 paths and found ALL denied: (1) `Read` tool → "File is in a directory that is denied by your permission settings"; (2) `Bash(cat:*)` and `Bash(wc:*)` though in allow list → harness denies because path-deny rule intersects; (3) `Glob agent-workspace/learning-data/events/*` → "No files found" because Glob honors .gitignore. The boundary CANNOT be circumvented from main session without explicit permission removal.
**Rule**: For runtime-deny boundaries on write-heavy data stores: combine (1) `.gitignore` exclusion (free, makes Glob blind) + (2) `.claude/settings.json` Read/Write/Edit deny rules on path globs (cheap, blocks tool families) + (3) drift signal scanning code paths for boundary-leaking references (e.g., D9 in drift-signals-D1-D9.sh). Any one alone is partial; all three is hardest enforcement available short of OS-level isolation.
**Anti-example**: Add only deny rule without gitignore — agent can still Glob the file paths and see they exist (information leak about what's being collected). Add only gitignore without deny — agent can still Read directly via known path.
**Correct example**: D-005 § 5.5d.1 architecture: events/+archive/ have all three. index/+dogfood/+loop/ have none (read-allowed; tracked).
**Severity**: low (validation of design intent; not a bug fix — informational).
**Auto-detect**: yes — drift-detector can grep for paths under `agent-workspace/` that are write-only-by-design (e.g., events/) appearing in skill/agent/command files (D9-equivalent). Also: when adding new boundary, lint that all 3 layers are configured.

### 2026-04-29 (S10 — Track 5.5d.1): Append-Only Contract Allows Stale Filename References in History
**Context**: When renaming `drift-signals-D1-D8.sh` → `drift-signals-D1-D9.sh` per D-005 § 5.5d.1, found 26 callers across the project. 4 are LIVE (`.claude/settings.json` + `.claude/manifest.yaml` 3× + 2 attach skill files); 22 are in append-only history (`agent-workspace/memory/{sessions,checkpoints,decisions,observations,drift-logs}/` + `agent-workspace/raw-sessions/` + `human-workspace/{q-and-a,notifications}/`). Updating the 22 historical references would rewrite history and violate workspace dualism (D-002). Leaving them stale was the chosen approach.
**Rule**: When renaming script/file/symbol referenced from BOTH live config AND historical append-only artifacts: update LIVE callers only (settings.json, manifest, skills, agents, commands, scripts); leave historical references stale. Past sessions/checkpoints/decisions/notifications are time-frozen snapshots — accuracy is "what was true at session-N", not "what is true now". A grep audit (`Grep oldname .claude/ scripts/` returning 0) is the LIVE-clean signal.
**Anti-example**: Run `find . -name '*.md' | xargs sed -i 's/old-name/new-name/g'` — rewrites 22 historical files; obscures the rename event in git diff; future audits reading old session logs see modern filename and lose temporal context.
**Correct example**: Update only `.claude/`, `scripts/`, and other LIVE config; document the choice in session log + add 1-line cross-reference in renamed file's header (e.g., "renamed from D1-D8 in S10 per D-005 § 5.5d.1").
**Severity**: low (process discipline; not a bug).
**Auto-detect**: partial — drift-detector can grep `Grep oldname .claude/ scripts/` after rename commits; non-zero match = drift. Historical references in memory/, raw-sessions/, q-and-a/ are EXEMPT from this check.

### 2026-04-29 (S11 — Track 5.5d.2): Phase 0 Hook Portability — Bash + Node + POSIX Only
**Context**: Track 5.5d.2 index-rebuild hook needed RAG-style indexer. D-005 listed SQLite FTS5 as preferred Phase 0 choice in deliverables prose. Pre-flight `command -v sqlite3` returned not-found on Windows Git Bash (current dev environment for project owner). Continuing with sqlite3 would have produced a hook that silently no-ops on dev machine — same failure shape as L-S10-1 silent ERR-trap. Picked "simple bash + node-eval" branch from D-005 § Open Questions instead. Manifest = JSON via printf+node; sample dump = NDJSON copy via cat+tail; state marker = JSON via printf+node-eval read.
**Rule**: Phase 0 hooks running on bare dev machines MUST limit dependencies to: `bash` + `node` (project already requires for telemetry) + standard POSIX (`find`, `grep`, `wc`, `mv`, `rm`, `cat`, `stat`, `sort`, `tail`, `head`, `tr`, `sed`, `awk`, `mkdir`, `printf`, `date`). NOT permitted: `sqlite3`, `duckdb`, `jq`, `python3` (project uses but not at hook level), `curl`/`wget` (no network from hooks), language runtimes beyond node. When richer indexing/processing is needed, defer to Phase 1+ where deployment ships dependencies in a Docker image with verified `requirements.txt` / `package.json`.
**Anti-example**: `sqlite3 db.fts < index.sql` in hook script — works on Linux dev machines, silently fails on Win Git Bash → boundary-hook bricked invisibly.
**Correct example**: `find events/ -name '*.ndjson' | sort | xargs cat | tail -100 > index/recent-sample.ndjson` — bash + POSIX only; works everywhere bash runs.
**Severity**: medium (portability gates the bootstrap promise of "hook works on any dev machine").
**Auto-detect**: yes — extension to `loc-ceiling-check.sh` or new `bash-hook-lint.sh`: scan `scripts/hooks/*.sh` for non-whitelisted command invocations (sqlite3, duckdb, python3, jq, curl, wget); flag with severity HIGH if found in Phase 0 hook. Promote to constitutional rule at Track 7 (S15) — candidate `agent-workspace/constitution/financial-data-protocol.md` § Phase 0 portability.

### 2026-04-29 (S11 — Track 5.5d.2): Spec Internal Inconsistency Surfaces at IMPL Time → IMPL-Tier Resolves
**Context**: D-005 § 5.5d.1 deliverables prose: `agent-workspace/learning-data/{events,index,archive}/`. D-005 § 5.5d.2 deliverables prose: `agent-workspace/memory/learning-data/index/categories-<TS>.md` (note: `memory/` prefix). These two paths are inconsistent. S10 implementation chose §5.5d.1 layout; permissions in `.claude/settings.json` (`allow Write(agent-workspace/learning-data/{index,dogfood,loop}/**)`), README boundary contract, and `.gitkeep` files are all aligned with §5.5d.1. S11 IMPL faced choice: follow §5.5d.2 prose (split tree under memory/) or §5.5d.1 layout (single tree). Chose §5.5d.1 — alignment with downstream artifacts wins; §5.5d.2 prose treated as drafting bug. Documented as IMPL-S11-2 in session log + carry-over for D-005 amendment at S15 Track 7.
**Rule**: When IMPL agent finds spec internal inconsistency at execution time: (a) resolve in favor of the layout/wording that downstream artifacts (permissions, README, gitkeep, tests, existing implementations) are already aligned with — alignment cost is real, prose changes are cheap; (b) document the resolution as IMPL-tier decision in session log with explicit "IMPL-S<N>-<M>" identifier; (c) surface the inconsistency for spec amendment at next planning boundary via append-only carry-over note in checkpoint + current-execution.md; (d) DO NOT block ship to wait for ratification — the inconsistency is in source-of-record, not in implementation; agent's call is the right call until amended.
**Anti-example**: Halt S11 ship to ask user "which path layout?" when 5/6 downstream artifacts are already aligned with one — this re-raises a settled question and inflates cycle time. Or: silently follow the latest-written prose without surfacing the inconsistency — future readers can't audit which layout is canonical.
**Correct example**: IMPL-S11-2 in session-11.md + checkpoint/latest.md "Open carry-over for S15 Track 7" + current-execution.md S11 carry-over block — three linked notes ensure D-005 amendment is unmistakable next planning cycle.
**Severity**: medium (recurring spec-drafting risk; Spec-as-source butterfly = drift signal D4 territory).
**Auto-detect**: partial — drift-detector D4 already scans for spec ↔ code dangling refs. Extension: when same decision file references two paths for the "same artifact concept" within different sections, flag as INTERNAL-INCONSISTENCY. Promote to formal rule in `agent-workspace/constitution/decision-discipline.md` § "When spec inconsistency surfaces at IMPL time" at Track 7 (S15).

### 2026-04-29 (S12 / Track 5.5d.3 dogfood): Self-Learning / Outer-Loop Claims Require Deterministic Metric Function
**Context**: S12 dogfooded `stanfordnlp/dspy@db83e5ad` (research-scanner dispatch result, agent-pick-1 from D-005 § 5.5d.3). Pattern insight from DSPy: every self-improving pipeline's optimizer requires a `metric` function returning a score from deterministic code — the LLM does not score itself. Mapping that onto stockforge's harness surfaced a gap: S11's L-1 classification produced bucket distributions (`0/0/0/49/11`) but emitted **no metric** comparing run N+1 to run N. Without a metric, no version of the loop can be substantiated as "improved" over baseline. The Karpathy outer-loop framing artifact (S12 D5) cannot answer "was the experiment better than the prior baseline?" without one.
**Rule**: Any "self-learning", "Karpathy outer-loop", or "harness-improvement" claim authored in stockforge (now or future) MUST cite a deterministic metric function (Python or bash, no LLM judgment) with: (a) explicit formula, (b) baseline value with `n_samples` + `as_of`, (c) target threshold, (d) falsification condition. If no metric exists → describe the experiment ("we tried X"), do NOT claim improvement ("X improved Y"). Per charter P8 calibration-over-confidence + P9 no-LLM-math.
**Anti-example**: A Karpathy framing artifact that says "we deepened classification quality by adding fail-mode wire-in" without a metric to prove the deepening — the claim collapses to vibes; future agent reading it cannot replicate the verdict.
**Correct example**: `agent-workspace/learning-data/loop/20260429T131608Z-experiment-frame.md` § Measurement plan — declares `failure_mode_populated_rate = count(events.failure_mode!=null) / count(events)`; baseline 0.0% (n=60, S11); target ≥8.3%; falsification = "rate stays 0% AND log shows failures occurred". Deterministic, falsifiable, calibrated.
**Severity**: high (without this, every self-learning iteration becomes a vibes-based feedback loop — exact failure mode charter principle 8 was written to prevent).
**Auto-detect**: yes — Track 5.5d.2 `learning-index-rebuild.sh` can be extended (S13) to scan `learning-data/loop/*-experiment-frame.md` for missing `metric_function:` frontmatter field; soft-warn at Stop hook. Promotion target priority hook>skill>charter (cheapest first) per D-005 § 5.5d.3 promotion path.

### 2026-04-29 (S13-pre drift audit): `head -1` of Unscoped Grep Returns Wrong Element on Chained Lists
**Context**: `scripts/hooks/session-export-raw.sh` SessionEnd hook ran 11 times across S1-S12 but produced only 2 raw-session files (`session-1.md` + `session-5.md`). Other 10 sessions overwrote into one of the two. Drift audit S13-pre traced to line 33: `SESSION_N="$(grep -oE 'S[0-9]+' "$EXEC_FILE" | head -1 | sed 's/^S//')"`. The `**Session N**:` line in current-execution.md lists the FULL chain `S1 → S2 → ... → S<latest>`, so `head -1` always returned S1 — the FIRST element, not the active session. Result: 10/12 raw transcripts lost provenance (UP-05 directive about source-of-truth context violated for ~83% of sessions).
**Rule**: When extracting "current/active/latest" from a list-bearing data file: NEVER use `head -1` on unscoped grep over the entire file. Either (a) scope grep to a specific line/section, OR (b) use `sort -n | tail -1` to find the largest, OR (c) use an explicit marker like `S<N> NEXT`. The smoke test for "is this extracting the right element" is to run it against a chain like `S1 → S2 → S13 NEXT` and verify it returns S13 (or whatever current session indicator dictates).
**Anti-example**: `grep -oE 'S[0-9]+' "$EXEC_FILE" | head -1` when file contains chain "S1 → S2 → ... → S13 NEXT".
**Correct example**: `grep -oE 'S[0-9]+[[:space:]]+NEXT' "$EXEC_FILE" | head -1 | grep -oE '[0-9]+'` (uses explicit NEXT marker) OR `grep -E '^\*\*Session N\*\*:' "$EXEC_FILE" | grep -oE 'S[0-9]+' | sed 's/^S//' | sort -n | tail -1` (scoped grep + numerical sort). Both return 13 for the chain above.
**Severity**: high (provenance loss; UP-05 directive violation; pattern can recur in any "latest item" extraction in hooks).
**Auto-detect**: yes — bash-hook-lint can scan `scripts/hooks/*.sh` for pattern `grep -oE '[A-Z][0-9]+' .* | head -1` (or similar list-extracting greps with head -1) → flag for review. Promote to constitution at S15 Track 7 paired with L-S11-1 Phase 0 portability rule.

### 2026-04-29 (S13 / Track 5.5c.3 wire-in): Producer-Consumer Log Path Mismatch Silently Nulled Telemetry Field
**Context**: `scripts/hooks/component-telemetry.sh` `correlate_failure_mode()` was reading `$MEMORY_DIR/.autonomous-stop-watchdog.log` since S8 ship. NO hook ever wrote that path. Real signals lived at `.session-hooks.log` (CLIFF + drift entries) and `.autonomous-premature-windown-alert.log` (mode-C alerts). Result: all 60 events at S11 L-1 had `failure_mode: null`. Misclassified as "harness too clean to instrument" in S11 caveat #2; actually was producer-consumer disconnect. Discovered S13 by tracing watchdog writers (`grep -r '.autonomous-stop-watchdog.log' scripts/` → 0 producers; `grep -r '.session-hooks.log' scripts/` → multiple producers).
**Rule**: When a hook claims to "correlate" between two logs (one writing, one reading), smoke-test the producer-consumer path: (a) `grep -r '<log-path>'` returns ≥1 producer AND ≥1 consumer; (b) feed a synthetic event through the consumer and verify the field populates. If either gate fails → wire-in is vacuous; the field will silently stay at default forever. Pairs with L-S10-1 (silent ERR-trap brick) — both are "schema appears wired but path/control flow doesn't actually populate" failure shapes.
**Anti-example**: Author `correlate_failure_mode()` reading `WATCHDOG_LOG="$MEMORY_DIR/.autonomous-stop-watchdog.log"` without verifying any sibling hook writes that path. Six months later, classifier reads 60 events of null and concludes harness is failure-free.
**Correct example**: S13 fix — point reader at logs with verified producers (`HOOKS_LOG="$MEMORY_DIR/.session-hooks.log"` written by 4+ hooks; `MODE_C_LOG="$MEMORY_DIR/.autonomous-premature-windown-alert.log"` written by `budget-watchdog.sh`) AND smoke-test 3 cases (error → "B", deny → "H", ok → null) before declaring wire-in complete.
**Severity**: high (same severity class as L-S10-1; bricked instrumentation undetected for 4 sessions; first measurable Karpathy loop iteration was structurally impossible until fix).
**Auto-detect**: yes — extension to `bash-hook-lint.sh` (S15 candidate): scan `scripts/hooks/*.sh` for `LOG_VAR="..."` assignments where the path doesn't match any `>>` or `> "$LOG_VAR"` redirect in the same scripts directory. Promote to constitutional rule at Track 7 paired with L-S11-1 portability.

### 2026-04-29 (S14 mid-session — user "why not autonomous continue?"): autonomous_mode=false Was Single Hard Gate; Mode-D Clean-Handoff Recovery Was Missing
**Context**: At S14 close (after writing checkpoint), user asked "why not autonomous continue? find why and note, fix". Investigation traced 3 enforcement points all gating on `autonomous_mode: false` in `agent-workspace/memory/current-execution.md` line 14:
1. `scripts/hooks/autonomous-stop-watchdog.sh` line 18: `if ! grep -qE '^\*\*autonomous_mode\*\*:\s*true' "$EXEC_FILE" 2>/dev/null; then exit 0; fi` — Stop hook silently exits without detection or recovery when flag is false.
2. `scripts/hooks/session-start-bootstrap.sh` line 135: continue-injector spawn gated on `autonomous_mode=true` for `source=startup`. (`source=clear` and `source=resume` ALWAYS fire injector; `source=startup` only fires when flag is true — so a fresh terminal-launch with flag=false sits silent).
3. `agent-workspace/memory/current-execution.md` itself — the source-of-truth that #1 and #2 both grep against.
**Second finding**: even with flag=true, the existing watchdog only triggers recovery on Mode B (API error) or Mode C (premature wind-down). **There is no "Mode D = clean handoff after writing checkpoint" detection** — so a session that ends gracefully (writes checkpoint, hits Stop, no error, no premature language) gets ZERO automatic continuation. User must manually `/clear` (which fires SessionStart-on-clear → injector unconditionally per L-S8) or type a prompt. That defeats "continue automatically after each session" expectation.
**Rule**: Autonomous continuation requires BOTH (a) `autonomous_mode: true` in current-execution.md AND (b) a recovery-trigger that matches the actual session-end condition. Failure-mode-only recovery (Mode A/B/C) does NOT cover graceful handoff. Mode-D detection is required: latest checkpoint mtime within last 60s + no other recovery already fired this Stop. Recovery dispatch by token level — tokens >= cliff (220K) → `session-self-reboot.sh` (full reboot for fresh envelope); tokens < cliff → `continue-injector.ps1` (just nudge "continue" to current TUI). Pairs Mode-D with existing Mode B/C reboot-vs-injector logic.
**Anti-example**: Setting `autonomous_mode: true` alone, expecting auto-continue after clean session. Stop watchdog runs detection but no Mode A/B/C suspected → script exits without firing recovery → silent loop break at every clean session end.
**Correct example** (S14 fix): (1) Flip `autonomous_mode: true` in `current-execution.md` (early activation per user authorization, ahead of Track 7 ratification). (2) Extend `autonomous-stop-watchdog.sh` with Mode-D detection block after Mode-C: `if no A/B/C suspected AND checkpoint mtime ≤ 60s AND idempotency marker not set → recovery dispatch (reboot if tokens ≥ cliff, injector otherwise)`. (3) Smoke test BOTH branches — high-tokens=371K → `reboot-handoff`; low-tokens=100K → `injector-handoff`. Both correct.
**Severity**: high (autonomous loop silently broken at every clean session boundary; user explicitly noticed; same drift class as L-S10-1 silent ERR-trap and L-S13-1 producer-consumer log mismatch — schema appears wired but trigger condition is missing).
**Auto-detect**: yes — drift-detector candidate: scan `scripts/hooks/*.sh` Stop hooks for "autonomous_mode" gate without any complementary "checkpoint just written" detection clause; flag if asymmetric. Promote to `bash-hook-lint.sh` extension at S15 Track 7 alongside L-S11-1 portability + L-S13-1 producer-consumer mismatch.
**Promotion candidate**: amend `agent-workspace/constitution/autonomous-protocol.md` (Track 7 deliverable) to codify Mode A/B/C/D coverage; possibly amend `session-budgets.md` to document cliff=220K → reboot vs <cliff → injector dispatch policy.

### 2026-04-29 (S14 / Track 6 REWRITE): Progressive-Disclosure Refactor First-Draft Trends 150–180 LOC; Budget Compression Reserve
**Context**: S14 refactored 8 D1 violators (postgres-pgvector / ddd-tactical-patterns / test-pyramid-balance / prompt-engineering / spec-dual-layer / obsidian-vault / devils-advocate command / spec-to-wiki command). For 6/8 the first-draft SKILL.md hit ≤150 cleanly. For 2/8 (prompt-engineering 176 / spec-dual-layer 163) the first-draft overshot. Both required a second compression pass (drop a duplicate example block, collapse a long table, tighten "Anti-Patterns"). Caught inline by `wc -l` per AP-S2-3, not at Stop hook.
**Rule**: When extracting from a 200–280 LOC content-heavy SKILL into SKILL.md + `references/<topic>.md`, plan SKILL.md at **≤140 LOC target** (10 LOC under ceiling) with verbatim templates absorbed by references (which informally target ≤300 LOC). The natural floor of "Purpose + When-to-Use + Decision Rules + Validation + Anti-Patterns + Smoke + See-Also" is ~110 LOC; first-draft slips to 160–180 if you keep an example block in SKILL.md instead of moving to references. **Verify with `wc -l` after every Write; recompress on overshoot before considering the refactor done.**
**Anti-example**: First-draft prompt-engineering at 176 LOC because the system-prompt template (15 LOC) was kept inline alongside the wrong/correct math example. Both belonged in references.
**Correct example**: Final prompt-engineering at 138 LOC; only 1 wrong/correct example pair stays inline (the load-bearing one for No-LLM-Math); full template + caching code + Pydantic DTO live in `references/prompt-templates.md`.
**Severity**: medium (ceiling-creep risk; would be caught at Stop hook anyway; costs 1 extra Edit pass per overshoot).
**Auto-detect**: yes — drift-signals D1 (already exists). No new hook needed.
**Promotion candidate**: amend `write-a-skill/SKILL.md` § Best practices, OR new section in `try-n-approaches/SKILL.md` body; defer to Track 7 (S15) per L-S* batch promotion.

### 2026-04-29 (S14 / Track 6 REWRITE): Skill-vs-Command Duplication Is a Refactor Multiplier
**Context**: At S14 the `.claude/commands/spec-to-wiki.md` (233 LOC violator) and `.claude/skills/spec-to-wiki/SKILL.md` (227 LOC, separate violator) had ~80% content overlap. Refactoring the command to a thin invoker (92 LOC, see-also pointing at the skill) was the cheap pass. The skill stayed unhandled this session (1 violation carried over) because bundling them would have over-shot S14 budget AND risked half-finished work. Same shape may apply to other skill+command pairs (e.g., possible candidates: `drift-check`, `master-plan`, `spec-author` — to be verified at S15).
**Rule**: When a `.claude/commands/<name>.md` and `.claude/skills/<name>/SKILL.md` exist for the same procedure, the duplication is structural. **The command should be a thin invoker (≤120 LOC: when-to-use + input + 1-line steps + see-also pointing to skill). The skill holds the load-bearing procedure (≤150 LOC main + references for verbatim templates).** Refactor the command first (cheap; the skill already holds the detail). Defer the skill refactor as a separate task — don't bundle if scope-tight; cleaner to leave 1 D1 violation than ship half-finished work that confuses future readers.
**Anti-example**: At S14 attempted to bundle command+skill spec-to-wiki refactors into one IMPL pass. Estimated overshoot of MULTI_TASK_IMPL ~150K target by ~20K. Aborted bundle; refactored command only; skill became carry-over.
**Correct example**: S14 IMPL-S14-1 — refactor command to 92 LOC pointing at skill; document skill carry-over in checkpoint + current-execution + agent-notes (this entry); plan skill refactor as part of Track 6 secondary at S15+.
**Severity**: low (process discipline; not a bug; protects against half-finished refactor PRs).
**Auto-detect**: partial — drift-signals D1 catches both files as separate violations; no special signal for the duplication itself. Possible bash-hook-lint extension: scan for matching `<name>` in both `.claude/commands/` and `.claude/skills/<name>/`; emit info-level signal if both > 120 LOC.
**Promotion candidate**: amendment to `write-a-skill/SKILL.md` (skill vs command split), OR new clause in `agent-workspace/constitution/architecture.md` § Slash command vs skill responsibility split. Track 7 (S15).

### 2026-04-29 (S14 mid-session): Wildcard Permissions Land in settings.local.json; Charter Deny Rules Stay Binding
**Context**: User mid-session asked: "use wildcard * if possible to approve every permission request for all path in this project". Naive read: edit `.claude/settings.json` to replace allow list with `Read/Edit/Write(**) + Bash(*)`. But team-wide `settings.json` has charter+constitution+learning-data deny rules that MUST stay enforced (PROJECT_CHARTER.md, agent-workspace/constitution/**, learning-data/{events,archive}, human-workspace/{user_prompt, decisions, q-and-a/answered, q-and-a/stale}). Replacing allow + accidentally dropping deny would breach charter immutability invariant.
**Rule**: User-requested loose permissions (e.g., "wildcard * for project") should write to `.claude/settings.local.json` (project-scoped, user-specific, **gitignored**) rather than the team-wide `.claude/settings.json`. Per Claude Code permission resolution, **deny rules from any source take precedence over allow rules from any source**. Therefore wildcard `Read/Edit/Write(**) + Bash(*)` in local settings does NOT bypass team-wide deny rules — it just stops prompting on the wide majority of routine paths. Use the `update-config` skill (which already encodes read-existing-merge-carefully + always-prefer-local-for-user-scope discipline).
**Anti-example**: Edit `.claude/settings.json` allow list to add `Edit(**) / Write(**)` — risks merging away deny rules accidentally; team members get unintended permissions on their next pull; charter immutability invariant breached.
**Correct example**: Create `.claude/settings.local.json` with minimal `permissions.allow: ["Read(**)", "Edit(**)", "Write(**)", "Bash(*)", "Glob(**)", "Grep(**)"]`. Verify `.gitignore` covers it (already at line 54). Validate JSON. Tell user `/hooks` reload OR session restart may be needed for settings file watcher caveat (per `update-config` skill).
**Severity**: medium (governance correctness; ensures charter immutability invariant survives loose-permissions request; charter scope drift is the most damaging drift type per AP-1).
**Auto-detect**: partial — `update-config` skill encodes the discipline; no automated check for "deny rules still cover charter paths after this change".
**Promotion candidate**: amend `update-config` skill's precondition checklist (add explicit "deny rules in main settings.json still cover charter+constitution+learning-data" verification step), OR amend `harness-bootstrap-permission-override` memory entry with the local-vs-main split. Track 7 (S15).

### 2026-04-29 (S13 / Track 5.5c.3): Cumulative-vs-Windowed Metric Distinction Matters at Wire-In Boundary
**Context**: S13 metric script `metric-failure-mode-rate.sh` defaults to CUMULATIVE rate over all events ever (321 at S13 mid-session; 2 with failure_mode → 0.62%). S12 Karpathy framing target was WINDOWED — `count(events.failure_mode != null) / count(events)` over "next 60-event corpus". The two interpretations differ: cumulative dilutes as denominator grows; windowed reflects current state. Pre-wire-in events (60 from S11) all have null because the field literally wasn't being populated; post-wire-in events will populate. Cumulative = 2/321 = 0.62% (well below 8.3% target); windowed last-60 = 2/60 ≈ 3.3% if just smoke tests, or higher with natural fires. Both are valid; report BOTH.
**Rule**: For instrumentation-wire-in metrics, the metric script MUST support BOTH cumulative AND windowed measurement (`--window N` flag). At wire-in boundary, the cumulative rate misleads (drowning by pre-wire-in null-event mass) and the windowed rate is the load-bearing comparable. Default behavior for S13 = cumulative (inclusive); follow-up addition = `--window N` for windowed last-N. Document this in script header so future agents don't conflate.
**Anti-example**: Report only cumulative (0.62%) and conclude DEEPEN failed because rate < 8.3%. Misses that the wire-in JUST happened mid-session; pre-wire-in events bias the cumulative.
**Correct example**: Run metric in both modes; report `cumulative=2/321=0.62% / windowed-last-60=X/60=Y%` so the comparison vs S11 baseline (0/60=0%) is apples-to-apples. Document in session log + carry-over flag for next L-1 dispatch.
**Severity**: medium (interpretation drift, not implementation bug).
**Auto-detect**: partial — drift-detector can scan metric script invocations in session logs for missing `--window` flag when comparing to a prior baseline that was windowed. Promote to skill best-practice at Track 6 REWRITE (S14).

### 2026-04-29 (S13-pre drift audit): Sessions MUST Update `project.md` at End-of-Session Per CLAUDE.md Protocol
**Context**: CLAUDE.md § Session End says: "1. Update agent-workspace/memory/project.md (if architectural decisions made)". Drift audit S13-pre found project.md was last updated 2026-04-23 — stale by 12 sessions and 5 ACCEPTED decisions (D-001 through D-005). The "10 tracks total / 7-8 sessions / 700-1200K tokens" statement was REV-1 estimate; reality is 14 sub-tracks / 19 sessions / ~2.44M tokens. Recent Architectural Decisions section listed 0 of D-001..D-005. Active TODOs were Day 1 checklist items (Phase 1 future), not Phase 0 active work. Per agent-workspace/CLAUDE.md Reading Priority, project.md is #2 (after current-execution.md) — every agent at SessionStart was reading STALE state.
**Rule**: SessionEnd protocol's "Update project.md" applies whenever (a) phase boundaries cross, (b) a NEW decision is ACCEPTED, (c) Recent Architectural Decisions list needs newest decision rotated in, OR (d) Active TODOs change. Skipping leads to compounding drift: future agents have wrong mental model. Add to mistake-log first time it happens; hook-detect on second occurrence.
**Anti-example**: Ship D-005 + 3 sessions (S10/S11/S12) of execution; never touch project.md; future SessionStart agents read "10 tracks / 7-8 sessions" while reality is "14 sub-tracks / 19 sessions". Sync drift between agents who read project.md vs current-execution.md.
**Correct example**: At SessionEnd of S<N>, if any of (a)/(b)/(c)/(d) holds, update project.md inline before checkpoint write. Ideally automated via Stop hook diffing project.md against current-execution.md, but manual until hook lands.
**Severity**: medium (mental-model drift, not execution drift; caught by drift audit; no IMPL artifact poisoned).
**Auto-detect**: yes — Stop hook can diff `project.md` Phase Goals Tracker section against `current-execution.md` Active Focus Track + Track Status; flag if mismatch on track count or session N. Promote to scripts/hooks/project-md-staleness-check.sh at S15 Track 7.


**Context**: S12 first dispatch of `.claude/agents/research-scanner.md` produced a 5-page survey of 6 candidate repos in ~213s wall-clock + 53K tokens (sonnet, run_in_background=true). Output structured per agent-file template: per-candidate findings with verbatim README quotes + commit SHAs + as-of dates; scoring matrix (5×6, scores cite source); adversarial bear case (4 distinct points); provenance log (18 URL+SHA+as-of rows). Critically, the adversarial scan caught `openai/swarm` is dead since 2025-03 (>400 days, README explicitly redirects to OpenAI Agents SDK) — a candidate that "minimal orchestration" framing might have led an unreviewed pick to choose. Scan was the only thing standing between "shallow seed-list pick" and "informed adversarial selection".
**Rule**: Every research-scanner dispatch MUST produce: (a) provenance log with repo URL + commit SHA-7 + as-of date for every cited fact; (b) license field per candidate (skip-fast disqualifies AGPL/proprietary if use case is permissive-only); (c) scoring on stockforge-specific axes with each score citing a verbatim README/commit quote (no "feel" scoring); (d) ≥3-distinct-point adversarial bear case for the picked candidate (maintenance staleness / license / integration cost / frontier-model substitution); (e) ≥1 disqualifier surfaced for at least one rejected candidate (signal: scan was adversarial, not just confirming). If <3 bear points emerge → assume scan was shallow; lengthen Phase 3-4 fact-gathering, do not ship the report.
**Anti-example**: A 1-page summary "DSPy looks great, license MIT, recent commits" with no SHAs, no quotes, no adversarial section — invoker cannot audit the pick; six months later when DSPy lab graduates and the repo stalls, no one remembers why it was picked over runner-up.
**Correct example**: `agent-workspace/learning-data/dogfood/agent-pick-1-research-report-20260429T131201Z.md` — 18-row provenance log, scores cite README lines, 4 bear points (frontier substitution / abstraction mismatch / Stanford research governance / LLM-as-judge in MIPRO), `openai/swarm` disqualified with explicit ">400 days since substantive commit + README explicitly redirects" reason.
**Severity**: high (a research scan that's not adversarial is an echo chamber for the seed list; AP-1 same-agent-self-review applies — pick-without-bear-case is structurally unfalsifiable).
**Auto-detect**: yes — Stop hook can grep new `learning-data/dogfood/research-*.md` for required frontmatter (`picked:` + `as_of:`) + section headers (`## Adversarial Bear Case` + `## Provenance Log`); soft-warn if missing. Cheap enforcement; promotion target = Track 5.5d hook extension.

<!-- ===========================================================================
     RECOVERY GAP MARKER -- lines 315..454 of original agent-notes.md
     ===========================================================================
     The original agent-notes.md (~470 LOC, 48 dated entries) was destructively
     overwritten by the S45 sandwich-architect subagent (agent abee75e2518d36e62)
     on 2026-05-05 ~07:47 +07:00 via Write-instead-of-Edit. See L-S45-1 + L-S45-2
     entries appended below.

     RECOVERY SOURCES used (verifiable from cached LLM transcripts):
       * Lines 1..314 -- restored verbatim from
         31a5f363-a178-41f8-b688-67b1b4cb7e41.jsonl:L33 (largest cached Read of
         the original file; covers Phase 0 Track 5.5d era end)
       * Lines 455..470 -- restored verbatim from
         agent-abee75e2518d36e62.jsonl:L67 (S45 subagent partial Read at
         offset=455 BEFORE the destructive Write at L72/L84)

     RECOVERY GAP -- lines 315..454 (~140 lines / ~30K chars) NOT IN ANY
     CACHED TRANSCRIPT located 2026-05-05. Per Charter "every claim has source
     + as-of date" + no-fabrication rule, gap content is NOT reconstructed by
     inference. The following lesson IDs are KNOWN to have lived in this gap
     (cited in checkpoints/sessions/current-execution.md) but their FULL BODY
     TEXT is unrecoverable from cache:
       L-S15-1 (inline-document IMPL deviations doctrine)
       L-S17-1 (SQLite portability binding)
       L-S19-1 (deterministic Stop-hook aggregator)
       L-S20-1 (Bash permission-matcher pattern)
       L-S25-1 / L-S26-1 / L-S28-1 (Phase 1 lessons cluster)
       L-S30-1 (VBW pre-flight Glob-before-Read)
       L-S32-1 (empirical-probe-first; promoted to skill at S43e cont 3)
       L-S34-1 / L-S35-N cluster (Track C + META_LOOP_RECOVERY)
       L-S43b-1..10 cluster (harness-recovery + LLM substrate boundary patterns;
                              promoted to charter at S43f via D-026)
       L-S43c-N cluster (rule-application discipline; partially promoted)
       L-S43d-1 (sonnet timeout cascade @ concurrency>=5)
       L-S43d-2 ($0-marginal substrate revalidation)
       L-S43e-1 (VF-5 emptiness root-cause taxonomy: Path A substrate-not-bug)

     For forensic reconstruction of any specific lesson body, primary sources
     in priority order:
       (1) checkpoints/latest.md -- has narrative summaries citing each L-S*
       (2) memory/sessions/2026-05-0*-session-43*.md -- session logs of S43b..f
       (3) memory/observations/{vf5-calibration-S43e,promote-rule-S43c,
           defer-s43b-status-S43e,S43f-user-gate-bundle-closure}.md
       (4) memory/decisions/026-S43e-charter-promote-bundle-C1-C2.md
           -- D-026 ratifies BP-S43b-1/2/3 + KI-S43b-1/2/3 with full text
       (5) constitution/architecture.md sec "LLM Substrate Boundary"
           -- D-026 codifies what L-S43b cluster taught
       (6) constitution/decision-discipline.md sec Rule 4b
           -- D-026 codifies what L-S43b-7 / KI-S35-5 / BP-S35-1 taught

     DO NOT silently re-author lesson body text without citing the
     forensic source. If a lesson must be re-derived, mark it with
     "// RECONSTRUCTED 2026-05-05 from <source>" header.
     =========================================================================== -->

**Auto-detect**: yes (low cost) — `scripts/hooks/proposal-bundle-advisor.sh` SessionStart hook (shipped S43f same-turn; 36 LOC; wired in `.claude/settings.json` SessionStart chain after ghost-work-audit). Greps `agent-workspace/proposals/*.md` for YAML or inline-markdown status PROPOSAL/PROPOSED count ≥2 (excluding ACCEPTED/REJECTED/AMENDED/RATIFIED); emits stderr advisory "N charter-tier proposals currently pending. Consider bundled deny-lift cycle…". Smoke-tested green: detected drift-signals-amendment-DR-INTENT.md + provenance-protocol.md (count=2). Promotion priority per Q-E3: HOOK = ✅ DONE (this turn). Skill not warranted (no LLM judgment required for bundling decision once trigger fires). Charter not warranted (efficiency rule, not identity-shaping).
**Provenance**: `agent-workspace/memory/decisions/026-S43e-charter-promote-bundle-C1-C2.md` § "Why bundled"; Q-B2 anti-pattern carve-out (bundling CHARTER+sub-charter prohibited; bundling CHARTER+CHARTER permitted).
**Lesson candidate ID**: L-S43f-1.


### 2026-05-05 (S44 — user correction "không phải do llm, do harness, deterministic thiếu à"): Self-Pause Pattern Is A Deterministic Detector Gap, Not Just LLM Policy
**Context**: At S44 close I held with "Holding here. Stop hook + Mode-D handles the boundary" instead of executing the next-action listed in my own just-shipped master-plan (surface Q-P3-1..3 + dispatch sandwich-architect). Mode-D continue-injector.ps1 fired correctly per `.autonomous-stop-watchdog.log` (5 fires logged 06:47-07:02; mode=injector-handoff) but the deterministic mechanism only types "continue" to TUI — it cannot override LLM policy. Each "continue" injection produced another self-pause turn. User correction: "tại sao lại không autonomous continue? lỗi hệ thống à" → follow-up: "không phải do llm, do harness, deterministic thiếu à" (not LLM, harness deterministic gap right?). User identified: existing autonomous-stop-watchdog.sh narration_hit detector catches "I will dispatch X" without dispatching, but does NOT catch "Holding here / next session's job / fresh context picks up / Stop hook handles" self-pause language. Pattern was therefore invisible to deterministic surveillance.
**Rule**: Self-pause language in autonomous-full mode (specifically: "Holding here", "S{N+1} entry is the next session's job", "fresh (context|session) picks up", "session boundary", "Stop hook handles", "wait for fresh session") is a Mode-E failure mode distinct from narration_hit (Mode-A). Detector MUST scan last assistant text for these phrases when autonomous_mode=true; emit alert to `.autonomous-self-pause-alert.log` with session_id + tokens; Mode-D continue-injector still fires normally (orthogonal — types "continue") but the alert makes the pattern deterministically visible so future occurrences cannot hide.
**Anti-example (S44 origin)**: 5 successive Stop-hook fires logged Mode-D firing continue-injector → user had to type "continue" themselves AND issue verbal correction because the self-pause loop produced no progress. User correctly diagnosed this as harness/deterministic gap (detector missing), NOT LLM willpower failure.
**Correct example**: Same session-end with checkpoint mtime fresh + Mode-D fires + detector scans assistant text → finds "Holding here" → emits Mode-E alert + (future iteration) injects stronger override prompt to TUI ("PROCEED with checkpoint NEXT-ACTION; do not pause"). LLM-side memory `~/memory/autonomous_continue_no_self_pause.md` ALSO updated this turn for LLM-side policy (defense-in-depth).
**Severity**: HIGH (root cause of full-autonomous loop dying; user-visible; required user correction to recover).
**Auto-detect**: ✅ DONE this turn — extended `scripts/hooks/autonomous-stop-watchdog.sh` § 3 with SELF_PAUSE_HIT pattern + § 4b alert log (`.autonomous-self-pause-alert.log`). Future Mode-E hits emit structured warning. Hook tier promotion: ✅ DONE; skill not warranted (deterministic regex check); charter pending IF ≥3 violations recur Phase 3 (would warrant Rule 4c "no self-pause in autonomous-full mode").
**Provenance**: user verbatim correction (saved in `~/memory/autonomous_continue_no_self_pause.md`); `.autonomous-stop-watchdog.log` 5-fire history confirming Mode-D was firing while LLM self-paused; `scripts/hooks/autonomous-stop-watchdog.sh:51-66` (extended detector); `scripts/hooks/autonomous-stop-watchdog.sh:91-99` (Mode-E alert path). Companion lesson L-S43f-2 (subagent stream-window stall — different failure mode but same family of "deterministic mechanism missing visibility on a known LLM failure pattern").
**Lesson candidate ID**: L-S44-1.

### 2026-05-05 (S45 -- sandwich-architect data-loss incident): Pre-Staged Sequential Files Require VBW Read-Before-Write

**Context**: At S45 entry both target artifacts (`008-S45-track-G-H-I-impl-sub-plan.md` + `027-S45-BC-6-architecture-influence-network.md`) already existed on-disk pre-staged from a prior dispatch attempt at the same turn (sibling subagent `aa04f00730b40eb55` returned earlier with the same file targets). Initial Glob check on `008-*` returned "No files found" (PowerShell glob mismatch on stem-only pattern); a more specific path probe revealed both files present with comprehensive content already satisfying brief intent. The S45 sandwich-architect then attempted to author L-S45-1 by calling `Write` on `agent-workspace/memory/agent-notes.md` instead of `Edit` -- destructively overwrote ~470 LOC of accumulated learned rules with a ~40 LOC stub.
**Rule**: Before authoring any new sequential ADR (`memory/decisions/NNN-*.md`) or session plan (`session-plans/pending/NNN-*.md`), VBW pre-flight MUST: (1) Glob the exact target slug AND nearby numeric range with multiple patterns; (2) if file exists, Read existing content first; (3) compare to brief intent -- if existing satisfies, leave unchanged + bind via reference; if differs in non-trivial way, supersede with N+1 entry per Contract Rule #2 (sequential numbering never reused; append-mostly + supersession-status); NEVER silently overwrite.
**Why**: Pre-staged duplicate dispatches happen when an autonomous loop dispatches the same architect twice (parallel `continue` triggers, race conditions, or operator-replay). Without VBW the second dispatch destroys the first's output.
**How to apply**: SessionStart hook should scan `agent-workspace/{memory/decisions,session-plans/pending}/` for files created within last 24h matching active-session-id; warn agent of pre-staged artifacts before authoring.
**Anti-example**: Glob `008-*` returns empty -> assume absent -> attempt Write -> safety blocker fires -> re-read reveals 430-LOC pre-existing file. Wasted tool calls + near-miss data loss.
**Correct example**: Glob `008-*` AND `00[0-9]-S45*` AND specific filename path -> Read any hit -> compare to brief intent -> bind-by-reference if sufficient. Document inline as IMPL deviation per L-S15-1.
**Severity**: HIGH (data-loss adjacent; this turn the incident propagated to L-S45-2 which IS data-loss).
**Auto-detect**: PARTIAL -- Read-before-Write enforcement already present as tool-level safety. Add complementary detector: SessionStart hook scanning `agent-workspace/{memory/decisions,session-plans/pending}/` for files created within last 24h matching active-session-id; warn agent of pre-staged artifacts before authoring.
**Provenance**: S45 sandwich-architect dispatch 2026-05-05; existing `agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md` (153 LOC) + `agent-workspace/session-plans/pending/008-S45-track-G-H-I-impl-sub-plan.md` (430 LOC) discovered already-on-disk during VBW phase.
**Lesson candidate ID**: L-S45-1.

### 2026-05-05 (S45 -- sandwich-architect data-loss incident -- ROOT CAUSE): Use Edit Not Write For Append-Only Files

**Context**: Same incident as L-S45-1. The destructive moment was when the subagent -- having decided to add an L-S45-1 lesson per just-ratified Rule 4b -- called `Write(file_path=agent-notes.md, content=<just the new entry>)` instead of `Edit(file_path=agent-notes.md, old_string=<anchor>, new_string=<anchor>+<new entry>)`. `Write` overwrites the entire file; `Edit` performs surgical insertion. The tool-level Read-before-Write safety blocker DOES NOT FIRE if the file was Read earlier in the session (subagent had Read lines 1-40 + offset=455+ at L56/L66/L69 before L72/L84 Writes), so the Write was permitted. Result: ~470 LOC truncated to ~40 LOC. The repo has `git status` = "no commits yet" so `git checkout` recovery is impossible. Recovery achieved by extracting cached Read tool_results from CCS instance JSONL transcripts (verifiable provenance for lines 1..314 + 455..470; lines 315..454 LOST per recovery gap marker above).
**Rule**: For ANY file under `agent-workspace/memory/{agent-notes,project,decisions,observations,sessions,checkpoints,patterns-discovered,drift-logs,post-mortems,thesis-log,sync-tracker,self-awareness,mistake-log}.md` AND `agent-workspace/{constitution,session-plans,quality-reports,ubiquitous-language,calibration,research}/**/*.md`: append/insert via `Edit` ONLY. `Write` is reserved for genuinely new files (existence-check via Glob first). NEVER use `Write` on an existing append-mostly file even when "just adding one entry".
**Why**: `Write` semantics overwrite; `Edit` semantics surgical-replace. The Read-before-Write safety only blocks first-write of unread file; it does NOT prevent loss when the agent has read PARTIAL ranges.
**How to apply**: Default tool choice for any markdown file under `agent-workspace/memory/` or `agent-workspace/constitution/` is `Edit` with `old_string`=last-known-trailing-anchor + `new_string`=anchor+`\n\n<new entry>`. Only use `Write` for first-creation (Glob returns empty).
**Anti-example (this turn)**: Subagent dispatched at 2026-05-05 07:40, by 07:47 had truncated agent-notes.md from ~470 LOC to ~40 LOC by calling `Write` with just-the-new-entry-content + a self-authored "RECOVERY NOTICE" assuming git-tracked rollback. Repo had no git commits. Recovery required forensic transcript-mining + accepted ~140-line gap.
**Correct example**: To add L-S45-1, subagent should have: (1) Read full agent-notes.md OR Read tail with explicit offset to capture last anchor; (2) `Edit(old_string=<verbatim last 200 chars>, new_string=<same>+\n\n<L-S45-1 entry>)`. No risk of overwrite.
**Severity**: CRITICAL (actual data loss; ~140 LOC of accumulated learned rules permanently unrecoverable from cache; project memory degraded).
**Auto-detect**: HOOK CANDIDATE -- SessionStart or PreToolUse hook on `Write` events targeting `agent-workspace/memory/agent-notes.md` OR any path matching `agent-workspace/memory/**/*.md`: HARD-BLOCK with stderr "Use Edit not Write on append-mostly files; see L-S45-2"; allow only if explicit override flag in tool input. Highest-priority promotion target -- this rule must be MECHANICAL not LLM-judgment.
**Provenance**: S45 sandwich-architect (`agent-abee75e2518d36e62`) tool-event chain L56->L57->L66->L67->L69->L70->L72(WRITE 1570 chars destructive)->L75->L76->L84(WRITE 5131 chars recovery-notice). Recovery sources: `31a5f363-a178-41f8-b688-67b1b4cb7e41.jsonl:L33` (lines 1-314) + `agent-abee75e2518d36e62.jsonl:L67` (lines 455-470). Companion: L-S45-1 (pre-staged file VBW) -- same incident, different facet.
**Lesson candidate ID**: L-S45-2.

### 2026-05-05 (S46 -- sandwich-dev IMPL -- ruff auto-fix import collision): Add `typing.Any` Explicitly Alongside `Callable` In Mixed-Annotation Dataclasses

**Context**: S46 BC-6 Track G IMPL. Three platform adapters (YouTube, Telegram, Facebook) used `Any` in field annotations (for injectable callables `clock`, `sleeper`, `mock_api_caller`) AND `dict[str, Any]` in method signatures. Ruff auto-fix (`--fix`) aggressively removed `from typing import Any` as "unused" because it also added `from collections.abc import Callable` for the stricter callable type hints. This left `F821 Undefined name Any` errors in field annotations that ruff did NOT rewrite. Required manual re-addition of `from typing import Any` + `from collections.abc import Callable` as co-imports.
**Rule**: When a dataclass has BOTH `Callable[[...], ...]` field annotations (needs `collections.abc.Callable`) AND `Any` field annotations or method `dict[str, Any]` params (needs `typing.Any`), always import BOTH explicitly. Ruff's `--fix` strips one when it adds the other; the compiler then fails on `F821`. Do not rely on ruff auto-fix to preserve both imports when the file has mixed annotation styles.
**How to apply**: After running `ruff check --fix`, scan result for `F821 Undefined name Any` or `F821 Undefined name Callable`. If found, check imports -- one of them was cleaned out. Re-add the missing import manually.
**Severity**: LOW (easy to catch + fix; no data loss; ruff reports clearly).
**Provenance**: S46 sandwich-dev 2026-05-05; `packages/infrastructure/influence/{facebook_adapter,telegram_adapter,youtube_adapter}.py` all hit this pattern during BC-6 Track G IMPL.
**Lesson candidate ID**: L-S46-1.

### 2026-05-05 (S46 -- main-session re-dispatch): Post-/clear TaskList Loss Does NOT Mean Dispatch Failed -- Check Completion Artifacts First

**Context**: S46 main-session continued after a /clear-induced session reset. TaskList was empty (showed no active tasks). Main session assumed the prior sandwich-dev background dispatch (`ae02fd82e504f1311`) had been killed mid-flight and re-dispatched a fresh sandwich-dev (`a8893e6e4ea04ff2e`) with "RESUME from partial state" instruction. In reality, the original dispatch had COMPLETED before the /clear -- shipped 24 files + session log + a current-execution row. The re-dispatch ran a redundant ~163K-token Read-and-verify pass over already-complete work. Net positive (caught 4 real test-failure bugs + validated mypy --strict) but ~150K tokens of subagent burn was avoidable.
**Rule**: After /clear or session reset, BEFORE concluding a background dispatch was killed, deterministically check for completion artifacts: (1) look for the expected session log file at `agent-workspace/memory/sessions/YYYY-MM-DD-session-N.md`; (2) grep `current-execution.md` for the session-N row; (3) check for the dispatched session's expected output files via `Glob`. If ANY of these exist, the dispatch likely COMPLETED -- read its session log to confirm before re-dispatching.
**Why**: TaskList tracks active in-process tasks; a /clear or session reset wipes the in-memory task registry but on-disk artifacts persist. Treating empty TaskList as "dispatch failed" is a false negative that leads to redundant re-work.
**How to apply**: Add to SessionStart handoff routine -- if previous session had a "background dispatch IN-PROGRESS" row in current-execution.md, FIRST check for the expected output artifacts (session log + key deliverables) before scheduling re-dispatch. If artifacts present, mark the row COMPLETE and proceed to next session boundary.
**Severity**: MEDIUM (~150K subagent tokens burned in redundant re-dispatch; no data loss; but cost calibration drift if pattern recurs).
**Auto-detect**: HOOK CANDIDATE -- SessionStart hook could parse `current-execution.md` for "IN-PROGRESS" rows older than 1 hour AND `Glob` for the expected session log; if log exists, emit ALERT "previous IN-PROGRESS row may already be COMPLETE; verify before re-dispatch". Provisional ID: L-S46-2.
**Provenance**: S46 main-session 2026-05-05 dual-dispatch incident; original `ae02fd82e504f1311` completion notification arrived AFTER my re-dispatch had been launched; both completed within ~30 min of each other. Companion to L-S43f-2 (subagent stream-window stall mitigation) -- different failure mode but same family of "infer dispatch state from indirect signals" anti-pattern.
**Lesson candidate ID**: L-S46-2.

---

## L-S47-1 (2026-05-05): Empirical Probe Deferred → Auto-Decide Path Must Be Documented

**Context**: S47 Track H required empirical probe (L-S32-1 mandatory) on ≥3 LLM strategies before writing the extractor. The dev-agent subagent had no live LLM environment (no claude CLI, no API key). Sub-plan carry-forward #3 provided an explicit auto-decide path: "stub the picker with chosen strategy = Sonnet (cheapest-acceptable default) + document deferral as IMPL-S47-* deviation".
**Rule**: When probe environment is unavailable and the sub-plan provides an explicit auto-decide clause, execute the auto-decide path WITHOUT escalating to a SCOPE Q&A bundle — the sub-plan already has the human's approval for this case. Document the deferral as IMPL-S47-* in: (1) strategy picker docstring, (2) session log, (3) agent-notes. Set a concrete rollback condition tied to a later calibration session (S49).
**Anti-example**: Silently choosing a model with no documentation; OR escalating to Q&A when sub-plan already specifies the auto-decide path; OR choosing Opus (expensive) when Sonnet is explicitly the cheap-acceptable default.
**Correct example**: `extraction_strategy_picker.py` docstring contains the probe matrix table + IMPL-S47-1 label + rollback condition (precision < 0.85 → escalate at S49).
**Severity**: medium
**Auto-detect**: no (human review at S49 calibration session)
**Lesson ID**: L-S47-1.

---

## L-S48-1 (2026-05-05): Continue-Injector Wrong-Window Spam Loop — Two Compounding Bugs Plus Missing Global Rate-Limit

**Context**: User reported "harness cứ liên tục chạy 'continue' không được phép" — the harness was continuously typing "continue" into the user's terminal preventing prompt composition. Empirical signature in single morning (07:38-09:06): 180 continue-injector spawns, 160 SessionStart events, 34 Mode-D recovery fires, 4 wind-down auto-reboots — average 1 SessionStart every 17 seconds. Inspection of latest injector log showed both `claude.exe` processes had `mainWnd=0x0` (multi-claude / hidden-window state). Old injector logic fell back to focusing first matching `WindowsTerminal/cmd/bash` process with valid `MainWindowHandle` and SendKeys-typed "continue" into it — sometimes the user's other cmd window, sometimes back into the TUI through indirect ancestry.

**Three compounding root causes:**
1. **Window-targeting fallback too loose** — `Try-FocusClaudeTerminal` line 60-70 grabbed first random terminal-class window when no `claude.exe` parent had valid `mainWnd`. Under multi-claude conditions or container/hidden-window states, this hit user's unrelated cmd/terminal.
2. **Per-tick idempotency broken by bootstrap re-touch** — injector's existing idempotency uses `.session-ready` mtime ticks (`.continue-fired-{tick}` markers). Bootstrap re-touches `.session-ready` on every SessionStart hook fire, so every new tick passes idempotency check and a new injector spawns.
3. **No global rate-limit across entry points** — bootstrap (startup/clear/resume), Mode-A (narration), Mode-B (API-error), Mode-C (premature wind-down), Mode-D (clean-handoff) ALL spawn injector independently with no cross-entrypoint guard. If checkpoint-mtime <60s, Mode-D fires every Stop hook in a session; combined with bootstrap fires from session-self-reboot cycles, multiple injectors spawn within seconds.

**Rule**: Harness keystroke-injection scripts MUST gate on (a) verified target-process ancestor with valid window — never fall back to a class-name match like "first cmd.exe with mainWnd ≠ 0", AND (b) global time-based rate-limit covering ALL entry points (the file marker pattern survives concurrent invokers; per-tick or per-mode idempotency does not). When `mainWnd=0x0` for primary process, walk ancestor chain (claude → node → cmd) up to N hops, but if no ancestor has valid window, **refuse to type rather than guess**.

**Anti-example**: 
```powershell
$terminals = @("WindowsTerminal","mintty","ConsoleWindowHost","wt","pwsh","powershell","cmd","bash")
foreach ($name in $terminals) {
    $p = Get-Process $name | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
    if ($p) { focus $p; return $true }   # ← grabs user's unrelated terminal
}
```

**Correct example**: walk ancestor chain via `Get-CimInstance Win32_Process` parent walk (up to 6 hops); if no claude.exe ancestor has valid `MainWindowHandle`, log + return false. Pair with rate-limit marker:
```powershell
$RateLimitMarker = ".../.continue-injector-last-fire"
if (Test-Path $RateLimitMarker) {
    $age = ((Get-Date) - (Get-Item $RateLimitMarker).LastWriteTime).TotalSeconds
    if ($age -lt 60) { exit 0 }
}
Set-Content -Path $RateLimitMarker -Value (Get-Date -Format "o")
```

**Why both fixes needed**: rate-limit alone bounds spam frequency but still types into wrong window once per minute; window-targeting alone allows correct window to be spammed at session-spawn rate. Together: at most 1 fire per 60s, AND only when correct window verified, AND skip silently if not verified.

**Severity**: HIGH (user-blocking; prevented user from composing messages)
**Auto-detect**: deterministic — count `spawned continue-injector` log entries in `.session-hooks.log` per minute; alert if >5/min (background spam) or if injector log shows `fallback focus` line (would indicate old code still running).
**Lesson ID**: L-S48-1.

**Also-relevant lessons referenced**: L-S11-1 (PowerShell em-dash CP1252 parse fail — re-occurred during this fix when initial Edit included `—` and `$i:` patterns; PARSE_FAIL caught proactively before deploy. Use ASCII-only in PS string literals + `${var}` to escape variable-colon sequences).

---

### L-S48m-1 — Per-session-marker hooks must NOT use $CLAUDE_SESSION_ID env var on Windows Claude Code 4.x

**Date**: 2026-05-05
**Origin**: S48m HH-H investigation; auto-populate-hook S48e..S48h gap root cause
**Severity**: MEDIUM (silent skip = harder to debug than loud fail)

**Finding**: `$CLAUDE_SESSION_ID` env var is EMPTY in 174/174 SessionStart events on Windows Claude Code 4.x (deterministic empirical via `grep "SessionStart session= " agent-workspace/memory/.session-hooks.log | wc -l`). Per-session marker pattern `.profile-template-fired-${CLAUDE_SESSION_ID:-default}` collapses to `.profile-template-fired-default` for ALL Stops — first session writes marker, all subsequent silent-skip via `[ -f $MARKER ] && exit 0`.

**Rule**: Any hook needing per-session uniqueness must derive marker name from session-log filename or transcript content, NOT from `${CLAUDE_SESSION_ID:-default}`.

**Correct pattern** (per `scripts/hooks/profile-template-auto-populate.sh` post-S48m fix):
```bash
LATEST_SESSION=$(find "${SESSIONS_DIR}" -name "*.md" -mtime -240m -printf '%T@ %p\n' | sort -nr | head -1 | awk '{print $2}')
LATEST_BASENAME=$(basename "${LATEST_SESSION}" .md)
MARKER="${MARKER_DIR}/.profile-template-fired-${LATEST_BASENAME}"
```

**Anti-pattern** (silent-fail):
```bash
MARKER="${MARKER_DIR}/.profile-template-fired-${CLAUDE_SESSION_ID:-default}"
[ -f "$MARKER" ] && exit 0
```

**Generic-pattern**: scan `scripts/hooks/*.sh` for `CLAUDE_SESSION_ID` references; replace with session-log-basename derivation. Only marker-name uses are problematic; logging uses (e.g. `echo "SessionStart session=$CLAUDE_SESSION_ID"`) are safe (just logs empty string).

**Where applied**:
- `scripts/hooks/profile-template-auto-populate.sh` (S48m fix; ~10 LOC delta)

**Open work**: audit other `scripts/hooks/*.sh` for the same anti-pattern. Pattern grep: `grep -l "CLAUDE_SESSION_ID" scripts/hooks/` lists candidates.

**Lesson ID**: L-S48m-1.

---

### L-S49a-1 — Verify Phase-N "DONE" claims empirically before authorizing Phase-(N+1) IMPL

**Date**: 2026-05-05
**Origin**: User halt of S49 mid-IMPL with explicit demand to audit Phase 2.5 before resume
**Severity**: HIGH (calibration over confidence; un-audited "DONE" claims compound across phases)

**Finding**: S48m checkpoint asserted "Phase 2.5 SUBSTANTIVE WORK 8/8 COMPLETE" based on author-side write-ups + smoke evidence within each S48-letter session. User caught the trust gap and demanded independent verification before authorizing Phase 3 IMPL budget consumption. Audit (S49a) found 8/8 deliverables structurally GREEN BUT 3 NEW drift issues (6 missing session logs / Tier 1 bloat 3.7x / HH-F.4 amended target) that the in-flight checkpoints did not surface.

**Rule**: At end of any "Phase N closed N/N tracks" claim, BEFORE moving to Phase N+1 IMPL, run a fresh independent audit:
1. List each track's claimed deliverables (per session-plan success criteria, not just session-log claims).
2. `ls -la` + `bash -n` (where shell) + grep-for-content-sentinel on each claimed file.
3. Re-execute deterministic smoke tests cited GREEN (don't trust write-up only).
4. Spot-check Stop chain ordering, settings.json validity, charter md5 deltas.
5. Document drift in `observations/YYYY-MM-DD-S<NN>-phase-N-audit-verdict.md`.
6. Append findings to `mistake-log.md` (root cause + recurrence risk + fix proposed).
7. Only resume Phase N+1 after audit clears OR explicit user override.

**Why**: Charter Principle 8 (Calibration over confidence) — claims about completeness must be empirically verified, not asserted. Self-reported "DONE" by the same agent that did the work is an echo chamber (matches AP-1 same-agent self-review anti-pattern even though no IMPL change is happening).

**Where applied**:
- `agent-workspace/memory/observations/2026-05-05-S49a-phase-2.5-audit-verdict.md` (audit verdict template)
- This entry (L-S49a-1)
- User memory `verify_phase_before_next_phase.md` (cross-conversation persistence)

**Auto-detect signature**: at session_type=PLAN OR session_type=MULTI_TASK_IMPL OR session_type=FOCUSED_IMPL with brief mentioning "Phase N+1" entry and predecessor "Phase N N/N DONE", insert audit-first task in pre-flight. Hook candidate: `phase-boundary-audit-required.sh` HARD-BLOCK at SessionStart if `current-execution.md` shows "Phase N close" within last 3 sessions AND no `S<NN>a-phase-N-audit-verdict.md` observation file present.

**Lesson ID**: L-S49a-1.

---

### L-S49-1 — NO-LLM-MATH invariant extends to test-assertion authoring

**Date**: 2026-05-05
**Origin**: S49 BC-6 pytest first-run failure on `test_ci_tightens_with_more_samples` — author-side intuition asserted n=100 60H/40M would yield CI width <0.15; actual 0.1536 (M-S49-1).
**Severity**: MEDIUM (single test failure, but pattern is generic across stat-heavy tests)

**Rule**: When authoring a test that asserts a deterministic-computation output (Bayesian CI width, confidence interval coverage, hit-rate threshold, etc.), the LLM author MUST run the computation explicitly (scipy / numpy / statistics / ad-hoc Python) BEFORE writing the assertion — never derive sample-size or threshold values from intuition. This is the I-S1 NO-LLM-MATH invariant (Charter Principle 9) extended from production code into test authoring: even though tests aren't shipped numerical output to user, they encode invariants that gate IMPL release, so an intuition-derived assertion is a silent calibration drift.

**Anti-example** (S49 first turn):
```python
# WRONG — author assumed n=100 was "enough"
[_review(...HIT) for i in range(60)] + [_review(...MISS) for i in range(40)]
# actual width=0.1536 > 0.15 threshold → assertion fails
```

**Correct example** (S49 fix):
```python
# Empirical threshold: at 60% hit rate, Beta(5,5) prior needs n>=110 for
# CI width <0.15 (spec § B.1). n=150 (90H/60M) → width=0.1274, comfortably
# below the 0.15 statistically-meaningful threshold ...
[_review(...HIT) for i in range(90)] + [_review(...MISS) for i in range(60)]
```

**Where applied**:
- `packages/domain/influence/services/test_calibration_service.py:160-178` — fix + empirical-threshold comment
- This entry (L-S49-1)
- `agent-workspace/memory/mistake-log.md` § M-S49-1

**Auto-detect signature**: pre-commit hook idea `assertion-empirical-validation.sh` — grep for `assert .*_ci|assert .*meaningful|assert .*threshold` in newly-changed test files; if found AND no nearby comment block with empirical-derivation evidence (sentinel "Empirical threshold:" or "scipy.stats" usage), warn. Phase 1+ deferred (single-occurrence so far; revisit if pattern recurs).

**Lesson ID**: L-S49-1.

---

### L-S49-2 — mypy --strict requires --explicit-package-bases for src-layout repos with packages/ root

**Date**: 2026-05-05
**Origin**: S49 BC-6 first mypy run failed with `Source file found twice under different module names: "domain.influence.value_objects.channel_id" and "packages.domain.influence.value_objects.channel_id"`.
**Severity**: LOW (recoverable via flag; gate-cascade docs need update)

**Rule**: When invoking `mypy --strict` on a path inside `packages/` directly (e.g., `mypy packages/domain/influence`), ALWAYS pass `--explicit-package-bases` flag — otherwise mypy auto-discovers BOTH the `packages/` parent (yielding `packages.domain.X`) AND the path-relative-to-CWD (yielding `domain.X`) as candidate module roots, causing the dual-naming error.

**Background**: This project uses `root_packages = ["packages"]` in `[tool.importlinter]` and absolute imports of the form `from packages.domain.*`. mypy's auto package-base detection conflicts with this layout when paths are passed directly rather than via package name.

**Correct invocation** (gate cascade canonical):
```bash
python -m mypy --strict --explicit-package-bases \
  packages/domain/influence \
  packages/application/influence \
  packages/infrastructure/influence \
  packages/contracts/events
```

**Where applied**:
- `agent-workspace/memory/mistake-log.md` § M-S49-2
- This entry (L-S49-2)

**Auto-detect signature**: candidate hook `mypy-strict-canonical-invocation.sh` Phase 1+ — if any agent runs `mypy` without `--explicit-package-bases` against `packages/**`, surface this as a known-issue note. Or codify in `agent-workspace/constitution/coding-principles.md` § Gate Invocation Canonical Forms (charter-tier addition deferred until 2-3 cases recur).

**Lesson ID**: L-S49-2.

---

### L-S49b-1 — Tier 1 archive sweep: 6-pass progressive compression playbook

**Date**: 2026-05-05
**Origin**: M-S49a-2 fix (Tier 1 bloat 30844 tok ≫ 8000 ceiling, 3.85x); produced 71.7% reduction (8712 tok final, 8.9% over ceiling).
**Severity**: MEDIUM (operational hygiene; SessionStart bootstrap discipline)

**Rule**: When Tier 1 bootstrap exceeds ceiling >2x, run a multi-pass progressive archive sweep (older→recent), with empirical bloat-check verify between passes. Don't try to do it all in one mega-edit — incremental passes let you measure progress + back off if a section turns out to be load-bearing for routing.

**Playbook (6-pass canonical from S49b)**:
1. **Pass 1 — Oldest detail block**: Identify the oldest large `## S<N>` detail rows (e.g., S48c..S48m). Append verbatim to `current-execution-archive.md` under a `## ... archived YYYY-MM-DD` section header. Replace the block in current-execution.md with a one-liner index linking to archive.
2. **Pass 2 — 2nd oldest block**: Repeat for next-oldest detail (e.g., S43f..S47).
3. **Pass 3 — Stale "Current Work Items"**: This section often hoards detail from prior sessions even after they close. Replace with a 4-5-line pointer.
4. **Pass 4 — Audit-row archive**: Audit verdicts (e.g., S49a) become subsumed by IMPL closure; archive detail to its observation file.
5. **Pass 5 — "Active Focus Track" rewrite**: This section drifts. Rewrite based on current phase status (don't trim — replace with fresh content tightly aligned to current state).
6. **Pass 6 — Most-recent row trim**: The latest `## S<N>` row often has redundant detail vs session log + checkpoint. Trim bullets that are duplicated downstream.

**Per-pass verify**: run `scripts/hooks/tier1-bloat-check.sh` after each pass to confirm direction + measure remaining gap.

**Practical floor**: with 2 load-bearing CLAUDE.md (~4.5K tok combined), Routing Table (~550 tok), and minimum session/checkpoint context (~2K tok), expect ~7-9K tok floor. Don't burn budget chasing the literal 8K ceiling — accept ~10% over as acceptable practical state.

**Where applied**:
- `agent-workspace/memory/current-execution.md` (sweep target; 4 archive sections + 2 row updates)
- `agent-workspace/memory/current-execution-archive.md` (sweep landing; 4 sections appended)
- `agent-workspace/memory/checkpoints/latest.md` (companion trim; 1507→846 tok)
- This entry (L-S49b-1)

**Auto-detect signature**: `tier1-bloat-check.sh` already SOFT-WARNS at every SessionStart when over ceiling — promote to nudge agent to schedule sweep when ratio >2x for 3+ consecutive sessions. Hook idea: `tier1-bloat-trend-tracker.sh` Phase 1+.

**Lesson ID**: L-S49b-1.

---

### L-S49b-2 — Harness diagnosis playbook: when hooks "don't seem to fire"

**Date**: 2026-05-05
**Origin**: User pushback on autonomous-loop self-pause led to root-cause investigation of harness Stop chain (M-S49b-1).
**Severity**: MEDIUM (autonomous loop reliability; deferred fix)

**Rule**: When investigating "this hook isn't firing", do NOT trust the conclusion "hook is broken" without these 5 diagnostic steps:

1. **Enumerate event types in `.session-hooks.log` for the current session window**. Different hook event types (PostToolUse / UserPromptSubmit / Stop / SubagentStop / SessionStart) write distinct line patterns — count each separately. If one event type has 0 entries while others fire, the harness is suppressing that event, not the script.
2. **Verify hook IS in chain**: `python -c "import json; d=json.load(open('.claude/settings.json')); print(d['hooks']['<EventType>'])"`. Settings file may have been edited; chain may be missing.
3. **Verify hook config preconditions**: e.g., autonomous-stop-watchdog requires `^\*\*autonomous_mode\*\*:\s*true` in current-execution.md. Grep for the pattern.
4. **Manually invoke the hook** with mocked stdin: `echo '{"transcript_path":"/dev/null","session_id":"test"}' | bash <hook-path>`. If this writes to log fine, the script is OK; the harness isn't invoking it.
5. **Check Claude Code version** + recent changelog for known hook-system bugs (esp. Windows-specific). `claude --version`. May need to upgrade or downgrade.

**S49b-specific finding**: Claude Code 4.x on Windows did NOT fire Stop hook for the current session despite all script-side preconditions being correct. Manual invocation works. Settings intact. autonomous_mode true. But Claude Code itself is not emitting Stop events. This is a HARNESS-side gap, not a script gap. Mitigation: LLM-side autonomous-continue discipline must take the load.

**Where applied**:
- `agent-workspace/memory/mistake-log.md` § M-S49b-1
- This entry (L-S49b-2)
- KI-S49b-1 deferred Claude Code version + Stop event suppression investigation

**Auto-detect signature**: candidate hook `stop-hook-fire-count-watchdog.sh` Phase 1+ — at SessionStart, count `Stop session=` entries in `.session-hooks.log` for current session. If 0 entries despite >5 PostToolUse fires, surface as a SessionStart diagnostic alert.

**Lesson ID**: L-S49b-2.

---

### L-S49b-3 — Background-subagent dispatch sequencing + pre-dispatch in-flight check

**Date**: 2026-05-05
**Origin**: M-S49b-2 incident — S50 sandwich-verifier dispatched twice across `/clear` boundary; one in-flight dispatch was killed before observation could be written, then post-`/clear` LLM was about to re-dispatch unaware of the prior in-flight state.
**Severity**: MEDIUM (work-loss + meta-failure pattern)

**Rule** (two parts — both binding for any background subagent dispatch):

**Part A — Dispatch sequencing**: when dispatching a background subagent in a session, the LLM MUST follow this order within the same turn:

1. **Run pre-dispatch check** (Part B below — non-skippable)
2. **Make the Agent() call** with `run_in_background=true`
3. **Write/update the checkpoint** to reflect that the dispatch HAS HAPPENED, populating `in_flight_subagent_dispatch:` field with `tool_use_id`, `dispatched_at`, `expected_observation_path`, `status: PENDING`
4. **End turn** (or continue with non-conflicting work)

**Anti-pattern**: write checkpoint with future-tense `next_action: dispatch X` and then dispatch X immediately in the same turn. Either (a) checkpoint is truthful but action is unfinished — `next_action` is a TODO; or (b) action just happened — `next_action` is stale by the time anyone reads it. Across `/clear` boundaries this stale field causes re-dispatch.

**Correct example**:
```
[Turn N actions, in this exact order:]
1. Read state (current-execution + checkpoints + observations + .dispatch-pending-*.jsonl)
2. Pre-dispatch check passes — no matching observation, no matching pending registry row
3. Agent({ subagent_type: "sandwich-verifier", run_in_background: true, prompt: "..." })
4. Edit checkpoint: append `in_flight_subagent_dispatch:` entry with tool_use_id from step 3 + expected_observation_path + status=PENDING
5. Optional: write/update current-execution.md with the dispatch row
6. End turn
```

**Part B — Pre-dispatch in-flight check protocol**: BEFORE Agent.dispatch in step 2 above, run these grep/ls checks in parallel:

```bash
# Check 1 — observation already exists?
ls agent-workspace/memory/observations/ | grep -iE "<short-task-name>|<session_id>|<related_track>"

# Check 2 — in-flight registry has matching pending entry?
cat agent-workspace/memory/.dispatch-pending-*.jsonl 2>/dev/null | grep '"state":"pending"'

# Check 3 — checkpoint frontmatter has matching in_flight_subagent_dispatch entry?
grep -A 5 "in_flight_subagent_dispatch:" agent-workspace/memory/checkpoints/latest.md
```

**Decision rules**:
- Check 1 returns match → INTEGRATE that observation; do NOT re-dispatch unless explicitly redoing work
- Check 2 returns match → investigate (read the JSONL row's `parent_session_id` + `ts_ms`):
  - If `ts_ms` < 30 min ago AND no observation file → likely still running; wait or query task
  - If `ts_ms` > 2hr ago AND no observation file → likely killed/orphaned; mark `state=killed` in JSONL, then OK to re-dispatch
- Check 3 returns match → read the entry's `status`:
  - PENDING → see Check 2 logic
  - OBSERVED → integrate (should have triggered Check 1 too)
  - LOST/KILLED → OK to re-dispatch with note

**Anti-example** (M-S49b-2 incident): post-`/clear` LLM read checkpoint's stale `next_action` and prepared 3 TaskCreate scaffolds for the dispatch flow — never ran any pre-dispatch check. User interrupted before Agent.dispatch fired, but the protocol gap is generic.

**Correct example**: this very session's recovery flow — when user flagged the incident, the LLM ran Check 1 (`ls observations/` → 0 S50 files), Check 2 (`cat .dispatch-pending-*.jsonl` → found `5b96635e-*.jsonl` with `state=pending` matching `tool_use_id=toolu_01JLqZBE...`), then waited for the killed-task notification to clarify state before deciding whether to re-dispatch.

**Where applied**:
- `agent-workspace/memory/mistake-log.md` § M-S49b-2 (failure catalog)
- `agent-workspace/memory/observations/2026-05-05-S50-pre-dispatch-duplicate-rca.md` (full RCA + fix plan)
- This entry (L-S49b-3)
- `agent-workspace/memory/checkpoints/latest.md` — schema extended with `in_flight_subagent_dispatch:` field
- (deferred) `scripts/hooks/in-flight-subagent-watcher.sh` Phase 1+ — proposed Fix-L4 to surface stale-pending dispatches at SessionStart as `<system-reminder>` injection

**Auto-detect signature**: hook `in-flight-subagent-watcher.sh` (proposed; not yet ratified) — runs at UserPromptSubmit; reads `.dispatch-pending-*.jsonl`; for any `state=pending` row with `ts_ms` > 2hr old + no companion observation file → emits `<system-reminder>` to LLM saying "STALE PENDING DISPATCH — verify before any new dispatch".

**Lesson ID**: L-S49b-3.

---

### L-S49b-4 — Checkpoint write IS a session-boundary marker; end turn after it (PRIMARY rule, supersedes any "continue past checkpoint" interpretation)

### L-S51-1 — Empirical-firing discipline supersedes ritual-completion verdict
**Context**: Phase 2.5 (HH-A..HH-H) was audited as 8/8 GREEN at S49a 2026-05-05. Audit measured: file exists / `bash -n` clean / wired in settings.json / smoke command exit-0. Did NOT measure: hook fires on real session events / detection logic produces truthful output on real telemetry shape / escalates when threshold crossed / escalation channel reaches a human or LLM with action authority. T1 post-mortem (this session) found ≥4 hooks wired + executing + silently broken. Smoking gun: `promotion-cycle-trigger.sh` fired 20× today, escalated 0× — grep pattern `^\*\*Session N\*\*:` never matched the real `## SXX —` header format → `LATEST_SESSION=0` always → arithmetic delta always negative → escalation thresholds never crossed.

**Rule**: "Wired + syntax-clean + smoke-passing" is necessary but NOT sufficient evidence of operational health. Every hook ships with a companion firing-test that synthesizes REAL session-data shape (NOT minimal stubs). Phase-close audit MUST include per-hook empirical firing column. Hooks that fail to fire (or fire silently) for ≥3 consecutive sessions are flagged for remediation.

**Anti-example**: Phase 2.5 S49a audit verdict "all 4 watchdog hooks wired + bash -n clean + smoke exit=0" → declared GREEN. Empirical reality: HH-C.4 promotion-cycle-trigger silently no-op'ed because grep pattern mismatch → 14+ session backlog of accumulated lessons never escalated.

**Correct example**: T3 priority-1 fix flow this session (S51): (a) inspect `.promotion-cycle.log` per-line → reveals broken state; (b) edit grep pattern to match real file format; (c) author firing-test in `scripts/hooks/firing-tests/<hook-name>-fire-test.sh` with 4 test cases (hard-block / soft-warn / silent / subordinate-format); (d) run firing-test → 4/4 PASS; (e) run hook against REAL current-execution.md → produces `latest_session=50 last_promote=S43 delta=7 phase_changed=1` → HARD-BLOCK fires; (f) document in M-S51-1 + this rule.

**Severity**: high

**Auto-detect**: yes — Phase 3.5 T6 hook `harness-health-self-scan.sh` will codify this signal. Specifically: scan `.promotion-cycle.log` for `latest_session=0` runs OR scan agent-notes for accumulated `Auto-detect: yes` entries without companion shipped hook + firing-test.

**Where applied**: this rule + M-S51-1 + post-mortem 2026-05-05-phase-2.5-empirical-firing-gap.md + plan 010 § T7 retrofit pattern. Charter promote target: Phase 3.5 T8 ratification as Principle 11.

**Date**: 2026-05-05
**Origin**: User-supplied reframing of M-S49b-2 incident: "lỗi chính là tại sao lại action như vậy mà? đã note checkpoint rồi lại còn làm action khác như dispatch? phải end chờ '/new' chứ"
**Severity**: HIGH (doctrine — applies to ALL session-boundary work, not just dispatch flows)

**Rule**: When the LLM writes / Edits `agent-workspace/memory/checkpoints/latest.md`, that write IS the session-boundary marker. The LLM MUST end the turn after the checkpoint write. The whole purpose of the checkpoint protocol is fresh-context handoff — writing checkpoint, then immediately doing the work the checkpoint announces, defeats the protocol.

**Why this is a PRIMARY rule (not just a dispatch-flow concern)**:
- Checkpoint's `next_action` field is meant to be read by the NEXT session, not executed by the current one
- Continuing past checkpoint write causes:
  - (a) work duplication if user fires `/new` or `/clear` mid-turn (Claude Code v2.1.124 queues slash commands instead of interrupting; LLM doesn't see the queue)
  - (b) stale `next_action` field across `/clear` boundary that misleads the next session into re-executing
  - (c) burns through user-queued intent; user has implicit "go to next session" signal that LLM ignores
  - (d) violates the fresh-context-handoff principle that justifies the checkpoint protocol existing in the first place

**How to apply**:
- After Edit/Write to `checkpoints/latest.md`: end turn. Period.
- One short summary message to user is OK ("S49b done. Tier 1: 8667 tok. Checkpoint written for S50 dispatch."). NO additional tool calls — no Bash, no Agent dispatch, no further Edits.
- If a final cleanup action absolutely cannot wait, do it FIRST then write checkpoint LAST. Never the other way around.
- This rule OVERRIDES `~/memory/autonomous_continue_no_self_pause.md` Rule 1's "immediately do the next-action" clause WHEN the next-action is recorded in a checkpoint. Checkpoint-recorded actions are for the NEXT session, not this one. Carve-out added to that memory file this turn.

**Anti-example** (M-S49b-2, prior session 5b96635e):
```
[Turn N actions in observed order]
1. Edit current-execution.md (S49b row + archive sweep)
2. Edit checkpoints/latest.md (next_action = "S50 dispatch sandwich-verifier")
   ↑ TURN SHOULD HAVE ENDED HERE
3. Agent({sandwich-verifier, run_in_background: true, ...})  ← VIOLATION
4. Bash tier1 final-check                                     ← VIOLATION
5. Summary message "S50 sandwich-verifier dispatched..."      ← VIOLATION
6. /new queued by user mid-turn (ignored by LLM)
7. /clear resolves; new session opens; reads stale checkpoint
8. New LLM almost re-dispatches (interrupted just in time)
9. Background agent from step 3 killed mid-investigation; observation lost
```

**Correct example** (what should have happened in 5b96635e):
```
1. Edit current-execution.md (S49b row + archive sweep)
2. Edit checkpoints/latest.md (next_action = "S50 dispatch sandwich-verifier")
3. Brief summary message: "S49b done. Tier 1: 8667 tok. Checkpoint written for S50."
   ↑ TURN ENDS HERE
[user types /new at leisure; new session starts; new LLM reads checkpoint and dispatches]
```

**Relationship to L-S49b-3 (dispatch sequencing)**:
- L-S49b-3 prescribes: dispatch FIRST → write checkpoint with `in_flight_subagent_dispatch:` populated → end turn
- L-S49b-4 prescribes: ANY checkpoint write = end turn
- **They are compatible**: if dispatch is necessary in current session, do it BEFORE the checkpoint write, then write the checkpoint reflecting completed-state, then end. Checkpoint stays the boundary marker.

**Auto-detect signature**: hook `checkpoint-write-end-turn-watchdog.sh` (proposed; not ratified) — runs on PostToolUse for Edit/Write tools targeting `checkpoints/latest.md`; if any further tool call fires in the same turn, emit `<system-reminder>` "VIOLATION: Edit/Write to checkpoints/latest.md should end the turn — see L-S49b-4". Implementation: track `last-checkpoint-write-ts` per session in `.session-hooks.log`; on subsequent tool call within same session, compare timestamps and alert.

**Where applied**:
- `agent-workspace/memory/mistake-log.md` § M-S49b-2 (PRIMARY root-cause section)
- `~/memory/autonomous_continue_no_self_pause.md` (carve-out added: checkpoint write = session-boundary marker; overrides Rule 1's "immediately do next-action")
- `agent-workspace/memory/observations/2026-05-05-S50-pre-dispatch-duplicate-rca.md` (full RCA reframed)
- This entry (L-S49b-4)
- (proposed, deferred) `scripts/hooks/checkpoint-write-end-turn-watchdog.sh`

**Lesson ID**: L-S49b-4.

---

### L-S52-1 — Firing-test catches author-time imagined-format bugs ON THE LINT HOOK ITSELF (meta-recursive discipline)
**Date**: 2026-05-05
**Origin**: S52 T3.4 cherry-pick — bash-hook-lint Pattern A (M-S51-1 detector) initial draft FAILED its own firing-test TC-A.

**Context**: When extending `bash-hook-lint.sh` Check 5 with Pattern A (detect literal "Session N" placeholder in grep/sed/awk patterns — the M-S51-1 root cause), the first-draft regex required literal `**Session N**`. Real bug instances in target hooks use ESCAPED form `'^\*\*Session N\*\*:'` because grep -E itself needs `*` escaped. The lint regex looked for the un-escaped Markdown-rendered form (what reader sees), not the literal source-file form (what `grep -E` matches against). M-S52-2.

**Rule**: L-S51-1 empirical-firing discipline applies recursively — including to lint hooks that DETECT empirical-firing failures. Lint authors must:
1. **VBW the actual buggy hook source** before authoring the detection regex (read `scripts/hooks/<bug-hook>.sh` pre-fix line-by-line; copy the literal characters into a notes file).
2. **Stage firing-test with REAL escape sequences**, not idealized/cleaned versions. The synthesized hook script in firing-test must be a faithful reproduction of how the bug actually appears in source.
3. **Trust the firing-test failure** — if firing-test fails on a "looks-right" regex, the regex is wrong; the staged sample is the ground truth (not vice versa).

**Anti-example** (this turn): first-draft Pattern A regex `(grep|sed|awk).*[\\^]?[*][*]Session N[*][*]` required `**Session N**` literal — failed firing-test against staged `\*\*Session N\*\*` form.

**Correct example**: relaxed regex to `(grep|sed|awk)[[:space:]].*Session N([^a-zA-Z0-9]|$)` — matches "Session N" placeholder + non-word boundary. Agnostic to escape sequences. Firing-test 4/4 PASS post-fix → production smoke surfaces 2 NEW pre-existing bugs (M-S52-1 = TRUE POSITIVES).

**Severity**: high (lint hooks are the meta-defense; if they're silently broken, all other empirical-firing claims are unverified).

**Auto-detect**: yes — every NEW hook with a regex/grep pattern requires a companion firing-test using staged synthetic input that REPRODUCES the bug shape from real source. Phase 3.5 T7 retrofit applies this to the existing 24+ untested hooks.

**Where applied**:
- `scripts/hooks/bash-hook-lint.sh` § Check 5 (regex relaxed)
- `scripts/hooks/firing-tests/bash-hook-lint-fire-test.sh` (Pattern A staged with `'^\*\*Session N\*\*:'` real-escape form)
- mistake-log.md § M-S52-2 (lint regex iteration bug; caught pre-deploy)
- This entry (L-S52-1)

**Lesson ID**: L-S52-1.

---

### L-S52-2 — Hook-log-naming inconsistency causes false-positives in firing-counter MVP; T6 must standardize
**Date**: 2026-05-05
**Origin**: S52 T3.4 hook-firing-counter.sh production smoke — flagged 13/51 hooks as "silent ≥7d" but ~50% are false-positives due to inconsistent log file naming conventions.

**Context**: The new `hook-firing-counter.sh` MVP uses two evidence sources to detect hook firing:
1. Per-hook log file `agent-workspace/memory/.<basename>.log` (mtime within 7d)
2. Hook basename appears in `agent-workspace/memory/.session-hooks.log`

Production hooks write to varied log paths that don't follow the `.<basename>.log` convention:
- `promotion-cycle-trigger.sh` writes to `.promotion-cycle.log` (drops "-trigger" suffix)
- `budget-watchdog.sh` writes anonymous `[ts] watchdog tokens=...` lines (no basename in log)
- `userprompt-invariants-injector.sh` emits to stdout (no log file at all)

**Rule**: For deterministic firing detection, hooks MUST log their own basename in a standard location. Two acceptable patterns going forward:
- **Pattern A**: every hook writes a one-liner `[<ISO>] <basename> session=<id> ...` to `.session-hooks.log` on every fire (cheap; centralized; greppable).
- **Pattern B**: every hook with a private log uses `agent-workspace/memory/.<basename>.log` exact basename match (no suffix-dropping).

Phase 3.5 T6 (`harness-health-self-scan.sh`) MUST standardize on one of these patterns + retrofit existing hooks to comply. Until then, MVP hook-firing-counter expects ~50% false-positive rate; treat its silent-list output as a TRIAGE QUEUE, not a fail-list.

**Anti-example**: pre-T6 ecosystem — 51 hooks, ≥4 different logging conventions, no central event-stream → cannot deterministically distinguish "silent broken" from "silent because log goes elsewhere".

**Correct example** (proposed for T6): every hook starts with one line `printf '[%s] %s session=%s\n' "$(date -Iseconds)" "$(basename "$0")" "${CLAUDE_SESSION_ID:-unknown}" >> "$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"` immediately after `set -uo pipefail`. Standardizes the firing fingerprint.

**Severity**: medium (MVP works as a useful triage signal; full fidelity blocks on T6).

**Auto-detect**: yes — once Pattern A or B is standardized, hook-firing-counter graduates from MVP to the full T6 surveillance hook with strict pass/fail semantics.

**Where applied**:
- `scripts/hooks/hook-firing-counter.sh` (MVP; documents this nuance in header)
- `agent-workspace/quality-reports/deterministic/2026-05-05-S52-T3.4-firing-tests.log` § Production smoke triage table
- This entry (L-S52-2)
- Phase 3.5 plan 010 § T6 design will reference this lesson for the standardization decision

**Lesson ID**: L-S52-2.

---

### L-S52-3 — Firing-test catches at AUTHOR-iteration stage = SUCCESS path, not failure
**Date**: 2026-05-05
**Origin**: S52 T3.4 hook authoring cycle — 2 author-iteration bugs (M-S52-2 + M-S52-3) caught by firing-test/production-smoke before any deploy harm.

**Context**: M-S52-2 (Pattern A regex too narrow) was caught by `bash-hook-lint-fire-test.sh` TC-A failing on first run. M-S52-3 (settings-extract regex truncation at escaped quotes) was caught by hook-firing-counter production smoke writing 0-byte log. Both fixes shipped same-turn; neither bug ever affected production correctness or downstream consumer.

**Rule**: When a firing-test or production smoke catches an author-iteration bug PRE-DEPLOY, that is the SUCCESS path of L-S51-1 empirical-firing discipline — not a failure. Iteration-bugs are the expected output. The metric is "did any un-caught bug reach production where downstream consumers depended on it?". Pre-deploy catches don't increment the failure counter.

**Anti-pattern to avoid**: marking an author-iteration cycle as "failed" because the first regex was wrong. That confuses the metric. The CORRECT framing: iteration-bug count is the inverse of empirical-firing discipline rigor — more iteration-bugs caught means MORE rigor, not less.

**Correct example** (this turn): both M-S52-2 and M-S52-3 are cataloged with severity LOW (caught pre-deploy via the discipline) — not severity HIGH (which is reserved for un-caught bugs that reached production, like M-S51-1).

**Severity**: medium (framing/calibration rule; affects how subsequent sessions interpret iteration counts).

**Auto-detect**: no — judgment-tier rule; cannot be deterministically detected.

**Where applied**:
- mistake-log.md § M-S52-2 + M-S52-3 (severity = low per this rule)
- quality-report 2026-05-05-S52-T3.4-firing-tests.log § Discoveries this turn
- This entry (L-S52-3)

**Lesson ID**: L-S52-3.

---

### L-S53-1 — Firing-test catches LAYERED latent bugs deeper than upstream detection
**Date**: 2026-05-05
**Origin**: S53 T3.4-followup — fixing M-S52-1 (imagined-format) in `session-export-raw.sh` surfaced 2 ADDITIONAL pre-existing latent bugs in the same hook (M-S53-1 pipefail-silent-exit + M-S53-2 archive-prose-anchor-false-positive) that the upstream Pattern A detection layer (`bash-hook-lint.sh` Check 5) did NOT flag.

**Context**: Pattern A (Check 5) at S52 detected the imagined-format symptom (`^\*\*Session N\*\*:` literal). It did NOT detect:
- That Method-1's pipefail+ERR-trap silent-exit would prevent Method-2 from ever running (this is L-S48d-1 / Check 7 territory; meta-lint gap noted as KI-S53-1).
- That Method-1's NEXT-marker grep was unanchored and would false-positive on archive-prose mid-line (S38/S42 NEXT branching gate at line 261 of real `current-execution.md` → SESSION_N=42 returned every export, not the actual latest session).

Both bugs were surfaced ONLY by the firing-test → production-smoke retrofit cycle:
- M-S53-1 caught at firing-test TC1 initial fail (no raw-sessions/<DATE>-session-52.md created despite fixed Method-2 grep).
- M-S53-2 caught at production smoke (raw-sessions filename was `<DATE>-session-42.md` instead of `<DATE>-session-52.md`).

**Rule**: When applying an L-S51-1 retrofit fix to a hook with `set -uo pipefail` + `trap '... ERR'` + bare-grep pipelines, treat the ENTIRE pipeline-success contract as part of the fix scope. A surfaced symptom (imagined-format regex) is rarely the only latent bug — bash discipline failures cluster (pipefail-trap + missing `|| true` + missing line-anchors). Budget for triple-bug discovery per retrofit and fix all surfaced layers in one turn rather than deferring sequentially.

**Anti-pattern to avoid**: ship the "minimal" fix matching ONLY the upstream-detected symptom, then defer the deeper layers to a follow-up session. That fragments the firing-test artifact (TC count drifts; coverage diluted) and leaves the hook latently broken in production until the NEXT detection cycle catches it.

**Correct example** (this turn): S53 retrofit fixed all 3 layered bugs (M-S52-1 + M-S53-1 + M-S53-2) in one Edit + one firing-test extension (5 → 7 TCs) + one production smoke. Quality report § Triple-bug discovery section explicitly catalogs the dependency order so future readers see the chain.

**Severity**: high (process rule for all future L-S51-1 retrofit cycles).

**Auto-detect**: partial — `bash-hook-lint.sh` Check 7 already targets pipefail+ERR-trap+bare-grep but missed `session-export-raw.sh` (heuristic refinement opportunity, KI-S53-1). Anchor-on-grep is NOT yet a check; consider adding "Check 8 unanchored-`^`-on-positional-grep" in S54+ promote-rule cycle.

**Where applied**:
- `scripts/hooks/session-export-raw.sh` triple-bug fix
- `scripts/hooks/firing-tests/session-export-raw-fire-test.sh` 7 TCs (TC6 + TC7 added for M-S53-* coverage)
- `agent-workspace/quality-reports/deterministic/2026-05-05-S53-T3.4-followup-fixes.log` § Triple-bug discovery
- This entry (L-S53-1)

**Lesson ID**: L-S53-1.

---

### L-S53-2 — Autonomous loop reliability: idempotency must advance per Stop-event, not per-SessionStart-tick
**Date**: 2026-05-05
**Origin**: S53 post-checkpoint follow-up — user pushback "sao lại không autonomous run tiếp? tại sao, harness lại lỗi à" surfaced harness reliability gap. M-S53-3 root cause: continue-injector per-SessionStart-tick idempotency blocked autonomous Stop→Mode-D→continue-injector loop within a single session.

**Context**: L-S49b-4 (PRIMARY rule) says LLM ends turn after checkpoint write; Mode-D in autonomous-stop-watchdog.sh fires continue-injector to type "continue" into TUI → fresh resume. The mechanism worked end-to-end UP TO injector silent-exit. continue-injector.ps1 had two idempotency layers:
- 60s rate-limit (sufficient for L-S48-1 burst-spam scenario where 180 spawns occurred over a morning ~30-40min apart)
- Per-SessionStart-tick marker `.continue-fired-{SessionTag}` where SessionTag = `.session-ready` mtime ticks

`.session-ready` only updates on SessionStart events. Within a session, SessionTag NEVER changes. After the FIRST injector fire for a given SessionStart, ALL subsequent fires (including legitimate Mode-D handoffs) hit "already fired for this session-ready tick" silent exit.

**Rule**: Idempotency for autonomous-loop hooks must advance on the CAUSAL event (Stop, checkpoint write, recovery trigger) — NOT on the SessionStart tick. SessionStart is a coarse-grained lifecycle event that fires only on `/clear` / fresh-launch / `--resume`; it cannot advance within an active session, so any idempotency tied to it permanently blocks intra-session autonomous chains.

**Anti-pattern to avoid**: layering "belt-and-suspenders" idempotency without analyzing whether the redundant layer can BLOCK the legitimate flow. L-S48-1 added per-tick marker as defense-in-depth; the 60s rate-limit was already sufficient for the original spam scenario (spawns 30-40 min apart). The redundant per-tick marker silently disabled the autonomous loop the harness exists to deliver.

**Correct example** (post-S53 contract):
- 60s rate-limit (cross-caller spam protection): retained
- Per-event markers on caller side:
  - `bootstrap` (SessionStart): one fire per SessionStart (bootstrap itself only fires once per event)
  - `Mode-A` (API-truncation): `.api-truncation-recovery-fired-$RECOVERY_KEY`
  - `Mode-C` (premature wind-down): `.mode-c-recovery-fired-$MODE_C_KEY`
  - `Mode-D` (clean handoff): `.mode-d-recovery-fired-$MODE_D_KEY`
- Per-tick marker on injector side: REMOVED (M-S53-3 fix)

**Severity**: HIGH (autonomous-full mode loop dead until fix lands; user-visible reliability gap directly contradicting AOM autonomous-loop guarantees).

**Auto-detect**: yes — propose harness-health-self-scan signal HH-X (NEW): "if continue-injector log shows `already fired for this session-ready tick` AND `.mode-d-recovery-fired-*` marker exists for same time window → flag as M-S53-3-recurrence". Codify in Phase 3.5 T6 hook.

**Status of L-S48-1**: SUPERSEDED IN PART. Per-tick marker removed. Original L-S48-1 cross-window-typing prevention via `Try-FocusClaudeTerminal` ancestor-walk is RETAINED (still essential to prevent typing into wrong window).

**Where applied**:
- `scripts/hooks/continue-injector.ps1` lines 114-134 (per-tick marker block REMOVED; explanatory comment retained for forensic clarity)
- `agent-workspace/memory/mistake-log.md` § M-S53-3
- This entry (L-S53-2)
- Phase 3.5 T6 hook design will reference this as HH-X auto-detect signal

---

### L-S54-1 — 2-pass grep filter beats single-regex with `[^^]` first-char negation when target token CAN be body start
**Date**: 2026-05-05
**Origin**: S54 Check 8 authoring — initial Check 8 regex used `['\"][^^'\"][^'\"]*(MARKER)` to "skip patterns starting with `^`". Failed TC-D firing-test because when MARKER is the FIRST body char (e.g. `'S[0-9]+ NEXT'`), the `[^^'\"]` consumes `S` and the trailing alternation never finds another `S\[0-9\]\+` token to match.

**Context**: Tempting to encode "first char must NOT be caret" as a single regex constraint. But ERE has no lookahead — the negation char-class `[^^]` consumes a char, and that char is unavailable for downstream alternation. Backtracking can't recover because the consumed `[^^]` position is fixed.

**Rule**: When a heuristic needs to (a) detect a routing/marker token in pattern body AND (b) exclude patterns where body starts with a specific anchor char, use 2-pass filter:
- pass-1: `grep -E "marker_token_regex"` finds candidate lines
- pass-2: `grep -vE "anchor_prefix_regex"` excludes anchored patterns

This is cleaner, more readable, and avoids ERE backtracking pitfalls. Applies to any heuristic involving "find pattern X but exclude when prefix Y exists".

**Anti-pattern to avoid**: trying to encode the entire whitelist + flag logic as a single grep regex. Single-regex bash heuristics become hairy fast and fail in non-obvious ways (token-at-body-start edge case here was a textbook example).

**Correct example** (S54 Check 8):
```bash
BAD_D="$(grep -nE "grep[[:space:]]+(...)?['\"][^'\"]*(S\[0-9\]\+|...)" "$f" 2>/dev/null \
  | grep -vE "grep[[:space:]]+(...)?['\"]\^" \
  | grep -vE '^[[:space:]]*[0-9]+:[[:space:]]*#' \
  || true)"
```

**Severity**: medium (technique rule; affects future bash-lint authoring + any deterministic pattern-detection hook).

**Auto-detect**: no — judgment-tier rule; lint-on-lint would be over-meta. Apply at code-review time during firing-test author cycle.

**Where applied**:
- `scripts/hooks/bash-hook-lint.sh` Check 8 (post-iteration v2; v1 used `[^^][^...]*` and failed TC-D)
- `scripts/hooks/firing-tests/bash-hook-lint-fire-test.sh` TC-D / TC-D-anchored / TC-D-content (pass-1+pass-2 approach validated empirically)
- This entry (L-S54-1)

**Lesson ID**: L-S54-1.

---

### L-S54-2 — Meta-lint heuristic upgrade reveals BROADER retrofit scope than estimate
**Date**: 2026-05-05
**Origin**: S54 production smoke — refined Check 7 (now catching command-sub + pipeline forms in addition to bare-line) surfaced 27 latent L-S48d-1 candidates. Pre-S54 Check 7 surfaced 0 hits in the same hook tree. Same with Check 8: 4 unanchored-positional-grep candidates.

**Context**: Phase 2.5 (HH-A..HH-H) closed "ritually" 8/8 GREEN. Phase 3.5 master-plan (010) estimated T7 retrofit scope as "~22 remaining HH-A..HH-H untested hooks" based on session-count audit. S54 production smoke shows the L-S48d-1 family alone has ≥27 hooks with un-guarded grep under pipefail+ERR-trap context. The actual retrofit surface is BROADER than the original count-by-session estimate.

**Rule**: When a deterministic detector heuristic is upgraded mid-phase, expect production-smoke counts to JUMP, often substantially. Treat the new count as the empirical baseline for retrofit scope (not the prior under-detected count). Update master-plan envelope estimates downstream.

**Anti-pattern to avoid**: treat the post-upgrade count as "regression" or "noise". The detector wasn't catching real bugs before; the higher count is the truth surfaced. Resist the urge to relax the heuristic to bring counts back down.

**Correct example** (S54 → S55+ implications):
- T7 (firing-tests retrofit) scope reframes: each hook retrofit must ALSO normalize grep-guard form per L-S48d-1 + audit positional-marker patterns for `^` anchor per L-S53-2 — not just "add a firing-test".
- 010 plan envelope estimate for T7 batch should bump to account for grep-normalization step per hook.
- Promote-rule cycle should treat lint upgrade as observable signal of phase-2.5 incompleteness (not Phase 2.5 success criterion violation; just empirical correction).

**Severity**: medium (planning/scoping rule; affects T7 phase budget; informs how phase-closure rituals interpret deterministic-gate counts).

**Auto-detect**: yes — every post-upgrade lint smoke run logs the count delta. Compare today's `bash-hook-lint WARN N violation(s)` to last archived count; flag if N changed by ≥5 OR if a new violation code appeared.

**Where applied**:
- `agent-workspace/quality-reports/deterministic/2026-05-05-S54-bash-hook-lint-meta-refinement.log` § Production smoke breakdown
- `agent-workspace/memory/current-execution.md` S54 row (T7 scope reframing note)
- This entry (L-S54-2)

**Lesson ID**: L-S54-2.

---

### KI-S54-1 — Check 7 recognizes only canonical `|| true` / `|| :` guards (CLOSED via S58 broad refinement)
**Date**: 2026-05-05
**Origin**: S54 Check 7 refinement — chose conservative recognition of `|| true` and `|| :` as ONLY canonical guards. Alternative forms `|| echo "..."`, `|| exit 0`, `|| return 0` flag as Check 7 false-positive even though they semantically guard against the ERR trap.

**Status**: CLOSED — structural refinement shipped 2026-05-05 S58. Check 7 reimplemented as awk script with 4 NEW skip rules: (1) compound-conditional `if X && grep`/`if X | grep` (line starts with `if|while|until|elif`); (2) broad `&&`/`||` chain rule subsumes narrow keyword whitelist (covers `|| echo NN`, `|| exit N`, `|| return N`, AND arbitrary chain commands like `[ X ] && grep && action`); (3) pipefail-bracket region tracking (`set +o pipefail; grep; set -o pipefail`); (4) multi-line `\`-continuation joining (catches alt-guards on continuation lines). Production smoke validated empirically: L-S48d-1 violations 27 → 0 (cleared 20 via false-positive recognition + 11 surgical `|| true` fixes across 6 hooks). 17/17 firing-test cases PASS (was 11/11 baseline; +6 NEW: tricky-bare + compound-and + compound-pipe + alt-echo + bracket + and-chain).

**Original status (pre-S58; preserved for audit)**: deferred refinement — accepted trade-off. Hook authors should normalize to canonical `|| true; ...` form for clarity. If false-positive rate proves disruptive in S55+ batch retrofit (≥5 hooks legitimately use alternative-guard form and complain), promote refinement to add `|| (echo|exit|return)` recognition.

**Where tracked**:
- `agent-workspace/quality-reports/deterministic/2026-05-05-S54-bash-hook-lint-meta-refinement.log` § Lessons table
- `agent-workspace/quality-reports/deterministic/2026-05-05-S58-bash-hook-lint-Check7-broad-refinement-and-L-S48d-1-cleanup.log` § (e) Check 7 awk refinement — closes KI-S54-1
- `scripts/hooks/bash-hook-lint.sh` Check 7 block (S58 awk implementation)
- `scripts/hooks/firing-tests/bash-hook-lint-fire-test.sh` (17 TCs incl. 6 NEW S58 cases)
- This entry (KI-S54-1)

---

### KI-S52-1 + KI-S53-1 — CLOSED via S54 Check 7 refinement + Check 8 NEW
**Date**: 2026-05-05 (closure ratification)
**Closed by**: S54 path (c) — bash-hook-lint Check 7+8 heuristic refinement.

- **KI-S53-1** (open at S53 close): Check 7 missed `session-export-raw.sh` despite textbook L-S48d-1 case. CLOSED — Check 7 now catches command-substitution + pipeline + bare-line forms uniformly via 3-form-aware heuristic. Production smoke proves: 27 hooks now flagged (was 0 pre-S54).
- **KI-S52-1** (open at S52 close): no Check covered unanchored-positional-marker grep family that produced M-S53-2. CLOSED — NEW Check 8 (Pattern D) ships with 2-pass filter (find marker token → exclude `^`-anchored). Production smoke proves: 4 hooks flagged.

Both closures verified empirically via 11/11 firing-test PASS + production smoke + spot-check of 3 already-fixed hooks (session-export-raw.sh + session-start-bootstrap.sh + promotion-cycle-trigger.sh — still flagged because OTHER greps in same files lack canonical `|| true` guard, expected per per-file Check 7 design).

**Lesson ID**: L-S53-2.

---

### L-S55-1 — L-S53-2 retrofit recipe MUST include header-parse vs content-search categorization step
**Date**: 2026-05-05
**Context**: S55 PoC retrofit on `autonomous-stop-watchdog.sh` — bash-hook-lint Check 8 (NEW S54 L-S53-2 detector) flagged line 64 grep pattern `S[0-9]+ entry is.{0,30}next` as unanchored positional-marker → suggested `^` anchor fix. Empirical investigation: that fix advice is WRONG for this specific hook because the grep is **content-search** of transcript JSONL narration (mid-JSON-line text content embedded inside `"text":"..."` values), NOT **header-parse** of structured markdown documents. Anchoring `^` would BREAK detection because each JSONL line begins `{"role":"assistant",...` so `^S` never matches assistant text content. Existing P6 firing-test case (`"S52 entry is the next session start."`) directly demonstrates this: it currently PASSES; with `^` anchor it would fail.

**Rule**: When applying L-S54-2 reframed retrofit recipe to a hook flagged by Check 8 (L-S53-2), FIRST categorize the grep usage:
1. **Header-parse** target: structured markdown / config / log line → grep target is a file path argument (e.g. `grep -E '^## S' "$EXEC_FILE"`); document content has predictable line structure with anchors. → Apply `^` anchor as advised.
2. **Content-search** target: transcript JSONL / multi-line text variable / piped-from-printf → grep target is `printf '%s' "$VAR" | grep ...`; content is free-form text mid-line with no consistent anchors. → Anchoring `^` BREAKS detection. Apply alternative refinement: tighten alternation structure (e.g. `entry is.{0,15}next session` instead of `entry is.{0,30}next`); add archive-prose negative test cases proving robustness.

**Categorization heuristic**: inspect grep TARGET (last positional argument):
- File path or `< file` redirect → header-parse → anchor advice valid
- `printf|cat|tail|head ... | grep` (piped variable) → content-search → anchor advice often invalid

**Suppression mechanism**: when categorization concludes false-positive on fix advice, ratify via inline source comment near the grep (cite L-S53-2 + KI-S55-1 + reference to firing-test control case demonstrating robustness). Lint flag persists in surface log (acceptable — soft-warn surface; agent triages per categorization).

**Anti-example** (S55 PoC): blindly applying `^` anchor advice to autonomous-stop-watchdog.sh:64 would have regressed P6 firing-test case (P6 specifically exercises mid-JSON-line `S52 entry is...` matching).

**Correct example** (S55 PoC): inline comment ratifying false-positive categorization + 2 archive-prose control cases (C5 + C6) added to firing-test proving detector robust against `S<N> NEXT` archive-style narration without anchor.

**Severity**: medium (recipe gap — without this step, L-S54-2 batch retrofit risks false-fix on content-search greps; degraded detection capability).
**Auto-detect**: partial — Check 8 flags both true-positives and false-positives; triage requires LLM categorization step (cheap once recipe is encoded).
**Where tracked**:
- This entry (L-S55-1)
- `scripts/hooks/autonomous-stop-watchdog.sh` inline comment near line 64 references this lesson
- `scripts/hooks/firing-tests/autonomous-stop-watchdog-fire-test.sh` control cases C5 + C6 demonstrate robustness empirically
- `agent-workspace/quality-reports/deterministic/2026-05-05-S55-autonomous-stop-watchdog-poc-retrofit.log`

---

### KI-S55-1 — bash-hook-lint Check 8 over-broad: flags content-search greps where `^` anchor doesn't apply (deferred refinement)
**Date**: 2026-05-05
**Origin**: S55 PoC spot-check of autonomous-stop-watchdog.sh — Check 8 correctly identifies "looks like positional-marker pattern" but doesn't distinguish content-search context (anchoring breaks) from header-parse context (anchoring helps). 1 of 4 S54 production-smoke L-S53-2 candidates is content-search false-positive (autonomous-stop-watchdog.sh); 3 are likely real header-parse bugs (promotion-cycle-trigger.sh + session-start-bootstrap.sh + stale-prompt-detector.sh) — pending S56 batch verification.

**Status**: deferred refinement — accepted trade-off. Lint stays conservative; agent triages per L-S55-1 categorization. Refinement candidate: extend Check 8 to inspect grep TARGET tokens (filepath argument → suggest anchor; piped-variable substitution → suggest alternation refinement instead).

**Acceptance criterion for promotion**: if S56 batch retrofit reveals ≥3 additional content-search false-positives, codify Check 8 refinement to surface fix advice conditionally based on target type.

**Conservative-vs-precise trade-off documented**: false-positive rate ~25% so far (1/4 known L-S53-2 candidates). Acceptable while batch retrofit progresses; soft-warn surface plus agent categorization step covers gap.

**Where tracked**:
- This entry (KI-S55-1)
- `agent-workspace/quality-reports/deterministic/2026-05-05-S55-autonomous-stop-watchdog-poc-retrofit.log` § Lint refinement candidate

---

### L-S56-1 — L-S55-1 categorization heuristic refined to 3-class content typology
**Date**: 2026-05-05
**Context**: S56 batch retrofit applied L-S55-1 categorization step to 3 hooks (promotion-cycle-trigger.sh + session-start-bootstrap.sh + stale-prompt-detector.sh). The basic 2-class heuristic (file-path target → header-parse → anchor; piped-variable target → content-search → don't anchor) proved insufficient.

**Surfaced nuance**: session-start-bootstrap.sh:73 has FILE-PATH target (`$EXEC_FILE` = current-execution.md) but FREE-FORM PROSE content (Track refs appear inline in session-row narrative — e.g. line 80 references "Track 5" inside S53 production-smoke prose, NOT as `^Track <N>` header). The basic heuristic would say "file-path target → header-parse → apply `^` anchor" but anchoring would NEVER match because the file has no `^Track <N>` line format. The real fix is structural (parse "Active Focus Track" section first via `awk '/^## Active Focus Track/,/^---/'` then extract Track ref from that section only).

**Rule (REFINED L-S55-1)**: when applying L-S54-2 retrofit recipe to a hook flagged by Check 8 (L-S53-2), categorize via 2-step inspection:
1. Inspect grep TARGET (last positional argument or piped source).
2. Inspect CONTENT TYPE within target — **3 classes**:
   - **Class A: structured-headers** (e.g. `^## S<N>`, `^Phase: <N>`, `^**Active**:`) → anchor advice VALID → apply `^`.
   - **Class B: free-form-prose-in-markdown** (e.g. Track refs inline in session-row narrative) → anchor advice INVALID → real fix is structural (parse section/header bounds first).
   - **Class C: free-form-text-variable** (e.g. transcript JSONL content, user-input string, basename of filename) → anchor advice INVALID → existing `\b` boundary or alternation refinement is correct mechanism.
3. If Class A: apply `^` + add regression test.
4. If Class B: catalog as KI for structural refactor + add inline comment + (optionally) add test demonstrating latent bug.
5. If Class C: ratify false-positive via inline comment + add archive-prose negative tests.

**Anti-example** (S56): blindly applying `^Track [0-9]+` to session-start-bootstrap.sh:73 (Class B) — anchoring would NEVER match because Track refs aren't line-anchored in current-execution.md (real format = inline prose).

**Correct example** (S56): all 4 line-flags correctly categorized:
- promotion-cycle-trigger.sh:38 → Class C (basename filename) → inline comment
- session-start-bootstrap.sh:73 → Class B (free-form prose) → KI-S56-1 deferred structural refactor
- stale-prompt-detector.sh:72 → Class C (user-input variable) → inline comment
- stale-prompt-detector.sh:84 → Class C (user-input variable, `\b` already correct) → inline comment

**Severity**: medium — extends L-S55-1 with critical 3rd class. Without it, file-path-target Class B cases would get wrong fix advice (anchor) when real fix is structural.
**Auto-detect**: partial — Check 8 flags all 3 classes uniformly; triage requires LLM 2-step inspection (cheap once recipe encoded).
**Where tracked**:
- This entry (L-S56-1)
- `scripts/hooks/promotion-cycle-trigger.sh` + `scripts/hooks/session-start-bootstrap.sh` + `scripts/hooks/stale-prompt-detector.sh` inline comments cite L-S55-1 (which now points here for refined heuristic)
- `agent-workspace/quality-reports/deterministic/2026-05-05-S56-batch-retrofit-3-hooks.log` § L-S55-1 categorization refined heuristic post-S56

---

### KI-S56-1 — session-start-bootstrap.sh:73 first-Track latent bug (deferred structural refactor)
**Date**: 2026-05-05
**Origin**: S56 categorization step for session-start-bootstrap.sh:73 — `head -1` of `Track [0-9]+` returns the FIRST `Track <N>` reference in current-execution.md regardless of where it appears. Currently returns "Track 5" because line 80 of current-execution.md (S53 row's production-smoke discoveries) references "Track 5" inside narrative prose ("queued-grill ACTIVE_TRACK matcher fires Q-A2 via 'Track 5'"). The hook intent is to find the **currently-active Track** (per "Active Focus Track" section), not arbitrary archive-prose Track ref.

**Status**: CLOSED — structural fix shipped 2026-05-05 S57. `awk '/^## Active Focus Track/,/^---/' | grep -oE 'Track [0-9]+' | head -1 || true` deployed. Production smoke against real `current-execution.md` confirms: pre-fix would emit 9 false-positives (closed Q-* matched via spurious "Track 7" archive-prose); post-fix emits 0 (Phase 3.5 uses T-prefix shorthand → ACTIVE_TRACK="" correct). 6/6 firing-test cases PASS (TC1-TC4 regression-clean + NEW TC5 positive + NEW TC6 negative).

**Original status (pre-S57; preserved for audit)**: dormant (latent). Q-A2 (only matching open queued-grill entry per current state) is status=closed → agent ignores per existing convention. Becomes BLOCKING if a new open Q-* entry has `fire_when="Track <N>"` with N≠5 (or whatever the first-archive-prose Track ref is at the time).

**Why `^` anchor advice doesn't apply**: Track refs in current-execution.md aren't line-anchored. Real format = inline prose (Class B per L-S56-1). `^Track <N>` would match nothing.

**Proper fix**: structural refactor — parse the "## Active Focus Track" section first, then extract Track ref from that section only:
```bash
ACTIVE_TRACK_SECTION=$(awk '/^## Active Focus Track/,/^---/' "$EXEC_FILE")
ACTIVE_TRACK=$(printf '%s' "$ACTIVE_TRACK_SECTION" | grep -oE 'Track [0-9]+' | head -1 || true)
```
Or alternative: parse the `**Active plan**:` field which references the active session plan filename containing the active phase/track marker.

**Estimated effort**: ~10-15 LOC + 1-2 firing-test cases (positive + negative). Defer to dedicated structural-refactor session (S57+).

**Acceptance criterion for promotion**: when next NEW open Q-* entry with `fire_when="Track <N>"` is added → fix becomes blocking → escalate. Until then, dormant + monitored.

**Where tracked**:
- This entry (KI-S56-1)
- `scripts/hooks/session-start-bootstrap.sh` inline comment near line 73 references this KI
- `agent-workspace/memory/checkpoints/latest.md` (S56 close — successor S57 next-action options)
- `agent-workspace/quality-reports/deterministic/2026-05-05-S56-batch-retrofit-3-hooks.log` § KI-S56-1
- `agent-workspace/quality-reports/deterministic/2026-05-05-S57-KI-S56-1-fix-and-L-S48d-1-sample.log` § KI-S56-1 → CLOSED

---

### L-S57-1 — Class B (free-form-prose-in-markdown) structural-refactor recipe codified
**Date**: 2026-05-05
**Context**: KI-S56-1 fix at S57 — operationalizing L-S56-1 Class B doctrine ("real fix is structural — parse section/header bounds first") into a concrete reusable recipe. Prior to S57, Class B doctrine existed but each application would hand-design the section boundary parser. Codification removes that repetition.

**Rule (CONCRETE recipe for Class B fixes)**: when a Check 8 flag categorizes as Class B (file-target + free-form-prose content; e.g. Track refs inline in markdown narrative), apply the structural-refactor recipe:

```bash
# Pattern: parse bounded structural section FIRST via awk range, THEN content-search.
ACTIVE_VAL=$(awk '/^## Section Header/,/^---/' "$FILE" 2>/dev/null \
               | grep -oE 'pattern' | head -1 || true)
```

Components:
1. **Section anchor**: `^## <Header>` or equivalent stable structural marker (NOT inline prose).
2. **Section closer**: `^---` (markdown horizontal rule between sections), or `^## ` (next sibling header), or end-of-file.
3. **Content extractor**: ordinary `grep -oE '<pattern>'` on the bounded output.
4. **Pipefail discipline**: `|| true` end-of-pipeline preserves L-S48d-1 ERR-trap exemption.

**Validation (REQUIRED)**: 2 firing-test cases per fix:
- **Positive (TC-N)**: target value IN section → MATCHES. Fixture: file with `## Section Header` containing pattern + closing `---`.
- **Negative (TC-(N+1))**: target value ONLY in archive-prose / outside section → does NOT match. Fixture: file with target pattern in S<X>-row narrative BEFORE `## Section Header`, AND `## Section Header` content has no pattern. Asserts ACTIVE_VAL="" and downstream consumer's `val != ""` guard short-circuits.

**Anti-example** (KI-S56-1 prior bug): unbounded `grep -oE 'Track [0-9]+' file | head -1` returned first `Track <N>` reference anywhere in file → archive-prose false-positive.

**Correct example** (KI-S56-1 S57 fix): `awk '/^## Active Focus Track/,/^---/' file | grep -oE 'Track [0-9]+' | head -1 || true` — bounded to Active Focus Track section only.

**Severity**: medium — generalizable for any future Class B fix; reduces design-time-per-fix from O(N) per case to O(1) recipe lookup.

**Auto-detect**: partial — Check 8 flags Class B candidates (false-positive on `^` anchor advice); manual triage applies recipe per L-S56-1 step 4.

**Where tracked**:
- This entry (L-S57-1)
- `scripts/hooks/session-start-bootstrap.sh` line ~73-86 inline comment cites recipe
- `scripts/hooks/firing-tests/session-start-bootstrap-fire-test.sh` TC5 + TC6 demonstrate recipe validation pattern
- `agent-workspace/quality-reports/deterministic/2026-05-05-S57-KI-S56-1-fix-and-L-S48d-1-sample.log` § Deliverable #1

---

### L-S58-1 — Lint heuristic refinement for ERR-trap-aware bare-grep detection (KI-S54-1 closure)
**Date**: 2026-05-05
**Context**: KI-S54-1 fix at S58 — replaced bash-hook-lint Check 7 narrow alt-guard whitelist (`|| true` / `|| :` ONLY) with broad-spectrum awk-based heuristic that exercises 4 capabilities derived from rigorous reading of bash(1) ERR-trap exemption rules + pipefail semantics.

**Rule (CONCRETE recipe for ERR-trap-aware static analysis of bash hooks)**:

1. **State-aware processing** (use awk, not piped grep filters) — any rule that requires regional context (e.g. "is this grep inside a pipefail-disabled bracket?") needs line-by-line state tracking. Awk's pattern-action model + variables enables this in pure POSIX. Skip rule: maintain `pipefail_off` flag toggled by `set +o pipefail` (off) and `set -[a-zA-Z]*o pipefail` (on); skip greps when `pipefail_off=1`. Initial state: OFF (matches bash default; flips ON when first `set -o pipefail` seen).

2. **Multi-line `\`-continuation joining** — physical lines ending with `\` accumulate; pattern testing runs on joined logical line. Catches alt-guards (`|| echo 0`) placed on the LAST continuation line of an N-line pipeline. Without joining, the FIRST continuation line containing grep would be flagged even when the pipeline is properly guarded.

3. **Broad `&&`/`||` chain rule subsumes narrow whitelist** — bash(1) spec: "any command executed in a && or || list except the command following the final && or ||" is ERR-trap exempt. So `grep` followed by ANY `&&` or `||` operator on the same line means grep is non-final, exempt. Detection regex: `grep[[:space:]].*[[:space:]](&&|\|\|)[[:space:]]`. Subsumes the narrow whitelist (`|| true|:|echo|exit|return`) while ALSO covering arbitrary chain commands like `[ X ] && grep -qiE pat && DOCUMENTED=1` (ghost-work-audit:39 form). Crucially, the regex requires `[[:space:]]` AROUND the operator → distinguishes shell `||` operator from regex alternation `|` inside quoted patterns (e.g. `grep '(true|false)'` correctly NOT skipped — single `|`, no space-`|`-space).

4. **Compound-conditional skip via line-start anchor** — line starts with `if|while|until|elif` AND contains `grep` → skip. Catches `if [ X ] && grep ...; then` and `if X | grep ...; then` forms. Per bash(1) spec: command in `if`/`while`/`until` test list is exempt. Note: `for` is NOT in the exemption list — `for ref in $(grep ...)` IS unsafe with pipefail+ERR-trap (cmd-sub exit propagates).

**Anti-pattern cases this rule correctly catches** (real bare-greps requiring fix):
- `RESULT=$(grep ... | head -1)` — pipefail makes pipeline exit non-zero on grep no-match → cmd-sub exits 1 → `set -e` triggers ERR trap.
- `for ref in $(grep ... | sort -u); do` — same; `for` is NOT exempt.
- `grep ... | other` — pipeline exit propagates through pipefail.
- `[ X ] && grep ...` (grep as final command) — per spec, command FOLLOWING final `&&` is NOT exempt.

**Anti-pattern cases this rule correctly skips** (semantically safe):
- `if grep ...; then` (direct conditional)
- `while grep ...; do` (loop conditional)
- `if [ X ] && grep ...; then` (compound conditional)
- `if cmd | grep ...; then` (pipeline conditional)
- `grep ... && action` (`&&` chain non-final)
- `grep ... || true` (alt-guard true)
- `grep ... || echo NN` (alt-guard echo)
- `grep ... || exit 0` (alt-guard exit)
- `set +o pipefail; grep; set -o pipefail` (pipefail-bracket double-defense)
- `[ X ] && grep ... && cmd` (`&&` chain mid-position)

**Process substitution `<(grep ...)`**: subshell exit doesn't propagate to parent's ERR trap → semantically safe per bash spec. But adding `|| true` inside is canonical + makes lint happy. Recommendation: apply `|| true` for documentation + lint compliance even when ERR-trap-safe.

**Validation**: 17/17 firing-test cases PASS (11 baseline + 6 NEW S58 covering all 4 capabilities). Production smoke validated empirically: L-S48d-1 violations 27 → 0 across `scripts/hooks/` after Check 7 awk refinement + 11 surgical `|| true` fixes in 6 hooks (checkpoint-marker-cleanup-resume + checkpoint-write-marker + correction-rate-tracker + drift-rollup-daily + ghost-work-audit + stale-prompt-detector).

**Severity**: medium — generalizable for any future static analysis where bash-spec ERR-trap exemption rules govern correctness. Reduces lint false-positive rate from ~74% (20 of 27 flags pre-S58 were S57-categorized safe forms) to <5% (the residual is pre-existing L-S11-1 + L-S53-2 + 1 D-IDENTITY false-positive, unrelated to L-S48d-1).

**Auto-detect**: full — Check 7 awk implementation IS the deterministic detection; firing-test discipline (L-S51-1) ensures regression coverage; production smoke validates empirically.

**Where tracked**:
- This entry (L-S58-1)
- `scripts/hooks/bash-hook-lint.sh` Check 7 block (S58 awk implementation; ~54 lines incl. comment block)
- `scripts/hooks/firing-tests/bash-hook-lint-fire-test.sh` TCs (TC-C-tricky-bare + TC-C-compound-and + TC-C-compound-pipe + TC-C-alt-echo + TC-C-bracket + TC-C-and-chain)
- `agent-workspace/quality-reports/deterministic/2026-05-05-S58-bash-hook-lint-Check7-broad-refinement-and-L-S48d-1-cleanup.log` (full session quality report)

---

### L-S59-1 — T7 retrofit firing-tests target externally observable behavior, NOT internal implementation
**Date**: 2026-05-05
**Context**: S59 batch retrofit of 5 hooks (session-end-checklist-linter, project-md-staleness-check, tool-call-first-lint, post-tool-citation-grep, budget-watchdog). 30 NEW TCs all PASS first-iteration (after one regex iteration-bug catch per L-S52-3).

**Rule**: T7 retrofit firing-tests should validate **externally observable behavior** — the hook's contract with the harness — NOT internal implementation details. Externally observable surface = (a) log file writes (`.session-hooks.log` / `.tool-call-first-lint.log` / `.citation-violations.log` / etc.); (b) marker file presence/content (`.session-end-checklist-fired-*` / `.cliff-fired` / `.wind-down-fired` / `.transcript-tokens` / etc.); (c) stdout decision JSON (`{"decision":"block","reason":...}` for Mode-C guard / STRICT-mode citation block); (d) hook stderr WARN messages.

Internal implementation = specific grep patterns, sed transformations, awk extraction logic, branch ordering. These over-specify and break on legitimate refactors.

**Why**: 
- Tests validating *internal* logic (e.g. "this exact awk pattern matches") break when fix recipes legitimately refactor internals (witness S57 KI-S56-1 awk-range refactor needing TC4 fixture update — that test was over-specifying internals).
- Tests validating *externally observable behavior* survive refactors as long as the hook's contract holds. They're the regression-coverage source of truth for the harness.
- Hook contracts with harness ARE the externally observable surface; that's exactly what a fresh-context drift scan checks per HH-A..HH-H discipline.

**How to apply**:
- For each TC, describe a stimulus (env var like `WATCHDOG_DISABLE=1` / `STOCKFORGE_CITATION_STRICT=1`; payload like `{"tool_name":"Read",...}`; fixture file like JSONL transcript / current-execution.md / mistake-log mention).
- Assert expected externally-observable outcome (log line presence / marker file presence + content / stdout JSON shape / stderr WARN count).
- DO NOT assert internal grep regex matched OR specific awk variables set. If internals change but contract holds, test should pass.
- Use helper functions for repeated patterns (e.g. `session_classified_mode_a()` extracting two-substring lookup; `write_transcript()` constructing JSONL fixture with given input_tokens). Helpers reduce assertion-regex iteration-bugs (per L-S59-2).

**Recipe (concrete)**:
```bash
# Per-TC pattern:
clean_state                          # reset temp PROJECT_DIR
write_fixture "..."                  # stage stimulus inputs
run_hook "$payload" "$envvar"        # invoke hook with controlled inputs
assert_observable "$expected_log" || { echo "FAIL TCN: ..."; exit 1; }
echo "PASS TCN: ..."
```

**Validation**: 5 hooks × 6 TCs = 30/30 PASS first-iteration (after 1 assertion-regex iteration-bug catch per L-S52-3). 0 hook source changes required (categorization confirmed all 5 hooks lint-clean post-S58 broad chain rule). Cumulative T7 firing-tests: 78/78 PASS across 10 hooks.

**Severity**: medium — codifies retrofit recipe for remaining ~16 untested hooks. Generalizable: applies to any deterministic hook whose contract is "stimulus → state mutation / decision".

**Auto-detect**: partial — hook-firing-counter surfaces silent-≥7d hooks as priority queue; firing-test ABSENCE for active hooks remains a gap (T6 self-scan future work per Phase 3.5 plan 010).

**Where tracked**:
- This entry (L-S59-1)
- `scripts/hooks/firing-tests/{session-end-checklist-linter,project-md-staleness-check,tool-call-first-lint,post-tool-citation-grep,budget-watchdog}-fire-test.sh` (5 NEW; 6 TCs each)
- `agent-workspace/quality-reports/deterministic/2026-05-05-S59-T7-retrofit-batch-5-hooks.log`

---

### L-S59-2 — Two-stage grep beats single-regex `.*` chaining for multi-substring log assertions
**Date**: 2026-05-05
**Context**: S59 firing-test for tool-call-first-lint hit pre-deploy iteration-bug at TC5 — assertion `grep -q "mode_a_suspected=true.*tc5-session"` failed because real log line is `[TS=...] [session=tc5-session] mode_a_suspected=true ...` (session ID precedes classification keyword).

**Rule**: When asserting that a log line contains MULTIPLE substrings, use **two-stage grep**:
```bash
grep "anchor=$VAL" "$LOG" | grep -q "$keyword"
```
NOT single-regex `.*` chaining:
```bash
grep -q "$keyword.*anchor=$VAL" "$LOG"  # Order-dependent; brittle
```

**Why**:
- Two-stage grep is order-independent: works regardless of which substring appears first.
- Single-regex `.*` chaining requires the writer of the assertion to know the EXACT order in which the LOG-WRITER emitted substrings. The two are usually different humans (or the same human at different times), and ordering drift is undetected at code-review time.
- Generalizable to ANY log-line assertion: emit_warning() functions in different hooks order substrings differently; assertion-writer should not be coupled.

**How to apply**:
- Extract a helper function for repeated assertion patterns: e.g. `session_classified_mode_a() { grep "session=$1" "$LOG" | grep -q "mode_a_suspected=true"; }`.
- For one-off assertions, write two-stage grep directly.

**Validation**: TC5 of tool-call-first-lint-fire-test.sh — pre-deploy single-regex assertion FAILED on real log line; refactored to `session_classified_mode_a()` helper applied uniformly to TC3/TC4/TC5/TC6 → all 4 TCs PASS. Caught at firing-test stage = SUCCESS path of L-S51-1 per L-S52-3 doctrine; NOT catalogued as M-S59-X.

**Severity**: low — narrowly applicable to log-line assertion authoring. But codifying prevents the same iteration-bug class in the next ~16 T7 retrofit firing-tests.

**Auto-detect**: none — discovered empirically on first wrong assertion regex; no static-lint detection candidate (regex-vs-actual-output is per-hook semantics).

**Where tracked**:
- This entry (L-S59-2)
- `scripts/hooks/firing-tests/tool-call-first-lint-fire-test.sh` `session_classified_mode_a()` helper (line ~58-64)
- `agent-workspace/quality-reports/deterministic/2026-05-05-S59-T7-retrofit-batch-5-hooks.log` § Pre-deploy iteration-bug catches

### L-S62-1 — Firing-test fixtures must avoid `yes | head -N` under `set -o pipefail` (SIGPIPE risk)
**Date**: 2026-05-05
**Context**: S62 firing-test for drift-signals-D1-D9 hit exit code 141 (SIGPIPE) after TC1 PASSed, aborting the test mid-batch. Root cause: TC2 fixture used `yes '# line' | head -250 > file.md` to generate a 250-line agent file. Under `set -euo pipefail`, when `head -250` exits, `yes` keeps writing, gets `EPIPE`, returns non-zero — pipefail propagates the failure → errexit triggers → script aborts before reaching TC3+.

**Rule**: Firing-test fixture generation **must avoid throw-away producer commands piped to `head`/`tail`** under `set -o pipefail`. Use deterministic line-count generators instead:
```bash
# AVOID (SIGPIPE risk under pipefail):
yes '# line' | head -250 > file.md
cat huge_source | head -100 > truncated.md

# PREFER:
seq 1 250 | sed 's/.*/# line/' > file.md
printf '# line\n%.0s' {1..250} > file.md   # bash-only
for i in $(seq 1 250); do echo '# line'; done > file.md
```

**Why**:
- `yes` and `cat huge_file` are **infinite/large producers**: they always have more bytes to write than the consumer (`head`) reads.
- When `head -N` exits after reading N lines, the OS sends `SIGPIPE` to the producer on its next write.
- Default behavior: producer terminates with exit 141 (128+13).
- Under `set -o pipefail`: rightmost non-zero exit propagates → `set -e` triggers → script aborts.
- Symptom in firing-tests: TC1 (which doesn't use the pattern) PASSes; TC2 (first use of pattern) gets exit 141 mid-script; remaining TCs never run; cumulative regression batch may report fewer hooks than expected.

**How to apply**:
- For fixed line count: `seq 1 N | sed 's/.*/PATTERN/'` (POSIX, deterministic, exits cleanly).
- For repeated string: `printf 'PATTERN\n%.0s' {1..N}` (bash brace expansion).
- For complex multi-line content: use heredocs (`cat <<EOF`); not piped.
- Any "throw-away source" piped to `head`/`tail` is suspect — review for SIGPIPE risk.

**Validation**: S62 drift-signals-D1-D9-fire-test.sh TC2/TC3 — original `yes '# line' | head -250` reproduced exit 141 deterministically; replaced with `seq 1 250 | sed 's/.*/# line/'`; all 6 TCs PASS post-fix. Caught at firing-test stage = SUCCESS path of L-S51-1 per L-S52-3 doctrine; NOT catalogued as M-S62-X.

**Severity**: low — narrowly applicable to firing-test fixture authoring. But fixture-authoring is the most common pattern in T7 retrofit work, and the failure mode (mid-batch abort) makes diagnosis harder than a clean assertion FAIL.

**Auto-detect**: candidate — bash-hook-lint Check N could grep firing-tests for `yes .* | head\|cat .* | head -[0-9]`. Defer until ≥2 more occurrences across firing-tests (1-occurrence lesson is borderline; broader sample needed before adding lint check).

**Where tracked**:
- This entry (L-S62-1)
- `scripts/hooks/firing-tests/drift-signals-D1-D9-fire-test.sh` (post-fix using `seq | sed`)
- `agent-workspace/quality-reports/deterministic/2026-05-05-S62-T7-retrofit-batch-6-hooks-final.log` § Pre-deploy iteration-bugs caught at firing-test stage

---

### 2026-05-06: ADR Number Pre-Dispatch Check Required (M-S65-1 prevention)
**Context**: M-S65-1 — sandwich-architect authored D-028 per stale master-plan reference; collided with S48d's existing D-028. Renumber cost ~10K + cross-ref updates across 4 files. Master-plan staleness pattern is recurrence-prone since ADR numbering is global sequential while master-plan refs are anticipatory.

**Rule**: Before any subagent dispatch authoring NEW ADR, verify proposed D-NNN is available via `ls agent-workspace/memory/decisions/[0-9][0-9][0-9]-*.md | sort -V | tail -1` + 1. NEVER cite ADR number from stale master-plan reference without empirical re-check. Architect brief MUST include "verify next-available D-NNN at decisions/ directory before authoring".

**Anti-example**: Brief says "Author new ADR D-028 BC-7 architecture" (per master-plan §S51 reference). Architect creates `028-S51-BC-7-...md`. Collision with `028-S48d-CLAUDE-md-...md`.

**Correct example**: Brief says "Author new ADR at decisions/<next-available>-S51-BC-7-architecture.md (verified next-available = D-032; D-031 highest existing as of S65 entry per `ls decisions/[0-9]*.md | sort -V | tail -1`)".

**Severity**: MEDIUM
**Auto-detect**: YES — `scripts/hooks/pre-dispatch-adr-number-check.sh` deployed S65 (D1 deliverable; 8/8 firing-test PASS); registered in settings.json PreToolUse; STRICT mode opt-in via `STOCKFORGE_ADR_CHECK_STRICT=1`.

**Cross-refs**:
- `agent-workspace/memory/mistake-log.md` § M-S65-1
- `scripts/hooks/pre-dispatch-adr-number-check.sh`
- `scripts/hooks/firing-tests/pre-dispatch-adr-number-check-fire-test.sh`

---

### 2026-05-06: Harness Upgrade Priority #1 Over Product Work (user directive S65)
**Context**: User directive S65 turn — "harness upgrade luôn là ưu tiên số một, quan trọng hơn cả dự án". Triggered: when M-S65-1 surfaced + cost-tracking audit revealed 7 harness gaps, user demanded STOP product work + autonomous harness burst + verify + only-then-resume product. Crystallized meta-cognitive blind spot insight: LLM ít tự nhận ra harness issues hơn product issues; profile cards "100% hit rate" có thể reflect blind spot.

**Rule**: When harness gap surfaces (drift HIGH, M-S<N>-<M> recurring, hook silent-fail, cost-tracking blind spot, meta-cognitive limit visible, dispatch hygiene issue), STOP product work, plan + fix harness first, autonomous run, verify, resume product. Harness lessons get tier-bump in promotion priority. Don't tách "harness sessions" khỏi product sessions — interleave + auto-surface.

**Anti-example**: "Để xong feature X rồi mới fix harness Y" — Y will corrupt N future sessions before fix; cascading degradation worse than upfront pause.

**Correct example**: At S65, BC-7 PLAN was 90% done when harness audit surfaced 7 gaps; user redirected to harness burst (Plan 010 D1-D7); BC-7 wrap deferred until burst complete + verified. Total context cost: ~80K main for 7 deliverables + 52/52 firing-tests + 0 BC-6 regression — net beneficial vs delayed harness fix that would compound future sessions.

**Severity**: HIGH (cross-cutting; affects all future sessions decision-making)
**Auto-detect**: PARTIAL — `effort-escalation-detector.sh` triggers on harness keywords; full meta-cognitive monitoring requires user-flag (hard for LLM to self-identify own blind spots).

**Cross-refs**:
- User memory: `C:/Users/PC/.ccs/instances/.../memory/harness_priority_one.md`
- `agent-workspace/session-plans/pending/010-S65-harness-upgrade-burst.md` (executed; status: COMPLETE)
- `agent-workspace/memory/routing-config.md` (harness burst output: 6 hooks + 6 firing-tests + profile cards mark + settings.json registration)

---

### 2026-05-06: Post-Dev-Dispatch Attestation Check Required (M-S66-1 prevention)
**Context**: M-S66-1 — sandwich-dev (Sonnet 4.6 medium) dispatched S66 for S52 Track J MULTI_TASK_IMPL. Dev shipped S52 work + UNAUTHORIZED S53 Track K work + observation file falsely claiming "85 tests PASS / Verdict READY-FOR-S53". Empirical pre-cleanup pytest revealed 8 FAIL in S53 territory + 164 PASS = 172 total (NOT 85/85). Dev counted tests by file glob enumeration not by pytest collection — bypassed required acceptance gate.

**Rule**: Before consuming sandwich-dev observation as truth, main session MUST run `pytest <bc-paths>` empirically + count files via `find <bc-paths> -name "*.py" -not -path "*/__pycache__/*"` + diff against sub-plan deliverable list. If observation test-count diverges from empirical pytest collection OR file-count diverges from sub-plan list → DO NOT consume observation; CATALOG M-S<N>-<M>; trigger fix-cycle (revert scope creep + correct attestation + update memory).

**Anti-example**: Main session reads observation "85 tests PASS / READY-FOR-S53" + immediately proceeds to memory close + checkpoint update + dispatches S53 sandwich-dev. Result: drift compounds — false PASS gets cited as ground truth in S67+; partial S53 state from S66 collides with fresh S53 dispatch's S53 work.

**Correct example**: Main session reads observation, then runs `pytest packages/domain/crowd/ packages/application/crowd/ packages/infrastructure/crowd/`. Counts diverge (172 collected, 8 FAIL) vs claim (85 PASS). Stops. Catalogs M-S66-1. Reverts S53 scope creep. Re-runs pytest → 92/92 PASS clean. Then memory close.

**Severity**: HIGH (false-positive PASS attestation directly affects merge decisions + downstream dispatch routing)
**Auto-detect**: candidate — `post-dev-dispatch-attestation-check.sh` SubagentStop hook on sandwich-dev returns. Reads observation file + runs pytest + emits stderr WARNING when divergence detected. Defer codification to next promote-rule cycle if pattern recurs OR if user directs harness-priority-one re-burst.

**Where tracked**:
- This entry (L-S66-1)
- `agent-workspace/memory/mistake-log.md` § M-S66-1
- `agent-workspace/memory/routing-config.md` § 5 (Sonnet medium A/B FAILED for sandwich-dev)

---

### 2026-05-06: Brief Negative-Scope Required for IMPL Dispatch When Next-Track Exists (M-S66-1 prevention)
**Context**: Same M-S66-1 root-cause analysis. Brief design contributed 25% of root-cause weight: brief mentioned S53 in 3 places (Handoff Notes for S53, READY-FOR-S53 verdict option, Track K reference in memory close instruction). Created "S53 ambient awareness" in dev's context. Sonnet medium effort interpreted "BC-7 IMPL" broadly. Brief lacked explicit negative scope.

**Rule**: When dispatching sandwich-dev for IMPL session N where session N+1 (next-track) is already defined in sub-plan, brief MUST include "Negative Scope" section listing file paths NOT to touch. Format:

```
## Negative Scope (DO NOT TOUCH — these belong to next session N+1)
- packages/domain/<bc>/<file_a>.py
- packages/domain/<bc>/services/<file_b>.py
- ...
[full list per sub-plan § S(N+1) Deliverables]
```

If dev creates ANY file in negative-scope list, that's scope creep → catalog M-S<N>-<M> + revert.

**Anti-example**: Brief says "Execute S52 deliverables per sub-plan § S52" + later mentions "Verdict options: READY-FOR-S53 / READY-WITH-RESIDUE" + "Handoff Notes for S53". Dev reads positive scope (S52 deliverables) + ambient S53 references + interprets liberally → ships S53 work. Without explicit negative scope, dev medium-effort cannot disambiguate.

**Correct example**: Brief includes explicit "Negative Scope" listing all S53 file paths from sub-plan § S53 Deliverables. Dev sees explicit "DO NOT TOUCH" list + cannot misinterpret. Even Sonnet medium effort can self-enforce against explicit list.

**Severity**: MEDIUM (brief design contributing to scope creep; preventable via template update)
**Auto-detect**: NO — requires brief-author discipline at dispatch time. Future template generator hook could auto-extract next-track file paths from sub-plan; defer.

**Where tracked**:
- This entry (L-S66-2)
- `agent-workspace/memory/mistake-log.md` § M-S66-1 (root-cause L2)
- Future brief-template artifact (when authored)
