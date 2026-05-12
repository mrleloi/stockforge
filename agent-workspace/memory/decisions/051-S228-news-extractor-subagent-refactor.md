---
id: D-051-S228-news-extractor-subagent-refactor
title: BC-5 news extractor — flip default transport from anthropic SDK to claude CLI subagent
date: 2026-05-09
status: ACCEPTED
level: ARCH
supersedes: []
superseded_by: []

author:
  - "Claude Opus 4.7"

source_evidence:
  - path: agent-workspace/memory/decisions/050-S227-anthropic-to-subagent-systemic.md
    section: D-050 § follow_ups — D-051 enumerated as next refactor target
  - path: agent-workspace/memory/checkpoints/latest.md (S227 close)
    section: S228 PRIORITY 1
  - path: packages/infrastructure/analysis/subagent_transport.py
    section: claude_cli_transport — pattern reused (signature differs)
  - path: packages/infrastructure/news/claude_llm_extractor.py (pre-S228)
    section: _default_transport using anthropic.Anthropic().messages.create

intent_classification:
  primary_intent: ARCH
  affects_charter: false
  affects_scope: false
  urgency: NORMAL

decision: |
  Author sibling subagent transport `packages/infrastructure/news/claude_cli_news_transport.py`
  with signature `(system_prompt, body) → str` matching ClaudeLlmExtractor.transport
  callable contract. Make it the canonical default for `ClaudeLlmExtractor.transport`.
  Retain legacy `_default_transport` (anthropic SDK) ONLY as a deprecation marker
  raising NotImplementedError pointing back to `claude_cli_news_transport` — same
  pattern as D-050 applied to BC-8 analysis adapter.

  Cross-BC import (BC-5 news → BC-8 analysis) FORBIDDEN per CLAUDE.md hard rule.
  `_unwrap_fence` + subprocess-invocation core duplicated locally (~60 LOC). Future
  hoist to `packages/infrastructure/_shared/` deferred until a 3rd consumer arrives.

rationale: |
  D-050 established the systemic doctrine: subagent canonical, anthropic deprecated.
  D-050 itself touched only BC-8 analysis (`use_case_builder.py` + CLI). BC-5 news
  extractor was explicitly enumerated as D-051 follow-up because its transport
  callable signature `(prompt, body) → str` differs from BC-8 analysis's
  `(model, system_prompt, user_message, temperature) → (text, in_tok, out_tok)`,
  so the existing `claude_cli_transport` cannot be reused as-is.

  Surgical pattern (P3): new file ~165 LOC + 4 line edits in extractor + 4 lines in
  __init__.py + 4 new tests in test_adapters.py. Zero new dependencies. Test stub
  injection via `transport=lambda _s, _b: response` continues to work unchanged.

trade_offs: |
  (+) Honors L-S227-1 (no anthropic SDK in production code path).
  (+) Cost model parity with D-050: subscription pre-paid, ~$0 marginal per article.
  (+) Pattern consistency: deprecation-marker-raises rather than silent fallback.
  (-) Code duplication of _unwrap_fence (~30 LOC) across BC-5/BC-8 — accepted per
      P2/P3 + cross-BC import boundary. Future _shared hoist is a 1-call refactor
      if BC-3 fundamental or another BC adopts the pattern.
  (-) D-052 (anthropic SDK code-path full removal + pyproject drop) still pending;
      this refactor unblocks it but does not execute it.

empirical_close_verify:
  - "py_compile all 4 edited/new files = OK"
  - "pytest packages/infrastructure/news/ = 31 PASS in 0.42s (was 27 pre-S228; +4 new D-051 doctrine tests)"
  - "scripts/hooks/firing-tests/run-all.sh = 86/86 PASS in 236s zero regression vs S227 baseline"

follow_ups:
  - "D-052 SDK code-path removal: delete `_default_transport` deprecation stubs in claude_llm_perspective_adapter.py + claude_llm_extractor.py + drop `anthropic` from pyproject.toml; verify CI green."
  - "D10 drift-signal authoring: grep production code for `import anthropic` / `ANTHROPIC_API_KEY` (excluding documented deprecation stubs); WARN unmarked references."
  - "Hoist `_unwrap_fence` to packages/infrastructure/_shared/ once a 3rd consumer arrives (out-of-scope for D-051)."

files_touched:
  - "NEW packages/infrastructure/news/claude_cli_news_transport.py (~165 LOC)"
  - "EDITED packages/infrastructure/news/claude_llm_extractor.py (~+15 / -25 LOC: docstring + import + `_default_transport` → NotImplementedError stub + dataclass default flip)"
  - "EDITED packages/infrastructure/news/__init__.py (+8 LOC: re-export new transport + factory + error class)"
  - "EDITED packages/infrastructure/news/test_adapters.py (+50 LOC: 4 new tests for D-051 doctrine + _unwrap_fence)"
