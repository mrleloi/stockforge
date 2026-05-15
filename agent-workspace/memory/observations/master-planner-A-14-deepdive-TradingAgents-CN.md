---
observation_id: master-planner-A-14-deepdive-TradingAgents-CN
session: S323-A-phase-a-deepdive
agent: general-purpose
date: 2026-05-15
repo: TradingAgents-CN
repo_path: C:/htdocs/research/TradingAgents-CN/
fit_level_hypothesis: HIGH-HIGHEST
fit_level_empirical: HIGH (pattern transfer); MEDIUM-LOW (direct code port)
license: Apache 2.0 (core `tradingagents/`, `cli/`, `scripts/`, `docs/`, `examples/`, `web/`) + Proprietary (`app/` FastAPI backend, `frontend/` Vue.js); commercial use of proprietary parts requires hsliup@163.com licensing
---

## 1. Repo Summary

TradingAgents-CN is the Chinese-localised, A-share-extended derivative of the original Tauric Research `TradingAgents` multi-agent stock-analysis framework (cited `README.md:7,57-61`). Version `v1.0.1` (`VERSION:1`) — author hsliuping (`LICENSING.md:64-67`).

**Architecture in one sentence**: a LangGraph-orchestrated DAG of LLM-driven sub-agents (Analysts → Researchers debate → Research Manager → Trader → Risk-debate triad → Risk Manager → Signal Processor) where each node is a prompt-template + tool-binding function, and the data layer is a multi-provider abstraction (Tushare / AKShare / BaoStock for A-share; AKShare / Yahoo for HK; Yahoo / FinnHub for US) with MongoDB + Redis caching.

**Stack**:
- LangGraph (`tradingagents/graph/setup.py:5` imports `StateGraph, END, START`) for agent DAG
- LangChain + provider-specific adapters (`tradingagents/llm_adapters/`: dashscope, deepseek, google, openai-compatible)
- Pluggable LLM clients (`tradingagents/llm_clients/factory.py` referenced from `trading_graph.py:74-83`) covering OpenAI, SiliconFlow, OpenRouter, AiHubMix, Ollama, DeepSeek, Qwen (DashScope), GLM, Qianfan, Anthropic, Google — see `trading_graph.py:60`
- Data providers in `tradingagents/dataflows/providers/{china,hk,us}/` with `BaseStockDataProvider` base class
- ChromaDB for agent memory (`tradingagents/agents/utils/memory.py:1,16-67`)
- Streamlit `web/` (legacy Apache) + FastAPI `app/` + Vue `frontend/` (both Proprietary; see § 6)

**Scale-and-shape signals**:
- `tradingagents/dataflows/providers/china/akshare.py` = **1676 LOC** (single-file omnibus — anti-pattern; see § 7)
- `tradingagents/agents/analysts/china_market_analyst.py` = 291 LOC
- `tradingagents/graph/setup.py` = 267 LOC, `conditional_logic.py` = 242 LOC, `signal_processing.py` = 336 LOC
- Provider matrix: 4 China providers (akshare, baostock, tushare, fundamentals_snapshot), 2 HK (hk_stock, improved_hk), 6 US (alpha_vantage_common/fundamentals/news, finnhub, optimized, yfinance) — see `ls` of `tradingagents/dataflows/providers/{china,hk,us}/`

**The CN-specific extension** (vs upstream TradingAgents) consists of:
- A bespoke `china_market_analyst.py` analyst with embedded A-share microstructure knowledge (cited § 3.1)
- Multi-source CN data providers with explicit ST + suspension flag handling (cited § 3.4)
- Chinese sentiment lexicons in `akshare.py:1497-1611` for news polarity scoring (cited § 3.5)
- Provider-key normalisation supporting Chinese LLM vendors (DashScope/Qwen, DeepSeek, GLM, Qianfan, SiliconFlow) — see `trading_graph.py:60` provider list

---

## 2. Architecture / Design Patterns

### 2.1 LangGraph DAG topology

The orchestration model (described visually in `docs/analysis/analysis-nodes-and-tools.md:10-48`, implemented in `tradingagents/graph/setup.py`):

```
Start → [Market | Social | News | Fundamentals analysts in parallel]
      → Investment Debate: Bull ↔ Bear loop (bounded by max_debate_rounds, default 1)
      → Research Manager (judge, produces investment_plan)
      → Trader (consumes investment_plan, emits trader_investment_plan)
      → Risk Debate: Risky ↔ Safe ↔ Neutral round-robin (bounded by max_risk_discuss_rounds)
      → Risk Manager (final judge, emits buy/hold/sell + reasoning)
      → Signal Processor → END
```

Citation: `tradingagents/graph/conditional_logic.py:201-217` (`should_continue_debate`) and `tradingagents/graph/conditional_logic.py:219-242` (`should_continue_risk_analysis`) — the bull/bear loop alternates speakers based on `current_response.startswith("Bull")` (line 215); the risk triad rotates Risky → Safe → Neutral.

### 2.2 Multi-Perspective Debate (adversarial-by-default at agent layer)

This is the single most important pattern for StockForge transfer:

