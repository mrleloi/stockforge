---
observation_id: sandwich-architect-S377-phase-f2-plan
agent: sandwich-architect
session: S377
type: PLAN-output
target_session: S378 (sandwich-dev FOCUSED_IMPL ~100-150K Opus)
authored: 2026-05-17
authoring_agent: Claude Opus 4.7 (background; THIS observation per agent-template L207-210 mandate)
status: complete
target_plan: agent-workspace/session-plans/pending/035-S377-phase-f2-personas-buffett-graham-taleb.md
parent_master_plan: agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md § E.2
predecessor: 034-S374-phase-f1-roleprompt-persona-transport (F.1 SHIPPED S375 + verified S376; D-074 ACCEPTED)
---

# S377 Observation — Phase F.2 First 3 Personas Sub-Plan Authoring

## Summary

Authored sub-plan 035 covering Phase F.2 first 3 persona-pack adapters (Buffett + Graham + Taleb) per master plan-033 § E.2. Plan consumes F.1 substrate (D-074 ACCEPTED) and decomposes into 5 sub-tracks (D1 PerspectiveRole enum extension + D2/D3/D4 per-persona adapter classes + D5 JSON content + tests + ADR + README append). 34 DoD items enumerated.

## Plan stats

- **File**: `agent-workspace/session-plans/pending/035-S377-phase-f2-personas-buffett-graham-taleb.md`
- **LOC**: ~1280 LOC (single coherent file; smaller scope than plan-034's 4-file split since F.2 adds 3 persona content without F.1's transport-flip migration complexity)
- **Sub-tracks**: D1 (enum) + D2 (Buffett) + D3 (Graham) + D4 (Taleb) + D5 (JSON+tests+ADR+README) — 5 total per dispatch brief contract
- **DDs**: 11 architecture decisions (DD-1 through DD-11) all with rationale + adversarial alternates
- **DoD items**: 34 distinct (10 file + 2 doc + 8 gate + 6 step0 + 5 book + 4 charter; ≥22 floor per dispatch brief satisfied)
- **AQs**: 10 pre-answered (AQ-1 through AQ-10)
- **RMs**: 10 + 1 carry-forward (RM1-RM10 + RM-AS-2 from F.1)
- **5-source evidence chain**: 5 decisions × 5 sources = 25 citations
- **STOP-AND-ASK triggers**: 5 documented (1 CHARTER-TIER per § M + 4 TACTICAL-TIER per § I)
- **L.1-L.5 conditional next-step branches** per AP-7 anti-vacuous-defer

## Phase 1b Calibration (n=1 narrow precedent)

- **task_class**: `multi-perspective-impl`
- **sample_size**: **n=1** (S375 F.1 IMPL clean cycle) — NARROW PRECEDENT
- **nearest analog**: `vietnamese-nlp-impl` n=3 (S362+S365+S368 all clean cycles ~150-160K Sonnet / ~39min / 0 mistakes each)
- **adjustment**: 100-150K Opus FOCUSED_IMPL per recalibrated CLAUDE.md; +15-25K Opus reserve for per-persona prompt content authoring novelty
- **cold-start verdict**: NO for adapter+test+ADR shape (transfers cleanly from S375 F.1 + S362-365-368 vietnamese-nlp); PARTIAL-COLD-START for per-persona JSON content authoring (sub-component novel); NO for PerspectiveRole enum extension
- **L-S354-2/L-S366-4/L-S369-1 cascade**: planner-stats infrastructure gap persists; manual reading via master plan-033 + sub-plan 034 + current-execution.md + observations substitute path
- **parallel hint**: D2+D3+D4 disjoint file scopes (3 separate `<persona>_agent.py`) — 56% wall reduction potential (62min sequential → 27min parallel)

## Key DD decisions (DD-1 through DD-11)

### DD-1: PerspectiveRole StrEnum extension
- 3 new values: BUFFETT='buffett' + GRAHAM='graham' + TALEB='taleb'
- Chosen over role_id-only routing for type-safety preservation + existing signature consistency
- Rejected mapping to existing MACRO/BEHAVIOR/MANAGER deferred stubs (semantically wrong; future MACRO/BEHAVIOR/MANAGER personas would conflict)

