---
plan_id: 021-S340-harness-stabilization-sweep
target_session: S341
type: MULTI_TASK_IMPL
budget: 100-150K (proposed; Sonnet sufficient; Opus only if D1 root-cause investigation gets gnarly)
phase: B/D-overlap (HARNESS — not product work; per `harness_priority_one` doctrine takes
       precedence over Phase D continuation NDH/Vietstock/VietnamBiz adapters + Phase E
       Theme I Vietnamese NLP until 7 anomalies close)
track: Harness Stabilization Sweep — close 7 queued anomalies from S331-S339 close-bookkeeping
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md
                    (Theme L first IMPL cycle CLOSED S339; harness anomalies deferred for
                    dedicated FOCUSED_IMPL sweep per `harness_priority_one`)
predecessor: 020-S337-phase-d-theme-l-crawling-adapter (completed S339; PASS-WITH-CONCERNS;
             F3+F4+F5 carry-forward → this plan)
successor: S342 sandwich-verifier (AP-1 fresh-context, Opus, ~50K VERIFY budget)
architect: S340 sandwich-architect (background; this plan)
dispatched_by: S339-main turn (parent main session orchestrating harness PLAN-IMPL-VERIFY
               sandwich after Phase D Theme L close-bookkeeping)
authored: 2026-05-16
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent)
executing_agent: sandwich-dev (background dispatch S341; fresh-context; AP-1 verifier in S342)
status: pending-execution

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse (post 2026-05-14 mass-deletion; per current-execution.md § INCIDENT + RECOVERY)"
  - "R2 project-integrity-watchdog.sh Stop hook"
  - "R3 daily-backup.sh Stop hook"
  - "BEHAVIORAL HOLD § (1) — SYNC-GRILLING cadence + ROUTINE-IDLE close ritual SUSPENDED (carry-forward; do NOT recommend sync-grilling cadence as part of fixes)"

depends_on:
  - "D-060 (commit-policy-agent-may-commit — operational gate for S341 dev commit boundary; sandwich-dev commits own work, main commits architect-only outputs per dispatch-template-gap recovery pattern)"
  - "D-062 (atomic-write-doctrine — BINDING for any new state/marker writes introduced by D1/D2/D5)"
  - "D-064 (path-safety 5-invariant contract — BINDING for any new file-path code; uses helpers from packages/_shared/path_safety.py)"
  - "D-066 PROPOSED (Theme L adapter contract — F3 mypy noise carry-forward in D6 touches its consumer files; D-066 ratifies itself on commit per IMPL-tier severity-schema)"
  - "Charter v1.1 Principle 11 (Harness must self-verify firing — D1/D2/D3 ALL ship companion firing-tests + verification grids)"
  - "Charter v1.1 Principle 7 (Dogfood mandatory — fixes self-audited via the affected hook chains in same session)"
  - "I-S33 self-aware-agent invariant (harness reliability is the substrate for I-S33; fixing escalation-spam protects it)"
  - "agent-workspace/CLAUDE.md Contract Rule 1 (constitution immutable absent explicit human approval — sandwich-dev cannot edit constitution/; if D2 introduces atomic-write-cleanup-doctrine, it lands as PROPOSED ADR D-067 at IMPL tier with no cool-down)"
  - "CLAUDE.md AP-23 ritual demotion: 'Refinement-of-rule is AP-23 RED FLAG: 2nd instance mandates promote-or-retire (not inline accumulation)' — applied to #3 dispatch-template gap (3rd instance: PROMOTE NOW); deferred to #4 parallel-architect-dispatch (1st instance: HOLD)"
  - "CLAUDE.md `harness_priority_one` memory rule (harness/system improvement is always higher priority than product work)"
  - "scripts/hooks/escalation-engine.sh (D1 primary target; investigation source)"
  - "scripts/hooks/severity-classifier.sh (D2 atomic-write hardening target)"
  - "scripts/hooks/html-separator-check.sh + path-safety-check.sh + python-determinism-check.sh (D1 secondary investigation — re-emit cycle source)"
  - "scripts/hooks/destructive-command-guard.sh (D3+D4 PreToolUse hook precedent — pattern reference)"
  - ".claude/agents/sandwich-architect.md (D3 + D7 template subjects)"
  - ".claude/agents/sandwich-dev.md (D7 template subject for STEP 0.10 + observation-file required)"
  - "agent-workspace/session-plans/completed/020-S337-phase-d-theme-l-crawling-adapter.md (plan shape reference)"
  - "agent-workspace/memory/observations/sandwich-architect-S337-phase-d-theme-l-plan.md (observation format reference)"
  - "agent-workspace/memory/checkpoints/latest.md § Harness anomalies (the 9-item queue snapshot from S339 close)"
  - "agent-workspace/memory/checkpoints/2026-05-14-S317-close.md § 'PRIORITY 6 (hygiene): zero-byte junk files in repo root' (D5 evidence — 8 known stray basenames listed: `**Audience**:`, `=`, `=0.40.0`, `Agent`, `allow`, `Env-var`, `Hardcoded`, `Immutable`; current Glob confirms ALL 8 still present + 6 NEW arrivals since S317 — see § D5 below)"
  - "agent-workspace/constitution/architecture.md § AP-23 (ritual-demotion framework)"

binding_decisions:
  - "D-060 — agent MAY git commit (NOT push); S341 dev decides commit boundary"
  - "AP-23 promote-or-retire — applied at sub-track level: D3 = PROMOTE NOW (3rd instance); D4 = HOLD (1st instance, but DECIDE-IN-PLAN whether to include in S341 IMPL); D6 = INCLUDE this session (F3 carry-forward minor); D7 = INCLUDE this session (F4+F5 dispatch-template improvements)"
  - "AP-7 anti-vacuous-defer — every DEFER decision in this plan names (a) prerequisites + (b) revisit trigger; no 'Out-of-scope item N with no follow-up'"
  - "Karpathy P3 surgical-changes — every recommendation in this plan traces to anomalies #1-#7 from latest.md § Harness anomalies; NO invented harness work"
  - "VBW protocol mandatory — before recommending any hook change, READ the actual hook file; this plan cites file:line for every claim per I-S2"

hard_rules_acknowledged:
  - "no production code in THIS plan-session (CLAUDE.md § Session Types — never mix PLAN + IMPL; this plan is architect's; S341 is dev's)"
  - "no commits in THIS plan-session (sandwich-architect subagent has no Bash tool; main commits this plan output per D-060 + dispatch-template recovery pattern from S335/S337×2)"
  - "no charter / no constitution writes in THIS plan-session (0 charter / 0 constitution per S340 brief)"
  - "no human-workspace writes (notification source files in D1 may be touched at IMPL but that is S341 dev's scope, gated by `Write(human-workspace/notifications/**)` allow-list)"
  - "no AskUserQuestion gate this session (no charter/scope question; all decisions are IMPL-tier; per `full_autonomous_no_supervised` AskUserQuestion is for SCOPE/CHARTER only)"
  - "every plan claim cites source file:line (per I-S2 + AOM)"
  - "actual hook files read end-to-end via Read tool, not memory (VBW protocol)"
---

# S341 — Harness Stabilization Sweep (close 7 queued anomalies)

## § A. Session metadata

| Field | Value |
|---|---|
| Plan ID | 021-S340-harness-stabilization-sweep |
| Target session | S341 (sandwich-dev, MULTI_TASK_IMPL) |
| Verify session | S342 (sandwich-verifier, AP-1 fresh-context Opus) |
| Budget | 100-150K (Sonnet sufficient; Opus only if D1 root-cause investigation expands) |
| Phase | B/D-overlap (HARNESS — non-product) |
| Type | MULTI_TASK_IMPL |
| Wave / Theme | Wave-1 substrate-care; closes 7 queued anomalies from S331-S339 |
| Coordination paths off-limits during S341 IMPL | See § J |
| Predecessor | 020-S337 (S339 PASS-WITH-CONCERNS; F3+F4+F5 carry-forward → D6+D7) |

## § B. Predecessor + invocation context

**Why this session now**: per CLAUDE.md `harness_priority_one` memory rule, harness/system
improvement takes precedence over product work whenever surfaced as blocking or
recurrence-pattern. The S339 close-checkpoint (`agent-workspace/memory/checkpoints/latest.md`
lines 58-69) listed **9 harness anomalies** carry-forward; **3 are AP-23 promote-now**
(#3 dispatch-template gap 3rd-instance per CLAUDE.md ritual-demotion rule "Refinement-of-rule
is AP-23 RED FLAG: 2nd instance mandates promote-or-retire"), and the escalation-engine
HIGH-spam (#1) is the **4th+ consecutive false-fire** noted across S335-S339, costing
~3 system-reminder lines per UserPromptSubmit/Stop/SessionStart cadence.

This plan closes **7 of the 9**, defers 2 with explicit AP-7 follow-up triggers:
- #3 html-separator-check Stop-mode summary line fluctuates → DEFER (different scan modes
  Stop vs PostToolUse already documented in `latest.md` S331-S334 row; investigate after
  D1 lands because D1 may surface the same fire-context distinction)
- #4 HH-6 legacy stale=3 dispatch sidecars → DEFER (aging out via 12h rotation; should
  clear naturally per S339 close note line 63; revisit if still present in 24h post-S341
  commit)

