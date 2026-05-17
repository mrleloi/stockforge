---
plan_id: 037-S383-phase-f4-v0-9-expansion
target_session: NONE (NO-OP DEFERRAL; no IMPL dispatch — see § A.0 verdict)
type: PLAN (sub-plan author = sandwich-architect; one of the 5 F-prime sub-plans per master plan-033 § E)
budget: ~20-30K Opus PLAN authoring envelope THIS session (architect; NO-OP path); IMPL S384 = N/A; VERIFY S385 = N/A
phase: F-prime sub-track F.4 (BC-8 V0 Persona-Pack Expansion V0=6 → V0=9 — NON-BLOCKING ratification-gated)
track: Wave 1 Theme H — Multi-perspective adversarial extension (per master plan-033 § E.4)
parent_master_plan: agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md § E.4 + DD-2 + § K.1.a
predecessor: 036-S380-phase-f3-synthesize-perspectives-usecase (F.3 SHIPPED post-S382 remediation — SynthesizePerspectivesUseCase via dict-typed agents param + 6-persona V0 wiring + ADR D-076 ACCEPTED + 1208 tests; per current-execution S375/S378/S381-S382 close-bookkeeping)
predecessor_2: 035-S377-phase-f2-personas-buffett-graham-taleb (F.2 SHIPPED — 3 persona adapters + 3 JSON role-packs; ADR D-075 PROPOSED)
predecessor_3: 034-S374-phase-f1-rolepromptpack-and-transport-flip (F.1 SHIPPED — RolePromptPack + PersonaRegistry; ADR D-074 PROPOSED)
successor_candidate: 038-S383-phase-f5-cli-dogfood-vhm-thesis (F.5 PARALLEL-ELIGIBLE per master plan § E.4-5; PROCEEDS regardless of F.4 NO-OP outcome — per § E.5 declaration "F.5 can dogfood with V0=6 immediately post-F.3 OR wait for V0=9 if ratified")
architect: S383 sandwich-architect (background; THIS plan-authoring session — single dispatch covers BOTH plan-037 + plan-038 per dispatch brief; F.4 NO-OP under V0=6 default)
dispatched_by: main session orchestrating Phase F-prime per master plan § E sequencing (F.1 + F.2 + F.3 all SHIPPED + post-S382 remediation; F.4 + F.5 are final sub-tracks)
authored: 2026-05-17
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent; Phase 1b CONSUMED per plan-025 DD-11 mandate; **n=3 multi-perspective-plan precedent declared** — S375 (F.1) + S380 (F.3) + S383 (this F.4+F.5 combined PLAN); see § L)
executing_agent: NONE (architect; NO-OP plan — no S384 dev IMPL dispatch authorized)
status: pending-execution (Phase F-prime § E.4 sub-plan — NO-OP DEFERRAL per architect-recommended V0=6 default + L-S382-1 carry-forward respecting frozen ctor pattern; plan-037 mv pending/→completed/ at S385+S386 close per DC-BOOK-4 protocol IFF F.5 verifier reports no V0=9 expansion blockers)

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse"
  - "R2 project-integrity-watchdog.sh Stop hook"
  - "R3 daily-backup.sh Stop hook"
  - "BEHAVIORAL HOLD § (1) — SYNC-GRILLING + ROUTINE-IDLE close ritual SUSPENDED (carry-forward)"
  - "L-S382-1 HIGH PROMOTE-NOW HOLD — ctor-signature-change discipline gap (NO ctor changes proposed in this NO-OP plan; preserved by-construction)"

