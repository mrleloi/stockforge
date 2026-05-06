---
observation_id: obs-S65-sandwich-architect-BC-7
type: sandwich-architect-output
created_at: 2026-05-06
dispatch_id: S65-sandwich-architect-BC-7
target: BC-7 Crowd Sentiment + Pump Detection (Tracks J+K) — Phase 3 PLAN session
verdict: READY-FOR-S52
---

# S65 sandwich-architect dispatch — BC-7 (Crowd Sentiment + Pump Detection) PLAN output

## Deliverables list

### D-032 (ADR)
- **Path**: `agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md`
- **LOC**: ~290 lines
- **Frontmatter**: 12-field schema mirrors D-027 verbatim (id, title, status=ACCEPTED, tier=ARCH, date_proposed/ratified=2026-05-06, ratifying_session=S65, authoring_agent, supersedes/superseded_by=none, source_evidence with 7 file:line refs, options_considered for all 9 decisions with chosen+rejected reasons, chosen_options=A1+B1+C1+D1+E1+F1+G1+H1+I1)
- **Body sections**: Context / Decisions § (a)..(i) / Consequences (Positive + Negative-or-accepted + Rollback path) / Provenance — mirrors D-027 structure
- **9 decisions ratified**:
  - (a) Storage substrate — SQLite extension
  - (b) Adapter pattern — Shared Protocol + 3 concrete impls
  - (c) Domain aggregates persistence — Domain aggregates + Protocol repos
  - (d) LLM substrate boundary — D-026 verbatim citation
  - (e) NarrativePhaseClassifier — Deterministic rule-based 7-state
  - (f) PumpPhaseClassifier — Deterministic multi-signal weighted scoring
  - (g) Counter-narrative generator — LLM bear points grounded in 3 sources
  - (h) Coordination detection — 3-feature extractor + conservative threshold + BR-10 enforcement
  - (i) Backtest validation gate — precision >0.5 + recall >0.3 holdout pre-deploy

### Sub-plan 009-S51 (S52 + S53 IMPL sub-plan)
- **Path**: `agent-workspace/session-plans/pending/009-S51-track-J-K-impl-sub-plan.md`
- **LOC**: ~510 lines
- **Structure**: mirrors `008-S45-track-G-H-I-impl-sub-plan.md` verbatim
- **Sessions covered**: 2 IMPL sessions
  - **S52 (MULTI_TASK_IMPL)**: 3 crowd aggregators (F319 + FB public group + CafeF/Vietstock comments) + RateLimitedFetcher base + LlmSentimentClassifier + CoordinationDetector + CLI smoke + 30+ NEW tests; 150-220K main + 50-100K subagent
  - **S53 (FOCUSED_IMPL)**: NarrativePhaseClassifier + PumpPhaseClassifier + CounterNarrativeGenerator + HistoricalAnalogFinder + PumpEvidenceSummarizer + 20+ NEW tests + BR-5 backtest validation harness; 150-220K main + 100-150K subagent
- **Empirical-probe-first ladder at S52 entry**: 3 LLM strategies for sentiment classifier + 3 adapter ToS-compliance strategies × public-only enforcement (per skill `.claude/skills/empirical-probe-first/SKILL.md`)

## Decisions made (chosen vs rejected, one-line each)

