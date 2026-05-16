---
id: D-061-wave-1-integration-ratification
title: Wave-1 Research-Integration Ratification (Phase A deep-dive findings)
date: 2026-05-15
status: ACCEPTED
level: IMPL

author:
  - "Claude Opus 4.7 (master-planner subagent, S325 dispatch)"

source_evidence:
  - path: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md
    section: "§ 4-8 (theme decomposition + ratification gate; ratified Q-INT-2026-05-1..4 = A/A/C/A at S322)"
    quote: "Default if user blanket-approves: A / A / C / A respectively"
  - path: agent-workspace/research/INTEGRATION_PROPOSAL_2026-05-15.md
    section: "§ 0 Summary Table — Final Disposition (15 repos) + § 4 FinceptTerminal + § 5 MediaCrawler + § 12 Scrapling + § 13 TradingAgents + § 15 Vibe-Trading"
    quote: "Material demotions (Wave-1 budget impact): FinceptTerminal MEDIUM → LOW; MediaCrawler HIGH → MEDIUM-LOW; Scrapling partial DEMOTE on Cloudflare-solver + patchright sub-modules (HARD REJECT)."
  - path: agent-workspace/research/INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md
    section: "§ Theme G (G.2 + G.3) + Theme H (H.2 + H.3 winner inversion) + Theme L (L.3 hybrid) + Theme N (N.1-N.3 net-new) + § Refined Wave-1 IMPL Allocation R.1-R.5"
    quote: "Winner: DEBATE-STYLE (Pattern B / TradingAgents-source) — but with explicit mitigations ... This recommendation INVERTS the master-plan default."
  - path: agent-workspace/memory/observations/master-planner-A-01-deepdive-ai-hedge-fund.md
    section: "§ 5 (isolated-then-aggregate confirmed)"
  - path: agent-workspace/memory/observations/master-planner-A-04-deepdive-FinceptTerminal.md
    section: "§ 5 (AGPL + commercial-license-required; pattern-only ZERO LITERAL LOC)"
  - path: agent-workspace/memory/observations/master-planner-A-05-deepdive-MediaCrawler.md
    section: "§ 5 (Non-Commercial Learning License 1.1 NOT OSI + platform mismatch)"
  - path: agent-workspace/memory/observations/master-planner-A-10-deepdive-nautilus_trader.md
    section: "§ 1.5 DST doctrine (D-059 re-confirmation source)"
  - path: agent-workspace/memory/observations/master-planner-A-12-deepdive-Scrapling.md
    section: "§ 5 + § 7 #1 #2 (Cloudflare-solver HARD REJECT)"
  - path: agent-workspace/memory/observations/master-planner-A-13-deepdive-TradingAgents.md
    section: "§ 2.2 debate-style + § 5 + § 7.2/7.3/7.4 anti-patterns"
  - path: agent-workspace/memory/observations/master-planner-A-14-deepdive-TradingAgents-CN.md
    section: "§ 3.10 + § 7.5 LLM-emits-numbers prompt smell"
  - path: agent-workspace/memory/observations/master-planner-A-15-deepdive-Vibe-Trading.md
    section: "§ 3 C9 validation pipeline (Theme N net-new source)"
  - path: agent-workspace/post-mortems/2026-05-14-mass-deletion-recovery.md
    section: "§ 1b (D-058 LOST + INTEGRATION_PROPOSAL_*.md LOST)"
  - path: agent-workspace/memory/decisions/059-python-determinism-contract.md
    section: "frontmatter depends_on: D-058 (Wave 0 substrate authorization)"
  - path: agent-workspace/memory/decisions/060-S321-commit-policy-agent-may-commit.md
    section: "frontmatter (commit policy ratified S321)"
  - path: agent-workspace/memory/observations/queued-grill-master.md
    section: "Active Queue (all items closed; no pending re-fire)"

intent_classification:
  primary_intent: DECISION
  affects_charter: false
  affects_scope: true
  urgency: NORMAL
  complexity_score: 70

