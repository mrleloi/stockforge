---
id: D-007-track-8b-memory-l0-l1-extraction
title: Track 8b — Session Memory L0/L1 Extraction module (packages/observability/)
date: 2026-04-29
status: ACCEPTED
level: IMPL

author:
  - "Claude Opus 4.7"

source_evidence:
  - path: agent-workspace/memory/decisions/002-phase-0-harness-bootstrap-design.md
    section: "Amendments — REV-2 § A. Track 8 SPLIT (Q-S1 = B)"
    quote: "Port `claude-sessions` L0 regex (extract-l0.ts:5-80) verbatim → packages/observability/extract_l0.py / Port `claude-sessions` L1 prompt (extract-l1.ts:33-64) verbatim with VN extension / Port 15+35 head/tail windowing / Port cleanText / Port TranscriptCache → packages/observability/transcript_cache.py / EXTEND L0 FAILURE_PATTERNS with VN phrases"
  - path: C:/htdocs/orch-starter/claude-sessions/src/memory/extract-l0.ts
    section: "lines 5-80 (regex constants + 5 extractor functions)"
  - path: C:/htdocs/orch-starter/claude-sessions/src/memory/extract-l1.ts
    section: "lines 27-100 (HEAD/TAIL windowing + buildExtractionPrompt + parseLLMResponse)"
  - path: C:/htdocs/orch-starter/claude-sessions/src/memory/snapshot.ts
    section: "lines 35-50 (cleanText 9-pattern strip chain)"
  - path: C:/htdocs/orch-starter/Claude-Code-Agent-Monitor/server/lib/transcript-cache.js
    section: "core caching mechanic (mtime+size dual-check + byte-offset incremental + LRU)"
  - path: agent-workspace/memory/decisions/003-up06-track-5.5-sync-layer-selfcap.md
    section: "Open Questions doctrine"
    quote: "Storage substrate is IMPL-tier; agent picks; subject to drift audit"
  - path: agent-workspace/memory/decisions/006-track-8a-confidence-score-system.md
    section: "Open Questions § Phase 1+ SQLite migration"
    quote: "When Track 8b ships python+sqlite3 module, migrate sync-tracker TSV → SQLite"
  - path: PROJECT_CHARTER.md
    section: "Core Principle 4 (Proprietary data moat) + Core Principle 6 (Human-in-loop)"

intent_classification:
  primary_intent: DECISION
  affects_charter: false
  affects_scope: false
  urgency: NORMAL
  complexity_score: 65

options_considered:
  - id: A
    summary: "Full port — L0 + L1 (with claude-CLI subprocess auto-invoke) + TranscriptCache + cleanText + skill"
    pros:
      - "End-to-end runnable; matches claude-sessions' MVP"
      - "L1 extraction immediately produces structured memories per session"
    cons:
      - "Subprocess invocation of `claude` CLI is a Phase 1+ concern (Charter Principle 9: deterministic code first; LLM dispatch is Phase 1+ when API client wires)"
      - "Adds early dependency on environment-installed claude CLI; brittle on bash hooks (L-S11-1 portability bind)"
      - "Conflates module-level callable (clean) with auto-fire (cross-cutting concern)"
  - id: B
    summary: "Library-only port — L0 (full) + L1 prompt+parser+windowing (callable, no auto-invoke) + TranscriptCache + cleanText + skill"
    pros:
      - "Clean module separation: packages/observability/ = pure library code; no harness wire-in"
      - "Phase 1+ caller (Claude API client or CLI) can dispatch L1 when ready"
      - "Smoke-testable today via fixture transcript without external CLI"
      - "Aligned with stockforge \"NO LLM math\" — module exposes prompt builder; doesn't itself compute or store LLM output"
      - "Python module also enables Phase 1+ sync-tracker SQLite migration (D-006 § Open Questions)"
    cons:
      - "L1 extraction not auto-fired in Phase 0; Phase 1+ wire-in still needed"
      - "Slightly larger LOC budget vs minimal stub since prompt builder + parser must work end-to-end on fixtures"
  - id: C
    summary: "Defer Track 8b to Phase 1+; ship only L0 stub at packages/observability/__init__.py"
    pros:
      - "Smallest S18 scope; no port from TS"
    cons:
      - "Breaks D-002 REV-2 § D session sequencing (S17 → S18 = Track 8b)"
      - "Blocks D-006 Phase 1+ SQLite migration path (still needs python+sqlite3 module to exist)"
      - "Loses the proprietary-data moat (Charter Principle 4) — every session uncaptured"

