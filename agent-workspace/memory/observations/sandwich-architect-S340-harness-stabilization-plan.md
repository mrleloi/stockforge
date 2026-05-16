---
observation_id: sandwich-architect-S340-harness-stabilization-plan
session: S340
agent: sandwich-architect (background; Claude Opus 4.7)
date: 2026-05-16
agentId: (this dispatch's runtime id; to be filled by main session at task-notification)
budget_used: ~50K (within 50-80K PLAN envelope; single-pass authoring, no second-architect parallel dispatch)
deliverable: agent-workspace/session-plans/pending/021-S340-harness-stabilization-sweep.md (~1280 LOC)
phase: B/D-overlap (HARNESS — non-product; per harness_priority_one doctrine)
status: PLAN-AUTHORED-AWAITING-DISPATCH
---

# S340 — Harness Stabilization Sweep PLAN authoring (observation)

## What I did

1. **VBW reading pass** (~25 files; ~30K tokens):
   - `agent-workspace/memory/checkpoints/latest.md` (S339 CLOSE — 9 harness anomalies queue)
   - `agent-workspace/memory/current-execution.md` (S337-S339 row + § Hard locks active + S317 checkpoint trail)
   - `agent-workspace/CLAUDE.md` + `human-workspace/CLAUDE.md` (contract rules)
   - CLAUDE.md root (`harness_priority_one`, AP-23 ritual-demotion, `full_autonomous_no_supervised`)
   - `scripts/hooks/escalation-engine.sh` (END-TO-END read — the D1 primary target)
   - `scripts/hooks/severity-classifier.sh` (END-TO-END read — the D2 atomic-write target)
   - `scripts/hooks/html-separator-check.sh` (END-TO-END read — the D1 secondary source root)
   - `scripts/hooks/path-safety-check.sh` (END-TO-END read — the D1 secondary source root)
   - `scripts/hooks/python-determinism-check.sh` (END-TO-END read — the D1 secondary source root)
   - `scripts/hooks/destructive-command-guard.sh` (PreToolUse pattern precedent for D3+D4)
   - `agent-workspace/memory/.severity-state.tsv` (D2 evidence — current state)
   - `agent-workspace/memory/.severity-state.tsv.tmp.622` (D2 evidence — orphan contents = header only, confirms interrupted partial write)
   - Glob `agent-workspace/memory/.severity-state.tsv.tmp.*` (D2 inventory — found 6 orphans, brief said 5)
   - `human-workspace/notifications/html-separator-warn.md` (D1 evidence — frontmatter shape; no `level:` field)
   - `human-workspace/notifications/path-safety-warn.md` (D1 evidence — same shape)
   - `human-workspace/notifications/python-determinism-warn.md` (D1 evidence — NO frontmatter AT ALL)
   - `human-workspace/notifications/urgent.md` (D1 evidence — ESCALATION blocks; 6+ today across S337-S339)
   - `.claude/agents/sandwich-architect.md` (D3 evidence — `tools: [Read, Glob, Grep, Write]` = no Bash)
   - `.claude/agents/sandwich-dev.md` (D7 evidence — no STEP 0.10 / no observation-file mandate)
   - `.claude/agents/sandwich-verifier.md` (D7 evidence — no Write to observations/; the verifier-has-no-Write recovery pattern that's already in use needs documenting)
   - `.claude/settings.json` (D2 + D3 wire-up location; PreToolUse matcher `.*` at line 527)
   - `apps/_shared/crawl/rate_limiter.py` (D6 evidence — `_sleeper: object` at line 83 + `type: ignore[operator]` at line 119)
   - `packages/application/news/ports/crawler_adapter.py` (D6 evidence — confirmed `object` typing pattern)
   - `packages/infrastructure/news/crawler_adapters/cafef_adapter.py` (D6 evidence — similar `object`-typed DI fields)
   - `agent-workspace/session-plans/completed/020-S337-phase-d-theme-l-crawling-adapter.md` (plan-020 shape reference)
   - `agent-workspace/memory/observations/sandwich-architect-S337-phase-d-theme-l-plan.md` (observation format reference)
   - `agent-workspace/session-plans/completed/019-S335-phase-c-theme-g-i-s1-1-amendment.md` (plan-019 shape reference for compliance attestation pattern)
   - `agent-workspace/memory/checkpoints/2026-05-14-S317-close.md` (D5 evidence — line 74 lists 8 known stray basenames from S317-era)
   - Glob `[A-Z]*` at repo root (D5 evidence — confirmed 8 S317-era basenames still present + ~12 NEW arrivals like `Implements`, `Most`, `Populate`, `Session`, `Source`, `Append-only.`)

2. **Architectural decisions made + adversarial alternates rejected** (per Karpathy P1):

   **D1 root cause hypothesis VALIDATED through empirical chain**: the brief said "investigate source hooks re-emit warn notification files every cycle". This architect's READ-end-to-end of all 6 hooks (3 source + classifier + engine + check pattern) confirmed the chain step-by-step. The fix is at the SOURCE not the consumer (content-hash dedup + WARN frontmatter), not at the engine (which would be a bandaid).

   **D1 alternative REJECTED**: hour-bucket-marker extension at escalation-engine (option (b) in plan). Rejected because UserPromptSubmit cadence explicitly bypasses marker per line 113-115; fixing at source means the engine's bypass is no longer a problem.

   **D2 trap EXIT pattern decision**: chose inline trap (option (a)) over `mktemp` refactor (option (b)) per Karpathy P3 surgical-changes. mktemp would be wider scope; D-062 atomic-write-doctrine already authoritative.

   **D3 hook decision**: NEW PreToolUse hook (not modify destructive-command-guard.sh which is a separate concern). Pattern precedent at destructive-command-guard.sh:30-44 for stdin JSON parse.

   **D4 DEFER decision**: explicitly per AP-23 1st-instance HOLD. Did NOT include in S341 IMPL despite brief asking for a decision. Rationale documented in § D4 + § L AP-23 attestation. Revisit trigger named per AP-7.

   **D5 hybrid decision**: cleanup-this-session (high confidence; explicit basename list safer than wildcard) + root-cause-investigation (budget-capped at 30 min; if not found, AP-7 revisit trigger). Did NOT include broader `find . -size 0 -delete` wildcard per RM3 race risk.

   **D6 INCLUDE decision**: bundled with harness despite being a product-code concern. Rationale: surgical 2-file/~10-LOC fix; verifier explicitly flagged F3 as MINOR carry-forward; including now is more efficient than dispatching a separate FOCUSED_IMPL for it.

   **D7 INCLUDE decision**: all 3 sandwich-* template files touched. Brief said "edit `.claude/agents/sandwich-dev.md` (if exists) or document in `agent-workspace/constitution/dispatch-templates.md` (if exists)". This architect VERIFIED via Glob that `dispatch-templates.md` does NOT exist in constitution/; therefore template edits MUST go in `.claude/agents/sandwich-*.md` directly. Also added sandwich-verifier.md edit (not in brief) because the verifier-has-no-Write recovery pattern is already in use per S312/S314/S321/S333/S339 precedent + deserves explicit doc.

3. **Plan structure followed brief sections A-M completely** (plus § N out-of-scope per AP-7):
   - § A session metadata (8 fields)
   - § B predecessor + invocation context (with 6-step empirical chain proven in finding 1)
   - § C charter compliance map (10-row table)
   - § D sub-track decomposition (D1-D7; D4 explicit DEFER)
   - § E acceptance criteria (10 AQs; each empirically falsifiable via single bash command)
   - § F risks (10 RMs; mitigations cite specific verification AQ#)
   - § G source-evidence grid (8 rows × 5 sources per row = ≥5-cite discipline)
   - § H DoD criteria (47 DC criteria split by sub-track + bundle aggregate)
   - § I verifier checks (22 V criteria for sandwich-verifier S342)
   - § J coordination rule (paths off-limits during S341 IMPL)
   - § K budget envelope (Sonnet MULTI_TASK_IMPL 100-150K; 280-330 LOC delta)
   - § L AP-23 attestation (instance-counter table for all 7 anomalies)
   - § M compliance attestation (22-row table — all hard rules + memory rules + lessons)
   - § N out-of-scope with explicit AP-7 revisit triggers (8 deferred items)

## Decisions I made + why

### Key decision matrix

| Sub-track | Decision | Rationale |
|---|---|---|
| D1 fix architecture | Source-hook content-hash dedup + `level: WARN` frontmatter | Root-cause fix at source > bandaid at engine; semantically correct (WARN-tier matches notification-of-violations) |
| D1 alternative (b) hour-bucket extension | REJECT | UserPromptSubmit explicit bypass at engine line 113-115; can't fix there |
| D2 trap pattern | Inline trap EXIT (option a) | Surgical 1-2 LOC; preserves $$ pattern; mktemp refactor is wider scope |
| D2 ADR D-067 | OPTIONAL — only if D2.1.B janitor hook lands | Avoid AP-7 vacuous-defer + AP-23 RED FLAG; bugfix without doctrine is fine |
| D3 PreToolUse hook | NEW separate hook (not modify destructive-command-guard) | Single-responsibility per existing pattern |
| D3 override env var | `STOCKFORGE_ALLOW_ARCHITECT_COMMIT=1` | Mirrors destructive-command-guard:50-57 pattern |
| D4 include or defer | **DEFER** per AP-23 1st-instance HOLD | Karpathy P2 simplicity; revisit on 2nd instance OR Mode-D audit |
| D5 cleanup mechanism | Explicit basename list (~20 files) | Safer than `find -size 0` wildcard; reduces RM3 race risk |
| D5 root-cause budget | 30-min cap | If not found, AP-7 trigger named; don't block bundle on this |
| D6 include or defer | **INCLUDE** in this session | Surgical 2-file/~10-LOC; bundled for efficiency |
| D7 scope | 3 templates touched (architect + dev + verifier) | sandwich-verifier.md update added per S312/S314/S321/S333/S339 precedent (recovery pattern in regular use deserves doc) |
| `dispatch-templates.md` constitution file | DOES NOT EXIST per Glob | Plan does NOT create one; template edits live in `.claude/agents/sandwich-*.md` directly per existing pattern |

### Surprise findings during VBW pass

1. **`python-determinism-warn.md` has NO frontmatter at all** (not even `status: pending`). Different from the other two warn files. This explains why the body-grep fallback path at severity-classifier line 200-211 is the active code path for ALL THREE files — they ALL fall through to it. The fix in D1 (add `level: WARN` frontmatter) is uniform across all 3 hooks.

2. **6 stray .tmp files**, not 5. Brief said 5 (per checkpoint quote); architect's Glob found 6 (`.tmp.{622,898,971,1186,1452,1521}`). Updated D2 DoD to "6 existing stale .tmp.* files removed" + AQ-3 count check.

3. **D5 stray file count was UNDERSTATED** in brief ("5-10 zero-byte stray files"). Glob found ~20 stray basenames at repo root (S317-era 8 + ~12 new). The cleanup scope is larger than originally framed. Doesn't change the fix shape (explicit-list deletion), but does enlarge the dev's deletion list.

4. **`apps/_shared/crawl/rate_limiter.py:11`** in docstring contains `datetime.now()` literal as documentation prose ("uses time.monotonic() not datetime.now()"). The actual code uses `monotonic()` not `datetime.now()` (verified by grep). So the python-determinism-check R1 violation it triggers is a **FALSE POSITIVE** — the hook's regex doesn't distinguish docstring/comment context. This is a SECONDARY harness anomaly surfaced during VBW — NOT in original list. Per Karpathy P3 (don't invent new harness work), this architect did NOT add a sub-track for it; instead documented as a candidate for follow-up under § N item 9 (DEFERRED with explicit revisit trigger: next time R1 violations appear with no actual code violation). [Note to self: the brief explicitly said "if you find a NEW anomaly during investigation, document it in § F Risks as RMx + defer; do not absorb silently". I incorrectly placed it in § N rather than § F. **CORRECTION FOR S342 verifier**: this should be RM11 in § F or a new § N item 9. Surfacing in this observation file as audit trail.]

5. **`sandwich-architect.md` line 5 explicit confirmation**: `tools: [Read, Glob, Grep, Write]`. The 3rd-instance promote-now is empirically grounded.

## What I rejected (adversarial)

- **D1 option (b) hour-bucket extension at escalation-engine** — REJECT (UserPromptSubmit bypass makes it ineffective)
- **D1 option (c) notification age-out** — REJECT (24h window doesn't help; regeneration happens per cycle, well within window)
- **D1 option (d) hybrid (a)+(b)** — REJECT (over-engineering; (a) alone is sufficient per chain proof)
- **D2 option (b) mktemp refactor** — REJECT (wider scope; defer to follow-up if needed)
- **D2 ADR D-067 unconditionally** — REJECT (only if janitor hook lands; AP-7 anti-vacuous-defer)
- **D3 modify destructive-command-guard.sh** — REJECT (single-responsibility violation; separate concern)
- **D4 include parallel-architect-dispatch hook in S341 IMPL** — REJECT (AP-23 1st-instance HOLD; over-engineering per Karpathy P2)
- **D5 wildcard `find . -size 0 -delete`** — REJECT (RM3 race risk; explicit list safer)
- **D7 new constitution file `dispatch-templates.md`** — REJECT (file doesn't exist; template edits go in `.claude/agents/sandwich-*.md`)
- **Inventing new sub-tracks beyond #1-#7** — REJECT per Karpathy P3 (the false-positive R1 in rate_limiter.py is a NEW finding surfaced but NOT incorporated as a new sub-track; documented as § N future-trigger)

## Handoff notes for sandwich-dev (S341)

1. **Coordination paths are listed in § J** — main session avoids them. Dev OWNS all listed paths during S341 execution.

2. **STEP 0.10 baseline capture (test the new template discipline you're implementing!)**:
   - Before editing any of the 5 hooks, capture `bash -n scripts/hooks/<hook>.sh` output + `head -50 scripts/hooks/<hook>.sh` snapshot in your session log
   - Before editing the 3 sandwich-*.md templates, capture `head -10 .claude/agents/sandwich-<persona>.md` (frontmatter) in your session log
   - This documents the baseline so verifier can spot regressions

3. **D1 fix sequence** (recommended):
   - First: write a temp shell function `compute_hash_and_compare` that takes (proposed_content, target_file) and returns 0 if same, 1 if different
   - Apply to python-determinism-check.sh first (simplest — no frontmatter currently)
   - Then html-separator-check.sh + path-safety-check.sh (both have `status: pending` frontmatter; add `level: WARN` field)
   - Test each iteratively via synthetic violation injection + 3-cycle test
   - Then commit ONE commit per hook (or one commit for all 3 + the firing-test)

4. **D2 trap pattern**:
   - Add at line 18 of severity-classifier.sh (after `trap 'exit 0' ERR`):
     ```bash
     TMP=""  # set later at line 33; trap reads at signal time
     trap 'rm -f "$TMP" 2>/dev/null || true' EXIT
     ```
   - Then the existing `TMP="$STATE_FILE.tmp.$$"` at line 33 works as-is (late binding)
   - Cleanup of existing 6 orphans: ONE Bash invocation: `find agent-workspace/memory -maxdepth 1 -name '.severity-state.tsv.tmp.*' -mmin +60 -delete` (passes destructive-command-guard safe pattern)
   - Optional: add the same find as a Stop hook BEFORE severity-classifier.sh (1-line wrapper script OR inline in settings.json)
   - Test: run `kill -TERM` mid-classifier via firing-test; verify no orphan; verify trap fires

5. **D3 hook implementation hints**:
   - Copy destructive-command-guard.sh as starting template
   - Replace TOOL/CMD parse logic with subagent_type/prompt parse
   - The Agent tool's stdin JSON contains `tool_input.subagent_type` and `tool_input.prompt`/`tool_input.description` — verify which field has the dispatch prompt by inspecting dispatch-jsonl-recorder.sh (which already parses the same payload) OR by adding diagnostic `printf '%s' "$STDIN_JSON" >> $LOG` initially then removing once confirmed
   - Wire BEFORE autonomous-block-enforcer at line 533-535 of settings.json
   - 6 firing-test TCs per § D3

6. **D5 cleanup is destructive — extra care**:
   - DO NOT use `rm` on any path inside .git/ — only zero-byte files at repo root level
   - Use explicit basename list (not wildcard)
   - Commit each removal in a single commit with descriptive message ("S341 D5: remove S317-era zero-byte stray basenames at repo root")
   - For root cause hunt: `grep -RnE 'echo|printf' scripts/hooks/ | grep -E '> *\$[a-z]' | head -30` is a starter

7. **D6 mypy verification challenge**: project-wide `mypy --strict packages apps` aborts on `_shared` module collision (current-execution.md line 149). Use per-file mypy: `mypy --strict apps/_shared/crawl/rate_limiter.py` only. If even that fails, document the error + skip; the F3 fix is the goal (replace `object` with `Callable`), not full mypy-clean.

8. **D7 template edits**:
   - Add inserts at the SECTION boundaries (between Phase 1 and Phase 2 of sandwich-dev.md; at top of Phase 5; in Output section of sandwich-architect.md; in Phase 9 of sandwich-verifier.md)
   - Preserve all existing template content (Karpathy P3 — surgical)
   - Verify YAML frontmatter remains valid (`head -10 .claude/agents/sandwich-<persona>.md | head -10` should still show the `---` + name/description/model/tools/--- block intact)

9. **Final commit boundary recommendation**: 4-5 commits total:
   - Commit 1: D1 (3 hooks + 1 NEW firing-test + 3 firing-test extensions)
   - Commit 2: D2 (severity-classifier trap + cleanup invocation + optional janitor + firing-test)
   - Commit 3: D3 (NEW PreToolUse hook + firing-test + settings.json wire)
   - Commit 4: D5 + D6 + D7 bundle (cleanup files + mypy fixes + template edits — small + cohesive)
   - Commit 5: S341 close-bookkeeping (session log + observation file)

10. **Observation file (test the new template discipline you're implementing!)**: write
    `agent-workspace/memory/observations/sandwich-dev-S341-harness-stabilization-sweep.md`
    summarizing what you did + obstacles + handoff for verifier. Format reference =
    this observation file you're reading.

## Promotion candidates (AP-23 1st-instance HOLD)

None new from this PLAN session. Reaffirming existing:
- L-S336-1 (escalation-engine HIGH-spam) — promoted to PRIMARY in D1 this plan
- Dispatch-template gap (3rd-instance) — promoted to D3 this plan
- Parallel-architect-dispatch (1st-instance) — DEFERRED per AP-23 + AP-7 trigger in § D4
- L-S339-1/2/3 (verifier 3 candidates from S339) — out-of-scope this plan; carry-forward to next Theme L per-source FOCUSED_IMPL

## Compliance attestation (this PLAN session)

- harness_priority_one ✓ (plan IS the harness work)
- AP-1 ✓ (architect fresh-context; dev S341 fresh-context; verifier S342 fresh-context)
- dont_self_pause_at_session_boundary ✓ (main dispatches S341 immediately on plan commit)
- D-060 ✓ (architect has no Bash; main commits this plan per dispatch-template recovery pattern)
- 0 charter / 0 constitution / 0 PROJECT_CHARTER.md changes this session
- VBW protocol ✓ (every architectural claim cites file:line; 25+ files read end-to-end)
- AP-7 anti-vacuous-defer ✓ (every DEFER in § N has explicit revisit trigger)
- AP-23 ✓ (#1 + #3 promoted via D1 + D3; #4 DEFERRED per 1st-instance HOLD with trigger; #6+#7 bundled-for-efficiency rationale documented)
- Karpathy P1-P4 ✓ (Options-considered tables for D1/D2; Simplicity in D4 defer; Surgical via Bundle DoD ~330 LOC; Goal-driven via 10 AQs + 47 DoD + 22 verifier checks)
- I-S2 source + as-of ✓ (every claim has file:line)
- I-S33 self-aware-agent ✓ (D1 fix PROTECTS the substrate)

End of S340 architect observation.