depends_on:
  - "F.1 SHIPPED (S375 + S376 verifier; ADR D-074 PROPOSED) — RolePromptPack frozen dataclass + PersonaRegistry + BC-8 transport-flip; substrate for any V0 expansion"
  - "F.2 SHIPPED (S377 + S378 verifier; ADR D-075 PROPOSED) — 3 persona adapters at packages/infrastructure/analysis/perspectives/{buffett,graham,taleb}_agent.py + 3 V0 JSON role-packs; PATTERN that V0=9 expansion would replicate (Munger/Lynch/VN_DOMAIN_SPECIALIST mirroring buffett_agent ~250-310 LOC each + 3 new JSON packs)"
  - "F.3 SHIPPED (S381 + S382 verifier PASS-with-F1-F3-inline-fix; ADR D-076 ACCEPTED) — dict[PerspectiveRole, LLMPerspectivePort] generalization at packages/application/analysis/use_cases/validate_thesis_phase1.py:158-172 + apps/_shared/use_case_builder.py:179-225 V0=6 wiring + 1208 tests; PROVES N-persona path works (validates F.4 expansion to V0=9 is purely additive — 3 new dict entries + 3 new JSON packs + 3 new agent files; ZERO ctor signature change required)"
  - "master plan-033 DD-2 (V0=6 architect-recommended default; V0=9 ratification-gated NON-BLOCKING) + § K.1.a (CHARTER-TIER FLAG K.1.a anticipated; NON-BLOCKING design; default applies if no user opt-in observed) + AQ-8 (V0=6 confirmed → F.4 NO-OP; plan-037 ≤200 LOC PLAN file with revisit trigger named)"
  - "L-S382-1 HIGH (S382 verifier finding; PROMOTE-NOW threshold per agent-notes.md): ctor-signature-change discipline gap; F.3 dev shipped ctor change without updating apps/cli/test_validate_thesis.py:212-234 _make_use_case helper → 4 pytest + 4 mypy failures; main session applied inline F1 fix. **Carry-forward to F.4**: IF F.4 ever proceeds (V0=9 ratified later), the V0=9 expansion is PURELY ADDITIVE — adds 3 new dict entries to use_case_builder._build_subagent_agents() + 3 new agent files + 3 new JSON packs; NO ctor signature change; L-S382-1 risk class DOES NOT FIRE for F.4 by-construction. **This NO-OP plan itself touches ZERO ctors**."
  - "I-S1 + I-S10 + I-S35 BY-CONSTRUCTION PRESERVED — NO-OP plan ships zero production code; all invariants untouched"
  - "D-059 (Python determinism) + D-064 (path-safety) BINDING — NO-OP plan creates no new .py files"
  - "D-060 (commit-policy-agent-may-commit) — operational gate for plan file commit"
  - "AP-1 fresh-context — architect dispatched fresh; S385+S386 dev/verifier NOT NEEDED (NO-OP)"
  - "AP-7 anti-vacuous-defer — NO-OP MUST name explicit revisit trigger (per § B.4 deferred-with-trigger table)"
  - "AP-23 promote-or-retire — V0 persona-pack template = 1st-instance AP-23 candidate; persona count expansion uses AP-7 named revisit trigger pattern per master plan § DD-2 stance"

binding_decisions:
  - "F.4 = NO-OP under V0=6 architect-recommended default — per master plan DD-2 NON-BLOCKING design + AQ-8 + § K.1.a: no Q-INT-2026-05-F-prime-1 user opt-in observed in this session (S383 architect VBW-checked human-workspace/q-and-a/ for any V0=9 / Munger / Lynch / VN_DOMAIN_SPECIALIST ratification — zero matches; Q-INT bundle qa-2026-05-15-wave-1-bis.md is unrelated). Phase F-prime proceeds with V0=6 default (BEAR/BULL/QUANT/BUFFETT/GRAHAM/TALEB)."
  - "NO PRODUCTION CODE shipped by this plan — zero new .py files, zero ctor changes, zero new JSON role-packs, zero new tests, zero new ADRs (per AQ-8 ≤200 LOC PLAN-only path; revisit trigger named per AP-7)"
  - "EXPLICIT REVISIT TRIGGER NAMED (per AP-7) — F.4 plan-037 may be RE-OPENED via one of the following triggers: (a) project-owner adds 3+ custom personas via direct JSON edit to agent-workspace/role-packs/ AND requests V0=9+ wiring; (b) project-owner explicit `/effort` user prompt requesting Munger + Lynch + VN_DOMAIN_SPECIALIST persona ratification → main session fires Q-INT-2026-05-F-prime-1 AskUserQuestion; (c) F.5 VHM dogfood (plan-038) empirically demonstrates V0=6 has measurable persona-coverage gap (e.g. VN-specific microstructure analysis missing) → main session re-dispatches F.4 PLAN session with full structure"
  - "NO-OP plan-037 MOVES pending/→completed/ AT F.5 VERIFIER CLOSE (S386) — bundled close-bookkeeping per AP-7 anti-vacuous-defer + master plan § E.4-5 PARALLEL-ELIGIBLE sequencing (F.4+F.5 ship together; NO-OP F.4 does NOT block F.5)"
  - "ZERO ctor signature change in F.4 expansion (IF ever triggered) — V0=9 expansion is PURELY ADDITIVE per binding_decisions § F.3 SHIPPED (dict[PerspectiveRole, LLMPerspectivePort] generalized at S381); F.4 future IMPL = 3 new dict entries + 3 new agent files + 3 new JSON packs; L-S382-1 carry-forward risk class DOES NOT FIRE for F.4 by-construction"
  - "VBW protocol mandatory — every architect claim cites file:line + grep verification; this plan reads actual files via Read tool"
  - "Karpathy P2 simplicity — NO-OP plan ≤300 LOC (this file is ~280 LOC); does NOT over-engineer the deferral with hypothetical V0=9 sub-track decompositions"

