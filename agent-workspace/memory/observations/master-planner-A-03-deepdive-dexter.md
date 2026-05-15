---
observation_id: master-planner-A-03-deepdive-dexter
session: S323-A-phase-a-deepdive
agent: general-purpose
date: 2026-05-15
repo: dexter
repo_path: C:/htdocs/research/dexter/
fit_level_hypothesis: MEDIUM
fit_level_empirical: MEDIUM
license: MIT (declared in `README.md:178-180`; no top-level LICENSE file present in repo root — only README declaration)
---

## 1. Repo Summary (README + docs/ entry)

Dexter is an **autonomous financial research agent in a terminal**, marketed as "Claude Code, but built specifically for financial research" (`README.md:3`). Stack: **TypeScript + Bun runtime + Ink/React for CLI + LangChain abstraction** (`AGENTS.md:4`, `package.json:20-41`). The agent decomposes a financial question into a research plan, executes tool calls iteratively (default max 10 iterations per `src/agent/agent.ts:24`), self-validates, and emits an evidence-backed answer.

Core flow (`src/agent/agent.ts:105-266`): `Agent.run(query)` is an async generator that loops: build messages → microcompact → call LLM (streaming with blocking fallback) → execute tools concurrently → push ToolMessages → context-threshold management → drain queued user injections. Provider-agnostic (`src/providers.ts`, env supports OpenAI/Anthropic/Google/xAI/OpenRouter/Ollama/Moonshot/DeepSeek per `env.example:1-8`). Default model `gpt-5.4` (`src/agent/agent.ts:23`).

Domain target = **US public equities** via `FINANCIAL_DATASETS_API_KEY` → `api.financialdatasets.ai` (`src/tools/finance/api.ts:4`, `env.example:18`). Out-of-scope for VN market without data-provider swap.

Onboarding docs in `docs/onboarding/*` (12 files: charter, HLD, LLD, ADR log, data model, etc.) written in Vietnamese — clearly a documentation generator output, not original; treat as derived not canonical.

## 2. Architecture / Design Patterns (top 3-5)

1. **Iterative tool-calling loop with growing message array** (`src/agent/agent.ts:105-266`). Single source of truth = the `BaseMessage[]` array; tools yield events; loop exits on no-tool-call response. Mirrors Claude Code / Anthropic agent loop.
2. **Two-tier context management — microcompact + full compact** (`src/agent/microcompact.ts:1-80`, `src/agent/compact.ts:1-100`). Microcompact = cheap per-turn marker-replacement of old read-only ToolMessage content (`COUNT_TRIGGER_THRESHOLD = 8`, `TOKEN_TRIGGER_THRESHOLD = 80_000`). Full compact = LLM-summarization of accumulated tool results with a structured 9-section prompt (Original Query / Key Concepts / Data Retrieved / Errors / Analysis Progress / **Numerical Data** / Pending Data Needs / Current Work State / Recommended Next Steps).
3. **Skill registry — markdown-frontmatter skills auto-discovered** (`src/skills/registry.ts:31-77`, `src/tools/skill.ts:37-74`). `SKILL.md` files with YAML frontmatter (`name`, `description`) scanned at startup from builtin + project dirs; skill metadata injected into system prompt; LLM invokes via `skill` tool; relative markdown links auto-resolved to absolute paths.
4. **Hybrid persistent memory with vector + BM25 + MMR + temporal decay** (`src/memory/index.ts:18-33`, `src/memory/temporal-decay.ts:21-38`, `src/memory/mmr.ts:28-57`). SQLite (`better-sqlite3`) + Markdown files. Default config: `vectorWeight 0.7`, `textWeight 0.3`, `halfLifeDays 30`, `mmr.lambda 0.7`. Note: temporal-decay + MMR explicitly ported from "Openclaw (MIT licensed)" per `src/memory/temporal-decay.ts:9`, `src/memory/mmr.ts:7`.
5. **Append-only JSONL scratchpad per query** (`src/agent/scratchpad.ts:55-101`). Each query writes `.dexter/scratchpad/<timestamp>_<md5-hash>.jsonl` with entries `init`, `tool_result`, `thinking`. Provides debuggability + replay surface — orthogonal to in-memory context management.

Bonus pattern: **meta-tool / sub-tool routing**. `get_financials` is a LangChain LLM-driven router (`src/tools/finance/get-financials.ts:60-79`) that dispatches to 9 sub-tools (fundamentals, key-ratios, estimates, earnings, segments…). Single user-facing tool surface; internal complexity hidden via LLM-as-router.

