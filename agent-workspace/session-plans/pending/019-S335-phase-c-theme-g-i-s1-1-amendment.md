---
plan_id: 019-S335-phase-c-theme-g-i-s1-1-amendment
target_session: S336
type: FOCUSED_IMPL
budget: 30-60K (proposed)
phase: C (Theme G I-S1-1 charter/constitution amendment — proposal authoring)
track: Theme G — I-S1-1 numeric-output discipline sub-rule
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md § 6.3
predecessor: 018-S331-wave-0-W0-3-4-5-bundle (completed S333+S334; Wave 0 substrate FULLY SEALED per `agent-workspace/memory/checkpoints/latest.md`)
successor: |
  Out-of-band human ratification gate (S336+1) — main session fires AskUserQuestion with 4
  options (A: charter v1.1 → v1.2 / B: constitution write / C: REJECT / D: re-architect).
  On user pick:
    A → human-only edit to PROJECT_CHARTER.md v1.1 → v1.2 (agent cannot perform; ≥48h cool-down)
    B → next FOCUSED_IMPL session for constitution write (still needs final user explicit-approve
        before merging the constitution/ edit — same-session temp-deny-lift per D-056 precedent)
    C → Theme G unnecessary; skip to Phase D-K Theme L IMPL; update D-061 § Decision item 5
        with retire-instead-of-promote outcome + supersession note
    D → re-dispatch sandwich-architect with refined scope per user comment
architect: S335 sandwich-architect (background subagent; THIS PLAN)
dispatched_by: S335-main turn (parent main session orchestrating Phase C PLAN-PROPOSAL sandwich)
authored: 2026-05-16
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent)
executing_agent: sandwich-dev (background dispatch S336; fresh-context; AP-1 verifier in S336+1 if dispatched)
status: pending-execution

depends_on:
  - "D-061 (Wave-1 integration ratification — ACCEPTED 2026-05-15T15:30+07:00 blanket-A; § Decision item 5 confirms 'Theme G I-S1-1 GENUINE-new CONFIRMED'; § Decision item 6 recommends path B 'constitution write')"
  - "Q-INT-2026-05-6 = A user pick (per `human-workspace/q-and-a/answered/qa-2026-05-15-wave-1-bis.md` line 32: 'constitution write in agent-workspace/constitution/financial-data-protocol.md extension; Phase C S333 PLAN + S334 human-approve gate')"
  - "D-059 (Python determinism contract) — PRECEDENT for I-S1 sub-rule shape (Q-INT documentation calls D-059 the 'first instance' of I-S1 refinement; I-S1-1 is the 2nd instance → AP-23 promote trigger fires per CLAUDE.md hard rule)"
  - "D-060 (commit-policy-agent-may-commit) — operational gate for S336 dev commit boundary"
  - "D-056 (charter v1.1 amendment) — PRECEDENT for Path A counterfactual if user picks charter; also precedent for the same-session temp-deny-lift pattern required for Path B IMPL"
  - "Phase A observations: master-planner-A-{01,04,13,14,15}-deepdive-*.md (5 empirical cite sources)"
  - "INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md § G.1-G.5 (5-row empirical survey + architectural recommendation + AP-23 trigger documentation)"
  - "INTEGRATION_PROPOSAL_2026-05-15.md § 1 (ai-hedge-fund repo bullet w/ A-01 R3 cite), § 13 (TradingAgents repo bullet w/ A-13 § 7.4 cite), § 14 (TradingAgents-CN repo bullet w/ A-14 § 3.10 + § 7.5 cite)"
  - "Master plan § 6.3 (Phase C scope) + § 7.8 (AP-23 risk flag)"
  - "PROJECT_CHARTER.md Principle 8, Principle 9, Revision Protocol (Path A reference)"
  - "agent-workspace/constitution/financial-data-protocol.md Rules 1-15 (Path B target home; Rule 6 + Rule 7 + Rule 9 are sibling-rule precedents)"
  - "agent-workspace/constitution/invariants-stockforge.md I-S1 + I-S7 (parent + sibling invariants)"
  - "agent-workspace/CLAUDE.md Contract Rule 1 (constitution immutable absent explicit human approval — defines the gate)"
  - "CLAUDE.md (root) Hard Rules: 'Never modify PROJECT_CHARTER.md / constitution without explicit human approval' + AP-23 ritual demotion clause"

