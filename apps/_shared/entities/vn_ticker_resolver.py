"""VnTickerResolver — Vietnamese ticker-entity resolver.

Resolves Vietnamese company-name mentions (e.g. "vinhomes", "Vinhomes",
"Công ty Cổ phần Vinhomes", "VHM") to canonical Ticker instances via a
hand-curated VN30 alias table and Python stdlib difflib fuzzy fallback.

Design decisions:
- DD-1: FRESH MODULE + ALIAS TABLE (plan-032 § D DD-1; parent plan-028 DD-6)
- DD-2: CONCRETE CLASS not Protocol (Karpathy P2 simplicity; no swap requirement
  for v0; Protocol-ification deferred per AP-23 first-instance HOLD)
- DD-3: MARKDOWN alias table as UL artifact (agent-workspace/ubiquitous-language/
  vn_ticker_aliases.md); parseable by domain experts without Python knowledge
- DD-4: Rule 16 MODE 2 satisfaction — resolution_confidence = difflib
  SequenceMatcher.ratio() (pure-function; deterministic; NO LLM in path)
- DD-6: AMBIGUOUS-explicit-surface — multi-candidate fuzzy matches surface ALL
  candidates without silent-pick; preserves I-S22 data lineage
- DD-8: difflib cutoff = 0.85 (architect default; empirically validated in
  test_vn_ticker_resolver.py TC6-TC17; revisit trigger in ADR D-073)

D-059 compliance:
- R1: NO datetime.now() call — alias_table_version is a static string literal
- R2: NO unseeded random / difflib is deterministic
- R4: NO time.time() in domain path

I-S1: NO LLM math — resolution is rule-based deterministic; LLM never invoked.
I-S22: ResolutionResult carries resolution_method + resolution_confidence +
  matched_alias + alias_table_version for full audit trail.
Rule 16 mode 2: resolution_confidence is deterministic-pipeline echo of
  SequenceMatcher.ratio(); never LLM-emitted.

Source: plan-032-S370-phase-e4-vn-ticker-resolver.md DD-1..DD-8 + ADR D-073.
"""

from __future__ import annotations

import difflib
import re
import unicodedata
from dataclasses import dataclass, field
from enum import StrEnum
from pathlib import Path

from packages.contracts.types.ticker import InvalidTickerError, Ticker

__all__ = [
    "ResolutionMethod",
    "ResolutionResult",
    "VnTickerResolver",
    "_MIN_CONFIDENCE_THRESHOLD",
]

# Architect default per DD-8; override per use case. Consumers import this
# constant to apply consistent threshold filtering.
_MIN_CONFIDENCE_THRESHOLD: float = 0.85

# Default alias table location (resolved relative to repo root at runtime).
_DEFAULT_ALIAS_TABLE_PATH = (
    Path(__file__).parent.parent.parent.parent
    / "agent-workspace"
    / "ubiquitous-language"
    / "vn_ticker_aliases.md"
)

# Regex matching canonical block header: ### <TICKER_SYMBOL>
_BLOCK_HEADER_RE = re.compile(r"^###\s+([A-Z0-9]{3})\s*$", re.MULTILINE)

# Regex matching the Aliases line inside a ticker block.
_ALIASES_LINE_RE = re.compile(r"^\*\*Aliases\*\*:\s*(.+)$", re.MULTILINE)

# Regex matching the version frontmatter line.
_VERSION_RE = re.compile(r"^version:\s*(\S+)", re.MULTILINE)


class ResolutionMethod(StrEnum):
    """Resolution method taxonomy for I-S22 data-lineage audit trail.

    Members ordered from highest to lowest confidence tier:
    - EXACT: 3-char canonical symbol matched exactly (case-sensitive)
    - CASE_INSENSITIVE: alias matched ignoring case
    - DIACRITICS_STRIPPED: alias matched after stripping Vietnamese diacritics
    - FUZZY: alias matched via difflib.get_close_matches (cutoff 0.85)
    - AMBIGUOUS: multiple candidates within fuzzy cutoff; consumers decide policy
    - UNKNOWN: no alias match found
    """

    EXACT = "EXACT"
    CASE_INSENSITIVE = "CASE_INSENSITIVE"
    DIACRITICS_STRIPPED = "DIACRITICS_STRIPPED"
    FUZZY = "FUZZY"
    AMBIGUOUS = "AMBIGUOUS"
    UNKNOWN = "UNKNOWN"