options_considered:
  - id: A
    summary: "Ratify Phase A findings verbatim: empirical FIT replaces master-plan hypothesis (5 demotions/inversions + 1 net-new theme); pending user-ratify of 4 NEW Q-INT-2026-05-bis questions surfaced by empirical findings"
    pros:
      - "Honest demotions preserved (FinceptTerminal M→L removes Theme K PLAN; MediaCrawler H→ML removes Theme L IMPL slot; Scrapling Cloudflare-solver HARD REJECT)"
      - "Theme H winner INVERSION (debate-style over isolated-then-aggregate) anchored to I-S12 literal compliance per A-13 § 5 ('debate-style is the principled fit, not isolated-then-vote')"
      - "Theme G I-S1-1 GENUINE-new confirmation (Phase A empirical: 3 main multi-agent frameworks all have LLM-emit-confidence/price fields per SUPPLEMENT § G.2) unblocks constitution-write path"
      - "Theme N net-new (Vibe-Trading validation pipeline) properly cataloged for Wave 2+ rather than silently dropped"
      - "Refined envelope 15-20 sessions / 2840-4180K saves -1 session / -160-320K vs master-plan 16-22 / 3000-4500K"
    cons:
      - "4 new Q-INT-bis questions add 1 ratification gate (S326) before Phase B IMPL"
      - "Theme H inversion adds quadratic-token risk requiring summarization step mitigation"
  - id: B
    summary: "Keep master-plan hypothesis (no demotions/inversions); execute Phase D-K against original ratified scope; flag Phase A deltas as informational only"
    pros:
      - "No new ratification gate; Phase B can start immediately"
    cons:
      - "Discards empirical Phase A evidence — anti-pattern per Charter Principle 8 (calibration over confidence)"
      - "Would mean importing MediaCrawler under non-OSI license (per A-05 § 5) and adopting Scrapling Cloudflare-solver (per A-12 § 7 #1 — I-S34 HARD REJECT) — DIRECT charter violation"
      - "Theme H isolated-then-aggregate erases rebuttal dynamic per I-S12 — weakest alignment with charter Principle 3"
  - id: C
    summary: "Defer ratification — collect more empirical evidence before locking integration decisions"
    pros:
      - "Maximum conservatism"
    cons:
      - "Phase A was the empirical-evidence collection (15 deep-dives + 2 synthesis files); deferring deferring is can-kicking per R7 defer-cycles drift"
      - "Blocks Wave 1 indefinitely"

chosen: A
chosen_rationale: |
  Phase A's 15 deep-dives + 2 synthesis files supply file:line-cited empirical evidence for every
  proposed delta. Option B would knowingly violate charter (I-S34 ToS-conflict adoption of Scrapling
  Cloudflare-solver per A-12 § 7 #1 + license violation adopting MediaCrawler under non-OSI per
  A-05 § 5). Option C postpones what Phase A was designed to settle. Option A locks the empirical
  findings into a ratification ADR (this D-061) and surfaces the 4 NEW Q-INT-bis questions the
  findings created — preserving human-ratify gate for the SCOPE-tier deltas (Theme H pattern winner,
  Theme G path, Theme N fate, Theme L adapter strategy).

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-05-15
    via: "S325 master-planner subagent dispatch (this ADR)"
  - actor: user
    action: ACCEPTED
    at: 2026-05-15T15:30+07:00
    via: "chat: 'approved all your recommendation for all pendings item and blocking items. continue' → blanket-A on Q-INT-2026-05-5/6/7/8 per qa-2026-05-15-wave-1-bis.md (each A option marked '(Recommended)')"
    picks: "Q-INT-5=A (debate-style + 4 mitigations) / Q-INT-6=A (constitution-write Phase C) / Q-INT-7=A (defer Theme N to Wave 2+) / Q-INT-8=A (dual-adapter hybrid crawl4ai + Scrapling-core)"