chosen: B
chosen_rationale: |
  Library-only port preserves Track 8b deliverables per D-002 REV-2 § A while keeping the
  module Phase-0-clean: zero external-CLI subprocess invocation; zero harness wire-in. Phase 1+
  callers (Claude API client, CLI bridge, batch indexer) compose L1 dispatch on top of the
  library. This matches stockforge's NO-LLM-math discipline (module exposes the prompt builder,
  but doesn't generate the numbers/memories itself), keeps L-S11-1 portability burden on bash
  hooks (not Python application code), and ships the python+sqlite3 substrate enabling D-006
  Phase 1+ TSV → SQLite migration. Smoke test runs end-to-end on a fixture transcript, proving
  the L0 regex chain + cleanText + windowing + parser all behave as ported.

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-04-29
    via: agent-workspace/memory/sessions/2026-04-29-session-18.md
  - actor: agent
    action: ACCEPTED
    at: 2026-04-29
    via: "IMPL-tier self-decide per D-003 § Open Questions doctrine + autonomous_mode=true (S15-close user correction); subject to drift audit + sandwich-verifier cross-check at Phase 0 closeout"

verified_by:
  - mechanism: smoke-test
    at: 2026-04-29
    result: PENDING

affects:
  charter: false
  spec_files: []
  code_paths:
    - packages/observability/__init__.py
    - packages/observability/extract_l0.py
    - packages/observability/extract_l1.py
    - packages/observability/clean_text.py
    - packages/observability/transcript_cache.py
    - packages/observability/tests/test_extract_l0.py
    - packages/observability/tests/test_extract_l1.py
    - packages/observability/tests/test_transcript_cache.py
    - packages/observability/tests/fixtures/sample-transcript.jsonl
    - .claude/skills/session-memory-l0-l1/SKILL.md
  config_files: []
  other_decisions:
    - D-006

depends_on:
  - D-002
  - D-003
  - D-005
  - D-006

supersedes: null
superseded_by: null

defer_cycles: 0
re_attempt_prereq: |
  N/A — direct ACCEPTED via IMPL-tier self-decide.

tags: ["phase-0", "track-8b", "observability", "memory-extraction", "harness", "vn-extension"]
---

# Decision 007 — Track 8b Memory L0/L1 Extraction module

## Context

Phase 0 Harness Bootstrap S18 inherits D-002 REV-2 § A spec to port the `claude-sessions` L0/L1
memory extraction layer to Python under `packages/observability/`. This is the natural sequencer
follow-on to Track 8a (S17, D-006 confidence-score system) — both feed `agent-workspace/memory/`
as proprietary-data moat (Charter Principle 4) and dovetail with D-006 § Open Questions Phase 1+
SQLite migration (which needs the python+sqlite3 substrate this module establishes).

Source upstream is `C:/htdocs/orch-starter/claude-sessions/src/memory/` (TS):
- `extract-l0.ts:5-80` — pure regex; 5 extractor functions (file paths / commands / errors /
  failures / next step) + JSONL parser → `L0Data` aggregate.
- `extract-l1.ts:33-64` — `buildExtractionPrompt` + `parseLLMResponse`; the rest of the file
  (lines 100+) handles claude-CLI subprocess dispatch + multi-agent session-file discovery,
  out-of-scope for Phase 0 library port.
- `snapshot.ts:35-50` — `cleanText`: 9-pattern strip chain removes harness chatter (system-reminder,
  command-name, command-message, command-args, local-command-stdout, local-command-caveat,
  task-notification, context_window_protection, context_guidance) — CRITICAL or memories pollute
  with harness boilerplate.

Plus `Claude-Code-Agent-Monitor/server/lib/transcript-cache.js` — generic file-content cache with
mtime+size dual-check + byte-offset incremental reads + LRU eviction. Token-extraction specifics
(model usage, compaction entries) are out-of-scope for Track 8b; only the caching mechanic is
required.