@dataclass(frozen=True, slots=True)
class ResolutionResult:
    """Immutable resolution result for a single mention string.

    Fields:
    - canonical_ticker: resolved Ticker or None (None for AMBIGUOUS + UNKNOWN)
    - resolution_method: resolution tier (I-S22 audit trail)
    - resolution_confidence: float in [0.0, 1.0]; 1.0 for EXACT/CASE_INSENSITIVE;
      0.95 for DIACRITICS_STRIPPED; SequenceMatcher.ratio() for FUZZY;
      0.0 for AMBIGUOUS + UNKNOWN. Rule 16 mode 2 (deterministic-pipeline echo).
    - matched_alias: the alias string that matched (or original mention for
      AMBIGUOUS/UNKNOWN); preserved for lineage
    - candidates: non-empty tuple of Ticker instances ONLY when AMBIGUOUS;
      empty otherwise
    - alias_table_version: version string from alias table frontmatter (I-S22)
    """

    canonical_ticker: Ticker | None
    resolution_method: ResolutionMethod
    resolution_confidence: float
    matched_alias: str
    alias_table_version: str
    candidates: tuple[Ticker, ...] = field(default_factory=tuple)

    def __post_init__(self) -> None:
        if not 0.0 <= self.resolution_confidence <= 1.0:
            raise ValueError(
                f"resolution_confidence {self.resolution_confidence} not in [0.0, 1.0] "
                "(Rule 16 mode 2 bounds violation)"
            )


def _strip_diacritics(text: str) -> str:
    """Strip Vietnamese and other Unicode combining diacritical marks.

    Uses unicodedata.normalize('NFD') to decompose composite characters, then
    filters out all Unicode Combining category characters. This converts e.g.
    'Công ty Cổ phần Vinhomes' -> 'Cong ty Co phan Vinhomes'.

    Pure-function; deterministic. D-059 R1+R2+R4 satisfied.
    """
    nfd = unicodedata.normalize("NFD", text)
    return "".join(ch for ch in nfd if unicodedata.category(ch) != "Mn")


def _parse_alias_table(content: str) -> tuple[dict[str, Ticker], str]:
    """Parse the markdown alias table and return (alias_map, version).

    alias_map maps each alias string (lowercased) to its canonical Ticker.
    The canonical ticker symbol itself is also inserted as a key.

    Raises ValueError if version frontmatter cannot be parsed.
    Raises ValueError if no ticker blocks found (empty table).

    Implementation uses lenient stdlib regex parsing; tolerates extra whitespace
    and trailing commas in alias lists.
    """
    # Extract version from frontmatter
    ver_match = _VERSION_RE.search(content)
    version = ver_match.group(1) if ver_match else "unknown"

    alias_map: dict[str, Ticker] = {}

    # Find all canonical ticker headers
    block_headers = list(_BLOCK_HEADER_RE.finditer(content))
    if not block_headers:
        raise ValueError(
            "vn_ticker_aliases.md: no ### TICKER blocks found; "
            "alias table may be malformed"
        )

    for i, header_match in enumerate(block_headers):
        symbol = header_match.group(1)  # e.g. "VHM"
        try:
            canonical = Ticker(symbol)
        except InvalidTickerError:
            # Skip malformed ticker symbol (e.g. editing artifact)
            continue

        # Extract block content up to next header or end of string
        start = header_match.end()
        end = block_headers[i + 1].start() if i + 1 < len(block_headers) else len(content)
        block_text = content[start:end]

        # Insert canonical symbol as alias (exact match path)
        alias_map[symbol.lower()] = canonical

        # Parse the Aliases line within this block
        aliases_match = _ALIASES_LINE_RE.search(block_text)
        if not aliases_match:
            continue

        aliases_raw = aliases_match.group(1)
        # Split on comma; strip whitespace; skip empty entries
        for raw_alias in aliases_raw.split(","):
            alias = raw_alias.strip().rstrip(",").strip()
            if not alias:
                continue
            alias_map[alias.lower()] = canonical

    return alias_map, version