## 3. Components / Features candidate for StockForge adoption (pattern-only adoption candidates given stack mismatch)

- **Two-tier compaction (microcompact + full compact)** → port the *pattern* (cheap marker-replacement before expensive summarization) into BC-8 thesis agent loop in Python. Could pair with `agent-workspace/proposals/memory-tiers.md`.
- **9-section structured compaction prompt** (`src/agent/compact.ts:45-100`) — the explicit "Numerical Data" section directly answers StockForge's NO-LLM-MATH invariant (forces preservation of source numbers across summarization). High-value prompt-engineering pattern.
- **SKILL.md auto-discovery with frontmatter** → already echoed in StockForge `.claude/skills/*/SKILL.md`, but Dexter's pattern of relative-link resolution (`src/tools/skill.ts:60-68`) is a clean port-candidate for multi-file skills.
- **DCF skill workflow** (`src/skills/dcf/SKILL.md`) — 8-step checklist with sector-WACC adjustment table (`src/skills/dcf/sector-wacc.md`). Adapt for VN-market sectors (with VN risk-free rate + VN equity-risk premium); aligns with BC-8 thesis/valuation needs. **Pattern**, not code.
- **X (Twitter) research skill** (`src/skills/x-research/SKILL.md`) — research-loop decomposition (decompose → execute → check key accounts → follow threads → synthesize by theme). Reusable as template for VN influencer research (BC-6) on Vietnamese platforms (Facebook fanpage, YouTube).
- **JSONL append-only scratchpad** — single-source-of-truth pattern with debuggability. Maps to StockForge thesis log pattern.
- **Web-fetch vs browser tool split** (`src/tools/browser/browser.ts:30-50`) — explicit "prefer cheap fetch over expensive browser" guard in tool description. Pattern for BC-5 news ingestion cost control.

## 4. Per-BC Mapping

| BC | Dexter mapping | Strength |
|---|---|---|
| BC-1 Market Data | `get_market_data` tool (`src/tools/finance/get-market-data.ts`) + `stock-price.ts` — but bound to financialdatasets.ai (US only) | LOW (data binding) / MEDIUM (interface pattern) |
| BC-2 Fundamentals | `get_financials` meta-tool + sub-tools (`fundamentals.ts`, `key-ratios.ts`, `estimates.ts`, `segments.ts`, `earnings.ts`) | LOW (US-only) / MEDIUM (meta-tool routing pattern) |
| BC-3 Reports/PDF | `read_filings` (`src/tools/finance/read-filings.ts`) — SEC 10-K/10-Q/8-K only, no VN equivalent (VN files at HOSE/HNX) | LOW (no overlap) / LOW pattern (SEC-specific item codes) |
| BC-4 Macro/Policy | Not addressed in Dexter | NONE |
| BC-5 News | `web_search` (Exa/Perplexity/Tavily fallback, `src/tools/search/`), `web_fetch`, `browser` (Playwright) | MEDIUM (search-provider fallback pattern, browser-vs-fetch split) |
| BC-6 Influence | `x_search` + `x-research` SKILL.md — but X/Twitter API gated on `X_BEARER_TOKEN`; pattern transferable to VN KOL research (Facebook/YouTube) | MEDIUM (pattern only) |
| BC-7 Crowd | Partial via `x-research` SKILL.md (sentiment themes, bullish/bearish/neutral grouping) | LOW (US-X-centric, not VN F319/Vietstock forum) |
| BC-8 Analysis & Thesis | DCF skill + two-tier compaction + memory + skill-tool pattern — Dexter is **single-perspective**, not adversarial; SOUL.md frames as Buffett-Munger lens only | MEDIUM (mechanics) / LOW (philosophy — fails multi-perspective adversarial Charter rule) |
| BC-9 Portfolio & Action | Not addressed — Dexter explicitly "not a trade-execution tool" (`docs/onboarding/01-PROJECT-CHARTER.md:7`) | NONE |

## 5. Honest Fit Assessment (FIT vs hypothesis)

**Empirical fit = MEDIUM** (matches hypothesis). Justification:

**Stack mismatch is REAL but NOT FATAL** — TypeScript + LangChain on Bun; StockForge is Python-primary. Code-port is uneconomic. However, the *patterns* (two-tier compaction, structured compaction prompt with Numerical-Data section, MMR + temporal decay re-ranking with documented `halfLifeDays`/`lambda` defaults, SKILL.md frontmatter discovery, meta-tool routing, JSONL scratchpad) are language-agnostic and high-value.