verified_by:
  - mechanism: provenance-chain
    at: 2026-05-15
    result: PARTIAL
    note: "Every claim in this ADR cites a deep-dive file:line; full PASS contingent on Q-INT-2026-05-bis answers landing"

affects:
  charter: false
  spec_files:
    - agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md
  code_paths: []
  config_files: []
  other_decisions:
    - "D-058 (LOST per post-mortem §1b — this ADR supersedes the lost ratification audit trail)"

depends_on:
  - "D-059 (Python determinism contract — Phase A A-10 § 1.5 re-confirmed at IMPL site)"
  - "D-060 (commit-policy-agent-may-commit — operational gate for Wave 1 commit boundaries)"

supersedes: "D-058 (Wave 0 substrate authorization — audit trail LOST 2026-05-14 mass-deletion per post-mortems/2026-05-14-mass-deletion-recovery.md §1b; this ADR re-establishes the ratification record)"
superseded_by: null

defer_cycles: 0
re_attempt_prereq: "N/A"

tags: ["wave-1", "phase-a", "research-integration", "ratification", "S325", "Q-INT-2026-05-bis"]
---

# Decision 061 — Wave-1 Research-Integration Ratification (Phase A findings)

## Context

This ADR ratifies the empirical Phase A deep-dive findings for the Wave-1 research-integration
master plan (`agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md`). The master
plan's 4 original ratification questions (Q-INT-2026-05-1..4) were answered A/A/C/A at S322 (per
master plan § 8 default-blanket-approval clause). Phase A then executed (S323 dispatch + S324
synthesis), producing 15 deep-dive observation files (`agent-workspace/memory/observations/master-planner-A-{01..15}-deepdive-*.md`)
+ two synthesis files (`agent-workspace/research/INTEGRATION_PROPOSAL_2026-05-15.md` 919 LOC +
`INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md` 603 LOC).

Phase A surfaced **5 material deltas vs master-plan hypothesis** + **1 net-new theme** that
require fresh human ratification before Phase D-K IMPL can begin. This ADR records the integration
choices Phase A locked in and queues the 4 NEW Q-INT-2026-05-bis questions for human gate.

Per post-mortem `agent-workspace/post-mortems/2026-05-14-mass-deletion-recovery.md` § 1b, the
prior D-058 ratification audit trail was LOST in the 2026-05-14 mass-deletion. This ADR (D-061)
is the recreation; D-059 + D-060 are landed and unaffected. Latest landed ADR before this = D-060.

## Analysis

### Material demotions (Phase A empirical evidence vs master-plan hypothesis)

1. **FinceptTerminal MEDIUM → LOW** per `INTEGRATION_PROPOSAL_2026-05-15.md:40 + § 4.1` four-point
   rationale: AGPL + Commercial-license-required (USD 10,200/yr per `LICENSE:70`); C++/Qt6 stack
   = zero LOC ports to Streamlit; pattern-yield concentrated in 3 small primitives (~20 + 50 LOC)
   (per `master-planner-A-04-deepdive-FinceptTerminal.md § 5`). **Wave-1 impact**: Theme K PLAN
   session REMOVED entirely.

2. **MediaCrawler HIGH → MEDIUM-LOW** per `INTEGRATION_PROPOSAL_2026-05-15.md:41 + § 5.1` five-point
   rationale: Non-Commercial Learning License 1.1 (NOT OSI; `LICENSE:1-59`); platform list 7
   Chinese platforms only (no VN targets `main.py:50-67`); signing/sub-detection layers
   platform-coupled (per `master-planner-A-05-deepdive-MediaCrawler.md § 5`). **Wave-1 impact**:
   MediaCrawler REMOVED from Theme L IMPL slot; pattern-reference only for CDP-consented mode.

