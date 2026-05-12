---
id: D-050-S227-anthropic-to-subagent-systemic
title: Replace ANTHROPIC_API_KEY with Claude Code subagent dispatch (systemic)
date: 2026-05-09
status: ACCEPTED
level: CHARTER

author:
  - "Claude Opus 4.7"

source_evidence:
  - path: chat 2026-05-09 (S227 AskUserQuestion response — LIVE-dogfood gate redirect)
    quote: "no need anthropic api key, use claude code subagent (claude subscription) instead, for every 'anthropic api key'"
  - path: agent-workspace/research/r-2026-05-01-claude-cli-substrate.md
    section: probe-result + IMPL — substrate already shipped at S43b
  - path: packages/infrastructure/analysis/subagent_transport.py
    section: claude_cli_transport — drop-in transport
  - path: ~/.ccs/instances/nathanleewindy/projects/C--htdocs-stockforge/memory/anthropic_api_to_subagent.md
    section: durable user-feedback rule

intent_classification:
  primary_intent: SCOPE
  affects_charter: true
  affects_scope: true
  urgency: NORMAL
  complexity_score: 70

options_considered:
  - id: A
    summary: "Flip default transport='subagent' + hard-block transport='anthropic' with deprecation pointer (Recommended)"
    pros:
      - Minimum surgical change leveraging existing S43b substrate (subagent_transport.py + _build_subagent_agents already shipped)
      - Zero marginal cost — bills against Claude Code subscription user already has
      - Preserves anthropic transport string as explicit opt-in marker for future re-enable
      - Already-passing 7/7 CLI test + 94/94 BC-8+dashboard pytest after edits
      - Deprecation NotImplementedError surfaces clear pointer; never silently breaks
    cons:
      - News claim extractor (packages/infrastructure/news/claude_llm_extractor.py) uses different transport signature (prompt, body) → str — NOT yet refactored; deferred to D-051 follow-up
      - _default_transport in adapter retained (anthropic SDK lazy import) — dead code path until removed in cleanup ADR
  - id: B
    summary: "Delete all anthropic SDK code paths immediately"
    pros:
      - One-shot cleanup; no transitional state
    cons:
      - Larger blast radius; news extractor refactor needs new transport substrate authored first (different signature)
      - Higher regression risk in single session
      - Premature deletion before News path refactor → stranded stub
  - id: C
    summary: "Keep anthropic as default; subagent opt-in only"
    pros:
      - No code change
    cons:
      - Directly contradicts user systemic directive ("for every ANTHROPIC_API_KEY")
      - REJECTED

chosen: A
chosen_rationale: |
  User's verbatim directive 2026-05-09 is systemic ("for every 'anthropic api key'"),
  not one-off. Substrate already exists from S43b (research/r-2026-05-01-claude-cli-substrate.md
  + subagent_transport.py + _build_subagent_agents in use_case_builder.py); flipping the default
  is a 4-file surgical edit (use_case_builder default + CLI default + dashboard docstring +
  t7 test rewrite to reflect new doctrine). News extractor refactor deferred to D-051 follow-up
  because its transport signature differs (prompt, body) → str vs analysis (model, system_prompt,
  user_message, temperature) → (text, in_tok, out_tok); needs sibling claude_cli_news_transport.
  Empirical close-verify: 94 PASS BC-8+dashboard + 86/86 firing-test zero regression.

approval_chain:
  - actor: user
    action: DIRECTED
    at: 2026-05-09
    via: chat (S227 AskUserQuestion response)
  - actor: agent
    action: ACCEPTED
    at: 2026-05-09
    via: this ADR + 4-file surgical edit + memory rule write + sync-state update

verified_by:
  - mechanism: pytest
    at: 2026-05-09
    result: PASS
    detail: "apps/cli/test_validate_thesis.py = 7/7 PASS; analysis+dashboard aggregate = 94/94 PASS / 8 skipped (streamlit not installed)"
  - mechanism: firing-test-suite
    at: 2026-05-09
    result: PASS
    detail: "86/86 PASS in 235s zero regression vs S226 baseline"
  - mechanism: py_compile
    at: 2026-05-09
    result: PASS
    detail: "all 4 edited files syntax OK"

affects:
  charter: true
  spec_files:
    - specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md  # § B.10 model routing notes; subagent CLI subprocess substrate becomes canonical
  code_paths:
    - apps/_shared/use_case_builder.py
    - apps/cli/validate_thesis.py
    - apps/cli/test_validate_thesis.py
    - apps/dashboard/pages/validate_thesis.py
  config_files: []
  other_decisions:
    - D-023  # S43c charter-amend autonomous-protocol cost substrate (subagent CLI mention)

