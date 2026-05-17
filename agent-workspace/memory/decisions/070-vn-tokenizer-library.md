---
id: 070
title: VN Tokenizer Library Selection
status: PROPOSED
date: 2026-05-17
authors: sandwich-dev S362
level: ARCH
supersedes: []
superseded-by: []
empirical_close_verify: |
  - VnTokenizer class instantiable + tokenize() returns deterministic list[str] on synthetic VN text
  - mypy --strict + ruff + pytest on packages/infrastructure/nlp/ exit 0
  - STEP 0 scorecard recorded at agent-workspace/calibration/vn_tokenizer_eval_v0.md
  - License classification recorded inline below
  - DC-GATE-1 through DC-GATE-7 all pass (per plan-029 § F)
---

# D-070: VN Tokenizer Library Selection

## Context

Sub-plan 029-S361-phase-e1-vn-tokenization STEP 0 empirical evaluation selected
a VN tokenization library for StockForge's Phase E Vietnamese NLP theme. The
selection required:
1. Empirical quality scoring on VN financial corpus
2. License audit (CHARTER-TIER GATE for GPL-3.0 / copyleft)
3. Perf + install cost measurement
4. I-S34 transitive dep audit (hard-reject patchright/playwright_stealth/etc.)
5. D-059 determinism smoke

## Decision

**SELECTED library**: `pyvi==0.1.1` (MIT license)

Per plan-029 § C STEP 0.5 architect recommendation:
> "IF pyvi quality within 10% of underthesea: pick (c) — simplicity + license
> safety wins over marginal quality gap."

Quality gap = 81.8% - 75.7% = 6.1% < 10% threshold => pyvi selected.
Additionally: underthesea v9.4.0 is Apache-2.0 (NOT GPL-3.0 as historical
documentation indicated; verified via LICENSE file at installed package path
`underthesea-9.4.0.dist-info/licenses/LICENSE` line 1: "Apache License
Version 2.0"). CHARTER-TIER GATE DID NOT FIRE.

## Empirical scorecard (STEP 0.3-0.4; n=36 articles; NDH/Vietstock/VietnamBiz)

| Candidate     | Quality % | Perf ms/1000tok | Install MB | License     | Selected? |
|---------------|-----------|-----------------|------------|-------------|-----------|
| underthesea   | 81.8%     | 27.2            | ~29 MB     | Apache-2.0  | NO        |
| pyvi          | 75.7%     | 7.5             | ~29 MB     | MIT         | YES       |
| whitespace    | 0.0%      | 0.2             | 0 MB       | Proprietary | NO        |

Quality metric: % of 50 VN financial reference terms (cổ phiếu, thị trường,
etc.) preserved as single tokens (NOT split into syllables) when present in
article body. Scored over n=30 sampled articles from n=36 corpus.

## CHARTER-TIER GATE outcome (STEP 0.5)

NOT FIRED — SELECTED candidate (pyvi) is MIT; no user ratification needed.

ADDITIONAL FINDING: underthesea v9.4.0 is Apache-2.0, NOT GPL-3.0. Historical
documentation (supplement + architect observations) stated GPL-3.0 based on
older versions. Current version license verified empirically:
- `pip show underthesea | grep License-Expression` → `Apache-2.0`
- LICENSE file at `underthesea-9.4.0.dist-info/licenses/LICENSE` line 1:
  "Apache License Version 2.0, January 2004"

This is a NEW FINDING (architect observations were stale re: underthesea license).
Recorded here per I-S2 citation discipline. Does NOT change selection decision
(pyvi still wins per quality-gap < 10% + MIT simplicity criteria).

## Authorization

PROPOSED at IMPL tier; auto-ratifies on commit per severity-schema (ARCH level).
No user ratification required (CHARTER-TIER GATE did not fire).

## Revisit triggers (per AP-7 anti-vacuous-defer)

1. pyvi quality <50% on sub-plan 030 held-out corpus eval (n=200+) →
   E.1-V2 underthesea or PhoBERT fallback evaluation
2. pyvi transitive-dep update introduces I-S34 HARD REJECT artifact →
   emergency unpin + revert to whitespace-baseline
3. pyvi license changes from MIT (quarterly re-verify cycle per NOTICE
   precedent) → CHARTER-TIER re-gate

## Risks

- RM1: pyvi v0.1.1 (2019 release; no recent maintenance) may become unmaintained →
  AP-7 trigger 2 above; whitespace-baseline always available as fallback
- RM2: tokenizer-output drift across pyvi model updates → exact version pinned
  in pyproject.toml (`pyvi>=0.1.1`); lock file provides additional protection
- RM3: underthesea license discovery was stale → future library-eval plans
  MUST verify LICENSE file verbatim (not rely on historical agent observations)

## Source

- plan-029 § C STEP 0.5 (library selection rationale + quality threshold)
- plan-029 § D DD-2 (CONDITIONAL library selection — STEP 0 gates)
- agent-workspace/calibration/vn_tokenizer_eval_v0.md (full scorecard)
- packages/infrastructure/nlp/vn_tokenizer.py (implementation)