3. **Scrapling Cloudflare-solver HARD REJECT** per `INTEGRATION_PROPOSAL_2026-05-15.md:602-603 + § 12.5 #1`:
   `engines/_browsers/_stealth.py:107-181` is mouse-click-on-Turnstile automation (calculates
   Captcha coordinates + `page.mouse.click(captcha_x, captcha_y)` with randomized delays). Direct
   I-S34 ToS-conflict (per `master-planner-A-12-deepdive-Scrapling.md § 7 #1`). **Wave-1 impact**:
   sub-module exclusion explicit at IMPL time; core parser + adaptive selector + ProxyRotator +
   RobotsTxtManager + `find_similar` retained at HIGH fit per `§ 12.3-12.4`.

4. **Theme H winner INVERSION (debate-style over isolated-then-aggregate)** per
   `INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md § H.3` 9-row comparison table + rationale chain:
   - I-S12 literal compliance: TradingAgents stores verbatim debate transcript as
     `investment_debate_state.history` (`master-planner-A-13-deepdive-TradingAgents.md § 2.2`
     last paragraph + `INTEGRATION_PROPOSAL_2026-05-15.md § 13.1` last bullet).
   - ai-hedge-fund isolated-then-vote (`master-planner-A-01-deepdive-ai-hedge-fund.md § 5` third
     bullet) erases rebuttal dynamic — weaker I-S12 alignment.
   - Charter Principle 3 "Adversarial by Design" realized via debate; isolated produces parallel
     monologues without challenge.
   **Mandatory mitigations** drawn from `master-planner-A-13-deepdive-TradingAgents.md § 7.2-7.4`:
   first-speaker bias randomization (A-13 § 7.2); 4-round token-cap with summarization step
   before judge (A-13 § 7.3); AP-1 fresh-context judge subagent separation; BAN `entry_price` +
   `price_target` LLM-emit per Theme G recommendation (A-13 § 7.4).

5. **Theme G I-S1-1 GENUINE-new CONFIRMED (not redundant with I-S1)** per
   `INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md § G.2` 5-row empirical survey:
   - ai-hedge-fund (`warren_buffett.py:13-16` + `:788-794` confidence rubric LLM-self-reported).
   - TradingAgents (`agents/schemas.py:127, 199` `entry_price` + `price_target` Optional float).
   - TradingAgents-CN (`agents/trader/trader.py:68-80` "🚨 强制要求提供具体数值" — most aggressive
     LLM-emit pattern; per `master-planner-A-14-deepdive-TradingAgents-CN.md § 3.10 + § 7.5`).
   - Vibe-Trading `SKILL.md:138-139` enforces `confidence=low` on mech-annualisation violation
     (counterexample — deterministic categorical confidence, not LLM-emit).
   AP-23 red-flag check: SECOND instance of rule-about-rule for I-S1 (first was W0-2 D-059);
   **promote-or-retire trigger fires** → recommended path = constitution write in
   `financial-data-protocol.md` extension (faster than charter v1.1 → v1.2 amendment).

### Material promotion (net-new vs master plan)

6. **Theme N net-new — Vibe-Trading statistical-validation pipeline** per
   `INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md § N.1-N.4 + INTEGRATION_PROPOSAL_2026-05-15.md § 15.3 C9`:
   `agent/backtest/validation.py:1-200+` ships Monte Carlo permutation + Bootstrap Sharpe CI +
   Walk-Forward as 3 independent functions called only if `config["validation"]` is present.
   Per `master-planner-A-15-deepdive-Vibe-Trading.md § 3 C9`: "Critical for Charter Month-12
   success criterion ('demonstrable alpha vs VN-Index') — without statistical-validation the
   alpha claim is empty." MIT-licensed → LOC port permitted. **Disposition**: DEFERRED past
   Wave 1 to candidate Wave 2+ ADR + PLAN session (Month-12 enabler; not Wave-1 critical path).

## Decision

This ADR ratifies (pending Q-INT-2026-05-bis answers) the following Wave-1 integration choices:

### What this means concretely — Integration choices LOCKED by Phase A

