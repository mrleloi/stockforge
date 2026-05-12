# Architect Observation — S251 Phase 4 Master-Plan Refresh

**Authored**: 2026-05-12 S251 (sandwich-architect fresh-context dispatch from main session post-S250 Phase 3.5 close)
**Subagent type**: sandwich-architect (per AP-1)
**Path chosen**: **Path X — AMEND in place** (single-artifact append to `008-S235-phase-4-master-plan.md`)
**Path rejected**: Path Y (sibling 011-S251 file)

## Decision rationale (1-sentence)

Path X chosen because the carryover delta is **editorial** (re-baseline session numbering S236→S252+ + 3 housekeeping tracks F/G/H + 2 risk rows + Q-P4-4 envelope tweak) NOT **structural** (no scope change to Tracks A/B/C/D/E + SC-1..SC-7 unchanged), so Charter Principle 8 (cheapest-first) + AP-23 (DEEPEN > BROADEN) favor preserving S235 archival integrity inside a single file via an explicit append-only Amendments section over creating a 011 sibling that splits future readers' attention surface and duplicates 510 LOC of S235 body content.

## What changed in 008-S235-phase-4-master-plan.md

### Frontmatter (additive)
- `amended: 2026-05-12 S251 (sandwich-architect fresh-context dispatch ...)` field added
- `amendment_session: S251` + `amendment_agent: Claude Opus 4.7` fields added
- `predecessor_close_handoff: agent-workspace/memory/checkpoints/latest.md` field added
- `predecessor_phase_close_obs: agent-workspace/memory/observations/2026-05-12-S250-phase-3.5-close.md` field added
- `predecessor_cluster_minimum_E: [E.4 proposal, E.3 hook, D-052 notification]` list added
- `sessions_planned`: notation updated to flag S236→S252 re-baseline + envelope unchanged
- `ratifying_decision`: re-pointed from S236 to S252 (bundle to be re-presented at fresh entry per amendment)
- `status: active` preserved (single artifact — no `amended-by-XYZ` flip needed)

### Body (mechanical session-number substitutions)
- All inline `S236`, `S237`, ..., `S251` pointers shifted +16 to `S252`, `S253`, ..., `S267` in body text + Track Catalog table + Session decomposition table + Critical path diagram + Risk Register + Open Questions wording + Pre-flight Checklist + Calibration envelope component breakdown
- 3 mechanical substitutions in Track A/B/C "Code site" header text to update reference to `S252` probe session
- Track D config-flag commit-session reference: `S237 → S253`
- Track A probe-observation filename: `track-A-bull-probe-S236.md → track-A-bull-probe-S252.md`
- SC-2 SQL measurement: `<S236-start-iso> → <S252-start-iso>`
- SC-7 cost rollup: `S236-S251 → S252-S267`
- SC-8 verify session: `S251 → S267`

### Track Catalog table — NEW rows
- **Track F — Housekeeping (Phase 3.5 DEFERRED-DOCUMENTATION + D-053 frontmatter)** — priority MED, BC=meta, scope = T5 protocol + T8 audit + D-053 hygiene, sessions = `parallel with A/B; single FOCUSED_IMPL session NEW`
- **Track G — E.1 anthropic SDK removal (Cluster Minimum E follow-on)** — priority MED, BC=infrastructure, scope = remove imports + drop pin + L-S227-1 pattern + mandatory E.4 verifier, sessions = `dedicated FOCUSED_IMPL, gated by E.4 ratification`
- **Track H — E.4 charter ratification (post-cool-down)** — priority CHARTER-tier, BC=constitution, scope = edit decision-discipline.md + author D-055 + run E.3 baseline, sessions = `dedicated CHARTER-tier session ≥2026-05-14T~21Z`

