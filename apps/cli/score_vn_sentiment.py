"""CLI harness for VN sentiment lexicon scoring.

Reads VN financial news articles from HTML directory (or SQLite DB) and
scores each body using VnSentimentLexicon + VnTokenizer. Outputs a JSON
report per article and prints a summary with category distribution.

Usage examples:
  python -m apps.cli.score_vn_sentiment \\
    --input-html-dir data/raw/news/vietstock/2026-05-16/ \\
    --limit 5 \\
    --output /tmp/score-smoke.json \\
    --summary

  python -m apps.cli.score_vn_sentiment \\
    --input-html-dir data/raw/news/ \\
    --limit 10 \\
    --output /tmp/all-sources.json \\
    --summary

Source: agent-workspace/session-plans/pending/030-S364-phase-e2-vn-sentiment-lexicon.md
        § D5 (CLI smoke + integration harness).

D-059 compliance: no datetime.now() / RNG / time.time() in domain path;
  this CLI is infrastructure-tier orchestration only.
I-S1 compliance: VnSentimentLexicon is LLM-free; this CLI makes no LLM calls.
Rule 16 mode-2: numeric_score is deterministic-pipeline echo from lexicon;
  this CLI reads + reports it but does not interpret it as a recommendation.
I-S35 compliance: scores are SIGNALS not RECOMMENDATIONS; CLI reports raw
  numeric_score + category; no "buy/sell" output.
"""

from __future__ import annotations

import html as html_mod
import json
import logging
import re
import time
from collections import Counter
from pathlib import Path

import click

from apps.extraction.sentiment.vn_lexicon import (
    VN_SENTIMENT_LEXICON_VERSION,
    VnSentimentLexicon,
)
from packages.infrastructure.nlp.vn_tokenizer import VnTokenizer, WhitespaceTokenizer

logging.basicConfig(level=logging.WARNING)
_log = logging.getLogger(__name__)

_TAG_RE = re.compile(r"<[^>]+>")
_WHITESPACE_RE = re.compile(r"\s+")

# Maximum characters to score per article (cap for perf)
_MAX_BODY_CHARS = 50_000


def _extract_body_text(html_path: Path) -> str:
    """Extract body text from an HTML file.

    Strips tags; unescapes HTML entities; normalizes whitespace.
    Mirrors tokenize_vn_text.py _extract_body_text for consistency.
    """
    content = html_path.read_text(encoding="utf-8", errors="replace")
    text = _TAG_RE.sub(" ", content)
    text = html_mod.unescape(text)
    text = _WHITESPACE_RE.sub(" ", text).strip()
    return text[:_MAX_BODY_CHARS]


def _collect_html_files(html_dir: Path, limit: int) -> list[Path]:
    """Collect up to ``limit`` .html files from ``html_dir`` (recursive)."""
    files: list[Path] = []
    for path in sorted(html_dir.rglob("*.html")):
        files.append(path)
        if len(files) >= limit:
            break
    return files


@click.command("score-vn-sentiment")
@click.option(
    "--input-html-dir",
    "input_html_dir",
    required=True,
    type=click.Path(exists=True, file_okay=False, dir_okay=True, path_type=Path),
    help="Directory containing .html article files (recursive search).",
)
@click.option(
    "--limit",
    default=10,
    show_default=True,
    help="Maximum number of articles to process.",
)
@click.option(
    "--output",
    "output_path",
    required=True,
    type=click.Path(dir_okay=False, writable=True, path_type=Path),
    help="Path for JSON output report.",
)
@click.option(
    "--summary",
    "print_summary",
    is_flag=True,
    default=False,
    help="Print per-article and aggregate summary to stdout.",
)
@click.option(
    "--use-whitespace-baseline",
    is_flag=True,
    default=False,
    help="Use WhitespaceTokenizer instead of VnTokenizer (for comparison).",
)
def main(
    input_html_dir: Path,
    limit: int,
    output_path: Path,
    print_summary: bool,
    use_whitespace_baseline: bool,
) -> None:
    """Score VN financial news articles for sentiment polarity.

    Reads articles from INPUT_HTML_DIR, scores using VnSentimentLexicon
    (VnTokenizer backend or WhitespaceTokenizer fallback), writes JSON report
    to OUTPUT.

    Output per article: article_id, numeric_score, category, keyword_hits,
    coverage_ratio, lib_used, lexicon_version.

    NOTE: Scores are SIGNALS not recommendations (I-S35 compliance).
    """
    if use_whitespace_baseline:
        tokenizer: VnTokenizer | WhitespaceTokenizer = WhitespaceTokenizer()
        lib_label = "whitespace-baseline-v0"
    else:
        tokenizer = VnTokenizer()
        lib_label = "pyvi==0.1.1"

    lexicon = VnSentimentLexicon(tokenizer=tokenizer)

    html_files = _collect_html_files(input_html_dir, limit)
    if not html_files:
        raise click.ClickException(
            f"No .html files found under {input_html_dir}"
        )

    rows: list[dict[str, object]] = []
    category_counts: Counter[str] = Counter()
    total_numeric = 0.0
    total_coverage = 0.0
    total_ms = 0.0

    for idx, html_path in enumerate(html_files):
        body = _extract_body_text(html_path)
        if not body:
            _log.warning("Empty body extracted from %s; skipping", html_path)
            continue

        t0 = time.monotonic()
        score = lexicon.score(body)
        elapsed_ms = (time.monotonic() - t0) * 1000

        total_numeric += score.numeric_score
        total_coverage += score.coverage_ratio
        total_ms += elapsed_ms
        category_counts[score.category.value] += 1

        row: dict[str, object] = {
            "article_id": html_path.stem,
            "source_file": str(html_path),
            "numeric_score": round(score.numeric_score, 4),
            "category": score.category.value,
            "keyword_hits": list(score.keyword_hits),
            "coverage_ratio": round(score.coverage_ratio, 4),
            "lib_used": lib_label,
            "lexicon_version": lexicon.lexicon_version,
            "perf_ms": round(elapsed_ms, 2),
        }
        rows.append(row)

        if print_summary:
            click.echo(
                f"[{idx + 1}/{len(html_files)}] {html_path.name}: "
                f"score={score.numeric_score:.4f} "
                f"category={score.category.value} "
                f"hits={len(score.keyword_hits)} "
                f"coverage={score.coverage_ratio:.3f} "
                f"({elapsed_ms:.1f}ms)"
            )

    # Write JSON report
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        json.dumps(rows, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    if print_summary:
        n = len(rows)
        avg_numeric = total_numeric / max(n, 1)
        avg_coverage = total_coverage / max(n, 1)
        avg_ms = total_ms / max(n, 1)
        click.echo(
            f"\n[score-vn-sentiment] SUMMARY"
            f"\n  Articles processed : {n}"
            f"\n  Avg numeric_score  : {avg_numeric:.4f}"
            f"\n  Avg coverage_ratio : {avg_coverage:.4f}"
            f"\n  Avg perf ms/article: {avg_ms:.1f}"
            f"\n  Category distribution:"
        )
        for cat, count in sorted(
            category_counts.items(), key=lambda x: -x[1]
        ):
            click.echo(f"    {cat:<25}: {count}")
        click.echo(
            f"  Library used       : {lib_label}"
            f"\n  Lexicon version    : {VN_SENTIMENT_LEXICON_VERSION}"
            f"\n  Output written to  : {output_path}"
        )


if __name__ == "__main__":
    main()
