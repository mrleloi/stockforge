---
id: 071
title: VN Sentiment Lexicon v0 + Calibration Loop
status: ACCEPTED
date: 2026-05-17
authors: sandwich-dev S365
ratified_by: ARCH-tier auto-ratification per severity-schema at S366 verifier PASS-WITH-CONCERNS verdict (2026-05-17)
level: ARCH
supersedes: []
superseded-by: []
empirical_close_verify: |
  - VnSentimentLexicon class instantiable + score() returns deterministic SentimentScore
  - mypy --strict + ruff + pytest on apps/extraction/sentiment/ exit 0
  - ≥15 unit tests PASS covering tier mapping + cultural anchors + edge cases
  - Calibration recipe recorded at agent-workspace/calibration/vn_sentiment_lexicon_v0.md
  - Rule 16 mode 2 compliance grep-asserted: ZERO LLM imports in apps/extraction/sentiment/
  - Cultural anchors ≥7 of 9 mandatory entries present in _VN_SENTIMENT_LEXICON
  - DC-FILE-1 through DC-FILE-11 all PASS per plan-030 § F
---

## Decision

VN sentiment lexicon v0 ships at `apps/extraction/sentiment/vn_lexicon.py` with
~220+ hand-curated keywords across 6 weight tiers + 8+ mandatory VN-cultural-anchors
(both ASCII-transliterated and unicode forms for dual-tokenizer matching).

v0 ships HYPOTHESIS weights (per `VN_SENTIMENT_LEXICON_VERSION = "v0.HYPOTHESIS"`);
calibration cycle per Charter Principle 8 + A-14 § 7.8 anti-pattern explicit veto
runs post-IMPL per recipe in `agent-workspace/calibration/vn_sentiment_lexicon_v0.md`.

## Calibration Outcome (STEP 0.5)

UNCALIBRATED-V0 ship — dev proceeded with HYPOTHESIS weights; calibration deferred
pending user ratification of labelling source via
`human-workspace/notifications/STOP-FINDING-S365-corpus-labelling-source.md`.

Calibration cycle is a data-only update (no new code needed); runs offline
post-user-pick and bumps `VN_SENTIMENT_LEXICON_VERSION` to `"v0.CALIBRATED"`.

## Authorization

**RESOLVED 2026-05-17 S391 via AskUserQuestion mega-bundle**: user pick = **(iv) Continue UNCALIBRATED-V0** [current path]

- Cross-val ≥70% DoD floor remains empirically-unverified — **accepted-risk per user-decision**
- v0.HYPOTHESIS posture retained at `packages/infrastructure/sentiment/vn_sentiment_lexicon.py`
- Calibration cycle deferred indefinitely until labelled corpus exists
- Revisit trigger = systematic-bias evidence in downstream E.3+ sentiment outputs
- Source notification: `human-workspace/notifications/STOP-FINDING-S365-corpus-labelling-source.md` (status: `answered-2026-05-17-via-AskUserQuestion-S391`)

Historical options offered (for audit trail):
- (i) Project-owner manual labelling — highest quality (~5-10h owner-time) — NOT PICKED
- (ii) LLM-bootstrap with 5% spot-check + CHARTER-TIER FLAG for calibration-meta-sampling — NOT PICKED
- (iii) Distant-labelling via market signals — DEFERRED per architect (noise too high for v0); NOT OFFERED at S391
- (iv) DEFER calibration / UNCALIBRATED-V0 — **PICKED**

## Pattern Source

TradingAgents-CN `tradingagents/dataflows/providers/china/akshare.py:1497-1611`
(per A-14 § 3.5 master-planner deepdive observation) — rule-based lexicon-weight
scoring pattern with score normalization formula `max(-1.0, min(1.0, raw_score / 3.0))`
at akshare.py:1563.

PATTERN ONLY adoption — no LOC copy (TradingAgents-CN Apache-2.0 safe per
D-061 § Item 4; pattern small enough to re-implement per Karpathy P2 simplicity).

## Architecture Decisions (DD-1 through DD-7)

