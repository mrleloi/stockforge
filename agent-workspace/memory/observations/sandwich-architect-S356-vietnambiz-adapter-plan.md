---
observation_id: sandwich-architect-S356-vietnambiz-adapter-plan
type: sandwich-architect-output
architect_agent_id: (this fresh-context dispatch; see dispatch.jsonl for ID)
created_at: 2026-05-16
plan_authored: agent-workspace/session-plans/pending/027-S356-phase-d-vietnambiz-adapter.md
target_session: S357 (sandwich-dev FOCUSED_IMPL)
verifier_session: S358 (sandwich-verifier AP-1 fresh-context)
phase_milestone: D Theme L FINAL adapter; Phase E Theme I Vietnamese NLP unlocks post-S358 close
sandwich_architect_has_no_Bash_tool: true (Read/Glob/Grep/Write only per agent template line 5; main commits per D-060 + pre-dispatch-architect-commit-guard.sh)
phase_1b_self_calibration: CONSUMED at n=2 sample (NDH S344 + Vietstock S354); cold-start declared on .planner-stats.tsv (L-S354-2 harness gap carry-forward)
---

# S356 sandwich-architect — VietnamBiz adapter plan-027 authoring observation

## What was authored

`agent-workspace/session-plans/pending/027-S356-phase-d-vietnambiz-adapter.md` — comprehensive FOCUSED_IMPL plan for VietnamBiz adapter, the FINAL Phase D Theme L per-source rollout.

**Plan stats** (architect-internal):
- Total LOC: ~1180 (within 1100-1200 brief envelope; +30 from plan-026 baseline due to L-S345-3 PROMOTE-NOW conditional skill-update path in § L + DD-5 conservative 3.0s rate-limit additional verification surface)
- 10 DD architecture decisions (DD-1..DD-10) all pre-answered with rationale + adversarial alternates
- 5 sub-tracks (D1..D5) with parallel_with + blocks_on + coordination_paths_exclusive + estimated_wall_min per plan-025 contract (n=2 dogfood)
- 36 DoD items (+1 vs plan-026 35; added DC-BOOK-6 for Phase E entry unblock attestation; added DC-IMPL-9 for `if store_raw:` guard verification; added DC-IMPL-10 for rate_limit_seconds=3.0 verification)
- 10 AQ pre-answered (AQ-1..AQ-10)
- 5-source-evidence chain rows (Strategy A subclass / SelectorChain[T] 3rd consumer / DD-7 F2-aware day-1 / RateLimiter 3.0s CONSERVATIVE / RobotsTxtManager)
- RM1..RM11 (RM11 = sextuple-guard regression defense + L-S345-3 PROMOTE-NOW validation point)

## Key architectural decisions (DD-1..DD-10 summary)

| DD | Decision | Distinct from plan-026 (Vietstock)? |
|---|---|---|
| DD-1 | Class = `VietnamBizAdapter`; source_id = `"vietnambiz"` | YES (different brand) |
| DD-2 | Path = `packages/infrastructure/news/crawler_adapters/vietnambiz_adapter.py` | NO (same pattern; +1 sibling) |
| DD-3 | Strategy A direct-subclass (no legacy wrap) | NO (same pattern at n=3) |
| DD-4 | 2x SelectorChain[Tag] (headline + body) + fmt-string chain for date | NO (same pattern at n=3) |
| **DD-5** | **`RateLimiter(base_delay=3.0)` — DD-5 CONSERVATIVE per plan-020 § E line 354 + skill flag "VietnamBiz less lenient"** | **YES (Vietstock + NDH + CafeF all 2.0s; VietnamBiz FIRST adapter with bumped default)** |
| DD-6 | Optional `robots_manager` injection; can_fetch before fetch | NO (same pattern at n=3) |
| **DD-7** | **F2-AWARE `_fetch_with_optional_chain(*, store_raw: bool = True)` from DAY ONE — n=3 store_raw presence; n=2 day-one ship** | **NO architecturally; L-S345-3 PROMOTE-NOW pivot point per § L** |
| DD-8 | Same UA `stockforge-research-bot/0.0.1 (+contact: nathanleewindy@gmail.com)` | NO (same UA at n=3) |
| DD-9 | Mirror Vietstock error handling (None on parse fail; raise on network fail) | NO (same pattern at n=3) |
| DD-10 | Synthetic minimal HTML in unit tests; ONE real HTML in CLI smoke (gitignored tmp) | NO (same pattern at n=3) |

