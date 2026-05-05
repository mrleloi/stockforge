"""Test extract_l0 — 5 extractor functions + VN failure patterns + JSONL aggregator."""

from pathlib import Path

from packages.observability import (
    ChatMessage,
    extract_commands,
    extract_errors,
    extract_failures,
    extract_file_paths,
    extract_l0_from_jsonl,
    extract_l0_from_messages,
    extract_next_step,
)

# --- File paths ---


def test_extract_file_paths_finds_python_paths() -> None:
    text = "edit packages/observability/extract_l0.py and tests/test_x.py"
    paths = extract_file_paths(text)
    assert "packages/observability/extract_l0.py" in paths
    assert "tests/test_x.py" in paths


def test_extract_file_paths_skips_http_urls() -> None:
    text = "see http://example.com/path.html for details"
    assert "http://example.com/path.html" not in extract_file_paths(text)


def test_extract_file_paths_dedupes() -> None:
    text = "src/a.py and src/a.py again"
    paths = extract_file_paths(text)
    assert paths.count("src/a.py") == 1


# --- Commands ---


def test_extract_commands_finds_bash_block() -> None:
    text = "```bash\npytest -v\n```"
    cmds = extract_commands(text)
    assert "pytest -v" in cmds


def test_extract_commands_finds_dollar_prefix() -> None:
    text = "$ ls -la /tmp"
    cmds = extract_commands(text)
    assert "ls -la /tmp" in cmds


def test_extract_commands_caps_at_20() -> None:
    text = "\n".join(f"$ cmd{i}" for i in range(50))
    assert len(extract_commands(text)) <= 20


# --- Errors ---


def test_extract_errors_finds_error_prefix() -> None:
    text = "Error: something exploded badly here"
    errs = extract_errors(text)
    assert any("something exploded badly here" in e for e in errs)


def test_extract_errors_finds_fatal() -> None:
    text = "FATAL: unrecoverable database corruption detected"
    errs = extract_errors(text)
    assert any("unrecoverable database corruption" in e for e in errs)


def test_extract_errors_caps_at_10() -> None:
    text = "\n".join(f"Error: msg number {i:02d} that is long enough" for i in range(20))
    assert len(extract_errors(text)) <= 10


# --- Failures (incl. VN extension per D-002 REV-2 § A) ---


def test_extract_failures_english() -> None:
    text = "I tried using regex but it didn't work as expected."
    fails = extract_failures(text)
    assert any("didn't work" in f.lower() or "tried using regex" in f.lower() for f in fails)


def test_extract_failures_russian() -> None:
    text = "не сработало с этим подходом, нужно другой."
    assert len(extract_failures(text)) >= 1


def test_extract_failures_vietnamese_khong_hoat_dong() -> None:
    text = "Cách này không hoạt động trên đa nền tảng."
    fails = extract_failures(text)
    assert any("không hoạt động" in f for f in fails)


def test_extract_failures_vietnamese_khong_hieu_qua() -> None:
    text = "Phương pháp đó không hiệu quả lắm trên dữ liệu lớn."
    fails = extract_failures(text)
    assert any("không hiệu quả" in f for f in fails)


def test_extract_failures_vietnamese_da_thu_nhung() -> None:
    text = "Tôi đã thử nhưng vẫn không ổn định."
    fails = extract_failures(text)
    assert any("đã thử nhưng" in f for f in fails)


def test_extract_failures_vietnamese_khong_kha_thi() -> None:
    text = "Phương án này không khả thi vì chi phí quá cao."
    fails = extract_failures(text)
    assert any("không khả thi" in f for f in fails)


def test_extract_failures_vietnamese_that_bai() -> None:
    text = "Lần thử nghiệm đầu tiên thất bại do timeout."
    fails = extract_failures(text)
    assert any("thất bại" in f for f in fails)


# --- Next step ---


def test_extract_next_step_uses_explicit_marker() -> None:
    msgs: list[ChatMessage] = [
        {"role": "assistant", "content": "Done with phase 1. Next step: write the L1 prompt builder."}
    ]
    step = extract_next_step(msgs)
    assert step is not None and "L1 prompt builder" in step


def test_extract_next_step_falls_back_to_first_sentence() -> None:
    msgs: list[ChatMessage] = [
        {"role": "assistant", "content": "We finished implementing the cache invalidation logic. More details follow."}
    ]
    step = extract_next_step(msgs)
    assert step is not None and "cache invalidation" in step


def test_extract_next_step_returns_none_when_no_assistant() -> None:
    msgs: list[ChatMessage] = [{"role": "user", "content": "hi"}]
    assert extract_next_step(msgs) is None


# --- Aggregator ---


def test_extract_l0_from_messages_summary_uses_first_user() -> None:
    msgs: list[ChatMessage] = [
        {"role": "user", "content": "Hello world request for help"},
        {"role": "assistant", "content": "Sure"},
    ]
    l0 = extract_l0_from_messages(msgs, project="stockforge")
    assert l0["summary"] == "Hello world request for help"
    assert l0["project"] == "stockforge"
    assert l0["messageCount"] == 2


def test_extract_l0_from_messages_empty() -> None:
    l0 = extract_l0_from_messages([], project="stockforge")
    assert l0["messageCount"] == 0
    assert l0["summary"] == ""


# --- JSONL parser ---


def test_extract_l0_from_jsonl_fixture() -> None:
    fixture = Path(__file__).parent / "fixtures" / "sample-transcript.jsonl"
    lines = fixture.read_text(encoding="utf-8").splitlines()
    l0 = extract_l0_from_jsonl(lines, project="stockforge")
    assert l0["messageCount"] > 0
    # Fixture has explicit Vietnamese failure phrases.
    fails = l0.get("failures") or []
    assert any("không hoạt động" in f for f in fails), f"Expected VN không hoạt động in failures, got: {fails}"
    # Fixture mentions packages/observability/extract_l0.py multiple times.
    files = l0.get("files") or []
    assert any("packages/observability/extract_l0.py" in f for f in files)
    # Fixture has bash commands.
    cmds = l0.get("commands") or []
    assert len(cmds) > 0


def test_extract_l0_from_jsonl_skips_malformed_lines() -> None:
    lines = [
        '{"type":"human","message":{"content":"hello"}}',
        "not json at all",
        '{"type":"assistant","message":{"content":"hi"}}',
    ]
    l0 = extract_l0_from_jsonl(lines, project="stockforge")
    assert l0["messageCount"] == 2
