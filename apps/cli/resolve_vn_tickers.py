"""CLI smoke harness for VN ticker resolution.

Resolves mention strings to canonical VN30 Ticker instances via VnTickerResolver.
Reads mentions from --from-stdin (one per line) or scans text snippets from
--from-text (comma-separated mention list for quick smoke testing).

Dumps per-mention JSON to stdout; summary stats to stderr.

Usage examples:
  echo "VHM\nvinhomes\nHoa Phat\nNotReal" | python -m apps.cli.resolve_vn_tickers --from-stdin

  python -m apps.cli.resolve_vn_tickers \\
    --from-text "VHM,vinhomes,Vingroup,Hoa Phat,Techcombank,fpt,NotARealTicker"

Source: plan-032-S370-phase-e4-vn-ticker-resolver.md § D5 + ADR D-073.

D-059 compliance: no datetime.now() / RNG / time.time() in domain path.
I-S1 compliance: VnTickerResolver is LLM-free; no LLM calls in this CLI.
Charter Principle 7 (Dogfood mandate): used at S371 STEP 0.8 for >=5 real
  VN news mention strings from the VN30 universe.
"""

from __future__ import annotations

import json
import sys

import click

from apps._shared.entities.vn_ticker_resolver import ResolutionMethod, VnTickerResolver


def _resolve_and_format(
    resolver: VnTickerResolver, mention: str
) -> dict[str, str | float | list[str] | None]:
    """Resolve a single mention and return JSON-serializable dict."""
    result = resolver.resolve(mention)
    canonical: str | None = result.canonical_ticker.symbol if result.canonical_ticker else None
    candidates: list[str] = (
        [t.symbol for t in result.candidates] if result.candidates else []
    )
    return {
        "mention": mention,
        "resolution_method": str(result.resolution_method),
        "resolution_confidence": result.resolution_confidence,
        "canonical_ticker": canonical,
        "matched_alias": result.matched_alias,
        "candidates": candidates,
        "alias_table_version": result.alias_table_version,
    }


@click.command("resolve-vn-tickers")
@click.option(
    "--from-stdin",
    "use_stdin",
    is_flag=True,
    default=False,
    help="Read mention strings from stdin (one per line).",
)
@click.option(
    "--from-text",
    "inline_text",
    default=None,
    help="Comma-separated list of mention strings for quick smoke testing.",
)
@click.option(
    "--compact",
    is_flag=True,
    default=False,
    help="Emit compact JSON (one object per line) instead of pretty-printed.",
)
def main(
    use_stdin: bool,
    inline_text: str | None,
    compact: bool,
) -> None:
    """Resolve Vietnamese ticker mentions to canonical VN30 Ticker symbols.

    Each mention is resolved via VnTickerResolver (alias table + difflib fuzzy).
    Results are emitted as JSON objects to stdout. Summary stats go to stderr.

    Resolution methods: EXACT | CASE_INSENSITIVE | DIACRITICS_STRIPPED |
    FUZZY | AMBIGUOUS | UNKNOWN.
    """
    if not use_stdin and inline_text is None:
        raise click.ClickException(
            "Provide either --from-stdin or --from-text <mentions>"
        )

    # Load resolver (raises FileNotFoundError if alias table missing)
    resolver = VnTickerResolver()
    click.echo(
        f"[resolve-vn-tickers] Alias table version: {resolver.alias_table_version}",
        err=True,
    )

    # Collect mentions
    mentions: list[str] = []
    if use_stdin:
        for line in sys.stdin:
            stripped = line.strip()
            if stripped:
                mentions.append(stripped)
    elif inline_text:
        mentions = [m.strip() for m in inline_text.split(",") if m.strip()]

    if not mentions:
        raise click.ClickException("No mention strings to resolve.")

    # Resolve each mention
    counts: dict[str, int] = {method.value: 0 for method in ResolutionMethod}
    rows: list[dict[str, str | float | list[str] | None]] = []

    for mention in mentions:
        row = _resolve_and_format(resolver, mention)
        rows.append(row)
        method_key_raw = row["resolution_method"]
        if isinstance(method_key_raw, str) and method_key_raw in counts:
            counts[method_key_raw] += 1

    # Output JSON results to stdout
    indent = None if compact else 2
    for row in rows:
        # ensure_ascii=True: safe for all terminal encodings (Windows cp1252 compatible).
        # Vietnamese characters are JSON-escaped as \uXXXX sequences.
        click.echo(json.dumps(row, ensure_ascii=True, indent=indent))

    # Summary stats to stderr
    total = len(rows)
    resolved = sum(
        1 for r in rows
        if r["resolution_method"] not in {
            ResolutionMethod.UNKNOWN.value,
            ResolutionMethod.AMBIGUOUS.value,
        }
    )
    click.echo("", err=True)
    click.echo("[resolve-vn-tickers] SUMMARY", err=True)
    click.echo(f"  Total mentions   : {total}", err=True)
    click.echo(f"  Resolved         : {resolved}/{total}", err=True)
    for method in ResolutionMethod:
        count = counts.get(method.value, 0)
        if count > 0:
            click.echo(f"  {method.value:<22}: {count}", err=True)
    click.echo(f"  Alias table ver  : {resolver.alias_table_version}", err=True)


if __name__ == "__main__":
    main()
