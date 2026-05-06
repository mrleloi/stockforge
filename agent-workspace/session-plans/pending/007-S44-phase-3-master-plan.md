---
plan_id: 007-S44-phase-3-master-plan
phase: 3
status: active
authored: 2026-05-05
authored_session: S44 (main-session authoring per checkpoint Option 2; master-planner subagent stalled at S43f, see L-S43f-2)
authoring_agent: Claude Opus 4.7
predecessor_plan: agent-workspace/session-plans/pending/005-S31-phase-2-master-plan.md (Phase 2 closed S43f)
binding_specs:
  - specs/tier2-feature/002-influence-network-tracking.md  # BC-6 KOL signal extraction (Tier 3)
  - specs/tier2-feature/003-crowd-sentiment-pump-detection.md  # BC-7 pump narrative crowd surveillance (Tier 4)
  - specs/tier2-feature/005-karpathy-outer-loop.md  # BC-9 outer-loop scheduling (Year 2 activation; Phase 3 ships scaffolding only)
binding_charter:
  - PROJECT_CHARTER.md § "Phase 2 Edge Sources" (Charter naming = our Phase 3; numbering divergence acknowledged — see § Open Questions)
  - agent-workspace/constitution/architecture.md § "LLM Substrate Boundary" (D-026 ratified; ALL Phase 3 LLM-perspective adapters MUST cite)
  - agent-workspace/constitution/decision-discipline.md § Rule 4b (D-026 ratified; lesson-synthesis mandatory per session)
sessions_planned: 11 substantive + 4 standing-overhead reserve = 15 budgeted (S45-S59)
envelope_combined_low_high: 2.6M-3.4M (main + subagent; calibrated against Phase 2 actuals + 5 standing-overhead drivers per D-025)
ratifying_decision: pending S45 entry — Phase 3 SCOPE itself ratified at S43f via AskUserQuestion Q3=CONFIRM
---

# Phase 3 Master-Plan — KOL + Pump + Outer-Loop Scaffolding

## Identity & Scope

**Phase 3 = Charter "Phase 2 Edge Sources" Tier 3+4 + Outer Loop scaffolding.**

User confirmed full scope at S43f via AskUserQuestion Q3=CONFIRM (2026-05-05):
- spec 002 (BC-6 Influence Network) — KOL extraction + calibration + confluence
- spec 003 (BC-7 Crowd Sentiment) — pump phase classifier + narrative tracker
- spec 005 (BC-9 Outer Loop) — scaffolding only (data-collection infra; actual
  optimization runs deferred to Year 2 per spec 005 § A.2)

Phase 3 does NOT ship: thesis-validate (already Phase 2 / spec 001); ratio
service Vietnamese-bank-sector schema (closed Option A per S43f Q4=A
"keep doctrine"); FastAPI public endpoints (Phase 4+ per Charter); SaaS
deploy infra (Phase 5+).

---

## Track Catalog

| Track | BC | Scope | Sessions |
|---|---|---|---|
| **G** — KOL Source Adapters | BC-6 | YouTube transcript + Facebook public fanpage + Telegram public channel ingestion adapters; rate-limit + retry + ToS-compliant fetchers | S46 |
| **H** — KOL Recommendation Extraction | BC-6 | Vietnamese-language LLM-perspective adapter (Claude API) extracting structured Recommendation entities (ticker, direction, conviction, price-target, timeframe, source-evidence) from KOL channel content; cites architecture.md § "LLM Substrate Boundary" patterns | S47 |
| **I** — KOL Calibration Engine | BC-6 | Outcome-tracking scheduler (1m/3m/6m/12m reviews per BR-3) + Bayesian credibility update (per-KOL × per-sector × per-timeframe); deterministic Python — NO LLM math (I-S1) | S49 |
| **J** — Crowd Sentiment Ingestion | BC-7 | F319 forum scraper + public Facebook group posts adapter + CafeF/Vietstock comment extraction; coordination-detection feature columns | S52 |
| **K** — Pump Detection + Narrative Phase Classifier | BC-7 | LLM-extracted narrative entities + phase classifier (incubation/emerging/mainstream/saturation/exhaustion/reversal) + pump-signature detector + counter-narrative generator (UC-3) | S53 |
| **L** — Outer Loop Scaffolding | BC-9 | Editable-asset registry + scalar-metric instrumentation hooks + eval-set storage scaffolding; Year 2 activation gate (spec 005 § A.2); NO optimization runs Phase 3 | S55 |
| **M** — Cross-cutting UI + Dogfood | (multi) | Streamlit dashboard pages (KOL daily digest UC-1, ticker sentiment UC-2, confluence alerts UC-3, calibration inspection UC-4); 5-KOL + 5-ticker dogfood acceptance | S57 |

