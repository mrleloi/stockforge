"""Unit tests for VnTokenizer + WhitespaceTokenizer.

Fixtures: synthetic inline VN text (NOT real corpus snapshots per DD-4;
real-corpus eval is STEP 0 only; gitignored fixtures = non-reproducible CI).

D-059 R2 compliance: test_whitespace_tokenizer_deterministic_across_runs
and test_vn_tokenizer_deterministic_across_runs both verify determinism.

Source: agent-workspace/session-plans/pending/029-S361-phase-e1-vn-tokenization.md
        § D3 (≥10 test cases; synthetic VN text fixtures inline).
"""

from __future__ import annotations

import pytest

from packages.application.nlp.ports.text_tokenizer_port import TextTokenizerPort
from packages.infrastructure.nlp.vn_tokenizer import VnTokenizer, WhitespaceTokenizer

# ---------------------------------------------------------------------------
# Synthetic VN financial text fixtures (architect-curated; inline per DD-4)
# ---------------------------------------------------------------------------

_SYNTHETIC_VN_FINANCIAL_TEXT = (
    "Cổ phiếu VHM tăng 5% trong phiên giao dịch hôm nay. "
    "Thị trường chứng khoán Việt Nam đang trong giai đoạn tích lũy. "
    "Nhà đầu tư khối ngoại bán ròng 200 tỷ đồng."
)

_SYNTHETIC_VN_PUMP_ANCHOR_TEXT = (
    "Đội lái đẩy giá cổ phiếu MSN lên mức trần. "
    "Cảnh báo: nhà đầu tư mới có thể đu đỉnh."
)

_SYNTHETIC_MIXED_VN_EN = "VHM Q1 2026 lợi nhuận đạt 1.5 trillion VND."

_SYNTHETIC_MULTI_SYLLABLE = "cổ phiếu thị trường lợi nhuận"

_SYNTHETIC_EMPTY = ""
_SYNTHETIC_WHITESPACE_ONLY = "   \n\t  "
_SYNTHETIC_WITH_PUNCTUATION = "Hôm nay, VHM giảm 2%."
_SYNTHETIC_DIACRITICS = "đu đỉnh bắt đáy"


# ===========================================================================
# WhitespaceTokenizer tests
# ===========================================================================


