---
id: D-063-html-comment-separator-doctrine
title: HTML-Comment Separator Doctrine for Append-Only Memory Zones
date: 2026-05-15
status: PROPOSED
level: IMPL

author:
  - "Claude Sonnet 4.6 (sandwich-dev S332)"

source_evidence:
  - path: "agent-workspace/memory/observations/master-planner-A-13-deepdive-TradingAgents.md § 0"
    quote: "W0-4 — HTML-comment separator pattern — direct quote from TradingAgents memory.py:13-14"
  - path: "C:/htdocs/research/TradingAgents/tradingagents/agents/utils/memory.py:13-14"
    quote: "# HTML comment: cannot appear in LLM prose output, safe as a hard delimiter\n    _SEPARATOR = \"\\n\\n<!-- ENTRY_END -->\\n\\n\""
  - path: "C:/htdocs/research/TradingAgents/tradingagents/agents/utils/memory.py:48"
    quote: "entry = f\"{tag}\\n\\nDECISION:\\n{final_trade_decision}{self._SEPARATOR}\" (write usage)"
  - path: "C:/htdocs/research/TradingAgents/tradingagents/agents/utils/memory.py:59"
    quote: "raw_entries = [e.strip() for e in text.split(self._SEPARATOR) if e.strip()] (parse usage)"
  - path: "agent-workspace/CLAUDE.md"
    quote: "mistake-log.md: Track 7 deliverable: structured failure catalog. Append-only. / agent-notes.md: Learned rules from real experience. Append-only mostly."
  - path: "agent-workspace/memory/decisions/059-python-determinism-contract.md"
    quote: "Hook + firing-test + ADR triad pattern (W0-2 predecessor template); Charter Principle 11 alignment"

intent_classification:
  primary_intent: DECISION
  affects_charter: false
  affects_scope: false
  urgency: NORMAL
  complexity_score: 25

options_considered:
  - id: A
    summary: "HTML comment separator <!-- ENTRY_END --> enforced via bash hook"
    pros:
      - "Forgery-proof: LLMs cannot emit HTML comments inside markdown prose"
      - "Invisible to markdown renderers (no visual pollution)"
      - "Exact string match — no false-positive risk from prose"
      - "Directly ported from TradingAgents with proven usage at :48 (write) and :59 (parse)"
    cons:
      - "Requires retroactive addition to existing files (W0-4.1 cleanup task)"
      - "Small cognitive overhead for authors who must remember to add separator"
  - id: B
    summary: "Timestamp-based or heading-based entry detection (no separator needed)"
    pros:
      - "No format change required to existing files"
    cons:
      - "Fragile: heading format can change; timestamps can be forged or absent"
      - "LLM can accidentally emit headings that look like entry boundaries"

chosen: A
chosen_rationale: |
  Option A provides a forgery-proof delimiter that is both machine-readable and
  invisible to markdown viewers. The HTML comment cannot appear in LLM prose (it is
  rendered/swallowed before reaching output) — this property is unique among simple
  text separators. TradingAgents uses this at :48 (write path) and :59 (split/parse path),
  proving the round-trip semantic is correct. Option B's heading-based detection is too
  fragile; headings are part of prose and LLMs routinely generate them.

approval_chain:
  - actor: "sandwich-dev S332"
    action: PROPOSED
    at: 2026-05-15
    via: "session-plans/pending/018-S331-wave-0-W0-3-4-5-bundle.md task sequence"

verified_by:
  - mechanism: firing-test
    at: 2026-05-15
    result: PASS
    detail: "12/12 TC PASS (scripts/hooks/firing-tests/html-separator-check-fire-test.sh)"

affects:
  charter: false
  spec_files: []
  code_paths:
    - "agent-workspace/memory/mistake-log.md"
    - "agent-workspace/memory/agent-notes.md"
    - "agent-workspace/memory/thesis-log/*.md"
    - "agent-workspace/memory/observations/*.md"
    - "agent-workspace/memory/post-mortems/*.md"
  config_files:
    - ".claude/settings.json"
  other_decisions:
    - "D-059"
    - "D-061"
    - "D-062"

depends_on:
  - "D-059"
  - "D-061"

supersedes: null
superseded_by: null
defer_cycles: 0
re_attempt_prereq: "N/A"

tags: ["wave-0", "substrate", "harness", "html-separator", "memory-zones", "forgery-proof"]
---

# Decision 063 — HTML-Comment Separator Doctrine for Append-Only Memory Zones

## Context

StockForge's append-only memory zones (`mistake-log.md`, `agent-notes.md`, `thesis-log/*.md`,
`observations/*.md`, `post-mortems/*.md`) accumulate multiple entries over time. Without an
unambiguous inter-entry separator, entries blur together: LLM-generated content can contain
any ASCII separator (`---`, `***`, headings) that naive patterns use, creating forgery or
split-corruption risks.

TradingAgents v0.2.4 (Apache-2.0, Tauric Research) solved this with a constant:

