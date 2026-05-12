---
id: D-052-S229-anthropic-sdk-codepath-full-removal
title: Delete anthropic SDK code-paths + drop pyproject dependency
date: 2026-05-09
status: ACCEPTED
level: ARCH
supersedes: []
superseded_by: []

author:
  - "Claude Opus 4.7"

source_evidence:
  - path: agent-workspace/memory/decisions/050-S227-anthropic-to-subagent-systemic.md
    section: D-050 § follow_ups — D-052 enumerated as final cleanup target
  - path: agent-workspace/memory/decisions/051-S228-news-extractor-subagent-refactor.md
    section: D-051 § follow_ups — "D-052 SDK code-path removal: delete `_default_transport` deprecation stubs in claude_llm_perspective_adapter.py + claude_llm_extractor.py + drop `anthropic` from pyproject.toml"
  - path: CLAUDE.md
    section: StockForge Hard Rules — NO ANTHROPIC_API_KEY / NO direct anthropic SDK in production code (appended S227)
  - path: agent-workspace/memory/agent-notes.md
    section: L-S227-1 critical-severity rule (auto-detect=yes)

intent_classification:
  primary_intent: ARCH
  affects_charter: false
  affects_scope: false
  urgency: NORMAL

decision: |
  Complete the D-050/D-051 chain by removing all anthropic SDK code-paths from
  production:

  1. `packages/infrastructure/analysis/claude_llm_perspective_adapter.py`:
     delete the `_default_transport` function (was a real anthropic SDK call,
     not a deprecation stub — D-050 only flipped the use_case_builder default).
     Set the dataclass `transport` default to `claude_cli_transport` from the
     same-BC sibling module `subagent_transport.py` (no cross-BC import).
  2. `packages/infrastructure/news/claude_llm_extractor.py`: delete the
     `_default_transport` deprecation-marker stub authored at D-051. Default
     was already `claude_cli_news_transport`; the stub is now dead code.
  3. `pyproject.toml`: remove `anthropic>=0.40.0` from dependencies. Keep
     `anthropic` in `[[tool.importlinter.contracts]] forbidden_modules` as a
     defensive boundary (regression detector even after the dep is gone).
  4. `packages/infrastructure/news/test_adapters.py`: replace the
     NotImplementedError-deprecation test with a regression test that asserts
     (a) `_default_transport` symbol no longer exists on the module and (b) no
     real `import anthropic` / `from anthropic` statement leaks back in.

rationale: |
  D-050 (S227) made subagent the canonical default but left two real anthropic
  SDK code-paths intact: the news extractor `_default_transport` (real SDK
  call) and the analysis adapter `_default_transport` (real SDK call). D-051
  (S228) replaced the news-extractor real-SDK call with a NotImplementedError
  stub plus authored a sibling subagent transport. The analysis adapter still
  carried the SDK call until D-052.

  Surgical removal (P3): no new files, ~30 LOC deleted across 3 files, no
  signature changes to public API. Tests injecting `transport=` callable
  continue to work unchanged. Symbol-existence regression test ensures the
  stub does not silently re-creep into production via future copy-paste.

trade_offs: |
  (+) Honors L-S227-1 critical-severity rule fully — no `import anthropic`
      remaining in production-code paths (`apps/**` + `packages/**`).
  (+) `pyproject.toml` ships smaller dep surface; one fewer license/version
      pin to track; `pip install` faster.
  (+) Cost model unchanged: subscription pre-paid, ~$0 marginal per call.
  (-) Direct dataclass instantiation of either adapter without a builder will
      now hit `claude` CLI subprocess on first use. Tests must inject a stub
      (already the existing pattern in test_adapters.py + test_perspective_adapter.py).
  (-) `vendor-api-probe` firing-test fixture intentionally uses `import anthropic`
      inside a heredoc to test the probe DETECTING missing anthropic; that's a
      shell-script test fixture, not production import — kept as-is.

empirical_close_verify:
  - "py_compile all 3 edited files = OK"
  - "pytest packages/infrastructure/news/ packages/infrastructure/analysis/ packages/application/analysis/ packages/domain/analysis/ apps/_shared/ apps/cli/test_validate_thesis.py = 125 PASS in 0.83s"
  - "firing-tests/run-all.sh = 86/86 PASS in 236s zero regression vs S228 baseline"
  - "Production-code grep `^[ \\t]*(?:import\\s+anthropic|from\\s+anthropic\\b)` in apps/+packages/ = 0 hits"

follow_ups:
  - "D10 drift-signal hook: now ZERO production references; hook can run with strict-zero-tolerance threshold + companion firing-test. Per L-S227-1 auto-detect=yes."
  - "Future hoist of _unwrap_fence to packages/infrastructure/_shared/ if a 3rd consumer arrives (no action this turn)."

files_touched:
  - "EDITED packages/infrastructure/analysis/claude_llm_perspective_adapter.py (~-32 / +5 LOC: _default_transport deleted, claude_cli_transport imported, dataclass default flipped, docstring rewrite)"
  - "EDITED packages/infrastructure/news/claude_llm_extractor.py (~-12 / +0 LOC: _default_transport stub deleted; docstring HARD BINDING line refers to D-052)"
  - "EDITED packages/infrastructure/news/test_adapters.py (~+15 / -10 LOC: legacy NotImplementedError test replaced with anthropic-import regression test; _default_transport import removed)"
  - "EDITED pyproject.toml (~-1 / +5 LOC: anthropic dep removed; comment-block referencing D-052 added)"
