---
observation_id: master-planner-A-15-deepdive-Vibe-Trading
session: S323-A-phase-a-deepdive
agent: general-purpose
date: 2026-05-15
repo: Vibe-Trading
repo_path: C:/htdocs/research/Vibe-Trading/
fit_level_hypothesis: HIGH
fit_level_empirical: HIGH (confirmed — W0-5 quad source confirmed + pre-ST filter pattern transferable to VN)
license: MIT (root `LICENSE:1`, `pyproject.toml:6` `license = "MIT"`)
prior_harvest: (deferred substrate; nothing shipped — W0-5 pending)
pending_harvest: W0-5 path-safety quad (4 patterns)
---

## 0. Lost S259 reconstruction

S259's `general-purpose-S259-deepdive-Vibe-Trading.md` was not recoverable on disk in `agent-workspace/memory/observations/` (no file present with that name; cross-checked by `glob master-planner-A-*deepdive*` finding 14 sibling files but no S259 Vibe-Trading entry). This observation re-derives the same claims by reading source directly. The findings claimed in master-plan § 4.15 (W0-5 path-safety quad + pre-ST filter hardening) are **both confirmed**.

### W0-5 path-safety quad — RECONFIRMED in source

The "quad" is a 4-public-helper API in **one module**, `agent/src/tools/path_utils.py` (213 LOC total). The helpers are **distinct by threat model**:

| # | Helper | Threat model | Source | Allowed roots | Call sites |
|---|--------|--------------|--------|---------------|------------|
| **P1** | `safe_path(p, workdir)` | Tool-controlled sandbox; `p` must resolve under a caller-supplied `workdir`; rejects `..`-escape + UNC | `path_utils.py:33-54` | Caller-supplied `workdir` arg | `read_file_tool.py:67`, `write_file_tool.py:51`, `edit_file_tool.py:53` |
| **P2** | `safe_user_path(p)` | User-supplied broker/import files; rejects anything outside explicit import roots (NOT the whole `$HOME`) | `path_utils.py:158-171` | `_default_file_roots()` (`agent/uploads`, `agent/runs`, `cwd/uploads`, `cwd/data`, `~/.vibe-trading/uploads`, `~/.vibe-trading/imports`) + `VIBE_TRADING_ALLOWED_FILE_ROOTS` env (`path_utils.py:75-87`) | `trade_journal_tool.py:411`, `shadow_account_tool.py:51, 94` |
| **P3** | `safe_document_path(p)` | Document-reader inputs; same allowed-roots set as P2 (shares `_safe_import_path` helper) — declared as a *separate* function so the threat model is intent-tagged at call site | `path_utils.py:174-187` | Same as P2 | `doc_reader_tool.py:272` |
| **P4** | `safe_run_dir(p)` | Generated-code / backtest run directories; separate root list from P2/P3 (a "run" directory is allowed to be wider — `agent/runs`, `cwd/runs`, `~/.vibe-trading/shadow_runs`) + `VIBE_TRADING_ALLOWED_RUN_ROOTS` env | `path_utils.py:190-213` + `_default_run_roots()` `path_utils.py:90-99` | Default run roots + env override | `backtest_tool.py:23`, `pattern_tool.py:318`, `edit_file_tool.py:52`, `write_file_tool.py:50`, `read_file_tool.py:47` |

Shared infrastructure: `_rejects_unc(p)` (`path_utils.py:27-30`) is the cross-cutting **fifth invariant** — UNC `\\…` and POSIX `//…` share-prefix paths are pre-rejected before any root check. This is the trick that makes the four public helpers a true "quad" rather than five disparate functions: every helper passes through `_rejects_unc` first.

Module docstring (`path_utils.py:1-16`) explicitly enumerates "three helpers, three threat models" — the doc was written before P4 (`safe_run_dir`) was added in PR #43 ("Relative `run_dir` normalized to active run dir", `README.md:66`); the doc is stale, the code surface is **four public helpers**. Test coverage in `agent/tests/test_path_safety.py` (136 LOC) covers all four publicly + the UNC + traversal cases.

### Pre-ST filter hardening — RECONFIRMED