### Session decomposition — NEW rows
- **S251** (PLAN AMEND row) — this dispatch
- **F.1** (FOCUSED_IMPL) — T5 + T8 + D-053 single bundle, 60-100K main
- **G.1** (FOCUSED_IMPL) — E.1 SDK removal, 80-120K main, gated by H.1
- **G.2** (VERIFY) — fresh-context sandwich-verifier per E.4, 50-70K main + 80-100K subagent
- **H.1** (CHARTER-promote) — E.4 charter ratification, 50-80K main, ≥2026-05-14T~21Z

### Calibration envelope — UPDATED
- Original subtotal `~1.13M-2.04M main + ~520M-870K subagent + $75-130 imputed`
- Amended subtotal `~1.37M-2.47M main + ~600-970K subagent + $75-130 imputed`
- Mid-band 1.85M-2.30M → 2.20M-2.70M
- F+G+H add no imputed-LLM-cost (no thesis runs); they consume subscription budget only

### Risk Register — NEW rows
- **R-P4-9** E.4 cool-down breach (Track G.1 ships before E.4 ratified) — MED severity, mitigation = G.1 gated by H.1 in critical-path diagram
- **R-P4-10** Track F T5 charter-drift (author harness-health-protocol.md content beyond proposals/ draft) — LOW severity, mitigation = F.1 brief constrains to literal transcription

### Q-P4-4 — UPDATED
- Envelope number revised 1.65M-2.91M → 1.97M-3.44M; mid-band 1.85M-2.30M → 2.20M-2.70M; 16 sessions → 20 budgeted slots
- New options (d) "RE-SCOPE — defer Track G E.1 SDK removal" + (e) "RE-SCOPE — combo (lightest Phase 4: A + B + E + F + H only)"

### Pre-flight Checklist — NEW items
- Item 10: NEW (S251) — E.4 charter rule binding on Track G.1 → G.2 sequence
- Item 11: NEW (S251) — Track F.1 constitution-file write authorization caveat per `agent-workspace/CLAUDE.md` Contract Rules #1

### NEW § "Amendments — post-S250 Phase 3.5 close" section appended (LOC ~150)
Contains: authoring metadata + path X vs Y rationale + audit-trail discipline statement + "Why amend now" empirical table (S236-S250 actual work breakdown showing 0/15 sessions advanced Phase 4) + per-track amendment delta detail (A. session re-baseline / B. Track F scope / C. Track G scope / D. Track H scope / E. E.3 hook passive observability note) + code-site re-verification table + Track G/H sequencing rationale + "What's preserved from S235 verbatim" inventory + "What main session must do next" 5-step handoff.

## What's preserved from S235 verbatim

Verified item-by-item:
- All Track A/B/C/D/E scope body text + Identity & Scope framing + acceptance gate paragraphs
- All SC-1..SC-8 quantitative criteria
- All Open Questions Q-P4-1..Q-P4-4 wording (Q-P4-4 envelope numbers + option list ADD-ONLY extended; original options a/b/c/d preserved as a/b/c/e+d shifted)
- Probe protocol body + decision criterion + anti-flake gate body
- Code-site empirical-grounding quoted blocks (bull_agent.py:157-161 / ingest_crowd_sentiment.py:162-168 / ingest_kol_channels.py fixture block)
- Calibration envelope original component breakdown (Track A..Track E + Phase 4 close VERIFY + Charter-promote rows unchanged; F+G+H rows + revised totals added below)
- Risk Register R-P4-1..R-P4-8 (R-P4-9 + R-P4-10 added below)
- Phase 5+ Deferrals list (unchanged)
- Notes on plan authoring discipline rules + LEAN brief honored note

## Code-site re-verification results

