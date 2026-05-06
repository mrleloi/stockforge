"""ingest_crowd_sentiment — CLI entry point for BC-7 crowd sentiment ingestion.

Usage:
    python -m apps.cli.ingest_crowd_sentiment --platform=f319 --ticker=VND --window=1H
    python -m apps.cli.ingest_crowd_sentiment --platform=all --ticker=HPG --window=4H --dry-run

Flags:
    --platform:  all | f319 | fb_group | comments
    --ticker:    VN ticker symbol (e.g. VND, HPG, FPT)
    --window:    1H | 4H | 1D | 1W
    --dry-run:   Run without persisting to database; logs snapshot to stdout

CLI smoke test:
    python -m apps.cli.ingest_crowd_sentiment --platform=f319 --ticker=VND --window=1H --dry-run

Exits 0 on success, non-zero on error.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.3 UC-1.
ADR: D-032 § (b) adapter pattern.
"""

from __future__ import annotations

import logging
import sys

import click

from packages.application.crowd.ports.coordination_detector_port import CoordinationFeature
from packages.application.crowd.use_cases.capture_sentiment_snapshot_use_case import (
    CaptureSentimentSnapshotUseCase,
    CoordinatedPostingDetectedEvent,
    SentimentSnapshotCapturedEvent,
)
from packages.domain.crowd.value_objects.window import Window

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)
logger = logging.getLogger("ingest_crowd_sentiment")


def _build_aggregator(platform: str) -> object:
    """Build the appropriate PostAggregatorPort concrete implementation."""
    if platform == "f319":
        from packages.infrastructure.crowd.aggregators.f319_forum_aggregator import (
            F319ForumAggregator,
        )
        return F319ForumAggregator()
    elif platform == "fb_group":
        from packages.infrastructure.crowd.aggregators.facebook_public_group_aggregator import (
            FacebookPublicGroupAggregator,
        )
        return FacebookPublicGroupAggregator()
    elif platform == "comments":
        from packages.infrastructure.crowd.aggregators.article_comments_aggregator import (
            ArticleCommentsAggregator,
        )
        return ArticleCommentsAggregator()
    else:
        raise ValueError(f"Unknown platform: {platform!r}")


class _DryRunRepo:
    """No-op repository for --dry-run mode."""

    def save(self, snapshot: object) -> None:
        logger.info("DRY-RUN: snapshot would be saved: %s", snapshot)

    def get_recent(self, ticker: str, window: object) -> list[object]:  # noqa: ARG002
        return []

    def find_by_id(self, snapshot_id: str) -> None:  # noqa: ARG002
        return None


class _DryRunClassifier:
    """Stub classifier for --dry-run: returns NEUTRAL for all posts."""

    def classify_batch(self, posts: list[object]) -> list[object]:
        from packages.application.crowd.ports.sentiment_classifier_port import ClassifiedPost
        from packages.domain.crowd.raw_post import RawPost
        from packages.domain.crowd.value_objects.sentiment import Sentiment

        result: list[object] = []
        for post in posts:
            if isinstance(post, RawPost):
                result.append(
                    ClassifiedPost(
                        post_id=post.post_id,
                        ticker=post.ticker,
                        source=post.source,
                        source_url=post.source_url,
                        posted_at=post.posted_at,
                        text=post.text,
                        poster_id=post.poster_id,
                        account_age_days=post.account_age_days,
                        sentiment=Sentiment.NEUTRAL,
                    )
                )
        return result


class _DryRunCoordinationDetector:
    """Stub detector for --dry-run: always returns 0.0."""

    def score(self, posts: list[object], features: list[CoordinationFeature]) -> float:  # noqa: ARG002
        return 0.0


@click.command()
@click.option(
    "--platform",
    type=click.Choice(["all", "f319", "fb_group", "comments"]),
    required=True,
    help="Platform to aggregate from.",
)
@click.option("--ticker", required=True, help="VN ticker symbol (e.g. VND, HPG).")
@click.option(
    "--window",
    type=click.Choice(["1H", "4H", "1D", "1W"]),
    default="1H",
    show_default=True,
    help="Aggregation window.",
)
@click.option(
    "--dry-run",
    is_flag=True,
    default=False,
    help="Run without persisting. Logs snapshot to stdout.",
)
def main(platform: str, ticker: str, window: str, dry_run: bool) -> None:
    """Ingest crowd sentiment for a ticker from specified platform.

    Research aid per I-S35. NOT financial advice.
    """
    win = Window(window)
    platforms = ["f319", "fb_group", "comments"] if platform == "all" else [platform]

    events: list[object] = []

    for plat in platforms:
        logger.info(
            "ingest_crowd_sentiment platform=%s ticker=%s window=%s dry_run=%s",
            plat,
            ticker,
            window,
            dry_run,
        )

        try:
            aggregator = _build_aggregator(plat)
        except ValueError as exc:
            logger.error("Unknown platform: %s", exc)
            sys.exit(1)

        if dry_run:
            classifier: object = _DryRunClassifier()
            detector: object = _DryRunCoordinationDetector()
            repo: object = _DryRunRepo()
        else:
            # Live mode: require real implementations (not wired Phase 3 — Phase 4)
            logger.warning(
                "Live mode not fully wired in Phase 3. "
                "Use --dry-run for smoke testing. Exiting."
            )
            sys.exit(1)

        uc = CaptureSentimentSnapshotUseCase(
            aggregator=aggregator,  # type: ignore[arg-type]
            classifier=classifier,  # type: ignore[arg-type]
            coordination_detector=detector,  # type: ignore[arg-type]
            snapshot_repo=repo,  # type: ignore[arg-type]
            publish_event=events.append,
        )

        snapshot = uc.execute(ticker, win)

        logger.info(
            "SNAPSHOT CAPTURED: ticker=%s window=%s mention_count=%d "
            "dominant_sentiment=%s coordination_score=%.3f",
            snapshot.ticker,
            snapshot.window.value,
            snapshot.mention_count,
            snapshot.dominant_sentiment().value,
            snapshot.coordinated_posting_score,
        )

    captured_count = sum(
        1 for e in events if isinstance(e, SentimentSnapshotCapturedEvent)
    )
    coord_count = sum(
        1 for e in events if isinstance(e, CoordinatedPostingDetectedEvent)
    )

    click.echo(
        f"Complete: {captured_count} snapshot(s) captured, "
        f"{coord_count} coordination alert(s). "
        f"Research aid only — not financial advice."
    )


if __name__ == "__main__":
    main()