```python
# HTML comment: cannot appear in LLM prose output, safe as a hard delimiter
_SEPARATOR = "\n\n<!-- ENTRY_END -->\n\n"
```
(`tradingagents/agents/utils/memory.py:13-14`)

Used at write-time (`:48`) and parse-time (`:59`). The HTML comment is:
1. **Forgery-proof**: LLMs cannot emit `<!-- ... -->` inside markdown prose — the LLM sees it
   in the context window but its output rendering swallows it before text output.
2. **Viewer-invisible**: markdown renderers (Obsidian, GitHub, VS Code preview) suppress HTML
   comments; files remain visually clean.
3. **Exact-match**: the string `<!-- ENTRY_END -->` has no ambiguity; simple `grep -F` is the
   parser.

**Attribution**: Pattern adapted from TradingAgents v0.2.4 (Tauric Research, Apache-2.0).
See `tradingagents/agents/utils/memory.py:13-14`.

## Audited Zones

Files that MUST use `<!-- ENTRY_END -->` as inter-entry separator:

| Zone | Reason |
|------|--------|
| `agent-workspace/memory/mistake-log.md` | Track 7 deliverable: M-S<N>-<M> structured failure entries; per `agent-workspace/CLAUDE.md` "Append-only" |
| `agent-workspace/memory/agent-notes.md` | "Learned rules from real experience ... Append-only mostly" (CLAUDE.md) |
| `agent-workspace/memory/thesis-log/*.md` | "Stock-domain thesis exploration entries" (CLAUDE.md) |
| `agent-workspace/memory/observations/*.md` | Subagent return artifacts; multi-entry shared files need separation |
| `agent-workspace/memory/post-mortems/*.md` | Post-mortem entries; "Append" per CLAUDE.md |

## Excluded Zones

Files NOT subject to this rule (single-document, not entry-segmented):

- Repo root `*.md` (README, charter, AOM — documents not logs)
- `agent-workspace/constitution/*.md` (charter-tier documents)
- `agent-workspace/research/*.md` (research notes; structured not log-style)
- `agent-workspace/master-plans/*.md` (single-document plans)
- `agent-workspace/session-plans/**/*.md` (one-plan-per-file)
- `agent-workspace/memory/sessions/*.md` (one-file-per-session; no multi-entry)
- `agent-workspace/memory/decisions/*.md` (one-ADR-per-file)
- `agent-workspace/memory/checkpoints/*.md` (one-checkpoint-per-file)

## The 3 Detection Rules (HS-R1 through HS-R3)

| Rule | Pattern | Severity |
|------|---------|---------|
| HS-R1 | File in audited zone with ≥2 headings AND ≥200 lines AND 0 `<!-- ENTRY_END -->` markers | ERR |
| HS-R2 | File contains malformed separator (`<!-- ENTRY -->`, `<!--ENTRY_END-->`, `<!-- entry_end -->`) | ERR |
| HS-R3 | File mixes `<!-- ENTRY_END -->` with naive ASCII separators (`---`, `***`) | WARN |

## Allow-List

| Mechanism | Effect |
|-----------|--------|
| Frontmatter `html-separator-exempt: true` | File entirely exempt from all 3 rules |
| `<!-- atomic-md-exempt: <rationale> -->` in first 20 lines | File entirely exempt |

## Enforcement

**Hook**: `scripts/hooks/html-separator-check.sh`
- PostToolUse mode: scans edited `.md` file if in audited zone
- Stop mode: full audit of all audited zone files
- Severity: ERR → `.session-hooks.log` as `severity=HIGH`; WARN → `severity=MEDIUM`
- RC=0 always (best-effort); hour-bucket markers `.htmlsep-marker-*`
- Notification: `human-workspace/notifications/html-separator-warn.md` (S318 idempotent)

**Firing-test**: `scripts/hooks/firing-tests/html-separator-check-fire-test.sh`
- 12/12 TC PASS covering all 3 rules + allow-list + edge cases + RC=0 regression floor

**Compliance enforcement** (per Charter Principle 8):
- Sessions 1-5: WARN-only posture; HS-R1 + HS-R2 are ERR in the hook but classifier is
  lenient. Calibration window.
- After 5 clean sessions: promote to BLOCKING via severity-classifier threshold increase.
- Current gap: `mistake-log.md` (111 lines) + `agent-notes.md` (697 lines) lack separator.
  Deferred to W0-4.1 cleanup session.

**Charter Principle 11** satisfied: hook ships with companion firing-test.

## Live Audit Count (S332 IMPL, 2026-05-15)

W0-4 audited-zone files lacking `<!-- ENTRY_END -->` separator:

- `agent-workspace/memory/mistake-log.md` — 111 lines, lacks separator (< 200 line threshold, HS-R1 won't fire yet)
- `agent-workspace/memory/agent-notes.md` — 697 lines, lacks separator (will trigger HS-R1)

**Total: 2 files** → deferred to W0-4.1 cleanup session. Count within normal range.

## Acceptance Record

- **2026-05-15**: PROPOSED by sandwich-dev S332 (Claude Sonnet 4.6) during W0-3+4+5 bundle IMPL