- `tradingagents/agents/researchers/bull_researcher.py:10` `create_bull_researcher(llm, memory)` factory — prompt makes case FOR the position, drawing on market + sentiment + news + fundamentals reports plus `memory.get_memories(curr_situation, n_matches=2)` of past similar cases
- `tradingagents/agents/researchers/bear_researcher.py:10,89-117` mirror — explicit prompt: "你的目标是提出合理的论证，强调风险、挑战和负面指标 ... 反驳看涨观点" ("Highlight risks, challenges, negative indicators ... rebut the bull's argument") with structured demand for: 风险和挑战 / 竞争劣势 / 负面指标 / 反驳看涨观点 / 参与讨论
- `tradingagents/agents/risk_mgmt/aggresive_debator.py:39-51` Risky persona — biases toward high-return strategies
- `tradingagents/agents/risk_mgmt/conservative_debator.py:40-52` Safe persona — biases toward capital preservation
- `tradingagents/agents/risk_mgmt/neutral_debator.py` Neutral persona (file exists; not opened, parallel structure)
- Iteration count bounded: `max_debate_rounds=1, max_risk_discuss_rounds=1` per `tradingagents/default_config.py:18-19`
- The judge model (`research_manager.py:35-74`, `risk_manager.py:37-59`) is INSTRUCTED to take a decisive stance: "Avoid defaulting to hold just because both sides have valid points" (`research_manager.py:37`)

**Note for StockForge transfer**: the prompts are stateful — bull and bear each maintain their own `bull_history` / `bear_history` strings (`bear_researcher.py:18,128-129`), plus a shared `history` log. Each round refines based on the opponent's `current_response`.

### 2.3 State machine pattern with infinite-loop circuit-breakers

`tradingagents/agents/utils/agent_states.py` defines `AgentState`, `InvestDebateState`, `RiskDebateState` — these are TypedDict-like keyed accumulators threaded through the graph. Every analyst increments a per-section tool-call counter:

- `market_tool_call_count` (max 3 — `conditional_logic.py:28-29`)
- `sentiment_tool_call_count` (max 3 — `conditional_logic.py:73`)
- `news_tool_call_count` (max 3 — `conditional_logic.py:111`)
- `fundamentals_tool_call_count` (max 1 — `conditional_logic.py:149`, because "一次工具调用就能获取所有数据")

When counter ≥ max OR a report ≥ 100 chars exists, the analyst is force-routed to its `Msg Clear *` terminal (`conditional_logic.py:46-53`). This is an explicit "死循环修复" (deadlock-fix) measure — see comments at lines 26, 45-47, 121-124 — surfaced as a "重大Bug修复" in `README.md:104` ("解决部分用户在分析过程中触发的无限循环问题").

**Transferable pattern**: bound LangGraph loops by content-presence AND iteration-count, not just one.

### 2.4 Provider abstraction + waterfall fallback

`tradingagents/dataflows/data_source_manager.py` is the central router (1700+ LOC by `grep` count). The pattern visible from `data_source_manager.py:168` and `:497` is a priority list (`ChinaDataSource.{TUSHARE,AKSHARE,BAOSTOCK}`) with fallback if the primary source fails.

`README.md:81` explicitly documents the AKShare multi-level fallback chain: `stock_bid_ask_em -> stock_zh_a_spot -> stock_zh_a_spot_em -> stock_zh_a_hist`. This maps directly onto VN's `I-S65: Source-Fallback Chain Order` invariant (cited `agent-workspace/constitution/invariants-stockforge.md:169`).

### 2.5 Memory-augmented reasoning

`tradingagents/agents/utils/memory.py:16-104` `ChromaDBManager` — singleton thread-safe wrapper. Each agent role has its own collection (`bull_memory`, `bear_memory`, `trader_memory`, `invest_judge_memory`, `risk_manager_memory` — see `graph/setup.py:33-46`). At each invocation: `past_memories = memory.get_memories(curr_situation, n_matches=2)` (`bear_researcher.py:80`). After-the-fact reflection (`tradingagents/graph/reflection.py`) writes outcomes back to memory — i.e. learning from past misjudgements is built in.

**Transfer to StockForge**: this is a calibration/learning loop. The mechanism aligns with StockForge's "calibration over confidence" hard rule (Charter Principle 8).

### 2.6 LLM-provider abstraction with Chinese-vendor first-class support

`tradingagents/graph/trading_graph.py:60` lists supported `normalized_provider` values: `openai, siliconflow, openrouter, aihubmix, ollama, deepseek, qwen, glm, custom_openai, qianfan` — plus Google and Anthropic via dedicated branches (lines 86-114). `tradingagents/llm_clients/provider_keys.py` (referenced at `trading_graph.py:11`) holds `env_key_for_provider, normalize_provider_key` — the env-var mapping rule `env_key = f"{provider.name.upper()}_API_KEY"` is documented in `docs/API_KEY_MANAGEMENT_ANALYSIS.md:86-92`.

### 2.7 Deterministic numerical extraction (parses LLM text back into structured signal)

`tradingagents/graph/signal_processing.py:240-279` reverse-extracts numerical signal (`action`, `percentage_change`, `target_price`) from LLM free-text using regex anchored on Chinese terms (上涨/涨幅/增长/目标价位/¥/元). This is a "LLM-emits-text, code-extracts-numbers" pattern — i.e. they did NOT trust the LLM to emit numbers directly, instead parsing them deterministically. **This is exactly StockForge's "NO LLM math" hard rule realized in practice.**

---

## 3. Components / Features candidate for StockForge adoption

### 3.1 China Market Analyst — embedded microstructure knowledge

`tradingagents/agents/analysts/china_market_analyst.py:113-138` (system message) explicitly enumerates the A-share idiosyncrasies the analyst is instructed to reason about:

- 涨跌停制度 (limit-up/limit-down)
- T+1交易 (T+1 settlement)
- 融资融券 (margin/securities-lending)
- 北向资金 (Northbound flow — Stock Connect)
- 大宗交易 (block trades)
- 退市制度 (delisting rules)
- ST股票 (Special-Treatment stocks)
- 科创板 / 创业板 (STAR Board / ChiNext board)
- 国企改革 / 混改 (SOE reform / mixed-ownership reform)
- 政策面 / 资金面 (policy + fund-flow analysis)