`docs/2026-04-30_session01_pr63_ashare_pre_st_filter_hardening.md` (32 LOC) documents PR #63 (`feat(skill): add ashare pre-ST filter`) + a follow-up hardening commit. The implementation lives in `agent/src/skills/ashare-pre-st-filter/` (`SKILL.md` 514 LOC + `scripts/fetch_sina_penalties.py` 627 LOC). The hardening claim — that the Sina-penalty scraper must accept `--stock-name` and tag each record with `target_relevance`/`e2_countable`/`relevance_reason` to exclude "the target stock appeared in some unrelated individual's brokerage-account trade list" mentions from E2 frequency counts — is concretely realised in `SKILL.md:257` ("相关性铁律") and the `--stock-name` arg + `target_relevance=security_mention_only` flag mentioned in the hardening doc lines 19-20.

The deeper, non-obvious win in this skill is the **subject-weighted frequency rule** (`SKILL.md:264-295`): regulatory penalties are weighted by `subject_normalized ∈ {company=1.0, shareholder=0.5, officer=0.5}` before the threshold table is applied. The rationale (`SKILL.md:275`): "shareholder de-stacking + director short-swing trade = personal compliance, not corporate-governance failure". A naive per-row count would systematically over-rate companies with active-shareholder dynamics. This is **directly transferable** to the VN parallel I-S62 (ST suspension semantics) — see § 4.

### Other patterns observed beyond master-plan § 4.15

- **A-share backtest engine** (`agent/backtest/engines/china_a.py:1-148`) — concrete encoding of T+1 + ±10%/±20%/±5% price limits + 100-share lot + commission/stamp-tax/transfer-fee fee structure. Master-plan A-15 hypothesis only listed "A-share backtest engine specifics" as a Month-12 candidate; the actual engine is more compact (148 LOC subclass over a 621-LOC `BaseEngine`) than expected.
- **`BaseEngine` plugin pattern** (`agent/backtest/engines/base.py:138-217`) — abstract market-rule interface (`can_execute` / `round_size` / `calc_commission` / `apply_slippage` / `on_bar`) with 8 concrete subclasses (china_a, china_futures, composite, crypto, forex, futures_base, global_equity, global_futures, options_portfolio). Cleaner than nautilus_trader's bigger surface.
- **Subject-normalisation regex catalogue** (`fetch_sina_penalties.py:70-90`) — Chinese-text NER fallback for company-officer / shareholder / company distinction without needing an LLM. Pattern-only transferable; VN text would need its own catalogue.

## 1. Repo Summary

Vibe-Trading is "AI-powered multi-agent finance workspace" — natural-language → backtest + strategy + research over A-share / HK / US / crypto / futures / forex (`README.md:9-30, 85-95`). Stack: Python ≥3.11 (`pyproject.toml:5`), LangChain/LangGraph for agent loop (`pyproject.toml:22-26`), FastAPI 0.104+ for HTTP (`pyproject.toml:48-49`), React 19 + Vite frontend, MCP server via `fastmcp`, SQLite/FTS5 for persistent memory, MIT licensed (`LICENSE:1`). Scale: 73 skills, 7 backtest engines, 29 swarm presets, 27 tools, 13 LLM providers (`README.md:22-25, 89-95`). Single-package CLI entry-point `vibe-trading` ships on PyPI as `vibe-trading-ai==0.1.6`.

Two surfaces: (a) interactive CLI/TUI via `prompt_toolkit` (`README.md:54`); (b) FastAPI server + React SPA on `:8899` bound to `127.0.0.1` by default (`docs/onboarding/12-ONBOARDING-TRACK.md:61`). Onboarding docs in `docs/onboarding/` are unusually rich for a hobby/research repo — 12-file structured doc set including HLD/LLD/ADR-log/sequence-diagrams/glossary, fully in **Vietnamese** (`docs/onboarding/12-ONBOARDING-TRACK.md:1`, `02-HLD.md:1` — Vietnamese narrative); this is an outlier among the 14 reference repos surveyed and suggests the contributor maintains them for personal learning, not for upstream contributors.

Roadmap (per `README.md:56`) emphasises: Research Autopilot, Data Bridge, Options Lab, Portfolio Studio, Alpha Zoo, Research Delivery, Trust Layer. Security hardening landed 2026-05-03 (`README.md:55`) — default API auth for non-local, path-containment in `safe_path`, gated shell tools, non-root Docker user, localhost-only published port — these are the *same* hardening practices StockForge needs.

