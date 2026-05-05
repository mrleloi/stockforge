# SYNTHESIS — Pattern Mining Cross-Reference (3 sources)
**Date**: 2026-04-29
**Agent**: synthesis (opus, fresh context)
**Sources**: pattern-mining-{orch,msmdp,refrepos}.md
**Token budget**: ~30K

---

## 1. Convergent Findings (where 2+ sources agree)

These are highest-confidence borrows for stockforge Phase 0.

| # | Convergent Finding | Sources | Action for stockforge |
|---|---|---|---|
| **C1** | **Sandwich workflow (Architect → Dev → Verifier) with fresh-context adversarial reviewer** | orch §B3, §A4 (sandwich-architect Mandates A-E); msmdp §B1 (3-session sandwich, 20%→6% failure rate); refrepos §A2 (Critic skill) | Already in CLAUDE.md as session types — port concrete handoff format from msmdp + Mandates A-E from orch. Sandwich is THE default workflow for IMPL. |
| **C2** | **Real-transcript watchdog over LLM self-track** for budget decisions | orch §B2 (`.transcript-tokens` file, Mode C fix); msmdp §"Token Tracking Template" (per-session ledger); refrepos §A2 TranscriptCache (incremental JSONL reads) | Port `budget-watchdog.sh` (orch) + Python TranscriptCache (refrepos). Forbid LLM self-track-driven wind-down. **Already in Track 5 spec.** |
| **C3** | **Decision-doc discipline (NNN-slug.md sequential + provenance chain)** | orch §B4 (43 decisions, README index); msmdp §B5 (Decision Provenance Chain, IEC 62304/DO-178C); refrepos N/A | Confirms Track 2 (Provenance Schema). msmdp adds source-evidence + approval-chain layers; orch confirms format works at scale. |
| **C4** | **No-LLM-math invariant enforced via grep gate** | orch §A2 (I-1 daemon-dumb, Decision 006 grep enforcement); msmdp §B3 Same-Commit Rule + §B6 VBW; refrepos §"Top 10 BORROW" UserPromptSubmit invariant injector | Stockforge has I-S1 in CLAUDE.md. Port grep gate (orch) + UserPromptSubmit invariant reminder (refrepos) + VBW checkpoints (msmdp). Add to Track 7. |
| **C5** | **Mistake/failure log as first-class artifact (FAILED approaches priority)** | orch §B4 decisions + agent-notes; msmdp §B10 mistake-log.md; refrepos §"Second-Brain" L1 prompt explicit "FAILED APPROACHES" priority | NEW: stockforge has `agent-notes.md` but unstructured. Port msmdp's mistake-log format + claude-sessions L1 FAILED-pattern emphasis. **ADD to Track 8.** |
| **C6** | **Local-first observation files (mailbox / observations / dispatch.jsonl)** | orch §B5 dispatch.jsonl 9-field schema; msmdp §B4 `.context/agent-mailbox/` 80% token savings; refrepos §A1 hook state machine | Port dispatch.jsonl schema (orch) + observation-file pattern (msmdp). Observations dir already exists in stockforge spec. **Track 5 + Track 8.** |
| **C7** | **Same-agent self-review is THE highest anti-pattern (echo chamber)** | orch §AP1 (sonnet self-review ~5% fail vs opus fresh ~25%); msmdp §AP3 "fox guarding henhouse"; refrepos confirms via separate Critic | Already in CLAUDE.md. Reinforce in Track 6 (port spec-compliance + code-quality + sandwich-verifier subagents from orch). |
| **C8** | **Drift-signal grep scripts (hook-runnable, not human-checked)** | orch §A6 charter-coherence-spot-check; msmdp §B8 D1-D8 with grep scripts; refrepos §"PostToolUse → I-S2 citation grep" | Stockforge has DR1-DR12 but human-checked. Port msmdp grep-script pattern. **Add to Track 5.** |
| **C9** | **Skill-test sibling files + LOC ceilings + frontmatter validator** | orch §A7 (sibling test.md, Stop-hook sampling) + §A8 Decision 028 LOC ceilings; msmdp implicit; refrepos §B1-B4 progressive-disclosure SKILL.md ≤150 LOC + `quick_validate.py` | NEW for stockforge: validate all 12 skills, port `validate_skills.py`. **ADD to Track 6.** |
| **C10** | **Identity discipline / scope discipline (don't drift into adjacent framework features)** | orch §CE3 "orch is scheduler, not agent framework" (Decision 042/043 reversal); msmdp §L4 L4/L5 autonomy regression-to-mean; refrepos §"Skip / Not Applicable" 14 patterns explicitly excluded | Stockforge identity = "AI-first VN stock advisory". Add to Track 7 constitution: explicit non-charter list (NOT a generic financial-modeling framework, NOT a multi-tenant SaaS, NOT a Telegram bot platform). |

---

## 2. Divergent Findings (sources disagree)

| # | Topic | Source A position | Source B position | Recommendation |
|---|---|---|---|---|
| **D1** | **Self-application timing** | orch §B10 / §A10: "Self-app must be Phase 0 deliverable, NOT deferred CF" (lesson from 4-cycle CF-DOGFOOD-2 defer) | msmdp §L4: warns against L4/L5 autonomy — "human must set boundaries before agent self-codes" | **Synthesis position**: stockforge Phase 0 IS self-application bootstrap (harness builds the harness). But charter + invariants are immutable boundaries. Track 7 codifies BOTH — self-app from day 1 AND human-set boundary discipline. |
| **D2** | **Multi-cycle defer admissibility** | orch §L5 (legitimate when re-attempt prerequisites are real, e.g., settings.json read-once) + §CE4 (5-cycle SC-39 defer warned as flag) | msmdp §AP4 "retry failed approach instead of revert" + §"AP-7" S45 cascading reverts | **Synthesis**: defer is admissible IF (a) blocker is genuinely structural (not architectural conflation), (b) re-attempt prerequisite is concrete and time-bound. >3 cycles = re-examine the gate, not iterate. **Add to Track 2 provenance schema: defer-cycles counter.** |
| **D3** | **Confidence calibration source** | msmdp §A9: HIGH/MEDIUM/LOW per-change confidence (qualitative) | refrepos §"What to ADAPT" thesis-anomaly-detector: 2σ deviation from historical hit rate (quantitative); orch §L4: calibration-over-confidence = empirical hit rate | **Synthesis**: stockforge MUST use empirical hit rate (orch + refrepos position) — NOT model "feeling certain" (msmdp's qualitative ladder is insufficient for finance). Track 8 Confidence Score schema already specifies this; reinforce in Decision 003. |
| **D4** | **Subagent context isolation cost** | orch §B6: foreground Agent dispatch stalls runtime → mandatory `run_in_background: true` | msmdp §B1: sandwich = 3 SEPARATE sessions (sequential, not parallel bg) | **Synthesis**: not a real conflict. orch's `run_in_background` rule is for AgentTool dispatch from main session. msmdp's sequential sandwich is across human-orchestrated sessions. **Both apply**: bg=true for in-session subagent dispatches; sequential for cross-session sandwich phases. |
| **D5** | **Continuous Guardian vs per-task verifier** | msmdp §B5: Guardian Agent runs CONTINUOUSLY, monitors 5 channels, can HALT all agents | orch §B3: per-task spec-compliance + per-phase-end opus sandwich-verifier (NOT continuous) | **Synthesis**: continuous Guardian is expensive at LLM tier. Port as **deterministic Guardian** = hooks (PostToolUse citation grep, charter-coherence-spot-check, drift-signal greps) running on every relevant event. LLM Guardian only fires at session-end aggregation (Track 9 Self-Awareness aggregator). This avoids "critic agent every action" cost concern from UP02 §1.4. |
| **D6** | **Rate of change in spec** | msmdp §B3 Same-Commit Rule: every behavior change = spec change in same commit | orch implicit: charter immutable, decisions sequential | **Synthesis**: stockforge has 2-tier discipline: Charter immutable (requires explicit revision + version bump per CLAUDE.md). Below-charter specs follow Same-Commit Rule. **Add to Track 7 constitution: spec-authority hierarchy.** |

---

## 3. Items Requiring Decision 002 Update

| # | Track | Suggested Amendment | Type | Rationale |
|---|---|---|---|---|
| **U1** | Track 5 | **ADD UserPromptSubmit invariant injector hook** (5-line reminder of I-S1 no-LLM-math, I-S2 citations, I-S3 deterministic risk before each user prompt) | ADD | refrepos identifies as HIGH priority; cheap to wire; directly addresses LLM forgetting invariants mid-session. Not in Decision 002 hook list. |
| **U2** | Track 5 | **ADD PostToolUse citation grep hook** (when LLM writes number → grep adjacent lines for `source:` and `as_of:`; flag if missing) | ADD | refrepos HIGH priority; automates I-S2 enforcement. Pairs with no-LLM-math grep. |
| **U3** | Track 5 | **ADD PreCompact hook** (dump thesis state before context loss) | ADD | refrepos identifies; relevant for long thesis sessions. Decision 002 doesn't mention. |
| **U4** | Track 5 | **ADD TaskCompleted audit hook** (auto-grep changed files for I-S1/I-S2 violations on every task close) | ADD | refrepos HIGH priority; cheap automation of per-task invariant enforcement. |
| **U5** | Track 6 | **ADD `validate_skills.py` skill validator** + sibling `*.test.md` for each skill | ADD | refrepos identifies; orch confirms test.md pattern; stockforge has 12 skills, 0 validators. Treat as Phase 0 hardening. |
| **U6** | Track 6 | **REFINE skill structure to progressive-disclosure** (SKILL.md ≤150 LOC + `references/` + `scripts/`) | REFINE | refrepos identifies all current 12 stockforge skills likely violate 150-LOC; add `--soft-warn` flag for first month. Not in Decision 002. |
| **U7** | Track 6 | **ADD missing subagent: `sandwich-verifier` (opus, fresh-context, phase-close)** | ADD | orch §B3 — currently absent from stockforge. Decision 002 lists 5 subagents to port (task-implementer, spec-compliance-reviewer, code-quality-reviewer, systematic-debugger, intent-classifier). MISSING the opus sandwich-verifier which is the highest-value gate. **Critical addition.** |
| **U8** | Track 7 | **ADD `mistake-log.md` to constitution + structured format** (What went wrong / Root cause / Prevention rule / Severity) | ADD | msmdp §B10 + refrepos §"Second-Brain" FAILED-approaches priority. Stockforge has agent-notes.md unstructured — separate file with format. |
| **U9** | Track 7 | **ADD `mode-routing.md` Mode A/B/C named taxonomy** (narrate-without-tool / API truncation / self-track illusion) | ADD | orch §1 dominant lesson — 33 STOP events in 7h. Mode A/B/C must be NAMED in stockforge constitution with structural fixes per mode. Decision 002 mentions tool-call-first ordering but not the named taxonomy. |
| **U10** | Track 7 | **ADD `user-intent-coherence.md` + USER-CRITICAL severity tier** | ADD | orch §B10 + §AP5 — directly addresses user's UP02 §1.1 charter-drift concern. NOT in Decision 002 explicitly. **Critical for stockforge given user explicitly raised this concern.** |
| **U11** | Track 7 | **ADD `self-application-bootstrap.md`** (Phase 0 self-app deliverable) | ADD | orch §A10 / §B10 — encode self-app from day 1 (stockforge calibration data feeds back into stockforge source-weighting). Avoids 4-cycle defer pattern. |
| **U12** | Track 7 | **ADD `identity-scope.md` (what stockforge is NOT)** | ADD | orch §CE3 (Decision 042→043 reversal) + msmdp §L4 + refrepos 14 explicit skips. Define explicit NOT-list: NOT generic AI advisor, NOT multi-tenant SaaS, NOT Telegram platform, etc. |
| **U13** | Track 8 | **REFINE Confidence Score: ground in empirical hit rate, not qualitative ladder** | REFINE | Divergence D3 — confirm Decision 003 specifies empirical-hit-rate base. Reject msmdp's qualitative HIGH/MED/LOW alone. |
| **U14** | Track 8 | **ADD L0/L1 session memory extraction** (port from claude-sessions verbatim) | ADD | refrepos §"Second-Brain" — L0 regex + L1 LLM prompt with FAILED-approaches emphasis = canonical second-brain pattern. Track 8 currently spec'd as Confidence Score only; this is the missing extraction layer. **Significant addition — possibly SPLIT_TRACK.** |
| **U15** | Track 8 | **EXTEND L0 FAILURE_PATTERNS with Vietnamese phrases** ("không hoạt động", "không hiệu quả", "đã thử nhưng") | REFINE | refrepos OQ3 — easy to forget. Not in Decision 002. |
| **U16** | Track 9 | **ADD OTEL single-container stack** (`grafana/otel-lgtm:1.4.0`) verbatim copy from `claude-code-otel/` | ADD | refrepos §"Telemetry" — copy `docker-compose-lgtm.yml` + `collector-config.yaml` + `claude-code-dashboard.json` to `docker/otel-stack/`. Idle ~150-300MB, one-command up. Decision 002 Track 9 doesn't specify telemetry stack. |
| **U17** | Track 9 | **ADD `thesis-anomaly-detector` + `daily-thesis-summary` + `hook-diagnostics` skills** (from refrepos §"Skills not yet in stockforge") | ADD | refrepos identifies as HIGH-priority for Track 9. Decision 002 lists Self-Awareness Agent but not these skill candidates. |
| **U18** | Track 9 | **ADD Guardian-as-deterministic-hooks pattern** (per Divergence D5) | REFINE | Avoids continuous LLM-Guardian cost concern (UP02 §1.4). Hooks = cheap deterministic Guardian; LLM Guardian only fires at session-end. |
| **U19** | Track 0 | **DECLARE COMPLETE** — 3 mining reports + this synthesis + borrow-list = Track 0 deliverable. No additional sources needed. | (closure) | All 3 sources fully mined. Synthesis identifies hand-off items to Track 1. |
| **U20** | Sequencing | **Tracks 5, 6, 7 ordering: keep current** but reinforce: hook-runnable drift-signals (Track 5) must precede skills validator (Track 6) which must precede constitution codification (Track 7) | (no change) | Confirmed valid; current Decision 002 sequencing holds. |

---

## 4. New Risks Surfaced

| # | Risk | Evidence | Proposed Mitigation | Urgency |
|---|---|---|---|---|
| **R1** | **Self-track inflation > 1.35× real transcript causes wind-down 25-35% too early** (Mode C) | orch §AP7 H-25 incident (165K self vs 122K real); orch §OQ1 — ratio drift never measured | Wire `.transcript-tokens` watchdog (Track 5) + log self-track-vs-real ratio time series. Alert when ratio > 1.5×. | **Phase 0** — included in Track 5 but explicit ratio drift not |
| **R2** | **API truncation (Mode B) automated recovery may double-charge tokens** without idempotency marker | orch §OQ2 deferred problem | Defer to Phase 1+ with explicit `.api-truncation-recovery-fired-<request_id>` marker design. | Phase 1+ |
| **R3** | **250K context cliff vs single-thesis-budget for complex VN stocks** (full price + sector + KOL + news + 10-K equivalents) | orch §OQ4 — orch hit cliff multiple times | Decision needed: split thesis across sessions (orch handoff pattern) OR aggressive context filtering (skill-pull-on-demand) OR both. **Surface as user decision Q&A in Phase 1+.** | Phase 1+ (prepare design now) |
| **R4** | **Vietnamese-text embedding quality** — orch never touched VN-specific NLP | orch §OQ6 | Open question for Phase 2+ ingestion. Document as known unknown in Track 7 constitution + Charter footnote. | Phase 2 |
| **R5** | **Skill validator hard-fail breaks existing 12 skills on day 1** (none currently meet 150-LOC progressive-disclosure rule) | refrepos OQ2 | `--soft-warn` flag for first 30 days, then flip to hard-fail. Track 6 must implement migration plan. | Phase 0 |
| **R6** | **Stockforge has stricter content rules than reference repos** — re-confirm no borrowed pattern needs paid sources or insider channels | refrepos §5 | Track 7 verifier re-confirms compliance for each ported pattern. | Phase 0 |
| **R7** | **Multi-cycle defer drifts into can-kicking** without enumerated re-attempt prerequisites + time-bound | orch §CE4 (5-cycle SC-39 defer); msmdp §AP4 | Track 2 provenance schema: every defer logs `re_attempt_prereq` + `cycle_count` field. Alert at >3 cycles. | Phase 0 |
| **R8** | **Continuous LLM-Guardian cost prohibitive** (UP02 §1.4: "critic agent độc lập bên ngoài thì chi phí quá đắt đỏ") | UP02 §1.4 + Divergence D5 | Use deterministic-hook Guardian (cheap) + LLM-Guardian only at session-end aggregation. **Encode in Track 9 spec.** | Phase 0 |
| **R9** | **L0/L1 extraction polluted by harness chatter** (`<system-reminder>`, `<command-name>`, `<task-notification>` tags) | refrepos §"Second-Brain" §4 cleanText regex | Port `cleanText` regex (claude-sessions snapshot.ts:38-49) before L0/L1 extraction. | Phase 0 (Track 8) |
| **R10** | **Hook result schema correctness** — generic JSON returns silently break gates | refrepos OQ1 + claude-code-learn schema spec | Document `{decision: approve|deny|modify, message?, additionalContexts?}` schema in Track 5 hook authoring guide. | Phase 0 |
| **R11** | **Phase 0 itself drifts (meta-drift) — agent ports without verifying applicability** | Decision 002 Risk table mentions; reinforced by orch §AP1 echo chamber | Track 5 verifier subagent reviews each cluster (Decision 002 sequencing already specifies this — confirm it executes). | Phase 0 |
| **R12** | **Spec-as-Source maturity-level-3 anti-pattern** (tiny spec change → butterfly → 50 files) | msmdp §AP5 | Stockforge MUST NOT let agent generate 100% of code from spec without code-level review checkpoints. Same-Commit Rule + sandwich pattern (Track 6) protects. | Phase 0 |

---

## 5. User-Concern-Specific Insights

### 5.1 Reboot cost / surgical context injection (UP02 §1.5)
- **Best pattern**: msmdp §"Reboot cost" — `.context/agent-mailbox/` mailbox files + 200-500 token `session-handoff.md` + 6-7K total bootstrap (constitution 2K + CLAUDE.md 3K + handoff 500 + skill manifest 300 + mistake-log 200). 87% token savings.
- **Combined with**: refrepos progressive-disclosure SKILL.md ≤150 LOC + `references/` lazy-load. Skills become 5-10× smaller in upfront context.
- **Action**: Track 1 (workspace dualism) creates `agent-workspace/observations/` as mailbox-equivalent. Track 6 refactors skills to progressive disclosure. Track 7 codifies bootstrap target ≤10K tokens per session.
- **Result**: Surgical context injection = (a) tier-1 immutable always-loaded (CLAUDE.md + Charter + active constitution); (b) tier-2 just-in-time (decisions, skill references, source data); (c) tier-3 explicit pull (full sessions, raw vault, historical theses).

### 5.2 Charter drift / user-intent-coherence (UP02 §1.1)
- **Direct match**: orch §B10 + §AP5 — CF-DOGFOOD-2 4-cycle drift was charter-level despite user_prompt.txt being USER-CRITICAL from Phase 8. Master-planner read carryforwards but never re-read user_prompt.
- **Action**: Track 7 ADD `user-intent-coherence.md` + USER-CRITICAL severity tier (above "important") + phase-entry checklist re-reads ALL `human-workspace/user_prompt/*.txt` files (not just most recent). Build attestation table. (See U10.)
- **Reinforcement**: hook-runnable charter-coherence-spot-check.py (orch §A6) — greps for "buy/sell/recommend" without "thesis exploration" framing; LLM-output numerics without code-source citation. Wired into post-task gate.

### 5.3 Q&A maximization / second brain live (UP03)
- **Best pattern**: claude-sessions L0 regex + L1 LLM extraction with explicit FAILED APPROACHES priority (refrepos §"Second-Brain"). Plus 15+35 head/tail windowing. Plus `cleanText` regex.
- **Combined with**: msmdp three persistence tiers (Tier 1 session ~500 tokens; Tier 2 cross-session indexed; Tier 3 permanent ~5K). orch decision-doc discipline.
- **Action**: Track 8 SPLIT into:
  - **Track 8a — Confidence Score System** (decision-class thresholds, asymmetric weights, reversal protocol — already spec'd)
  - **Track 8b — Session Memory L0/L1 Extraction** (port claude-sessions verbatim with VN extension)
  - Both feed into the same SQLite `sync-tracker.db`. (See U14.)
- **"Live" semantic** = SessionStart auto-loads top-10 by tag+recency, plus continuous append from L0/L1 extraction events, plus `/sync-pull` skill for explicit query.

### 5.4 Self-Awareness across model × effort × thinking (UP03)
- **Best pattern stack**:
  - refrepos: OTEL single-container + claude-code-dashboard (model/cost/token/edit-decision metrics)
  - orch: Effort routing D1-D6 (Decision 032) — concurrency caps, escalation gates, retroactive downshift
  - msmdp: Token tracking template per session-type
- **Action**: Track 9 ADD OTEL stack (U16) + `thesis-anomaly-detector`/`daily-thesis-summary`/`hook-diagnostics` skills (U17) + Guardian-as-hooks pattern (U18). Self-Awareness Agent = LLM aggregator at session-end reading OTEL metrics + dispatch.jsonl + L1 extracted "FAILED" events → produces profile cards.
- **Profile card schema** (per Decision 002 Track 9): `<model>-<effort>.md` with strengths/weaknesses by task_class. Reading this BEFORE dispatching subagents = effort routing informed by self-awareness.

### 5.5 Provenance + drift detection (UP02 §1.3)
- **Direct match**:
  - orch §B4 decision-doc discipline (43 decisions, sequential, README index)
  - msmdp §B5 Decision Provenance Chain (IEC 62304/ASPICE/DO-178C — discussion thread + decision record + source evidence + approval chain + git blame)
  - msmdp §B8 D1-D8 drift signals with grep scripts (vs. orch DR1-DR12 human-checked)
- **Action**: Track 2 spec already includes 12-field schema. ADD msmdp's source-evidence + approval-chain layers + grep-runnable drift detection (U8 implicit; explicit in Track 5 hooks). Per-decision defer-cycles counter (R7).
- **Drift Anchor pattern** (msmdp VBW DA rule): every 5 implementation steps, re-read task spec — prevents implementation drift from initial intent. Add to Track 7 VBW protocol refinement.

---

## 6. Anti-Pattern Catalog (Combined)

| # | Anti-Pattern | Evidence | Why stockforge MUST avoid |
|---|---|---|---|
| **AP-1** | **Same-agent self-review (echo chamber)** | orch §AP1 sonnet ~5% vs opus fresh ~25% productive fail; msmdp §"AP-5" fox-guarding-henhouse | Highest-cost failure mode. ALWAYS dispatch fresh-context verifier for thesis output. |
| **AP-2** | **LLM self-track as wind-down trigger (Mode C)** | orch §AP7 H-25 165K self vs 122K real, 2.5h dead time | `.transcript-tokens` real-transcript is authoritative. Forbid self-track-driven wind-down. |
| **AP-3** | **Foreground Agent dispatch (no run_in_background)** | orch §AP8 Phase 1 catastrophic | Always `run_in_background: true` for in-session dispatches. |
| **AP-4** | **Mix PLAN and IMPL in same session** | orch §AP6; msmdp §AP-2 Session 4 catastrophe | Already in CLAUDE.md. Reinforce. |
| **AP-5** | **Charter-coherence defer overriding user intent** | orch §AP5 CF-DOGFOOD-2 4-cycle; msmdp §"Spec is God" | USER-CRITICAL severity tier + phase-entry user_prompt re-read mandatory. (U10) |
| **AP-6** | **LLM rationalization "just one little LLM call" inside daemon** | orch §AP4 Decision 006 foreclosure | Grep gate over `packages/domain/`. Numbers MUST come from code. (I-S1 enforcement) |
| **AP-7** | **Performative success-criterion (SC ticking without value)** | orch §AP9 SC-39 thin-signal vacuous proposals | Never ship a thesis to populate dashboard. DEFER with explicit prerequisites. |
| **AP-8** | **Pre-staged work causing checkpoint drift** | orch §AP2 Tasks 3.8/3.9 substantively-pre-implemented | Update `current-execution.md` immediately on task complete, not session-end. |
| **AP-9** | **CRITICAL bugs invisible to standalone tests** | orch §AP10 CRITICAL-1 Task 4.12 | Full-stack pytest run as gate before phase close. |
| **AP-10** | **Refactor adjacent unrelated code (violates P3)** | orch §AP3; msmdp implicit | Surgical changes only. Don't touch unrelated theses when fixing one bug. |
| **AP-11** | **Hallucination from convention** (writing from DDD/library memory without verifying methods exist) | msmdp 11.1% measured hallucination rate | Explicit VBW for method calls / library APIs / data fields. (msmdp §B6 + stockforge VBW skill) |
| **AP-12** | **Spec-as-Source L3 maturity (butterfly effect)** | msmdp §AP-5 — tiny spec → 50 files | NEVER let agent generate 100% of code from spec without code-level review. Sandwich pattern protects. |
| **AP-13** | **Stale Spec / Spec in Slack / Monolithic Spec** | msmdp §AP-6 | Same-Commit Rule + 200-500 LOC ceiling per BC spec. (Track 7 codifies) |
| **AP-14** | **Plan staleness during impl** | msmdp §AP-10 | Re-read target files in Phase B (impl) — don't trust plan. (msmdp DA rule) |
| **AP-15** | **Sandwich over-applied to small tasks** | msmdp §AP-9 | Decision matrix: <3-file changes = single session, no sandwich. Don't over-formalize. |
| **AP-16** | **Retry failed approach instead of revert** | msmdp §AP-7 S45 cascading reverts (370+ TS errors) | "Revert early, revert often" rule. Add to Track 7. |
| **AP-17** | **Identity drift (orch is scheduler, not agent framework)** | orch §CE3 Decision 042→043 reversal | Stockforge identity = AI-first VN stock advisory. Explicit NOT-list. (U12) |
| **AP-18** | **Multi-cycle defer without enumerated prerequisites** | orch §CE4 SC-39 5-cycle | Each defer logs `re_attempt_prereq` + `cycle_count`; alert at >3. (R7) |
| **AP-19** | **Single-perspective thesis (no bear case)** | CLAUDE.md hard rule + orch §B3 verifier checklist + msmdp Critic | Already in CLAUDE.md. Bear case mandatory. |
| **AP-20** | **Confident output without calibration data** | CLAUDE.md hard rule + Divergence D3 | Confidence MUST trace to historical hit rate, not LLM "feeling certain". |
| **AP-21** | **Pre-commit hook bypass / refactor without justification** | CLAUDE.md general guidance + msmdp Same-Commit | Never `--no-verify`. Never refactor adjacent unrelated code. |
| **AP-22** | **AI tier-3 routing in daemon (LLM classifies messages)** | refrepos §"Skip" praktor anti-pattern | Violates I-S1. Prefix routing only in daemon code; LLM only at user-facing edges. |
| **AP-23** | **Continuous LLM-Guardian (cost prohibitive)** | UP02 §1.4 + Divergence D5 | Deterministic hooks = Guardian. LLM Guardian only at session-end aggregation. |

---

## 7. Top 5 Items Requiring User Decision Before Execution

These surfaced from synthesis where stockforge cannot resolve via charter principles + Decision 002 alone.

### Q-S1. Track 8 split confirmation
**Issue**: refrepos §"Second-Brain" identifies L0/L1 session memory extraction as canonical second-brain pattern from claude-sessions (MIT). Decision 002 Track 8 currently spec'd as "Confidence Score System" only. L0/L1 extraction is a substantial addition (~150 LOC Python port + LLM prompt + VN FAILURE_PATTERN extension + `cleanText` regex).
**Options**:
- **A**: Add L0/L1 to Track 8 as sub-deliverable (single track, larger scope) — est +30K tokens
- **B**: SPLIT into Track 8a (Confidence Score) and Track 8b (Session Memory Extraction) — sequential, est +50K tokens
- **C**: Defer L0/L1 to Phase 1+ — scope discipline; ship Track 8 = Confidence Score only
**Recommendation**: **B (split)** — L0/L1 is the highest-leverage ROI per refrepos finding; FAILED-approaches priority is irreplaceable for calibration. SPLIT keeps each focused under 130K budget.

### Q-S2. Track 0 closure declaration
**Issue**: 3 mining reports + this synthesis + borrow-list = Track 0 deliverable per Decision 002 Track 0 success criterion. No additional sources identified as needed.
**Question**: Confirm Track 0 = COMPLETE? (Sources fully covered: orch crystal, ms-mdp phase2_workflow, orch reference-repos.) Or expand to additional sources (e.g., new reference repos, Vietnamese fintech open-source)?
**Recommendation**: **CLOSE Track 0**. Hand off to Track 1.

### Q-S3. Decision 002 amendment ratification
**Issue**: 18 amendments to Decision 002 (U1-U18 above) surfaced from synthesis. Decision 002 was ACCEPTED via "ok rồi. continue" before mining results. Amendments include net-new tracks (UserPromptSubmit hook, OTEL stack, sandwich-verifier subagent, `mistake-log.md`, etc.).
**Options**:
- **A**: Amend Decision 002 in-place (revision marker); mining-driven additions NOT counted as "scope expansion" since pattern mining was already a pre-condition track
- **B**: Issue Decision 002a (companion amendment) listing additions for explicit approval
- **C**: Q&A bundle to user, await explicit confirmation before execution
**Recommendation**: **A (in-place amend)** — pattern mining was Track 0 = explicit pre-design refinement step. Additions are within original spirit + budget envelope. Issue clear revision-marker comment header.

### Q-S4. OTEL telemetry stack inclusion in Phase 0
**Issue**: Track 9 in Decision 002 doesn't specify telemetry stack. refrepos identifies single-container `grafana/otel-lgtm:1.4.0` as right default (idle ~150-300MB, copy 3 files verbatim). User runs 24/7 on home PC per problem statement.
**Question**: Is single-container OTEL stack acceptable Phase 0 inclusion (~30K tokens to wire)? Or defer to Phase 1+?
**Recommendation**: **INCLUDE in Phase 0** — cheap, copy-verbatim, foundational for Self-Awareness Agent. Without it, Track 9 has nothing to aggregate.

### Q-S5. Identity NOT-list ratification
**Issue**: Synthesis recommends explicit identity-scope NOT-list in Track 7 constitution (U12). Items: NOT a generic AI advisor, NOT a multi-tenant SaaS (despite "small trusted circle"), NOT a Telegram bot platform, NOT a generic financial-modeling framework.
**Question**: Confirm scope. Particularly:
- Does "small trusted circle" remain explicitly excluded from multi-tenant features in Phase 0? (Currently Decision 002 §A9 ADAPT mentions tenancy as Phase 6+ scope.)
- Is Telegram bot definitively deferred to Phase 4+ (per Decision 002 Open Items)? Confirms refrepos-recommended skip-list.
**Recommendation**: **CONFIRM identity NOT-list as drafted**. User explicit confirmation prevents future scope creep.

---

## 8. Recommended Track 0 Closure

### Status: **COMPLETE** (pending user confirmation per Q-S2)

### What Track 1's first session needs from Track 0
1. **Borrow-list** (`borrow-list.md`) — the actionable port queue, sorted by priority. Track 1 begins with TIER 1 BORROW items.
2. **Anti-pattern catalog** (Section 6 above) — 23 items to encode in Track 7 constitution. Track 1 should reference these when designing folder permissions.
3. **User-decision blockers** (Section 7 Q-S1..Q-S5) — must be resolved before execution proceeds (especially Q-S1, Q-S3).
4. **Risk register** (Section 4, R1-R12) — feed into Decision 002 risk table revision.
5. **Convergent findings** (Section 1 C1-C10) — highest-confidence borrows; Track 1's first action should validate folder structure aligns with mailbox / observations / dispatch.jsonl pattern.
6. **Identity scope draft** (U12) — Track 1 codifies workspace contract; identity scope informs what folders are explicitly OUT.

### Hand-off artifact
- `agent-workspace/memory/patterns-discovered/SYNTHESIS.md` (this file)
- `agent-workspace/memory/patterns-discovered/borrow-list.md` (companion file, sorted port queue)
- 3 source mining reports (preserved for trace-back)

### No additional mining required
- All 3 sources fully mined per Decision 002 Track 0 spec.
- VN-domain-specific gaps (R4 VN embeddings) flagged as known unknowns; deferred per user-original "stick to charter" discipline.

### Track 0 → Track 1 handoff session start checklist
1. Read this SYNTHESIS.md
2. Read borrow-list.md
3. Resolve Q-S1..Q-S5 with user (1 Q&A bundle, 5 questions)
4. Apply approved amendments to Decision 002 (or issue Decision 002a)
5. Begin Track 1 (workspace dualism foundation) per amended spec

---

**END SYNTHESIS.md** — ~7K tokens.