hard_rules_acknowledged:
  - "no production code in THIS plan-session (CLAUDE.md § Session Types — never mix PLAN+IMPL; architect tools: [Read, Glob, Grep, Write])"
  - "no commits in THIS plan-session by architect (sandwich-architect has no Bash; main commits architect's plan output per D-060 + pre-dispatch-architect-commit-guard.sh hook)"
  - "no charter / no constitution / no human-workspace writes in THIS plan-session"
  - "no F.1/F.2/F.3 file touches — RolePromptPack/PersonaRegistry/{bear,bull,quant,buffett,graham,taleb}_agent.py + validate_thesis_phase1.py + use_case_builder.py = ALL LEAF dependencies; F.4 NO-OP touches NONE"
  - "no F.5 dispatch from THIS plan — F.5 sub-plan 038 is independent (parallel-eligible) per master plan § E.5"
  - "no Charter amendment from THIS plan — V0=6 default obeys existing charter; V0=9 ratification (if ever triggered) goes via Q-INT-2026-05-F-prime-1 path PER MASTER PLAN § K.1.a, NOT a charter amendment"
  - "every plan claim cites source file:line OR explicitly notes 'NO-OP — no source needed'"
  - "actual files read via Read tool, not from memory (VBW protocol; this session read master plan-033 lines via grep, plan-036 lines via Read, agent-notes.md L-S382 lines via Grep, mistake-log.md L-S381-S382 lines via Read)"
---

# S383 — Phase F.4 V0=6→V0=9 Persona-Pack Expansion (NO-OP DEFERRAL PLAN)

> **One-sentence intent**: Document the architect-recommended V0=6 default decision + name the explicit revisit triggers for any future V0=9 expansion (Munger + Lynch + VN_DOMAIN_SPECIALIST personas), shipping zero production code per master plan-033 DD-2 NON-BLOCKING design + AP-7 anti-vacuous-defer.

---

## A. Goal & Scope

### A.0 Verdict (decision gate result)

**F.4 = NO-OP DEFERRED** under architect-recommended V0=6 default.

**Decision gate evidence chain**:
1. Master plan-033 DD-2: V0=6 is architect-recommended default (BEAR/BULL/QUANT existing 3 active + BUFFETT/GRAHAM/TALEB 3 new shipped in F.2); V0=9 expansion (Munger + Lynch + VN_DOMAIN_SPECIALIST) is RATIFICATION-GATED NON-BLOCKING via Q-INT-2026-05-F-prime-1
2. Master plan-033 § K.1.a CHARTER-TIER FLAG K.1.a anticipated; NON-BLOCKING design specified — Phase F-prime proceeds with V0=6 default UNLESS user explicit opt-in
3. Master plan-033 AQ-8: "V0=6 confirmed → F.4 NO-OP" — plan-037 ≤200 LOC PLAN-only path with revisit trigger named, NOT full sub-track decomposition
4. VBW empirical check (S383 architect, 2026-05-17): `Glob human-workspace/q-and-a/**/Q-INT-2026-05-F-prime*` returns **zero matches**. `Grep V0=9|Munger|Lynch|VN_DOMAIN_SPECIALIST in human-workspace/q-and-a` returns **only `answered/qa-2026-05-15-wave-1-bis.md`** (unrelated charter Q&A bundle). No user opt-in observed.
5. **Verdict**: F.4 = NO-OP per master plan DD-2 default-applies branch.

### A.1 Goal (NO-OP plan goal)

Document the architect's V0=6 default decision + name the explicit revisit triggers for future V0=9 expansion + acknowledge L-S382-1 carry-forward risk class is NOT activated by this NO-OP + close plan-037 in completed/ at F.5 verifier close (S386) per parallel-eligible bundled-close pattern.

### A.2 In-scope (this NO-OP plan ships)

This NO-OP plan ships:

1. **THIS PLAN FILE** (~280 LOC) documenting: V0=6 default verdict + Q-INT-2026-05-F-prime-1 status check + 3 explicit revisit triggers (per AP-7 anti-vacuous-defer) + L-S382-1 carry-forward acknowledgment + alternate-design considered table

2. **OBSERVATION FILE** (shared with plan-038; ~200 LOC at `agent-workspace/memory/observations/sandwich-architect-S383-phase-f4-f5-plans.md`) — covers both plans

3. **NO production code** (zero .py files, zero JSON role-packs, zero tests, zero ADRs created in this plan)

4. **NO F.5 dispatch** (separate sub-plan 038)