binding_decisions:
  - "Charter v1.1 Principle 9 (No LLM math — parent principle I-S1-1 operationalizes)"
  - "Charter v1.1 Principle 8 (Calibration over confidence — provides the calibration-mode satisfaction)"
  - "Charter v1.1 Principle 11 (Harness must self-verify firing — N/A to PROPOSAL tier; relevant only when the proposed RULE 16 hook lands in a follow-up IMPL session)"
  - "I-S1 (NO LLM math) — parent invariant"
  - "I-S2 (every claim sourced) — every claim in proposal + plan cites file:line"
  - "I-S35 (research-aid framing only — no buy/sell/recommendation language)"
  - "D-061 § Decision item 5 (Theme G GENUINE-new CONFIRMED)"
  - "D-061 § Decision item 6 (Path B recommended)"
  - "D-060 (agent MAY git commit; MUST NOT push)"

hard_rules_acknowledged:
  - "no production code in this S336 dev session (CLAUDE.md § Session Types — Phase C is proposal-tier; no production code, no test code beyond what proposal text references)"
  - "no direct charter or constitution edits in S336 (CLAUDE.md hard rule; Write is BLOCKED for PROJECT_CHARTER.md + agent-workspace/constitution/**); the proposal CONTAINS the literal text awaiting human gate"
  - "no human-workspace writes in S336 (proposal already lives in agent-workspace/proposals/ from S335 architect; AskUserQuestion gate fired by main S335 or main S336 post-dev-return)"
  - "every plan + proposal claim cites source file:line per I-S2"
  - "no LLM math — severity/likelihood claims categorical (CRITICAL/HIGH/MEDIUM/LOW), not LLM-emitted floats"
  - "AP-1 mitigation — verifier subagent in S336+1 is fresh-context separate from dev S336"
  - "VBW protocol — dev reads actual proposal file authored by S335 architect, not from memory"
---

# S336 — Theme G I-S1-1 Constitution-Write Proposal (Phase C of Wave-1 Master Plan)

## Goal

