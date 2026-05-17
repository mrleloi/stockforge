"""CLI harness for VN claim extraction with lexicon scoring + cultural anchors.

Reads Vietnamese financial news articles from HTML directory and runs the full
ClaudeLlmExtractor pipeline with optional VnTokenizer + VnSentimentLexicon DI.
Outputs per-claim JSON including lexicon_score + mentioned_pump_anchors fields.

This is the integration smoke harness for plan-031 D5 (S368).

Usage examples:
  # Stub transport (no live claude CLI required; CI-friendly):
  python -m apps.cli.extract_vn_claims \\
    --input-html-dir data/raw/news/vietstock/2026-05-16/ \\
    --limit 3 \\
    --output /tmp/extract-smoke.json \\
    --summary \\
    --stub-transport

  # Live transport (requires claude CLI on PATH):
  python -m apps.cli.extract_vn_claims \\
    --input-html-dir data/raw/news/cafef/2026-05-16/ \\
    --limit 5 \\
    --output /tmp/cafef-claims.json \\
    --summary \\
    --use-lexicon

  # Disable lexicon (backward-compat mode; mirrors pre-E.3 behavior):
  python -m apps.cli.extract_vn_claims \\
    --input-html-dir data/raw/news/ \\
    --limit 10 \\
    --output /tmp/claims.json \\
    --summary \\
    --no-lexicon \\
    --stub-transport

Source: agent-workspace/session-plans/pending/031-S367-phase-e3-claim-extraction-wrapper.md
        § D5 (CLI smoke + integration harness; plan-031 D5 deliverable).

D-059 compliance: no datetime.now() / RNG in domain; clock injected via ClaudeLlmExtractor.
I-S1 compliance: lexicon_score / mentioned_pump_anchors computed deterministically; no LLM math.
Rule 16 mode-2: lexicon_score is deterministic echo from VnSentimentLexicon; CLI reports it as
  SIGNAL not RECOMMENDATION (I-S35).
I-S34 HARD REJECT: no patchright/playwright_stealth/fake-useragent deps; claude CLI subprocess
  is local not an HTTP fetcher.
"""

from __future__ import annotations

import html as html_mod
import json
import logging
import re
import statistics
from collections import Counter
from datetime import UTC, datetime
from pathlib import Path

import click

from apps.extraction.sentiment.vn_lexicon import (
    VN_CULTURAL_ANCHORS,
    VN_SENTIMENT_LEXICON_VERSION,
    VnSentimentLexicon,
)
from packages.contracts import Ticker
from packages.domain.news.models import NewsArticle
from packages.infrastructure.news import ClaudeLlmExtractor
from packages.infrastructure.news.claude_cli_news_transport import (
    make_claude_cli_news_transport,
)
from packages.infrastructure.nlp.vn_tokenizer import VnTokenizer

logging.basicConfig(level=logging.WARNING)
_log = logging.getLogger(__name__)

_TAG_RE = re.compile(r"<[^>]+>")
_WHITESPACE_RE = re.compile(r"\s+")

# Maximum characters to use as body_excerpt (matches ExtractedClaim _MAX_EXCERPT_CHARS
# but we pass more context to the LLM; excerpt is truncated inside _build_claim)
_MAX_BODY_CHARS = 50_000

# Stub response for --stub-transport mode; always returns 1 synthetic claim
_STUB_TRANSPORT_RESPONSE = json.dumps(
    {
        "claims": [
            {
                "claim_text": "[STUB] Synthetic claim for integration smoke",
                "source_text_excerpt": "Stub excerpt for CI smoke test",
                "sentiment": "neutral",
                "mentioned_tickers": ["VHM"],
                "mentioned_sectors": [],
                "key_phrases": ["stub"],
                "tone_indicators": [],
                "confidence": 0.5,
            }
        ]
    }
)


