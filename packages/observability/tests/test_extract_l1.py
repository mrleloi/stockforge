"""Test extract_l1 — prompt builder + parser + windowing."""

from pathlib import Path

from packages.observability import (
    HEAD_COUNT,
    TAIL_COUNT,
    ChatMessage,
    build_extraction_prompt,
    extract_messages_from_jsonl,
    parse_llm_response,
)

# --- Prompt builder ---


def test_build_extraction_prompt_includes_six_categories() -> None:
    msgs: list[ChatMessage] = [{"role": "user", "content": "hi"}]
    p = build_extraction_prompt(msgs)
    for cat in ("profile", "preferences", "entities", "events", "cases", "patterns"):
        assert cat in p, f"category {cat} missing from prompt"


def test_build_extraction_prompt_emphasizes_failed_approaches() -> None:
    """extract-l1.ts:53 — explicit emphasis on FAILED APPROACHES carry-over."""
    p = build_extraction_prompt([{"role": "user", "content": "x"}])
    assert "FAILED APPROACHES" in p


def test_build_extraction_prompt_has_json_array_marker() -> None:
    p = build_extraction_prompt([{"role": "user", "content": "x"}])
    assert "JSON array" in p


def test_build_extraction_prompt_concatenates_messages() -> None:
    msgs: list[ChatMessage] = [
        {"role": "user", "content": "first"},
        {"role": "assistant", "content": "second"},
    ]
    p = build_extraction_prompt(msgs)
    assert "user: first" in p
    assert "assistant: second" in p


# --- Parser ---


def test_parse_llm_response_clean_json() -> None:
    raw = '[{"category":"events","name":"test-event","content":"ran tests at 10am"}]'
    out = parse_llm_response(raw)
    assert len(out) == 1
    assert out[0]["category"] == "events"
    assert out[0]["name"] == "test-event"


def test_parse_llm_response_with_prose_preamble() -> None:
    raw = "Here are the memories I extracted:\n[{\"category\":\"profile\",\"name\":\"role\",\"content\":\"engineer\"}]\nDone."
    out = parse_llm_response(raw)
    assert len(out) == 1
    assert out[0]["category"] == "profile"


def test_parse_llm_response_skips_invalid_category() -> None:
    raw = '[{"category":"BADCATEGORY","name":"x","content":"y"},{"category":"patterns","name":"good","content":"y"}]'
    out = parse_llm_response(raw)
    assert len(out) == 1
    assert out[0]["category"] == "patterns"


def test_parse_llm_response_skips_missing_fields() -> None:
    raw = '[{"category":"events","name":"","content":"y"},{"category":"events","name":"good","content":"y"}]'
    out = parse_llm_response(raw)
    assert len(out) == 1
    assert out[0]["name"] == "good"


def test_parse_llm_response_empty_input() -> None:
    assert parse_llm_response("") == []
    assert parse_llm_response("   ") == []


def test_parse_llm_response_no_json_array() -> None:
    assert parse_llm_response("Just prose, no JSON here.") == []


def test_parse_llm_response_malformed_json() -> None:
    assert parse_llm_response("[{bad json") == []


# --- Windowing ---


def test_extract_messages_from_jsonl_returns_all_when_short() -> None:
    """If total <= HEAD + TAIL, return all messages."""
    import json
    import tempfile

    short = [{"type": "human", "message": {"content": f"msg {i}"}} for i in range(10)]
    with tempfile.NamedTemporaryFile(
        mode="w", suffix=".jsonl", delete=False, encoding="utf-8"
    ) as f:
        for ev in short:
            f.write(json.dumps(ev) + "\n")
        path = f.name
    try:
        msgs = extract_messages_from_jsonl(path)
        assert len(msgs) == 10  # below HEAD+TAIL=50, so all returned
    finally:
        Path(path).unlink()


def test_extract_messages_from_jsonl_windowing_triggers_for_long_session() -> None:
    fixture = Path(__file__).parent / "fixtures" / "sample-transcript.jsonl"
    raw_lines = fixture.read_text(encoding="utf-8").splitlines()
    if len(raw_lines) > HEAD_COUNT + TAIL_COUNT:
        msgs = extract_messages_from_jsonl(fixture)
        assert len(msgs) == HEAD_COUNT + TAIL_COUNT


def test_extract_messages_from_jsonl_user_role_normalized() -> None:
    fixture = Path(__file__).parent / "fixtures" / "sample-transcript.jsonl"
    msgs = extract_messages_from_jsonl(fixture)
    roles = {m["role"] for m in msgs}
    assert "user" in roles
    assert "assistant" in roles
    # JSONL "human" type must be normalized to "user".
    assert "human" not in roles


def test_extract_messages_from_jsonl_trims_long_user_content() -> None:
    """User content trimmed to 1000 chars per extract-l1.ts:132."""
    import json
    import tempfile

    long_content = "x" * 5000
    with tempfile.NamedTemporaryFile(
        mode="w", suffix=".jsonl", delete=False, encoding="utf-8"
    ) as f:
        f.write(json.dumps({"type": "human", "message": {"content": long_content}}) + "\n")
        path = f.name
    msgs = extract_messages_from_jsonl(path)
    Path(path).unlink()
    assert len(msgs) == 1
    assert len(msgs[0]["content"]) == 1000