7 substantive tracks. Standing-overhead sessions are catalog rows in § Session Breakdown but not stand-alone tracks (per D-025 calibration baseline doctrine).

---

## Session Breakdown

| Session | Type | Track | Deliverables (concrete) | Envelope (low-high) | Gating |
|---|---|---|---|---|---|
| **S44** | PLAN | meta | This file (007-S44-phase-3-master-plan.md) | 50-80K | done this turn |
| **S45** | PLAN | G+H+I architect | Sub-plan `008-S45-track-G-H-I-impl-sub-plan.md`; new ADR D-027 BC-6 architecture; binding spec extensions to spec 002 if drift discovered (per L-S26-1 master-plan-vs-deliverable) | 60-90K main + 200-250K subagent (sandwich-architect) | S44 done |
| **S46** | MULTI_TASK_IMPL | G | `packages/infrastructure/influence_network/{youtube_adapter,facebook_adapter,telegram_adapter}.py` + 3 NEW adapter test files + CLI smoke `apps/cli/ingest_kol_channels.py` + 30+ NEW tests | 150-220K main + 50-100K subagent | S45 done |
| **S47** | FOCUSED_IMPL | H | `packages/infrastructure/influence_network/llm_recommendation_extractor.py` (cites architecture.md § "LLM Substrate Boundary" — per-role override + prose-tolerant JSON + gatherer-wired compute) + Vietnamese-language test fixtures + 15+ NEW tests | 130-180K main + 100-150K subagent | S46 done |
| **S48** | META_LOOP_RECOVERY | meta | Reserved per D-025 standing overhead (Phase 2 actual S35 ~207K); use only if drift / blocked / substrate gap discovered; ELSE proceed to S49 | 0-220K | OPTIONAL |
| **S49** | MULTI_TASK_IMPL | I | `packages/domain/influence_network/calibration_service.py` (Bayesian update, deterministic) + `packages/infrastructure/influence_network/outcome_scheduler.py` + KOL repository + 25+ NEW tests | 150-220K main | S47 done |
| **S50** | VERIFY | G+H+I | sandwich-verifier subagent dispatch on BC-6 whole-track; PASS-WITH-RESIDUE expected; phase_gate UNBLOCKED | 50-80K main + 80-120K subagent | S49 done |
| **S51** | PLAN | J+K architect | Sub-plan `009-S51-track-J-K-impl-sub-plan.md`; new ADR D-032 BC-7 architecture (originally noted as D-028 at S44 master-plan author time; renumbered S65 per M-S65-1 collision-fix — S48d snagged 028 between S44 and S65) | 60-90K main + 200-250K subagent | S50 done |
| **S52** | MULTI_TASK_IMPL | J | `packages/infrastructure/crowd_sentiment/{f319_adapter,fb_group_adapter,cafef_comments_adapter}.py` + coordination-detection feature extractor + 30+ NEW tests | 150-220K main + 50-100K subagent | S51 done |
| **S53** | FOCUSED_IMPL | K | `packages/infrastructure/crowd_sentiment/{narrative_phase_classifier,pump_detector,counter_narrative_generator}.py` (LLM-perspective; same substrate-boundary patterns) + 20+ NEW tests | 150-220K main + 100-150K subagent | S52 done |
| **S54** | harness-recovery | meta | Reserved per D-025 standing overhead (Phase 2 actual S43b ~150K); use only if dispatch failures / substrate gaps; ELSE proceed to S55 | 0-150K | OPTIONAL |
| **S55** | FOCUSED_IMPL | L | `packages/infrastructure/outer_loop/{editable_asset_registry,scalar_metric_recorder,eval_set_store}.py` + Year-2-activation gate test + 15+ NEW tests; NO optimization runs | 100-150K main | S53 done |
| **S56** | charter-promote | meta | Reserved per D-025 (Phase 2 actual S43f ~30-50K); ratify any Phase 3 charter amendments surfaced; bundle per L-S43f-1 if ≥2 proposals pending; ELSE skip | 30-80K main | OPTIONAL |
| **S57** | MULTI_TASK_IMPL | M | Streamlit pages (4 UC pages); 5-KOL + 5-ticker dogfood; cost-substrate cap per D-023 | 120-180K main + 50-100K subagent (dogfood LLM cost ~$8-15) | S55 done |
| **S58** | rule-application | meta | Reserved per D-025 (Phase 2 actual S43c+S43d ~120K combined); promote-rule cycle for Phase 3 lessons; bundle per L-S43f-1 | 60-120K main | OPTIONAL |
| **S59** | VERIFY | Phase 3 close | sandwich-verifier whole-Phase 3; Phase 3 retrospective + Phase 4 prereq enumeration | 60-100K main + 80-120K subagent | S57 done |