**VN parallel** (claim with citation):
- 涨跌停制度 → `I-S61: Ceiling / Floor (Trần / Sàn) Per-Sàn Limits` (cited `agent-workspace/constitution/invariants-stockforge.md:153`)
- T+1 → VN T+2.5 cleared cash, `I-S55` (cited `agent-workspace/constitution/invariants-stockforge.md:129`)
- 北向资金 / foreign-flow → VN `I-S56: Foreign-Room Saturation Alert` (cited `invariants-stockforge.md:133`)
- ST股票 → VN `I-S62: Trading-Suspension Event Handling` (cited `invariants-stockforge.md:157`)
- 退市 → VN `I-S59: Listing-Status Sàn Tagging` (cited `invariants-stockforge.md:145`) for sàn-tier transitions (HOSE/HNX/UPCoM)
- 科创板 / 创业板 board-tier differentiation → VN HOSE / HNX / UPCoM (`I-S59`)

**Adoption form**: prompt-template port (re-localised). The KNOWLEDGE (which microstructure facts to enumerate) is reusable; the SPECIFICS (涨跌停 10% normal / 5% ST / 20% ChiNext) must be replaced with VN values (`I-S61` Trần/Sàn sàn-tiered: HOSE ±7%, HNX ±10%, UPCoM ±15% — to verify against StockForge invariants file).

### 3.2 Multi-perspective debate framework (Bull/Bear + Risky/Safe/Neutral)

Already detailed § 2.2. **Direct candidate for adoption.** Pattern is portable; prompts must be re-localised to Vietnamese + VN-market terms.

Map to StockForge BCs:
- Bull/Bear researcher → BC-7 thesis exploration (consumer-facing) and BC-6 contrarian-view generation (per StockForge charter "adversarial by default")
- Risky/Safe/Neutral triad → BC-5 risk-management policy layer (deterministic position-sizing constraints) — note: StockForge invariant requires LLM CANNOT override max position size; the triad here biases the recommendation but stops short of binding it.

### 3.3 LangGraph circuit-breaker pattern

Pattern from § 2.3. **Direct candidate** for StockForge BC-7 or BC-8 multi-step pipelines. Map: tool-call counter + content-length sentinel ⇒ force terminal state.

### 3.4 ST / suspension data field surfacing

`tradingagents/dataflows/providers/china/baostock.py:577` — BaoStock's `query_history_k_data_plus` is queried with `fields_str = "date,code,open,high,low,close,preclose,volume,amount,adjustflag,turn,tradestatus,pctChg,isST"`. Two key fields:
- `tradestatus` — trading status (suspended / normal)
- `isST` — whether the stock is currently flagged Special Treatment

**VN parallel**: This is precisely the data-shape needed for `I-S62: Trading-Suspension Event Handling` (suspension flag) and adjacent `I-S59: Listing-Status Sàn Tagging`. The schema lesson: **augment the OHLCV bar with a 'status' tag and a 'special-treatment' boolean at ingest time**, not at query time.

**Adoption form**: schema-level transfer (add `is_suspended: bool` and `is_under_warning: bool` columns to VN bar table) and ingest-time tagging from data-source flags (e.g. HOSE/HNX has its own 警示/CKD/cảnh báo flagging system — confirm via StockForge ingestion docs).

### 3.5 Chinese sentiment lexicon for news polarity

`tradingagents/dataflows/providers/china/akshare.py:1497-1521` defines `positive_keywords` (利好/上涨/增长/盈利/突破/涨停/...) and `negative_keywords` (利空/下跌/亏损/暴跌/跌停/退市/停牌/...).

`akshare.py:1523-1563` `_calculate_sentiment_score` — keyword-weight dictionary:
```
'涨停': 1.0, '暴涨': 0.9, '大涨': 0.8, '飙升': 0.8,
'创新高': 0.7, '突破': 0.6, '上涨': 0.5, ...
'跌停': -1.0, '暴跌': -0.9, '大跌': -0.8, '跳水': -0.8,
'创新低': -0.7, '破位': -0.6, ...
```

Note: this is rule-based lexicon scoring (NOT LLM scoring) — i.e. deterministic, reproducible, auditable. Score range normalised to [-1, 1] (line 1563).

**VN parallel**: directly transferable PATTERN. The Chinese lexicon must be replaced with a Vietnamese one (tăng/giảm/sàn/trần/đột phá/lao dốc/đỉnh/đáy/cổ phiếu nóng/cảnh báo/...). This maps to StockForge BC-4 (news/sentiment ingestion) and BC-7 (sentiment scoring for thesis). **Strongly recommended adoption** — directly satisfies StockForge "no-LLM-math" invariant for sentiment numerics.

**Caveat**: the keyword-counting method is crude. Recommend BiLSTM or fine-tuned VN-financial DistilBERT for production; lexicon as fallback. See § 5.

### 3.6 KOL / retail-sentiment platform list (BC-7 target source list)

`tradingagents/agents/analysts/social_media_analyst.py:128-140` system message names the Chinese retail-sentiment platforms:
- 财联社, 新浪财经, 东方财富, 腾讯财经 (financial news)
- 雪球, 东方财富股吧, 同花顺 (retail discussion forums)
- 微博财经大V, 知乎投资话题 (microblog KOLs + Q&A forums)