Author (or refine, if the architect's S335 draft is partial) the canonical proposal document at
`agent-workspace/proposals/theme-g-i-s1-1-amendment-2026-05-16.md` that:

1. DECIDES the canonical home for the I-S1-1 sub-rule (recommended path = B = constitution
   write in `financial-data-protocol.md` per D-061 § Decision item 6 + Q-INT-2026-05-6=A).
2. Documents the LITERAL TEXT of the proposed Rule 16 (full rule body + sibling
   invariants-stockforge.md companion edit + Quick Reference Table row + last-modified
   footer amendment) so the eventual human approver can copy-paste verbatim.
3. Cites ≥5 empirical source-evidence references from Phase A deep-dives.
4. Provides the 4-path decision matrix (A: charter v1.1 → v1.2 / B: constitution write /
   C: REJECT / D: re-architect) with explicit recommendation + adversarial framing for
   each.
5. Documents cool-down + version-bump bookkeeping (Path A counterfactual) and the
   constitution-write gate (Path B, recommended).
6. Surfaces the out-of-band ratification gate the main session will fire via AskUserQuestion
   post-S336 (CHARTER-tier allowed per AskUserQuestion-is-for-SCOPE/CHARTER memory rule).

**S335 architect output**: the proposal file at the cited path was AUTHORED by S335
sandwich-architect (this plan's author). S336 dev's role is **NOT** to re-author it from
scratch — it is to:
- (a) verify the proposal file exists at the canonical path + is well-formed
- (b) read it via VBW protocol (not from memory)
- (c) if any DoD item below is missing or ambiguous, REFINE the proposal text (additive
  only; do NOT rewrite — the architect's literal text and recommended path are binding
  per D-061 ratification)
- (d) write a session log per `agent-workspace/memory/sessions/`
- (e) write an observation per `agent-workspace/memory/observations/`
- (f) decide commit boundary per D-060 (architect-recommended: single commit just for the
  proposal file + session log + observation; main session decides final commit boundary
  on dev return).

## Context — why a PROPOSAL session, not an IMPL session

**Hard constraint from CLAUDE.md** (root + agent-workspace/CLAUDE.md Contract Rule 1):
"Never modify `PROJECT_CHARTER.md` / files in `agent-workspace/constitution/` without
explicit human approval." This applies to:
- Path A target (`PROJECT_CHARTER.md`) — same rule
- Path B target (`agent-workspace/constitution/financial-data-protocol.md` +
  `agent-workspace/constitution/invariants-stockforge.md`) — same rule

The S336 dev session is therefore a **PROPOSAL-tier** session. It:
- Authors / refines the literal proposal text
- Does NOT touch PROJECT_CHARTER.md
- Does NOT touch any file in agent-workspace/constitution/
- Does NOT pre-stage any IMPL work that would be invalid if the human picks Path C (REJECT)

This is conservative-by-design. Per master plan § 6.3, Phase C was always scoped as
"~1-2 sessions, ~80-160K tokens" — and the conservative shape is "1 PROPOSAL + 1 GATE",
not "1 PLAN + 1 IMPL". The architect's S335 PROPOSAL already does the heavy lifting; S336
is a verification + finishing session for the proposal artifact.

**Phase A's "Theme G GENUINE-new" claim was already CONFIRMED by D-061 § Decision item 5**
based on the 5-row empirical survey in `INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md § G.2`.
The architect re-verified this evidence in § 1 of the proposal and CONFIRMS — Path C
(REJECT) is empirically unsupported. The 4 surface inventory rows in § 2 of the proposal
demonstrate that the rule has bite within the stockforge codebase, not just in third-party
repos.

## § Empirical Evidence (Phase A findings — summary; full chain in proposal § 1)

5 file-cited deep-dive sources establish the 5-row empirical confidence-field survey:

1. **ai-hedge-fund** (`master-planner-A-01-deepdive-ai-hedge-fund.md`):
   - § 5 + § 7 R3: `WarrenBuffettSignal.confidence: int 0-100` at
     `src/agents/warren_buffett.py:13-16`; LLM-emitted; rubric anchored on "evidence
     quality LLM perceives" at `:788-794`, NOT historical hit-rate.
   - Anti-pattern: "LLM-self-reported confidence treated as ground-truth … without
     back-test calibration this is a hallucinated metric."

2. **TradingAgents** (`master-planner-A-13-deepdive-TradingAgents.md`):
   - § 5 + § 7.4: `entry_price: Optional[float]` at `tradingagents/agents/schemas.py:127`
     + `price_target: Optional[float]` at `:199`; LLM-fillable via structured output.
   - Audit point: "either ban these fields, or require them to echo a code-computed value
     (no LLM arithmetic)."

3. **TradingAgents-CN** (`master-planner-A-14-deepdive-TradingAgents-CN.md`):
   - § 3.10 + § 7.5: `tradingagents/agents/trader/trader.py:68-80` mandates "🚨 强制要求
     提供具体数值" + "不允许设置为null或空值" for 投资建议/目标价位/置信度(0-1)/风险评分(0-1)
     /详细推理.
   - Verdict: "the most aggressive LLM-number-emit pattern; direct collision with charter
     I-S1; anti-pattern to NOT inherit."
   - Additional: `agents/managers/research_manager.py:44-51` mandates "您必须提供具体的
     目标价格 - 不要回复'无法确定'".

4. **FinceptTerminal** (`master-planner-A-04-deepdive-FinceptTerminal.md`) —
   COUNTEREXAMPLE:
   - § 7.3: `NotifLevel { Info, Warning, Alert, Critical }` at
     `services/notifications/NotificationService.h:15` — bounded ENUM, no LLM-emitted
     float; demonstrates the categorical surrogate pattern.

5. **Vibe-Trading** (`master-planner-A-15-deepdive-Vibe-Trading.md`) — COUNTEREXAMPLE:
   - § 3 C5: `confidence=low` enforcement at `SKILL.md:138-139` triggered by
     mech-annualisation block-rule violation at `SKILL.md:264-295`; deterministic
     categorical-confidence assignment; demonstrates the deterministic-rule pattern.

**Architect's re-attestation**: the Phase A claim that I-S1-1 is GENUINE-new is sound;
2 counter-examples confirm the safe pattern that I-S1-1 will canonicalize.

## § Path Decision Matrix (summary; full table + adversarial framing in proposal § 3 + § 6)

| Path | Description | Recommendation |
|---|---|---|
| **A** | Charter v1.1 → v1.2 amendment (new sub-principle 9.1 OR top-level P12) | Not recommended — heavier ceremony than the rule's specificity warrants; 48h cool-down delays Phase F-prime IMPL |
| **B** | Constitution write — new "Rule 16 — Numeric-Field Discipline (I-S1-1)" in `financial-data-protocol.md` + companion edit in `invariants-stockforge.md` + Quick Reference Table row + last-modified footer | **RECOMMENDED** — honors D-061 prior ratification of Q-INT-2026-05-6=A; right specificity tier (rule is schema-enforcement specialization of an existing principle, not a new foundational principle); no cool-down; precedent (Rule 7 categorical surrogate; Rule 9 confidence_extracted field; Rules 11-15 from D-019 + D-021 all landed without charter ceremony) |
| **C** | REJECT — claim I-S1 already covers; retire-without-promote | **DO NOT PICK** — contradicts D-061; discards Phase A empirical evidence; AP-23 retire-without-evidence is itself a charter violation |
| **D** | RE-ARCHITECT with refined scope | Only pick if the human believes the SCOPE of I-S1-1 is wrong (e.g. should cover more than just numeric fields); not just the file home |

## § Literal Amendment Text (full text in proposal § 4)

The architect's proposal § 4 contains:
- § 4.1: Rule 16 verbatim text for `financial-data-protocol.md` (problem statement + rule
  body w/ 4 satisfaction modes [categorical / deterministic-echo / calibration / null] +
  enforcement at schema-definition / runtime / amendment time + initial inventory of
  subject fields + cross-references to Principle 8/9, I-S1/I-S7, Rule 6/7/9). **LOC: ~60.**
- § 4.2: Companion edit text for `invariants-stockforge.md` — new I-S1-1 entry between
  I-S1 (line 27) and I-S2 (line 29). **LOC: ~7.**
- § 4.3: Companion edit for Quick Reference Table at `financial-data-protocol.md:261-274`.
  **LOC: ~1.**
- § 4.4: Last-modified footer amendment. **LOC: ~2.**

**Total**: ~70 LOC of literal text awaiting human gate.

The text is structured to drop into either Path A or Path B home (rule-level prose, not
file-section-specific) so the eventual human approver can paste-and-go on either choice.

## § Cool-Down + Version-Bump Bookkeeping (full text in proposal § 5)

- **Path B (recommended)**: no cool-down ceremony; precedent D-019 + D-021 added rules to
  `financial-data-protocol.md` without charter machinery.
- **Path A (counterfactual)**: 48h cool-down clock starts at human ratification turn; if
  ratified 2026-05-16T08:00 SEAST the earliest commit window is 2026-05-18T08:00 SEAST.
  Version bump v1.1 → v1.2. md5-rebaseline of `.charter-md5-baseline` per D-056 process.

## § Sub-track for S336 sandwich-dev (PROPOSAL-author session)

### D1 — VBW Read of the Architect's Proposal

- Read `agent-workspace/proposals/theme-g-i-s1-1-amendment-2026-05-16.md` via the Read
  tool (not from memory; VBW protocol mandatory).
- Verify: file exists; frontmatter is well-formed; sections § 1 - § 9 are present.

### D2 — DoD Coverage Check + Refinement (additive only)

- For each DoD item DC1-DC10 below, verify the proposal text covers it.
- If a DoD item is uncovered or ambiguous: REFINE the proposal text additively (do NOT
  rewrite the architect's binding choices — Path B remains the recommendation, the rule's
  literal text in proposal § 4 remains as authored).
- Refinement examples (acceptable scope):
  - Adding 1-2 sentences clarifying a satisfaction mode if § 4.1 is ambiguous.
  - Adding a missing citation file:line if § 7 is short of a claim.
  - Adding a missing companion edit if proposal § 4.3 / § 4.4 was omitted.
- Refinement examples (OUT OF SCOPE for S336):
  - Switching the recommended path from B to A or C (this would contradict D-061; only
    the human at the ratification gate may do this).
  - Re-authoring the literal Rule 16 text (the architect's text is the binding draft;
    only the human may amend it).

### D3 — Constitution-Untouched Verification

- Confirm `PROJECT_CHARTER.md` has NOT been modified by S336 (check via Read tool on
  the file; compare against the v1.1 + Principle 11 baseline at line 4-5 and line 77).
- Confirm `agent-workspace/constitution/**` has NOT been modified by S336 (Read tool on
  `financial-data-protocol.md` last-modified footer line 356-357 — should still read
  "2026-04-23 (v1.0 initial — stock-specific data integrity)" + "Amended 2026-05-04:
  Rule 11 (D-019 hook portability), Rules 12-15 (D-021 Vietnam-domain)"; should NOT yet
  mention a 2026-05-NN Rule 16 amendment).

### D4 — NO new hook / NO new firing-test

S336 is a PROPOSAL session. The Rule 16 enforcement hook
(`scripts/hooks/numeric-field-discipline-check.sh`) mentioned in proposal § 4.1
"Enforcement" subsection is **planned, not authored**. It is part of a future IMPL session
(deferred to post-ratification IMPL slot, likely sequenced after Phase D-K Theme L IMPL
to honor master-plan critical-path ordering L → I → H → J → K).

DC4 enforces this: S336 must NOT create any new file under `scripts/hooks/` or
`scripts/hooks/firing-tests/`.

### D5 — Session Log + Observation

- Write `agent-workspace/memory/sessions/session-336.md` per session-log template.
  Contents:
  - Type: FOCUSED_IMPL (proposal-author)
  - Phase: C (Theme G I-S1-1)
  - Files touched: 1 (proposal file) + 1 (session log) + 1 (observation) — possibly +1 plan
    file mv from pending/ → completed/
  - Decisions made: NONE (the path recommendation is the architect's via this plan; the
    final ratification is the human's via AskUserQuestion gate)
  - Mistakes: per `agent-workspace/memory/mistake-log.md` rule — write "no mistakes this
    session" if no M-S336-N entries
  - Tracking retention check per CLAUDE.md hard rule
  - L-S336-N lessons (if any emerged)
- Write `agent-workspace/memory/observations/S336-sandwich-dev-theme-g-proposal.md`.
  Contents:
  - Observation-style narrative of what dev did, what it found, any anomalies.
  - DoD coverage attestation row-by-row (DC1 - DC10).
  - Forward to verifier checklist for V1-V6 (this plan § Verifier Checklist).

### D6 — Commit Boundary

Per D-060 ("agent MAY git commit; MUST NOT push"), the S336 dev decides commit boundary:

- **Architect-recommended**: single commit at session-close-eligible point with subject
  "S336-close: Theme G I-S1-1 proposal + plan-019 + session-log".
- **Alternative**: zero commits — leave staging to the main session post-return.
- Main session's S335-close consolidation has flexibility to pick either.

NO push under any circumstance — push is human-only per D-060.

## § DoD criteria

| ID | Criterion | Source |
|---|---|---|
| **DC1** | Proposal doc exists at `agent-workspace/proposals/theme-g-i-s1-1-amendment-2026-05-16.md` | this plan § Goal + this plan § Coordination rules |
| **DC2** | Proposal cites ≥ 5 empirical source-evidence references with file:line (5 minimum: A-01, A-04, A-13, A-14, A-15) | this plan § Empirical Evidence + proposal § 1 + proposal § 7 |
| **DC3** | Literal Rule 16 text complete + well-formed (problem statement + rule body w/ 4 satisfaction modes + enforcement subsection + cross-references) | this plan § Literal Amendment Text + proposal § 4.1 |
| **DC4** | Companion edit text for `invariants-stockforge.md` (I-S1-1 alias) + Quick Reference Table row + last-modified footer amendment all present | this plan § Literal Amendment Text + proposal § 4.2 + § 4.3 + § 4.4 |
| **DC5** | Decision matrix complete (4 paths A/B/C/D) with explicit recommendation (Path B) + rationale chain (≥4 reasons each source-cited) | this plan § Path Decision Matrix + proposal § 3 |
| **DC6** | Cool-down window documented (Path A counterfactual; 48h per Revision Protocol) | this plan § Cool-Down + Version-Bump Bookkeeping + proposal § 5 |
| **DC7** | `PROJECT_CHARTER.md` untouched (verify via Read tool spot-check on line 4 status + line 77 Principle 11 + git status if Bash available — but dev has no Bash by spec; rely on Read tool comparison + sandwich-verifier V2 cross-check) | this plan § Sub-track D3 + sandwich-verifier V2 |
| **DC8** | `agent-workspace/constitution/**` untouched (verify via Read tool spot-check on `financial-data-protocol.md` last-modified footer line 356-357 — must still read "2026-04-23 (v1.0 initial …)" + "Amended 2026-05-04: Rule 11 (D-019 hook portability), Rules 12-15 (D-021 Vietnam-domain)") | this plan § Sub-track D3 + sandwich-verifier V2 |
| **DC9** | NO premature charter version bump (Charter still reads v1.1 — check line 4 of `PROJECT_CHARTER.md`) | this plan § Sub-track D3 |
| **DC10** | Plan-019 references the proposal at the canonical path; D-061 § Decision item 6 cited; out-of-band ratification flow documented (4 picks A/B/C/D in this plan + proposal § 9) | this plan § Out-of-band Ratification Flow + proposal § 9 |
| **DC11** | Session log + observation written per § Sub-track D5 | this plan § Sub-track D5 |
| **DC12** | Plan-019 moves `pending/` → `completed/` at S336 close (or at main S336+1 close-bookkeeping turn — architect leaves this to dev/main discretion per D-060 + plan-018 precedent) | this plan § Sub-track D6 + plan-018 completed-mv precedent |
| **DC13** | NO new hook / NO new firing-test file authored under `scripts/hooks/` or `scripts/hooks/firing-tests/` (proposal § 4.1 mentions a planned `numeric-field-discipline-check.sh` but that is OUT OF SCOPE for S336) | this plan § Sub-track D4 |
| **DC14** | NO production code modified (no edits under `packages/**` or `apps/**`) — S336 is PROPOSAL tier | this plan § Hard Rules Acknowledged |

## § Coordination rules (during S336 dev)

**S336 dev (background subagent) owns these write paths**:

- `agent-workspace/proposals/theme-g-i-s1-1-amendment-2026-05-16.md` (refinement only;
  architect's path B recommendation + literal Rule 16 text are binding)
- `agent-workspace/memory/sessions/session-336.md` (new)
- `agent-workspace/memory/observations/S336-sandwich-dev-theme-g-proposal.md` (new)
- Optional: move `agent-workspace/session-plans/pending/019-S335-phase-c-theme-g-i-s1-1-amendment.md`
  → `completed/` at session close

**S336+ main session avoids these paths** during background dispatch:

- `agent-workspace/proposals/theme-g-i-s1-1-amendment-2026-05-16.md`
- `agent-workspace/session-plans/pending/019-S335-phase-c-theme-g-i-s1-1-amendment.md`
  (this plan; possibly mv'd at close)
- `agent-workspace/memory/sessions/session-336.md`
- `agent-workspace/memory/observations/S336-sandwich-dev-theme-g-proposal.md`
- `agent-workspace/memory/decisions/065-*` (if dev proposes a D-065 ADR draft for the
  decision-of-the-decision; architect does NOT mandate this — D-065 is the natural
  next number per D-060 + D-061 + D-062 + D-063 + D-064 sequence; the ADR may be
  authored by the post-ratification IMPL session instead of S336)

**Charter / constitution paths under HARD avoid by everyone**:

- `PROJECT_CHARTER.md` (never edited by agent without explicit human gate)
- `agent-workspace/constitution/financial-data-protocol.md` (Path B target; gated)
- `agent-workspace/constitution/invariants-stockforge.md` (companion edit gated)
- `agent-workspace/constitution/invariants.md` (general invariants; no I-S* additions
  here per S48l HH-G.2 split rule)

## § Risk + Mitigation

| # | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| R1 | Architect misreads Phase A evidence (I-S1-1 actually redundant w/ I-S1) | LOW | HIGH (would justify Path C; would have surfaced as a contradiction in the proposal's § 1 evidence chain — but architect re-verified all 5 file:line cites against the actual deep-dive files in the S335 read pass) | (a) Empirical 5-row survey in `INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md § G.2` was reviewed during architect dispatch; the table shows 3 LLM-emit confirmations + 2 counter-examples — sound; (b) D-061 ratification accepted GENUINE-new claim 2026-05-15T15:30+07:00; reverting now would require fresh user input |
| R2 | User picks Path A at ratification gate (charter amendment) — proposal's "drop into either home" structure handles it | MEDIUM | LOW (proposal text in § 4.1 is rule-level prose; the prose drops into either `PROJECT_CHARTER.md` § Core Principles as new P9.1 or into `financial-data-protocol.md` as Rule 16) | Plan-019 + proposal § 5 explicitly document the Path A counterfactual; the literal text in proposal § 4.1 is structured to drop into either home with minor section-heading adjustment |
| R3 | User picks Path C at ratification gate (REJECT) — Phase F-prime Theme H IMPL would inherit ungoverned `entry_price` / `price_target` LLM-emit | LOW (this would contradict D-061; architect counter-recommends NOT picking) | HIGH | Proposal § 6 explicitly catalogs Path C risks as DO-NOT-PICK; main session AskUserQuestion includes Path C with rationale-against framing |
| R4 | 48h cool-down window violated if Path A picked + commit landed early | LOW (the cool-down is documented in proposal § 5 + Path A is not the recommendation) | MEDIUM (charter coherence corruption risk per D-047 precedent caught at S253) | (a) D-056 process precedent — temp-deny-lift only at the verified-actual ratification session, not pre-staged; (b) main session must wait for ≥48h before any charter edit if Path A picked |
| R5 | Path B picked but constitution edit later fails human-approve gate (e.g. wording change requested) | MEDIUM | LOW (just iterates — the proposal becomes input to a next iteration; no production code lost) | Proposal § 4.1 text is a DRAFT; human approver may amend before dropping into constitution; subsequent ADR records final landed text not the draft |
| R6 | Companion edit to `invariants-stockforge.md` forgotten by post-ratification IMPL session | LOW (proposal § 4.2 explicit; DoD § DC4 explicit; verifier V4 checks) | MEDIUM (coherence gap if Rule 16 lands but I-S1-1 alias missing) | (a) Plan for post-ratification IMPL session will inherit DC4 + V4; (b) `phase-status-coherence.sh` Stop hook + `project-md-adr-staleness.sh` Stop hook catch coherence gaps |
| R7 | S336 dev attempts to write the constitution edit prematurely (ghost-greening) | LOW (no Bash; Write to constitution/ is deny-listed per `.claude/settings.json`) | LOW (settings.json deny would block; dev would error before writing) | (a) Deny rule in settings.json — defense in depth; (b) DC7 + DC8 verify untouched at session close; (c) sandwich-verifier V2 cross-checks |
| R8 | Defer cycles inflate on D-061 § Decision item 6 if ratification gate not closed in 48h | LOW (Q-INT-2026-05-6 already ACCEPTED 2026-05-15T15:30; this proposal is the follow-through, not a fresh defer) | LOW | `defer_cycles` in D-061 frontmatter remains at 0 unless main session explicitly defers; expected_answer_by SLA defaults to 24-48h per `agent-workspace/CLAUDE.md` Auto-mv rule |
| R9 | D-061 § Decision item 6 was over-interpreted — Q-INT-2026-05-6=A picked "Path B" but the human might have meant the constitution write IS subject to the same gate (yes, it is) | NEGLIGIBLE | NEGLIGIBLE | The Q-INT-2026-05-6 answer option A text per `qa-2026-05-15-wave-1-bis.md` line 32 reads "constitution write in agent-workspace/constitution/financial-data-protocol.md extension; **Phase C S333 PLAN + S334 human-approve gate**" — both PLAN + human-approve gate are explicit; nothing was over-interpreted |
| R10 | Plan-019's proposal-pointer goes stale if proposal is renamed | LOW | LOW | This plan cites the canonical path; if a rename happens both this plan + sub-track D1's Read call need updating — track via verifier V6 |

## § Verifier checklist (V1-V6 for S336+1 sandwich-verifier if dispatched)

The S336+1 verifier (fresh-context per AP-1) reviews the S336 dev output. Checklist:

| ID | Check | How |
|---|---|---|
| **V1** | All DoD criteria DC1-DC14 met | Read this plan + each DoD item's source; cross-reference proposal + session-log + observation files; emit row-by-row PASS/FAIL/SKIP table |
| **V2** | **PROJECT_CHARTER.md untouched** — line 4 still reads `Immutable v1.1 — changes require explicit charter revision.` line 77 still reads the Principle 11 verbatim; **agent-workspace/constitution/** untouched — `financial-data-protocol.md` last-modified footer at line 356-357 unchanged; `invariants-stockforge.md` last-modified footer at line 197 unchanged | Read tool spot-checks on the cited line numbers; if Bash tool is granted to verifier, `git diff --stat -- PROJECT_CHARTER.md agent-workspace/constitution/` returns empty (CRITICAL — any non-empty diff is HARD FAIL) |
| **V3** | Empirical cite accuracy — for each of the 5 cite sources (A-01, A-04, A-13, A-14, A-15), open the cited file:line range and confirm the proposal's quotation matches the source | Sample-read each of the 5 deep-dive observations; spot-check at least 2 of the 5 fully |
| **V4** | Literal amendment text well-formed — Rule 16 body has all 4 satisfaction modes (categorical / deterministic-echo / calibration / null); enforcement subsection covers schema-definition / runtime / amendment-time; cross-references list Principle 8 + Principle 9 + I-S1 + I-S7 + Rule 6 + Rule 7 + Rule 9 | Read proposal § 4.1; tick off the 4 modes + 3 enforcement layers + 7 cross-refs |
| **V5** | Decision matrix complete — 4 paths A/B/C/D each have row in the matrix + explicit recommendation flagged on Path B + adversarial framing subsection (§ 6) lists "what could go wrong" for each path | Read proposal § 3 + § 6; tick off |
| **V6** | Proposal doc shape — frontmatter has required fields (proposal_id, session, authored, status, recommended_path); sections § 1 - § 9 all present | Read proposal frontmatter + section headings |

**Verdict format** (per S312 / S314 / S333 verifier pattern):
- PASS — all V1-V6 PASS; no action required
- PASS-WITH-CONCERNS — V1-V6 PASS but ≥1 IMPORTANT cosmetic issue; merge-eligible, log for remediation
- FAIL — ≥1 V1-V6 FAIL on critical item (V2 charter/constitution diff; V3 cite accuracy on a foundational source); blocks ratification gate until remediation

## § Out-of-band Ratification Flow

**Trigger**: S336 dev returns + plan-019 moves to completed/ + main session reads dev's
observation file + checks DoD coverage.

**Main fires AskUserQuestion** (CHARTER-tier allowed per AskUserQuestion-is-for-SCOPE/CHARTER
memory rule + per stop_offering_routing_branches memory rule's exception "Q&A only for
SCOPE/CHARTER"):

```
Q-PHASE-C-THEME-G — Theme G I-S1-1 sub-rule canonical home

Per proposal at agent-workspace/proposals/theme-g-i-s1-1-amendment-2026-05-16.md:

(A) CHARTER amendment v1.1 → v1.2 — add Principle 9.1 (or P12) "Numeric-Field Discipline"
    to PROJECT_CHARTER.md. Per Revision Protocol: 48h cool-down clock starts on your pick;
    earliest edit window 2026-05-18T08:00 SEAST. Heavier ceremony; equally binding.

(B) CONSTITUTION write — add "Rule 16 — Numeric-Field Discipline (I-S1-1)" to
    agent-workspace/constitution/financial-data-protocol.md + companion I-S1-1 alias edit
    in invariants-stockforge.md + Quick Reference Table row + last-modified footer.
    No cool-down. Same-session temp-deny-lift edit pattern (per D-056 process). Recommended
    per D-061 § Decision item 6 + Q-INT-2026-05-6=A you already picked 2026-05-15. **(Recommended)**

(C) REJECT — claim I-S1 already covers; retire-without-promote. Contradicts D-061;
    discards Phase A empirical evidence; AP-23 retire-without-evidence is itself a
    charter violation per CLAUDE.md hard rule. Architect counter-recommends NOT picking.

(D) RE-ARCHITECT — refine scope (e.g. expand beyond numeric fields to all LLM-emit
    schema fields). Re-dispatch sandwich-architect with refined scope.
```

**On user pick**:

- **Pick A** → main session enters Path-A workflow:
  1. ACCEPT D-NNN ADR draft (next-available number; per architect's recommendation this
     is D-065 candidate) with status PROPOSED + 48h cool-down clock recorded
  2. After 48h elapsed, FOCUSED_IMPL session for charter edit via same-session
     temp-deny-lift pattern per D-056 process
  3. Update `.charter-md5-baseline` post-edit; verify via Read + grep per D-056 V1-V4

- **Pick B (recommended)** → main session enters Path-B workflow:
  1. ACCEPT D-NNN ADR draft (D-065 candidate) with status PROPOSED at IMPL tier
  2. Same-session OR next-session FOCUSED_IMPL session for constitution write via
     same-session temp-deny-lift pattern; D-019 + D-021 precedent established
  3. Verify post-edit: `financial-data-protocol.md` Rule 16 present, well-formed; companion
     I-S1-1 alias present in `invariants-stockforge.md`; Quick Reference Table row added;
     last-modified footer dated
  4. ADR moves PROPOSED → ACCEPTED on edit landing

- **Pick C** → main session enters Path-C workflow:
  1. D-061 § Decision item 5 amendment: append REV-1 noting the human ratification gate
     produced retire-instead-of-promote outcome
  2. Update Theme G in `INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md` (additive only;
     do NOT delete the original content — append a supersession note) to reflect
     "Theme G retired at gate; I-S1 + I-S7 deemed sufficient"
  3. Skip to Phase D-K Theme L IMPL kickoff (master plan § 6.4)

- **Pick D** → main session re-dispatches sandwich-architect with refined scope per
  user comment in the AskUserQuestion answer

## § Compliance Attestation (this plan)

- ✅ no production code written by this plan (markdown only; sandwich-architect subagent)
- ✅ no commits by this plan (no Bash tool granted to sandwich-architect)
- ✅ no charter edits proposed in this plan beyond the literal candidate text in the
  proposal (the literal text is awaiting human gate, not applied)
- ✅ no constitution writes in this plan beyond the literal candidate text (same)
- ✅ no human-workspace writes (proposal lives in `agent-workspace/proposals/`;
  AskUserQuestion gate fired by main S336)
- ✅ R-1 no-mix PLAN+IMPL — this is PLAN-tier; S336 dev is FOCUSED_IMPL-tier for PROPOSAL
  authoring (no production code in S336 either; the only "code" is markdown)
- ✅ R-2 split-if->10-tasks — S336 sub-track has 6 D1-D6 items + 14 DoD criteria; under
  the threshold
- ✅ every claim source-cited per I-S2 (see frontmatter `depends_on` + proposal § 7)
- ✅ I-S35 research-aid framing preserved (no "buy/sell/recommendation" language anywhere
  in plan or proposal)
- ✅ I-S10 / I-S11 multi-perspective preserved (this proposal references but does not
  itself execute Theme H synthesis primitives; safe)
- ✅ AP-23 promote-or-retire trigger satisfied via Path B promote-to-dedicated-rule
  recommendation (per CLAUDE.md hard rule); NOT inline accumulation
- ✅ AP-1 mitigation noted — S336+1 verifier (if dispatched) is fresh-context separate
  from S336 dev
- ✅ verify_phase_before_next_phase — Phase B's Wave 0 substrate FULLY SEALED per
  `agent-workspace/memory/checkpoints/latest.md`; Phase C entry is empirically justified
- ✅ Wave-1 master plan § 6.3 Phase C scope honored (PROPOSAL + GATE; no IMPL pre-staged
  beyond the proposal text)

End of plan-019.