### DD-2: File naming convention
- `<role_id>_agent.py` parallel to existing bear_agent.py / bull_agent.py / quant_agent.py
- Rejected single `personas.py` (file size + merge-conflict surface); rejected subfolder over-engineering

### DD-3: NO shared base class (AP-23 first-instance HOLD)
- 3 personas worth of duplication (~210 LOC × 3 = ~630 LOC; ~60% identical skeleton) acceptable per Karpathy P3
- Promote-to-shared trigger at AP-23 2nd instance (sub-plan 037 V0=9 ratification adding 3+ more personas)

### DD-4: Per-persona category_universe = persona-distinct 6-element tuples
- **Buffett**: MOAT / MANAGEMENT / VALUATION / ROIC / BALANCE_SHEET / GROWTH (6)
- **Graham**: EARNINGS_STABILITY / BALANCE_SHEET_STRENGTH / DIVIDEND_RECORD / MARGIN_OF_SAFETY / NCAV / GRAHAM_NUMBER (6)
- **Taleb**: FRAGILITY / CONVEXITY / SKIN_IN_GAME / TAIL_RISK / VOLATILITY_REGIME / ANTIFRAGILITY (6)
- min_distinct_categories=3 + min_points=3 (mirrors I-S10 floor)

### DD-5: conviction_guidance = Rule 16 mode 1 categorical rubric
- Explicit "do NOT emit numeric percentage" instruction per persona
- A-01 § 3 C9 Buffett 90-100 rubric REJECTED per Rule 16
- Per-persona criteria documented (Buffett moat+ROIC+valuation alignment / Graham margin of safety + current_ratio + earnings consistency / Taleb antifragile + convex + skin)

### DD-6: vietnam_notes = persona-specific VN content (≥150 chars per persona)
- **Buffett**: VinGroup conglomerate moat + Vinamilk consumer brand + MWG retail moat + banking oligopoly moat + HPG steel scale + cross-holding governance caveat
- **Graham**: VN banking NCAV limitations + VN real estate balance-sheet complexity + current ratio threshold relaxation 2.0→1.5 + Graham Number VN-adjusted EPS caveat + dividend record 5y→3y for VN30
- **Taleb**: VN F0 retail-dominated >85% volume + daily price limit ±7% volatility-clamping + 'đội lái' pump-cluster textbook fragility + USD/VND managed peg with one-shot devaluation risk + insider trading disclosure compliance weak

### DD-7: model_id_preference = 'claude-sonnet-4-6' for all 3 personas
- Explicit value (NOT None default) for audit trail benefit
- Value-investor reasoning ≠ Opus-class computational reasoning per master plan-033 DD-12 cost-routing
- QUANT remains only Opus persona

### DD-8: Per-persona retry-validator = MIRROR D-054 BearPerspectiveAgent shape exactly
- `_validate_<persona>_output(raw, role_pack)` reads role_pack for min_points/min_distinct_categories/category_universe (parameterization avoids hardcoding)
- 3-attempt + re-prompt with error + cumulative cost + validation-exhausted WARNING + empty PerspectiveAnalysis on triple-fail (NOT silent)

### DD-9: Test pattern parity
- ≥12 TC per persona mirroring test_bear_agent.py shape
- TC-<persona>-1 through TC-<persona>-13 documented (≥36 NEW TC across 3 personas)
- NEW per-persona check at TC-<persona>-8: category not in role_pack.category_universe → (False, reason)

### DD-10: Pattern-port NOT code-port per A-01 § 6 LICENSE caveat
- ZERO verbatim copy of warren_buffett.py / ben_graham.py / nassim_taleb.py
- DC-GATE-8: grep 50+ char substring match between F.2 JSON content and ai-hedge-fund source returns 0
- 50-char threshold intentionally HIGH (typical English phrase ≤30 chars)

### DD-11: ADR D-075 PROPOSED at IMPL tier
- Records (a) PerspectiveRole enum extension + (b) per-persona file structure + (c) per-persona category_universe + (d) Vietnam-relevance evidence + (e) pattern-port-not-code-port attestation
- 10-item empirical-close-verify suite for verifier S379

## STEP 0 STOP-AND-ASK triggers (5 documented)