**VN parallel** (CN F0 retail "韭菜" → VN "F0" investor wave):
- VN equivalents: CafeF, NDH, Vietstock, VietnamBiz (financial news — already on StockForge crawler shortlist per `crawler-reliability` skill)
- F319 (cổ phiếu forum), Forum F319, Voz f17 (retail forums)
- Vietstock Stockfun, Facebook fanpages (e.g. "Đầu tư chứng khoán Việt Nam"), Zalo nhóm "đội lái"
- YouTube channels (KOL transcripts — already on StockForge BC-7 target list per master-plan § 4.14)

**Note for StockForge**: TradingAgents-CN does NOT crawl these platforms directly in the open-source layer — it delegates to a "get_chinese_social_sentiment" tool whose implementation lives in `tradingagents/tools/` and which surfaces `"由于中国社交媒体API限制，如果数据获取受限，请明确说明并提供替代分析建议"` (`social_media_analyst.py:157`) — i.e. the implementation is a stub that gracefully degrades, NOT a working crawler. StockForge cannot inherit a crawler from this repo; it must build its own (per `crawler-reliability` skill).

### 3.7 Multi-vendor LLM abstraction (Chinese vendors first-class)

`tradingagents/graph/trading_graph.py:39-160` + `tradingagents/llm_clients/factory.py` + `llm_clients/provider_keys.py` — comprehensive provider abstraction. Especially valuable: DashScope (Qwen) + DeepSeek + GLM (Zhipu) support — these are Chinese-language-optimised models that are ALSO competitive on Vietnamese (since CJK-trained tokenizers handle VN diacritics reasonably).

**Note**: per StockForge memory `anthropic_api_to_subagent.md` — direct API calls for the StockForge runtime should be refactored to Claude Code subagent dispatch. But for the **ingest/extraction layer** (BC-4 news classification, BC-7 KOL recommendation extraction), Qwen-2.5-7B / DeepSeek-V2 as local model candidates are worth piloting. The provider abstraction in this repo is a useful reference.

### 3.8 Reflection / past-mistakes mechanism

`tradingagents/graph/reflection.py` (file exists, not opened) — combined with `memory.get_memories(curr_situation, n_matches=2)` (`research_manager.py:26-33`, `bear_researcher.py:80`) — implements a "look back at similar past situations + the recommendations made + their outcomes" loop. The Research Manager prompt at `research_manager.py:55-56` explicitly says: "以下是您对错误的过去反思: {past_memory_str}".

**VN parallel**: maps onto StockForge's "calibration over confidence" Charter Principle 8 and `agent-workspace/calibration/` directory mentioned in `CLAUDE.md`. **Direct adoption candidate** for a thesis-feedback-loop pattern in BC-7. Replace ChromaDB with Postgres+pgvector (per StockForge stack — `postgres-pgvector` skill).

### 3.9 Configurable analysis depth (lookback days)

`docs/ANALYST_DATA_CONFIGURATION.md:13-115` — single config knob `MARKET_ANALYST_LOOKBACK_DAYS` (default 30) with four named tiers:
- 快速分析 (10-15 days, ~2-4 min)
- 标准分析 (30 days, ~6-10 min)
- 深度分析 (60-90 days, ~10-15 min) ⭐ recommended
- 全面分析 (180-365 days, ~15-25 min)

Plus a fundamentals-fixed-10-days pattern (10 days fetched, last 2 days used — buffer for weekend/holiday data gaps).

**VN parallel**: directly transferable pattern. **Adoption form**: a `THESIS_DEPTH_TIER` env var or config flag with named tiers per StockForge session-type taxonomy (FOCUSED vs MULTI-TASK vs THESIS). Maps neatly to StockForge `agent-workspace/constitution/session-budgets.md`.

### 3.10 Mandatory target-price + risk-rating in trader output

`tradingagents/agents/trader/trader.py:68-80` system message DEMANDS the trader output:
- 投资建议 (买入/持有/卖出)
- 目标价位 ({currency}) — "🚨 强制要求提供具体数值"
- 置信度 (0-1)
- 风险评分 (0-1)
- 详细推理

Plus the explicit constraint at line 71: "不允许设置为null或空值".

**VN parallel**: maps onto StockForge hard rule "Output is structured, not narrative. Use trade-off matrices, multi-criteria, never single 'buy/sell' score". HOWEVER — TradingAgents-CN does allow a single-action recommendation ('买入/卖出/持有'). StockForge's adversarial-by-default doctrine would replace the action with a 2D matrix (bull-case + bear-case + base-case, with explicit confidence interval). **Pattern shape is adoptable; specific output structure must be reshaped to multi-criteria.**

---

## 4. Per-BC Mapping