1. **License-class hard filter ENFORCED** (per `INTEGRATION_PROPOSAL_2026-05-15.md § 16` matrix):
   - AGPL / Commercial-required / GPL / Non-Commercial / Modified-MIT-Non-Commercial:
     pattern-only, ZERO LITERAL LOC. Affects FinceptTerminal + MoneyPrinterPlus + MoneyPrinterV2
     + NarratoAI + MediaCrawler.
   - LGPL (nautilus_trader): pip-install dependency or re-implementation from architectural
     shape; no LOC vendoring.
   - Apache / MIT / BSD-3: LOC port permitted with attribution (per-file header + NOTICE root
     for Apache-2.0+Attribution-clause repos like crawl4ai).

2. **FinceptTerminal Theme K removed from Wave 1** (master-plan § 5.6 + § 6.4.5 PLAN session
   REMOVED entirely). Stockforge dashboard work Phase 2+ uses `streamlit-elements` /
   `streamlit-extras` direct, NOT FinceptTerminal-pattern study.

3. **MediaCrawler removed from Theme L IMPL slot**. Theme L hybrid winner = crawl4ai (Apache-2.0
   + NOTICE; ~800 LOC: `DefaultMarkdownGenerator` + `PruningContentFilter` + `RateLimiter` +
   `CacheValidator` + `BaseCrawler`/`CrawlerHub` shape) + Scrapling-core (BSD-3; ~600 LOC:
   adaptive selector + `find_similar` + `ProxyRotator` + `RobotsTxtManager` + browserforge)
   per `INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md § L.3` hybrid recommendation.

4. **Scrapling Cloudflare-solver HARD REJECT** + patchright DO NOT IMPORT + `StealthyFetcher`
   excluded as a class per `INTEGRATION_PROPOSAL_2026-05-15.md § 12.5 #1-#2`. Core parser +
   adaptive selector + ProxyRotator + RobotsTxtManager + `find_similar` retained.

5. **Theme H winner INVERTED to debate-style** (TradingAgents source pattern;
   `agents/utils/agent_states.py:7-43` + `graph/conditional_logic.py:46-67`) with 4 mandatory
   mitigations:
   a) Randomise first speaker OR rotate over runs (A-13 § 7.2).
   b) Cap debate rounds at design time (4-round max); design summarisation step before judge
      for ≥4 perspectives × ≥2 rounds (A-13 § 7.3).
   c) Fresh-context judge subagent separate from debate participants (AP-1 mitigation per
      CLAUDE.md "Never review your own implementation").
   d) BAN `entry_price` + `price_target` LLM-emit (A-13 § 7.4); LLM emits reasoning,
      deterministic pipeline emits numbers.

6. **Theme G recommended path = constitution write** in `agent-workspace/constitution/financial-data-protocol.md`
   (path B per master plan Q-INT-2026-05-3 option B) — faster than charter v1.1 → v1.2 amendment;
   requires explicit human-approve gate per CLAUDE.md hard rule; AP-23 promote trigger satisfied.
   **Pending user-ratify Q-INT-2026-05-6**.
   **Ratification follow-through: D-065 ACCEPTED 2026-05-16 via S336 user Path B pick; Rule 16 landed in `financial-data-protocol.md`.**

7. **Theme N net-new disposition = DEFER to Wave 2+** with ADR-first PLAN session post-Wave-1.
   Pairs with Theme M-3 (nautilus backtest skeleton) — Theme N is statistical layer; M-3 is
   simulation layer. **Pending user-ratify Q-INT-2026-05-7**.

