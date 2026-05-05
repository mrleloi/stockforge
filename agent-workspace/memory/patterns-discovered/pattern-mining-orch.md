# Pattern Mining — Orch Knowledge Crystal
**Date**: 2026-04-29
**Source**: C:\htdocs\orch-starter\agent-workspace\memory\
**Files read**: 27 (3 phase retros, 14 decisions, 2 constitution files, agent-notes.md, project-complete.md, README + meta-retrospective + Phase 12 active + Phase 0/1 retros + 2 directory listings)
**Token budget**: ~48K consumed of 50K cap

---

## Executive Summary

1. **Tool-call-first ordering** is the most surgically-leveraged hook port for stockforge. Orch logged ~33 Mode-B (API mid-stream truncation) STOP events in a single 7h window; defeating it required restructuring assistant turns so the `Agent` tool_use block emits BEFORE narrative text. This is the highest-ROI port for stockforge's autonomous loop.

2. **Three named loop-break modes** (Mode A narrate-without-tool-call, Mode B API truncation, Mode C self-track illusion) carry different root causes but identical chat appearance. Stockforge MUST port all three named, with the structural fix for each: tool-call-first lint (A), continue-injector hook (B), real-transcript pre-stop check via `.transcript-tokens` (C).

3. **Adversarial opus verifier with fresh context catches what same-agent sonnet review misses** — every phase had at least one critical finding from sandwich-verifier (P0 Date redaction, async-void leak, dead security primitives, unauthenticated /admin). Single-agent self-review was the highest anti-pattern. The two-stage spec-compliance + code-quality reviewer pair (sonnet) plus phase-end opus sandwich-verifier is the highest-value quality gate orch built — port wholesale.

4. **Real-transcript watchdog (`.transcript-tokens`) over LLM self-track** prevented Mode C recurrence after Session #23. Self-track inflates ~25-35% over real (165K self vs 122K real observed). Stockforge should never trust LLM-side budget reasoning for end-turn decisions.

5. **Effort routing (Decision 032: D1 default sonnet/medium; D2 escalation gate for opus/medium+; D4 concurrency caps ≤4 agents/≤2 opus/≤1 opus-max)** prevented quota burnout after Session #41 hit quota mid-flight from over-using opus/max. Port D1-D6 with stockforge model names (Claude API not subscription).

6. **Charter-coherence defer logic (Deliberation E pattern) silently overrode user intent** for 4 cycles on CF-DOGFOOD-2. The fix is mandatory `tasks/*/user_prompt.txt` re-read at every phase entry + USER-CRITICAL severity tier above "important" + scripted post-phase coherence gate. This pattern protects "user told me X is important" from getting buried under technical defer rationale.

7. **Decision-doc discipline** (NNN-slug.md, sequential, Status: active/superseded-by-XXX, README index) gave clean audit trail for ~43 decisions across 12 phases. Port the README + format conventions verbatim; retroactively backfill missed decisions via Decision 032's pattern.

8. **dispatch.jsonl as machine-readable event log** (separate from human-narrative budget-tracker.md) is the right architecture for component telemetry — append-only JSONL with 9-field schema (event/dispatch_id/agent_type/model/parent_session_id/bg/ts_ms/outcome/tokens_used). Critical lesson: `tool_use_id` correlation has structural blockers (settings.json read-once + PreToolUse stdin payload gap) that took 4 phases to diagnose. Stockforge can avoid this by using SubagentStop-side capture only and not pursuing PreToolUse correlation initially.

9. **The "daemon-dumb / workers-smart" invariant (I-1)** is enforced by grep gates over `packages/core/`. Decision 006 (handoff-no-llm) is the canonical example — explicit foreclosure of "just one little LLM call" rationalization, with grep-test enforcement at verifier-time. Stockforge's equivalent: NO LLM math (already in CLAUDE.md), enforced by similar deterministic grep over `packages/domain/` for any numeric computation by LLM.

10. **Self-application (orch coding orch)** took 4 phases to actually wire the dispatch step (CF-DOGFOOD-2). The LESSON: encode "self-application" as a same-phase deliverable from day 1, not as a CF that gets technically deferred. Stockforge's Phase 0 should already wire stockforge-codes-stockforge, not defer it.

---

## Top 10 BORROW Patterns

For each: name, source file path, what it does, why high-leverage, exact port destination in stockforge.