**Domain mismatch is REAL** — Dexter's data tools point at financialdatasets.ai (US equities, SEC filings). Zero VN market binding. Re-implementing get_financials/read_filings against VN sources (SSI/vnstock for prices, HOSE/HNX for filings) is essentially writing from scratch.

**Philosophy partial-mismatch** — SOUL.md frames Dexter as a Buffett-Munger value-investor lens. Single-perspective. StockForge Charter mandates **multi-perspective adversarial** (bull + bear + neutral) and **calibration over confidence**. Dexter's compaction prompt does preserve numerical data (good fit with NO-LLM-MATH invariant), but the agent identity is opinionated-single-lens — StockForge would need a multi-agent or multi-prompt wrapper.

**Net: MEDIUM**. Pattern-adoption candidate; no code-port. Two specific themes (H = compaction strategy, K = skill-tool pattern from master-plan §4.3) are most actionable.

## 6. License + Attribution

- **Declared MIT** in `README.md:178-180` ("This project is licensed under the MIT License.").
- **No top-level LICENSE file** present (`ls -la C:/htdocs/research/dexter/` confirms — only `.git`, `.gitignore`, AGENTS.md, README.md, SOUL.md, package.json, src/, docs/, scripts/, tsconfig.json, env.example, jest.config.js, bun.lock, package-lock.json).
- **Risk**: MIT declaration without a LICENSE file is informal. Before *any* code lift, must (a) confirm with upstream maintainer (virattt — `package.json` repo URL: github.com/virattt/dexter via `AGENTS.md:3`); (b) record attribution in StockForge with file-path + commit-hash citation.
- **Upstream attribution example already inside Dexter** (`src/memory/temporal-decay.ts:9`, `src/memory/mmr.ts:7`): "Ported from Openclaw (MIT licensed)". This is the attribution pattern to copy if porting from Dexter.

## 7. Risks / Anti-patterns to avoid (TypeScript-Python idiom transfer gotchas)

- **`async function*` (async generators)** — heavily used in `agent.ts`, `tool-executor.ts` to yield streaming events. Python equivalent = `async def` + `yield` (PEP 525), but consumer-side `for await … of` translates to `async for … in`. Threading model differs (JS event loop ≠ Python asyncio); don't 1:1 transcribe.
- **LangChain TS vs LangChain Python** — APIs diverge (`StructuredToolInterface` vs `BaseTool`, `AIMessage`/`ToolMessage` shapes, streaming semantics). Don't assume parity. For StockForge, **prefer not adopting LangChain at all** — its abstraction layer adds dependency surface for marginal benefit when calling Claude API directly is straightforward.
- **`bindTools` semantics differ across providers in TS** (`src/model/llm.ts` per `AGENTS.md:50`) — `FAST_MODELS` map, Anthropic-specific `cache_control` injection. Python claude-api skill in StockForge already handles prompt caching; do not re-invent.
- **Zod schemas (TS)** ↔ **Pydantic / dataclasses (Python)** — direct port tempting but Pydantic in domain layer is **explicitly forbidden** by StockForge CLAUDE.md ("Domain layer has ZERO framework dependency… use dataclasses"). Keep Zod-style schemas at adapter layer, not domain.
- **`process.env` reads scattered across tool files** (registry.ts:145, 153, 161, 171; api.ts:43; embeddings.ts) — anti-pattern from `agent-workspace/constitution/architecture.md` perspective. Centralize via single config provider in port.
- **Single-perspective SOUL.md identity** — copying SOUL.md into StockForge would violate Charter's multi-perspective-adversarial rule. If borrowing the *identity-document pattern*, instantiate **multiple personas** (bull-analyst, bear-analyst, neutral-quant) not one.
- **`scratchpad/` JSONL on disk** — Dexter writes one file per query at `.dexter/scratchpad/<timestamp>_<hash>.jsonl`. StockForge equivalent must respect `current-execution.md` 200-LOC inline cap + telemetry rotation (per CLAUDE.md "Tracking retention" rule). Don't blindly mirror Dexter's unbounded-growth pattern.
- **DCF sector-WACC table is US-market-calibrated** (`sector-wacc.md:11-23`) — risk-free 4%, equity-risk-premium 5-6%. VN equivalents are materially different (VN 10Y bond yields, VN-specific equity-risk premium). Don't copy numbers; copy *table structure* only.
- **Max-iterations = 10 hardcoded** (`agent.ts:24`) — too low for complex multi-perspective thesis sessions. StockForge BC-8 thesis sessions are budgeted up to 100K tokens (`CLAUDE.md` session types) — calibrate per session-type, not a single global.

---

Self-attestation: every claim cites a specific file in the repo.