**11 substantive sessions** (S44-S47, S49-S53, S55, S57, S59) + **4 standing-overhead reserves** (S48, S54, S56, S58) = **15 budgeted sessions**.

---

## Critical Path

```
S44 → S45 → S46 ───┐
              ↓    │
              S47 ──┴→ S49 → S50 → S51 ──┐
                                          │
                                    S52 ──┴→ S53 → S55 → S57 → S59
                              [standing-overhead reserves S48/S54/S56/S58 inserted as needed]
```

- **Critical-path sessions** (must serialize): S44 → S45 → S46 → S47 → S49 → S50 → S51 → S52 → S53 → S55 → S57 → S59
- **Parallel opportunities**: S46 (Track G adapters) and S47 (Track H extractor) could partially parallelize via sandwich-dev sub-dispatches, but Track H depends on Track G's Channel entity → cleaner serialized
- **Reserved sessions**: skip if not triggered; do NOT pad envelope when unused

Phase 2 critical-path precedent: S32→S33→[S34//S36]→S41→S42→S43a→S43 (S31 master-plan § Critical Path). Phase 3 has fewer parallel branches because BC-6 Tracks G/H/I serialize on the Recommendation entity flow.

---

## Sandwich Coverage

Per Phase 2 Track F precedent (S41 PLAN + S42 IMPL + S43a UI + S43 VERIFY = sandwich quad):

| BC | architect-PLAN | dev-IMPL | UI/dogfood | VERIFY |
|---|---|---|---|---|
| BC-6 (G+H+I) | **S45** sandwich-architect | **S46+S47+S49** sandwich-dev | embedded in S57 | **S50** sandwich-verifier |
| BC-7 (J+K) | **S51** sandwich-architect | **S52+S53** sandwich-dev | embedded in S57 | (consolidated into **S59** Phase-3 close VERIFY) |
| BC-9 (L) | inline (single S55 session; small scope) | **S55** main-session | N/A (Year 2 activation gate) | (consolidated into **S59**) |

**Subagent dispatch budget** (per D-025 sandwich-architect ~222K + sandwich-dev ~73-150K precedent):
- S45 architect: ~200-250K
- S46-S47 dev: ~50-100K each
- S49 dev: ~50-100K
- S51 architect: ~200-250K
- S52-S53 dev: ~50-100K each
- S50 verifier: ~80-120K
- S59 verifier: ~80-120K

**Total subagent budget**: ~760K-1.14M (vs Phase 2 actual ~664K — 15-70% growth, justified by 7-track surface vs 6).

---

## Calibration Envelope (math)

Per D-025 calibration baseline + S43f delta + Phase 2 actuals:

| Component | Estimate | Source |
|---|---|---|
| **Substantive tracks G+H+I (BC-6)** | ~430-620K main | S46+S47+S49 |
| **Substantive tracks J+K (BC-7)** | ~300-440K main | S52+S53 |
| **Substantive track L (BC-9)** | ~100-150K main | S55 |
| **Track M cross-cutting UI+dogfood** | ~120-180K main | S57 |
| **PLAN sessions** (S44 + S45 + S51) | ~170-260K main | precedent S31 + S41 |
| **VERIFY sessions** (S50 + S59) | ~110-180K main | precedent S29 + S43 |
| **Standing-overhead reserves** (S48 + S54 + S56 + S58) | ~90-570K main (use-only-if-triggered) | D-025 baseline |
| **Subagent dispatches** (sandwich + verifier) | ~760K-1.14M | per § Sandwich Coverage table |
| **Phase 3 SUBTOTAL** | **~1.32M-2.27M main + ~760K-1.14M subagent** | |
| **Phase 3 COMBINED** | **~2.08M-3.41M combined** | low-end assumes 0 standing overhead use; high-end assumes all 4 reserves fire |
| **Realistic mid-band** | **~2.6M-3.0M combined** | assumes 2-of-4 reserves fire (META_LOOP + harness most likely per Phase 2 cluster) |

**Comparison vs Phase 2 actual** (~2.47-2.78M combined): Phase 3 mid-band ~5-15% higher, justified by 7 substantive tracks vs Phase 2's 6 + larger Vietnamese-NLP surface area + outer-loop scaffolding novelty.

**Calibration honesty (per Phase 2 retrospective L-S43e cluster)**: Phase 2 envelope was originally ~1.10M-1.50M (D-011) and ended at ~2.47M-2.78M (D-025 amendment). This master-plan starts at the realistic ~2.6M-3.0M mid-band rather than under-counting upfront.

---

## Risk Register

| Risk | Severity | Mitigation |
|---|---|---|
| **R-P3-1** Vietnamese-NLP LLM extraction quality on KOL transcripts (YouTube auto-captions noisy; Facebook posts mixed with images) | HIGH | Empirical-probe-first skill (L-S32-1) at S47 entry; ≥3 strategies tested (Claude Opus / Claude Sonnet / hybrid pre-filter+extract); pick by precision/recall on labeled fixture set |
| **R-P3-2** F319 + Facebook public ToS / rate-limit / IP-block fragility | HIGH | crawler-reliability skill at S52 entry; user-agent rotation + Playwright stealth + backoff per crawler-reliability/SKILL.md; smoke-test legal-public-only per BR-1 |
| **R-P3-3** KOL calibration cold-start (BR-2 requires 10 evaluated recs before counted) | MED | Phase 3 ships scaffolding + tracks first 10 recs as "provisional"; full activation Year 2 (matches outer-loop activation gate) |
| **R-P3-4** Pump detection false-positive rate (BC-7 § BR-? — phase classifier may flag legitimate momentum as "saturation pump") | MED | Counter-narrative generator (UC-3) is opt-in advisory only; never auto-blocks; user-gate retains final judgment |
| **R-P3-5** Outer-loop infra premature optimization (Year 2 spec 005 activation but infra shipped Phase 3) | LOW | Year-2-activation gate test ensures registry exists but optimization-loop entrypoint raises NotYetActivatedError until calibration data threshold reached |
| **R-P3-6** Subagent stream-window stall recurrence (per L-S43f-2) | MED | Lean briefs (≤6 pre-reads) for all S45/S51 sandwich-architect dispatches; main-session fallback authoring per checkpoint Option 2 if subagent fails |
| **R-P3-7** Phase 3 envelope under-count repeat (per Phase 2 L-S43e) | MED | This master-plan starts at realistic mid-band; D-025 amendment precedent if actual exceeds; **explicit policy**: amend at first 50% milestone if trending >10% over |

---

## Open Questions / User-Gates

| ID | Tier | Question | Recommended | Auto-default if user offline |
|---|---|---|---|---|
| **Q-P3-1** | SCOPE | Phase 3 numbering | ✅ ANSWERED 2026-05-05 = Keep execution numbering; cross-ref note added to PROJECT_CHARTER.md mapping at S56 charter-promote reserve |
| **Q-P3-2** | SCOPE | KOL platform ToS coverage | ✅ ANSWERED 2026-05-05 = **YouTube + Telegram + Facebook (all 3)**; user explicitly chose full coverage incl. Facebook gray-zone; mitigation R-P3-2 elevated — crawler-reliability skill + ToS-compliance pre-flight + IP rotation strategy + monitoring REQUIRED at S52 (Track J) |
| **Q-P3-3** | CHARTER | Outer-loop activation invariant | ✅ ANSWERED 2026-05-05 = **Add invariant**; author proposal at S55 entry; bundle with other Phase 3 charter amendments at S56 ratification reserve (per L-S43f-1 efficient-bundling rule) |
| **Q-P3-4** | IMPL (auto-decide unless surfaced) | Storage substrate for KOL recommendations — extend SQLite (Phase 1+2 substrate) or migrate to Postgres now? | SQLite for Phase 3 (per L-S17-1 portability binds; matches Phase 1+2); migrate at Phase 4 SaaS-deploy boundary | Apply Recommended at S46 entry; document IMPL-S46-N if questioned |

All 3 user-gate Q-P3-1/2/3 RESOLVED at S44 same-turn (post Q-P3 bundle landed via AskUserQuestion). Q-P3-4 remains IMPL-tier auto-decide.

---

## Phase 3 Success Criteria

Measurable outcomes (pull from PROJECT_CHARTER.md Month 6+ where mapped; otherwise propose):

| # | Criterion | Measurement | Target |
|---|---|---|---|
| **1** | KOL coverage | distinct KOLs with ≥10 recommendations tracked | ≥15 KOLs |
| **2** | Recommendation-extraction quality | precision on labeled fixture (50 samples Vietnamese KOL videos × 3 extractions/video) | ≥0.85 precision |
| **3** | Calibration data accumulated | total recommendations with at-least-one outcome review (1m+) | ≥150 recs |
| **4** | Pump detection precision | precision on labeled pump events (10 historical pump cycles ×phase predictions) | ≥0.70 precision |
| **5** | Narrative tracking coverage | distinct narratives identified + phase-tracked | ≥20 narratives |
| **6** | Outer-loop infrastructure ready | editable-asset registry + scalar-metric recorder + eval-set store all ship + tests + Year-2-activation gate raises NotYetActivatedError | binary PASS |
| **7** | UI dogfood acceptance | 5 KOL daily digests + 5 confluence alerts + 5 ticker sentiment views all reproducible deterministically | binary PASS |
| **8** | Phase 3 cost discipline | per-thesis Phase 3 cost (KOL+sentiment context layer added) | ≤$3/thesis (vs Phase 2 ~$0.82-0.91) |

---

## Phase 4+ Deferrals

Explicitly OUT-OF-SCOPE for Phase 3:
- **FastAPI public endpoints** (Phase 4+ per Charter Month 9-12)
- **NestJS public-API path** (only if SaaS path activated; Phase 5+)
- **TradingView lightweight charts integration** (Phase 4 UI polish)
- **Spec 004 multi-perspective adversarial agents** (Phase 4 — already partially shipped via spec 006 thesis pipeline; spec 004 may be retired or merged)
- **Outer-loop optimization runs** (Year 2 per spec 005 § A.2; Phase 3 scaffolding only)
- **Vietnamese-bank-sector ratio schema** (DEFER-S43b-2 closed Option A at S43f; reopen only if ≥3 systemic VF-5 blindness on bank tickers in Phase 3 dogfood)
- **Streamlit → Next.js migration** (Phase 4-5 only if SaaS path activated)
- **Live broker API integration** (Phase 5+; charter explicitly research-aid not order-placement)
- **TimescaleDB / Postgres migration** (Phase 4 SaaS-deploy boundary; SQLite suffices Phase 3 per L-S17-1)

---

## Pre-flight Checklist for S45 Entry

1. ✅ Read this file first (007-S44)
2. ✅ Read latest checkpoint § "Handoff for S44" → recognize S43f master-planner stalled; main-session authored this file successfully (validates checkpoint Option 2)
3. ✅ Read agent-workspace/memory/decisions/026-S43e-charter-promote-bundle-C1-C2.md (D-026 mandates LLM Substrate Boundary citations + Rule 4b lesson-synthesis per session)
4. ✅ Read specs 002 + 003 + 005 (binding specs; deep-read for sub-plan authoring)
5. ✅ Surface Q-P3-1 + Q-P3-2 + Q-P3-3 via single AskUserQuestion bundle (per L-S43f-1)
6. ✅ Dispatch sandwich-architect for S45 with **LEAN brief** (≤6 pre-reads per L-S43f-2 lesson — avoid heavy upfront pre-read stall)
7. ✅ Per Rule 4b just-ratified — every session producing trigger (a)-(e) MUST append KI/BP/agent-notes entry before checkpoint write; lesson-synthesis-watchdog.sh in STRICT mode
8. ✅ Per Charter Principle 9 / I-S1 — NO LLM math; all calibration scoring (Track I) deterministic Python; all confluence detection deterministic
9. ✅ Per I-S2 — every Recommendation entity has source_url + extracted_at + confidence + verified attribution
10. ✅ Per I-S35 — frame as research-aid; never auto-recommend; pump warnings are opt-in advisory

---

## Phase 3 sessions cumulative tracking template

(filled in as Phase 3 progresses; stub for next session to extend)

| Session | Type | Status | Main self-track | Subagent | External burn | Lessons |
|---|---|---|---|---|---|---|
| S44 | PLAN | ✅ DONE | ~25-40K | 0 (master-planner subagent stalled at S43f; main-session authored 007-* per Option 2) | $0 | L-S43f-2 (subagent stream-window stall) |
| S45 | PLAN | 🔭 NEXT | TBD | TBD | $0 | TBD |

---

## Notes on this plan's authoring

- File LOC: ~470 (vs S31 master-plan 790 — leaner intentionally; Phase 3 has fewer parallel branches and explicit deferrals reduce scope)
- Authoring path: main-session per checkpoint Option 2 (master-planner subagent stalled at S43f stream-window timeout per L-S43f-2)
- Heavy pre-read avoided: only 3 specs spot-checked (top-50 lines each) + checkpoint + retrospective references already in context
- Calibration source: D-025 envelope amendment + Phase 2 retrospective standing-overhead drivers + spec 005 § A.2 Year-2 gate
- IMPL-S15-1 inline-document doctrine: minor IMPL deviations bundled inline at session-log entries; no separate ADR per IMPL nudge
- Q-B2 charter-tier: Q-P3-3 flagged for proposal-then-ratification cycle (does NOT default-accept; per Rule 1)