### B1. Tool-call-first ordering rule (autonomous-protocol.md TURN-END DISCIPLINE)
- **Source**: `C:\htdocs\orch-starter\agent-workspace\constitution\autonomous-protocol.md` lines 277-385
- **What**: When dispatching after a `<task-notification>`, structure the assistant response with `Agent` tool_use as the FIRST content block. Long summaries/analysis go AFTER the tool call (or into memory files), not before. Defeats Mode B API mid-stream truncation.
- **Why high-leverage**: The dominant cause of human intervention in orch (33 STOP events in 7h on 2026-04-25). One-line discipline change with measurable impact.
- **Stockforge port**: `C:\htdocs\stockforge\agent-workspace\constitution\autonomous-protocol.md` § TURN-END DISCIPLINE — copy verbatim with stockforge thesis-log/post-mortem path substitutions.

### B2. Real-transcript pre-stop check (`.transcript-tokens` watchdog)
- **Source**: `autonomous-protocol.md` lines 311-342 + `agent-notes.md` lines 17-21
- **What**: Before any wind-down action, mandatory read of `.transcript-tokens` (real, written by budget-watchdog.sh from JSONL `message.usage.*`) instead of trusting LLM self-track. Forbidden rationales: "self-track approaching 200K", "past 150K soft-prep", "want to give next task fresh envelope".
- **Why high-leverage**: Mode C cost ~2.5h dead time per occurrence; one-rule fix prevents recurrence.
- **Stockforge port**: `C:\htdocs\stockforge\agent-workspace\constitution\autonomous-protocol.md` § DEFEATING FAILURE MODE C + `scripts/hooks/budget-watchdog.sh` (Python rewrite acceptable). Threshold: 200K real transcript = wind-down.