- **(a) A1 SQLite chosen** — match BC-6 D-027(a) + Phase 1+2 substrate per L-S17-1; Phase 4 migration boundary; rejected A2 Postgres-now (premature) + A3 hybrid (drift surface)
- **(b) B1 shared Protocol + 3 concretes chosen** — F319 + FacebookPublicGroup + ArticleComments-CafeF/Vietstock; mirror BC-6 D-027(b) + S64 telegram_adapter ToS hardening pattern; rejected B2 (duplicated boilerplate) + B3 (god-service); Telegram explicitly excluded Phase 3 BC-7 (deferred Phase 4)
- **(c) C1 domain aggregates + Protocol repos chosen** — frozen dataclass + __post_init__ invariants in `packages/domain/crowd/`; rich entity behaviors per spec § B.1; rejected C2 (anemic anti-pattern)
- **(d) D1 D-026 verbatim citation chosen** — per-role override + prose-tolerant JSON + gatherer-wired compute; LLM ONLY for categorical sentiment (BR-4) + bear-point text (UC-4) + evidence summary text (UC-3); LLM NEVER outputs numeric per I-S1; rejected D2 (would violate D-026 ratified) + D3 (would violate I-S1+BR-4)
- **(e) E1 deterministic 7-state chosen** — pure-Python rule-based per spec § B.3 lines 301-333 verbatim; thresholds tunable via config; rejected E2 (LLM declares phase — spec § C.1 explicitly rejects) + E3 (ML model — insufficient labeled data Phase 3)
- **(f) F1 deterministic multi-signal weighted scoring chosen** — pure-Python 5-state per spec § B.3 lines 379-423; confidence gate ≥0.4 OR returns UNCERTAIN; weights tunable per Karpathy outer loop Year 2; rejected F2 (LLM declares phase) + F3 (no confidence gate violates § B.10 R6)
- **(g) G1 LLM bear-points grounded in 3 sources chosen** — failing analogs + bullish_consensus + sector_structural_risks; MANDATORY per BR-6 when bullish_ratio>0.8 (gates positive signal per I-S13); rejected G2 (template-based — spec § C.1 rejects) + G3 (freeform no grounding violates BR-6+I-S2)
- **(h) H1 3-feature extractor + conservative threshold chosen** — template_similarity + timing_cluster + account_age_distribution; ensemble 0.4/0.3/0.3; threshold ≥0.8 per BR-8; **BR-10 NEVER names operators** payload schema CONSTITUTIONALLY FORBIDDEN; rejected H2 (LLM judges violates I-S1+BR-8) + H3 (2-signal violates spec § B.4 explicit 3-feature)
- **(i) I1 precision >0.5 + recall >0.3 holdout chosen** — BR-5 hold-out gate at S53 close BEFORE pump classifier deploys live; Phase 1 human-review-first per § B.8 every detection reviewed before alert fires; rejected I2 (no validation gate) + I3 (precision 0.8 unachievable Phase 3)

## Open questions for S52/S53 entry

**IMPL-tier auto-decide (no SCOPE-tier escalation needed)**:
- Q-S52-1: F319 fully-public threads only (recommend YES per BR-1)
- Q-S52-2: FB Graph API endpoint version (recommend `posts` v18+ for stability)
- Q-S52-3: account_age_days fetched per-post or sampled+cached (recommend sampled + 24h TTL)
- Q-S52-4: RateLimitedFetcher import-from-influence_network OR duplicate-with-attribution (recommend import-if-shape-compatible)
- Q-S53-1: HistoricalAnalogFinder embedding model (recommend OpenAI text-embedding-3-small per architecture.md § LLM)
- Q-S53-2: LabeledPump seed who-labels (recommend hybrid agent-drafts + user-reviews 5-10 entries)
- Q-S53-3: sector_structural_risks query stub or wire to BC-3 (recommend stub if BC-3 sector-risk repo not wired)
- Q-S53-4: counter-narrative bear-points length cap (recommend 500 chars per spec § B.5 + BR-10 audit-trace)
- Q-S53-5: Phase 1 human-review-first storage UI (recommend stub UI at S53 + full UI at S57 Track M)

**SCOPE-tier escalation triggers (only if surfaced at session entry, NOT pre-emptive)**:
- IF S52 sentiment classifier all-3-strategy probe <85% per-label accuracy → SCOPE Q&A escalate via AskUserQuestion (defer Track J classifier to S54 META_LOOP_RECOVERY)
- IF S53 BR-5 hold-out gate fails (precision ≤0.5 OR recall ≤0.3) → SCOPE Q&A escalate (defer pump live-deploy to S54)
- IF FB Graph API auth shifts mid-Phase-3 (ToS hardening) → adapter falls back to manual link-list mode + IMPL-S52-N documented (no SCOPE escalation needed; mirror BC-6 D-027 R1)

**Q-B2 charter-tier mandate compliance**: NO charter-tier user-gates surfaced at S65; D-032 is ARCH-tier (sub-charter); all 9 decisions cite spec 003 + D-027 + D-026 explicit binding (no novel charter-shaping). S52+S53 entry SHOULD NOT trigger AskUserQuestion unless probe/gate failures emerge per rollback paths.

## Risks identified beyond master plan

**No new HIGH-severity risks beyond R-P3-1/R-P3-2/R-P3-4/R-P3-6 master-plan baseline.**

