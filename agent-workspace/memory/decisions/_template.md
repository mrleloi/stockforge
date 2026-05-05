---
# === Canonical Decision Schema (12+ fields) ===
# Source: Decision 002 § Track 2 + REV-2 § B (R7 mitigation, Decision Provenance Chain pattern from msmdp).
# Every decision file MUST start with this frontmatter, even if some fields are empty.

id: D-NNN-slug                         # sequential; never reused; e.g. D-003-confidence-score-system
title: <human-readable title>          # short, declarative
date: YYYY-MM-DD                       # creation date (initial PROPOSED)
status: PROPOSED                       # PROPOSED | ACCEPTED | SUPERSEDED-BY-D-NNN | REVOKED
level: IMPL                            # CHARTER | SCOPE | ARCH | IMPL  (Q&A A4 thresholds: 0.99 / 0.90 / 0.80 / 0.50)

author:                                # who proposed
  - "Claude Opus 4.7"                  # model identity
  # - "user"                           # add when user-authored

# Source evidence — every claim must trace back somewhere.
# Use file:line or human-workspace path; quote a snippet if helpful.
source_evidence:
  - path: human-workspace/user_prompt/YYYYMMDD_NN_<slug>.txt
    quote: "<verbatim user phrase>"
  - path: agent-workspace/memory/patterns-discovered/SYNTHESIS.md
    section: <section anchor>
  # Add as many as needed. Empty list = INSUFFICIENT-EVIDENCE flag for drift-detector.

# How the underlying user input was classified by intent-classifier subagent
# (omit if decision did not originate from user prompt).
intent_classification:
  primary_intent: <SCOPE | DECISION | QUESTION | IDEA | CORRECTION | TRIVIAL>
  affects_charter: false
  affects_scope: false
  urgency: NORMAL                      # URGENT | NORMAL | LOW
  complexity_score: 0                  # 0-100; high = multi-Q&A bundle expected

# Options the agent considered before choosing.
options_considered:
  - id: A
    summary: <option name + 1-line description>
    pros: []
    cons: []
  - id: B
    summary: <option name + 1-line description>
    pros: []
    cons: []

chosen: A                              # which option id; or NEW if amended later
chosen_rationale: |
  <one paragraph: why this option, what it optimizes, what it sacrifices>

# Approval chain — captures human-in-the-loop touchpoints.
approval_chain:
  - actor: agent
    action: PROPOSED
    at: YYYY-MM-DD
    via: <session log file or chat>
  - actor: user
    action: ACCEPTED                   # or DEFERRED | REJECTED | AMENDED
    at: YYYY-MM-DD
    via: <chat reply phrase | user_prompt path | q-and-a path>

# What verified this decision still holds.
verified_by:
  - mechanism: <drift-check | post-mortem | smoke-test | sandwich-verifier | manual>
    at: YYYY-MM-DD
    result: PASS                       # PASS | FAIL | PARTIAL
  # Append as new verifications happen; do not delete.

# Blast radius.
affects:
  charter: false
  spec_files: []                       # e.g. specs/tier1-strategic/001-...
  code_paths: []                       # e.g. packages/observability/**
  config_files: []                     # e.g. .claude/settings.json
  other_decisions: []                  # downstream D-IDs

depends_on: []                         # upstream D-IDs (must be ACCEPTED for this to take effect)

supersedes: null                       # D-ID this replaces (and the old one's status becomes SUPERSEDED-BY-this)
superseded_by: null                    # set when this is replaced

# R7 mitigation (msmdp Decision Provenance Chain pattern):
# track how often a decision is deferred without resolution to detect can-kicking.
defer_cycles: 0                        # increment each time decision is paused/rolled forward
re_attempt_prereq: |
  <if status==DEFERRED or REVOKED, what must be true for re-attempt?>
  Default: N/A
# >3 defer_cycles → drift-detector raises alert (per REV-2 § C R7).

tags: []                               # free-form: e.g. ["phase-0", "harness", "provenance"]
---

# Decision NNN — <Title>

> Replace this template instantiation with actual content for the decision.
> Frontmatter above is BINDING; sections below are recommended structure.

## Context

<What problem motivated this decision? What constraints exist? Cite source_evidence inline using `[path:line]` format.>

## Analysis

<What did the agent investigate? What evidence did it gather? Reference patterns from `agent-workspace/memory/patterns-discovered/` if applicable.>

## Decision

<Restate the chosen option in concrete terms. Use lists, tables, or pseudo-code as needed.>

### What this means concretely

- <bullet point describing what changes>
- <bullet point describing what does NOT change>

## Why (Reasons)

1. <Reason 1, ideally tied to a charter principle or invariant ID>
2. <Reason 2>

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| <risk> | Low/Med/High | <mitigation> |

## Open Questions

<If status=PROPOSED and Q&A bundle is open, list the question IDs from `human-workspace/q-and-a/pending/`>

## Amendments (append-only)

> When this decision is partially revised in-place (REV-2, REV-3 …), record an entry here.
> Each entry includes: rev tag, date, trigger, summary of what changed, link to source evidence.

### REV-N (YYYY-MM-DD)

- **Trigger**: <what surfaced the need for amendment>
- **Authorization**: <who approved + via what channel>
- **Source artifacts**: <links>
- **Summary of changes**: <bullet list>

## Acceptance Record

> Update each time the status changes.

- **YYYY-MM-DD**: PROPOSED by <author>
- **YYYY-MM-DD**: ACCEPTED by user via "<chat phrase or user_prompt file>"
- **YYYY-MM-DD**: AMENDED REV-N (see Amendments)
- (or) **YYYY-MM-DD**: SUPERSEDED-BY-D-MMM
- (or) **YYYY-MM-DD**: REVOKED — see post-mortem `<path>`