### B3. Two-stage subagent review (spec-compliance + code-quality + opus sandwich-verifier at phase close)
- **Source**: `phase-1-complete.md` Tasks 1.10/1.16 + `phase-3-complete.md` + `project-complete.md` "What Worked Well"
- **What**: Per-task: spec-compliance-reviewer (sonnet) + code-quality-reviewer (sonnet). Per-phase close: sandwich-verifier (opus, fresh context, mandatory). The opus fresh-context verifier had ~25% FAIL rate vs ~5% for sonnet implementer — productive failures (real bugs caught: P0 Date redaction, CRITICAL-1 async-void leak, dead security primitives).
- **Why high-leverage**: Single highest-quality gate in entire pipeline. Treat APPROVED_AFTER_FIX as expected outcome, not exception.
- **Stockforge port**: `C:\htdocs\stockforge\.claude\agents\` — port `spec-compliance-reviewer.md`, `code-quality-reviewer.md`, `sandwich-verifier.md` (currently absent from stockforge skills list). Adapt to thesis review use case: spec-compliance = does the thesis cite all required sources / has bear case / has confidence calibration?; code-quality = is data-pipeline code clean?; sandwich-verifier = adversarial review at phase close including "did the thesis numbers come from code, not LLM?"

### B4. Decision-doc discipline (NNN-slug.md sequential format + README index)
- **Source**: `C:\htdocs\orch-starter\agent-workspace\memory\decisions\README.md` + 43 decision files
- **What**: One file per non-trivial decision made without user input. Format: `NNN-short-slug.md` zero-padded sequential. Status: active / superseded-by-XXX / ratified / BINDING. README has index table. Each decision has Context / Options Considered / Decision / Charter Reference / Consequences / Reversibility sections.
- **Why high-leverage**: Made the 4-cycle CF-DOGFOOD-2 drift detectable (decisions 027/039/040/041 trace the resolution chain). Enables Phase N's master-planner to read decisions for context.
- **Stockforge port**: `C:\htdocs\stockforge\agent-workspace\memory\decisions\` (already exists per dir listing). Copy README.md template verbatim. Stockforge equivalents will track thesis decisions, source-prioritization decisions, calibration-drift decisions.

### B5. dispatch.jsonl machine-readable event log (separate from human-readable budget-tracker.md)
- **Source**: `decisions/023-7.2-dispatch-jsonl-schema.md` + `scripts/hooks/dispatch-jsonl-recorder.sh`
- **What**: Append-only JSONL at `agent-workspace/memory/dispatch.jsonl`. 9-field schema: event/dispatch_id/agent_type/model/parent_session_id/bg/ts_ms/outcome/tokens_used. DISPATCHED + COMPLETED events as separate lines. Parsing is 2-line snippet.
- **Why high-leverage**: Enables programmatic analysis (subagent-failure-rate, p99-duration, cost-per-task-shape) without LLM. Foundation for Self-Awareness Agent and Confidence Score System.
- **Stockforge port**: `C:\htdocs\stockforge\agent-workspace\memory\dispatch.jsonl` (new) + `scripts/hooks/dispatch-jsonl-recorder.{sh,py}` (Python preferred per stockforge stack). Add stockforge-specific event types: thesis-dispatched, source-fetched, calibration-update.

### B6. Run-in-background discipline (`run_in_background: true` mandatory for Agent dispatches)
- **Source**: `agent-notes.md` line 31-33 + Phase 1 lesson
- **What**: Foreground Agent calls stall the runtime; `<task-notification>` only fires for background agents. Without bg=true, main session hangs indefinitely.
- **Why high-leverage**: Phase 1 catastrophic failure mode; held universally after Phase 1 lesson.
- **Stockforge port**: `C:\htdocs\stockforge\CLAUDE.md` + autonomous-protocol.md — explicit MUST rule. Port to all stockforge agent dispatch code.

### B7. Hook commands MUST use `${CLAUDE_PROJECT_DIR:-.}` and `mkdir -p`
- **Source**: `agent-notes.md` line 36-38
- **What**: Relative paths break from subagent cwds. All hook `command` entries must prefix with `${CLAUDE_PROJECT_DIR:-.}` and run `mkdir -p "$(dirname "$LOGFILE")"` before first write.
- **Why high-leverage**: Prevents Mode D hook misconfig failure mode. Caught early in orch (Phase 1) and never recurred.
- **Stockforge port**: All `C:\htdocs\stockforge\scripts\hooks\*.{sh,py}` — universal prefix rule.

### B8. autonomous-stop-watchdog hook + continue-injector pattern (structural Mode-C fix)
- **Source**: `agent-notes.md` lines 23-26 + `scripts\hooks\autonomous-stop-watchdog.sh` + `scripts\hooks\continue-injector.ps1`
- **What**: Stop hook that detects premature wind-down and fires continue-injector via SendKeys. Memory rules alone failed twice; the watchdog is the structural fix.
- **Why high-leverage**: Structural rather than discipline fix; survives even if LLM forgets the rule.
- **Stockforge port**: `C:\htdocs\stockforge\scripts\hooks\autonomous-stop-watchdog.{sh,py}` + Windows-specific continue-injector (since stockforge runs 24/7 on home PC per problem statement). NOTE: SendKeys requires AttachThreadInput foreground-bypass + 4-retry loop (per agent-notes.md line 56-59).

### B9. Effort routing framework D1-D6 (Decision 032)
- **Source**: `decisions/032-effort-routing.md`
- **What**: D1 default (sonnet, medium); D2 escalation gate for opus/medium+ requires inline justification; D3 budget logging in budget-tracker.md; D4 concurrency caps ≤4 agents / ≤2 opus / ≤1 opus-max; D5 effort-routing skill consultation; D6 retroactive downshift policy.
- **Why high-leverage**: Quota burn incidents (Session #41 mid-flight quota exhaustion) prevented after framework adoption.
- **Stockforge port**: `C:\htdocs\stockforge\agent-workspace\memory\decisions\NNN-effort-routing.md` + skill `.claude/skills/effort-routing/SKILL.md`. Adapt to Claude API rate limits (not subscription quota): caps shift to API rate-limit headroom.

### B10. User-intent coherence: tasks/*/user_prompt.txt re-read at every phase entry + USER-CRITICAL tier
- **Source**: `agent-workspace/constitution/user-intent-coherence.md` + `decisions/040-cf-dogfood-2-r039-5-user-override.md`
- **What**: USER-CRITICAL severity tier (above "important"). Defer rules: cannot defer to next phase without explicit user-override decision in current cycle. Multi-cycle defer FORBIDDEN absent user re-grant per cycle. Phase-entry checklist: master-planner reads ALL user_prompt.txt files (not just most recent), builds attestation table.
- **Why high-leverage**: Prevented 4-cycle drift on CF-DOGFOOD-2 (Phase 8→11). Items can be USER-CRITICAL even if technical complexity is low.
- **Stockforge port**: `C:\htdocs\stockforge\agent-workspace\constitution\user-intent-coherence.md`. The Phase 0 brief stockforge has now (`user_requirement.md`) is the canonical user-intent source. Add USER-CRITICAL tier and phase-entry re-read checklist.

---

## Top 10 ADAPT Patterns

For each: name, source, adaptation needed for Python/FastAPI stack, port destination.

### A1. Telemetry-Analyst RULE-1..RULE-4 + rollup-telemetry deterministic aggregator
- **Source**: `decisions/017-6.2-feedback-loop-architecture.md` + `decisions/021-6.2-telemetry-analyst-tier.md` + `.claude/agents/telemetry-analyst.md`
- **What**: Two-stage feedback loop: (1) deterministic `rollup-telemetry.ts` reads dispatch.jsonl → emits `component-rollup-<phase>.md` table (count, success_rate, p50/p99 duration, p50/p99 tokens, top failure modes); (2) `telemetry-analyst` sonnet subagent reads rollup + master-planner.md routing rules → emits `phase-N-routing-recommendations.md` proposals.
- **Adaptation**: Python rewrite. `scripts/utilities/rollup_telemetry.py`. Telemetry-analyst stays as Claude subagent. Stockforge-specific RULES: RULE-stock-source-failure (count >= 5 AND source_success_rate < 0.7), RULE-thesis-bear-case-missing (≥ 1 thesis lacks bear case), RULE-calibration-drift (predicted vs actual hit-rate gap > 15%).
- **Stockforge port**: `C:\htdocs\stockforge\.claude\agents\telemetry-analyst.md` + `scripts\utilities\rollup_telemetry.py`. Output: `agent-workspace/memory/component-rollup-phase-N.md`.

### A2. Daemon-dumb invariant (I-1) enforcement via grep gate
- **Source**: `decisions/006-handoff-no-llm.md` + invariants.md I-1
- **What**: Forbidden imports `anthropic|@anthropic-ai|openai|claude-agent-sdk|ClaudeSDKClient` in `packages/core/`. Verifier-time grep is final gate. Decision 006 explicitly forecloses "just one little LLM call" rationalization with grep-test enforcement.
- **Adaptation**: Stockforge stack is Python; equivalent grep over `packages/domain/` for `import anthropic|openai|from langchain` AND for any numeric calculation done in LLM-output (per stockforge "NO LLM math" hard rule). The new invariant: I-S1 (no LLM math) — every number traceable to deterministic Python code with verified inputs.
- **Stockforge port**: `C:\htdocs\stockforge\agent-workspace\constitution\invariants.md` § I-S1. Verification: `scripts/verify/no_llm_math_grep.py` greps `packages/domain/` AND scans agent outputs for "approximately", "around", "roughly" + numeric values without source citation.

### A3. Phase-N-complete.md retrospective template
- **Source**: `phase-1-complete.md` through `phase-11-complete.md` (consistent §A-§I structure)
- **What**: Template with sections: §A Verdict Summary, §B SC Scorecard (per-success-criterion table), §C Substage Progress Recap, §D Carryforwards Consolidated, §E Determinism Evidence, §F I-6 Evidence (commit hygiene), §G Block-Close Audit, §H P0-P10 Probe Results, §I Next Action.
- **Adaptation**: Stockforge phases are different (research → ingest → thesis bake-off → calibration → portfolio → publish). Sections that adapt: SC Scorecard (per-thesis-success-criterion), Carryforwards (deferred theses, source gaps), Determinism Evidence (test runs replaced by data-pipeline runs), Probe Results (stockforge-specific: data-freshness probe, citation-coverage probe, calibration-probe).
- **Stockforge port**: `C:\htdocs\stockforge\agent-workspace\memory\phase-N-complete.md` template. Phase 0 retro should include: research-scanner artifacts, decisions logged, calibration-baseline.json.

### A4. Sandwich pattern (architect → dev → verifier) for IMPL phases
- **Source**: `decisions/002-task-1.7-sandwich-dev-vs-task-implementer.md` + `decisions/003-task-1.8-sandwich-dev-rationale.md` + project-complete.md
- **What**: Three-agent structure for each implementation session. Architect catches scope creep before it lands; verifiers (especially opus) find defects sonnet developers miss. Pattern adds ~30% wall-clock per task but prevents ~80% of narrow-fix cycles.
- **Adaptation**: Stockforge "implementation" = thesis production + portfolio decisions. Architect = thesis-architect (defines bear case mandate, source-citation requirements, confidence calibration target). Dev = thesis-author (multi-perspective: bull case, bear case, base case from Python pipeline). Verifier = thesis-verifier (adversarial: did numbers come from code? cite sources? bear case present?).
- **Stockforge port**: `.claude\agents\thesis-architect.md`, `.claude\agents\thesis-author.md`, `.claude\agents\thesis-verifier.md`.

### A5. Sandwich-architect Mandates A-E (pre-write Part-C dry-run discipline)
- **Source**: `agent-notes.md` lines 117-119 + `decisions/037-sc39-retry-verdict-v2.6.md` (Mandate E specifically)
- **What**: Phase 6 dominant lesson. Mandates A/B/C/D/E enforced in `.claude/agents/sandwich-architect.md`: pre-write dry-run, staged-index verify, awk-range self-match check, Prisma flag freshness. Mandate E: ≥10 incremental Edit operations (incremental writes vs single Write-fallback).
- **Adaptation**: Stockforge architects produce specs (thesis envelopes, calibration audits). Mandates: pre-write VBW protocol (verify-before-write — already in stockforge constitution), staged-index verify on data files, source-citation grep, multi-perspective coverage check (bull/base/bear).
- **Stockforge port**: `.claude\agents\sandwich-architect.md` § Mandates A-E with stockforge-specific pre-write checklist.

### A6. Charter-coherence spot-check script (post-phase gate A.6)
- **Source**: `phase-9-complete.md` § Test/Lint/Typecheck/Invariant Gate Summary + Gate A.6
- **What**: Script greps for "can bypass" / "may bypass" language patterns. False-positive incident: flagged denial qualifier ("→ NO, ...") at first; refined to skip denial markers. Production deployed as Drift-C detection.
- **Adaptation**: Stockforge equivalent — charter-coherence-spot-check.py greps for: "buy", "sell", "recommend" language without "thesis exploration" / "consideration" framing; LLM-generated numeric values without code-source citation; absent bear case in thesis output.
- **Stockforge port**: `scripts\verify\charter_coherence_spot_check.py`. Wired into post-phase.sh A.6 equivalent.

### A7. Skill self-test discipline (sibling test.md files)
- **Source**: `phase-0-4-meta-retrospective.md` proposal #10 + `.claude/skills/<name>/SKILL.md` + `.claude/agents/telemetry-analyst.md` test.md
- **What**: For every skill in `.claude/skills/<name>/SKILL.md`, a sibling `<name>.test.md` listing trigger conditions, expected behavior, failure modes, `<assertions>` block. Stop hook randomly samples one skill self-test and confirms LLM (in dispatched isolated subagent) follows it.
- **Adaptation**: Stockforge skills already exist (`postgres-pgvector`, `evidence-extraction`, `crawler-reliability`, etc.). Each gets a sibling test.md. Phase 0 deliverable.
- **Stockforge port**: For each skill in `C:\htdocs\stockforge\.claude\skills\*\SKILL.md`, add `<name>.test.md`. Build `scripts\skills_self_test.py`.

### A8. Config-style normative format (Decision 028)
- **Source**: `decisions/028-config-style-normative-format.md`
- **What**: Per-artifact-type frontmatter schema; canonical `tools` key (not `allowed-tools`); `model` field required on agents+discipline-skills; `archetype` field (`discipline` or `reference`) required on skills; section ordering canonical; LOC ceilings (200/150/120 for agents/skills/commands); post-incident integrate-into-Process rule.
- **Adaptation**: Mostly direct copy — stockforge `.claude/` already follows similar conventions. Add LOC ceilings + archetype field + model body-vs-frontmatter consistency check.
- **Stockforge port**: `C:\htdocs\stockforge\agent-workspace\constitution\config-style-guide.md` + `scripts\audit\config_style_lint.py`.

### A9. Tenancy model file-level isolation (Decision 029) — for multi-thesis sharing
- **Source**: `decisions/029-tenancy-model-file-level.md`
- **What**: File-level workspace separation `<user-id>/projects/<project>/`. POSIX 0700 ACL + runtime scope-resolver. Daemon-level fallback documented for v2.4.
- **Adaptation**: Stockforge "primary user + small trusted circle" use case (per CLAUDE.md). Tenancy model: per-user thesis namespaces in `agent-workspace/users/<user-id>/theses/`. Each user's theses + portfolio are isolated; shared sources (KB, raw vault) are read-only for all users.
- **Stockforge port**: `C:\htdocs\stockforge\agent-workspace\constitution\tenancy-model.md` + Phase 6+ scope.

### A10. Self-application as Phase 0 deliverable (NOT a deferred CF)
- **Source**: `decisions/039-cf-dogfood-2-disposition-v2.6.md` + `decisions/040-cf-dogfood-2-r039-5-user-override.md` (the LESSON: 4-cycle defer was anti-pattern)
- **What**: Orch deferred "use orch to develop orch" 4 cycles (Phase 8→11) before user explicitly invoked override. Lesson: encode self-application as same-phase deliverable from day 1.
- **Adaptation**: Stockforge self-application = use stockforge to evaluate stockforge's own backtest performance. Calibration data collected from stockforge predictions feeds back into stockforge's source-weighting + confidence calibration.
- **Stockforge port**: `C:\htdocs\stockforge\agent-workspace\constitution\self-application-bootstrap.md` — Phase 0 deliverable. Wire stockforge.calibration.feedback → stockforge.source-weighting from day 1.

---

## Top 5 LEARN Patterns

Concepts to internalize without porting code.

### L1. Performative-vs-actionable verdict discipline (Decision 025 SC-39 DEFER)
- **Source**: `decisions/025-7.7-sc39-defer.md`
- **Lesson**: A self-evolution loop run on signal-thin data produces "performative theater" — ticking the SC box without delivering value. Better to DEFER with explicit re-attempt prerequisites than to fire RULES that propose vacuous architectural changes (e.g., "tier-down unknown-agent" when no such agent exists).
- **Stockforge application**: Don't ship thesis output when source signal is thin (e.g., < 3 independent sources, calibration n < 30). DEFER thesis with explicit "need-N-more-sources" gate. Don't manufacture confidence to populate a dashboard.

### L2. Independence audit when authoring defers
- **Source**: `decisions/040-cf-dogfood-2-r039-5-user-override.md` § E.2
- **Lesson**: SC-39 W-1 (telemetry quality) and CF-DOGFOOD-2 (runtime dispatch) were architecturally independent but conflated into a single defer dependency for 4 cycles. When authoring a defer, write an "independence audit" section: list named blocker, prove dependency is real, not architectural conflation.
- **Stockforge application**: When deferring a thesis or analysis, prove the blocker is real (e.g., "calibration data thin" is a real blocker; "we should validate against backtest first" is often architectural conflation if backtest is unrelated to the question being deferred).

### L3. Decision quality philosophy — Document-And-Move
- **Source**: `autonomous-protocol.md` Rule 7 + Decision 027 (Phase 8 Strategic Redirect)
- **Lesson**: After making a decision, write ONE paragraph in `decisions/NNN-<slug>.md` (Context / Options / Choice / Why). Then move on. Do not ruminate. But: when ≥200-word user prompt introduces dimensions not in current plan, do NOT advance silently; write Decision file ratifying redirect, rename superseded plan `.SUPERSEDED.md`, dispatch master-planner with comprehensive brief.
- **Stockforge application**: Same Decision-And-Move discipline. For thesis decisions: when adversarial review surfaces a dimension not in current thesis (new sector risk, new regulatory factor), write Decision file ratifying scope redirect, do NOT silently merge.

### L4. Calibration over confidence — verifier productive failure rate
- **Source**: `phase-0-4-meta-retrospective.md` § 4.3
- **Lesson**: Sandwich-verifier (opus) had ~25% FAIL rate vs sonnet ~5%. The HIGHER FAIL rate is the system working — opus fresh-context catches real bugs. Don't suppress verifier-FAIL rate by "tuning down adversarial mode"; tune only when failures are not productive (false positives).
- **Stockforge application**: Stockforge thesis-verifier should EXPECT high FAIL rate (e.g., "missing bear case", "number not traceable to code", "source not cited"). Don't tune it down. Track productive vs non-productive failure ratio over time.

### L5. Multi-cycle structural-defer pattern (Decision 033 Deliberation E)
- **Source**: `decisions/033-sc39-narrow-gate-supersession.md`
- **Lesson**: Some problems genuinely cannot be fixed within one phase budget (settings.json read-once constraint requires next-session boot to test fixes; volume gates require natural accumulation over time). Multi-cycle defer is admissible IF: (a) re-attempt prerequisites enumerated, (b) supersession-target is a future binding decision, (c) NOT a USER-CRITICAL item.
- **Stockforge application**: Some calibration validations need 6-12 months of forward predictions to evaluate. That's legitimate multi-cycle defer. Distinguish from technical can-kicking by writing the "natural accumulation gate" explicitly.

---

## Anti-Patterns Observed

### AP1. Same-agent self-review (echo chamber)
**Evidence**: `phase-0-4-meta-retrospective.md` § 4.3 — sonnet implementers had ~5% real-fail rate; opus fresh-context verifiers had ~25%. Sonnet self-review missed real bugs (P0 Date redaction, async-void leak, dead security primitives).
**Stockforge MUST NOT**: Use the same model + same context for both implementation and review of any thesis output. Always dispatch fresh-context verifier.

### AP2. Pre-staged work causing checkpoint drift
**Evidence**: `phase-0-4-meta-retrospective.md` § 1.11 — Tasks 3.8, 3.9 substantively pre-implemented in session #19 but appeared as pending in current-execution.md. Architect pass had to discover this. Same pattern at Task 3.10.
**Stockforge MUST NOT**: Let session logs drift. Update `current-execution.md` immediately when a task completes, not at end of session. Subagent contract: "Before declaring DONE, write the session log inline with files-modified list."

### AP3. Refactor adjacent unrelated code (violates Karpathy P3)
**Evidence**: `agent-notes.md` general guidance + `decisions/022` (cross-spec migration discipline)
**Stockforge MUST NOT**: When fixing a thesis bug, don't touch adjacent unrelated theses. Surgical changes only.

### AP4. LLM rationalization "just one little LLM call" inside daemon code
**Evidence**: `decisions/006-handoff-no-llm.md` § "Why this decision is being foreclosed in writing now" — the temptation to summarize session log via LLM was rejected pre-emptively, in writing, with grep enforcement.
**Stockforge MUST NOT**: Allow ANY LLM call inside `packages/domain/`. Numbers MUST come from code, not LLM. The temptation to "just have the LLM compute ROE from these numbers" is the same anti-pattern. Decision 006 is the canonical foreclosure pattern.

### AP5. Charter-coherence defer logic overriding user intent
**Evidence**: `decisions/039` + `decisions/040` + `user-intent-coherence.md` § E.1 — CF-DOGFOOD-2 deferred 4 cycles despite user_prompt.txt mục 1.5 being USER-CRITICAL from Phase 8 entry. Master-planner read carryforwards-vN.md but never re-read user_prompt.txt.
**Stockforge MUST NOT**: Treat user-priority items as ordinary CFs. USER-CRITICAL severity tier is mandatory. Phase-entry checklist re-reads ALL user_prompt.txt files.

### AP6. Mixing PLAN and IMPL in same session
**Evidence**: `CLAUDE.md` § Session Types — "Never mix PLAN and IMPL in same session. (Session 4 catastrophic failure mode.)"
**Stockforge MUST NOT**: Already in stockforge CLAUDE.md. Confirmed anti-pattern.

### AP7. Self-track inflation as wind-down trigger (Mode C)
**Evidence**: `agent-notes.md` lines 17-21 + `phase-0-4-meta-retrospective.md` H-25 — Session #23 ended turn at self-track 165K citing "approaching 200K wind-down" while real transcript was 121,778 tokens. ~2.5h dead time before user nudged.
**Stockforge MUST NOT**: Trust LLM self-track for end-turn budget decisions. Real transcript via `.transcript-tokens` is authoritative.

### AP8. Foreground Agent dispatch (no run_in_background)
**Evidence**: `agent-notes.md` line 31-33 — Phase 1 catastrophic. Foreground stalls runtime; `<task-notification>` only fires for background.
**Stockforge MUST NOT**: Ever omit `run_in_background: true`.

### AP9. Performative success-criterion (SC ticking without delivering value)
**Evidence**: `decisions/025-7.7-sc39-defer.md` — running self-evolution loop on signal-thin data produces vacuous proposals.
**Stockforge MUST NOT**: Ship a thesis just to populate a dashboard. Better to DEFER with explicit prerequisite list.

### AP10. CRITICAL bugs invisible to standalone tests (cross-package parallel)
**Evidence**: `phase-0-4-meta-retrospective.md` § 1.12 — CRITICAL-1 in Task 4.12 reproducible only under root parallel `pnpm test`, invisible to standalone package tests.
**Stockforge MUST NOT**: Trust per-component tests alone for integration validation. Add full-stack pytest run as gate before phase close.

---

## Open Questions Raised

These are problems orch never solved that stockforge will face:

### OQ1. How to programmatically detect "self-track inflation ratio" drift
Self-track was 1.35× real at H-25. If future v2 work chains many returns, the ratio could go higher. Orch never measured this drift dynamically. Stockforge should: have the LLM log self-track and watchdog log real, build a `self-track-ratio.jsonl` time series, alert when ratio exceeds threshold.

### OQ2. Mode B (API truncation) automated recovery without double-charging tokens
Orch deferred this — proposal #2 in meta-retrospective. The risk: hook that injects `continue` when API overloaded may double-charge if prior turn DID partially succeed. Solution requires marker like `.api-truncation-recovery-fired-<request_id>` for idempotency. Stockforge should solve this if running 24/7 unattended.

### OQ3. Subagent-failure-rate granularity (per-task-shape, not per-agent-type)
Orch has subagent-index.md mapping agentId → verdict. But the ROUTING decision needs per-task-shape data ("which agent type single-pass-clean'd which task shapes?"). Orch didn't build the task-shape classifier. Stockforge should: define a thesis-task taxonomy (research / extraction / synthesis / verification) and route based on per-shape historical performance.

### OQ4. The 250K context cliff vs single-thesis-budget for complex stocks
Orch hit cliff multiple times. Stockforge thesis on a complex stock may require: full historical price + sector context + KOL transcripts + news + 10-K-equivalents. This will exceed 250K easily. Decision needed: split thesis across multiple sessions with handoff context (orch pattern), or aggressive context filtering (skill-pull-on-demand pattern from Decision 043), or both.

### OQ5. Multi-user calibration data isolation vs shared signal
Stockforge "primary + small trusted circle" use case. If 3 users share a stockforge instance, do their calibration histories aggregate or stay separate? Orch's tenancy model (Decision 029) is file-level isolation; calibration aggregation across users is not addressed. Important because: small-N calibration is unreliable; aggregating across 3 users gives 3× the data.

### OQ6. Vietnamese-text embedding quality vs multilingual model performance
Orch never touched VN-specific NLP. Stockforge will need pgvector embeddings for VN text. Open question: which embedding model? OpenAI multilingual + translation? Local VN-specific model? This is on stockforge's path; orch has no patterns to port.

---

## Counter-Examples / Reversed Decisions

Decisions that orch made then reversed — useful so stockforge doesn't reattempt:

### CE1. Reversed: Phase 8 v2.3 Carryforward Burndown plan → Strategic Pivot
- **Decision 027** invalidated the original Phase 8 master plan (`phase-8-v2.3-carryforward-burndown.md`) after user introduced strategic redirect (drift-audit + self-application + community-readiness). The OLD plan was renamed `.SUPERSEDED.md`.
- **Lesson**: When user prompt introduces new dimensions, do NOT advance existing plan silently. Re-author. Stockforge should follow the same pattern for any major scope-redirect.

### CE2. Reversed: telemetry-analyst opus → sonnet (Decision 021)
- **Decision 017** specified sonnet. Architect 6.2 escalated to opus on "non-mechanical pattern recognition" grounds. Decision 021 reversed back to sonnet — adjudication: rules are threshold comparisons over uniformly-formatted markdown table; pattern-recognition claim doesn't hold.
- **Lesson**: Don't escalate model tier on speculative complexity. Look at actual operations being performed. Stockforge: thesis-verifier IS opus-tier (real adversarial reasoning); thesis-classifier should be sonnet (deterministic classification).

### CE3. Reversed: Phase 13 "per-agent precise context injection" framing → "orch is scheduler, not agent framework"
- **Decision 042** scoped Phase 13 as agent-framework work (per-role profiles, scoped memory loader, skill on-demand pull). **Decision 043** corrected: those are Claude Code's domain, not orch's. Phase 13 deliverables narrowed to: prune orch-internal artifacts + make "orch self-codes orch" viable.
- **Lesson**: Identity discipline matters. Orch is "dumb scheduler + smart interface". Don't drift into agent-framework features. Stockforge identity: AI-first VN stock advisory. Do NOT drift into building a generic financial-modeling framework or generic-purpose AI advisor. Tight scope.

### CE4. Reversed: SC-39 ENABLE_RETRY → DEFER chain (Decisions 025 → 033 → 034 → 035 → 037)
- 5-decision chain. Original Decision 025 deferred SC-39 to v2.3 due to thin signal. Decision 033 added narrow gate. Decision 034 DEFER-V2.5. Decision 035 DEFER-V2.6 with engineering fixes. Decision 037 DEFER-V2.7 due to settings.json read-once constraint. The ENABLE_RETRY never landed.
- **Lesson**: Multi-cycle defer is sometimes legitimate (genuinely structural blockers — settings.json read-once is real). But 5 cycles is a flag — the gate semantics may be wrong. Stockforge: when calibration validation is taking >3 cycles, re-examine the gate, not just continue iterating.

### CE5. Reversed: Phase 5 "Self-Evolution Loop Activation" was *partially* shipped
- Phase 6 SC-22 (rollup script) + SC-23 (telemetry-analyst) shipped. But SC-39 (the actual self-evolution upgrade — applying a proposal to modify config) never fired. The READ-AND-PROPOSE half landed; the APPLY half never did, despite 5 phases of work.
- **Lesson**: The proposal/apply split is real and apply is harder. Stockforge: don't promise "self-evolving recommendation engine" upfront; ship the propose-only half first, gate apply behind explicit user approval until calibration data justifies auto-apply.

### CE6. Reversed: vi.useFakeTimers approach for Windows-Git-Bash subprocess timing flakes
- `phase-6-complete.md` §F initially recommended `vi.useFakeTimers()` for Mode C / Mode B timing tests. **Decision 022** reversed: fake timers replace in-process JS timers, not subprocess wallclock. The actual fix is the "informational reporter" pattern (push durations to module-scope array, log p99/median in afterAll, no hard threshold assertion).
- **Lesson**: Cross-platform timing assertions are a flake source. Use informational reporter for cross-platform subprocess timing. Stockforge: data-pipeline timing tests (e.g., "crawler should fetch in <2s") should follow the informational-reporter pattern, not hard threshold.

---

## Cross-Reference Index (selected absolute paths)

- `C:\htdocs\orch-starter\agent-workspace\memory\agent-notes.md` — 161 lines of accumulated learned rules
- `C:\htdocs\orch-starter\agent-workspace\memory\phase-0-4-meta-retrospective.md` — 300-line systematic mode-A/B/C analysis
- `C:\htdocs\orch-starter\agent-workspace\memory\phase-{0..11}-complete.md` — 11 phase retros
- `C:\htdocs\orch-starter\agent-workspace\memory\decisions\{001..043}-*.md` — 43 decision files
- `C:\htdocs\orch-starter\agent-workspace\constitution\autonomous-protocol.md` — Mode A/B/C discipline
- `C:\htdocs\orch-starter\agent-workspace\constitution\user-intent-coherence.md` — USER-CRITICAL pattern
- `C:\htdocs\orch-starter\agent-workspace\memory\project-complete.md` — v1.0.0 retrospective synthesis

**END Pattern Mining Report.**