**VN extension required** per D-002 REV-2 § A: extend FAILURE_PATTERNS with Vietnamese phrases:
"không hoạt động", "không hiệu quả", "đã thử nhưng", "không khả thi", "thất bại". This makes the
extractor capture failure signals from Vietnamese-language sessions (user's primary working
language; see auto-memory).

## Analysis

**LOC budget**: target ~400-600 Python LOC across 5 files + tests. No D1 budget concerns —
application code, not config files (skill/agent/command).

**Phase boundary for L1 dispatch**: D-002 REV-2 § A names "claude-sessions L1 prompt port" but
does not bind us to subprocess invocation in Phase 0. Charter Principle 9 (no LLM math; LLM only
interprets) and the broader Phase 0 harness-bootstrap charter (build the deterministic substrate
first; wire LLM dispatch when API client lands) push the L1 dispatch out to Phase 1+. Library
ships the prompt builder (deterministic) + parser (deterministic) + windowing (deterministic);
caller composes dispatch.

**cleanText fidelity**: snapshot.ts has 9 strip patterns; restore.ts has 7 (subset). Port the
9-pattern version (more complete) since stockforge SessionStart hooks emit
context_window_protection + context_guidance tags too.

**TranscriptCache scope**: claude-code-agent-monitor's TranscriptCache extracts tokens-by-model,
compaction entries, errors, turn durations, thinking-block counts — all out-of-scope for memory
extraction. Port only the caching mechanic (file-keyed cache; mtime+size dual-check; byte-offset
incremental; LRU eviction) and parameterize with a parser callable so consumers (extract_l0,
future telemetry consumers) plug their own logic.

**No L-S11-1 violation**: Python modules under `packages/observability/` are application code;
the L-S11-1 portability rule (bash + POSIX only) binds `scripts/hooks/*.sh`. Verified by
`bash scripts/hooks/bash-hook-lint.sh` Check 1 — scope is hooks, not packages/.

## Decision

Port the L0/L1 extraction layer to Python under `packages/observability/` with the following
file structure:

```
packages/observability/
├── __init__.py                  # exports L0Data, ChatMessage, extract_l0_*, build_extraction_prompt, parse_llm_response, TranscriptCache, clean_text
├── clean_text.py                # cleanText port (~30 LOC)
├── extract_l0.py                # extract-l0.ts port + VN extension (~180 LOC)
├── extract_l1.py                # buildExtractionPrompt + parseLLMResponse + windowing helpers (~120 LOC)
├── transcript_cache.py          # generic file-content cache (~110 LOC)
└── tests/
    ├── __init__.py
    ├── fixtures/
    │   └── sample-transcript.jsonl   # canned 60-message fixture for end-to-end smoke
    ├── test_clean_text.py            # 9-pattern strip + edge cases
    ├── test_extract_l0.py            # 5 extractor functions + VN failure patterns
    ├── test_extract_l1.py            # prompt builder + parser + windowing
    └── test_transcript_cache.py      # mtime+size cache hit/miss/incremental/LRU
```

Plus a thin discovery skill:

```
.claude/skills/session-memory-l0-l1/
└── SKILL.md                     # ≤150 LOC D1 ceiling; explains module purpose + 3 examples
```

### What this means concretely

- **L0 (extract_l0.py)**: pure Python regex; 5 functions matching `extract-l0.ts:5-80` API:
  `extract_file_paths`, `extract_commands`, `extract_errors`, `extract_failures`, `extract_next_step`.
  Plus aggregator `extract_l0_from_messages(messages, project, agent_id) -> L0Data` and JSONL
  parser `extract_l0_from_jsonl(lines, project) -> L0Data`. FAILURE_PATTERNS list extended with
  5 VN phrases (raw regex strings).
- **L1 (extract_l1.py)**: `build_extraction_prompt(messages) -> str`, `parse_llm_response(text) -> List[MemoryCandidate]`,
  `extract_messages_from_jsonl(path) -> List[ChatMessage]` with HEAD_COUNT=15 + TAIL_COUNT=35
  windowing.