### CHARTER-TIER (1 — § M)
- F.2 prompt drafts surface LLM emitting buy/sell/recommendation prose despite I-S35 → STOP-FINDING-S378-0.4-i-s35-buysell-leak-<persona>.md + HALT pending AskUserQuestion

### TACTICAL-TIER (4 — § I)
- § C.0.1 BLOCKING: F.1 substrate regression (D-074 attestation state drift; import anthropic re-introduced; existing tests fail) → STOP-FINDING-S378-0.1-f1-substrate-regression.md
- § C.0.2 CONDITIONAL: Vietnam-relevance weak for any persona → STOP-FINDING-S378-0.2-vietnam-relevance-weak-<persona>.md
- § C.0.3 BLOCKING: RolePromptPack invariant violation during JSON authoring (9 invariants) → STOP-FINDING-S378-0.3-rolepromptpack-invariant-violation-<persona>.md
- § C.0.4 BLOCKING (per dispatch brief explicit): persona vietnam_notes <100 chars OR generic boilerplate → STOP-FINDING-S378-0.4-vietnam-relevance-too-weak-<persona>.md with named options (a) swap persona / (b) accept weak with revisit trigger / (c) defer F.2

## S378 dev budget recommendation

**Projected S378 IMPL envelope**: **115-180K Opus FOCUSED_IMPL** (100-150K cap + 15-30K reserve)

**Breakdown**:
- STEP 0 evaluation: ~10-20K
- D1 enum extension: ~3-5K
- D2 BuffettPerspectiveAgent: ~20-25K
- D3 GrahamPerspectiveAgent: ~20-25K
- D4 TalebPerspectiveAgent: ~25-30K (slight novelty for fragility category mapping)
- D5 JSON content + tests + ADR + README: ~30-40K
- Observation + session log + mistake-log: ~10-15K
- STOP-AND-ASK file (CONDITIONAL): ~5-10K
- Reserve for inline F-fix: ~10-15K

**SPLIT trigger** (per AQ-7): if cumulative tokens >145K at start of D5 → commit D1+D2+D3+D4 + ADR D-075 partial state via D-060; dispatch fresh-context S379-dev for D5; S380 sandwich-verifier AP-1 reviews cumulative.

**Parallel dispatch option** (3-parallel D2+D3+D4 via fresh-context sub-agents):
- ~40K tokens × 3 sub-agents = 120K parallel + ~50K main = ~170K total
- Not preferred over SPLIT (3-parallel introduces AP-23 first-instance for persona-pack dev dispatch; SPLIT proven shape from F.1)
- Sequential D2→D3→D4 with main session orchestrating = ~75K cumulative dev tokens (preferred)

## Vietnam-relevance verdict per 3 personas (per master plan-033 DD-2 evidence chain)

### Buffett — HIGH-relevance V0 ✓
- VinGroup conglomerate moat exposure (VIC + VHM + VRE cross-holding moat fragility tradeoff)
- Vinamilk (VNM) >50y dairy leadership = durable consumer brand value moat
- MWG retail >3000 stores distribution moat
- Banking oligopoly moat (VCB / BID / TCB state-protected)
- HPG steel scale advantage moat
- VinGroup cross-holding = governance fragility caveat (architect-author flags moat tradeoff)
- Circle of competence applicable: avoid speculative small-cap pump stocks

### Graham — HIGH-relevance V0 ✓ (with VN-specific caveats)
- VN banking NCAV applicability LIMITED (banks rarely trade below NCAV; price-to-book floors 1.0x historically)
- VN real estate (Vinhomes / Khang Dien / Novaland) balance-sheet complexity (land bank revaluation + long cash-conversion-cycle)
- Current ratio 2.0 threshold often unmet in VN industrial sector (short-term financing reliance); relax to 1.5 with caveat
- Graham Number requires VN-adjusted EPS (no IFRS earnings smoothing for many VN companies)
- Dividend record < 5y for many VN30 tickers (HSX since 2007); relax to ≥3y for VN30

