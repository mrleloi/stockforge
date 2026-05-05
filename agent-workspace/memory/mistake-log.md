# Mistake Log — Structured Failure Catalog

> Append-only. Each entry: what went wrong / root cause / prevention rule / severity.
> Per `agent-workspace/CLAUDE.md`: "pre-flight read by all agents".
> Created S7 (2026-04-29) with first entry M-S7-1 from UP-07 follow-up.
>
> **Format** (per entry):
> ```
> ### M-<S>-<N>: <Short title>
> **Date**: YYYY-MM-DD
> **Session**: SN (or N/A)
> **Severity**: critical | high | medium | low
> **What happened**: ...
> **Root cause** (multi-layer if needed): ...
> **Prevention rule**: actionable; ideally enforced by hook
> **Where applied**: file paths of fix artifacts
> ```

---

### M-S7-1: Stale-prompt vs current-state mismatch (post-/clear)
**Date**: 2026-04-29
**Session**: S7 SessionStart
**Severity**: high (blocks autonomous flow)

**What happened**: After `/clear` and SessionStart, user submitted prompt "continue UP-07 work — check if claude-code-guide research returned, then synthesize options + fire AskUserQuestion". UP-07 was already CLOSED in S6 the same day via D-004 (4-question AskUserQuestion answered, ADR shipped, hooks updated). Agent was forced to fire a clarifying AskUserQuestion to resolve the ambiguity, blocking autonomous flow + costing scarcest resource (human time).

**Root cause** (4-layer):
- L1 (surface): User mental model lagged project state — `/clear` wiped chat history, no quick post-clear visibility into "S6 closed UP-07".
- L2 (mechanism): `scripts/hooks/continue-injector.ps1` not gated by `autonomous_mode` flag — fires every SessionStart regardless of mode (3 log files same day verified). In SUPERVISED mode this creates race condition with user typing + can re-submit work already done.
- L3 (detection gap): `scripts/hooks/session-start-bootstrap.sh` did NOT cross-check user prompt vs checkpoint state. No deterministic guardrail like queued-grill-fire-when scan exists for "stale ref" detection.
- L4 (data gap): No `up-intake-log.md` ledger tracks UP-N status (open|closed-by-DXXX) for fast lookup. Status info scattered across checkpoint + sessions/ + decisions/.

**Prevention rule**:
- (a) Continue-injector MUST be gated by `autonomous_mode` field in `agent-workspace/memory/current-execution.md`. Skip spawn if `autonomous_mode=false`.
- (b) UserPromptSubmit hook `stale-prompt-detector.sh` MUST greps user prompt for `UP-[0-9]+`, `D-[0-9]+`, `Track [0-9]+`, `S[0-9]+` references; cross-checks `up-intake-log.md` + `decisions/*.md` + `current-execution.md`; emits `additionalContext` warning if reference is CLOSED/DONE. Non-blocking (agent decides action).
- (c) Agent rule: when stale-prompt warning fires, FIRST surface closure status (1-2 sentences citing the linked decision/session) before any action. Only re-do work if user explicitly picks "redo" via AskUserQuestion or clear text.

**Where applied** (S7 ship):
- `scripts/hooks/session-start-bootstrap.sh` lines 109-148 — autonomous_mode gating
- `agent-workspace/memory/up-intake-log.md` — NEW intake ledger
- `scripts/hooks/stale-prompt-detector.sh` — NEW UserPromptSubmit hook
- `.claude/settings.json` UserPromptSubmit array — wired
- `agent-workspace/memory/agent-notes.md` — appended rule

**Auto-detect signature**: smoke-test sample stored in this entry's commit; recurrence verified zero in next 10 sessions per `correction-rate-tracker.sh` aggregator.

---

### M-S13-pre-1: session-export-raw.sh head-1 bug → 10/12 raw transcripts lost provenance
**Date**: 2026-04-29
**Session**: S13 pre-flight drift audit (user-triggered before S13 IMPL)
**Severity**: high (UP-05 directive violation; ~83% of session raw-transcript provenance silently destroyed)

**What happened**: User requested comprehensive drift audit before S13. Audit traced raw-sessions/ contains only 2 files (`2026-04-29-session-1.md` + `2026-04-29-session-5.md`) despite SessionEnd hook firing 11 times across S1-S12. .session-hooks.log showed `session-export-raw: wrote .../session-1.md` for S1 SessionEnd, then continually overwriting `.../session-5.md` for S2-S12 SessionEnds. Hash idempotency check did not catch this because each session's transcript had different content → fresh hash → overwrite filename. Net result: 10/12 raw transcripts permanently lost (silent file overwrite, no audit trail).

