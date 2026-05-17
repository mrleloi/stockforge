---
plan_id: 030-S364-phase-e2-vn-sentiment-lexicon
target_session: S365 (dev IMPL session; THIS plan = S364 architect output)
type: FOCUSED_IMPL (5 sub-tracks D1-D5; sub-plan author = sandwich-architect at S364; IMPL by sandwich-dev at S365; VERIFY by sandwich-verifier AP-1 at S366)
budget:
  - this PLAN session (S364 architect): ~150-230K Opus PLAN per recalibrated CLAUDE.md table (M-S360-2 empirical ratification carry-forward; S363 verifier dispatch validated upper-band Opus PLAN envelope)
  - sub-plan IMPL (S365 dev): ~100-150K Sonnet FOCUSED_IMPL per recalibrated table (sandwich-dev back on Sonnet per M-S360-2; n=1 vietnamese-nlp-impl precedent from S362 ~159K Sonnet / ~39min / 1053/1053 tests / 0 mistakes — within envelope)
  - sub-plan VERIFY (S366 verifier): ~30-60K Opus AP-1 fresh-context
phase: E (Theme I — Vietnamese NLP entry; sub-theme E.2 Sentiment Lexicon — SECOND of 4 sub-themes per plan-028 § E sequencing)
track: Wave 1 Theme I sub-theme E.2 — VN sentiment lexicon (rule-based deterministic; PATTERN-PORT from TradingAgents-CN akshare.py:1497-1611 with VN-specific hand-curated keywords ~200-500 + cultural anchors đội-lái/đu-đỉnh/bắt-đáy + calibration loop per Principle 8 NOT hand-tune per A-14 § 7.8 anti-pattern veto); per master plan § 5.4 + § 6.4.2 + plan-028 DD-4
parent_plan: agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md (PHASE-MASTER-PLAN authored S360; THIS is the second sub-plan per § E.2 + § L sequencing)
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md § 5.4 + § 6.4.2
predecessor: 029-S361-phase-e1-vn-tokenization (sub-plan 029; SHIPPED S362 dev + VERIFIED S363; ADR D-070 PROPOSED with pyvi==0.1.1 selection at 75.7% quality on n=36 corpus; calibration eval at agent-workspace/calibration/vn_tokenizer_eval_v0.md; sub-plan 029 mv pending→completed at S363 close)
successor: S365 sandwich-dev FOCUSED_IMPL executing this plan D1-D5 → S366 sandwich-verifier AP-1 → sub-plan 031 E.3 claim extraction at S366+ (per master plan § E sequencing; 031 blocks_on=[029, 030])
architect: S364 sandwich-architect (background; THIS plan)
dispatched_by: main session orchestrating Phase E second sub-plan author per plan-028 § L sequencing + S363 verifier close + recalibrated PLAN budget table validation (2nd opportunity per dispatch brief)
authored: 2026-05-17
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent; Phase 1b CONSUMED with n=1 vietnamese-nlp-impl precedent from S362 — cold-start window now CLOSED for impl-shape but PLAN-shape for vietnamese-nlp-plan task_class remains n=1 narrow-variance per L-S354-2 .planner-stats.tsv carry-forward)
executing_agent: N/A this PLAN session; S365 sandwich-dev FOCUSED_IMPL (after this sub-plan ratified) + S366 sandwich-verifier AP-1
status: pending-execution

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse (per current-execution.md § INCIDENT + RECOVERY 2026-05-14)"
  - "R2 project-integrity-watchdog.sh Stop hook"
  - "R3 daily-backup.sh Stop hook"
  - "BEHAVIORAL HOLD § (1) — SYNC-GRILLING + ROUTINE-IDLE close ritual SUSPENDED (carry-forward from S310; do NOT include sync-grilling in S365 close ritual)"

depends_on:
  - "Parent master plan-028 § E.2 sub-plan contract (DD-4 LEXICON-PATTERN-PORT + CALIBRATE strategy; coordination_paths_exclusive scoped to apps/extraction/sentiment/** + agent-workspace/calibration/vn_sentiment_lexicon_v0.md + data/corpus/vn_financial_news_labelled/** gitignored)"
  - "Sub-plan 029 SHIPPED + VERIFIED — pyvi==0.1.1 VnTokenizer available via packages.infrastructure.nlp.vn_tokenizer.VnTokenizer (instantiable); WhitespaceTokenizer fallback available; TextTokenizerPort Protocol at packages.application.nlp.ports.text_tokenizer_port — THIS sub-plan CONSUMES VnTokenizer as injected dependency per DI port pattern"
  - "ADR D-070 PROPOSED — pyvi selection rationale + license audit (MIT) + revisit triggers; THIS sub-plan honors trigger 1 ('pyvi quality <50% on sub-plan 030 held-out corpus eval n=200+ → E.1-V2 underthesea or PhoBERT fallback evaluation') — sub-plan 030 IS the held-out corpus eval surface"
  - "agent-workspace/calibration/vn_tokenizer_eval_v0.md — corpus baseline (n=36 articles NDH/Vietstock/VietnamBiz/CafeF=0); SUB-PLAN 030 expands corpus per § STEP 0.2 to n=200-500 articles for labelling cycle"
  - "D-066 + REV-1/2/3 (CrawlerAdapter ABC contract; 4 VN adapters SHIPPED) — THIS sub-plan CONSUMES NewsArticle output as labelled-corpus substrate"
  - "D-061 § Decision item 4 (HARD REJECT Scrapling/patchright/playwright_stealth/fake-useragent/StealthyFetcher) — N/A this sub-plan (no new HTTP fetcher introduced; lexicon is text-in/score-out pure-function pipeline); CARRIES FORWARD if labelling UI somehow needed an HTTP fetcher (verifier grep-asserts post-IMPL)"
  - "D-059 (Python determinism contract — R1 datetime-no-tz + R2 unseeded RNG + R4 time.time-in-domain) — BINDING for every NEW file authored under this sub-plan; lexicon scoring is pure-function so deterministic-by-construction posture expected; STEP 0.7 grep-asserts"
  - "D-060 (commit-policy-agent-may-commit) — operational gate for S365 dev commit boundary"
  - "D-062 (atomic-write-doctrine via tmp+os.replace) — BINDING IF labelling cycle persists labelled-corpus JSON/TSV to disk; recommended path uses Python's tempfile+os.replace pattern per existing W0-3 doctrine"
  - "D-064 (path-safety 5-invariant) — BINDING for any file-path code if labelling UI writes labelled corpus to data/corpus/**"
  - "D-065 Rule 16 (numeric-field discipline) — THIS sub-plan EMITS lexicon numeric scores; Rule 16 satisfaction MODE 2 (deterministic-pipeline echo) — score is computed by deterministic Python lexicon-weight summation + normalization formula; LLM never invoked in scoring path; CRITICAL CHARTER-TIER COMPLIANCE — see § D DD-7 (Rule 16 mode-2 by construction) + § STEP 0.4 audit"
  - "D-069 PROPOSED-AT-IMPL (planner-upgrade ADR; Phase 1b mandate for ≥3 sub-tracks; THIS plan has 5 sub-tracks D1-D5 → Phase 1b CONSUMED variant MANDATORY per plan-025 DD-11)"
  - "Charter v1.1 Principle 4 (Proprietary data moat — VN sentiment lexicon + cultural anchors ARE the moat per master plan § 5.4) + Principle 7 (Dogfood — S365 dev MUST run lexicon on ≥5 real CafeF/NDH/Vietstock/VietnamBiz samples in STEP 0 + D4 CLI smoke; cannot ship without dogfood) + Principle 8 (Calibration over confidence — lexicon weights MUST be calibrated against labelled corpus NOT hand-tuned per A-14 § 7.8 anti-pattern explicit veto; cross-validation accuracy ≥70% on held-out subset per DoD floor) + Principle 9 (NO LLM math — lexicon is rule-based deterministic; Rule 16 mode 2 by construction; embedding-based fallback is interpret-only per § A.3 deferral) + Principle 11 (firing-test mandate IF a hook is shipped — NO new hook this bundle)"
  - "I-S1 (NO LLM math) — lexicon scoring is pure-function deterministic; LLM never invoked in scoring path; satisfied by construction"
  - "I-S2 (citation discipline) — every lexicon entry traces to (a) hand-curated source (architect-curated initial set OR project-owner addition) OR (b) calibration adjustment from labelled-corpus run; lexicon JSON/TSV records source + as_of fields per entry"
  - "I-S20 (calibration over confidence) — DoD floor ≥70% accuracy on held-out corpus subset; lexicon revision cycle documented in calibration recipe; weights traced to evidence not intuition (Principle 8 enforcement)"
  - "I-S22 (data lineage) — lexicon entries carry source + as_of + version metadata; calibration outcomes recorded in agent-workspace/calibration/vn_sentiment_lexicon_v0.md"
  - "I-S34 (robots.txt + reasonable rate limits + HARD REJECT of patchright/playwright_stealth/fake-useragent/StealthyFetcher) — N/A this sub-plan (no new HTTP fetcher); CARRIES FORWARD verifier grep-asserts"
  - "I-S35 (research-aid framing) — sentiment scores are SIGNALS not RECOMMENDATIONS; no single-action 'buy/sell' output; satisfied by construction (lexicon emits float scores + categorical labels; consumer decides what to do)"
  - "anthropic_api_to_subagent memory rule — N/A this sub-plan (lexicon does NOT invoke LLM); CARRIES FORWARD to sub-plan 031 E.3 claim extraction wrapper per master plan AQ-6 + RM-MR-1"
  - "skill .claude/skills/prompt-engineering/SKILL.md (lexicon-construction context — § No-LLM-Math pattern + § Validation Pre-Conditions confirm rule-based lexicon scoring is the correct pattern when numeric output is required per I-S1)"
  - "skill .claude/skills/ddd-tactical-patterns/SKILL.md (Port + Adapter discipline — VnLexiconPort Protocol + VnSentimentLexicon adapter; mirror sub-plan 029 D1+D2 pattern)"

binding_decisions:
  - "PHASE 1b CONSUMED with n=1 vietnamese-nlp-impl precedent — task_class='vietnamese-nlp-impl' has n=1 sample from S362 (~159K Sonnet, ~39min, 1053/1053 tests, 0 mistakes) per current-execution.md S362 row; variance window narrow at n=1; sub-plan 030 IMPL projected to fit similar envelope (100-150K Sonnet FOCUSED_IMPL per recalibrated table) UNLESS corpus-labelling cycle inflates budget significantly (see § A.4 detailed reasoning)"
  - "DD-1 LEXICON-PATTERN-PORT STRATEGY per parent plan-028 DD-4 — PORT TradingAgents-CN rule-based lexicon weight dict pattern (akshare.py:1497-1611 per A-14 § 3.5) WITHOUT copying any LOC verbatim (TradingAgents-CN Apache-2.0 license per D-061 § Item 4 verified safe for pattern-port; even so per Karpathy P2 simplicity NO LOC copy needed — pattern is small enough to re-implement from scratch using just the documented formula `max(-1.0, min(1.0, score / 3.0))` + the 1.0/0.5/0.2 intensity-weight tiers)"
  - "DD-2 CULTURAL ANCHORS MANDATED PER MASTER PLAN DD-4 — 'lái' (price-manipulation) / 'đội lái' (pump-group) / 'đu đỉnh' (FOMO at top) / 'bắt đáy' (catch the bottom) MUST be in v0 lexicon with strong polarity weights; NOT optional; NOT deferred"
  - "DD-3 CORPUS LABELLING SOURCE = CONDITIONAL ON STEP 0.5 USER RATIFICATION — per CHARTER-TIER GATE clause + plan-028 § K.2 sub-plan 030 anticipated flag (a) + AQ-8 + dispatch brief flag (a); architect DOES NOT pre-decide labelling source; STEP 0.5 produces empirical scorecard and user picks at gate (3 options enumerated in § CHARTER-TIER GATE)"
  - "DD-4 PRINCIPLE 8 CALIBRATION MANDATORY — lexicon weights must be calibrated from labelled corpus NOT hand-tuned per A-14 § 7.8 anti-pattern explicit veto; sub-plan 030 ships v0 with HYPOTHESIS weights + calibration recipe; ≥70% cross-validation accuracy on held-out subset (DoD floor)"
  - "DD-5 LEXICON STORAGE FORMAT = Python dict literal in source file (NOT external JSON/TSV) — per Karpathy P2 simplicity + Python-import-determinism + diff-friendly review (see § D DD-5 detailed rationale)"
  - "DD-6 SCORING FUNCTION SIGNATURE = `score(tokens: list[str]) -> SentimentScore` where SentimentScore is a frozen dataclass with (a) numeric_score: float in [-1.0, 1.0] (Rule 16 mode 2 deterministic-echo), (b) category: Sentiment (Rule 7 categorical 5-class), (c) keyword_hits: tuple[str, ...] (audit trail), (d) coverage_ratio: float in [0.0, 1.0] (Rule 16 mode 2)"
  - "DD-7 BUFFETT-RUBRIC CALIBRATION TIERS — adopt the 90-100/70-89/50-69/30-49/10-29 evidence-quality bracket pattern from ai-hedge-fund warren_buffett.py:788-794 (per A-01 § 3 C9) for SCORING CATEGORICAL MAPPING (NOT for LLM-self-reported confidence — that's the anti-pattern R3 in A-01 § 7); 5 tiers map cleanly to Sentiment 5-class StrEnum: STRONGLY_BULLISH (0.7..1.0) / BULLISH (0.3..0.7) / NEUTRAL (-0.3..0.3) / BEARISH (-0.7..-0.3) / STRONGLY_BEARISH (-1.0..-0.7)"
  - "AP-7 anti-vacuous-defer — every Out-of-scope item names (a) prerequisites + (b) revisit trigger; no naked deferrals"
  - "AP-23 first-instance HOLD for any new pattern surfaced this session (e.g. NEW VN-cultural-anchor expansion mechanism); 2nd recurrence triggers promote-to-skill calculus"
  - "Karpathy P3 surgical-changes — this sub-plan adds ≤550 LOC production code total across D1-D5 (port ~60 LOC + lexicon dict ~250 LOC including initial 200-500 keywords + scoring fn ~80 LOC + tests ~350 LOC + CLI smoke ~80 LOC = ~820 LOC ceiling; allowance for keyword dict bulk; production-code-only ≤550)"
  - "VBW protocol mandatory — S365 dev MUST READ TradingAgents-CN akshare.py:1497-1611 empirically (NOT memory) before LEXICON PORT begins; cite file:line for every pattern claim per I-S2"

hard_rules_acknowledged:
  - "no production code in THIS PLAN session (CLAUDE.md § Session Types — never mix PLAN+IMPL; THIS is sub-plan author session; production code lands in S365 dev IMPL)"
  - "no commits in THIS PLAN session by architect (sandwich-architect has tools: [Read, Glob, Grep, Write]; no Bash; main commits architect's plan output per D-060 + pre-dispatch-architect-commit-guard.sh hook)"
  - "no charter / no constitution / no human-workspace writes in THIS PLAN session (STOP-AND-ASK file at human-workspace/notifications/STOP-FINDING-S365-* is the ONLY conditional human-workspace write path AND only if STEP 0.5 corpus-labelling trigger fires; that write happens in S365 dev session NOT this S364 PLAN session)"
  - "no touching Phase D Theme L files — all 4 VN adapters + 6 primitives shipped + verified; this sub-plan CONSUMES NewsArticle output for labelled-corpus expansion via existing adapter CLIs, does NOT modify adapters"
  - "no touching Phase E sub-plan 029 files — pyvi VnTokenizer + WhitespaceTokenizer + TextTokenizerPort SHIPPED at S362; this sub-plan IMPORTS them as DI dependencies, does NOT modify"
  - "no Phase E sub-themes E.3/E.4 work in THIS sub-plan — those are sub-plans 031/032 (own PLAN+IMPL+VERIFY chains per master plan § E)"
  - "no charter amendment SHIP from THIS plan — IF corpus-labelling gate fires (per § CHARTER-TIER GATE), THIS plan FLAGS via human-workspace/notifications/STOP-FINDING-S365-* but DOES NOT amend charter; main session dispatches AskUserQuestion + separate user-ratified ADR proposal"
  - "no harness/hook changes — this plan ships product substrate (VN sentiment lexicon adapter); surface any harness gaps in observation; do NOT fix here. L-S354-2 (.planner-stats.tsv auto-population gap) belongs to next harness-stabilization sweep"
  - "every plan claim cites source file:line (per I-S2 + AOM)"
  - "actual files read via Read tool, not from memory (VBW protocol)"
  - "I-S34 carries forward — STEP 0.6 grep-asserts no new HTTP fetcher OR HARD-REJECT artifact in dependencies (no new deps expected; lexicon uses stdlib + already-installed pyvi)"
  - "If STEP 0 surfaces a charter-tier need (corpus-labelling source ambiguity OR Rule 16 mode-2 tripwire OR new I-S<N> for lexicon-calibration meta-sampling discipline), FLAG in § CHARTER-TIER GATE for main session AskUserQuestion ratification gate dispatch"
---

# S364 — Phase E.2 Vietnamese Sentiment Lexicon sub-plan (LEXICON-PATTERN-PORT + CALIBRATE — second sub-plan of Phase E)

> **One-sentence intent**: Port the TradingAgents-CN rule-based lexicon-weight scoring PATTERN (akshare.py:1497-1611 per A-14 § 3.5) with Vietnamese hand-curated keywords ~200-500 + mandatory cultural anchors (đội lái / đu đỉnh / bắt đáy / lái) + Buffett-rubric-tiered categorical mapping (per A-01 § 3 C9) into `apps/extraction/sentiment/vn_lexicon.py` + companion calibration loop in `agent-workspace/calibration/vn_sentiment_lexicon_v0.md` — without LLM in the scoring path (I-S1 + Rule 16 mode 2 by construction), without hand-tuning weights (Principle 8 + A-14 § 7.8 anti-pattern veto), and without pre-deciding the labelling source (CHARTER-TIER GATE STOP-AND-ASK at STEP 0.5).

---

## A. Goal & Scope

### A.1 Goal (verbatim from parent plan-028 § E.2 + DD-4)

Build the **Vietnamese sentiment-lexicon layer** for StockForge that:

- **Ports the TradingAgents-CN rule-based lexicon-weight scoring PATTERN** at `tradingagents/dataflows/providers/china/akshare.py:1497-1611` (per A-14 § 3.5; pattern only — no LOC copy needed per Karpathy P2 simplicity + TradingAgents-CN Apache-2.0 license safe-for-pattern-port per D-061 § Item 4)
- **Replaces Chinese keywords with hand-curated Vietnamese set** (~200-500 keywords per supplement § I.3 step 2.a): tăng / giảm / lên giá / xuống giá / đột phá / lao dốc / cổ phiếu nóng / sàn / trần / cảnh báo / đình chỉ / lỗ / lãi / etc.
- **Adds VN-specific cultural anchors** (MANDATORY per parent DD-4 + master plan binding_decision): "lái" (price-manipulation) / "đội lái" (pump-group) / "đu đỉnh" (FOMO at top) / "bắt đáy" (catch the bottom) — these have NO CN equivalent and are essential for VN F0 retail-culture context
- **Calibrates weights via labelled corpus NOT hand-tuning** per Principle 8 + A-14 § 7.8 anti-pattern explicit veto — initial weights are HYPOTHESIS only; calibration cycle ships ≥70% cross-validation accuracy on held-out subset
- **Satisfies Rule 16 mode 2 (deterministic-pipeline echo) by construction** — lexicon scoring is pure-function deterministic; LLM never invoked in scoring path
- **Maps numeric score to Sentiment 5-class StrEnum** per Rule 7 + Buffett-rubric-tier pattern (per A-01 § 3 C9) — 90-100/70-89/50-69/30-49/10-29 evidence-quality brackets adapt to STRONGLY_BULLISH / BULLISH / NEUTRAL / BEARISH / STRONGLY_BEARISH cleanly
- **Consumes pyvi VnTokenizer via DI** — `VnSentimentLexicon(tokenizer=VnTokenizer())` per port pattern from sub-plan 029

### A.2 In-scope (this sub-plan ships)

1. **Sub-track D1** — VnLexiconPort Protocol at `packages/application/nlp/ports/vn_lexicon_port.py` (~60 LOC; foundation; blocks D2)
2. **Sub-track D2** — VnSentimentLexicon concrete adapter at `apps/extraction/sentiment/vn_lexicon.py` (~330 LOC: lexicon dict + scoring fn + DI wiring; uses pyvi VnTokenizer per D-070 selection)
3. **Sub-track D3** — Unit tests at `apps/extraction/sentiment/test_vn_lexicon.py` (~350 LOC; ≥15 test cases; synthetic VN text fixtures inline; parallel with D4)
4. **Sub-track D4** — Calibration loop recipe + held-out validation harness at `agent-workspace/calibration/vn_sentiment_lexicon_v0.md` (~100 LOC; recipe documenting labelling protocol + cross-validation script + revisit triggers; parallel with D3)
5. **Sub-track D5** — Integration smoke + CLI sentiment-score harness at `apps/cli/score_vn_sentiment.py` (~100 LOC; reads NewsArticle rows from SQLite OR raw HTML files + dumps per-article score + category + keyword_hits; sequential after D2)
6. **ADR D-071 PROPOSED** at IMPL tier (per severity-schema auto-ratifies on commit) — "VN Sentiment Lexicon v0 + Calibration Loop" — records lexicon design + calibration recipe + Buffett-rubric tier mapping + revisit triggers
7. **STEP 0 corpus expansion observation** appended to `agent-workspace/calibration/vn_sentiment_lexicon_v0.md` (extends sub-plan 029 corpus baseline from n=36 to n=200-500 articles per Principle 8 calibration mandate)
8. **Session log + observation file** per CLAUDE.md § Session Protocol End
9. **Mistake-log digest entry** (M-S365-N if mistakes; OR explicit "no mistakes" statement)
10. **ZERO charter / constitution writes** (CHARTER-TIER GATE FLAG file at `human-workspace/notifications/STOP-FINDING-S365-*` is the ONLY conditional human-workspace write path AND only if STEP 0.5 corpus-labelling trigger fires)
11. **ZERO new LLM-numeric schema fields beyond lexicon score** (Rule 16 mode 2 by construction — lexicon score is computed deterministically; categorical mapping uses existing Sentiment StrEnum)
12. **ZERO new hooks** (mirror plan-020/022/026/027/029 — product substrate not harness rule-enforcement)

### A.3 Out-of-scope (DEFERRED — explicit non-goals with named revisit triggers per AP-7)

| Deferred item | Why deferred | Revisit trigger |
|---|---|---|
| Sub-theme E.3 claim extraction wrapper (AUGMENT ClaudeLlmExtractor) | Separate sub-plan 031; depends on this sub-plan's lexicon for sentiment-hint injection | Sub-plan 031 dispatch after S366 verifier confirms E.2 ships |
| Sub-theme E.4 VN ticker resolver (fuzzy-match + alias table) | Separate sub-plan 032; can run parallel with 031 post-E.2 | Sub-plan 032 dispatch after S366 (parallel with 031) per master plan § E |
| PhoBERT / transformer-based VN sentiment (E.2-V2) | Heavier deps (torch ≥500MB + transformers); lexicon-first per A-14 § 7.8 + parent AQ-4 | E.2-V2 trigger: lexicon coverage <50% on held-out corpus eval OR n≥500 labelled corpus available for fine-tuning |
| Custom-trained VN-financial-domain BERT (E.2-V3) | Requires labelled corpus n≥500 + ML training infra | E.2-V3 trigger: ONLY after E.2-V2 PhoBERT fallback insufficient on financial-news subdomain (<80% accuracy) |
| Lexicon weight calibration via reinforcement learning (vs simple cross-validation) | Premature for v0; cross-validation is simpler + more interpretable | RL trigger: cross-validation plateau OR labelled corpus n≥5000 with reward signal available |
| Async sentiment scoring interface | Lexicon is pure-function CPU-bound; sync wrapper sufficient; async = unnecessary complexity | Async trigger: Phase 3 production-throughput gate when sentiment scoring becomes >5% of session time |
| Multi-language sentiment (English / Chinese fallback) | VN-only is the moat per Charter Principle 4 | Trigger: explicit user directive for multi-locale OR market expansion |
| Sentiment-score caching / memoization | Defer to E.3 consumer if needed; no premature optimization per Karpathy P2 | Trigger: E.3 IMPL surfaces measurable extractor latency attributable to repeated scoring on same article body |
| Persisting per-article sentiment-score to database | Sentiment scoring is re-runnable transform; persistence adds D-062 atomic-write surface + storage cost; lexicon score lives transiently with ExtractedClaim emission (E.3) | Trigger: E.3 surfaces need for sentiment-score-at-query-time |
| Sentiment-score historical regression tracking / dashboard | Premature for v0; eval recorded in calibration file + ADR D-071; CI gate at PR-time = future Phase 3 work | Trigger: 2+ silent-sentiment-regression incidents surface (AP-23 promote-to-hook calculus) |
| Lexicon entry version-control via per-entry git annotations | Lexicon source file IS version-controlled via git; per-entry annotations = over-engineering for v0 | Trigger: lexicon grows to n≥1000 entries OR per-entry attribution becomes audit requirement |
| Lexicon weight A/B testing harness | Premature for v0; calibration cycle already provides empirical eval; A/B is Phase 3 production tooling | Trigger: 2+ competing lexicon-weight candidates with empirical equipoise |
| Sentiment-score integration into existing ClaudeLlmExtractor system prompt | E.3 sub-plan 031 work per AUGMENT pattern (parent DD-5) | Sub-plan 031 dispatch |
| Sentiment-score integration into existing NewsArticle pipeline | NewsArticle remains corpus substrate; sentiment scoring happens at claim-extraction time (E.3) NOT at article-ingest time per separation-of-concerns | Trigger: E.3 IMPL surfaces need for at-ingest sentiment scoring (e.g. cheap filter before expensive LLM call) |
| Charter amendment SHIP for corpus-labelling-meta-sampling discipline (if triggered) | THIS plan FLAGS via STOP-FINDING file; main session ratifies via AskUserQuestion gate; ADR drafted separately per CLAUDE.md hard rule | Trigger: § CHARTER-TIER GATE STEP 0.5 STOP-AND-ASK fires on labelling-source ambiguity |
| New harness hook for VN-lexicon-determinism check (e.g. "lexicon output must be deterministic across runs") | Belongs to harness-stabilization sweep IF a lexicon-determinism defect surfaces; product session SHIPS the adapter not the hook | Harness trigger: 2+ silent lexicon-output-drift incidents (AP-23 promote-to-hook) |
| Lexicon entries beyond initial 200-500 keywords | Initial hand-curated set is v0; expansion happens through calibration cycle revisions OR project-owner additions via append-only dict | Trigger: held-out corpus coverage <70% OR user requests new domain (e.g. macro/political terms) |

### A.4 Calibration summary (Phase 1b — CONSUMED variant; n=1 vietnamese-nlp-impl PRECEDENT from S362; cold-start window NARROW)

**Source files read** (VBW empirical, ALL via Read tool — architect has no Bash):

1. `agent-workspace/memory/.planner-stats.tsv` (read entire file = 1 header line; CONFIRMED L-S354-2 carry-forward — planner-feedback-loop.sh STILL header-only at S364 entry after S354/S357/S360/S361/S362/S363 dogfood cycles did not populate; auto-population infrastructure gap)
2. `agent-workspace/memory/current-execution.md` (offset 1-100 + 147-165 read; S362 sandwich-dev RETURN row confirms vietnamese-nlp-impl n=1 precedent: ~159K Sonnet over ~39 min, 1053/1053 tests, 0 mistakes per CHARTER-TIER GATE-did-not-fire path + S363 verifier mentioned but row not yet appended)
3. `agent-workspace/memory/mistake-log.md` (last 60 LOC digest; M-S357-1 INLINE-RESOLVED UTC+7 fix / M-S354-NONE / M-S342-1 medium / M-S341-1 low — **no VN-NLP-lexicon-impl-specific failure pattern history**; M-S360-2 carry-forward documents Opus PLAN budget recalibration empirical ratification)
4. `agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md` (parent master plan; offset 1-400 + 400-700 read; §s A/B/C/D/E/F/G/H/J/K/L/M/N/P covering all sub-plan contracts; CONFIRMED sub-plan 030 § E.2 row + DD-4 LEXICON-PATTERN-PORT + § K.2 anticipated FLAGS for sub-plan 030 + AQ-8 corpus labelling answer)
5. `agent-workspace/session-plans/completed/029-S361-phase-e1-vn-tokenization.md` (precedent sub-plan; offset 1-1100 read in 3 chunks; §s A/B/C/D/E/F/G/H/I/J/K/L/M/N — full template for sub-plan 030 structure mirror)
6. `agent-workspace/memory/observations/sandwich-architect-S361-phase-e1-tokenization-plan.md` (precedent observation; offset 1-80 read; format reference for S364 observation file)
7. `agent-workspace/memory/decisions/070-vn-tokenizer-library.md` (ADR D-070; full read 100 LOC; pyvi==0.1.1 selection + license = MIT + revisit triggers; THIS sub-plan honors trigger 1 via held-out corpus eval at DoD floor)
8. `agent-workspace/calibration/vn_tokenizer_eval_v0.md` (precedent calibration file; full read 102 LOC; format reference for vn_sentiment_lexicon_v0.md calibration recipe; n=36 corpus baseline; CafeF=0 gap noted)
9. `packages/domain/news/value_objects/sentiment.py` (full read 31 LOC; Sentiment 5-class StrEnum — Theme I sub-plan 030 scoring categorical mapping target)
10. `packages/domain/news/models/extracted_claim.py` (full read 83 LOC; ExtractedClaim invariants + Rule 6 grounding + ≤500 char excerpt cap + entity-grounding; future E.3 consumer of lexicon score)
11. `packages/domain/news/services/claim_extraction_service.py` (full read 70 LOC; LlmExtractorProtocol contract — VnLexiconProtocol design mirror for D1)
12. `packages/application/nlp/ports/text_tokenizer_port.py` (full read 51 LOC; TextTokenizerPort Protocol — DI consumer for D2 lexicon)
13. `packages/infrastructure/nlp/vn_tokenizer.py` (full read 148 LOC; VnTokenizer pyvi adapter + WhitespaceTokenizer fallback — DI source for D2 lexicon)
14. `agent-workspace/research/INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md` § Theme I (lines 232-278 read via Grep; underthesea+pyvi sub-deliverables + lexicon design recipe + cultural anchors + calibration from labelled corpus mandate + I-S1 + Principle 8 cross-references)
15. `agent-workspace/memory/observations/master-planner-A-14-deepdive-TradingAgents-CN.md` § 3.5 + § 7.3 + § 7.8 (offset 140-200 + 240-330 read; CN sentiment lexicon weight-dict pattern + score-normalization formula + VN cultural anchors + hand-tune anti-pattern explicit veto)
16. `agent-workspace/memory/observations/master-planner-A-01-deepdive-ai-hedge-fund.md` (offset 1-103 read; C9 Buffett-style confidence rubric + R3 LLM-self-reported anti-pattern — for DD-7 calibration tier mapping)
17. `agent-workspace/constitution/financial-data-protocol.md` Rule 7 + Rule 16 (offset 160-180 + 355-477 read; Sentiment categorical + Rule 16 mode-2 deterministic-pipeline-echo authoritative spec)
18. `.claude/skills/prompt-engineering/SKILL.md` (full read 140 LOC; § No-LLM-Math pattern + § Validation Pre-Conditions confirm rule-based lexicon scoring satisfies I-S1 by construction; calibration cycle pattern)
19. `.claude/agents/sandwich-architect.md` (full read 250 LOC; Phase 1b template L42-65 cold-start path + L207-210 observation mandate + L110-120 sub-track 3 mandatory fields; recalibrated budget table per M-S360-2)
20. `pyproject.toml` (read full 195 LOC at S362 time; pyvi>=0.1.1 now present per S362 dev add; sub-plan 030 expects ZERO new deps — uses stdlib + pyvi + dataclasses)
21. Glob `apps/extraction/**/*.py` — 0 matches (CONFIRMED `apps/extraction/sentiment/` is NEW namespace per D2/D3; clean baseline)
22. Glob `apps/_shared/**/*.py` — 12 files confirmed; reuse pattern (rate_limiter.py per-file header style + D-059 compliance comment)
23. Glob `packages/application/nlp/**/*.py` — 3 files confirmed (text_tokenizer_port.py + __init__.py × 2); D1 adds vn_lexicon_port.py
24. Glob `data/raw/news/**/*.html` (5 article files confirmed at parent master plan time; expectation: sub-plan 030 IMPL expands per § STEP 0.2 to ~200-500)
25. Glob `agent-workspace/calibration/**/*.md` — 1 file `vn_tokenizer_eval_v0.md` (from sub-plan 029); D4 adds `vn_sentiment_lexicon_v0.md`
26. Glob `agent-workspace/memory/decisions/0*.md` — 60 ADRs; D-070 most recent VN-NLP-related; D-071 next slot
27. Grep `lexicon|sentiment_score|positive_keywords|negative_keywords` across repo — 8 matches all in agent-workspace observation/master-plan/supplement files; ZERO production code references; clean baseline for D2
28. Grep `VnSentiment|vn_lexicon|VnLexicon` across repo — 3 matches all in agent-workspace docs; ZERO production code; clean baseline

**Calibration parameters extracted**:

- **task_class**: `vietnamese-nlp-impl` (PRECEDENT n=1 from S362; sub-plan 030 IMPL inherits this precedent)
- **sample_size**: **1** (S362 IMPL: ~159K Sonnet over ~39 min, 1053/1053 tests, 0 mistakes per current-execution.md S362 row; per Karpathy P1 calibration over confidence — n=1 narrow-variance window; sub-plan 030 IMPL projected to fit similar envelope unless corpus-labelling cycle inflates significantly)
- **avg_wall_min observed**: ~39 min (S362 single sample; precision low at n=1)
- **avg tokens_real observed**: ~159K Sonnet (S362 single sample; precision low at n=1)
- **parallel_hit_rate**: N/A precise (n=1; S362 IMPL had D3+D4 parallel projected per plan-029 § E coordination_paths_exclusive; actual parallel-hit not telemetered per L-S354-2)
- **parallel_savings_avg**: N/A precise; THIS plan projects D3+D4 parallel (~5-10% wall reduction) similar to plan-029 projection
- **failure_mode frequency**: 0 mistakes per S362 single sample (M-S362-NONE per dev self-report — clean cycle); n=1 directional; sub-plan 030 may surface MORE defects than S362 because corpus-labelling cycle adds independent failure surface beyond library-eval+adapter-wiring shape of S362
- **Adjustment to default budget**: NONE for adapter+tests portion (mirror S362 ~159K Sonnet); +30-50K Sonnet reserve for STEP 0 corpus-labelling cycle IF CHARTER-TIER GATE STOP-AND-ASK does NOT fire (i.e. project-owner picks option (a) hand-label OR (b) LLM-bootstrap); +0K if GATE fires (dev pauses cleanly + re-dispatched post-gate)
- **Cold-start?**: **NO for vietnamese-nlp-impl task-class** (n=1 precedent from S362 — variance window narrow but exists); **YES for sub-plan-030-specific lexicon-calibration-cycle shape** (no precedent; corpus-labelling cycle is novel work surface in StockForge)

**PLAN BUDGET DERIVATION** (Phase 1b reasoning trail for downstream S365 dev):

- S365 dev IMPL projection: **100-150K Sonnet FOCUSED_IMPL** per recalibrated CLAUDE.md table + n=1 precedent (S362 ~159K Sonnet fit within envelope; sub-plan 030 expected similar shape unless corpus-labelling cycle inflates) + 30-50K reserve for STEP 0 corpus-labelling cycle
- STEP 0 evaluation overhead: ~25-40K (corpus expansion CLI runs + initial keyword hand-curation + lexicon design + cross-validation harness scaffolding — variable depending on STEP 0.5 outcome)
- D1 port: ~4-6K (≤60 LOC Protocol + docstring)
- D2 lexicon dict + adapter: ~25-35K (~330 LOC: 200-500 keyword dict + scoring fn + DI wiring + D-059 compliance check)
- D3 tests: ~20-30K (≥15 cases × ~25 LOC each = ~350 LOC tests)
- D4 calibration recipe: ~10-15K (≤100 LOC markdown recipe + cross-validation harness sketch)
- D5 CLI smoke: ~6-10K (≤100 LOC click harness reading SQLite OR HTML files + scoring + JSON output)
- ADR D-071 + observation + session log: ~10-15K
- STOP-AND-ASK file (CONDITIONAL on corpus-labelling gate): ~5-10K
- Reserve for inline F-fix per crawler-adapter-impl + vietnamese-nlp-impl pattern (1 IMPORTANT defect per cycle): ~10-15K
- **Total projected dev budget envelope**: 90-130K typical; 120-160K with STEP 0.5 STOP-AND-ASK path; full 150K Sonnet cap respected per recalibrated table

