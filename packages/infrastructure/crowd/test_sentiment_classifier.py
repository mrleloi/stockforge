"""Tests for LlmSentimentClassifier.

Coverage:
- Happy path: mock-LLM returns valid categorical JSON → ClassifiedPost list
- BR-4 enforcement: numeric "80%" in LLM output → LlmOutputViolatesISOne raised
- Prose-tolerant JSON: preamble before JSON block → extracted correctly
- Vietnamese diacritics preserved in ClassifiedPost.text
- Empty batch raises ValueError
- Unrecognized sentiment value defaults to NEUTRAL

Markers: unit
"""

from __future__ import annotations

import json
from datetime import UTC, datetime

import pytest

from packages.application.crowd.ports.sentiment_classifier_port import (
    LlmOutputViolatesISOne,
)
from packages.domain.crowd.raw_post import RawPost
from packages.domain.crowd.value_objects.sentiment import Sentiment
from packages.infrastructure.crowd.sentiment_classifier import LlmSentimentClassifier

_NOW = datetime(2026, 5, 6, 12, 0, 0, tzinfo=UTC)


def _make_post(post_id: str, text: str = "VND tốt") -> RawPost:
    return RawPost(
        post_id=post_id,
        ticker="VND",
        source="f319",
        source_url=f"https://f319.com/threads/{post_id}",
        posted_at=_NOW,
        text=text,
        poster_id=f"user_{post_id}",
        account_age_days=None,
    )


def _mock_llm_response(posts: list[RawPost], sentiment: str) -> str:
    """Construct a clean JSON response for all posts with given sentiment."""
    result = [{"post_id": p.post_id, "sentiment": sentiment} for p in posts]
    return json.dumps(result)


@pytest.mark.unit
class TestLlmSentimentClassifierHappyPath:
    def test_returns_classified_posts_for_each_input(self) -> None:
        posts = [_make_post("p1"), _make_post("p2")]
        classifier = LlmSentimentClassifier(
            llm_client=lambda _model, _prompt: _mock_llm_response(posts, "bullish")
        )
        result = classifier.classify_batch(posts)
        assert len(result) == 2
        assert all(r.sentiment is Sentiment.BULLISH for r in result)

    def test_strongly_bullish_label_preserved(self) -> None:
        posts = [_make_post("p1")]
        classifier = LlmSentimentClassifier(
            llm_client=lambda _model, _prompt: _mock_llm_response(posts, "strongly_bullish")
        )
        result = classifier.classify_batch(posts)
        assert result[0].sentiment is Sentiment.STRONGLY_BULLISH

    def test_classified_post_fields_match_raw_post(self) -> None:
        post = _make_post("test_001", "Mua VND")
        classifier = LlmSentimentClassifier(
            llm_client=lambda _model, _prompt: _mock_llm_response([post], "bullish")
        )
        result = classifier.classify_batch([post])
        cp = result[0]
        assert cp.post_id == post.post_id
        assert cp.ticker == post.ticker
        assert cp.source == post.source
        assert cp.text == post.text
        assert cp.poster_id == post.poster_id


@pytest.mark.unit
class TestBR4NumericEnforcement:
    def test_percentage_in_llm_output_raises_is_one(self) -> None:
        """BR-4 + I-S1: "80%" in LLM output → LlmOutputViolatesISOne."""
        classifier = LlmSentimentClassifier(
            llm_client=lambda _model, _prompt: '{"sentiment": "bullish", "score": "80%"}'
        )
        with pytest.raises(LlmOutputViolatesISOne):
            classifier.classify_batch([_make_post("p1")])

    def test_approximately_in_output_raises_is_one(self) -> None:
        classifier = LlmSentimentClassifier(
            llm_client=lambda _model, _prompt: "approximately [bullish for all]"
        )
        with pytest.raises(LlmOutputViolatesISOne):
            classifier.classify_batch([_make_post("p1")])

    def test_roughly_in_output_raises_is_one(self) -> None:
        classifier = LlmSentimentClassifier(
            llm_client=lambda _model, _prompt: 'roughly [{"post_id": "p1", "sentiment": "bullish"}]'
        )
        with pytest.raises(LlmOutputViolatesISOne):
            classifier.classify_batch([_make_post("p1")])

    def test_clean_categorical_output_does_not_raise(self) -> None:
        posts = [_make_post("p1")]
        classifier = LlmSentimentClassifier(
            llm_client=lambda _model, _prompt: _mock_llm_response(posts, "neutral")
        )
        result = classifier.classify_batch(posts)  # should not raise
        assert result[0].sentiment is Sentiment.NEUTRAL


@pytest.mark.unit
class TestProseToleranceJSON:
    def test_preamble_before_json_array_is_tolerated(self) -> None:
        posts = [_make_post("p1")]
        preamble_response = (
            "Sure, here is the classification result:\n\n"
            '[{"post_id": "p1", "sentiment": "bearish"}]'
        )
        classifier = LlmSentimentClassifier(
            llm_client=lambda _model, _prompt: preamble_response
        )
        result = classifier.classify_batch(posts)
        assert result[0].sentiment is Sentiment.BEARISH

    def test_fenced_code_block_extracted(self) -> None:
        posts = [_make_post("p1")]
        fenced = '```json\n[{"post_id": "p1", "sentiment": "strongly_bearish"}]\n```'
        classifier = LlmSentimentClassifier(
            llm_client=lambda _model, _prompt: fenced
        )
        result = classifier.classify_batch(posts)
        assert result[0].sentiment is Sentiment.STRONGLY_BEARISH


@pytest.mark.unit
class TestVietnameseDiacriticsPreserved:
    def test_diacritics_in_text_preserved(self) -> None:
        text = "VND tiềm năng tăng mạnh theo xu hướng đầu tư công"
        post = _make_post("p_vi", text)
        posts = [post]
        classifier = LlmSentimentClassifier(
            llm_client=lambda _model, _prompt: _mock_llm_response(posts, "bullish")
        )
        result = classifier.classify_batch(posts)
        assert result[0].text == text  # diacritics preserved, not transliterated


@pytest.mark.unit
class TestEdgeCases:
    def test_empty_batch_raises_value_error(self) -> None:
        classifier = LlmSentimentClassifier(
            llm_client=lambda _model, _prompt: "[]"
        )
        with pytest.raises(ValueError, match="at least 1"):
            classifier.classify_batch([])

    def test_unknown_sentiment_value_defaults_to_neutral(self) -> None:
        posts = [_make_post("p1")]
        classifier = LlmSentimentClassifier(
            llm_client=lambda _model, _prompt: '[{"post_id": "p1", "sentiment": "very_positive"}]'
        )
        result = classifier.classify_batch(posts)
        assert result[0].sentiment is Sentiment.NEUTRAL
