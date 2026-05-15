---
plan_id: 2026-05-15-wave-1-research-integration
created: 2026-05-15
author: master-planner subagent (dispatched from S322 main session)
parent_directive: agent-workspace/research/RECOVERED-20260513_01-user-prompt.txt
language_of_directive: Vietnamese (faithful reconstruction; original 20260513_01.txt lost in 2026-05-14 mass-deletion)
phase_coverage: Phase 0 (Wave 0 finish) → Phase 1 entry (Wave 1 themes G/H/I/J/K/L) → Phase 1 Foundation overlap
status: ratified (Q-INT-2026-05-1..4 = A/A/C/A at S322; Q-INT-2026-05-5..8 = A/A/A/A at S326 via D-061 ACCEPTED 2026-05-15T15:30+07:00 blanket-A user pick)
predecessor_state: S321-close (commit da02ad0; plan 015 Batch E still pending in S322; Wave 0 W0-1/W0-1b/W0-2 DONE; W0-2.1/3/4/5 TODO; D-058 LOST in mass-deletion)
ratification_gate: ≤4 AskUserQuestion items below (§ 8); plan does NOT execute until those return
budget_envelope: ~16-22 sessions (Phase A 4-5 PLAN/INGEST sessions; Phase B 4-5 IMPL sessions; Phase C 1-2 charter sessions; Phases D-K ~8-12 product sessions, ordering refines per ratification)
hard_rules_acknowledged:
  - "no production code in this PLAN session (CLAUDE.md § Session Types — never mix PLAN + IMPL)"
  - "no commits in this PLAN session (master-planner subagent dispatch instructions)"
  - "no charter / constitution / human-workspace writes (CLAUDE.md hard rules)"
  - "every claim in this plan cites source — provenance per § 9"
  - "research-aid framing only — I-S35 (no marketing-style 'buy/sell' output even when surveying MoneyPrinter*-style video repos)"
provenance_summary: |
  This plan was authored from these binding sources, all read at session start (S322 dispatch turn):
    - agent-workspace/research/RECOVERED-20260513_01-user-prompt.txt (user intent)
    - agent-workspace/memory/current-execution.md (Wave 0 progress, BEHAVIORAL HOLD, S322 next-action)
    - agent-workspace/memory/checkpoints/latest.md (S321-close state)
    - PROJECT_CHARTER.md v1.1 (11 principles; I-S1..I-S35 stock invariants)
    - agent-workspace/constitution/architecture.md (9 BCs)
    - agent-workspace/constitution/invariants.md + invariants-stockforge.md (binding rules)
    - agent-workspace/constitution/session-budgets.md (sizing rules)
    - agent-workspace/memory/decisions/059-python-determinism-contract.md (W0-2 ACCEPTED)
    - agent-workspace/memory/decisions/060-S321-commit-policy-agent-may-commit.md (D-060)
    - agent-workspace/research/r-2026-05-01-claude-cli-substrate.md (CLI-subprocess pattern)
    - agent-workspace/post-mortems/2026-05-14-mass-deletion-recovery.md (loss list + R1/R2/R3 prevention status)
    - C:/htdocs/research/ directory listing (15 repos confirmed; per-repo docs/ paths per dispatch brief)

  Repo deep-dive material referenced below is RECONSTRUCTED from the dispatch brief's inventory table
  + general repo-domain knowledge — the prior S259 deep-dives are LOST and Phase A of THIS plan
  re-creates them. Repo-specific FIT claims marked [pending Phase A empirical re-survey] are HYPOTHESES,
  not verified findings, and Phase A's deep-dive subagents will replace them with file-cited evidence.
---

# Master Plan — Wave 1+ Research-Repo Integration into StockForge

> **Single sentence**: Recover the lost S259/D-058 research audit trail, finish the harness substrate
> (Wave 0 W0-2.1/3/4/5), then run a stockforge-need-driven cherry-pick of components, patterns, and
> design discipline from 15 reference repos in `C:/htdocs/research/` — without copying entire
> frameworks, without violating research-aid framing (I-S35), and without spending tokens on
> repos whose fit is honestly low.

---

## 1. Goal & Non-Goals

### 1.1 Goal (verbatim user intent, translated)

Reference the 15 repos in `C:/htdocs/research/` to learn components, architecture, implementation,
effectiveness — to integrate value into StockForge. Both stock/financial-business depth AND data-
crawling depth are in scope. Most repos have a `docs/` (often with `onboarding/` subdir) as the
entry point; Phase A deep-dives use those as the launch. Analyze carefully, self-assess, propose
options/components/designs/features, build the integration plan.

Source: `agent-workspace/research/RECOVERED-20260513_01-user-prompt.txt` (faithful reconstruction;
original lost 2026-05-14 mass-deletion per `post-mortems/2026-05-14-mass-deletion-recovery.md` §1b).

### 1.2 What this plan DOES drive

- **Stockforge-need-driven adoption**: themes are organized by which stockforge bounded context
  (BC-1 .. BC-9 per `constitution/architecture.md`) or harness gap the integration closes — not
  by repo order or repo size.
- **Component-level + pattern-level adoption**, not framework wholesale-port. Wave 0 W0-1/W0-1b
  already proved this works: stockforge ported a single 8-state FSM concept from nautilus_trader
  without adopting the rest of nautilus_trader.
- **Audit-trail reconstruction**: Phase A re-creates the lost `INTEGRATION_PROPOSAL_2026-05-13.md`
  + `INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-13.md` + 7 lost `general-purpose-S259-deepdive-*.md`
  observation files + lost D-058 ratification (per post-mortem §1b).
- **Honest fit-assessment** per § 4: high-fit repos get IMPL sessions; low-fit repos get a
  one-paragraph "out of scope, here's why" entry and zero downstream sessions.

### 1.3 What this plan EXPLICITLY DOES NOT drive (non-goals)

- **NOT a wholesale port of any single repo**. We are not building "stockforge as a fork of
  nautilus_trader" or "stockforge as a fork of TradingAgents". Each integration is a surgical
  pattern lift or component port with attribution.
- **NOT a content-marketing pipeline**. MoneyPrinter*/NarratoAI/Pixelle-Video repos generate
  short videos / TikTok / YouTube content. Even if their tech is interesting, stockforge output
  must remain framed as "research aid, not financial advice" (I-S35 + charter principle line 117).
  Any video/output-distribution adoption MUST preserve that framing in the generated artifacts.
- **NOT a license-fork**. License compliance is § 7-Risk-L1 — pattern adoption is generally safe,
  literal code-copy needs attribution + license-compatibility check per repo.
- **NOT in this PLAN session**: no production code, no commits, no charter edits, no constitution
  writes, no human-workspace writes. This is a PLAN session per CLAUDE.md § Session Types — output
  is this single master-plan markdown + the ratification AskUserQuestion items.

---

## 2. Inventory — 15 Repos at `C:/htdocs/research/`

Confirmed from dispatch brief's inventory table (path + primary-language + docs/ entry + domain).
All 15 have `docs/`. ⭐ marks "high fit" per § 4 honest-assessment.