## 2. Architecture / Design Patterns

1. **C4-layered, FastAPI + ReAct agent loop** (`docs/onboarding/02-HLD.md:39-83`) — 5 containers: FastAPI (`:8899`) / Agent Loop (max-50-iter ReAct) / Swarm Runtime (ThreadPool DAG of agents) / Session Service (SQLite WAL + FTS5) / React SPA. Communication: HTTP REST + SSE (server-sent events for streaming).
2. **Plugin-based tool registry** (`agent/src/tools/` — 27 files, one per tool; auto-discovered). Same pattern as ai-hedge-fund (A-01) and nautilus_trader analyst registry.
3. **Skill-as-markdown** (`agent/src/skills/<name>/SKILL.md` + scripts/) — every skill has a frontmatter (`name`, `description`, `category`) + Markdown contract + optional `scripts/` directory; loaded by `load_skill_tool.py`. 73 skills total; `ashare-pre-st-filter` is one. **Same pattern as ai-hedge-fund and StockForge's own `.claude/skills/` substrate**.
4. **BaseEngine + market-rule interface** (`agent/backtest/engines/base.py:138-217`) — abstract `can_execute / round_size / calc_commission / apply_slippage / on_bar` overrides per market. Bar-by-bar execution loop in base; **8 market engines** subclass it (`engines/__init__.py` lists china_a, china_futures, composite, crypto, forex, futures_base, global_equity, global_futures, options_portfolio).
5. **Loader registry with auto-fallback** (`agent/backtest/loaders/registry.py` + `runner.py:28-34` `FALLBACK_CHAINS, LOADER_REGISTRY, get_loader_cls_with_fallback`) — 6 data sources (tushare/akshare/yfinance/ccxt/okx/futu) with declared fallback chains; `source="auto"` routes by symbol prefix.
6. **Validation as a separate concern, not entangled in engine** (`agent/backtest/validation.py:1-15`) — Monte Carlo permutation, Bootstrap Sharpe CI, Walk-Forward analysis are 3 independent functions called only if `config["validation"]` is present.
7. **Optimizer plugin slot** (`agent/backtest/optimizers/__init__.py:1-10`) — 4 weighting schemes: equal_volatility, risk_parity, mean_variance, max_diversification. Each in its own module exposing `optimize(ret, pos, dates, **kwargs)`. Loaded dynamically by name in `_load_optimizer` (`engines/base.py:114-132`).
8. **Pydantic-validated runner config** (`agent/backtest/runner.py:43-80`) — `BacktestConfigSchema(BaseModel)` validates `codes`/`start_date`/`end_date`/`source`/`interval`/`engine` before execution.
9. **Path-safety quad as security boundary** (see § 0) — *the* architectural feature most reusable for StockForge.

## 3. Components / Features candidate for StockForge adoption

