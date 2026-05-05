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