| # | Repo | Language | docs/ entry | Domain | Lost S259 deep-dive? |
|---|---|---|---|---|---|
| 1 | `ai-hedge-fund` ⭐ | Python | `docs/onboarding/` | Stock/financial agent system | YES — re-create Phase A |
| 2 | `crawl4ai` ⭐ | Python | `docs/md_v2/`, `docs/codebase/` | LLM-friendly web crawling | YES — re-create Phase A |
| 3 | `dexter` | TypeScript | `docs/onboarding/` | Trading/finance (TS) | YES — re-create Phase A |
| 4 | `FinceptTerminal` | C++ + Python | `docs/ARCHITECTURE.md`, etc. | Bloomberg-terminal-style UI | NO — new deep-dive |
| 5 | `MediaCrawler` ⭐ | Python | `docs/index.md`, `docs/data_storage_guide.md` | Social media crawling (Chinese) | NO — new deep-dive |
| 6 | `MoneyPrinterPlus` | Python | `docs/en/`, `docs/jp/` | Short-video gen | NO — new deep-dive |
| 7 | `MoneyPrinterTurbo` | Python | `docs/GPU_DOCKER_DEPLOYMENT.md` | Short-video AI pipeline | NO — new deep-dive |
| 8 | `MoneyPrinterV2` | (mixed) | `docs/Roadmap.md`, `docs/YouTube.md` | Multi-platform content automation | NO — new deep-dive |
| 9 | `NarratoAI` | Python | `docs/` mostly screenshots | AI narration / video story | NO — new deep-dive |
| 10 | `nautilus_trader` ⭐ | Rust + Python | `docs/concepts/`, `docs/integrations/`, etc. | Production algo trading | YES — already partially harvested (W0-1/W0-1b/W0-2); re-create + complete |
| 11 | `Pixelle-Video` | Python | `docs/en/`, `docs/zh/` | Video generation | NO — new deep-dive |
| 12 | `Scrapling` ⭐ | Python | `docs/README_*.md` (root README primary) | Fast adaptive scraping | YES — re-create Phase A |
| 13 | `TradingAgents` ⭐ | Python | `docs/onboarding/` | Multi-agent stock-trading framework | YES — re-create Phase A (W0-3/4 already in pipeline) |
| 14 | `TradingAgents-CN` ⭐ | Python | `docs/ANALYST_DATA_CONFIGURATION.md`, etc. | TradingAgents CN-market fork | NO — new deep-dive (HIGH priority — A-share parallels VN-share) |
| 15 | `Vibe-Trading` ⭐ | Python | `docs/onboarding/`, `docs/2026-04-30_*.md` | A-share trading | YES — re-create Phase A (W0-5 in pipeline) |

**7 lost S259 deep-dives** to re-create per post-mortem §1b: `TradingAgents`, `ai-hedge-fund`,
`nautilus_trader`, `Scrapling`, `crawl4ai`, `dexter`, `Vibe-Trading`.

**8 new deep-dives** (never surveyed pre-mass-deletion): `FinceptTerminal`, `MediaCrawler`,
`MoneyPrinterPlus`, `MoneyPrinterTurbo`, `MoneyPrinterV2`, `NarratoAI`, `Pixelle-Video`,
`TradingAgents-CN`.

---

## 3. Re-establish Lost Prior Work (Phase A entry)

The 2026-05-14 mass-deletion destroyed (per post-mortem §1b table):

| Lost artifact | Original LOC | Mitigation status |
|---|---|---|
| `agent-workspace/research/INTEGRATION_PROPOSAL_2026-05-13.md` | ~340 | Findings ONLY partially preserved (D-058 was itself lost — see below) |
| `agent-workspace/research/INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-13.md` | ~700 | Same — partial-only preservation; full content gone |
| 7× `agent-workspace/memory/observations/general-purpose-S259-deepdive-*.md` | unknown | LOST; re-creatable from Phase A re-dispatch |
| `human-workspace/user_prompt/20260513_01.txt` | 17 lines | RECONSTRUCTED in `agent-workspace/research/RECOVERED-...txt`; human must manually copy back |
| **D-058 (Q-INT mega-bundle ratification)** | unknown | **CONFIRMED LOST**: `agent-workspace/memory/decisions/` listing (read at S322 dispatch) shows 058 + 057 + 055 ALL ABSENT — only 056 + 059 + 060 present in the 050+ range. The mass-deletion table flagged "D-058 preserved" but the file is empty/missing. Phase A MUST re-author D-057/D-058 or the new equivalent numbering. |

**Implication**: Phase A is NOT optional — without it, every Wave-1 IMPL session forward operates
on unverifiable hypotheses about each repo's content. The dispatch brief's "FIT-rating" claims in
§ 4 below are HYPOTHESES until Phase A subagents re-verify.

**Phase A deliverables** (concrete files to author):

1. **15 deep-dive observation files** at `agent-workspace/memory/observations/master-planner-A-<N>-deepdive-<repo>.md`
   — one per repo, each cites file paths inside the repo + names specific components/patterns.
   Format mirrors the lost S259 format (which itself can be inferred from the surviving
   `D-059` cite: `general-purpose-S259-deepdive-nautilus_trader.md §1.5 DST doctrine`).
2. **`agent-workspace/research/INTEGRATION_PROPOSAL_2026-05-15.md`** (replaces the lost
   `..._2026-05-13.md`) — synthesizes the 15 deep-dives into themed integration recommendations
   + license-compliance audit + per-recommendation BC mapping.
3. **`agent-workspace/research/INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md`** (replaces the lost
   `..._SUPPLEMENT_2026-05-13.md`) — cross-repo theme synthesis (the "Theme F .. Theme L"
   structure of § 5 below).
4. **New D-NNN ratification ADR** authored at IMPL tier (D-058 number is taken by the lost
   ADR — agent must use the next-available decision number; latest landed is D-060 so probable
   path is **D-061** authored at Phase A close, ratifying the new INTEGRATION_PROPOSAL_2026-05-15
   approach + ordering of themes). Honors decision-discipline rules per `decisions/_template.md`.
   The lost D-058 audit trail is documented in this ADR as "supersedes via re-creation".
5. **Q-INT-2026-05 mega-bundle** at `human-workspace/q-and-a/pending/qa-2026-05-15-wave-1-integration.md`
   bundling all ratification questions (see § 8) for human approval.

**Phase A dispatch shape** (deterministic, NOT in this PLAN session):

- 15 parallel `general-purpose` subagents (one per repo) per the S259 precedent. R1
  `destructive-command-guard.sh` is now ACTIVE (per current-execution.md "INCIDENT + RECOVERY" section)
  — re-running parallel subagents is safer than at the S259 era pre-R1. Each subagent is briefed
  read-only with explicit prohibition of any tool that could mass-delete or git-mutate.
- Budget: 30-40K tokens per subagent (8-12K input briefing + 15-25K analysis output) = 450-600K
  tokens total across the 15 — but parallel, so wall-time ≈ longest single subagent (~5-10 min).
