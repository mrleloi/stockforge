"""Backtest CLI for PumpPhaseClassifier — BR-5 holdout gate (BC-7).

REQUIRED at S53 close per D-032 § (i) BR-5 gate:
  python -m apps.cli.backtest_pump_classifier --holdout-split=0.3
  Exits 0 if precision > 0.5 AND recall > 0.3.
  Exits 1 with error message if gate fails.

I-S1: NO LLM math. All precision/recall computed in Python from labeled data.
Precision/recall computed deterministically from LabeledPump holdout set.

Usage:
  python -m apps.cli.backtest_pump_classifier [--db-path PATH] [--holdout-split FLOAT]
  python -m apps.cli.backtest_pump_classifier --from-json eval-sets/labeled-pumps/

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.7 + § B.8.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § i).
"""

from __future__ import annotations

import json
import sys
from datetime import UTC, datetime
from pathlib import Path

import click

from packages.domain.crowd.labeled_pump import LabeledPump
from packages.domain.crowd.services.pump_phase_classifier import (
    PumpPhaseClassifier,
    TickerSignals,
)
from packages.domain.crowd.value_objects.pump_phase import PumpPhase
from packages.infrastructure.crowd.sqlite_labeled_pump_repository import SqliteLabeledPumpRepository

# BR-5 gate thresholds (verbatim from D-032 § i)
_PRECISION_THRESHOLD = 0.5
_RECALL_THRESHOLD = 0.3


def _load_from_json_dir(json_dir: Path) -> list[LabeledPump]:
    """Load LabeledPump records from eval-sets/labeled-pumps/ JSON files."""
    pumps: list[LabeledPump] = []
    for json_file in sorted(json_dir.glob("*.json")):
        try:
            data = json.loads(json_file.read_text(encoding="utf-8"))
            pump = LabeledPump(
                ticker=data["ticker"],
                period_start=datetime.fromisoformat(data["period_start"]).replace(tzinfo=UTC),
                period_end=datetime.fromisoformat(data["period_end"]).replace(tzinfo=UTC),
                phases=tuple(data["phases"]),
                features_at_detection=data["features_at_detection"],
                subsequent_outcome=data.get("subsequent_outcome"),
                labeled_by=data["labeled_by"],
            )
            pumps.append(pump)
        except (KeyError, ValueError) as e:
            click.echo(f"Warning: skipping {json_file.name}: {e}", err=True)
    return pumps


def _signals_from_labeled(pump: LabeledPump) -> TickerSignals:
    """Build TickerSignals from LabeledPump.features_at_detection.

    Converts string feature values to typed Python types.
    I-S1: pure Python conversion; no LLM.
    """
    f = pump.features_at_detection

    def fbool(key: str, default: bool = False) -> bool:
        v = str(f.get(key, str(default))).lower()
        return v == "true"

    def ffloat(key: str, default: float = 0.0) -> float:
        try:
            return float(str(f.get(key, default)))
        except (ValueError, TypeError):
            return default

    return TickerSignals(
        price_change_30d=ffloat("price_change_30d"),
        price_5d_change=ffloat("price_5d_change"),
        volume_30d_avg_rising=fbool("volume_30d_avg_rising"),
        volume_5d_avg_declining=fbool("volume_5d_avg_declining"),
        volume_5d_avg=ffloat("volume_5d_avg"),
        volume_30d_avg=ffloat("volume_30d_avg"),
        t2_news_silent=fbool("t2_news_silent"),
        t3_kol_mentions_rising=fbool("t3_kol_mentions_rising"),
        t3_kol_mentions_peak=fbool("t3_kol_mentions_peak"),
        t4_novice_post_share=ffloat("t4_novice_post_share"),
        t4_coordination_score=ffloat("t4_coordination_score"),
        historical_similar_cases_count=0,  # no analog finder at backtest time
    )


def _label_to_phase(phases: tuple[str, ...]) -> PumpPhase:
    """Extract the dominant/peak phase from labeled phases list.

    Priority: pump > distribution > dump > pre_pump > uncertain.
    I-S1: pure Python lookup; no LLM.
    """
    phase_set = set(phases)
    priority = [
        ("pump", PumpPhase.PUMP),
        ("distribution", PumpPhase.DISTRIBUTION),
        ("dump", PumpPhase.DUMP),
        ("pre_pump", PumpPhase.PRE_PUMP),
    ]
    for phase_str, phase_enum in priority:
        if phase_str in phase_set:
            return phase_enum
    return PumpPhase.UNCERTAIN