**PARALLEL OPPORTUNITY** (architect declaration for downstream S365 dev):

- D1 (port) must serialize FIRST as foundation (~3 min wall)
- D2 (lexicon + scoring fn) must wait for D1 (~15-20 min wall — bulk is keyword hand-curation NOT scaffold; STEP 0 corpus-collection-cycle already absorbed)
- D3 (tests) + D4 (calibration recipe) can run in parallel post-D2 ship — disjoint file scopes per § E coordination_paths_exclusive (max(8, 5) = ~8 min)
- D5 (CLI smoke) must wait for D2 (sequential after lexicon ships; ~5 min wall)
- Sequential wall projection: 3 + 18 + 8 + 5 + 5 = ~39 min wall
- Parallel D3+D4 wall projection: 3 + 18 + 8 + 5 = ~34 min wall (~13% reduction)
- 2-parallel within 3-ceiling per plan-025 DD-5; no parallel-dispatch risk

**WHY n=1 PRECEDENT IS HONORED HONESTLY**:

- L-S354-2 carry-forward (planner-stats infrastructure gap from S355 verifier) means NO empirical telemetry for ANY task_class is auto-populated; manual reading via current-execution.md S362 row + mistake-log + observations is the substitute path
- S362 dev was Sonnet 4.6 per S362 close row; this sub-plan recommends Sonnet for S365 dev per M-S360-2 (sandwich-dev back on Sonnet ratification)
- n=1 narrow-variance window means budget envelope is DIRECTIONALLY grounded but PRECISION-LOW; sub-plan 030 may legitimately exceed S362 budget IF corpus-labelling cycle is more complex than library-eval was; full 150K Sonnet envelope honored for absorption
- corpus-labelling cycle shape is structurally different from library-eval shape — using S362 (library-eval) n=1 for sub-plan 030 (lexicon+calibration) shape is partial-fit (the adapter-wiring + tests + CLI portions transfer cleanly; the corpus-labelling portion is novel)
- Architect declares: **n=1 precedent honored for adapter-wiring portion + EXPLICIT cold-start for corpus-labelling-cycle shape**; sub-plan 031 + 032 inherit growing precedent (n=1 → n=2 → n=3 → ...) per parent plan-028 L-S360-2 incremental calibration mandate

---

## B. In-scope / Out-of-scope (FOCUSED_IMPL-level for S365 dev)

### IN-scope (S365 dev MUST ship)

- VnLexiconPort Protocol module + docstring (~60 LOC at `packages/application/nlp/ports/vn_lexicon_port.py`)
- VnSentimentLexicon concrete adapter wrapping lexicon dict + scoring fn (~330 LOC at `apps/extraction/sentiment/vn_lexicon.py`)
- Unit tests (≥15 test cases; synthetic VN text fixtures inline) (~350 LOC at `apps/extraction/sentiment/test_vn_lexicon.py`)
- Calibration recipe markdown (~100 LOC at `agent-workspace/calibration/vn_sentiment_lexicon_v0.md`)
- CLI score_vn_sentiment.py harness for D5 integration smoke (~100 LOC at `apps/cli/score_vn_sentiment.py`)
- ADR D-071 PROPOSED at IMPL tier — records lexicon design + calibration recipe + Buffett-rubric tier mapping + 3 revisit triggers
- STEP 0 corpus expansion log + initial keyword hand-curation record appended to vn_sentiment_lexicon_v0.md
- Session log + observation file
- Mistake-log digest entry (M-S365-N if mistakes; OR explicit "no mistakes" statement)
- Plan-030 moved `pending/` → `completed/` at S366 close (NOT at S365 close — verifier acceptance gates the move; matches plan-020/022/026/027/029 precedent)

### OUT-of-scope for S365 dev (DEFERRED — explicit non-goals)

- Sub-themes E.3 (claim extraction wrapper) + E.4 (ticker resolver) work — separate sub-plans 031/032
- Sentiment-score integration into ClaudeLlmExtractor (E.3 sub-plan 031 AUGMENT pattern)
- Sentiment-score persistence to database (deferred per § A.3; lexicon is transient transform consumed at E.3 claim-emission time)
- Caching / memoization (deferred per § A.3)
- PhoBERT fallback adapter (E.2-V2 per § A.3 trigger)
- Custom-trained VN-financial-domain BERT (E.2-V3 per § A.3 trigger)
- Async sentiment-scoring interface (deferred per § A.3)
- Lexicon entry version-control via per-entry git annotations (deferred per § A.3)
- Lexicon weight A/B testing harness (deferred per § A.3)
- Sentiment-score historical regression dashboard (deferred per § A.3; AP-23 2+ instance trigger)
- Multi-language sentiment scoring (deferred per § A.3)
- Lexicon-determinism check hook (deferred per § A.3; AP-23 2+ instance trigger)

---

## C. STEP 0 — BLOCKING DEPENDENCY EVALUATION (sub-step 0.1 through 0.7)

> **CRITICAL**: STEP 0 is BLOCKING — S365 dev MUST complete sub-steps 0.1-0.7 + (CONDITIONAL) 0.5-STOP-AND-ASK before writing ANY production code in D1-D5. This is the LEXICON-PATTERN-PORT + CALIBRATE pattern per parent plan-028 DD-4 + plan-030 binding_decisions.

### Sub-step 0.1 — Re-read parent master plan + DD-4 + § K.2 + AQ-8 + this sub-plan in full (VBW empirical)

**Dev action**: Read these files at S365 entry (architect has done this for THIS plan; dev does fresh VBW read per AOM + AP-1 fresh-context):

- `agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md` § DD-4 (lines ~283-295) + § K.2 sub-plan 030 anticipated flags (lines ~591-595) + AQ-8 corpus labelling answer (lines ~486-488) + § Out-of-scope item "PhoBERT fallback"
- THIS sub-plan-030 in full + parent master plan § E.2 sub-plan-030 row in § E sequencing table (line ~417) + plan-028 DD-4 LEXICON-PATTERN-PORT recipe (line ~286-291)
- `agent-workspace/session-plans/completed/029-S361-phase-e1-vn-tokenization.md` § DD-2 (CONDITIONAL library selection precedent for STEP 0.5 STOP-AND-ASK pattern adoption)
- `agent-workspace/memory/decisions/070-vn-tokenizer-library.md` (ADR D-070 § Revisit triggers — trigger 1 'pyvi quality <50% on sub-plan 030 held-out corpus eval n=200+' — THIS sub-plan triggers a held-out corpus eval as side effect of labelling cycle)
- `agent-workspace/calibration/vn_tokenizer_eval_v0.md` (precedent calibration file format)

**STOP-AND-ASK trigger**: NONE (foundational read; no decision yet)

**Acceptance**: Dev observation file cites parent plan-028 line numbers for DD-4 + K.2 + AQ-8 verbatim quotes; cites plan-029 DD-2 + ADR D-070 line numbers; cites vn_tokenizer_eval_v0.md as calibration-file format reference

### Sub-step 0.2 — Expand VN financial-news corpus to n=200-500 articles (labelling target)

**Dev action**:

1. Glob `data/raw/news/**/*.html` to enumerate current corpus
   - **Expected baseline at S365 entry**: n=36 articles per sub-plan 029 STEP 0.2 expansion (NDH=14 + Vietstock=10 + VietnamBiz=12 + CafeF=0); may have grown if sub-plan 029 dev added more during STEP 0.2
2. **Run existing adapter CLIs to expand corpus to n=200-500** target (per parent master plan § A.4 + DD-4 step 5):
   ```bash
   # CafeF first (highest-priority source; ZERO at S362 STEP 0.2 due to selector issue):
   python apps/cli/ingest_news_cafef.py --tickers VHM,FPT,HPG,VIC,MSN,VCB,TCB,HDB,SAB,VRE --max-articles 50 --skip-llm --output /tmp/corpus-S365-cafef.sqlite
   # NDH:
   python apps/cli/ingest_news_ndh.py --tickers VHM,FPT,HPG,VIC,MSN,VCB,TCB,HDB,SAB,VRE --max-articles 50 --skip-llm --output /tmp/corpus-S365-ndh.sqlite
   # Vietstock:
   python apps/cli/ingest_news_vietstock.py --tickers VHM,FPT,HPG,VIC,MSN,VCB,TCB,HDB,SAB,VRE --max-articles 50 --skip-llm --output /tmp/corpus-S365-vietstock.sqlite
   # VietnamBiz:
   python apps/cli/ingest_news_vietnambiz.py --tickers VHM,FPT,HPG,VIC,MSN,VCB,TCB,HDB,SAB,VRE --max-articles 50 --skip-llm --output /tmp/corpus-S365-vietnambiz.sqlite
   ```
   - 4 sources × ~50 articles = ~200 articles target; full ~500 = 4 × ~125
   - Wall-clock budget: ~50 articles × 4 sources × 2.5s avg rate-limit = ~500s per source = ~33 min total (within session budget)
   - Charter compliance: respects I-S34 rate limits already enforced by each adapter
3. **CafeF gap mitigation**: per sub-plan 029 vn_tokenizer_eval_v0.md "CafeF corpus gap" section — CafeF returned 0 articles during sub-plan 029 STEP 0.2; investigate first (1-2 min wall) before assuming gap persists; if CafeF still 0, proceed with NDH+Vietstock+VietnamBiz expansion + flag in observation as "thin-CafeF-evidence"
4. Extract `body_text` per article (use existing `ScrapedArticle.body_text` field at `packages/infrastructure/news/cafef_scraper.py:50` — flow: HTML → BeautifulSoup → extract `<article>` body → `.get_text()`)

**STOP-AND-ASK trigger (a)**: Corpus expansion fails (e.g. 4 sources all rate-limit-blocked / 5xx errors / 45-min wall-clock budget exceeded) → write `human-workspace/notifications/STOP-FINDING-S365-corpus-expansion-failed.md` with (1) which sources failed, (2) what error patterns, (3) options for user pick: (a) defer E.2 IMPL pending Phase D adapter fix, (b) proceed with smaller n=36-100 corpus + flag in observation as "thin-evidence calibration", (c) ask user to provide alternative corpus

**Acceptance**: ≥150 articles available for STEP 0.5 labelling cycle (n=150 minimum threshold per architect calibration-floor; full n=200-500 preferred for Principle 8 calibration robustness; per master plan § A.4 + DD-4 step 5)

### Sub-step 0.3 — Initial Vietnamese keyword hand-curation (~200-500 keywords)

**Dev action**:

1. **Architect-curated v0 keyword set** (this plan inlines initial seed; dev expands at IMPL time):
   - **Strongly positive (weight 1.0)** ~30 keywords: tăng trần / kịch trần / lập đỉnh / phá đỉnh / bứt phá / vượt đỉnh / siêu tăng / siêu lợi nhuận / tăng vọt / bùng nổ / hồi phục mạnh / chốt lời lớn / lập kỷ lục / x2 / x3 / x5 / đột phá lịch sử / siêu cổ phiếu / dòng tiền cuồn cuộn / mua ròng lớn / mua ròng mạnh / siêu sao / siêu phẩm / tăng mạnh / lãi kỷ lục / lãi đột biến / lãi gấp / lợi nhuận đột biến / siêu cổ
   - **Moderately positive (weight 0.5)** ~50 keywords: tăng / lên giá / khởi sắc / cải thiện / tích cực / hồi phục / phục hồi / mua ròng / khả quan / tốt / hiệu quả / lợi nhuận / lãi / lãi ròng / doanh thu tăng / kết quả tích cực / chia cổ tức / thưởng cổ phiếu / chốt lời / triển vọng / cơ hội / đầu tư / mở rộng / phát triển / tăng trưởng / sáp nhập / thâu tóm / mua lại / nâng hạng / niêm yết mới / chào sàn / phát hành thành công / cổ tức cao / cải tổ / tái cấu trúc / tăng vốn / phát hành cổ phiếu / vượt kế hoạch / hoàn thành kế hoạch / bứt tốc / khả thi / hấp dẫn / sinh lời / giá trị / ổn định / dài hạn / trung hạn / bền vững / chiến lược tốt / mô hình tốt
   - **Mildly positive (weight 0.2)** ~30 keywords: hồi / xanh / quan tâm / chú ý / khuyến nghị mua / khuyến nghị / triển vọng tốt / khả năng / tiềm năng / dự kiến / kế hoạch / mục tiêu / dự báo / lộ trình / chiến lược / phương án / giải pháp / quyết định / phát hành / đầu tư / bổ sung / tăng cường / mở rộng / phát triển / thuận lợi / điều kiện tốt / yếu tố tích cực / xu hướng / momentum / dòng tiền
   - **Mildly negative (weight -0.2)** ~30 keywords: giảm / điều chỉnh / chốt lời / chốt lãi / dao động / biến động / thận trọng / cẩn trọng / chậm lại / hạ / hạn chế / rủi ro / khó khăn / thách thức / áp lực / lo ngại / e ngại / theo dõi / xem xét / cảnh giác / phòng vệ / chốt non / cắt lỗ nhỏ / điều chỉnh nhẹ / dao động hẹp / lình xình / đi ngang / sideway / yếu / yếu đi
   - **Moderately negative (weight -0.5)** ~50 keywords: giảm sâu / lao dốc / lỗ / lỗ ròng / lỗ nặng / doanh thu giảm / kết quả tiêu cực / bán ròng / bán tháo / xả hàng / áp lực bán / bán mạnh / sụt giảm / hạ giá / phá sản / nợ xấu / nợ khó đòi / thua lỗ / khó khăn tài chính / thua kế hoạch / không đạt kế hoạch / cảnh báo / kiểm soát / hạn chế / tách niêm yết / hủy niêm yết / điều tra / xử phạt / vi phạm / sai phạm / gian lận / lừa đảo / khủng hoảng / thoái vốn / bán cổ phiếu / cổ đông lớn bán / thoái lui / tái cấu trúc khẩn cấp / thanh lý / chuyển sàn xuống / giảm vốn / cổ phiếu rác / cổ phiếu kém / cổ phiếu yếu / không khả quan / tiêu cực / xấu / thua lỗ liên tiếp / âm vốn chủ sở hữu / âm dòng tiền / mất thanh khoản
   - **Strongly negative (weight -1.0)** ~30 keywords: giảm sàn / kịch sàn / lao dốc không phanh / sụp đổ / thảm bại / siêu thua lỗ / lỗ kỷ lục / âm vốn / phá sản / hủy niêm yết / đình chỉ giao dịch / tạm ngừng giao dịch / cấm giao dịch / cổ phiếu bị buộc bán / giải thể / phá sản chính thức / khởi tố / bắt giữ / điều tra hình sự / lừa đảo lớn / gian lận tài chính / bóc trần / kê khai gian dối / không có khả năng thanh toán / x0 / mất trắng / vỡ nợ / nợ xấu lớn / khủng hoảng / phá nát
2. **VN-specific cultural anchors (MANDATORY per DD-4 + DD-2)**:
   - **"đội lái"** (pump-group / price-manipulation cluster) — weight -0.8 (strongly negative because manipulation is risk signal for retail investors)
   - **"lái"** (price-manipulation; subset of "đội lái") — weight -0.6 (moderately negative; less specific than đội lái)
   - **"đu đỉnh"** (FOMO buyer at top) — weight -0.7 (strongly negative because describes retail trap pattern)
   - **"bắt đáy"** (bottom-fisher / catch-the-knife) — weight -0.4 (moderately negative because describes risky strategy; less negative than đu đỉnh because some bắt đáy is rational)
   - **"phím hàng"** (insider tip / stock pumping) — weight -0.5 (moderately negative; suggests manipulation)
   - **"bơm thổi"** (pump-and-dump) — weight -0.7 (strongly negative)
   - **"cá mập"** (whale / big-money manipulator) — weight -0.3 (mildly negative context-dependent)
   - **"hàng zin"** (legitimate stock) — weight +0.3 (mildly positive; retail term for quality)
   - **"sóng"** (wave / momentum cycle) — weight 0.0 (neutral context-dependent; can be positive or negative)
