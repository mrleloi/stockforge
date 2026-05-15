---
proposal_id: INTEGRATION_PROPOSAL_2026-05-15
session: S324-A-synthesis
author: master-planner subagent (S324 dispatch)
date: 2026-05-15
status: pending-ratification (Q-INT-2026-05 + new D-061)
supersedes: agent-workspace/research/INTEGRATION_PROPOSAL_2026-05-13.md (LOST 2026-05-14 mass-deletion per post-mortems/2026-05-14-mass-deletion-recovery.md §1b)
inputs:
  master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md
  deep_dives: agent-workspace/memory/observations/master-planner-A-{01..15}-deepdive-*.md (15 files, ~2100 LOC total)
ratification_defaults_recorded:
  Q-INT-2026-05-1: A (all 15 deep-dived; preserved)
  Q-INT-2026-05-2: A (Theme L→I→H→J→K critical-path ordering)
  Q-INT-2026-05-3: C (Defer Theme G charter/constitution path to Phase A findings)
  Q-INT-2026-05-4: A (thin Phase A deep-dive for video repos; no Wave-1 IMPL)
compliance:
  - I-S1 (NO LLM math) — every numeric value sourced from deep-dive cite chain
  - I-S2 (every claim sourced) — every architectural recommendation cites deep-dive section + repo file:line
  - I-S35 (research aid framing) — no "buy/sell/recommendation" language; thesis-exploration framing preserved
  - I-S10/I-S11 (adversarial + ≥2 perspective) — Theme H synthesis (see SUPPLEMENT) preserves multi-perspective primitives
non_goals:
  - Wholesale framework port of any single repo (pattern/component lift only)
  - LOC-port of LGPL/AGPL/proprietary/non-OSI-licensed code (re-implement instead)
  - Adoption of automated anti-bot tooling (Cloudflare-solver, fingerprint-spoof JS, hardcoded signing keys) — all classified I-S34 ToS-conflict; HARD REJECT
---

# INTEGRATION_PROPOSAL_2026-05-15 — Per-Repo Synthesis (15 Repos)

> Replaces the LOST `INTEGRATION_PROPOSAL_2026-05-13.md` (mass-deletion). Cross-repo theme synthesis is in `INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md`.

---

## 0. Summary Table — Final Disposition (15 repos)

| # | Repo | License | Hypothesis FIT (master-plan §4) | Empirical FIT (deep-dive §5) | Δ vs Hypothesis | Wave-1 IMPL Allocation |
|---|---|---|---|---|---|---|
| 1 | ai-hedge-fund | MIT (root file missing) | HIGH | HIGH (w/ caveats) | confirm | IMPL-1 (Theme H pattern primitive — isolated-then-aggregate) |
| 2 | crawl4ai | Apache-2.0 + Attribution clause | HIGH | HIGH (pattern); MEDIUM-LOW (wholesale) | confirm | IMPL-1 (Theme L crawling adapter + Markdown converter) |
| 3 | dexter | MIT (README-declared; no LICENSE file at root) | MEDIUM | MEDIUM | confirm | PLAN-only (Theme H compaction pattern reference; TS stack mismatch) |
| 4 | FinceptTerminal | AGPL-3.0 + Commercial-license-required (USD 10,200/yr) | MEDIUM | LOW | **DEMOTE** | NONE (Theme K design-study only; deferred to Phase 2+) |
| 5 | MediaCrawler | Non-Commercial Learning License 1.1 (NOT OSI) | HIGH | MEDIUM-LOW | **DEMOTE** | NONE (license blocker; pattern-reference only for CDP-consented mode) |
| 6 | MoneyPrinterPlus | GPL-3.0 | LOW | LOW | confirm | NONE (Phase 4+ deferred) |
| 7 | MoneyPrinterTurbo | MIT | LOW | LOW | confirm | NONE (Phase 4+ deferred) |
| 8 | MoneyPrinterV2 | AGPL-3.0 | LOW | LOW | confirm | NONE (Phase 4+ deferred) |
| 9 | NarratoAI | Modified MIT — Non-Commercial Only | LOW | LOW | confirm | NONE (Phase 4+ deferred) |
| 10 | nautilus_trader | LGPL-3.0 | HIGH | HIGH | confirm | IMPL-1 (W0-2.1 fix); IMPL-2-deferred (Theme M: risk-engine + backtest blueprint + MessageBus) |
| 11 | Pixelle-Video | Apache-2.0 | LOW | LOW | confirm | NONE (Phase 4+ deferred) |
| 12 | Scrapling | BSD-3-Clause | HIGH | HIGH (parser+adaptive); MEDIUM (fetcher pattern); REJECT (Cloudflare-solver, patchright) | partial-DEMOTE | IMPL-1 (Theme L adaptive selector + ProxyRotator + RobotsTxtManager + find_similar) |
| 13 | TradingAgents | Apache-2.0 | HIGH | HIGH | confirm | IMPL-1 (W0-3 atomic write + W0-4 HTML separator); IMPL-2 (Theme H debate-style primitives + structured-output schema) |
| 14 | TradingAgents-CN | Apache-2.0 (core) + Proprietary (`app/` + `frontend/`) | HIGH-HIGHEST | HIGH (pattern); MEDIUM-LOW (direct port) | confirm | IMPL-2 (Theme H prompt template adaptation + Theme I sentiment lexicon pattern + circuit-breaker pattern); IMPL-1 referenced from VN microstructure prompt template |
| 15 | Vibe-Trading | MIT | HIGH | HIGH | confirm | IMPL-1 (W0-5 path-safety quad); IMPL-2-candidate (Theme N net-new: BaseEngine + validation pipeline) |

**HARD-FILTER outcomes (license-driven):**
- AGPL-3.0 / Commercial-required (FinceptTerminal, MoneyPrinterV2): **pattern-only, ZERO LITERAL LOC**.
- GPL-3.0 (MoneyPrinterPlus): pattern-only; copyleft prevents code-port.
- Non-Commercial Learning License (MediaCrawler): pattern-only; commercial-use prohibited.
- Modified MIT Non-Commercial (NarratoAI): pattern-only; commercial-use prohibited.
- LGPL-3.0 (nautilus_trader): re-implementation from architectural shape preferred over LOC-port; pip-install dependency safe.
- BSD-3 / MIT / Apache-2.0 (ai-hedge-fund, crawl4ai, dexter, MoneyPrinterTurbo, Pixelle-Video, Scrapling, TradingAgents, TradingAgents-CN core, Vibe-Trading): LOC-port permitted with attribution.

**Material demotions (Wave-1 budget impact):**
- FinceptTerminal MEDIUM → LOW: removes any Theme K IMPL session in Wave 1.
- MediaCrawler HIGH → MEDIUM-LOW: removes MediaCrawler from Theme L IMPL slot (license + platform-mismatch).
- Scrapling: partial DEMOTE on Cloudflare-solver + patchright sub-modules (HARD REJECT); core parser+adaptive selector remains HIGH.

**Material promotion (net-new vs master plan):**
- Vibe-Trading `agent/backtest/validation.py` (Monte Carlo + Bootstrap Sharpe CI + Walk-Forward) → candidate Theme N (deferred past Wave 1) for Charter Month-12 backtest goal; flagged in SUPPLEMENT § "Refined Wave-1 IMPL Allocation".

---

## 1. ai-hedge-fund (A-01)

- **Repo**: `ai-hedge-fund` (virattt)
- **Path**: `C:/htdocs/research/ai-hedge-fund/`
- **Primary language**: Python 3.11 (LangGraph + LangChain + Pydantic + FastAPI + ReactFlow web app)
- **License class**: **MIT (declared in `README.md:155-157`); root `LICENSE` file MISSING** — only `app/frontend/LICENSE` present (per A-01 § 6). License is ambiguous in practice; **patterns safe, code-port HIGH RISK pending upstream verification**.

### 1.1 Hypothesis-vs-Empirical Fit Verdict

**CONFIRM HIGH.** A-01 § 5 found:
- 19 personality-based perspectives (Buffett/Graham/Lynch/Taleb/Munger/Ackman/Wood/Burry/Pabrai/Druckenmiller/Damodaran/Fisher/Jhunjhunwala + 4 functional) — confirms the master-plan §4.1 hypothesis that ai-hedge-fund is a candidate BC-8 multi-perspective primitive set.
- Empirically validated as **isolated-then-aggregate** (NOT debate-style): parallel fan-out at `src/main.py:112-115` with NO inter-agent messaging; Portfolio Manager sees only `{ticker: {agent_id: {sig, conf}}}` table (`portfolio_manager.py:160-175`). Per A-01 § 5 third bullet: "Recommendation: adopt this pattern as Wave-1 default for BC-8; defer debate-style until evidence shows ensemble underperforms."
- Empirically validated as **deterministic-then-LLM split at agent level**: Warren Buffett agent (`warren_buffett.py`) is ~826 LOC, ~750 deterministic Python math + ~80 LLM prompt+parse — i.e. 90/10 split (A-01 § 5 second bullet). Validates I-S1 at scale.

### 1.2 BC Mapping

| Component | BC |
|---|---|
| Per-perspective signal contract `{signal, confidence, reasoning}` (`src/agents/warren_buffett.py:13-16`) | BC-8 |
| Plugin registry (`src/utils/analysts.py:25-178`) | BC-8 |
| Deterministic-then-LLM split | BC-8 + reinforces I-S1 charter |
| Compact-facts prompt template (`warren_buffett.py:769-809`) | BC-8 |
| Volatility-adjusted position-limit step function (`risk_manager.py:270-298`) | BC-9 |
| Correlation multiplier (`risk_manager.py:301-317`) | BC-9 |
| Pre-validated allowed-actions + pure-hold prefill (`portfolio_manager.py:96-157, 192-205`) | BC-9 |
| Multi-stage DCF with conservative haircuts (`warren_buffett.py:380-624`) | BC-2 (compute) → BC-8 (interpret) |
| Sentiment weighting pattern (insider 0.3 + news 0.7 — `src/agents/sentiment.py:50-74`) | BC-6 + BC-7 (VN has no insider-trade feed; reweight for KOL + Crowd) |
| 12-file onboarding-docs template (`docs/onboarding/*`) | harness substrate (spec/doc layer) |
| Nassim Taleb antifragility / tail-risk perspective (`src/agents/nassim_taleb.py:32-100+`) | BC-8 (adversarial bear-case slot) |

### 1.3 Patterns to ADOPT (license-safe regardless of LICENSE-file ambiguity)

1. **Per-perspective signal contract** (A-01 § 3 C1) — `{signal: bullish|bearish|neutral, confidence: int 0-100, reasoning: str}` re-implemented with Python `dataclass` (StockForge architecture rule: "Domain layer has ZERO framework dependency… use dataclasses", per A-01 § 7 R2).
2. **Plugin-style perspective registry** (A-01 § 3 C2) — single-source-of-truth dict pattern; one file + one dict entry to add a perspective.
3. **Deterministic-then-LLM split discipline** (A-01 § 3 C3) — codify as `I-S1-1` candidate sub-rule + dedicated skill; aligns with charter "NO LLM math".
4. **Confidence rubric pattern** (A-01 § 3 C9) — Buffett-style 90-100/70-89/50-69/30-49/10-29 evidence-quality brackets; feeds Theme G I-S1-1 calibration sub-rule discussion.
5. **Onboarding-docs scaffold** (A-01 § 3 C12) — 12-file kit (HLD/LLD/ADR/sequence/data-model/glossary/security/quality/infra) referenced as concept-only; potential spec-layer reuse.

### 1.4 Components to PORT (LOC-level — DEFER until license verified)

Per A-01 § 6: "Cannot safely copy code lines verbatim. Recommendation: re-implement from scratch using the pattern documented here; do not copy file contents."

- C4 compact-facts prompt template (`warren_buffett.py:769-809`) — re-implement (VN context + role-prompt-pack).
- C5 volatility-adjusted position-limit step function (`risk_manager.py:270-298`) — re-implement (verify tiers fit VN vol regime).
- C6 correlation multiplier (`risk_manager.py:301-317`) — re-implement.
- C7 pre-validated allowed-actions + pure-hold prefill (`portfolio_manager.py:96-157, 192-205`) — re-implement (token-saving + safety).
- C8 multi-stage DCF with conservative haircuts (`warren_buffett.py:380-624`) — re-implement with VN-CPI / risk-free rate.
- C13 Taleb antifragility / kurtosis / VaR / convexity scoring (`src/agents/nassim_taleb.py:32-100+`) — re-implement.

**Action item before any code-port (A-01 § 6)**: file a Q-bundle item to confirm license source-of-truth (root MIT vs frontend-only MIT). Defer to spec phase, not Wave-1 IMPL.

### 1.5 Anti-Patterns to AVOID (charter conflicts)

- **R2 (A-01 § 7) — Pydantic in domain layer.** ai-hedge-fund mixes Pydantic into agent function signatures freely. Stockforge architecture rule forbids it; translate Pydantic → `dataclass` and isolate Pydantic to BC adapter layer.
- **R3 (A-01 § 7) — LLM-self-reported confidence treated as ground truth.** Buffett agent emits `confidence: 75` ungrounded. Stockforge MUST wire confidence values to historical hit-rate feedback (charter "Calibration over confidence") OR explicitly mark confidence as un-calibrated.
- **R4 — Missing source / as-of fields.** No signal carries `source_url` or `as_of_date`. Direct port would violate I-S2 "every claim has source + as-of date". Schema-extension required up-front.
- **R5 — US-market-only data assumptions.** Insider trades, SEC-style fundamentals, USD market cap. VN-domain port requires different primitives (vnstock / SSI / KOL Telegram-Facebook / Vietnamese-language NLP).
- **R9 — Reasoning-string limit `<120 chars`** (`warren_buffett.py:795`). For Stockforge thesis-log we want longer narrative; do not adopt as a global pattern.

