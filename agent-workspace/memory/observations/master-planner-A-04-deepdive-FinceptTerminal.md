---
observation_id: master-planner-A-04-deepdive-FinceptTerminal
session: S323-A-phase-a-deepdive
agent: general-purpose
date: 2026-05-15
repo: FinceptTerminal
repo_path: C:/htdocs/research/FinceptTerminal/
fit_level_hypothesis: MEDIUM
fit_level_empirical: LOW
license: AGPL-3.0 (dual-licensed; Commercial License REQUIRED for internal/business use, USD 10,200/year)
---

## 1. Repo Summary

Fincept Terminal v4 is an open-source Bloomberg-Terminal-class desktop app. Tagline: "Your Thinking is the Only Limit. The Data Isn't." Native C++20 + Qt6 single binary; embedded Python 3.11 for analytics; SQLite for local persistence (`C:/htdocs/research/FinceptTerminal/README.md:21,44`).

Stack from `docs/ARCHITECTURE.md:48-58`:
- Language: C++20; UI: Qt6 Widgets + Qt6 Charts; Networking: Qt6 Network + WebSockets; Persistence: Qt6 Sql (SQLite); Build: CMake 3.27.7 + Ninja; Python: 3.11.9 (embedded via `QProcess`).
- Pinned toolchain (`docs/CPP_CONTRIBUTOR_GUIDE.md:14-22`) — MSVC 19.38 / GCC 12.3 / Apple Clang 15.0, CMake `FATAL_ERROR` on version mismatch.

Feature scope (`README.md:50-59`): 40+ screens; 100+ data connectors (Yahoo, FRED, IMF, World Bank, AkShare, government APIs); 37 AI agents (Buffett/Graham/Lynch/Munger personas + economic + geopolitics); real-time crypto/equity WebSocket trading; 18 QuantLib modules; maritime/geopolitics intel; node-editor visual workflows.

Codebase scale (`fincept-qt/src/`): ~50 screens (`screens/` subdirs), 100+ Python scripts (`docs/PYTHON_CONTRIBUTOR_GUIDE.md:11-15`), 41 dashboard widgets (`screens/dashboard/widgets/` — 68 files = 34 widget pairs), 13+ repositories (`storage/repositories/`).

Contributor docs present: `ARCHITECTURE.md`, `GETTING_STARTED.md`, `CPP_CONTRIBUTOR_GUIDE.md`, `PYTHON_CONTRIBUTOR_GUIDE.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `COMMERCIAL_LICENSE.md`, plus 4 plans in `fincept-qt/plans/` (crypto-center phases).

## 2. Architecture / Design Patterns

Strict 4-layer architecture (`docs/ARCHITECTURE.md:13-39`): UI Layer (Qt6 Widgets) → Application Layer (Screens / Services / Trading / MCP) → Infrastructure Layer (HTTP / SQLite / WebSocket / Python Bridge) → Platform Layer (Qt6 cross-platform abstraction).

**Screen/Service separation** (`docs/ARCHITECTURE.md:170-188`): Screens render UI only — no HTTP, no business logic; Services handle fetching/caching/processing; Screens connect via Qt signals/slots, never call `HttpClient` directly. Parallels StockForge BC-internal layering (domain ↔ adapters).

**Core infrastructure primitives** (`docs/ARCHITECTURE.md:191-195`):
- `Result<T>` error type (no exceptions).
- `EventBus::instance().publish(event, data)` for decoupled cross-module pub/sub — used by MCP tools to mutate news monitors via LLM (`fincept-qt/src/screens/news/NewsScreen.h:153-159`).
- `AppConfig::instance()` for constants (no magic strings).
- Structured logging `LOG_INFO(tag, msg)`.

**Threading model** (`docs/ARCHITECTURE.md:198-202`): UI on main thread; `QThread` / `QtConcurrent` for background; `QMetaObject::invokeMethod` for cross-thread results; `QMutex` for shared state. Asynchronous generation-ID pattern for stale-result rejection: `std::atomic<int> filter_generation_` in `NewsScreen.h:120`.

**Python bridge** (`docs/ARCHITECTURE.md:240-258`): `QProcess` spawns Python; script outputs JSON to stdout; C++ parses `QJsonDocument`. Pattern is analogous to a worker-process boundary — comparable to StockForge's future hybrid (FastAPI calling Python ML scripts).

**ADS docking** (`fincept-qt/src/app/DockScreenRouter.h:9-60`): uses third-party Qt Advanced Docking System (`#include <DockManager.h>`). Screens registered as `CDockWidget` — dockable, tabbed, floatable, auto-hide. Lazy factory pattern: `ScreenFactory` lambdas only invoked on first navigation. `tab_into()` and `add_alongside()` compose multi-panel layouts programmatically.

