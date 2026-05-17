"""CLI harness for VN text tokenization.

Reads VN financial news articles from an HTML directory and tokenizes each
body using VnTokenizer (pyvi backend). Outputs a JSON report per article
and prints a summary with perf metrics.

Usage examples:
  python -m apps.cli.tokenize_vn_text \\
    --input-html-dir data/raw/news/vietstock/2026-05-16/ \\
    --limit 5 \\
    --output /tmp/tokenize-smoke.json \\
    --summary

  python -m apps.cli.tokenize_vn_text \\
    --input-html-dir data/raw/news/ \\
    --limit 10 \\
    --output /tmp/all-sources.json

Source: agent-workspace/session-plans/pending/029-S361-phase-e1-vn-tokenization.md
        § D4 (CLI smoke + integration harness).

D-059 compliance: no datetime.now() / RNG / time.time() in domain path;
  this CLI is infrastructure-tier orchestration only.
I-S1 compliance: VnTokenizer is LLM-free; this CLI makes no LLM calls.
"""

from __future__ import annotations

import html as html_mod
import json
import logging
import re
import time
from pathlib import Path

import click

from packages.infrastructure.nlp.vn_tokenizer import VnTokenizer, WhitespaceTokenizer

logging.basicConfig(level=logging.WARNING)
_log = logging.getLogger(__name__)

_TAG_RE = re.compile(r"<[^>]+>")
_WHITESPACE_RE = re.compile(r"\s+")

# Maximum characters to tokenize per article (cap for perf)
_MAX_BODY_CHARS = 50_000


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


@click.command("tokenize-vn-text")
@click.option(
    "--input-html-dir",
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
    """Tokenize VN financial news articles from HTML files.

    Reads articles from INPUT_HTML_DIR, tokenizes using the selected
    VN tokenizer, writes JSON report to OUTPUT.
    """
    if use_whitespace_baseline:
        tokenizer: VnTokenizer | WhitespaceTokenizer = WhitespaceTokenizer()
        lib_label = "whitespace-baseline-v0"
    else:
        tokenizer = VnTokenizer()
        lib_label = "pyvi==0.1.1"

    html_files = _collect_html_files(input_html_dir, limit)
    if not html_files:
        raise click.ClickException(
            f"No .html files found under {input_html_dir}"
        )

    rows: list[dict[str, object]] = []
    total_token_count = 0
    total_ms = 0.0

    for idx, html_path in enumerate(html_files):
        body = _extract_body_text(html_path)
        if not body:
            _log.warning("Empty body extracted from %s; skipping", html_path)
            continue

        t0 = time.monotonic()
        tokens = tokenizer.tokenize(body)
        elapsed_ms = (time.monotonic() - t0) * 1000

        total_token_count += len(tokens)
        total_ms += elapsed_ms

        row: dict[str, object] = {
            "article_id": html_path.stem,
            "source_file": str(html_path),
            "token_count": len(tokens),
            "sample_tokens": tokens[:50],
            "lib_used": lib_label,
            "perf_ms": round(elapsed_ms, 2),
        }
        rows.append(row)

        if print_summary:
            click.echo(
                f"[{idx + 1}/{len(html_files)}] {html_path.name}: "
                f"{len(tokens)} tokens in {elapsed_ms:.1f}ms"
            )

    # Write JSON report
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        json.dumps(rows, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    if print_summary:
        n = len(rows)
        avg_tokens = total_token_count // max(n, 1)
        avg_ms = total_ms / max(n, 1)
        click.echo(
            f"\n[tokenize-vn-text] SUMMARY"
            f"\n  Articles processed : {n}"
            f"\n  Total tokens       : {total_token_count}"
            f"\n  Avg tokens/article : {avg_tokens}"
            f"\n  Avg perf ms/article: {avg_ms:.1f}"
            f"\n  Library used       : {lib_label}"
            f"\n  Output written to  : {output_path}"
        )


if __name__ == "__main__":
    main()