### 1.6 Risks Flagged by Deep-Dive (A-01 § 7)

- **R1** — LangChain/LangGraph wholesale dependency = unstable 0.2.x API (per `04-ADR-LOG.md:11-17`). Skip.
- **R6** — In-memory cache (`ADR-007`): no TTL, lost on restart. Stockforge uses Redis/Postgres; do NOT port the cache module.
- **R7** — Plaintext API keys in SQLite (`app/backend/database/models.py:107`). Do NOT replicate.
- **R8** — License ambiguity; pattern-only safe.
- **R10** — `v2/` directory parallel to `src/` (mid-refactor; per `04-ADR-LOG.md:81-91`). Prefer stable `src/` over spike `v2/`.

---

## 2. crawl4ai (A-02)

- **Repo**: `crawl4ai` (Unclecode), v0.8.6
- **Path**: `C:/htdocs/research/crawl4ai/`
- **Primary language**: Python ≥3.10
- **License class**: **Apache-2.0 + custom Attribution Requirement** (`LICENSE:1-51` + `LICENSE:54-67`). Apache permissive; explicit NOTICE-file attribution mandatory in any redistribution. Per A-02 § 6 — adds NOTICE file at stockforge root + per-file header for any port.

### 2.1 Hypothesis-vs-Empirical Fit Verdict

**CONFIRM HIGH for pattern adoption; DEMOTE wholesale-port to MEDIUM-LOW.** A-02 § 5:
- Three master-plan §4.2 hypothesis pieces (LLM-friendly markdown converter, async crawler scheduling with rate-limits, content-fingerprint dedup) all empirically exist as tightly-bounded modules with deterministic logic. ~600-900 LOC of code-port + attribution delivers them.
- Wholesale `AsyncWebCrawler` adoption pulls playwright + patchright + playwright-stealth + aiohttp + httpx + bs4 + lxml + cssselect + rank-bm25 + snowballstemmer + fake-useragent + unclecode-litellm (`pyproject.toml:15-50`) — overkill for stockforge single-tenant 3-5-peer scale.

### 2.2 BC Mapping (A-02 § 4)

| Component | BC |
|---|---|
| C1 DefaultMarkdownGenerator + PruningContentFilter + BM25ContentFilter | BC-5 News; BC-6 Influence; BC-7 Crowd |
| C2 RateLimiter (per-domain DomainState; `async_dispatcher.py:28-85`) | BC-5/6/7 (I-S34 ToS enforcement) |
| C3 MemoryAdaptiveDispatcher | harness/_shared (Phase 1 NOT needed; Phase 2+) |
| C4 CacheValidator + head-fingerprint (`cache_validator.py:42-200` + `utils.compute_head_fingerprint:2885-2943`) | BC-5/6 dedup |
| C5 RobotsParser (SQLite-backed, WAL, 7-day TTL; `utils.py:252-280+`) | BC-5/6/7 (I-S34 minimum) |
| C6 AsyncUrlSeeder (sitemap + Common Crawl; `async_url_seeder.py:1-100`) | BC-5 mainly |
| C7 FilterChain + URLScorer (`deep_crawling/filters.py:40-140`, `scorers.py:26-80`) | BC-7 + BC-6 |
| C8 CrawlerHub registry (`hub.py:37-69` + `BaseCrawler.__init_subclass__` typecheck `hub.py:24-35`) | harness + BC-5/6/7 (Theme L adapter shape) |
| C9 PDFContentScrapingStrategy + NaivePDFProcessorStrategy (`crawl4ai/processors/pdf/processor.py:1-100`) | BC-3 Reports (strategy-shape only; naive impl insufficient for VN broker PDFs) |
| AsyncWebCrawler facade, browser_manager, deep_crawling BFS/DFS, hooks, MCP bridge, Docker server, C4A Script DSL | out-of-scope |

### 2.3 Patterns to ADOPT

1. **CrawlerHub registry pattern** (A-02 § 3 C8) — single biggest architectural win for Theme L; maps cleanly to per-source ACL anti-corruption layer in DDD. Refactor `_crawlers` to instance-scoped with explicit `register()` call (not the class-level `Dict` global; per A-02 § 7 "Hub auto-discovery is global mutable state").
2. **`DefaultMarkdownGenerator` + `PruningContentFilter` + `BM25ContentFilter` pattern** (A-02 § 3 C1) — for VN news → LLM ingestion pipeline; re-implement ~150-300 LOC into `apps/ingestion/news/markdown_converter.py` + `pruning_filter.py`.

### 2.4 Components to PORT (LOC-level — Apache-2.0 + NOTICE)

- **C2 RateLimiter + DomainState** (`async_dispatcher.py:28-85`, ~60 LOC) — copy-with-attribution into `apps/_shared/crawl/rate_limiter.py`. Preserves jitter + decay semantics.
- **C4 CacheValidator** (`cache_validator.py:42-200`, ~200 LOC) — copy-with-attribution into `apps/_shared/crawl/cache_validator.py`. Pair with xxhash dep.
- **C5 RobotsParser** (~120 LOC, `utils.py:252-280+`) — copy-with-attribution OR re-implement; either acceptable.

### 2.5 Anti-Patterns to AVOID

- **VN-source selector gap (A-02 § 7).** Crawl4AI ships only `crawlers/amazon_product/` + `crawlers/google_search/` — every VN source (CafeF, NDH, VietstockFinance, Vietnam Biz) is a from-scratch `BaseCrawler` subclass.
- **`fake-useragent` rotation + `playwright-stealth` = ToS-grey (A-02 § 7).** I-S34 compliance + "public sources only" rule → **disable stealth-mode features by default**; use real stable user-agent strings; honor robots.txt strictly; rate-limit conservatively (≥2s/domain default).
- **LLM-extraction strategies in same package as deterministic.** I-S1 mandates **whitelist deterministic strategies only**: `DefaultMarkdownGenerator`, `PruningContentFilter`, `BM25ContentFilter`, `JsonCssExtractionStrategy`, `JsonXPathExtractionStrategy`, `RegexExtractionStrategy`, `DefaultTableExtraction`. Blacklist `LLMExtractionStrategy`, `LLMContentFilter`, `LLMTableExtraction` from port surface.
- **Vendored `html2text` license risk.** A-02 § 7 — vendored fork's license is uncertain (originally GPL Aaron Swartz; various forks relicensed MIT/GPL-3). Read `crawl4ai/html2text/__init__.py` license header BEFORE any port of `CustomHTML2Text`.
- **`unclecode-litellm` fork bus-factor.** Supply-chain hotfix replaced `litellm` with maintainer-personal fork; do NOT pull transitively.
- **3K-line `utils.py` god-module.** Re-implement the 30-50 LOC we need (compute_head_fingerprint, RobotsParser shape); do not import.

### 2.6 Risks Flagged by Deep-Dive

- **Sole maintainer + recent supply-chain hotfix** (A-02 § 5 last bullet) — pattern-port safer than dep-vendor.
- **CacheValidator head-fingerprint false-negatives** (A-02 § 7) — title+meta hash only; body changes without meta changes (corrections, comment additions) misclassify as FRESH. Layer a body-fingerprint over `cleaned_html` as a second pass.

---

## 3. dexter (A-03)

- **Repo**: `dexter` (likely virattt; `package.json` repo URL per `AGENTS.md:3`)
- **Path**: `C:/htdocs/research/dexter/`
- **Primary language**: TypeScript + Bun runtime + Ink/React CLI + LangChain abstraction
- **License class**: **MIT (declared in `README.md:178-180`); no LICENSE file at root** (A-03 § 6). Same license-ambiguity pattern as ai-hedge-fund.

### 3.1 Hypothesis-vs-Empirical Fit Verdict

**CONFIRM MEDIUM.** A-03 § 5: stack mismatch is REAL but NOT FATAL. TypeScript + LangChain on Bun ≠ Python-primary stockforge; code-port is uneconomic. Patterns (two-tier compaction, structured compaction prompt with Numerical-Data section, MMR + temporal decay re-ranking, SKILL.md frontmatter discovery, meta-tool routing, JSONL scratchpad) are language-agnostic and high-value.

### 3.2 BC Mapping (A-03 § 4)

| BC | Dexter mapping | Strength |
|---|---|---|
| BC-1 Market Data | `get_market_data` + `stock-price.ts` (financialdatasets.ai bound — US only) | LOW (data) / MEDIUM (pattern) |
| BC-2 Fundamentals | `get_financials` meta-tool + sub-tools | LOW (US-only) / MEDIUM (meta-tool routing) |
| BC-3 Reports/PDF | `read_filings` (SEC-only) | LOW |
| BC-4 Macro/Policy | Not addressed | NONE |
| BC-5 News | `web_search` (Exa/Perplexity/Tavily fallback), `web_fetch`, `browser` (Playwright) | MEDIUM (search-provider fallback pattern, browser-vs-fetch split) |
| BC-6 Influence | `x_search` + `x-research` SKILL.md (X-API-bound) | MEDIUM (pattern only) |
| BC-7 Crowd | Partial via `x-research` SKILL.md | LOW |
| BC-8 Analysis & Thesis | DCF skill + two-tier compaction + memory + skill-tool pattern; **single-perspective** SOUL.md (Buffett-Munger lens) | MEDIUM (mechanics) / LOW (philosophy — fails adversarial Charter rule) |
| BC-9 Portfolio & Action | Explicit non-trade-execution | NONE |

### 3.3 Patterns to ADOPT (pattern-only; stack-mismatch precludes code-port)

1. **Two-tier compaction** (microcompact + full compact) (A-03 § 3) — port pattern (cheap marker-replacement before expensive summarization) into BC-8 thesis-agent loop in Python.
2. **9-section structured compaction prompt** (`src/agent/compact.ts:45-100`) — explicit "Numerical Data" section directly answers I-S1 (forces preservation of source numbers across summarization). **High-value prompt-engineering pattern.**
3. **SKILL.md auto-discovery with frontmatter** + relative-link resolution (`src/tools/skill.ts:60-68`) — refinement on stockforge's existing `.claude/skills/*/SKILL.md`.
4. **DCF skill workflow** (`src/skills/dcf/SKILL.md`) — 8-step checklist with sector-WACC adjustment table. Adapt for VN-market sectors (VN risk-free rate + VN equity-risk premium).
5. **JSONL append-only scratchpad** (`src/agent/scratchpad.ts:55-101`) — debuggability + replay surface. Respect stockforge `current-execution.md` 200-LOC inline cap + telemetry rotation; do NOT mirror dexter's unbounded growth.
6. **MMR + temporal decay re-ranking** (`src/memory/temporal-decay.ts:21-38`, `src/memory/mmr.ts:28-57`) — defaults: `vectorWeight 0.7`, `textWeight 0.3`, `halfLifeDays 30`, `mmr.lambda 0.7`. Re-port (originally from "Openclaw MIT", per file headers).
7. **Web-fetch vs browser tool split** (`src/tools/browser/browser.ts:30-50`) — "prefer cheap fetch over expensive browser" cost-control pattern for BC-5 ingestion.

### 3.4 Components to PORT

NONE direct code-port (stack mismatch). Pattern-only.

### 3.5 Anti-Patterns to AVOID (A-03 § 7)

- **`async function*` translation gotcha** — Python equivalent is `async def` + `yield` (PEP 525); threading model differs, do NOT 1:1 transcribe.
- **LangChain TS vs LangChain Python APIs diverge.** For stockforge, **prefer NOT adopting LangChain** at all — abstraction layer adds dependency surface for marginal benefit when calling Claude API via subagent dispatch (per `anthropic_api_to_subagent` rule).
- **Zod schemas (TS) → Pydantic / dataclasses (Python)** — Pydantic in domain layer **explicitly forbidden** by CLAUDE.md ("Domain layer has ZERO framework dependency… use dataclasses"). Keep Zod-style schemas at adapter layer.
- **`process.env` reads scattered across tool files** — centralize via single config provider in port.
- **Single-perspective SOUL.md identity** — copying SOUL.md as-is would violate Charter multi-perspective-adversarial rule. If borrowing identity-document pattern, instantiate **multiple personas**.
- **DCF sector-WACC table US-market-calibrated** (`sector-wacc.md:11-23`) — risk-free 4%, equity-risk-premium 5-6%. VN equivalents differ; copy STRUCTURE not NUMBERS.
- **Max-iterations = 10 hardcoded** — calibrate per session-type, not single global.

### 3.6 Risks Flagged by Deep-Dive

- Onboarding docs in `docs/onboarding/*` are Vietnamese and "appear to be documentation generator output, not original; treat as derived not canonical" (A-03 § 1).
- License informality (MIT-declared without root file) — same risk class as ai-hedge-fund.

---

## 4. FinceptTerminal (A-04) — **DEMOTE MEDIUM → LOW**