**Symbol Group linking** (`fincept-qt/src/core/symbol/SymbolGroup.h:9-35` + `IGroupLinked.h:5-44`): explicit Bloomberg-Launchpad-equivalent "Security Groups" — 10 named slots (A–J, color-coded amber/cyan/magenta/green/purple/red/yellow/orange/teal/pink). Panel implements `IGroupLinked`; on symbol change it publishes via `SymbolContext::set_group_symbol(group, ref, this)`, and all other panels in the same group subscribe via `on_group_symbol_changed(ref)`. Mix-in interface (`Q_DECLARE_INTERFACE`) means router `qobject_cast`s widgets to wire up automatically. Stored as single char in JSON (`SymbolGroup.h:22-33`) — workspace-persistable.

## 3. Components / Features Candidate (UI patterns only — stack mismatch)

**Dashboard Canvas** (`fincept-qt/src/screens/dashboard/canvas/DashboardCanvas.h:12-89`):
- Absolute-positioned canvas described as "react-grid-layout port"; 12-column responsive grid with vertical compaction.
- Drag from title bar; resize from bottom-right; drag-debouncing via `resize_timer_` (`DashboardCanvas.h:80-83`) to avoid layout destruction during ADS splitter drag.
- Placeholder ghost cell during drag; auto-scroll during edge-drag (`scroll_timer_`, `DashboardCanvas.h:75`).
- `canonical_cols_` preserves user's chosen width across responsive shrink (`DashboardCanvas.h:84-86`).

**Widget Registry / Factory** (`fincept-qt/src/screens/dashboard/canvas/WidgetRegistry.h:17-43`): single registry pattern — `WidgetMeta {type_id, display_name, category, description, default_w/h, min_w/h, factory}`. Factory receives per-instance persisted `QJsonObject` config, enabling reproducible widget state across reloads. Categories enable picker filtering.

**Dashboard Templates** (`fincept-qt/src/screens/dashboard/canvas/DashboardTemplates.h:9-17`): 6 built-in starter templates; `apply_template(template_id)` swaps the canvas to a curated default layout.

**Workspace Persistence** (`fincept-qt/src/storage/cache/TabSessionStore.h:9-56` + `storage/repositories/DashboardLayoutRepository.h:7-22`):
- Per-tab `{tab_id, screen_name, scroll_position, filters, selections, last_accessed}` in `cache.db`.
- `save_screen_state(key, state, state_version)` + `state_version` check — if loaded version mismatches expected, returns empty so screen starts fresh (`TabSessionStore.h:28-33`).
- Phase 4b enhancement: UUID-keyed per-instance state (`save_screen_state_by_uuid`, `TabSessionStore.h:34-50`) — two watchlists of same type get distinct rows.
- Dashboard layout stored as profile (default + named): `load_layout(profile_name)`, `save_layout(layout, profile_name)`, `clear_layout()` (`DashboardLayoutRepository.h:11-19`).

**News Multi-Panel Layout** (`fincept-qt/src/screens/news/NewsScreen.h:25-33`): 4-band layout — Command bar 32px (search/category/time/sort/view pills), Intel strip 26px (live stats + sentiment + monitors + deviations), full-width feed + optional 420px right detail overlay + optional 280px left intel drawer, Ticker strip 22px (scrolling FLASH/URGENT/BREAKING headlines, `NewsTickerStrip.h:12-46`).

**Alert/Priority Tiers** (`fincept-qt/src/services/news/NewsService.h:24-39`):
- `enum class Priority { FLASH, URGENT, BREAKING, ROUTINE }`.
- `enum class Sentiment { BULLISH, BEARISH, NEUTRAL }`.
- `enum class Impact { HIGH, MEDIUM, LOW }`.
- `enum class ThreatLevel { CRITICAL, HIGH, MEDIUM, LOW, INFO }` with categorical sub-classification (`conflict, cyber, natural, market, regulatory, general`).
- `enum class SourceFlag { NONE, STATE_MEDIA, CAUTION }` — source credibility annotations.
- `enum class NotifLevel { Info, Warning, Alert, Critical }` (`fincept-qt/src/services/notifications/NotificationService.h:15`).

