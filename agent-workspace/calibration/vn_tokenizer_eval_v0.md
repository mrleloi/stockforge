# VN Tokenizer Library Evaluation v0 — STEP 0 scorecard (S362)

> Empirical scorecard from sub-plan 029-S361-phase-e1-vn-tokenization STEP 0.
> Source: S362 dev session + ADR D-070.
> Re-eval trigger: per ADR D-070 revisit trigger 1 (sub-plan 030 held-out corpus <50% quality)

## Corpus

- **N=36 articles** extracted from `data/raw/news/` after corpus expansion via CLIs
- Source distribution:
  - NDH = 14 articles (ingest_news_ndh CLI; 2026-05-16 date dir) [S363 F1 correction: dev observation said 12; empirical find/wc -l = 14; total 36 unchanged]
  - Vietstock = 10 articles (ingest_news_vietstock CLI; 2026-05-16 date dir)
  - VietnamBiz = 12 articles (ingest_news_vietnambiz CLI; 2026-05-16 date dir)
  - CafeF = 0 articles (ingest_news_cafef returned 0; likely network/selector issue)
- Quality scoring used n=30 articles (first 30 of 36)

## Reference financial-term list (50 terms; per plan-029 § C STEP 0.3)

cổ phiếu, thị trường, doanh nghiệp, lợi nhuận, cổ đông,
chứng khoán, niêm yết, kết quả kinh doanh, tăng trưởng, lao dốc,
đột phá, nhà đầu tư, quỹ đầu tư, tài sản, lãi suất,
tỷ giá, vốn hóa, tự doanh, khối ngoại, khối nội,
phái sinh, cơ bản, kỹ thuật, phân tích, dự báo,
kế hoạch, chiến lược, thâu tóm, sáp nhập, mua lại,
bán ròng, mua ròng, đặt lệnh, khớp lệnh, dư mua,
dư bán, giao dịch, phiên giao dịch, chỉ số, phục hồi,
điều chỉnh, tích lũy, phân phối, đầu cơ, đầu tư dài hạn,
cắt lỗ, chốt lời, đu đỉnh, bắt đáy, đội lái

## Per-candidate scorecard

| Candidate    | Quality %* | Perf ms/1000tok | Install MB | License    | Selected? |
|--------------|-----------|-----------------|------------|------------|-----------|
| underthesea  | 81.8%     | 27.2            | ~29 MB     | Apache-2.0 | NO        |
| pyvi         | 75.7%     | 7.5             | ~29 MB     | MIT        | YES       |
| whitespace   | 0.0%      | 0.2             | 0 MB       | own        | NO        |

*Quality metric: % of 50 VN financial reference terms preserved as single
underscore-joined token when present in article body (n=30 articles).

Perf metric: ms per 1000 output tokens; measured over 10K chars × 3 runs.

## License audit (STEP 0.5 verbatim verification)

- **underthesea v9.4.0**: `pip show underthesea | grep License-Expression` →
  `Apache-2.0`. LICENSE file at
  `underthesea-9.4.0.dist-info/licenses/LICENSE` line 1:
  "Apache License Version 2.0, January 2004".
  NOTE: historical agent documentation incorrectly stated GPL-3.0; this
  was stale — v9.4.0 (2024+) is Apache-2.0.

- **pyvi v0.1.1**: `pip show pyvi | grep License` → `MIT`. LICENSE file at
  `pyvi-0.1.1.dist-info/LICENSE.txt` line 1:
  "The MIT License (MIT) Copyright (c) 2016 Viet-Trung Tran".

**CHARTER-TIER GATE: DID NOT FIRE** — both candidates permissive.

## I-S34 HARD REJECT audit (STEP 0.6)

```
pip list | grep -iE "patchright|playwright.*stealth|fake.*useragent|StealthyFetcher|cloudflare"
# → ZERO matches
```

No patchright, playwright_stealth, fake-useragent, StealthyFetcher, or
cloudflare-solver in underthesea or pyvi transitive dependencies.

## D-059 Determinism smoke (STEP 0.7)

```python
# underthesea: word_tokenize(text) == word_tokenize(text) -> True
# pyvi: ViTokenizer.tokenize(text) == ViTokenizer.tokenize(text) -> True
```

Both libraries produce identical output across 2 consecutive calls on same
ASCII-safe test input. CONFIRMED DETERMINISTIC.

## Selection decision

pyvi selected per plan-029 § C STEP 0.5 architect recommendation:
- Quality gap = 81.8% - 75.7% = **6.1% < 10% threshold**
- Architect recommendation: "IF pyvi quality within 10% of underthesea:
  pick (c) — simplicity + license safety wins over marginal quality gap."
- pyvi is 3.6x faster (7.5 vs 27.2 ms/1000tok)
- pyvi is MIT (simpler than Apache-2.0; both permissive)

## Re-use for sub-plan 030

This scorecard is the corpus baseline for sub-plan 030 sentiment lexicon
calibration. Sub-plan 030 should:
1. Expand corpus to n=200-500 articles (labelling cycle)
2. Re-run quality eval on sub-plan 030's held-out subset
3. Trigger E.1-V2 (underthesea or PhoBERT) if quality drops below 50%

## CafeF corpus gap

ingest_news_cafef returned 0 articles during STEP 0.2 expansion (2026-05-17).
Investigation deferred per plan-029 Out-of-scope (not E.1 concern). Impact:
corpus is NDH/Vietstock/VietnamBiz only; CafeF article style not represented
in quality scores. Mitigation: 36 articles from 3 sources is above n=30
minimum threshold; eval is directional not absolute; sub-plan 030 expansion
to n=200-500 will include CafeF if adapter recovers.