8. **W0-3 / W0-4 / W0-5 ports** now have empirically-confirmed citation chains:
   - W0-3 atomic temp-file-replace: TradingAgents `memory.py:109-114 + :161-163 + :215-217` +
     test `tests/test_memory_log.py:426-437` (`INTEGRATION_PROPOSAL_2026-05-15.md § 13` first bullet).
   - W0-4 HTML-comment separator: TradingAgents `memory.py:13-14` `_SEPARATOR = "\n\n<!-- ENTRY_END -->\n\n"`
     (`INTEGRATION_PROPOSAL_2026-05-15.md § 13` second bullet).
   - W0-5 path-safety quad: Vibe-Trading `agent/src/tools/path_utils.py:1-213` (4 helpers + shared
     `_rejects_unc`) + tests `agent/tests/test_path_safety.py:1-136`
     (`INTEGRATION_PROPOSAL_2026-05-15.md § 15` last bullet).

### What does NOT change

- D-059 (Python determinism contract) remains ACCEPTED — Phase A A-10 § 1.5 re-confirmed nautilus
  DST doctrine at IMPL site.
- D-060 (commit policy — agents MAY commit, MUST NOT push) remains ACCEPTED.
- Charter v1.1 + 11 principles + I-S1..I-S35 invariants: UNCHANGED. This ADR ratifies plan
  revisions at IMPL tier; it does NOT amend charter.
- Master plan critical-path ordering: L → I → H → J → K CONFIRMED by Phase A findings (per
  `INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md § R.5`).

## Why (Reasons)

1. **Charter Principle 8 (calibration over confidence)** — Phase A empirical evidence MUST
   replace master-plan hypothesis where the two diverge. Option B (keep hypothesis) would
   discard 15 deep-dives' worth of file:line-cited findings.
2. **I-S2 (every claim sourced)** — this ADR cites a deep-dive section + repo file:line for
   every material claim.
3. **I-S34 (public sources only + ToS compliance)** — Scrapling Cloudflare-solver + MediaCrawler
   stealth.min.js + reverse-engineered signing keys are direct violations (`A-12 § 7 #1` +
   `A-05 § 7 #1+#2`). HARD REJECT enforces compliance.
4. **License compliance** — adopting AGPL/Non-Commercial repos under "patterns-only" rule
   protects stockforge's proprietary-by-default posture (per `INTEGRATION_PROPOSAL_2026-05-15.md § 16`).
5. **AP-23 promote-or-retire trigger** — I-S1-1 is the 2nd refinement-of-rule for I-S1 (D-059
   was the 1st); CLAUDE.md hard rule mandates promote to dedicated rule, not inline accumulation.
6. **R7 mitigation (no can-kicking)** — deferring ratification (option C) would inflate
   `defer_cycles` past the > 3 threshold; Phase A was the empirical-evidence collection.

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Q-INT-2026-05-bis answers diverge from "Recommended" picks | Med | All 4 options are surfaced with rationale; user can pick differently (e.g., Theme N option B "add to Wave 1 PLAN") and the master plan will revise per S327 RECOVERY clause |
| Theme H debate-style quadratic token cost exceeds budget | Med | A-13 § 7.3 mitigation: 4-round token-cap + summarisation step before judge; A-13 § 7 risk #2 records adversarial fallback to isolated-then-aggregate if empirical performance underwhelms |
| Constitution-write for I-S1-1 blocked at human-approve gate | Low | Phase C (S333-S334) gate is honestly out-of-band; if blocked, Phase F-prime Theme H IMPL can proceed with explicit "I-S1-1 NOT yet active; using interim ban-list" workaround |
| Theme N (Vibe-Trading validation pipeline) deferred too long → Month-12 gate at risk | Low | Master plan Wave 2+ scope still has runway; Charter Month-12 criterion is still ~7 months out; Theme N PLAN session can be triggered any time post-Wave-1 close |
| Q-INT-2026-05-bis SLA missed (default 48h) | Low | Standard pending → stale auto-mv per `agent-workspace/CLAUDE.md` Auto-mv rule; bundle frontmatter `expected_answer_by: 2026-05-17T00:00Z` |

## Consequences