- Run with `run_in_background=true` per the SessionStart guidance (per CLAUDE.md and the dispatch
  brief's "subagent dispatches in subsequent phases must be `run_in_background=true`").

---

## 4. Repo-by-Repo Fit Assessment

Honesty bar: per user directive `phân tích kĩ và tự đánh giá`. "FIT" = does this repo's content
materially advance stockforge's stated goals in `PROJECT_CHARTER.md` Phase 1-4 success criteria?

Levels: **HIGH** (drives ≥1 IMPL session), **MEDIUM** (informs ≥1 design decision; possibly
informs IMPL; standalone session not guaranteed), **LOW** (one-paragraph mention, no follow-up),
**N/A** (out of scope, document why).

All FIT claims below are **[pending Phase A empirical re-survey]** — final claims will be in the
Phase A deep-dive files + the new INTEGRATION_PROPOSAL_2026-05-15.md.

### 4.1 ai-hedge-fund — FIT: HIGH (BC-8 + I-S1-1 confidence-field discipline)

**What it does**: Python multi-agent system simulating stock-fund roles (analyst / portfolio manager
/ risk / etc.).
**BC mapping**: BC-8 (Analysis & Thesis multi-perspective adversarial) — directly aligned with
charter principle 3 ("adversarial by design"). Charter I-S11 requires ≥2-perspective synthesis,
ideally ≥4 — ai-hedge-fund's role-set is a candidate primitive set.
**Candidate components/patterns** (hypothesis, Phase A verifies):
- Role-prompt templates for analyst / portfolio-manager / risk-officer (compare with
  charter list: bear / bull / quant / behavior / macro / manager).
- Confidence-field surfaces in agent outputs (Phase G — see § 5.2: "don't let LLM emit
  `confidence: 0.83` ungrounded"); ai-hedge-fund + TradingAgents both reportedly surface this
  per the dispatch brief's recollection of lost S259 work.
**Wave-1 IMPL candidate sessions**: Theme H (BC-8 multi-perspective primitives) — pattern
selection between ai-hedge-fund's isolated-perspective-then-aggregate vs TradingAgents'
debate-style synthesis.
**License check pending Phase A**: assess `LICENSE` file for compatibility with stockforge's
proprietary-by-default + Charter "Not a goal: providing licensed financial advice" framing.

### 4.2 crawl4ai — FIT: HIGH (BC-5 News Stream + BC-6 Influence + BC-7 Crowd ingestion)

**What it does**: LLM-friendly web crawling — converts pages to markdown clean enough for LLM
extraction; production-tested.
**BC mapping**: BC-5 News Stream (CafeF / NDH / VietstockFinance / Vietnam Biz scraping),
BC-6 Influence (KOL YouTube/Facebook scraping), BC-7 Crowd (forum/group scraping).
**Candidate components/patterns**:
- LLM-friendly markdown converter (vs html-to-text raw — preserves table structure, removes
  ads/nav consistently).
- Async crawler scheduling (rate limits per source — respects I-S34 ToS).
- Content-fingerprint dedup (relevant for daily-recurring news with minor edits).
**Wave-1 IMPL candidate sessions**: Theme L (crawling adapter shape). Compare with Scrapling +
MediaCrawler before final pick.
**Risk**: Vietnamese-source-specific selectors won't be in upstream; we extend per Theme I.

### 4.3 dexter — FIT: MEDIUM (informational; TypeScript not stockforge's primary)

**What it does**: Trading/finance TypeScript repo. Per dispatch-brief inventory: "specify after read".
**BC mapping**: Unclear pre-Phase-A. If it's strategy-pattern-rich, may inform BC-8 / BC-9 design
even without code-port (stack mismatch: stockforge is Python-primary per architecture.md).
**Wave-1 IMPL candidate sessions**: Theme H or Theme K possibly informed by patterns; NO direct
IMPL session — pattern-only adoption.
**License check pending Phase A**.

### 4.4 FinceptTerminal — FIT: MEDIUM (BC-9 dashboard UX inspiration)

**What it does**: Bloomberg-terminal-style finance UI (C++ + Python). Per dispatch brief: docs
include ARCHITECTURE.md / GETTING_STARTED.md / CPP/PYTHON contributor guides / CRYPTO_WALLET_CONNECT.md.
**BC mapping**: BC-9 (Portfolio & Action — dashboard surface; charter says "Streamlit for personal
dashboard Phase 1-2"). FinceptTerminal's data-density patterns + alert-surface design are
informational reference, not direct code-port (stack: C++ ≠ stockforge Streamlit/Next.js).
**Candidate components/patterns**:
- Multi-pane layout for time-series + news + KOL chatter (charter's "personal Bloomberg
  Terminal — data density + analysis depth" reference model in PROJECT_CHARTER.md line 51).
- Alert-tier visualization (color coding).
- Workspace/layout persistence model.
**Wave-1 IMPL candidate sessions**: Theme K (UX/output) — single PLAN-session design study,
ideally Phase 2+ when Streamlit dashboard work activates. NOT a Phase 1 priority.

### 4.5 MediaCrawler — FIT: HIGH (BC-7 Crowd + BC-6 Influence; Chinese-platform patterns
transferable to VN)

**What it does**: Python crawler for Xiaohongshu / Douyin / Kuaishou / Bilibili / Weibo / Tieba /
Zhihu. Production code with anti-detection patterns. Docs include `data_storage_guide.md` +
`CDP模式使用指南.md` (CDP browser mode usage).
**BC mapping**: BC-6 (Influence: KOL channel monitoring on YouTube/Facebook), BC-7 (Crowd:
F319 group chats / public discussion forums). The PATTERNS (anti-detection, login-state
preservation, scroll-pagination) are highly transferable to VN platforms even though the
target platforms differ.
**Candidate components/patterns**:
- Headless browser session-state preservation (vs cookie-jar-only).
- CDP mode (Chrome DevTools Protocol) integration for harder-to-scrape platforms.
- Comment-tree extraction pattern (for KOL-video comment analysis).
- Storage adapter shape (file / db / kafka — picks aligned with stockforge Postgres + R2 stack).
**Wave-1 IMPL candidate sessions**: Theme L crawling — likely picks MediaCrawler for
JavaScript-heavy VN sources where crawl4ai's lighter approach fails.
**Risk**: ToS compliance (I-S34) — Chinese-platform scrapers may have legal-grey patterns that
DON'T transfer to VN/EU legal context. Phase A must flag these.

### 4.6 MoneyPrinterPlus — FIT: LOW (out-of-scope for Phase 1-2)

**What it does**: Short-video content generation (en + jp docs).
**BC mapping**: None in Phase 1-2. Theoretical Phase 4+ — "thesis summary video" output for the
3-5 trusted-peer circle. But the user explicit non-goal in charter is "Not a goal: ... becoming
a SaaS in Year 1, beating frontier LLMs at general reasoning".
**Honest assessment**: The user prompt says "đều có thể học hỏi" so don't dismiss — but Phase A
should produce a thin deep-dive that catalogs WHAT could theoretically apply (video-summary of a
thesis for the trusted peers), then defer indefinitely to Phase 4+. Output-side adoption MUST
preserve I-S35 disclaimer in the video itself.
**Wave-1 IMPL candidate sessions**: NONE.

### 4.7 MoneyPrinterTurbo — FIT: LOW (out-of-scope for Phase 1-2; same rationale as 4.6)

**What it does**: Short-video AI pipeline (GPU-Docker docs + colab notebook).
**Honest assessment**: Same as 4.6 — thin Phase A deep-dive, defer.

### 4.8 MoneyPrinterV2 — FIT: LOW (out-of-scope; differs from 4.6/4.7 only in being multi-platform)

**What it does**: Multi-platform content automation (Affiliate Marketing / PostBridge / TwitterBot /
YouTube docs).
**Honest assessment**: The PostBridge cross-posting pattern (publish once → fan out to N platforms)
COULD theoretically inform thesis-distribution to the trusted-peer circle — but charter says
"build for ourselves and 3-5 peers" so the fan-out value is low. Same as 4.6.

### 4.9 NarratoAI — FIT: LOW (same as 4.6/4.7/4.8)

**What it does**: AI narration / video story (docs mostly screenshots).
**Honest assessment**: Same as 4.6.

### 4.10 nautilus_trader — FIT: HIGH (already partially harvested; finish Wave 0)

**What it does**: Production-grade algorithmic trading platform (Rust core + Python bindings).
**BC mapping**: BC-1 (Market Data; high-precision time-series), BC-9 (Portfolio & Action;
backtest engine architecture). Already partially harvested:
- **W0-1 (DONE)**: 8-state observation-lifecycle FSM ported (per current-execution.md S311
  result + verified S312 PASS).
- **W0-1b (DONE)**: re-escalation + col7 schema (S313/S314 PASS).
- **W0-2 (DONE)**: Python determinism contract D-059 ACCEPTED (DST doctrine from
  `general-purpose-S259-deepdive-nautilus_trader.md §1.5`).
- **W0-2.1 (TODO)**: pre-existing Python-determinism violations in production code
  (`capture_sentiment_snapshot_use_case.py` R2 + `sqlite_thesis_repository.py` R1, per
  current-execution.md S315 result).
**Candidate components/patterns** (Phase A re-creates the lost S259 deep-dive to confirm):
- Event-driven message bus pattern (cross-BC events per architecture.md "Event Flow"
  Phase 2+ "consider event-driven across BCs with proper broker").
- Strategy/Indicator interface boundaries (BC-8 indicators).
- Backtest engine architecture (charter Month-12 success criterion "demonstrable alpha vs
  VN-Index on dogfood portfolio").
- Risk engine deterministic-rules pattern (charter principle 10 "Position sizing & risk
  management are deterministic — code-enforced rules, LLM cannot override").
**Wave-1 IMPL candidate sessions**: Theme F finishes (W0-2.1 + W0-3/4/5 — W0-3/4 are
TradingAgents-sourced, W0-5 is Vibe-Trading-sourced); deeper nautilus_trader pattern adoption
(backtest engine arch, risk engine arch) sits as candidate Theme M (deferred — not in Wave 1).

### 4.11 Pixelle-Video — FIT: LOW (same as 4.6/4.7/4.8/4.9)

**What it does**: Video generation pipeline (`docs/en/` + `docs/zh/` + `docs/FAQ.md`).
**Honest assessment**: Same as 4.6.

### 4.12 Scrapling — FIT: HIGH (BC-5/6/7 lightweight adapter; complementary to crawl4ai)

**What it does**: Fast adaptive web scraping (Python; benchmark-focused). Per dispatch brief
inventory: `docs/README_*.md` multi-language READMEs only — root README is primary entry.
**BC mapping**: BC-5 News (lighter alternative to crawl4ai for stable selectors); BC-6 Influence
(YouTube transcript-page scrape); BC-7 Crowd (forum scrape).
**Candidate components/patterns**:
- Auto-adaptive selectors (selector-resilience when site structure shifts).
- Speed-focused fetch primitives (Scrapling benchmarks itself favorably vs BeautifulSoup +
  requests).
- Anti-blocking heuristics (user-agent rotation, retry-after honoring).
**Wave-1 IMPL candidate sessions**: Theme L crawling adapter — Scrapling vs crawl4ai vs
MediaCrawler bake-off in Phase A deep-dive; pick by VN-source profile.

### 4.13 TradingAgents — FIT: HIGH (already partially in pipeline; finish + go deeper)

**What it does**: Multi-agent stock-trading framework (Python; `docs/onboarding/`).
**BC mapping**: BC-8 (multi-perspective adversarial). Already partially in pipeline:
- **W0-3 (TODO)**: Atomic temp-file-replace doctrine.
- **W0-4 (TODO)**: HTML-comment separator pattern.
Both these were from the lost S259 deep-dive (`general-purpose-S259-deepdive-TradingAgents.md`).
**Candidate components/patterns**:
- Debate-style synthesis (vs ai-hedge-fund's isolated-then-aggregate); charter I-S12 says
  "Disagreement Surfaced, Not Resolved" → debate-style transparency may serve I-S12 better.
- Agent-prompt template structure.
- Workflow orchestration (graph-based per typical multi-agent frameworks).
**Wave-1 IMPL candidate sessions**: Theme H — IMPL session selecting + implementing the
debate-vs-isolated multi-perspective primitive shape.
**Risk**: TradingAgents is US/global stock; not VN-specific. VN-overlay (foreign flow, ATO/ATC,
sàn tiering) is stockforge's customization layer; TradingAgents framework adoption must NOT
displace I-S55..I-S65 VN-specific invariants.

### 4.14 TradingAgents-CN — FIT: HIGH (A-share parallels to VN; highest cross-domain transfer)

**What it does**: Chinese-market fork of TradingAgents — A-share + HK-share specifics. Per dispatch
brief: `ANALYST_DATA_CONFIGURATION.md`, `API_KEY_MANAGEMENT_ANALYSIS.md`, `BUILD_GUIDE.md`,
`CONFIG_VALIDATION_FIX_SUMMARY.md`, `ENHANCED_HISTORY_FEATURES_SUMMARY.md` + many more.
**BC mapping**: BC-1 (intraday + ATO/ATC parallels; HK-share lot sizing — VN has 100-share rule
per I-S60), BC-2 (CN-specific financial-statement conventions; VN's parallel is Vietstock public),
BC-4 (CN macro/policy — VN macro = SBV monetary policy + retail-investor regulations), BC-7
(CN retail-investor sentiment patterns — closest analog to VN's 85-90% retail share).
**Candidate components/patterns**:
- Pre-ST (Special Treatment / suspension) filter — VN equivalent is I-S62 trading-suspension.
- A-share market microstructure adaptations — VN parallels in I-S57 (Phiên ATO/ATC),
  I-S60 (lot size 100), I-S61 (ceiling/floor sàn-tiered).
- KOL-style retail-investor sentiment dynamics — China's "韭菜" retail-investor culture has
  documented behavioral parallels to VN's "F0" investor wave (charter principle 5
  "Pattern transfer + local adaptation").
**Wave-1 IMPL candidate sessions**: Theme I (Vietnamese NLP — adjacent to Chinese NLP), and
HIGH priority for Phase A deep-dive (this is the single repo whose market structure is closest
to VN's). The dispatch brief flags this as the highest-fit for "stock business / financial
business" learning.
**Risk**: License compatibility (Chinese repos sometimes have non-OSI licenses); legal-grey
patterns from China may not transfer.

### 4.15 Vibe-Trading — FIT: HIGH (A-share + W0-5 path-safety quad in pipeline)

**What it does**: A-share trading (Python; `docs/onboarding/` + `docs/2026-04-30_session01_pr63_ashare_pre_st_filter_hardening.md`).
**BC mapping**: BC-1 + BC-9 (A-share = VN-share parallels per § 4.14); already in pipeline:
- **W0-5 (TODO)**: Vibe-Trading path-safety quad (per current-execution.md S322 next-action).
**Candidate components/patterns**:
- Pre-ST filter hardening (per the `2026-04-30_session01_pr63...` doc title — directly parallel
  to I-S62 trading-suspension handling).
- Path-safety quad (the 4 path-safety patterns that constitute W0-5; Phase A deep-dive
  re-creates the lost details).
- A-share backtest engine specifics (charter's Month-12 backtest goal).
**Wave-1 IMPL candidate sessions**: Theme F finishes (W0-5); Phase A re-survey may reveal more
candidates in Theme J (PDF + table extraction if Vibe-Trading does FS extraction).

---

## 5. Wave 1 Sub-Track / Theme Decomposition

Themes are organized by **stockforge gap closed**, not by repo. Each theme references the repos
that contribute. Some themes (F) have inflight work; others (G-L) need PLAN sessions before IMPL.

### 5.1 Theme F — Substrate (Wave 0 finish; nautilus + TradingAgents + Vibe-Trading)

**Status**: 60% done. Remaining work:

- **W0-2.1 (TODO)**: Fix the 2 pre-existing production violations surfaced by W0-2 hook
  (`capture_sentiment_snapshot_use_case.py` R2 unseeded RNG + `sqlite_thesis_repository.py` R1
  `datetime.now()` no-tz). Per S315 result (current-execution.md). FOCUSED_IMPL session,
  ~80-120K budget.
- **W0-3 (TODO)**: TradingAgents atomic temp-file-replace doctrine. Patterns from lost
  S259 deep-dive — Phase A re-creates. Likely PLAN-then-FOCUSED_IMPL.
- **W0-4 (TODO)**: TradingAgents HTML-comment separator. Pattern from lost S259. Plan + Impl.
- **W0-5 (TODO)**: Vibe-Trading path-safety quad (4 patterns; per current-execution.md).
  Likely 1 PLAN + 1-2 FOCUSED_IMPL sessions.

**Charter alignment**: Principle 8 (calibration over confidence) + Principle 9 (no LLM math)
+ Principle 11 (harness must self-verify firing).

**Gate**: Phase B follows Phase A; Phase B = Theme F closure.

### 5.2 Theme G — I-S1-1 sub-rule (confidence-field discipline)

**Status**: New theme. Charter currently has I-S1 (no LLM math) + I-S7 (confidence ≠ hit rate)
but no operationalized rule preventing LLM from emitting `confidence: 0.83` as a numeric output
field. Per dispatch brief: "ai-hedge-fund + TradingAgents both surfaced this" — empirical
evidence from the lost S259 work shows ≥17 surface fields where LLM was emitting numeric
confidences without grounding.

**Proposed sub-rule (Phase C charter-amendment candidate)**: I-S1-1 — "LLM never emits a
floating-point confidence value as an output field. Confidence values come from the
calibration database keyed on extractor_version + signal_type (charter principle 8)."

**Wave-1 IMPL candidate**: Phase C — single charter-amendment session (NOT a code session;
constitution write or charter v1.2 amendment per `PROJECT_CHARTER.md` Revision Protocol —
requires "Written rationale with evidence" + "48-hour cool-down before committing change" +
"Explicit version bump v1.1 → v2.0"). Honest call: this MAY not be a charter amendment but a
constitution write (`agent-workspace/constitution/financial-data-protocol.md` extension) —
Phase A decides.

**Coverage**: BC-8 (Analysis & Thesis output schemas), BC-6 (KOL recommendation extraction
schemas — `confidence_extracted: float` already in `KolRecommendationExtracted` event per
architecture.md line 300; the SEMANTICS need pinning: "confidence_extracted = how sure LLM is
about extraction quality, NOT recommendation strength" — already documented in architecture.md
line 300 but needs enforcement).

### 5.3 Theme H — BC-8 Multi-Perspective Primitives (debate vs isolated; ai-hedge-fund + TradingAgents + dexter)

**Status**: New theme. Charter principle 3 (adversarial by design) + I-S10 (bear case
mandatory) + I-S11 (≥2-perspective synthesis; ≥4 for high-confidence) already in place. What's
MISSING: choice between two architectural patterns —
- **Pattern A (isolated-then-aggregate)**: ai-hedge-fund style. Each perspective runs in
  isolation, output flows to deterministic aggregator. Pros: per-perspective context budget
  controllable; better matches I-S12 (disagreement surfaced not resolved). Cons: less rich
  cross-perspective challenge.
- **Pattern B (debate)**: TradingAgents style. Perspectives see each other's drafts and
  rebuttal-cycle. Pros: richer challenge surfaces. Cons: combinatorial context-budget growth;
  AP-1 (same-agent-self-review) risk if perspectives share context.

**Wave-1 IMPL candidate**: Phase D PLAN session (sandwich-architect) selects the pattern;
Phase D+ FOCUSED_IMPL sessions implement. Likely 1-2 IMPL sessions covering the BC-8 use case
`SynthesizeMultiPerspectiveThesisUseCase`.

**Substrate**: r-2026-05-01-claude-cli-substrate.md (CLI subprocess transport) is the LLM
substrate — already shipped at S43b. Theme H uses it without modification.

### 5.4 Theme I — Vietnamese NLP (Vietnamese tokenization, sentiment, claim extraction; TradingAgents-CN parallels + crawl4ai/Scrapling adapters for CafeF/VietstockFinance/NDH)

**Status**: New theme. Charter says "OpenAI text-embedding-3-small (works for Vietnamese)" —
acceptable but not optimized. Vietnamese-specific NLP fragility surfaces (per dispatch brief
recollection of lost S259 + the surviving slash-vs-skill section L-S18-1 cross-locale pattern
extension rule in architecture.md line 437).

**Sub-themes**:
- Vietnamese tokenization (underthesea / pyvi / cli-tool comparison).
- Vietnamese sentiment lexicon (extends crawl4ai content extractor; analog to TradingAgents-CN
  Chinese sentiment patterns).
- Claim extraction from Vietnamese financial news (CafeF / NDH / VietstockFinance — BC-5).
- VN-specific entity recognition (Ticker `VHM` vs `vinhomes` vs `Vinhomes` resolution).

**Wave-1 IMPL candidate**: 1 PLAN + 1-2 FOCUSED_IMPL covering BC-5 News Stream Vietnamese
extractor pipeline. Dependent on Theme L (crawling) for upstream data flow.

### 5.5 Theme J — PDF + Table Extraction (BC-2 financial statements)

**Status**: New theme. Charter Phase-3 success criterion "30+ KOL channels tracked, calibration
database has >100 recommendations with outcomes pending"; Phase-2 criterion includes "30+ KOL
channels" but NO explicit financial-statement coverage criterion. However, BC-2 Fundamental
requires `FinancialStatement` ingestion (architecture.md line 49). Vietnam-specific: most
listed companies publish financial statements as PDF on their company website + Vietstock
public. Extracting tables from PDF is a known hard problem.

**Repos contributing**: Speculative — Phase A may surface relevant patterns in
TradingAgents-CN (CN-specific A-share FS extraction) or in any of the video repos (some
include PDF→text pipelines). Likely NEW IMPL work without major upstream port — but the
adapter shape can be informed.

**Wave-1 IMPL candidate**: 1 PLAN session — design a `PdfTableExtractorPort` (application
layer) with at-least-2 candidate adapters: a pure-Python (pdfplumber + camelot) and an
LLM-assisted (Claude vision). FOCUSED_IMPL follows in Phase 1+ as BC-2 work begins.

### 5.6 Theme K — UX/Output (FinceptTerminal Bloomberg-style; MoneyPrinter*/NarratoAI/Pixelle honest deferral)

**Status**: New theme. Phase 1-2 dashboard target = Streamlit (charter line 162). FinceptTerminal
informs the data-density vision. Video repos (MoneyPrinter*/NarratoAI/Pixelle) honestly deferred
per § 4.6-4.9 + 4.11 — Phase A documents them, then we move on.

**Wave-1 IMPL candidate**: NONE in Wave 1 (Phase 1 too early for dashboard polish; Streamlit
defaults are sufficient for the M3 success criterion "Can run /thesis-validate on a stock
end-to-end in <5 minutes"). DEFERRED to Phase 2 dashboard work.

### 5.7 Theme L — Crawling Adapter Shape (crawl4ai vs Scrapling vs MediaCrawler)

**Status**: New theme. Charter Phase-1 success criterion: "Tier 1 + 2 data pipeline operational
for VN30" — Tier 2 = "Official Narrative (semi-structured): mainstream financial news, broker
reports". Means crawling adapter for CafeF / NDH / VietstockFinance is on Phase-1 critical path.

**Sub-themes**:
- Per-VN-source profile: static-HTML (likely CafeF article pages) vs SPA/JS-heavy (likely
  YouTube transcripts / Facebook fanpages) — different adapters per profile.
- crawl4ai is LLM-friendly markdown converter (best for static + LLM downstream).
- Scrapling is speed-focused + adaptive (best for high-volume + selector-resilience).
- MediaCrawler is browser-state-preserving + CDP-capable (best for JS-heavy + login-walled).

**Wave-1 IMPL candidate**: 1 PLAN (adapter shape + per-source assignment) + 1-2 FOCUSED_IMPL
(per-source implementation). HIGH priority for Phase 1 (BC-5 News Stream).

---

## 6. Phased Session Sequence (budget-aware)

Phase ordering: Phase A (recovery + inventory) → Phase B (Wave 0 finish; substrate) → Phase C
(charter amendment for Theme G — if confirmed needed) → Phase D-K (per-theme IMPL). Each
session has a budget envelope per `constitution/session-budgets.md`.

**Session naming convention**: `S<NNN>-<phase>-<theme>-<scope>` (e.g., `S323-A-recovery-15-deep-dives`).
Numbering continues from S322 baseline.

### 6.1 Phase A — Recovery + Inventory (S323-S327; ~4-5 sessions)

| Session | Type | Budget | Goal | Output |
|---|---|---|---|---|
| S323 | INGEST (dispatch shape; main session orchestrates) | 50-80K main + 15× 30K parallel = ~510-580K wall-time-parallel | 15 parallel general-purpose subagents (one per repo); each writes `observations/master-planner-A-<N>-deepdive-<repo>.md` | 15 deep-dive observation files |
| S324 | PLAN (sandwich-architect or main) | 80-100K | Synthesize the 15 deep-dives into `agent-workspace/research/INTEGRATION_PROPOSAL_2026-05-15.md` + `..._SUPPLEMENT_2026-05-15.md` | 2 integration proposal files |
| S325 | PLAN | 50-80K | Author `agent-workspace/memory/decisions/061-wave-1-integration-ratification.md` ADR at IMPL tier; queue Q-INT-2026-05 mega-bundle for user ratification | 1 ADR + 1 Q-INT bundle file in `human-workspace/q-and-a/pending/` |
| S326 (GATE) | Human ratification | (out-of-band; user replies to Q-INT bundle) | User picks ratification options per § 8 | Q-INT bundle moves `pending/` → `answered/`; ADR D-061 moves PROPOSED → ACCEPTED |
| S327 (optional) | RECOVERY | 80-150K | If Q-INT ratification reveals scope changes, revise the master plan + Theme F-L ordering | Updated master plan + handoff |

**Budget total Phase A**: ~250-400K main-session tokens; ~510-580K subagent tokens (parallel).
**Wall time**: ~2-3 turns (with `run_in_background=true` dispatches).
**Pre-flight check (verify_phase_before_next_phase)**: BEFORE S323, main session verifies (a)
`destructive-command-guard.sh` ACTIVE per current-execution.md, (b) all 15 repos at
`C:/htdocs/research/` are present + git-clean, (c) the dispatch brief language file
`RECOVERED-20260513_01-user-prompt.txt` still exists.

### 6.2 Phase B — Wave 0 Substrate Finish (S328-S332; ~4-5 sessions)

| Session | Type | Budget | Goal |
|---|---|---|---|
| S328 | PLAN (sandwich-architect) | 50-80K | Sub-plan for W0-2.1 (the 2 pre-existing production R1/R2 violations); plan moves into `session-plans/pending/` |
| S329 | FOCUSED_IMPL | 100-150K | Execute W0-2.1: fix the 2 violations; tests; ADR if scope-changes anything |
| S330 | VERIFY (sandwich-verifier) | 30-60K | Adversarial review of S329 |
| S331 | PLAN (sandwich-architect) | 50-80K | Bundle W0-3 + W0-4 + W0-5 plans (TradingAgents atomic temp-file-replace + HTML-comment separator + Vibe-Trading path-safety quad). Phase A's TradingAgents + Vibe-Trading deep-dives provide the implementation details. |
| S332 | FOCUSED_IMPL / VERIFY | 100-200K | Execute (or split into 2 FOCUSED_IMPL + 1 VERIFY if scope warrants per R-2 splits-if->10-tasks) |

**Gate**: Phase B requires Phase A's nautilus + TradingAgents + Vibe-Trading deep-dives to be
complete (those are inputs to S328/S331 planning).

### 6.3 Phase C — Theme G Charter/Constitution Amendment (S333-S334 if confirmed needed; ~1-2 sessions)

| Session | Type | Budget | Goal |
|---|---|---|---|
| S333 | PLAN | 50-80K | Decide CHARTER amendment (v1.1 → v1.2, requires "48-hour cool-down" per Revision Protocol) vs CONSTITUTION-write (new rule in `financial-data-protocol.md` — agent-write forbidden, requires user-explicit-approve gate per CLAUDE.md hard rule). If charter: produce charter-revision rationale doc + queue for human approval. If constitution: produce constitution-write proposal in `proposals/`. |
| S334 (GATE) | Human ratification | out-of-band | User picks |

**Honest call**: Theme G may emerge from Phase A as unnecessary (if the deep-dives reveal the
17+ surface fields don't actually exist OR are already covered by I-S1 + I-S7). Phase C is
**conditional** on Phase A's findings.

### 6.4 Phases D-K — Per-Theme IMPL (S335+; ~8-12 sessions)

Ordering picked by stockforge-need-driven priority, NOT alphabetical:

1. **Phase D = Theme L (Crawling adapter shape)** — Phase-1 critical path (BC-5 News Stream
   needed for "Tier 1 + 2 data pipeline operational for VN30" M3 success criterion). 1 PLAN
   + 1-2 IMPL + 1 VERIFY.
2. **Phase E = Theme I (Vietnamese NLP)** — depends on Phase D's crawling output. 1 PLAN
   + 1-2 IMPL + 1 VERIFY.
3. **Phase F-prime = Theme H (BC-8 multi-perspective primitives)** — depends on Theme G (or
   skips it if Phase C ratifies NO charter amendment needed). 1 PLAN + 1-2 IMPL + 1 VERIFY.
4. **Phase G-prime = Theme J (PDF + table extraction)** — Phase-2 work, can defer. 1 PLAN;
   IMPL deferred to Phase 2 entry.
5. **Phase H-prime = Theme K (UX/output)** — Phase-2 work, deferred. PLAN only in Wave 1.

**Budget envelope per phase**: 200-500K total per phase (PLAN 50-80K + 1-2 IMPL 100-150K each
+ VERIFY 30-60K).

### 6.5 Total session count + budget envelope

- Phase A: 4-5 sessions, ~510-580K subagent + 250-400K main
- Phase B: 4-5 sessions, ~400-650K
- Phase C: 1-2 sessions, ~80-160K
- Phase D-K: 8-12 sessions, ~1600-3000K (spread; not in any single session per R-1 no-mix rule)

**Total Wave 1+ envelope**: ~16-22 sessions, ~3000-4500K tokens across all sessions.

---

## 7. Risks & Gotchas

### 7.1 R-Risk-L1 — License compatibility (per-repo)

Pattern-adoption (e.g., "we learned the FSM concept from nautilus_trader's docs/concepts/")
is generally not license-encumbered. Code-copy (verbatim function bodies) needs per-repo
license check. **Mitigation**: Phase A deep-dive subagent's brief MUST require: capture LICENSE
file content + license-class (Apache / MIT / GPL / proprietary / unclear) per repo as a deep-dive
section. INTEGRATION_PROPOSAL_2026-05-15.md cross-references license-class to per-component
adoption decisions (pattern vs code-copy-with-attribution).

### 7.2 R-Risk-VN — Vietnamese-vs-A-share market differences (transfer ≠ wholesale port)

TradingAgents-CN insights apply to VN ONLY where market structure parallels hold (retail-investor
share, lot-size, ATO/ATC, ceiling-floor sàn-tiered). Where it differs (state-bank ownership of
state-listed companies in VN; "đội lái" pump-operator culture; foreign-room saturation per I-S56)
the CN patterns DON'T transfer. **Mitigation**: every TradingAgents-CN pattern adoption is gated
by "applies to VN per I-S55..I-S65 invariants" check.

### 7.3 R-Risk-M — MoneyPrinter*/NarratoAI/Pixelle research-aid framing (I-S35)

If ANY video-output adoption proceeds (Phase 4+; currently DEFERRED per § 4 and § 5.6), the
generated artifacts MUST preserve the I-S35 disclaimer ("research aid, not financial advice")
on every video. **Mitigation**: charter-amendment Q-INT item flagged in § 8 (one of the ≤4
ratification questions covers this).

### 7.4 R-Risk-Lost — D-058 + Q-INT mega-bundle audit-trail unrecoverable

Per post-mortem §1b: D-058 audit trail is gone. We re-author as D-061 + new Q-INT-2026-05. Risk:
some ratification context from D-058 may not be reconstructable. **Mitigation**: Phase A includes
re-querying user on the substantive D-058 question (`Q-INT-10=A` blanket-A on Wave 0 substrate
authorization) — but that question is ALREADY OPERATIVE (W0-1/1b/2 shipped under it; D-059 ADR
references "depends_on: D-058"). The re-authoring records the residual context-loss as a known-gap.

### 7.5 R-Risk-AP-1 — Parallel subagent dispatches in Phase A

15 parallel subagents per S323 — risk of AP-1 (same-agent-self-review) if any subagent re-reads
its OWN output later. **Mitigation**: each subagent gets a UNIQUE repo to deep-dive (no cross-repo
overlap in brief); the SYNTHESIZER session (S324) is a fresh-context session reading the 15
subagent outputs as adversarial inputs (not self-review).

### 7.6 R-Risk-budget — Phase A subagent token spend

Phase A's 510-580K subagent token spend is the largest single phase budget. **Mitigation**: each
subagent has a 30-40K hard cap; dispatch instructions enforce "report findings, do not load
entire repo source — focus on `docs/onboarding/` + key file paths". Verify before dispatch:
estimate budget envelope using session-budgets.md formula.

### 7.7 R-Risk-mass-deletion — R1/R2/R3 still required across Phase A-K

The R1/R2/R3 prevention rules SHIPPED 2026-05-14 (per current-execution.md). Phase A-K MUST
verify these are ACTIVE before each subagent dispatch. **Mitigation**: per-session pre-flight
checks: (a) `destructive-command-guard.sh` PreToolUse wired in `.claude/settings.json`,
(b) `project-integrity-watchdog.sh` Stop hook wired, (c) `daily-backup.sh` Stop hook wired.

### 7.8 R-Risk-AP-23 — Refinement-of-rule lesson-about-lesson red flag

Per CLAUDE.md § Hard Rules: "Refinement-of-rule (lesson-about-lesson) is AP-23 RED FLAG: 2nd
instance mandates promote-or-retire (not inline accumulation)." Theme G's I-S1-1 sub-rule is
itself a refinement of I-S1. **Mitigation**: Phase C explicitly evaluates whether I-S1-1 is a
GENUINE new rule or a redundant refinement of I-S1 — if redundant, retire it; if genuine,
promote it as a separate invariant (not nested under I-S1).

---

## 8. Ratification Gate — AskUserQuestion (≤4 items per call)

These ≤4 questions MUST be asked of the user BEFORE Phase A executes (S323+). Per CLAUDE.md
+ `human-workspace/q-and-a/` lifecycle. Bundled as one Q-INT-2026-05 mega-bundle per the user's
"qa_bundle_all_pending" preference.

**Q-INT-2026-05-1 — Scope: which repos enter Phase A deep-dive?**

> The 15 repos at `C:/htdocs/research/` map to per-repo FIT levels in this master plan § 4.
> Which subset enters Phase A deep-dive at S323?
>
> **(A)** ALL 15 (most thorough; ~510-580K subagent tokens; preserves the user's "đều có thể
> học hỏi" preference — even LOW-fit repos get a one-paragraph documentation entry).
> **(B)** 7 HIGH-fit + TradingAgents-CN = 8 repos (skip MoneyPrinter*/NarratoAI/Pixelle entirely;
> save ~210K tokens). HIGH-fit list: ai-hedge-fund, crawl4ai, MediaCrawler, nautilus_trader,
> Scrapling, TradingAgents, TradingAgents-CN, Vibe-Trading + dexter (informational).
> **(C)** Tier-by-tier — first batch = 5 (TradingAgents, TradingAgents-CN, ai-hedge-fund,
> crawl4ai, Scrapling); second batch = others as needed.
> **(D)** Different scope — specify.

**Q-INT-2026-05-2 — Theme ordering: should we follow the § 6.4 critical-path ordering
(Theme L → I → H → J → K) or a different ordering?**

> Phase D-K orders themes by stockforge-Phase-1-critical-path priority:
>
> **(A)** Follow the § 6.4 ordering (Theme L crawling first because BC-5 News Stream is on
> Phase-1 M3 success criterion; then I Vietnamese NLP; then H multi-perspective; then J PDF;
> then K UX).
> **(B)** Front-load multi-perspective (Theme H first) — argument: charter principle 3
> "adversarial by design" is the differentiating thesis-quality lever; everything else
> compounds on its quality.
> **(C)** Front-load substrate (Theme F finish W0-2.1/3/4/5 first — already in Phase B per
> § 6.2; this option just confirms Phase B order).
> **(D)** Different ordering — specify.

**Q-INT-2026-05-3 — Theme G charter/constitution amendment: which path?**

> Per § 5.2 and § 7.8 — Theme G (I-S1-1 confidence-field discipline) is a candidate charter
> amendment OR constitution write. Which path?
>
> **(A)** Charter amendment v1.1 → v1.2 (requires 48-hour cool-down per Revision Protocol;
> requires written rationale with linked sessions). Most binding; longest cycle.
> **(B)** Constitution write in `agent-workspace/constitution/financial-data-protocol.md`
> (agent-forbidden direct write; requires explicit human-approve gate). Faster than (A).
> **(C)** Defer to Phase A findings — Phase A determines if I-S1-1 is GENUINE-new or
> REDUNDANT (AP-23 red-flag check), then proposes accordingly.
> **(D)** Skip — I-S1 + I-S7 are sufficient; no I-S1-1 needed.

**Q-INT-2026-05-4 — Low-fit video repos (MoneyPrinter*/NarratoAI/Pixelle): treat how?**

> Per § 4.6-4.9 + § 4.11 (5 video repos rated LOW-fit), and per § 7.3 I-S35 framing risk:
>
> **(A)** Thin Phase A deep-dive per repo (one paragraph each, documented as "out-of-scope
> Phase 1-2, possibly Phase 4+"); no Wave-1 IMPL sessions. **(Currently the recommended path
> in § 4.)**
> **(B)** Skip entirely from Phase A — don't spend tokens on deep-dives for repos with no
> Wave-1 IMPL path; document the skip rationale in INTEGRATION_PROPOSAL_2026-05-15.md.
> **(C)** Phase A deep-dive + Phase 4+ research note (a `research/` markdown entry per repo
> exploring "thesis-summary-video for trusted-peer circle" with mandatory I-S35 framing in
> any future video output).
> **(D)** Different treatment — specify.

**Default if user blanket-approves**: A / A / C / A respectively (per user's "qa_bundle_all_pending"
preference + the prior D-058 "blanket-A" precedent). All four answers can be combined in one
4-item AskUserQuestion call.

---

## 9. Provenance (cite-every-claim per I-S2 applied to this plan itself)

Every substantive claim in this master plan is sourced from:

| Section | Claim type | Source |
|---|---|---|
| § 1 | User intent | `agent-workspace/research/RECOVERED-20260513_01-user-prompt.txt` |
| § 1.3 | "no production code" rule | `CLAUDE.md` § Session Types (lines 137-148) |
| § 2 | 15-repo inventory | dispatch-brief inventory table + `C:/htdocs/research/` glob |
| § 3 | Lost-files list | `agent-workspace/post-mortems/2026-05-14-mass-deletion-recovery.md` § 1b |
| § 3 | D-058 missing from filesystem | `agent-workspace/memory/decisions/` glob (read at S322 dispatch turn) — 057/058 absent |
| § 4 | BC mapping | `agent-workspace/constitution/architecture.md` § 9 BCs (lines 36-100) |
| § 4 | Charter principles | `PROJECT_CHARTER.md` (lines 55-77, principles 1-11) |
| § 4 | I-S* invariants | `agent-workspace/constitution/invariants-stockforge.md` |
| § 4.10 | W0-1/1b/2 status | `agent-workspace/memory/current-execution.md` (S311-S316 results) |
| § 4.10 | D-059 nautilus DST cite | `agent-workspace/memory/decisions/059-python-determinism-contract.md` source_evidence section |
| § 5.1 | W0-2.1 pre-existing violations | `current-execution.md` S315 result |
| § 5.3 | Multi-perspective patterns | `architecture.md` Domain Model Rules + I-S10/11/12 |
| § 5.3 | CLI substrate | `agent-workspace/research/r-2026-05-01-claude-cli-substrate.md` |
| § 6 | Session-type budgets | `agent-workspace/constitution/session-budgets.md` |
| § 6 | R-1 no-mix rule + R-2 split-if->10 | `session-budgets.md` § Hard Rules |
| § 7 | R1/R2/R3 prevention | post-mortem § 5 + current-execution.md S310 BEHAVIORAL HOLD context |
| § 7.8 | AP-23 red flag | `CLAUDE.md` § Hard Rules (Ritual demotion clause) |
| § 8 | Q-INT bundling preference | user memory `qa_bundle_all_pending.md` |

**Self-attestation**: this plan was authored entirely from cited sources. No claim references
LLM-internal knowledge of any repo's content beyond what is in the dispatch brief's inventory
table. All per-repo FIT claims in § 4 are marked **[pending Phase A empirical re-survey]** —
Phase A's deep-dive subagents replace these hypotheses with file-cited evidence.

---

## 10. Handoff (to next session = ratification gate)

**Status of this master plan**: `pending-ratification` (per frontmatter).

**Next action expected from main session**:

1. Read this master plan.
2. Read the 4 Q-INT-2026-05 questions in § 8.
3. Dispatch ONE `AskUserQuestion` call with all 4 items (4-per-call limit; user's
   mega-bundle preference satisfied).
4. On user reply: move Q-INT bundle `pending/` → `answered/` (via auto-mv if frontmatter
   `status:` matches per `agent-workspace/CLAUDE.md` Contract HH-E.2; otherwise manual via
   `qa-pending-auto-mover.sh`).
5. Update this master plan's frontmatter `status:` from `pending-ratification` → `ratified`
   (or `partially-ratified` if user picks differ from defaults).
6. Author D-061 (per § 6.1 S325) capturing the ratification outcome at IMPL or SCOPE tier
   (per decision-discipline rules — SCOPE if Q-INT-1 or Q-INT-2 picks differ from defaults).
7. Dispatch Phase A S323 with 15 (or 8, or 5) parallel `general-purpose` subagents per
   ratified scope, `run_in_background=true`.

**Coordination rule for ratification turn**: main session avoids `agent-workspace/research/`
(Phase A's write target) + `agent-workspace/memory/decisions/061-*` (D-061 author target) +
`session-plans/pending/master-plan-2026-05-15-*` (this plan's stable location).

**Plan move**: this plan stays at `agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md`
through Phase A-K execution; on Wave 1 completion, archive to `agent-workspace/master-plans/completed/`
(directory to be created on Wave 1 close, NOT in this PLAN session).

---

## 11. Compliance Attestation (this PLAN session)

- ✅ no production code written
- ✅ no commits
- ✅ no charter edits
- ✅ no constitution writes
- ✅ no human-workspace writes (Q-INT bundle is queued to be written by main session post-ratification,
  NOT by this master-planner subagent)
- ✅ R-1 no-mix PLAN+IMPL honored (PLAN-only session)
- ✅ R-2 split-if->10-tasks honored (16-22 sessions across Phase A-K, no single session > 10 tasks)
- ✅ every claim source-cited per I-S2-applied-to-this-plan (§ 9)
- ✅ I-S35 research-aid framing preserved (Theme K + § 7.3 + Q-INT-2026-05-4)
- ✅ I-S10 / I-S11 multi-perspective preserved (Theme H + § 5.3)
- ✅ all 4 ratification AskUserQuestion items have lettered options per user's
  `qa_bundle_all_pending.md` preference (§ 8)
- ✅ Wave 0 substrate progress (W0-1/1b/2 DONE; W0-2.1/3/4/5 TODO) acknowledged per
  current-execution.md
- ✅ Mass-deletion losses (D-058 + INTEGRATION_PROPOSAL_*.md + 7 lost S259 deep-dives)
  acknowledged + reconstruction path defined (Phase A § 3)

End of master plan 2026-05-15-wave-1-research-integration.md.