class TestWhitespaceTokenizer:
    """Tests for the zero-dep whitespace baseline tokenizer."""

    def test_whitespace_tokenizer_basic_vn_text(self) -> None:
        """Test 1: basic VN text is tokenized by whitespace/punctuation split."""
        tokens = WhitespaceTokenizer().tokenize("Cổ phiếu VHM tăng 5%")
        assert "Cổ" in tokens
        assert "phiếu" in tokens
        assert "VHM" in tokens
        assert "tăng" in tokens
        assert "5" in tokens

    def test_whitespace_tokenizer_empty_string_returns_empty_list(self) -> None:
        """Test 2: empty string returns [] per Protocol contract (NOT raises)."""
        tokens = WhitespaceTokenizer().tokenize(_SYNTHETIC_EMPTY)
        assert tokens == []

    def test_whitespace_tokenizer_whitespace_only_returns_empty_list(self) -> None:
        """Test 3: whitespace-only input returns [] per Protocol contract."""
        tokens = WhitespaceTokenizer().tokenize(_SYNTHETIC_WHITESPACE_ONLY)
        assert tokens == []

    def test_whitespace_tokenizer_preserves_diacritics(self) -> None:
        """Test 4: Vietnamese diacritics preserved in output tokens."""
        tokens = WhitespaceTokenizer().tokenize(_SYNTHETIC_DIACRITICS)
        assert "đu" in tokens
        assert "đỉnh" in tokens
        assert "bắt" in tokens
        assert "đáy" in tokens
        # Confirm NOT stripped to ASCII equivalents
        assert "du" not in tokens
        assert "dinh" not in tokens

    def test_whitespace_tokenizer_strips_punctuation(self) -> None:
        """Test 5: punctuation split; ',' and '%' and '.' not in tokens."""
        tokens = WhitespaceTokenizer().tokenize(_SYNTHETIC_WITH_PUNCTUATION)
        assert "VHM" in tokens
        assert "giảm" in tokens
        assert "2" in tokens
        # Punctuation should not appear as standalone token
        assert "." not in tokens
        assert "," not in tokens
        assert "%" not in tokens

    def test_whitespace_tokenizer_deterministic_across_runs(self) -> None:
        """Test 6: same input twice yields identical output (D-059 R2 smoke)."""
        tok = WhitespaceTokenizer()
        out1 = tok.tokenize(_SYNTHETIC_VN_FINANCIAL_TEXT)
        out2 = tok.tokenize(_SYNTHETIC_VN_FINANCIAL_TEXT)
        assert out1 == out2, f"WhitespaceTokenizer non-deterministic: {out1} != {out2}"

    def test_whitespace_tokenizer_returns_list_of_str(self) -> None:
        """Test 7: output is list[str] (Protocol contract validation)."""
        tokens = WhitespaceTokenizer().tokenize(_SYNTHETIC_VN_FINANCIAL_TEXT)
        assert isinstance(tokens, list)
        assert all(isinstance(t, str) for t in tokens)

    def test_whitespace_tokenizer_does_not_preserve_compound_words(self) -> None:
        """Test 8: baseline splits 'co phieu' into 2 tokens (DEFAULT-LOW-QUALITY).

        This is EXPECTED behaviour for the baseline — it documents why the
        selected library (pyvi) is preferred.
        """
        tokens = WhitespaceTokenizer().tokenize(_SYNTHETIC_MULTI_SYLLABLE)
        # 'cổ phiếu' has a space → split into 2 tokens by baseline
        assert "cổ" in tokens and "phiếu" in tokens
        # Baseline CANNOT produce 'cổ_phiếu' (no compound-word awareness)
        compound_forms = [t for t in tokens if "_" in t]
        assert len(compound_forms) == 0, (
            f"Whitespace baseline unexpectedly produced underscore tokens: {compound_forms}"
        )


# ===========================================================================
# VnTokenizer tests (pyvi-backed)
# ===========================================================================