**News Clustering** (`fincept-qt/src/services/news/NewsClusterService.h:10-24`): `NewsCluster {id, lead_article, articles[], source_count, velocity ("rising"/"stable"/"falling"), sentiment, category, tier, latest_sort_ts, is_breaking}`. Cluster aggregates duplicate stories across sources to reduce feed noise — directly applicable to BC-5/BC-7 dedup.

**Equity Research Tabs** (`fincept-qt/src/screens/equity_research/EquityResearchScreen.h:16-80`): per-symbol single-screen tabbed analysis: Overview / Financials / Analysis / Technicals / Talipp / Peers / News / Sentiment. Quote-bar mini-header (sym, price, change, vol, high-low, mkt-cap, recommendation) plus `IGroupLinked` so changing the symbol in one panel updates all linked panels.

**Theme Tokens** (`fincept-qt/src/ui/theme/ThemeTokens.h:8-67`): centralized design-system tokens — `bg_base/surface/raised/hover`, `border_dim/med/bright`, `text_primary/secondary/tertiary/dim`, `positive/negative/warning/info`, `accent_bg/positive_bg/negative_bg` (translucent tints), `chart_colors[6]`. Single "Obsidian" preset (`THEME_OBSIDIAN`); the design constraint is "no hardcoded hex anywhere else" — all painters/QSS read from the token struct. Direct analog to CSS-vars/Tailwind theme tokens.

**Bloomberg-style Command Bar Pills** (`fincept-qt/src/screens/news/NewsCommandBar.h:14-94`): two-row 58px header — Row 1 (32px) search + category pills + time pills + sort/view toggles + refresh/summarize/drawer buttons; Row 2 (26px) "Intel strip" — `update_stats(feeds, articles, clusters, sources)`, `update_sentiment(bull, bear, neut)`, `update_deviations()`, `update_monitor_summary(total, active_alerts)`. Pill helper `make_pill()` + active-state grouping `update_pill_group()`. Dense status-line aesthetic.

**Notification Service** (`fincept-qt/src/services/notifications/NotificationService.h:20-67`):
- `NotificationRequest {title, message, level, trigger, timestamp}` with `NotifTrigger { Manual, PriceAlert, OrderFill, NewsAlert, WorkflowNode }`.
- `INotificationProvider` abstraction — `provider_id`, `display_name`, `icon`, `is_configured`, `is_enabled`, `send(req, cb)`, `load_config`, `save_config`. Telegram/email/push providers implement same interface. Pattern is portable to any backend.

## 4. Per-BC Mapping (BC-9 primary, BC-5/BC-7 secondary)

| BC | Component / Pattern in FinceptTerminal | Pattern transferable? |
|---|---|---|
| BC-9 Portfolio & Action (dashboard UX) | DashboardCanvas 12-col react-grid-layout (`screens/dashboard/canvas/DashboardCanvas.h`); WidgetRegistry + DashboardTemplates; TabSessionStore + DashboardLayoutRepository workspace persistence; ThemeTokens design system | YES — port the *concept* to Streamlit (`streamlit-elements` or `streamlit-extras` grid); workspace persistence concept fits any framework |
| BC-9 (multi-symbol linking) | Symbol Group Linking (A–J slots, `core/symbol/SymbolGroup.h` + `IGroupLinked.h`) | PARTIAL — Streamlit's single-page reactive model handles this differently; pattern most useful in Phase 2+ if Next.js/desktop UI appears |
| BC-5 News (multi-panel + cluster + tiered priority) | NewsScreen 4-band layout; NewsCluster (lead+sources+velocity); Priority/Sentiment/Impact/ThreatLevel/SourceFlag enums; NewsTickerStrip scrolling FLASH/URGENT | YES on the data-model side (Priority + ThreatLevel + SourceFlag enums directly applicable); UI patterns are aspirational for Phase 2+ |
| BC-7 Crowd (sentiment visualization) | EquitySentimentTab + sentiment gauge widgets (`screens/equity_research/EquitySentimentTab.h`); sentiment bull/bear/neut tri-color pills in NewsCommandBar | YES (concept); pattern: bull/bear/neutral as 3 separate gauges, not single composite score — consistent with charter "structured, not narrative" rule |
| BC-8 Analysis & Thesis (multi-perspective) | EquityResearchScreen 8-tab structure (Overview / Financials / Analysis / Technicals / Talipp / Peers / News / Sentiment) | PARTIAL — useful as a structural template for thesis-display UI; FinceptTerminal does NOT enforce StockForge's bear-case/adversarial mandate, so cannot import verbatim |
| BC-1/2/3/4/6 | No specific transferable pattern — Fincept's connectors are direct REST/WebSocket per data source; StockForge already has the BC contracts pattern | NO |
| Cross-cutting: Notifications | NotificationService + INotificationProvider abstraction (Info/Warning/Alert/Critical × Manual/PriceAlert/OrderFill/NewsAlert/WorkflowNode) | YES — clean Python port for BC-9 alerts → Telegram/email |

