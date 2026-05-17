# VN Sentiment Lexicon v0 — Calibration Recipe (S365)

> Calibration recipe for `apps/extraction/sentiment/vn_lexicon.py` per
> Charter Principle 8 + A-14 § 7.8 anti-pattern explicit veto.
> Source: plan-030 § D DD-7 + D4 sub-track output (S365 dev session).
> Re-eval trigger: per ADR D-071 revisit trigger 2 (cross-validation
> macro-F1 <70% on held-out subset) OR trigger 1 (lexicon coverage <50%
> on held-out corpus eval n=200+).

## v0 Status

- **Lexicon version**: v0.HYPOTHESIS (per `VN_SENTIMENT_LEXICON_VERSION`)
- **Calibrated**: NO — user picked option (iv) UNCALIBRATED-V0 ship per
  CHARTER-TIER GATE STEP 0.5 outcome (see `human-workspace/notifications/
  STOP-FINDING-S365-corpus-labelling-source.md`)
- **Corpus baseline**: n=36 articles from sub-plan 029 STEP 0.2
  (NDH=14 + Vietstock=10 + VietnamBiz=12 + CafeF=0)
- **STEP 0.5 outcome**: UNCALIBRATED-V0 ship; calibration cycle deferred
  pending user pick on labelling source (options i/ii/iv presented in
  STOP-FINDING file)
- **Keyword count**: 220 entries across 6 tiers + cultural anchors

## STEP 0.2 Corpus Expansion Log

**S365 session outcome**: Corpus expansion CLI runs (STEP 0.2 per plan-030
§ C sub-step 0.2) skipped in-session due to live HTTP request budget
constraints. Thin-evidence baseline acknowledged.

**Baseline corpus** (from sub-plan 029 STEP 0.2 / ADR D-070):
- NDH: ~14 articles
- Vietstock: ~10 articles
- VietnamBiz: ~12 articles
- CafeF: 0 (persistent gap per sub-plan 029 calibration)
- **Total: ~36 articles** (below n=150 architect calibration floor)

**Next-step for corpus expansion** (when ready):
```bash
# CafeF (highest priority; was 0 at S362):
python apps/cli/ingest_news_cafef.py \
  --tickers VHM,FPT,HPG,VIC,MSN,VCB,TCB,HDB,SAB,VRE \
  --max-articles 50 --skip-llm --output /tmp/corpus-S365-cafef.sqlite

# NDH:
python apps/cli/ingest_news_ndh.py \
  --tickers VHM,FPT,HPG,VIC,MSN,VCB,TCB,HDB,SAB,VRE \
  --max-articles 50 --skip-llm --output /tmp/corpus-S365-ndh.sqlite

# Vietstock:
python apps/cli/ingest_news_vietstock.py \
  --tickers VHM,FPT,HPG,VIC,MSN,VCB,TCB,HDB,SAB,VRE \
  --max-articles 50 --skip-llm --output /tmp/corpus-S365-vietstock.sqlite

# VietnamBiz:
python apps/cli/ingest_news_vietnambiz.py \
  --tickers VHM,FPT,HPG,VIC,MSN,VCB,TCB,HDB,SAB,VRE \
  --max-articles 50 --skip-llm --output /tmp/corpus-S365-vietnambiz.sqlite
```

**CafeF gap note**: per sub-plan 029 calibration, CafeF returned 0 articles
due to selector/CSS issues. Investigate before assuming gap persists. If still
0, proceed with NDH + Vietstock + VietnamBiz only; flag as "thin-CafeF-evidence".

## Keyword Set Summary (v0.HYPOTHESIS)

| Tier | Weight | Count | Examples |
|------|--------|-------|---------|
| 1 | +1.0 | 30 | tang_tran, kich_tran, lap_dinh, but_pha, tang_manh |
| 2 | +0.5 | 50 | tang, len_gia, khoi_sac, mua_rong, loi_nhuan |
| 3 | +0.2 | 30 | hoi, xanh, tiem_nang, khuyen_nghi, dong_tien |
| 4 | -0.2 | 30 | giam, dieu_chinh, rui_ro, ap_luc, yeu |
| 5 | -0.5 | 50 | giam_sau, lao_doc, lo, ban_thao, pha_san |
| 6 | -1.0 | 30 | giam_san, kich_san, sup_do, pha_san_chinh_thuc |
| Cultural (DD-3) | -0.8 to +0.3 | ~16 | doi_lai, du_dinh, bat_day, bom_thoi, hang_zin |

**Total**: ~236 entries including unicode forms (both ASCII-transliterated +
unicode for dual-tokenizer matching).

## Labelling Protocol

### Source decision (per STEP 0.5 CHARTER-TIER GATE + AQ-8 + plan-028 § K.2)