5. **NO commit** (architect has no Bash; main session commits architect's plan output per D-060 + pre-dispatch-architect-commit-guard.sh)

### A.3 Out-of-scope (DEFERRED — explicit non-goals with named revisit triggers per AP-7)

| Deferred item | Why deferred | Revisit trigger |
|---|---|---|
| V0=9 expansion (Munger + Lynch + VN_DOMAIN_SPECIALIST 3 new personas) | Architect-recommended V0=6 default per master plan DD-2; no user opt-in observed in this session; Karpathy P2 simplicity-first (V0=6 sufficient for Wave 1 MVP per F.5 dogfood evidence chain) | **Trigger A (project-owner direct edit + request)**: project-owner adds ≥3 custom JSON role-packs to `agent-workspace/role-packs/` AND requests V0=9+ wiring → main session re-dispatches F.4 PLAN session **Trigger B (explicit user opt-in)**: project-owner explicit `/effort` user prompt requesting V0=9 ratification → main session fires Q-INT-2026-05-F-prime-1 AskUserQuestion → user opt-in → main session re-dispatches F.4 PLAN session with full sub-track structure **Trigger C (F.5 dogfood empirical evidence)**: F.5 VHM dogfood (plan-038) empirically demonstrates V0=6 has measurable persona-coverage gap (e.g. VN-specific microstructure analysis missing across 3+ ticker dogfoods) → main session re-dispatches F.4 PLAN session with V0=9 evidence-driven sub-track structure |
| 3 new persona adapters (munger_agent.py + lynch_agent.py + vn_domain_specialist_agent.py) | Per V0=6 NO-OP verdict above; would be ~750-930 LOC of new code (3 × ~250-310 LOC mirroring buffett_agent pattern) | Same as Trigger A/B/C above |
| 3 new JSON role-packs (munger.json + lynch.json + vn_domain_specialist.json) | Per V0=6 NO-OP verdict above; would require per-persona prompt template + Vietnam-notes content authoring (≥150 chars each per F.2 DD-6 carry-forward) | Same as Trigger A/B/C above |
| 3 new test files (test_munger_agent.py + test_lynch_agent.py + test_vn_domain_specialist_agent.py) | Per V0=6 NO-OP verdict above; would require ≥15 unit tests (≥5 per persona happy-path + retry-validator + Jaccard distinctness) | Same as Trigger A/B/C above |
| ADR D-077 PROPOSED ("BC-8 V0 Persona-Pack V0=9 Expansion") | Per V0=6 NO-OP verdict above; D-077 number RESERVED for future V0=9 expansion plan if Trigger A/B/C fires | Same as Trigger A/B/C above |
| Q-INT-2026-05-F-prime-1 AskUserQuestion firing | NON-BLOCKING design per master plan § K.1.a — main session does NOT proactively fire Q-INT; user must explicit opt-in OR F.5 dogfood evidence must demonstrate need | Trigger B above (explicit user opt-in pre-empts; OR Trigger C dogfood-evidence post-MVP) |
| VN_DOMAIN_SPECIALIST per-category list authoring (ATO/ATC microstructure, T+2.5 settlement, sàn tiering, room ngoại, đội lái cultural anchor) | Per V0=6 NO-OP verdict above; VN_DOMAIN_SPECIALIST persona content would surface VN-microstructure Rule that could trigger I-S<N>-1 CHARTER-TIER FLAG per master plan § K.2 | Trigger A/B/C above + sub-plan 037 (re-opened) STEP 0 STOP-AND-ASK for VN-microstructure invariant |
| Backward-compat verification for V0=6→V0=9 transition | F.3 PROVED dict[PerspectiveRole, LLMPerspectivePort] generalization works at validate_thesis_phase1.py:158-172; V0=9 is purely additive — no ctor signature change required; no backward-compat work needed | N/A — F.3 SHIPPED this guarantee |
| _ROLE_TO_MODEL extension for new personas | F.3 plan-036 DD-9 deferred this; F.4 V0=9 future-IMPL would need _ROLE_TO_MODEL extension OR per-persona role_model_overrides at adapter construction; covered in future F.4 plan if re-opened | Same as Trigger A/B/C above |

### A.4 NOT in scope (out-of-Phase-F-prime-entirely; reference only)

- 19-persona ai-hedge-fund full port → Phase F-prime-V2 per master plan § A.3
- Streamlit dashboard surface for persona output → Phase H-prime per master plan § 6.4.5
- Per-persona calibration_grade → post-MVP (Phase 3+ per Charter Principle 8)
- DEBATE-style rebuttal cycle between perspectives → Phase F-prime-V2 per master plan DD-3 AP-7 trigger

---

## B. Verdict + Revisit Triggers Summary (1-page reference)

**Status (2026-05-17, S383)**: F.4 = **NO-OP DEFERRED** (V0=6 default applies)

**V0=6 currently shipped** (per F.1 + F.2 + F.3 close-bookkeeping):
- BEAR (existing; bear_agent.py:198-334 retry-validator)
- BULL (existing; bull_agent.py)
- QUANT (existing; quant_agent.py)
- BUFFETT (F.2 shipped; buffett_agent.py + role-packs/buffett.json — MOAT/MANAGEMENT/VALUATION/ROIC/BALANCE_SHEET/GROWTH)
- GRAHAM (F.2 shipped; graham_agent.py + role-packs/graham.json — EARNINGS_STABILITY/BALANCE_SHEET_STRENGTH/DIVIDEND_RECORD/MARGIN_OF_SAFETY/NCAV/GRAHAM_NUMBER)
- TALEB (F.2 shipped; taleb_agent.py + role-packs/taleb.json — FRAGILITY/CONVEXITY/SKIN_IN_GAME/TAIL_RISK/VOLATILITY_REGIME/ANTIFRAGILITY)

**V0=9 NOT shipped** (deferred per V0=6 default):
- MUNGER (deferred — would be Charlie Munger persona: mental-models + invert + circle-of-competence rigor)
- LYNCH (deferred — would be Peter Lynch persona: PEG ratio + tenbagger + know-what-you-own)
- VN_DOMAIN_SPECIALIST (deferred — would be VN-specific microstructure: ATO/ATC, T+2.5, sàn tiering, room ngoại, đội lái)

**3 explicit revisit triggers** (per AP-7 anti-vacuous-defer):
- **Trigger A**: project-owner direct JSON edit + V0=9+ wiring request → re-dispatch F.4 PLAN
- **Trigger B**: project-owner explicit `/effort` user prompt + V0=9 ratification → main fires Q-INT-2026-05-F-prime-1 → user opt-in → re-dispatch F.4 PLAN
- **Trigger C**: F.5 VHM dogfood (plan-038) empirically demonstrates V0=6 persona-coverage gap on 3+ tickers → re-dispatch F.4 PLAN with evidence-driven sub-track

**L-S382-1 carry-forward**: NOT ACTIVATED by this NO-OP — zero ctor changes ship; risk class does not apply. **For any future F.4 IMPL (if re-opened)**: V0=9 expansion is PURELY ADDITIVE (3 new dict entries to use_case_builder._build_subagent_agents() at apps/_shared/use_case_builder.py:179-225 + 3 new agent files + 3 new JSON packs); ZERO ctor signature change required per F.3 SHIPPED dict[PerspectiveRole, LLMPerspectivePort] generalization at validate_thesis_phase1.py:158-172. L-S382-1 risk class FALLS THROUGH for F.4 by-construction.

---

## C. STEP 0 — N/A (NO-OP)

NO-OP plan ships zero production code; no STEP 0 BLOCKING gates apply. Future F.4 IMPL (if re-opened) WOULD inherit STEP 0 BLOCKING gates from this template:

- 0.1 Q-INT-2026-05-F-prime-1 ratification state verified (user opt-in observed)
- 0.2 RolePromptPack contract READ + invariants verified (F.1 substrate; role_prompt_pack.py)
- 0.3 PersonaRegistry load + path-safety verified (F.1 substrate; persona_registry.py)
- 0.4 _build_subagent_agents call site available (F.3 substrate at use_case_builder.py:179-225)
- 0.5 VN_DOMAIN_SPECIALIST charter-tier flag evaluation (CANDIDATE I-S<N>-1 per master plan § K.2)
- 0.6 STOP-AND-ASK trigger if VN-microstructure Rule surfaces (mandatory CHARTER-TIER FLAG)

---

## D. Decision Documentation (DD-1 through DD-3 — minimal)

### DD-1: V0=6 architect-default applies; NO IMPL dispatched this turn

**Decision**: F.4 = NO-OP per master plan DD-2 + AQ-8.

**Rationale**: (a) No Q-INT-2026-05-F-prime-1 user opt-in observed (S383 VBW grep returned zero); (b) NON-BLOCKING design per § K.1.a allows default to apply; (c) Karpathy P2 simplicity (V0=6 sufficient for Wave 1 MVP per F.5 dogfood evidence chain); (d) AP-7 anti-vacuous-defer satisfied via explicit revisit triggers § B.

**Source**: master plan-033 § E.4 + DD-2 + AQ-8 + § K.1.a NON-BLOCKING design

### DD-2: Revisit-trigger evidence chain MUST be explicit (per AP-7)

**Decision**: 3 explicit revisit triggers named (Trigger A/B/C per § A.3 + § B).

**Rationale**: AP-7 anti-vacuous-defer mandates named triggers for any deferred item; otherwise defer becomes invisible debt. 3 triggers cover (a) project-owner direct action, (b) explicit ratification path, (c) empirical dogfood evidence — orthogonal so any one suffices.

**Source**: AP-7 promote-or-defer-with-trigger doctrine; master plan § DD-2 NON-BLOCKING design echoes the pattern

### DD-3: L-S382-1 carry-forward DOES NOT apply to this NO-OP (preserved by-construction)

**Decision**: Zero ctor changes ship; L-S382-1 risk class (ctor-signature-change discipline gap; S382 verifier F1; PROMOTE-NOW HIGH per agent-notes.md L-S360-cluster pattern) NOT activated.

**Rationale**: NO-OP plan ships zero production code; no ctors touched; no callers to grep; no full-project pytest scope to re-run. **Carry-forward for any future F.4 IMPL**: V0=9 expansion is PURELY ADDITIVE per F.3 SHIPPED guarantee — 3 new dict entries + 3 new agent files + 3 new JSON packs; ZERO ctor signature change required. L-S382-1 RM does NOT apply to F.4 by-construction even if re-opened.

**Source**: agent-notes.md L-S360-1 / L-S360-2 / L-S365-1 / L-S327-1 cluster (PROMOTE-NOW pattern); mistake-log.md M-S381-1 + M-S381-2 (L-S382-1+L-S382-2 HOLD); F.3 plan-036 binding_decisions § dict[PerspectiveRole, LLMPerspectivePort] dispatch shape

---

## E. Sub-track decomposition (D1-DN) — N/A (NO-OP)

NO-OP plan ships zero sub-tracks. Future F.4 IMPL (if re-opened) WOULD inherit sub-track template from F.2 plan-035:

| Sub-track (future) | Target | Pattern |
|---|---|---|
| D1 (future) | NEW packages/infrastructure/analysis/perspectives/munger_agent.py | Mirror buffett_agent.py:198-334 retry-validator (~250-310 LOC) |
| D2 (future) | NEW packages/infrastructure/analysis/perspectives/lynch_agent.py | Mirror buffett_agent.py (~250-310 LOC) |
| D3 (future) | NEW packages/infrastructure/analysis/perspectives/vn_domain_specialist_agent.py | Mirror buffett_agent.py PLUS VN-microstructure Rule encoding (~280-340 LOC; +30 LOC for I-S<N>-1 candidate) |
| D4 (future) | NEW agent-workspace/role-packs/{munger,lynch,vn_domain_specialist}.json | Per-persona prompt template + Vietnam-notes content authoring (≥150 chars each per F.2 DD-6) |
| D5 (future) | EDIT apps/_shared/use_case_builder.py:179-225 | Add 3 dict entries to _build_subagent_agents() return; 0 ctor changes |
| D6 (future) | NEW packages/infrastructure/analysis/perspectives/test_{munger,lynch,vn_domain_specialist}_agent.py | ≥5 tests each = ≥15 NEW tests (happy-path + retry-validator + Jaccard distinctness + invariant-gate) |
| D7 (future) | NEW agent-workspace/memory/decisions/077-bc-8-v0-9-persona-pack-expansion.md | ~200 LOC ADR documenting Q-INT-2026-05-F-prime-1 user opt-in evidence + 3 new personas added |

---

## F. Definition of Done (NO-OP plan-level — minimal)

**PLAN-tier (S383 sandwich-architect THIS session — NO-OP)**:
- [ ] **DC-PLAN-1** — This NO-OP plan file exists at `agent-workspace/session-plans/pending/037-S383-phase-f4-v0-9-expansion.md` (~280 LOC)
- [ ] **DC-PLAN-2** — F.4 NO-OP verdict documented per § A.0 + § B with VBW evidence chain (5 evidence items)
- [ ] **DC-PLAN-3** — 3 explicit revisit triggers named per AP-7 anti-vacuous-defer (Trigger A/B/C per § A.3 + § B)
- [ ] **DC-PLAN-4** — L-S382-1 carry-forward acknowledged per § DD-3 (NOT activated by this NO-OP; preserved by-construction for any future F.4 IMPL)
- [ ] **DC-PLAN-5** — Frontmatter `successor_candidate: 038-S383-phase-f5-cli-dogfood-vhm-thesis` declared (F.5 proceeds regardless per master plan § E.4-5 PARALLEL-ELIGIBLE)
- [ ] **DC-PLAN-6** — VBW protocol followed (all claims cite file:line OR explicitly note NO-OP)
- [ ] **DC-PLAN-7** — Shared observation file at `agent-workspace/memory/observations/sandwich-architect-S383-phase-f4-f5-plans.md` covers both plans (~200 LOC)
- [ ] **DC-PLAN-8** — `0 charter / 0 constitution / 0 human-workspace writes` attestation in observation

**IMPL-tier (NONE — NO-OP; no S384 dev dispatch authorized)**:
- N/A

**VERIFY-tier (NONE — NO-OP; no S385 verifier dispatch authorized)**:
- N/A

**Close-bookkeeping-tier**:
- [ ] **DC-CLOSE-1** — Plan-037 moved `pending/` → `completed/` AT F.5 verifier close (S386) per parallel-eligible bundled-close pattern (DC-BOOK-4 protocol)
- [ ] **DC-CLOSE-2** — Plan-037 status updated to `NO-OP-DEFERRED-completed` in frontmatter
- [ ] **DC-CLOSE-3** — F.5 verifier observation notes plan-037 NO-OP did not affect F.5 IMPL outcome

---

## G. AQ-1 through AQ-3 — minimal Q&A (anticipated questions)

### AQ-1 — Why is F.4 NO-OP and not full sub-plan?

**Answer**: Per master plan-033 DD-2 NON-BLOCKING design + AQ-8: V0=6 is architect-recommended default; V0=9 requires explicit user opt-in via Q-INT-2026-05-F-prime-1; S383 VBW grep returned zero opt-in evidence; therefore default applies; plan-037 = NO-OP. This is the master plan's INTENDED behavior, not a deferral failure.

### AQ-2 — When will F.4 ever ship?

**Answer**: When one of 3 revisit triggers fires (Trigger A/B/C per § A.3 + § B). Until then, V0=6 is sufficient per Karpathy P2 simplicity + Wave 1 MVP scope. Empirical evidence from F.5 dogfood (plan-038 IMPL) is the most likely trigger pathway.

### AQ-3 — Does this NO-OP block Phase F-prime DONE attestation?

**Answer**: NO. Per master plan § E.4-5 PARALLEL-ELIGIBLE sequencing: F.4 + F.5 ship together; F.5 verifier close (S386) marks Phase F-prime DONE → Wave 1 MVP ready. NO-OP F.4 does NOT block F.5; F.5 dogfood validates V0=6 pipeline end-to-end on VHM ticker. Plan-037 mv pending/→completed/ at S386 close per bundled-close pattern.

---

## H. 5-source evidence chain (NO-OP verdict)

1. **Master plan-033 § E.4** (parent plan): `4. Sub-track F.4 — V0 persona-pack expansion + Vietnam-relevance subset selection (target: ratify persona count V0 N=6 vs ≥4 OR fewer per architect recommendation in DD-2)` — F.4 SCOPE is "ratification check"; if no ratification, scope is NO-OP

2. **Master plan-033 DD-2** (`V0 persona count = ratification-gated (architect recommends N=6) — NON-BLOCKING design`): `Architect-recommended default V0=6: BEAR + BULL + QUANT (existing 3 active) + BUFFETT + GRAHAM + TALEB (3 new in F.2). F.4 sub-plan IMPL adds 3 MORE personas (CHARLIE_MUNGER + PETER_LYNCH + VN_DOMAIN_SPECIALIST) ONLY if user RATIFIES V0=6+3=9 expansion path. NON-BLOCKING design: Phase F-prime proceeds with V0=6 by default UNLESS user explicit opt-in to V0=9 via NON-BLOCKING Q-INT-2026-05-F-prime-1`

3. **Master plan-033 AQ-8** (`Sub-plan 037 V0=6 confirmed → F.4 NO-OP — what happens to plan-037?`): `Per DD-2 NON-BLOCKING design. Plan-037 PLAN session writes ≤200 LOC PLAN file documenting V0=6 confirmation + NO-OP rationale + revisit trigger named (project-owner adds 3+ custom personas via direct YAML edit OR explicit re-ratification request); plan-037 marked NO-OP-DEFERRED status; moved to completed/ with brief observation; F.4 budget envelope ~20K not 200K`

4. **Master plan-033 § K.1.a** (`CHARTER-TIER FLAG K.1.a — V0 persona count V0=6 (architect-default) vs V0=9 ratification gate`): `Architect recommends V0=6 (existing 3 active + 3 new in F.2: BUFFETT/GRAHAM/TALEB). Sub-plan 037 F.4 expansion to V0=9 (MUNGER/LYNCH/VN_DOMAIN_SPECIALIST) is GATE-conditional. NON-BLOCKING design: Phase F-prime proceeds with V0=6 default UNLESS user opt-in to V0=9 via Q-INT-2026-05-F-prime-1`

5. **S383 VBW empirical check** (this session): `Glob human-workspace/q-and-a/**/Q-INT-2026-05-F-prime* → zero matches; Grep V0=9|Munger|Lynch|VN_DOMAIN_SPECIALIST in human-workspace/q-and-a → only answered/qa-2026-05-15-wave-1-bis.md (unrelated charter Q&A bundle)`. No user opt-in observed; default applies.

---

## I. Risk Matrix (NO-OP plan-level — minimal)

### RM1 — V0=6 empirically insufficient on dogfood (LIKELY-MEDIUM)

**Risk**: F.5 VHM dogfood reveals V0=6 has measurable persona-coverage gap; users want V0=9 personas (Munger/Lynch/VN_DOMAIN_SPECIALIST) for richer thesis output.

**Mitigation**: Trigger C explicitly named; F.5 dogfood IMPL captures per-persona output quality; if 3+ tickers across post-MVP show gap, main session re-dispatches F.4 PLAN with evidence chain. NON-BLOCKING design preserves option without front-loading work.

### RM2 — User opt-in arrives mid-Phase-F-prime (LIKELY-LOW)

**Risk**: Project-owner issues `/effort high run V0=9 ratification` mid-S384 (F.5 IMPL); F.4 NO-OP status becomes stale.

**Mitigation**: Main session may re-dispatch F.4 PLAN inline (post-F.5 verify close); F.4 PLAN can ship in parallel with F.5 dogfood without blocking; ZERO sequencing dependency. Plan-037 mv pending/→completed/ at S386 includes status-update if needed.

### RM3 — L-S382-1 carry-forward misinterpreted (LIKELY-LOW)

**Risk**: Future F.4 IMPL author misreads L-S382-1 carry-forward as "F.4 needs ctor change" → false discipline fire → wasted ctor-grep cycle.

**Mitigation**: § DD-3 explicitly states L-S382-1 DOES NOT FIRE for F.4 by-construction; future F.4 PLAN MUST reference this DD-3 in its STEP 0 evaluation surface; PURELY ADDITIVE pattern documented in § E sub-track table.

---

## J. Coordination paths (NO-OP plan-level — minimal)

NO-OP plan touches ZERO files in scope; no coordination conflict possible.

**Coordination paths exclusive (if F.4 ever re-opens)**: `packages/infrastructure/analysis/perspectives/{munger,lynch,vn_domain_specialist}_agent.py` (NEW) + `agent-workspace/role-packs/{munger,lynch,vn_domain_specialist}.json` (NEW) + `apps/_shared/use_case_builder.py` (EXTEND lines 179-225 _build_subagent_agents) + `apps/_shared/use_case_builder.py` (EXTEND lines 249-334 _build_mock_agents) + ADR D-077 (NEW path-reserved).

**Coordination paths active THIS session**: NONE (NO-OP).

---

## K. Budget (NO-OP plan-level)

**Authoring envelope THIS session (S383 architect)**: ~20-30K Opus PLAN-only (covers both plan-037 NO-OP + plan-038 full structure per single dispatch).

**Future IMPL envelope (S384 dev — IF F.4 ever re-opened)**: N/A — no dispatch.

**Future VERIFY envelope (S385 verifier — IF F.4 ever re-opened)**: N/A — no dispatch.

**Combined Phase F-prime budget impact of F.4 NO-OP**: Saves ~190-310K Opus per master plan § E budget table row 5 (plan-037 row reads `~190-310K cumulative IF V0=9; ~20K NO-OP IF V0=6`); confirmed NO-OP path → ~20K saved cycle.

---

## L. Phase 1b Calibration (n=3 multi-perspective-plan precedent declared)

**task_class**: multi-perspective-plan (sandwich-architect declaring PLAN authoring for multi-perspective expansion work)

**Phase 1b precedent**: n=3 (per dispatch brief constraint "Phase 1b MANDATORY")

**Precedent observations**:
1. **S375 (F.1 PLAN)** — sandwich-architect Opus authored sub-plan 034 (RolePromptPack + transport-flip); ~150K Opus actual; PLAN authored DD-7 (RolePromptPack dataclass 10 fields) + DD-8 (PersonaRegistry JSON loader fallback); IMPL S375-S376 SHIPPED cleanly
2. **S378 (F.2 PLAN)** — sandwich-architect Opus authored sub-plan 035 (3 personas BUFFETT/GRAHAM/TALEB); ~165K Opus actual; PLAN authored DD-6 (Vietnam-notes content ≥150 chars) + DD-10 (pattern-port NOT code-port + 50+ char grep gate); IMPL S378 SHIPPED cleanly
3. **S380 (F.3 PLAN)** — sandwich-architect Opus authored sub-plan 036 (SynthesizePerspectivesUseCase generalization); ~180K Opus actual; PLAN authored DD-1 (dict[PerspectiveRole, LLMPerspectivePort] dispatch shape) + DD-2 (AC-5 STABLE-SORTED-BY-ROLE); IMPL S381-S382 SHIPPED with M-S381-1 + M-S381-2 inline-remediated (L-S382-1 PROMOTE-NOW)

**S383 (F.4+F.5 combined PLAN) — THIS session**: 4th instance multi-perspective-plan; n=3 precedent SATISFIED; calibration band ~150-230K Opus PLAN per recalibrated CLAUDE.md.

**Empirical confidence**: HIGH — 3 prior plans (F.1+F.2+F.3) all shipped successfully via this PLAN-pattern; only F.3 surfaced ctor-signature-change discipline gap (L-S382-1 PROMOTE-NOW; explicitly carry-forward into F.4+F.5 plans per § DD-3 + plan-038 binding_decisions).

**Phase 1b artifact** (per plan-025 DD-11 mandate): see § L of plan-038 for shared n=3 precedent declaration; THIS plan's Phase 1b is satisfied via shared declaration (both plans authored same session).

---

## M. Phase F-prime DONE contract (NO-OP plan-level reference)

**This NO-OP plan does NOT define Phase F-prime DONE attestation** (that responsibility is in plan-038 § M — F.5 ships the dogfood + verifier close attestation).

**This NO-OP plan's role in Phase F-prime DONE**: completed/ move at S386 close (bundled with F.5 verifier close per § F DC-CLOSE-1).

**Wave 1 MVP gate readiness contribution from this plan**: ZERO production code shipped → ZERO impact on Wave 1 MVP gate; F.5 dogfood ALONE establishes Wave 1 MVP gate readiness.

---

**End of plan-037 (NO-OP DEFERRAL)**.

Approx LOC: ~280 (within ≤300 LOC budget per AQ-8).