## 5. Honest Fit Assessment — DEMOTE MEDIUM → LOW

**Why LOW (not MEDIUM as hypothesized):**

1. **Stack mismatch is severe** — C++/Qt6 + ADS docking is not a "look at the code and port" exercise. Every UI pattern is QWidget-based with painter/event/signal idioms; zero LOC ports to Streamlit. The DashboardCanvas itself is explicitly "a port of react-grid-layout" (`screens/dashboard/canvas/DashboardCanvas.h:12`), so StockForge would be better off going straight to `react-grid-layout` (Phase 2+ Next.js) or `streamlit-elements` (Phase 1) — bypassing FinceptTerminal entirely.

2. **Phase 1 priorities mismatch** — StockForge Phase 1 is data ingestion + claim extraction + basic Streamlit dashboard. The high-density Bloomberg UX FinceptTerminal exemplifies is a Phase 2+ visual goal. Trying to import these patterns in Phase 1 violates P2 (Simplicity First) and adds frontend complexity before the data layer is solid.

3. **License risk is real (see Section 6).** AGPL-3.0 + commercial-license-required-for-internal-use means StockForge cannot literally copy any code or close-paraphrase any non-trivial design. Patterns-only adoption is mandatory; literal LOC import would taint StockForge's license posture.

4. **The pattern-yield is concentrated in 3 small primitives**, NOT in the bulk of the repo:
   - News priority/threat tier enums (~20 LOC equivalent).
   - Workspace-state versioning + UUID per-instance keying (~50 LOC equivalent in Python).
   - 12-column grid + widget factory registry concept (already standard pattern from react-grid-layout).
   The other ~95% of the C++ code is Qt-specific framework plumbing or trading-broker integrations irrelevant to StockForge.

**Where MEDIUM could still apply:** If StockForge ever moves to a desktop or Next.js terminal-like UI in Phase 3+, the news/equity multi-panel layout patterns become more directly relevant. For Phase 1 Streamlit, LOW is the honest call.

**Wave-1 IMPL candidate:** Theme K (UX/output) — single PLAN-session "design study" output as a Streamlit prototype sketch + a sticky-note rule "when you start the dashboard, look at FinceptTerminal news layout for tier-density inspiration." **Do NOT** allocate IMPL time in Wave-1.

## 6. License + Attribution

**License:** AGPL-3.0 + Fincept Commercial License (dual) — `C:/htdocs/research/FinceptTerminal/LICENSE:1-89`.

**Hard constraints (`LICENSE:20-44`):**
- AGPL-3.0 free only for "personal use, individual learning, academic research by individual students, and open-source contribution to this repository."
- Commercial License REQUIRED for "any business or internal company use, regardless of revenue, size, or duration" (`LICENSE:33-35`). Price USD 10,200/year (`LICENSE:70`).
- "Internal use within any for-profit organization, government body, fund, or revenue-generating non-profit is Commercial Use" (`LICENSE:52-55`).
- AGPL "is NOT available for Commercial Use as defined in docs/COMMERCIAL_LICENSE.md, Section 3" (`LICENSE:41-43`).
- "Cloning, forking, downloading, building, or modifying this repository does NOT grant any right to use Fincept Terminal — or any Modified Version or Derivative Work — for Commercial Use" (`LICENSE:51-55`).
- Trademark restriction (`LICENSE:78-89`): "Fincept", "Fincept Terminal" cannot be reused without permission.

**Implications for StockForge:**
- StockForge is single-tenant + 3-5 trusted peers. **Whether this counts as "personal use" or "internal use within a small group" is ambiguous under FinceptTerminal's commercial-license trigger** — the license is aggressive and reads as triggering on any non-academic use. Safest position: assume StockForge use of any literal FinceptTerminal code would require the Commercial License.
- AGPL-3.0's network-service clause means any literal-LOC fork that later gets hosted (e.g., the StockForge dashboard shared with peers via web) must release modifications under AGPL-3.0 — incompatible with StockForge's intended licensing posture (TBD but not AGPL).
- **Conclusion: pattern-only adoption with no literal LOC import.** Reference patterns by name in design notes; do not copy code. If a pattern is described in `docs/ARCHITECTURE.md` (which is itself AGPL-licensed), reformulate the description in StockForge's own words — design descriptions ARE copyrightable but ideas are not.

