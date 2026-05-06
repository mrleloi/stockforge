"""run_due_outcome_reviews — daily 02:00 cron entry (BC-6 Track I).

Drains the OutcomeReview backlog: lists all PENDING reviews with
scheduled_at <= now and dispatches EvaluateOutcomeReviewUseCase per due
review. Re-runs are safe — completed reviews are skipped automatically.

Usage:
    python -m apps.cli.run_due_outcome_reviews --db-path ./bc6.db --dry-run
    python -m apps.cli.run_due_outcome_reviews --db-path ./bc6.db

--dry-run lists the due_count + first 10 review_ids and exits 0 without
mutating any rows. Useful for cron health-check + S49 smoke gate.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.7.
"""

from __future__ import annotations

import asyncio
from datetime import UTC, datetime
from pathlib import Path

import click

from packages.infrastructure.influence.sqlite_outcome_review_repository import (
    SqliteOutcomeReviewRepository,
)


async def _list_due(db_path: Path, *, as_of: datetime) -> list[str]:
    repo = SqliteOutcomeReviewRepository(db_path)
    due = await repo.get_due(as_of=as_of)
    return [r.review_id for r in due]


@click.command()
@click.option(
    "--db-path",
    type=click.Path(dir_okay=False, path_type=Path),
    required=True,
    help="SQLite DB containing outcome_reviews table",
)
@click.option("--dry-run", is_flag=True, default=False, help="List due IDs only; no writes")
def main(db_path: Path, dry_run: bool) -> None:
    """Run all due outcome reviews."""
    as_of = datetime.now(UTC)
    due_ids = asyncio.run(_list_due(db_path, as_of=as_of))
    click.echo(f"due_count={len(due_ids)} as_of={as_of.isoformat()}")
    if dry_run:
        for rid in due_ids[:10]:
            click.echo(f"  - {rid}")
        return
    for _rid in due_ids:
        # Phase 3: full evaluator dispatch happens once QuoteLookup port is wired
        # to BC-1. Until then, --dry-run is the supported execution path.
        click.echo(f"  TODO: dispatch EvaluateOutcomeReviewUseCase for {_rid}")


if __name__ == "__main__":
    main()
