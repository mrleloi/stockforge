"""Phase1DataGatherer — deterministic Tier 1+2 data assembly (no LLM).

Orchestrates reads from BC-1 (BarRepository), BC-2 (FundamentalRepository +
RatioService), and BC-5 (NewsRepository + ClaimRepository) to produce a
SharedContext bundle per (ticker, as_of).

This class is in INFRASTRUCTURE (not domain) because it crosses BC boundaries
as an orchestrator — it reads from BC-1, BC-2, and BC-5 repositories. The
repositories are injected as Protocol-typed constructor parameters to avoid
direct cross-BC imports. Cross-BC types pass through packages.contracts only.

Gaps detection:
- "price_stale": no bars or latest bar > 3 days before as_of
- "fundamentals_stale": no statements or latest filing > 180 days before as_of
- "no_news_90d": 0 news articles in past 90 days

data_snapshot_md5: deterministic md5 over a canonicalized payload string.
Ordering: bar_ids + statement_id + claim_ids in lexicographic order.
This ensures same data → same md5 → same thesis_id (AC-5 reproducibility).

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.6.
"""

from __future__ import annotations

import hashlib
import json
import logging
from datetime import date, timedelta
from typing import TYPE_CHECKING, Protocol, runtime_checkable

from packages.application.analysis.use_cases.validate_thesis_phase1 import SharedContext
from packages.contracts.types import Ticker
from packages.domain.market_data.services.ta_service import compute_ta_features

if TYPE_CHECKING:
    pass

__all__ = ["Phase1DataGatherer"]

log = logging.getLogger(__name__)


@runtime_checkable
class _BarRepository(Protocol):
    async def get_range_as_of(
        self, ticker: Ticker, start: date, end: date
    ) -> list[object]: ...


@runtime_checkable
class _FundamentalRepository(Protocol):
    async def get_as_of(self, ticker: Ticker, as_of: date) -> object: ...


@runtime_checkable
class _NewsRepository(Protocol):
    async def get_for_ticker(
        self, ticker: Ticker, start: date, end: date
    ) -> list[object]: ...


@runtime_checkable
class _ClaimRepository(Protocol):
    async def get_for_ticker(
        self, ticker: Ticker, start: date, end: date
    ) -> list[object]: ...


@runtime_checkable
class _RatioService(Protocol):
    def compute_ttm_ratios(self, **kwargs: object) -> dict[str, object]: ...


def _md5_of_context(
    quotes: list[object],
    statements: object,
    recent_claims: list[object],
) -> str:
    """Deterministic md5 over canonicalized context payload.

    Ordering: quote repr + statement repr + claim_ids sorted lexicographically.
    This is stable for same data regardless of insertion/retrieval order.
    """
    quote_keys = sorted(
        str(getattr(q, "bar_id", repr(q))) for q in quotes
    )
    stmt_key = str(getattr(statements, "statement_id", repr(statements)))
    claim_keys = sorted(
        str(getattr(c, "claim_id", repr(c))) for c in recent_claims
    )
    payload = json.dumps(
        {"quotes": quote_keys, "statement": stmt_key, "claims": claim_keys},
        sort_keys=True,
    )
    return hashlib.md5(payload.encode("utf-8")).hexdigest()


