---
observation_id: master-planner-A-13-deepdive-TradingAgents
session: S323-A-phase-a-deepdive
agent: general-purpose
date: 2026-05-15
repo: TradingAgents
repo_path: C:/htdocs/research/TradingAgents/
fit_level_hypothesis: HIGH
fit_level_empirical: HIGH (confirmed — debate-style multi-agent + dual harvest patterns + structured-output schema all map cleanly to BC-8 and to harness substrate)
license: Apache-2.0 (LICENSE l.1-201)
prior_harvest: deferred substrate; nothing shipped yet — W0-3 + W0-4 pending in Wave-0
pending_harvest: W0-3 atomic temp-file-replace doctrine (re-confirmed source); W0-4 HTML-comment separator pattern (re-confirmed source); plus Theme H candidate — debate-style synthesis (LangGraph round-robin)
upstream_version_observed: 0.2.4 (pyproject.toml l.7)
---

# Deep-dive: TradingAgents → StockForge BC-8 (multi-perspective adversarial) + harness substrate

## 0. Lost S259 reconstruction (W0-3 + W0-4 substrate sources)

Both deferred substrate patterns are re-confirmed in a **single file**:
`C:/htdocs/research/TradingAgents/tradingagents/agents/utils/memory.py` (~301 LOC, Apache-2.0). This is the `TradingMemoryLog` class.

### W0-3 — Atomic temp-file-replace doctrine

Source = the `update_with_outcome()` and `batch_update_with_outcomes()` methods. The doctrine is explicitly named in the docstring:

- `memory.py` l.109-114 docstring:
  > "Replace pending tag and append REFLECTION section using atomic write. … Uses a temp-file + os.replace() so a crash mid-write never corrupts the log."
- `memory.py` l.161-163 — concrete two-line idiom:
  ```python
  tmp_path = self._log_path.with_suffix(".tmp")
  tmp_path.write_text(new_text, encoding="utf-8")
  tmp_path.replace(self._log_path)
  ```
- `memory.py` l.215-217 — identical idiom in `batch_update_with_outcomes()` (proving the pattern is intentional, not accidental).
- `tests/test_memory_log.py` l.426-437 — `test_update_atomic_write` proves stale-tmp survival (over-write semantics, no append).

**Doctrine surface area for StockForge harness adoption (W0-3 lift):**
1. Resolve sibling tmp path via `Path.with_suffix(".tmp")` (not a separate temp dir → keeps move within same filesystem, which is required for `os.replace`/`Path.replace` atomicity guarantee on POSIX).
2. Single-shot `write_text` to tmp (not append, not chunked).
3. `tmp_path.replace(self._log_path)` — atomic on POSIX, near-atomic on Windows ≥10 with NTFS.
4. UTF-8 explicit on both write and read (cross-references ADR-008 in `docs/onboarding/04-ADR-LOG.md` l.19).

The pattern is the canonical "crash-safe markdown log write" — `agent-workspace/memory/sessions/*.md`, `mistake-log.md`, `agent-notes.md`, and `current-execution.md` are all candidates. The harness today writes these with vanilla open(...,"w") and can corrupt mid-write if a session aborts.

### W0-4 — HTML-comment separator pattern

Source = the `_SEPARATOR` class constant in the same file:

- `memory.py` l.13-14:
  ```python
  # HTML comment: cannot appear in LLM prose output, safe as a hard delimiter
  _SEPARATOR = "\n\n<!-- ENTRY_END -->\n\n"
  ```
- Used as a delimiter for both write (l.48: `entry = f"{tag}\n\nDECISION:\n{final_trade_decision}{self._SEPARATOR}"`) and parse (l.59: `text.split(self._SEPARATOR)`).
- Used by both atomic-write methods (l.160 and l.214) to round-trip the file: split → modify blocks → `_SEPARATOR.join`.

**Doctrine surface area for StockForge harness adoption (W0-4 lift):**
- `<!-- ... -->` is HTML markup which the LLM **cannot** emit inside markdown prose (LLMs see it but render swallows it), so the delimiter is forgery-proof against agent output.
- Renders invisible in any markdown viewer (Obsidian, GitHub, VS Code preview) — so an entry-segmented log still reads as a single document to the human.
- Multi-character, multi-line ASCII (`\n\n<!-- ENTRY_END -->\n\n`) → low collision risk on `str.split`.