### Taleb — VERY-HIGH-relevance V0 ✓ (per A-01 § 3 C13 + A-14 retail-culture cite)
- VN F0 retail-dominated >85% volume per HOSE = high-tail-risk regime
- Daily price limit ±7% (UPCoM ±15%) volatility-clamping but masks true tail risk
- 'Đội lái' pump-cluster phenomenon (VC1/SHB historical pumps) = textbook fragility / fat-tail surface
- USD/VND managed peg ±5% per SBV → low historical vol BUT one-shot devaluation risk (1997 Asian crisis / 2008-2011 progressive devaluation precedent) = classic Taleb 'turkey problem'
- Insider trading disclosure compliance weaker than developed markets = skin-in-the-game signal less reliable; weight insider trades with VN cynicism
- VN macro convexity = export-led growth vulnerable to USD strength / China slowdown / trade-war asymmetry

**Vietnam-relevance verdict consensus**: All 3 personas have substantive Vietnam application; ≥150 char vietnam_notes per persona is achievable empirically; STOP-AND-ASK trigger per § C.0.4 + § I (4) is INSURANCE not expected-fire.

## Hard rules compliance (this PLAN session)

- 0 charter writes ✓ (PROJECT_CHARTER.md untouched)
- 0 constitution writes ✓ (agent-workspace/constitution/** untouched)
- 0 human-workspace writes ✓ (plan output to agent-workspace/session-plans/pending/ only; observation to agent-workspace/memory/observations/ only)
- 0 production code ✓ (architect PLAN-only per agent-template L21)
- AP-1 ✓ (fresh-context dispatch)
- VBW protocol ✓ (~22 files read empirically; key 10 highlighted in plan § A.4)
- I-S2 ✓ (every plan claim cites source file:line; 5-source-evidence chain populated)
- ai-hedge-fund LICENSE-file caveat A-01 § 6 ACKNOWLEDGED per DD-10 pattern-port not code-port

## Commits expected (per D-060)

- 1 commit by main session: plan-035 file + this observation file (architect has no Bash; main commits architect's output per D-060 + pre-dispatch-architect-commit-guard.sh hook validation)
- 0 commits by architect (architect tools: [Read, Glob, Grep, Write] only)
- 0 pushes by anyone (push is human-only per D-060)

## Next-turn action recommendation

Main session:
1. Commit plan-035 + this observation file with concise message
2. Dispatch S378 sandwich-dev FOCUSED_IMPL fresh-context with this plan as input + budget 100-150K Opus + S378-dispatch-brief.md or equivalent
3. Wait for S378 return → branch per § L conditional paths (L.1 PASS / L.2 PASS-WITH-CONCERNS / L.3 BLOCKED / L.4 FAILED / L.5 SPLIT)

If main session prefers parallel architect-tier work: dispatch sub-plan 036 PLAN authoring (F.3 N-perspective use case extension) PARALLEL with S378 dev IMPL post-S378 commit per master plan-033 § N.2 sequencing — but plan-036 blocks_on plan-035 ship + verify (S379 PASS) so sequential is safer.

## Risks flagged

- **AP-23 first-instance HOLD on shared-base-class** — DD-3 explicit; sub-plan 037 V0=9 ratification triggers 2nd-instance promote-to-shared calculus
- **Pattern-port substring match verification** — DC-GATE-8 grep threshold 50+ char; may flag common-domain-vocabulary phrases (architect mitigates via ADR D-075 documenting common phrases)
- **Per-persona retry-validator empty-output flood** — D-054 BEAR has shipped stably ~6 months; empirical fail rate ~5-15% per attempt; cumulative ~0.1-0.4% triple-fail per persona acceptable
- **Vietnam-relevance content drift over time** — V0 ships static; RM10 named AP-7 revisit trigger (Phase F-prime-V2 / quarterly refresh / project-owner-driven update)
- **D-052 § Implementation step 3 carry-forward** — RM-AS-2 inherited from F.1; verifier S379 acknowledges as known-deferred

---

**END OF S377 OBSERVATION**

> Architect output: plan-035 (`agent-workspace/session-plans/pending/035-S377-phase-f2-personas-buffett-graham-taleb.md`) + this observation file (`agent-workspace/memory/observations/sandwich-architect-S377-phase-f2-plan.md`).
> Main session next-step: commit + dispatch S378 sandwich-dev FOCUSED_IMPL.