class Phase1DataGatherer:
    """Orchestrates Tier 1+2 data reads and produces a SharedContext.

    All repository parameters are Protocol-typed to prevent concrete cross-BC
    imports — only the abstract interface is visible from this class.
    """

    def __init__(
        self,
        bar_repo: object,          # _BarRepository Protocol
        fundamental_repo: object,  # _FundamentalRepository Protocol
        ratio_service: object,     # _RatioService Protocol
        news_repo: object,         # _NewsRepository Protocol
        claim_repo: object,        # _ClaimRepository Protocol
    ) -> None:
        self._bar_repo = bar_repo
        self._fundamental_repo = fundamental_repo
        self._ratio_service = ratio_service
        self._news_repo = news_repo
        self._claim_repo = claim_repo

    async def gather(self, ticker: Ticker, as_of: date) -> SharedContext:
        """Gather all Tier 1+2 data for (ticker, as_of). Returns SharedContext.

        All reads are point-in-time (I-S2). Gaps are recorded; has_critical_gaps()
        determines if the use case should return Thesis.incomplete().
        """
        start_365 = as_of - timedelta(days=365)
        start_90 = as_of - timedelta(days=90)

        # BC-1: Bar history
        quotes: list[object] = []
        try:
            bar_repo = self._bar_repo
            if hasattr(bar_repo, "get_range_as_of"):
                result = await bar_repo.get_range_as_of(ticker, start_365, as_of)
                quotes = list(result) if isinstance(result, list) else []
        except Exception as exc:
            log.warning("BC-1 bar read failed for %s: %s", ticker.symbol, exc)

        # BC-2: Fundamental data + ratio compute
        statements: object = None
        try:
            fund_repo = self._fundamental_repo
            if hasattr(fund_repo, "get_as_of"):
                statements = await fund_repo.get_as_of(ticker, as_of)
        except Exception as exc:
            log.warning("BC-2 fundamental read failed for %s: %s", ticker.symbol, exc)
            statements = None

        ratios_ttm: dict[str, object] = {}
        if statements is not None:
            try:
                # RatioService.compute_ttm_ratios expects specific kwargs per S34 API;
                # gather income_statements from statements if available
                income_stmts = getattr(statements, "income_statements", [statements])
                latest_bs = getattr(statements, "latest_balance_sheet", statements)
                last_price = getattr(statements, "last_price_per_share", None)
                rs = self._ratio_service
                if hasattr(rs, "compute_ttm_ratios"):
                    result_ratios = rs.compute_ttm_ratios(
                        ticker=ticker,
                        period_end=as_of,
                        income_statements=income_stmts if isinstance(income_stmts, list) else [income_stmts],
                        latest_balance_sheet=latest_bs,
                        price_per_share=last_price,
                    )
                    if isinstance(result_ratios, dict):
                        ratios_ttm = result_ratios
            except Exception as exc:
                log.warning("Ratio compute failed for %s: %s", ticker.symbol, exc)

        # BC-5: News + Claims
        recent_news: list[object] = []
        try:
            nr = self._news_repo
            if hasattr(nr, "get_for_ticker"):
                news_result = await nr.get_for_ticker(ticker, start_90, as_of)
                recent_news = list(news_result) if isinstance(news_result, list) else []
        except Exception as exc:
            log.warning("BC-5 news read failed for %s: %s", ticker.symbol, exc)

        recent_claims: list[object] = []
        try:
            cr = self._claim_repo
            if hasattr(cr, "get_for_ticker"):
                claims_result = await cr.get_for_ticker(ticker, start_90, as_of)
                recent_claims = list(claims_result) if isinstance(claims_result, list) else []
        except Exception as exc:
            log.warning("BC-5 claims read failed for %s: %s", ticker.symbol, exc)

        # Gap detection
        gaps: list[str] = []

        if not quotes:
            gaps.append("price_stale")
        else:
            latest_period = getattr(quotes[-1], "period_end", None)
            if latest_period is not None and (as_of - latest_period).days > 3:
                gaps.append("price_stale")

        if statements is None:
            gaps.append("fundamentals_stale")
        else:
            filing_date = getattr(statements, "filing_date", None)
            if filing_date is not None and (as_of - filing_date).days > 180:
                gaps.append("fundamentals_stale")

        if len(recent_news) == 0:
            gaps.append("no_news_90d")

        # TA features (BC-1 deterministic; DEFER-S43b-5 — quant material)
        ta_features: dict[str, object] = {}
        ta_audit: dict[str, str] = {}
        if quotes:
            try:
                feats = compute_ta_features(quotes)
                ta_features = feats.to_dict()
                ta_audit = dict(feats.audit)
            except Exception as exc:
                log.warning("TA feature compute failed for %s: %s", ticker.symbol, exc)
        if not ta_features:
            gaps.append("ta_insufficient")

        data_md5 = _md5_of_context(quotes, statements, recent_claims)

        return SharedContext(
            ticker=ticker,
            as_of=as_of,
            quotes=quotes,
            statements=statements,
            ratios_ttm=ratios_ttm,
            peer_comparables=[],  # Phase 3: peer service integration
            percentiles={},       # Phase 3: 5yr percentile compute
            recent_news=recent_news,
            recent_claims=recent_claims,
            ta_features=ta_features,
            ta_audit=ta_audit,
            gaps=gaps,
            data_snapshot_md5=data_md5,
        )