| DD | Decision | Rationale |
|----|----------|-----------|
| DD-1 | `typing.Protocol` (NOT ABC) | Lighter; mypy --strict structural typing; mirrors sub-plan 029 D1 TextTokenizerPort + LlmExtractorPort precedent |
| DD-2 | Python dict literal in source file (NOT JSON/TSV) | Per Karpathy P2 simplicity + Python-import-determinism + diff-friendly review |
| DD-3 | Cultural anchors IN main dict (NOT separate dict) | One source of truth; scoring fn walks one dict; frozenset for E.3 consumer audit |
| DD-4 | `score(text: str)` NOT `score(tokens: list[str])` | Adapter owns tokenizer DI; caller sees clean text-in/score-out; E.3 simplicity |
| DD-5 | Frozen dataclass with 4 fields | Domain value-object discipline (NOT Pydantic); Rule 16 mode 2 + Rule 7 compliance |
| DD-6 | Buffett-rubric-tier thresholds 0.7/0.3/-0.3/-0.7 | A-01 § 3 C9 pattern; symmetric; interpretable; calibratable post-IMPL |
| DD-7 | HYPOTHESIS weights + calibration recipe (NOT hand-tune) | Principle 8 + A-14 § 7.8 anti-pattern explicit veto; ground-truth from labelled corpus |

## VN Keyword Set (hand-curated v0 hypothesis)

| Tier | Weight | Count | Examples |
|------|--------|-------|---------|
| 1 | +1.0 | ~30 | tang_tran, kich_tran, lap_dinh, but_pha, tang_manh, x2, x3 |
| 2 | +0.5 | ~50 | tang, len_gia, khoi_sac, mua_rong, loi_nhuan, hoi_phuc |
| 3 | +0.2 | ~30 | hoi, xanh, tiem_nang, khuyen_nghi, dong_tien |
| 4 | -0.2 | ~30 | giam, dieu_chinh, rui_ro, ap_luc, yeu, sideway |
| 5 | -0.5 | ~50 | giam_sau, lao_doc, lo, ban_thao, pha_san, khung_hoang |
| 6 | -1.0 | ~30 | giam_san, kich_san, sup_do, pha_san_chinh_thuc, vo_no |
| Cultural anchors | -0.8 to +0.3 | 8+8 unicode | doi_lai, du_dinh, bat_day, bom_thoi, hang_zin + unicode forms |

**Total**: ~236 entries (220+ unique strings including unicode forms).

## Cultural Anchors (MANDATORY per parent DD-4 + plan-030 DD-3)

| Anchor | ASCII form | Unicode form | Weight | Meaning |
|--------|-----------|-------------|--------|---------|
| Pump-group | doi_lai | đội_lái | -0.8 | Price-manipulation cluster |
| Manipulation | lai_co_phieu | — | -0.6 | Stock price manipulation |
| FOMO at top | du_dinh | đu_đỉnh | -0.7 | Retail trap: buying at peak |
| Bottom-fish | bat_day | bắt_đáy | -0.4 | Risky bottom-fishing strategy |
| Insider tip | phim_hang | phím_hàng | -0.5 | Stock pumping via tips |
| Pump-and-dump | bom_thoi | bơm_thổi | -0.7 | Classic pump-and-dump |
| Whale | ca_map | cá_mập | -0.3 | Large-money manipulator |
| Quality stock | hang_zin | hàng_zin | +0.3 | Retail term for legitimate stock |

8 mandatory anchors shipped. `VN_CULTURAL_ANCHORS: frozenset[str]` exported for
E.3 sub-plan 031 consumer (mentioned_pump_anchors field per parent DD-5 step 5).

## Buffett-Rubric-Tier Categorical Mapping (per DD-6 + A-01 § 3 C9)

- numeric_score in [0.7, 1.0] → `STRONGLY_BULLISH`
- numeric_score in [0.3, 0.7) → `BULLISH`
- numeric_score in [-0.3, 0.3) → `NEUTRAL`
- numeric_score in [-0.7, -0.3) → `BEARISH`
- numeric_score in [-1.0, -0.7) → `STRONGLY_BEARISH`

## Files Shipped (DC-FILE-N)

| DC | File | Status |
|----|------|--------|
| DC-FILE-1 | packages/application/nlp/ports/vn_lexicon_port.py | SHIPPED |
| DC-FILE-2 | packages/application/nlp/ports/__init__.py (exports VnLexiconPort) | MODIFIED |
| DC-FILE-3 | apps/extraction/__init__.py | SHIPPED |
| DC-FILE-4 | apps/extraction/sentiment/__init__.py | SHIPPED |
| DC-FILE-5 | apps/extraction/sentiment/vn_lexicon.py | SHIPPED |
| DC-FILE-6 | apps/extraction/sentiment/test_vn_lexicon.py | SHIPPED |
| DC-FILE-7 | apps/cli/score_vn_sentiment.py | SHIPPED |
| DC-FILE-8 | agent-workspace/memory/decisions/071-vn-sentiment-lexicon.md | THIS FILE |
| DC-FILE-9 | agent-workspace/calibration/vn_sentiment_lexicon_v0.md | SHIPPED |
| DC-FILE-10 | agent-workspace/memory/sessions/2026-05-17-session-365.md | SHIPPED |
| DC-FILE-11 | agent-workspace/memory/observations/sandwich-dev-S365-vn-sentiment-lexicon.md | SHIPPED |