**Attribution if patterns referenced:** "Pattern inspired by FinceptTerminal — https://github.com/Fincept-Corporation/FinceptTerminal — AGPL-3.0. No code imported." Place in `agent-workspace/memory/decisions/` or skill docs as appropriate.

## 7. Risks / Anti-patterns

**C++ idiom gotchas (do not transplant verbatim):**
1. **`Result<T>` instead of exceptions** (`docs/ARCHITECTURE.md:192`) — Python idiom is exceptions or `dataclass` + `Optional[Error]`. Don't introduce a `Result<T>` clone; use Python's native error handling.
2. **`QProcess` Python subprocess bridge** — works for FinceptTerminal because C++ can't run yfinance/pandas natively, but StockForge is Python-native end-to-end. Don't replicate the subprocess pattern — call libraries directly.
3. **`EventBus::instance().publish()` singleton pub/sub** — works in Qt's main-thread-only model but is a smell in Python (global state, harder to test). Prefer dataclass events + explicit handler injection or Redis pub/sub for cross-BC.
4. **Mix-in interfaces via `Q_DECLARE_INTERFACE`** — Python uses `Protocol` or ABCs; don't replicate Qt's metaobject system.
5. **`std::atomic<int> filter_generation_` for stale-result rejection** (`NewsScreen.h:120`) — pattern is correct (idempotent generation IDs) but the Python equivalent is `asyncio` tasks + cancellation tokens, not atomics.

**Bloomberg-imitation legal-grey patterns:**
1. **"Bloomberg-terminal-class performance"** as marketing copy — FinceptTerminal explicitly positions as a Bloomberg alternative (`README.md:23`, `GETTING_STARTED.md:10`); StockForge's charter already nods to "personal Bloomberg Terminal" (`PROJECT_CHARTER.md:51`) but should be careful about the trademark surface. Avoid using "Bloomberg" in any user-facing copy.
2. **`F1`-`F12` function-key bar** (`fincept-qt/src/ui/navigation/FKeyBar.h`) and dense status-line aesthetic — Bloomberg-Terminal-distinctive trade dress. Inspiration is fine; pixel-for-pixel imitation of Bloomberg's amber-on-black palette + key layout could attract attention if StockForge ever becomes public. Use Obsidian-style or a custom palette.
3. **"Security Group" labels A-J** — Bloomberg Launchpad uses exactly this naming and color scheme. FinceptTerminal copies it verbatim (`core/symbol/SymbolGroup.h:9-18`). If StockForge adopts the linking pattern, rename to neutral terms (e.g., "Watch Slot 1-10" or "Linked View α-ι").

**StockForge-charter conflicts to flag:**
1. **FinceptTerminal includes AI "buy/sell" agent personas** (Buffett/Graham/Lynch — `README.md:53`). This directly violates StockForge's "frame as research aid, not financial advice" charter rule. **Do NOT import the agent-persona pattern as-is** — keep StockForge agents as "perspective synthesizers" not "recommenders."
2. **Single sentiment score per article** (`NewsService.h:62-66` SentimentAnalysis) violates StockForge's "structured, not narrative" rule if used as the sole output. The bull/bear/neutral tri-pill pattern in `NewsCommandBar.h:82-86` is the correct adversarial-by-default presentation — adopt the tri-pill, reject any single composite "sentiment score" output.
3. **No source/as-of-date discipline visible in news data model** (`NewsService.h:42-59` NewsArticle has `source` + `time` but no separation of `as_of_date` vs `ingested_at` vs `event_time`). StockForge's "every claim has source + as-of date" rule is stricter; the FinceptTerminal model is a starting point, not a final shape.

**Operational risks if used as inspiration:**
- **Scope creep risk**: FinceptTerminal has 40+ screens. If StockForge starts importing FinceptTerminal's feature breadth (maritime tracking, geopolitics, 16 broker integrations), it derails Phase 1. Constrain reference to: dashboard layout system, news priority enums, notification provider abstraction, workspace persistence pattern. Anything else is out-of-scope.

---

Self-attestation: every claim cites a specific file in the repo.