depends_on:
  - D-023  # S43c subagent substrate ratification

supersedes: null
superseded_by: null

# R7 — provenance chain
provenance:
  user_intent: "Replace every ANTHROPIC_API_KEY usage with Claude Code subagent dispatch (subscription billing, not API metered)"
  proposal_origin: "S227 AskUserQuestion redirect (LIVE-dogfood gate)"
  ratification_path: "user direct chat reply 2026-05-09"

# Follow-ups (not part of this ADR's verification surface)
follow_ups:
  - id: D-051-news-extractor-subagent-refactor
    summary: "Author claude_cli_news_transport (prompt, body) → str sibling to subagent_transport; flip news/claude_llm_extractor default same way"
    blocking: false
  - id: D-052-anthropic-sdk-removal
    summary: "After D-051 lands, remove _default_transport stubs + drop anthropic from pyproject.toml dependencies"
    blocking: false

---

# D-050 — Replace ANTHROPIC_API_KEY with Claude Code subagent dispatch (systemic)

## Summary

Per user directive 2026-05-09 ("no need anthropic api key, use claude code subagent (claude subscription) instead, for every 'anthropic api key'"): the canonical LLM substrate for stockforge production code is the **claude CLI subprocess** (parent Claude Code OAuth/keychain), NOT the `anthropic` SDK with `ANTHROPIC_API_KEY`. This rule is **systemic** — applies to every site that would otherwise reach for the SDK + key.

## Implementation (this session — S227)

Surgical default-flip leveraging existing S43b substrate:

1. `apps/_shared/use_case_builder.py`:
   - Default `transport: str = "anthropic"` → `"subagent"`.
   - `_DOGFOOD_GATE_MSG` rewritten as deprecation pointer.
   - `_check_live_gate()` simplified to always raise `NotImplementedError` when `transport=='anthropic'` (env-var check removed; no longer relevant).
   - HARD BINDING docstring rewritten.

2. `apps/cli/validate_thesis.py`:
   - `--transport` default `"anthropic"` → `"subagent"`.
   - HARD BINDING + exit-code docstring rewritten.

3. `apps/cli/test_validate_thesis.py`:
   - `t7` rewritten: was `--no-mock-llm without ANTHROPIC_API_KEY → exit 4 + key in error`; now `--no-mock-llm --transport=anthropic → exit 3 + 'subagent' pointer in error`.

4. `apps/dashboard/pages/validate_thesis.py`:
   - HARD BINDING docstring rewritten.

## Empirical close-verify

- `python -m py_compile` all 4 files = OK.
- `pytest apps/cli/test_validate_thesis.py -q` = **7/7 PASS** in 0.14s.
- `pytest packages/infrastructure/analysis/ packages/application/analysis/ packages/domain/analysis/ apps/_shared/ apps/cli/test_validate_thesis.py apps/dashboard/test_smoke.py -q` = **94 PASS / 8 skipped** (skipped = streamlit dashboard smoke; not installed in dev env).
- `bash scripts/hooks/firing-tests/run-all.sh` = **86/86 PASS** in 235s zero regression vs S226 baseline.

## Deferred (separate ADRs)

- **D-051**: News claim extractor refactor — `packages/infrastructure/news/claude_llm_extractor.py` uses a different transport signature `(prompt, body) → str`. Need a sibling `claude_cli_news_transport` module before flipping its default. Production ingest path; not load-bearing for current Phase 3 close.
- **D-052**: Anthropic SDK code-path removal — after D-051 lands, delete `_default_transport` stubs from both adapter modules and drop `anthropic` from `pyproject.toml` dependencies.

## LIVE-dogfood gate impact

The Phase 3 LIVE 5-KOL+5-ticker dogfood gate (Q&A 2026-05-01-002 + master-plan §S57) was previously gated on `$8-15 ANTHROPIC_API_KEY budget authorization`. Under the new doctrine the marginal cost is **~$0** (subscription already paid), so the gate semantics shift to "**streamlit installed + sqlite populated via ingest CLIs**" — re-fire authorization next session once those prereqs land.

## Charter binding

This ADR is CHARTER-class because it codifies a systemic LLM-routing rule across the entire codebase. Promotion-target candidate for `agent-workspace/constitution/architecture.md` § LLM Substrate (or new file `constitution/llm-routing.md`) at next promote-rule cycle.