- **cleanText (clean_text.py)**: single `clean_text(s: str) -> str` function with the 9 regex
  patterns from snapshot.ts.
- **TranscriptCache (transcript_cache.py)**: generic class with constructor `TranscriptCache(parser, max_entries=200)`;
  `extract(path) -> Any | None` calling the injected parser; mtime+size dual-check; byte-offset
  incremental; LRU eviction.
- **Skill (SKILL.md)**: agents-discoverable purpose + 3 examples (extract L0 from raw transcript,
  build L1 prompt for offline LLM dispatch, cache wrapper for repeat reads).
- **No claude-CLI subprocess** in Phase 0. Phase 1+ caller wires dispatch.
- **No auto-invocation hook**. Module is library; orchestration deferred.

## Why (Reasons)

1. **Charter Principle 4 (Proprietary data moat)**: every session ingested is data; module is the
   on-ramp. Without it, every session's content is uncaptured by the memory layer.
2. **Charter Principle 9 (No LLM math) + Phase 0 deterministic-first**: ship deterministic substrate
   (regex + windowing + parser) before wiring any LLM dispatch.
3. **D-002 REV-2 § A**: Track 8b spec is binding; library port is the spec-compliant
   interpretation that defers only the implementation-detail choice of WHEN/WHERE to invoke L1
   (orchestration is downstream concern).
4. **D-006 Phase 1+ migration enabler**: shipping python+sqlite3 module footprint here lets
   sync-tracker TSV → SQLite migration ride along when we wire Phase 1+ DB access.
5. **L-S11-1 portability scope**: bash hooks remain bash+POSIX; Python lives in `packages/`.
   No portability debt added.
6. **Smoke-testability today**: fixture transcript + 4 test files prove the chain works
   end-to-end without external CLI dependencies (claude binary, network, etc.).

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Python regex semantics differ from JS regex (e.g. lookahead, multiline, lastIndex) | Medium | Use Python `re` module with `re.MULTILINE | re.IGNORECASE` flags matching JS `/gim`; smoke-test verifies same output on canned fixture |
| L1 prompt text drifts from claude-sessions verbatim | Low | Test asserts prompt contains 6 category keywords (profile / preferences / entities / events / cases / patterns) + VN-relevant clause; spec authors can re-port quickly if ts source updates |
| TranscriptCache leaks memory under high-churn workload | Low | LRU cap at 200 entries (matches js source); cache.size + invalidate(path) + clear() exposed for explicit eviction |
| Library has no consumer in Phase 0 → dead code feeling | Medium | Skill ships with 3 examples; D-006 § Open Questions Phase 1+ migration explicitly references this module; Track 9 self-awareness consumer planned (S19/S20) |
| VN failure patterns false-positive on legit Vietnamese discussion (not failure) | Medium | Mitigation: keep patterns specific (require failure-context phrase, e.g. "không hoạt động" but not bare "không"); review false-positive rate at first dogfood week |
| L1 prompt instructs LLM to do classification (`category` field) — could be perceived as math | Low | Charter Principle 9 bans LLM-generated NUMBERS, not LLM-generated structured text. Memory extraction is text classification + summarization, charter-compliant. Document in skill. |

## Open Questions

(None for D-007 itself.)

**Phase 1+ followups** (not blocking S18):
- L1 dispatch wiring: Claude API client (Anthropic SDK) vs claude-CLI subprocess vs batch via Files API. Decide when Phase 1+ Claude API track lands.
- Memory storage: TSV (consistent with sync-tracker) or SQLite (D-006 Open Questions migration target). Recommend SQLite since L1 ingests larger structured-memory volumes than sync-tracker events.
- L0 + L1 auto-fire wire-in: SessionEnd hook (after current session JSONL stable) vs cron worker (offline ingest). Phase 1+ scope.

## Amendments (append-only)

(None yet.)

## Acceptance Record

- **2026-04-29**: PROPOSED + ACCEPTED in same turn by Claude Opus 4.7 via IMPL-tier self-decide doctrine (D-003 § Open Questions) + autonomous_mode=true (S15-close user correction). Subject to drift audit + sandwich-verifier cross-check at Phase 0 closeout.