- **Repo**: Fincept Terminal v4 (Fincept-Corporation)
- **Path**: `C:/htdocs/research/FinceptTerminal/`
- **Primary language**: C++20 + Qt6 (native single binary) + embedded Python 3.11.9 for analytics
- **License class**: **AGPL-3.0 + Fincept Commercial License (dual)** — `LICENSE:1-89`. AGPL free only for personal/individual learning/academic; Commercial License REQUIRED for any business/internal company use (USD 10,200/yr per `LICENSE:70`).

### 4.1 Hypothesis-vs-Empirical Fit Verdict

**DEMOTE MEDIUM → LOW.** A-04 § 5 four-point rationale:
1. Stack mismatch severe — C++/Qt6 + ADS docking; zero LOC ports to Streamlit. The `DashboardCanvas` is itself "a port of react-grid-layout" (`screens/dashboard/canvas/DashboardCanvas.h:12`); stockforge better off going direct to `react-grid-layout` (Phase 2+ Next.js) or `streamlit-elements` (Phase 1).
2. Phase 1 priorities mismatch — stockforge Phase 1 is data ingestion + claim extraction + basic Streamlit; high-density Bloomberg UX is Phase 2+ goal. Trying to import in Phase 1 violates P2 (Simplicity First).
3. License risk real — AGPL + commercial-license-for-internal-use means stockforge cannot literally copy any code or close-paraphrase any non-trivial design. **Patterns-only adoption mandatory.**
4. Pattern-yield concentrated in 3 small primitives (~20 + 50 + standard react-grid-layout knowledge); other ~95% C++ is Qt-specific framework plumbing or broker integrations irrelevant.

### 4.2 BC Mapping (A-04 § 4)

| BC | Component | Pattern transferable? |
|---|---|---|
| BC-9 (dashboard UX) | DashboardCanvas 12-col react-grid-layout; WidgetRegistry + DashboardTemplates; TabSessionStore + DashboardLayoutRepository workspace persistence; ThemeTokens design system | YES (concept) — port to Streamlit |
| BC-9 (multi-symbol linking) | Symbol Group Linking A-J slots | PARTIAL — Streamlit single-page reactive handles differently |
| BC-5 News (multi-panel) | NewsScreen 4-band layout; NewsCluster (lead+sources+velocity); Priority/Sentiment/Impact/ThreatLevel/SourceFlag enums; NewsTickerStrip | YES on data-model side; UI patterns aspirational Phase 2+ |
| BC-7 Crowd (sentiment viz) | bull/bear/neutral tri-color pills in NewsCommandBar | YES (concept) — adversarial-by-default presentation |
| BC-8 (multi-perspective) | EquityResearchScreen 8-tab Overview/Financials/Analysis/Technicals/Talipp/Peers/News/Sentiment | PARTIAL — FinceptTerminal does NOT enforce charter bear-case/adversarial mandate |
| Cross-cutting: Notifications | `NotificationService` + `INotificationProvider` abstraction | YES — clean Python port for BC-9 alerts → Telegram/email |

### 4.3 Patterns to ADOPT (ZERO LITERAL LOC due to AGPL+Commercial-required)

Reformulate description in stockforge's own words (per A-04 § 6):
1. **News priority/threat tier enums concept** — `Priority { FLASH, URGENT, BREAKING, ROUTINE }`, `Sentiment { BULLISH, BEARISH, NEUTRAL }`, `Impact { HIGH, MEDIUM, LOW }`, `ThreatLevel { CRITICAL, HIGH, MEDIUM, LOW, INFO }` with `SourceFlag { NONE, STATE_MEDIA, CAUTION }`. ~20 LOC equivalent in Python.
2. **Workspace-state versioning + UUID per-instance keying** (`TabSessionStore`). ~50 LOC Python equivalent.
3. **12-column grid + widget factory registry concept** (already standard react-grid-layout pattern).
4. **NotificationProvider abstraction** (`provider_id, display_name, icon, is_configured, is_enabled, send(req, cb), load_config, save_config`) — clean Python port for BC-9 alerts.

### 4.4 Components to PORT

**NONE.** AGPL + commercial-license-required prohibits literal LOC import. Pattern-only adoption with attribution: "Pattern inspired by FinceptTerminal — https://github.com/Fincept-Corporation/FinceptTerminal — AGPL-3.0. No code imported."

### 4.5 Anti-Patterns to AVOID (A-04 § 7)

**StockForge-charter conflicts:**
- **AI "buy/sell" agent personas** (`README.md:53` Buffett/Graham/Lynch) directly violate I-S35 ("frame as research aid, not financial advice"). **Do NOT import the agent-persona-as-recommender pattern**; keep stockforge agents as "perspective synthesizers" not "recommenders".
- **Single sentiment score per article** (`NewsService.h:62-66`) violates "structured, not narrative". Adopt the bull/bear/neutral tri-pill pattern (`NewsCommandBar.h:82-86`); reject any single composite "sentiment score" output.
- **No source/as-of-date discipline** visible in news data model (`NewsService.h:42-59`). I-S2 stricter — must separate `as_of_date` vs `ingested_at` vs `event_time`.

**Bloomberg-imitation legal-grey:**
- "Bloomberg-terminal-class" marketing copy — avoid using "Bloomberg" in any user-facing copy (trademark).
- `F1`-`F12` function-key bar + amber-on-black palette = Bloomberg distinctive trade dress. Inspiration fine; **pixel-for-pixel imitation must be avoided** if stockforge ever surfaces publicly.
- Bloomberg "Security Group" labels A-J → rename to neutral (e.g., "Watch Slot 1-10" or "Linked View α-ι").

**C++ idiom gotchas** (do not transplant verbatim) — `Result<T>`, `QProcess` Python bridge, `EventBus::instance()` singleton, `Q_DECLARE_INTERFACE`, `std::atomic<int>` stale-result rejection. Python idioms differ.

### 4.6 Risks Flagged by Deep-Dive

- **Scope creep risk** (A-04 § 7): FinceptTerminal has 40+ screens. Importing breadth (maritime/geopolitics/16 broker integrations) derails Phase 1.
- **License posture risk** (A-04 § 6): "Cloning, forking, downloading, building, or modifying this repository does NOT grant any right to use Fincept Terminal — or any Modified Version or Derivative Work — for Commercial Use" (`LICENSE:51-55`). AGPL network-service clause means any literal-LOC fork later hosted (peer-shared web dashboard) must release modifications under AGPL — incompatible with stockforge posture.

---

## 5. MediaCrawler (A-05) — **DEMOTE HIGH → MEDIUM-LOW**

- **Repo**: `MediaCrawler` (NanmiCoder, relakkes@gmail.com)
- **Path**: `C:/htdocs/research/MediaCrawler/`
- **Primary language**: Python async (Playwright + httpx)
- **License class**: **NON-COMMERCIAL LEARNING LICENSE 1.1 (NOT OSI-approved)** — `LICENSE:1-59`. Commercial use prohibited; per-file source-link mandatory; "may not be used for large-scale crawling" (§1 cond. 2). Auto-disqualified for stockforge commercial-defensible use; pattern-reference only.

### 5.1 Hypothesis-vs-Empirical Fit Verdict

**DEMOTE HIGH → MEDIUM-LOW.** A-05 § 5 five-point rationale:
1. **License blocks production use** — non-OSI; learning/research-only; "no large-scale crawling" clause grey for stockforge.
2. **Platform list does not include VN targets** — 7 Chinese platforms hardcoded (`main.py:50-67`). No Facebook, no YouTube, no Vietnamese forum support. Building VN platforms from scratch is required.
3. **Signing/sub-detection layers are platform-coupled** — `xhs_sign.py`, `playwright_sign.py`, `libs/douyin.js`, `libs/zhihu.js`, Tieba's `PC_SIGN_SECRET` hardcoded MD5 key (`tieba/client.py:39`) — ALL specific to Chinese anti-bot schemes; NONE transfers to F319 (no JS signing), Facebook (different scheme), YouTube (official OAuth).
4. **CDP-mode pattern is the genuine reusable artifact** — `tools/cdp_browser.py` (524 LOC) IS extractable as a pattern even if not copied verbatim. The "connect to user's existing logged-in Chrome" approach (`cdp_browser.py:140-195`) is legitimate, user-consented, superior to headless bot detection. **Single highest-value takeaway.**
5. **Storage / proxy / cache adapter shapes are textbook** — no stockforge-specific advantage over rolling own with SQLAlchemy + httpx + cachetools.

### 5.2 BC Mapping (A-05 § 4)

- **BC-6 Influence**: Conceptual mapping to creator mode (`media_platform/xhs/core.py:121-123`) — fetch all content from a creator's homepage. Pattern reusable; YouTube has official Data API v3 (preferred per I-S34) and yt-dlp for transcripts; Facebook public-page = Meta's robots.txt + ToS; SHAPE transfers, IMPLEMENTATION (xhshow signing, mobile-QR login) does not.
- **BC-7 Crowd (F319 forums)**: Closest analog Tieba module. Comment-tree walker pattern (`media_platform/xhs/client.py:407-536`) transferable; signing layer not needed (F319 is vBulletin-style, server-rendered HTML).
- **BC-5 News**: No direct mapping. Use crawl4ai instead.
- **BC-1/2/3/4/8/9**: No mapping.

### 5.3 Patterns to ADOPT (pattern-reference only — clean-room re-derive, do not copy)

1. **AbstractCrawler / AbstractLogin / AbstractStore / AbstractApiClient interface shape** (`base/base_crawler.py:26-127`).
2. **CDP-connect-existing-Chrome flow** (`cdp_browser.py:140-195`) — `CDP_CONNECT_EXISTING=True` mode ONLY; the `_launch_browser` auto-confirm mode (`cdp_browser.py:250-286`) is legal-grey (see § 5.5).
3. **Cursor + sub-comments pagination loop** (`media_platform/xhs/client.py:407-536`).
4. **`ProxyRefreshMixin.init_proxy_pool()` + `_refresh_proxy_if_expired()`** (`proxy/proxy_mixin.py:34-77`) PATTERN — Chinese paid proxies (快代理/万代理) NOT TRANSFERABLE; substitute provider.
5. **AbstractCache + ExpiringLocalCache + RedisCache** (`项目架构文档.md:562-593`) — textbook pattern.
6. **app_runner.run() with SIGINT/SIGTERM graceful-exit + 15s cleanup timeout** (`main.py:142-157`) — solid harness pattern.

### 5.4 Components to PORT

**NONE.** License non-OSI; clean-room re-derive the IDEA in own code.

### 5.5 Anti-Patterns to AVOID — **MANDATORY legal-grey audit (A-05 § 7)**

1. **`libs/stealth.min.js` (180KB fingerprint spoofer)** — injected via `browser_context.add_init_script` in `media_platform/xhs/core.py:93`. EU Directive 2013/40/EU + EU AI Act risk-classification + Vietnamese Law on Cybersecurity 2018 §16 all lean AGAINST. **HARD REJECT.** Stockforge announces bot identity in User-Agent + respects robots.txt.
2. **Reverse-engineered signing keys** — `tieba/client.py:39` hardcodes `PC_SIGN_SECRET = "36770b1f34c9bbf2e7d1a99d2b82fa9e"`. Plus `xhs_sign.py` + `playwright_sign.py` (~328 LOC combined). NEVER NEEDED FOR VN TARGETS.
3. **CDP-launched-with-auto-confirm mode** (`cdp_browser.py:250-286`, `CDP_CONNECT_EXISTING=False`) — spawns Chrome with `--remote-debugging-port` + auto-connects without user opt-in. Bot automation masked as user. **USE ONLY `CDP_CONNECT_EXISTING=True` MODE.**
4. **Browser-context `fetch()` evaluation to bypass TLS** (`tieba/client.py:108-120`) — own-account use OK; anonymous-target scraping NOT.
5. **`AUTO_CLOSE_BROWSER=False` + persistent `USER_DATA_DIR`** — privacy/secrets risk; must encrypt user_data at rest + separate profiles per target + periodic credential rotation.
6. **`Crawler_Illegal_Cases_In_China` reference link in README** (`README_en.md:22`) — tacit acknowledgement that even the AUTHOR considers tooling legally fraught.
7. **`Crawler_Max_Sleep_Sec = 2` default** (`config/base_config.py:133`) — too aggressive. **Set ≥5-10s + jitter + per-source robots.txt enforcement.**
8. **600-retry decorator on login check** (`xhs/login.py:51`) — 10-minute brute-spam loop on login probe; do NOT replicate.
9. **`DISABLE_SSL_VERIFY` config option** (`base_config.py:135-137`) — even gated by warning, having the knob invites misuse. **Hard-disable SSL-skip in stockforge.**

### 5.6 Mandatory StockForge Guard Rails when Adopting Any Pattern (A-05 § 7 final list)

- Deterministic pre-crawl gate that checks target's robots.txt + ToS-allowlist (I-S34) before launching.
- Announce stockforge identity in User-Agent (do not spoof).
- Cap request rate at platform-published API limits; reject unconfigured platforms by default.
- Audit-log every scrape with source URL + as-of timestamp + ToS-version-hash.
- Use ONLY `CDP_CONNECT_EXISTING=True` consent flow if CDP adopted.
- Drop ALL of `libs/*.js` and all `*_sign.py` files.

### 5.7 Risks Flagged by Deep-Dive