class TestVnTokenizer:
    """Tests for the pyvi-backed VnTokenizer."""

    def test_vn_tokenizer_preserves_multi_syllable_vn_words(self) -> None:
        """Test 9: pyvi produces fewer tokens than whitespace for compound VN words.

        Input 'co phieu thi truong loi nhuan' = 6 syllables (whitespace = 6 tokens).
        pyvi should preserve at least some as compound tokens => len < 6.
        """
        vn_tok = VnTokenizer()
        ws_tok = WhitespaceTokenizer()
        vn_tokens = vn_tok.tokenize(_SYNTHETIC_MULTI_SYLLABLE)
        ws_tokens = ws_tok.tokenize(_SYNTHETIC_MULTI_SYLLABLE)
        # pyvi should produce fewer tokens than whitespace split
        assert len(vn_tokens) < len(ws_tokens), (
            f"VnTokenizer did not preserve any compound words: "
            f"pyvi={vn_tokens!r}, ws={ws_tokens!r}"
        )

    def test_vn_tokenizer_empty_string_returns_empty_list(self) -> None:
        """Test 10: empty string returns [] per Protocol contract."""
        tokens = VnTokenizer().tokenize(_SYNTHETIC_EMPTY)
        assert tokens == []

    def test_vn_tokenizer_whitespace_only_returns_empty_list(self) -> None:
        """Test 11: whitespace-only input returns []."""
        tokens = VnTokenizer().tokenize(_SYNTHETIC_WHITESPACE_ONLY)
        assert tokens == []

    def test_vn_tokenizer_handles_mixed_vn_english(self) -> None:
        """Test 12: mixed VN+English text tokenized correctly.

        'VHM' (ticker) should be preserved as an uppercase token.
        'loi_nhuan' may be compound-joined or split depending on pyvi.
        """
        tokens = VnTokenizer().tokenize(_SYNTHETIC_MIXED_VN_EN)
        assert isinstance(tokens, list)
        assert len(tokens) > 0
        token_str = " ".join(tokens)
        # VHM ticker must survive tokenization
        assert "VHM" in tokens or "VHM" in token_str

    def test_vn_tokenizer_returns_list_str_typing(self) -> None:
        """Test 13: output is list[str] (Protocol contract validation)."""
        tokens = VnTokenizer().tokenize(_SYNTHETIC_VN_FINANCIAL_TEXT)
        assert isinstance(tokens, list)
        assert all(isinstance(t, str) for t in tokens)

    def test_vn_tokenizer_satisfies_text_tokenizer_port_protocol(self) -> None:
        """Test 14: VnTokenizer satisfies TextTokenizerPort via structural typing.

        Duck-type check + static assignment — mypy verifies structural compatibility.
        """
        tok = VnTokenizer()
        assert hasattr(tok, "tokenize"), "VnTokenizer missing tokenize() method"
        # Static type assignment (mypy structural typing check)
        _port_check: TextTokenizerPort = tok  # noqa: F841

    def test_whitespace_tokenizer_satisfies_text_tokenizer_port_protocol(self) -> None:
        """Test 15: WhitespaceTokenizer satisfies TextTokenizerPort as well."""
        tok = WhitespaceTokenizer()
        assert hasattr(tok, "tokenize"), "WhitespaceTokenizer missing tokenize() method"
        _port_check: TextTokenizerPort = tok  # noqa: F841

    def test_vn_tokenizer_handles_long_input_gracefully(self) -> None:
        """Test 16: long repeated input returns list (not raises)."""
        long_text = "VHM " * 1000  # 4000 chars
        tokens = VnTokenizer().tokenize(long_text)
        assert isinstance(tokens, list)
        assert len(tokens) > 0

    def test_vn_tokenizer_deterministic_across_runs(self) -> None:
        """Test 17: same input twice yields identical output (D-059 R2 smoke)."""
        tok = VnTokenizer()
        out1 = tok.tokenize(_SYNTHETIC_VN_FINANCIAL_TEXT)
        out2 = tok.tokenize(_SYNTHETIC_VN_FINANCIAL_TEXT)
        assert out1 == out2, f"VnTokenizer non-deterministic: {out1} != {out2}"

    def test_vn_tokenizer_loads_pyvi_on_first_call(self) -> None:
        """Test 18: _tokenize_fn is None before first call, loaded after."""
        tok = VnTokenizer()
        assert tok._tokenize_fn is None, "tokenize_fn should be lazy-loaded"
        _ = tok.tokenize("test")
        assert tok._tokenize_fn is not None, "tokenize_fn should be populated after call"

    def test_vn_tokenizer_raises_on_import_failure(self) -> None:
        """Test 19: RuntimeError raised with install hint if pyvi unavailable."""
        import sys
        from unittest.mock import patch

        # Temporarily hide pyvi module to simulate install failure
        # We remove it from sys.modules and patch the import machinery
        saved: dict[str, object] = {}
        for key in list(sys.modules.keys()):
            if "pyvi" in key.lower():
                saved[key] = sys.modules.pop(key)

        try:
            # patch.dict value None signals "module blocked"; triggers ImportError
            with patch.dict("sys.modules", {"pyvi": None}):
                fresh_tok = VnTokenizer()
                fresh_tok._tokenize_fn = None  # force lazy re-load
                with pytest.raises((RuntimeError, ImportError)):
                    fresh_tok.tokenize("test input")
        finally:
            # Restore pyvi to sys.modules
            for k, v in saved.items():
                sys.modules[k] = v  # type: ignore[assignment]
