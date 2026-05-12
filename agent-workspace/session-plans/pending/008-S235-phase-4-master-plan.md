---
plan_id: 008-S235-phase-4-master-plan
phase: 4
status: superseded-by-011-S251-phase-4-master-plan (2026-05-12 S251 main-session reconciliation; sibling 011 authored by master-planner persona in parallel with this file's Path-X amendment; user Q-P4-x ratification answers align with 011's Track 0/A-F structure not this file's Track A-H amended structure; both files preserved as audit trail)
authored: 2026-05-10
authored_session: S235 (sandwich-architect fresh-context dispatch per AP-1)
authoring_agent: Claude Opus 4.7 (sandwich-architect persona)
predecessor_plan: agent-workspace/session-plans/pending/007-S44-phase-3-master-plan.md
amended: 2026-05-12 S251 (sandwich-architect fresh-context dispatch — Path X amend-in-place; see § Amendments — post-S250 Phase 3.5 close at bottom)
amendment_session: S251 (architect dispatch from main session post-S250 Phase 3.5 close)
superseded_reason: S251 main-session reconciliation — 011-S251 plan exists in pending/ authored by parallel master-planner; user Q-P4-1..Q-P4-6 picks (all = Recommended option A) frame S252 as T5 mv (Track 0/Track F) NOT Track A bull-role probe (which this file's amended Track A still implies). Bull-role hardening already SHIPPED via D-053/D-054 (S239-S243) per 011 § 0 framing — this file's Track A is functionally vacuous. 011 supersedes; amendment archived intact for audit.
amendment_agent: Claude Opus 4.7 (sandwich-architect persona, fresh context)
predecessor_close_handoff: agent-workspace/memory/checkpoints/latest.md (S250 Phase 3.5 close handoff)
predecessor_phase_close_obs: agent-workspace/memory/observations/2026-05-12-S250-phase-3.5-close.md
predecessor_cluster_minimum_E:
  - agent-workspace/proposals/E4-fresh-context-verifier-arch-charter-tier.md  # E.4 charter rule PROPOSED (cool-down ≥ 2026-05-14T~21Z)
  - scripts/hooks/adr-empirical-close-verify-spot-check.sh  # E.3 hook SHIPPED
  - human-workspace/notifications/N-2026-05-11T21Z-ALERT-D-052-ghost-greening.md  # original D-052 cluster surface
verifier_input: agent-workspace/memory/observations/sandwich-verifier-S234-phase3-close.md (PASS-WITH-RESIDUE)
binding_specs:
  - specs/tier1-core/006-thesis-pipeline.md  # bull-role hardening lives in BC-5 perspective adapters
  - specs/tier2-feature/003-crowd-sentiment-pump-detection.md  # LIVE crowd_sentiment write-path
  - specs/tier2-feature/002-influence-network-tracking.md  # KOL credentials onboarding
binding_charter:
  - PROJECT_CHARTER.md § Phase 2 Edge Sources (Charter naming = our Phase 4)
  - PROJECT_CHARTER.md Principle 11 § cost discipline (Phase 4 envelope binding)
  - PROJECT_CHARTER.md Principle 9 § I-S1 NO LLM MATH
  - agent-workspace/constitution/architecture.md § "LLM Substrate Boundary" (D-026)
  - agent-workspace/constitution/invariants.md § I-S3 (≥3 distinct bull/bear points)
  - agent-workspace/constitution/invariants.md § I-S10 (adversarial-by-default)
  - agent-workspace/constitution/invariants.md § I-S35 (research-aid framing)
sessions_planned: 14 substantive + 2 standing-overhead reserve = 16 budgeted (RE-BASELINED S252-S267 via S251 amendment; original S236-S251 envelope consumed entirely by harness + cluster work, NOT Phase 4 — see § Amendments)
envelope_combined_low_high: 1.65M-2.55M (main + subagent; calibrated against Phase 3 actual ~2.6-3.0M and the narrower Phase 4 surface; ENVELOPE UNCHANGED by S251 amendment — only session-numbering re-baselined)
ratifying_decision: pending S252 entry — Phase 4 SCOPE itself ratified at S235 via AskUserQuestion bundle (Q-P4-1..Q-P4-4 below; bundle to be re-presented at S252 main-session entry per amendment)
related_residue_doc: agent-workspace/memory/observations/sandwich-verifier-S234-phase3-close.md
---

# Phase 4 Master-Plan — Bull-Hardening + LIVE-Wiring + Eval-Set Foundation

## Identity & Scope

**Phase 4 = Bull-role hardening + LIVE crowd-sentiment write-path + KOL credentials onboarding + eval-set seeding + composite real_thesis flip rule.**

Phase 4 is NOT "Charter Phase 3 (FastAPI / Streamlit→Next.js / TimescaleDB / live broker)". Those remain Phase 5+ deferrals per master-plan 007 § Phase 4+ Deferrals. **Phase 4 is the residue-clearing phase**: every PRIORITY-CRITICAL / PRIORITY-HIGH prereq surfaced by S234 verifier becomes a named Track here; every PRIORITY-MED becomes a backlog Track; every PRIORITY-LOW remains in sustained-backlog (Track E) and only lands on observed signal (per L-S204-1 / AP-23 cheapest-by-RISK).

The single most important framing rule for Phase 4: **Track A (bull-role hardening) gates everything thesis-pipeline-touching.** No FOCUSED_IMPL session that writes to `packages/infrastructure/analysis/perspectives/`, `apps/_shared/use_case_builder.py`, or any thesis-pipeline downstream may begin until Track A produces a green-gate decision (probe-then-commit per L-S204-1 doctrine). Tracks B/C/D/E may proceed in parallel because their surfaces (BC-7 ingest, BC-6 KOL adapters, eval-set storage, sustained-backlog) do not touch the bull-role degradation site.

Phase 4 ships only the residue. It does NOT speculatively expand surface area (per AP-23 cheapest-by-RISK: prefer DEEPEN > BROADEN > ABANDON).

---

## Phase 4 Goals + Acceptance Criteria

### SC-1 — Bull-role hardening green-gate

**Target**: 5/5 LIVE dogfood tickers (BID, BVH, CTG, FPT, GAS) produce I-S3-compliant bull output (≥3 distinct-category bull points per ticker, no silent-empty, no JSON-parse fallback to empty list) across **2 consecutive runs** (anti-flake gate per L-S204-1 vindication).

**Measurement**: `python -m apps.cli.validate_thesis --ticker <T> --no-mock-llm` 5 times, scrape `bull_points` count from frontmatter; second run launched ≥30 minutes later (avoids cache hits if any).

**Status**: gates SC-2/SC-3/SC-4/SC-5/SC-6/SC-7. Phase 4 IMPL of any thesis-pipeline-touching feature is BLOCKED until SC-1 green.

### SC-2 — LIVE crowd_sentiment write-path operational

**Target**: `python -m apps.cli.ingest_crowd_sentiment --ticker <T> --platform <P>` (live, not `--dry-run`) writes ≥1 row to `data/stockforge.sqlite`.`sentiment_snapshots` per (ticker, platform) tuple. Smoke runs 3 platforms × 3 tickers = 9 (ticker, platform) tuples → ≥9 rows.

**Measurement**: `sqlite3 data/stockforge.sqlite "SELECT COUNT(*) FROM sentiment_snapshots WHERE created_at > '<S252-start-iso>'"` returns ≥9.

**Code site**: replaces `apps/cli/ingest_crowd_sentiment.py:162-168` early-exit branch with real `_LiveClassifier`, `_LiveCoordinationDetector`, and `SqliteSnapshotRepository` wirings (parallel to existing `_DryRunClassifier`/`_DryRunCoordinationDetector`/`_DryRunRepo` pattern).

### SC-3 — KOL credentials onboarding flow operational

**Target**: ≥1 LIVE KOL channel ingested per platform (YouTube + Telegram + Facebook = 3 platforms minimum). Each platform produces ≥1 row in `data/stockforge.sqlite`.`kol_recommendations` from real fetch (not fixture).

**Measurement**: `sqlite3 data/stockforge.sqlite "SELECT platform, COUNT(*) FROM kol_recommendations GROUP BY platform"` returns 3 rows with COUNT≥1 each.

**Doctrinal artifact**: `docs/kol-credentials-setup.md` exists; `apps/cli/validate_kol_credentials.py` exists and exits 0 with all 3 platforms validated.

### SC-4 — Eval-set seeding (≥10 reference theses + ≥10 labeled pump events)

**Target A**: `eval-sets/historical-theses/` contains ≥10 thesis JSON files (5 from S232 dogfood ticker re-runs after SC-1 + 5 newly-selected tickers). All have `calibration_grade ≥ C` (i.e., `n_samples ≥ 10`).

**Target B**: `eval-sets/labeled-pumps/*.json` count grows from current 7 to ≥10 (master-plan 007 SC-4 target).

**Measurement**: `find eval-sets/historical-theses -name '*.json' | wc -l` ≥10; `find eval-sets/labeled-pumps -name '*.json' | wc -l` ≥10.

### SC-5 — Composite `real_thesis` flip rule codified

**Target**: `apps/cli/validate_thesis.py:220` literal `"real_thesis: false"` replaced with computed boolean from a deterministic rule:

```
real_thesis = (
    SC-1_bull_hardening_resolved (config flag from registry)
    AND len(thesis.bull_points) >= 3
    AND len(thesis.bear_points) >= 3
    AND thesis.live_crowd_sentiment_present (snapshot_id resolves)
    AND thesis.data_gaps == []
    AND thesis.calibration_grade != 'D'
)
```

**Measurement**: 5/5 LIVE dogfood re-runs with all conditions met → frontmatter shows `real_thesis: true`. 1/N test where one condition fails → `real_thesis: false`. Both branches exercised in unit tests.

### SC-6 — Master-plan §186 SC-6 wording amendment landed

**Target**: master-plan 007 file gains an explicit `## Amendments (post-S234 verifier)` section appending: "SC-6 wording 'raises NotYetActivatedError' supersedes-by spec 005 §A.2 'returns ActivationGateStatus dataclass'. Amendment authored S<N> per F5 of S234 verifier report. No edit to upstream history rows."

**Measurement**: `grep -c '^## Amendments' agent-workspace/session-plans/pending/007-S44-phase-3-master-plan.md` returns 1.

### SC-7 — Phase 4 cost discipline

**Target**: total Phase 4 imputed token cost ≤ 1.5× Phase 3 actual ($6.93 imputed dogfood + ~$0 marginal subscription) AND per-thesis re-run cost ≤ $3 (master-plan 007 SC-8 target preserved).

**Measurement**: sum of `imputed_cost` across all S252-S267 sessions ≤ master-plan 007 actual × 1.5; per-thesis from SC-1 re-runs ≤ $3.

### SC-8 — Phase 4 close VERIFY produces PASS or PASS-WITH-RESIDUE

**Target**: fresh-context sandwich-verifier dispatch at S267 produces PASS or PASS-WITH-RESIDUE verdict against this plan; no FAIL-BLOCK on any SC-1..SC-7.

---

## Track Catalog

> **S251 amendment note**: original Tracks A-E + VERIFY/close UNCHANGED in scope. Three NEW housekeeping tracks F/G/H absorb Phase 3.5 DEFERRED-DOCUMENTATION carryover (T5+T8) + Cluster Minimum E carryover (E.1 SDK removal + E.4 charter ratification). Session columns re-baselined S236→S252+ per § Amendments. See § Amendments for new-track scope detail.

| Track | Priority | BC | Scope | Sessions (RE-BASELINED) |
|---|---|---|---|---|
| **A** — Bull-role hardening | CRITICAL | BC-5 | Empirical-probe-first 3-strategy comparison (strict-JSON-mode / retry-validator / model-swap); commit one strategy; verify 5/5 + 2-run anti-flake | S252-S255 |
| **B** — LIVE crowd_sentiment write-path wiring | HIGH | BC-7 | Replace early-exit branch with real live classifier + coordination detector + sqlite snapshot repo; 3-platform smoke | S256-S257 |
| **C** — KOL credentials onboarding flow | HIGH | BC-6 | 3-platform env-var doc + validation CLI + at-least-one live channel ingest end-to-end per platform | S258-S260 |
| **D** — Eval-set seeding + composite-flip-rule + §186 amendment | MED | BC-5/cross-cutting | ≥10 reference theses + labeled-pumps growth + `real_thesis` flip rule + master-plan amendment | S261-S263 |
| **E** — Sustained backlog | LOW | cross-cutting | L-S207-1 + L-S219-1 separate hook+skill promotions; L-S222-1 sustained queue; notifications retention escalation | S264 (single bundle session) |
| **F** — Housekeeping (Phase 3.5 DEFERRED-DOCUMENTATION absorption + D-053 frontmatter) | MED | meta | T5 author harness-health-protocol.md from proposals/ draft + T8 documentation-audit of charter v1.0→v1.1 Principle 11 ratification (Principle 11 ratification already happened S65; T8 is the audit ledger) + D-053 frontmatter DUPLICATE label hygiene single-file edit | parallel with A/B; single FOCUSED_IMPL session NEW |
| **G** — E.1 anthropic SDK removal (Cluster Minimum E follow-on) | MED | infrastructure | Remove `anthropic` imports from `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` (line 80) + `claude_llm_extractor.py` (line 84) + drop `anthropic>=0.40.0` pin in `pyproject.toml` (line 11); replace with Claude Code subagent dispatch pattern per L-S227-1; dedicated FOCUSED_IMPL session + MANDATORY fresh-context sandwich-verifier at close (per E.4 charter rule once ratified ≥2026-05-14T~21Z) NEW | dedicated FOCUSED_IMPL, gated by E.4 ratification |
| **H** — E.4 charter ratification (post-cool-down) | CHARTER-tier | constitution | Edit `agent-workspace/constitution/decision-discipline.md` § new sub-section "Fresh-Context Close-Verify Required for ARCH+/CHARTER-tier ADRs" per `proposals/E4-fresh-context-verifier-arch-charter-tier.md`; author canonical `agent-workspace/memory/decisions/055-fresh-context-verifier-arch-charter-tier.md`; run E.3 hook baseline; close E.4 in current-execution NEW | dedicated CHARTER-tier session ≥2026-05-14T~21Z |
| **VERIFY + close** | meta | n/a | Phase 4 close VERIFY + retrospective + Phase 5 prereq enumeration | S266 + S267 |

**5 original substantive tracks** (A-E) + **3 NEW housekeeping tracks** (F, G, H) + **VERIFY/close** + **2 standing-overhead reserves** (S265a META_LOOP_RECOVERY, S262b harness-recovery).

**Track F+G+H discipline**: priority MED non-blocking; runs parallel with Track A/B/C/D. NONE of them gates SC-1..SC-8. They close known carryover debt without competing for Phase 4 critical-path budget. Track G is gated by Track H ratification (E.4 mandates fresh-context verifier at close for ARCH+/CHARTER tier; E.1 SDK removal touches charter-binding L-S227-1 enforcement path → must respect Track H ratification before shipping).

---

## Track A — Bull-role hardening (PRIORITY-CRITICAL)

### Empirical-probe-first frame

Per `.claude/skills/empirical-probe-first/SKILL.md` and L-S204-1 doctrine, Phase 4 MUST probe 3 candidate strategies before committing — NOT pick by armchair reasoning. The probe is the first IMPL session of Phase 4 (S252) and is SCOPED AS PROBE, not as production code (per AP-23 cheapest-by-RISK).

### Code site (empirically grounded — S251 RE-VERIFIED)

`packages/infrastructure/analysis/perspectives/bull_agent.py:157-161` (verified stable 2026-05-12 S251 amendment dispatch; D-053/D-054 retry-validator edits landed in bear_agent.py + quant_agent.py NOT bull_agent.py):

```python
try:
    payload = json.loads(raw_json)
    raw_points: list[object] = payload.get("key_points", []) if isinstance(payload, dict) else []
except (json.JSONDecodeError, AttributeError):
    raw_points = []
```

This silent-swallow at line 160-161 is the root cause of 4/5 dogfood degradation. No retry. No telemetry. No diagnostic stderr. Three observed failure modes per S232 dogfood: (a) JSON-parse fail on prose+table emit (FPT, BVH); (b) haiku 300s CLI timeout under parallel load (BID, recurring S43b-class); (c) silent bull-empty (GAS).

### Candidate strategies

#### Strategy A1 — Strict-JSON-mode flag

**Approach**: enforce `response_format={"type": "json_object"}` (or CLI subprocess equivalent) on the bull subagent transport call. The `claude` CLI subprocess does NOT currently expose `response_format`; this strategy requires either (1) a CLI flag investigation (probe step) or (2) a structural pre-amble like `Output ONLY valid JSON. No prose. No markdown.` reinforced as the first user message + assistant prefill `{`.

**Cost**: ~2-LOC change at `subagent_transport.py` if CLI flag exists; otherwise ~10-LOC prompt-shaping change.

**Risk**:
- Haiku may not honor JSON mode reliably (empirical question — needs probe).
- CLI subprocess interface may not pass through flag.
- Does NOT fix the timeout failure mode (BID) — only fixes parse-fail (FPT, BVH).

#### Strategy A2 — Bull-output-validator with retry-on-parse-fail (max-2)

**Approach**: post-LLM JSON-parse + structural-validate (key_points list non-empty AND each point has `claim`+`evidence`+`category`); on failure, re-prompt with a corrected-format excerpt; max 2 retries before fall-through-to-empty-bull-with-warning (telemetry stderr line + frontmatter `bull_failure_mode` field).

**Cost**: ~30-LOC validator + retry loop in `bull_agent.py` analyze() method + 1 new dataclass `BullValidationResult` + tests.

**Risk**:
- Retry loop adds latency (2x or 3x in worst case → may push BID into compounded timeout).
- Masks root cause of prompt fragility (treats symptom not disease).
- Telemetry surface adds value: failure_mode column populates dogfood summary.
- DOES address timeout failure mode if retry uses different model on attempt 2/3.

**S251 amendment note**: Strategy A2 has a CLOSE PRECEDENT now (D-054 bear/quant retry-validator symmetry, ACCEPTED 2026-05-10 S243). D-054's empirical record + 22 unit tests + 0.07s test runtime + B5 asymmetric-budget protocol is REUSABLE evidence for A2 viability. This is empirical signal, NOT a probe-skip authorization — S252 still runs the full 3-strategy probe; D-054 just reduces A2's first-instance uncertainty.

#### Strategy A3 — Bull model swap haiku → sonnet under parallel load

**Approach**: per S43b precedent (`apps/_shared/use_case_builder.py:151-158` empirically: haiku swap was the original fix for sonnet-300s-timeout, but haiku now itself fails under parallel load). Hypothesis: under 4-way parallel-fanout (Bear+Bull+Quant+Aggregator), haiku contention is the issue — sonnet may degrade more gracefully because longer reasoning is the actual workload, not contention.

**Cost**: config flag flip in `_build_subagent_agents()` (1-LOC change) + cost-budget recompute.

**Risk**:
- Per master-plan 007 §188 cost target ≤$3/thesis. Sonnet swap from haiku is roughly 3-5x cost-per-bull-call. Per S232 dogfood max thesis cost was $1.5851; 3-5x bull-portion (~$0.30) → ~$1.50-$2.50 per thesis worst case. Margin under $3 is thin but plausible.
- Re-introduces the original timeout failure mode that haiku swap fixed (reverting risk).
- Doesn't address parse-fail mode (FPT, BVH) — sonnet still emits prose if prompt is fragile.

### Probe protocol (S252)

**Each strategy is run against the canonical 5-ticker dogfood validation set (BID, BVH, CTG, FPT, GAS).** No new tickers introduced — empirical comparability with S232 baseline is the point.

**S251 amendment note (4-vs-5 ticker decision)**: 5-ticker set RETAINED. BVH-only-fail-allowed standing per L-S240-2 applies if S239-era anti-flake intuition persists; this is a tolerance band on the green-gate, not a ticker-set reduction. Architect chose 5-ticker over 4-ticker because (a) S232 baseline is 5-ticker → empirical comparability requires same set; (b) BVH-only-fail-allowed already provides asymmetric tolerance without dropping BVH from the probe matrix. Final decision: 5-ticker probe with BVH-only-fail-allowed downstream tolerance (per L-S240-2).

**Deterministic metric per ticker per strategy**:
1. `bull_points_count >= 3` (I-S3 quantitative gate).
2. `bull_points` come from ≥2 distinct categories (FUNDAMENTAL/GROWTH/VALUATION/etc).
3. No silent-empty (`raw_points != []` after parse OR explicit failure_mode logged).
4. End-to-end thesis CLI exit 0.
5. Per-thesis imputed cost ≤ $3.

**Decision criterion** (per L-S204-1 doctrine):
- Pick strategy with highest **(I-S3-compliance-rate, cost-per-thesis-rank)** lexicographic tuple.
- All claims about strategy performance MUST cite empirical numbers from probe matrix table — NO LLM-feeling, NO armchair reasoning.
- If two strategies tie on compliance rate, pick the one with lower cost-per-thesis.
- If no strategy reaches ≥4/5 compliance, ESCALATE to human via SCOPE-tier AskUserQuestion (re-scope Track A: invest in deeper root-cause investigation OR accept partial-degraded as Phase 4 residue).

**Anti-flake gate**: chosen strategy must produce 5/5 I-S3-compliant bull output across **2 consecutive full runs** (run 1 = probe; run 2 = ratification, ≥30 minutes after run 1).

### Probe matrix template (S252 deliverable)

| Strategy | BID | BVH | CTG | FPT | GAS | Compliance rate | Sum cost (imputed) |
|---|---|---|---|---|---|---|---|
| A1 strict-JSON-mode | ? | ? | ? | ? | ? | ?/5 | $? |
| A2 retry-validator | ? | ? | ? | ? | ? | ?/5 | $? |
| A3 sonnet-swap | ? | ? | ? | ? | ? | ?/5 | $? |
| Baseline (Phase 3 actual) | 0 | 0 | 3 | 0 | 0 | 1/5 | $6.93 |

**S252 fills in the `?` cells.** Output goes to `agent-workspace/memory/observations/track-A-bull-probe-S252.md` (per Track 6 spec — observation file).

### Track A acceptance gate

SC-1 green-gate (5/5 across 2 consecutive runs) — required to unblock Tracks B/C/D IMPL sessions that touch any thesis-pipeline file. Tracks B/C/D may proceed in parallel for sessions that DO NOT touch perspectives or use_case_builder.

---

## Track B — LIVE crowd_sentiment write-path wiring (PRIORITY-HIGH)

### Code site (empirically grounded — S251 RE-VERIFIED)

`apps/cli/ingest_crowd_sentiment.py:162-168` (verified stable 2026-05-12 S251 amendment dispatch; early-exit branch present, dry-run stubs `_DryRunRepo`/`_DryRunClassifier`/`_DryRunCoordinationDetector` continue to provide the wiring template):

```python
else:
    # Live mode: require real implementations (not wired Phase 3 — Phase 4)
    logger.warning(
        "Live mode not fully wired in Phase 3. "
        "Use --dry-run for smoke testing. Exiting."
    )
    sys.exit(1)
```

This is the explicit Phase-4-handoff comment. Track B's job: replace this branch with real wirings.

### Required wirings (exhaustive)

1. `_LiveClassifier` — wraps the deterministic sentiment classifier from `packages/infrastructure/crowd_sentiment/sentiment_classifier.py` (Phase 3 ships scaffold; needs real model swap per S234 verifier backlog item B). Phase 4 may ship deterministic-rule classifier (keyword + emoji + valence dictionary lookup) as the v1; LLM-perspective classifier deferred to Phase 5.
2. `_LiveCoordinationDetector` — wraps the deterministic coordination-feature extractor already in `packages/infrastructure/crowd_sentiment/coordination_detector.py` (BC-7 Track J output; ships in S52). Verify it has a `detect()` method matching the dry-run interface.
3. `_LiveSnapshotRepo` — implements `SnapshotRepository` Protocol. Backed by `data/stockforge.sqlite` `sentiment_snapshots` table. Schema per spec 003 + BC-7 ADR.

### 3-platform smoke acceptance

Run `python -m apps.cli.ingest_crowd_sentiment --ticker FPT --platform cafef` (and same for vietstock, youtube-comments). Each writes ≥1 row to `sentiment_snapshots`.

### Track B acceptance gate

SC-2 green: `sqlite3 data/stockforge.sqlite "SELECT COUNT(*) FROM sentiment_snapshots"` ≥ 9 (3 platforms × 3 tickers minimum); each row has non-null `polarity` + `coordination_score` columns.

### Track B does NOT touch thesis pipeline

So Track B IMPL sessions (S256, S257) may proceed in parallel with Track A probe sessions IF they only edit `apps/cli/ingest_crowd_sentiment.py` and `packages/infrastructure/crowd_sentiment/*` (not `packages/infrastructure/analysis/*`).

---

## Track C — KOL credentials onboarding flow (PRIORITY-HIGH)

### Phase 3 baseline (empirically grounded — S251 RE-VERIFIED)

Per S234 verifier F3: `apps/cli/ingest_kol_channels.py:43-60` ships exactly 3 fixture channels (verified stable 2026-05-12 S251 amendment dispatch — `UCkol_youtube_fixture` / `kol_telegram_fixture` / `kol_facebook_fixture` at lines 44-60; line numbers shifted from `:43-60` to `:44-60` — one-line shift, scope unchanged). Production sqlite has 0 BC-6 tables.

### Deliverables

1. **`docs/kol-credentials-setup.md`** — per-platform env-var setup doc:
   - YouTube Data API v3 key acquisition (Google Cloud Console steps; quota; ToS pre-flight)
   - Telegram Bot token (BotFather flow; channel-add semantics)
   - Facebook Graph token (per crawler-reliability skill — gray-zone ToS warning + IP rotation strategy + Playwright-stealth fallback if Graph unavailable; ratifies Q-P3-2 answer)
   - Storage: `.env` file path; `.env.example` template; **never** commit secrets (gitignore verification)

2. **`apps/cli/validate_kol_credentials.py`** — validation CLI:
   - Reads each env-var (`STOCKFORGE_YOUTUBE_API_KEY`, `STOCKFORGE_TELEGRAM_BOT_TOKEN`, `STOCKFORGE_FB_GRAPH_TOKEN`).
   - Per platform: 1 test fetch (e.g., YouTube `videos.list?id=<known-public-id>`; Telegram `getMe`; Facebook `/me?fields=id,name`).
   - Exit 0 on all-3-pass; non-zero with diagnostic per platform on any fail.
   - NO secrets logged to stderr.

3. **At-least-one live channel ingest end-to-end per platform** — replaces fixture path with `--live` flag:
   - User must provide ≥1 KOL channel ID per platform.
   - Per-platform smoke: `python -m apps.cli.ingest_kol_channels --platform youtube --channel-id <UC...> --live`.
   - Writes ≥1 row to `data/stockforge.sqlite`.`kol_recommendations`.

### Track C SCOPE-tier escalation

Track C entry REQUIRES user to provide either (a) actual platform credentials or (b) explicit deferral signal "Phase 4 ships docs+validator, defer LIVE ingest to Phase 5". This is one of the SCOPE questions for the parent's AskUserQuestion gate (Q-P4-2 below).

### Track C acceptance gate

SC-3 green: 3 platform rows in `kol_recommendations` from live (not fixture) ingest. If user defers per Q-P4-2=DEFER, SC-3 partial-PASS = doc + validator ship; LIVE ingest deferred to Phase 5 with explicit Phase 4 residue line.

---

## Track D — Eval-set seeding + composite-flip-rule + §186 amendment (PRIORITY-MED)

### D.1 — Eval-set seeding

**Historical theses ≥10**:
- 5 LIVE dogfood ticker re-runs after Track A green (BID, BVH, CTG, FPT, GAS) — these become the first 5 reference theses with `real_thesis: true` and `calibration_grade ≥ C`.
- 5 newly-selected tickers — sector diversity (banking covered by BID/CTG; insurance by BVH; tech by FPT; energy by GAS → add 5 from sectors not yet represented: real estate, retail, industrial, utilities, materials). User selection deferred to Q-P4-3 SCOPE question.

**Labeled pumps 7→10**:
- Per S234 verifier: `eval-sets/labeled-pumps/` has 7 labeled pump events; master-plan 007 SC-4 target was ≥10. Phase 4 closes this gap by labeling 3 more historical VN pump cycles from public news + price action.

### D.2 — Composite `real_thesis` flip rule

**Code site**: `apps/cli/validate_thesis.py:220` literal string `"real_thesis: false",`.

**Replacement**:
```python
real_thesis_value = _compute_real_thesis(
    bull_hardening_resolved=_load_config_flag("BULL_HARDENING_RESOLVED"),
    thesis=thesis,
)
# new helper at bottom of file or in apps/_shared/thesis_realness.py
def _compute_real_thesis(*, bull_hardening_resolved: bool, thesis: Thesis) -> bool:
    return (
        bull_hardening_resolved
        and len(thesis.bull_case.points) >= 3
        and len(thesis.bear_case.points) >= 3
        and thesis.live_crowd_sentiment_snapshot_id is not None
        and thesis.data_gaps == []
        and thesis.calibration_grade != CalibrationGrade.D
    )
```

**Config flag**: `BULL_HARDENING_RESOLVED` lives in `agent-workspace/memory/sync-tracker/` or env-var; flips to true ONLY after S253-S255 anti-flake gate green. Rule for flipping is itself codified in S253 commit message + doc.

### D.3 — Master-plan §186 amendment

Append to `agent-workspace/session-plans/pending/007-S44-phase-3-master-plan.md`:

```markdown
## Amendments (post-S234 verifier)

### A1 (S<N>) — SC-6 wording supersession
F5 of S234 verifier: §186 SC-6 wording 'raises NotYetActivatedError' was a specification drift from spec 005 §A.2 ratified design which returns `ActivationGateStatus`. The implementation matches spec 005, NOT this master-plan §186. Authoritative reading: ActivationGateStatus dataclass return is correct. This row is appended (not edited inline) to preserve audit trail per L-S43f-3-class no-history-edit doctrine.
```

### Track D acceptance gate

SC-4 green: ≥10 historical-theses + ≥10 labeled-pumps. SC-5 green: composite flip rule unit-tested (both branches: all-conditions-met → true; one-condition-fails → false). SC-6 green: master-plan amendment row exists.

---

## Track E — Sustained backlog (PRIORITY-LOW; single bundle session)

### Items (per S234 backlog + project.md sustained queue)

1. **L-S207-1 + L-S219-1 separate hook+skill promotions** — promote-rule cycle dispatch (cheapest-by-RISK; only items with observed signal).
2. **L-S222-1 sustained queue review** — `project.md` Phase Goals Tracker auto-update hook coverage gap (probe whether observed-violation occurred in Phase 3; if NO, defer per AP-23 cheapest-by-RISK).
3. **L-S222-2 deferred** per L-S204-1 26th vindication; **re-probe at Phase 4 mid-point and only land if observed violation** (NOT speculative).
4. **Notifications retention policy** — 793 files in `human-workspace/notifications/`; SCOPE-tier user policy decision required (Q-P4-4 escalation candidate).
5. **UL glossary stale entries** + **D-027 ADR path drift** + **BC-6 events defined-but-not-published** — bundled batch-cleanup; only items confirmed by S234 verifier (NOT speculative additions).

### Track E discipline

Per L-S204-1 doctrine + AP-23 cheapest-by-RISK: Track E items land ONLY if S264 entry confirms observed-violation OR explicit user request. NOT speculative. NOT exhaustive. Single 60-90K session is the MAX budget — defer overflow to Phase 5 sustained queue.

### Track E acceptance gate

Soft. No SC line. Track E session output: list of items processed (PROMOTED / DEFERRED / RETIRED) with explicit reason per item.

---

## Session decomposition

> **S251 amendment note**: session numbering RE-BASELINED from original S235-S251 envelope (consumed entirely by harness + Cluster Minimum E work, NONE of which was Phase 4 product work) to S252-S267. Original SC counts + acceptance gates UNCHANGED. New rows for Track F/G/H appended at bottom of session table.

| Session | Type | Track | Pre-reqs | Deliverables | Budget (low-high) | Acceptance gate |
|---|---|---|---|---|---|---|
| **S235** | PLAN | meta | S234 verifier done | This file (008-S235-phase-4-master-plan.md) + observation file | 50-80K | This file lands |
| **S251** | PLAN AMEND | meta | S250 Phase 3.5 close handoff | This file's § Amendments section + re-baselined session numbering + Tracks F/G/H added; observation `sandwich-architect-S251-phase-4-master-plan-refresh.md` | 50-80K | Plan + observation lands; main session dispatches S252 sandwich-dev |
| **S252** | THESIS / probe | A | S251 done; SCOPE bundle answered | Probe matrix S252 fills A1/A2/A3 cells; observation `track-A-bull-probe-S252.md` lands; preliminary winning strategy named | 80-120K main + 30-50K probe-LLM imputed | Probe matrix all-cells-filled |
| **S253** | FOCUSED_IMPL | A | S252 done; user authorizes winning strategy | Production code commits selected strategy at `bull_agent.py` + relevant transport / use_case_builder edits; tests added | 100-150K main | Local mock tests + 1-ticker LIVE smoke = 1/1 I-S3 |
| **S254** | THESIS / verify | A | S253 done | LIVE 5-ticker dogfood run #1 (anti-flake gate part 1) | 60-80K main + ~$1.50-3.00 imputed | 5/5 I-S3 compliant |
| **S255** | THESIS / verify | A | S254 done; ≥30min lapse | LIVE 5-ticker dogfood run #2 (anti-flake gate part 2) — SC-1 green-gate | 60-80K main + ~$1.50-3.00 imputed | **SC-1 GREEN** |
| **S256** | FOCUSED_IMPL | B | S251 done (parallel-with-A allowed) | LIVE crowd_sentiment write-path: `_LiveClassifier` + `_LiveCoordinationDetector` + `_LiveSnapshotRepo` wirings | 100-130K main | Unit tests pass; dry-run still works |
| **S257** | MULTI_TASK_IMPL | B | S256 done | 3-platform smoke run (cafef × vietstock × youtube-comments × 3 tickers); SC-2 green | 80-120K main | **SC-2 GREEN** (≥9 sentiment_snapshots rows) |
| **S258** | FOCUSED_IMPL | C | S251 done; Q-P4-2 SCOPE answered | `docs/kol-credentials-setup.md` + `apps/cli/validate_kol_credentials.py` + tests | 100-130K main | Validator exits 0 on test creds |
| **S259** | MULTI_TASK_IMPL | C | S258 done; user provides creds OR DEFER | Per-platform `--live` ingest path; 3-platform smoke runs | 100-150K main | 3 rows in `kol_recommendations` from LIVE |
| **S260** | THESIS / verify | C | S259 done | Sandwich-verifier subagent dispatch on Track C; SC-3 verdict | 50-70K main + 80-100K subagent | **SC-3 GREEN or PARTIAL-PASS-with-residue** |
| **S261** | FOCUSED_IMPL | D | S255 done (Track A green) | Composite flip rule code + tests + master-plan §186 amendment append | 80-120K main | Both branches unit-tested |
| **S262** | INGEST | D | S255 + S257 + S259 done | 5 dogfood ticker re-runs (now `real_thesis: true`) + 5 new-ticker theses + 3 new labeled-pumps | 100-150K main + ~$15-30 imputed (10 theses × ~$1.50-3.00) | **SC-4 + SC-5 + SC-6 GREEN** |
| **S262b** | harness-recovery | meta | reserved | OPTIONAL: use only if dispatch failure / substrate gap | 0-150K | n/a |
| **S263** | VERIFY | D | S262 done | sandwich-verifier subagent dispatch on Tracks A+B+C+D consolidated | 60-90K main + 80-120K subagent | Track-D verdict |
| **S264** | rule-application | E | S263 done | Track E sustained-backlog bundle session (promote-rule + sustained-queue review + notifications policy escalation) | 60-100K main | Track E checklist filled |
| **S265a** | META_LOOP_RECOVERY | meta | reserved | OPTIONAL: use only if drift / blocked / substrate gap | 0-220K | n/a |
| **S266** | VERIFY | Phase 4 close | S264 done | sandwich-verifier whole-Phase-4 + Phase 5 prereq enumeration + retrospective | 60-100K main + 80-120K subagent | Phase 4 verdict |
| **S267** | charter-promote | meta | S266 done | OPTIONAL: ratify any Phase 4 charter amendments + close formally | 30-80K main | Phase 4 closed |
| **F.1** | FOCUSED_IMPL | F | S251 done; parallel with A/B | (a) Author `agent-workspace/constitution/harness-health-protocol.md` from `proposals/harness-health-protocol.md` draft (T5); (b) author T8 audit ledger documenting charter v1.0→v1.1 Principle 11 ratification (already RATIFIED S65 per Charter; T8 = audit doc only, NOT a new charter edit); (c) D-053 frontmatter DUPLICATE label cleanup single-file edit | 60-100K main | T5 protocol lands in constitution/; T8 audit ledger lands; D-053 frontmatter fixed; 0 charter edits this session |
| **G.1** | FOCUSED_IMPL | G | S251 done; H.1 RATIFIED (E.4 charter rule active) | Remove `import anthropic` from `claude_llm_perspective_adapter.py:80` + `claude_llm_extractor.py:84`; drop `anthropic>=0.40.0` pin from `pyproject.toml:11`; replace with Claude Code subagent dispatch per L-S227-1; unit + integration test pass | 80-120K main | All 3 sites cleared; `grep -r "import anthropic" packages/ apps/` returns 0 hits (verified empirically by post-edit re-grep, NOT armchair claim) |
| **G.2** | VERIFY | G | G.1 done | Fresh-context sandwich-verifier dispatch per E.4 charter rule; empirical close-verify of G.1 grep claims | 50-70K main + 80-100K subagent | E.1 fully closed; D-052 cluster fully remediated; M-S249-1 + M-S249-2 retired |
| **H.1** | CHARTER-promote | H | ≥2026-05-14T~21Z (E.4 cool-down complete) | Edit `agent-workspace/constitution/decision-discipline.md` per `proposals/E4-fresh-context-verifier-arch-charter-tier.md` § 2; author canonical `agent-workspace/memory/decisions/055-fresh-context-verifier-arch-charter-tier.md`; run E.3 hook baseline; update `agent-workspace/proposals/E4-fresh-context-verifier-arch-charter-tier.md` status RATIFIED | 50-80K main | D-055 canonical exists; constitution/decision-discipline.md updated; proposal status RATIFIED |

**14 substantive Phase-4 sessions** (S252-S267) + **2 standing-overhead reserves** (S262b, S265a) + **4 housekeeping sessions** (F.1, G.1, G.2, H.1) = **20 budgeted slots**. The 4 housekeeping sessions ADD to envelope; original 16 envelope budget UNCHANGED for SC-1..SC-7 work.

### Critical path

```
S235 → S251 (amend) → S252 → S253 → S254 → S255 (Track A green) ─┐
                                                                  ├─→ S261 → S262 → S263 → S264 → S266 → S267
                            S256 → S257 (Track B green) ─────────┤
                            S258 → S259 → S260 (Track C green) ──┘
                                    [reserves S262b, S265a inserted as needed]

PARALLEL (non-blocking, MED priority):
    F.1 — housekeeping (T5 + T8 + D-053) — runs anytime post-S251
    H.1 — charter ratification — runs ≥2026-05-14T~21Z (E.4 cool-down)
    G.1 → G.2 — E.1 SDK removal — runs after H.1 ratified
```

- **Track A is critical-path** — no Phase 4 close without SC-1 green.
- **Tracks B and C parallelize with Track A** — they touch BC-7 and BC-6 respectively, NOT BC-5 perspective adapters. Sessions S256-S260 may run interleaved with S252-S255 if context budget allows.
- **Track D depends on A AND B AND C** — composite flip rule requires Track A green (bull_hardening_resolved flag) + Track B green (live_crowd_sentiment_snapshot_id resolves) + Track C green (live KOL data populates calibration paths).
- **Track F runs anytime** — housekeeping, non-blocking.
- **Track G is gated by Track H ratification** — E.4 charter rule must be ACTIVE before G.1 IMPL ships (E.1 is the canonical first-customer of the E.4 rule; G.2 verifier dispatch is the rule's own first invocation).

---

## Calibration envelope (math)

Per Phase 3 actual ~2.6-3.0M combined and the narrower Phase 4 surface:

| Component | Estimate | Source |
|---|---|---|
| Track A probe + IMPL + 2 verify runs (S252-S255) | 300-430K main + 60-100K imputed-LLM-cost | empirical-probe-first overhead |
| Track B IMPL (S256-S257) | 180-250K main | typical 2-session IMPL band |
| Track C IMPL + verify (S258-S260) | 250-350K main + 80-100K subagent (S260 verifier) | doc + validator + 3-platform live |
| Track D IMPL + INGEST (S261-S262) | 180-270K main + $15-30 imputed | code + 10-thesis re-run |
| Track D verify (S263) | 60-90K main + 80-120K subagent | typical sandwich-verifier band |
| Track E (S264) | 60-100K main | bundle session cap |
| Phase 4 close VERIFY (S266) | 60-100K main + 80-120K subagent | typical phase-close verify |
| Charter-promote (S267) | 30-80K main | typical close |
| Standing-overhead reserves (S262b + S265a) | 0-370K main | use-only-if-triggered |
| Track F housekeeping (F.1) | 60-100K main | T5 + T8 + D-053 single bundle |
| Track G E.1 SDK removal (G.1 + G.2) | 130-220K main + 80-100K subagent | IMPL + mandatory fresh-context verifier per E.4 |
| Track H E.4 charter ratify (H.1) | 50-80K main | constitution edit + D-055 author + hook baseline |
| **Phase 4 SUBTOTAL** | **~1.37M-2.47M main + ~600-970K subagent + $75-130 imputed-LLM** | UPDATED with F+G+H additions |
| **Phase 4 COMBINED** | **~1.97M-3.44M combined** | low-end assumes 0 reserves; high-end assumes all reserves fire + all F+G+H land |
| **Realistic mid-band** | **~2.20M-2.70M combined** | assumes 1-of-2 reserves fires + F+G+H all land |

**Cost discipline (Charter Principle 11 binding)**: Phase 4 imputed-LLM-cost target = $75-130 (mostly Track A 5-ticker × 3-strategy × 2-runs ≈ 30 thesis-equivalents × ~$1.50-3.00 = $45-90 + Track D 10 theses × ~$1.50-3.00 = $15-30). ≤ Phase 3 actual × 1.5 ($6.93 × 1.5 = $10.40) per-session-AVG; PHASE-TOTAL exceeds Phase 3 because we're running probe matrix + dogfood re-runs + eval-set seeding (3 dogfood-equivalents). **Cost rationale documented for Charter compliance** (Principle 11 binding budget). **Tracks F+G+H add NO imputed-LLM-cost** (no thesis runs; only code edits + constitution writes + subagent verifier consuming subscription budget).

---

## Risk Register

| Risk | Severity | Mitigation |
|---|---|---|
| **R-P4-1** Track A probe inconclusive (no strategy reaches 4/5 compliance) | HIGH | S252 escalation path: SCOPE-tier AskUserQuestion → "deeper investigation OR accept partial-degraded as Phase 4 residue OR rollback to bear-only thesis pipeline". Pre-staged in Q-P4-1 below. |
| **R-P4-2** Sonnet swap (A3) breaches $3/thesis cost target | MED | Cost measured during S252 probe. If A3 selected and cost > $3, surface immediately to user. Allow $5/thesis temporary cap during Phase 4 dogfood per Charter Principle 11 Phase-amendment, OR fall back to A2. |
| **R-P4-3** Bull-haiku 300s timeout recurs even after A2 retry-validator | MED | A2 strategy includes max-2 retry then fall-through-to-empty + telemetry; this mode logs `bull_failure_mode = "timeout-after-retry"` allowing post-mortem-driven Phase 5 investigation. NOT a Phase 4 close blocker per current SC framing IF anti-flake gate green still 5/5; **but** if compounded retry latency causes parallel-fanout cascade timeout, escalate. |
| **R-P4-4** Track C user does not provide credentials → SC-3 partial-PASS | MED | Q-P4-2 SCOPE-tier escalation explicit. PARTIAL-PASS path defined: doc + validator ship; LIVE ingest moves to Phase 5 sustained queue. Mark explicit Phase 4 residue. |
| **R-P4-5** LIVE crowd_sentiment scrapers ToS / rate-limit / IP-block fragility (recurrence of R-P3-2) | MED | Apply `crawler-reliability/SKILL.md` at S256 entry. User-agent rotation + Playwright stealth + backoff. Probe each platform's rate-limit envelope BEFORE multi-ticker smoke. |
| **R-P4-6** Phase 4 envelope under-count repeat (per Phase 2 L-S43e + Phase 3 master-plan R-P3-7) | MED | This master-plan starts at realistic mid-band; D-025 amendment precedent if actual exceeds; explicit policy: amend at first 50% milestone if trending >10% over. S251 amendment now establishes precedent for in-flight re-baselining. |
| **R-P4-7** Same-agent self-review violation (AP-1) | LOW | Tracks A, C, D all use fresh-context sandwich-verifier subagent dispatches (S260, S263, S266). Architect (S251 session) does NOT verify own amended plan; main session will dispatch sandwich-verifier separately if needed. Track G.2 is itself the FIRST canonical application of the E.4 charter rule. |
| **R-P4-8** Subagent stream-window stall recurrence (per L-S43f-2) | MED | All sandwich-architect / sandwich-verifier dispatches use LEAN brief (≤6 pre-reads). This file's S235 + S251 authorings honored that rule. |
| **R-P4-9** NEW (S251 amendment) E.4 cool-down breach — Track G.1 ships before E.4 ratified | MED | Track G.1 explicitly gated by H.1 acceptance in critical path diagram. If user wants G.1 sooner, must explicitly waive E.4 rule via AskUserQuestion (and accept M-S249-1 carryover persistence). |
| **R-P4-10** NEW (S251 amendment) Track F T5 charter-drift — author harness-health-protocol.md edits content beyond proposals/ draft | LOW | F.1 session brief MUST constrain agent to literal transcription of `proposals/harness-health-protocol.md` content into `constitution/harness-health-protocol.md` location; structural edits require separate charter-coherence subagent. Constitution write IS authorized for F.1 (NEW constitution file creation, not edit of existing constitution file — distinct boundary per `agent-workspace/CLAUDE.md` § Contract Rules #1). |

---

## Open Questions (SCOPE-tier — for parent AskUserQuestion bundle)

| ID | Tier | Question | Recommended | Default-if-offline |
|---|---|---|---|---|
| **Q-P4-1** | SCOPE | Track A bull-role hardening strategy commitment after S252 probe — accept architect's auto-pick by lexicographic (compliance, cost) rule, OR require explicit user approval per strategy? | Auto-pick by deterministic rule (transparent: probe matrix posted, decision criterion published; only escalate if no strategy reaches 4/5) | Auto-pick |
| **Q-P4-2** | SCOPE | Track C KOL credentials disposition — (a) USER PROVIDES creds for all 3 platforms now (full SC-3); (b) USER PROVIDES creds for ≥1 platform (partial-PASS, defer rest to Phase 5); (c) DEFER all to Phase 5 (Track C ships docs+validator only) | Option (b) — pragmatic; YouTube creds easiest to provision; defer Telegram/FB if friction | Option (c) DEFER all (most conservative) |
| **Q-P4-3** | SCOPE | Track D 5 new-ticker selection for eval-set diversity — auto-pick by sector-coverage rule from `data/stockforge.sqlite` available coverage, OR user explicitly names 5? | Auto-pick by sector rule (real-estate / retail / industrial / utilities / materials = 1 representative each from existing bars+fundamentals coverage) | Auto-pick |
| **Q-P4-4** | SCOPE | Phase 4 timeline acceptance — calibration envelope REVISED 1.97M-3.44M combined (mid-band 2.20M-2.70M) over 20 budgeted slots including 4 housekeeping sessions (F.1 + G.1 + G.2 + H.1). Accept revised envelope + decomposition, OR re-scope (e.g., defer Track C OR Track D to Phase 5; OR drop Track G E.1 SDK removal to Phase 5 sustained queue)? | ACCEPT as-amended; housekeeping Tracks F+G+H close known carryover debt; Track C has DEFER fallback per Q-P4-2 if scope-anxiety | ACCEPT |

**All 4 questions are SCOPE-tier**; per autonomous-full doctrine, parent session MUST surface as a single AskUserQuestion mega-bundle (per `qa_bundle_all_pending.md` user memory rule) before authorizing Phase 4 IMPL entry (S252). **S251 amendment note**: questions are RE-PRESENTED at S252 entry (original S235 bundle was never actually run because S235→S250 envelope diverted entirely to harness work; bundle is fresh-context-required because elapsed-time + carryover context changes the answer surface).

### Backlog questions (lower-priority; surface only if observed signal)

| ID | Tier | Question | Disposition |
|---|---|---|---|
| Q-P4-5 | IMPL | Notifications retention policy (793 files) | Surfaced as Track E discussion item; user-policy decision deferred to S264 if observed friction |
| Q-P4-6 | CHARTER | Master-plan §186 amendment style — append-only vs inline-with-supersession-marker | Recommended: append-only (per L-S43f-3 no-history-edit); auto-decided unless user objects |

---

## SCOPE-tier authorization gate

Per autonomous-full doctrine (`stop_offering_routing_branches.md` + `autonomous_continue_no_self_pause.md` user memories) AND the explicit framing that **Phase 4 entry IS SCOPE-tier**, the parent session MUST run an `AskUserQuestion` mega-bundle covering all four Q-P4-1..Q-P4-4 BEFORE authorizing S252 IMPL entry.

### Bundle payload (single AskUserQuestion call)

```yaml
header: "Phase 4 entry — SCOPE-tier authorization gate (4 questions — RE-PRESENTED at S252 entry post-S251 amend)"
questions:
  - id: Q-P4-1
    question: |
      Track A bull-role strategy commitment after S252 empirical probe — should the architect auto-pick the winning strategy by deterministic rule (compliance-rate desc, cost-per-thesis asc), OR do you want to approve each strategy commit explicitly?
    options:
      a: "AUTO-PICK by deterministic rule (transparent matrix posted; recommended)"
      b: "EXPLICIT APPROVAL per strategy (more user friction; safer if you distrust the metric)"
      c: "ESCALATE only if no strategy reaches 4/5 compliance (hybrid)"

  - id: Q-P4-2
    question: |
      Track C KOL credentials — provisioning today blocks SC-3 quantitative target. Options:
    options:
      a: "FULL — provide YouTube + Telegram + Facebook creds now (full SC-3)"
      b: "PARTIAL — provide ≥1 platform now (likely YouTube easiest); defer rest to Phase 5 (recommended)"
      c: "DEFER ALL — Track C ships docs + validator only; LIVE ingest deferred to Phase 5 (most conservative)"

  - id: Q-P4-3
    question: |
      Track D eval-set seeding — 5 new-ticker selection for sector diversity (real-estate / retail / industrial / utilities / materials). Auto-pick by sector rule, OR you explicitly name 5?
    options:
      a: "AUTO-PICK by sector-coverage rule (recommended; transparent)"
      b: "I name 5 explicitly (please list in chat)"
      c: "DEFER — keep eval-set at 5 dogfood theses only (Phase 4 ships partial SC-4)"

  - id: Q-P4-4
    question: |
      Phase 4 REVISED envelope (1.97M-3.44M combined, mid-band 2.20M-2.70M, 20 budgeted slots including F+G+H housekeeping) — accept as-amended, or re-scope?
    options:
      a: "ACCEPT as-amended (recommended; Track C DEFER fallback per Q-P4-2 covers worst-case)"
      b: "RE-SCOPE — defer Track C entirely to Phase 5 (lighter Phase 4)"
      c: "RE-SCOPE — defer Track D entirely to Phase 5 (skip eval-set seeding)"
      d: "RE-SCOPE — defer Track G E.1 SDK removal to Phase 5 sustained queue (lighter housekeeping)"
      e: "RE-SCOPE — combo (lightest Phase 4: A + B + E + F + H only)"
```

### After-bundle disposition

- Q-P4-1 answer determines S252-S253 handoff style.
- Q-P4-2 answer gates Track C from full to partial to deferred.
- Q-P4-3 answer determines S262 ticker list.
- Q-P4-4 answer determines whether session decomposition stays at 20 or shrinks.

NO Phase 4 IMPL session may begin until all four are answered. The architect's job ends here; the parent session runs the AskUserQuestion call, records answers, then dispatches S252.

---

## Pre-flight Checklist for S252 entry

1. ✅ Read this file first (008-S235 amended-at-S251)
2. ✅ Verify all 4 SCOPE questions answered + disposition recorded in `current-execution.md`
3. ✅ Verify `BULL_HARDENING_RESOLVED` config flag is `false` (it should be — Track A hasn't run yet)
4. ✅ Per Charter Principle 11 — Phase 4 cost target $75-130 imputed; track via `cost-ledger.tsv`
5. ✅ Per L-S204-1 doctrine — S252 probe is empirical-only; NO armchair "obvious winner" picking
6. ✅ Per AP-1 — S260, S263, S266, G.2 verifier dispatches MUST be fresh-context subagent (not main session)
7. ✅ Per L-S43f-2 lean-brief rule — every architect/dev/verifier subagent dispatch ≤6 pre-reads
8. ✅ Per autonomous-full doctrine — Phase 4 close (S266+S267) does NOT pause for routine handoff; only Q-P4-1..Q-P4-4 (and Q-P4-5/Q-P4-6 if surfaced) trigger AskUserQuestion
9. ✅ Per Tracking retention — `current-execution.md` ≤5 sessions inline, ≤200 LOC; archive if breached during Phase 4
10. ✅ NEW (S251) — Per E.4 charter rule (post-ratification): Track G.1 IMPL MUST be followed by G.2 fresh-context sandwich-verifier before closing E.1 / M-S249-1 / M-S249-2
11. ✅ NEW (S251) — Per `agent-workspace/CLAUDE.md` Contract Rules #1: Track F.1 ships harness-health-protocol.md NEW constitution file (NOT an edit to existing constitution); preferred path is user-approved-write to constitution/, alternative path is keep in proposals/ until explicit user approve

---

## Phase 5+ Deferrals (explicit OUT-OF-SCOPE for Phase 4)

- FastAPI public endpoints (Charter Phase 4 surface; renamed Phase 5+ here)
- NestJS public-API path (Phase 5+ if SaaS path activated)
- Streamlit → Next.js migration (Phase 5+ if SaaS path activated)
- TimescaleDB / Postgres migration (Phase 5+ SaaS-deploy boundary)
- Live broker API integration (Phase 5+; Charter explicit research-aid framing)
- LLM-perspective sentiment classifier (Phase 5; Phase 4 ships deterministic-rule classifier only)
- Outer-loop optimization runs (Year 2 per spec 005 §A.2; Phase 4 still scaffolding-only)
- Bull-role parallel-load investigation root-cause-deep-dive (S234 backlog item E; Phase 4 retry-validator addresses symptom, deep-dive deferred)
- Calibration data full-150-rec accumulation (Charter Year 2 + spec 002 BR-2 cold-start; Phase 4 ships eval-set seed of 10)
- Notifications retention policy enforcement (Q-P4-5 deferred to Track E discussion → likely Phase 5 sustained queue)

---

## Phase 4 sessions cumulative tracking template

| Session | Type | Status | Main self-track | Subagent | External burn | Lessons |
|---|---|---|---|---|---|---|
| S235 | PLAN | original architect dispatch — 008 file authored 2026-05-10 | ~95K (estimated) | sandwich-architect (S235 fresh-context) | $0 | per L-S204-1 vindication, all claims grounded by file reads |
| S251 | PLAN AMEND | this amendment — § Amendments section added; re-baselined S236→S252+; Tracks F/G/H appended | TBD (≤80K target) | sandwich-architect (S251 fresh-context) | $0 | code-site re-verification stable (bull_agent.py:157-161 unchanged; ingest_crowd_sentiment.py:162-168 unchanged; ingest_kol_channels.py shifted 1 line :43-60→:44-60) |
| S252 | THESIS / probe | NEXT | TBD | TBD | ~$30-60 imputed | TBD |

---

## Notes on this plan's authoring

- File LOC: ~510 original + ~150 amendment delta ≈ ~660 (amendment section pre-§ Notes pushes past the original ≤600 target by ~10%; acceptable per AP-23 cheapest-by-RISK — single-artifact amendment is cheaper than splitting into 011 sibling file)
- Authoring path: sandwich-architect fresh-context subagent dispatch (per AP-1; per S234 verifier recommendation; per S251 main-session dispatch)
- Lean brief honored (S235): 6 pre-reads (verifier observation, dogfood summary, master-plan 007 §M, bull_agent.py:150-165, use_case_builder.py:145-165, ingest_crowd_sentiment.py:155-175)
- Lean brief honored (S251): 6 pre-reads (latest.md checkpoint, current-execution.md S250+S249, project.md Phase Goals Tracker + Recent ADRs, this 008 plan, E.4 proposal, D-054 ADR for code-site verification context) + 3 code-site Reads for empirical line-number verification
- Per L-S204-1 doctrine: every code-site claim grounded by literal Read of the file lines cited (NOT memory) — RE-VERIFIED at S251
- Per AP-23 cheapest-by-RISK: Track E sustained-backlog kept minimal; Tracks F/G/H added at S251 only because they're known-carryover debt with named source-of-truth artifacts (E.4 proposal, T5 proposals/draft, D-052 cluster notification) — NOT speculative fan-out
- Per Charter Principle 11: cost envelope explicit; mid-band stated; under-count risk acknowledged; F+G+H envelope addition explicit
- Per autonomous-full + qa_bundle_all_pending: SCOPE bundle pre-staged as a single AskUserQuestion call (4 questions); never piecemeal

---

# Amendments — post-S250 Phase 3.5 close

> **Authored**: 2026-05-12 S251 (sandwich-architect fresh-context dispatch from main session post-S250 Phase 3.5 close)
> **Path chosen**: Path X — AMEND in place (single-artifact append). Rejected Path Y (sibling 011 file) because the delta is editorial (re-baseline + 3 housekeeping tracks) NOT structural (no scope change to A/B/C/D/E), and Charter Principle 8 (cheapest-first) + AP-23 (DEEPEN > BROADEN) favor preserving the S235 archival-integrity inside a single file with explicit append-only Amendments section.
> **Audit-trail discipline**: per L-S43f-3 no-history-edit doctrine, the body of this plan above (Identity & Scope through § Notes on this plan's authoring) is PRESERVED VERBATIM from S235 EXCEPT for: (a) frontmatter additions of amended/amendment_session/amendment_agent/predecessor_close_handoff/predecessor_phase_close_obs/predecessor_cluster_minimum_E fields; (b) sessions_planned + envelope_combined_low_high frontmatter notation of S236→S252 re-baseline; (c) ratifying_decision frontmatter pointer to S252 entry; (d) inline session-number substitutions in body text (S236→S252, S237→S253, ..., S251→S267) for downstream-pointer coherence — substitutions are mechanical re-baseline, NOT scope edit; (e) added Track F/G/H rows to Track Catalog + Session decomposition tables; (f) added F.1/G.1/G.2/H.1 rows to Session decomposition; (g) added R-P4-9 + R-P4-10 to Risk Register; (h) revised Q-P4-4 envelope number + added option (d)+(e); (i) added pre-flight checklist items 10+11; (j) S251 row inserted in cumulative tracking template; (k) code-site re-verification note inserted under Track A + Track B + Track C "Code site (empirically grounded)" headers. NO inline edits to existing rows beyond above mechanical substitutions; NO deletion of S235 content.

## Why amend now

S235 plan budgeted S236-S251 (14 substantive + 2 standing-overhead) for Phase 4 product work. Empirical S236-S250 actual:

| Session range | Actual work | Phase 4 product work? |
|---|---|---|
| S236-S241 | D-053 retry-validator design + S240 anti-flake run + D-054 author + S243 verify | NO (BC-5 perspective hardening for bear/quant, not bull; harness-adjacent) |
| S242-S244 | D-054 implement + verify + lock-trap parallel finding | NO |
| S245-S246 | S245 LIVE 5-ticker anti-flake ARC + S246 Strategy (f) lock-fix | PARTIAL (5-ticker LIVE validation was BEAR/QUANT-only; Track A BULL still pending) |
| S247 | env-prefix Form-B → Form-C fix + HH-8/HH-6 hygiene | NO (harness hygiene) |
| S248 | firing-test-spawn-context-lint hook + AP-23 promotion | NO (harness/promote-rule cycle) |
| S249 | README D-001..D-054 source-prompt backfill + D-052 ghost-greening surface | NO (hygiene + cluster RCA) |
| S250 | Phase 3.5 close + Cluster Minimum E E.3 hook + E.4 proposal | NO (harness + charter-tier; Phase 3.5 close was the trigger to permit Phase 4 entry but is NOT itself Phase 4) |

**Net**: 0 of 15 sessions (S236-S250) advanced Phase 4 product SC-1..SC-7. The Phase 4 envelope is intact (no actual product-work burn against it). Session numbering MUST be re-baselined to preserve the 14+2 budget assumption.

## What this amendment changes

### A. Session numbering re-baselined
Original S236 → S252. Mechanical +16 shift across all session-pointer references in body text + tables. Original envelope unchanged (14 substantive + 2 reserves = 16 main budget). New envelope adds 4 housekeeping sessions (F.1, G.1, G.2, H.1) for **20 budgeted slots total**.

### B. NEW Track F — Housekeeping (priority MED, non-blocking, parallel with A/B/C/D)
Absorbs Phase 3.5 DEFERRED-DOCUMENTATION:
- **T5**: author `agent-workspace/constitution/harness-health-protocol.md` (NEW constitution file). Source draft already lives at `agent-workspace/proposals/harness-health-protocol.md`. F.1 session brief constrains to literal transcription of proposals/ draft → constitution/ location (no structural redesign at F.1). Note: this is a NEW constitution file CREATION, which is distinct from EDITING existing constitution files; per `agent-workspace/CLAUDE.md` Contract Rules #1, the `.claude/settings.json` deny list blocks Edit/Write to constitution/**, so F.1 requires either (a) explicit user-approved write OR (b) keep in proposals/ until explicit approve. F.1 brief MUST surface this choice to user before executing.
- **T8**: charter v1.0→v1.1 Principle 11 ratification documentation/audit. Principle 11 was already RATIFIED at S65 per Charter; T8 is the audit ledger of completed work, NOT a new charter edit. Authoring an audit observation file is the F.1 deliverable for T8.
- **D-053 frontmatter DUPLICATE label hygiene** (PRIORITY 5 in S250 checkpoint): single-file edit to remove DUPLICATE label pointing to non-existent canonical. Tucked into F.1 housekeeping bundle.

### C. NEW Track G — E.1 anthropic SDK removal (priority MED, dedicated FOCUSED_IMPL + mandatory verifier per E.4)
Per S250 PRIORITY 4 (deferred SCOPE) and Cluster Minimum E carryover: 3 sites need cleanup:
- `packages/infrastructure/analysis/claude_llm_perspective_adapter.py:80` (`import anthropic`)
- `packages/infrastructure/analysis/claude_llm_extractor.py:84` (`import anthropic`)
- `pyproject.toml:11` (`anthropic>=0.40.0`)
Replacement pattern: Claude Code subagent dispatch per L-S227-1 user-memory rule. G.1 = IMPL; G.2 = mandatory fresh-context sandwich-verifier dispatch per E.4 charter rule. G.1 GATED by H.1 ratification (E.1 is the canonical first-customer of E.4 rule; verifier dispatch IS the rule's first invocation).

### D. NEW Track H — E.4 charter ratification (CHARTER-tier, dedicated session, post-cool-down ≥2026-05-14T~21Z)
Per S250 PRIORITY 2: edit `agent-workspace/constitution/decision-discipline.md` § new sub-section per `proposals/E4-fresh-context-verifier-arch-charter-tier.md` § 2 proposed text; author canonical `agent-workspace/memory/decisions/055-fresh-context-verifier-arch-charter-tier.md`; run E.3 hook baseline; flip proposal status to RATIFIED. Single CHARTER-tier session. Cannot run before 2026-05-14T~21Z per Charter Revision Protocol 48hr cool-down.

### E. E.3 hook status (passive observability across S252+)
SHIPPED 2026-05-12 S250. Stop hook now active in production; will sample-fire on ACCEPTED ADRs with `empirical_close_verify` field. Production smoke caught D-052 with 24 anthropic-token hits during S250 close. No further action needed; sustained-backlog item monitored via `.adr-empirical-spot-check.log` accumulation.

## Code-site re-verification results (S251 architect)

| Track | Original cite (S235) | S251 re-verify | Status |
|---|---|---|---|
| A | `packages/infrastructure/analysis/perspectives/bull_agent.py:157-161` silent-swallow try/except | UNCHANGED at exact lines 157-161; full match to S235 quoted block | STABLE |
| B | `apps/cli/ingest_crowd_sentiment.py:162-168` `else: # Live mode: require real implementations` → `sys.exit(1)` | UNCHANGED at exact lines 162-168; full match to S235 quoted block | STABLE |
| C | `apps/cli/ingest_kol_channels.py:43-60` 3 fixture channels (`_FIXTURE_CHANNELS`) | One-line shift to `:44-60` (the `_FIXTURE_CHANNELS:` declaration begins at line 44, not 43; content lines 45-60 are the 3 fixture entries) | STABLE; minor line-number shift |

**Conclusion**: code sites for all 3 Tracks (A, B, C) remain stable. D-053/D-054 retry-validator edits in S241-S243 landed in `bear_agent.py` + `quant_agent.py` (per D-054 canonical ADR `source_evidence`), NOT bull_agent.py. Tracks B and C had no work between S235 and S251 to disturb their cite lines. The S251 amendment requires NO restructuring of Track A/B/C technical scope.

## Track G/H sequencing rationale

E.4 rule (once ratified by H.1) mandates fresh-context sandwich-verifier dispatch for ARCH+/CHARTER ADR close. Track G ships E.1 SDK removal — this is BORDERLINE TIER: D-050 (CHARTER-tier parent) and D-052 (ARCH-tier child) both bind on this work. Per E.4 rule strict reading, G.1 IMPL → ACCEPTED status flip on either D-050 or D-052 requires fresh-context verifier. G.2 is that verifier. Therefore: H.1 must ratify BEFORE G.1 ships; otherwise G.1 inherits the same AP-1 self-review defect that produced D-052 ghost-greening in the first place. Sequence is fixed: H.1 → G.1 → G.2.

If user wants G.1 sooner (skipping H.1 wait), they must explicitly waive E.4 via AskUserQuestion. Architect recommendation: WAIT for H.1 ratification — the cool-down expires ≥2026-05-14T~21Z, which is ~2.5 days from S251 dispatch (2026-05-12). G.1 can be scheduled for the first session after H.1 closes.

## What's preserved from S235 verbatim

- All Track A/B/C/D/E scope text + acceptance gates + risk register R-P4-1..R-P4-8
- All SC-1..SC-8 acceptance criteria text
- All Open Questions Q-P4-1..Q-P4-4 wording (only Q-P4-4 envelope numbers + option list extended)
- Probe protocol + decision criterion + anti-flake gate text
- Code-site empirical-grounding quoted blocks
- Calibration envelope component breakdown (only F+G+H rows added; A-E rows preserved)
- Phase 5+ Deferrals list
- Notes on plan authoring discipline rules

## What main session must do next

1. Read this amended plan + sandwich-architect observation `sandwich-architect-S251-phase-4-master-plan-refresh.md`
2. Decide: (a) run Q-P4-1..Q-P4-4 AskUserQuestion bundle now OR (b) dispatch sandwich-verifier first to ratify the amendment per AP-1
3. If (a): on user answers, dispatch S252 sandwich-dev for Track A probe (NOT sandwich-architect — probe is FOCUSED_IMPL not PLAN)
4. If (b): wait for verifier ACCEPT/REJECT, then proceed to (a)
5. S252 Track A probe brief (drafted in companion architect observation) is the immediate handoff target

End of Amendments.