def _extract_body_text(html_path: Path) -> str:
    """Extract body text from an HTML file.

    Strips tags; unescapes HTML entities; normalizes whitespace.
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


def _build_article_from_html(html_path: Path, article_idx: int) -> NewsArticle:
    """Build a synthetic NewsArticle from an HTML file for smoke testing."""
    body_excerpt = _extract_body_text(html_path)
    stem = html_path.stem[:100]  # cap for article_id
    now = datetime.now(UTC)
    return NewsArticle(
        article_id=f"smoke-{article_idx}-{stem}",
        source=html_path.parent.name,
        source_url=f"file://{html_path}",
        title=stem,
        body_excerpt=body_excerpt[:5000],  # reasonable limit for LLM context
        published_at=now,
        ingested_at=now,
        mentioned_tickers=(Ticker("VHM"),),  # synthetic; LLM will override
    )


@click.command("extract-vn-claims")
@click.option(
    "--input-html-dir",
    "input_html_dir",
    required=True,
    type=click.Path(exists=True, file_okay=False, dir_okay=True, path_type=Path),
    help="Directory containing .html article files (recursive search).",
)
@click.option(
    "--limit",
    default=5,
    show_default=True,
    help="Maximum number of articles to process.",
)
@click.option(
    "--output",
    "output_path",
    required=True,
    type=click.Path(dir_okay=False, writable=True, path_type=Path),
    help="Path for JSON output report (per-claim rows).",
)
@click.option(
    "--summary",
    "print_summary",
    is_flag=True,
    default=False,
    help="Print per-article and aggregate summary to stdout.",
)
@click.option(
    "--use-lexicon/--no-lexicon",
    "use_lexicon",
    default=True,
    show_default=True,
    help="Enable VnSentimentLexicon DI for lexicon_score + mentioned_pump_anchors (default: on).",
)
@click.option(
    "--stub-transport",
    "stub_transport",
    is_flag=True,
    default=False,
    help=(
        "Use deterministic stub transport instead of live claude CLI. "
        "CI-friendly; always returns 1 synthetic claim per article."
    ),
)
def main(
    input_html_dir: Path,
    limit: int,
    output_path: Path,
    print_summary: bool,
    use_lexicon: bool,
    stub_transport: bool,
) -> None:
    """Extract VN claims from HTML articles using ClaudeLlmExtractor.

    Runs the full pipeline with optional VnTokenizer + VnSentimentLexicon DI.
    Emits per-claim JSON rows with lexicon_score + mentioned_pump_anchors fields.

    Integration smoke for plan-031 D5 (Phase E.3).
    """
    # Wire up DI
    tokenizer = VnTokenizer()
    lexicon = VnSentimentLexicon(tokenizer=tokenizer) if use_lexicon else None

    if stub_transport:
        transport_fn = lambda _sys, _body: _STUB_TRANSPORT_RESPONSE  # noqa: E731
        transport_label = "stub"
    else:
        transport_fn = make_claude_cli_news_transport()
        transport_label = "claude-cli"

    extractor = ClaudeLlmExtractor(
        transport=transport_fn,
        tokenizer=tokenizer,
        lexicon=lexicon,
    )

    lexicon_version = VN_SENTIMENT_LEXICON_VERSION if use_lexicon else "DISABLED"
    cultural_anchor_count = len(VN_CULTURAL_ANCHORS)

    if print_summary:
        click.echo(
            f"extract-vn-claims: transport={transport_label} "
            f"tokenizer={tokenizer.selected_library} "
            f"lexicon_version={lexicon_version} "
            f"cultural_anchors={cultural_anchor_count}"
        )

    # Collect HTML files
    html_files = _collect_html_files(input_html_dir, limit)
    if not html_files:
        click.echo(
            f"WARNING: no .html files found under {input_html_dir}",
            err=True,
        )
        output_path.write_text("[]", encoding="utf-8")
        return

    if print_summary:
        click.echo(f"Found {len(html_files)} HTML files (limit={limit})")

    # Process articles
    all_claims: list[dict[str, object]] = []
    article_claim_counts: list[int] = []
    lexicon_scores: list[float] = []
    all_mentioned_anchors: list[str] = []
    sentiment_counts: Counter[str] = Counter()

    for idx, html_path in enumerate(html_files):
        article = _build_article_from_html(html_path, idx)
        claims = extractor.extract(article)
        article_claim_counts.append(len(claims))

        if print_summary:
            click.echo(
                f"  [{idx + 1}/{len(html_files)}] {html_path.name}: "
                f"{len(claims)} claims"
            )

        for claim in claims:
            lexicon_scores.append(claim.lexicon_score)
            all_mentioned_anchors.extend(claim.mentioned_pump_anchors)
            sentiment_counts[claim.sentiment.value] += 1
            all_claims.append(
                {
                    "article_id": claim.article_id,
                    "claim_id": claim.claim_id,
                    "claim_text": claim.claim_text,
                    "sentiment": claim.sentiment.value,
                    "lexicon_score": claim.lexicon_score,
                    "mentioned_pump_anchors": list(claim.mentioned_pump_anchors),
                    "mentioned_tickers": [t.symbol for t in claim.mentioned_tickers],
                    "source_text_excerpt": claim.source_text_excerpt[:200],
                }
            )

    # Write JSON output
    output_path.write_text(
        json.dumps(all_claims, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    if print_summary:
        total_articles = len(html_files)
        total_claims = len(all_claims)
        click.echo("\n--- SUMMARY ---")
        click.echo(f"Articles processed: {total_articles}")
        click.echo(f"Total claims extracted: {total_claims}")
        click.echo(
            f"Claims/article: "
            f"min={min(article_claim_counts) if article_claim_counts else 0} "
            f"max={max(article_claim_counts) if article_claim_counts else 0}"
        )
        if lexicon_scores:
            click.echo(
                f"lexicon_score: "
                f"min={min(lexicon_scores):.4f} "
                f"max={max(lexicon_scores):.4f} "
                f"mean={statistics.mean(lexicon_scores):.4f}"
            )
            nonzero = [s for s in lexicon_scores if s != 0.0]
            click.echo(
                f"  non-zero scores: {len(nonzero)}/{len(lexicon_scores)} "
                f"({100 * len(nonzero) / max(1, len(lexicon_scores)):.1f}%)"
            )
        else:
            click.echo("lexicon_score: N/A (no claims extracted)")
        if all_mentioned_anchors:
            anchor_counts = Counter(all_mentioned_anchors)
            click.echo(f"mentioned_pump_anchors: {dict(anchor_counts)}")
        else:
            click.echo("mentioned_pump_anchors: none detected")
        if sentiment_counts:
            click.echo(f"Sentiment distribution: {dict(sentiment_counts)}")
        click.echo(f"Output written to: {output_path}")


if __name__ == "__main__":
    main()
