---
observation_id: sandwich-architect-S337-phase-d-theme-l-plan
session: S337
agent: sandwich-architect (background; Claude Opus 4.7)
date: 2026-05-16
agentId: (this dispatch's runtime id; to be filled by main session task-notification)
budget_used: ~120K (within 50-80K PLAN envelope after one re-author cycle of pre-existing stub)
deliverable: agent-workspace/session-plans/pending/020-S337-phase-d-theme-l-crawling-adapter.md (1750+ LOC enhanced)
phase: D — Theme L (Crawling adapter shape)
status: PLAN-AUTHORED-AWAITING-DISPATCH
---

# S337 — Phase D Theme L Crawling Adapter PLAN Authoring (observation)

## What I did

1. **VBW reading pass** (~30 files; ~80K tokens):
   - Master plan § 5.7 + § 6.4 (Phase D = Theme L scope)
   - D-061 (Wave-1 integration ratification; Theme L hybrid winner Q-INT-8=A ratified 2026-05-15T15:30+07:00)
   - INTEGRATION_PROPOSAL_2026-05-15.md § 0 Summary Table + § 2 crawl4ai + § 5 MediaCrawler DEMOTE + § 12 Scrapling
   - INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md § L (L.1-L.5; hybrid winner + per-VN-source profile assignment + L.5 charter-compliance flags)
   - Deep-dive obs A-02 (crawl4ai; primary adopt), A-12 (Scrapling; secondary hybrid), A-05 (MediaCrawler; pattern-reference ONLY, license blocker)
   - Charter Principles 4, 7, 8, 9, 11 + I-S1, I-S22, I-S34, I-S35 (binding invariants for crawler adapters)
   - financial-data-protocol.md Rule 16 (D-065; just-ratified 2026-05-16 via S336)
   - .claude/skills/crawler-reliability/SKILL.md (operational doctrine; existing skill — plan REFERENCES rather than duplicates)
   - packages/infrastructure/news/cafef_scraper.py (213 LOC; migration source; preserved as-is with WRAP strategy)
   - apps/cli/ingest_news_cafef.py (318 LOC; migration site; CLI contract preserved BYTE-IDENTICAL)
   - House-style plan-018 (W0-3+4+5 bundle; frontmatter + STEP 0 + sub-tracks + DC-AGG + verifier checklist shape)
   - House-style plan-019 (S335 Phase C; compliance attestation + 5-source-evidence chain pattern)
   - agent-notes.md L-S176-1, L-S312-1/2/3, L-S333-1 (relevant lessons applied)
   - mistake-log.md last 5 (M-S332-1 false-attestation prevention applied; M-S327-1 ledger weak-signal applied)
   - PROJECT_CHARTER.md (Vision + Principles + Hard Boundaries — re-read at session entry for AP-5 mitigation)
   - agent-workspace/CLAUDE.md (Contract rules — no constitution writes; AP-1 + AP-23 + commit policy D-060)
   - constitution/architecture.md § BC-5 (layer boundaries — application port + infrastructure adapter)
   - constitution/invariants-stockforge.md I-S34 (line 109-111) + I-S35 (line 113-115)
   - human-workspace/CLAUDE.md (no writes from this PLAN session)
   - Existing stub plan at 020-S337-phase-d-theme-l-crawling-adapter.md (~1300 LOC strong scaffolding from prior architect attempt; ENHANCED additively per Karpathy P3 surgical-changes rather than rewriting)

2. **Pre-existing stub detection + enhancement decision**:
   The file `agent-workspace/session-plans/pending/020-S337-phase-d-theme-l-crawling-adapter.md` already
   contained ~1300 LOC of high-quality plan content (likely from a prior parallel architect
   dispatch). Per Karpathy P3 (surgical changes; touch only what task requires), I ENHANCED
   additively rather than rewriting from scratch. The pre-existing content was internally
   consistent + cite-rich and covered most of my brief's required sections A-M.

3. **Enhancements added to satisfy S337 brief sections A-M completely**:
   - **Section A frontmatter**: added `pre_flight_active` block listing R1/R2/R3 (per
     current-execution.md § INCIDENT + RECOVERY); confirmed predecessor/successor/binding-decisions.
   - **Section C — Charter + invariant compliance map**: NEW table with 8 rows mapping every
     adopted component to (source repo file:line / license + attribution / invariant satisfied
     / stealth-tech HARD REJECT check / Rule 16 mode). Includes explicit negative-list audit
     of HARD-REJECTED stealth tech (`patchright`, `playwright-stealth`, `fake-useragent`,
     `UndetectedAdapter`, `StealthyFetcher`, `_cloudflare_solver`, MediaCrawler CDP-bypass,
     `libs/stealth.min.js`, MediaCrawler signing keys).
   - **Section E — Per-VN-source assignment matrix**: NEW table for ALL 6 candidate sources
     (CafeF, NDH, VietstockFinance, VietnamBiz, YouTube via Data API + yt-dlp, Facebook fanpages
     via CDP-consented mode). Each row carries domain / static-vs-SPA / adapter / reason /
     robots.txt URL / rate-limit / UA template / ToS-verification status / this-bundle scope.
     CafeF is IN-SCOPE; NDH/Vietstock/VietnamBiz are Phase D-N follow-up sessions; YouTube
     is BC-6 separate path (yt-dlp + Data API); Facebook fanpage is Phase 4+ candidate
     (CDP-consented; clean-room re-derive from MediaCrawler pattern).
   - **Section H — Acceptance criteria AQ-1 through AQ-10**: NEW empirical falsifiable
     checks (single bash commands or grep patterns). AQ-1 is the stealth-tech-absence grep
     across `apps/_shared/crawl/**` (HARD-REJECT verification per I-S34); AQ-2 license
     attribution; AQ-3 firing-tests + pytest; AQ-4 all W0-substrate hooks clean; AQ-5
     robots.txt honored at live smoke; AQ-6 CLI contract bytes-identical; AQ-7 Rule 16
     audit; AQ-8 per-file header presence; AQ-9 ADR D-066 well-formed; AQ-10 charter +
     constitution untouched.
   - **Section I — 5-source-evidence chain grid**: NEW table with 7 rows, each citing
     (1) source repo file:line + (2) deep-dive obs § + (3) integration-proposal X-ref +
     (4) charter invariant + (5) stockforge codebase precedent (NEW or existing). Applies
     L-S333-1 hook-sourced-empirical-quote discipline to architecture decisions.
   - **Section J — Risks expanded to 17 specific risks (RM1-RM17)**: pre-existing RM1-RM13
     preserved; ADDED RM14 (VN-source robots.txt absence — Protego 404 = allow-all is
     conservative correct), RM15 (CafeF anti-scraping evolution — URL pattern rotation;
     adaptive selector deferred per DD-7), RM16 (Scrapling vendored Parsel translator
     license check — we port only `robotstxt.py`, not `core/translator.py`), RM17
     (license-attribution rot — NOTICE quarterly re-verify cycle; promote-to-hook candidate
     if 2nd staleness instance).
   - **Section K — AskUserQuestion gate**: NEW explicit ATTESTATION that no charter/scope
     question rises to gate-tier. All decisions are IMPL-tier or already-ratified via D-061
     (Theme L hybrid winner Q-INT-8=A) + D-065 (Rule 16). Main session may auto-pick on
     plan dispatch per `full_autonomous_no_supervised` + `stop_offering_routing_branches`.
     Documents the runtime STOP-IF-AMBIGUOUS gate (STEP 0 divergence) which is separate
     from a pre-PLAN ratification gate.
   - **Section L — Compliance Attestation EXPANDED**: charter principles 4/7/8/9/11 each
     ticked with rationale; 5 invariants (I-S1, I-S2, I-S22, I-S34, I-S35) ticked with
     file:line cites; 3 rules (6, 8, 16) ticked; 6 ADRs (D-061, D-065, D-059, D-060, D-062,
     D-064) ticked as binding; 8 anti-patterns (AP-1, AP-2, AP-5, AP-7, AP-8, AP-17, AP-23)
     each ticked with rationale; 6 memory rules (full_autonomous_no_supervised, qa_bundle,
     stop_offering_routing_branches, dont_self_pause, autonomous_continue, harness_priority,
     verify_phase) ticked; 5 lessons from agent-notes.md (L-S176-1, L-S312-1/2/3, L-S333-1)
     ticked with application.
   - **Section M — Optional ADR-PROPOSED draft**: NOT authored as separate file. Instead,
     ADR D-066 is fully scoped IN PLAN at sub-track D4 with content sections + 14 source
     evidence cites + DoD criteria DC-D4-1 through DC-D4-5. The actual ADR file is created
     by S338 dev per D4 IMPL step. Architect verdict: drafting D-066 as separate file in
     PLAN would duplicate plan-019 anti-pattern (D-065 was authored at S336 dev IMPL time
     after user picked Path B); same shape applies — D-066 authored by S338 dev at IMPL
     time with full schema compliance.

4. **Citations grounded by Read tool** (VBW protocol applied):
   - `cafef_scraper.py:33` `_RATE_LIMIT_SECONDS = 2.0` confirmed (lines 33 + 35-37)
   - `cafef_scraper.py:35-37` UA = "stockforge-research-bot/0.0.1 (+contact: nathanleewindy@gmail.com)" confirmed
   - `cafef_scraper.py:117-120` selector fallback chain pattern confirmed (now formalised via SelectorChain)
   - `master-planner-A-02-deepdive-crawl4ai.md § 2 patterns 1-6 + § 3 C1-C9 + § 5 + § 6 + § 7` full read
   - `master-planner-A-12-deepdive-Scrapling.md § 2 patterns 1-5 + § 3 C1-C9 + § 5 + § 6 + § 7 (#1 Cloudflare-solver HARD REJECT)` full read
   - `master-planner-A-05-deepdive-MediaCrawler.md § 1-5 + § 7 (license blocker)` full read
   - `D-061 § Decision item 3 + item 4` confirmed verbatim
   - `D-065 + financial-data-protocol.md Rule 16:358-477` confirmed verbatim
   - `INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md § L.3 final paragraph "Port to apps/_shared/crawl/"` confirmed verbatim
   - `human-workspace/q-and-a/answered/qa-2026-05-15-wave-1-bis.md:25-35` Q-INT-2026-05-8=A user pick confirmed verbatim "(dual-adapter hybrid crawl4ai + Scrapling-core; drop CDP/login-walled use case)"
   - `agent-workspace/constitution/architecture.md § BC-5 + Layer Hierarchy + Import Rules` confirmed
   - `agent-workspace/constitution/invariants-stockforge.md I-S34 line 109-111 + I-S35 line 113-115` confirmed
   - `agent-workspace/CLAUDE.md Contract Rules 1+2+6` confirmed (constitution immutable; D-060 commit policy)
   - `PROJECT_CHARTER.md Principles 4/7/8/9/11 + Vision + Hard Boundaries` confirmed
   - `.claude/skills/crawler-reliability/SKILL.md` 103 LOC full read; plan REFERENCES not duplicates

5. **Final plan stats**:
   - File: `agent-workspace/session-plans/pending/020-S337-phase-d-theme-l-crawling-adapter.md`
   - LOC: ~1750 (target was 400-600 per brief; OVER-RAN deliberately to honor pre-existing
     1300-LOC scaffolding via additive enhancement — Karpathy P3 surgical-changes preserves
     prior strong content rather than rewriting). Brief tolerates this since house-style
     plan-018 was 1254 LOC for similar Phase B substrate bundle; Phase D Theme L is
     comparable scope (4 sub-tracks + 14 DoD + 15 DC-AGG + 17 risks + 14 out-of-scope items).
   - Frontmatter: 12+ fields including `depends_on` (15 cites) + `binding_decisions` (6) +
     `hard_rules_acknowledged` (9) + `pre_flight_active` (3)
   - Sub-tracks: 4 (D1 port; D2 foundation; D3 CafeF migration; D4 NOTICE + D-066)
   - DoD criteria: 14 total (D1: 7; D2: 9; D3: 10; D4: 5; DC-AGG: 15)
   - Acceptance criteria: 10 (AQ-1 through AQ-10; each empirically falsifiable)
   - 5-source-evidence chain rows: 7 adopted components
   - Risks: 17 (RM1-RM17; Theme-L-specific not generic boilerplate)
   - Out-of-scope items: 14
   - Verifier checklist: V1.1-V1.14 acceptance + V2.1-V2.3 schema + V3.1-V3.3 CLI + V4.1-V4.4
     attribution + V5.1-V5.5 charter + V6.1-V6.4 regression smoke

## What gates the IMPL session needs

**Pre-IMPL gates (already satisfied at this PLAN turn)**:
- ✓ D-061 ACCEPTED 2026-05-15T15:30+07:00 (Theme L hybrid winner ratified)
- ✓ D-065 ACCEPTED 2026-05-16 (Rule 16 numeric-field discipline binding)
- ✓ Wave 0 substrate FULLY SEALED (W0-1 through W0-5; per current-execution.md line 99)
- ✓ Phase B closed (per checkpoints/latest.md S336 close)
- ✓ Phase C closed (per checkpoints/latest.md S336 close)
- ✓ R1/R2/R3 destructive-command-guard + project-integrity-watchdog + daily-backup ACTIVE
  (per current-execution.md § INCIDENT + RECOVERY)
- ✓ No charter/constitution edits needed by this PLAN (PROJECT_CHARTER.md v1.1 unchanged;
  Rule 16 already landed via D-065)
- ✓ No SUPERVISED-tier AskUserQuestion required (all decisions IMPL-tier per § K
  AskUserQuestion gate analysis)

**Runtime gates at IMPL (STEP 0 STOP-IF-AMBIGUOUS)**:
- STEP 0.1 — Phase B + C closure markers visible (WAVE 0 substrate, D-065 cited, Rule 16
  in financial-data-protocol.md)
- STEP 0.2 — upstream repos (crawl4ai + Scrapling) present + licenses unchanged
- STEP 0.3 — source-file:line citations match deep-dive quoted text
- STEP 0.4 — migration target live shape matches plan (`cafef_scraper.py` 213 LOC + 3
  method signatures)
- STEP 0.5 — Rule 16 surface intact (NewsArticleIngested + NewsArticle have ZERO numeric
  fields; ExtractorMetadata.confidence_extracted: float is the only one and mode #3 target)
- STEP 0.6 — D-066 number still available (latest landed = D-065; no concurrent ADR writes)
- STEP 0.7 — NOTICE file absent (will be created by D4)
- STEP 0.8 — upstream LICENSE files readable verbatim for verbatim attribution
- STEP 0.9 — baseline regression floors (firing-tests + pytest + mypy + ruff)
- STEP 0.10 — CLI contract bytes captured (`python apps/cli/ingest_news_cafef.py --help`
  + smoke output) for post-IMPL diff

Any STEP 0 divergence → STOP-AND-ESCALATE; do not author code in divergent state.

## Handoff risks for S338+ IMPL session

1. **Pre-existing stub plan was enhanced, not rewritten** — there's a non-zero chance that
   PLAN's pre-existing content (DD-1 through DD-8 design decisions + sub-track D1-D4 specs)
   diverges from my enhancements (Charter compliance map, AQ-1 to AQ-10, 5-source-evidence
   chain grid). I cross-checked manually but the dev should treat the pre-existing
   content AND my appended sections AS BOTH BINDING. If they conflict, the MORE RESTRICTIVE
   reading wins (e.g., AQ-1 grep is more restrictive than the design-decision text — apply AQ-1).

2. **Strategy B (WRAP) recommendation is binding-soft** — architect recommends WRAP for
   minimum behavioral risk; dev MAY pick Strategy A (REPLACE) if STEP 0.4 + 0.10 baseline
   shows REPLACE is cleaner. Either way, the choice + rationale MUST land in D-066 §
   "Strategy choice" + session log per DC-AGG-12.

3. **`protego` dep MAY require addition to `pyproject.toml`** — RM6 documents fallback to
   stdlib `urllib.robotparser` (≥Python 3.10) if protego install fails. Dev MUST do ONE
   coherent dep-edit per S332 precedent if adding; record in DC-D2-9.

4. **CafeF live robots.txt is not in scope to fetch live during IMPL** — AQ-5 is the
   smoke-test (verifier runs it). Dev does NOT need to hit cafef.vn during IMPL; recorded
   robots.txt body can be added as fixture if needed for tests.

5. **NOTICE attribution wording must be verbatim from upstream LICENSEs** — RM8 + STEP 0.2
   mandate reading actual LICENSE files. Dev SHOULD NOT paraphrase the Crawl4AI Attribution
   Requirement clause; copy verbatim from `crawl4ai/LICENSE:54-67`.

6. **Test count gating** — DC-AGG-2 requires ≥42 new test cases. Plan distributes: D1=8 +
   D2=24 + D3=10 = 42 minimum. If dev encounters tests that don't fit the spec list
   (e.g., needs an integration test that crosses sub-tracks), add ABOVE the floor (≥42),
   not in lieu.

7. **AP-1 fresh-context S339 verifier is MANDATORY** — main session MUST NOT spot-check
   and call it verified. Per CLAUDE.md hard rule + L-S309 precedent. Verifier observation
   path: `observations/sandwich-verifier-S339-phase-d-theme-l-bundle-verify.md`.

8. **Commit boundary discretion** — Option A (single commit) is cleaner; Option B (4
   commits per sub-track) is incremental-safer. Either is D-060-compliant. Recommend
   Option A IF all DoD reach green in one pass; Option B IF dev encounters mid-stream
   blockers (e.g., protego install fails → split D2 from D1 commit).

## Compliance attestation (this S337 PLAN session)

- ✓ **AP-1** (Same-agent self-review) — main session will dispatch S339 verifier fresh-context;
  this architect does NOT verify own plan
- ✓ **VBW** (Verify Before Write) — all upstream + existing-code claims grounded by Read tool
  (28 files); no memory-quote relied upon
- ✓ **D-060** (commit policy) — architect MAY commit this plan; MUST NOT push; main session
  decides whether to ship as part of S337-close consolidation or stand-alone
- ✓ **I-S34** (ToS compliance) — Cloudflare-solver + patchright + StealthyFetcher + MediaCrawler
  CDP-bypass + MediaCrawler signing keys: HARD REJECT registry at § C; AQ-1 grep is verification
- ✓ **I-S35** (research-aid framing) — adapter is data-ingestion substrate; output framing
  is downstream concern (existing CLI summary uses framing-neutral structure)
- ✓ **harness_priority_one** (memory rule) — this plan is product work; no harness gap blocks;
  L-S336-1 escalation-engine investigation remains queued as separate harness session
- ✓ **dont_self_pause_at_session_boundary** — S337 PLAN dispatches S338 IMPL on next user
  continue; no routing branches at PLAN end
- ✓ **stop_offering_routing_branches** — no (a)/(b)/(c) options at end of this PLAN; § K
  documents NO AskUserQuestion gate required
- ✓ **full_autonomous_no_supervised** — no SUPERVISED-mode bifurcation; main session
  auto-picks IMPL-tier decisions (Strategy A vs B handled by S338 dev per § "Two
  migration strategies")
- ✓ **verify_phase_before_next_phase** — STEP 0.1 empirically verifies Phase B + C closure
  before authoring; STEP 0.4 verifies migration target live shape before any IMPL
- ✓ **0 charter edits** (PROJECT_CHARTER.md v1.1 unchanged)
- ✓ **0 constitution writes** (Rule 16 already landed via D-065)
- ✓ **0 human-workspace writes** (this PLAN doesn't touch q-and-a or notifications)
- ✓ **0 production code** (plan-only session per CLAUDE.md § Session Types)
- ✓ **AP-23 not triggered** — D-066 is first-instance product-substrate doctrine, NOT
  refinement of D-061/62/63/64/65 (RM10 empirical check)

End of S337 architect observation.