Direct fit: any StockForge memory file that is an append-only collection of "entries" can adopt this delimiter. Candidates: `mistake-log.md` (M-S<N>-<M> entries), `agent-notes.md` (lesson digests), `thesis-log/*.md`, session-rollup TSVs (but TSVs don't need this — markdown-only).

### Other patterns claimed in prior S259 work (re-verification while here)

- **5-tier rating vocabulary + heuristic parser** (`tradingagents/agents/utils/rating.py` l.18-50). Maps to StockForge's "structured output, not narrative" charter rule. Not harness substrate — domain-layer pattern, listed in § 3 below.
- **Reflection-loop architecture** (`tradingagents/graph/reflection.py` l.6-53 + `trading_graph.py` l.229-263 `_resolve_pending_entries`). Defers reflection until outcome is known (yfinance return + alpha vs SPY), then writes back to the log. Maps to charter "calibration over confidence". Listed in § 3.
- **Per-agent state TypedDict** (`agents/utils/agent_states.py` l.7-43 — `InvestDebateState`, `RiskDebateState`). Maps to BC-8 debate-state contract. Listed in § 3.

## 1. Repo Summary

- **Identity**: TradingAgents v0.2.4 (pyproject.toml l.7) — multi-agent LLM trading framework from Tauric Research (arXiv 2412.20138, README.md l.6-9).
- **License**: Apache-2.0 (LICENSE l.1-201). Permissive, compatible with StockForge lift-and-adapt under attribution.
- **Maturity**: 12 documented ADRs covering 2025-06 → 2026-04 (`docs/onboarding/04-ADR-LOG.md` l.10-23). Apache-2.0 + active development. v0.2.4 (April 2026) adds structured-output agents, LangGraph checkpoint resume, persistent decision log (README.md l.31).
- **Posture**: "Research framework. Trading performance may vary … not intended as financial, investment, or trading advice." (README.md l.65). Matches StockForge's "research aid, not financial advice" framing.
- **Stack**: Python 3.10+, LangGraph (StateGraph orchestration), LangChain providers (OpenAI, Anthropic, Google, xAI, DeepSeek, Qwen, GLM, Ollama, Azure, OpenRouter), yfinance + Alpha Vantage for market data, SQLite via `langgraph-checkpoint-sqlite` (pyproject.toml l.11-33).
- **Onboarding docs**: Vietnamese-language docs/onboarding/ exists (12 files, 01-PROJECT-CHARTER through 12-ONBOARDING-TRACK + README-EXEC). HLD at l.1-50 of 02-HLD.md confirms the pipeline shape.

## 2. Architecture / Design Patterns

The framework is a **LangGraph StateGraph pipeline** with three sequential debate phases. Source: `tradingagents/graph/setup.py` l.29-182, `trading_graph.py` l.50-394.

### 2.1 Pipeline shape (StateGraph topology)

From `setup.py` l.110-180:

```
START → [Market | Social | News | Fundamentals] Analyst (sequential, each with tool loop)
      → Bull Researcher ⇄ Bear Researcher (round-robin debate, max_debate_rounds × 2 turns)
      → Research Manager (judge — emits structured ResearchPlan)
      → Trader (emits structured TraderProposal)
      → Aggressive Analyst → Conservative Analyst → Neutral Analyst (round-robin, max_risk_discuss_rounds × 3 turns)
      → Portfolio Manager (judge — emits structured PortfolioDecision)
      → END
```

Conditional-edge logic at `tradingagents/graph/conditional_logic.py` l.46-67. Termination is count-based, not consensus-based — debate runs a fixed number of rounds then the manager-judge synthesises.

### 2.2 Debate-style synthesis primitives (Theme H key evidence)

Two distinct debate stages, both implemented as **shared-state round-robin** rather than isolated parallel calls:

**A. Investment debate (2 agents — bull vs bear):**
- `agents/researchers/bull_researcher.py` l.3-48
- `agents/researchers/bear_researcher.py` l.3-50
- Shared state: `InvestDebateState` (`agent_states.py` l.7-17) with `history`, `bull_history`, `bear_history`, `current_response`, `count`.
- Each agent's prompt **reads `history` and `current_response` from the opposing side** before generating (bull: l.28-31 reads "Last bear argument: {current_response}"). Output is appended to both `history` and the agent's own `*_history`.
- Termination: `should_continue_debate()` at `conditional_logic.py` l.46-55 — toggles bull/bear until `count >= 2 * max_debate_rounds`.
- Judge: `agents/managers/research_manager.py` l.13-65 — reads `history`, emits structured `ResearchPlan` (`schemas.py` l.61-90) via `bind_structured` + `invoke_structured_or_freetext` fallback.

**B. Risk debate (3 agents — aggressive / conservative / neutral):**
- `agents/risk_mgmt/aggressive_debator.py` l.3-53
- `agents/risk_mgmt/conservative_debator.py` l.3-55
- `agents/risk_mgmt/neutral_debator.py` (3rd voice)
- Shared state: `RiskDebateState` (`agent_states.py` l.21-43) — per-agent histories + `latest_speaker` + per-agent `current_*_response`.
- Each agent reads **both** opposing positions before speaking (aggressive: l.27-29 reads `current_conservative_response` + `current_neutral_response`).
- Termination: `should_continue_risk_analysis()` at `conditional_logic.py` l.57-67 — rotates aggressive→conservative→neutral until `count >= 3 * max_risk_discuss_rounds`.
- Judge: `agents/managers/portfolio_manager.py` l.24-92 — reads `history` + investment plan + trader plan + past-context lessons, emits structured `PortfolioDecision` (`schemas.py` l.171-206).

**Key contrast vs ai-hedge-fund "isolated then aggregate" pattern** (the Theme H decision):

| Property | TradingAgents (debate) | ai-hedge-fund (isolated, hypothesised) |
|---|---|---|
| Inter-agent context | Each agent **sees opposing arguments** before generating | Each agent runs in isolation against same data |
| State coupling | Shared `*_history` accumulator (`InvestDebateState.history`) | None — outputs concatenated post-hoc |
| Termination | Round count (deterministic, not convergence-based) | Single-shot |
| Synthesis | Separate "judge" agent reads full debate transcript | Aggregator reduces independent verdicts (weighted vote / score) |
| Transparency for I-S12 | Debate history is verbatim — disagreement is **the artefact**, not erased | Per-agent verdicts preserved but no cross-rebuttal |
| Latency cost | N × rounds × agents LLM calls | N agents × 1 call (constant) |
| Token cost | Quadratic-ish (history grows each round) | Linear |
| Determinism | Lower — outputs depend on which side speaks first + round count | Higher — agents are order-independent |

**Implication for StockForge I-S11/I-S12**: TradingAgents' debate style directly produces a verbatim disagreement transcript (`investment_debate_state.history` is stored in the final state JSON at `trading_graph.py` l.359-369). This is a **literal "disagreement surfaced, not resolved"** artefact — exactly what I-S12 wants. The judge synthesises but the raw debate is preserved as evidence. ai-hedge-fund's isolated-then-vote pattern erases the rebuttal dynamic.

### 2.3 Agent-prompt template structure

Two distinct prompt styles in the codebase:

**Tool-using analysts** (e.g. `agents/analysts/market_analyst.py` l.11-88):
- Uses `langchain_core.prompts.ChatPromptTemplate` with `system_message` placeholder.
- Tool wiring via `llm.bind_tools(tools)` then `prompt | llm.bind_tools(tools)` chain composition (l.74).
- Tool-call loop driven by `should_continue_market` conditional (`conditional_logic.py` l.14-20).
- Language injection via `get_language_instruction()` helper (l.49) — runtime locale switch.
- `instrument_context` injected at prompt-partial time (l.72) — separates static system instructions from per-run context.

**Debate / decision agents** (e.g. `agents/researchers/bull_researcher.py`):
- Plain f-string prompt assembled inside the node function (no ChatPromptTemplate, no tools).
- All four analyst reports + opposing-side current response + debate history are formatted directly into the prompt (l.15-32).
- Output is plain `llm.invoke(prompt).content` for non-structured agents (l.34); structured agents use `invoke_structured_or_freetext` (`agents/utils/structured.py` l.48-73).

### 2.4 Structured-output pattern (decision agents)

Source: `agents/utils/structured.py` l.31-73 + `agents/schemas.py` l.1-228.

- `bind_structured(llm, schema, agent_name)` wraps the LLM via `llm.with_structured_output(schema)` (l.37-45) — returns None if provider doesn't support it.
- `invoke_structured_or_freetext` (l.48-73) — runs structured call; on **any** exception (malformed JSON, transient provider error) falls back to plain `llm.invoke(prompt)` so pipeline never blocks (l.66-73).
- Three schemas: `ResearchPlan` (5-tier rating + rationale + strategic_actions), `TraderProposal` (3-tier action + reasoning + entry/stop/sizing), `PortfolioDecision` (5-tier rating + executive_summary + investment_thesis + price_target + time_horizon).
- Each schema has a `render_*` helper (e.g. `render_pm_decision` l.209-228) that converts Pydantic → markdown for downstream memory log + saved reports — preserves the exact section-header shape regex-parsers already expect.

ADR-004 (`docs/onboarding/04-ADR-LOG.md` l.71-82) records this as the explicit replacement for prose-regex parsing — explicitly addressing "fragile prompt wording" risk.

### 2.5 Memory log + reflection loop

Source: `tradingagents/agents/utils/memory.py` (full file, 301 LOC) + `tradingagents/graph/reflection.py` l.6-53 + `trading_graph.py` l.229-348.

- Decision log is markdown, append-only, at `~/.tradingagents/memory/trading_memory.md` (overridable via `TRADINGAGENTS_MEMORY_LOG_PATH`).
- Each entry: tag-line `[YYYY-MM-DD | TICKER | rating | pending]` + `DECISION:` block + (later) `REFLECTION:` block + `<!-- ENTRY_END -->` separator.
- **Phase A — write at end of run**: `store_decision()` l.31-50 — idempotency guard via fast raw-text scan (l.41-45) avoids duplicate entries.
- **Phase B — resolve at start of next same-ticker run**: `_resolve_pending_entries()` (`trading_graph.py` l.229-263) → `_fetch_returns()` l.191-227 fetches yfinance return + SPY alpha → `Reflector.reflect_on_final_decision()` (`reflection.py` l.31-53) emits 2-4 sentence reflection → `batch_update_with_outcomes()` atomic write.
- Past context injection: `get_past_context()` l.71-96 — 5 same-ticker entries + 3 cross-ticker lessons → injected into Portfolio Manager prompt at `portfolio_manager.py` l.35-40.
- ADR-005 (`docs/onboarding/04-ADR-LOG.md` l.86-96) records this explicitly replaced an earlier ChromaDB + BM25 per-agent embedding-memory design — chose markdown + atomic write over vector DB.

### 2.6 Checkpoint resume

Source: `tradingagents/graph/checkpointer.py` l.1-91.

- Per-ticker SQLite DB at `~/.tradingagents/cache/checkpoints/<TICKER>.db` (l.19-25).
- Deterministic thread ID via `hashlib.sha256(f"{ticker.upper()}:{date}".encode())[:16]` (l.28-30) — same ticker + date resumes, different date starts fresh.
- Context-manager pattern wraps SqliteSaver (l.33-43).
- ADR-006 documents the choice of per-ticker DB over single global DB for concurrency.

## 3. Components / Features candidate for StockForge adoption

| # | Pattern | Source file:lines | StockForge fit | Wave |
|---|---|---|---|---|
| C1 | **Atomic temp-file-replace** | `agents/utils/memory.py` l.109-163, l.215-217 | Harness substrate — every append-only memory file | W0-3 (already queued) |
| C2 | **HTML-comment separator** | `agents/utils/memory.py` l.13-14 | Harness substrate — entry-segmented memory files | W0-4 (already queued) |
| C3 | **Debate-style synthesis (LangGraph round-robin)** | `agents/researchers/{bull,bear}_researcher.py` + `agents/risk_mgmt/*_debator.py` + `conditional_logic.py` l.46-67 | BC-8 multi-perspective adversarial — Theme H comparison vs ai-hedge-fund | Wave-1 IMPL candidate |
| C4 | **Shared debate-state TypedDict** | `agents/utils/agent_states.py` l.7-43 (`InvestDebateState`, `RiskDebateState`) | BC-8 debate-state contract (DDD: shared between debate participants + judge) | Wave-1 IMPL |
| C5 | **Structured-output schema + free-text fallback** | `agents/utils/structured.py` l.31-73 + `agents/schemas.py` l.1-228 | BC-8 decision-agent output contract; satisfies charter "structured, not narrative" | Wave-1 IMPL |
| C6 | **5-tier rating + heuristic parser** | `agents/utils/rating.py` l.18-50 | BC-8 rating vocabulary (replaces binary "buy/sell" anti-pattern) | Wave-1 IMPL |
| C7 | **Render-back-to-markdown helper** | `agents/schemas.py` l.93-101, l.141-163, l.209-228 | Bidirectional contract: structured for code, markdown for memory log + human | Wave-1 IMPL |
| C8 | **Reflection / outcome resolution loop** | `graph/reflection.py` l.31-53 + `trading_graph.py` l.229-263 | Calibration over confidence — needs VN return source (HoSE/HNX, not yfinance/SPY) | Wave-2 candidate |
| C9 | **Past-context injection (memory log → judge prompt)** | `agents/utils/memory.py` l.71-96 + `agents/managers/portfolio_manager.py` l.35-40 | Cross-session continuity for adversarial debate | Wave-2 candidate |
| C10 | **LangGraph checkpoint resume (per-ticker SQLite)** | `graph/checkpointer.py` l.1-91 | Long-running BC-8 debate recovery | Wave-2 candidate (only if VN backtest depths require it) |
| C11 | **Idempotency guard via fast raw-text scan** | `agents/utils/memory.py` l.41-45 | Harness — prevents duplicate appends on retry | Wave-0 candidate (small lift) |
| C12 | **Precompiled regex as class constants** | `agents/utils/memory.py` l.16-17 (`_DECISION_RE`, `_REFLECTION_RE`) | Harness — pattern for any hot-path parser | Wave-0 micro-pattern |
| C13 | **`safe_ticker_component()` path-traversal hardening** | `tradingagents/dataflows/utils.py` (referenced from `trading_graph.py` l.382-384) + `graph/checkpointer.py` l.21-25 | Harness — applies to any user-input-derived path component | Wave-0 candidate (small lift) |

## 4. Per-BC Mapping

### BC-8 (Multi-perspective adversarial synthesis) — PRIMARY FIT

- **Direct lift candidates**: C3, C4, C5, C6, C7 (debate framework + rating + structured output + render-back).
- **Adaptation gap**: TradingAgents has 2-agent + 3-agent debate; StockForge charter wants ≥4 perspectives (bull / bear / quant / behavior / macro / manager). Topology is generalisable — `setup.py` `add_node` + `add_conditional_edges` calls are mechanical and can be extended to N perspectives by adding nodes + extending `should_continue_*` rotation logic at `conditional_logic.py` l.57-67. The pattern scales.
- **Required VN extensions**: Add "macro" perspective for SBV policy; add "behavior" perspective for retail-flow sentiment; add "regulation" perspective for HoSE/HNX rule events. None of these exist in TradingAgents — must be authored fresh for StockForge.

### BC-3 (Memory / continuity) — PARTIAL FIT

- C8 (reflection loop), C9 (past-context injection) match BC-3's outcome→reflection→reuse loop.
- yfinance + SPY return path (`trading_graph.py` l.200-220) is US-only; must be replaced with HoSE/HNX (e.g. via vnstock or direct SSI/VND data path) before lift. ADR-005 evidence shows this is the correct intent but wrong data source for VN.

### BC-1 (Bounded-context infrastructure / harness) — SUBSTRATE FIT

- C1, C2, C11, C12, C13 are domain-agnostic harness improvements. They are already queued as Wave-0 (W0-3 + W0-4) and complementary micro-patterns.

### NOT a fit

- BC-2 (data ingestion): TradingAgents uses yfinance/Alpha Vantage — wrong vendors for VN.
- BC-5 (UI / dashboard): TradingAgents has Rich CLI; Streamlit dashboard is StockForge's choice.
- BC-7 (signal extraction): TradingAgents leans on technical indicators (MACD, RSI, BB) which is just standard pandas/stockstats — no novel patterns to lift.

## 5. Honest Fit Assessment

**Hypothesis confirmation**: HIGH fit holds empirically.

**Strengths (why HIGH)**:
1. Debate-style synthesis (C3+C4+C5) is **the** archetypal implementation of charter principle 3 ("adversarial by design") and gives I-S12 ("disagreement surfaced, not resolved") a literal artefact — `investment_debate_state.history` is saved verbatim in the final JSON. ai-hedge-fund's hypothesised isolated-then-aggregate erases this. **Theme H verdict from this evidence: debate-style is the principled fit, not isolated-then-vote.**
2. Structured-output + free-text fallback (C5+C7) cleanly satisfies "structured, not narrative" without forcing brittle JSON-only prompts.
3. Apache-2.0 license permits lift with attribution — no copyleft contamination.
4. The repo is mature (12 ADRs, 0.2.4) and has a battle-tested fallback path (free-text on structured-output failure).

**Risks / mismatches (why not stronger than HIGH)**:
1. **US-stock assumption pervasive in data path** (see § 7 below).
2. **Debate cost scales quadratically**. `max_debate_rounds=1` default = 2 LLM calls; `max_risk_discuss_rounds=1` = 3 calls; total 5 LLM calls per ticker per run for debate alone, plus 4 analysts + 2 judges + trader = 12+ calls. With Anthropic subscription billing this is fine; with API billing it stings. Acceptable for StockForge's single-tenant 3-5 user posture.
3. **History grows each turn** (l.39 bull node: `history + "\n" + argument`). For longer debates, prompts inflate. TradingAgents doesn't truncate — at 4+ rounds and 8K+ token reports, the judge's prompt gets large. Mitigation: cap rounds, or summarise pre-judge.
4. **LangGraph dependency is heavy** (pyproject.toml l.18-19: `langgraph>=0.4.8`, `langgraph-checkpoint-sqlite>=2.0.0`). Charter has not yet adopted LangGraph — IMPL decision required. Alternative: write the StateGraph-equivalent in plain Python (the topology is ~50 lines, the conditional-edge logic is ~20 lines, the state TypedDicts are 40 lines — total ~110 LOC vs full LangGraph dep). Worth empirically probing per L-S32-1.
5. **No native VN-overlay**. Foreign-flow gating, ATO/ATC handling, sàn-tier rules (I-S55..I-S65) are not modelled. Must be added as new perspective-agents in the BC-8 lift.
6. **Determinism note**: round-count termination is deterministic but **first-speaker-bias** is real (bull always speaks first → bear always rebutts → judge reads bear-last argument freshest). For symmetric perspectives StockForge wants, may need randomised first-speaker.

**Net verdict**: HIGH stays. Lift C1+C2 as substrate (W0-3, W0-4, already queued). Lift C3+C4+C5+C6+C7 as Wave-1 IMPL with adaptations: (a) extend perspective count to ≥4, (b) reauthor data layer for VN, (c) decide LangGraph-or-plain-Python via empirical probe (L-S32-1).

## 6. License + Attribution

- **License**: Apache-2.0, file `LICENSE` l.1-201. Copyright "Tauric Research".
- **Citation requested** (README.md l.262-271): arXiv 2412.20138 — Xiao, Sun, Luo, Wang, 2025. StockForge should attribute in any IMPL-session ADR that lifts patterns C1–C13, e.g.:
  > Pattern adapted from TradingAgents v0.2.4 (Tauric Research, Apache-2.0). See `tradingagents/agents/utils/memory.py` for the original.
- **Trademark**: Apache-2.0 § 6 — does not grant use of "TradingAgents" / "Tauric Research" trademarks. StockForge names its own components.
- **Attribution placement**: Charter likely wants a `THIRD_PARTY_NOTICES.md` or per-file NOTICE comment. Defer to next IMPL ADR.

## 7. Risks / Anti-patterns to avoid

### 7.1 VN-overlay must NOT be displaced

The framework's data layer is **US-stock-only**:
- yfinance default (`default_config.py` l.41-45) — Yahoo Finance has poor VN coverage.
- SPY benchmark for alpha (`trading_graph.py` l.206, l.216-218) — wrong benchmark; VN uses VN-Index / VN30.
- Trading-day calendar implicit in `holding_days + 7` buffer (`trading_graph.py` l.202) — assumes US 5-day week; HoSE/HNX have different holiday set.
- No notion of ATO/ATC sessions, foreign-ownership-room cap, sàn-tier (HoSE vs HNX vs UPCoM listing rules), price-band rules (±7% HoSE, ±10% HNX). I-S55..I-S65 must be added as explicit guards either in data layer (block ineligible analysis) or in agent prompts (each agent told the constraints).

**Anti-pattern to refuse**: lift the data layer wholesale and re-route to a "VN-equivalent vendor". This loses VN-specific structure (T+2.5 settlement, tick-size rules, GTC/IOC/FOK limitations). Instead: lift only the **orchestration shape** (graph topology, state TypedDicts, debate-state, structured output). Re-author dataflows/ from scratch against vnstock + SSI + VND.

### 7.2 First-speaker bias

`should_continue_debate` (`conditional_logic.py` l.51-55) always starts with Bull Researcher (because of `setup.py` l.134 edge: `current_clear → "Bull Researcher"`). This biases the judge's recency-window. For a symmetric 4+ perspective StockForge debate (bull / bear / quant / behavior), randomise first speaker, or rotate over runs.

### 7.3 Token bloat from `history` accumulation

`investment_debate_state.history` is concatenated with each turn (l.39 bull, l.41 bear, similar for risk). At 2 rounds × 2 agents × 3K-token argument = 12K history tokens before judge reads it. Cap rounds at design time; for I-S11 ≥4 perspectives × ≥2 rounds, design a summarisation step before the judge.

### 7.4 LLM-math creep

Each agent prompt asks for prose interpretation, but charter forbids the LLM from emitting computed numbers. TradingAgents passes raw market-data text into the prompt and asks the LLM to interpret — which **is** safe under charter rule "LLM only interprets". However the structured-output schemas have `entry_price: Optional[float]` (schemas.py l.127) and `price_target: Optional[float]` (schemas.py l.199) which **could** be filled by LLM. StockForge IMPL must either (a) ban these fields, or (b) require them to echo a code-computed value (no LLM arithmetic). Audit point.

### 7.5 Reflection loop's "LLM judges past LLM"

`Reflector.reflect_on_final_decision()` (`reflection.py` l.31-53) reads the final-decision prose + actual return + alpha → emits a 2-4 sentence "lesson". This is **LLM judging LLM** with one external grounding (the return number). For calibration purposes the return is real, but the lesson is LLM prose — it can drift, recency-bias, and confirmation-bias. Don't take reflections as truth; track which reflections actually correlated with future correct calls (a meta-calibration loop). Acceptable as written but flag for Wave-2 hardening.

### 7.6 Deterministic termination ≠ consensus

Both debates terminate by round-count, not by convergence/disagreement-measure. The judge can be forced to synthesise a still-unresolved disagreement. This is **the right answer** under I-S12 (don't force resolution) — but StockForge should be explicit: the judge's role is to surface tradeoffs, not adjudicate. TradingAgents' Research Manager prompt (`research_manager.py` l.22-40) does say "Commit to a clear stance whenever … warrant one; reserve Hold for … genuinely balanced" — adapt to StockForge's framing ("surface the tradeoff, recommend a thesis exploration, not a buy/sell").

---

**Self-attestation**: every claim cites a specific file in the repo.
