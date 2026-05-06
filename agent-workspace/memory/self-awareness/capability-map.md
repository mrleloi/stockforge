---
created_at: 2026-05-05 (S48k — HH-F.3 capability-map populate)
purpose: task_class × model × effort recommendation matrix sourced from sync-tracker categories + 6 profile cards + 153-row events.tsv corpus
source_data:
  state_tsv: agent-workspace/memory/sync-tracker/state.tsv (5 categories, post-S48j ETL)
  events_tsv: agent-workspace/memory/sync-tracker/events.tsv (153 rows, S48j ETL bootstrap)
  profile_cards: agent-workspace/memory/self-awareness/profiles/{opus47-max-FOCUSED_IMPL,opus47-max-PLAN,opus47-max-MULTI_TASK_IMPL,opus47-max-VERIFY,sonnet46-max-FOCUSED_IMPL,haiku45-max-FOCUSED_IMPL}.md
  category_schema: agent-workspace/memory/decisions/002-track-8-confidence-score.md § Track 8 § Categories
schema_source: agent-workspace/memory/self-awareness/profile-template.md § 3
charter_principle: 8 (Calibration over confidence) + 9 (No LLM math; hit rate from empirical sources only)
status: SEEDED — populated from S48j ETL data; auto-update when new profile cards or sync-tracker categories surface
---

# Capability Map — task_class × model × effort routing