| # | Candidate | Source | BC | Transfer-shape | Effort |
|---|-----------|--------|----|-----------------|--------|
| C1 | **Path-safety quad** (P1-P4 + UNC reject) — Theme F W0-5 | `agent/src/tools/path_utils.py:1-213` | harness-substrate (BC-0) | **Code-port** (rename `VIBE_TRADING_ALLOWED_*` → `STOCKFORGE_ALLOWED_*`; adapt default-root list to StockForge layout) | S (3-5h: port + 4 helpers + UNC guard + ~10 tests) |
| C2 | **Pre-ST filter logic + subject-weighted frequency rule** | `agent/src/skills/ashare-pre-st-filter/SKILL.md:264-295` + `scripts/fetch_sina_penalties.py:70-90` | BC-1 + BC-9 | **Pattern-port** (subject-normalisation regex catalogue is Chinese; reimplement for VN with vietnamese keyword list); confirm VN-equivalent of "consecutive 2 years loss + revenue < threshold" disclosure (HOSE/HNX/UPCoM rules differ from CSRC) | M (1-2d: skill + scraper + VN rule research) |
| C3 | **`min(n_income, profit_dedt)` worst-of-two test** (R1 R4 触线判定 — protects against "造壳公司" via 扣非 = non-recurring-stripped profit) | `SKILL.md:118, 145-146, 197-212` | BC-1 (fundamentals) | **Concept-port**: codify as I-S62-1 sub-rule "VN ST check must use worst-of EPS and EPS-ex-extraordinary" | XS (rule-doc only) |
| C4 | **Dividend-deduplication 3-tuple `(end_date, ann_date, cash_div_tax)`** (anti-triple-count from 预案/股东大会通过/实施 lifecycle) | `SKILL.md:62, 168-180` | BC-1 (dividend analysis) | **Code-port**: VN parallel = ResolutionDate/RecordDate/ExecutionDate triple — same triple-count bug exists | S (3-5h) |
| C5 | **Mechanical-annualisation block-rule** (forbid H1×2 / Q1Q3×(4/3)) — explicit `confidence=low` enforcement when violated | `SKILL.md:138-139` | BC-1 | **Concept-port** as I-S62 sub-rule + decorator on forecasting functions | XS (rule-doc + assertion helper) |
| C6 | **BaseEngine market-rule interface** | `agent/backtest/engines/base.py:138-217` | BC-9 (backtest engine — Month-12 goal) | **Code-port** as abstract class; implement `VnEquityEngine` subclass with VN rules (T+2.5, ±7% HOSE/±10% HNX, lot=100, fees per VN brokerage table) | M (1-2d for base + VN subclass) |
| C7 | **A-share fee table as VN-fee-table template** | `agent/backtest/engines/china_a.py:31-38` | BC-9 | **Pattern-port**: replicate the config-key + `apply_slippage`/`calc_commission` shape; VN fees materially different | XS (3h once C6 done) |
| C8 | **Optimizer plugin slot** (4 weighting schemes; dynamic import) | `agent/backtest/optimizers/` | BC-9 | **Code-port** all 4 modules (`equal_volatility`, `risk_parity`, `mean_variance`, `max_diversification`) — pure NumPy/scipy, no market-specific logic | S (4-6h) |
| C9 | **Validation pipeline (Monte Carlo permutation + Bootstrap Sharpe CI + Walk-Forward)** | `agent/backtest/validation.py:1-200+` | BC-9 + BC-8 (calibration tie-in) | **Code-port**: critical for Charter Month-12 success criterion ("demonstrable alpha vs VN-Index") — without statistical-validation the alpha claim is empty | M (1d) |
| C10 | **Loader registry with declared fallback chains** | `agent/backtest/loaders/registry.py` + `runner.py:28-34` | BC-1 (data ingest) | **Pattern-port**: VN equivalent = vnstock primary + SSI direct httpx + cafef scraping; register fallback chain `vnstock → SSI direct → cafef CSV → cached snapshot` | S (4-6h) |
| C11 | **Skill-as-markdown loader** (frontmatter + body + scripts/ trio) | `agent/src/skills/<name>/SKILL.md` + frontmatter at line 1-5 | harness-substrate | **Concept-port**: already partly aligned with StockForge `.claude/skills/`; cross-check that StockForge can call the script-as-tool pattern (e.g. SKILL invokes `python scripts/foo.py`) | XS (verify only) |
| C12 | **GBK-decode + SSRF-guard scraper template** (allowed-host whitelist + throttle + exponential backoff + structured JSON failure on stdout — never raise traceback) | `fetch_sina_penalties.py:1-50` | BC-1 (crawler) | **Pattern-port**: VN-news (cafef/vietstock) scrapers should follow same idempotent failure-mode contract (`{"source": "unavailable", "error": "..."}` to stdout + nonzero exit) | S (3-5h) |

## 4. Per-BC Mapping