| StockForge BC | TradingAgents-CN component | File anchor | Adoption form | Priority |
|---|---|---|---|---|
| **BC-1** Market Data (intraday + ATO/ATC parallel) | Provider abstraction `data_source_manager.py`; OHLCV with `isST` + `tradestatus` from BaoStock | `tradingagents/dataflows/data_source_manager.py:168,497`; `providers/china/baostock.py:577` | Schema-level (add status flags); waterfall pattern direct | HIGH |
| **BC-2** Fundamentals (financial-statement conventions) | `fundamentals_analyst.py` + Tushare `daily_basic` (PE/PB/PE_TTM/PB_MRQ/total_mv/circ_mv/turnover_rate/volume_ratio) | `tradingagents/agents/analysts/fundamentals_analyst.py`; `docs/analysis/pe-pb-data-update-analysis.md:24-50` | Field-set reference (CN GAAP vs VN VAS reconciliation) — pattern only | MEDIUM |
| **BC-4** Macro / Policy / News | News analyst + Chinese-finance aggregator + sentiment lexicon | `tradingagents/agents/analysts/news_analyst.py`; `dataflows/news/chinese_finance.py:18-60`; `providers/china/akshare.py:1497-1611` | Sentiment lexicon: ADOPT PATTERN with VN lexicon; News-aggregator: build VN equiv per `crawler-reliability` skill | HIGH |
| **BC-5** Risk Management (position sizing) | Risky/Safe/Neutral debate triad + Risk Manager judge | `tradingagents/agents/risk_mgmt/{aggresive,conservative,neutral}_debator.py`; `agents/managers/risk_manager.py:37-59` | Adopt triad PATTERN; respect StockForge invariant (LLM cannot override max-position size — deterministic guards in code) | HIGH |
| **BC-7** Retail Sentiment / Thesis | Social media analyst + Bull/Bear debate + Memory/Reflection | `agents/analysts/social_media_analyst.py:128-157`; `agents/researchers/{bull,bear}_researcher.py`; `agents/utils/memory.py`; `graph/reflection.py` | Bull/Bear debate: DIRECT (Vietnamese re-localise); Memory: replace Chroma with Postgres+pgvector | HIGHEST |
| **BC-8** Trading Decision / Output | Trader + Signal Processor + Research-Manager-judge | `agents/trader/trader.py:68-80`; `graph/signal_processing.py:240-336`; `agents/managers/research_manager.py:35-74` | LLM-text → regex-extracted numbers: ADOPT (matches StockForge no-LLM-math); reshape single-action output to multi-criteria matrix | HIGH |

**Inherited from upstream TradingAgents (Tauric Research)** — not CN-specific:
- LangGraph DAG topology (general pattern)
- Memory/reflection mechanism (general pattern)
- Bull/Bear adversarial researcher pattern (general)
- The CN fork adds: A-share knowledge, Chinese LLM vendors, CN data providers, CN sentiment lexicons.

---

## 5. Honest Fit Assessment

For each candidate component, VN-transferability rated HIGH / MED / LOW with explicit reasoning + I-S invariant citations:

### 5.1 China Market Analyst microstructure knowledge → BC-1 prompt template

**Rating: HIGH (pattern), MEDIUM (parameters)**

Reasoning: The PATTERN of enumerating market-specific microstructure facts inline in the analyst's system prompt (so the LLM reasons WITH them, not despite them) is directly portable. The Chinese facts are NOT directly portable — they must be replaced with VN equivalents.

Specific replacements required (each cited):
- 涨跌停 10% / ST 5% / ChiNext 20% / STAR 20% → VN sàn-tier limits per `I-S61` (`invariants-stockforge.md:153`): HOSE ±7%, HNX ±10%, UPCoM ±15% (verify exact values in StockForge invariants source)
- T+1 settlement → VN T+2.5 cleared-cash per `I-S55` (`invariants-stockforge.md:129`)
- 北向资金 (Stock Connect inflow) → VN foreign-investor room per `I-S56` (`invariants-stockforge.md:133`)
- 涨跌停 imposes "trapped position" risk → SAME concept applies in VN; just different magnitudes
- 科创板/创业板 board differentiation → VN HOSE/HNX/UPCoM per `I-S59` (`invariants-stockforge.md:145`)
- ST flag → VN suspension/warning flag per `I-S62` (`invariants-stockforge.md:157`)
- 涨跌停 on suspension transition (ST → \*ST → delisting cascade) → VN HOSE-to-UPCoM relegation cascade per `I-S59`+`I-S62`

Risk: An over-eager copy-port could leave Chinese terms in VN prompts. Mitigation: linter that flags Chinese characters in `apps/` Vietnamese-Vietnamese strings.

### 5.2 Multi-perspective Bull/Bear + Risk-Triad debate → BC-7 + BC-5

**Rating: HIGH**

Reasoning: This is the strongest match. StockForge charter mandates "Adversarial by default: any thesis output includes bear case explicitly" (`CLAUDE.md`). TradingAgents-CN realises this at the agent layer. The bounded-iteration pattern (`max_debate_rounds=1` per `default_config.py:18`) maps onto StockForge token-budget constraints.

Caveats:
- The CN risk-triad PROMPTS recommend (per `aggresive_debator.py:51` — "断言承担风险的好处以超越市场常规"). They DO NOT enforce deterministic risk caps. StockForge MUST add the deterministic position-sizing layer (per StockForge hard rule "Position sizing & risk management are deterministic code").
- The CN judge layer (`research_manager.py:37`) is explicitly told to avoid "default hold". This is at odds with VN's higher retail/F0 churn — VN context may need a more conservative judge prompt that biases toward NO-ACTION when conviction is low. Calibration needed (StockForge Charter Principle 8).

### 5.3 LangGraph circuit-breaker pattern → cross-cutting

**Rating: HIGH**

Reasoning: Pattern is content-neutral. Tool-call counter + report-length sentinel = bounded LangGraph loop. Directly adoptable. Pairs naturally with StockForge session-budget rules in `agent-workspace/constitution/session-budgets.md`.

### 5.4 ST / suspension data-field ingest → BC-1 schema + I-S62 implementation

**Rating: HIGH**

Reasoning: The schema lesson (augment OHLCV bar with `is_suspended: bool` and `is_under_warning: bool` columns at ingest time) is universal. The CN BaoStock implementation cited at `providers/china/baostock.py:577` is a reference for the field-name and propagation pattern. Maps directly to VN `I-S62` (`invariants-stockforge.md:157`).

