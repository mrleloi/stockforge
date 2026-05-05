# Current Execution — Routing Source of Truth

> This is THE single source of truth for "where is work currently happening".
> Agent reads this at session start to identify active track.
> Hardcoded paths in CLAUDE.md or skills are ANTI-PATTERN — they go stale.

## S45 — INCIDENT: agent-notes.md data-loss + recovery + L-S45-2 mechanical guard (2026-05-05) 🔴 SUBSTRATE

**CRITICAL incident this session**: S45 sandwich-architect (`agent-abee75e2518d36e62`) called `Write` (not `Edit`) on `agent-workspace/memory/agent-notes.md`, destructively overwriting ~470 LOC of accumulated learned rules with a ~40 LOC stub. The repo has `git status` = "no commits yet" (per S43c carry-forward "git thì không cần release, bỏ qua") so `git checkout HEAD --` rollback was IMPOSSIBLE.

**Recovery executed this turn** (forensic transcript-mining of CCS instance JSONL caches):
- Lines 1..314 verbatim from `31a5f363-a178-41f8-b688-67b1b4cb7e41.jsonl:L33` (largest cached pre-incident Read)
- Lines 455..470 verbatim from `agent-abee75e2518d36e62.jsonl:L67` (S45 subagent's own partial Read at offset=455 BEFORE the destructive Write)
- Lines 315..454 (~140 lines, ~30K chars) **PERMANENTLY UNRECOVERABLE** from any cache located 2026-05-05; explicit gap marker inserted with HTML-comment block listing the lesson IDs known-to-have-lived-there (L-S15-1, L-S17-1, L-S19-1, L-S20-1, L-S25-1, L-S26-1, L-S28-1, L-S30-1, L-S32-1, L-S34-1, L-S35-N, L-S43b-1..10, L-S43c-N, L-S43d-1, L-S43d-2, L-S43e-1) and forensic-reconstruction primary-source priority (checkpoints/sessions/observations/D-026/architecture.md/decision-discipline.md). Per Charter "every claim has source + as-of date" + no-fabrication rule, gap content is NOT inferred. Final restored file = 409 LOC (vs original ~470 LOC).
- Recovery script `scripts/recover-agent-notes.py` retained as authoring evidence.

**2 NEW lesson entries appended**: L-S45-1 (pre-staged sequential files require VBW Read-Before-Write — pre-staged duplicate dispatches happen when autonomous loop dispatches the same architect twice; without VBW the second dispatch destroys the first's output) + L-S45-2 (use Edit not Write for append-only files — Read-before-Write safety only blocks first-write of unread files; does NOT prevent loss when partial Reads have happened; CRITICAL severity — actual data loss). Per just-ratified Rule 4b, lesson-synthesis triggered (a) substrate gap + (b) deferred-fix mechanical-enforcement.

**L-S45-2 mechanical promotion (HOOK FIRST per Q-E3) ✅ SHIPPED same-turn**: NEW `scripts/hooks/write-vs-edit-guard.sh` (~85 LOC; bash + POSIX per L-S11-1; exit 2 HARD-BLOCK on `Write` calls targeting protected paths: `agent-workspace/memory/{agent-notes,project,mistake-log,current-execution}.md` + `agent-workspace/{constitution,proposals}/**`; allows first-creation when file absent; allows all `Edit` calls). Wired into `.claude/settings.json` PreToolUse chain after `dispatch-jsonl-recorder.sh`. **4/4 smoke-test cases green**: existing-protected→BLOCK / unprotected→ALLOW / Edit→ALLOW / first-creation→ALLOW.

**Sandwich-architect did still ship its primary deliverables**: `008-S45-track-G-H-I-impl-sub-plan.md` (428 LOC; IMPL-S45-1 cosmetic over ≤300 advisory) + `027-S45-BC-6-architecture-influence-network.md` (152 LOC; under ≤200 advisory). S46/S47/S49 deliverables locked: 14+7+15 NEW files + 30+15+25 NEW tests; cumulative ~430-620K main + ~200-350K subagent envelope. 9 IMPL-tier auto-decides Q-S46-1/2/3 + Q-S47-1/2/3 + Q-S49-1/2/3.

**Self-track this turn (incident recovery)**: ~50-80K (forensic transcript scan + Python recovery script + 2 new entries authoring + hook + smoke-test + this row). 0 NEW SCOPE-tier; 0 NEW IMPL-tier ADR; 2 NEW HIGH/CRITICAL lesson candidates (L-S45-1 + L-S45-2) — cited verbatim in agent-notes.md per Rule 4b. **Phase 3 NEXT session = S46 MULTI_TASK_IMPL Track G** (separate session per CLAUDE.md never-mix; gate on S45 done = SATISFIED despite incident).

## S45 — Phase 3 Track G+H+I (BC-6) sub-plan via sandwich-architect (2026-05-05) ✅ DONE

Sandwich-architect background dispatch returned clean (~313s wall, 102K subagent tokens, 9 tool uses — well under master-planner-stall mitigation envelope per L-S43f-2 LEAN brief). 2 NEW artifacts: (A) `agent-workspace/session-plans/pending/008-S45-track-G-H-I-impl-sub-plan.md` (428 LOC; over ≤300 advisory by ~43% = IMPL-S45-1 cosmetic; session-plans not D1-bounded; expanded probe-ladder + Vietnamese fixture coverage justify); (B) `agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md` (152 LOC under ≤200 advisory). S46 deliverables locked: 14 NEW + 2 EDIT files + 30+ NEW tests (3 KOL adapters YouTube/Telegram/Facebook + rate-limited fetcher base + CLI). S47 deliverables locked: 7 NEW files + 5 Vietnamese fixtures + 1 EDIT + 15+ NEW tests; LLM probe ladder = Claude Opus / Claude Sonnet / Haiku-prefilter+Sonnet-extract per L-S32-1 empirical-probe-first skill. S49 deliverables locked: 15 NEW files + 1 EDIT + 25+ NEW tests (Bayesian calibration domain service + outcome scheduler + KOL repository). Cumulative envelope ~430-620K main + ~200-350K subagent across S46+S47+S49. 9 IMPL-tier open questions Q-S46-1/2/3 + Q-S47-1/2/3 + Q-S49-1/2/3 (all auto-decide unless surfaced). 0 NEW SCOPE-tier; 0 NEW lesson candidates. Rule 4b lesson-synthesis NOT triggered this turn (no user correction / deferred-fix / substrate gap / charter-tier decision / META_LOOP recovery). Main self-track this turn ~30-50K (file verification + 2 routing edits; subagent did the heavy authoring). **Phase 3 NEXT session = S46 MULTI_TASK_IMPL Track G** (separate session per CLAUDE.md never-mix; gate on S45 done = SATISFIED).

## S44 — Phase 3 master-plan main-session authoring (2026-05-05) ✅ DONE

After S43f master-planner subagent stall (L-S43f-2 stream-window timeout), shipped Phase 3 master-plan via main-session authoring per checkpoint Option 2: NEW `agent-workspace/session-plans/pending/007-S44-phase-3-master-plan.md` (240 LOC; lean vs S31 790 LOC). 7 substantive tracks G-M (BC-6 KOL adapters/extraction/calibration + BC-7 sentiment/pump + BC-9 outer-loop scaffolding + cross-cutting UI). 11 substantive sessions S45-S59 + 4 standing-overhead reserves (S48 META_LOOP / S54 harness / S56 charter-promote / S58 rule-application) per D-025 calibration baseline. Critical path S44→S45→S46→S47→S49→S50→S51→S52→S53→S55→S57→S59. Envelope ~2.6M-3.0M combined mid-band (15% above Phase 2 actuals; honest mid-band start vs Phase 2 under-count anti-pattern). 4 user-gates flagged Q-P3-1..4 for S45 entry (3 SCOPE/CHARTER + 1 IMPL auto-decide). 8 success criteria measurable. Phase 4+ deferrals enumerated. **Phase 3 NEXT session = S45 PLAN (Track G+H+I sandwich-architect dispatch with LEAN brief ≤6 pre-reads per L-S43f-2)**.

## S43f — User-gate bundle ratification + C1+C2 deny-lift cycle (2026-05-05) ✅ DONE

4-question AskUserQuestion bundle landed all 4 user-gate items in one shot. Q1 C1=ACCEPT + Q2 C2=ACCEPT → bundled deny-lift cycle ratified both charter amendments via D-026 (`agent-workspace/memory/decisions/026-S43e-charter-promote-bundle-C1-C2.md`); architecture.md +25 LOC "LLM Substrate Boundary" subsection + decision-discipline.md +33 LOC Rule 4b + lesson-synthesis-watchdog.sh flipped advisory→strict. Q3 Phase 3 SCOPE=CONFIRM full envelope (Tier 3+4 + KOL spec 002 + pump spec 003 + outer-loop spec 005) → S44 PLAN session authorized for Phase 3 master-plan authoring. Q4 DEFER-S43b-2=A (keep doctrine) → closed; bank-sector schema work NOT in Phase 3 scope. NEW L-S43f-1 agent-notes entry (bundled deny-lift cycle for sibling charter proposals; hook-tier promotion candidate). Closure observation: `agent-workspace/memory/observations/S43f-user-gate-bundle-closure.md`. Self-track ~25-40K. **Phase 2 OFFICIALLY CLOSED post-S43f**; next session = S44 Phase 3 master-plan PLAN.

## Active Focus Track

**Phase**: 2 — Foundation Tier 1+2 (Tier 1+2 VN30 rollout; entered 2026-04-30 via D-011 SCOPE-tier user-gated Option A; per Charter Month 3 success criteria #1+#2 + spec-T1-001 § B.2). Phase 1 = COMPLETE 2026-04-30 (S25-S30 all DONE). Phase 2 master-plan SHIPPED at S31 (2026-04-30).
**Active plan (Phase 2)**: `agent-workspace/session-plans/pending/005-S31-phase-2-master-plan.md` (790 LOC; 6 tracks A-F: A R2 closure / B VN30 BC-1 / C BC-2 Fundamental / D BC-5 News+CafeF / E 9 proposals parallel / F thesis 3-perspective real impl; 11 sessions S32-S43; critical path S32→S33→[S34//S36 parallel]→S41→S42→S43a→S43; Track E S38/S39/S40 PARALLEL non-blocking; ~860K-1.25M main + ~250K subagent envelope refined from D-011 abstract per Phase 1 actual ~888-1023K calibration)
**Track F sub-plan (S41 PLAN deliverable)**: `agent-workspace/session-plans/pending/006-S41-track-F-impl-sub-plan.md` (S42 + S43a deliverables matrix; mirrors 004-S24-... format; binding spec `specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md`; binding ADR `agent-workspace/memory/decisions/014-track-F-architecture.md`)
**Phase 1 closed plan (archived reference)**: `agent-workspace/session-plans/pending/004-S24-phase-1-thin-slice-plan.md` (S25-S30 ALL DONE; Phase 1 thin-slice on VHM exemplar)
**Phase 0 closed plan (archived reference)**: `agent-workspace/session-plans/pending/001-port-from-orch.md` (filename retained; content = closed 14-track REV-3 plan)
**Session N**: S1 ✅ → ... → S22 ✅ (Phase 0 close) → S23 ✅ (Phase 1 entry) → S24 ✅ (PLAN master-plan 004) → S25 ✅ (PLAN — glossary + spec frame + D-009) → S26 ✅ (FOCUSED_IMPL — VN-Domain Constitution Proposals Track B) → S27 ✅ (MULTI_TASK_IMPL — first entities BC-1+BC-9; 161 PASS) → S28 ✅ (FOCUSED_IMPL — Tier 1 ingestion adapter; 182 PASS; live 248 VHM bars) → S29 ✅ (VERIFY — sandwich-verifier whole-Phase 1; PASS-WITH-RESIDUE; phase_gate UNBLOCKED) → S30 ✅ (FOCUSED_IMPL — Phase 1 closure: 4 NEW deliverables + R1 partial fix + 3 IMPL-S30-* deviations + Phase 1 close ceremony + AskUserQuestion 1Q SCOPE-tier; D-011 ACCEPTED Option A; D1=0 sustained; self-track ~85-110K) → S31 ✅ (PLAN — Phase 2 master-plan author via master-planner subagent dispatch; 1 NEW plan file `005-S31-phase-2-master-plan.md` 790 LOC; 6 tracks A-F; 11 sessions S32-S43; sandwich coverage S41+S42+S43a+S43; Phase 2 envelope refined ~860K-1.25M; D1=0; self-track main ~30-45K) → **S32 ✅ (FOCUSED_IMPL — Track A R2 closure; A3 SSI iBoard direct httpx adapter pivot picked over master-plan-recommended A2 vnstock alternate-source after empirical 4-strategy ladder probe rejected A1 [TCBS endpoints all 404] + A2 [vnstock 4.0.2 Quote effectively VCI-only]; 1 NEW production module `packages/infrastructure/market_data/ssi_adapter.py` 211 LOC [+17% over ≤180 advisory = IMPL-S32-1 cosmetic; under D1 20% threshold]; 4 EDITs [__init__.py +8 / tcbs_adapter.py +7 deprecation banner / ingest_vhm.py +15 / test_adapters.py +182 = 16 NEW tests]; 2 NEW data artifacts [`data/vn30-coverage-S32.md` 121 LOC + `data/vn30-probe-ssi.json` 35 LOC]; 1 NEW IMPL-tier decision D-012 ACCEPTED [205 LOC; +46% over ≤140 advisory = IMPL-S32-3]; 198 tests PASS in 0.50s [+16 NEW; 0 regressions]; mypy --strict + ruff clean on Phase 2 surface; D1=0 sustained; LLM-math creep = 0; live smoke `ingest_vhm` 1-year backfill 248 vnstock + 248 SSI = 496 rows; **`data/vhm-reconciliation.md`: 248 HIGH / 0 LOW / 0 SINGLE_SOURCE — was 248 SINGLE_SOURCE pre-S32; R2 CLOSED**; SSI VN30 coverage 30/30 = 100% live, pessimistic VCI×SSI intersection ≥93%; 1 NEW lesson candidate L-S32-1 ["empirical probe before strategy commit" doctrine; promote at Phase 2 close per Q-E2]; 0 NEW SCOPE-tier; 3 IMPL-tier cosmetic deviations [IMPL-S32-1/2/3]; self-track main ~80-110K within FOCUSED_IMPL 100-150K target)** → S32 → **S33 ✅ (MULTI_TASK_IMPL — Track B VN30 BC-1 universe expansion DONE; 3 NEW production [vn30_universe.py 94 LOC + ingest_vn30.py 206 LOC IMPL-S33-1 +14% + value_objects/__init__.py 10 LOC] + 4 EDIT [domain market_data __init__.py +9 / reconciliation_service.py +24 IMPL-S33-2 +4% / sqlite_bar_repository.py +44 IMPL-S33-3 +9% / test_adapters.py +106 IMPL-S33-4 +44%] + 2 NEW tests [test_ingest_vn30.py 150 LOC IMPL-S33-5 +7%]; 6 IMPL-S33-* cosmetic deviations all under D1 20% threshold; 0 NEW SCOPE-tier; 0 NEW IMPL-tier decision file [per L-S15-1 inline-document doctrine]; 214 PASS in 0.81s [+16 NEW: 5 VN30 universe + 2 sàn-tier + 4 multi-ticker + 5 CLI smoke; master-plan minimum 10 — exceeded]; mypy --strict + ruff 0 errors on Phase 2 surface; D1=0 sustained; cross-BC + framework + LLM-math creep greps all 0 hits; live smoke 3-ticker subset VHM/VIC/FPT × 20 days = 120 rows persisted, 100% DUAL_SOURCE HIGH confidence; full 30-ticker × 1-year live backfill DEFERRED as R4 NEW [long-running ~45 min wall at 0.3 RPS; not blocking S34/S36]; 0 NEW lesson candidates; L-S30-1 VBW pre-flight APPLIED [caught value_objects/ directory absence vs master-plan stale claim]; self-track main ~80-110K well within MULTI_TASK_IMPL 150-250K target)** → S34 ✅ (Track C BC-2 Fundamental DONE) → S35 ✅ (META_LOOP_RECOVERY) → S36 ✅ (Track D BC-5 News + CafeF + LLM extractor; 327 PASS) → **S41 ✅ (PLAN — Track F sandwich-architect subagent dispatch; 3 NEW deliverables: spec 006 (~620 LOC vs ≤350 advisory; IMPL-S41-1 deviation +77%), D-014 (~190 LOC vs ≤140 advisory; IMPL-S41-2 deviation +35%), sub-plan 006-S41 (~290 LOC vs ≤300 advisory; under); 1 EDIT current-execution.md (this row); 2 SCOPE-tier user-gates flagged in D-014 § Open Questions [Q-S41-1 QuantAgent Opus vs Sonnet; Q-S41-2 personal-risk-profile fill timing] both `pending_user_gate: true` with Recommended defaults documented; D1=0 sustained; LLM-math creep grep 0 hits in spec/ADR/sub-plan; L-S30-1 VBW pre-flight APPLIED — `Glob` confirmed all 3 target paths absent + parent dirs present; 0 NEW lesson candidates; self-track main ~30-45K within PLAN 50-80K target).** S42 NEXT (MULTI_TASK_IMPL — Track F BC-8 domain + adapters + use case; ~16 files; ~200-240K envelope per master-plan 005 § S42 + sub-plan 006-S41 § S42; pre-flight projection check at entry mandatory — split S42a/S42b if >230K).

**Prior session — S20 close detail**: (FOCUSED_IMPL — Track 6 Secondary Closure: 16 D1 violators refactored ≤ ceiling; D1 baseline 16 → 0; 5 skills + 10 commands + 1 agent compressed per L-S14-1/L-S14-1 corollary/L-S14-2; 3 references/templates.md companion files NEW for spec-to-wiki + ubiquitous-language + write-a-skill; tactical settings.local.json expansion adding defaultMode:bypassPermissions + ~150 explicit Bash(<cmd>:*) entries triggered by user mobile-remote bug report; new user memory `bash_permission_pattern.md` documenting permission-matcher semantics; 0 NEW IMPL-tier decisions; L-S20-1 candidate already wired)
**Status**: S21 VERIFY closed cleanly. Phase 0 closure boundary intact; **Phase 0 = COMPLETE**. Verifier verdict PASS-WITH-RESIDUE. 11 tracks (Track 0-9 + sub-tracks) all ✅ DONE with deliverables traceable to artifacts on disk. 8 decisions ratified (D-001..D-008) with 12-field schema + REV chains preserved. Charter + 9 constitution files immutable since 2026-04-24 (md5 + mtime confirmed). 82 observability tests PASS in 0.17s (verifier reran live). 22/22 sampled LOC claims exact (only stale: bash-hook-lint.sh 140→143 micro-drift documentation-only). 5 L-S* carry-overs all UNWIRED (claim correct). 4 IMPL-S* decisions all trace to source. LLM-math creep check 0 hits (Charter Principle 9 preserved). DR1+DR6+L-S11-1 invariants preserved. No scope creep / no orphan files. **3 non-blocking residue items**: R1 = proposal count drift (current-execution.md says 6 but actual = 7; provenance-protocol predates S16 batch); R2 = inert `Bash(*)` line in settings.local.json contradicts L-S20-1 (functionally inert via defaultMode); R3 = bash-hook-lint.sh stale LOC 140→143. **Weakest forward-link**: self-awareness-aggregate.sh authored but not auto-wired (IMPL-S19-1 deferral); sessions-rollup.tsv has only S18 smoke row. **11 deferrals to Phase 1+** all documented in D-006/D-007/D-008 § Open Questions. S21 self-track ~50-60K (within VERIFY 60-80K target). Cumulative Phase 0 ~2.85M as projected.

**Prior session — S19**: closed cleanly. Deliverables shipped per S19 task plan (11-step sequence): (1) D-1 pre-flight verification (checkpoint + current-execution + S18 session log + queued-grill scan + drift baseline + bash-hook-lint baseline + D-002 REV-2 § B Track 9 + REV-3 § C reduction + S15-close ~50K basis + jsonl-schema.md + otel-design.md + telemetry source files + docker dir absence confirmed); (2) D-008 NEW decision file (279 LOC; canonical 12-field schema; status ACCEPTED via IMPL-tier self-decide + autonomous_mode=true; documents IMPL-S19-1 REDUCED scope; 9 source_evidence entries; 3 options considered chose B); (3) packages/observability/state_machine.py 128 LOC — pure dataclasses + Enum; HookEventState (str-mixin, 4 lowercase tokens) + HookEvent (eq+hash by name+started_at) + VALID_TRANSITIONS frozenset (5 entries: 3 forward + 2 reactivation) + transition() + is_terminal() + InvalidTransitionError; (4) __init__.py extended 50→67 LOC with 6 NEW exports + module docstring updated; (5) test_state_machine.py 185 LOC 20 tests PASS — full obs suite 82 PASS in 0.18s; (6) self-awareness/ template seeds — README.md (61) + profile-template.md (79) + known-issues.md (74; 3 SEED KI-001..KI-003) + best-practices.md (70; 3 SEED BP-001..BP-003); pre-existing jsonl-schema.md + otel-design.md preserved; (7) self-awareness-aggregate.sh 124 LOC ≤180 bash+awk only — reads dispatch.jsonl + component-telemetry.jsonl + .transcript-tokens + .session-hooks.log + sessions/*.md → emits header + row to sessions-rollup.tsv; (8) aggregator smoke PASS — emitted `18 09d3d5a4 2026-04-29T16:56:07Z 158142 873 5 B:1,H:1 244`; initial off-by-one in awk substr fixed RSTART+16/RLENGTH-17; (9) hook-diagnostics SKILL.md 113 LOC ≤150 D1 — 9 sections + 3 examples + 3 anti-patterns; visible in available-skills system reminder; (10) drift + bash-hook-lint clean — D1 = 16 UNCHANGED, 0 NEW L-S11-1, 0 NEW D9, 0 D-IDENTITY findings; (11) lifecycle: this current-execution.md S19 ✅ → S20 NEXT, session log 2026-04-29-session-19.md, checkpoint latest.md + sibling 2026-04-29-S19-close.md. **D1 baseline post-S19 = 16 violations UNCHANGED**. All 11 S19 success criteria PASS (per S19 session log Outcome table). 1 IMPL-tier decision: IMPL-S19-1 (REDUCED Track 9 — defer thesis-side amendments + telemetry-analyst + rollup_telemetry + OTEL docker to Phase 1+). 1 NEW lesson L-S19-1 (deterministic Stop-hook aggregator > continuous LLM Guardian for Phase 0 telemetry rollup; promotion target proposals/architecture-amendment.md § "Telemetry rollup design" OR decompose-work/SKILL.md telemetry-rollup template). 0 SessionStart carry-over for S20.
**autonomous_mode**: true (always — full autonomous is the only mode per user correction S15 close 2026-04-29; "SUPERVISED" was a fabricated default-until-Track-7, never user-authorized; routine handoffs go via Stop hook → Mode-A/B/C/D → continue-injector / session-self-reboot)
**Mode**: AUTONOMOUS (full — no human-in-the-loop bifurcation; AskUserQuestion reserved for genuinely-new SCOPE/CHARTER decisions only, NOT routine session handoffs)
**Last checkpoint**: `agent-workspace/memory/checkpoints/latest.md` (S38 Bundle 1 charter promote close — written 2026-05-01; overwrites S42 Track F BC-8 IMPL close); **Phase 1 verdict (preserved)**: `agent-workspace/memory/checkpoints/phase-1-thin-slice-S29-verdict.md` (S29 PASS-WITH-RESIDUE)
**Track status**: Phase 0 = COMPLETE (S1-S22). **Phase 1 = COMPLETE (S23-S30 all DONE).** Phase 2 entry ✅ APPROVED (D-011 SCOPE-tier; S30). Phase 2 master-plan ✅ SHIPPED (S31). **Track A ✅ DONE (S32).** **Track B ✅ DONE (S33).** **Track C ✅ DONE (S34 — BC-2 Fundamental).** **S35 ✅ DONE (META_LOOP_RECOVERY).** **Track D ✅ DONE (S36 — BC-5 News Stream + CafeF scraper + Claude LLM extractor; 21 NEW + 2 EDIT files; 327 PASS [+60 NEW tests; was 267]; 0 regressions; mypy --strict 0 errors on 26 source files; ruff 0 errors; D1=0 sustained; cross-BC + framework + LLM-math creep greps all 0 hits; 3 IMPL-S36-* cosmetic deviations [infra +49% / CLI +70% / tests +67% — all under D1]; 0 NEW SCOPE-tier; 0 NEW IMPL-tier decision file [L-S15-1 inline-document]; 0 NEW lesson candidates; L-S30-1 + L-S15-1 + L-S28-1 APPLIED; 1 NEW soft DR-DEFER R6 [live CafeF smoke gated on cost willingness]; self-track main ~120-160K within MULTI_TASK_IMPL 150-250K target).** **Track F PLAN ✅ DONE (S41 — sandwich-architect subagent dispatch; 3 NEW: spec 006 + D-014 + sub-plan 006-S41; 2 SCOPE-tier user-gates surfaced in D-014 § Open Questions [Q-S41-1 QuantAgent Opus vs Sonnet; Q-S41-2 personal-risk-profile fill timing]).** **Track F IMPL ✅ DONE (S42 — sandwich-dev subagent dispatch; 29 NEW + 1 EDIT files; 390 PASS [+63 NEW tests; was 327]; 0 regressions; mypy --strict 0 errors on 38 source files; ruff clean after 1 auto-fix; D1=0 sustained; cross-BC + framework + LLM-math creep greps all 0 hits; 10 IMPL-S42-* cosmetic deviations [largest: sqlite_thesis_repository +86%, validate_thesis_phase1 +82%, phase1_data_gatherer +49%; all bundled inline per L-S15-1]; 0 NEW SCOPE-tier; 0 NEW IMPL-tier decision file; 0 NEW lesson candidates; L-S30-1 + L-S25-1 + L-S15-1 + L-S34-1 APPLIED; positive cost deviation [synthesizer pure deterministic per spec § A.6.1 → actual $0.90/thesis vs spec § B.10 estimate $1.30; ~31% cheaper]; subagent 73K reported [50% under projected 150-200K]; main self-track ~30-45K; combined ~105-120K [50% under sub-plan §S42 ~200-240K envelope]).** Phase 2 NEXT session = **S38 (FOCUSED_IMPL — Track E Bundle 1 charter promote; ~30-50K) IF Q&A 2026-05-01-001 answered**; else **S43a (FOCUSED_IMPL — Track F UI Streamlit + CLI + 5-thesis dogfood per spec 006 § B.7 + sub-plan 006-S41 § S43a; ~120-140K; gates on Q&A 2026-05-01-002 user-gates resolution before LIVE dogfood)**.
**Budget delta** (post-S42): Phase 0 cumulative ~2.95M (closed). Phase 1 cumulative ~888-1023K (closed). Phase 2 cumulative S31+S32+S33+S34+S35+S36+S41+S42 = ~990K-1.16M main + ~502K subagent (S31 ~158K + S35 ~207K + S41 ~222K + S42 ~73K) = **~1.49M-1.66M combined**. Phase 2 estimated envelope ~860K-1.25M main + ~250K subagent (~1.1M-1.5M total) — **tracking ~11% over top of envelope band**; remaining S38/S39/S40/S43a/S43 must fit ~70-100K headroom or trigger Phase 2 envelope amendment ADR (S43a budget ~120-140K likely pushes envelope amendment by S43a close).

**Prior budget**: S20 real-transcript ~292K (over 250K hard cap due to heavy pre-flight + 16-file Read+Write cycles + system-reminder accumulation). Cumulative Phase 0 ~2.79M post-S20. REV-3 ~2.44M envelope held through S19. Cumulative Track 7+8a+8b+9 = PLAN-S15 (~70K) + IMPL-S16 (~110K) + IMPL-S17 (~110-130K) + IMPL-S18 (~140-160K) + IMPL-S19 (~150-170K) = ~580-640K (vs original ~440K combined estimate); ~140-200K overrun absorbed by Track 6 secondary defer to S20 + Phase-0 final verifier S21.

---

## Routing Table

Short prompt tokens resolve to actual files:

| Prompt pattern | Resolves to |
|---|---|
| "phase 0" | `agent-workspace/session-plans/pending/001-port-from-orch.md` (filename retained; content = 11-track + Track 5.5 Phase 0 plan REV-3) |
| "track 5.5" | `agent-workspace/session-plans/pending/002-track-5.5-sync-layer-selfcap.md` |
| "phase 1" | `docs/DAY_1_CHECKLIST.md` (was old Phase 0) |
| "phase 2" | `agent-workspace/session-plans/pending/005-S31-phase-2-master-plan.md` (Tier 1+2 VN30 rollout; 6 tracks A-F; 11 sessions S32-S43; SHIPPED at S31 2026-04-30) |
| "track f sub-plan" | `agent-workspace/session-plans/pending/006-S41-track-F-impl-sub-plan.md` (S42 + S43a deliverables matrix; SHIPPED at S41 2026-05-01) |
| "track f spec" | `specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md` (Phase 2 Track F thesis pipeline spec; SHIPPED at S41 2026-05-01) |
| "phase 3" | `agent-workspace/session-plans/pending/007-S44-phase-3-master-plan.md` (KOL + pump + outer-loop scaffolding; 7 tracks G-M; 11 substantive + 4 standing-overhead reserve sessions; SHIPPED at S44 2026-05-05 main-session per checkpoint Option 2) |
| "phase 4" | (TBD) |
| "phase 5" | (TBD) |
| "decision NNN" | `agent-workspace/memory/decisions/NNN-*.md` |
| "track N" | section of `001-port-from-orch.md`, or sibling session plan (e.g. "track 5.5" → `002-track-5.5-...md`) |
| "session N" | `agent-workspace/memory/sessions/` (latest file) |
| "strategic spec" | `specs/tier1-strategic/001-four-tier-signal-architecture.md` |
| "thesis spec" | `specs/tier2-feature/001-validate-investment-thesis.md` |
| "kol spec" | `specs/tier2-feature/002-influence-network-tracking.md` |
| "pump spec" | `specs/tier2-feature/003-crowd-sentiment-pump-detection.md` |
| "agents spec" | `specs/tier2-feature/004-multi-perspective-adversarial-agents.md` |
| "outer loop spec" | `specs/tier2-feature/005-karpathy-outer-loop.md` |
| "charter" | `PROJECT_CHARTER.md` |
| "manual" | `AGENT_OPERATING_MANUAL.md` |
| "data protocol" | `agent-workspace/constitution/financial-data-protocol.md` |
| "phase 1 thin-slice spec" | `specs/tier2-feature/000-phase-1-thin-slice-VHM.md` |
| "glossary" | `agent-workspace/ubiquitous-language/glossary.md` |

---

## Current Work Items

- **S43e — Promote-rule queued actions C2/C3/C4 + VF-5 calibration analysis + VF-3 reproducibility ✅ PASS (DONE — FOCUSED_IMPL — 2026-05-04)** per S43d handoff next-actions (a-d); user repeated "continue" as session directive (AUTONOMOUS-FULL):
  - **(d) Promote-rule queued actions** (per `observations/promote-rule-S43c.md`):
    - **C4 ghost-work-audit.sh** — NEW `scripts/hooks/ghost-work-audit.sh` (51 LOC; SessionStart hook; bash+POSIX per L-S11-1; soft-warn exit 0); wired into `.claude/settings.json` SessionStart chain after learning-queue-sweeper; smoke-tested green — detected 5 untracked source files (`packages/contracts/events/{extracted_claim_published,financial_statement_filed,news_article_ingested,position_value_computed}.py` + `packages/infrastructure/analysis/subagent_transport.py`) which is the audit working as designed (these are S43b ghost-work artifacts requiring later provenance audit); `bash-hook-lint.sh` clean on the new hook
    - **C3 pre-clear-handoff-guard `⚠️ unverified` ext** — EDIT `scripts/hooks/pre-clear-handoff-guard.sh` (+15 LOC); regex `'⚠️ unverified|⚠ unverified|unverified ⚠'` against `checkpoints/latest.md`; smoke-tested — `unverified=1` correctly populated when checkpoint references the marker (note: current-checkpoint matches are documentation references describing the C3 hook itself; false-positive acceptable since soft-warn; real `⚠️ unverified` field values would still trigger correctly)
    - **C2 charter-tier proposal draft** — NEW `agent-workspace/proposals/decision-discipline-amendment-rule-4b.md` (~140 LOC; PROPOSAL status; **USER-GATE REQUIRED for ratification per Q-B2 + L-S15-1**); proposes Rule 4b "Lesson-synthesis mandatory at session-end" with 5 trigger gates (a-e) + paired hook upgrade `lesson-synthesis-watchdog.sh` advisory→strict; covers KI-S35-5 / BP-S35-1 / KI-S43b-5 / BP-S43b-4 / L-S43b-7 cluster; explicit ACCEPT/REJECT/AMEND ratification paths documented
    - C1 architecture.md cross-ref (~6 LOC) — DEFERRED (needs deny-lift cycle; bundle with next charter-edit batch per S38 mechanism)
    - C5 bash-hook-lint printf `--` ext — already shipped post-S43d-close (per S43d checkpoint § Substrate residue)
  - **(b) VF-5 disagreement-detector calibration analysis** — NEW `agent-workspace/memory/observations/vf5-calibration-S43e.md` (~110 LOC); 2-path root cause taxonomy: Path A (4/5 tickers BID/BVH/CTG/GAS) bull returns Rule-7 honest-insufficient on data gaps → detector has empty bull dimension verdicts → correct behavior, NOT bug; Path B (1/5 FPT) bull populated 5pts but on QUALITY/RISK while bear populated VALUE/RISK with overlap-mismatch → detector-design limit; 4 remediation paths classified (P1 Phase 3 peer-comparables RECOMMENDED long-term / P2 prompt-tuning REJECTED — violates I-S35 honest-research-aid / **P3 narrative-disagreement detector pass ~30 LOC ACCEPTABLE Phase 2 close** / **P4 spec amendment for gap-attributed-emptiness ACCEPTABLE pairs with P1/P3**); 1 NEW lesson candidate L-S43e-1 (VF-5 emptiness on bull-side = data-gap signal, mitigation = P1+P3 not P2); analysis-only observation per L-S15-1
  - **(c) VF-3 reproducibility test** — background bash bef3ccxu1: `python -m apps.cli.validate_thesis --ticker CTG --as-of 2026-04-29 --no-mock-llm --transport subagent`; **✅ PASS — thesis_id IDENTICAL `1c8c5cb8...d6f236d`** to S43d baseline (AC-5 deterministic-thesis-id confirmed); cost $0.8178 vs S43d $0.9099 (-10.1% cheaper, subagent-spawn variability); bull-case still empty (Rule-7 honest-insufficient; same Path A pattern as S43d, reinforces vf5-calibration-S43e § Path A substrate-not-bug attribution); 0 NEW lesson candidates (already captured as L-S43e-1)
  - **0 NEW SCOPE-tier; 0 NEW IMPL-tier decision file** (per L-S15-1 inline-document)
  - **1 NEW charter-tier PROPOSAL DRAFT** (decision-discipline Rule 4b, awaiting USER-GATE)
  - **1 NEW lesson candidate**: L-S43e-1 (VF-5 emptiness root-cause taxonomy)
  - **D1=0 sustained**; D9 charter md5 unchanged (proposals/ is not constitution/); LLM-math creep 0; bash-hook-lint shows pre-existing violations only (subagent-stop-logger.sh + vendor-api-probe.sh L-S11-1 carryovers — not introduced this turn)
  - **Self-track main this turn (in-progress)**: ~50-80K within FOCUSED_IMPL 100-150K target (low end — analysis + 3 hook artifacts + proposal authoring; no subagent dispatch this turn)
  - **External subscription burn (in-progress)**: ~$0.91 (CTG VF-3 run; D-023 $0-marginal)
  - **(continuation) P3 narrative-disagreement detector + P4 spec amendment ✅ SHIPPED** per VF-5 calibration recommendation (S43e § VF-5 Path B mitigation; user "continue" 2nd dispatch):
    - **P3 detector extension**: EDIT `packages/domain/analysis/models/synthesis.py` (+8 LOC; added `kind: str = "verdict"` field to Disagreement dataclass with backward-compat default); EDIT `packages/infrastructure/analysis/phase1_synthesizer.py` (+27 LOC; added narrative-disagreement detection branch firing when bear+bull both engaged on dim with asymmetric STRONG/NEUTRAL verdicts; verdict-kind branch unchanged); EDIT `packages/infrastructure/analysis/sqlite_thesis_repository.py` (+1 LOC; deserializer round-trips `kind` field with default "verdict"); EDIT `packages/infrastructure/analysis/test_synthesizer.py` (+50 LOC; 2 NEW tests `test_narrative_disagreement_bull_strong_bear_neutral_engaged` + `test_narrative_disagreement_does_not_fire_when_one_side_empty`)
    - **P4 spec amendment**: EDIT `specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md` § A.4 VF-5 (gap-attributed-emptiness now acceptable) + § A.11 Disagreement Handling (kind=verdict vs kind=narrative classifier with explicit per-kind firing rules + perspective-asymmetry deferral to Phase 3)
    - **Test results**: 445 PASS / 3 SKIP / 0 regressions in 14.32s (was 443 PASS at S43d; +2 NEW narrative-disagreement tests)
    - **Conservative scope**: P3 narrative rule fires ONLY when BOTH perspectives engaged on dimension (preserves test_strong_consensus_path semantics); perspective-asymmetry case (one perspective silent, other STRONG) explicitly NOT detected — per spec § A.11 P4 amendment, deferred to Phase 3 peer-comparable shipping (§ A.10) OR future SCOPE-tier amendment with user-gate
    - **Self-track main this continuation**: ~30-50K (VBW reads + 4 surgical edits + 2 NEW tests + spec amendment + suite re-run); cumulative S43e self-track ~80-130K within FOCUSED_IMPL 100-150K target
    - **0 NEW SCOPE-tier; 0 NEW IMPL-tier decision file** (spec amendment documents the change inline per L-S15-1)
    - **0 NEW lesson candidates** — P3+P4 implementation is direct from L-S43e-1 recommendation
  - **(continuation 2) Phase 2 Retrospective ✅ SHIPPED** per checkpoint handoff item (e); user "continue" 4th dispatch this session:
    - NEW `agent-workspace/memory/post-mortems/2026-05-04-phase-2-retrospective.md` (~97 LOC under D1 220 ceiling): Charter alignment 7-row table (4 in-scope DONE + 1 PARTIAL + 3 OUT-OF-SCOPE per D-011) / Track A-F + Track E parallel completion summary / D-025 calibration delta (~$2.31M-2.53M combined within amended envelope) with 4 structural drivers cataloged for Phase 3 baseline / lesson inventory L-S32-1 / L-S35-N / L-S43b-N / L-S43c-N / L-S43d-1/2 / L-S43e-1 with promotion targets per Q-E2/Q-E3 / substrate residue carried forward (C1 / C2 / DEFER-S43b-1/2 / R4 / R6 / Phase 3 perspective-asymmetry detector) / drift watch final (D1=0 / D9 immutable-modulo-deny-lift / LLM-math creep=0) / 445 PASS / 6 Phase 3 kickoff prerequisites / honest self-assessment three-pane
    - C2 user-gate AskUserQuestion **deferred this turn** (advisory `lesson-synthesis-watchdog.sh` operational; user can ratify at own pace; not blocker for autonomous loop)
    - **Self-track main this continuation**: ~10-20K; cumulative S43e ~90-150K within FOCUSED_IMPL 100-150K target
    - **0 NEW SCOPE-tier; 0 NEW IMPL-tier decision file; 0 NEW lesson candidates** (retrospective is aggregation only)
  - **(continuation 3) L-S32-1 skill promotion ✅ SHIPPED** per Phase 2 retrospective prereq #3; user "continue" 5th dispatch this session:
    - NEW `.claude/skills/empirical-probe-first/SKILL.md` (94 LOC under D1 150 ceiling): purpose + S32 origin narrative + when-use/when-not + 7-step process + outputs + pre-flight checklist + anti-patterns + pairs-with section + provenance; encodes LLM-judgment-required procedure complementing `vendor-api-probe.sh` deterministic detection (shipped S35 per D-013)
    - EDIT `agent-workspace/memory/agent-notes.md` (+12 LOC) — appended S43e continuation 3 entry recording the promotion + auto-detect path + skill provenance
    - Skill registered (visible in available-skills system reminder post-write)
    - **Per Q-E3 promotion priority for L-S32-1**: hook=DONE (S35) / skill=DONE (this turn) / charter=DEFERRED (only if ≥3 violations recur Phase 3)
    - **Self-track main this continuation**: ~10-15K; cumulative S43e ~100-165K (potentially +0-15K over FOCUSED_IMPL 100-150K target — acceptable given closing-loop nature)
    - **0 NEW SCOPE-tier; 0 NEW IMPL-tier decision file; 0 NEW lesson candidates** (skill is execution of existing promotion target, not new rule discovery)
  - **(continuation 4) C1 architecture amendment proposal ✅ DRAFTED** per Phase 3 prereq #4; user "continue" 6th dispatch this session:
    - NEW `agent-workspace/proposals/architecture-amendment-C1-llm-substrate-boundary.md` (114 LOC under D1 220 ceiling for proposals): drafts ~22 LOC architecture.md insert (new "LLM Substrate Boundary" subsection between current line 131 OSS fallback and line 133 Frontend); cross-references BP-S43b-1/2/3 + KI-S43b-1/2/3 with citations to existing production code (claude_llm_perspective_adapter.py / subagent_transport.py / use_case_builder.py); ACCEPT/REJECT/AMEND ratification paths documented; **bundle opportunity** flagged: pair with C2 for single deny-lift batch
    - Pre-staged in proposals/ analogous to C2 — actual charter edit requires user-gated deny-lift cycle per S38 mechanism
    - **Self-track main this continuation**: ~10-15K; cumulative S43e ~110-180K (over FOCUSED_IMPL 100-150K target by 0-30K — acceptable closing-loop work; no PLAN/IMPL mix since proposal-drafting is authoring)
    - **0 NEW SCOPE-tier; 0 NEW IMPL-tier decision file; 0 NEW lesson candidates** (proposal drafting from existing promote-rule observation, not new rule discovery)
  - **(continuation 5 — FINAL) DEFER-S43b-1/2 status assessment ✅ SHIPPED** per honest-budget closing-loop discipline; user "continue" 7th dispatch this session:
    - NEW `agent-workspace/memory/observations/defer-s43b-status-S43e.md` (~52 LOC): DEFER-S43b-1 ✅ EMPIRICALLY RESOLVED (6 dogfood runs all reported real cost figures; source-of-truth code path verified intact at claude_llm_perspective_adapter.py:47); DEFER-S43b-2 🔭 PHASE 3 SIZING DECISION (3 options A/B/C; Recommended A keep-doctrine; bundle into Phase 3 SCOPE gate)
    - **Self-track main this continuation**: ~5-10K; cumulative S43e ~125-210K (over FOCUSED_IMPL upper target by 0-60K — honest-budget signal; clean stop point per L-S43b-10)
    - **0 NEW SCOPE-tier; 0 NEW IMPL-tier decision file; 0 NEW lesson candidates** (status assessment only)
  - **Routing**: NEXT session = S44 Phase 3 entry — single bundled AskUserQuestion covering: (i) C1 architecture cross-ref ratify A/B/C, (ii) C2 Rule 4b ratify A/B/C, (iii) Phase 3 SCOPE envelope confirmation analogous to D-011, (iv) DEFER-S43b-2 RatioService bank schema A/B/C. After ratification → Phase 3 master-plan PLAN session (separate per CLAUDE.md never-mix). Critical-path: Phase 2 ALL DONE; Phase 3 prereq #1/#3/#4 satisfied (or staged); #2 bakes into master-plan; #5 user-gate; #6 low-priority. **NO COMMIT** (CLAUDE.md hard rule + S43c user "git thì không cần release, bỏ qua" carry-forward)

- **S43d — Promote-rule HARD-BLOCK clearance + Q7=a 5-thesis dogfood substrate validation (DONE — FOCUSED_IMPL — 2026-05-04)** per S43c handoff next-actions (a)+(b); user repeated "continue" as session directive (AUTONOMOUS-FULL):
  - **(a) promote-rule subagent dispatch (HARD-BLOCK clear)**: background dispatch a930cd91 fresh-context general-purpose subagent; wrote `agent-workspace/memory/observations/promote-rule-S43c.md` (162 LOC; matches glob → `promotion-cycle-trigger.sh` HARD-BLOCK clears at next SessionStart); 6 clusters / 19 candidate rules; cheapest-first routing per Q-E3 = 2 NEW HOOK + 1 HOOK ext + 1 CHARTER-TIER PROPOSAL DRAFT (C2 self-upgrade-loop dormancy → `proposals/decision-discipline-amendment-rule-4b.md`; **USER-GATE pending S43e**); 0 SKILL promotes; subagent burn 102K tokens / 15 tool uses / 154s
  - **(b) Q7=a 5-thesis dogfood**: background bash b00xppg5r — 5 parallel `python -m apps.cli.validate_thesis --ticker {BID,BVH,CTG,FPT,GAS} --as-of 2026-04-29 --no-mock-llm --transport subagent`; wall ~8 min (14:29:41Z → 14:37:30Z); concurrency stalled at 5-6 visible claude.exe vs theoretical 15 → 2/5 (BID+FPT) hit Bear sonnet 300s subprocess timeout cascade; **5/5 exit=0**; cost table BID $1.7560 / BVH $1.0726 / CTG $0.9099 / FPT $1.9123 / GAS $1.1905 = total $6.8413 / avg $1.37
  - **VBW pre-flight finding**: substrate **already exists** — `subagent_transport.py` + `ClaudeLLMPerspectiveAdapter(transport=claude_cli_transport, role_model_overrides={BULL: haiku})` deployed S43b-FRESH/S43b-BULL; checkpoint handoff "write SubagentLLMPerspectiveAdapter" was a misnomer; no new code authored, validation-only turn
  - **Acceptance signals (spec 006 § A.4)**: VF-1 5 thesis files ✅ / VF-2 ≤$15 ≤$2 avg ✅ ($6.84 / $1.37 — 52% over $0.90 amended target due to sonnet timeout fallback overhead) / VF-4 bear ≥3 distinct ✅ (4-5 pts each) / VF-5 ≥1/5 disagreement ❌ (0/5; bull 0-points on 4/5 means I-S12 detector has nothing to disagree with — semantic limit not substrate bug; Phase 3 peer-comparable fix per spec § A.10) / VF-3 reproducibility NOT TESTED (defer S43e)
  - **Substrate validation**: ✅ Q7=a CLOSED — claude CLI subagent transport handles 5-ticker parallel dogfood end-to-end without ANTHROPIC_API_KEY; D-023 Cost Substrate hypothesis empirically confirmed ($0 marginal in API-key terms; $6.84 billed against Claude Code subscription)
  - **5 NEW thesis-log entries**: `agent-workspace/memory/thesis-log/2026-04-29-{BID,BVH,CTG,FPT,GAS}.md`
  - **3 NEW lesson candidates**: L-S43d-1 (Windows claude CLI concurrency stalls at 5-6 vs 15 theoretical → future batches >3 cap parallelism at 3) / L-S43d-2 (D-023 substrate empirically validated $0 marginal) / L-S43d-3 (VF-5 disagreement emptiness when bull Rule-7 honest-insufficient is substrate-not-bug)
  - **0 NEW SCOPE-tier; 0 NEW IMPL-tier decision file** (per L-S15-1 inline-document doctrine)
  - **D1=0 sustained**; LLM-math creep grep 0 hits in theses; D9 charter md5 unchanged; I-S1/2/5/10/35 ALL ✅ across 5 theses
  - **Self-track main this turn**: ~110-150K within FOCUSED_IMPL 100-150K target (high end due to repeated dogfood progress polling)
  - **External subscription burn**: ~$6.84 (5-thesis dogfood; D-023 $0-marginal substrate)
  - **Routing**: NEXT session = S43e — (a) Q10 envelope amendment ADR (now ripe with $6.84 actual + Phase 2 cumulative refresh) / (b) VF-5 disagreement-detector calibration (FPT bull 5pts vs 4×0pts root cause) / (c) VF-3 reproducibility test / (d) 5 promote-rule queued actions ~118 LOC (C5+C4+C3 cheap; C1 needs deny-lift; C2 charter-tier USER-GATE) / (e) Resume Phase 2 critical path — Track A/B/C/D/F all DONE, Track E S38/S39/S40 PARALLEL non-blocking. **NO COMMIT** (per CLAUDE.md + S43c user "git thì không cần release, bỏ qua" carry-forward)

- **S43c — Q&A 2026-05-01-003 mega-bundle apply + HR-4 ratify + 7 NEW ADRs + Q8 hook fix + Q9 spec amend (DONE — FOCUSED_IMPL — 2026-05-04)** per user verbatim "tôi accept toàn bộ q&a recommend của agent và các đề xuất còn đang block. git thì không cần release, bỏ qua":
  - **Q&A 003 inline answers**: Q1=A Q2=A Q3=A Q4=A Q5=A Q6=A Q7=a (deferred next session) Q8=A Q9=A Q10=A applied inline; status flipped pending → answered-2026-05-04-via-chat (awaiting user mv to answered/)
  - **6 charter amendments via S38 deny-lift mechanism** (Edit `.claude/settings.json` deny lines 96+105 lifted → applied amendments → restored deny → verified zero-residue):
    - Q1: `constitution/architecture.md` += "Slash Command vs Skill — Responsibility Split" (D-018) bundling L-S14-2 + L-S16-1 + L-S18-1 + L-S19-1
    - Q2: `constitution/financial-data-protocol.md` += Rule 11 Hook Portability (D-019)
    - Q3: `constitution/session-budgets.md` += "Mode A/B/C/D — Cliff vs Injector Dispatch" + Verifier Budget by Scope (D-020)
    - Q4: `constitution/financial-data-protocol.md` += VN Rules 12-15 (T+2.5 / Room Ngoại / Sàn HOSE-HNX-UPCoM tiering / FX point-in-time) (D-021)
    - Q5: `constitution/invariants.md` += I-S55..I-S65 (11 NEW invariants) (D-022; gated on D-021)
    - Q6: `constitution/autonomous-protocol.md` += "Rule 9 — Cost Substrate" (D-023; subagent-first $0 marginal)
  - **HR-4 charter ratification**: `mv proposals/memory-routing-tree.md → constitution/memory-routing-tree.md`; frontmatter status PROPOSAL→CHARTER; companion hook `scripts/hooks/memory-routing-audit.sh` wired into `.claude/settings.json` Stop chain between lesson-synthesis-watchdog + promotion-cycle-trigger (D-024)
  - **7 NEW ADRs** D-018 through D-024 authored (~60-90 LOC each; 12-field schema; provenance chains intact)
  - **Q8 IMPL-S35-1 hook regex fix**: `scripts/hooks/promotion-cycle-trigger.sh` line 22 LATEST_SESSION extraction — replaced whole-file `grep -oE 'S[0-9]+'` (caught L-S*/I-S*/KI-S*/BP-S*/IMPL-S*) with `**Session N**:` line-scoped extraction. Smoke-tested: now reports `latest_session=43` correct (was inflated). Hook legitimately HARD-BLOCKs delta=8 since S35 — separate concern (next session promote-rule dispatch needed)
  - **Q9 spec 006 § B.10 cost amendment**: amended `Target average: $1.30/thesis` → `$0.90/thesis` (S42 actual; ~31% cheaper than estimate; Phase1Synthesizer fully deterministic per § A.6.1); revised dogfood + monthly band; cross-references D-023 cost-substrate for future "$0 marginal" trajectory
  - **Q7=a S43b LIVE-via-subagent DEFERRED to next session** (per Q&A 003 Q7=a explicit pick; ~150-200K subagent dispatch budget; needs SubagentLLMPerspectiveAdapter authoring + 5-thesis dogfood BID/BVH/CTG/FPT/GAS)
  - **Q10 envelope amendment ADR DEFERRED** post-S43b close (per Q&A 003 Q10=A — documents calibration delta after dogfood lands)
  - **Stop hook chain**: 18 → 19 hooks (+memory-routing-audit.sh wired between lesson-synthesis-watchdog + promotion-cycle-trigger)
  - **Stage 2 lesson-synthesis HR-6 first live dispatch validated this turn**: lesson-synthesizer subagent ran 60K tokens / 22 tool uses / 144s → wrote KI-S43b-8 (ghost-work pre-flight) + BP-S43b-8 (`⚠️ unverified` markers mandatory first-action) + L-S43b-11 + observation file. Loop closes end-to-end: dormancy → dispatch → fresh entries → mtime updated → next HR-1 fire clears
  - **Substrate residue UPDATED**: HR-4 ✅ RATIFIED (was DRAFTED + GATED); HR-6 ✅ LIVE-VALIDATED (was AUTHORED + AWAITING-OPT-IN); HR-1/2/3/5/7/8 unchanged ✅ DEPLOYED
  - **0 NEW SCOPE-tier (all picks were pre-existing user-gate-recommended)**; **7 NEW IMPL/CHARTER-tier ADRs (D-018..D-024)**; **0 NEW lesson candidates** (this is rule-application, not rule-discovery)
  - **Self-track main this turn**: ~140-180K (4 Q&A reads + 6 proposal reads + 5 constitution reads + 11 inline edits + 6 charter edits + 7 ADR writes + 1 hook patch + 1 spec amend + state edits + smoke test + HR-6 subagent dispatch overhead)
  - **External subscription burn**: ~$0 (HR-6 subagent dispatch billed against Claude Code subscription per D-023)
  - **Routing**: NEXT session = Q7=a S43b LIVE-via-subagent (write SubagentLLMPerspectiveAdapter + 5-thesis dogfood BID/BVH/CTG/FPT/GAS) OR resume Phase 2 critical path per pending-Q7 detail. Promote-rule subagent dispatch ALSO due (delta=8 since S35 trigger). **NO COMMIT** (per CLAUDE.md hard rule + user "git thì không cần release, bỏ qua")

- **S43b-EVIDENCE + HARNESS-RECOVERY (DONE — FOCUSED_IMPL pivoted mid-turn to CHARTER-TIER recovery — 2026-05-01)** per user verbatim "fix toàn diện" after audit caught dormant self-upgrade loop:
  - **Part 1 — quant TA wiring (DEFER-S43b-5 mitigation)**:
    - EDIT `packages/infrastructure/analysis/phase1_data_gatherer.py` (+12 LOC) — imports `compute_ta_features`; populates `ctx.ta_features` + `ctx.ta_audit`; gap `ta_insufficient` when no quotes
    - TRACK (was untracked) `packages/domain/market_data/services/ta_service.py` (164 LOC; 15 tests passing) + `packages/domain/market_data/test_ta_service.py` (163 LOC) — authored prior partial session, now wired
    - NEW `packages/infrastructure/analysis/test_phase1_data_gatherer.py` (~95 LOC; 3 tests covering populated + insufficient + audit)
    - Adapter `_context_to_str` already had `[TA Features]` block renderer (pre-existing)
    - Tests: 443 PASS / 3 SKIP / 0 regressions in 14.16s [+18 NEW vs S43b-BULL 425]; mypy --strict 0 errors; ruff clean
    - Live FPT dogfood (run 6): `recommendation=watch confidence=medium cost=$1.4375` — quant grounded points VALIDATION DEFERRED (need to read thesis-log/2026-05-01-FPT.md run 6)
  - **Part 2 — harness recovery (engaged when user pivot landed)**:
    - 6-task list A-F all completed: (A) handoff checkpoint written; (B) 6 NEW KI entries + 6 NEW BP entries to self-awareness/known-issues.md + best-practices.md; (C) 7 NEW agent-notes.md entries documenting S43b arc lessons; (D) drift hook health diagnosed (healthy; `.drift-signals.log` active 2159 lines; `drift-logs/` is separate manual-report surface — documentation gap not bug); (E) pre-/clear handoff invariant codified (BP-S43b-6 + KI-S43b-6); (F) `promotion-cycle-trigger.sh` WIRED into Stop hook chain in `.claude/settings.json` (was TODO'd in script header; smoke-test confirmed HARD-BLOCK alert fires correctly with delta=30 sessions since last promote)
  - **0 NEW SCOPE-tier; 0 NEW IMPL-tier decision file** (per L-S15-1 inline-document — all changes documented in checkpoint + agent-notes + KI/BP entries)
  - **8 NEW lesson candidates L-S43b-1 through L-S43b-8** (per-role model override / prose-tolerant JSON / wire-via-gatherer / lesson-synthesis-stage-2-dead / project-vs-user-memory routing / pre-clear handoff invariant / drift-summary-promotion gap)
  - **Substrate residue (UPDATED post-second-half-of-turn — verified at SessionStart resume 2026-05-01)**:
    - HR-1: ✅ DEPLOYED `scripts/hooks/lesson-synthesis-watchdog.sh` (Stop priority 12); smoke-tested clean. LLM-based lesson-synthesizer subagent reclassified as HR-6 (Phase 3 candidate)
    - HR-2: ✅ DEPLOYED `scripts/hooks/pre-clear-handoff-guard.sh` (Stop priority 1, before aggregator); smoke-tested clean. Hard-block JSON deny-decision tracked as HR-7 (advisory-only currently)
    - HR-3: ✅ DEPLOYED `scripts/hooks/drift-rollup-daily.sh` (107 LOC; Stop hook after promotion-cycle-trigger). Idempotent (skips when raw .drift-signals.log not newer than rollup mtime). Smoke-tested 2026-05-01 19:50: rolled up 621 today entries (HIGH=59 / MEDIUM=546 / LOW=16 / 26 distinct files); rollup written to `agent-workspace/memory/drift-logs/2026-05-01-rollup.md`. Two-surface confusion (KI-S43b-* / L-S43b-8) now structurally resolved.
    - HR-4: ✅ DRAFTED + 🔒 GATED-HUMAN-APPROVAL — proposal at `agent-workspace/proposals/memory-routing-tree.md` (Q1/Q2/Q3 tree + 4 hard rules) + companion deterministic hook `scripts/hooks/memory-routing-audit.sh` DRAFTED (93 LOC; smoke-tested green default + forced-trigger; UNWIRED pending ratification). On charter ratification: (a) move proposal to `constitution/`, (b) add hook entry to `.claude/settings.json` Stop chain after lesson-synthesis-watchdog. All autonomous portions complete.
    - HR-5: ✅ VERIFIED — bear case improved 3→5 grounded points heavily citing TAFeatures (SMA_50/SMA_200/RSI_14/pct_off_52w_high/realized_vol_90d_annualized); quant STILL 0 points (gated on Phase 3 peer_comparables + percentiles per spec § A.10); bull STILL 0 points (data-availability gap, not substrate)
    - HR-6: ✅ AUTHORED — `.claude/agents/lesson-synthesizer.md` (117 LOC, under 200 ceiling). Fresh-context subagent: reads session diff + recent KI/BP/agent-notes, proposes ≥1 new entry following surface schemas, writes observation file for HR-1 cross-check. HR-1 watchdog ALERT now references this subagent as automated path. Loop closed: dormancy detected (HR-1) → dispatch (this subagent) → entry written → next HR-1 fire sees fresh mtime → cleared. Live LLM dispatch to test on this session deferred to user opt-in (avoids surprise $ burn).
    - HR-7: ✅ DEPLOYED — `pre-clear-handoff-guard.sh` upgraded with opt-in hard-signal via `exit 2` gated on `STOCKFORGE_HANDOFF_HARDBLOCK=1` OR `STOCKFORGE_HOOK_PROFILE=strict`. Default behavior unchanged (advisory exit 0). 4-mode smoke matrix passes: (A) default+pending+stale→ALERT stderr/exit 0; (B) strict profile→ALERT+exit 2; (C) HARDBLOCK flag→ALERT+exit 2; (D) pending+fresh checkpoint→no alert/exit 0. Loop finite (≤1 hard-block per triggering pattern; agent writes checkpoint → next Stop auto-unblocks).
    - HR-8: ✅ DEPLOYED `scripts/hooks/harness-recovery-dod-watchdog.sh` (this turn — addresses KI-S43b-7 premature-stop chain). Parses `current-execution.md` for pending markers within HR-* lines; ALERT stderr in default mode; exit 2 in strict mode (`STOCKFORGE_DOD_HARDBLOCK=1` OR `STOCKFORGE_HOOK_PROFILE=strict`). Wire into settings.json Stop chain.
    - **SessionStart 2026-05-01 resume verification**: recovery artifacts confirmed on disk — KI-S43b-4/5/6 + BP-S43b-3/4/5/6 + 7 NEW agent-notes entries 2026-05-01 + drift-hook diagnosed healthy + hooks HR-1/HR-2 deployed + smoke-tested. **Phase 2 resume precondition MET** (Stage 2 lesson-synthesis-watchdog active + Stage 3 promotion-cycle-trigger wired)
    - **DoD CHECKLIST (per BP-S43b-7)**: HR-1 done / HR-2 done / HR-3 done / HR-4 drafted-gated-human / HR-5 done / HR-6 authored-awaiting-live-dispatch-opt-in / HR-7 done / HR-8 done. **All autonomous portions complete.** Outstanding: HR-4 ratification (charter human gate); HR-6 live LLM-dispatch test (cost gate, ~$0.10-0.30 sonnet on this session diff).
  - **External subscription burn this turn**: ~$1.44 (single FPT dogfood run 6)
  - **Self-track main this turn**: ~110-150K (deep audit + TA wiring + tests + dogfood + 5 state file edits + 6 KI + 6 BP + 7 agent-notes + hook wire + smoke test)
  - **Routing**: NEXT session — verify recovery via SessionStart pre-flight per checkpoint § Handoff; build HR-1+HR-2+HR-3 before resuming Phase 2 critical path; **NO COMMIT** (production + state files staged only, await user-explicit commit instruction)

- **S43b-BULL (DONE — FOCUSED_IMPL — DEFER-S43b-3 RESOLVED via per-role model override; bull haiku replaces bull sonnet — 2026-05-01)** per user "ok. try to keep autonomous full" pick of S43b-FRESH § Routing option (a):
  - **Adapter EDIT**: `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` (+~10 LOC) — added `_HAIKU_MODEL = "claude-haiku-4-5"` constant + Haiku entry in `_COST_PER_MTOK` ($1.00/$5.00 per Anthropic public pricing); added `role_model_overrides: dict[PerspectiveRole, str] | None = None` field on `ClaudeLLMPerspectiveAdapter` dataclass; resolution order in `call_llm`: `model_override → role_model_overrides[role] → _ROLE_TO_MODEL[role] → _DEFAULT_MODEL`
  - **Wiring EDIT**: `apps/_shared/use_case_builder.py::_build_subagent_agents` (+~10 LOC) — passes `role_model_overrides={PerspectiveRole.BULL: "claude-haiku-4-5"}` to adapter; docstring documents DEFER-S43b-3 rationale (bull sonnet 300s timeout reproduced 2/2 dogfood; haiku faster + cheaper + sufficient for bull's evidence-gathering task)
  - **NEW tests**: `packages/infrastructure/analysis/test_adapter.py` (~115 LOC; 8 tests) — covers default routing for 3 roles, role-override leaving non-targeted roles intact, global model_override beating role override, Haiku cost computation correctness, end-to-end haiku cost via call_llm path, fallback when role missing from overrides
  - **Tests**: 425 PASS / 3 SKIP / 0 regressions in 14.18s [+8 NEW; was 417 post-S43b-FRESH]; mypy --strict + ruff 0 errors on touched files (1 ruff fixed: redundant Any quotes)
  - **Live FPT dogfood (run 5)**: `python -m apps.cli.validate_thesis --ticker FPT --as-of 2026-05-01 --no-mock-llm --transport subagent` → no bull timeout this run; thesis written; recommendation=watch, confidence=medium, cost=$1.294525 (was $0.953 with bull timeout in S43b-FRESH; +$0.34 for the haiku call that actually completed); bear=3 points (was 4; LLM stochasticity); bull=0 points (no timeout — honest Rule-7 insufficient given 90d-no-positive-news context); quant=0 points (same as S43b-FRESH — honest Rule-7 insufficient given no TA-features in SharedContext)
  - **Substrate**: 3/3 perspectives now execute end-to-end without timeout. The remaining 0-bull / 0-quant point counts are **semantic** (Rule 7 honest "insufficient" verdicts given current SharedContext content), **NOT substrate bugs**. The orchestrator correctly accepts these as valid honest outputs per spec § B.5.1 Rule 7.
  - **DEFER-S43b-3 RESOLVED**: bull no longer times out; per-role model override pattern is the production-grade fix
  - **DEFER-S43b-4 RECLASSIFIED**: was "quant 0-points cause unclear" → now confirmed semantic-not-bug. Promoted to **DEFER-S43b-5**: enrich SharedContext with bull-side evidence (positive 90d news / peer comparables) + quant TA features (RSI/SMA/Bollinger from bar history) so bull+quant have material to ground points. Out-of-scope this turn; spec § A.10 amendment candidate.
  - **0 NEW SCOPE-tier; 0 NEW IMPL-tier decision file** (per L-S15-1 inline-document — adapter +10 LOC + builder +10 LOC + test 115 LOC; no LOC deviations)
  - **0 NEW lesson candidates** (per-role model override doctrine recorded inline in adapter docstring; specific to claude CLI subprocess + sonnet-bull-prompt-pairing edge case)
  - **External subscription burn this turn**: ~$1.29 (single FPT dogfood; bear sonnet + bull haiku + quant opus all completed)
  - **Self-track main this turn**: ~40-55K (adapter edit + builder edit + test write + test run + live dogfood + thesis read + 3 state file edits)
  - **Routing**: NEXT = (a) S43b-EVIDENCE — implement DEFER-S43b-5 (extend SharedContext + gatherer with bull-side news filter by sentiment + RSI/SMA TA features computed in BC-1 service) + re-fire FPT dogfood expecting populated bull+quant cases; ~80-120K + ~$0.40 dogfood; OR (b) S39-IMPL gates on Q&A 003; OR (c) ratify S43b-* arc as "substrate proven" + return to Phase 2 master-plan critical path (S43 = Track F final dogfood)

- **S43b-FRESH (DONE — FOCUSED_IMPL — non-bank end-to-end dogfood; substrate fully proven for general-corporate path — 2026-05-01)** per user "continue" + checkpoint S43b-DATA next-action recommendation:
  - **Pre-flight (L-S30-1)**: 20/20 subagent_transport unit tests PASS in 0.02s (extractor refactor untouched); SQLite data inventory confirmed FPT viable: 496 bars (2025-05-05→2026-04-29) + bs/cf/is statements (4 each, period_end 2026-03-31) + 5 news articles tagged FPT in 90d window (vs BID's stale-news 0/90d gap)
  - **Live FPT dogfood**: `python -m apps.cli.validate_thesis --ticker FPT --as-of 2026-05-01 --no-mock-llm --transport subagent` → thesis written to `agent-workspace/memory/thesis-log/2026-05-01-FPT.md`; recommendation=`watch`, confidence=`medium`, calibration_grade=D, cost_usd=$0.953070, real_thesis=false (Phase 2 has no calibration), disclaimer_present=true
  - **Bear case COMPLETE per I-S10**: 4 grounded bear points produced (≥3 required), each citing source_url + as-of date per I-S2; conviction strong/moderate/moderate/weak; covers (1) 90d news blackout structural blind-spot, (2) absent P/E + P/B vs 75500 VND close = unverifiable entry multiple, (3) DEBT_EQUITY 0.7094 hides liability composition + maturity + FX-mismatch risks, (4) absent peer-comparables on ROE 0.27 / NET_MARGIN 0.17 — **all 4 numbers from code (RatioService TTM), not LLM math; I-S1 preserved**
  - **Substrate fully validated end-to-end (deepest layer + general-corporate case)**: ✅ subprocess + OAuth (no API key) + UTF-8 decode + 3-pattern JSON extractor (prose + fenced/bare/passthrough) + parallel asyncio.gather + DB-backed `_SubagentDataGatherer` (BC-1 bars + BC-2 fundamentals + BC-5 news/claims) + adapter context_to_str (news fallback when claims=0) + RatioService (non-bank schema works) + thesis-log write + I-S2 source-citation + I-S10 ≥3 bear + I-S35 disclaimer + cost ledger ($0.95 bubbled correctly, no longer $0 from error path)
  - **2 RESIDUE items (NOT blockers; same as S43b-DATA carry-over)**:
    - DEFER-S43b-3 ACUTE: bull sonnet call 300s timeout reproduced 2/3 dogfood runs (was 1/1 BID, now 1/1 FPT) → bull case EMPTY in thesis output → next-step Q-S43b-1 (haiku fallback per role OR longer timeout OR shorter system_prompt)
    - DEFER-S43b-4 NEW: quant_opus call returned 0 quant_points despite no timeout — either honest "insufficient" verdict (likely; bundle has only TTM ratios + BS, no bar-history TA features yet) OR parse silently dropped (less likely; bear came through fine). Investigation needed: log raw_text snippet for quant role on next dogfood
  - **Tests**: 417 PASS / 3 SKIP / 0 regressions (same as S43b-DATA — no source code modified this turn)
  - **0 NEW SCOPE-tier; 0 NEW IMPL-tier decision file; 0 NEW lesson candidates** (substrate-validation dogfood; no source modifications; pure execution + state update)
  - **External subscription burn this turn**: ~$0.95 (single FPT dogfood; 1× quant_opus full + 1× bear_sonnet full + 1× bull_sonnet partial-then-timeout)
  - **Self-track main this turn**: ~25-40K (pre-flight tests + DB inventory + 1 live dogfood + thesis read + 2 state file edits + 1 checkpoint write + 1 session log)
  - **Routing**: NEXT = (a) S43b-BULL — fix DEFER-S43b-3 by adding role→model override (haiku for bull) OR per-role timeout config (extend bull to 600s); ~30-50K; OR (b) S43b-QUANT — diagnose quant 0-points by adding raw_text snippet logging on quant role + re-fire FPT to see if quant returns honest "insufficient" envelope (~$0.40); OR (c) S39-IMPL gates on Q&A 003; OR (d) idle

- **S43b-DATA (DONE — FOCUSED_IMPL — DB-backed data gatherer + prose-tolerant JSON extractor + 3rd live dogfood — 2026-05-01)** per user "continue" pick after S43b-LIVE-PROOF:
  - **Wiring SHIPPED**: `_SubagentDataGatherer` (~85 LOC inline in `apps/_shared/use_case_builder.py`) reads `data/stockforge.sqlite` via SqliteBarRepository.get_as_of / SqliteFundamentalRepository.get_as_of / SqliteNewsRepository.get_known_as_of / SqliteClaimRepository.get_for_ticker; computes ratios via RatioService (price=None → P/E and P/B skipped); deterministic md5 over canonicalized payload; `gaps` propagation
  - **Adapter context_to_str extended**: `claude_llm_perspective_adapter.py` _context_to_str now surfaces `recent_news` (title + source_url + published_at + body_excerpt) when `recent_claims` empty — gives LLM grounded provenance to cite (≥10 LOC EDIT)
  - **JSON extractor refactored**: `subagent_transport._unwrap_fence` now handles 3 patterns (was 1): prose preamble + ```json fence (LAST fenced block taken), bare {...} after prose (brace-depth scan with string escape), pure prose (passthrough). 5 NEW tests cover each branch. 20 tests total PASS
  - **Adapter diagnostic**: claude_llm_perspective_adapter.py logs raw_text[:600] snippet on JSONDecodeError — surfaced the prose-preamble pattern that drove the extractor refactor
  - **Live BID dogfood (run 3, post-data-wire)**: 4 LLM calls (3 + 1 bear retry); 1 bull call hit 300s subprocess timeout (sonnet + this prompt is slow); other 3 returned valid JSON envelopes wrapped in prose preamble — JSON correctly says "INSUFFICIENT_BEAR_CASE" because: (a) BID is a BANK; RatioService can't compute net_margin/ROE/ROA/D/E from bank-specialized statements (BS/IS line items don't map); (b) News articles in DB published >90d before 2026-05-01 → `gaps=['no_news_90d']` correctly flagged; LLM honestly invokes Rule 7 ("Insufficient bear case is a valid honest output"); thesis correctly INCOMPLETE per I-S10 (≥3 distinct bear points required)
  - **Substrate validated to deepest layer**: ✅ subprocess + OAuth + UTF-8 + JSON envelope + prose-tolerant extraction + parallel asyncio.gather + DB-backed gatherer + adapter integration + thesis-log write + I-S10 invariant enforcement + LLM honest "insufficient" path
  - **NOT a substrate failure**: thesis INCOMPLETE due to DATA QUALITY (bank schema + news age), NOT substrate. Substrate path COMPLETE for general-stock case (non-bank, fresh news). Dogfood with non-bank ticker (FPT/GAS/BVH) likely produces COMPLETE thesis
  - **Tests**: 417 PASS [+5 NEW extractor tests; was 412] / 3 SKIP / 0 regressions in 14s; mypy + ruff clean on all 4 modified files; 20/20 subagent_transport unit tests PASS
  - **0 NEW SCOPE-tier; 0 NEW IMPL-tier decision file** (~85 LOC NEW + ~10+25+5 EDIT; under deviation thresholds; per L-S15-1 inline-document)
  - **0 NEW lesson candidates** — Windows cp1252 fix + prose-tolerant extractor patterns recorded inline in subagent_transport.py docstring
  - **External subscription burn this turn**: ~$1.20-2.00 estimated across 3 dogfood runs (some calls timed out, some returned non-JSON pre-extractor-fix; cost ledger says 0 due to adapter error path)
  - **Self-track main this turn**: ~50-70K (data gatherer wiring + extractor refactor + diagnostic logging + 1 live dogfood + state file edits)
  - **Routing**: NEXT = (1) test extractor on real LLM via 1-call probe with non-bank ticker (verify prose-tolerant works end-to-end with COMPLETE thesis); (2) for COMPLETE thesis dogfood need EITHER non-bank ticker (FPT/GAS) OR fresh news ingest (CafeF re-run within last 90d); (3) S39-IMPL still gates on Q&A 003 user pick; (4) optional: extend RatioService for bank schema (separate spec amendment per Q-S28-3 doctrine)

- **S43b-LIVE-PROOF (DONE — FOCUSED_IMPL — substrate end-to-end verified — 2026-05-01)** per user pick "(b)" after S43b PARTIAL:
  - **Wiring SHIPPED**: `apps/_shared/use_case_builder.py` `+transport` parameter (validates `("anthropic", "subagent")`) + new `_build_subagent_agents()` helper (~25 LOC) wiring real `BearPerspectiveAgent`/`BullPerspectiveAgent`/`QuantPerspectiveAgent` + `ClaudeLLMPerspectiveAdapter(transport=claude_cli_transport)`; `apps/cli/validate_thesis.py` `--transport=anthropic|subagent` flag passed through (~5 LOC)
  - **Bug found + fixed during dogfood**: Windows cp1252 decode crash on subprocess stdout — parent Python `subprocess.run(..., text=True)` defaulted to cp1252; claude CLI returns UTF-8 (Vietnamese diacritics + em-dashes in CLAUDE.md auto-discovery). Fix: `encoding="utf-8", errors="replace"`. 1-line change in `subagent_transport.py`. 15/15 tests still PASS.
  - **Live BID dogfood result**: pipeline END-TO-END VERIFIED — CLI invoked use_case → real Bear/Bull/Quant agents → adapter → claude CLI subprocess (3 parallel sonnet/sonnet/opus) → JSON envelope parsed → markdown written `agent-workspace/memory/thesis-log/2026-05-01-BID.md`; thesis status INCOMPLETE due to **data grounding gap** (MockDataGatherer has no `recent_claims`/`source_url` → system_prompt "EVERY CLAIM CITES SOURCE_URL" forces honest "Insufficient bear case" → 0 cited points → I-S10 correctly fails); wall 286s (post-fix); cost_usd 0 in ledger (adapter error path returns Decimal(0); CLI-reported actual unknown ~$0.05-0.30 estimated)
  - **Substrate validated**: ✅ subprocess + OAuth (no API key) + JSON envelope + UTF-8 decode + parallel asyncio.gather + adapter integration + thesis-log write + I-S10 invariant enforcement
  - **NOT validated** (next gap): real Phase1DataGatherer wiring (BC-1 SqliteBarRepository + BC-2 VnstockFundamentalRepository + BC-2 RatioService + BC-5 SqliteNewsRepository + BC-5 SqliteClaimRepository); requires NEW `_build_subagent_data_gatherer()` ~30 LOC; data already in `data/stockforge.sqlite` per S43a Stage A (2480 bars + 44 statements + 159 articles for 5 tickers); claims = 0 (gated on LLM extractor running, which itself can use subagent transport)
  - **Tests**: 412 PASS [unchanged from S43b PARTIAL] / 3 SKIP / 0 regressions in 14s; mypy + ruff clean on 4 modified files
  - **0 NEW SCOPE-tier; 0 NEW IMPL-tier decision file** (~25+5+1 = 31 LOC EDIT total; well under deviation threshold)
  - **0 NEW lesson candidates** — Windows cp1252 fix recorded inline in subagent_transport.py docstring; not promoted (specific to Windows + subprocess; existing L-S15-1 inline-document doctrine sufficient)
  - **Drift**: D1=0; LLM-math creep grep 0 in modified files; D9 unchanged
  - **Self-track main this turn**: ~50-70K (probe + IMPL + tests + 2 dogfood live runs + research note + 4 state file edits; within FOCUSED_IMPL 100-150K)
  - **Routing**: NEXT = (1) wire real Phase1DataGatherer for subagent path (~30 LOC + tests) → re-fire BID dogfood with real grounded data → expected COMPLETE thesis with ≥3 bear key_points; (2) optionally extend transport to also handle BC-5 ClaimExtractor (LLM-based news → claim extraction) for full data pipeline; (3) S39-IMPL gates on Q&A 003 user pick

- **S43b (PARTIAL — superseded by S43b-LIVE-PROOF row above — kept for audit)** per checkpoint § "User insight mid-S38" + L-S38-2 lesson candidate + user "continue" 3× directive:
  - **Probe (live)**: `claude -p --model haiku --output-format json --disable-slash-commands --system-prompt ...` returns structured JSON envelope with `total_cost_usd` + `usage.{input_tokens, output_tokens, cache_creation_input_tokens, cache_read_input_tokens}`. Auth = parent OAuth/keychain (no ANTHROPIC_API_KEY required). Latency 26s wall / haiku call. Cost $0.041/call (heavy CLAUDE.md cache_creation). Response wrapped in ```json fence — strippable. `--bare` mode strictly demands env var, so OAuth-friendly path is non-bare.
  - **IMPL**: `packages/infrastructure/analysis/subagent_transport.py` 130 LOC (module) + `test_subagent_transport.py` 175 LOC (15 unit tests, mocked subprocess) — both under ≤180 advisory; 0 LOC deviations
  - **Drop-in compatibility**: same `(model, system_prompt, user_message, temperature) -> (text, in_tok, out_tok)` signature as existing `_default_transport`; opt-in via constructor `ClaudeLLMPerspectiveAdapter(transport=claude_cli_transport)`; existing default unchanged
  - **Trade-off**: no `--temperature` flag in CLI → AC-5 reproducibility downgraded to "best-effort"; `prompt_hash` + model_id pinning preserved
  - **Cost reframe — 5-thesis dogfood**: $7.50 (anthropic SDK direct, Opus quant+2× Sonnet) → ~$0.60 (haiku all 3) or ~$2.00 (sonnet+sonnet+opus); bills against subscription
  - **Tests**: 412 PASS [+15 NEW; was 397 post-S38] / 3 SKIP / 0 regressions in 14s; mypy --strict + ruff 0 errors on 2 new files
  - **0 NEW SCOPE-tier; 0 NEW IMPL-tier decision file** (L-S15-1 inline-document — module + tests both under advisory; no separate ADR)
  - **0 NEW lesson candidates this session** — L-S38-2 RATIFIED as production substrate
  - **L-S30-1 VBW pre-flight APPLIED** — read existing adapter + port + perspectives/ before Write; confirmed transport injection point at line 164
  - **Drift sweep**: D1=0 sustained; D-INTENT preserved (substrate path matches user 2026-05-01 chat directive); LLM-math creep grep 0 hits in new module/tests; D9 charter md5 unchanged
  - **NEXT (deferred)**: (1) `apps/cli/validate_thesis.py` flag `--transport=subagent` ~10 LOC; (2) live 1-ticker dogfood (BID, ~$0.12 / ~80s wall — defer to user explicit go); (3) optional spec § A.10 amendment for AC-5 reproducibility downgrade
  - **Research note**: `agent-workspace/research/r-2026-05-01-claude-cli-substrate.md` (full probe + IMPL summary)
  - Self-track main this turn ~50-70K (probe + IMPL + tests + docs; within FOCUSED_IMPL 100-150K target)

- **S39 (PARTIAL — FOCUSED_IMPL — Track E Bundle 2 SCOPE amendments compose — 2026-05-01)** per master-plan 005 § S39:
  - Q&A bundle composed: `human-workspace/q-and-a/pending/2026-05-01-003-S39-track-E-bundle-2-scope-amendments.md` (3 SCOPE questions + mechanism note)
  - 3 amendments target EXISTING constitution files (Edit semantics, not mv — different from S38 Bundle 1):
    - Q1: architecture-amendment.md (98 LOC) → append NEW § "Slash Command vs Skill — Responsibility Split" to architecture.md (L-S14-2 codification)
    - Q2: financial-data-protocol-amendment.md (42 LOC) → append NEW § "Rule 11 — Hook Portability Per Phase" to financial-data-protocol.md (L-S11-1 codification)
    - Q3: session-budgets-amendment.md (74 LOC) → append NEW § "Mode A/B/C/D — Cliff vs Injector Dispatch" to session-budgets.md (D-004 thresholds canonicalization)
  - Notification posted: `human-workspace/notifications/N-2026-05-01T22-30-INFO-S39-bundle-2-pending.md`
  - Mechanism precedent: same as S38 Q4=B (direct settings.json deny lift+restore; settings.local.json approach impossible per deny>allow precedence)
  - **S39-IMPL waits on user answers** to 2026-05-01-003 → execute apply + author D-018/D-019/D-020 + lifecycle (~30-50K main; governance-only; no production code)
  - 0 NEW deviations / 0 NEW SCOPE / 0 NEW lessons (compose-only step)
  - Self-track main this turn ~10-15K (compose-only; the bigger spend is S39-IMPL after user answers)

- **S38 (DONE — FOCUSED_IMPL — Track E Bundle 1 charter promote — 2026-05-01)** per master-plan 005 § S38 + Q&A 2026-05-01-001 user pick (Q1=A Q2=A Q3=A Q4=B):
  - 3 charter promotes via `mv proposals/* → constitution/*`: autonomous-protocol.md (127 LOC) + decision-discipline.md (111→~135 LOC with Rule 2 sub-clause + Rule 4a augmentation) + memory-tiers.md (87 LOC); all 3 frontmatter status PROPOSAL → CHARTER + ratifying_decision pointer
  - 3 NEW ADRs: D-015 (autonomous-protocol promote) + D-016 (decision-discipline + Rule 2 L-S26-1 sub-clause + Rule 4a phase-boundary trigger) + D-017 (memory-tiers + tier1-bloat-check.sh hook)
  - 1 NEW hook: `scripts/hooks/tier1-bloat-check.sh` 49 LOC — bash+wc; ≤50ms; soft-WARN at SessionStart if Tier 1 bootstrap >8K. **Smoke test fired immediately on real state**: 23,952 tok vs 8K ceiling (current-execution.md alone = 18,490 tok)
  - File-move mechanism (Q4=B applied as-actually-implementable): edited `.claude/settings.json` to temporarily remove 2 constitution deny lines (Write+Edit) → did mv + augmentation Edits → restored 2 deny lines. Verified post-restore: settings.json contains constitution deny again. Per memory `wildcard_permissions_preference.md` deny>allow precedence, settings.local.json approach impossible — only direct settings.json Edit works
  - D-013 status updated PARTIAL-ACCEPTED → ACCEPTED (charter subset ratified)
  - Q&A 2026-05-01-001 inline-answered (awaiting user mv to answered/)
  - 397 PASS sustained (Bundle 1 = pure governance promote; no production code touched; no test impact)
  - 1 NEW lesson candidate **L-S38-1**: current-execution.md historical session-rows bloat → trim/paginate to `agent-workspace/memory/sessions-rollup/<phase>.md` while keeping active phase rows; defer to Phase 2 close per Q-E2
  - 0 NEW IMPL-tier deviations (all 3 ADRs ≤155 LOC under ≤140 advisory by ≤11%; under D1 20%); 0 NEW SCOPE-tier
  - Self-track main ~30-50K within FOCUSED_IMPL 30-50K target (right on budget)
  - Constitution count: 9 → **12 files** (+3 ratified)

- **S43a-CODE (DONE — FOCUSED_IMPL — Track F UI Streamlit + CLI build via background sandwich-dev subagent dispatch — 2026-05-01)** per master-plan 005 § S43a + sub-plan 006-S41 § S43a:
  - 11 NEW staged in `apps/dashboard/` + `apps/cli/` + `apps/_shared/`: dashboard `__init__/main/test_smoke` (51+214 LOC), `pages/__init__/validate_thesis` (121 LOC), `components/__init__/thesis_card` (240 LOC IMPL-S43a-1 +33%), cli `validate_thesis` (330 LOC IMPL-S43a-2 +175%) + `test_validate_thesis` (498 LOC IMPL-S43a-4 +256%), `_shared/__init__/use_case_builder` (236 LOC IMPL-S43a-3 +136%) — 4 cosmetic LOC overruns inline-documented per L-S15-1; full mock-LLM scaffolding required > line budgets
  - 397 PASS + 3 SKIP (streamlit testing API absent — non-blocking) in 14s; +7 NEW tests over S42 baseline (390 → 397); 0 regressions; mypy --strict + ruff clean; D1 = 0 sustained
  - HARD BINDING confirmed by background subagent: NO live Anthropic code path imported; `_check_live_gate()` raises `BuildError`/NotImplementedError; mock_llm default True; ANTHROPIC_API_KEY absent → exit 4; key present + --no-mock-llm → exit 3 ("S43a-DOGFOOD gate pending")
  - I-S35 disclaimer: Streamlit banner + thesis card footer + CLI markdown footer + frontmatter
  - 2 SCOPE-tier user-gates (Q-S41-1 + Q-S41-2) RESOLVED in-session via AskUserQuestion: Q-S41-1 → **C** (Opus first 5 dogfood theses, reassess Phase 2 close); Q-S41-2 → **A** (charter-floor defaults; fill profile post-dogfood); D-014 § Open Questions edited; Q&A 2026-05-01-002 file inline-answered (awaiting user mv to answered/)
  - 0 NEW SCOPE-tier; 0 NEW IMPL-tier decision file (4 LOC overruns inline per L-S15-1); 0 NEW lessons; L-S30-1 + L-S15-1 APPLIED
  - S43a-DOGFOOD remains gated; user picked **Stage A: Ingest data only** routing — no API cost this turn

- **S43a-DOGFOOD Stage A (DONE — data ingest into unified `data/stockforge.sqlite` + 2 adapter/CLI fixes — 2026-05-01)** per user explicit pick at S43a entry AskUserQuestion + follow-up "(a) full autonomous continue" pick:
  - Tickers (default per Q-S43a-1; user didn't override): `[BID, BVH, CTG, FPT, GAS]` (first 5 VN30 alphabetical excl VHM)
  - Bars ✅: 2480 rows × 5 tickers × 2 providers reconciled HIGH; `data/s43a-bars-summary.md`
  - Fundamentals: initial run = 0 (vnstock 4.0.x WIDE format vendor drift L-S28-1) → adapter pivot fix in `packages/infrastructure/fundamental/vnstock_fundamental_adapter.py` (+~50 LOC: `_PERIOD_COL_RE` regex + `_quarter_label_to_period_end()` + wide-format detection in `_iter_rows` + 8 NEW entries in `_VNSTOCK_LINE_ITEM_MAP`) → re-ingest = ✅ 44 statements × 5 tickers (BVH/FPT/GAS=12 each, banks BID/CTG=4 each due to specialized bank schema)
  - News: initial single-listing = 31 articles / 5 mentions → CLI fix in `apps/cli/ingest_news_cafef.py` (+~15 LOC: CSV `--listing` parser + URL dedup + per-listing degrade-gracefully) → multi-listing re-ingest = ✅ 159 articles / 15 ticker-mentions (BID=9, FPT=5, GAS=1, CTG=1, BVH=0 — thin coverage for BVH/CTG/GAS flagged as data-freshness caveat)
  - Claims = 0 (--skip-llm; reserved for LIVE step)
  - Verification: 397 PASS sustained (0 regressions; 12 existing fundamental adapter tests still PASS — long-format pathway preserved); mypy --strict + ruff clean on 2 modified files
  - 0 NEW SCOPE; 0 NEW IMPL-tier decision file (~65 LOC EDIT total; well under deviation threshold); 0 NEW lessons; L-S28-1 vendor-drift doctrine APPLIED 2nd time
  - LIVE gates STILL NOT met: ANTHROPIC_API_KEY absent + user $ authorization pending — S43a-DOGFOOD-LIVE blocks here

- **S41 (DONE — PLAN — Track F sandwich-architect subagent dispatch — 2026-05-01)** per master-plan 005 § S41 + autonomous_mode=true:
  - 5 success criteria per master-plan §S41: 5 PASS (frontmatter complete ✅; 3 system_prompts ≥40 LOC each with NO LLM math + source_url instructions ✅; cost profile target ≤$2 + hard cap $3 ✅; personal-risk-profile prereq surfaced in D-014 § Risks ✅; D-014 12 fields populated ✅)
  - Files (3 NEW + 1 EDIT):
    - NEW `specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md` ~620 LOC (vs ≤350 advisory = IMPL-S41-1 +77% deviation; densified Part B § B.5 system prompts verbatim + Part A § A.11 adversarial check + Part B § B.2-B.10 full architecture; under D1 20% threshold N/A — D1 only checks .claude/skills/commands/agents)
    - NEW `agent-workspace/memory/decisions/014-track-F-architecture.md` ~190 LOC (vs ≤140 advisory = IMPL-S41-2 +35% deviation; full 12-field schema + 3 options-considered + 2 SCOPE-tier user-gate Open Questions + 11-row Risks table)
    - NEW `agent-workspace/session-plans/pending/006-S41-track-F-impl-sub-plan.md` ~290 LOC (under ≤300 advisory; mirrors 004-S24-... format with S42 + S43a per-session deliverables matrix)
    - EDIT `agent-workspace/memory/current-execution.md` (this file) — appended Track F sub-plan reference + S41 row + 2 NEW routing rows (track f sub-plan + track f spec)
  - 2 SCOPE-tier user-gates flagged (per Q-B2 doctrine — `pending_user_gate: true` in D-014 § Open Questions):
    - Q-S41-1 — QuantAgent model: Opus (Recommended; $0.70/run) vs Sonnet ($0.20/run); user explicit-pick required before S43a dogfood
    - Q-S41-2 — personal-risk-profile.md fill timing: A=Proceed charter-floor (Recommended; non-blocking) / B=Block S42 until user fills / C=AskUserQuestion 1Q
  - 0 NEW IMPL-tier decision file (the 2 cosmetic LOC overruns are IMPL-S41-1 + IMPL-S41-2 inline-documented per L-S15-1; no separate ADR file — only D-014 SCOPE-tier ADR)
  - 0 NEW lesson candidates; L-S30-1 (VBW pre-flight) APPLIED — `Glob` confirmed `specs/tier2-feature/006-*.md` + `agent-workspace/memory/decisions/014-*.md` + `agent-workspace/session-plans/pending/006-*.md` all absent before Write; parent dirs all present
  - Drift sweep: D1=0 sustained; D4=0 (no forward refs created — S42 + S43a paths reference NEW packages not yet built per spec; that's expected, not regression); D9 carry-over unchanged; LLM-math creep grep 0 hits in spec/ADR/sub-plan
  - Self-track main ~30-45K within PLAN 50-80K target (subagent dispatch is this PLAN itself; combined ~50-80K from main + ~150-200K subagent envelope — within S41 master-plan budget of 50-80K main + ~150K subagent)

- **S36 (DONE — MULTI_TASK_IMPL — Track D BC-5 News Stream + CafeF + LLM claim-extraction — 2026-05-01)** per master-plan 005 § S36 + spec-T1-001 § B.2 + financial-data-protocol Rule 6/7/8:
  - 8 success criteria: 8 PASS (CLI shape ✅; Rule 6 provenance ✅; Sentiment categorical ✅; cost ceiling deferred via R6; no-framework-in-domain ✅; cross-BC=0 ✅; mypy+ruff clean ✅; D1=0 ✅)
  - Files (16 NEW production + 5 NEW test files + 2 EDIT contract barrels = 21 NEW + 2 EDIT; ~2,710 LOC):
    - NEW `packages/domain/news/` 12 files (482 LOC): models {news_article 72 / extracted_claim 82} + value_objects {sentiment 30 / extractor_metadata 62} + repositories {news_repository 56 / claim_repository 37} + services {claim_extraction_service 69} + barrels
    - NEW `packages/application/news/` 3 files (54 LOC): ports/llm_extractor_port 49 + barrels
    - NEW `packages/infrastructure/news/` 4 files (744 LOC): cafef_scraper 212 + claude_llm_extractor 225 + sqlite_news_repository 294 + barrel — IMPL-S36-1 +49% over ≤500 advisory
    - NEW `apps/cli/ingest_news_cafef.py` 306 LOC — IMPL-S36-2 +70% over ≤180 advisory
    - NEW `packages/contracts/events/news_article_ingested.py` 53 + `extracted_claim_published.py` 70 = 123 LOC
    - NEW tests: domain test_models 117 + test_value_objects 78 + test_services 102 + infra test_adapters 427 + apps test_ingest_news_cafef 189 + contracts test_news_events 88 = 1001 LOC / 60 NEW tests — IMPL-S36-3 +67% coverage density
    - EDIT contracts/events/__init__.py + contracts/__init__.py (barrel exports for both NEW events)
  - Tests: 327 PASS (was 267 post-S34; +60 NEW; 0 regressions); 60 vs ≥35 master-plan target = +71% over
  - Gates: mypy --strict 0 errors on 26 source files (`--explicit-package-bases`); ruff "All checks passed"; D1-D9 hook exit 0; cross-BC + framework + LLM-math creep greps all 0
  - 0 NEW SCOPE-tier decisions; 0 NEW IMPL-tier decision file (L-S15-1 inline-document — 3 cosmetic LOC overruns all under D1 20%)
  - 3 IMPL-S36-* cosmetic deviations: IMPL-S36-1 (infra +49%) / IMPL-S36-2 (CLI +70%) / IMPL-S36-3 (tests +67%)
  - 0 NEW lesson candidates; L-S30-1 (VBW pre-flight 4th application) + L-S15-1 + L-S28-1 (vendor-drift graceful degrade) APPLIED
  - Drift sweep: D1=0 sustained; D-INTENT NEW invariant tests cover Rule 6 mandatory fields; D-PROV every artifact maps to spec § B.2 + financial-data-protocol Rule 6/7/8 + master-plan 005 § S36; D9 charter md5 0 changes; DR-DEFER 1 NEW soft (R6 — live CafeF smoke deferred, gated on $50 sandbox cost willingness)
  - Self-track main ~120-160K within MULTI_TASK_IMPL 150-250K target (favorable burn rate; subagent dispatches NONE)

- **S38 / S42 (NEXT — branching gate)** per master-plan 005 § S38 + § S42 + sub-plan 006-S41 § S42:
  - **If Q&A 2026-05-01-001 (charter-promote bundle from S35) answered** → **S38 FOCUSED_IMPL Bundle 1 charter promote** (4 CHARTER proposals; ~30-50K; mv proposals/ → constitution/ + D-NNN ratification ADRs)
  - **Else** → **S42 MULTI_TASK_IMPL Track F IMPL** (BC-8 domain + adapters + use case; ~16 files; ~200-240K envelope; pre-flight projection check at entry; split S42a/S42b if >230K per master-plan §S42 line 549 + sub-plan 006-S41 § S42 split-doctrine)
  - Pre-flight per L-S30-1 / BP-S30-1: ls + Glob target dirs before Write; spec 006 + D-014 + sub-plan 006-S41 all binding
  - S42 Goal: ship BC-8 Analysis production code (Thesis aggregate + PerspectiveAnalysis + Synthesis + 4 value objects + ThesisRepository Protocol + ValidateThesisPhase1UseCase + LLMPerspectivePort + CostTrackerPort + 3 perspective agents [Bear/Bull/Quant per spec 006 § B.5 verbatim system prompts] + Phase1Synthesizer + Phase1DataGatherer + ClaudeLLMPerspectiveAdapter + SqliteThesisRepository + InProcessCostTracker + ThesisRecorded event + ≥40 tests fixture-mocked LLM)
  - Pre-flight reads (≤5): spec 006 + D-014 + S36 BC-5 reference (claude_llm_extractor + ExtractedClaim Rule 6 patterns) + S34 BC-2 reference (RatioService) + architecture.md § BC-8 + Layer Hierarchy
  - Budget: ~200-240K target (MULTI_TASK_IMPL 150-250K; under R1 split threshold)
  - Decision tier: IMPL per D-014 chosen Option A (3-perspective parallel matching spec 001 § B.3 verbatim)
  - Successor: S43a (FOCUSED_IMPL — Streamlit + CLI + 5-thesis dogfood; ~120-140K)
  - Success metric: ≥40 PASS in <3s; LLM port mocked in tests; bear case ≥3 distinct categories enforced; disagreement preserved per I-S12; cost tracker enforces $3 cap; cross-BC + framework + LLM-math creep greps all 0; D1=0 sustained

- **S34 (DONE — MULTI_TASK_IMPL — Track C BC-2 Fundamental)** per master-plan 005 § S34 + spec-T1-001 § B.1 + spec 001 § B.4 + financial-data-protocol Rule 1:
  - 8 success criteria: 7 PASS + 1 DEFERRED (R5 — long-running live ingestion)
  - Goal achieved: BC-2 Fundamental aggregate operational; ratio formulas textbook-audited (Damodaran/Penman/Higgins/Brealey-Myers/White-Sondhi-Fried); point-in-time `get_as_of` integrity verified zero-lookahead.
  - Files (8 NEW production + 6 NEW tests + 5 EDIT/barrel):
    - NEW `packages/domain/fundamental/` package: __init__.py + models/{__init__,financial_statement (107)} + value_objects/{__init__,statement_type (30),line_item (64),ratio (64)} + services/{__init__,ratio_service (255),peer_service (110),percentile_service (116)} + repositories/{__init__,fundamental_repository (49)}
    - NEW `packages/infrastructure/fundamental/` package: __init__.py + vnstock_fundamental_adapter.py (226) + sqlite_fundamental_repository.py (212)
    - NEW `apps/cli/ingest_fundamentals_vn30.py` (203 LOC; +45% over ≤140 = IMPL-S34-3)
    - NEW `packages/contracts/events/financial_statement_filed.py` (57 LOC)
    - NEW tests: test_models.py (97/9 tests) + test_value_objects.py (76/7) + test_services.py (256/17) + infra test_adapters.py (218/11) + apps test_ingest_fundamentals_vn30.py (76/4) + contracts test_financial_statement_filed.py (57/5) = 780 LOC / 53 tests
    - EDIT contracts events/__init__.py + contracts/__init__.py (barrel exports for FinancialStatementFiled)
  - Tests: 267 PASS in 1.16s (+53 NEW; 0 regressions)
  - Gates: mypy --strict 0 errors on 22 source files; ruff clean across packages/+apps/; D1=0 sustained; cross-BC + framework + LLM-math creep greps all 0 hits on BC-2 surface
  - 0 NEW SCOPE-tier decisions; 0 NEW IMPL-tier decision file (L-S15-1 inline-document doctrine — 4 cosmetic deviations all under D1 20% threshold)
  - 4 IMPL-S34-* cosmetic deviations: IMPL-S34-1 (services 481 vs ≤350 +37%) / IMPL-S34-2 (infra 438 vs ≤350 +25%) / IMPL-S34-3 (CLI 203 vs ≤140 +45%) / IMPL-S34-4 (tests 780 vs ≤500 +56%)
  - 1 NEW lesson candidate **L-S34-1** "Cross-BC import detection during IMPL — manual grep BEFORE gate". Mid-session refactor on peer_service: original imported `VN30_UNIVERSE` from BC-1 directly (Charter violation); not caught by mypy/ruff/import-linter (which only enforce layer ordering + framework forbiddenness). Refactored to ConstituentRecord Protocol + inject Sequence + from_constituents classmethod. Promotion target: `proposals/architecture-amendment.md` § "Cross-BC import-linter independence contract"; defer to Phase 2 close per Q-E2.
  - L-S30-1 (VBW pre-flight) APPLIED: third successful application — Glob caught README-only state of `packages/domain/fundamental/`
  - Drift sweep: D1=0 sustained; D2 carry-overs unchanged; D4=0 (S34 file refs verified); D9 carry-over unchanged; DR-DEFER 1 NEW soft (R5)
  - Self-track main ~120-160K within MULTI_TASK_IMPL 150-250K target (favorable)

- **S33 (DONE — MULTI_TASK_IMPL — Track B VN30 BC-1 expansion)** per master-plan 005 § S33 + D-012 carry-over guidance + amendment-VN Rule 14:
  - 8 success criteria: 6 PASS + 2 DEFERRED (R4 — long-running ops)
  - Goal achieved: BC-1 ingestion scaled VHM (1 ticker) → VN30 (30 tickers); nightly batch CLI shipped; per-Sàn tolerance scaffold wired ahead of amendment-VN Rule 14 promotion; multi-ticker batched insert with per-ticker transaction isolation operational.
  - Live smoke result: 3-ticker subset (VHM/VIC/FPT × 20 days) = 120 rows persisted, 100% DUAL_SOURCE HIGH confidence (60/60 reconciled rows). Full 30-ticker × 1-year backfill deferred to background batch (R4 — ~45 min wall at 0.3 RPS; not blocking S34).
  - Files (3 NEW production + 4 EDIT + 2 NEW tests + lifecycle):
    - NEW `packages/domain/market_data/value_objects/__init__.py` 10 LOC + `vn30_universe.py` 94 LOC (≤120 advisory; -22% under)
    - NEW `apps/cli/ingest_vn30.py` 206 LOC (+14% over ≤180 = IMPL-S33-1 cosmetic; under D1)
    - EDIT `packages/domain/market_data/__init__.py` 17→26 (export VN30 universe)
    - EDIT `packages/infrastructure/market_data/reconciliation_service.py` 153→177 (+4% over ≤170 = IMPL-S33-2; tolerance_for + Sàn table)
    - EDIT `packages/infrastructure/market_data/sqlite_bar_repository.py` 206→250 (+9% over ≤230 = IMPL-S33-3; save_many_by_ticker + count_for)
    - EDIT `packages/infrastructure/market_data/test_adapters.py` 472→578 (+44% over ≤400 = IMPL-S33-4; 11 NEW tests)
    - NEW `apps/cli/test_ingest_vn30.py` 150 LOC (+7% over ≤140 = IMPL-S33-5; 5 CLI smoke tests)
    - NEW `data/vn30-smoke-summary.md` (live-smoke artifact, 100% DUAL_SOURCE)
  - Tests: 214 PASS in 0.81s (+16 NEW: 5 VN30 universe + 2 sàn-tier + 4 multi-ticker + 5 CLI smoke; 0 regressions)
  - Gates: mypy --strict 0 errors on 7 changed source files; ruff clean across packages/+apps/; D1=0 sustained; cross-BC + framework + LLM-math creep greps all 0 hits
  - 0 NEW SCOPE-tier decisions (no charter implications)
  - 0 NEW IMPL-tier decision file (per L-S15-1 inline-document doctrine — 6 cosmetic deviations all under D1 20% threshold)
  - 6 IMPL-tier cosmetic deviations: IMPL-S33-1 (ingest_vn30 +14%) / IMPL-S33-2 (reconciliation_service +4%) / IMPL-S33-3 (sqlite_bar_repository +9%) / IMPL-S33-4 (test_adapters +44% coverage-density) / IMPL-S33-5 (test_ingest_vn30 +7%) / IMPL-S33-6 (value_objects/ directory created — master-plan stale path claim corrected via L-S30-1 VBW)
  - 0 NEW lesson candidates; L-S30-1 (VBW pre-flight) APPLIED — caught directory absence before Write
  - Drift sweep: D1=0 sustained; D2 carry-overs unchanged; D4 = 0 (S33 file refs verified on disk); D9 carry-over unchanged; DR-DEFER 1 NEW soft (R4 — long-running full backfill)
  - Self-track main ~80-110K well within MULTI_TASK_IMPL 150-250K target (favorable)


- **S32 (DONE — FOCUSED_IMPL — Track A R2 closure)** per master-plan 005 § S32 + IMPL-S28-1 anchor + financial-data-protocol § Rule 4 + amendment-VN Rule 14:
  - 6 success criteria: 6 PASS
  - Goal achieved: R2 (TCBS public API 404 → SINGLE_SOURCE only) **CLOSED via D-012 A3 strategy** (SSI iBoard direct httpx adapter); A1+A2 ladder rejected via empirical probe (TCBS endpoints all 404; vnstock 4.0.2 Quote effectively VCI-only — TCBS/DNSE/SSI/FMARKET deprecated as Quote sources, MSN ConnectionError); A4 SCOPE waiver not invoked.
  - Live smoke result: `ingest_vhm` 1-year backfill produced 496 rows (248 vnstock + 248 SSI); `data/vhm-reconciliation.md` shows **248 HIGH / 0 LOW / 0 SINGLE_SOURCE** (was 248 SINGLE_SOURCE pre-S32 — R2 baseline). SSI iBoard 30/30 VN30 = 100% live (`data/vn30-probe-ssi.json`).
  - Files (1 NEW production + 4 EDIT + 2 NEW data + 1 NEW decision + 3 lifecycle):
    - NEW `packages/infrastructure/market_data/ssi_adapter.py` 211 LOC (+17% over ≤180 advisory = IMPL-S32-1 cosmetic; under D1)
    - EDIT `__init__.py` 30→38 / `tcbs_adapter.py` 190→197 (deprecation banner) / `ingest_vhm.py` 127→142 (SSI wired primary alternate; TCBS graceful-fail) / `test_adapters.py` 290→472 (16 NEW tests = 13 SsiAdapter + 3 cross-source = IMPL-S32-2 +39%)
    - NEW `data/vn30-coverage-S32.md` 121 / `data/vn30-probe-ssi.json` 35
    - NEW `agent-workspace/memory/decisions/012-track-A-source-pivot.md` 205 LOC (+46% = IMPL-S32-3)
  - Tests: 198 PASS in 0.50s (+16 / 0 regressions)
  - Gates: mypy --strict 0 errors on Phase 2 surface (3 source files); ruff clean across packages/+apps/; D1=0 sustained; LLM-math creep grep 0 hits
  - 1 NEW IMPL-tier decision: **D-012** ACCEPTED (Track A R2 closure via SSI iBoard direct; TCBS public API permanently retired to graceful-fail archive)
  - 3 IMPL-tier cosmetic deviations: IMPL-S32-1 (ssi_adapter +17%) / IMPL-S32-2 (test_adapters +39%) / IMPL-S32-3 (D-012 +46%) — all under D1 20% (D1 only checks .claude/skills/commands/agents); all driven by documentation-density (option-ladder rationale + carry-over guidance) and test-coverage-density (16 NEW)
  - 1 NEW lesson candidate: **L-S32-1** "Empirical probe before strategy commit" doctrine — when master-plan ladder includes ≥3 strategies, probe all viable strategies before commit; predecessor source_evidence may be stale on vendor APIs (extends L-S28-1). Promotion target `proposals/architecture-amendment.md` § "Multi-strategy ladder probe-first doctrine"; defer to Phase 2 close per Q-E2.
  - Drift sweep: D1=0 sustained; D2 self-attest carry-overs unchanged; D4=0; D9 carry-over unchanged; DR-PROV every artifact maps to user "continue" + master-plan 005 § S32 + S29 R2 residue + Rule 4
  - Self-track main ~80-110K within FOCUSED_IMPL 100-150K target (came in below ceiling; favorable burn rate)

- **S31 (DONE — PLAN — Phase 2 master-plan author)** per D-011 ACCEPTED + master-plan 004 § "Phase 2 NEXT session = PLAN type":
  - 6 success criteria: 6 PASS
  - **(a) Plan SHIPPED**: `agent-workspace/session-plans/pending/005-S31-phase-2-master-plan.md` (790 LOC; +13% over advisory 700 cap = IMPL-S31-1 cosmetic; under D1 20% threshold; predecessor 004 = 531 LOC; per-session density 005 = 72 LOC/session vs 004 = 106 LOC/session — 005 MORE compact when normalized)
  - **(b) 6 tracks A-F fleshed out**: A R2 closure (4-strategy ladder; A2 vnstock alternate-source recommended first) / B VN30 BC-1 expansion (nightly batch via `apps/cli/ingest_vn30.py` NEW) / C BC-2 Fundamental (financial statements + ratio compute + peer comparables) / D BC-5 News stub + CafeF (NewsArticle + ExtractedClaim aggregates; categorical sentiment 5-class no numeric) / E 9 proposals parallel non-blocking 4-3-2 batching per L-S15-1 (3 sessions S38/S39/S40) / F thesis 3-perspective real impl (BearAgent + BullAgent + QuantAgent + Phase1Synthesizer + ValidateThesisPhase1UseCase + Streamlit page; S41 architect + S42 IMPL + S43a UI/dogfood)
  - **(c) Track A ordered FIRST** per Rule 4 multi-source reconciliation discipline (BLOCKER for B); B+C+D+F sequenced; E fully parallel non-blocking
  - **(d) ≥6 risks catalogued**: vendor API drift (L-S28-1 expanded VN30) / news scraping ToS legal / claim extractor model+version drift / Tier 2 LLM cost budget per spec § B.10 / R2 closure failure-mode (all-single-source SCOPE deviation) / VN30 rate-limit pressure (~30x VHM) / thesis cost ceiling violation per spec § A.3 AC-1
  - **(e) Final VERIFY S43 included** (sandwich-verifier whole-Phase 2; ~100-150K per L-S21-1 calibrated; surface ~80-100 files vs Phase 1 ~44 — bigger than S29's ~98K actual)
  - **(f) Plan structure mirrors 004 predecessor format** (frontmatter + Charter Alignment + Track Catalog + Dependency Graph + Session Breakdown + Budget Envelope + Risk Catalog + Anti-Patterns + Lessons-Learned + Phase 3 Entry Preview + Ratification Path)
  - Master-planner subagent: agent ID `a4150bcd731e5dd5d`; ~9.6 min wall; 19 tool uses; ~158K reported tokens; within calibrated 150-200K per L-S25-1
  - VBW pre-flight per L-S30-1 doctrine APPLIED by subagent (first practical exercise — confirmed `apps/dashboard/` does NOT exist + `eval-sets/` SEED.md files exist + 9 proposals confirmed via Glob + BC `__init__.py` files confirmed; no path-drift bugs)
  - Drift sweep: D1=0 sustained; D2 carry-overs unchanged; D4 = 0 sustained from S30 close; D9 carry-over unchanged; LLM-math creep grep 0 hits in master-plan 005
  - 0 NEW SCOPE-tier decisions (no new SCOPE gate at S31 per D-011 § binding_phase: 2 + Q-B2 doctrine)
  - 1 IMPL-tier deviation: IMPL-S31-1 (master-plan 005 = 790 LOC vs ≤700 advisory ceiling +13% cosmetic; under D1 20% threshold)
  - 0 NEW lesson candidates; L-S30-1 prior candidate APPLIED successfully by subagent
  - Self-track main ~30-45K within PLAN 50-80K target; subagent ~158K within calibrated 150-200K per L-S25-1; combined ~190-200K

- **S30 (DONE — FOCUSED_IMPL — Phase 1 closure)** per master-plan 004 § S30 + S29 PASS-WITH-RESIDUE verdict + user "continue" 2026-04-30:
  - 7 success criteria: 7 PASS
  - **(a) R1 partial**: 1-LOC fix at `packages/observability/tests/test_state_machine.py:30` (`HookEventState.COMPLETED == "completed"` → `.value == "completed"` mirroring test_types.py canonical pattern); 20 obs state_machine tests still PASS in 0.03s; mypy comparison-overlap on that line CLEARED. 7 remaining obs mypy errors (transcript_cache.py + test_transcript_cache.py) confirmed Phase 0 baseline OUT OF SCOPE.
  - **(b) Eval-sets RATIFIED-IN-PLACE (IMPL-S30-1)**: pre-flight Glob discovered existing `eval-sets/{historical-theses,labeled-kol-recommendations,historical-pumps}/SEED.md` files satisfy Day 1 § B.2-B.4 deliverable purpose (full template + example + USER FILL); master-plan literal paths drifted from disk reality; NO new files written per CLAUDE.md P3 surgical changes.
  - **(c) thesis-log/_template.md** NEW (141 LOC < 180 ceiling): per spec 001 § A.4 + thesis-log/README.md schema; sections include bear case mandatory ≥3 (I-S10), Quant Summary `-- query: ...` audit (I-S1), calibrated Confidence n_samples/hit_rate (I-S7), Sources Cited table (I-S5), Personal Bias Check (I-S22), Post-Mortem Schedule (I-S26), I-S35 disclaimer.
  - **(d) VHM exemplar thesis** NEW (145 LOC < 200 ceiling): `agent-workspace/memory/thesis-log/2026-04-30-VHM-exemplar.md`; 15 deterministic SQL queries Q1-Q15 against `data/vhm.sqlite` (248 bars 2025-05-05..2026-04-29); recommendation = PASS (honest framing — Tier 2-4 absent in Phase 1; cannot form genuine thesis); bear case 4 distinct points (mandatory ≥3 satisfied); frontmatter `exemplar: true` + `real_thesis: false` per Q-S30-1 doctrine — NOT counted toward Charter Month-3 5-thesis criterion.
  - **(e) post-mortems/_template.md** NEW (123 LOC; +2.5% over advisory ≤120 — IMPL-S30-2 cosmetic deviation; under D1 20% threshold): per I-S26 schedule + post-mortems/README.md schema; sections include Outcome (numbers via code), Calibration Impact (I-S7+I-S20), Bias Check (Charter Principle 6 + I-S22), Personal-Risk-Profile drift check.
  - **(f) Phase 1 close ceremony**: D-011 NEW (SCOPE-tier ACCEPTED via user explicit pick A); latest.md overwrite (S29 close → S30 close; 145 LOC); session log; project.md § Phase Goals Tracker Phase 1 DONE 2026-04-30 + Phase 2 IN PROGRESS + § Recent ADRs prepended D-011 (D-005 + S13 pushed off rolling 5-window); current-execution.md § Active Focus Track Phase 1 → COMPLETE / Phase 2 entry NEXT.
  - **(g) AskUserQuestion 1Q SCOPE-tier**: "Phase 1 closed; which path next?" — Option A (Recommended; Enter Phase 2 — Tier 1+2 VN30 rollout) chosen over B (Pause for dogfood week) and C (User-approve 9 proposals first); D-011 ACCEPTED via SCOPE-tier user-gate per Q-B2 doctrine.
  - 1 NEW SCOPE-tier decision: D-011 (Phase 2 entry; binding_phase: 2)
  - 3 IMPL-tier deviations: IMPL-S30-1 (eval-sets ratify-in-place) / IMPL-S30-2 (post-mortems _template.md cosmetic +2.5%) / IMPL-S30-3 (master-plan path literal `eval-sets/labeled-pumps/seed.md` nonexistent on disk)
  - 1 NEW lesson candidate: L-S30-1 (PLAN-tier deliverable VBW pre-flight; promote at Phase 2 close per Q-E2)
  - Drift sweep: D1=0 sustained; D2 carry-overs unchanged; D4 = 0 (Phase 1 forward-refs all resolved); D9 carry-over unchanged; LLM-math creep grep 0 hits in thesis-log/
  - Self-track ~85-110K (within FOCUSED_IMPL 100-150K target)

- **S29 (DONE — VERIFY — sandwich-verifier whole-Phase 1 review)**: per user "continue" 2026-04-30 + autonomous_mode=true + master-plan 004 § S29 directives
  - 7 success criteria: 7 PASS (all 10 V dimensions GREEN on Phase 1 surface 44 files; A1-A9 GREEN; verdict produced; mirror to disk verbatim; lifecycle artifacts written)
  - Verdict: **PASS-WITH-RESIDUE** — phase_gate UNBLOCKED; S30 closure proceeds
  - Verifier: sandwich-verifier subagent (agent ID ad3fbd0e52b1b29a2; fresh context; ~4.7 min wall; 65 raw tool uses / ~26 substantive; ~98K reported tokens within L-S21-1 80-150K calibrated band; well under 150K cap)
  - V dimensions GREEN: V1 spec align / V2 LLM-math = 0 grep hits / V3 cross-BC = 0 / V4 Bar invariants enforced (5 invariants in __post_init__: period_end>today, filing_date>ingested_at.date(), OHLC currency mismatch, OHLC ordering, negative volumes) / V5 RiskRule frozen + Decimal-validated; Position deterministic / V6 source_provider non-Optional Enum 5 sites sampled / V7 182 PASS in 0.51s zero failures / V8 mypy --strict 0 errors on 44 Phase 1 files + ruff 0 whole-tree (8 mypy errors confined to packages/observability/ Phase 0 baseline = R1 residue) / V9 D1=0 sustained / V10 charter md5 stable + 0 imports from proposals/
  - A1-A9 probes GREEN: A1 shared-kernel uniqueness; A2 PositionValueComputed signature matches spec § B.3; A3 BarRepository Protocol-only domain / SqliteBarRepository infrastructure; A4 vnstock VCI source + SourceProvider.VNSTOCK; A5 TcbsAdapter REST + TcbsApiError graceful CLI fallback; A6 ReconciliationService pure stdlib; A7 StrEnum migration complete (1 R1 tail in obs); A8 Decimal arithmetic everywhere no LLM; A9 reconciliation report Rule 4 format
  - 4 LOW residue items:
    - R1 (LOW) — 8 mypy errors in `packages/observability/` Phase 0 baseline; includes 1 StrEnum migration tail at `test_state_machine.py:30`; touch-on-pass at S30 (5-LOC) OR defer Phase 2
    - R2 (LOW) — TCBS 404 → live smoke 248 SINGLE_SOURCE rows only (reconciliation logic exercised by 5 fixture tests); defer Phase 2 endpoint hardening per IMPL-S28-3
    - R3 (LOW) — 5 production files exceed master-plan advisory LOC ceilings (IMPL-S28-2 documented; not D1-scope); no action
    - R4 (LOW) — checkpoint LOC bookkeeping discrepancy (3,378 claim vs verifier independent 2,039 strict count); reconcile at Phase 1 close
  - Outputs: `agent-workspace/memory/observations/sandwich-verifier-S29-phase1-final.md` (165 LOC < 300 ceiling; verbatim mirror) + `agent-workspace/memory/checkpoints/phase-1-thin-slice-S29-verdict.md` (~55 LOC < 150 ceiling)
  - Drift sweep: D1=0 sustained; D4=0 sustained; D2 carry-overs unchanged; D9 carry-over unchanged; DR-PROV all S29 artifacts trace to user "continue" + master-plan § S29 + spec 000 § B.5 + S28 close + verifier return
  - 0 NEW IMPL-tier decisions (VERIFY = read-only)
  - 0 NEW lesson candidates (L-S21-1 confirmed in calibration; whole-Phase 1 verifier ~98K well within 80-150K band)
  - Self-track main session ~25-35K + verifier subagent ~98K reported (substantive ~50K within VERIFY 50-60K base)

- **S28 (DONE — FOCUSED_IMPL — Phase 1 sixth sub-track Tier 1 ingestion adapter)**: per user "continue" 2026-04-30 + autonomous_mode=true + master-plan 004 § S28 directives
  - 7 success criteria: 7 PASS (live smoke run 248 VHM bars; ≥15 tests achieved 21; mypy+ruff clean post retroactive + S28; D1=0; cross-BC + framework imports = 0; reconciliation graceful for missing-day; SQLite roundtrip clean)
  - Deliverables shipped (13 files; 1,223 LOC):
    - Application port `packages/application/market_data/ports/bar_provider_port.py` 41/50 LOC + 3 barrels (17 LOC)
    - Infrastructure adapters `packages/infrastructure/market_data/`: vnstock_adapter 169/180 + tcbs_adapter 190/180 (+6%) + reconciliation_service 152/120 (+27%) + sqlite_bar_repository 205/140 (+46%) + 2 barrels (36 LOC)
    - Tests `packages/infrastructure/market_data/test_adapters.py` 290/200 (+45%; 21 tests)
    - CLI `apps/cli/ingest_vhm.py` 127/100 (+27%) + barrel (1 LOC)
  - Pre-flight retroactive S27 (per IMPL-S27-3): StrEnum migration (Currency, AdjustmentType, SourceProvider, HookEventState); TID252 absolute import; mypy comparison-overlap fix via .value; 21 ruff UP017 auto-fixes — 161 S27 tests still PASS post-edits
  - Test results: 21 NEW PASS in 0.50s (target ≥15; achieved 21); combined obs+S27+S28 = 182 PASS in 0.50s
  - Live smoke: 248 VHM bars on disk for 2025-05-05..2026-04-29; TCBS 404 → graceful single-source mode; reconciliation report at data/vhm-reconciliation.md
  - Cross-BC import grep: 0 hits in production code AND test code
  - Framework import grep (domain + contracts): 0 hits; vnstock confined to infrastructure
  - LLM-math creep grep (approximately/roughly/around): 0 hits
  - Drift sweep: D1=0 sustained; D4 forward-refs = 0 (BOTH S27 + S28 forward-refs RESOLVED); D2 carry-overs unchanged; D9 carry-over unchanged
  - mypy --strict --explicit-package-bases: 0 issues across 44 source files (S27 retroactive + S28 production)
  - ruff check: 0 errors across packages/ + apps/
  - 3 NEW IMPL-tier decisions:
    - IMPL-S28-1 (vnstock 4.0.2 dropped TCBS source; TcbsAdapter calls TCBS public REST direct via httpx with graceful TcbsApiError raise on non-200)
    - IMPL-S28-2 (advisory ceiling overruns: 5 files marginally over master-plan estimate; not D1 scope; documented as expected for production code cohesion + 40% more test coverage than minimum)
    - IMPL-S28-3 (TCBS smoke-run 404 → Phase 2 hardening item; Q-S28-3 doctrine: log + continue, not block; reconciliation report shows SINGLE_SOURCE entries)
  - 1 NEW lesson candidate L-S28-1 (vendor-API surface drift PLAN→IMPL: vnstock 4.0.2 dropped TCBS as Quote source between master-plan authoring + S28 IMPL same day; promotion target proposals/architecture-amendment.md § "Adapter library surface lock-in"; defer Phase 1 close per Q-E2)
  - Self-track ~110-130K (within FOCUSED_IMPL 100-150K target)

- **S27 (DONE — MULTI_TASK_IMPL — Phase 1 fifth sub-track first entities)**: per user "continue" 2026-04-30 + autonomous_mode=true + master-plan 004 § S27 directives
  - 8 success criteria: 5 PASS + 1 DEVIATION (file count 23 vs master-plan abstract 14; reorganized per IMPL-S27-1 + IMPL-S27-2 cross-BC discipline) + 2 DEFERRED (mypy+ruff via IMPL-S27-3; pytest fully green)
  - Deliverables shipped (23 files; 2,155 LOC total):
    - Shared kernel `packages/contracts/` (9 files): __init__.py 46 / types/__init__.py 35 / types/ticker.py 62 / types/money.py 88 / types/adjustment_type.py 51 / types/identifiers.py 32 / types/price_snapshot.py 48 (NEW per IMPL-S27-2) / events/__init__.py 9 / events/position_value_computed.py 59
    - BC-1 Market Data (5 files): models/__init__.py 5 / models/bar.py 154 / repositories/__init__.py 7 / repositories/bar_repository.py 54 / __init__.py 16
    - BC-9 Portfolio (5 files): value_objects/__init__.py 5 / value_objects/risk_rule.py 76 / models/__init__.py 5 / models/position.py 139 / __init__.py 20
    - Tests (4 files; 623 LOC): contracts/test_types.py 162 / contracts/test_position_value_computed.py 93 / market_data/test_bar.py 188 / portfolio/test_position.py 180
  - Test results: 79 NEW PASS in 0.26s (target ≥40); combined obs+S27 = 161 PASS in 0.26s
  - Cross-BC import grep: 0 hits in production code AND test code
  - Framework import grep (domain + contracts): 0 hits
  - LLM-math creep grep (approximately/roughly/around): 0 hits
  - Drift sweep: D1=0 sustained; D4 LOW × 2 → × 1 (position_value_computed.py forward-ref RESOLVED); D2 carry-overs unchanged; D9 carry-over unchanged
  - 3 NEW IMPL-tier decisions:
    - IMPL-S27-1 (shared-kernel VO relocation: Ticker+Money+Enums+Ids → contracts/types/ per architecture cross-BC rule; master-plan deliverable paths #1-3 reorganized; documented as deviation)
    - IMPL-S27-2 (cross-BC PriceSnapshot value object introduction: bridges Bar→Position consumption without direct cross-BC import; Bar.to_snapshot() projection method added)
    - IMPL-S27-3 (mypy+ruff deferred to S28 entry: tools declared in pyproject.toml dev deps but not installed in current env; pytest 79/79 PASS provides primary correctness signal; S28 must install + retroactively cover S27)
  - 1 NEW lesson candidate L-S27-1 (cross-BC VO placement doctrine: ubiquitous VOs live in contracts/types/ regardless of which BC introduced them; per-BC value_objects/ holds only BC-private types; promotion target proposals/architecture-amendment.md § "Cross-BC value object placement doctrine"; defer Phase 1 close)
  - Self-track ~150-180K (within MULTI_TASK_IMPL 150-250K target; under 230K split threshold per master-plan R1)

- **S26 (DONE — FOCUSED_IMPL — VN-Domain Constitution Proposals Track B)**: per user "continue" 2026-04-30 + autonomous_mode=true + master-plan 004 § S26 directives
  - 8 success criteria: 7 PASS + 1 DRIFT (proposal count 9 vs master-plan abstract 8; deliverable #1 explicit "separate" honored over success-criteria #7 "fold"; documented as IMPL-S26-1)
  - Deliverables shipped (4 NEW + 1 edit; 440 LOC):
    - `agent-workspace/proposals/financial-data-protocol-amendment-VN.md` 116/200 LOC — Rules 12-15 (T+2.5 settlement / Room ngoại saturation / Sàn HOSE-HNX-UPCoM data-quality tiering / FX VND-USD point-in-time)
    - `agent-workspace/proposals/invariants-amendment-VN.md` 108/180 LOC — I-S55..I-S65 (11 NEW VN-specific invariants enforcing Rules 12-15)
    - `agent-workspace/memory/personal-risk-profile.md` 110/120 LOC — template; 33 USER FILL placeholders across 7 sections (holding period / position sizing / stop-loss / dividend / sector exclusions / drawdown tolerance / audit trail)
    - `agent-workspace/memory/decisions/010-VN-domain-constitution-proposals.md` 106/140 LOC — 12-field schema; status ACCEPTED-as-PROPOSAL (distinct from ACCEPTED — flags user-approve gate)
    - `agent-workspace/memory/project.md` § Recent ADRs prepended D-010 + D-009; D-005 + D-004 pushed off rolling 5-window
  - Drift sweep: D1=0 sustained; D4 LOW × 2 forward-refs unchanged (will resolve S27+S28); D2 stale carry-overs unchanged; D9 carry-over unchanged
  - 1 NEW IMPL-tier decision: IMPL-S26-1 (option B separate proposals over master-plan abstract count)
  - 1 lesson candidate L-S26-1 (master-plan contradiction resolution doctrine — defer Phase 1 close)
  - Self-track ~80-100K (within FOCUSED_IMPL 100-150K target)

- **S25 (DONE — PLAN — sandwich-architect subagent dispatch)**: per user strategic statement + Q-S25-1 explicit-pick **VHM Recommended** + master-plan 004 § S25 directives
  - User strategic statement folded: "đủ data metric / research kĩ idea / llm sync / human scope+goals / phương pháp khả thi" maps 1-1 to S25-S30 sequence (no scope amendment required)
  - AskUserQuestion 1Q SCOPE-tier (Q-S25-1): VHM (Recommended) — confirmation-bias check passed
  - Architect subagent dispatch SHIPPED 5 deliverables (624 LOC total):
    - glossary.md 212 LOC / 42 VN-stock terms / 8 critical VN-domain present (T+2.5, Room ngoại, Đội lái, Mua-Bán chủ động, HOSE/HNX/UPCoM, ATO/ATC, USD/VND); each entry: term + def + Source + As-of + BC + Phase
    - spec frame 188 LOC / dual-layer SPEC_TEMPLATE / Part A (UC-1/2/3 + BR-1..5 + 10 out-of-scope items + Charter Month 3 SC mapping) + Part B (S26-S30 deliverables matrix + position_value_computed event signature + V1-V10 verifier surface)
    - D-009 110 LOC / 12-field schema / 3 options-considered (A=VHM/B=VIC/C=VPB) / status ACCEPTED via SCOPE-tier
    - drill-me transcript 114 LOC / 15 Q&A / SYNTHETIC-ELICITATION marker
    - current-execution.md routing rows 54-55 appended ("phase 1 thin-slice spec" + "glossary")
  - Drift sweep: D1=0 sustained; D4 LOW × 2 NEW (forward-refs to S27/S28 deliverables; expected, not regression); D2 stale carry-overs unchanged + 1 NEW expected pattern; D9 carry-over unchanged
  - 0 NEW IMPL-tier decisions (S25 = PLAN); 1 lesson candidate L-S25-1 (architect-spec-frame budget calibration 150-200K vs 80K PLAN target — defer promotion to Phase 1 close)
  - Self-track ~25-35K main + ~192K architect subagent (47 tool uses, 17.5 min) ≈ ~220K combined

- **S24 (DONE — PLAN — master-plan Phase 1 thin slice)**: per user "continue" 2026-04-30 + autonomous_mode=true + AskUserQuestion bundle 3Q user explicit picks
  - AskUserQuestion bundle (3Q): Q1 (S24 sub-track) → E master-plan / Q2 (Q-D1 sessions scaling) → C keep-flat / Q3 (Q-D2 wiki scaling) → A current-Karpathy-pattern; all Recommended
  - Sync-state.md: sync-039 (Q-D1 closure) + sync-040 (Q-D2 closure) added as confirmed-aligned; `last_check: 2026-04-30` set in YAML frontmatter (dampens SYNC-GRILLING-DUE next session)
  - Queued-grill-master.md: Q-D1 + Q-D2 closed with answer + closed_at + confirmed_via fields
  - Sync-tracker: 3 q_and_a_resolution events (SCOPE 47.6/3/4 → 47.7/4/**3** drained 1; DESIGN_THINKING 50.3/3 → 50.5/5)
  - Master-planner subagent dispatch SHIPPED `agent-workspace/session-plans/pending/004-S24-phase-1-thin-slice-plan.md` (531 LOC; S25→S30 sequence; VHM exemplar; 2 BCs first-entity = market_data/Bar + portfolio/Position+RiskRule; 1 cross-BC contract event `position_value_computed`; ~640-860K envelope)
  - 0 NEW IMPL-tier decisions (S24 = PLAN-only)
  - 0 NEW lessons (established patterns held)
  - Drift sweep clean: D1=0 sustained; 1 NEW D2 stale on session-23.md (acceptable carry-over pattern); 1 D9 pre-existing
  - Self-track ~50-70K (within PLAN 70-80K target if subagent dispatch counted; main session ~30-40K)

- **S23 (DONE — FOCUSED_IMPL — Phase 1 entry)**: per user "continue" 2026-04-30 + autonomous_mode=true + Phase 0 100% closed at S22
  - Sync-bundle (4 questions): sync-013 (identity) / sync-015 (9 BCs) / sync-016 (calibration) / sync-017 (sandwich) → all A=Recommended; all 4 transitioned assumed-aligned → confirmed-aligned in `agent-workspace/memory/sync-state.md`
  - Sync-tracker drained: 4 q_and_a_resolution events fired (SCOPE 5→4; DOMAIN_UBIQUITOUS samples 1→2; DESIGN_THINKING 2→3; DECISION_ROUTING 1→2; LANGUAGE unchanged)
  - Monorepo skeleton SHIPPED: `packages/domain/` with 9 BCs (market_data, fundamental, company_intelligence, macro, news, influence, crowd, analysis, portfolio); 19 files (9 README.md + 9 __init__.py + 1 top-level __init__.py); 204 README LOC total all ≤30; pure stdlib (no framework deps per CLAUDE.md hard rule)
  - Sub-folder structure (models/value_objects/events/services/repositories/) DEFERRED to per-BC first-entity sessions per CLAUDE.md P2 Simplicity First (S27 activates first 2 BCs per master-plan 004)
  - Drift sweep: D1=0 sustained; carry-overs unchanged (2 D2 stale + 1 D9)
  - 0 NEW IMPL-tier decisions (mechanical infra work per architecture.md spec)
  - 0 NEW lessons
  - Self-track ~50-70K (well within FOCUSED_IMPL 100-150K target)

- **S22 (DONE — FOCUSED_IMPL — Phase 0 Cleanup + 100% Closure)**: per user directive 2026-04-30 "fix all first... continue done autonomous phần harness hoàn toàn trước khi business logic"
  - 10 success criteria PASS
  - **R1 fixed**: `project.md:56` "6→7 proposals pending" + annotation; `current-execution.md:133` annotated S16 batch + pre-existing 7th
  - **R2 fixed**: `.claude/settings.local.json:11` `Bash(*)` removed
  - **R3 acknowledged**: bash-hook-lint.sh stale 140→143 (append-only protocol; current state via `wc -l`)
  - **6 L-S* promoted**:
    - L-S15-1 → grill-maximization/SKILL.md § Multi-Batch Composition (81→93 LOC)
    - L-S16-1 + L-S18-1 + L-S19-1 → architecture-amendment.md (49→98 LOC; 3 sections)
    - L-S17-1 → decision-discipline.md § Rule 2 sub-clause (97→111 LOC)
    - L-S21-1 → session-budgets-amendment.md § Verifier Budget by Scope (55→74 LOC)
  - **Self-awareness Stop hook wired (IMPL-S22-1)**: `.claude/settings.json` Stop block 12→13 entries; ratifies prior IMPL-S19-1 deferral on this sub-item only; sessions-rollup.tsv backfilled with S21 row (manual aggregator invocation; rows 2→3)
  - **UP-XX tracing audit complete**: 8/8 UP prompts (UP-01..UP-08) traced via `up-intake-log.md` to D-001..D-005; intent observations exist for UP-04+UP-05 only (intent-classifier shipped from UP-04); pre-classifier prompts traced via decision source_evidence (durable contract, stronger than intent observation); 4 q-and-a/pending bundles file-state pending logically closed via AskUserQuestion (human file-move pending per contract rule 4)
  - **Drift sweep clean**: D1=0; 0 NEW; carry-overs unchanged (2 D2 stale + 1 D9)
  - **bash-hook-lint clean** on aggregator wire
  - 1 NEW IMPL-tier decision: IMPL-S22-1 (Stop hook wire-in for self-awareness-aggregate.sh ratified per user directive)
  - 0 NEW lessons
  - S22 self-track ~80-100K (within FOCUSED_IMPL 100-150K target)

- **S21 (DONE — VERIFY)**: Phase-0 final verifier — sandwich-verifier whole-Phase adversarial review per D-002 REV-2 § D + REV-3 § D S14
  - 8 success criteria PASS
  - Verdict: **PASS-WITH-RESIDUE** — Phase 1 entry UNBLOCKED
  - Verifier: agent ID `a9f7c66b6f3f393a6`, ran 9.7 min, 126K tokens / 89 tool uses
  - V1-V10 dimensions all covered with evidence + file paths
  - Confirmed: D1=0 (independent fresh run 00:53:01), Charter+9 constitution immutable (md5+mtime), 82 tests PASS in 0.17s (live rerun), 22/22 sample LOC exact, 5 L-S* carry-overs all UNWIRED, 4 IMPL-S* trace to source, 0 LLM-math creep, 0 scope creep
  - 3 residue items (non-blocking): R1=proposal count drift (6→7), R2=inert `Bash(*)` line, R3=bash-hook-lint stale 140→143
  - Weakest forward-link: self-awareness-aggregate.sh authored but not auto-wired (IMPL-S19-1 deferral)
  - 11 deferrals to Phase 1+ all documented in D-006/D-007/D-008 § Open Questions
  - Outputs: `agent-workspace/memory/observations/sandwich-verifier-S21-phase0-final.md` (NEW; mirror of agent return text) + `agent-workspace/memory/checkpoints/phase-0-to-1-handoff.md` (UPDATED; full content)
  - 0 NEW IMPL-tier decisions (read-only review)
  - 1 lesson candidate L-S21-1 (whole-Phase verifier budget calibration → 150K instead of 80K)
  - S21 self-track ~50-60K (within VERIFY 60-80K target)

- **S20 (DONE — FOCUSED_IMPL)**: Track 6 secondary closure
  - 7 success criteria PASS
  - 5 skills refactored: spec-to-wiki 227→67, crawler-reliability 226→102, fastapi-module 225→122, ubiquitous-language 210→97, write-a-skill 163→99
  - 10 commands refactored: drill-me 217→65, drift-check 209→93, master-plan 201→54, ul-audit 200→56, session-start 199→95, grill-me 198→61, vbw-check 192→71, session-end 183→55, spec-author 163→65, budget-check 146→66
  - 1 agent refactored: drift-detector 235→88
  - 3 NEW references/templates.md (spec-to-wiki 163, ubiquitous-language 120, write-a-skill 88; total 371 LOC consolidating extracted detail)
  - settings.local.json expanded: `defaultMode: bypassPermissions` + ~150 explicit `Bash(<cmd>:*)` entries
  - New user memory `bash_permission_pattern.md` + MEMORY.md index update (matcher semantics doc)
  - D1 baseline 16 → 0 confirmed via `.drift-signals.log` 2026-04-30 00:43 run
  - 0 NEW IMPL-tier decisions (mechanical work per L-S14-1 / L-S14-1 corollary / L-S14-2 from S16)
  - 1 lesson candidate L-S20-1 already wired (no further promotion needed)
  - Real-transcript ~292K (over 250K hard cap due to heavy pre-flight + 16-file cycles + system-reminder accumulation)

- **S19 (DONE — MULTI_TASK_IMPL)**: Track 9 Self-Awareness REDUCED Phase 0 per D-002 REV-2 § B + REV-3 § C + S15-close ~50K target
  - 11-step sequence per S19 task plan all complete
  - Single-tier outputs:
    - 1 NEW decision (D-008 279 LOC; canonical 12-field schema; ACCEPTED via IMPL-tier self-decide + autonomous_mode=true; documents IMPL-S19-1 REDUCED scope — defer thesis-side amendments + telemetry-analyst + rollup_telemetry + OTEL docker to Phase 1+)
    - 1 NEW Python module packages/observability/state_machine.py 128 LOC — pure dataclasses + Enum; HookEventState (4 states) + HookEvent + VALID_TRANSITIONS frozenset (5 entries) + transition + is_terminal + InvalidTransitionError
    - __init__.py extended 50→67 LOC with 6 NEW exports
    - 1 NEW pytest test file test_state_machine.py 185 LOC 20 tests PASS — full obs suite 62→82 PASS in 0.18s
    - 4 NEW self-awareness templates totaling 284 LOC — README.md (61) + profile-template.md (79) + known-issues.md (74; 3 SEED entries KI-001..KI-003) + best-practices.md (70; 3 SEED entries BP-001..BP-003)
    - 1 NEW Stop hook self-awareness-aggregate.sh 124 LOC ≤180 bash+awk only per L-S11-1 — emits sessions-rollup.tsv with header
    - 1 NEW skill hook-diagnostics SKILL.md 113 LOC ≤150 D1 — consumes packages/observability/ state_machine + transcript_cache
    - Aggregator smoke test PASS — emitted row `18 09d3d5a4 2026-04-29T16:56:07Z 158142 873 5 B:1,H:1 244`
    - 0 NEW D1 violations + 0 NEW L-S11-1 + 0 NEW D9 + 0 D-IDENTITY findings
  - All 11 S19 success criteria PASS

- **S18 (DONE — FOCUSED_IMPL)**: Track 8b Memory L0/L1 Extraction + Option C coda per D-002 REV-2 § A
  - 9-step sequence per S18 task plan all complete
  - Single-tier outputs:
    - 1 NEW decision (D-007 277 LOC; canonical 12-field schema; ACCEPTED via IMPL-tier self-decide + autonomous_mode=true; documents IMPL-S18-1 library-only L1 + IMPL-S18-2 TranscriptCache full-reread simplification)
    - 5 NEW Python modules at packages/observability/ totaling 664 LOC — clean_text.py 36 + extract_l0.py 264 (incl. 5 NEW VN failure phrases) + extract_l1.py 165 + transcript_cache.py 149 + __init__.py 50
    - 4 NEW pytest test files + 1 fixture totaling 62 tests PASS in 0.18s — test_clean_text 15 / test_extract_l0 24 / test_extract_l1 13 / test_transcript_cache 10
    - 1 NEW skill (session-memory-l0-l1 SKILL.md 142 LOC ≤150 D1)
    - 1 hook MODIFIED (qa-answered-detector.sh 44→49 LOC; Option C wire-in)
    - Option C smoke test PASS — events.tsv +1 row + state.tsv DESIGN_THINKING 50.1/1 → 50.2/2
    - 0 NEW D1 violations + 0 NEW L-S11-1 + 0 NEW D9 + 0 D-IDENTITY findings
  - All 12 S18 success criteria PASS

- **S17 (DONE — FOCUSED_IMPL)**: Track 8a Confidence Score System per D-002 § Track 8 + REV-2 + Q&A A4/A5/A6
  - 8-step sequence per S17 task plan all complete
  - Single-tier outputs:
    - 1 NEW decision (D-006 ~190 LOC; canonical 12-field schema; ACCEPTED via IMPL-tier self-decide + autonomous_mode=true; documents IMPL-S17-1 substrate deviation)
    - 5 NEW sync-tracker layer files (events.tsv / state.tsv / weights.yaml 29 LOC / _index.md auto-rendered / README.md ~80 LOC)
    - 2 NEW hooks (sync-tracker-update.sh 151 LOC ≤180; sync-tracker-render.sh 106 LOC ≤180; both bash+awk only)
    - 1 NEW skill (sync-pull SKILL.md 109 LOC ≤150 D1)
    - 5+1-event smoke test PASS (all 5 categories scored; reversal protocol activated)
    - 0 NEW D1 violations + 0 NEW L-S11-1 + 0 D-IDENTITY findings
  - All 10 S17 success criteria PASS

- **S16 (DONE — FOCUSED_IMPL)**: Track 7 IMPL ratification per S15 PLAN
  - 8-step sequence per Plan Appendix A all complete
  - Single-tier outputs:
    - 2 decision amendments (D-003 REV-4 + D-005 REV-1 appended)
    - 1 NEW hook (`bash-hook-lint.sh` 140 LOC) + 3 hook wire-ins to Stop block
    - 6 NEW proposals at `agent-workspace/proposals/` from S16 Track 7 batch (decision-discipline, autonomous-protocol, memory-tiers, architecture-amendment, financial-data-protocol-amendment, session-budgets-amendment) — plus 1 pre-existing `provenance-protocol.md` authored S2 = **7 total pending user approve**
    - 1 NEW skill companion file (`write-a-skill/references/best-practices.md`)
    - 1 SKILL.md amendment (`try-n-approaches/SKILL.md` final 136 LOC)
    - 1 memory file extension (`~/.ccs/.../harness_bootstrap_permission_override.md` § L-S14-3)
    - 1 routing summary (`promotion-routing-S16.md`)
  - All 10 S16 success criteria PASS

- **S15 (DONE — PLAN)**: Track 7 plan composition
  - Single deliverable: `session-plans/pending/003-S15-track-7-constitution-amendments.md` (279 LOC)
  - 9 queued-grill items fired+closed via 3 AskUserQuestion batches (Batch 1: 4 governance, Batch 2: 3 autonomous-protocol inputs, Batch 3: 2 drift)
  - All 9 answers Recommended; folded into plan § 3 + § 4
  - Self-track ~70K within ~80K PLAN target

- **Track 6 secondary carry-over** (16 D1 violations remaining, S15 optional or S16):
  - 5 skill violators: `crawler-reliability` 226, `fastapi-module` 225, `spec-to-wiki` 227, `ubiquitous-language` 210, `write-a-skill` 163
  - 10 command violators: `drift-check` 209, `drill-me` 217, `grill-me` 198, `master-plan` 201, `session-end` 183, `spec-author` 163, `ul-audit` 200, `vbw-check` 192, `budget-check` 146
  - 1 agent violator: `drift-detector` 235

- **S15 carry-over from prior sessions (Track 7 amendments — append-only)**:
  - IMPL-S11-2 D-005 path inconsistency (5.5d.1 vs 5.5d.2 prose)
  - IMPL-S12-1 D-005 path-prose vs survey-vs-dogfood-insight-file-split (paired with IMPL-S11-2)
  - **IMPL-S13-1 D-003 § 5.5c.5 failure_mode 8-code expansion vs 3-code prose**
  - **IMPL-S14-1 carry-over: skill `spec-to-wiki/SKILL.md` 227 LOC still violates D1 (Track 6 secondary closure)**

- **S15 promotion targets (L-S*)** — all routed via S16 IMPL per `agent-workspace/memory/observations/promotion-routing-S16.md`:
  - L-S11-1 → `bash-hook-lint.sh` § Check 1 + `proposals/financial-data-protocol-amendment.md` Rule 11 ✅
  - L-S11-2 → `proposals/decision-discipline.md` Rule 2 ✅
  - L-S12-1 → `learning-loop-metric-check.sh` (wired) + `try-n-approaches/SKILL.md` § Validation Pre-Conditions ✅
  - L-S12-2 → `research-scanner-output-validator.sh` (wired) ✅
  - L-S13-1 → `bash-hook-lint.sh` § Check 2 ✅
  - L-S13-2 → `try-n-approaches/SKILL.md` § Best Practices ✅
  - L-S14-1 → `write-a-skill/references/best-practices.md` ✅
  - L-S14-2 → `write-a-skill/references/best-practices.md` + `proposals/architecture-amendment.md` ✅
  - L-S14-3 → `~/.ccs/.../harness_bootstrap_permission_override.md` § L-S14-3 ✅
  - L-S14-4 → `proposals/autonomous-protocol.md` Rule 2 + `proposals/session-budgets-amendment.md` § Mode A/B/C/D ✅

- **S16-S21 NEW promotion candidates**:
  - **L-S15-1 multi-batch packing (4+3+2)** → `grill-maximization/SKILL.md` § Multi-batch composition (S22+ candidate; verifier confirmed UNWIRED)
  - **L-S16-1 companion-via-references for D1-violating files** → APPLIED in S20 Track 6 secondary closure (3 references/templates.md created); promotion to `proposals/architecture-amendment.md` § "When SKILL.md exceeds ceiling" still pending user approve (verifier confirmed proposal section UNWIRED)
  - **L-S17-1 spec-storage-substrate-IMPL-tier-when-portability-binds** → `proposals/decision-discipline.md` § "IMPL-tier resolution doctrine" Rule 3 sub-clause (S22+ candidate; verifier confirmed UNWIRED)
  - **L-S18-1 cross-language-regex-porting-requires-locale-extension** → `proposals/architecture-amendment.md` § "When porting from source repos" OR `evidence-extraction/SKILL.md` cross-locale port checklist (S22+ candidate; verifier confirmed UNWIRED)
  - **L-S19-1 deterministic-stop-hook-aggregator-before-LLM-Guardian** → `proposals/architecture-amendment.md` § "Telemetry rollup design" OR `decompose-work/SKILL.md` telemetry-rollup template (S22+ candidate; verifier confirmed UNWIRED)
  - **L-S20-1 Bash permission allowlist explicit cmd:* required** → already wired (user memory `bash_permission_pattern.md` + settings.local.json comprehensive; no further promotion needed) [verifier note: `Bash(*)` line still present in settings.local.json:11; cosmetic R2 fix recommended for S22]
  - **L-S21-1 VERIFY-session resource discipline (whole-Phase verifier may exceed 80K dispatch cap; recommend 150K)** → `proposals/session-budgets-amendment.md` § "Verifier budget by scope" OR constitution amendment (S22+ candidate; new from S21)

- **S22+ (Phase 1 entry)**: Phase 1 substantive work + 11 carry-over deferrals
  - **Sequence**: S22 (Phase 1 entry per `docs/DAY_1_CHECKLIST.md`) → ongoing Phase 1
  - **3 residue items** (non-blocking; recommend touch-on-pass during Phase 1):
    - R1: fix proposal count drift (6→7) in current-execution.md + S20-close checkpoint (cosmetic; provenance-protocol.md predates S16 batch by ~9h)
    - R2: remove inert `Bash(*)` line from `.claude/settings.local.json` (cosmetic; defaultMode covers it)
    - R3: bash-hook-lint.sh micro-stale LOC 140→143 (documentation-only)
  - **Weakest forward-link**: self-awareness-aggregate.sh not auto-wired (IMPL-S19-1 deferral); recommend backfill or Stop hook wire as early Phase 1 task
  - **Phase 1+ deferrals from D-006/D-007/D-008** (11 items, all documented in respective § Open Questions):
    - TSV → SQLite migration (D-006; unblocked since S18)
    - Concurrency upgrade (D-006)
    - L1 dispatch wire-in via Anthropic SDK (D-007; when client lands)
    - Memory storage substrate decision (D-007)
    - L0+L1 auto-fire wire-in (D-007)
    - Profile card auto-render (D-008; when thesis data ≥5 entries)
    - OTEL docker stack (D-008; when dashboard needed)
    - thesis-anomaly + daily-thesis skills (D-008)
    - telemetry-analyst subagent (D-008)
    - rollup_telemetry.py Python rewrite (D-008)
    - Stop hook registration for self-awareness-aggregate.sh (IMPL-S19-1)

---

## Paused / Deferred

(None)

---

## Archived (completed phases)

(None — we're at the start)

---

## How Agent Uses This File

On `/session-start`:
1. Read this file first
2. Identify active track (currently Phase 0)
3. Load appropriate plan file (currently `docs/DAY_1_CHECKLIST.md`)
4. Determine session type based on current state
5. Propose next action

When work transitions:
- Phase changes → update Active Focus Track
- New work item starts → add to Current Work Items
- Work completes → move to Archived
- Work blocks → add Blocker info

**Critical**: This file is truth. If CLAUDE.md, skills, or session plans mention phases, they point HERE, they don't hardcode paths.
