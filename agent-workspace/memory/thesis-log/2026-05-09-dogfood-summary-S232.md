# LIVE 5-Ticker Dogfood Summary — S232 (2026-05-09)

> **Status**: Phase 3 dogfood validation run (`real_thesis: false` per CLI doctrine — NOT Charter SC-3 publishable).
> **Authorization**: AskUserQuestion S232 PRIORITY 1 — Q1=Fixture-only KOL + LIVE crowd+LLM, Q2=Full 5-KOL+5-ticker.
> **Framing**: research aid pipeline validation, NOT financial advice (I-S35).

## Scope

- **Tickers**: BID, BVH, CTG, FPT, GAS (the 5 in `data/stockforge.sqlite` with bars + financial_statements coverage).
- **As-of**: 2026-05-09.
- **Transport**: subagent (`claude` CLI subprocess via Claude Code OAuth subscription per D-050).
- **Cost model**: actual marginal $0 per subscription billing; imputed token-pricing logged in frontmatter only.
- **KOL layer**: fixture-only (Q1 disposition); no LIVE channel ingest.
- **Crowd-sentiment layer**: LIVE crowd_sentiment ingest NOT WIRED in Phase 3 (`apps/cli/ingest_crowd_sentiment.py` falls back to dry-run with WARNING "Live mode not fully wired in Phase 3"). Theses generated against existing news_articles + bars + financial_statements.

## Per-thesis outcomes

| Ticker | Recommendation | Confidence | Calibration grade | n_samples | Imputed cost | Bear pts | Bull pts | Notes |
|---|---|---|---|---|---|---|---|---|
| FPT | watch | medium | D | 0 | $1.5183 | 6 | 0 | Bull JSON parse fail — LLM emitted prose+table |
| BID | watch | medium | D | 0 | $1.0037 | 7 | 0 | Bull-haiku 300s timeout (recurrence of S43b-class issue) |
| BVH | watch | medium | D | 0 | $1.0853 | 6 | 0 | Bull JSON parse fail — `{FUNDAMENTAL, GROWTH, VALUATION, ...}` placeholder emit |
| CTG | investigate | low | D | 0 | $1.5355 | 5 | 3 | Clean — only ticker with full bull case |
| GAS | watch | medium | D | 0 | $1.5851 | 5 | 0 | Bull empty (no error stdout; warrants log-level audit) |
| **TOTAL** | — | — | — | — | **$6.93** | 29 | 3 | — |

## Acceptance criteria (per `agent-workspace/session-plans/pending/007-S44-phase-3-master-plan.md` § Track M)

| Criterion | Target | Actual | Status |
|---|---|---|---|
| Per-thesis Phase 3 cost (KOL+sentiment context layer added) | ≤$3/thesis | max $1.5851 | PASS |
| Total cost envelope | $8-15 | $6.93 imputed; $0 actual marginal | PASS (well under) |
| 5 ticker thesis end-to-end via `validate_thesis.py --no-mock-llm` | binary PASS | 5/5 thesis files written | PASS |
| I-S10 — bear case ≥3 specific evidence-grounded points | per-thesis | 5/5 PASS (5/6/6/7/5 = avg 5.8) | PASS |
| I-S35 — research-aid framing (no buy/sell) | per-thesis | 5/5 PASS (4× watch + 1× investigate) | PASS |
| Bull case quality | per-thesis ≥3 points | 1/5 PASS (CTG only); 4/5 FAIL (haiku-timeout / JSON parse) | **DEGRADED** |
| `real_thesis: true` Charter SC-3 ready | binary | 0/5 (all `real_thesis: false` per CLI doctrine — dogfood is pipeline-validation, not Charter SC-3) | N/A by design |

## Findings

### Bull-role degradation (4/5; persistent class issue)

Three distinct failure modes observed:

1. **JSON-parse failure on prose/table emit** (FPT, BVH 2/5): Bull-haiku LLM emits markdown prose + table summary instead of strict JSON schema. Use-case fallback empties bull_case. Same root cause across two tickers — schema-prompt fragility.
2. **Bull-haiku 300s CLI timeout** (BID 1/5): use_case_builder.py:151-158 already documents this exact failure mode for the bull role on FPT in S43b dogfood (2/2 BID+FPT) — presumed-fixed by sonnet→haiku model swap, but timeout recurred under parallel-load. Hypothesis: parallel-4-subprocess contention or longer prompt context (Phase 3 added KOL+sentiment layer per master-plan even though crowd-sentiment dry-runs only).
3. **Silent bull-empty** (GAS 1/5): no stderr error logged, but bull_points=0 in output. Warrants log-level audit — possibly the JSON-parse path emitted to a different stream.

**Class signal**: 4-out-of-5 bull-role degradation suggests the bull-prompt + JSON-output combo is the weakest link. NOT a blocker for Phase 3 close (bear-case I-S10 compliance is the hard gate per spec), but is a Phase 4 backlog item.

### KOL fixture-only path (Q1 disposition)

- KOL ingest CLI `apps/cli/ingest_kol_channels.py` runs against fixture channels (UCkol_youtube_fixture / kol_telegram_fixture / kol_facebook_fixture); 0 fetched (no creds). KOL signal layer in theses is empty.
- Per Q1 answer: acceptable degradation. Pipeline end-to-end exercised; KOL layer is a noop in this dogfood.

### Crowd-sentiment LIVE blocker

- `apps/cli/ingest_crowd_sentiment.py` falls back to dry-run with WARNING "Live mode not fully wired in Phase 3. Use --dry-run for smoke testing. Exiting." Real persistence not implemented yet.
- Per Q1 answer: acceptable. Theses generated against existing news_articles + bars + financial_statements layer.

## Phase 3 close gate signal

| Gate | Status |
|---|---|
| BC-6 + BC-7 + BC-8 + BC-9 Track L + Track M scaffold | DONE (per checkpoint S231) |
| LIVE 5-ticker dogfood pipeline validation | **DONE this S232** (5/5 thesis files written; cost discipline PASS; bear I-S10 PASS) |
| S59 VERIFY (sandwich-verifier whole-Phase-3 + retrospective + Phase 4 prereq enumeration) | **PENDING — S233 PRIORITY 1** |

## Recommendations for Phase 4 backlog

1. **Bull-role JSON schema enforcement** — switch from prose-prompt to strict-JSON-mode (Anthropic SDK supported `response_format=json_object`; CLI subprocess equivalent TBD). Or add bull-output-validator with retry-on-parse-fail.
2. **LIVE crowd-sentiment write path** — wire `ingest_crowd_sentiment.py` to actually persist snapshots to sqlite (currently exits early with WARNING).
3. **KOL credentials onboarding flow** — document the 3-platform credential env-var setup (YouTube API key / Telegram bot token / Facebook Graph token) once user wants LIVE KOL.
4. **Calibration data seeding** — all 5 theses currently `n_samples: 0 / calibration_grade: D`. Phase 4+ loop should run thesis post-mortems against actual VN market outcomes (4-week / 13-week / 26-week horizons) and feed back to update calibration grades.

## Files written

- `agent-workspace/memory/thesis-log/2026-05-09-FPT.md` (LIVE; was overwritten S232 from S231 mock-LLM smoke)
- `agent-workspace/memory/thesis-log/2026-05-09-BID.md` (NEW)
- `agent-workspace/memory/thesis-log/2026-05-09-BVH.md` (NEW)
- `agent-workspace/memory/thesis-log/2026-05-09-CTG.md` (NEW)
- `agent-workspace/memory/thesis-log/2026-05-09-GAS.md` (NEW)
- `agent-workspace/memory/thesis-log/2026-05-09-dogfood-summary-S232.md` (THIS file)
- `data/stockforge.sqlite` `theses` table: +5 rows submitted (was 6 → now 11)

## Disclaimer

Research aid only. NOT financial advice. NOT a buy/sell recommendation (I-S35). Theses generated by a deterministic pipeline + LLM perspective adapters; numbers cited within trace to deterministic Python tool calls (I-S1) against `data/stockforge.sqlite` snapshot 2026-05-09. Bull-role degradation in 4/5 makes the bear-case-only framing artificially asymmetric — readers MUST treat single-perspective output as anti-pattern (CLAUDE.md hard rule "Adversarial by default"). Reader discretion required before any portfolio action.