- Non-OSI license commercial-prohibition + "no large-scale crawling" clause.
- Author maintains paid "Pro" version (MediaCrawlerPro per `README_en.md:54-73`) → OSS variant intentionally limited.

---

## 6. MoneyPrinterPlus (A-06) — Phase 4+ deferred

- **Repo**: `MoneyPrinterPlus` (Chinese-language short-video toolkit)
- **Path**: `C:/htdocs/research/MoneyPrinterPlus/`
- **Primary language**: Python (Streamlit UI: `requirements.txt:7` `streamlit==1.34.0`)
- **License class**: **GPL-3.0** (`LICENSE:1-2`). Strong copyleft — derivative-work-linking forces stockforge to release codebase under GPL-3.0. **Hard incompatibility with stockforge proprietary-by-default posture.**

### 6.1 Hypothesis-vs-Empirical Fit Verdict

**CONFIRM LOW.** A-06 § 5: "The repo's ambient framing (auto-publish to Douyin/Kuaishou/Xiaohongshu per `services/publisher/*.py`) is fundamentally a content-marketing / SaaS-creator pipeline — the StockForge charter explicitly lists 'becoming a SaaS in Year 1' as a non-goal, and the auto-publish to public short-video platforms collides head-on with I-S35 (research-aid-not-financial-advice) framing."

### 6.2 BC Mapping

NONE for Phase 1-2. Hypothetical Phase 4+: thin tie-in to BC-8 (Thesis Synthesis) for video-summary rendering; even there I-S35 disclaimer + ban LLM-authored narration required.

### 6.3 Patterns / Components

NONE for Wave 1.

### 6.4 Anti-Patterns to AVOID (A-06 § 7)

- **Default output style** (traffic-optimized short-video for public platforms) **structurally incompatible with I-S35** — platforms optimize discovery via engagement, which conflicts with calibrated/hedged research output. Adopting prompt templates or publishing pipelines would push stockforge toward financial-advice-positioning content even with disclaimer overlays.
- **GPL-3.0 copyleft viral propagation** — clean-room reimplementation required to sidestep license; not justified given LOW fit.

### 6.5 Risks Flagged by Deep-Dive

- Phase 4+ deferral recommended. If peer-circle video ever happens, build narrow custom pipeline rather than fork this repo.

---

## 7. MoneyPrinterTurbo (A-07) — Phase 4+ deferred

- **Repo**: `MoneyPrinterTurbo` (harry0703), v1.2.7 per `pyproject.toml:10`
- **Path**: `C:/htdocs/research/MoneyPrinterTurbo/`
- **Primary language**: Python (FastAPI backend + Streamlit WebUI; moviepy + faster-whisper + edge-tts + azure-speech)
- **License class**: **MIT** (`LICENSE:1-3`, Copyright (c) 2024 Harry). Permissive — were Phase 4+ to borrow any module, attribution + license-text inclusion satisfies compliance. **No copyleft contagion.**

### 7.1 Hypothesis-vs-Empirical Fit Verdict

**CONFIRM LOW.** A-07 § 5: "No surprises. The repo is a content-marketing pipeline; the only intersection with StockForge is the shared use of Streamlit and Python 3.11+, which is incidental commodity-stack convergence, not architectural fit."

### 7.2 BC Mapping

NONE. Pipeline produces video artifacts; no overlap with any thesis/data/risk BC.

### 7.3 Patterns / Components

NONE for Wave 1.

### 7.4 Anti-Patterns to AVOID (A-07 § 7)

- **I-S35 preservability risk HIGH if ever adopted** — `app/services/llm.py` script-generation stage designed to produce persuasive narrative copy ("Generate short videos from prompts"). Auto-narrated video tends toward recommendation-shaped output. Phase 4+ adoption must intercept script generation with deterministic citation-bound template, NOT free-form LLM prose.
- **GPU-Docker compute-cost concern** (`Dockerfile.gpu:1` mandates CUDA 12.1 + cuDNN 8; `docker-compose.gpu.yml:21-27` reserves 1 NVIDIA GPU) — disproportionate for 3-5-peer scale + trivial output volume.
- **LLM-math leak risk** — `app/services/llm.py` allows LLM to invent statistics inside narration. **Direct collision with I-S1.** Any adoption requires reducing script generator to templating layer over pre-computed deterministic outputs only.

### 7.5 Risks Flagged by Deep-Dive

- Phase 4+ deferral.

---

## 8. MoneyPrinterV2 (A-08) — Phase 4+ deferred

- **Repo**: `MoneyPrinterV2` (FujiwaraChoki; sponsored by Post Bridge)
- **Path**: `C:/htdocs/research/MoneyPrinterV2/`
- **Primary language**: Python 3.12 monolithic CLI app
- **License class**: **AGPL-3.0** (`LICENSE:1`, Copyright 2024 FujiwaraChoki at L633). Strong copyleft with network-use clause — any derivative interacting with users over a network must offer Corresponding Source. **Incompatible with stockforge private posture.**

### 8.1 Hypothesis-vs-Empirical Fit Verdict

**CONFIRM LOW.** A-08 § 5 five-fold rationale: wrong domain (content monetization); wrong scale (one-to-many public social fan-out vs 3-5 named peers); wrong primitive (`classes/YouTube`, `classes/Twitter`, `classes/AFM`, `classes/Outreach`); license-incompatible (AGPL); Phase 1-2 has no video/content output.

### 8.2 BC Mapping

NONE. Closest hypothetical adjacency = future Distribution BC (Phase 4+); even there Post Bridge wrong tool (targets public TikTok/Instagram/YouTube; stockforge "research aid for 3-5 peers" precludes public-platform fan-out).

### 8.3 Patterns / Components

NONE for Wave 1. Pattern-only conceptual reference to **Post Bridge signed-URL upload + per-platform account resolver** (`src/post_bridge_integration.py:14-60`) if Phase 4+ ever publishes to Telegram/Discord/Zalo — ~50 LOC reimplementable; copying brings no leverage and inherits AGPL-3.0 viral copyleft.

### 8.4 Anti-Patterns to AVOID (A-08 § 7)

- **I-S35 framing preservation** — MPV2 framing "make money online" + AGPL-licensed bots; superficial pattern-borrowing risks bleeding monetization/content-creator language into stockforge code or docs.
- **ToS-grey automation patterns** — scraped-business cold-outreach (`README.md:29, 41`) + bulk Twitter/YouTube posting via cron brush against CAN-SPAM, GDPR. Distribution BC must target named-peer private channels with consent, not scraped audiences.

### 8.5 Risks Flagged by Deep-Dive

- AGPL-3.0 viral propagation — do not vendor, do not copy, do not import as dependency.

---

## 9. NarratoAI (A-09) — Phase 4+ deferred

- **Repo**: `NarratoAI` v0.7.9 (linyq)
- **Path**: `C:/htdocs/research/NarratoAI/`
- **Primary language**: Python (Streamlit `webui.py`, `streamlit>=1.45.0`; moviepy + edge-tts + azure-cognitiveservices-speech + dashscope; Gemini + Qwen-VL vision analyzers)
- **License class**: **Modified MIT — Non-Commercial Use Only** (`LICENSE:1-3, 10-13`). Personal/educational/research permitted; commercial use prohibited without written permission. **Eliminates any future revenue-product path if code reused.**

### 9.1 Hypothesis-vs-Empirical Fit Verdict

**CONFIRM LOW.** A-09 § 5: domain mismatch (video/film commentary vs VN equity research) + stack mismatch (moviepy/edge-tts/Streamlit-desktop vs Postgres-backed Python service) + license-blocks-commercial. **Zero Wave-1 IMPL action.**

### 9.2 BC Mapping

NONE. Closest tangential overlap = LLM-prompting infrastructure (`app/services/llm/`, `app/services/prompts/`); but stockforge has own prompt-engineering skill + no-LLM-math constraint NarratoAI does not enforce.

### 9.3 Patterns / Components

NONE for Wave 1.

### 9.4 Anti-Patterns to AVOID (A-09 § 7)

- **I-S35 preservation** — adopting narration/video output paradigm would actively undermine research-aid framing; audio/video commentary on stocks reads as advice. **STRONG recommendation: do not import this output pattern even in Phase 4+.**

### 9.5 Risks Flagged by Deep-Dive

- Documentation-quality MODERATE — screenshot-heavy README impedes code-port comprehension; technical `docs/onboarding/` track exists.
- Non-commercial clause eliminates revenue path.
- Scope-creep risk — mere awareness could tempt future agent to propose video-output features violating Phase 1-2 charter.

---

## 10. nautilus_trader (A-10)

- **Repo**: `nautilus_trader` (Nautech Systems Pty Ltd) — Rust-native event-driven trading engine + Python control plane via PyO3
- **Path**: `C:/htdocs/research/nautilus_trader/`
- **Primary language**: Rust core (24 crates in `crates/`) + Python bindings (Cython `.pyx/.pxd` + PyO3)
- **License class**: **LGPL-3.0** (`LICENSE:1`, per-file headers consistent `Copyright (C) 2015-2026 Nautech Systems Pty Ltd. All rights reserved.`). LGPL allows pip-install dependency; modifications must be LGPL'd; LOC vendoring triggers source-availability. **Pip-install or re-implement-from-shape preferred over LOC copy.**

### 10.1 Hypothesis-vs-Empirical Fit Verdict

**CONFIRM HIGH.** A-10 § 5: W0-1 / W0-1b / W0-2 sources all empirically re-verified.