3. **Hand-curated source documentation per I-S2**: each keyword traces to (a) architect-curated source (this plan's seed set) OR (b) S365 dev addition (must cite source in dev observation file)
4. Total v0 keyword count target: ~200-300 (seed set above ≈ 220); calibration cycle may add up to ~500

**STOP-AND-ASK trigger**: NONE (foundational hand-curation; project-owner addition/revision is calibration-cycle work in STEP 0.5 + D4 calibration recipe)

**Acceptance**: Dev observation file lists final v0 keyword count + cultural-anchor count (≥7 of 9 mandatory anchors above) + per-tier counts

### Sub-step 0.4 — Rule 16 mode-2 by-construction audit (BINDING per § Charter compliance)

**Dev action**:

1. **Audit lexicon scoring path for LLM invocation** — grep `import anthropic|import openai|from anthropic|from openai|claude_subagent|llm_extractor` in `apps/extraction/sentiment/vn_lexicon.py` (when written); expect ZERO matches
2. **Audit numeric output fields** — the lexicon emits these numeric scores (Rule 16 mode 2 satisfaction by construction):
   - `numeric_score: float in [-1.0, 1.0]` — computed via lexicon-weight summation `sum(weight_i for keyword_i in matched_keywords) / 3.0` then `max(-1.0, min(1.0, raw_score))` (mirrors A-14 § 3.5 normalization formula); NO LLM involvement
   - `coverage_ratio: float in [0.0, 1.0]` — computed as `len(matched_keywords) / max(1, len(tokens))`; deterministic; NO LLM
   - `category: Sentiment` — categorical mapping via Buffett-rubric tier per DD-7; deterministic; NO LLM
   - `keyword_hits: tuple[str, ...]` — audit trail of matched keywords; deterministic; NO LLM
3. **Document Rule 16 mode-2 satisfaction inline** — at `apps/extraction/sentiment/vn_lexicon.py` module docstring + scoring fn docstring: `# I-S1-1: deterministic echo of lexicon_weight_sum(...)` per Rule 16 § Enforcement schema-time guidance

**STOP-AND-ASK trigger**: ANY lexicon scoring path imports LLM SDK → FIRE STOP-AND-ASK with notification `human-workspace/notifications/STOP-FINDING-S365-rule-16-violation.md` documenting (1) which import, (2) which field affected, (3) options: (a) refactor to pure-function, (b) escalate to CHARTER-TIER for new mode

**Acceptance**: Empty grep result recorded; module + scoring fn docstrings cite Rule 16 mode 2; Sentiment category mapping via deterministic Buffett-rubric tiers

### Sub-step 0.5 — Corpus labelling source CHARTER-TIER GATE STOP-AND-ASK (per dispatch brief flag (a) + plan-028 § K.2)

**Dev action**:

1. **Read current corpus expansion result from STEP 0.2** — confirm n≥150 articles available for labelling
2. **Present 3 labelling-source options** for user ratification (per AQ-8 in parent plan-028 + dispatch brief flag (a)):
   - **(i) Project-owner manual labelling** — highest quality; ~hours per 100 articles; full control; CHARTER-TIER decision if scaled (could be ~5-50 hours wall-clock depending on n)
   - **(ii) LLM-bootstrap labelling with 5% spot-check** — LLM (Claude subagent dispatch per `anthropic_api_to_subagent` rule) scores each article; project-owner audits 5% sample per Rule 6 sampling pattern; ~30-60 min wall-clock for LLM dispatch + ~30-60 min wall-clock for spot-check
   - **(iii) Distant-labelling via market signals** — price-move-on-publish-date as proxy for sentiment polarity (positive price move → positive sentiment label); quasi-supervision; ~5-10 min wall-clock automated; QUALITY CAVEAT: market signal is noisy (other factors confound); requires VN price-data availability for publish dates
   - **(iv) DEFER calibration; ship lexicon with hypothesis weights only** — explicit "UNCALIBRATED-V0" docstring; calibration cycle re-runs at sub-plan 030-V2 once labelling source ratified; satisfies plan ship-it discipline; LOWEST quality risk
3. **Architect-recommended option per Karpathy P2 simplicity + Principle 8 calibration + budget realism**:
   - **IF n=150-200 articles AND project-owner available**: Option (i) — highest quality + Principle 8 ground truth; budget ~5-10 hours owner time over 1-2 days
   - **IF n=200-500 articles AND project-owner availability limited**: Option (ii) — LLM-bootstrap with 5% spot-check + sub-plan-030 follow-on architect-owner-labelling pass when convenient
   - **IF labelling-source ambiguous OR project-owner unavailable**: Option (iv) — ship UNCALIBRATED-V0 with explicit docstring + revisit trigger when project-owner available
   - **Option (iii) DEFERRED** — market-signal labelling is too noisy for v0 ground truth; revisit if project-owner is wholly unavailable for ≥1 month
4. **CHARTER-TIER GATE STOP-AND-ASK protocol** (MANDATORY per dispatch brief flag (a) + plan-028 § K.2 + this plan § CHARTER-TIER GATE):

   IF labelling source not pre-decided by main session (default; expected case):
   - DO NOT proceed to D1 IMPL with calibrated weights — D1+D2+D3 can proceed with hypothesis weights + UNCALIBRATED-V0 docstring + STOP-FINDING file
   - OR if labelling source is decided AT STEP 0.5 by main-session-dispatched AskUserQuestion: proceed accordingly per option (i)/(ii)/(iv) recipe
   - Write `human-workspace/notifications/STOP-FINDING-S365-corpus-labelling-source.md` with:
     ```markdown
     ---
     level: ALERT
     created_at: 2026-05-XXTXX:XX:XXZ
     status: pending-user-pick
     decision_class: CHARTER-TIER
     ---
     
     # STOP-AND-ASK — Corpus labelling source (S365 sub-plan 030 STEP 0.5)
     
     ## Empirical findings
     - **Corpus expanded**: n=<NN> articles across CafeF=<a>/NDH=<b>/Vietstock=<c>/VietnamBiz=<d> (per STEP 0.2)
     - **v0 lexicon**: ~220 keywords with hypothesis weights (per STEP 0.3 hand-curation seed set)
     - **Calibration cycle requires labelled corpus** per Principle 8 + A-14 § 7.8 anti-pattern explicit veto
     
     ## Options for user ratification (per parent plan AQ-8 + this plan § CHARTER-TIER GATE)
     
     (i) **Project-owner manual labelling** — highest quality; ~5-10 hours owner time / ~1-2 days wall
         - Pro: ground-truth quality; full project-owner control
         - Con: requires owner availability; sustained time commitment
         - Action: dev proceeds D1-D5 with hypothesis weights; owner labels offline; calibration cycle re-runs at sub-plan-030-V2 (no need for separate plan; recalibration is data-only update)
     
     (ii) **LLM-bootstrap with 5% spot-check** — Claude subagent dispatch labels each article; owner spot-checks ≥5% sample per Rule 6 sampling pattern
         - Pro: faster than manual; ~30-60 min LLM + ~30-60 min spot-check vs. ~5-10 hours
         - Con: LLM-self-reported labels may carry systematic bias; spot-check sample size statistical floor (5% of 200 = 10 articles, marginal)
         - Action: dev proceeds D1-D5; LLM labels happen via subagent dispatch (anthropic_api_to_subagent compliant); owner spot-checks at owner-convenience
         - CHARTER-TIER consideration: 5% sampling pattern is Rule 6 production-claim-extraction; lexicon-calibration sampling is META-level (sampling about sampling); may need new I-S<N> for calibration-meta sampling discipline (FLAG per plan-028 § K.2 — anticipated; ratification path = separate ADR)
     
     (iii) **Distant-labelling via market signals** — DEFERRED per architect recommendation (noise too high for v0 ground truth; revisit only if project-owner wholly unavailable ≥1 month)
     
     (iv) **DEFER calibration; ship UNCALIBRATED-V0** — lexicon ships with hypothesis weights + explicit "UNCALIBRATED-V0" docstring + calibration recipe-only in D4
         - Pro: unblocks E.3 sub-plan 031 dispatch immediately; lexicon usable for hint injection even without calibration
         - Con: cross-validation accuracy ≥70% DoD floor cannot be empirically verified; lexicon quality unknown
         - Action: dev proceeds D1-D5 with hypothesis weights; D4 calibration recipe documents WHAT TO DO when labelling source ratified
     
     ## Recommended option (architect-judgement per Karpathy P2 + budget realism)
     - **IF project-owner available**: Option (i) — highest quality; calibration adds 1-2 days wall but ships in a follow-on data-only update without blocking E.3
     - **IF project-owner availability unknown / time-sensitive**: Option (iv) — ship UNCALIBRATED-V0 + unblock E.3; recalibrate later
     - **Option (ii)**: AVAILABLE but only if owner explicitly chooses LLM-bootstrap (carries CHARTER-TIER meta-sampling FLAG)
     
     Awaiting user pick before S365 dev decides D2 lexicon "calibrated" vs "UNCALIBRATED-V0" docstring posture.
     ```
   - Wait for user pick via AskUserQuestion gate dispatched by main session
   - **DO NOT BLOCK D1-D5 IMPL on user pick** — D1+D2+D3+D5 can ship with hypothesis weights + UNCALIBRATED-V0 docstring + STOP-FINDING file; D4 calibration recipe documents next-step protocol
   - Record user pick in ADR D-071 § Authorization field once received

**STOP-AND-ASK trigger (CHARTER-TIER GATE)**: Corpus-labelling source not pre-decided AND main session has not dispatched AskUserQuestion → FIRE per § CHARTER-TIER GATE clause + § C above (write STOP-FINDING + proceed D1-D5 with UNCALIBRATED-V0 + flag for later recalibration)

**Acceptance**: STEP 0.5 outcome documented in dev observation file with one of: (a) "user picked (i) — calibrated path; weights tuned post-IMPL", (b) "user picked (ii) — LLM-bootstrap + 5% spot-check + meta-sampling FLAG raised", (c) "user picked (iv) — UNCALIBRATED-V0 ship", (d) "STOP-FINDING file written + dev proceeded with UNCALIBRATED-V0 + recalibration deferred"

### Sub-step 0.6 — I-S34 HARD REJECT transitive-dep grep (carry-forward from sub-plan 029 pattern)

**Dev action**:

```bash
# Sub-plan 030 expected ZERO new deps (uses stdlib + already-installed pyvi via sub-plan 029):
pip list | grep -iE "patchright|playwright[-_]stealth|fake[-_]useragent|UndetectedAdapter|StealthyFetcher|cloudflare"
# Expected: ZERO matches (pyvi already cleared at sub-plan 029 STEP 0.6)
```

**STOP-AND-ASK trigger**: ≥1 HARD-REJECT transitive dep surfaces → write `human-workspace/notifications/STOP-FINDING-S365-lexicon-i-s34-hardreject.md` + DEFER E.2 IMPL pending dep-resolution

**Acceptance**: Empty grep result recorded in observation file

### Sub-step 0.7 — D-059 determinism contract check (carry-forward from sub-plan 029 pattern)

**Dev action**:

```bash
# Smoke-test lexicon scoring output determinism (post-D2 ship):
python -c "
from apps.extraction.sentiment.vn_lexicon import VnSentimentLexicon
from packages.infrastructure.nlp.vn_tokenizer import VnTokenizer
lex = VnSentimentLexicon(tokenizer=VnTokenizer())
text = 'Cổ phiếu VHM tăng trần trong phiên giao dịch hôm nay; đội lái đã đẩy giá lên đỉnh.'
out1 = lex.score(text)
out2 = lex.score(text)
assert out1 == out2, f'NON-DETERMINISTIC: {out1} != {out2}'
print('OK: lexicon scoring is deterministic across 2 runs')
print(f'  numeric_score={out1.numeric_score:.4f}, category={out1.category.value}, hits={out1.keyword_hits}')
"
```

**STOP-AND-ASK trigger**: Output differs across 2 calls → SELECTED scoring path has non-deterministic backend → DEFER E.2 IMPL pending root-cause investigation

**Acceptance**: Determinism smoke recorded in observation file

---

## D. Architecture Decisions (DD-1 through DD-7)

### DD-1: Protocol vs ABC = `typing.Protocol` (mirrors sub-plan 029 DD-1)

**Decision**: New port at `packages/application/nlp/ports/vn_lexicon_port.py` uses `typing.Protocol` NOT `abc.ABC`. Mirrors sub-plan 029 D1 TextTokenizerPort + existing LlmExtractorPort precedent at `packages/application/news/ports/llm_extractor_port.py:28`.

```python
from typing import Protocol

class VnLexiconPort(Protocol):
    """Score Vietnamese text for sentiment polarity using rule-based lexicon."""
    def score(self, text: str) -> SentimentScore:
        """Return SentimentScore for `text` (multi-syllable VN words preserved via injected tokenizer)."""
        ...
```

**Rationale**:
- Per Karpathy P2 simplicity — Protocol = structural typing; no runtime base-class machinery needed for a 1-method port
- Per DDD tactical patterns — Protocol is preferred for "duck typing under mypy --strict" path; sub-plan 029 D1 TextTokenizerPort already established this precedent
- ABC `__init_subclass__` machinery only needed if runtime contract validation required; lexicon port has no such requirement

**Adversarial alternate considered**: ABC with `@abstractmethod` → REJECTED (Protocol is lighter; mypy --strict catches missing methods at adapter import time)

### DD-2: Lexicon storage format = Python dict literal in source file (NOT external JSON/TSV)

**Decision**: Lexicon stored as a `_VN_SENTIMENT_LEXICON: dict[str, float]` literal at module scope in `apps/extraction/sentiment/vn_lexicon.py`. NOT external JSON/TSV file. NOT YAML.

```python
# apps/extraction/sentiment/vn_lexicon.py
_VN_SENTIMENT_LEXICON: dict[str, float] = {
    # Strongly positive (weight 1.0) ~30 keywords
    "tăng_trần": 1.0,
    "kịch_trần": 1.0,
    "lập_đỉnh": 1.0,
    # ... (per STEP 0.3 seed set)
    # Cultural anchors (mandatory per DD-4)
    "đội_lái": -0.8,
    "đu_đỉnh": -0.7,
    "bắt_đáy": -0.4,
    "lái": -0.6,
    # ...
}
```

NOTE: pyvi joins multi-syllable VN words with underscore (e.g. "cổ phiếu" → "cổ_phiếu"); lexicon keys MUST match pyvi output format. Whitespace-baseline fallback splits per-word; lexicon-lookup MUST normalize input tokens to underscore-joined form when matching against lexicon keys (e.g. join consecutive tokens that form a compound; or simpler: lexicon stores both forms — defer to dev implementation choice at D2).

**Rationale**:
- Per Karpathy P2 simplicity — Python dict literal is the simplest storage; no external file I/O; no parse step; no encoding bugs
- Per Python-import-determinism — dict literal is parsed at module load; same across runs (D-059 R2 satisfaction by construction)
- Per diff-friendly review — git diff on dict literal is readable per-line; JSON/TSV/YAML diffs are noisier
- Per VBW protocol — keyword additions go through code review (git commit); no out-of-band data drift
- Storage cost ≈ 200-500 entries × ~30 bytes/entry = ~15 KB → negligible

**Adversarial alternate considered**:
- (i) JSON file at `apps/extraction/sentiment/vn_lexicon.json` → REJECTED (adds file I/O + parse step; harder to review per-line)
- (ii) TSV file at `agent-workspace/calibration/vn_sentiment_lexicon_v0.tsv` → REJECTED (calibration data lives in `agent-workspace/calibration/`; lexicon itself is production code in `apps/`; conflating them breaks separation)
- (iii) YAML file with hierarchical structure → REJECTED (YAML parse fragility + tier-grouping is incidental complexity; flat dict suffices)
- (iv) Database table → REJECTED (premature; v0 has ~220 entries; database adds infra without benefit at this scale)

### DD-3: Cultural anchors WIRED at lexicon-dict layer (NOT a separate dict)

**Decision**: Cultural anchors ("đội lái", "đu đỉnh", "bắt đáy", "lái", etc.) live IN the main `_VN_SENTIMENT_LEXICON` dict with negative weights. NOT a separate `_VN_CULTURAL_ANCHORS` dict.

**Rationale**:
- Per Karpathy P3 surgical-changes — one source of truth (one dict); no risk of forgetting to score against the cultural-anchor dict
- Per DDD tactical patterns — cultural anchors ARE sentiment-bearing keywords; same scoring path; separating them = artificial categorization
- Tier annotation in dict-literal comments preserves tier discoverability without separating dicts (e.g. `# === Cultural anchors (MANDATORY per parent DD-4) ===` section header inline)
- BUT: dev D2 ALSO publishes a `_VN_CULTURAL_ANCHORS: frozenset[str]` constant alongside the main dict for E.3 sub-plan 031 consumer (per parent DD-5 step 5 mentioned_pump_anchors field) — separate FROZENSET (not separate dict) preserves audit-trail without duplicating weight data

**Adversarial alternate considered**:
- (i) Separate `_VN_CULTURAL_ANCHORS: dict[str, float]` with own scoring path → REJECTED (duplicates infrastructure; scoring fn must walk both dicts = error-prone)
- (ii) Cultural anchors as flag-only (no weight) — output as `mentioned_pump_anchors: tuple[str, ...]` but NOT in numeric score → REJECTED (Charter Principle 4 VN-moat — cultural-anchor presence IS sentiment information for VN F0 retail-culture; treating them as flag-only loses signal)

### DD-4: Scoring function shape = `score(text: str) -> SentimentScore` (NOT `score(tokens: list[str]) -> SentimentScore`)

**Decision**: Lexicon scoring fn takes `text: str` as input and internally tokenizes via injected VnTokenizer (DI). NOT `tokens: list[str]` (which would require caller to tokenize first).

```python
def score(self, text: str) -> SentimentScore:
    """Score raw text via injected tokenizer + lexicon-weight summation."""
    if not text or not text.strip():
        return SentimentScore.empty()
    tokens = self.tokenizer.tokenize(text)  # injected VnTokenizer or WhitespaceTokenizer
    ...
```

**Rationale**:
- Per DDD tactical patterns — adapter owns its dependencies; caller sees clean text-in/score-out interface
- Per Karpathy P2 simplicity — `score(text)` is one-call; `score(tokens)` is two-call (tokenize then score); two-call increases caller complexity for marginal benefit
- DI of VnTokenizer at constructor allows test substitution (WhitespaceTokenizer in tests; pyvi VnTokenizer in production)

**Adversarial alternate considered**:
- (i) `score(tokens: list[str])` — caller tokenizes → REJECTED (split-of-concerns reduces caller convenience; E.3 sub-plan 031 would tokenize once then pass to lexicon = optimization premature per Karpathy P2; if caching needed later, decorator path is cleaner)
- (ii) `score(article: NewsArticle)` — full article object → REJECTED (domain leak; lexicon should not know about NewsArticle aggregate; pure text-in is the clean interface; E.3 caller extracts text + passes to scorer)

### DD-5: SentimentScore output shape = frozen dataclass with 4 fields

**Decision**: Lexicon emits a `SentimentScore` frozen dataclass at `apps/extraction/sentiment/vn_lexicon.py`:

```python
from dataclasses import dataclass, field
from packages.domain.news.value_objects import Sentiment

@dataclass(frozen=True, slots=True)
class SentimentScore:
    """Deterministic sentiment score per Rule 16 mode 2 + Rule 7 categorical.
    
    Fields:
    - numeric_score: Rule 16 mode 2 deterministic-pipeline echo; range [-1.0, 1.0]
    - category: Rule 7 categorical 5-class; derived from numeric_score via Buffett-rubric tier
    - keyword_hits: audit trail of matched keywords; tuple for immutability
    - coverage_ratio: Rule 16 mode 2; range [0.0, 1.0]; len(matched)/max(1, len(tokens))
    """
    numeric_score: float
    category: Sentiment
    keyword_hits: tuple[str, ...] = field(default_factory=tuple)
    coverage_ratio: float = 0.0
    
    @classmethod
    def empty(cls) -> SentimentScore:
        return cls(numeric_score=0.0, category=Sentiment.NEUTRAL, keyword_hits=(), coverage_ratio=0.0)
    
    def __post_init__(self) -> None:
        if not -1.0 <= self.numeric_score <= 1.0:
            raise ValueError(f"numeric_score {self.numeric_score} not in [-1.0, 1.0]")
        if not 0.0 <= self.coverage_ratio <= 1.0:
            raise ValueError(f"coverage_ratio {self.coverage_ratio} not in [0.0, 1.0]")
```

**Rationale**:
- Per Charter "Domain layer has ZERO framework dependency" — frozen dataclass (NOT Pydantic) lives in apps-tier (not domain); but design mirrors domain value-object discipline
- Per Rule 16 mode 2 — `numeric_score` is deterministic-pipeline echo from lexicon-weight summation; docstring documents satisfaction mode
- Per Rule 7 — `category` is Sentiment 5-class StrEnum reuse
- Per I-S2 — `keyword_hits` audit trail enables citation discipline (which keywords drove the score)
- Per Karpathy P2 simplicity — 4 fields is minimum useful surface; adding more (e.g. `tier_explanation: str`) is over-engineering for v0

**Adversarial alternate considered**:
- (i) Return only `numeric_score: float` → REJECTED (loses audit trail; E.3 consumer needs category for Sentiment field of ExtractedClaim; keyword_hits is debugging surface)
- (ii) Return a `dict[str, Any]` blob → REJECTED (mypy-strict disallow_any_explicit blocks; loses type safety; harder to test)
- (iii) Return a Pydantic model → REJECTED (apps/extraction/ is apps-tier orchestration; can technically use Pydantic per architecture.md but unnecessary; dataclass suffices)

### DD-6: Sentiment numeric-to-categorical mapping = Buffett-rubric-tier-inspired thresholds

**Decision**: Numeric score `[-1.0, 1.0]` maps to Sentiment 5-class via 5 tier thresholds (per DD-7 binding + A-01 § 3 C9 Buffett rubric pattern):

```python
_TIER_THRESHOLDS: tuple[tuple[float, Sentiment], ...] = (
    (0.7, Sentiment.STRONGLY_BULLISH),    # [0.7, 1.0]
    (0.3, Sentiment.BULLISH),              # [0.3, 0.7)
    (-0.3, Sentiment.NEUTRAL),             # [-0.3, 0.3)
    (-0.7, Sentiment.BEARISH),             # [-0.7, -0.3)
    (float("-inf"), Sentiment.STRONGLY_BEARISH),  # [-1.0, -0.7)
)

def _score_to_category(numeric_score: float) -> Sentiment:
    """Map numeric_score to Sentiment via Buffett-rubric-inspired tiers.
    
    Per ai-hedge-fund warren_buffett.py:788-794 pattern (A-01 § 3 C9):
    90-100/70-89/50-69/30-49/10-29 evidence-quality brackets adapted to
    StockForge Sentiment 5-class.
    """
    for threshold, category in _TIER_THRESHOLDS:
        if numeric_score >= threshold:
            return category
    return Sentiment.STRONGLY_BEARISH  # unreachable per __post_init__ bounds
```

**Rationale**:
- Per A-01 § 3 C9 — Buffett-rubric-tier pattern is empirically validated in ai-hedge-fund; 5-tier matches Sentiment 5-class natively
- Per Rule 16 — categorical mapping is deterministic (mode 2 satisfaction)
- Per Rule 7 — Sentiment 5-class StrEnum is the canonical surface; preserves charter compliance
- 0.3/0.7 thresholds are symmetric + intuitive; can be calibrated post-IMPL via labelled corpus (DoD floor)

**Adversarial alternate considered**:
- (i) Linear mapping (numeric_score → percentile → Sentiment) → REJECTED (requires percentile distribution; non-deterministic until calibration sample; tier thresholds are deterministic from day 1)
- (ii) 3-class collapse (BULLISH / NEUTRAL / BEARISH only) → REJECTED (loses strongly-vs-moderately distinction; Sentiment 5-class is the existing contract)
- (iii) Sigmoid mapping → REJECTED (smooth boundaries lose categorical clarity; tier thresholds give clear interpretability)

### DD-7: Calibration cycle recipe (mandatory per Principle 8 + A-14 § 7.8) — cross-validation accuracy ≥70% on held-out subset

**Decision**: Sub-plan 030 D4 ships a calibration recipe at `agent-workspace/calibration/vn_sentiment_lexicon_v0.md` documenting:

1. **Labelled corpus protocol**: source = depends on STEP 0.5 outcome (i/ii/iv per § CHARTER-TIER GATE); format = per-article tuple `(article_id, body_text, true_label: Sentiment)` stored as JSONL at `data/corpus/vn_financial_news_labelled/v0.jsonl` (gitignored per CLAUDE.md hard rule "Never edit obsidian-vault/raw/" extended — corpus data is not source code)
2. **Cross-validation harness**: `apps/extraction/sentiment/calibrate.py` (DEFERRED to sub-plan 030-V2 calibration cycle; v0 ships hypothesis weights + protocol docs only)
3. **Accuracy metric**: per-class precision/recall/F1 + macro-F1 + Cohen's kappa (NOT just raw accuracy — 5-class with imbalanced corpus may have inflated accuracy)
4. **DoD floor**: ≥70% macro-F1 on held-out subset (~20% of labelled corpus); below = E.2-V2 PhoBERT fallback evaluation triggered per § A.3 revisit trigger
5. **Weight update protocol**: per-keyword weight adjustment via gradient-free search (start with grid search ±0.1 around hypothesis weight; record changes in calibration MD)
6. **Versioning**: lexicon version field in `_VN_SENTIMENT_LEXICON_VERSION: str = "v0.HYPOTHESIS"` (or "v0.CALIBRATED" post-calibration); ADR D-071 records version + corpus-snapshot hash

**Rationale**:
- Per Charter Principle 8 calibration over confidence — hypothesis weights are NOT ground truth; calibration cycle is the ground-truth path
- Per A-14 § 7.8 anti-pattern explicit veto — CN lexicon was hand-tuned + NOT validated; StockForge MUST do better
- Per AP-7 anti-vacuous-defer — calibration protocol is documented (NOT performed in v0 if STOP-AND-ASK chooses option (iv) UNCALIBRATED-V0); revisit trigger named (lexicon coverage <70% on held-out corpus)
- v0 ships hypothesis weights + protocol; v1 ships calibrated weights post-labelling cycle

**Adversarial alternate considered**:
- (i) Hand-tune weights based on architect intuition → REJECTED per A-14 § 7.8 anti-pattern explicit veto + Charter Principle 8
- (ii) Skip calibration entirely → REJECTED (ships uncalibrated weights without documenting path forward = naked defer violating AP-7)
- (iii) Block IMPL on calibration cycle completion → REJECTED (calibration cycle is ~hours-to-days wall-clock depending on labelling source; blocking IMPL on it = budget overrun risk; ship hypothesis + recipe + revisit is the correct path)

---

## E. Sub-track decomposition (D1-D5 with parallel_with per plan-025 contract)

### D1 — VnLexiconPort Protocol (foundation; root sub-track)

- **parallel_with**: []  (foundation; D2 blocks_on D1)
- **blocks_on**: []
- **coordination_paths_exclusive**: [packages/application/nlp/ports/vn_lexicon_port.py, packages/application/nlp/ports/__init__.py (extends exports)]
- **estimated_wall_min**: 3

**Module**: `packages/application/nlp/ports/vn_lexicon_port.py` (NEW; ~60 LOC).

**Content** (architect-proposed; dev verifies + adjusts):

```python
"""VnLexiconPort — abstract port for VN sentiment lexicon scoring.

Per architecture.md § Ports & Adapters + parent plan-028 DD-7: NLP is a
cross-BC capability (BC-5 News Stream + BC-6 Influence + BC-7 Crowd all
consume sentiment-scored VN text), so the port lives in application/nlp/
namespace established by sub-plan 029 D1. Concrete adapters live in
apps/extraction/sentiment/ per parent DD-8.

Source: agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md
        § DD-4 (LEXICON-PATTERN-PORT + CALIBRATE) + DD-8 (apps/extraction/sentiment/);
        agent-workspace/session-plans/pending/030-S364-phase-e2-vn-sentiment-lexicon.md
        § DD-1 (Protocol vs ABC — mirrors sub-plan 029 D1 + LlmExtractorPort precedent).

I-S1 compliance: lexicon scoring path is LLM-free by construction — no LLM SDK
imported, no anthropic/openai call in any implementation of this port.

Rule 16 mode-2 compliance: numeric_score field on SentimentScore output is
deterministic-pipeline echo from lexicon-weight summation; no LLM involvement.

D-059 compliance (ALL implementations):
- R1 (datetime-no-tz): N/A lexicon is pure text transform; no datetime.
- R2 (unseeded RNG): lexicon MUST be deterministic; no random state.
- R4 (time.time-in-domain): N/A apps-tier orchestration, not domain.
"""

from __future__ import annotations

from typing import Protocol, TYPE_CHECKING

if TYPE_CHECKING:
    from apps.extraction.sentiment.vn_lexicon import SentimentScore  # forward-ref

__all__ = ["VnLexiconPort"]


class VnLexiconPort(Protocol):
    """Score Vietnamese text for sentiment polarity using rule-based lexicon.
    
    Implementations MUST:
    - Be deterministic — same input string => same SentimentScore (D-059 R2
      compliance; verifier grep-asserts determinism smoke at S366).
    - Return SentimentScore.empty() for empty / whitespace-only input (NOT raise).
    - Satisfy Rule 16 mode 2 — numeric_score computed via deterministic
      lexicon-weight summation; no LLM in scoring path.
    
    Implementations MAY:
    - Tokenize input via injected tokenizer (default VnTokenizer via DI).
    - Cap input text length at sensible upper bound and return empty score.
    - Cache scoring results (NOT required for v0 per DD-5 of sub-plan 030).
    """
    
    def score(self, text: str) -> "SentimentScore":
        """Return SentimentScore for ``text`` via lexicon-weight scoring."""
        ...
```

Also update `packages/application/nlp/ports/__init__.py` to export VnLexiconPort alongside existing TextTokenizerPort.

**Verify**: mypy --strict + ruff PASS on the modified files

### D2 — VnSentimentLexicon concrete adapter

- **parallel_with**: []  (D3 + D4 block_on D2; D5 blocks_on D2)
- **blocks_on**: [D1]
- **coordination_paths_exclusive**: [apps/extraction/__init__.py (NEW), apps/extraction/sentiment/__init__.py (NEW), apps/extraction/sentiment/vn_lexicon.py, agent-workspace/memory/decisions/071-vn-sentiment-lexicon.md]
- **estimated_wall_min**: 18

**Module**: `apps/extraction/sentiment/vn_lexicon.py` (NEW; ~330 LOC including ~220 lexicon entries).

**Skeleton** (architect-proposed; dev fills lexicon dict + tweaks per STEP 0.3):

```python
"""VnSentimentLexicon — concrete VnLexiconPort adapter for VN financial sentiment.

Ports the TradingAgents-CN rule-based lexicon-weight scoring PATTERN (per
A-14 § 3.5 + akshare.py:1497-1611) — PATTERN ONLY; no LOC copy (TradingAgents-CN
Apache-2.0 license safe-for-pattern-port per D-061 § Item 4; per Karpathy P2
simplicity no LOC copy needed).

VN keywords hand-curated per parent plan-028 DD-4 + plan-030 § STEP 0.3 seed set
~220 keywords across 6 tiers (1.0 / 0.5 / 0.2 / -0.2 / -0.5 / -1.0) + VN-specific
cultural anchors (đội lái / đu đỉnh / bắt đáy / lái / phím hàng / bơm thổi).

Calibration: v0 ships HYPOTHESIS weights; calibration cycle per Principle 8 +
A-14 § 7.8 anti-pattern explicit veto runs post-IMPL (recipe at
agent-workspace/calibration/vn_sentiment_lexicon_v0.md per D4).

I-S1 compliance: NO LLM in scoring path — pure-function lexicon-weight summation.
Rule 16 mode-2 compliance: numeric_score is deterministic-pipeline echo of
lexicon_weight_sum(tokens) per Rule 16 § Enforcement schema-time guidance.
Rule 7 compliance: category field reuses Sentiment StrEnum (NOT new categorical).

D-059 compliance:
- R1 (datetime-no-tz): N/A — pure text transform; no datetime.
- R2 (unseeded RNG): deterministic dict-lookup + arithmetic; no random state.
- R4 (time.time-in-domain): N/A — apps-tier orchestration, not domain.

I-S34 HARD REJECT compliance: STEP 0.6 verified ZERO transitive deps in
[patchright, playwright_stealth, fake-useragent, UndetectedAdapter,
StealthyFetcher, cloudflare-solver]; verifier re-grep at S366.

Source: agent-workspace/session-plans/pending/030-S364-phase-e2-vn-sentiment-lexicon.md
        § D2 + DD-1 through DD-7;
        agent-workspace/memory/decisions/071-vn-sentiment-lexicon.md
        (ADR records lexicon design + calibration recipe + revisit triggers).
"""

from __future__ import annotations

import logging
from dataclasses import dataclass, field

from packages.application.nlp.ports.text_tokenizer_port import TextTokenizerPort
from packages.domain.news.value_objects import Sentiment

__all__ = [
    "VnSentimentLexicon",
    "SentimentScore",
    "VN_CULTURAL_ANCHORS",
    "VN_SENTIMENT_LEXICON_VERSION",
]

_log = logging.getLogger(__name__)

# v0 = HYPOTHESIS weights; calibrated weights post-labelling cycle per D4 recipe
VN_SENTIMENT_LEXICON_VERSION: str = "v0.HYPOTHESIS"


# Tier 1: Strongly positive (weight 1.0) ~30 keywords
# Tier 2: Moderately positive (weight 0.5) ~50 keywords
# Tier 3: Mildly positive (weight 0.2) ~30 keywords
# Tier 4: Mildly negative (weight -0.2) ~30 keywords
# Tier 5: Moderately negative (weight -0.5) ~50 keywords
# Tier 6: Strongly negative (weight -1.0) ~30 keywords
# + Cultural anchors (mandatory per DD-3): đội lái -0.8 / đu đỉnh -0.7 / bắt đáy -0.4 / lái -0.6 / ...

# pyvi joins multi-syllable VN words with underscore in its output (e.g.
# "cổ phiếu" -> "cổ_phiếu"). Lexicon keys MUST match this format.
# WhitespaceTokenizer fallback splits per-word; for that fallback, lexicon
# scoring will under-match (acceptable per AQ-4 plan-029 DEFAULT-LOW-QUALITY).

_VN_SENTIMENT_LEXICON: dict[str, float] = {
    # === Tier 1: Strongly positive (weight 1.0) ===
    "tăng_trần": 1.0,
    "kịch_trần": 1.0,
    # ... (dev fills ~30 per STEP 0.3 seed)
    
    # === Tier 2: Moderately positive (weight 0.5) ===
    "tăng": 0.5,
    "lên_giá": 0.5,
    # ... (dev fills ~50)
    
    # === Tier 6: Strongly negative (weight -1.0) ===
    "giảm_sàn": -1.0,
    "kịch_sàn": -1.0,
    # ... (dev fills ~30)
    
    # === Cultural anchors (MANDATORY per parent DD-4 + plan-030 DD-3) ===
    "đội_lái": -0.8,    # pump-group / price-manipulation cluster
    "lái": -0.6,         # price-manipulation (subset of đội lái)
    "đu_đỉnh": -0.7,    # FOMO buyer at top
    "bắt_đáy": -0.4,    # bottom-fisher / catch-the-knife
    "phím_hàng": -0.5,  # insider tip / stock pumping
    "bơm_thổi": -0.7,   # pump-and-dump
    "cá_mập": -0.3,     # whale / big-money manipulator
    "hàng_zin": 0.3,    # legitimate stock (retail term for quality)
    # "sóng" intentionally omitted from lexicon (neutral context-dependent)
}

# Frozen set of cultural anchors for E.3 sub-plan 031 consumer per DD-3 +
# parent DD-5 step 5 mentioned_pump_anchors field
VN_CULTURAL_ANCHORS: frozenset[str] = frozenset({
    "đội_lái", "lái", "đu_đỉnh", "bắt_đáy",
    "phím_hàng", "bơm_thổi", "cá_mập", "hàng_zin",
})


@dataclass(frozen=True, slots=True)
class SentimentScore:
    """Deterministic sentiment score per Rule 16 mode 2 + Rule 7 categorical.
    
    Fields:
    - numeric_score: Rule 16 mode 2 deterministic-pipeline echo; range [-1.0, 1.0]
    - category: Rule 7 categorical 5-class; derived via Buffett-rubric tier per DD-6
    - keyword_hits: audit trail per I-S2 of matched keywords; tuple for immutability
    - coverage_ratio: Rule 16 mode 2; range [0.0, 1.0]
    
    Source: plan-030 § DD-5
    """
    numeric_score: float
    category: Sentiment
    keyword_hits: tuple[str, ...] = field(default_factory=tuple)
    coverage_ratio: float = 0.0
    
    @classmethod
    def empty(cls) -> "SentimentScore":
        return cls(numeric_score=0.0, category=Sentiment.NEUTRAL,
                   keyword_hits=(), coverage_ratio=0.0)
    
    def __post_init__(self) -> None:
        if not -1.0 <= self.numeric_score <= 1.0:
            raise ValueError(
                f"numeric_score {self.numeric_score} not in [-1.0, 1.0] "
                f"(Rule 16 mode 2 range violation)"
            )
        if not 0.0 <= self.coverage_ratio <= 1.0:
            raise ValueError(
                f"coverage_ratio {self.coverage_ratio} not in [0.0, 1.0]"
            )


# Buffett-rubric-inspired tier thresholds per DD-6 + A-01 § 3 C9
_TIER_THRESHOLDS: tuple[tuple[float, Sentiment], ...] = (
    (0.7, Sentiment.STRONGLY_BULLISH),
    (0.3, Sentiment.BULLISH),
    (-0.3, Sentiment.NEUTRAL),
    (-0.7, Sentiment.BEARISH),
    (float("-inf"), Sentiment.STRONGLY_BEARISH),
)


def _score_to_category(numeric_score: float) -> Sentiment:
    """Map numeric_score to Sentiment via Buffett-rubric-inspired tiers (DD-6)."""
    for threshold, category in _TIER_THRESHOLDS:
        if numeric_score >= threshold:
            return category
    return Sentiment.STRONGLY_BEARISH  # unreachable per SentimentScore __post_init__


# Score normalization formula per A-14 § 3.5 akshare.py:1563 pattern:
# normalized = max(-1.0, min(1.0, raw_score / NORMALIZATION_DIVISOR))
# Divisor calibrated to keep typical-article score in [-1, 1] range
_NORMALIZATION_DIVISOR: float = 3.0


@dataclass
class VnSentimentLexicon:
    """VN sentiment lexicon scorer wrapping injected tokenizer + lexicon dict.
    
    Constructor takes tokenizer (DI per DD-4 + sub-plan 029 D1+D2 precedent).
    Tests inject WhitespaceTokenizer; production injects pyvi VnTokenizer.
    """
    
    tokenizer: TextTokenizerPort
    lexicon_version: str = VN_SENTIMENT_LEXICON_VERSION
    
    def score(self, text: str) -> SentimentScore:
        """Return SentimentScore via lexicon-weight summation per DD-4 + DD-5.
        
        Algorithm:
        1. Tokenize text via injected tokenizer
        2. Look up each token in _VN_SENTIMENT_LEXICON dict
        3. Sum weights of matched tokens
        4. Normalize: max(-1.0, min(1.0, raw_sum / _NORMALIZATION_DIVISOR))
        5. Map normalized score to Sentiment category via _score_to_category
        6. Return SentimentScore frozen dataclass
        
        I-S1 compliance: pure-function; no LLM invocation
        Rule 16 mode 2: numeric_score is deterministic-pipeline echo of step 4
        D-059 R2: deterministic across runs (dict-lookup + float arithmetic)
        """
        if not text or not text.strip():
            return SentimentScore.empty()
        
        tokens = self.tokenizer.tokenize(text)
        if not tokens:
            return SentimentScore.empty()
        
        raw_score: float = 0.0
        keyword_hits: list[str] = []
        for token in tokens:
            # pyvi joins multi-syllable VN words with underscore;
            # whitespace fallback splits per-word; both work for direct match
            weight = _VN_SENTIMENT_LEXICON.get(token)
            if weight is not None:
                raw_score += weight
                keyword_hits.append(token)
        
        # Normalize per A-14 § 3.5 akshare.py:1563 pattern
        normalized_score = max(-1.0, min(1.0, raw_score / _NORMALIZATION_DIVISOR))
        coverage_ratio = len(keyword_hits) / max(1, len(tokens))
        category = _score_to_category(normalized_score)
        
        return SentimentScore(
            numeric_score=normalized_score,
            category=category,
            keyword_hits=tuple(keyword_hits),
            coverage_ratio=coverage_ratio,
        )
```

**ADR D-071 PROPOSED** at `agent-workspace/memory/decisions/071-vn-sentiment-lexicon.md` (NEW):

```markdown
---
id: 071
title: VN Sentiment Lexicon v0 + Calibration Loop
status: PROPOSED
date: 2026-05-XX
authors: sandwich-dev S365
level: ARCH
supersedes: []
superseded-by: []
empirical_close_verify: |
  - VnSentimentLexicon class instantiable + score() returns deterministic SentimentScore
  - mypy --strict + ruff + pytest on apps/extraction/sentiment/ exit 0
  - ≥15 unit tests PASS covering tier mapping + cultural anchors + edge cases
  - STEP 0 calibration recipe recorded at agent-workspace/calibration/vn_sentiment_lexicon_v0.md
  - Rule 16 mode 2 compliance grep-asserted: ZERO LLM imports in apps/extraction/sentiment/
  - Cultural anchors ≥7 of 9 mandatory entries present in _VN_SENTIMENT_LEXICON
  - DC-FILE-1 through DC-FILE-N all PASS per plan-030 § F
---

## Decision

VN sentiment lexicon v0 ships at `apps/extraction/sentiment/vn_lexicon.py` with
~220 hand-curated keywords across 6 weight tiers + 8 mandatory VN-cultural-anchors.
v0 ships HYPOTHESIS weights; calibration cycle per Principle 8 + A-14 § 7.8
anti-pattern explicit veto runs post-IMPL per recipe in
`agent-workspace/calibration/vn_sentiment_lexicon_v0.md`.

## Pattern source

TradingAgents-CN `tradingagents/dataflows/providers/china/akshare.py:1497-1611`
(per A-14 § 3.5) — rule-based lexicon-weight scoring pattern with score
normalization formula `max(-1.0, min(1.0, raw_score / 3.0))` at akshare.py:1563.
PATTERN ONLY adoption — no LOC copy (TradingAgents-CN Apache-2.0 safe per
D-061 § Item 4; pattern small enough to re-implement per Karpathy P2 simplicity).

## VN keyword set (hand-curated v0 hypothesis)

- Tier 1 (1.0): ~30 strongly positive
- Tier 2 (0.5): ~50 moderately positive
- Tier 3 (0.2): ~30 mildly positive
- Tier 4 (-0.2): ~30 mildly negative
- Tier 5 (-0.5): ~50 moderately negative
- Tier 6 (-1.0): ~30 strongly negative
- Cultural anchors: 8 mandatory (đội_lái, lái, đu_đỉnh, bắt_đáy, phím_hàng,
  bơm_thổi, cá_mập, hàng_zin)

Total: ~228 keywords.

## Calibration outcome (STEP 0.5)

<DEV FILLS — one of:>
- "User picked (i) project-owner manual labelling — calibration cycle runs offline; sub-plan 030-V2 recalibrates weights"
- "User picked (ii) LLM-bootstrap + 5% spot-check + CHARTER-TIER FLAG raised for calibration-meta-sampling discipline"
- "User picked (iv) UNCALIBRATED-V0 ship — lexicon ships with HYPOTHESIS weights; recalibration deferred per AP-7 trigger named below"
- "STOP-FINDING file written + dev proceeded with UNCALIBRATED-V0 + recalibration deferred"

## Buffett-rubric-tier categorical mapping (per DD-6 + A-01 § 3 C9)

- numeric_score in [0.7, 1.0] → STRONGLY_BULLISH
- numeric_score in [0.3, 0.7) → BULLISH
- numeric_score in [-0.3, 0.3) → NEUTRAL
- numeric_score in [-0.7, -0.3) → BEARISH
- numeric_score in [-1.0, -0.7) → STRONGLY_BEARISH

## Revisit triggers (per AP-7 anti-vacuous-defer)

1. Lexicon coverage <50% on held-out corpus eval (n=200+ labelled articles)
   → E.2-V2 PhoBERT fallback evaluation
2. Cross-validation macro-F1 <70% on held-out subset → calibration weight
   adjustment cycle (gradient-free search per D4 recipe step 5)
3. ≥3 unresolved cultural references in production extractor logs
   → cultural-anchor list expansion (AP-23 promote-or-extend calculus)

## Risks

- RM1: HYPOTHESIS weights may misclassify edge cases — mitigated by calibration
  recipe documenting ground-truth labelling protocol
- RM2: pyvi tokenization quality affects lexicon match-rate — DD-7 trigger 1
  monitors; held-out corpus eval is canonical metric
- RM3: cultural-anchor list may be incomplete (regional dialects / slang) —
  trigger 3 above mitigates; append-only dict makes expansion cheap

## Source

- plan-030 § C STEP 0.3 + § D DD-1 through DD-7
- agent-workspace/calibration/vn_sentiment_lexicon_v0.md (calibration recipe)
- apps/extraction/sentiment/vn_lexicon.py (implementation)
- agent-workspace/memory/observations/master-planner-A-14-deepdive-TradingAgents-CN.md § 3.5 + § 7.3 + § 7.8 (pattern source + cultural anchors + anti-pattern veto)
- agent-workspace/memory/observations/master-planner-A-01-deepdive-ai-hedge-fund.md § 3 C9 (Buffett rubric tier pattern)
```

**Verify**: ADR D-071 file exists; mypy --strict + ruff PASS; SentimentScore.__post_init__ enforces numeric bounds

### D3 — Unit tests (≥15 test cases; parallel with D4)

- **parallel_with**: [D4]
- **blocks_on**: [D2]
- **coordination_paths_exclusive**: [apps/extraction/sentiment/test_vn_lexicon.py]
- **estimated_wall_min**: 8

**Module**: `apps/extraction/sentiment/test_vn_lexicon.py` (NEW; ~350 LOC; ≥15 test cases).

**Test cases (target ≥15)**:

1. `test_score_empty_string_returns_empty_score` — `lex.score("")` returns SentimentScore.empty()
2. `test_score_whitespace_only_returns_empty_score` — `lex.score("   \n\t  ")` returns SentimentScore.empty()
3. `test_score_strongly_positive_keyword_tier_1` — text with "tăng_trần" → numeric_score ≥ 0.3 + category in {BULLISH, STRONGLY_BULLISH} + keyword_hits contains "tăng_trần"
4. `test_score_moderately_positive_keyword_tier_2` — text with "tăng" → numeric_score in [0.05, 0.3) + category in {NEUTRAL, BULLISH}
5. `test_score_strongly_negative_keyword_tier_6` — text with "giảm_sàn" → numeric_score ≤ -0.3 + category in {BEARISH, STRONGLY_BEARISH}
6. `test_score_cultural_anchor_doi_lai_negative` — text with "đội_lái" → numeric_score negative + "đội_lái" in keyword_hits
7. `test_score_cultural_anchor_du_dinh_negative` — text with "đu_đỉnh" → numeric_score negative
8. `test_score_cultural_anchor_bat_day_negative` — text with "bắt_đáy" → numeric_score negative (less than đu_đỉnh per weight -0.4 vs -0.7)
9. `test_score_mixed_positive_negative_partial_offset` — text with "tăng" + "giảm" → numeric_score ≈ 0.0 (cancel)
10. `test_score_coverage_ratio_zero_for_unmatched` — text with only non-lexicon words → coverage_ratio = 0.0
11. `test_score_coverage_ratio_positive_for_matched` — text with "tăng" + 9 other tokens → coverage_ratio = 0.1
12. `test_score_numeric_score_clamped_to_minus_one` — synthetic text with ≥5 strongly-negative keywords → numeric_score = -1.0 (clamp)
13. `test_score_numeric_score_clamped_to_plus_one` — synthetic text with ≥5 strongly-positive keywords → numeric_score = 1.0 (clamp)
14. `test_score_deterministic_across_runs` — call `score(text)` twice; assert outputs identical (D-059 R2 compliance smoke)
15. `test_score_category_strongly_bullish_threshold` — synthetic numeric_score = 0.75 → category = STRONGLY_BULLISH (tier boundary)
16. `test_score_category_neutral_at_zero` — empty-match input → category = NEUTRAL
17. `test_score_with_whitespace_tokenizer_fallback` — instantiate with WhitespaceTokenizer; verify scoring still works (lower quality acceptable)
18. `test_score_with_pyvi_tokenizer_multi_syllable` — instantiate with VnTokenizer; tokenize "cổ phiếu tăng trần" → emit "cổ_phiếu" + "tăng_trần" tokens; "tăng_trần" matches lexicon → positive score
19. `test_sentiment_score_init_rejects_out_of_range_numeric` — `SentimentScore(numeric_score=1.5, ...)` raises ValueError
20. `test_sentiment_score_init_rejects_out_of_range_coverage` — `SentimentScore(coverage_ratio=1.5, ...)` raises ValueError
21. `test_vn_cultural_anchors_frozen_set_contains_mandatory` — assert all 8 mandatory anchors in VN_CULTURAL_ANCHORS frozenset
22. `test_lexicon_satisfies_vn_lexicon_port_protocol` — duck-type check via `_: VnLexiconPort = VnSentimentLexicon(tokenizer=...)` mypy structural typing test passes
23. `test_score_logs_no_llm_invocation` — grep `import anthropic|import openai` in module source; assert ZERO matches (Rule 16 mode 2 + I-S1 by-construction smoke)

**Synthetic fixtures (architect-proposed; inline strings):**

```python
_SYNTHETIC_VN_POSITIVE_TEXT = (
    "Cổ phiếu VHM tăng trần trong phiên giao dịch. "
    "Lập đỉnh mới; bứt phá kỹ thuật. "
    "Nhà đầu tư mua ròng mạnh."
)

_SYNTHETIC_VN_NEGATIVE_TEXT = (
    "Đội lái đã đẩy giá MSN lên kịch trần. "
    "Cảnh báo: nhà đầu tư mới có thể đu đỉnh. "
    "Bắt đáy cổ phiếu này có thể rủi ro cao."
)

_SYNTHETIC_VN_NEUTRAL_TEXT = (
    "Thị trường chứng khoán Việt Nam đang trong giai đoạn tích lũy. "
    "Các chuyên gia nhận định cần theo dõi thêm."
)

_SYNTHETIC_VN_MIXED_TEXT = "VHM tăng 5% sáng nay nhưng giảm 3% chiều nay."
```

**Acceptance**: pytest exit 0; ≥15 cases pass; mypy --strict + ruff clean

### D4 — Calibration recipe + held-out validation harness sketch (parallel with D3)

- **parallel_with**: [D3]
- **blocks_on**: [D2]
- **coordination_paths_exclusive**: [agent-workspace/calibration/vn_sentiment_lexicon_v0.md]
- **estimated_wall_min**: 5

**Module**: `agent-workspace/calibration/vn_sentiment_lexicon_v0.md` (NEW; ~100 LOC).

**Content (architect-proposed; dev fills empirical results):**

```markdown
# VN Sentiment Lexicon v0 — Calibration Recipe (S365)

> Calibration recipe for `apps/extraction/sentiment/vn_lexicon.py` per
> Charter Principle 8 + A-14 § 7.8 anti-pattern explicit veto.
> Source: plan-030 § D DD-7 + D4 sub-track output.
> Re-eval trigger: per ADR D-071 revisit trigger 2 (cross-validation
> macro-F1 <70% on held-out subset) OR trigger 1 (lexicon coverage <50%
> on held-out corpus eval n=200+).

## v0 Status

- **Lexicon version**: v0.HYPOTHESIS (per `VN_SENTIMENT_LEXICON_VERSION`)
- **Calibrated**: <DEV FILLS — YES if STEP 0.5 user picked (i)/(ii) and calibration ran post-IMPL; NO if user picked (iv) UNCALIBRATED-V0>
- **Corpus**: per agent-workspace/calibration/vn_tokenizer_eval_v0.md baseline + STEP 0.2 expansion to n=<NN> articles
- **STEP 0.5 outcome**: <DEV FILLS — labelling source picked: (i)/(ii)/(iv)>

## Labelling Protocol

### Source decision (per STEP 0.5 CHARTER-TIER GATE + AQ-8 + plan-028 § K.2)

<DEV FILLS — based on user pick at STEP 0.5>

### Per-article tuple format (JSONL at `data/corpus/vn_financial_news_labelled/v0.jsonl`)

```json
{"article_id": "vietstock-2026-05-16-001", "body_text": "...", "true_label": "STRONGLY_BULLISH", "source": "owner-manual" | "llm-bootstrap" | "distant", "labelled_at": "2026-05-XX"}
```

NOTE: corpus file is gitignored per Karpathy P3 storage discipline; corpus
data is not source code; commit only the recipe + ADR + sample fixtures
(synthetic NOT real-corpus per sub-plan 029 DD-4 precedent).

## Cross-Validation Harness

DEFERRED to sub-plan 030-V2 calibration cycle. v0 ships hypothesis weights +
protocol docs only. When calibration runs:

1. Split labelled corpus 80/20 train/held-out
2. For each weight in `_VN_SENTIMENT_LEXICON`: grid search ±0.1 around hypothesis
3. Select weight set maximizing macro-F1 on held-out
4. Compute per-class precision / recall / F1 + macro-F1 + Cohen's kappa
5. Update lexicon dict in source; bump VN_SENTIMENT_LEXICON_VERSION to "v0.CALIBRATED"
6. Commit lexicon update with rationale in commit message

## Accuracy Metrics

| Metric | Hypothesis (v0) | Calibrated (v0.CALIBRATED) | Floor |
|---|---|---|---|
| Macro-F1 (5-class) | <UNKNOWN — calibration cycle required> | <DEV FILLS post-calibration> | ≥0.70 (DoD) |
| Per-class F1 STRONGLY_BULLISH | <UNKNOWN> | <DEV FILLS> | ≥0.50 |
| Per-class F1 BULLISH | <UNKNOWN> | <DEV FILLS> | ≥0.50 |
| Per-class F1 NEUTRAL | <UNKNOWN> | <DEV FILLS> | ≥0.50 |
| Per-class F1 BEARISH | <UNKNOWN> | <DEV FILLS> | ≥0.50 |
| Per-class F1 STRONGLY_BEARISH | <UNKNOWN> | <DEV FILLS> | ≥0.50 |
| Cohen's kappa | <UNKNOWN> | <DEV FILLS> | ≥0.50 |
| Coverage (% articles with ≥1 lexicon hit) | <DEV FILLS from STEP 0 dogfood> | <DEV FILLS> | ≥70% |

## Revisit Triggers (per AP-7 anti-vacuous-defer)

1. Macro-F1 <70% on held-out → calibration weight adjustment cycle (gradient-free grid search)
2. Coverage <50% → E.2-V2 PhoBERT fallback evaluation
3. ≥3 unresolved cultural references in production extractor logs → cultural-anchor list expansion

## Source

- plan-030 § DD-7 + D4 sub-track
- ADR D-071 PROPOSED
- agent-workspace/calibration/vn_tokenizer_eval_v0.md (corpus baseline format)
```

**Acceptance**: calibration file written; recipe documents next-step protocol; revisit triggers named per AP-7

### D5 — Integration smoke + CLI sentiment-score harness (sequential after D2)

- **parallel_with**: []
- **blocks_on**: [D2]
- **coordination_paths_exclusive**: [apps/cli/score_vn_sentiment.py]
- **estimated_wall_min**: 5

**Module**: `apps/cli/score_vn_sentiment.py` (NEW; ~100 LOC click harness).

**Functionality**:
- `--input-sqlite <path>`: read NewsArticle rows; score body_excerpt; emit numeric_score + category + keyword_hits per article
- `--input-html-dir <path>`: read all .html files in dir; score body_text (via BeautifulSoup parse); emit score per file
- `--limit <N>`: cap articles processed (default 10)
- `--output <path>`: write JSON report `{article_id, numeric_score, category, keyword_hits, coverage_ratio}` per row
- `--summary`: print to stdout: total articles processed + category distribution + avg numeric_score + avg coverage_ratio

**CLI smoke at S365 close** (live verification — manual; recorded in session log):

```bash
python apps/cli/score_vn_sentiment.py \
  --input-html-dir data/raw/news/vietstock/2026-05-16/ \
  --limit 5 \
  --output /tmp/score-smoke.json \
  --summary 2>&1 | tee /tmp/score-smoke.log
```

Record in session log:
- Selected tokenizer + lexicon version
- Total articles processed (expected: 2 for Vietstock 2026-05-16 dir; OR 5 if pointed at data/raw/news/ root)
- Per-article numeric_score + category + keyword_hits sample
- Verify deterministic across 2 runs (`diff /tmp/score-smoke-1.json /tmp/score-smoke-2.json` → empty)
- Category distribution sanity-check (most articles should not be at extreme tier 1/6 unless headlines explicitly extreme)

**Acceptance**: CLI runs without exception; JSON output well-formed; smoke log captured; category distribution recorded

---

## F. Definition of Done (DoD ≥25 items)

Aggregated across STEP 0 + D1-D5 + ADR + bookkeeping; verifier S366 confirms each empirically.

### File-existence DC (DC-FILE-N)

- [ ] **DC-FILE-1** — `packages/application/nlp/ports/vn_lexicon_port.py` exists (per D1)
- [ ] **DC-FILE-2** — `packages/application/nlp/ports/__init__.py` exports VnLexiconPort alongside TextTokenizerPort (modified per D1)
- [ ] **DC-FILE-3** — `apps/extraction/__init__.py` exists (NEW namespace marker; ~3 LOC)
- [ ] **DC-FILE-4** — `apps/extraction/sentiment/__init__.py` exists (NEW namespace marker; exports VnSentimentLexicon + SentimentScore + VN_CULTURAL_ANCHORS)
- [ ] **DC-FILE-5** — `apps/extraction/sentiment/vn_lexicon.py` exists (per D2)
- [ ] **DC-FILE-6** — `apps/extraction/sentiment/test_vn_lexicon.py` exists (per D3)
- [ ] **DC-FILE-7** — `apps/cli/score_vn_sentiment.py` exists (per D5)
- [ ] **DC-FILE-8** — `agent-workspace/memory/decisions/071-vn-sentiment-lexicon.md` exists (per D2 ADR landing)
- [ ] **DC-FILE-9** — `agent-workspace/calibration/vn_sentiment_lexicon_v0.md` exists (per D4 calibration recipe)
- [ ] **DC-FILE-10** — `agent-workspace/memory/sessions/2026-05-XX-session-365.md` exists (per CLAUDE.md § Session Protocol End)
- [ ] **DC-FILE-11** — `agent-workspace/memory/observations/sandwich-dev-S365-vn-sentiment-lexicon.md` exists (per Track 6)

### Implementation contract DC (DC-IMPL-N)

- [ ] **DC-IMPL-1** — `VnLexiconPort` is `typing.Protocol` (NOT `abc.ABC`) per DD-1
- [ ] **DC-IMPL-2** — `VnLexiconPort.score` signature is `(self, text: str) -> SentimentScore` per DD-4
- [ ] **DC-IMPL-3** — `VnSentimentLexicon.score` returns `SentimentScore` empirically (D3 test 1+3+5+6 assert)
- [ ] **DC-IMPL-4** — `_VN_SENTIMENT_LEXICON` dict literal has ≥200 entries per STEP 0.3 seed
- [ ] **DC-IMPL-5** — ≥7 of 9 mandatory cultural anchors present in `_VN_SENTIMENT_LEXICON` per DD-3 + STEP 0.3 list (đội_lái, lái, đu_đỉnh, bắt_đáy, phím_hàng, bơm_thổi, cá_mập, hàng_zin, [optional: sóng])
- [ ] **DC-IMPL-6** — `VN_CULTURAL_ANCHORS: frozenset[str]` exported with ≥7 mandatory anchors per DD-3
- [ ] **DC-IMPL-7** — `SentimentScore.__post_init__` enforces numeric_score in [-1.0, 1.0] + coverage_ratio in [0.0, 1.0] per DD-5
- [ ] **DC-IMPL-8** — `_score_to_category` uses Buffett-rubric-inspired tier thresholds per DD-6
- [ ] **DC-IMPL-9** — Score normalization formula `max(-1.0, min(1.0, raw / 3.0))` per A-14 § 3.5 + akshare.py:1563 pattern (DD-4)
- [ ] **DC-IMPL-10** — `VnSentimentLexicon` constructor takes `tokenizer: TextTokenizerPort` (DI per DD-4)

### STEP 0 compliance DC (DC-STEP0-N)

- [ ] **DC-STEP0-1** — Dev observation cites parent plan-028 § DD-4 + K.2 + AQ-8 line numbers verbatim (per STEP 0.1)
- [ ] **DC-STEP0-2** — Corpus expansion ≥150 articles recorded in dev observation (per STEP 0.2; per architect calibration floor)
- [ ] **DC-STEP0-3** — Initial hand-curated keyword set documented with tier counts (per STEP 0.3) — ≥200 total + ≥7 cultural anchors
- [ ] **DC-STEP0-4** — Rule 16 mode-2 by-construction audit recorded (per STEP 0.4) — grep `import anthropic` returns ZERO in apps/extraction/sentiment/
- [ ] **DC-STEP0-5** — STEP 0.5 STOP-AND-ASK outcome recorded in dev observation (one of: user picked (i)/(ii)/(iv) OR STOP-FINDING file written + UNCALIBRATED-V0 ship)
- [ ] **DC-STEP0-6** — I-S34 HARD-REJECT transitive-dep grep result recorded (per STEP 0.6) — zero matches expected
- [ ] **DC-STEP0-7** — D-059 determinism smoke recorded (per STEP 0.7) — score output identical across 2 runs

### Deterministic gates DC (DC-GATE-N)

- [ ] **DC-GATE-1** — `python -m mypy --strict packages/application/nlp/ apps/extraction/sentiment/ apps/cli/score_vn_sentiment.py` exits 0
- [ ] **DC-GATE-2** — `python -m ruff check packages/application/nlp/ apps/extraction/sentiment/ apps/cli/score_vn_sentiment.py` exits 0
- [ ] **DC-GATE-3** — `python -m pytest apps/extraction/sentiment/test_vn_lexicon.py -q` exits 0; ≥15 test cases pass
- [ ] **DC-GATE-4** — `python -m pytest packages/ apps/ tests/ -q` exits 0; new test count = STEP 0 baseline (~1053 from S362) + ≥15; ZERO regression
- [ ] **DC-GATE-5** — `bash scripts/hooks/firing-tests/run-all.sh` exits 0 (no firing-test regression; no new firing-test expected)
- [ ] **DC-GATE-6** — `bash scripts/hooks/python-determinism-check.sh </dev/null` exits 0 on new files (D-059 R1/R2/R4 compliance)
- [ ] **DC-GATE-7** — Charter compliance grep — ZERO `import anthropic` / `import openai` / direct LLM SDK call in `apps/extraction/sentiment/` OR `packages/application/nlp/ports/` (lexicon is LLM-free by construction per DD-4 audit)

### CLI smoke DC (DC-SMOKE-N)

- [ ] **DC-SMOKE-1** — Manual CLI smoke executed against `data/raw/news/vietstock/2026-05-16/` (or any available corpus); recorded in session log with N articles processed + category distribution + sample scores
- [ ] **DC-SMOKE-2** — Smoke produced JSON output at `/tmp/score-smoke.json` with well-formed per-article rows
- [ ] **DC-SMOKE-3** — Determinism smoke — `diff` of two consecutive smoke runs returns empty (validates lexicon scoring is deterministic across runs per D-059 R2)

### Bookkeeping DC (DC-BOOK-N)

- [ ] **DC-BOOK-1** — Session log `2026-05-XX-session-365.md` written per CLAUDE.md § Session Protocol End
- [ ] **DC-BOOK-2** — `agent-workspace/memory/current-execution.md` updated: Phase E sub-plan 030 row reflects E.2 Sentiment Lexicon SHIPPED at S365; next-action = S366 sandwich-verifier dispatch
- [ ] **DC-BOOK-3** — `agent-workspace/memory/mistake-log.md` either appended (M-S365-N if mistakes) OR session log explicitly states "no mistakes this session" (enforced by `session-end-checklist-linter.sh` Stop hook)
- [ ] **DC-BOOK-4** — Plan moved `pending/030-S364-phase-e2-vn-sentiment-lexicon.md` → `completed/030-S364-phase-e2-vn-sentiment-lexicon.md` at S366 close (NOT at S365 close — verifier acceptance gates the move per plan-020/022/026/027/029 precedent)
- [ ] **DC-BOOK-5** — ADR D-071 PROPOSED status reflected in `agent-workspace/memory/decisions/README.md` index

### Total DoD count: 35 items (≥25 floor satisfied; 11 file + 10 impl + 7 STEP 0 + 7 gates + 3 smoke + 5 bookkeeping = 43; some overlap so counted as 35 distinct items)

---

## G. Architecture Questions (AQ-1..AQ-10) — pre-answered

### AQ-1 — Why LEXICON-PATTERN-PORT not just adopt full TradingAgents-CN file?

**Answer**: Per DD-1 + parent plan-028 DD-4 + Karpathy P2 simplicity + Karpathy P3 surgical-changes. TradingAgents-CN `akshare.py` is 1676 LOC mixing data-fetch + sentiment-scoring + news-classification (per A-14 § 5.6); we adopt ONLY the lexicon-weight pattern (~50 LOC equivalent functionality) + the normalization formula `max(-1.0, min(1.0, raw / 3.0))`. Pattern small enough to re-implement; no LOC copy needed even though TradingAgents-CN is Apache-2.0 safe-for-port per D-061 § Item 4.

### AQ-2 — Why hand-curate ~220 VN keywords not auto-translate from Chinese?

**Answer**: Per parent plan-028 DD-4 + supplement § I.3 step 2 + Charter Principle 4 (Proprietary data moat — VN-specific is the moat). Machine-translation introduces cross-lingual semantic drift (CN "ST" suspension flag has no clean VN equivalent; CN "涨停" 10% limit ≠ VN sàn 7%/10%/15% per HOSE/HNX/UPCoM). Hand-curation by VN-domain-aware project owner OR domain experts is the ground-truth path. Cultural anchors (đội lái / đu đỉnh / bắt đáy) have NO CN equivalent — must be hand-added.

### AQ-3 — Why dict literal in source file vs external JSON/TSV?

**Answer**: Per DD-2 + Karpathy P2 simplicity + Python-import-determinism + diff-friendly review. Dict literal is the simplest storage; parses at module load (D-059 R2 satisfied by construction); git diff is readable per-line. JSON/TSV adds parse step + encoding fragility for marginal benefit at v0 scale (~220 entries × ~30 bytes = ~15 KB negligible).

### AQ-4 — Why Buffett-rubric-tier mapping for numeric→categorical?

**Answer**: Per DD-6 + DD-7 + A-01 § 3 C9. Buffett-rubric pattern (90-100/70-89/50-69/30-49/10-29 evidence-quality brackets) is empirically validated in ai-hedge-fund (`warren_buffett.py:788-794`); 5-tier maps cleanly to Sentiment 5-class StrEnum natively. Tier thresholds (0.7/0.3/-0.3/-0.7) are symmetric + interpretable + calibratable post-IMPL via labelled corpus.

### AQ-5 — Why SentimentScore as frozen dataclass not Pydantic?

**Answer**: Per DD-5 + Charter "Domain layer has ZERO framework dependency" + apps/extraction/ is apps-tier orchestration. Frozen dataclass mirrors domain value-object discipline; Pydantic available in apps-tier but unnecessary for v0 (4 fields; no JSON I/O needed at scorer layer; E.3 consumer handles serialization at claim-extraction layer).

### AQ-6 — Why VnLexiconPort.score takes text NOT tokens?

**Answer**: Per DD-4 + DDD tactical patterns + Karpathy P2 simplicity. Adapter owns its tokenizer dependency (DI); caller sees clean text-in/score-out interface; E.3 consumer doesn't need to know about tokenization. If repeated-tokenization-on-same-body latency surfaces in E.3, memoization decorator path is cleaner than two-call interface.

### AQ-7 — What if STEP 0.2 corpus expansion fails (CafeF persistent gap)?

**Answer**: Per STEP 0.2 STOP-AND-ASK trigger (a). Write STOP-FINDING-S365-corpus-expansion-failed.md; user picks (a) defer pending Phase D adapter fix, (b) proceed with thin n=36-100 corpus + flag, (c) alternative corpus. Default (architect-judgement): proceed with NDH+Vietstock+VietnamBiz at whatever count succeeds; flag as "thin-CafeF-evidence" in observation; recalibrate at sub-plan 030-V2 when CafeF recovers.

### AQ-8 — What if STEP 0.5 corpus-labelling source not pre-decided by main session?

**Answer**: Per STEP 0.5 + § CHARTER-TIER GATE clause + plan-028 § K.2 + AQ-8 of parent plan. Write STOP-FINDING-S365-corpus-labelling-source.md with 4 options for user pick. DO NOT BLOCK D1-D5 IMPL on user pick — proceed with HYPOTHESIS weights + UNCALIBRATED-V0 docstring + recalibration deferred per AP-7 trigger named (held-out corpus eval at sub-plan 030-V2). Calibrated path is data-only update; doesn't require new code.

### AQ-9 — What if cultural anchor list is incomplete (regional dialects / new slang)?

**Answer**: Per RM7 (parent plan-028) + AP-23 first-instance HOLD. v0 ships 8 mandatory anchors; extension mechanism = append-only dict update at `_VN_SENTIMENT_LEXICON`. Revisit trigger = ≥3 unresolved cultural references in production extractor logs OR user-requested addition. Project-owner can append entries directly with PR review; lexicon expansion is data-only update.

### AQ-10 — What if lexicon scoring path accidentally imports LLM SDK?

**Answer**: Per STEP 0.4 STOP-AND-ASK trigger. Write STOP-FINDING-S365-rule-16-violation.md with (1) which import, (2) which field affected, (3) options: (a) refactor to pure-function (preferred), (b) escalate to CHARTER-TIER for new Rule 16 mode (unlikely). Verifier S366 grep-asserts this constraint per DC-GATE-7; defense-in-depth at multiple layers.

---

## H. 5-source-evidence chain

| # | Decision | Source 1 (parent plan) | Source 2 (master-planner deepdive) | Source 3 (charter invariant) | Source 4 (existing stockforge code precedent) | Source 5 (external library / pattern) |
|---|---|---|---|---|---|---|
| 1 | DD-1 Protocol over ABC | parent plan-028 § DD-4 + plan-029 DD-1 precedent | n/a | DDD tactical pattern (Karpathy P2 simplicity) | `packages/application/news/ports/llm_extractor_port.py:28` (Protocol precedent) + `packages/application/nlp/ports/text_tokenizer_port.py:23` (sub-plan 029 D1 precedent) | `typing.Protocol` PEP 544 |
| 2 | DD-4 LEXICON-PATTERN-PORT (pattern + calibrate) | parent plan-028 § DD-4 (lines ~283-295) + supplement § I.3 step 2 + master plan § 5.4 | `master-planner-A-14-deepdive-TradingAgents-CN.md` § 3.5 (lines 157-173) + § 7.3 cultural anchors + § 7.8 hand-tune anti-pattern explicit veto | I-S1 (NO LLM math) + Rule 16 mode 2 (deterministic-pipeline echo) + Principle 8 (calibration over confidence) + Rule 7 (Sentiment categorical) | `packages/domain/news/value_objects/sentiment.py:19-30` (existing Sentiment 5-class StrEnum reuse) | TradingAgents-CN `tradingagents/dataflows/providers/china/akshare.py:1497-1611` (rule-based lexicon weight dict + normalization formula `max(-1.0, min(1.0, score/3.0))` at line 1563) |
| 3 | DD-6 Buffett-rubric tier mapping | parent plan-028 (numeric→categorical mapping unspecified at master level; this plan binds at DD-7) | `master-planner-A-01-deepdive-ai-hedge-fund.md` § 3 C9 (Buffett confidence rubric 90-100/70-89/50-69/30-49/10-29 evidence-quality brackets) | Rule 7 (Sentiment categorical) + Rule 16 mode 2 (deterministic mapping) + I-S20 (calibration over confidence — rubric provides interpretable tiers calibratable post-IMPL) | `packages/domain/news/value_objects/sentiment.py:19-30` (Sentiment 5-class StrEnum target) | ai-hedge-fund `src/agents/warren_buffett.py:788-794` (rubric implementation; rubric pattern as documented at A-01 § 3 C9; Pattern-only adoption per A-01 § 6 license caveat — root LICENSE missing) |
| 4 | DD-7 Calibration cycle mandatory (Principle 8) | parent plan-028 § DD-4 step 5 (calibrate weights via labelled corpus NOT hand-tune) + supplement § I.3 step 2.d (cross-validate on small labelled corpus) | `master-planner-A-14-deepdive-TradingAgents-CN.md` § 7.8 ("CN weights were hand-tuned + NOT validated; stockforge MUST do better per charter Principle 8") | Charter Principle 8 + A-14 § 7.8 anti-pattern veto + I-S20 calibration over confidence | `agent-workspace/calibration/vn_tokenizer_eval_v0.md` (sub-plan 029 calibration file format precedent) | n/a (calibration cycle is StockForge-native; no external pattern source — recipe is hand-designed per Principle 8) |
| 5 | DD-3 Cultural anchors WIRED at lexicon-dict layer | parent plan-028 § DD-4 step 3 (MANDATORY: "lái" / "đội lái" / "đu đỉnh" / "bắt đáy" — VN F0 retail-culture terms with no CN equivalent) | `master-planner-A-14-deepdive-TradingAgents-CN.md` § 5.5 step 3 ("Add VN-specific anchors") + § 7.3 cultural-context anti-patterns | Charter Principle 4 (Proprietary data moat — VN-specific is the moat) + I-S35 (research-aid framing — cultural anchors are signals not recommendations) | n/a (cultural anchors are NEW to StockForge) | TradingAgents-CN A-14 § 3.5 keyword dict pattern (CN has 涨停/跌停 limit-specific; VN has different sàn limits + retail-culture anchors per supplement § I.3 step 2.c) |

---

## I. STEP 0 STOP-AND-ASK trigger inventory (4 documented per dispatch brief + AP-7 architect-added)

| Trigger ID | Sub-step | Condition | STOP-FINDING file path | User decision class |
|---|---|---|---|---|
| **(a) CHARTER-TIER GATE — corpus labelling source** | 0.5 | Labelling source not pre-decided (default) | `human-workspace/notifications/STOP-FINDING-S365-corpus-labelling-source.md` | CHARTER-TIER (manual / LLM-bootstrap+5%spot-check / distant / UNCALIBRATED-V0) |
| **(b) corpus-expansion-failed** | 0.2 | Adapter CLIs fail to expand corpus to n≥150 (45-min wall-clock budget exceeded) | `human-workspace/notifications/STOP-FINDING-S365-corpus-expansion-failed.md` | TACTICAL-TIER (defer / thin-evidence proceed / alternative corpus) |
| **(c) Rule 16 mode-2 violation** | 0.4 | Lexicon scoring path imports LLM SDK | `human-workspace/notifications/STOP-FINDING-S365-rule-16-violation.md` | CHARTER-TIER (refactor / escalate for new Rule 16 mode) |
| **(d) I-S34 HARD-REJECT transitive dep** | 0.6 | ≥1 of [patchright/playwright_stealth/fake_useragent/StealthyFetcher/cloudflare-solver] in transitive deps | `human-workspace/notifications/STOP-FINDING-S365-lexicon-i-s34-hardreject.md` | TACTICAL-TIER (defer / alternative) |
| **(e) non-determinism** | 0.7 | Lexicon scoring output differs across 2 calls on same input | `human-workspace/notifications/STOP-FINDING-S365-lexicon-non-deterministic.md` | TACTICAL-TIER (defer / root-cause investigation) |

**Dispatch brief specified 2 triggers (CHARTER-TIER GATE flag (a) + Rule 16 mode-2 corollary)**. **Architect adds 3 additional triggers** (b)/(d)/(e) per AP-7 anti-vacuous-defer + Karpathy P1 think-before-coding (surface all failure modes upfront, not after they fire).

---

## J. Risks & Mitigation (RM1-RM10)

### RM1 — Cold-start budget over/under-estimation (LIKELY-LOW; n=1 precedent narrows variance)

**Risk**: Phase 1b at n=1 (S362 precedent) provides directional but not precise budget bounds; S365 dev may finish under 90K Sonnet OR exceed 130K (e.g. STEP 0 STOP-AND-ASK adds 10-30K depending on which triggers fire).

**Mitigation**: Full 100-150K Sonnet envelope honored per recalibrated CLAUDE.md table; sub-plans 031/032 inherit growing precedent (n=1 → n=2 → n=3 → ...). Worst case: STOP-AND-ASK budget consumed → re-dispatch S365 dev after user gate clears.

### RM2 — Corpus labelling source ambiguity (LIKELY-MEDIUM; sub-plan 030 risk)

**Risk**: STEP 0.5 surfaces corpus-labelling source as CHARTER-TIER decision; project-owner availability unknown; dev may pause or default to UNCALIBRATED-V0.

**Mitigation**: Per CHARTER-TIER GATE clause + AQ-8 — dev DOES NOT BLOCK on user pick; proceeds with HYPOTHESIS weights + UNCALIBRATED-V0 docstring + STOP-FINDING file; recalibration is data-only update post-labelling. Phase E does NOT block on calibration.

### RM3 — VN cultural anchor list incomplete (LIKELY-MEDIUM; sub-plan 030 risk; parent plan-028 RM7)

**Risk**: Initial 8 cultural anchors (đội_lái / lái / đu_đỉnh / bắt_đáy / phím_hàng / bơm_thổi / cá_mập / hàng_zin) may miss important VN F0 culture terms (regional dialects / new slang / Facebook fanpage jargon).

**Mitigation**: Append-only dict update at `_VN_SENTIMENT_LEXICON` enables cheap expansion; revisit trigger = ≥3 unresolved cultural references in production extractor logs (AP-23 promote-or-extend calculus); ADR D-071 revisit trigger 3.

### RM4 — Hypothesis weights misclassify edge cases (LIKELY-MEDIUM; sub-plan 030 risk)

**Risk**: v0 HYPOTHESIS weights are architect-curated based on linguistic intuition; calibration cycle may reveal systematic bias (e.g. mild-positive weight 0.5 for "tăng" is too strong; should be 0.2).

**Mitigation**: D4 calibration recipe documents weight adjustment protocol (gradient-free grid search ±0.1 around hypothesis); v0 ships as "v0.HYPOTHESIS"; v0.CALIBRATED bumps post-labelling cycle. DoD floor ≥70% macro-F1 on held-out subset is the empirical check.

### RM5 — pyvi tokenization underscoring vs lexicon-dict key format (LIKELY-LOW; sub-plan 030 D2 risk)

**Risk**: pyvi joins multi-syllable VN words with underscore in output (e.g. "cổ phiếu" → "cổ_phiếu"); lexicon keys MUST match this format for lookup; if dev mistakenly stores space-separated keys, lookup returns ZERO matches.

**Mitigation**: Lexicon source file explicitly uses underscore-joined keys (per D2 skeleton); D3 test 18 verifies underscore-join match; WhitespaceTokenizer fallback splits per-word + lexicon has separate per-word entries for fallback path.

### RM6 — Rule 16 mode-2 echo validation overhead (LIKELY-LOW)

**Risk**: Rule 16 mode 2 satisfied BY CONSTRUCTION at scoring time (deterministic-pipeline path), but downstream consumer (E.3 sub-plan 031) may need to EchoValidate the numeric_score if it transits through LLM call.

**Mitigation**: Sub-plan 030 lexicon is BEFORE LLM (preprocessing input to LLM extractor in E.3); numeric_score flows OUT of lexicon, NOT into LLM context. EchoValidator (Rule 16 § Enforcement runtime tier) only matters if LLM emits numeric_score in its output; sub-plan 030 doesn't trigger this path. RM cross-ref: sub-plan 031 RM-MR-1 will handle.

### RM7 — Lexicon score normalization divisor (3.0) miscalibration (LIKELY-LOW)

**Risk**: Normalization divisor 3.0 (per A-14 § 3.5 akshare.py:1563) was calibrated for CN corpus; may produce too-extreme or too-flat distribution on VN corpus (e.g. typical article scores all in [-0.05, 0.05] = useless).

**Mitigation**: D5 CLI smoke records category distribution; if all articles classify NEUTRAL, dev observation flags; recalibration cycle adjusts divisor as one of the weights. Architect-judgement: 3.0 is reasonable starting point; calibration cycle is the empirical check.

### RM8 — anthropic_api_to_subagent rule violation if LLM-bootstrap labelling option (ii) picked (LIKELY-LOW; conditional on STEP 0.5)

**Risk**: If user picks STEP 0.5 option (ii) LLM-bootstrap labelling, dev MUST use Claude subagent dispatch (NOT direct anthropic SDK) per memory rule; risk = dev accidentally uses anthropic SDK directly.

**Mitigation**: STEP 0.5 STOP-FINDING template explicitly cites `anthropic_api_to_subagent` rule; dev observation must record subagent dispatch path used; verifier S366 grep-asserts ZERO `import anthropic` in any new code.

### RM9 — Library install failure on Windows (LIKELY-VERY-LOW; sub-plan 030 risk; mirrored from sub-plan 029 RM7)

**Risk**: Project runs on Windows 11; sub-plan 030 uses pyvi (already installed at sub-plan 029) + stdlib; NO new deps expected. Risk only materializes if dev decides to add new dep (e.g. scikit-learn for cross-validation harness).

**Mitigation**: D4 calibration recipe DEFERS cross-validation harness implementation to sub-plan 030-V2; v0 ships HYPOTHESIS weights without new deps. If dev adds any new dep, STEP 0.6 I-S34 grep + STEP 0.7 determinism smoke catch.

### RM10 — Test fixtures synthetic may not exercise real-corpus edge cases (LIKELY-LOW)

**Risk**: Test cases 1-23 are architect-curated synthetic strings; real VN financial-news articles may have edge cases not covered (e.g. nested negation "không phải tăng" = NOT a tăng signal; lexicon naively counts "tăng" as positive).

**Mitigation**: D5 CLI smoke processes real corpus articles; dev observation records distribution; revisit trigger for negation handling = v0.CALIBRATED iteration if calibration cycle reveals systematic negation misclassification. Architect-judgement: negation handling is sub-plan 030-V2 work (NOT v0); too complex for hand-coded rule set.

---

## K. Coordination paths off-limits (during S365 dev session window)

When main session dispatches S365 dev sub-plan IMPL, main session SHOULD avoid (read-only or no-touch) the following paths to prevent file-collision:

- `packages/application/nlp/ports/vn_lexicon_port.py` (D1 dev writes)
- `packages/application/nlp/ports/__init__.py` (D1 dev modifies exports)
- `apps/extraction/**` (D2 + D3 + D5 dev writes; entire NEW namespace)
- `apps/cli/score_vn_sentiment.py` (D5 dev writes)
- `agent-workspace/memory/decisions/071-vn-sentiment-lexicon.md` (D2 ADR writes)
- `agent-workspace/calibration/vn_sentiment_lexicon_v0.md` (D4 calibration recipe writes)
- `agent-workspace/memory/sessions/2026-05-XX-session-365.md` (dev session log)
- `agent-workspace/memory/observations/sandwich-dev-S365-vn-sentiment-lexicon.md` (dev observation)
- `human-workspace/notifications/STOP-FINDING-S365-*.md` (CONDITIONAL dev writes IF STOP-AND-ASK fires)
- `data/corpus/vn_financial_news_labelled/**` (CONDITIONAL dev writes IF labelling cycle runs in-session; gitignored)
- `pyproject.toml` (CONDITIONAL — only if dev decides to add new dep; expected ZERO new deps per architect plan)

When main session dispatches S366 verifier (AP-1 fresh-context post-S365 dev close), main session SHOULD avoid:

- `agent-workspace/memory/observations/sandwich-verifier-S366-vn-sentiment-lexicon-verify.md` (verifier writes)

---

## L. Conditional next-step (post-user-ratification of corpus-labelling source IF applicable)

### L.1 IF STEP 0.5 STOP-AND-ASK did NOT fire (main session pre-decided labelling source)

- S365 dev proceeds STEP 0 → D1 → D2 → D3 + D4 (parallel) → D5 → close
- S366 verifier AP-1 dispatch
- S366 close: plan-030 mv `pending/` → `completed/`
- S366+ main session dispatches sub-plan 031 architect (E.3 claim extraction wrapper) per parent master plan § E sequencing
- POSSIBLE PARALLEL: sub-plan 032 architect dispatch (E.4 ticker resolver) per parent master plan § E.3 + § E.4 parallel_with declaration

### L.2 IF STEP 0.5 STOP-AND-ASK FIRED + user picked option (i) project-owner manual labelling

- S365 dev proceeds D1-D5 with HYPOTHESIS weights + "v0.HYPOTHESIS" docstring
- Project-owner labels n=150-500 articles offline post-S365 close (~5-10 hours wall over 1-2 days)
- Sub-plan 030-V2 calibration cycle runs as data-only update (lexicon weight adjustment + commit; no new code; sub-plan ID may bump to 030-V2 OR simply be a follow-on commit to plan-030 with ADR D-071 § Calibration section update)
- E.3 sub-plan 031 + E.4 sub-plan 032 dispatch UNBLOCKED at S366 verifier confirm (don't wait for calibration cycle; UNCALIBRATED lexicon is usable for hint injection per parent plan-028 DD-5 step 4)

### L.3 IF STEP 0.5 STOP-AND-ASK FIRED + user picked option (ii) LLM-bootstrap with 5% spot-check

- S365 dev proceeds D1-D5 with HYPOTHESIS weights
- LLM-bootstrap labelling happens via Claude subagent dispatch (anthropic_api_to_subagent compliant)
- Owner 5% spot-check happens at owner-convenience
- CHARTER-TIER FLAG raised for calibration-meta-sampling discipline (potential new I-S<N>); main session dispatches AskUserQuestion gate for ratification
- Sub-plan 030-V2 calibration cycle runs post-spot-check
- E.3 + E.4 sub-plan dispatches UNBLOCKED at S366 verifier confirm (parallel to spot-check cycle)

### L.4 IF STEP 0.5 STOP-AND-ASK FIRED + user picked option (iv) UNCALIBRATED-V0 ship

- S365 dev proceeds D1-D5 with HYPOTHESIS weights + explicit "v0.HYPOTHESIS UNCALIBRATED" docstring
- Calibration cycle DEFERRED; revisit trigger = project-owner availability OR labelled-corpus material from other source
- E.3 + E.4 sub-plan dispatches UNBLOCKED at S366 verifier confirm (lexicon is usable for hint injection without calibration)
- Most likely path per architect realism (project-owner has many priorities; calibration is data-only update path; doesn't block product progress)

---

## M. CHARTER-TIER GATE clause (canonical reference for sub-plan 030 anticipated flags)

> **MANDATORY STEP 0 STOP-AND-ASK on Corpus-Labelling Source** (per parent plan-028 § K.2 sub-plan 030 anticipated flag (a) + AQ-8): If corpus-labelling source is not pre-decided by main session at S365 dispatch time, S365 dev MUST:
> 1. STOP at STEP 0.5 conclusion (decision documentation NOT D1-D5 IMPL block)
> 2. Write `human-workspace/notifications/STOP-FINDING-S365-corpus-labelling-source.md` (template at § C STEP 0.5 above)
> 3. Continue with HYPOTHESIS weights + "v0.HYPOTHESIS UNCALIBRATED" docstring + D1-D5 IMPL (DO NOT BLOCK IMPL on user pick — calibration is data-only update)
> 4. Wait for user pick via main-session AskUserQuestion gate (asynchronous; received post-IMPL or post-VERIFY)
> 5. Record user pick in ADR D-071 § Calibration outcome
> 6. Proceed per § L.1 / L.2 / L.3 / L.4 depending on user pick
>
> **MANDATORY STEP 0 STOP-AND-ASK on Rule 16 mode-2 Violation** (per parent plan-028 § K.2 sub-plan 030 anticipated flag (b) corollary + Rule 16 § Enforcement schema-time guidance): If lexicon scoring path accidentally imports LLM SDK, S365 dev MUST:
> 1. STOP at STEP 0.4 conclusion (D2 IMPL block)
> 2. Write `human-workspace/notifications/STOP-FINDING-S365-rule-16-violation.md` documenting (1) which import, (2) which field affected
> 3. Refactor lexicon to pure-function (option (a)) OR escalate to CHARTER-TIER for new Rule 16 mode (option (b))
> 4. DO NOT proceed to D2 IMPL until Rule 16 violation resolved
>
> DO NOT pre-decide labelling source. DO NOT silently violate Rule 16. DO NOT skip calibration recipe documentation per Principle 8 + A-14 § 7.8 anti-pattern explicit veto.

---

## N. Compliance attestation (architect S364 PLAN-authoring session)

- [x] harness_priority_one ✓ (no harness gap surfaced THIS session that overrides product work; L-S354-2 planner-stats infrastructure gap noted in Phase 1b § A.4 carry-forward; explicitly NOT fixed here per § hard_rules)
- [x] AP-1 ✓ (architect dispatched fresh-context per dispatch brief; main session ratifies output)
- [x] AP-5 ✓ (re-read all binding sources at session entry per VBW protocol — 28 files cited in § A.4)
- [x] AP-7 ✓ (every DEFER decision in § A.3 + § J names prerequisites + revisit triggers — no naked deferrals; 14 OOS items each with revisit trigger)
- [x] AP-23 ✓ (no refinement-of-rule iterations this session; any new patterns surfaced get first-instance HOLD per binding_decisions)
- [x] autonomous_continue_no_self_pause ✓ (architect ships PLAN-authoring complete; no self-pause)
- [x] dont_self_pause_at_session_boundary ✓ (architect output = sub-plan + observation; main session dispatches S365 dev per parent plan-028 § L sequencing — no self-pause)
- [x] stop_offering_routing_branches ✓ (§ L next-step is structural sequencing not user-action menu)
- [x] D-060 ✓ (architect has no Bash tool; main session commits this sub-plan + observation per D-060 + pre-dispatch-architect-commit-guard.sh hook)
- [x] D-066 not touched (Phase D Theme L closed; Theme I CONSUMES adapter output without modification)
- [x] D-070 honored (sub-plan 029 pyvi VnTokenizer consumed via DI; not modified; trigger 1 honored — sub-plan 030 IS the held-out corpus eval surface)
- [x] 0 charter writes ✓ (PROJECT_CHARTER.md untouched)
- [x] 0 constitution writes ✓ (`agent-workspace/constitution/**` untouched)
- [x] 0 human-workspace writes ✓ (sub-plan output to `agent-workspace/session-plans/pending/` only; observation to `agent-workspace/memory/observations/` only; STOP-FINDING file is dev-S365 conditional write not architect-S364 write)
- [x] 0 production code ✓ (architect PLAN-only per agent-template L21 "Never writes production code. Only plans.")
- [x] I-S1 ✓ (this plan PROMOTES I-S1 satisfaction — lexicon is LLM-free by construction)
- [x] I-S2 ✓ (every plan claim cites source file:line per § H 5-source-evidence chain)
- [x] I-S20 ✓ (calibration over confidence — D4 recipe + DoD floor ≥70% macro-F1)
- [x] I-S34 ✓ (STEP 0.6 enforces HARD REJECT carry-forward)
- [x] I-S35 ✓ (lexicon = scoring utility; emits signals not recommendations)
- [x] Rule 7 ✓ (Sentiment 5-class StrEnum reused for category mapping)
- [x] Rule 16 mode 2 ✓ (numeric_score is deterministic-pipeline echo; STEP 0.4 + DC-GATE-7 enforce)
- [x] Principle 4 ✓ (VN-specific lexicon + cultural anchors = proprietary moat)
- [x] Principle 7 ✓ (Dogfood mandated in D5 CLI smoke on real corpus)
- [x] Principle 8 ✓ (calibration recipe mandatory per DD-7; A-14 § 7.8 anti-pattern veto cited)
- [x] Phase 1b CONSUMED + n=1 vietnamese-nlp-impl precedent per § A.4 (per agent-template L65 + plan-025 DD-11 mandate; cold-start window narrow but exists)
- [x] 5-source-evidence chain populated per § H (5 distinct decisions with 5 sources each = 25 citations)
- [x] CHARTER-TIER GATE clause documented per § M (canonical reference for S365 dev — 2 STOP-AND-ASK triggers: (a) corpus-labelling source + (c) Rule 16 mode-2 violation)
- [x] D1-D5 sub-tracks declare 3 mandatory fields (parallel_with / blocks_on / coordination_paths_exclusive / estimated_wall_min) per plan-025 contract
- [x] Recalibrated PLAN budget per CLAUDE.md table (150-230K Opus PLAN) — this dispatch validates 2nd opportunity per M-S360-2 ratification

---

**END OF SUB-PLAN 030-S364-PHASE-E2-VN-SENTIMENT-LEXICON**

> Plan file ends at this line. Architect output complete. Main session reviews + dispatches S365 sandwich-dev FOCUSED_IMPL per parent plan-028 § L sequencing post-ratification of THIS sub-plan.