| BC | Component | Why this BC |
|----|-----------|-------------|
| **BC-0 / harness-substrate** | C1 path-safety quad (Theme F W0-5) | The 4 helpers are tool-infrastructure for the agent itself — gates the `read_file`/`write_file`/`edit_file`/`backtest`/`doc_reader`/`trade_journal`/`shadow_account` tools (see § 0 call-sites). Substrate, not product. |
| **BC-1 (Fundamentals + Ingest)** | C2 Pre-ST filter, C3 worst-of-two test, C4 dividend dedup, C5 mech-annualisation, C10 loader-registry, C12 scraper template | All depend on raw financial-statement + regulatory-action ingest. Pre-ST filter is the canonical example: pulls income/balancesheet/cashflow/fina_indicator/forecast/express/dividend + regulatory penalty page + computes 4 quantitative red lines + 3 fact red flags. Direct VN parallel = HOSE/HNX/UPCoM listing-status check + cảnh báo / kiểm soát rules. |
| **BC-9 (Risk + Backtest)** | C2 Pre-ST (ST/退市 = high-severity risk signal), C6 BaseEngine, C7 fee-table, C8 optimizers, C9 validation pipeline | Backtest engine + statistical-validation directly serves Charter Month-12 success criterion "demonstrable alpha vs VN-Index on dogfood portfolio". |
| BC-8 (Calibration) | C9 (validation outputs feed calibration ledger), C5 (confidence-tier explicit rule) | Calibration needs Monte Carlo p-values + Bootstrap Sharpe CI to give "high/medium/low confidence" non-vacuous meaning. |

Theme F (W0-5 path-safety quad) is the **only** substrate-layer harvest from this repo; everything else (C2-C12) is product-layer BC-1 / BC-9.

## 5. Honest Fit Assessment