**Refined Wave-1 envelope** (per `INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md § R.3`):
- Phase A: 4-5 sessions, ~760-980K (complete)
- Phase B: 4-5 sessions, ~400-650K (W0-2.1 + W0-3 + W0-4 + W0-5)
- Phase C: 1-2 sessions, ~80-160K (Theme G constitution write)
- Phase D: 3-4 sessions, ~400-650K (Theme L crawling; -10-30K from MediaCrawler demotion +
  Scrapling sub-module rejection)
- Phase E: 3-4 sessions, ~400-650K (Theme I VN NLP)
- Phase F-prime: 3-4 sessions, ~400-650K (Theme H BC-8 multi-perspective; INVERTED to debate-style)
- Phase G-prime: 1 PLAN, ~50-80K (Theme J PDF; IMPL deferred to Phase 2 entry)
- Phase H-prime (Theme K UX): NONE in Wave 1 (-50K from master-plan removal)
- Theme M (nautilus risk + backtest + MessageBus): NONE in Wave 1 (deferred)
- Theme N (Vibe-Trading validation pipeline): NONE in Wave 1 (NET-NEW; deferred to Wave 2+)

**Total Wave 1**: 15-20 sessions / ~2840-4180K tokens
(vs master plan original: 16-22 sessions / 3000-4500K tokens; net savings ~-1 session / ~-160-320K).

**Downstream effects**:
- Wave-1 Theme K dropped entirely (FinceptTerminal demotion).
- New Theme N catalogued for Wave 2+ pipeline (Month-12 enabler).
- W0-3 / W0-4 / W0-5 port instructions now reference empirically-confirmed citation chains.
- Theme L IMPL plan (S-future) will reference hybrid crawl4ai + Scrapling-core architecture
  (no MediaCrawler LOC; no Cloudflare-solver code path).
- Theme H IMPL plan (S-future) will reference debate-style topology + 4 mandatory mitigations.
- Theme G constitution-write proposal (S333 PLAN) will reference I-S1-1 confirmed-genuine status.

## Alternatives Considered

### Alternative theme orderings

Master plan § 6.4 already settled L → I → H → J → K = A (per S322 Q-INT-2026-05-2 = A). Phase A
findings CONFIRM this ordering — no inversion required at the phase level. L is Phase-1
critical-path (BC-5 News M3 success criterion); I depends on L upstream; H depends on G; J + K
are Phase-2 work.

### Alternative Theme H pattern

