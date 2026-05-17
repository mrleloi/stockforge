"""VnSentimentLexicon — concrete VnLexiconPort adapter for VN financial sentiment.

Ports the TradingAgents-CN rule-based lexicon-weight scoring PATTERN (per
A-14 § 3.5 + akshare.py:1497-1611) — PATTERN ONLY; no LOC copy (TradingAgents-CN
Apache-2.0 license safe-for-pattern-port per D-061 § Item 4; per Karpathy P2
simplicity no LOC copy needed).

VN keywords hand-curated per parent plan-028 DD-4 + plan-030 § STEP 0.3 seed set
~220 keywords across 6 tiers (1.0 / 0.5 / 0.2 / -0.2 / -0.5 / -1.0) + VN-specific
cultural anchors (doi_lai / du_dinh / bat_day / lai / phim_hang / bom_thoi).

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

# ---------------------------------------------------------------------------
# Lexicon dict — hand-curated per plan-030 § STEP 0.3 seed set
#
# pyvi joins multi-syllable VN words with underscore in its output
# (e.g. "co phieu" -> "co_phieu").  Lexicon keys MUST match this format.
# WhitespaceTokenizer splits per-word; for that fallback, multi-syllable keys
# will not match (acceptable per plan-029 AQ-7 DEFAULT-LOW-QUALITY posture).
#
# Source: plan-030 § C STEP 0.3 (architect seed set, 2026-05-17)
# ---------------------------------------------------------------------------

_VN_SENTIMENT_LEXICON: dict[str, float] = {
    # ===================================================================
    # === Tier 1: Strongly positive (weight 1.0) ~30 keywords ===
    # ===================================================================
    "tang_tran": 1.0,          # hit circuit breaker limit up
    "kich_tran": 1.0,          # locked limit up (same as tang_tran, alt form)
    "lap_dinh": 1.0,           # set new high
    "pha_dinh": 1.0,           # break through previous high
    "but_pha": 1.0,            # breakthrough
    "vuot_dinh": 1.0,          # surpass peak
    "sieu_tang": 1.0,          # super rise
    "sieu_loi_nhuan": 1.0,     # super profit
    "tang_vot": 1.0,           # surge
    "bung_no": 1.0,            # explode (positive)
    "hoi_phuc_manh": 1.0,      # strong recovery
    "chot_loi_lon": 1.0,       # take big profit
    "lap_ky_luc": 1.0,         # set record
    "dot_pha_lich_su": 1.0,    # historical breakthrough
    "sieu_co_phieu": 1.0,      # super stock
    "dong_tien_cuon_cuon": 1.0, # gushing money flow (strong buying)
    "mua_rong_lon": 1.0,       # large net buy
    "mua_rong_manh": 1.0,      # strong net buy
    "lai_ky_luc": 1.0,         # record profit
    "lai_dot_bien": 1.0,       # spike profit
    "lai_gap": 1.0,            # profit multiplied
    "loi_nhuan_dot_bien": 1.0, # profit spike
    "sieu_co": 1.0,            # super stock (short form)
    "tang_manh": 1.0,          # strong rise
    "x2": 1.0,                 # doubled (price/profit)
    "x3": 1.0,                 # tripled
    "x5": 1.0,                 # quintupled
    "siêu_tăng": 1.0,          # unicode form: super rise
    "tăng_trần": 1.0,          # unicode form: hit ceiling
    "kịch_trần": 1.0,          # unicode form: locked limit up
    # ===================================================================
    # === Tier 2: Moderately positive (weight 0.5) ~50 keywords ===
    # ===================================================================
    "tang": 0.5,               # rise / increase
    "len_gia": 0.5,            # price up
    "khoi_sac": 0.5,           # brightening / upbeat
    "cai_thien": 0.5,          # improve
    "tich_cuc": 0.5,           # positive
    "hoi_phuc": 0.5,           # recovery
    "phuc_hoi": 0.5,           # recover
    "mua_rong": 0.5,           # net buy
    "kha_quan": 0.5,           # favorable
    "loi_nhuan": 0.5,          # profit
    "lai": 0.5,                # profit (short)
    "lai_rong": 0.5,           # net profit
    "doanh_thu_tang": 0.5,     # revenue increase
    "ket_qua_tich_cuc": 0.5,   # positive results
    "chia_co_tuc": 0.5,        # dividend payment
    "thuong_co_phieu": 0.5,    # stock bonus
    "chot_loi": 0.5,           # profit-taking (positive)
    "trien_vong": 0.5,         # prospect / outlook positive
    "co_hoi": 0.5,             # opportunity
    "mo_rong": 0.5,            # expand
    "phat_trien": 0.5,         # develop
    "tang_truong": 0.5,        # growth
    "sap_nhap": 0.5,           # merger (positive context)
    "mua_lai": 0.5,            # buyback
    "nang_hang": 0.5,          # upgrade
    "niem_yet_moi": 0.5,       # new listing
    "chao_san": 0.5,           # IPO debut
    "phat_hanh_thanh_cong": 0.5, # successful issuance
    "co_tuc_cao": 0.5,         # high dividend
    "tai_cau_truc": 0.5,       # restructure (positive)
    "tang_von": 0.5,           # capital increase
    "vuot_ke_hoach": 0.5,      # beat target
    "hoan_thanh_ke_hoach": 0.5, # target achieved
    "but_toc": 0.5,            # accelerate
    "hap_dan": 0.5,            # attractive
    "sinh_loi": 0.5,           # profitable
    "gia_tri": 0.5,            # value (positive)
    "on_dinh": 0.5,            # stable
    "ben_vung": 0.5,           # sustainable
    "chien_luoc_tot": 0.5,     # good strategy
    "mo_hinh_tot": 0.5,        # good model
    "tăng": 0.5,               # unicode: rise
    "lên_giá": 0.5,            # unicode: price up
    "lợi_nhuận": 0.5,          # unicode: profit
    "khởi_sắc": 0.5,           # unicode: brightening
    "phục_hồi": 0.5,           # unicode: recovery
    "mua_ròng": 0.5,           # unicode: net buy
    "cải_thiện": 0.5,          # unicode: improve
    "tích_cực": 0.5,           # unicode: positive
    "triển_vọng": 0.5,         # unicode: prospect
    # ===================================================================
    # === Tier 3: Mildly positive (weight 0.2) ~30 keywords ===
    # ===================================================================
    "hoi": 0.2,                # recover slightly
    "xanh": 0.2,               # green (positive price)
    "quan_tam": 0.2,           # interest / attention
    "chu_y": 0.2,              # attention
    "khuyen_nghi_mua": 0.2,    # buy recommendation
    "khuyen_nghi": 0.2,        # recommendation
    "trien_vong_tot": 0.2,     # good prospects
    "kha_nang": 0.2,           # possibility
    "tiem_nang": 0.2,          # potential
    "du_kien": 0.2,            # expected
    "ke_hoach": 0.2,           # plan
    "muc_tieu": 0.2,           # target
    "du_bao": 0.2,             # forecast
    "lo_trinh": 0.2,           # roadmap
    "chien_luoc": 0.2,         # strategy
    "phuong_an": 0.2,          # plan / option
    "giai_phap": 0.2,          # solution
    "quyet_dinh": 0.2,         # decision
    "phat_hanh": 0.2,          # issue / launch
    "dau_tu": 0.2,             # invest
    "bo_sung": 0.2,            # supplement
    "tang_cuong": 0.2,         # strengthen
    "thuan_loi": 0.2,          # favorable
    "yeu_to_tich_cuc": 0.2,    # positive factor
    "xu_huong": 0.2,           # trend (neutral-to-positive)
    "momentum": 0.2,           # momentum
    "dong_tien": 0.2,          # money flow
    "tiem_năng": 0.2,          # unicode: potential
    "đầu_tư": 0.2,             # unicode: invest
    "khuyến_nghị": 0.2,        # unicode: recommendation
    # ===================================================================
    # === Tier 4: Mildly negative (weight -0.2) ~30 keywords ===
    # ===================================================================
    "giam": -0.2,              # decrease
    "dieu_chinh": -0.2,        # adjust / correct (down)
    "dao_dong": -0.2,          # fluctuate
    "bien_dong": -0.2,         # volatile
    "than_trong": -0.2,        # cautious
    "can_trong": -0.2,         # careful
    "cham_lai": -0.2,          # slow down
    "han_che": -0.2,           # limit / restrict
    "rui_ro": -0.2,            # risk
    "kho_khan": -0.2,          # difficulty
    "thach_thuc": -0.2,        # challenge
    "ap_luc": -0.2,            # pressure
    "lo_ngai": -0.2,           # concern
    "e_ngai": -0.2,            # worry
    "theo_doi": -0.2,          # monitor (cautious context)
    "xem_xet": -0.2,           # consider (cautious)
    "canh_giac": -0.2,         # vigilant / be careful
    "phong_ve": -0.2,          # defensive
    "chot_non": -0.2,          # premature exit
    "cat_lo_nho": -0.2,        # small stop-loss
    "dieu_chinh_nhe": -0.2,    # light adjustment
    "dao_dong_hep": -0.2,      # narrow range
    "linh_xinh": -0.2,         # sideways / stagnant
    "di_ngang": -0.2,          # sideways
    "sideway": -0.2,           # sideway
    "yeu": -0.2,               # weak
    "yeu_di": -0.2,            # weakening
    "giảm": -0.2,              # unicode: decrease
    "điều_chỉnh": -0.2,        # unicode: adjust
    "rủi_ro": -0.2,            # unicode: risk
    # ===================================================================
    # === Tier 5: Moderately negative (weight -0.5) ~50 keywords ===
    # ===================================================================
    "giam_sau": -0.5,          # deep decline
    "lao_doc": -0.5,           # plunge
    "lo": -0.5,                # loss
    "lo_rong": -0.5,           # net loss
    "lo_nang": -0.5,           # heavy loss
    "doanh_thu_giam": -0.5,    # revenue decline
    "ket_qua_tieu_cuc": -0.5,  # negative results
    "ban_rong": -0.5,          # net sell
    "ban_thao": -0.5,          # panic sell / dump
    "xa_hang": -0.5,           # sell off
    "ap_luc_ban": -0.5,        # selling pressure
    "ban_manh": -0.5,          # strong sell
    "sut_giam": -0.5,          # drop / decline
    "ha_gia": -0.5,            # price reduction
    "pha_san": -0.5,           # bankruptcy
    "no_xau": -0.5,            # bad debt / NPL
    "no_kho_doi": -0.5,        # irrecoverable debt
    "thua_lo": -0.5,           # operating loss
    "kho_khan_tai_chinh": -0.5, # financial difficulty
    "thua_ke_hoach": -0.5,     # miss target
    "khong_dat_ke_hoach": -0.5, # fail target
    "canh_bao": -0.5,          # warning
    "kiem_soat": -0.5,         # under control / supervision (negative)
    "tach_niem_yet": -0.5,     # delist
    "huy_niem_yet": -0.5,      # delist forced
    "dieu_tra": -0.5,          # investigate
    "xu_phat": -0.5,           # fine / penalty
    "vi_pham": -0.5,           # violation
    "sai_pham": -0.5,          # wrongdoing
    "gian_lan": -0.5,          # fraud
    "lua_dao": -0.5,           # scam
    "khung_hoang": -0.5,       # crisis
    "thoai_von": -0.5,         # divest
    "ban_co_phieu": -0.5,      # sell shares
    "co_dong_lon_ban": -0.5,   # large shareholder selling
    "thoai_lui": -0.5,         # retreat / exit
    "tai_cau_truc_khan_cap": -0.5, # emergency restructure
    "thanh_ly": -0.5,          # liquidate
    "chuyen_san_xuong": -0.5,  # downgrade market tier
    "giam_von": -0.5,          # capital reduction
    "co_phieu_rac": -0.5,      # junk stock
    "co_phieu_kem": -0.5,      # poor stock
    "co_phieu_yeu": -0.5,      # weak stock
    "khong_kha_quan": -0.5,    # not favorable
    "tieu_cuc": -0.5,          # negative
    "xau": -0.5,               # bad
    "thua_lo_lien_tiep": -0.5, # consecutive losses
    "am_von_chu_so_huu": -0.5, # negative equity
    "am_dong_tien": -0.5,      # negative cash flow
    "mat_thanh_khoan": -0.5,   # illiquid
    "lỗ": -0.5,                # unicode: loss
    "bán_ròng": -0.5,          # unicode: net sell
    "bán_tháo": -0.5,          # unicode: panic sell
    "khủng_hoảng": -0.5,       # unicode: crisis
    # ===================================================================
    # === Tier 6: Strongly negative (weight -1.0) ~30 keywords ===
    # ===================================================================
    "giam_san": -1.0,          # hit circuit breaker limit down
    "kich_san": -1.0,          # locked limit down
    "lao_doc_khong_phanh": -1.0, # uncontrolled plunge
    "sup_do": -1.0,            # collapse
    "tham_bai": -1.0,          # catastrophic loss
    "sieu_thua_lo": -1.0,      # super loss
    "lo_ky_luc": -1.0,         # record loss
    "am_von": -1.0,            # negative capital
    "pha_san_chinh_thuc": -1.0, # officially bankrupt
    "dinh_chi_giao_dich": -1.0, # trading suspended
    "tam_ngung_giao_dich": -1.0, # trading halted
    "cam_giao_dich": -1.0,     # trading banned
    "co_phieu_bi_buoc_ban": -1.0, # forced sale of shares
    "giai_the": -1.0,          # dissolution
    "khoi_to": -1.0,           # criminal prosecution
    "bat_giu": -1.0,           # arrest
    "dieu_tra_hinh_su": -1.0,  # criminal investigation
    "lua_dao_lon": -1.0,       # major fraud
    "gian_lan_tai_chinh": -1.0, # financial fraud
    "boc_tran": -1.0,          # expose fraud
    "ke_khai_gian_doi": -1.0,  # false declaration
    "khong_co_kha_nang_thanh_toan": -1.0, # unable to pay
    "x0": -1.0,                # value wiped to zero
    "mat_trang": -1.0,         # total loss (wiped out)
    "vo_no": -1.0,             # debt collapse / default
    "pha_nat": -1.0,           # destroyed / ruined
    "giảm_sàn": -1.0,          # unicode: hit floor limit
    "kịch_sàn": -1.0,          # unicode: locked limit down
    "sụp_đổ": -1.0,            # unicode: collapse
    "phá_sản": -1.0,           # unicode: bankruptcy
    # ===================================================================
    # === Cultural anchors (MANDATORY per parent DD-4 + plan-030 DD-3) ===
    # These entries are also in VN_CULTURAL_ANCHORS frozenset below.
    # ===================================================================
    "doi_lai": -0.8,           # pump-group / price-manipulation cluster
    "lai_co_phieu": -0.6,      # stock manipulation (different from "lai" profit)
    "du_dinh": -0.7,           # FOMO buyer at top / catching falling knife at top
    "bat_day": -0.4,           # bottom-fisher / catch-the-knife (less severe)
    "phim_hang": -0.5,         # insider tip / stock pumping
    "bom_thoi": -0.7,          # pump-and-dump
    "ca_map": -0.3,            # whale / big-money manipulator (context-dependent)
    "hang_zin": 0.3,           # legitimate stock (retail term for quality)
    # unicode forms of cultural anchors
    "đội_lái": -0.8,           # unicode: pump-group
    "đu_đỉnh": -0.7,           # unicode: FOMO at top
    "bắt_đáy": -0.4,           # unicode: bottom-fisher
    "phím_hàng": -0.5,         # unicode: insider tip
    "bơm_thổi": -0.7,          # unicode: pump-and-dump
    "cá_mập": -0.3,            # unicode: whale
    "hàng_zin": 0.3,           # unicode: legitimate stock
}

# Frozen set of cultural anchors for E.3 sub-plan 031 consumer per DD-3 +
# parent DD-5 step 5 mentioned_pump_anchors field.
# Contains BOTH ascii-transliterated and unicode forms for robust matching.
VN_CULTURAL_ANCHORS: frozenset[str] = frozenset(
    {
        # ASCII-transliterated forms (what WhitespaceTokenizer may produce)
        "doi_lai",
        "du_dinh",
        "bat_day",
        "phim_hang",
        "bom_thoi",
        "ca_map",
        "hang_zin",
        # Unicode forms (what pyvi VnTokenizer joins with underscore)
        "đội_lái",
        "đu_đỉnh",
        "bắt_đáy",
        "phím_hàng",
        "bơm_thổi",
        "cá_mập",
        "hàng_zin",
    }
)


@dataclass(frozen=True, slots=True)
class SentimentScore:
    """Deterministic sentiment score per Rule 16 mode 2 + Rule 7 categorical.

    Fields:
    - numeric_score: Rule 16 mode 2 deterministic-pipeline echo; range [-1.0, 1.0]
    - category: Rule 7 categorical 5-class; derived via Buffett-rubric tier per DD-6
    - keyword_hits: audit trail per I-S2 of matched keywords; tuple for immutability
    - coverage_ratio: Rule 16 mode 2; range [0.0, 1.0];
                      len(matched_keywords) / max(1, len(tokens))

    Source: plan-030 § DD-5
    I-S1-1: numeric_score is deterministic echo of lexicon_weight_sum(tokens) per
             Rule 16 § Enforcement schema-time guidance.
    """

    numeric_score: float
    category: Sentiment
    keyword_hits: tuple[str, ...] = field(default_factory=tuple)
    coverage_ratio: float = 0.0

    @classmethod
    def empty(cls) -> SentimentScore:
        """Return neutral SentimentScore for empty / unmatched input."""
        return cls(
            numeric_score=0.0,
            category=Sentiment.NEUTRAL,
            keyword_hits=(),
            coverage_ratio=0.0,
        )

    def __post_init__(self) -> None:
        if not -1.0 <= self.numeric_score <= 1.0:
            raise ValueError(
                f"numeric_score {self.numeric_score} not in [-1.0, 1.0] "
                "(Rule 16 mode 2 range violation)"
            )
        if not 0.0 <= self.coverage_ratio <= 1.0:
            raise ValueError(
                f"coverage_ratio {self.coverage_ratio} not in [0.0, 1.0]"
            )


# Buffett-rubric-inspired tier thresholds per DD-6 + A-01 § 3 C9
# Pattern from ai-hedge-fund warren_buffett.py:788-794 (90-100/70-89/50-69/30-49/10-29
# evidence-quality brackets adapted to StockForge Sentiment 5-class).
_TIER_THRESHOLDS: tuple[tuple[float, Sentiment], ...] = (
    (0.7, Sentiment.STRONGLY_BULLISH),     # [0.7, 1.0]
    (0.3, Sentiment.BULLISH),              # [0.3, 0.7)
    (-0.3, Sentiment.NEUTRAL),             # [-0.3, 0.3)
    (-0.7, Sentiment.BEARISH),             # [-0.7, -0.3)
    (float("-inf"), Sentiment.STRONGLY_BEARISH),  # [-1.0, -0.7)
)


def _score_to_category(numeric_score: float) -> Sentiment:
    """Map numeric_score to Sentiment via Buffett-rubric-inspired tiers (DD-6).

    Deterministic lookup — no LLM involvement (Rule 16 mode 2 by construction).
    """
    for threshold, category in _TIER_THRESHOLDS:
        if numeric_score >= threshold:
            return category
    return Sentiment.STRONGLY_BEARISH  # unreachable per SentimentScore __post_init__


# Score normalization formula per A-14 § 3.5 akshare.py:1563 pattern:
# normalized = max(-1.0, min(1.0, raw_score / NORMALIZATION_DIVISOR))
# Divisor 3.0 keeps typical-article score in [-1, 1] for lexicons with
# ~3 matching keywords per article at average weight ±1.0.
_NORMALIZATION_DIVISOR: float = 3.0


@dataclass
class VnSentimentLexicon:
    """VN sentiment lexicon scorer wrapping injected tokenizer + lexicon dict.

    Constructor takes tokenizer (DI per DD-4 + sub-plan 029 D1+D2 precedent).
    Tests inject WhitespaceTokenizer; production injects pyvi VnTokenizer.

    Satisfies VnLexiconPort structural Protocol via duck-typing (mypy --strict
    validates at import time; no explicit base class required per DD-1).

    Calibration status: v0.HYPOTHESIS — weights are hand-curated seed set from
    plan-030 § STEP 0.3; calibration cycle runs post-IMPL per Principle 8 recipe
    at agent-workspace/calibration/vn_sentiment_lexicon_v0.md.
    """

    tokenizer: TextTokenizerPort
    lexicon_version: str = field(default=VN_SENTIMENT_LEXICON_VERSION)

    def score(self, text: str) -> SentimentScore:
        """Return SentimentScore via lexicon-weight summation per DD-4 + DD-5.

        Algorithm:
        1. Tokenize text via injected tokenizer (pyvi or whitespace baseline)
        2. Look up each token in _VN_SENTIMENT_LEXICON dict
        3. Sum weights of matched tokens
        4. Normalize: max(-1.0, min(1.0, raw_sum / _NORMALIZATION_DIVISOR))
        5. Map normalized score to Sentiment category via _score_to_category
        6. Return SentimentScore frozen dataclass

        I-S1 compliance: pure-function; no LLM invocation
        Rule 16 mode 2: numeric_score is deterministic-pipeline echo of step 4
        I-S1-1: deterministic echo of lexicon_weight_sum(tokens) per Rule 16
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
            # whitespace fallback splits per-word; both work for direct match.
            # Lowercased for matching consistency (lexicon keys are lowercase).
            token_lower = token.lower()
            weight = _VN_SENTIMENT_LEXICON.get(token_lower)
            if weight is not None:
                raw_score += weight
                keyword_hits.append(token_lower)

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