**Current status**: UNCALIBRATED-V0 (option iv). User ratification pending
via `human-workspace/notifications/STOP-FINDING-S365-corpus-labelling-source.md`.

When user picks labelling source, calibration cycle proceeds with:

### Per-article tuple format (JSONL)

Store labelled corpus at `data/corpus/vn_financial_news_labelled/v0.jsonl`
(**gitignored** per Karpathy P3 storage discipline; corpus data is not source code).

```json
{
  "article_id": "vietstock-2026-05-16-001",
  "body_text": "...",
  "true_label": "STRONGLY_BULLISH",
  "source": "owner-manual",
  "labelled_at": "2026-05-XX"
}
```

Valid `true_label` values (per Sentiment 5-class StrEnum Rule 7):
- `"strongly_bullish"`, `"bullish"`, `"neutral"`, `"bearish"`, `"strongly_bearish"`

Valid `source` values:
- `"owner-manual"` (option i — project-owner labels)
- `"llm-bootstrap"` (option ii — Claude subagent labels; requires 5% spot-check)
- `"distant"` (option iii — DEFERRED per architect recommendation)

## Cross-Validation Harness

DEFERRED to sub-plan 030-V2 calibration cycle. v0 ships hypothesis weights +
protocol docs only. When calibration runs:

1. Expand corpus to n≥150 articles per § STEP 0.2 recipe above
2. Label each article: `(article_id, body_text, true_label)` per format above
3. Split labelled corpus 80/20 train/held-out (stratified by class if possible)
4. For each weight in `_VN_SENTIMENT_LEXICON`:
   - Grid search ±0.1 around hypothesis weight
   - Evaluate macro-F1 on held-out split
5. Select weight set maximizing macro-F1 on held-out
6. Compute per-class precision/recall/F1 + macro-F1 + Cohen's kappa
7. Update lexicon dict in source; bump `VN_SENTIMENT_LEXICON_VERSION` to
   `"v0.CALIBRATED"` + date stamp (e.g. `"v0.CALIBRATED-2026-05-30"`)
8. Commit lexicon update with rationale in commit message

**Helper script location** (to be created at calibration cycle):
`apps/extraction/sentiment/calibrate.py`

## Accuracy Metrics

| Metric | Hypothesis (v0) | Calibrated (v0.CALIBRATED) | DoD Floor |
|--------|-----------------|---------------------------|-----------|
| Macro-F1 (5-class) | UNKNOWN — calibration required | DEV FILLS post-calibration | ≥0.70 |
| Per-class F1 STRONGLY_BULLISH | UNKNOWN | DEV FILLS | ≥0.50 |
| Per-class F1 BULLISH | UNKNOWN | DEV FILLS | ≥0.50 |
| Per-class F1 NEUTRAL | UNKNOWN | DEV FILLS | ≥0.50 |
| Per-class F1 BEARISH | UNKNOWN | DEV FILLS | ≥0.50 |
| Per-class F1 STRONGLY_BEARISH | UNKNOWN | DEV FILLS | ≥0.50 |
| Cohen's kappa | UNKNOWN | DEV FILLS | ≥0.50 |
| Coverage (% articles ≥1 hit) | DEV FILLS from dogfood | DEV FILLS | ≥70% |

## CLI Dogfood Results (D5 Integration Smoke — S365)

See session log `agent-workspace/memory/sessions/2026-05-17-session-365.md`
§ D5 CLI smoke section for per-article scores and category distribution.

## Revisit Triggers (per AP-7 anti-vacuous-defer)

1. **Macro-F1 <70% on held-out** → calibration weight adjustment cycle
   (gradient-free grid search per § Cross-Validation Harness step 4)
2. **Coverage <50% on held-out corpus eval n=200+** → E.2-V2 PhoBERT fallback
   evaluation (per plan-030 § A.3 deferral trigger)
3. **≥3 unresolved cultural references in production extractor logs** →
   cultural-anchor list expansion (AP-23 promote-or-extend calculus)
4. **Project-owner picks labelling source (i or ii)** → calibration cycle
   runs; weights updated; version bumped to v0.CALIBRATED

## ADR D-071 Reference

See `agent-workspace/memory/decisions/071-vn-sentiment-lexicon.md` for:
- Lexicon design rationale (DD-1 through DD-7)
- Buffett-rubric tier mapping
- Pattern source (TradingAgents-CN akshare.py:1497-1611 — pattern only)
- Authorization field (filled when user picks labelling source)

## Source

- plan-030 § DD-7 + D4 sub-track (S364 architect; S365 dev session)
- ADR D-071 PROPOSED (`agent-workspace/memory/decisions/071-vn-sentiment-lexicon.md`)
- `agent-workspace/calibration/vn_tokenizer_eval_v0.md` (corpus baseline format reference)
- `apps/extraction/sentiment/vn_lexicon.py` (implementation)