**Two distinct architectural callouts vs Vietstock baseline**:
1. **DD-5 3.0s rate-limit** (per plan-020 § E matrix line 354 + skill flag; FIRST per-source rate-bump in BC-5 suite)
2. **L-S345-3 PROMOTE-NOW pivot point** — VietnamBiz day-one ship at n=2 (Vietstock 1st; VietnamBiz 2nd) triggers AP-23 3-instance ratification for SKILL-tier mandate IF S358 verifier confirms quintuple-guard ALL GREEN

## Phase 1b self-calibration (CONSUMED variant; n=2 baseline)

**Source files read (VBW empirical, ALL via Read tool — architect has no Bash)**:
1. `agent-workspace/memory/.planner-stats.tsv` — header-only (L-S354-2 harness gap; cold-start declared)
2. `agent-workspace/memory/self-awareness/sessions-rollup.tsv` — schema lacks `task_class` column; cannot key cleanly; derivation via cross-reference with session logs
3. `agent-workspace/memory/dispatch.jsonl` — grep for S344/S345/S354/S355 returned no matches (likely truncated archive or session IDs in different log format)
4. `agent-workspace/memory/mistake-log.md` — last 80 LOC digest; M-S354-NONE clean / M-S342-1 medium / M-S341-1 low / M-S347-NONE
5. `agent-workspace/session-plans/completed/022-S343-phase-d-ndh-adapter.md` — partial read (file too large for single read; offset+limit used)
6. `agent-workspace/session-plans/completed/026-S353-phase-d-vietstock-adapter.md` — full read across 4 chunks
7. `agent-workspace/memory/observations/sandwich-verifier-S355-vietstock-adapter-verify.md` — full read; cites L-S345-3 strengthening + L-S354-1 1st-HOLD + L-S354-2 1st-HOLD-harness
8. `packages/infrastructure/news/crawler_adapters/vietstock_adapter.py` — full read (477 LOC; mirror reference)
9. `packages/infrastructure/news/crawler_adapters/ndh_adapter.py` — partial read (signature + _fetch_with_optional_chain shape lines 115-353)
10. `packages/infrastructure/news/crawler_adapters/__init__.py` — full read (current exports: CafeFAdapter + NDHAdapter + VietstockAdapter — confirms 3 sibling baseline)
11. `agent-workspace/memory/decisions/066-bc5-crawler-adapter-contract.md` — partial read (REV-1 + REV-2 + Amendments section)
12. `agent-workspace/session-plans/completed/020-S337-phase-d-theme-l-crawling-adapter.md` § E matrix lines 344-371 — confirmed VietnamBiz rate-limit 3.0s + skill flag
13. `.claude/skills/crawler-reliability/SKILL.md` — confirmed § Rate Limiting line 54 "VietnamBiz less lenient than CafeF"

**Calibration parameters extracted**:
- task_class = `crawler-adapter-impl` (Strategy A greenfield)
- sample_size = 2 (NDH S344 + Vietstock S354)
- avg_wall_min = 33.5 (NDH ~31min + Vietstock ~36min; variance ±2.5min ≈ 7% — tight envelope)
- avg tokens_real Opus = ~34K (Vietstock S354 actual per S355 verifier; NDH was Sonnet so wide variance)
- parallel_hit_rate empirical = 0% (no .planner-stats population — L-S354-2 gap)
- parallel_hit_rate declared = n=1 (Vietstock plan-026 first declaration)
- failure_mode frequency = 1 IMPORTANT per cycle (both INLINE-RESOLVABLE; n=2)
- Adjusted budget = 90-130K Opus FOCUSED_IMPL (slightly under default 100-150K to acknowledge Vietstock actual efficiency)
- Cold-start? PARTIAL (.planner-stats header-only; sessions-rollup lacks task_class column; mistake-log digest informative; n=2 confidence DIRECTIONAL not statistical)

**Calibration verdict**: Phase 1b PROOF-OF-CONSUMPTION at n=2 sample baseline. Architect explicitly cites empirical observations (Vietstock S354 ~34K Opus / ~36min wall; NDH S344 ~116K Sonnet / ~31min wall). Final budget recommendation **100-150K Opus FOCUSED_IMPL with 20% reserve** balanced for: Vietstock-actual baseline + DD-5 3.0s CLI smoke wall-inflation + L-S345-3 PROMOTE-NOW conditional ship +5K + STEP 0 surprise reserve.

## Why the recommendations differ from plan-026

1. **DD-5 3.0s rate-limit** (vs Vietstock 2.0s): NEW per-source rate-bump precedent in BC-5 suite. Justified by plan-020 § E matrix line 354 + skill flag. First adapter where rate-limit ≠ baseline 2.0s — precedent for future adapters (if any) with different rate-profile needs.