Adoption path: pre-populate the `is_suspended` / `is_under_warning` columns in StockForge's bar table from vnstock/TCBS/SSI source flags. The VN-specific warning system (kim cương / vàng / cảnh báo / kiểm soát / hạn chế / đình chỉ) needs its own taxonomy mapping — see VN HOSE listing-management rules.

### 5.5 Chinese sentiment lexicon pattern → BC-4 VN sentiment-lexicon implementation

**Rating: HIGH (pattern), N/A (content — lexicon must be replaced)**

Reasoning: Rule-based, deterministic, reproducible — directly satisfies StockForge "no-LLM-math" hard rule for sentiment numerics. The score-normalisation step at `akshare.py:1563` (`max(-1.0, min(1.0, score / 3.0))`) is a useful reference for bounded output.

VN-specific implementation steps:
1. Build VN financial lexicon (~200-500 keywords): tăng/giảm/lên giá/xuống giá/đột phá/lao dốc/cổ phiếu nóng/sàn/trần/cảnh báo/đình chỉ/lỗ/lãi/...
2. Weight by intensity (similar to CN scheme — 1.0 for extreme, 0.5 for moderate, etc.)
3. Add VN-specific anchors: "lái" (price-manipulation), "đội lái" (pump-group), "đu đỉnh" (FOMO at top), "bắt đáy" (catch the bottom) — these are VN F0 retail-culture terms with no direct CN equivalent
4. Cross-validate on a small labelled corpus (e.g. 200 manually-tagged CafeF/NDH articles)
5. Fallback when lexicon coverage low: defer to fine-tuned BERT (e.g. underthesea / phoBERT)

### 5.6 Provider abstraction + waterfall fallback → cross-cutting

**Rating: HIGH (pattern), LOW (code port — different APIs)**

Reasoning: Pattern (BaseStockDataProvider + chain-of-fallbacks) is portable. The specific provider implementations (`akshare.py`, `tushare.py`, `baostock.py`) are NOT — VN equivalents (vnstock, TCBS, SSI Fast Connect, FiinTrade) have different APIs. Maps onto VN `I-S65: Source-Fallback Chain Order` (`invariants-stockforge.md:169`).

Specific anti-pattern caveat: `providers/china/akshare.py` is 1676 LOC in a single file mixing data-fetch + sentiment-scoring + news-classification. **Do NOT port the structure** — split per BC.

### 5.7 ChromaDB-backed memory / reflection → BC-7 calibration loop

**Rating: MEDIUM (pattern adoptable, stack mismatch)**

Reasoning: The memory-augmented reasoning pattern is sound. StockForge uses Postgres+pgvector per `postgres-pgvector` skill, not ChromaDB. Re-implement on the StockForge stack — the LangGraph integration shape is portable; the vector-store choice is not.

The `n_matches=2` parameter (`bear_researcher.py:80`) is small — likely intentional, to keep prompt budget bounded. Calibration needed for VN data volume.

### 5.8 KOL / retail-sentiment platform list → BC-7 crawler target list

**Rating: MEDIUM (informational), LOW (no working code)**

Reasoning: The PLATFORM LIST is a useful reference for what sources to target. The implementation in `social_media_analyst.py` is a stub that gracefully degrades when data is unavailable (`social_media_analyst.py:157`). StockForge must build its own crawlers (per `crawler-reliability` skill). Examples directory contains `examples/crawlers/{internal_message_crawler.py, message_crawler_scheduler.py, social_media_crawler.py}` — worth opening for inspection IF code-port becomes a goal, but **for Apache 2.0 portions only**.

### 5.9 Chinese-vendor LLM abstraction → cross-cutting

**Rating: MEDIUM**

Reasoning: Useful as a reference for supporting Qwen / DeepSeek / GLM in StockForge's ingest pipeline. NOT directly applicable to StockForge's main agent runtime per `anthropic_api_to_subagent.md` (which mandates Claude Code subagent dispatch over direct API). Useful for BC-4 / BC-7 LOCAL extraction (offline NER, sentiment) where a self-hosted Qwen-2.5-7B might be cost-effective.

### 5.10 Configurable analysis-depth tiers → cross-cutting

**Rating: HIGH**

Reasoning: Maps cleanly onto StockForge session-type taxonomy (`CLAUDE.md` § "Session Types"). Adopt as `THESIS_DEPTH={quick,standard,deep,comprehensive}` env var or session-type-derived parameter.

### 5.11 Mandatory structured trader output → BC-8 output schema

**Rating: MEDIUM**

Reasoning: PATTERN is adoptable (force LLM to emit all required fields). CONTENT must be reshaped per StockForge hard rule "Output is structured, not narrative. Use trade-off matrices, multi-criteria, never single 'buy/sell' score". Convert single-action `买入/持有/卖出` → multi-perspective output (bull-case-thesis + bear-case-thesis + base-case + confidence-interval + structured-risks).

---

## 6. License + Attribution — MANDATORY check

### 6.1 License Status (verified)

**LICENSE (root)** at `C:/htdocs/research/TradingAgents-CN/LICENSE:1-30`:
- **Apache License 2.0** for ALL files EXCEPT `app/` and `frontend/`
- **PROPRIETARY License** for `app/` (FastAPI backend) and `frontend/` (Vue.js frontend)
- Commercial use of proprietary parts requires contacting `hsliup@163.com`

**LICENSING.md** at `C:/htdocs/research/TradingAgents-CN/LICENSING.md`:
- Apache 2.0 scope: `tradingagents/` (core agent library), `cli/`, `scripts/`, `docs/`, `examples/`, `web/` (Streamlit), `assets/`, `tests/`, root `*.py`, `*.md`, `*.yml`, `*.yaml`
- Proprietary scope: `app/`, `frontend/` — "不得重新分发 / 不得商业使用（需授权）/ 不得修改或创建衍生作品 / 不得逆向工程"