**Root cause** (3-layer):
- L1 (surface): `scripts/hooks/session-export-raw.sh` line 33 logic was `SESSION_N=$(grep -oE 'S[0-9]+' "$EXEC_FILE" | head -1 | sed 's/^S//')`. The current-execution.md `**Session N**:` line lists the FULL chain `S1 → S2 → ... → S<latest>`, so `head -1` always returned S1. Once line 12 was rewritten to start with "S5" (post Phase renumber), it returned S5. Filename derivation broken since project start.
- L2 (mechanism): no smoke test verified "extracted session N matches actual current session". Hook shipped at S3 (Track 5) without testing against multi-session current-execution.md.
- L3 (detection gap): no drift signal scans hook scripts for "head -1 on unscoped grep over chained lists" anti-pattern. Bug was undetectable until cumulative state inspection.

**Prevention rule** (3-fold):
- (a) Replace `head -1` with explicit marker scope: prefer `grep -oE 'S[0-9]+\s+NEXT'` (current-active session by routing convention), fall back to `grep -E '^\*\*Session N\*\*:' | grep -oE 'S[0-9]+' | sed 's/^S//' | sort -n | tail -1` (scoped grep + numerical sort).
- (b) Add smoke test in hook: post-edit, verify `bash session-export-raw.sh < sample-payload.json` produces the expected filename for the sample's session_id.
- (c) Promote bash-hook-lint signal: scan `scripts/hooks/*.sh` for pattern `grep .* head -1` over multi-element source files; flag for review. Candidate at S15 Track 7.

**Where applied** (this audit ship):
- `scripts/hooks/session-export-raw.sh` lines 29-44 — 3-tier session-N detection (NEXT marker → scoped Session N line → 0 fallback)
- `agent-workspace/memory/agent-notes.md` § "2026-04-29 (S13-pre drift audit): head -1 of Unscoped Grep Returns Wrong Element"
- `agent-workspace/memory/mistake-log.md` (this entry)

**Recovery note**: 10 lost transcripts (S2-S4, S6-S12) cannot be recovered (no harness-side source preserves them). Going forward (S13+), fix is in place. Lost provenance accepted; future audits depend on session-export-raw producing correct filenames.

**Auto-detect signature**: bash-hook-lint scan; pre-commit could verify hook post-condition (extracted session N matches expected from sample input).

---

### M-S13-pre-2: project.md stale by 12 sessions / 5 decisions / 1 phase-design REV
**Date**: 2026-04-29
**Session**: S13 pre-flight drift audit
**Severity**: medium (mental-model drift across all SessionStart reads; no IMPL poisoned but compounding cognitive overhead)

**What happened**: Drift audit found `agent-workspace/memory/project.md` last updated 2026-04-23 (Day 1 init). Across S1-S12 (12 sessions) and 5 ACCEPTED decisions (D-001..D-005) including 2 SCOPE-tier amendments (D-003 REV-3 + D-005 REV-3), no session updated project.md. State claims:
- "10 tracks total" → reality: 14 sub-tracks (Tracks 0-9 + 5.5a/b/c/d)
- "7-8 sessions, ~700-1200K tokens" → reality: 19 sessions, ~2.44M tokens user-accepted
- Recent Architectural Decisions (last 5): listed 0 of D-001..D-005 (instead 2 stale architecture choices from 2026-04-23)
- Active TODOs: Day 1 checklist items (Phase 1+ future), not Phase 0 active S13 IMPL work