| Cite (S235 plan) | S251 actual read | Status |
|---|---|---|
| `packages/infrastructure/analysis/perspectives/bull_agent.py:157-161` silent-swallow try/except | Lines 157-161 read; verbatim match to S235 quoted block (`try: payload = json.loads(raw_json); raw_points: list[object] = payload.get("key_points", []) if isinstance(payload, dict) else [] / except (json.JSONDecodeError, AttributeError): raw_points = []`) | **STABLE — no drift** |
| `apps/cli/ingest_crowd_sentiment.py:162-168` `else: # Live mode: require real implementations` early-exit | Lines 162-168 read; verbatim match to S235 quoted block (`else: # Live mode: require real implementations (not wired Phase 3 — Phase 4) / logger.warning(...) / sys.exit(1)`) | **STABLE — no drift** |
| `apps/cli/ingest_kol_channels.py:43-60` 3 fixture channels (`_FIXTURE_CHANNELS`) | Lines 44-60 read; `_FIXTURE_CHANNELS: dict[str, dict[str, str]] = {` declaration at line 44; 3 fixture entries (youtube/telegram/facebook) on lines 45-60; full content match to S235 description | **STABLE — one-line shift `:43-60 → :44-60`; no scope drift** |

D-053/D-054 retry-validator edits from S241-S243 landed in `bear_agent.py` + `quant_agent.py` per D-054 canonical ADR `source_evidence` field (verified at `agent-workspace/memory/decisions/054-bear-quant-retry-validator-symmetry.md` lines 21-30); NOT bull_agent.py. Tracks B and C had no in-flight work between S235 and S251 to disturb their cite lines.

**Conclusion**: Track A/B/C technical scope requires NO restructuring at S251. The S235 plan body remains technically correct for Phase 4 entry; the amendment is purely envelope re-baseline + carryover absorption.

## S252 Track A entry handoff brief

**For main session to consume + dispatch S252 sandwich-dev (NOT architect; probe is FOCUSED_IMPL not PLAN).**

### Pre-conditions for S252 dispatch