Sub-plan elevates 3 BC-7-specific risks already implicit in master-plan but newly catalogued:
- **R3 (HIGH)** — BR-10 operator-naming leakage in counter-narrative or pump-evidence LLM output: regex gate at output + LLM prompt instructs "NEVER name individuals" + pytest BR-10 test verifies (catalogued at S53 risk register)
- **R4 (MED)** — LabeledPump dataset insufficient for BR-5 gate (5 historical pumps minimum needed): Phase 3 ships with 5-10 minimum; agent-with-review drafts if user-time-constrained (catalogued at S53 risk register)
- **R5 (MED)** — HistoricalAnalogFinder cold-start (no historical setup-fingerprints loaded): bootstrap script seeds 20+ historical ticker-period fingerprints from BC-1 + BC-2 if available; else empty fallback (catalogued at S53 risk register)

These are operationalizations of master-plan R-P3-4 (pump detection false-positive rate MED) — sub-plan adds concrete mitigation paths without elevating severity.

## Dispatch metadata

**Tokens consumed (estimate)**: ~58K (within 60-90K main + 200-250K subagent envelope per master-plan §S51)
- Pre-read consumption: ~22K (specs/003 ~680 LOC + D-027 ~155 LOC + 008-* ~430 LOC + D-026 ~130 LOC + 007-* ~245 LOC + architecture.md targeted-grep + 230-LOC + 60-LOC slices)
- D-032 authoring: ~16K
- Sub-plan authoring: ~18K
- Observation file authoring: ~2K

**Files read (count + paths)**: 6 files
1. `C:\htdocs\stockforge\specs\tier2-feature\003-crowd-sentiment-pump-detection.md` (full read; 680 LOC)
2. `C:\htdocs\stockforge\agent-workspace\memory\decisions\027-S45-BC-6-architecture-influence-network.md` (full read; 155 LOC)
3. `C:\htdocs\stockforge\agent-workspace\session-plans\pending\008-S45-track-G-H-I-impl-sub-plan.md` (full read; 430 LOC)
4. `C:\htdocs\stockforge\agent-workspace\memory\decisions\026-S43e-charter-promote-bundle-C1-C2.md` (full read; 130 LOC)
5. `C:\htdocs\stockforge\agent-workspace\session-plans\pending\007-S44-phase-3-master-plan.md` (full read; 245 LOC)
6. `C:\htdocs\stockforge\agent-workspace\constitution\architecture.md` (targeted-grep + 2 slices: lines 1-230 + 385-444)

**Lean brief mandate compliance**: 6 files = exactly the L-S43f-2 cap; no expansion beyond brief.

**Files written (count + paths)**: 3 files
1. `C:\htdocs\stockforge\agent-workspace\memory\decisions\032-S51-BC-7-architecture-crowd-sentiment.md` (D-032; ~290 LOC)
2. `C:\htdocs\stockforge\agent-workspace\session-plans\pending\009-S51-track-J-K-impl-sub-plan.md` (sub-plan; ~510 LOC)
3. `C:\htdocs\stockforge\agent-workspace\memory\observations\sandwich-architect-S65-BC-7.md` (this observation file)

**Stream-window stall risk**: NOT manifested. Both deliverables shipped within single dispatch window. Fallback Option 2 (main session authors second deliverable) NOT invoked.

## Verdict

**READY-FOR-S52** — no SCOPE-tier blockers surfaced; D-032 ratifies all 9 architectural decisions with ≥2 alternatives + chosen+rejected reasons each per Q-B2 charter-tier mandate; sub-plan 009 covers S52+S53 verbatim per master-plan §S51-S53 binding; all hard constraints honored:
- D-032 frontmatter mirrors D-027 12-field schema verbatim ✓
- All 9 decisions list ≥2 alternatives ✓
- Sub-plan cites spec 003 BR-1..BR-10 + master plan §S51-S53 binding ✓
- I-S1 NO LLM math enforced in (d)+(e)+(f) — LLM only outputs categorical sentiment + bear-point text + evidence summary text ✓
- BR-1 public-only enforced in (b) — no private FB groups, no Telegram (deferred Phase 4), no Zalo, no DMs; mirror BC-6 telegram_adapter S64 hardening ✓
- BR-10 no public accusations enforced in (h) — flagged ≠ confirmed; payload schema CONSTITUTIONALLY FORBIDDEN from operator-naming fields ✓
- NO git commit ✓ (no commits made; CLAUDE.md hard rule honored)
- Domain layer ZERO framework dependency in `packages/domain/crowd/` — pure Python dataclasses + StrEnum; no FastAPI/Pydantic/SQLAlchemy/httpx imports planned ✓

S52 entry ready: pre-flight reads §S52 in 009-* sub-plan + crawler-reliability skill + empirical-probe-first skill ladder for sentiment classifier + adapter ToS-compliance × public-only.