2. **L-S345-3 PROMOTE-NOW CONDITIONAL skill update in § L** (vs Vietstock REV-2 amendment-only): VietnamBiz is the 3rd instance + 2nd day-one ship — meets AP-23 3-instance promotion threshold. Skill update FIRES at S358 verifier-confirm; architect documents the path explicitly to give main session a clean execution recipe post-verifier-confirm. Main session writes the skill update (not dev), per separation-of-concerns (product-tier IMPL vs skill-tier amendment).

3. **DC-BOOK-6** added (vs plan-026 DC-BOOK-5): Phase D Theme L closure milestone requires project.md Phase Goals Tracker update + Phase E entry unblock attestation per CLAUDE.md § End rule 7 + `phase-status-coherence.sh` UserPromptSubmit cadence.

4. **DC-IMPL-9 + DC-IMPL-10** added (vs plan-026 DC-IMPL-8): explicit `if store_raw:` guard verification + `rate_limit_seconds=3.0` verification — sextuple-guard (was quintuple in plan-026) — strengthens regression defense at the L-S345-3 PROMOTE-NOW pivot moment.

5. **Test 21 added** (vs plan-026 20-test ceiling): `test_vietnambiz_adapter_rate_limit_default_is_3_seconds` — DD-5 verification.

## What I rejected

1. **Bundle Phase E entry into this plan** — RM4 catastrophic-mix-pattern; Phase E entry needs own PLAN session (separation per CLAUDE.md § Session Types "never mix PLAN and IMPL")
2. **2.0s rate-limit (mirror sibling adapters)** — REJECTED per skill flag + plan-020 § E explicit 3.0s; charter Principle 8 calibration over confidence
3. **Same-session L-S345-3 skill update (S357 dev writes it)** — REJECTED; skill-tier amendment belongs to main session post-verifier-confirm; cleanly separates product-tier IMPL from skill-tier promotion
4. **Compose VietnamBizAdapter from internal `_VietnamBizScraper` helper class** — REJECTED per plan-022/026 DD-3 precedent; unnecessary indirection at n=3
5. **CafeFAdapter Strategy B → Strategy A consolidation in same bundle** — REJECTED; RM12 carry-forward; separate Phase D-N consolidation plan
6. **Protocol-typed optional injections refactor (L-S354-1 1st-HOLD)** — REJECTED; cross-adapter refactor mixes product ship + refactor (RM4); separate harness-cross-cutting session
7. **`report_response(url, 200)` hardcoded fix (L-S345-4 carry-forward)** — REJECTED; fetcher contract change is cross-adapter scope; separate session
8. **AJAX/JSON API consumption for VietnamBiz listings** — REJECTED; Strategy A targets static HTML article pages only; AJAX-aware adapter is separate future work

## STEP 0 BLOCKING clauses (10 sub-steps; 4 STOP-AND-ASK triggers)

Mirror plan-026 STEP 0 structure with 1 plan-027-specific adaptation:
- **Sub-step 0.1 explicitly notes plan-020 § E line 354 URL TYPO** — listed as `vietstockfinance.vn` (which is the Vietstock subdomain); correct URL is `vietnambiz.vn`. STEP 0.1 empirically verifies.
- Sub-step 0.2 protego rate-limit check expects 3.0s default per DD-5; bump only if Crawl-delay > 3.0s
- Sub-step 0.4 selector candidates list VietnamBiz-likely classes (e.g. `h1.title-detail`, `div.article-content`)
- Sub-steps 0.6 + 0.9 verify all 3 sibling adapters (CafeF + NDH + Vietstock) importable + zero-regression
- Sub-step 0.10 STEP 0 summary write captures DD-5 rate-limit decision explicitly

4 STOP-AND-ASK triggers: site 404 / robots.txt disallow / ToS forbids / JS-rendered. Mirror plan-026 — n=2 precedent confirms 4-trigger contract is robust.

## L-S345-3 PROMOTE-NOW path explicit in § L

Plan § L documents the conditional skill update path with:
- **Trigger condition**: S358 verifier confirms ALL SIX quintuple-guard items GREEN
- **Authority chain**: ADR D-066 REV-1+REV-2+REV-3 + plan-022+026+027 DD-7 + AP-23 3-instance ratification
- **Skill update spec**: full text drafted for `.claude/skills/crawler-reliability/SKILL.md` — Adapter Storage Discipline section with helper signature contract + quintuple-guard verification checklist
- **Promotion deferral rationale**: if even ONE quintuple-guard item FAILS at S358, promotion DEFERRED to next adapter ship (likely CafeFAdapter consolidation) — Karpathy P1 + Charter Principle 8 binding
- **Execution boundary**: main session writes skill update post-S358 (NOT S357 dev) — product-tier IMPL vs skill-tier amendment separation