1. SCOPE-tier AskUserQuestion bundle Q-P4-1..Q-P4-4 answered + disposition recorded in `current-execution.md` per autonomous-full doctrine
2. `BULL_HARDENING_RESOLVED` config flag = `false` (Track A hasn't run yet)
3. Cost ledger `cost-ledger.tsv` headers updated for S252+ Phase 4 entries
4. Main session has reviewed this observation + amended plan
5. Optional: sandwich-verifier dispatch on this S251 amendment per AP-1 (architect does NOT review own work)

### Probe session brief (≤6 pre-reads per LEAN-brief rule L-S43f-2)

Pre-reads for S252 sandwich-dev:
1. `agent-workspace/session-plans/pending/008-S235-phase-4-master-plan.md` § Track A + § Amendments
2. `agent-workspace/memory/observations/sandwich-architect-S251-phase-4-master-plan-refresh.md` (this file)
3. `packages/infrastructure/analysis/perspectives/bull_agent.py` lines 150-180 (full analyze() method + silent-swallow block)
4. `packages/infrastructure/analysis/perspectives/bear_agent.py` lines 145-334 (D-054 retry-validator reference pattern for Strategy A2 priors)
5. `apps/_shared/use_case_builder.py` lines 145-165 (parallel-fanout site; reference for Strategy A3 sonnet-swap injection point)
6. `agent-workspace/memory/decisions/054-bear-quant-retry-validator-symmetry.md` (D-054 ACCEPTED IMPL-tier precedent for A2)

### Deterministic metric definition (per Track A probe protocol)

Per-ticker per-strategy:
- **M1 (count)**: `bull_points_count >= 3` — I-S3 quantitative gate
- **M2 (diversity)**: bull_points come from ≥2 distinct categories ∈ {FUNDAMENTAL, GROWTH, VALUATION, COMPETITIVE, MACRO, NARRATIVE}
- **M3 (non-silent)**: `raw_points != []` after parse OR explicit `bull_failure_mode` logged to stderr+frontmatter
- **M4 (cli-success)**: `python -m apps.cli.validate_thesis --ticker <T> --no-mock-llm` exit code 0
- **M5 (cost-bound)**: per-thesis imputed cost ≤ $3 (Charter Principle 11 binding)

Strategy passes per ticker IFF ALL of M1∧M2∧M3∧M4∧M5. Strategy compliance rate = (tickers-passing / 5).

**Decision criterion** (lexicographic): pick strategy with highest (compliance-rate desc, cost-per-thesis-rank asc). If two strategies tie on compliance rate, lower cost wins. If no strategy reaches ≥4/5, ESCALATE to user via SCOPE-tier AskUserQuestion.

### Probe matrix template (S252 deliverable shape)

```
| Strategy             | BID  | BVH  | CTG  | FPT  | GAS  | Compliance | Sum cost |
|----------------------|------|------|------|------|------|------------|----------|
| A1 strict-JSON-mode  | ?    | ?    | ?    | ?    | ?    | ?/5        | $?       |
| A2 retry-validator   | ?    | ?    | ?    | ?    | ?    | ?/5        | $?       |
| A3 sonnet-swap       | ?    | ?    | ?    | ?    | ?    | ?/5        | $?       |
| Baseline (S232)      | 0    | 0    | 3    | 0    | 0    | 1/5        | $6.93    |
```

Each cell value = `bull_points_count` (or `FAIL:reason` if M1-M5 fail).

Output observation: `agent-workspace/memory/observations/track-A-bull-probe-S252.md` per Track 6 spec.

### 4-tickers vs 5-tickers decision (architect explicit pick)

**5-ticker probe with BVH-only-fail-allowed downstream tolerance** — chosen over 4-ticker reduction.

Rationale:
1. **Empirical comparability**: S232 baseline is 5-ticker (BID/BVH/CTG/FPT/GAS); replacing the probe ticker set would lose direct apples-to-apples comparison to the existing `1/5 = $6.93` baseline cell
2. **BVH-only-fail-allowed standing per L-S240-2**: existing lesson already provides asymmetric tolerance — BVH may fail without failing the strategy. This means a strategy that achieves `4/5 with BVH fail` is treated as PASS at anti-flake gate, equivalent to `4/4` if BVH had been dropped. The probe doesn't need to drop BVH to get this tolerance — it gets it via the L-S240-2 tolerance band.
3. **D-053/D-054 retry-validator validation** (the empirical context the dispatch question references): D-053/D-054 validated bear+quant retry on 5-ticker, NOT bull. The 5-ticker set is the canonical Phase 3.5 anti-flake validation surface; using it for Track A maintains protocol continuity across BC-5 perspective hardening.

**Implication for S252 dev brief**: probe matrix has 5 ticker columns (not 4). Anti-flake gate evaluation applies L-S240-2: `≥4/5 with BVH-only-failure-allowed` = PASS at anti-flake gate; `≥4/5 with any non-BVH ticker failing` = retry one more run.

### Probe-first frame restatement (per L-S204-1)

> "Probe THREE candidate strategies empirically before committing. Do NOT armchair-pick. Probe matrix IS the deliverable; strategy commitment is a SEPARATE downstream session (S253) gated by Q-P4-1 answer + probe matrix evidence."

Strategy A1 (strict-JSON-mode), A2 (retry-validator), A3 (sonnet-swap) are EQUAL CANDIDATES at S252 entry. The architect does NOT pick a winner. The probe matrix picks the winner via deterministic rule. If no winner reaches ≥4/5 → escalate per Q-P4-1=ESCALATE branch.

### Cost envelope for S252 probe session

- Main self-track: 80-120K
- Probe imputed-LLM cost: 30-50K equivalent (probe runs 3 strategies × 5 tickers = 15 thesis-equivalents at ~$2-4 each → $30-60 estimate)
- Total Phase 4 envelope contribution: ~110-180K + $30-60

### Out-of-scope for S252 (defer to S253+)

- Production-code commits to bull_agent.py / subagent_transport.py / use_case_builder.py — DEFER to S253 (after Q-P4-1 user signal + strategy selection)
- Persistent telemetry schema design for `bull_failure_mode` field — DEFER to S253 (Strategy A2's `bull_failure_mode` only ships if A2 wins)
- Sonnet-vs-Haiku cost-budget recomputation — DEFER to S253 (only if A3 wins probe)

## Surprises / harness-defect findings during this dispatch

**None.** Code-site re-verification passed; no harness defects surfaced; no production-code drift; no charter-coherence drift; no constitution mutation needed.

Empirical signals checked:
- `git status` not run from architect (no Bash invocation per dispatch scope); per pre-existing baseline `c70177a` last commit + S250 close handoff confirming clean state
- `grep -r "import anthropic" packages/ apps/` NOT re-run (out of scope; E.1 / Track G is the future closure; current state per S249 audit is 2 production-code imports + 1 pyproject pin remaining — unchanged)
- `bull_agent.py:157-161` exact line numbers PRESERVED per direct Read (lines 157-161)

If main session wants additional empirical verification before authorizing S252, recommend:
- `grep -n "json.loads(raw_json)" packages/infrastructure/analysis/perspectives/bull_agent.py` should return `158:    payload = json.loads(raw_json)` (per S251 architect Read)
- `grep -n "Live mode not fully wired" apps/cli/ingest_crowd_sentiment.py` should return `164: "Live mode not fully wired in Phase 3. "` (per S251 architect Read)
- `grep -n "_FIXTURE_CHANNELS" apps/cli/ingest_kol_channels.py` should return `44:_FIXTURE_CHANNELS: dict[str, dict[str, str]] = {` (per S251 architect Read)

## Hard constraints honored (S251 dispatch)

- 0 git commits ✓ (CLAUDE.md hard rule + dispatch instruction)
- 0 charter file edits ✓ (E.4 still in cool-down; T8 audit ledger not authored at S251)
- 0 constitution writes ✓ (T5 belongs to F.1 future session)
- 0 production-code edits ✓ (Track A IMPL is for S252+)
- 0 new hooks ✓
- AP-1 honored ✓ (architect did NOT review own work; main session will dispatch sandwich-verifier separately if desired)
- harness_priority_one applied ✓ (none surfaced; clean dispatch)
- L-S204-1 / empirical-probe-first doctrine restated ✓ (Track A handoff brief explicitly frames 3 strategies as EQUAL candidates with deterministic-rule winner-pick, NOT architect armchair-pick)
- Working-memory budget: ~110K consumed of 150K allotment (under-budget; comfortable)
- Lean brief discipline ≤6 pre-reads honored ✓

## Files written this dispatch

1. **M** `agent-workspace/session-plans/pending/008-S235-phase-4-master-plan.md` (Path X amendment in place — frontmatter + body session-number substitutions + Track Catalog rows F/G/H + Session decomposition rows F.1/G.1/G.2/H.1 + Risk Register R-P4-9/R-P4-10 + Q-P4-4 envelope update + Pre-flight items 10/11 + cumulative tracking S251 row + NEW § Amendments — post-S250 Phase 3.5 close section)
2. **A** `agent-workspace/memory/observations/sandwich-architect-S251-phase-4-master-plan-refresh.md` (this file)
3. **M** `agent-workspace/memory/current-execution.md` (S251 row prepend — architect dispatch in progress / output written / next action = S252 Track A probe sandwich-dev dispatch) — pending in same dispatch

## Summary for main session

- **Path X amendment in place** complete — single-artifact append to 008
- **3 housekeeping tracks F/G/H added** absorbing Phase 3.5 DEFERRED-DOCUMENTATION + Cluster Minimum E carryover
- **Code-site verification PASS** — bull_agent.py:157-161 + ingest_crowd_sentiment.py:162-168 STABLE; ingest_kol_channels.py one-line shift :43→:44 cosmetic
- **Session numbering re-baselined S236→S252+** — original envelope intact, +4 housekeeping slots added
- **No harness defects surfaced** during code-site re-verification
- **Track A S252 handoff brief ready** with 5-ticker pick + L-S240-2 BVH tolerance + deterministic probe-matrix-decides framing
- **Recommended next action**: main session runs Q-P4-1..Q-P4-4 AskUserQuestion bundle, then dispatches S252 sandwich-dev (per Track A probe brief above)

End of S251 architect observation.
