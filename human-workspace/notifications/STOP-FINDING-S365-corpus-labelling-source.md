---
level: ALERT
created_at: 2026-05-17T00:00:00Z
status: pending-user-pick
decision_class: CHARTER-TIER
---

# STOP-AND-ASK — Corpus labelling source (S365 sub-plan 030 STEP 0.5)

## Context

Per plan-030 § C sub-step 0.5 + § CHARTER-TIER GATE clause + plan-028 § K.2.
S365 sandwich-dev proceeds with UNCALIBRATED-V0 path per dispatch brief
(NON-BLOCKING per plan-030 § M + architect recommendation option (iv)).

## Empirical findings

- **Corpus baseline**: n=36 articles at S362 STEP 0.2 expansion (NDH/Vietstock/VietnamBiz; CafeF=0)
- **STEP 0.2 corpus expansion**: Skipped in-session (live HTTP requests exceed session budget;
  recorded in calibration recipe as "thin-evidence baseline")
- **v0 lexicon**: ~220 keywords with hypothesis weights (per STEP 0.3 hand-curation seed set
  from plan-030 § C STEP 0.3)
- **Calibration cycle requires labelled corpus** per Principle 8 + A-14 § 7.8 anti-pattern explicit veto

## Dev action taken (NON-BLOCKING path per dispatch brief)

S365 dev proceeded with:
1. HYPOTHESIS weights per plan-030 STEP 0.3 seed set
2. `VN_SENTIMENT_LEXICON_VERSION = "v0.HYPOTHESIS"` docstring + UNCALIBRATED-V0 posture
3. Calibration recipe documented at `agent-workspace/calibration/vn_sentiment_lexicon_v0.md`
4. THIS STOP-FINDING file written per plan-030 § C STEP 0.5 protocol

## Options for user ratification (per parent plan AQ-8 + plan-030 § CHARTER-TIER GATE)

(i) **Project-owner manual labelling** — highest quality; ~5-10 hours owner time / ~1-2 days wall
    - Pro: ground-truth quality; full project-owner control
    - Con: requires owner availability; sustained time commitment
    - Action: owner labels corpus offline at `data/corpus/vn_financial_news_labelled/v0.jsonl`
      (gitignored); calibration cycle re-runs at sub-plan-030-V2 (data-only update, no new code)

(ii) **LLM-bootstrap with 5% spot-check** — Claude subagent dispatch labels each article;
     owner spot-checks >=5% sample per Rule 6 sampling pattern
    - Pro: faster than manual; ~30-60 min LLM + ~30-60 min spot-check
    - Con: LLM labels may carry systematic bias; 5% of 36 = 2 articles (statistically weak)
    - CHARTER-TIER consideration: calibration-meta sampling may need new I-S<N>
      (FLAG per plan-028 § K.2; ratification = separate ADR)

(iii) **Distant-labelling via market signals** — DEFERRED per architect recommendation
      (noise too high for v0; revisit only if owner unavailable >=1 month)

(iv) **DEFER calibration; ship UNCALIBRATED-V0** [CURRENT PATH — dev proceeded with this]
    - Pro: unblocks E.3 sub-plan 031 dispatch immediately
    - Con: cross-validation accuracy >=70% DoD floor cannot be verified empirically

## Recommended option (architect-judgement per Karpathy P2 + budget realism)

- **IF project-owner available**: Option (i) — highest quality + Principle 8 ground truth
- **IF project-owner unavailable / time-sensitive**: Option (iv) — CURRENT PATH (already shipped)
- **Option (ii)**: AVAILABLE if owner explicitly chooses LLM-bootstrap

## What happens next

- E.2 lexicon shipped with UNCALIBRATED-V0 + recipe
- E.3 sub-plan 031 dispatch UNBLOCKED (lexicon usable for hint injection without calibration)
- Calibration cycle: data-only update post-labelling; no new code needed
- Record user pick in ADR D-071 § Authorization field once received

Awaiting user pick at owner's convenience (NOT blocking E.3).