> **Use this file as a lookup, not a rulebook.** Profile cards (§ profiles/) are the empirical source-of-truth; this map distills them into routing recommendations.
>
> All confidence numbers cited here come from the source artifacts (state.tsv tier scores, profile cards' § 5 Calibration). NO LLM-generated metrics per Charter Principle 9.

## 1. Source data snapshot (as of S48k 2026-05-05)

**Sync-tracker categories** (state.tsv post-S48j ETL):

| category | samples | score | tier | drift signal |
|---|---|---|---|---|
| LANGUAGE | 31 | 51.4 | MED | 5 LLM-side language slips (M-S35-1/M-S35-5/M-S45-2/M-S47-1/M-S48e-1); offset by 5 charter promotions (D-026/D-028/D-030/D-031 + 2 watchdog regex extends) |
| DOMAIN_UBIQUITOUS | 32 | 56.7 | MED | highest score; charter-rich (DDD glossary + 9 BCs + Tier 1+2+3 architecture) |
| DESIGN_THINKING | 30 | 54.8 | MED | architectural patterns + hooks; ~58% Q&A-resolution events |
| SCOPE | 30 | 50.7 | MED | must_grill_remaining=2 (D-test-revoked smoke residue); 5 phase-boundary events |
| DECISION_ROUTING | 30 | 49.5 | MED-LOW | M-S45-1 substrate-loss correction (-2.0) drags score; otherwise on-trajectory |

**Profile cards** (6 total; status reflects sample-size-vs-floor):

| (model × effort × task_class) | samples | status |
|---|---|---|
| opus47-max × FOCUSED_IMPL | 12 | STABLE (S26/S28/S30/S32/S35/S47/S48b/S48c/S48d/S48f/S48g/S48h) |
| opus47-max × PLAN | 6 | STABLE (S15/S24/S31/S44/S48a/S48e) |
| opus47-max × MULTI_TASK_IMPL | 4 | STABLE (S20/S27/S33/S34) |
| opus47-max × VERIFY | unknown | INSUFFICIENT (no S48 sessions; phase-boundary VERIFY deferred Phase 2.5 close) |
| sonnet46-max × FOCUSED_IMPL | 2 | DRAFT-INSUFFICIENT (sandwich-dev S46+S47; promotes STABLE +1) |
| haiku45-max × FOCUSED_IMPL | 1 | DRAFT-INSUFFICIENT (Track-H probe S47; promotes STABLE +2) |

## 2. Sync-tracker category → task_class taxonomy

| sync-tracker category | task families this category measures confidence for | profile-card linkage |
|---|---|---|
| LANGUAGE | prompt authoring; regex/keyword extension; charter-language amendments; Mode-E watchdog tuning | opus47-max-FOCUSED_IMPL § 1 (charter-promotion authoring) + § 4 (M-S45-2/M-S47-1 Mode-E recurrence) |
| DOMAIN_UBIQUITOUS | DDD BC architecture; ubiquitous-language glossary; BC contract authoring; cross-BC adapter design | opus47-max-MULTI_TASK_IMPL § 1 (BC-1+BC-9 / VN30 / BC-2 ships) + sonnet46-max § 1 (BC-6 sandwich-dev) |
| DESIGN_THINKING | architectural patterns; hook authoring; skill design; deterministic-substrate doctrine | opus47-max-FOCUSED_IMPL § 1 (Phase 2.5 hook authoring cluster S48b/c/d/g/h) + opus47-max-PLAN § 1 (master-plan dependency graphs) |
| SCOPE | master-plan authoring; phase-boundary decisions; charter-tier vs SCOPE-tier vs IMPL-tier classification; envelope estimation | opus47-max-PLAN § 1 (5/5 master-plan ratification rate) + § 5 Calibration (envelope vs actual) |
| DECISION_ROUTING | grill-vs-auto-decide; tier classification; AskUserQuestion bundling; sync-state.md confirmed-vs-open routing | opus47-max-FOCUSED_IMPL § 1 (bundled deny-lift cycles) + opus47-max-PLAN § 4 (M-S45-1 sandwich-architect substrate-loss = downstream of DECISION_ROUTING gap) |

## 3. Recommendation matrix (which profile to invoke per task family)

> Reading guide: row = task family, columns = which (model × effort × task_class) profile to activate. Empty cell means insufficient data — do NOT route there blindly.

| task family | PRIMARY route | SECONDARY (when PRIMARY busy/exhausted) | AVOID |
|---|---|---|---|
| Charter-tier amendments + ratification (CHARTER) | opus47-max × FOCUSED_IMPL (proposals/<file>.md author + AskUserQuestion gate + deny-lift cycle + D-NNN ADR) | opus47-max × PLAN (proposal-only; defer ratification to next FOCUSED_IMPL) | sonnet46-max (Charter Principle 3 adversarial requires fresh-context Opus); haiku45-max (output structure too thin for 12-field ADR schema) |
| SCOPE-tier master-plan (multi-session decomposition) | opus47-max × PLAN (subagent dispatch via master-planner ~150-200K) | opus47-max × PLAN main-session author when subagent stalls (S44 fallback after L-S43f-2 stream-window timeout) | MULTI_TASK_IMPL (overhead too high for plan-only); sonnet46-max (no SCOPE-tier samples) |
| ARCH-tier IMPL (cross-BC contract authoring + new entity ship) | opus47-max × MULTI_TASK_IMPL (4-10 tasks at 150-250K; S27 BC-1+BC-9 / S33 VN30 / S34 BC-2 all 4/4 deliverables 100% test-PASS) | opus47-max × FOCUSED_IMPL (1-3 tasks at 100-150K when scope tighter) | VERIFY (insufficient data; phase-boundary deferred) |
| IMPL-tier sandwich-dev dispatch (test-first IMPL ≤30 NEW files + ≤80 NEW tests) | sonnet46-max × FOCUSED_IMPL (S46 BC-6 Track G 14 NEW + 67 tests; S47 Track H 23 NEW + 21 NEW = 44 tests) | opus47-max × FOCUSED_IMPL when surface ≤20 files + sub-agent budget tight | haiku45-max (reasoning-heavy IMPL not validated) |
| IMPL-tier prefilter / classification (LLM pipeline preprocessing) | haiku45-max × FOCUSED_IMPL (S47 Track-H S3 winner: precision=1.0, recall=0.889, ~$0.027/fixture, ~6× cheaper than Sonnet full pipeline) | sonnet46-max × FOCUSED_IMPL when precision-floor critical | opus47-max (cost-prohibitive for high-volume prefilter) |
| Hook authoring + smoke testing (single-track in FOCUSED_IMPL) | opus47-max × FOCUSED_IMPL (Phase 2.5 cluster: S48b/c/d/g/h shipped 8 wired hooks ~70-155 LOC each + smoke 100% GREEN) | opus47-max × MULTI_TASK_IMPL when ≥3 hooks shipped per session (M-S48d-1 pipefail-bracket trap warning) | sonnet46-max (no hook-authoring samples) |
| Sandwich-architect (PLAN-tier subagent for ARCH design) | opus47-max × PLAN via subagent dispatch | main-session author at S44 fallback pattern when subagent stalls (cost-equivalent ~80K main vs 220K subagent burn) | sandwich-architect Write tool authority (M-S45-1 substrate-loss; mechanical guard `write-vs-edit-guard.sh` shipped) |
| Sandwich-verifier (fresh-context adversarial review) | OPEN — no S48 verifier samples; defer to Phase 2.5 close VERIFY session | provisional opus47-max × VERIFY at <60K budget per CLAUDE.md table | same agent that wrote IMPL (AP-1 echo chamber) |
| META_LOOP_RECOVERY (cleanup after multi-session drift) | opus47-max × FOCUSED_IMPL with META_LOOP_RECOVERY tag (S35 prototype) | opus47-max × MULTI_TASK_IMPL when cleanup spans >3 subsystems | sonnet46-max + haiku45-max (no recovery-mode samples) |
| Q&A bundling + AskUserQuestion gate authoring | opus47-max × FOCUSED_IMPL (multi-Q bundle composition + grill-maximization skill discipline) | opus47-max × PLAN when proposal-stage bundling | continuous Q&A (UP-06 NO-Silent-Default) |

## 4. Routing decision tree

```
Step 1 — Classify task tier:
  CHARTER       → opus47-max × FOCUSED_IMPL (deny-lift cycle + AskUserQuestion + D-NNN ADR)
  SCOPE         → opus47-max × PLAN (master-plan subagent OR main-session fallback)
  ARCH          → opus47-max × MULTI_TASK_IMPL or sandwich-architect dispatch
  IMPL          → see Step 2
  VERIFY        → opus47-max × VERIFY (deferred — insufficient samples; provisional only)

Step 2 — Classify IMPL surface:
  test-first IMPL ≤30 files + ≤80 tests   → sonnet46-max via sandwich-dev dispatch
  hook authoring 1-3 hooks ≤200 LOC each  → opus47-max × FOCUSED_IMPL
  hook authoring ≥3 hooks per session     → opus47-max × MULTI_TASK_IMPL
  prefilter/classification high-volume    → haiku45-max via per-role override (BP-S43b-1)
  cross-BC IMPL 4-10 tasks                → opus47-max × MULTI_TASK_IMPL

Step 3 — If ANY of these signals fire, route up to opus47-max × FOCUSED_IMPL:
  - Charter Principle 9 (No LLM math) constraint touched
  - Multi-perspective adversarial structure required
  - Provenance chain (12-field ADR) authoring
  - mistake-log.md M-S<N>-<M> ETL
  - sync-tracker categories must_grill_remaining > 0
```

## 5. Empirical calibration (cited; not LLM-computed)

> Per Charter Principle 9: numbers below are read from source artifacts, not generated.

**opus47-max × FOCUSED_IMPL** (samples=12; profile § 5):
- Hit rate (deliverables shipped / planned): 5/5 = 1.00 across S26/S28/S30/S32/S35 (legacy band)
- 100% test-PASS post-IMPL (0 regressions across 12 sessions)
- Budget actual vs envelope: S28 ~110-140K / S30 ~85-110K / S32 ~80-110K (favorable); S20 ~292K (over hard_cap due to permission bug context inflation)
- Phase 2.5 cluster (S48b/c/d/g/h): 8 hooks shipped + 4 charter ADRs (D-028..D-031) all ratified

**opus47-max × PLAN** (samples=6; profile § 5):
- Master-plan ratification rate: 5/5 = 1.00 (002+004+005+007+009 all shipped + downstream-executed)
- Subagent reliability: 1/2 master-planner stalls (S43f stream-window timeout L-S43f-2); main-session fallback recovery 100% at S44

**opus47-max × MULTI_TASK_IMPL** (samples=4; profile § 5):
- Test delta per session: S27 +9 / S33 +16 / S34 +53 (mean ~+26)
- Hit rate: 4/4 = 1.00 with cosmetic deviations under D1 threshold (20%)
- IMPL-tier LOC ceiling adherence: 60% (40% under D1 cosmetic deviations)

**sonnet46-max × FOCUSED_IMPL** (samples=2; DRAFT; profile § 5):
- Test delta: S46 +67 / S47 +44 (mean ~+55)
- Test-PASS post-IMPL: 100% (0 regressions across 2 samples after re-dispatch bug-fix S46)
- Budget overrun S46 ~333K cumulative vs 150-220K target (+51%) — partly attributable to L-S46-2 candidate (post-/clear TaskList loss → re-dispatch)

**haiku45-max × FOCUSED_IMPL** (samples=1; DRAFT; profile § 5):
- S47 Track-H S3: precision=1.0, recall=0.889, F1=0.941 (N=10 Vietnamese KOL fixtures)
- Cost ~$0.027/fixture (Haiku prefilter only) vs Sonnet-4-6 full pipeline ~$0.16/fixture (~6× cheaper)
- DO NOT GENERALIZE — N=1 probe is research signal, not statistical hit rate

**sync-tracker tier scores** (state.tsv post-S48j; § 1 above):
- 4/5 categories at MED tier (>50): DOMAIN_UBIQUITOUS 56.7 / DESIGN_THINKING 54.8 / LANGUAGE 51.4 / SCOPE 50.7
- 1/5 at MED-LOW: DECISION_ROUTING 49.5 (M-S45-1 substrate-loss -2.0 drag)
- 0/5 at MED_HIGH (>70) — see HH-F.4 success-criterion adjustment rationale (S48k)

## 6. Known gaps + AVOID list

**INSUFFICIENT-SAMPLE profiles** (do not route blindly):
- opus47-max × VERIFY — 0 S48 samples; phase-boundary VERIFY deferred Phase 2.5 close
- sonnet46-max × FOCUSED_IMPL — 2 samples (≥3 floor); BC-6 IMPL only; generalization to other BCs provisional
- haiku45-max × FOCUSED_IMPL — 1 sample; prefilter classification only; reasoning-heavy NOT validated

**MISSING profiles** (no card yet; route at risk):
- sonnet46-max × PLAN, MULTI_TASK_IMPL, VERIFY (no samples; opus47-max routing preferred until evidence accumulates)
- haiku45-max × PLAN, MULTI_TASK_IMPL, VERIFY (cost-effective for some preprocessing tasks; substrate not validated for substrate authoring)
- opus47-max × MULTI_TASK_IMPL × META_LOOP_RECOVERY (S35 was FOCUSED_IMPL variant; cross-effort comparison untested)

**AVOID patterns** (charter-cited):
- AP-1 same-agent self-review — never route VERIFY to the same model+effort that authored IMPL
- AP-17 identity drift — Stockforge is AI-first VN stock advisory; reject `general framework` framings in prompts
- AP-23 continuous LLM-Guardian — deterministic hooks ARE the Guardian; LLM aggregator session-end ONLY
- M-S45-1 family — sandwich-architect Write authority (use Edit; mechanical guard active)
- M-S46-1 / L-S46-2 — post-/clear TaskList loss should NOT trigger re-dispatch without artifact-completion check

## 7. Update lifecycle

This file updates when:
- A new profile card lands in `profiles/` (auto-populate hook HH-C.3 surfaces session sample) → re-render § 1 + § 5
- A sync-tracker category transitions tier (state.tsv mutation) → re-render § 1 + § 5
- A new task family emerges from agent-notes promotion (e.g., new skill or new BC architecture pattern) → re-render § 2 + § 3 + § 4
- An AVOID pattern surfaces (mistake-log new M-S<N>-<M> entry) → append to § 6

**Rendering**: manual main-session edit (Phase 0 doctrine — no auto-render). Phase 1+ telemetry-analyst subagent may auto-render per profile-template.md § "Profile card lifecycle" if the same scaling pattern proves out.

## 8. References

- D-002 § Track 8 (sync-tracker category schema)
- D-006 (weights.yaml runtime config knob)
- D-008 (Track 9 self-awareness REDUCED scope; Phase 0 deterministic-only)
- D-026 (LLM Substrate Boundary BP-S43b-1/2/3)
- agent-workspace/memory/self-awareness/profile-template.md § 3 Recommended task_class allocation
- CLAUDE.md § Session Types (PLAN / FOCUSED_IMPL / MULTI_TASK_IMPL / VERIFY / RECOVERY / THESIS / INGEST / POST-MORTEM budget bands)
- agent-workspace/constitution/karpathy-principles.md § P3 Surgical Changes
- Charter Principle 8 (Calibration over confidence) + 9 (No LLM math)