class VnTickerResolver:
    """Resolves Vietnamese company-name mention strings to canonical Tickers.

    Concreate class (not Protocol) per plan-032 DD-2 (Karpathy P2 simplicity;
    single backend for v0; no swap requirement until n>200 tickers per AQ-9).

    Resolution stages (applied in order; first match wins):
    1. EXACT — 3-char canonical symbol match (case-sensitive)
    2. CASE_INSENSITIVE — alias-table lookup on mention.lower()
    3. DIACRITICS_STRIPPED — alias-table lookup on _strip_diacritics(mention.lower())
    4. FUZZY — difflib.get_close_matches(cutoff=0.85, n=3) on diacritics-stripped form
    5. AMBIGUOUS — multiple candidates within cutoff window; surface ALL
    6. UNKNOWN — no match

    All stages are pure-function deterministic; D-059 R1+R2+R4 satisfied.
    """

    def __init__(self, alias_table_path: Path | None = None) -> None:
        """Load alias table from markdown file.

        Args:
            alias_table_path: path to vn_ticker_aliases.md; defaults to
                agent-workspace/ubiquitous-language/vn_ticker_aliases.md
                (resolved relative to this module's repo root).

        Raises:
            FileNotFoundError: if alias_table_path does not exist.
            ValueError: if alias table cannot be parsed.
        """
        path = alias_table_path or _DEFAULT_ALIAS_TABLE_PATH
        if not path.exists():
            raise FileNotFoundError(
                f"VnTickerResolver: alias table not found at {path}. "
                "Expected agent-workspace/ubiquitous-language/vn_ticker_aliases.md"
            )
        content = path.read_text(encoding="utf-8")
        self._aliases, self._alias_table_version = _parse_alias_table(content)

        # Pre-build diacritics-stripped alias map for stage 3
        self._stripped_aliases: dict[str, Ticker] = {
            _strip_diacritics(alias): ticker
            for alias, ticker in self._aliases.items()
        }

        # Pre-build list of all alias strings for difflib fuzzy stage
        self._alias_keys: list[str] = list(self._aliases.keys())

    @property
    def alias_table_version(self) -> str:
        """Alias table version string (from markdown frontmatter; I-S22)."""
        return self._alias_table_version

    def resolve(self, mention: str) -> ResolutionResult:
        """Resolve a mention string to a ResolutionResult.

        Multi-stage resolution per plan-032 DD-4 + DD-6 + DD-8:
        - EXACT / CASE_INSENSITIVE: confidence = 1.0
        - DIACRITICS_STRIPPED: confidence = 0.95
        - FUZZY: confidence = max SequenceMatcher.ratio() of best candidate
        - AMBIGUOUS: confidence = 0.0, candidates populated
        - UNKNOWN: confidence = 0.0, canonical_ticker = None

        Args:
            mention: raw mention string from LLM JSON or user input.

        Returns:
            ResolutionResult (always; never raises for normal input).
        """
        if not mention:
            return ResolutionResult(
                canonical_ticker=None,
                resolution_method=ResolutionMethod.UNKNOWN,
                resolution_confidence=0.0,
                matched_alias=mention,
                alias_table_version=self._alias_table_version,
                candidates=(),
            )

        # Stage 1: EXACT match (canonical 3-char uppercase, case-sensitive)
        mention_stripped_leading = mention.strip()
        if (
            len(mention_stripped_leading) == 3
            and mention_stripped_leading.isupper()
            and mention_stripped_leading in {t.symbol for t in self._aliases.values()}
        ):
            # Direct lookup via canonical symbol key
            lookup_key = mention_stripped_leading.lower()
            if lookup_key in self._aliases:
                return ResolutionResult(
                    canonical_ticker=self._aliases[lookup_key],
                    resolution_method=ResolutionMethod.EXACT,
                    resolution_confidence=1.0,
                    matched_alias=mention_stripped_leading,
                    alias_table_version=self._alias_table_version,
                )

        # Stage 2: CASE_INSENSITIVE alias lookup
        mention_lower = mention.lower()
        if mention_lower in self._aliases:
            return ResolutionResult(
                canonical_ticker=self._aliases[mention_lower],
                resolution_method=ResolutionMethod.CASE_INSENSITIVE,
                resolution_confidence=1.0,
                matched_alias=mention,
                alias_table_version=self._alias_table_version,
            )

        # Stage 3: DIACRITICS_STRIPPED match
        mention_stripped = _strip_diacritics(mention_lower)
        if mention_stripped in self._stripped_aliases:
            return ResolutionResult(
                canonical_ticker=self._stripped_aliases[mention_stripped],
                resolution_method=ResolutionMethod.DIACRITICS_STRIPPED,
                resolution_confidence=0.95,
                matched_alias=mention,
                alias_table_version=self._alias_table_version,
            )

        # Stage 4 + 5: FUZZY / AMBIGUOUS via difflib
        # Match against diacritics-stripped alias keys for robustness
        stripped_alias_keys = list(self._stripped_aliases.keys())
        close = difflib.get_close_matches(
            mention_stripped,
            stripped_alias_keys,
            n=3,
            cutoff=_MIN_CONFIDENCE_THRESHOLD,
        )

        if not close:
            return ResolutionResult(
                canonical_ticker=None,
                resolution_method=ResolutionMethod.UNKNOWN,
                resolution_confidence=0.0,
                matched_alias=mention,
                alias_table_version=self._alias_table_version,
                candidates=(),
            )

        # Compute ratios for all close matches
        ratios: list[tuple[float, str]] = []
        for candidate_alias in close:
            ratio = difflib.SequenceMatcher(
                None, mention_stripped, candidate_alias
            ).ratio()
            ratios.append((ratio, candidate_alias))

        ratios.sort(key=lambda x: x[0], reverse=True)
        best_ratio, best_alias = ratios[0]

        # Collect distinct canonical tickers for all close matches
        candidate_tickers: list[Ticker] = []
        seen_symbols: set[str] = set()
        for _, alias in ratios:
            ticker = self._stripped_aliases[alias]
            if ticker.symbol not in seen_symbols:
                candidate_tickers.append(ticker)
                seen_symbols.add(ticker.symbol)

        if len(candidate_tickers) >= 2:
            # AMBIGUOUS: multiple distinct tickers within cutoff window
            # Surface ALL candidates explicitly per DD-6; no silent pick
            return ResolutionResult(
                canonical_ticker=None,
                resolution_method=ResolutionMethod.AMBIGUOUS,
                resolution_confidence=0.0,
                matched_alias=mention,
                alias_table_version=self._alias_table_version,
                candidates=tuple(candidate_tickers),
            )

        # Single candidate: FUZZY match
        return ResolutionResult(
            canonical_ticker=candidate_tickers[0],
            resolution_method=ResolutionMethod.FUZZY,
            resolution_confidence=best_ratio,
            matched_alias=best_alias,
            alias_table_version=self._alias_table_version,
        )