def _compute_precision_recall(
    predictions: list[PumpPhase],
    actuals: list[PumpPhase],
) -> tuple[float, float]:
    """Compute precision and recall for non-UNCERTAIN predictions.

    Precision: of predicted non-UNCERTAIN phases, what fraction matched actual?
    Recall: of actual non-UNCERTAIN phases, what fraction did we predict correctly?

    I-S1: pure Python arithmetic; no LLM.
    """
    true_positives = 0
    false_positives = 0
    false_negatives = 0

    for pred, actual in zip(predictions, actuals, strict=False):
        if pred is PumpPhase.UNCERTAIN:
            if actual is not PumpPhase.UNCERTAIN:
                false_negatives += 1
            continue

        if pred == actual:
            true_positives += 1
        else:
            false_positives += 1
            if actual is not PumpPhase.UNCERTAIN:
                false_negatives += 1

    precision = (
        true_positives / (true_positives + false_positives)
        if (true_positives + false_positives) > 0
        else 0.0
    )
    recall = (
        true_positives / (true_positives + false_negatives)
        if (true_positives + false_negatives) > 0
        else 0.0
    )
    return precision, recall


@click.command()
@click.option(
    "--db-path",
    default=":memory:",
    help="SQLite DB path (default: :memory: for JSON-only mode)",
)
@click.option(
    "--holdout-split",
    default=0.3,
    type=float,
    show_default=True,
    help="Fraction of data for holdout (default 0.3 = 30%)",
)
@click.option(
    "--from-json",
    default="eval-sets/labeled-pumps",
    help="Directory containing labeled-pump JSON files",
    type=click.Path(exists=False),
)
def main(db_path: str, holdout_split: float, from_json: str) -> None:
    """Run PumpPhaseClassifier backtest against labeled holdout set.

    BR-5 gate: precision > 0.5 AND recall > 0.3.
    Exits 0 on PASS, 1 on FAIL.
    """
    click.echo("Backtest: PumpPhaseClassifier — BR-5 holdout gate")

    # Load labeled pumps
    json_dir = Path(from_json)
    if json_dir.exists() and json_dir.is_dir():
        all_pumps = _load_from_json_dir(json_dir)
        click.echo(f"Loaded {len(all_pumps)} labeled pumps from {json_dir}")
    else:
        # Fallback to SQLite repo
        repo = SqliteLabeledPumpRepository(db_path=db_path)
        all_pumps = repo.get_all()
        click.echo(f"Loaded {len(all_pumps)} labeled pumps from SQLite {db_path}")

    if len(all_pumps) < 3:
        click.echo(
            f"Error: BR-5 gate requires at least 3 labeled pump entries; got {len(all_pumps)}.",
            err=True,
        )
        click.echo("Seed eval-sets/labeled-pumps/ with at least 3 manually-labeled pump events.")
        sys.exit(1)

    # 70/30 split
    holdout_count = max(1, int(len(all_pumps) * holdout_split))
    holdout = all_pumps[-holdout_count:]
    click.echo(f"Holdout set: {len(holdout)}/{len(all_pumps)} labeled pumps (split={holdout_split:.0%})")

    # Run classifier on holdout
    classifier = PumpPhaseClassifier()
    predictions: list[PumpPhase] = []
    actuals: list[PumpPhase] = []

    for pump in holdout:
        signals = _signals_from_labeled(pump)
        actual_phase = _label_to_phase(pump.phases)
        pred_phase, confidence, _ = classifier.classify(signals)
        predictions.append(pred_phase)
        actuals.append(actual_phase)
        click.echo(
            f"  {pump.ticker} {pump.period_start.date()} "
            f"actual={actual_phase.value} pred={pred_phase.value} conf={confidence:.2f}"
        )

    # Compute metrics (I-S1: Python arithmetic)
    precision, recall = _compute_precision_recall(predictions, actuals)

    click.echo("\nResults:")
    click.echo(f"  Precision: {precision:.3f} (threshold: >{_PRECISION_THRESHOLD})")
    click.echo(f"  Recall:    {recall:.3f} (threshold: >{_RECALL_THRESHOLD})")

    # BR-5 gate
    precision_pass = precision > _PRECISION_THRESHOLD
    recall_pass = recall > _RECALL_THRESHOLD

    if precision_pass and recall_pass:
        click.echo("\nBR-5 GATE: PASS")
        click.echo("PumpPhaseClassifier meets precision + recall requirements for live deploy.")
        sys.exit(0)
    else:
        click.echo("\nBR-5 GATE: FAIL", err=True)
        if not precision_pass:
            click.echo(f"  FAIL: precision {precision:.3f} <= {_PRECISION_THRESHOLD}", err=True)
        if not recall_pass:
            click.echo(f"  FAIL: recall {recall:.3f} <= {_RECALL_THRESHOLD}", err=True)
        click.echo("Per D-032 § Rollback path: pump live-deploy deferred to S54.", err=True)
        sys.exit(1)


if __name__ == "__main__":
    main()
