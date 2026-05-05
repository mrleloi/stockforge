"""Test clean_text — 9-pattern strip + edge cases."""

from packages.observability import clean_text


def test_strips_system_reminder() -> None:
    assert clean_text("hello <system-reminder>x</system-reminder> world") == "hello  world"


def test_strips_command_name() -> None:
    assert clean_text("<command-name>/foo</command-name>real").strip() == "real"


def test_strips_command_message() -> None:
    assert clean_text("<command-message>noise</command-message>x") == "x"


def test_strips_command_args() -> None:
    assert clean_text("<command-args>--flag</command-args>x") == "x"


def test_strips_local_command_stdout() -> None:
    assert clean_text("a<local-command-stdout>output</local-command-stdout>b") == "ab"


def test_strips_local_command_caveat() -> None:
    assert clean_text("a<local-command-caveat>warn</local-command-caveat>b") == "ab"


def test_strips_task_notification() -> None:
    assert clean_text("a<task-notification>n</task-notification>b") == "ab"


def test_strips_context_window_protection() -> None:
    assert clean_text("a<context_window_protection>p</context_window_protection>b") == "ab"


def test_strips_context_guidance() -> None:
    assert clean_text("a<context_guidance>g</context_guidance>b") == "ab"


def test_strips_multiline_tag_content() -> None:
    text = "before<system-reminder>\nlots\nof\nlines\n</system-reminder>after"
    assert clean_text(text) == "beforeafter"


def test_handles_multiple_tags_same_text() -> None:
    text = "<system-reminder>a</system-reminder>real<task-notification>b</task-notification>"
    assert clean_text(text).strip() == "real"


def test_empty_input_returns_empty_string() -> None:
    assert clean_text("") == ""


def test_no_tags_returns_trimmed_input() -> None:
    assert clean_text("  hello world  ") == "hello world"


def test_outer_tag_strips_nested_inner() -> None:
    """snapshot.ts non-greedy match strips outer-first; inner tag becomes irrelevant."""
    text = "<task-notification>x<system-reminder>y</system-reminder>z</task-notification>real"
    # Non-greedy outer match would stop at first </task-notification>, so the whole nested
    # block is stripped because there's only one outer tag pair.
    assert clean_text(text) == "real"