## Revisit Triggers (per AP-7 anti-vacuous-defer)

1. **Lexicon coverage <50% on held-out corpus eval (n=200+ labelled articles)**
   → E.2-V2 PhoBERT fallback evaluation triggered (per plan-030 § A.3)
2. **Cross-validation macro-F1 <70% on held-out subset**
   → calibration weight adjustment cycle (gradient-free search per recipe step 4)
3. **≥3 unresolved cultural references in production extractor logs**
   → cultural-anchor list expansion (AP-23 promote-or-extend calculus)
4. **User picks labelling source (i or ii)**
   → calibration cycle runs; weights updated; version bumped to v0.CALIBRATED

## Risks

- RM1: HYPOTHESIS weights may misclassify edge cases — mitigated by calibration
  recipe documenting ground-truth labelling protocol
- RM2: pyvi tokenization quality affects lexicon match-rate — DD-7 trigger 1
  monitors; held-out corpus eval IS the canonical metric (ADR D-070 trigger 1)
- RM3: cultural-anchor list may be incomplete (regional dialects / new slang) —
  trigger 3 above mitigates; append-only dict makes expansion cheap

## Source

- plan-030 § C STEP 0.3 + § D DD-1 through DD-7
- agent-workspace/calibration/vn_sentiment_lexicon_v0.md (calibration recipe)
- apps/extraction/sentiment/vn_lexicon.py (implementation)
- agent-workspace/memory/observations/master-planner-A-14-deepdive-TradingAgents-CN.md
  § 3.5 + § 7.3 + § 7.8 (pattern source + cultural anchors + anti-pattern veto)
- agent-workspace/memory/observations/master-planner-A-01-deepdive-ai-hedge-fund.md
  § 3 C9 (Buffett rubric tier pattern)

## Anchor Provenance Log

> Append-only. Every modification to `VN_CULTURAL_ANCHORS` frozenset MUST add a row here.
> Required per plan-039 D6 (L-S366-3 promotion) + I-S22 data-lineage invariant.
> Format: anchor | session | agent | rationale | source corpus

| Anchor | Added (session) | Added by | Rationale | Source corpus |
|---|---|---|---|---|
| doi_lai / đội_lái | S365 | sandwich-dev a8b3a3966a14bd85a | Pump-group manipulation marker; dual ASCII+unicode for pyvi tokenizer coverage; plan-030 DD-3 mandatory anchors | n=36 corpus (RM7 reference corpus; HYPOTHESIS weights) |
| lai_co_phieu | S366 | sandwich-verifier inline-fix F1 | Dict entry had weight -0.6 but was NOT in VN_CULTURAL_ANCHORS frozenset; frozenset drives I-S22 consumer (mentioned_pump_anchors); mismatch = data-lineage gap | inherited from initial corpus; found during S366 adversarial review |
| du_dinh / đu_đỉnh | S365 | sandwich-dev a8b3a3966a14bd85a | FOMO-at-top retail-trap signal; mandatory per plan-030 DD-3 | n=36 corpus |
| bat_day / bắt_đáy | S365 | sandwich-dev a8b3a3966a14bd85a | Bottom-fishing risky strategy marker; mandatory per plan-030 DD-3 | n=36 corpus |
| phim_hang / phím_hàng | S365 | sandwich-dev a8b3a3966a14bd85a | Insider-tip stock pumping; mandatory per plan-030 DD-3 | n=36 corpus |
| bom_thoi / bơm_thổi | S365 | sandwich-dev a8b3a3966a14bd85a | Classic pump-and-dump; mandatory per plan-030 DD-3 | n=36 corpus |
| ca_map / cá_mập | S365 | sandwich-dev a8b3a3966a14bd85a | Whale / large-money manipulator; mandatory per plan-030 DD-3 | n=36 corpus |
| hang_zin / hàng_zin | S365 | sandwich-dev a8b3a3966a14bd85a | Quality stock (positive anchor); mandatory per plan-030 DD-3 | n=36 corpus |