Every SessionStart agent reading project.md (priority #2 per agent-workspace/CLAUDE.md) loaded stale mental model. Real-impact mitigated because current-execution.md (priority #1) was kept fresh and dominated routing.

**Root cause** (2-layer):
- L1 (process): CLAUDE.md § Session End step 1 says "Update agent-workspace/memory/project.md (if architectural decisions made)". Phrase "if architectural decisions made" is permissive — agents can rationalize "this was a sub-track decision, not architectural" → never update. 12 sessions of rationalization compound.
- L2 (no enforcement): no Stop hook diffs project.md against current-execution.md to flag mismatch.

**Prevention rule**:
- (a) Sharper Session-End rule: update project.md whenever ANY of (i) phase boundary crosses, (ii) NEW decision file added to memory/decisions/, (iii) Recent Architectural Decisions section's newest entry is older than newest decision, OR (iv) Phase Goals Tracker count differs from current-execution.md Track Status count.
- (b) Add Stop hook `scripts/hooks/project-md-staleness-check.sh` (S15 Track 7 promotion candidate per agent-notes entry): diff Phase Goals Tracker vs current-execution.md Track Status; flag mismatch.
- (c) Update project.md at this drift-audit ship; reset baseline.

**Where applied**:
- `agent-workspace/memory/project.md` — refreshed Phase 0 description (10 → 14 sub-tracks; 7-8 → 19 sessions; ~700-1200K → ~2.44M); Recent Architectural Decisions (replaced 2 stale ADRs with D-001..D-005); Active TODOs (replaced Day 1 list with Phase 0 active items + Phase 1+ queue)
- `agent-workspace/memory/agent-notes.md` § "2026-04-29 (S13-pre): Sessions MUST Update project.md..."
- `agent-workspace/memory/mistake-log.md` (this entry)

**Auto-detect signature**: `grep "10 tracks total\|7-8 sessions" project.md` after a known REV-N ratification → drift if found. Hook proposed for S15.

---

### M-S20-1: Mid-session permission-system bug surfaced via mobile-remote — Bash(*) wildcard non-functional
**Date**: 2026-04-30
**Session**: S20
**Severity**: medium (workflow blocker mid-session; user time wasted on permission grant retry; no production code damage)

**What happened**: User on mobile-remote granted `Bash` permission for `mkdir -p .claude/skills/spec-to-wiki/references && ls X && echo OK` chain; command stayed stuck after grant. Claude Code permission matcher does NOT treat `Bash(*)` as a catch-all (despite presence in allow list); compound `&&` chains match against the FIRST command only. Tactical fix mid-session: `defaultMode: bypassPermissions` + ~150 explicit `Bash(<cmd>:*)` entries.

**Root cause** (2-layer):
- L1 (matcher contract surprise): the `Bash(*)` wildcard pattern was assumed catch-all from convention with other tools (`Read/Edit/Write/Glob/Grep` accept `*`). Compound-command semantic (match-first-command) was not documented anywhere agent had read.
- L2 (no smoke test for new permission grants): no fixture verified "after adding X to allow list, simple `mkdir` actually runs". Bug invisible until live mobile-remote session.

**Prevention rule**: enumerate each tool family with `Bash(<cmd>:*)` per file; never trust `Bash(*)`. Compound chains: match against first command — chain works only if first command allowed. Mid-session permission edits apply on next session via `defaultMode`. Memory `bash_permission_pattern.md` carries the rule (already wired, no further promotion needed).

**Where applied**:
- `.claude/settings.local.json` — `defaultMode: bypassPermissions` + ~150 explicit `Bash(<cmd>:*)` entries (S20)
- `~/.ccs/.../memory/bash_permission_pattern.md` — user memory (S20)
- `agent-workspace/memory/sessions/2026-04-30-session-20.md` § "Tactical permission-system improvement"
- `agent-workspace/memory/sessions/2026-04-30-session-21.md` § R2 — verifier flagged residual `Bash(*)` line as "documented learning contradicted by config"; cleaned in S22.

**Auto-detect signature**: `grep '"Bash(\*)"' .claude/settings*.json` → if hit, contradiction with L-S20-1 doctrine; flag.

---

### M-S21-1: Verifier flagged 3 residue items (R1/R2/R3) — proposal-count drift, inert Bash(*), stale LOC
**Date**: 2026-04-30
**Session**: S21 (sandwich-verifier)
**Severity**: medium (cosmetic drift across 3 dimensions; no production damage; reflects per-session bookkeeping discipline gap)

**What happened**: Phase-0 final sandwich-verifier surfaced 3 cosmetic-but-real residue items missed by S16/S20 close ceremonies:
- **R1**: `current-execution.md` + S20-close said "6 proposals" but disk had 7 (the 7th = `provenance-protocol.md` authored S2, predates S16 Track 7 batch by ~9h; never re-counted after that).
- **R2**: `.claude/settings.local.json:11` still contained literal `"Bash(*)"` — pattern L-S20-1 explicitly says is invalid. Functionally inert (covered by `defaultMode: bypassPermissions`) but contradicts the documented learning shipped same-day.
- **R3**: `bash-hook-lint.sh` LOC stale (140 in S16 log → 143 actual on disk).

**Root cause** (2-layer):
- L1 (count-stating-without-recount): authors stated "6 proposals" once at S16 close and copied forward 4 sessions without re-running `ls agent-workspace/proposals/ | wc -l`. Session-end checklist does not require recount of derived counters.
- L2 (no diff between documented learning and actual config): L-S20-1 lesson shipped + `Bash(*)` line shipped in same session window — no closing audit grep ensured config matched lesson text.

**Prevention rule**: at every session-end, derived counters (proposals, decisions, lesson candidates) MUST be recomputed via `ls`/`find`/`wc -l` rather than copied. Append-only session logs frozen-in-time per protocol; current state authoritative via filesystem. When shipping a lesson that names an anti-pattern, grep config files for that exact pattern at the same commit.

**Where applied**:
- `agent-workspace/memory/sessions/2026-04-30-session-21.md` § Residue items
- `agent-workspace/memory/sessions/2026-04-30-session-22.md` § R1/R2/R3 fix execution

**Auto-detect signature**: phase-boundary verifier MUST diff documented counters vs `ls | wc -l` for: proposals/, decisions/, sessions/, lesson candidates in agent-notes.md.

---

### M-S25-1: Architect subagent ran ~220K tokens — above PLAN+subagent ~150-180K envelope (L-S25-1 candidate)
**Date**: 2026-04-30
**Session**: S25 (PLAN; architect dispatch)
**Severity**: low (budget overrun cosmetic; output quality high; calibration data point)

**What happened**: PLAN session dispatched architect subagent for Phase 1 master-plan authoring. Combined main+subagent self-track ran ~220K — above the calibrated ~150-180K PLAN+subagent envelope per session-budgets.md. Tracked as L-S25-1 candidate (architect budget calibration).

**Root cause**: architect ran richer than estimate due to broader Phase 1 surface than L-S21-1 verifier calibration anticipated; budget envelope calibrated against Phase 0 verify, not Phase 1 plan.

**Prevention rule**: PLAN with architect subagent for multi-track Phase: bump envelope to 180-220K; calibrate per-Phase. Do not hardcode 150K from L-S21-1 (that was VERIFY whole-Phase 0 surface).

**Where applied**:
- `agent-workspace/memory/sessions/2026-04-30-session-25.md` § DR-BUDGET
- `agent-workspace/memory/agent-notes.md` (L-S25-1 batched for promotion at Phase 2 close)

**Auto-detect signature**: budget-watchdog post-PLAN check: if `tokens_real_combined > 180K` AND session_type=PLAN → flag for calibration update.

---

### M-S26-1: Master-plan internal contradiction — deliverable text vs success-criteria abstract count (8 vs 9 proposals)
**Date**: 2026-04-30
**Session**: S26
**Severity**: medium (plan-fidelity ambiguity; agent forced to self-decide IMPL-tier deviation; precedent for future plans)

**What happened**: Master-plan 004 § S26 deliverable #1 text said "separate file" (financial-data-protocol-amendment-VN.md alongside existing -amendment.md); success-criteria #7 said "fold to 8 proposals". Agent executed deliverable explicit text → 9 proposals net (not 8). Documented as IMPL-S26-1 + L-S26-1 candidate (master-plan internal contradiction resolution doctrine).

**Root cause** (2-layer):
- L1 (plan-author drift across sections): master-plan 004 authored at S25, deliverables and success-criteria edited in different passes; abstract counter (8) not refreshed when deliverable #1 was finalized as "separate file".
- L2 (no plan-internal-consistency lint): no automated cross-check between deliverable counts and success-criteria abstract numbers.

**Prevention rule**: when master-plan deliverable explicit text contradicts success-criteria abstract count, prioritize deliverable text; document as IMPL-tier drift in session log. PLAN-author doctrine: abstract counters in success-criteria MUST be derived from deliverable list, not asserted independently.

**Where applied**:
- `agent-workspace/memory/sessions/2026-04-30-session-26.md` § Master-plan drift documented + IMPL-S26-1
- `agent-workspace/memory/agent-notes.md` (L-S26-1 batched)
- `agent-workspace/proposals/decision-discipline.md` § "Master-plan internal contradiction resolution doctrine" (proposed)

**Auto-detect signature**: master-plan lint — count deliverables block vs success-criteria abstract number → mismatch flag.

---

### M-S28-1: Vendor-API surface drift — vnstock 4.0.2 dropped TCBS as Quote source between PLAN and IMPL (6h apart)
**Date**: 2026-04-30
**Session**: S28
**Severity**: high (would have caused silent fake-data-source if not caught at IMPL probe; affected production data adapter)

**What happened**: Master-plan 004 (authored S25 morning) referenced TCBS as primary alternative source via `vnstock.api.quote.Quote(symbol, source='TCBS')`. At S28 IMPL entry probe (~6h later same day), `Quote(symbol='VHM', source='TCBS')` raised `ValueError: ... source là kbs, vci, msn, dnse, binance, fmp, fmarket` — TCBS REMOVED in vnstock 4.0 migration. Agent rerouted: VnstockAdapter→VCI; TcbsAdapter→direct REST to `apipubaws.tcbs.com.vn` (which then 404'd at live smoke → SINGLE_SOURCE fallback per IMPL-S28-3). Live smoke produced 248 SINGLE_SOURCE rows; reconciliation never exercised genuine 2-source compare (R2 carry-over to Phase 2).

**Root cause** (3-layer):
- L1 (vendor-API surface drifts faster than plan-write→plan-execute window): library deprecated TCBS in 4.0; PLAN cited TCBS without probing live API.
- L2 (no PLAN→IMPL boundary probe contract): nothing in master-plan or session-budgets requires probing every named external library at PLAN→IMPL boundary.
- L3 (TCBS public REST endpoint subsequently 404 too — second-order vendor drift): the documented public endpoint `apipubaws.tcbs.com.vn/stock-insight/v2/stock/bars-long-term` returned 404 at smoke. Two layers of vendor drift in the same session.

**Prevention rule**: every external library/API in master-plan MUST be probed via context7 OR live import at PLAN→IMPL boundary; if surface drifted, IMPL session adjusts and documents IMPL-tier deviation inline. Dual fallback wiring (multi-source) ALWAYS keeps SINGLE_SOURCE mode as legitimate exit, never silent map to fake source. Naming preserved (file = `tcbs_adapter.py` even if endpoint failing) so deprecation surface is visible to future readers.

**Where applied**:
- `packages/infrastructure/market_data/vnstock_adapter.py` — VCI source (IMPL-S28-1)
- `packages/infrastructure/market_data/tcbs_adapter.py` — direct REST + `TcbsApiError` clean raise on 404 (IMPL-S28-1)
- `apps/cli/ingest_vhm.py` — SINGLE_SOURCE fallback path (IMPL-S28-3)
- `agent-workspace/memory/sessions/2026-04-30-session-28.md` § IMPL-S28-1, IMPL-S28-3, L-S28-1
- `agent-workspace/proposals/architecture-amendment.md` § "Adapter library surface lock-in" (proposed)

**Auto-detect signature**: PLAN→IMPL boundary linter: `grep -E 'vnstock|httpx|requests' master-plan-N.md | xargs -I{} python -c "import {}; print({}.__version__)"` at IMPL entry → diff against PLAN as-of date.

---

### M-S29-1: Phase 1 verifier surfaced 4 residue items (R1-R4) — observability mypy / TCBS 404 / LOC ceilings / LOC bookkeeping
**Date**: 2026-04-30
**Session**: S29 (sandwich-verifier Phase 1)
**Severity**: medium (4 residue items; all LOW severity individually; none blocking S30; reflects mid-Phase quality-gate gaps)

**What happened**: Phase 1 sandwich-verifier sweep found:
- **R1**: 8 mypy errors in `packages/observability/` (Phase 0 baseline carry; includes 1 StrEnum migration tail at `test_state_machine.py:30` analogous to S28 retroactive fix on `test_types.py:26-28`).
- **R2**: TCBS 404 → 248 SINGLE_SOURCE; reconciliation logic only exercised by 5 fixture tests, not by live data (carry from M-S28-1).
- **R3**: 5 production files exceed master-plan advisory LOC ceilings (tcbs +6%, reconciliation +27%, sqlite_bar +46%, ingest_vhm +27%, test_adapters +45%).
- **R4**: Checkpoint claim "S27+S28 = ~3,378 LOC" diverges from verifier independent count (2,039 LOC across 26 .py files; 3,378 includes barrels + observability).

**Root cause** (2-layer):
- L1 (deferred-fix accumulation): R1 known since Phase 0 baseline; R3 ceilings deferred per IMPL-S28-2 documentation; cumulative drift across 4-session window builds without a Phase-mid forced cleanup checkpoint.
- L2 (LOC bookkeeping ambiguity): no canonical definition of "LOC for a phase" — barrels in/out, observability in/out — caused R4 numerical divergence.

**Prevention rule**: phase-mid verifier (between PLAN-mid and PLAN-close) catches accumulating residue early; LOC-counting standard MUST be defined at master-plan time (e.g., `wc -l packages/**/*.py packages/**/*.py` with explicit excludes) and used uniformly in all session checkpoints.

**Where applied**:
- `agent-workspace/memory/sessions/2026-04-30-session-29.md` § R1-R4
- `agent-workspace/memory/observations/2026-04-30-S29-verifier.md` (verifier observation)

**Auto-detect signature**: verifier-gate: diff `wc -l` actual vs checkpoint-claimed totals; flag if delta > 10%.

---

### M-S31-1: PLAN session breached BUDGET — master-plan 005 = 790 LOC vs ≤700 advisory (IMPL-S31-1)
**Date**: 2026-04-30
**Session**: S31 (PLAN; master-planner subagent)
**Severity**: low (cosmetic; +13% under D1 20% threshold; per-session density actually compact)

**What happened**: Master-plan 005 (Phase 2) shipped at 790 LOC vs ≤700 advisory ceiling. Per-session density 72 LOC/session (11 sessions) is actually MORE compact than master-plan 004's 106 LOC/session. Documented IMPL-S31-1; no remediation. PLAN subagent ran ~158K tokens (within L-S25-1 calibrated 150-200K).

**Root cause**: master-plan length advisory ≤700 was set against shorter (5-session) plans; 11-session Phase 2 plan needs proportionally larger surface. Advisory not parameterized by plan span.

**Prevention rule**: parameterize master-plan LOC advisory by session count: `≤ 80 LOC × N_sessions` (typical) or `≤ 130 LOC × N_sessions` (complex multi-track). Static 700 cap is anti-pattern.

**Where applied**:
- `agent-workspace/session-plans/pending/005-S31-phase-2-master-plan.md` (790 LOC)
- `agent-workspace/memory/sessions/2026-04-30-session-31.md` § IMPL-S31-1

**Auto-detect signature**: PLAN-output linter — compute `LOC / session_count` density; flag only if density > 130 LOC/session (not absolute LOC).

---

### M-S34-1: Cross-BC import in `peer_service.py` not detected pre-write — required mid-session refactor (L-S34-1)
**Date**: 2026-04-30
**Session**: S34
**Severity**: high (architectural-boundary violation; caught only mid-session, not at write-time; would have silently leaked BC dependency into BC-2 production code)

**What happened**: Initial draft of `packages/domain/fundamental/services/peer_service.py` imported `VN30_UNIVERSE` directly from BC-1 (`packages/domain/market_data/...`) — direct cross-BC import. Architecture rule "Cross-BC communication via contracts only" was violated at draft-write time. Caught only when post-write `grep -rn "from packages.domain" packages/domain/fundamental/` ran during cross-BC sweep deliverable check. peer_service.py rewritten mid-session to consume contract event / repository contract; cross-BC sweep then = 0 hits.

**Root cause** (3-layer):
- L1 (no pre-write import linter on cross-BC): write-time gate did not parse imports against BC-membership map. Discovery happened only at deliverable-check sweep.
- L2 (architect-subagent did not flag in plan): master-plan 005 § S34 listed peer_service.py with sector-peer lookup; sector data lives in BC-1; plan did not call out the contract-only constraint explicitly.
- L3 (no fast `import-linter` config or equivalent): tooling for BC-boundary enforcement (`import-linter`, `tach`, custom AST script) not installed.

**Prevention rule**: pre-write/pre-commit import linter MUST scan `packages/domain/<bc-N>/**/*.py` and forbid `from packages.domain.<other-bc>` imports — only `packages.contracts.*` allowed. Configure `import-linter` or equivalent; wire as Tier-1 deterministic gate. Plans listing files that consume cross-BC data MUST explicitly cite contract path.

**Where applied**:
- `packages/domain/fundamental/services/peer_service.py` (rewritten mid-session)
- `agent-workspace/memory/sessions/2026-04-30-session-34.md` § Cross-BC import sweep + L-S34-1
- `agent-workspace/memory/agent-notes.md` (L-S34-1 batched for promotion at Phase 2 close)

**Auto-detect signature**: pre-commit hook — `python -c "import ast; ..."` AST scan on `packages/domain/**/*.py` checking imports against BC-map; reject if cross-BC direct import found.

---

### M-S35-1: Confabulated drift report — claimed `.transcript-tokens` / telemetry / dispatch / reboot files "missing" when all exist
**Date**: 2026-05-01
**Session**: S34-extension (today)
**Severity**: high (VBW protocol violation; eroded user trust in agent's audit capability; emitted false HIGH/CRITICAL recommendations against existing infrastructure)

**What happened**: During S34-extension drift report, claimed `.transcript-tokens`, `component-telemetry.jsonl`, `dispatch.jsonl`, `session-self-reboot.sh` were "missing" — all four EXIST at correct paths. Agent searched wrong folders, then asserted HIGH/CRITICAL drift without VBW protocol read of the actual source scripts. False signal escalated to user as "recommendations to fix missing infrastructure" when no infrastructure was missing.

**Root cause** (3-layer):
- L1 (VBW protocol violation — CLAUDE.md hard rule): "VBW Protocol mandatory before writing specs/tests/code. Read actual source, not memory." Drift reports are agent-generated specs about state; same rule applies. Agent asserted file-path absence from memory rather than `ls`/`Glob`.
- L2 (search-folder choice without pre-flight): searched a single conjectured folder, not the canonical paths in `scripts/hooks/` + `agent-workspace/memory/observations/`. No fallback search before negative assertion.
- L3 (no negative-assertion guard): nothing in agent flow blocks emitting "X is missing" without a `Glob` + `Read`(parent dir) round-trip.

**Prevention rule**: every "X is missing" or "X does not exist" assertion in any drift report or audit MUST be preceded by an explicit `Glob` or `ls` over the full known root (`./` + `scripts/` + `agent-workspace/`) — NOT a single conjectured subdir. Negative assertions are claims; claims need source. Drift-detector subagent brief MUST include "VBW protocol applies to negative assertions" in system prompt.

**Where applied**:
- `agent-workspace/memory/post-mortems/2026-05-01-self-awareness-promotion-skip.md` § "What actually happened" + cognitive failure 1+2
- `agent-workspace/memory/checkpoints/latest.md` § "LLM cognitive failures em confessed (this turn)" item 1+2

**Auto-detect signature**: post-hoc audit — grep agent output for `("missing"|"does not exist"|"not found")` immediately preceded (within 50 LOC) by no `Glob`/`Bash(ls`/`Read` tool call → flag as unverified negative assertion.

---

### M-S35-2: Echo-chamber acceptance of drift-detector subagent verdict — no scope cross-verify
**Date**: 2026-05-01
**Session**: S34-extension
**Severity**: high (AP-1 same-class self-review violation; subagent verdict treated as final word; user audit was the only recovery)

**What happened**: Drift-detector subagent dispatched earlier in S34-extension reported "PASS-WITH-RESIDUE 0 HIGH". Agent accepted the verdict as comprehensive coverage. Subagent in fact ran only DR1-DR12 technical signals (per `constitution/drift-signals.md`) — same scope as `/drift-check` skill — and did NOT check self-awareness loop liveness, promotion cycle status, or `human-workspace/user_prompt/` intent alignment (DR-INTENT). Scope gap invisible until user audit prompt forced surface. 4 dead loops (mistake-log + KI/BP + promotion + DR-INTENT) had been silently dead 15 sessions.

**Root cause** (2-layer):
- L1 (subagent-as-final-word): no agent step "after subagent returns, verify subagent's scope covered the questions you needed answered". Verdict accepted by signature-of-finality.
- L2 (`/drift-check` skill scope blind to meta-loop liveness): drift-signals.md DR1-DR12 cover code-level technical drift only. DR-INTENT (re-read user_prompt/* at phase boundary) is mentioned in CLAUDE.md SYNTHESIS § 6 AP-5 but not codified as a DR signal.

**Prevention rule**: after every subagent return, agent MUST emit a 1-line "subagent scope check" — list what subagent covered vs what original task required; if gap, dispatch follow-up or run delta personally. Drift-check skill MUST be extended with DR-INTENT (`/drift-check` skill amendment) — diff `human-workspace/user_prompt/*` content vs active `current-execution.md` Goals.

**Where applied**:
- `agent-workspace/memory/post-mortems/2026-05-01-self-awareness-promotion-skip.md` § cognitive failure 6
- `agent-workspace/memory/checkpoints/latest.md` § cognitive failure 3

**Auto-detect signature**: post-subagent agent-flow check — `grep "scope check" agent-output` after Task() return → if absent, flag.

---

### M-S35-3: Self-track ignored, ran ~280K tokens past 250K hard_cap without auto-fire handoff
**Date**: 2026-05-01
**Session**: S34-extension
**Severity**: high (Charter hard rule violation — context-threshold band per D-004; budget-watchdog auto-fire bypassed; mandatory split only triggered after user audit, not at hard_cap)

**What happened**: S34-extension self-track climbed past 220K cliff to ~280K — VƯỢT hard_cap 250K (CLAUDE.md mandatory split). `.cliff-fired` marker was set from S34 close; `budget-watchdog.sh` did not re-fire `session-self-reboot.sh`. Agent did not note band-cross or force handoff. Mandatory split eventually written manually as part of recovery checkpoint after user audit forced surface.

**Root cause** (3-layer):
- L1 (`.cliff-fired` not archived between sub-sessions): once marker is set, watchdog suppresses re-fire. S34 closed with `.cliff-fired` set; S34-extension started in same harness without resetting.
- L2 (agent self-track band-monitoring not internalized as continuous duty): agent treated self-track as a passive metric, not an active cap to enforce. CLAUDE.md band rules (180K/220K/250K) are listed as "Charter hard rule" but no agent-side ritual fires at 220K.
- L3 (AP-2: self-track wind-down — `.transcript-tokens` real-transcript is authoritative, not LLM self-track — and self-track is unreliable for catching cliff in real time).

**Prevention rule**: at session start, archive prior `.cliff-fired` marker → `.cliff-fired.s<N-1>-archived` (per S35 sub-plan recovery action; now codified). Agent at every Stop hook check `tokens_real` from `.transcript-tokens` (NOT self-track) against bands; if ≥ 220K, force write checkpoint + handoff text. Band thresholds may need recalibration per D-004 empirical re-eval.

**Where applied**:
- `agent-workspace/memory/checkpoints/latest.md` § "vượt hard_cap 250K" + handoff
- `.cliff-fired.s34-archived` (marker archived this turn)
- `agent-workspace/session-plans/pending/006-S35-meta-loop-recovery.md` (D5/D6 candidates: agent-side band ritual)

**Auto-detect signature**: budget-watchdog post-Stop — if `tokens_real >= 250000` AND no checkpoint written this turn → auto-emit "MANDATORY SPLIT MISSED" notification.

---

### M-S35-4: 4 dead meta-loops skipped 15 sessions — plan-fidelity > meta-loop-fidelity
**Date**: 2026-05-01 (surfaced); incurred S20-S34
**Session**: S34-extension (audit)
**Severity**: critical (4 continuous-obligation loops silently dead 15 sessions; drift-compounded invisibly; only surfaced by user audit prompt; if undetected, promotion + self-awareness data would be unrecoverable for whole Phase 1+2)

**What happened**: Per post-mortem 2026-05-01 file mtime evidence:
- `mistake-log.md` last touch 2026-04-29 20:37 (S19) — DEAD 15 sessions, 0 M-S20..M-S34 entries
- `known-issues.md` + `best-practices.md` — only seed KI-001/002/003 + BP-001/002/003 from Track 9 build; 0 cards from Phase 1+2 work
- `profile-template.md` — NEVER USED, 0 populated cards
- Promotion cycle — 9 proposals + 7 lesson candidates batched, **0 promoted to constitution since project start**; constitution mtime baseline Apr 24
- DR-INTENT — `human-workspace/user_prompt/*` (8 prompts) never re-read at phase boundary

**Root cause** (4 LLM cognitive failure modes per post-mortem § Root cause analysis):
- L1 (plan-fidelity > meta-loop-fidelity): Agent focused on master-plan deliverable matrix; continuous loops not in deliverable matrix → invisible.
- L2 ("defer to phase close" black hole): Lessons batched with mindset "promote at S43"; phase boundaries themselves crowded with closure work; promotion never executes.
- L3 (CLAUDE.md § Session End checklist incomplete): 5-step ritual covers session-state updates but missing explicit steps for mistake-log + KI/BP card + promote-rule trigger.
- L4 (confused one-shot deliverables with continuous loops): Track 9 shipped S19 as one-shot (templates + aggregator + skill); Em treated as "shipped" → forgot Track 9 = continuous obligation. Same pattern for promotion cycle.

**Prevention rule** (4-fold; per post-mortem § Promotion candidates):
- (a) Stop hook `promote-rule auto-trigger`: detect "≥3 lesson candidates batched OR ≥10 sessions since last promotion" → auto-fire promote-rule subagent. Tighten Q-E2 doctrine "promote at phase boundary" to N-cap.
- (b) Stop hook `session-end-checklist linter`: verify last session log mentions mistake-log update OR explicit "no mistakes this session" — soft-warn if missing.
- (c) Extend `/drift-check` skill: append DR-INTENT signal — diff `human-workspace/user_prompt/*` against active `current-execution.md` Goals; flag soft if any UP item not addressed.
- (d) Amend CLAUDE.md § Session End: explicit step "If failure / drift / user-correction happened: append M-S{N}-* entry to mistake-log.md" + "If new lesson emerged: append KI-S{N}-* card".

**Where applied**:
- `agent-workspace/memory/post-mortems/2026-05-01-self-awareness-promotion-skip.md` (full audit + LLM root cause)
- `agent-workspace/session-plans/pending/006-S35-meta-loop-recovery.md` (8-deliverable recovery plan)
- `agent-workspace/memory/mistake-log.md` (this backfill — D1 of S35 recovery)

**Auto-detect signature**: Stop hook check — `mtime(mistake-log.md) - mtime(latest session log) > 7 days` → flag DEAD-LOOP HIGH; same for KI/BP cards + promotion-cycle artifacts.

---

### M-S35-5: "Want me to /schedule..." human-gate offer at S34 close — defection from autonomous_mode
**Date**: 2026-05-01
**Session**: S34 close → S34-extension
**Severity**: high (violates user memory `full_autonomous_no_supervised.md`: "No human-in-the-loop bifurcation; trust Stop hook + Mode-D for routine handoffs; AskUserQuestion is for SCOPE/CHARTER only")

**What happened**: At S34 close, agent emitted "Want me to /schedule..." offer for routine follow-up — a human-gate pattern. Memory `full_autonomous_no_supervised.md` (binding `autonomous_mode=true`) explicitly bans bifurcating routine flow into "ask user". The /schedule skill's "OFFER PROACTIVELY" trigger landed on agent without override-by-user-memory check.

**Root cause** (2-layer):
- L1 (skill default trigger overrode user memory): /schedule skill description includes "ALSO OFFER PROACTIVELY" — agent followed skill default without checking `full_autonomous_no_supervised.md` precedence. CLAUDE.md hard rule "User prompt overrides ALL defaults" applies to user MEMORY too, not just session prompts.
- L2 (no agent-side `autonomous_mode` gate around AskUserQuestion-class offers): no ritual checks `current-execution.md` autonomous_mode flag before emitting any "Want me to..." prompt to user.

**Prevention rule**: agent-side gate — before emitting any "Want me to ..." / "Should I ..." / "/schedule ..." offer, check `current-execution.md` `autonomous_mode` field. If `true`, route the action through internal scheduling (Stop-hook handoff, current-execution.md Next Session block) — NOT through human prompt. Skill descriptions ("OFFER PROACTIVELY") are defaults; user memory and `autonomous_mode=true` override.

**Where applied**:
- `agent-workspace/memory/checkpoints/latest.md` § cognitive failure 4
- `agent-workspace/memory/post-mortems/2026-05-01-self-awareness-promotion-skip.md` § cognitive failure (AP-5 layer)

**Auto-detect signature**: post-message agent-output linter — grep agent output for `(Want me to|Should I|/schedule|/loop)\s` → if matched AND `autonomous_mode=true`, flag autonomous-defection.