## S357 dev budget recommendation

**100-150K Opus FOCUSED_IMPL** (per Phase 1b n=2 calibrated; slightly conservative bound to absorb DD-5 3.0s CLI smoke wall-inflation + STEP 0 surprises + L-S345-3 conditional ship +5K reserve).

Architect verdict: dev should NOT need MULTI_TASK_IMPL upgrade unless STEP 0 surfaces complications (RM3 SelectorChain gap at n=3 → Path B D-067 — Very Low likelihood per n=2 validation).

## Phase E entry recommendation post-S358 close

Post-S358 verifier acceptance:
1. Mv `pending/027-S356-phase-d-vietnambiz-adapter.md` → `completed/`
2. Update `project.md` Phase Goals Tracker: Phase D Theme L row CLOSED; Phase E Theme I row UNBLOCKED
3. Update `current-execution.md`: Active Focus Track → Phase E Theme I Vietnamese NLP
4. Conditional: if quintuple-guard ALL GREEN, write `.claude/skills/crawler-reliability/SKILL.md` Adapter Storage Discipline section per § L PROMOTE-NOW path
5. Dispatch fresh-context sandwich-architect for plan-028 (Phase E entry — Vietnamese NLP primitives PLAN session)

**Phase E entry plan-028 scope sketch** (architect-suggested for next session's main):
- BC-5/BC-6 boundary surface: token classification + sentiment classification primitives
- Vietnamese-text-specific challenges (per S259 master plan cluster I-finding "Vietnamese-text NLP fragility")
- Reference repos to scan: spaCy + transformers + underthesea (Vietnamese-specific NLP)
- Charter alignment: I-S1 (no LLM math) + Rule 7 (sentiment categorical not numeric)
- Carry-forward: L-S354-1 (Protocol-typed injection refactor) may fold into Phase E if BC-5 adapter touch needed; L-S354-2 (planner-feedback-loop.sh harness gap) stays in harness queue

## Compliance attestation

- AP-1 fresh-context ✓ (dispatched fresh per main brief; no carryover context from prior session)
- harness_priority_one N/A (product PLAN; L-S354-2 harness gap stays in harness queue per § Out-of-scope)
- 0 charter / 0 constitution / 0 human-workspace writes / 0 production code (PLAN-only)
- 0 git commits (sandwich-architect has no Bash tool; main commits per D-060)
- VBW ✓ (12 source files read; key signatures verified file:line — vietstock_adapter.py:322 `_fetch_with_optional_chain` signature + plan-020 § E line 354 rate-limit 3.0s + skill SKILL.md line 54 "VietnamBiz less lenient")
- I-S34 ✓ (plan does NOT enumerate any banned imports; HARD REJECT list cited in DD-3 / DC-COMPLIANCE-1 / RM10)
- Phase 1b CONSUMED at n=2 sample (explicit Calibration summary § B; cold-start declared on .planner-stats.tsv per L-S354-2 carry-forward)
- D-060 ✓ (main commits plan per pre-dispatch-architect-commit-guard.sh hook contract)
- DD-7 F2-aware quintuple-guard MANDATED day-one (NOT post-S345 retrofit; n=2 day-one precedent)
- DD-5 conservative 3.0s rate-limit BINDING (NOT 2.0s; skill prior + plan-020 § E + Charter Principle 8)

## Recommendations to main session

1. **Commit plan-027** + this observation file as a single architect commit
2. **Dispatch S357 sandwich-dev** with FOCUSED_IMPL Opus 100-150K budget recipe; brief should cite plan-027 § E sub-tracks + DD-7 sextuple-guard mandate + DD-5 3.0s rate-limit BINDING + STEP 0 BLOCKING (especially Sub-step 0.1 URL typo correction)
3. **AP-1 mandate**: S358 verifier dispatched fresh-context (NOT main self-review)
4. **L-S345-3 PROMOTE-NOW decision point at S358 close**: main session reads verifier verdict on quintuple-guard items; IF ALL 6 GREEN → write skill update per § L spec; IF ANY FAIL → defer promotion + flag for next adapter ship
5. **Post-S358 Phase E entry**: dispatch fresh-context sandwich-architect for plan-028 Vietnamese NLP entry PLAN session (NEW session — NEVER mix PLAN+IMPL)
6. **L-S354-2 harness gap carry-forward**: if .planner-stats.tsv STILL header-only after S357 dispatch, L-S354-2 promotes to 2nd-instance HOLD = mandatory next-harness-session inclusion