**Fit: HIGH (confirmed).** Vibe-Trading is the most directly applicable A-share-domain repo in the survey because (a) A-share ST/*ST regulatory framework is structurally closest to VN HOSE cảnh báo / kiểm soát / hạn chế giao dịch / hủy niêm yết tiered system among the 14 reference repos surveyed (closer than US 13F / 10-K / 10-Q which are disclosure not status-flagging); (b) T+1 + ±10% price limits + lot=100 are *almost* identical to VN T+2.5 + ±7%/±10% + lot=100; (c) the path-safety quad is market-agnostic harness infrastructure.

**Caveats — A-share specifics that do NOT transfer to VN:**

1. **ST/*ST suspension semantics ≠ VN suspension semantics.** China's ST adds a `ST ` prefix to the ticker + tighter ±5% daily limit; *ST adds `*ST` prefix + de-listing risk warning; 退市整理期 is a final 30-day liquidation window. VN equivalents (cảnh báo, kiểm soát, hạn chế giao dịch, đình chỉ giao dịch) have **different price-limit consequences**, different tiered thresholds, and the "consecutive 2 years loss + revenue < threshold" rule has a VN equivalent but with different thresholds (HOSE/HNX listing rules per Decree 155/2020). The four red-line thresholds in `SKILL.md:88-91` (营收 < 3亿/1亿, 市值 < 5亿/3亿, dividend 5000万/3000万) are CSRC numbers and **must not** be copied as-is.
2. **扣非净利润 (`profit_dedt` = profit after stripping non-recurring) field** is a CSRC-disclosure requirement. VN equivalent depends on each company's adopted IFRS/VAS disclosure level — often **not separately disclosed** for mid/small caps. C3 codifying "worst-of-two" must include a fallback rule when `profit_dedt`-equivalent is null.
3. **Subject-normalisation regex catalogue** (`fetch_sina_penalties.py:70-90`) is Chinese-text-specific (董事长, 总经理, 控股股东, 实际控制人). VN equivalent needs its own keyword list (chủ tịch HĐQT, tổng giám đốc, cổ đông lớn, người có liên quan, etc.).
4. **Tushare/akshare data-source duality** is a CN-market specialty (paid+free Chinese data vendors). VN has vnstock + SSI direct + cafef scraping; the *pattern* of declared-fallback-chains (C10) transfers, but the specific data-source list is per-market.
5. **R3 dividend rule** ("近三年累计现金分红 < 30% 年均净利润 且 < 板块阈值") is a CSRC ST trigger. VN does NOT have a direct dividend-floor delisting rule; this rule should be carried only as a *quality signal*, not as a hard ST predictor.
6. **Board-segmentation thresholds** (主板 / 创业板 / 科创板 / 北交所 with different revenue/market-cap/dividend numbers in `SKILL.md:82-91`) → VN parallel = HOSE / HNX / UPCoM, with **distinct** listing-status rules per board. Skill must be re-thresholded per VN board, not just translated.

**Risks:**

- A-share legal-environment + retail-investor profile (much higher retail concentration than VN; T+1 + price-limit driven) makes the **backtest engine's microstructure assumptions** (e.g. price-limit-up = unable-to-buy in `china_a.py:67-69`) directly applicable to VN, *but* VN has additional ATO/ATC sessions (open + close auctions) not modelled in the A-share engine — adopting C6 needs a VN-microstructure delta.
- **Over-fitting to A-share regime**: backtest patterns tuned on A-share data 2015-2024 (regime-rich: 2015 leverage crash + 2018 trade war + 2020 COVID + 2022 zero-COVID + 2024 stimulus) may not generalise to VN 2024-2026 conditions. Validation pipeline C9 mitigates but does not eliminate this risk.

## 6. License + Attribution

- **License**: MIT (`LICENSE:1-2`, `pyproject.toml:6` `license = "MIT"`).
- **Copyright**: `Copyright (c) 2026 Vibe-Trading Contributors` (`LICENSE:3`).
- **Author**: HKUDS (Hong Kong University Data Science group), `pyproject.toml:8-10` `authors = [{name = "HKUDS", email = "hkuds@connect.hku.hk"}]`. README mentions a Discord (`README.md:29`) + Feishu/WeChat groups (`README.md:27-28`).
- **PyPI package**: `vibe-trading-ai==0.1.6` (`pyproject.toml:1-3`).
- **GitHub**: `HKUDS/Vibe-Trading` (link in `README.md:54-67` referencing PRs #63/#64/#65/#69/#57/#60 etc.).
- **Attribution requirement** (MIT): preserve copyright + permission notice in any file we port. Practical pattern for ports: add `# Adapted from Vibe-Trading (HKUDS/Vibe-Trading, MIT-licensed, 2026)` header to each ported module.

## 7. Risks / Anti-patterns to avoid

1. **DO NOT copy CSRC numeric thresholds** in `SKILL.md:88-91` as VN thresholds. Re-research VN HOSE/HNX/UPCoM thresholds (Decree 155/2020 + UBCKNN guidance + exchange listing rules) before any port.
2. **DO NOT treat ST/*ST and "cảnh báo / kiểm soát" as semantically equivalent.** The state machines are different; agent should map VN → A-share severity tier explicitly, not assume parallel.
3. **DO NOT copy R3 dividend rule as a hard delisting predictor for VN.** Demote to quality-signal.
4. **DO NOT skip `--stock-name`/`target_relevance` filtering** when porting C2. The hardening doc (`pr63_ashare_pre_st_filter_hardening.md:11-12`) exists precisely because the un-hardened version had a systematic over-count failure mode (any individual whose brokerage-account trade list mentioned the target stock would inflate E2 frequency). VN news-scrapers will have the *same* class of failure mode (any KOL article mentioning the stock will be over-counted).
5. **DO NOT over-fit backtest patterns to A-share data.** The Charter Month-12 alpha-vs-VN-Index criterion is for VN-data alpha; A-share data is for engine-architecture template only, not for parameter tuning.
6. **DO NOT copy the docstring-out-of-date pattern** (`path_utils.py:1-16` claims "three helpers" but ships four — a maintenance smell). When porting, refresh the docstring to "four helpers, four threat models" + name the UNC guard as the fifth shared invariant.
7. **DO NOT skip path-safety tests** when porting C1. `agent/tests/test_path_safety.py:1-136` covers all four helpers + UNC + traversal cases; replicate test surface 1:1 — path-safety is exactly the kind of feature where the test is the contract.
8. **DO NOT rely on Vietnamese onboarding docs as authoritative semantics.** `docs/onboarding/02-HLD.md` and `12-ONBOARDING-TRACK.md` are in Vietnamese and reflect *one contributor's* learning notes; the canonical contract is the code + `README.md` (English) + `SKILL.md` files (Chinese for A-share-specific ones, English elsewhere).
9. **DO NOT bundle C2 (pre-ST skill) into Phase A direct-IMPL without VN-rule research session first.** The CSRC → UBCKNN rule mapping is non-trivial; a separate VN-listing-status research-spike session is required before code.
10. **DO NOT port the MCP server pattern + `fastmcp` dependency naively.** StockForge already has a Claude-subagent dispatch model (per `anthropic_api_to_subagent` rule); adding an MCP layer is gold-plating unless explicitly requested.

---

**Self-attestation: every claim cites a specific file in the repo.**