**README warning** at `README.md:13-27`:
> 我们注意到 tradingagents-ai.com 网站未经授权使用了我们的专有代码 ... 我们项目组目前没有给任何组织或个人进行过商业授权
> (We notice tradingagents-ai.com has used our proprietary code without authorization ... we have not granted commercial authorization to any organization or individual.)

**v2.0.0 status** (`README.md:36-39`):
> v2.0.0 暂时不进行开源 (v2.0.0 will temporarily not be open-sourced) — due to plagiarism concerns.

### 6.2 Verdict for StockForge

**Pattern adoption: SAFE.** Apache 2.0 explicitly permits derivative works, commercial use, and modification of the `tradingagents/` core library. StockForge is single-tenant + private (3-5 trusted peers per CLAUDE.md), not commercial distribution — well within Apache 2.0 scope.

**Code port: SAFE FOR APACHE 2.0 PARTS, RISKY FOR PROPRIETARY.**
- Apache 2.0 (`tradingagents/`, `cli/`, `scripts/`, `docs/`, `examples/`, `web/`): MAY port code; MUST preserve copyright notice + Apache 2.0 license headers + attribution to Tauric Research (upstream) + hsliuping (CN fork).
- Proprietary (`app/`, `frontend/`): **MUST NOT port code, design, or reverse-engineered architecture.** Even "internal use" is restricted ("个人评估和测试 / 教育用途（非商业）/ 内部业务评估" only).

**Recommended adoption stance for StockForge**:
1. **Pattern-only** for proprietary parts (`app/`, `frontend/`) — observe how they architect FastAPI + Vue, but do NOT port specific code or unique designs. StockForge uses Streamlit Phase 1 anyway (CLAUDE.md), so the FastAPI proprietary layer is moot in Phase 1.
2. **Code-port with attribution** for Apache 2.0 parts (`tradingagents/`). When porting any file or function: prepend a comment block citing source + Apache 2.0 + upstream attribution.
3. **Pattern + lexicon-rebuild** for the sentiment-scoring layer — the lexicon content is data, not "creative expression" copyright-protected, but cite the pattern.

**Attribution template for StockForge ports**:
```python
# Pattern adapted from TradingAgents-CN (Apache 2.0)
# Upstream: github.com/hsliuping/TradingAgents-CN (CN fork)
# Original: github.com/TauricResearch/TradingAgents
# StockForge adaptation: VN-localised for HOSE/HNX/UPCoM market structure
```

### 6.3 Action items

- DO NOT crawl tradingagents-ai.com — known unlicensed mirror per README warning
- DO NOT inspect `app/` or `frontend/` for code-port purposes (proprietary)
- DO inspect `tradingagents/`, `docs/`, `examples/` for pattern + reference (Apache 2.0)
- DO add Apache 2.0 attribution to any ported file

---

## 7. Risks / Anti-patterns to avoid

### 7.1 Legal-grey signals from CN context

- **Unauthorised commercial mirror exists** (per `README.md:13-27`) — this is a known IP-violation case in the CN ecosystem. Do not associate StockForge with it.
- **Mixed-license repo pattern**: hsliuping's choice to keep core open + Web proprietary is a common CN open-source-with-commercial-protection pattern. StockForge should NOT mimic this — StockForge is single-tenant private, not aimed at commercial distribution.
- **v2.0.0 not open-source** — implies hsliuping considers the architectural learnings here valuable enough to withhold. The visible v1.0.1 is the safe-to-pattern-from baseline.

### 7.2 VN regulatory difference: SBV vs PBOC vs CSRC