**What surfaced from S339 verifier explicitly**:
- F3 IMPORTANT-adjacent MINOR: `object`-typed DI fields (`packages/application/news/ports/crawler_adapter.py:83` `_sleeper`-style + `packages/infrastructure/news/crawler_adapters/cafef_adapter.py` similar) produce ~12 mypy unused-ignore lines → D6
- F4 MINOR: STEP 0.10 baseline `--help` not captured verbatim in S338 dev session log → D7 dispatch-template improvement
- F5 MINOR: sandwich-dev observation file omitted (only session log + ADR) → D7 dispatch-template improvement

**What the empirical investigation found** (this architect's VBW pass):
1. **D1 root cause CONFIRMED**: the 3 source hooks (`html-separator-check.sh:226-245` +
   `path-safety-check.sh:301-320` + `python-determinism-check.sh:221-239`) **regenerate**
   their respective `*-warn.md` notification files at every Stop / PostToolUse cycle
   when violations are present. The notifications use **fixed-name idempotent writes**
   (post-S318 fix per `checkpoints/2026-05-14-S317-close.md` line 71-72) — but each
   `printf '...' > "$NOTIF_FILE"` call mtime-touches the file, so
   `severity-classifier.sh:188 [ "$age" -le 24 ]` ALWAYS sees them as fresh + `:190 nlevel`
   parses `level: pending` (NO `level:` frontmatter at all in 2 of 3 files; see § G evidence
   row 1) → falls back to `case "$nlevel" in ... *)` body-grep at line 200-211 which finds
   keyword `ALERT` → classifies as HIGH every cycle → `escalation-engine.sh:166-168`
   UserPromptSubmit always emits the HIGH system-reminder. There IS a hour-bucket marker
   at line 56 (`.escalation-fired-${EVENT}-${BUCKET}`) but line 113-115 explicitly bypasses
   it for UserPromptSubmit (`UserPromptSubmit) ;;  # always emit injection`).

   The HIGH spam is **NOT false** (the underlying violations EXIST per W0-substrate hooks)
   — it's REDUNDANT per session. Per-fire stale-cache check is the missing piece.

2. **D2 confirmed**: 6 stray `.severity-state.tsv.tmp.*` files present at `agent-workspace/memory/`:
   `.tmp.{622,898,971,1186,1452,1521}`. The brief listed 5; this architect's Glob found
   1 additional (`.tmp.898`). `severity-classifier.sh:33` creates these via
   `TMP="$STATE_FILE.tmp.$$"` then `:217 mv -f "$TMP" "$STATE_FILE"` — if the process
   crashes/is-killed between the two, the `.tmp.<pid>` is leaked. No `trap EXIT cleanup_tmp`
   anywhere in the script. Read `.tmp.622` showed only the header (no rows) — confirming
   interrupted partial write.

3. **D3 confirmed**: `.claude/agents/sandwich-architect.md:5` frontmatter
   `tools: [Read, Glob, Grep, Write]` — **NO Bash**. Sandwich-architect CANNOT
   `git commit` its plan output. Recurrence: S335 (D-065 PROPOSED via architect plan)
   + S337 first-pass (plan-020 base) + S337 second-pass (plan-020 enhancement) = **3rd
   instance** per S339 close-checkpoint line 32 + per AP-23 promote-now mandate.

4. **D4 partially confirmed**: parallel-architect-dispatch was a 1st-instance event at
   S337 (per checkpoint line 33). Mode-D continue-injector COULD re-dispatch architect
   during /clear+continue keep-alive window. AP-23 → HOLD (1st instance), but DECIDE
   here whether to include in S341 IMPL pre-emptively or defer to true 2nd instance.

5. **D5 confirmed AND EXPANDED**: this architect's Glob `[A-Z]*` at repo root found
   the S317-known 8 stray basenames PLUS 6 newer ones:
   - **S317-era 8** (per `checkpoints/2026-05-14-S317-close.md:74`): `**Audience**:`,
     `=`, `=0.40.0`, `Agent`, `allow`, `Env-var`, `Hardcoded`, `Immutable`
   - **NEW since S317** (from current Glob output — sub-architect verified):
     `Implements`, `Most`, `Populate`, `Session`, `Source`, `Append-only.`, `Numbered,`,
     `Run`, `Things`, `Measured`, `Stock-specific`, `Companion`, `Per`, `This`, `Hardcoded`
     (dup), `NOTICE` (legitimate file from S338 — NOT stray)
   
   So `D5 cleanup` is larger than originally thought: **~20 stray files** (subtract
   legitimate `NOTICE`). Root-cause hunt: any hook with `echo "..." > $somevar` where
   `$somevar` is shell-expanded from a prompt fragment + whitespace-tokenized. Need
   defensive grep across `scripts/hooks/**` for shell-redirect-to-variable patterns
   without `set -u` defense.

6. **D6 + D7 carry-forward** — covered above in brief.

## § C. Charter compliance map

This plan ships **0 charter edits / 0 constitution writes**. Confirmation matrix:

| Boundary | Status | How protected |
|---|---|---|
| PROJECT_CHARTER.md | UNTOUCHED | not in any sub-track's file list |
| agent-workspace/constitution/** | UNTOUCHED | sandwich-dev cannot Write here (.claude/settings.json line 97 deny); if D2 atomic-write doctrine needs codification, lands as IMPL-tier PROPOSED ADR D-067 only |
| obsidian-vault/raw/** | UNTOUCHED | not in any sub-track's file list |
| Principle 11 (Harness self-verify firing) | UPHELD | D1/D2/D3/D4 sub-tracks ALL ship companion firing-tests under `scripts/hooks/firing-tests/` |
| Principle 7 (Dogfood) | UPHELD | D1 dogfoods escalation-engine in same session (verify spam stops) |
| I-S1 (No LLM math) | N/A | no LLM-emitted numerics in any sub-track |
| I-S2 (Source + as-of) | UPHELD | every architectural claim in this plan cites file:line |
| I-S22 (Data lineage) | UPHELD | telemetry-coverage maintained; no hook removed without replacement coverage |
| I-S33 (Self-aware agent invariant) | UPHELD | escalation reliability IS the substrate for I-S33; D1 fix protects it |
| I-S35 (Research-aid framing) | N/A | no thesis-output paths touched |

## § D. Sub-track decomposition

Order optimized to minimize blast radius: D1 first (highest value, blast-radius scoped to
3 hooks + classifier + engine), D2 second (atomic-write hardening), D3 third (PreToolUse
hook addition), D7 fourth (template improvements; minimal blast), D6 fifth (2-file mypy
fix), D5 last (cleanup + root-cause hunt), **D4 = DECIDE: DEFER** (see below).

---

### D1. Escalation-engine HIGH-spam fix (root cause: source-hook regeneration → severity-classifier mtime → escalation re-emit)

**Anomaly**: #1 (4th+ consecutive false-fire across S335-S339). Per UserPromptSubmit/Stop/
SessionStart cadence, `escalation-engine.sh:166-168` emits a HIGH system-reminder citing
the same 3 notification files every cycle.

**Empirical investigation finding** (this architect's VBW, ~15 min reading 6 hooks):

The cascade is:
1. `python-determinism-check.sh:241 NOTIF_FILE="$NOTIF_DIR/python-determinism-warn.md"` +
   `:243 } > "$NOTIF_FILE"` regenerates the file when violations > 0.
   Same pattern at `html-separator-check.sh:231-245` + `path-safety-check.sh:306-320`.
2. The `>` redirect mtime-touches the file even if **content is byte-identical**.
3. `severity-classifier.sh:188 [ "$age" -le 24 ] || continue` filters by mtime; since
   the regeneration just happened, age = 0h, file is admitted.
4. `:190 nlevel=$(head -10 "$n" 2>/dev/null | grep -m1 '^level:' | sed ...)` extracts
   frontmatter — but `python-determinism-warn.md` has NO `level:` frontmatter (the file
   this architect Read shows it starts with `# python-determinism-check — ALERT` at
   line 1 — no frontmatter at all). The other two (`html-separator-warn.md` line 1-4 +
   `path-safety-warn.md` line 1-4) have `status: pending` but **NO `level:`**.
5. `:200 *)` fallback branch runs body-grep at `:202`. Body contains "ALERT" keyword →
   `:204 grep -q "ALERT\|alert\|URGENT"` matches → classified as HIGH (line 205).
6. `escalation-engine.sh:122` `HIGH_N > 0` + `HAS_HIGH_DELTA=1` (because hour-bucket
   marker absent at first fire OR UserPromptSubmit cadence bypasses marker per `:113-115`)
   → appends to urgent.md.
7. `:161-168` UserPromptSubmit explicit emit (the system-reminder spam).

**Options considered**:

| Option | Mechanism | Pro | Con | Verdict |
|---|---|---|---|---|
| (a) Source-hook content-hash dedup | Source hook computes sha256 of new content; if matches existing file content, SKIP the write; mtime preserved | Surgical at root cause; 3 hooks × ~5 LOC each; preserves "violations still present" state | None — surgical | **PICK** |
| (b) Escalation-engine UserPromptSubmit cadence skip if same items already emitted this hour | Extend hour-bucket marker to record HIGH set as comma-joined hash; compare on re-fire | Doesn't touch source hooks | Bandaid (root cause still re-touches mtime); marker file proliferation; doesn't fix underlying repeated stat calls | REJECT |
| (c) Notification file age-out (rotate or delete after 24h) | urgent-md-rotate.sh-style pattern for warn notifications | Reduces backlog | Doesn't fix the per-cycle re-emit (regeneration < 24h) | REJECT |
| (d) Hybrid (a)+(b) | Both layers of defense | Defense-in-depth | Over-engineering; (a) alone is sufficient per empirical chain | REJECT |

**Recommendation = Option (a) — source-hook content-hash dedup**

Implementation (sandwich-dev): in each of the 3 source hooks
(`html-separator-check.sh` + `path-safety-check.sh` + `python-determinism-check.sh`),
before the `>` redirect to `$NOTIF_FILE`, compute the proposed new content into a
shell variable, compute sha256 of variable, compare against sha256 of existing file
content (if exists). If equal: SKIP the write entirely (preserves mtime → severity-
classifier filters via `age <= 24` continues to admit but: classifies LOW because
**we will also add `level: WARN` frontmatter** to the regenerated content so it
classifies as MEDIUM not HIGH — see below). If different: rewrite + mtime updates
(legitimate new violation).

**Companion frontmatter fix**: in each of the 3 source hook regeneration blocks, add
`level: WARN` to the YAML frontmatter so `severity-classifier.sh:196 WARN|warn|Warn`
branch fires → MEDIUM → DIGEST not HIGH+ESCALATION. The hooks document themselves as
WARN-severity per their own headers (`html-separator-check.sh:35` "severity=HIGH (ERR)
/ severity=MEDIUM (WARN)"; `path-safety-check.sh:22` same; `python-determinism-check.sh:15-16`
"HIGH ... severity-schema.md Layer 4"). The current absence of `level:` frontmatter
means they fall through to body-grep — fixing the frontmatter is the **correct semantic**:
when the hook detects an ERR-rule violation, the file is named `*-warn.md` (legacy from
S318 fix), but the embedded violations include both ERR + WARN; the right pattern is to
classify the FILE as WARN-tier (notification-of-violations is informational; the ERR-tier
rules are enforced at PostToolUse where they can block, not at Stop where they just
inform).

Per § Charter compliance: WARN-tier is appropriate because these notifications are
agent→human informational pushes (`agent-workspace/constitution/severity-schema.md`
referenced via S317-close). They do NOT block autonomous mode (CRITICAL does, per
`severity-classifier.sh:71`). HIGH is reserved for genuinely-actionable bundles
(`escalation-engine.sh:74-84` HIGH_QA_ROWS is the "must fire AskUserQuestion"
class; notification files are explicitly NOT in that class per `:127-131`).

**Verification at S341 IMPL** (sandwich-dev MUST):
- Run a synthetic Stop cycle: trigger HS-R1 violation in a temp file (e.g. echo "###
  heading 1\n... 200 lines ... \n### heading 2" > test.md in audited zone), confirm
  notification regenerated with `level: WARN` frontmatter, confirm `severity-state.tsv`
  classifies as MEDIUM, confirm escalation-engine does NOT emit HIGH system-reminder.
- Run second cycle WITHOUT modifying violations: confirm notification file mtime
  UNCHANGED (content-hash matched), confirm classifier still admits + classifies MEDIUM,
  confirm urgent.md does NOT get new ESCALATION row, confirm escalation-engine SYSTEM-
  reminder NOT emitted (HAS_HIGH_DELTA logic + no new urgent.md row).
- Run third cycle with modified violation list: confirm notification regenerated +
  classified correctly + escalation-engine emits ONCE per hour-bucket per cadence.

**Companion firing-test**: NEW `scripts/hooks/firing-tests/escalation-spam-dedup-fire-test.sh`
exercising the 3-cycle scenario above. Plus extend existing
`scripts/hooks/firing-tests/{python-determinism-check,html-separator-check,path-safety-check}-fire-test.sh`
with one TC each verifying content-hash dedup branch + level frontmatter presence.

---

### D2. Stale .tmp orphan cleanup + atomic-write hardening (root cause: severity-classifier mv crash without trap-EXIT)

**Anomaly**: #2. 6 stray `.severity-state.tsv.tmp.<pid>` files present (latest commit lists 5; this architect found 6 — see § B finding 2).

**Root cause**: `severity-classifier.sh:33 TMP="$STATE_FILE.tmp.$$"` + `:53 emit_row >> "$TMP"` + `:217 mv -f "$TMP" "$STATE_FILE"` — but no `trap` ensuring cleanup on early exit (the `trap 'exit 0' ERR` at `:17` is for ERR signal, not EXIT). Per D-062 atomic-write-doctrine, the right pattern is `trap 'rm -f "$TMP" 2>/dev/null || true' EXIT`.

**Two-part fix**:

**D2.1 — cleanup of 6 existing orphans + janitor for future leaks**:
- Approach A: One-shot cleanup in S341 IMPL (`rm -f agent-workspace/memory/.severity-state.tsv.tmp.*` — gated by destructive-command-guard.sh `:77` `.severity-state` safe-allowlist regex, so it'll pass).
- Approach B: Add a janitor invocation at Stop hook ordering BEFORE `severity-classifier.sh` (or at SessionStart) that does `find agent-workspace/memory -maxdepth 1 -name '.severity-state.tsv.tmp.*' -mmin +60 -delete 2>/dev/null` — matches the safe pattern at `destructive-command-guard.sh:83-87` (`-maxdepth + -name`).

**Recommendation**: BOTH. (A) cleans up the historical mess (one Bash invocation in dev's IMPL session); (B) prevents recurrence (insert as 1-line Stop hook BEFORE severity-classifier.sh OR inline into severity-classifier.sh's header block).

**D2.2 — atomic-write trap EXIT hardening in severity-classifier.sh**:
- Add at line 18 (after `trap 'exit 0' ERR`): `trap 'rm -f "$TMP" 2>/dev/null || true' EXIT`
- BUT the trap can't reference `$TMP` before it's defined at `:33`. Two fixes:
  - **(a)** Define `TMP=""` at top, then `trap` references `"$TMP"` early-binding-OK because trap evaluates at signal time, not at registration. Late-set `TMP=...` at line 33 propagates correctly to trap.
  - **(b)** Use `mktemp` instead of `$$` for the tmp file path (standardize across all hooks per D-062). `path-safety-check.sh:50` already does `mktemp /tmp/...` — pattern precedent.
  - **Recommendation**: (a) is more surgical (1-2 LOC change, preserves existing pattern); (b) is more idiomatic but is a wider refactor for follow-up.

**Sister hooks audit**: Per D-062 atomic-write-doctrine, EVERY hook that uses `tmp.$$ + mv -f` pattern should have `trap EXIT cleanup`. Sandwich-dev MUST grep `scripts/hooks/*.sh` for `tmp\.\$\$\|\.tmp\.\$\$` to find peers; AT MINIMUM document any found in dev session log even if not fixed this session (AP-7 prerequisites + revisit trigger).

**ADR**: If new janitor approach lands (D2.1.B), document as PROPOSED `agent-workspace/memory/decisions/067-atomic-write-tmp-cleanup-doctrine.md` at IMPL tier (no cool-down per severity-schema). Schema follows D-062 template. **Architect decision**: ADR D-067 is OPTIONAL — if the fix is small (just adding `trap EXIT` to ONE file + cleanup invocation), no ADR needed; it's a bugfix not a doctrine. ONLY draft ADR D-067 if D2.1.B (janitor hook) is created as a separate hook file (then it's worth documenting the doctrine).

**Companion firing-test**: Extend `scripts/hooks/firing-tests/severity-classifier-fire-test.sh` (verify exists first) with: TC: kill -TERM during tmp write, confirm trap fires, confirm no orphan left. If firing-test file doesn't exist, NEW `scripts/hooks/firing-tests/severity-classifier-fire-test.sh` with 3 TCs (happy path / kill -TERM / kill -INT).

---

### D3. Sandwich-architect dispatch-template hook (3rd-instance PROMOTE NOW per AP-23)

**Anomaly**: #5 from latest.md (meta-lesson 3rd instance). Per CLAUDE.md
ritual-demotion rule: "Refinement-of-rule (lesson-about-lesson) is AP-23 RED FLAG:
2nd instance mandates promote-or-retire (not inline accumulation)". This is the **3rd
instance** (S335 + S337 first-pass + S337 second-pass = 3 architect dispatches that
needed main to commit because architect has no Bash). **PROMOTE NOW** = mandatory.

**Empirical evidence** (this architect's VBW):
- `.claude/agents/sandwich-architect.md:5` frontmatter `tools: [Read, Glob, Grep, Write]` — NO Bash. Confirmed.
- `.claude/settings.json:138-558` hook configuration shows PreToolUse hooks DO exist
  and pattern-match via `"matcher": ".*"` (line 527).
- `scripts/hooks/destructive-command-guard.sh:30-44` is the precedent PreToolUse hook
  that reads stdin JSON for `tool_name` + `tool_input.command`. Same JSON-parse pattern
  can extract `subagent_type` from `Agent` tool calls.

**Recommendation**: NEW `scripts/hooks/pre-dispatch-architect-commit-guard.sh` PreToolUse
hook (similar shape to `destructive-command-guard.sh`). Logic:

1. Read stdin JSON.
2. If `tool_name != "Agent"`, exit 0 (allow).
3. Parse `tool_input.subagent_type`; if `!= "sandwich-architect"`, exit 0 (allow).
4. Parse `tool_input.prompt` (or `tool_input.description` — verify which Agent tool field
   contains the dispatch prompt by reading Claude Code Agent tool docs OR by inspecting
   existing dispatch-jsonl-recorder.sh which already parses the same payload).
5. If prompt regex-matches `git commit|git add|git mv|git push`, emit blocking warning
   to stderr ("architect cannot commit; main session must commit per D-060") + exit 2
   (block). Else exit 0 (allow).
6. Optional: also block if prompt asks architect to "execute" or "run" commands that
   would need Bash (defensive). KEEP MINIMAL initially per Karpathy P3 — start with
   git commands only; expand if false-negatives surface.

**Wire-up**: insert as a new hook entry in `.claude/settings.json` `"PreToolUse"`
section AFTER `destructive-command-guard.sh` (line 530-531) BEFORE
`autonomous-block-enforcer.sh` (line 533-535). One JSON entry; ~5 LOC.

**Override**: `STOCKFORGE_ALLOW_ARCHITECT_COMMIT=1` env bypass (mirrors `destructive-
command-guard.sh:50-57` pattern) for the rare case where architect's prompt legitimately
mentions "git commit" in a non-action context (e.g. quoting a prior commit hash).

**Companion firing-test**: NEW `scripts/hooks/firing-tests/pre-dispatch-architect-commit-guard-fire-test.sh`
with ≥6 TCs:
- TC1: Agent + sandwich-architect + prompt contains "git commit" → BLOCKED (exit 2)
- TC2: Agent + sandwich-architect + prompt clean → ALLOW (exit 0)
- TC3: Agent + sandwich-dev + prompt contains "git commit" → ALLOW (dev can commit)
- TC4: Bash + clean → ALLOW
- TC5: env STOCKFORGE_ALLOW_ARCHITECT_COMMIT=1 + sandwich-architect + "git commit" → ALLOW (bypass)
- TC6: stdin empty → ALLOW (defensive)

**Update sandwich-architect.md template** (companion): add explicit § Constraints note:
"Sandwich-architect has NO Bash tool. Plan output ends at file write; main session commits
per D-060 + this PreToolUse guard hook." This makes the contract explicit so future
architects don't try.

---

### D4. Parallel-architect-dispatch detection (1st-instance — DECIDE: INCLUDE or DEFER)

**Anomaly**: #6 from latest.md. AP-23 status = HOLD (1st-instance only). S337
parallel dispatch was a clean recovery (second architect detected first's scaffolding
+ additively enhanced). Mode-D continue-injector is the suspected root cause.

**Architect decision: DEFER from S341 IMPL** per AP-23 1st-instance discipline.

**Rationale** (AP-7 anti-vacuous-defer — prerequisites + revisit trigger named below):
1. AP-23 explicitly says "2nd instance mandates promote-or-retire" — implementing on
   1st instance is over-engineering per Karpathy P2 (Simplicity First). The S337
   clean recovery suggests the architects are robust to this case (additive enhancement
   pattern works).
2. The Mode-D continue-injector root cause may itself be the fix-point (de-dupe at
   continue-injector level, not at PreToolUse level). Investigating Mode-D first costs
   less than building a process-detection PreToolUse hook that's only useful if Mode-D
   can't be fixed.
3. Process-detection on Windows is non-trivial (no portable `pgrep` for subagent IDs;
   would need to query Claude Code session-internals which aren't externally observable).

**Prerequisites for revisit**: (a) 2nd instance of parallel-architect-dispatch fires
(then PROMOTE per AP-23); OR (b) Mode-D continue-injector audit lands as a separate
harness FOCUSED_IMPL session (then defer the PreToolUse hook entirely if Mode-D fix
covers it).

**Revisit trigger**: next instance of parallel-architect-dispatch detected in any
session close-checkpoint, OR `mode-d-continue-injector.sh` audit results, OR Q-INT
question raised by main session if this pattern shows up in S342/S343/etc.

**Tracking**: do NOT create AP-7-vacuous "Out-of-scope item N"; this DEFER is recorded
in § L AP-23 attestation explicitly with revisit trigger.

---

### D5. Repo-root zero-byte stray cleanup + offending-hook root cause hunt

**Anomaly**: #2 from latest.md (carry-forward from S317 close). This architect's
empirical Glob `[A-Z]*` at repo root found ~20 stray files (S317-era 8 still present
+ ~12 new arrivals).

**Empirical evidence**:
- `checkpoints/2026-05-14-S317-close.md:74` listed 8 known stray basenames; current Glob
  confirms ALL 8 still present (`Env-var`, `Hardcoded`, `Immutable`, `Agent`, etc.).
- Additional strays found by this architect: `Implements`, `Most`, `Populate`, `Session`,
  `Source`, `Append-only.`, `Numbered,`, `Run`, `Things`, `Measured`, `Stock-specific`,
  `Companion`, `Per`, `This` (these look like prose tokens — e.g. "Stock-specific" appears
  multiple times in CLAUDE.md as a section heading word).
- These are NOT in git index (no `git add` recorded these). They're filesystem-only.

**Working hypothesis** (per S317 close + latest.md "buggy hook with cwd-relative-write
fallback"): some hook does `echo "$VAR" > somefile` where `$VAR` is shell-expanded from
a prompt fragment + word-splitting on whitespace turns the FIRST word into the redirect
target. Specifically: `echo "Some prose" > $var_holding_filename` — if `$var_holding_filename`
is unset/empty AND `set -u` is missing, `> ` becomes `> Some` (because shell sees no
target and word-splits the prose). This requires:
- Hook running with cwd = stockforge root (true for ALL Claude Code hooks per docs)
- Hook doing redirect with unquoted variable expansion
- Hook lacking `set -u`

**Two-part fix**:

**D5.1 — One-shot cleanup of ~20 stray files**:
- Bash command (gated by destructive-command-guard.sh): `find . -maxdepth 1 -size 0 -type f -not -path './.git*' -not -name '.gitignore' -not -name '.gitattributes' -delete` (passes the safe-allowlist at `destructive-command-guard.sh:83-87` because of `-maxdepth + -name`).
- ALTERNATIVELY: explicit list of basenames known stray (safer, less risk of deleting legit zero-byte files).
- **Recommendation**: Explicit list (~20 basenames). Document each as cleanup target in
  S341 dev session log; commit each removal in a separate `git rm` for audit.

**D5.2 — Offending-hook root cause hunt**:
- Sandwich-dev: grep `scripts/hooks/**` for `echo .* > \$[a-z]\|printf .* > \$[a-z]`
  patterns where the variable on the RHS is NOT in `[[:upper:]]` (uppercase convention
  suggests env-var; lowercase suggests local) AND `set -u` is absent from script header.
- For each candidate match, READ the hook + verify if it's a real cwd-relative-write
  vulnerability OR a false positive.
- Document findings in S341 dev session log; if root cause IDENTIFIED, fix in same session
  by quoting the variable + adding `set -u`. If NOT identified, document the candidates
  + mark for follow-up (AP-7 trigger: stray file appears again after cleanup).

**Out of scope**: this sub-track is BUDGET-CAPPED at 30 min of S341 dev's time. If
investigation doesn't find root cause within budget, ship cleanup only + mark
"root cause TBD; revisit on next stray file appearance" in dev session log + close
the sub-track (do not block other sub-tracks on this).

**Companion firing-test**: NONE this session (insufficient root cause; can't write
firing-test for unknown bug). Add when root cause confirmed.

---

### D6. F3 mypy noise fix (object-typed DI fields)

**Anomaly**: F3 MINOR from S339 verifier. Anomaly #7 in latest.md harness queue.

**Empirical evidence**:
- `packages/application/news/ports/crawler_adapter.py:60` `def __init_subclass__(cls, **kwargs: object) -> None:` — `object` typing here is fine (kwargs).
- `apps/_shared/crawl/rate_limiter.py:83` `_sleeper: object = field(default=sleep, repr=False)` — uses `object` to dodge mypy complaints about Callable variance; falls through to `type: ignore[operator]` at `:119` (1 line) when called. Per F3 finding: 12 mypy unused-ignore lines across the new files (this architect could not run mypy due to known project-wide `mypy --strict` abort issue per current-execution.md S338 row line 149; but the verifier flagged 12 unused-ignore lines).

**Fix** (sandwich-dev):
- Replace `_sleeper: object = field(...)` pattern with `_sleeper: Callable[[float], None] = field(...)`
  (proper type) + drop the `# type: ignore[operator]` where they fire.
- Use `TYPE_CHECKING` guard for `Callable` import if it's not already imported at runtime
  (it IS imported runtime in `apps/_shared/crawl/rate_limiter.py:26 from time import monotonic, sleep`
  — Callable comes from `collections.abc` which is stdlib; runtime import OK).
- File scope: this architect estimates **2 files touched** (`rate_limiter.py` +
  `cafef_adapter.py`), ~5 LOC delta each, ~10 LOC total. SURGICAL.

**Verification**: ruff clean (existing baseline 0); mypy strict for the 2 files only
(avoid the project-wide collision); confirm no behavioral change (existing 54 tests
remain green).

**Charter alignment**: Karpathy P3 surgical-changes ratified.

**Companion firing-test**: NONE (mypy noise is not a hook concern).

---

### D7. F4 + F5 sandwich-dev dispatch-template updates (STEP 0.10 verbatim + observation-file required)

**Anomaly**: F4 + F5 MINOR from S339 verifier. Anomaly #8 + #9 in latest.md harness queue.

**Empirical evidence**:
- `.claude/agents/sandwich-dev.md:32-148` — current template. No mention of "STEP 0.10"
  baseline `--help` capture; no explicit "MUST write observation file" requirement.
  Phase 5 § Dev Session Report just says "After all tasks done (or session ends): ..."
  followed by a markdown template — the report goes back to invoker, NOT necessarily
  to disk.
- `agent-workspace/constitution/dispatch-templates.md` — Glob confirms this file does
  NOT exist. So dispatch-template documentation lives in `.claude/agents/sandwich-*.md`
  files directly.

**Fix** (sandwich-dev — edit `.claude/agents/sandwich-dev.md`):

**F4 fix** — add to § Phase 1: Load Plan (between "Read plan completely before starting any task" and "Apply VBW Protocol"):
> **STEP 0.10 BASELINE CAPTURE (mandatory)**: For every CLI tool or script you'll
> migrate/touch, capture its `--help` output VERBATIM in your session log BEFORE editing.
> If the tool has no `--help`, capture the click signature via `python -c 'import X;
> import click; click.echo(X.command.help)'` or equivalent. The baseline is your
> contract: any deviation in S341 IMPL output vs. baseline is a regression.

**F5 fix** — add to § Phase 5: Report (new sub-section at top):
> **OBSERVATION FILE (mandatory)**: After your dev session, write a structured observation
> at `agent-workspace/memory/observations/sandwich-dev-S<N>-<plan-id-slug>.md` summarizing
> what you did + obstacles encountered + handoff notes for verifier. Format mirrors the
> sandwich-architect observation pattern (see `agent-workspace/memory/observations/sandwich-architect-S337-phase-d-theme-l-plan.md`
> for reference). Session log alone is INSUFFICIENT (per S339 F5).

**Also propagate** to `.claude/agents/sandwich-architect.md` § Output (new sub-bullet):
> **OBSERVATION FILE (mandatory)**: After plan authoring, write observation at
> `agent-workspace/memory/observations/sandwich-architect-S<N>-<plan-id-slug>.md`
> (~150-250 LOC; what was decided + why + what was rejected; reference format = S337).

**Also propagate** to `.claude/agents/sandwich-verifier.md` § Phase 9: Deliver Report:
> **OBSERVATION FILE recovery pattern**: sandwich-verifier has NO Write to
> `agent-workspace/memory/observations/`. If observation file required, return the
> observation text in your final message; main session writes the file per the
> "verifier-has-no-Write recovery pattern" precedent (S312 / S314 / S321 / S333 / S339).

**Charter alignment**: this is template improvement (`.claude/agents/**` is allow-listed
per `.claude/settings.json:49`); 0 charter / 0 constitution touched.

**Companion firing-test**: NONE (template change is meta-doc, not hook).

---

## § E. Acceptance criteria (AQ-1..AQ-10)

Each AQ is empirically falsifiable via single bash command or `grep` invocation.

| ID | Criterion | Verification command |
|---|---|---|
| AQ-1 | escalation-engine HIGH-spam STOPPED — UserPromptSubmit cadence emits 0 SEVERITY-ESCALATION HIGH lines when notifications unchanged from prior fire | Trigger 3 consecutive UserPromptSubmit cycles synthetically; tail urgent.md; confirm no new ESCALATION row in cycles 2+3 (only cycle 1) |
| AQ-2 | severity-classifier classifies all 3 warn notifications as MEDIUM (DIGEST) not HIGH | `grep '^MEDIUM' agent-workspace/memory/.severity-state.tsv | grep -c warn.md` returns ≥3 |
| AQ-3 | 6 stale `.severity-state.tsv.tmp.*` files removed AND no new ones created after 3 Stop cycles | `ls agent-workspace/memory/.severity-state.tsv.tmp.* 2>/dev/null | wc -l` = 0 |
| AQ-4 | severity-classifier has trap EXIT cleanup AND firing-test covers SIGTERM mid-write | `grep -n "trap.*EXIT" scripts/hooks/severity-classifier.sh` returns line; firing-test has TC: kill -TERM scenario |
| AQ-5 | pre-dispatch-architect-commit-guard hook exists + wired in settings.json | `grep -c pre-dispatch-architect-commit-guard .claude/settings.json` ≥ 1; firing-test 6/6 PASS |
| AQ-6 | sandwich-architect.md updated with "no Bash" constraint + observation-file mandate | `grep -c "no Bash\|sandwich-architect has NO Bash" .claude/agents/sandwich-architect.md` ≥ 1; `grep -c "observation file" .claude/agents/sandwich-architect.md` ≥ 1 |
| AQ-7 | F3 mypy noise reduced — `_sleeper` typed as `Callable[[float], None]` + zero new `# type: ignore` lines | `grep -c "type: ignore" apps/_shared/crawl/rate_limiter.py` = 0 (was 1); `grep "_sleeper:" apps/_shared/crawl/rate_limiter.py` shows Callable type |
| AQ-8 | sandwich-dev.md template has STEP 0.10 baseline capture + observation-file mandate | `grep -c "STEP 0.10\|baseline capture" .claude/agents/sandwich-dev.md` ≥ 1; `grep -c "OBSERVATION FILE.*mandatory" .claude/agents/sandwich-dev.md` ≥ 1 |
| AQ-9 | repo root stray files removed — count of zero-byte files outside .git/ is 0 (or = baseline if root cause un-fixable) | `find . -maxdepth 1 -size 0 -type f -not -path './.git*' -not -name '.git*' | wc -l` = 0 |
| AQ-10 | 0 charter / 0 constitution writes this session | `git diff --name-only HEAD` post-S341-commit shows no files matching `PROJECT_CHARTER.md\|agent-workspace/constitution/.*\|obsidian-vault/raw/.*` |

## § F. Risks (RM1..RM10)

| ID | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| RM1 | D1 over-suppresses escalation-engine — hides a real CRITICAL emission | LOW | HIGH | CRITICAL handling (`escalation-engine.sh:89-107`) is untouched in this fix; only HIGH classification changes via WARN frontmatter + content-hash dedup. The CRITICAL/HIGH-QA paths remain emit-every-cycle. Verify in AQ-1 by injecting synthetic CRITICAL marker (`.charter-violation-detected`) + confirming `.autonomous-BLOCKED` still raised. |
| RM2 | D3 dispatch-template hook blocks legitimate architect dispatches (false-positive) | LOW | MEDIUM | Regex narrowly scoped to `git commit|git add|git mv|git push` in PROMPT (not architect's own output). Override env `STOCKFORGE_ALLOW_ARCHITECT_COMMIT=1` exists. Firing-test TC2 specifically verifies clean architect prompt is NOT blocked. |
| RM3 | D2 stale-tmp cleanup races with active classifier write — deletes a legitimate in-flight `.tmp.<pid>` | LOW | LOW | Cleanup uses `-mmin +60` (older than 60 min only) per D-062 atomic-write rule; classifier writes complete in <1 sec normally. Also D2.1.A one-shot cleanup runs OUTSIDE classifier execution window (in dev's IMPL session, classifier not actively running at that moment). |
| RM4 | D5 zero-byte hook root cause not findable in this session (budget overrun) | MEDIUM | LOW | Sub-track explicitly budget-capped at 30 min per § D5. If root cause not found, cleanup-only ships + AP-7 revisit trigger (next stray file appearance) is named. |
| RM5 | D1 content-hash dedup adds latency to source hooks (3 hooks × small overhead) | LOW | LOW | sha256 of <10KB content is sub-millisecond; well within Stop-chain budget. Measured precedent: all existing hooks already compute hashes in some form. |
| RM6 | D2 trap EXIT cleanup logic interferes with existing `trap 'exit 0' ERR` | LOW | MEDIUM | The two traps are for different signals (ERR vs EXIT); coexistence is standard bash idiom. Firing-test TC verifies both fire correctly under different abort scenarios. |
| RM7 | D1 frontmatter change (`level: WARN`) breaks downstream consumer that parses by absence | LOW | LOW | Architecturally, the absence-based parsing IS the bug being fixed (classifier falls through to body-grep). All consumer paths grep for `level:` field explicitly; adding the field can only IMPROVE downstream behavior. Verify via AQ-2. |
| RM8 | D6 mypy fix breaks runtime behavior (Callable variance issue surfaces) | LOW | LOW | Existing 54 tests cover the modified files; any runtime break surfaces immediately. Test execution is mandatory per dev template Phase C. |
| RM9 | D5 explicit-list deletion misses a stray basename (incomplete cleanup) | MEDIUM | LOW | Cleanup is iterative — dev can re-run Glob `[A-Z]*` + `[a-z]*` + numerics at repo root to catch all. Cleanup is non-destructive (only zero-byte files outside .git/). AQ-9 verifies via `find` query. |
| RM10 | D7 template edit conflicts with parallel sandwich-architect/sandwich-dev dispatch in S341 itself (the template the dev is reading is the same one being edited) | LOW | LOW | Edits to `.claude/agents/*.md` apply on NEXT subagent dispatch, not current one. S341 dev's own dispatch is read at dispatch time; in-flight edits do NOT change it. AQ-6+AQ-8 verify post-fact. |

## § G. Source-evidence grid

Each major decision cites ≥5 sources per L-S333-1 hook-sourced-empirical-quote discipline.

| Decision | Source 1 (file:line) | Source 2 (file:line) | Source 3 (file:line) | Source 4 (precedent) | Source 5 (CLAUDE.md / charter) |
|---|---|---|---|---|---|
| D1 root cause = source-hook regeneration | `python-determinism-check.sh:241-243` `NOTIF_FILE=...; ... > "$NOTIF_FILE"` | `html-separator-check.sh:230-245` same pattern | `path-safety-check.sh:305-320` same pattern | `severity-classifier.sh:188 [ "$age" -le 24 ]` mtime filter | CLAUDE.md `harness_priority_one` rule |
| D1 fix = content-hash dedup at source | S318 idempotent-notification fix per `checkpoints/2026-05-14-S317-close.md:71-72` (precedent: same hooks already moved to fixed-name) | `escalation-engine.sh:113-115` UserPromptSubmit bypass (proves marker can't catch it) | `severity-classifier.sh:200-211` body-grep fallback (proves classification needs frontmatter) | severity-schema.md WARN-tier reference | `latest.md:60` anomaly #1 quote |
| D1 frontmatter `level: WARN` | `severity-classifier.sh:189-197` level frontmatter classifier branch (explicit WARN→MEDIUM mapping) | `html-separator-check.sh:35` "severity=HIGH (ERR) / severity=MEDIUM (WARN)" self-documentation | `path-safety-check.sh:22` same self-doc | `python-determinism-check.sh:15-16` same | `agent-workspace/constitution/severity-schema.md` (per S317-close reference) |
| D2 root cause = no trap EXIT | `severity-classifier.sh:17` `trap 'exit 0' ERR` (only ERR not EXIT) | `severity-classifier.sh:33 TMP=...tmp.$$` (the variable that needs cleanup) | `severity-classifier.sh:217 mv -f "$TMP"` (success path) | Architect's Glob: 6 `.tmp.*` files present | D-062 atomic-write-doctrine (`decisions/062-atomic-write-doctrine.md`) |
| D2 fix = trap + janitor | D-062 atomic-write-doctrine ADR | `path-safety-check.sh:136-140 cleanup_helper + trap` (precedent: trap EXIT pattern in existing hooks) | `destructive-command-guard.sh:83-87` find-maxdepth-name safe pattern (for janitor) | `severity-classifier.sh:217` mv-or-cleanup (the failed path) | CLAUDE.md AP-23 (3rd-instance lesson would be janitor escape-pattern if accumulated) |
| D3 dispatch-template hook | `.claude/agents/sandwich-architect.md:5` `tools: [Read, Glob, Grep, Write]` (no Bash) | `destructive-command-guard.sh:30-44` JSON parse pattern precedent | `.claude/settings.json:527-557` PreToolUse matcher `.*` (insertion point) | checkpoint `latest.md:32` "3rd instance" attestation | CLAUDE.md AP-23 promote-now rule "Refinement-of-rule is AP-23 RED FLAG: 2nd instance mandates promote-or-retire" |
| D5 root cause cwd-relative-write | `checkpoints/2026-05-14-S317-close.md:74` "PRIORITY 6 (hygiene): zero-byte junk files in repo root — git-restore / buggy-redirect artifacts" | This architect's Glob: 20 stray basenames | Working hypothesis from `latest.md:61` "buggy hook with cwd-relative-write fallback" | S331 first-detection per current-execution.md | Karpathy P3 surgical-changes (only fix what task requires) |
| D6 F3 mypy noise | `apps/_shared/crawl/rate_limiter.py:83 _sleeper: object` | `apps/_shared/crawl/rate_limiter.py:119 type: ignore[operator]` | S339 verifier F3 finding in `observations/sandwich-verifier-S339-phase-d-theme-l-verify.md` | CrawlerAdapter `__init_subclass__` precedent at `crawler_adapter.py:60` (object kwargs OK there) | Karpathy P3 surgical-changes (~10 LOC scope) |
| D7 STEP 0.10 + observation file | `.claude/agents/sandwich-dev.md:32-148` current template (no STEP 0.10) | `.claude/agents/sandwich-dev.md:84-119` Phase 5 report (no observation-file requirement) | S339 verifier F4 + F5 findings | architect observation file precedent at `observations/sandwich-architect-S337-phase-d-theme-l-plan.md` (format reference) | I-S2 source + as-of discipline (baseline IS source data) |

## § H. DoD criteria (47 total — broken down by sub-track)

### D1 DoD (DC-D1-1..DC-D1-12)
- DC-D1-1: `html-separator-check.sh` regeneration block computes content hash of new content + compares to existing file content; SKIPs write if equal
- DC-D1-2: `path-safety-check.sh` same content-hash dedup
- DC-D1-3: `python-determinism-check.sh` same content-hash dedup
- DC-D1-4: All 3 source hooks include `level: WARN` in YAML frontmatter of regenerated notification content
- DC-D1-5: Frontmatter is the FIRST content line (parseable by `head -10 | grep '^level:'`)
- DC-D1-6: `escalation-engine.sh` and `severity-classifier.sh` UNTOUCHED in D1 sub-track (root fix at source, not at consumer)
- DC-D1-7: NEW `firing-tests/escalation-spam-dedup-fire-test.sh` exists, ≥3 TCs, all PASS
- DC-D1-8: Existing firing-test for each source hook extended with content-hash dedup TC; all firing-tests PASS
- DC-D1-9: Synthetic 3-cycle test confirms cycle 2+3 emit 0 new ESCALATION rows in urgent.md
- DC-D1-10: After D1 fix, `severity-state.tsv` shows MEDIUM (not HIGH) for the 3 warn notifications
- DC-D1-11: bash-hook-lint clean for all 3 modified hooks
- DC-D1-12: `bash -n` syntax check passes for all 3 modified hooks

### D2 DoD (DC-D2-1..DC-D2-8)
- DC-D2-1: `severity-classifier.sh` has `trap 'rm -f "$TMP" 2>/dev/null || true' EXIT` registered (after ERR trap)
- DC-D2-2: All 6 existing stale `.tmp.*` files removed (verified via Glob)
- DC-D2-3: Janitor logic (inline in severity-classifier.sh OR new stale-tmp-cleaner.sh hook) exists + uses `-mmin +60` window
- DC-D2-4: If new janitor hook created, wired in settings.json at appropriate Stop chain position (BEFORE severity-classifier OR at SessionStart)
- DC-D2-5: After 3 Stop cycles, no new stale `.tmp.*` files generated (verified via Glob)
- DC-D2-6: Firing-test exists for severity-classifier (NEW or extended) with kill -TERM TC; trap fires correctly; no orphan left
- DC-D2-7: Optional ADR D-067 PROPOSED only if D2.1.B new janitor hook lands (not required if just trap EXIT inline fix)
- DC-D2-8: bash-hook-lint clean + bash -n syntax OK for severity-classifier.sh

### D3 DoD (DC-D3-1..DC-D3-7)
- DC-D3-1: NEW `scripts/hooks/pre-dispatch-architect-commit-guard.sh` exists, follows destructive-command-guard.sh shape
- DC-D3-2: Reads stdin JSON for `tool_name == "Agent"` + `tool_input.subagent_type == "sandwich-architect"` + prompt regex
- DC-D3-3: Blocks (RC=2) when prompt contains `git commit|git add|git mv|git push`
- DC-D3-4: Allows (RC=0) on any other tool / non-architect / clean prompt
- DC-D3-5: Override via `STOCKFORGE_ALLOW_ARCHITECT_COMMIT=1` env
- DC-D3-6: Wired in `.claude/settings.json` PreToolUse section AFTER destructive-command-guard.sh
- DC-D3-7: NEW `firing-tests/pre-dispatch-architect-commit-guard-fire-test.sh` exists, ≥6 TCs, all PASS

### D5 DoD (DC-D5-1..DC-D5-4)
- DC-D5-1: All identified stray zero-byte files at repo root removed (explicit list deletion + Glob verification)
- DC-D5-2: Grep across `scripts/hooks/**` for cwd-relative-write patterns recorded in dev session log
- DC-D5-3: If root cause identified, hook fixed with quoted variable + `set -u` (and added to D5 DoD)
- DC-D5-4: If root cause NOT identified within 30-min budget, dev session log documents grep results + AP-7 revisit trigger ("next stray file appearance")

### D6 DoD (DC-D6-1..DC-D6-3)
- DC-D6-1: `apps/_shared/crawl/rate_limiter.py:83` typed `_sleeper: Callable[[float], None]` (replacing `object`)
- DC-D6-2: `# type: ignore[operator]` lines removed where unused; remaining ones legitimately required
- DC-D6-3: All 54 existing tests for D2 + D3 sub-tracks (from S338) remain green

### D7 DoD (DC-D7-1..DC-D7-5)
- DC-D7-1: `.claude/agents/sandwich-dev.md` updated with STEP 0.10 baseline-capture mandate in Phase 1
- DC-D7-2: `.claude/agents/sandwich-dev.md` updated with OBSERVATION FILE mandatory section in Phase 5
- DC-D7-3: `.claude/agents/sandwich-architect.md` updated with OBSERVATION FILE mandatory bullet in Output + "no Bash; main commits" constraint note
- DC-D7-4: `.claude/agents/sandwich-verifier.md` updated with verifier-has-no-Write recovery pattern note in Phase 9
- DC-D7-5: All 3 template files pass `head -10 | grep '^name:'` (YAML frontmatter intact)

### Bundle DoD aggregate (DC-AGG-1..DC-AGG-8)
- DC-AGG-1: All sub-tracks D1+D2+D3+D5+D6+D7 DoD criteria met (D4 = explicit DEFER per AP-7)
- DC-AGG-2: Total LOC delta ≤ 500 (Karpathy P3 surgical-changes budget; estimate 350-450)
- DC-AGG-3: No charter edits / no constitution writes
- DC-AGG-4: All existing firing-tests still PASS (regression check)
- DC-AGG-5: All existing pytest still PASS (existing 968 + any new from D2 firing-test)
- DC-AGG-6: bash-hook-lint clean across all modified hooks
- DC-AGG-7: S341 dev observation file written at `agent-workspace/memory/observations/sandwich-dev-S341-harness-stabilization-sweep.md` (~200-300 LOC)
- DC-AGG-8: S341 dev session log written at `agent-workspace/memory/sessions/2026-05-16-session-341.md` with STEP 0.10 baseline captures verbatim for all modified hooks (test the new dispatch-template discipline!)

## § I. Verifier checks (V1..V22) for sandwich-verifier S342

Adversarial test grid. Pattern from plan-020 + plan-019.

### V1 group: D1 escalation-spam fix verification
- V1.1: Confirm content-hash dedup in all 3 source hooks (read each `> "$NOTIF_FILE"` block; verify hash-compare logic)
- V1.2: Confirm `level: WARN` frontmatter in all 3 hook-emitted notification files (run hooks fresh; head -5 of each warn.md)
- V1.3: Run 3 synthetic UserPromptSubmit cycles; confirm 0 new ESCALATION rows in urgent.md in cycles 2+3
- V1.4: Confirm `severity-state.tsv` shows MEDIUM (not HIGH) for the 3 warn notifications
- V1.5: Confirm CRITICAL handling path UNCHANGED — inject `.charter-violation-detected` marker; confirm `.autonomous-BLOCKED` still raised + system-reminder still emitted

### V2 group: D2 stale-tmp cleanup + trap verification
- V2.1: Confirm `trap ... EXIT` registered in severity-classifier.sh
- V2.2: `ls agent-workspace/memory/.severity-state.tsv.tmp.*` returns 0 files
- V2.3: Send synthetic SIGTERM mid-classifier-write; confirm no orphan after kill
- V2.4: Run severity-classifier 5 times; confirm 0 `.tmp.*` accumulation

### V3 group: D3 dispatch-template hook verification
- V3.1: NEW hook file exists + is executable + has `#!/usr/bin/env bash` shebang
- V3.2: Hook wired in settings.json PreToolUse section after destructive-command-guard
- V3.3: All 6 firing-test TCs PASS
- V3.4: Inject synthetic Agent dispatch with sandwich-architect + "git commit" in prompt; verify hook returns RC=2
- V3.5: Inject same with sandwich-dev; verify hook returns RC=0 (dev can commit per template)
- V3.6: Override env STOCKFORGE_ALLOW_ARCHITECT_COMMIT=1 bypass works

### V4 group: D5 zero-byte cleanup + root cause verification
- V4.1: `find . -maxdepth 1 -size 0 -type f -not -path './.git*' -not -name '.git*' | wc -l` returns 0
- V4.2: Dev session log documents grep findings for cwd-relative-write patterns
- V4.3: If root cause identified, fix is in place + firing-test added

### V5 group: D6 + D7 template + mypy verification
- V5.1: `grep -c "type: ignore" apps/_shared/crawl/rate_limiter.py` = 0
- V5.2: `_sleeper` field typed as `Callable[[float], None]` (grep + read)
- V5.3: All 54 existing tests still green
- V5.4: `.claude/agents/sandwich-dev.md` contains "STEP 0.10" and "OBSERVATION FILE" mandatory text
- V5.5: `.claude/agents/sandwich-architect.md` contains "no Bash" constraint + observation-file mandate

### V6 group: Bundle aggregate verification
- V6.1: `git diff HEAD~N --name-only` post-S341-commit does NOT include PROJECT_CHARTER.md or agent-workspace/constitution/**
- V6.2: bash-hook-lint clean across all modified hooks
- V6.3: All firing-tests PASS (regression + new)

## § J. Coordination rule (S341 IMPL)

Main session AVOIDS edits to these paths during S341 dev execution to prevent trampling:

**Hook files (sandwich-dev's primary work):**
- `scripts/hooks/escalation-engine.sh` (Read-only validation by main; D1 untouched but verifier may grep)
- `scripts/hooks/severity-classifier.sh` (D2 primary; main avoids)
- `scripts/hooks/html-separator-check.sh` (D1 primary; main avoids)
- `scripts/hooks/path-safety-check.sh` (D1 primary; main avoids)
- `scripts/hooks/python-determinism-check.sh` (D1 primary; main avoids)
- `scripts/hooks/pre-dispatch-architect-commit-guard.sh` (D3 NEW; main avoids)
- `scripts/hooks/firing-tests/escalation-spam-dedup-fire-test.sh` (D1 NEW; main avoids)
- `scripts/hooks/firing-tests/pre-dispatch-architect-commit-guard-fire-test.sh` (D3 NEW; main avoids)
- `scripts/hooks/firing-tests/severity-classifier-fire-test.sh` (D2 NEW or extended; main avoids)
- `scripts/hooks/firing-tests/{html-separator,path-safety,python-determinism}-check-fire-test.sh` (D1 extended; main avoids)

**State files (touched by hooks under modification):**
- `agent-workspace/memory/.severity-state.tsv` (D2 atomic-write target)
- `agent-workspace/memory/.severity-state.tsv.tmp.*` (D2 cleanup target)
- `agent-workspace/memory/.escalation-fired-*` (D1 marker family — Read-only for main during S341)

**Notification source files:**
- `human-workspace/notifications/html-separator-warn.md` (D1 regeneration target)
- `human-workspace/notifications/path-safety-warn.md` (D1 regeneration target)
- `human-workspace/notifications/python-determinism-warn.md` (D1 regeneration target)
- `human-workspace/notifications/urgent.md` (D1 indirectly affected; main avoids appending while D1 in flight)

**Settings + agent template files:**
- `.claude/settings.json` (D2 + D3 hook wiring; main avoids)
- `.claude/agents/sandwich-dev.md` (D7 edit target)
- `.claude/agents/sandwich-architect.md` (D7 edit target)
- `.claude/agents/sandwich-verifier.md` (D7 edit target)

**Production code (D6):**
- `apps/_shared/crawl/rate_limiter.py` (D6 mypy fix target)
- `packages/infrastructure/news/crawler_adapters/cafef_adapter.py` (D6 mypy fix target)

**Optional ADR (D2 conditional):**
- `agent-workspace/memory/decisions/067-atomic-write-tmp-cleanup-doctrine.md` (only if D2.1.B new janitor hook lands)

**Session logs (S341 dev's authoring scope):**
- `agent-workspace/memory/sessions/2026-05-16-session-341.md`
- `agent-workspace/memory/observations/sandwich-dev-S341-harness-stabilization-sweep.md`

Main session may continue routine work on other paths during S341 IMPL. Main's main risks during S341:
- Do NOT edit `.severity-state.tsv` while classifier is being modified (race)
- Do NOT trigger explicit Stop cycles while D1 in flight (would muddy synthetic test)
- Do NOT dispatch parallel sandwich-architect/sandwich-dev while S341 dev is running (until D3 hook lands)

## § K. Budget envelope

| Sub-track | Estimated LOC | Estimated tokens | Risk-of-blowout |
|---|---|---|---|
| D1 (3 hooks edit + 1 NEW firing-test + 3 firing-test extensions) | ~80 LOC | ~20K | LOW (well-scoped) |
| D2 (1 hook trap + cleanup invocation + possibly 1 NEW janitor hook + firing-test) | ~50 LOC (~100 if janitor) | ~10-15K | LOW |
| D3 (1 NEW hook + 1 NEW firing-test + settings.json wire) | ~80 LOC + ~120 LOC firing-test | ~15K | LOW |
| D5 (~20 file deletions + grep + session log entries) | ~30 LOC session log | ~10K | MEDIUM (grep investigation) |
| D6 (2 file edits, ~10 LOC delta) | ~10 LOC | ~5K | LOW |
| D7 (3 template file edits, ~30 LOC delta total) | ~30 LOC | ~10K | LOW |
| Verification + commit | n/a | ~15K | n/a |
| **Total** | ~280-330 LOC | ~85-100K | **fits Sonnet MULTI_TASK_IMPL** |

**Recommendation**: **Sonnet MULTI_TASK_IMPL, budget 100-150K**. Opus only if D1 root-cause
investigation expands (e.g. if content-hash dedup uncovers other re-emission paths).

**S342 verifier budget**: 50-80K Opus VERIFY (fresh-context). Adversarial regression
across all 22 verifier checks + bundle aggregate.

## § L. AP-23 attestation

| Anomaly | Pre-S341 instance count | Post-S341 outcome |
|---|---|---|
| #1 escalation-engine HIGH-spam | 4th+ instance (S335-S339) — PROMOTE NOW already triggered S336 | **CLOSED via D1** (root cause fixed) |
| #2 stale `.tmp.*` orphans | 1st instance (cleanup not previously attempted) | **CLOSED via D2** (cleanup + trap + janitor) |
| #3 dispatch-template gap | 3rd instance (S335 + S337×2) — PROMOTE NOW per AP-23 mandate | **CLOSED via D3** (PreToolUse hook + template update) |
| #4 parallel-architect-dispatch | 1st instance (S337) | **DEFERRED per AP-23 HOLD**; revisit on 2nd instance OR Mode-D audit; explicit AP-7 trigger named (§ D4) |
| #5 zero-byte stray files | 2nd instance (S331 + carry-forward via S317-close + this) | **CLOSED via D5** cleanup; root cause investigation budget-capped at 30 min; AP-7 revisit trigger named if cleanup incomplete |
| #6 F3 mypy noise (object-typed DI) | 1st instance (S339) — usually HOLD but bundled here for surgical efficiency | **CLOSED via D6** (~10 LOC fix) |
| #7 F4 + F5 dispatch-template updates | 1st instance (S339) — same bundle-for-efficiency rationale | **CLOSED via D7** (.claude/agents/sandwich-*.md template edits) |

**Net AP-23 outcome**: 6 anomalies CLOSED, 1 DEFERRED with explicit AP-7 trigger.
3 promote-now triggers honored (#1, #3, both 3rd+ instance).

## § M. Compliance attestation

| Attestation | Status | Evidence |
|---|---|---|
| harness_priority_one | ✓ | Plan IS the harness work; product (Phase D NDH/Vietstock/VietnamBiz + Phase E Theme I) explicitly paused per CLAUDE.md rule until this plan lands |
| AP-1 same-agent self-review avoidance | ✓ | Architect = S340 (this); Dev = S341 (fresh-context Sonnet); Verifier = S342 (fresh-context Opus); all 3 distinct sandwich-* personas |
| dont_self_pause_at_session_boundary | ✓ | Main dispatches S341 immediately after committing this plan; main dispatches S342 verifier immediately after S341 dev returns (per autonomous-full discipline) |
| autonomous_continue_no_self_pause | ✓ | No AskUserQuestion in this plan; no charter/scope question requires user; all decisions IMPL-tier |
| stop_offering_routing_branches | ✓ | Plan does not enumerate (a)/(b)/(c) "next" options for user — autonomous main picks based on this plan + § L AP-23 attestation |
| D-060 commit policy | ✓ | Sandwich-dev commits own S341 work; main commits THIS plan (architect has no Bash) + commits architect-only outputs going forward |
| verify_phase_before_next_phase | ✓ | This plan empirically VERIFIED 6 of 7 anomaly root causes via VBW pass (D4 deferred per AP-23 rather than verified — that's the appropriate response for 1st-instance) |
| 0 charter | ✓ | PROJECT_CHARTER.md not in any sub-track's file list |
| 0 constitution | ✓ | agent-workspace/constitution/** not in any sub-track's file list; if D2.1.B janitor hook lands, ADR D-067 is IMPL-tier PROPOSED (memory/decisions/, not constitution/) |
| SYNC-GRILLING not fired | ✓ | BEHAVIORAL HOLD § (1) suspends cadence; not recommended in any sub-track |
| Karpathy P1 (Think before coding) | ✓ | Each sub-track has explicit Options-considered table; rejected alternatives documented |
| Karpathy P2 (Simplicity first) | ✓ | D4 DEFERRED explicitly to avoid over-engineering; D6+D7 bundled-for-surgery |
| Karpathy P3 (Surgical changes) | ✓ | Every recommendation traces to anomalies #1-#7 from latest.md; total LOC delta capped at ~330 |
| Karpathy P4 (Goal-driven) | ✓ | 10 AQs are empirically falsifiable; 47 DoD criteria + 22 verifier checks |
| AP-7 anti-vacuous-defer | ✓ | D4 + D5 partial-defer explicit prerequisites + revisit triggers named |
| AP-17 identity drift | ✓ | This is harness work for VN stock advisory; not generic framework work |
| AP-23 ritual-demotion | ✓ | #1 + #3 promoted (3rd+ instance); #4 + #5 + #6 + #7 either bundled-for-efficiency OR explicit HOLD with revisit trigger |
| L-S176-1 (architect doesn't write production code) | ✓ | This plan is PLAN, not IMPL; sandwich-dev executes |
| L-S312-1 single-shot pattern | ✓ | D1 fixes the single-shot HIGH spam pattern by adding content-hash dedup |
| L-S333-1 hook-sourced-empirical-quote | ✓ | § G source-evidence grid has 5+ cites per major decision; every claim file:line |
| `full_autonomous_no_supervised` | ✓ | No AskUserQuestion; autonomous-full continues |
| `stop_offering_routing_branches` | ✓ | No (a)/(b)/(c) enumeration to user |

---

## § N. Out-of-scope (with explicit revisit triggers per AP-7)

1. **Anomaly #3 html-separator-check Stop-mode summary line fluctuates** (from latest.md
   line 62). DEFER to FOLLOW-UP harness session. Revisit trigger: if D1 fixes don't
   incidentally fix it OR if fluctuation persists post-S341.
2. **Anomaly #4 HH-6 legacy stale=3 dispatch sidecars** (from latest.md line 63).
   DEFER. Revisit trigger: if still present 24h post-S341-commit (should age out via
   12h rotation).
3. **D4 parallel-architect-dispatch hook**. DEFER per AP-23 HOLD. Revisit trigger:
   (a) 2nd instance detected OR (b) Mode-D continue-injector audit completes.
4. **D2.1.B new janitor hook**. CONDITIONAL on whether D2.2 trap EXIT inline fix is
   sufficient. Revisit trigger: if `.tmp.*` orphans accumulate again post-S341.
5. **D5 root-cause hook fix** (if grep investigation runs out of budget). DEFER per § D5.
   Revisit trigger: next zero-byte stray file appearance at repo root.
6. **ADR D-067 atomic-write-tmp-cleanup-doctrine**. CONDITIONAL on D2.1.B landing.
   Revisit trigger: if janitor hook is created as separate file (then ADR worth drafting).
7. **D-066 ratification cleanup** — S339 close-checkpoint notes "D-066 PROPOSED
   (Theme L adapter contract; ratifiable on commit per IMPL-tier severity-schema)".
   Out-of-scope this session; lives in next Phase D per-source FOCUSED_IMPL turn.
8. **broader mypy --strict project-wide fix** — known issue (current-execution.md line
   149): `mypy --strict packages apps` aborts on `packages/_shared` vs `apps/_shared`
   module-name collision. D6 sidesteps by per-file mypy check. Broader fix is a separate
   PLAN session (rename one of the two `_shared` dirs OR configure mypy to handle them
   distinctly). Revisit trigger: when mypy gate becomes effectively-blocking for any
   sub-track.

---

End of plan-021. S341 sandwich-dev MULTI_TASK_IMPL begins on dispatch (main commits this
plan first per D-060 dispatch-template recovery pattern).