The Phase A empirical-evidence-driven inversion (isolated-then-aggregate → debate-style) is the
primary alternative considered. Master-plan default (`A-01 § 5` "Recommendation: adopt this
pattern as Wave-1 default for BC-8; defer debate-style until evidence shows ensemble
underperforms") was the conservative choice. SUPPLEMENT § H.3 reasoning chain demonstrates
debate-style is the **principled** I-S12 fit, not just the alternative. Adversarial-alternate
kept on shelf: if empirical IMPL evidence shows quadratic token cost dominates, RECOVERY session
re-plans to isolated-then-aggregate.

### Alternative Theme G paths

- (A) Charter v1.1 → v1.2 amendment — heaviest machinery (48h cool-down per Revision Protocol +
  written rationale + version bump). Rejected per SUPPLEMENT § G.3: "heavy machinery for a
  sub-rule that operationalizes existing principle 9."
- (B) Constitution write in `financial-data-protocol.md` — RECOMMENDED per SUPPLEMENT § G.3:
  "faster, agent-forbidden direct write → requires explicit human-approve gate per CLAUDE.md
  hard rule."
- (C) Skip — empirically rejected per SUPPLEMENT § G.2 (3 main frameworks have LLM-emit
  confidence/price; I-S1 + I-S7 alone don't enforce at schema-level).
- (D) Defer further — can-kicking per R7 mitigation.

### Alternative Theme N treatments

- (A) Defer to Wave 2+ — RECOMMENDED per SUPPLEMENT § N.3 (Month-12 still has runway).
- (B) Add to Wave 1 as PLAN-only — preserves option to start design without IMPL until BC-9
  backtest exists.
- (C) Add to Wave 1 as PLAN + IMPL — expands envelope by ~200-350K.
- (D) Charter-flag as Month-12 gate.

## Open Questions

Q-INT-2026-05-bis questions queued in `human-workspace/q-and-a/pending/qa-2026-05-15-wave-1-bis.md`:
- **Q-INT-2026-05-5** — Theme H pattern winner (debate vs isolated vs hybrid vs defer).
- **Q-INT-2026-05-6** — Theme G path (constitution vs charter vs skip vs defer).
- **Q-INT-2026-05-7** — Theme N net-new fate (defer Wave 2+ vs Wave 1 PLAN vs Wave 1 PLAN+IMPL
  vs charter-flag).
- **Q-INT-2026-05-8** — Theme L crawling adapter pick (dual-adapter vs crawl4ai-only vs
  Scrapling-core-only vs defer).

This ADR moves PROPOSED → ACCEPTED upon answers landing (file
`human-workspace/q-and-a/answered/qa-2026-05-15-wave-1-bis.md`).

## Provenance

Sources read by this S325 dispatch (master-planner subagent):

1. `agent-workspace/memory/decisions/_template.md` (12-field schema)
2. `agent-workspace/research/INTEGRATION_PROPOSAL_2026-05-15.md` (919 LOC; full read in chunks)
3. `agent-workspace/research/INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md` (603 LOC; full read
   in chunks)
4. `agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md` (§ 1, § 6.2-6.5, § 7,
   § 8, § 9, § 10)
5. `agent-workspace/memory/decisions/060-S321-commit-policy-agent-may-commit.md` (style + most-recent-ADR cite)
6. `agent-workspace/memory/decisions/059-python-determinism-contract.md` (depends_on cite)
7. `agent-workspace/memory/observations/queued-grill-master.md` (confirmed all items closed; no
   re-fire pending)
8. `agent-workspace/memory/observations/master-planner-A-01-deepdive-ai-hedge-fund.md` (via § 1
   summary in INTEGRATION_PROPOSAL_2026-05-15.md)
9. `agent-workspace/memory/observations/master-planner-A-04-deepdive-FinceptTerminal.md` (via § 4
   summary)
10. `agent-workspace/memory/observations/master-planner-A-05-deepdive-MediaCrawler.md` (via § 5
    summary)
11. `agent-workspace/memory/observations/master-planner-A-10-deepdive-nautilus_trader.md` (via
    § 10 summary)
12. `agent-workspace/memory/observations/master-planner-A-12-deepdive-Scrapling.md` (via § 12
    summary)
13. `agent-workspace/memory/observations/master-planner-A-13-deepdive-TradingAgents.md` (via § 13
    summary)
14. `agent-workspace/memory/observations/master-planner-A-14-deepdive-TradingAgents-CN.md` (via
    § 14 summary)
15. `agent-workspace/memory/observations/master-planner-A-15-deepdive-Vibe-Trading.md` (via § 15
    summary)
16. `agent-workspace/post-mortems/2026-05-14-mass-deletion-recovery.md` (§ 1b D-058 LOST cite)
17. `agent-workspace/CLAUDE.md` (Q&A bundle + auto-mv rule context)
18. `human-workspace/q-and-a/answered/2026-05-07-001-phase-3.5-T5-T6-T8-charter-gate.md` (style
    reference)
19. `agent-workspace/memory/sync-tracker/state.tsv` (sync-state advisory check; no
    must_grill_remaining items pending)

## Acceptance Record

- **2026-05-15**: PROPOSED by Claude Opus 4.7 (master-planner subagent, S325 dispatch).
  Awaiting Q-INT-2026-05-bis answers in
  `human-workspace/q-and-a/pending/qa-2026-05-15-wave-1-bis.md`.
- (Pending) **YYYY-MM-DD**: ACCEPTED — to be filled when user answers Q-INT-2026-05-5..8.