- CN: PBOC (People's Bank of China) = monetary policy; CSRC (China Securities Regulatory Commission) = market regulator
- VN: SBV (State Bank of Vietnam) = monetary policy; SSC (State Securities Commission) = market regulator
- The `china_market_analyst.py:118` prompt names "中国经济政策" / "证监会政策" (CSRC) — VN port must reference SBV monetary policy + SSC listing rules + Ministry of Finance + HSX/HNX exchange-specific circulars
- VN-specific: VND/USD pegged-ish managed-float (different from CNY managed float); VN current-account dynamics; VN FDI inflow patterns; ASEAN integration considerations — NONE of these have direct CN parallels in the analyst prompt

### 7.3 CN F0 / 韭菜 retail dynamics vs VN F0 dynamics

CN "韭菜" (chives) = retail-investor-as-cyclical-prey. The CN sentiment lexicon embeds this implicitly. VN "F0 investor wave" (post-2020 retail surge) is a similar phenomenon but with VN-specific cultural texture:
- VN: "đu đỉnh" (FOMO-buying at top), "bắt đáy" (catch-bottom), "lái" (price manipulators), "đội lái" (pump groups)
- VN: heavy Facebook/Zalo group dynamics (CN equivalent is WeChat groups — not exposed in TradingAgents-CN open-source layer)
- VN: 85-90% retail share (per dispatch brief) — much higher than CN's ~50-60% retail share

**Anti-pattern to avoid**: porting the CN sentiment lexicon as-is. The CN lexicon is calibrated for ~50-60% retail; VN at 85-90% retail will need MORE retail-culture-aware keywords (including the "đội lái" pump dynamic) and DIFFERENT intensity weights.

### 7.4 Single-file omnibus anti-pattern

`tradingagents/dataflows/providers/china/akshare.py` is **1676 LOC** mixing:
- Data ingest (lines 1-1480)
- Sentiment lexicon (`_analyze_news_sentiment`, `_calculate_sentiment_score`, lines 1484-1563)
- News-importance classifier (`_assess_news_importance`, lines 1594-1629)
- News classification (`_classify_news`, line 1631+)
- Keyword extraction (lines 1565-1592)

**DO NOT port this structure.** Split per BC: AKShare-equivalent ingest → BC-1; sentiment lexicon → BC-4; news classification → BC-4 / BC-7. Each ≤ 300 LOC. (StockForge CLAUDE.md P2 "Simplicity First: if 200 lines could be 50, rewrite".)

### 7.5 LLM-emits-numbers prompt smell

`agents/managers/research_manager.py:44-51` instructs the LLM:
> 📊 目标价格分析：基于所有可用报告 ... 提供全面的目标价格区间和具体价格目标
> ...
> 💰 您必须提供具体的目标价格 - 不要回复"无法确定"或"需要更多信息"

**This violates StockForge's no-LLM-math hard rule** (`CLAUDE.md` § Hard Rules). TradingAgents-CN has a partial mitigation at `signal_processing.py:240-279` (regex-extract numbers from text) but the prompt still asks the LLM to produce a number. StockForge MUST refactor: the LLM should reason about RANGES, CATALYSTS, SCENARIOS — and a deterministic price-derivation step (DCF, P/E multiple from sector median, P/B multiple, etc.) emits the final numeric. Anti-pattern to NOT inherit.

### 7.6 ChromaDB on Windows quirks

`tradingagents/agents/utils/memory.py:36-50` has a Windows 11 special-case branch (`is_windows_11()`) and three layered fallbacks. This suggests ChromaDB on Windows is fragile. StockForge already uses Postgres+pgvector — sidestep this entirely.

### 7.7 Hard-coded English-only company-name lookups in CN-fork

`agents/analysts/china_market_analyst.py:67-79` (and identical patterns in `bull_researcher.py:60-66`, `bear_researcher.py:59-65`, `social_media_analyst.py:69-82`, `fundamentals_analyst.py:76-79`, `news_analyst.py:73-86`) hard-code an 8-stock English→Chinese name map for US stocks (AAPL/TSLA/NVDA/MSFT/GOOGL/AMZN/META/NFLX). This is duplicated across ~6 files. Anti-pattern: pull into a shared `stock_name_resolver` utility. **Lesson for StockForge: extract such lookups into BC-shared infrastructure early.**

### 7.8 Cross-language sentiment intensity not validated

The CN keyword-weight scheme (`akshare.py:1537-1548`) gives 涨停=1.0, 暴涨=0.9, etc. — these weights are NOT validated against a labelled corpus in the open-source code; they appear hand-tuned. For StockForge: build a small labelled VN corpus (200-500 articles) and CALIBRATE the lexicon weights from data, not from intuition. This is a Charter Principle 8 "Calibration over confidence" enforcement.

### 7.9 Implicit assumption: A-share = 6-digit numeric

`tradingagents/utils/stock_utils.py:43-52` uses regex `^\d{6}$` for A-share, `^\d{4,5}\.HK$` for HK, `^[A-Z]{1,5}$` for US. VN equivalent: HOSE/HNX/UPCoM tickers are 3-uppercase-letter (`^[A-Z]{3}$`). StockForge has its own ticker-shape detection (per ubiquitous-language glossary); the LESSON is "centralise ticker-shape detection in one util" — `StockUtils.identify_stock_market` pattern is a good shape.

### 7.10 Risk-debate triad does NOT bind risk caps

`agents/risk_mgmt/{aggresive,conservative,neutral}_debator.py` — the risky agent argues FOR taking risk; the conservative argues AGAINST. The Risk Manager judges. **There is no deterministic guard preventing the final recommendation from violating a position-size cap.** StockForge MUST add this guard (per StockForge hard rule "Position sizing & risk management are deterministic code. LLM cannot override max position size, sector concentration, stop loss rules").

**Adoption form**: keep the triad debate (it produces good reasoning); add a POST-judge deterministic gate that REJECTS any recommendation violating `max_position_size_pct`, `sector_concentration_pct`, `stop_loss_pct`. Citation chain: VN trader signals → triad debate → judge → deterministic-risk-gate → output.

### 7.11 Single max_debate_rounds=1 may be too shallow

`tradingagents/default_config.py:18-19` `max_debate_rounds=1, max_risk_discuss_rounds=1` — i.e. one round of Bull-then-Bear, then judge. For VN's high-noise retail-driven market, more rounds may be needed; conversely for token-budget concerns, more rounds = more LLM cost. Calibrate empirically with StockForge token-budget rules.

### 7.12 Documentation drift signal

Some docs are dated 20251011 (e.g. `docs/analysis/4级深度分析验证报告_20251011.md`, `docs/analysis/时间统计准确性分析_20251011.md`) — these are AFTER the `LICENSING.md` "Last updated 2025年10月" timestamp, suggesting the project is actively maintained but with rapid iteration. Lesson: this is a moving target. Pin to a specific commit hash if porting code.

---

Self-attestation: every claim cites a specific file in the repo + the relevant I-S invariant (where applicable). All file paths verified by Bash `ls`/`grep -c` or Read tool against `C:/htdocs/research/TradingAgents-CN/`; all I-S invariant references verified by Grep against `C:/htdocs/stockforge/agent-workspace/constitution/invariants-stockforge.md`. License status verified against `LICENSE:1-30` and `LICENSING.md` (both opened). LOC counts produced by `grep -c "" <path>`.