**Reconfirmed harvest sources (A-10 §0):**
- **W0-1 FSM substrate** — generic `FiniteStateMachine` at `nautilus_trader/core/fsm.pyx:41-130`; OrderStatus FSM (14-state) at `nautilus_trader/model/orders/base.pyx:99-164`; ComponentState FSM (14-state) at `nautilus_trader/common/component.pyx:1614-1677`. Stockforge adaptation at `packages/domain/observation_lifecycle/fsm.py:1-80` (8-state `INITIALIZED/DISPATCHED/IN_FLIGHT/OBSERVATION_WRITTEN/SIDECAR_ATTESTED/RECTIFIED/ORPHANED/RESOLVED`). Note: claim re-clarified — the FSM **substrate** was ported (the `(state, trigger) → next_state` table pattern), not the 8 specific states. The 14-state Nautilus enums were collapsed to fit stockforge's 8 observation-lifecycle phases.
- **W0-1b re-escalation + 7-col TSV schema** — NOT directly from nautilus_trader (stockforge-original; Nautilus FSM doesn't track "age").
- **W0-2 Python determinism / no-naive-datetime doctrine** — DST doctrine at `docs/concepts/dst.md:1-200`; pre-commit hook at `.pre-commit-hooks/check_dst_conventions.sh:1-50` (6 explicit ban rules + `ALLOW_MARKER="dst-ok"` parallel to stockforge); UTC enforcement helpers at `nautilus_trader/core/datetime.pyx:217-301` (`is_datetime_utc`, `is_tz_naive`, `as_utc_timestamp`); Clock abstraction at `nautilus_trader/common/component.pyx:129-236, 622, 838`. Audit: only **3 `datetime.now(` call sites total** across entire `nautilus_trader/` Python package (`adapters/interactive_brokers/parsing/instruments.py:1047-1050`, all `tz=datetime.UTC`).

### 10.2 BC Mapping (A-10 § 4)

| BC | Match | Sources | Notes |
|---|---|---|---|
| BC-1 Market Data | HIGH | `nautilus_trader/data/`, `model/data.pyx` (QuoteTick, TradeTick, Bar), `persistence/` | Bar/tick canonical types; `TimeRangeGenerator`; nanosecond UNIX timestamps |
| BC-9 Portfolio & Action | HIGH | `nautilus_trader/portfolio/`, `risk/engine.pyx`, `backtest/engine.pyx` | Backtest arch (Month-12), deterministic risk rules (Principle 10), position lifecycle |
| BC-8 Analysis & Thesis | MEDIUM | `indicators/base.pyx`, `trading/strategy.pyx` | Indicator interface (input handler → state → reset) maps to perspective-as-class |
| Harness substrate | HIGH | `core/fsm.pyx`, `common/component.pyx Clock`, `docs/concepts/dst.md` + `check_dst_conventions.sh` | Theme F: FSM (W0-1), Clock-injection (W0-2), pre-commit discipline (W0-2.1 PENDING fix; 2 violations live) |
| BC-2/3/4/5/6/7 | LOW | n/a | Nautilus is information-flow agnostic; no claim-extraction, no source-citation, no calibration tracking |

### 10.3 Patterns to ADOPT (re-implement from architectural shape; pip-install pattern preferred)

1. **DST / clock-injection / no-naive-datetime doctrine** — re-implementation pattern (W0-2 D-059 already ACCEPTED). Fix patterns documented for W0-2.1 violations (see § 10.4).
2. **Event-driven MessageBus pattern** (`nautilus_trader/common/component.pyx:2215-2340`) — Theme M candidate, **DEFERRED past Wave 1**. Extract topic-wildcard subscription resolution + endpoint dispatcher; build stockforge-sized equivalent (drop Redis backing + threading complexity).
3. **Strategy/Indicator interface boundaries** (BC-8 indicators; `trading/strategy.pyx:109-200`, `indicators/base.pyx:21-78`) — input handler + initialized flag + reset; maps cleanly to "perspective inputs → claim score" with deterministic reset for backtest.
4. **BacktestEngine architecture** (`nautilus_trader/backtest/engine.pyx:217-280`) — heap-priority time events + deterministic clock injection + venue simulation. Reimplement in **pure Python with `heapq`** (Python stdlib); **DO NOT port Rust `TimeEventAccumulator` (Cython FFI)**.
5. **Risk engine deterministic-rules pattern** (`nautilus_trader/risk/engine.pyx:77-200, 569-628`) — pre-trade `_check_order → _check_order_price → _check_order_quantity → _check_orders_risk` chain. **Direct match to charter Principle 10** ("LLM cannot override max position size, sector concentration, stop loss rules"). Three `TradingState` modes: `ACTIVE / REDUCING / HALTED`. Per-instrument `max_notional_per_order` dict.
6. **Fixed-precision arithmetic for Price/Quantity/Money** (`model/objects.pyx:91-170` — Quantity uses uint64/uint128 raw storage; 16-decimal precision; no float arithmetic). Direct enabler of charter "NO LLM math". Stockforge uses Decimal (sufficient for single VN-market, single currency).

### 10.4 Components to PORT — W0-2.1 mechanical fix (live in production)

**Re-confirmed live violations** (A-10 § 3.5):
- `packages/application/crowd/use_cases/capture_sentiment_snapshot_use_case.py:114` — `default_factory=lambda: lambda: datetime.now(UTC)` (R2 main-block-context heuristic miss)
- `packages/infrastructure/analysis/sqlite_thesis_repository.py:206` — `else datetime.now()` (R1 bare-parens — naive datetime, the worse case)

**Fix pattern** (mirror nautilus): inject `clock: Callable[[], datetime]` parameter (use case constructor) or `Clock` port (repository); call `clock()` / `clock.utc_now()`. Default factory in tests via fixture; production wires `datetime.now(UTC)` once at composition root. **Single-source-of-now.**

### 10.5 Anti-Patterns to AVOID (A-10 § 7)

- **Over-port risk** — nautilus is 24 Rust crates + 22 Python sub-packages; stockforge is single-tenant VN advisory. Porting more than minimum architectural shape violates P2 (Simplicity First).
- **Do not port** `Throttler`, `ExecutionAlgorithm`, `EmulatedOrder`, `ContingencyType` (OCO/OUO/OTO orders), `TrailingStopMarket/Limit`, `AccountType`-multi-asset abstractions. These exist for venue heterogeneity stockforge doesn't have.
- **Do not port the Rust FFI layer (PyO3, Cython `.pyx`).** Pure Python is mandatory.
- **Do not adopt high-precision (128-bit Money)** — single VN-market, single currency, Decimal sufficient.
- **LGPL surface-area risk** — never vendor code; **keep nautilus as `pip install` dependency only** (dynamic link); cite-by-pattern (architectural reference) for code we write ourselves.
- **Premature event-driven adoption** — BC integration is currently file-and-function-based, not event-based. Theme M deferral past Wave 1 is correct.
- **Backtest scope creep** — Nautilus supports tick-level multi-venue parallel backtests with order-book reconstruction; stockforge needs **end-of-day bar-level single-venue VN-Index backtests** for Month-12 criterion. Don't import complexity envelope.
- **DST contract is Rust-only** — `docs/concepts/dst.md` applies to Rust `tokio` runtime, not Python control plane. Python-side determinism in stockforge (W0-2 hook) is structurally analogous but does NOT inherit nautilus's enforcement strength.

### 10.6 Risks Flagged by Deep-Dive

- No VN-market specifics (no HOSE/HNX/UPCOM, no T+2.5, no foreign-room, no Vietnamese sentiment). All VN-domain logic must come from elsewhere (BC-2 → BC-7 source repos).
- LGPL § per-file copyright header: `Copyright (C) 2015-2026 Nautech Systems Pty Ltd. All rights reserved. // Licensed under the GNU Lesser General Public License Version 3.0`. **Attribution mandatory for any code-port**: cite `nautilus_trader/<file>:<line-range>` in stockforge module docstring (precedent set in `packages/domain/observation_lifecycle/fsm.py:4`).

---

## 11. Pixelle-Video (A-11) — Phase 4+ deferred

- **Repo**: `Pixelle-Video` (AIDC-AI) — `README_EN.md:1-2`, `NOTICE:1`
- **Path**: `C:/htdocs/research/Pixelle-Video/`
- **Primary language**: Python (api/ + pixelle_video/{pipelines,services,models,prompts}; ComfyUI-based atomic-capability stack)
- **License class**: **Apache-2.0** (`LICENSE:1-3`); `NOTICE:1` "Copyright (C) 2025 AIDC-AI" with downstream OSS attributions. Permissive — derivative/private use with NOTICE retention.

### 11.1 Hypothesis-vs-Empirical Fit Verdict

**CONFIRM LOW.** A-11 § 5: "Repo is a content-creation tool (`README_EN.md:17-25` 'Zero threshold... typing a sentence'), explicitly targeting general short-video creators, not financial research or claim-integrity workflows."

### 11.2 BC Mapping

NONE for Phase 1-2.

### 11.3 Patterns / Components

NONE for Wave 1. ComfyUI atomic-workflow architecture (`README_EN.md:59`) noted as **theoretical** Phase 4+ pattern — citation-overlay could be injected as custom workflow step (presentation skin over verified deterministic outputs).

### 11.4 Anti-Patterns to AVOID (A-11 § 7)

- **R1 — Default pipeline produces fluent LLM-written narration with ZERO citation scaffolding** (`docs/FAQ.md:32-46` only covers TTS/LLM error handling). Direct use violates I-S35 + I-S1.
- **R2 — TTS voice cloning** (`docs/en/tutorials/voice-cloning.md`) — deepfake/impersonation risk if used to "voice" any analyst or KOL; **must be banned in any Phase 4+ adoption.**
- **R3 — "3-minute video" speed framing** (`docs/en/index.md:5`) culturally invites quick-take stock-tip content, opposite of adversarial-thesis discipline.
- **R4 — Templates / visual styles** (`docs/en/tutorials/custom-style.md`) trend toward attention-grabbing aesthetics, conflicts with calibration-over-confidence.

Mitigation if ever adopted: treat as **pure presentation skin over already-verified structured outputs**; ban LLM-authored narration in favor of deterministic templated narration from cited claim records; ban voice cloning entirely.

### 11.5 Risks Flagged by Deep-Dive

- Phase 4+ deferral.

---

## 12. Scrapling (A-12) — **partial DEMOTE on Cloudflare-solver + patchright**

- **Repo**: `Scrapling` v0.4.7 (Karim Shoair, karim.shoair@pm.me; `pyproject.toml:8-13`)
- **Path**: `C:/htdocs/research/Scrapling/`
- **Primary language**: Python ≥3.10
- **License class**: **BSD-3-Clause** (`LICENSE:1-28`). Permissive — three conditions: retain copyright (source + binary docs) + no endorsement use. **Cleanest legal posture among the three crawler candidates.**

### 12.1 Hypothesis-vs-Empirical Fit Verdict

**CONFIRM HIGH for parser + adaptive selector triad; DEMOTE on stealth.** A-12 § 5:
- **HIGH FIT — adaptive parser + ProxyRotator + RobotsTxtManager + find_similar.** Code quality clean (parser.py:803-868 similarity score has type hints, coherent algorithm). **This IS the differentiator vs Parsel/lxml** — directly addresses spirit of I-S34 (resilience to site changes without re-engineering).
- **MEDIUM FIT — fetcher / spider patterns** (pattern-only, don't vendor). Speed claim overstated: 784x BS4 win is BS4's problem, not Scrapling's superiority; Scrapling ≈ Parsel.
- **LOW FIT / DO NOT ADOPT — `StealthyFetcher._cloudflare_solver`** (`engines/_browsers/_stealth.py:107-181`) is **mouse-click-on-Turnstile-iframe automation** calculating Captcha coordinates and clicking via `page.mouse.click(captcha_x, captcha_y)` with randomized delays. **Explicit Cloudflare evasion.** Internal contradiction: README CAUTION at `README.md:524-525` says "respect terms of service" yet ships active CF bypass. **HARD REJECT.**
- **LOW FIT — `patchright`** (`pyproject.toml:75`) — community Playwright fork patched for anti-detection (removes `webdriver` property, spoofs `navigator.plugins`). Using it implies intent to evade automation detection. **DO NOT IMPORT.**

### 12.2 BC Mapping (A-12 § 4)

- **BC-1 Portfolio**: no fit.
- **BC-2 Universe**: marginal — adaptive selectors help when HOSE/HNX redesigns; tiny payoff vs FiinPro/SSI direct APIs.
- **BC-3 Fundamentals**: marginal — VN broker reports are PDFs (Scrapling no PDF support).
- **BC-4 Macro**: low fit — government/SBV data better via direct CSV/Excel.
- **BC-5 News**: **HIGH FIT** — adaptive selectors + FetcherSession TLS impersonation + RobotsTxtManager directly serve CafeF/NDH/VietstockFinance/VietnamBiz.
- **BC-6 Influence**: MEDIUM — YouTube transcript page dynamic JS (yt-dlp is canonical); Facebook public pages = StealthyFetcher works but ToS-grey; adaptive selectors useful for FB layout drift.
- **BC-7 Crowd (F319 forums, Reddit-style threads)**: **HIGH FIT** — `find_similar` purpose-built for "given one thread card, find the rest" pattern; spider framework handles forum politeness.
- **BC-8 Adversary**: low fit.
- **BC-9 Calibration**: no fit.

**Dominant fit: BC-5 (news) + BC-7 (crowd). BC-6 partial.**

### 12.3 Patterns to ADOPT (BSD-3 with attribution)

1. **Adaptive Selector** (`parser.py:564-692` + `core/storage.py:74-157`, ~250 LOC core) — pattern-port into `apps/_shared/crawl/adaptive_selector.py`. CRITICAL CAVEAT (A-12 § 7 #2): `adaptive=True` without prior `auto_save=True` is a no-op — **fallback recovery mechanism, NOT prevention**.
2. **`find_similar`** (`parser.py:1009-1068`, ~60 LOC) — pattern-port for BC-7 forum thread listings + BC-5 news article cards.
3. **Speed-optimized lxml parser with pre-compiled XPath** (`parser.py:6-16, 47-61`) — pattern-reference; pre-compile hot XPaths at module load.

### 12.4 Components to PORT (BSD-3 with attribution)

- **C4 ProxyRotator** (`engines/toolbelt/proxy_rotation.py:39-100`, ~100 LOC) — copy-with-attribution. Thread-safe round-robin with pluggable strategy callable.
- **C5 RobotsTxtManager** (`spiders/robotstxt.py:10-60`, ~70 LOC) — copy-with-attribution. Maps directly to I-S34. NOTE: in-memory cache; swap to SQLite for long-running daemons.
- **C7 Development-mode response cache** (`spiders/cache.py` + `engine.py:56-61`) — pattern-port for crawler dev/test workflow.
- **C8 Browserforge-based header generation** (`engines/toolbelt/fingerprints.py:37-56`) — dependency-adopt `pip install browserforge`, ~20 LOC wrapper.
- **`FetcherSession` curl_cffi TLS impersonation** (`engines/static.py:49-200+`) — **dependency-adopt curl_cffi directly** (not vendor Scrapling's session wrapper); pattern-level: ~150 LOC `_merge_request_args` adoption.

**Attribution header template** (A-12 § 6):
```python
# Adapted from Scrapling (BSD-3-Clause) by Karim Shoair
# https://github.com/D4Vinci/Scrapling
# Original file: scrapling/<path>.py
```

### 12.5 Anti-Patterns to AVOID — **HARD REJECT (A-12 § 7)**

1. **Cloudflare Turnstile bypass** (`engines/_browsers/_stealth.py:107-200, 382-460`) — **HARD REJECT.** Active circumvention of Cloudflare anti-bot via automated mouse-click. Cloudflare ToS + protected-site ToS universally prohibit. **Stockforge MUST NOT adopt `solve_cloudflare=True` or `_cloudflare_solver` code path.**
2. **`StealthyFetcher` class as a whole** is suspect — even without `solve_cloudflare`, uses `patchright`. **Do not import `StealthyFetcher` or `patchright`.**
3. **Adaptive selector requires prior fingerprint** — README "Scrape data that survives website design changes!" (`README.md:64-66`) technically true but requires healthy first-run baseline. **Anti-pattern: relying on adaptive selectors as primary resilience strategy.** Use as *fallback*; treat selector failures as real failures requiring human inspection.
4. **SQLite storage at default path collides across projects** (`parser.py:47` `__DEFAULT_DB_FILE__` inside installed Scrapling package directory). **Stockforge mitigation**: force explicit per-source storage paths (e.g., `data/crawl/fingerprints/cafef.db`).
5. **Single-author project, pre-1.0** (`pyproject.toml:12-13, 39`) — supply-chain risk. **Mitigation**: extract algorithm (C1/C2/C4/C5) into local `apps/_shared/crawl/` modules with attribution, don't pin `scrapling==0.4.x` as runtime dependency.

### 12.6 Risks Flagged by Deep-Dive

- Benchmark vs production reality gap — synthetic deeply-nested HTML (`benchmarks.py:17-19` `<div class="item">` × 5000); real VN news pages vary. No benchmarks shipped for fetcher latency.
- `browserforge` + `apify-fingerprint-datapoints` supply-chain audit needed before adopting (Apify is paid scraping platform).
- No GDPR/privacy-aware text handling — Scrapling extracts wholesale; layer PII-redaction step downstream for BC-6/BC-7.
- Spider's "blocked detection" HTTP-status-only — real anti-bot blocks return 200 + challenge page; implement content-based block detection.

---

## 13. TradingAgents (A-13)

- **Repo**: TradingAgents v0.2.4 (Tauric Research; arXiv 2412.20138)
- **Path**: `C:/htdocs/research/TradingAgents/`
- **Primary language**: Python 3.10+; LangGraph StateGraph + LangChain providers + yfinance + Alpha Vantage + SQLite via `langgraph-checkpoint-sqlite`
- **License class**: **Apache-2.0** (`LICENSE:1-201`, Copyright "Tauric Research"). Permissive; lift-and-adapt with attribution permitted. Citation requested (README.md:262-271 — arXiv 2412.20138).

### 13.1 Hypothesis-vs-Empirical Fit Verdict

**CONFIRM HIGH.** A-13 § 5: debate-style multi-agent + dual harvest patterns + structured-output schema all map cleanly to BC-8 + harness substrate.

**Reconfirmed harvest sources (A-13 § 0):**
- **W0-3 atomic temp-file-replace doctrine** — `tradingagents/agents/utils/memory.py:109-114` docstring explicitly names "Replace pending tag and append REFLECTION section using atomic write. … Uses a temp-file + os.replace() so a crash mid-write never corrupts the log." Idiom at `memory.py:161-163` (`tmp_path = self._log_path.with_suffix(".tmp")` + `tmp_path.write_text(...)` + `tmp_path.replace(self._log_path)`). Identical idiom in `batch_update_with_outcomes()` at `memory.py:215-217`. Test at `tests/test_memory_log.py:426-437` (`test_update_atomic_write`).
- **W0-4 HTML-comment separator pattern** — `memory.py:13-14` `_SEPARATOR = "\n\n<!-- ENTRY_END -->\n\n"`. Used as delimiter for write (`memory.py:48`) + parse (`memory.py:59`) + atomic write methods (`memory.py:160, 214`). HTML markup LLM **cannot** emit inside markdown prose (LLMs see it but render swallows it) → forgery-proof delimiter.

### 13.2 BC Mapping (A-13 § 4)

| BC | Patterns | Adaptation gap |
|---|---|---|
| **BC-8 (Multi-perspective adversarial)** PRIMARY | C3 debate framework, C4 shared debate-state TypedDict, C5 structured-output schema + free-text fallback, C6 5-tier rating + heuristic parser, C7 render-back-to-markdown helper | 2-agent + 3-agent debate; stockforge charter wants ≥4 perspectives. Topology generalisable (mechanical `add_node` + `add_conditional_edges` extension). Add VN-specific perspectives (macro/SBV policy, behavior/retail-flow, regulation/HoSE-HNX-rule). |
| **BC-3 (Memory / continuity)** PARTIAL | C8 reflection loop, C9 past-context injection (memory log → judge prompt) | yfinance + SPY return path (`trading_graph.py:200-220`) is US-only; must be replaced with HoSE/HNX (vnstock or direct SSI/VND). |
| **BC-1 (harness substrate)** SUBSTRATE | C1 atomic temp-file-replace (W0-3), C2 HTML-comment separator (W0-4), C11 idempotency guard via fast raw-text scan, C12 precompiled regex as class constants, C13 `safe_ticker_component()` path-traversal hardening | Domain-agnostic improvements; W0-3/W0-4 already queued |
| NOT a fit | BC-2 (yfinance/Alpha Vantage US-only) | wrong vendor for VN |
| NOT a fit | BC-5 (Rich CLI) | Streamlit is stockforge's choice |
| NOT a fit | BC-7 (technical indicators) | standard pandas/stockstats — no novel patterns |

### 13.3 Patterns to ADOPT (Apache-2.0 with attribution)

1. **Atomic temp-file-replace (C1)** — `memory.py:109-163, 215-217`. Harness substrate. W0-3 queued.
2. **HTML-comment separator (C2)** — `memory.py:13-14`. Harness substrate. W0-4 queued.
3. **Debate-style synthesis (C3)** — `agents/researchers/{bull,bear}_researcher.py` + `agents/risk_mgmt/*_debator.py` + `conditional_logic.py:46-67`. Shared-state round-robin; each agent reads opposing argument before generating. **Theme H key evidence** (see SUPPLEMENT for debate vs isolated decision).
4. **Shared debate-state TypedDict (C4)** — `agents/utils/agent_states.py:7-43` (`InvestDebateState`, `RiskDebateState`).
5. **Structured-output schema + free-text fallback (C5)** — `agents/utils/structured.py:31-73` + `agents/schemas.py:1-228`. `invoke_structured_or_freetext` falls back to `llm.invoke(prompt)` on ANY exception so pipeline never blocks. ADR-004 records this replaces fragile prose-regex parsing.
6. **5-tier rating + heuristic parser (C6)** — `agents/utils/rating.py:18-50`. Replaces binary "buy/sell" anti-pattern.
7. **Render-back-to-markdown helper (C7)** — `agents/schemas.py:93-101, 141-163, 209-228`. Bidirectional contract: structured for code, markdown for memory log + human.
8. **Idempotency guard via fast raw-text scan (C11)** — `memory.py:41-45`. Prevents duplicate appends on retry.
9. **Precompiled regex as class constants (C12)** — `memory.py:16-17` (`_DECISION_RE`, `_REFLECTION_RE`).
10. **`safe_ticker_component()` path-traversal hardening (C13)** — `tradingagents/dataflows/utils.py` (referenced from `trading_graph.py:382-384`) + `graph/checkpointer.py:21-25`.

### 13.4 Components to PORT (Apache-2.0 with attribution)

Apache-2.0 permits LOC port. Required attribution per file:
```python
# Pattern/code adapted from TradingAgents v0.2.4 (Tauric Research, Apache-2.0)
# Original: tradingagents/<file>:<lines>
# Cite: arXiv 2412.20138 (Xiao, Sun, Luo, Wang, 2025)
```

- **C1+C2 W0-3/W0-4 substrate** — direct LOC port for harness atomic-write doctrine.
- **C5+C7 Structured-output + free-text fallback + render-back** — LOC port for BC-8 decision-agent output contract (satisfies "structured, not narrative" + I-S2 audit trail).
- **C8 Reflection / outcome resolution loop** — `graph/reflection.py:31-53` + `trading_graph.py:229-263`. **Wave-2 candidate** (calibration over confidence; needs VN return source).
- **C10 LangGraph checkpoint resume per-ticker SQLite** — `graph/checkpointer.py:1-91`. **Wave-2 candidate** (only if VN backtest depths require it).

### 13.5 Anti-Patterns to AVOID (A-13 § 7)

- **7.1 VN-overlay must NOT be displaced** — yfinance default (`default_config.py:41-45`); SPY benchmark for alpha (`trading_graph.py:206, 216-218`); US 5-day-week trading calendar implicit; no ATO/ATC, no foreign-room cap, no sàn-tier (HoSE/HNX/UPCoM), no price-band rules. **Anti-pattern**: lift data layer wholesale and reroute to VN-equivalent vendor. Lift only **orchestration shape** (graph topology, state TypedDicts, debate-state, structured output); re-author dataflows from scratch against vnstock + SSI + VND.
- **7.2 First-speaker bias** — `should_continue_debate` (`conditional_logic.py:51-55`) always starts with Bull (because `setup.py:134` edge `current_clear → "Bull Researcher"`). Biases judge's recency-window. **For symmetric 4+ perspective stockforge debate (bull/bear/quant/behavior), randomise first speaker, or rotate over runs.**
- **7.3 Token bloat from `history` accumulation** — `investment_debate_state.history` concatenated each turn (`bull:39`, `bear:41`). At 2 rounds × 2 agents × 3K-token argument = 12K history tokens before judge. **Cap rounds at design time; for I-S11 ≥4 perspectives × ≥2 rounds, design a summarisation step before judge.**
- **7.4 LLM-math creep** — structured-output schemas have `entry_price: Optional[float]` (`schemas.py:127`) and `price_target: Optional[float]` (`schemas.py:199`) — **could** be filled by LLM. **IMPL must either (a) ban these fields, or (b) require them to echo a code-computed value (no LLM arithmetic). Audit point.**
- **7.5 Reflection loop's "LLM judges past LLM"** — `Reflector.reflect_on_final_decision()` (`reflection.py:31-53`) emits 2-4 sentence "lesson". LLM judging LLM with one external grounding (return number). Don't take reflections as truth; track which reflections correlated with future correct calls. Acceptable as written; flag for Wave-2 hardening.
- **7.6 Deterministic termination ≠ consensus** — both debates terminate by round-count, not convergence/disagreement-measure. Judge forced to synthesise still-unresolved disagreement. **This is the right answer under I-S12 (don't force resolution)** — but stockforge should be explicit: judge's role is to surface tradeoffs, not adjudicate. Adapt CN-style "Avoid defaulting to hold" (research_manager.py:22-40) to stockforge framing ("surface the tradeoff, recommend a thesis exploration, not a buy/sell").

### 13.6 Risks Flagged by Deep-Dive

- **LangGraph dependency heavy** (`pyproject.toml:18-19` `langgraph>=0.4.8`, `langgraph-checkpoint-sqlite>=2.0.0`). Charter has NOT yet adopted LangGraph. **IMPL decision required.** Alternative: write StateGraph-equivalent in plain Python (~110 LOC: ~50 topology + ~20 conditional-edge + ~40 state TypedDicts). Worth empirically probing per L-S32-1.
- **Debate cost scales quadratically** with rounds × agents × history. Acceptable for stockforge single-tenant 3-5 user posture with Anthropic subscription billing.

---

## 14. TradingAgents-CN (A-14)

- **Repo**: TradingAgents-CN v1.0.1 (hsliuping) — Chinese-localised, A-share-extended derivative of upstream `TradingAgents`
- **Path**: `C:/htdocs/research/TradingAgents-CN/`
- **Primary language**: Python (LangGraph + LangChain + provider adapters; MongoDB + Redis caching; ChromaDB for agent memory)
- **License class**: **MIXED — Apache-2.0 (core `tradingagents/`, `cli/`, `scripts/`, `docs/`, `examples/`, `web/`) + Proprietary (`app/` FastAPI backend, `frontend/` Vue.js)** per `LICENSE:1-30` + `LICENSING.md`. Commercial use of proprietary parts requires `hsliup@163.com` licensing. **Pattern-adoption SAFE for both; code-port SAFE only for Apache parts with attribution.**

### 14.1 Hypothesis-vs-Empirical Fit Verdict

**CONFIRM HIGH (pattern); MEDIUM-LOW (direct code port).** A-14 § 5: pattern transfer is the high-fit path; direct code-port frequently blocked by VN/CN delta (CSRC numbers must NOT port as VN thresholds; CN regex catalogue must be reauthored for VN; Chinese sentiment lexicon must be replaced).

### 14.2 BC Mapping (A-14 § 4)

| BC | Component | File anchor | Adoption form | Priority |
|---|---|---|---|---|
| BC-1 Market Data (intraday + ATO/ATC parallel) | Provider abstraction + OHLCV with `isST`+`tradestatus` from BaoStock | `dataflows/data_source_manager.py:168,497`; `providers/china/baostock.py:577` | Schema-level (add status flags); waterfall pattern direct | HIGH |
| BC-2 Fundamentals | `fundamentals_analyst.py` + Tushare `daily_basic` (PE/PB/PE_TTM/PB_MRQ/total_mv/circ_mv/turnover_rate/volume_ratio) | `agents/analysts/fundamentals_analyst.py`; `docs/analysis/pe-pb-data-update-analysis.md:24-50` | Field-set reference (CN GAAP vs VN VAS reconciliation) — pattern only | MEDIUM |
| BC-4 Macro / Policy / News | News analyst + Chinese-finance aggregator + sentiment lexicon | `agents/analysts/news_analyst.py`; `dataflows/news/chinese_finance.py:18-60`; `providers/china/akshare.py:1497-1611` | Sentiment lexicon: ADOPT PATTERN with VN lexicon; News-aggregator: build VN equivalent | HIGH |
| BC-5 Risk Management (position sizing) | Risky/Safe/Neutral debate triad + Risk Manager judge | `agents/risk_mgmt/{aggresive,conservative,neutral}_debator.py`; `agents/managers/risk_manager.py:37-59` | Adopt triad PATTERN; respect stockforge invariant (LLM cannot override max-position size — deterministic guards in code) | HIGH |
| BC-7 Retail Sentiment / Thesis | Social media analyst + Bull/Bear debate + Memory/Reflection | `agents/analysts/social_media_analyst.py:128-157`; `agents/researchers/{bull,bear}_researcher.py`; `agents/utils/memory.py`; `graph/reflection.py` | Bull/Bear: DIRECT (VN re-localise); Memory: replace Chroma with Postgres+pgvector | HIGHEST |
| BC-8 Trading Decision / Output | Trader + Signal Processor + Research-Manager-judge | `agents/trader/trader.py:68-80`; `graph/signal_processing.py:240-336`; `agents/managers/research_manager.py:35-74` | LLM-text → regex-extracted numbers: ADOPT (matches stockforge no-LLM-math); reshape single-action output to multi-criteria matrix | HIGH |

### 14.3 Patterns to ADOPT (Apache-2.0 core only, with attribution)

1. **China Market Analyst microstructure-knowledge prompt template** (A-14 § 3.1; `agents/analysts/china_market_analyst.py:113-138`) — **prompt-template port (re-localised)**. The KNOWLEDGE pattern (enumerate market-specific microstructure inline so LLM reasons WITH them) is portable; SPECIFICS replaced with VN values per A-14 § 5.1 invariant citations:
   - 涨跌停 → VN `I-S61` sàn-tiered Trần/Sàn (HOSE ±7%, HNX ±10%, UPCoM ±15%).
   - T+1 → VN T+2.5 per `I-S55`.
   - 北向资金 → VN foreign-investor room per `I-S56`.
   - ST → VN suspension/warning per `I-S62`.
   - 退市 / 科创板 / 创业板 → VN HOSE/HNX/UPCoM per `I-S59`.
2. **Multi-perspective Bull/Bear + Risk-Triad debate framework** (A-14 § 3.2). PATTERN PORT — re-localise prompts to Vietnamese + VN-market terms.
3. **LangGraph circuit-breaker pattern** (A-14 § 3.3; `conditional_logic.py:26-29, 73, 111, 149` per-section tool-call counter caps + report-length sentinel + force-route to `Msg Clear *` terminal at lines 46-53). **Content-presence AND iteration-count bounded.** Cross-cutting; pairs with `agent-workspace/constitution/session-budgets.md`.
4. **ST / suspension data-field surfacing schema lesson** (A-14 § 3.4; `providers/china/baostock.py:577` fields `tradestatus` + `isST`) — augment VN bar table with `is_suspended: bool` + `is_under_warning: bool` columns at ingest time.
5. **Chinese sentiment lexicon PATTERN** (A-14 § 3.5; `akshare.py:1497-1521` `positive_keywords` + `negative_keywords`; `_calculate_sentiment_score` at `akshare.py:1523-1563` keyword-weight dict with score-normalisation `max(-1.0, min(1.0, score / 3.0))` at line 1563). Rule-based, deterministic, reproducible — directly satisfies I-S1 for sentiment numerics. **Content (CN keywords) NOT portable; build VN lexicon (tăng/giảm/sàn/trần/đột phá/lao dốc/đỉnh/đáy/đu đỉnh/bắt đáy/đội lái/lái/cảnh báo/đình chỉ/lỗ/lãi/...).**
6. **Reflection / past-mistakes mechanism** (A-14 § 3.8; `graph/reflection.py` + `memory.get_memories(curr_situation, n_matches=2)` at `research_manager.py:26-33` + `bear_researcher.py:80`; Research Manager prompt `research_manager.py:55-56` `"以下是您对错误的过去反思: {past_memory_str}"`). Maps onto charter Principle 8 "calibration over confidence" + `agent-workspace/calibration/`. **Replace ChromaDB with Postgres+pgvector** per `postgres-pgvector` skill.
7. **Configurable analysis-depth tiers** (A-14 § 3.9; `docs/ANALYST_DATA_CONFIGURATION.md:13-115`) — single config knob `MARKET_ANALYST_LOOKBACK_DAYS` with four named tiers (快速/标准/深度/全面). Adopt as `THESIS_DEPTH={quick,standard,deep,comprehensive}` env var or session-type-derived parameter; maps to stockforge session-type taxonomy.

### 14.4 Components to PORT (Apache-2.0 core only)

**Attribution template** (A-14 § 6.2):
```python
# Pattern adapted from TradingAgents-CN (Apache 2.0)
# Upstream: github.com/hsliuping/TradingAgents-CN (CN fork)
# Original: github.com/TauricResearch/TradingAgents
# StockForge adaptation: VN-localised for HOSE/HNX/UPCoM market structure
```

**SAFE for code port:** files in `tradingagents/`, `cli/`, `scripts/`, `docs/`, `examples/`, `web/` (Streamlit). MUST preserve copyright notice + Apache 2.0 license headers + attribution to both Tauric Research (upstream) + hsliuping (CN fork).

**MUST NOT port:** `app/` FastAPI backend, `frontend/` Vue.js — even internal use restricted to "个人评估和测试 / 教育用途（非商业）/ 内部业务评估". Stockforge uses Streamlit Phase 1 anyway, so the FastAPI proprietary layer is moot in Phase 1.

### 14.5 Anti-Patterns to AVOID — **MANDATORY (A-14 § 7)**

1. **7.1 Legal-grey signals from CN context** — unauthorised commercial mirror `tradingagents-ai.com` documented in `README.md:13-27` ("我们项目组目前没有给任何组织或个人进行过商业授权"). Do NOT associate. **v2.0.0 not open-source** (`README.md:36-39` "暂时不进行开源" due to plagiarism) — v1.0.1 is safe-to-pattern-from baseline.
2. **7.2 VN regulatory difference: SBV vs PBOC vs CSRC** — `china_market_analyst.py:118` names 中国经济政策/证监会政策 (CSRC); VN port must reference SBV monetary policy + SSC listing rules + Ministry of Finance + HSX/HNX exchange-specific circulars; VND/USD managed-float ≠ CNY managed-float; ASEAN integration — NONE in analyst prompt.
3. **7.3 CN F0 / 韭菜 retail dynamics ≠ VN F0 dynamics.** VN-specific: "đu đỉnh" (FOMO at top), "bắt đáy" (catch bottom), "lái" (manipulators), "đội lái" (pump groups). Heavy Facebook/Zalo (CN equivalent = WeChat). VN 85-90% retail share much higher than CN 50-60%. **Lexicon must be RECALIBRATED for VN retail-culture-aware keywords + DIFFERENT intensity weights.**
4. **7.4 Single-file omnibus anti-pattern** — `providers/china/akshare.py` is **1676 LOC** mixing data ingest (1-1480) + sentiment lexicon (1484-1563) + news-importance classifier (1594-1629) + news classification (1631+) + keyword extraction (1565-1592). **DO NOT port this structure.** Split per BC; each ≤300 LOC (CLAUDE.md P2 "Simplicity First").
5. **7.5 LLM-emits-numbers prompt smell** — `agents/managers/research_manager.py:44-51` instructs LLM: "📊 目标价格分析：基于所有可用报告 ... 提供全面的目标价格区间和具体价格目标 ... 您必须提供具体的目标价格 - 不要回复'无法确定'". **VIOLATES stockforge I-S1 no-LLM-math.** Partial mitigation at `signal_processing.py:240-279` (regex-extract numbers) but prompt still asks LLM to produce number. **Stockforge MUST refactor**: LLM reasons about RANGES, CATALYSTS, SCENARIOS — deterministic price-derivation step (DCF, P/E multiple from sector median, P/B multiple) emits final numeric. **Anti-pattern to NOT inherit.**
6. **7.6 ChromaDB on Windows quirks** — `agents/utils/memory.py:36-50` has Windows 11 special-case branch + 3 layered fallbacks. ChromaDB fragile on Windows. Stockforge uses Postgres+pgvector — sidestep entirely.
7. **7.7 Hard-coded English-only company-name lookups** — `china_market_analyst.py:67-79` 8-stock English→Chinese map duplicated across ~6 files (`bull:60-66`, `bear:59-65`, `social:69-82`, `fundamentals:76-79`, `news:73-86`). Extract into shared `stock_name_resolver` utility from the start.
8. **7.8 Cross-language sentiment intensity not validated** — keyword-weight scheme (`akshare.py:1537-1548`) gives 涨停=1.0, 暴涨=0.9 etc. — NOT validated against labelled corpus; hand-tuned. **Build small labelled VN corpus (200-500 articles) and CALIBRATE lexicon weights FROM DATA, not intuition** (charter Principle 8).
9. **7.9 Implicit ticker-shape assumption** — `utils/stock_utils.py:43-52` regex `^\d{6}$` for A-share, `^\d{4,5}\.HK$` for HK, `^[A-Z]{1,5}$` for US. VN: `^[A-Z]{3}$`. Centralise ticker-shape detection.
10. **7.10 Risk-debate triad does NOT bind risk caps** — `agents/risk_mgmt/{aggresive,conservative,neutral}_debator.py` produces reasoning; **no deterministic guard prevents recommendation from violating position-size cap.** **Stockforge MUST add post-judge deterministic gate that REJECTS any recommendation violating `max_position_size_pct`, `sector_concentration_pct`, `stop_loss_pct`** (charter hard rule). Citation chain: VN trader signals → triad debate → judge → deterministic-risk-gate → output.
11. **7.11 Single max_debate_rounds=1 may be too shallow** — `default_config.py:18-19`. Calibrate empirically with stockforge token-budget rules.
12. **7.12 Documentation drift signal** — some docs dated 20251011 AFTER `LICENSING.md` 2025年10月 — rapid iteration; **pin to specific commit hash if porting code.**

### 14.6 Risks Flagged by Deep-Dive

- Mixed license (Apache + Proprietary) — code-port boundary discipline mandatory; do NOT inspect `app/` or `frontend/` for code-port purposes.
- VN regulatory delta — CN ST/*ST/退市 ≠ VN cảnh báo/kiểm soát/hạn chế/đình chỉ/hủy niêm yết; different price-limit consequences, different tiered thresholds, different "consecutive 2 years loss + revenue < threshold" thresholds (Decree 155/2020).

---

## 15. Vibe-Trading (A-15)

- **Repo**: `Vibe-Trading` (HKUDS — Hong Kong University Data Science group), v0.1.6 published on PyPI as `vibe-trading-ai`
- **Path**: `C:/htdocs/research/Vibe-Trading/`
- **Primary language**: Python ≥3.11; LangChain/LangGraph + FastAPI 0.104+ + React 19 + Vite frontend; MCP server via `fastmcp`; SQLite/FTS5 for persistent memory
- **License class**: **MIT** (`LICENSE:1-2`, `pyproject.toml:6`; Copyright (c) 2026 Vibe-Trading Contributors). Permissive — attribution requirement: preserve copyright + permission notice in any ported file.

### 15.1 Hypothesis-vs-Empirical Fit Verdict

**CONFIRM HIGH.** A-15 § 5: Vibe-Trading is the most directly applicable A-share-domain repo (closer than US 13F/10-K/10-Q which are disclosure not status-flagging; closer than TradingAgents-CN on path-safety substrate).

**Reconfirmed harvest source (A-15 § 0):**
- **W0-5 path-safety quad** — 4 public helpers in `agent/src/tools/path_utils.py` (213 LOC total):
  - **P1 `safe_path(p, workdir)`** at `path_utils.py:33-54` — tool-controlled sandbox; caller-supplied `workdir` arg; rejects `..`-escape + UNC.
  - **P2 `safe_user_path(p)`** at `path_utils.py:158-171` — user-supplied broker/import files; allowed import roots (NOT whole $HOME).
  - **P3 `safe_document_path(p)`** at `path_utils.py:174-187` — document-reader inputs; same allowed-roots as P2.
  - **P4 `safe_run_dir(p)`** at `path_utils.py:190-213` — generated-code/backtest run dirs; separate root list.
  - **Shared `_rejects_unc(p)`** at `path_utils.py:27-30` — cross-cutting **fifth invariant** (UNC `\\…` + POSIX `//…` pre-rejected before any root check).
  - Tests at `agent/tests/test_path_safety.py` (136 LOC) cover all four + UNC + traversal.
- **Pre-ST filter hardening** — `agent/src/skills/ashare-pre-st-filter/SKILL.md` (514 LOC) + `scripts/fetch_sina_penalties.py` (627 LOC). PR #63 + follow-up hardening per `docs/2026-04-30_session01_pr63_ashare_pre_st_filter_hardening.md` (32 LOC). Subject-weighted frequency rule at `SKILL.md:264-295` (`subject_normalized ∈ {company=1.0, shareholder=0.5, officer=0.5}`).

### 15.2 BC Mapping (A-15 § 4)

| BC | Component | Why this BC |
|----|-----------|-------------|
| **BC-0 / harness substrate** | C1 path-safety quad (Theme F W0-5) | 4 helpers are tool-infrastructure for agent itself — gates read/write/edit/backtest/doc_reader/trade_journal/shadow_account tools |
| **BC-1 (Fundamentals + Ingest)** | C2 Pre-ST filter, C3 worst-of-two test, C4 dividend dedup, C5 mech-annualisation, C10 loader-registry, C12 scraper template | All depend on raw FS + regulatory-action ingest; direct VN parallel = HOSE/HNX/UPCoM listing-status check + cảnh báo/kiểm soát rules |
| **BC-9 (Risk + Backtest)** | C2 Pre-ST (ST/退市 = high-severity risk signal), C6 BaseEngine, C7 fee-table, C8 optimizers, C9 validation pipeline | Backtest engine + statistical-validation directly serves Charter Month-12 alpha vs VN-Index |
| BC-8 (Calibration) | C9 (validation outputs → calibration ledger), C5 (confidence-tier explicit rule) | Calibration needs Monte Carlo p-values + Bootstrap Sharpe CI to give "high/medium/low confidence" non-vacuous meaning |

Theme F (W0-5 path-safety) is the **only** substrate-layer harvest from this repo; everything else (C2-C12) is product-layer BC-1 / BC-9.

### 15.3 Patterns to ADOPT (MIT with attribution header `# Adapted from Vibe-Trading (HKUDS/Vibe-Trading, MIT-licensed, 2026)`)

1. **C1 Path-safety quad** — Theme F W0-5 (`agent/src/tools/path_utils.py:1-213`). **Code-port S effort (3-5h)**: rename `VIBE_TRADING_ALLOWED_*` → `STOCKFORGE_ALLOWED_*`; adapt default-root list to stockforge layout. Replicate test surface 1:1 from `agent/tests/test_path_safety.py:1-136`.
2. **C3 `min(n_income, profit_dedt)` worst-of-two test** — `SKILL.md:118, 145-146, 197-212`. Concept-port as I-S62-1 sub-rule "VN ST check must use worst-of EPS and EPS-ex-extraordinary".
3. **C5 Mechanical-annualisation block-rule** — `SKILL.md:138-139`. Forbid H1×2 / Q1Q3×(4/3); explicit `confidence=low` enforcement when violated. Concept-port as I-S62 sub-rule + decorator on forecasting functions.
4. **C6 BaseEngine market-rule interface** — `agent/backtest/engines/base.py:138-217`. Abstract `can_execute / round_size / calc_commission / apply_slippage / on_bar`. Code-port for `VnEquityEngine` subclass (T+2.5, ±7% HOSE/±10% HNX, lot=100, fees per VN brokerage table).
5. **C8 Optimizer plugin slot** — `agent/backtest/optimizers/` (4 weighting schemes: equal_volatility, risk_parity, mean_variance, max_diversification). Pure NumPy/scipy — code-port all 4 modules.
6. **C9 Validation pipeline (Monte Carlo permutation + Bootstrap Sharpe CI + Walk-Forward)** — `agent/backtest/validation.py:1-200+`. **Critical for Charter Month-12 success criterion ("demonstrable alpha vs VN-Index") — without statistical-validation the alpha claim is empty.** Net-new theme candidate (see SUPPLEMENT § "Refined Wave-1 IMPL Allocation").
7. **C10 Loader registry with declared fallback chains** — `agent/backtest/loaders/registry.py` + `runner.py:28-34` (`FALLBACK_CHAINS`, `LOADER_REGISTRY`, `get_loader_cls_with_fallback`). 6 data sources declared. Pattern-port: VN equivalent = `vnstock → SSI direct httpx → cafef CSV → cached snapshot`. Maps to VN `I-S65 Source-Fallback Chain Order`.
8. **C11 Skill-as-markdown loader** — `agent/src/skills/<name>/SKILL.md` frontmatter + body + `scripts/` trio. Already partly aligned with stockforge `.claude/skills/`; verify SKILL invokes `python scripts/foo.py` pattern.
9. **C12 GBK-decode + SSRF-guard scraper template** — `fetch_sina_penalties.py:1-50`. Allowed-host whitelist + throttle + exponential backoff + structured JSON failure on stdout (NEVER raise traceback). Idempotent failure-mode contract `{"source": "unavailable", "error": "..."}` to stdout + nonzero exit.

### 15.4 Components to PORT (MIT with attribution)

- **C1 Path-safety quad** — direct LOC port for W0-5 (4 helpers + UNC guard + tests). S effort.
- **C2 Pre-ST filter logic** — **Pattern-port + VN rule research session FIRST.** Subject-normalisation regex catalogue (`fetch_sina_penalties.py:70-90`) is Chinese; reimplement for VN with vietnamese keyword list. CSRC numeric thresholds (`SKILL.md:88-91` 营收<3亿/1亿, 市值<5亿/3亿, dividend 5000万/3000万) **MUST NOT** be copied as VN thresholds — confirm VN-equivalent via Decree 155/2020 + UBCKNN guidance + exchange listing rules.
- **C4 Dividend-deduplication 3-tuple `(end_date, ann_date, cash_div_tax)`** — `SKILL.md:62, 168-180`. Anti-triple-count from 预案/股东大会通过/实施 lifecycle. VN parallel = ResolutionDate/RecordDate/ExecutionDate — same triple-count bug exists. Code-port S effort.
- **C7 A-share fee table as VN-fee-table template** — `agent/backtest/engines/china_a.py:31-38`. Pattern-port: config-key + `apply_slippage`/`calc_commission` shape; VN fees materially different.

### 15.5 Anti-Patterns to AVOID (A-15 § 7)

1. **DO NOT copy CSRC numeric thresholds** in `SKILL.md:88-91` as VN thresholds. Re-research VN HOSE/HNX/UPCoM thresholds (Decree 155/2020 + UBCKNN + exchange rules) before any port.
2. **DO NOT treat ST/*ST and "cảnh báo/kiểm soát" as semantically equivalent.** State machines differ; agent maps VN → A-share severity tier explicitly, not assume parallel.
3. **DO NOT copy R3 dividend rule** ("近三年累计现金分红 < 30% 年均净利润 且 < 板块阈值") as hard delisting predictor for VN. Demote to quality-signal.
4. **DO NOT skip `--stock-name`/`target_relevance` filtering** when porting C2 — un-hardened version had systematic over-count failure mode (any individual whose brokerage-account trade list mentioned target stock would inflate E2 frequency). VN news-scrapers will have **same class of failure mode** (any KOL article mentioning stock will be over-counted).
5. **DO NOT over-fit backtest patterns to A-share data.** Charter Month-12 alpha-vs-VN-Index criterion is for VN data; A-share data is for engine-architecture template only, not parameter tuning.
6. **DO NOT copy docstring-out-of-date pattern** (`path_utils.py:1-16` claims "three helpers" but ships four — maintenance smell). Refresh docstring to "four helpers, four threat models" + name UNC guard as fifth shared invariant.
7. **DO NOT skip path-safety tests** when porting C1. Replicate `agent/tests/test_path_safety.py:1-136` test surface 1:1 — path-safety is exactly the kind of feature where the test is the contract.
8. **DO NOT rely on Vietnamese onboarding docs as authoritative semantics.** `docs/onboarding/02-HLD.md` + `12-ONBOARDING-TRACK.md` are in Vietnamese — one contributor's learning notes; canonical contract is code + English `README.md` + `SKILL.md` files.
9. **DO NOT bundle C2 (pre-ST skill) into Phase A direct-IMPL** without VN-rule research session first. CSRC → UBCKNN rule mapping is non-trivial.
10. **DO NOT port the MCP server pattern + `fastmcp` dependency naively.** Stockforge has Claude-subagent dispatch (per `anthropic_api_to_subagent` rule); adding MCP layer is gold-plating unless explicitly requested.

### 15.6 Risks Flagged by Deep-Dive

- A-share microstructure assumptions (e.g. price-limit-up = unable-to-buy in `china_a.py:67-69`) directly applicable to VN, **but** VN has additional ATO/ATC sessions (open + close auctions) not modelled in A-share engine — adopting C6 needs VN-microstructure delta.
- Over-fitting to A-share regime: patterns tuned on A-share 2015-2024 (regime-rich) may not generalise to VN 2024-2026. C9 validation pipeline mitigates but does not eliminate.

---

## 16. License-Class Matrix — quick reference

| License class | Repos | LOC-port? | Pattern-port? | Attribution form |
|---|---|---|---|---|
| Apache-2.0 (clean) | nautilus_trader docs cite + TradingAgents + Pixelle-Video | YES with attribution + NOTICE | YES | per-file header + NOTICE root |
| Apache-2.0 + Attribution clause (extra) | crawl4ai | YES with NOTICE file at stockforge root + per-file header | YES | NOTICE file mandatory |
| Apache-2.0 mixed with Proprietary | TradingAgents-CN (core Apache; `app/` + `frontend/` Proprietary) | YES for core files only | YES | per-file header citing both Tauric Research + hsliuping |
| MIT (clean) | MoneyPrinterTurbo + Vibe-Trading + (NarratoAI Modified-MIT non-commercial-only — pattern only) | YES with attribution (Turbo/Vibe); NO for NarratoAI | YES | per-file header + license-text inclusion |
| MIT (declared, file missing) | ai-hedge-fund + dexter | DEFER until verified | YES | per-file header + verify upstream before LOC-port |
| BSD-3-Clause | Scrapling | YES with attribution | YES | per-file header `# Adapted from Scrapling (BSD-3-Clause)...` |
| LGPL-3.0 | nautilus_trader | NO direct LOC-vendoring (LGPL § triggers source-availability); pip-install OK | YES | per-file header citing source path:line |
| GPL-3.0 | MoneyPrinterPlus | NO (copyleft viral) | clean-room rewrite if pattern needed | clean-room note |
| AGPL-3.0 | MoneyPrinterV2 | NO (network-service clause viral) | clean-room rewrite if pattern needed | clean-room note |
| AGPL-3.0 + Commercial-required | FinceptTerminal | NO (USD 10,200/yr otherwise) | YES (pattern-only, ZERO LITERAL LOC) | "Pattern inspired by FinceptTerminal — AGPL-3.0. No code imported." |
| Modified MIT — Non-Commercial Only | NarratoAI | NO (commercial-prohibited; eliminates revenue-product path) | YES if non-commercial use defensible | attribution + license-text |
| Non-Commercial Learning License 1.1 (NOT OSI) | MediaCrawler | NO (commercial-prohibited; "no large-scale crawling") | YES via clean-room re-derive | attribution NOT sufficient; clean-room mandated |

---

## 17. Cross-Repo Quick Recommendations (per-BC)

| BC | First-choice repo + pattern | Backup |
|---|---|---|
| BC-1 Market Data | nautilus_trader Clock + FSM patterns (W0-2 already; risk + backtest blueprint Wave 2+) | Vibe-Trading `BaseEngine` (Theme N candidate) |
| BC-2 Fundamentals | TradingAgents-CN `fundamentals_analyst.py` field-set reference (CN GAAP vs VN VAS reconciliation) | Vibe-Trading C2 Pre-ST filter pattern (after VN rule research) |
| BC-3 Reports/PDF | crawl4ai `PDFContentScrapingStrategy` strategy-shape | LLM-vision custom adapter |
| BC-4 Macro/Policy | (none directly; SBV/government data via direct CSV/Excel pulls per VN ecosystem) | TradingAgents-CN news analyst + sentiment lexicon PATTERN |
| BC-5 News Stream | crawl4ai `DefaultMarkdownGenerator` + `PruningContentFilter` + `CacheValidator` + Scrapling adaptive selector + `RateLimiter` + `RobotsTxtManager` | TradingAgents-CN news-aggregator pattern |
| BC-6 Influence | YouTube official Data API v3 + yt-dlp (canonical); MediaCrawler CDP-consented pattern for FB | Scrapling `find_similar` + adaptive selector for layout drift |
| BC-7 Crowd | Scrapling `find_similar` + spider framework (BC-7 forum thread listings) | MediaCrawler comment-tree walker PATTERN (clean-room) |
| BC-8 Analysis & Thesis | TradingAgents debate-style + structured-output schema + ai-hedge-fund per-perspective dataclass contract + plugin registry | dexter compaction prompt (Numerical Data section) + TradingAgents-CN microstructure prompt-template adaptation |
| BC-9 Portfolio & Action | nautilus_trader risk-engine deterministic-rules pattern (Wave 2+) + ai-hedge-fund pre-validated allowed-actions + vol-adjusted position-limit | Vibe-Trading BaseEngine subclass + optimizer plugin slot + validation pipeline (Theme N candidate) |
| Harness substrate | nautilus_trader Clock + FSM (W0-1/2 done; W0-2.1 pending mechanical fix) + TradingAgents atomic write (W0-3) + TradingAgents HTML separator (W0-4) + Vibe-Trading path-safety quad (W0-5) | ai-hedge-fund onboarding-docs scaffold (concept only) |

---

## 18. Compliance Attestation (this proposal)

- ✅ I-S1 NO LLM math — every numeric value comes from a deep-dive citation chain (no LLM-computed numbers).
- ✅ I-S2 every claim sourced — every architectural recommendation cites the deep-dive section + repo file:line (provenance chain in each § per-repo block).
- ✅ I-S35 research-aid framing — no "buy/sell/recommendation" language in this proposal; consistent thesis-exploration framing.
- ✅ I-S10 + I-S11 + I-S12 (adversarial + ≥2-perspective + disagreement surfaced) — Theme H synthesis (cross-repo, in SUPPLEMENT) preserves multi-perspective primitives.
- ✅ License-rules honored — AGPL/proprietary/non-OSI repos are pattern-only with ZERO LITERAL LOC; LGPL recommends pip-install or re-implementation from architectural shape; Apache/MIT/BSD permitted LOC port with attribution.
- ✅ Honest demotions surfaced — FinceptTerminal MEDIUM→LOW, MediaCrawler HIGH→MEDIUM-LOW, Scrapling stealth-submodule HARD-REJECT.
- ✅ Honest promotions surfaced — Vibe-Trading `validation.py` Monte Carlo + Bootstrap + Walk-Forward → candidate Theme N (deferred past Wave 1; explicit in SUPPLEMENT).
- ✅ NO commits, NO push, NO git operations performed by this dispatch.
- ✅ NO charter edits, NO constitution writes, NO human-workspace writes performed.

End of `INTEGRATION_PROPOSAL_2026-05-15.md` per-repo synthesis. Cross-repo theme synthesis is in `INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md`.
