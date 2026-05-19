---
level: WARN
status: pending
---

# html-separator-check — ALERT

HTML separator violations detected: 15

  - HS-R1 [ERR]: agent-workspace/memory/observations/2026-05-07-S172-phase-audit-reconciliation.md — multi-entry file (11 headings, 268 lines) has 0 <!-- ENTRY_END --> separators — must use HTML-comment separator pattern
  - HS-R1 [ERR]: agent-workspace/memory/observations/2026-05-07-S178-file-pattern-hook-compliance-audit.md — multi-entry file (9 headings, 208 lines) has 0 <!-- ENTRY_END --> separators — must use HTML-comment separator pattern
  - HS-R1 [ERR]: agent-workspace/memory/observations/2026-05-16-planner-upgrade-proposal.md — multi-entry file (14 headings, 281 lines) has 0 <!-- ENTRY_END --> separators — must use HTML-comment separator pattern
  - HS-R1 [ERR]: agent-workspace/memory/observations/intent-2026-04-29-UP04-3e294318.md — multi-entry file (3 headings, 217 lines) has 0 <!-- ENTRY_END --> separators — must use HTML-comment separator pattern
  - HS-R1 [ERR]: agent-workspace/memory/observations/master-planner-A-10-deepdive-nautilus_trader.md — multi-entry file (8 headings, 223 lines) has 0 <!-- ENTRY_END --> separators — must use HTML-comment separator pattern
  - HS-R1 [ERR]: agent-workspace/memory/observations/master-planner-A-14-deepdive-TradingAgents-CN.md — multi-entry file (11 headings, 474 lines) has 0 <!-- ENTRY_END --> separators — must use HTML-comment separator pattern
  - HS-R1 [ERR]: agent-workspace/memory/observations/sandwich-architect-S241-bear-quant-retry-arch.md — multi-entry file (11 headings, 548 lines) has 0 <!-- ENTRY_END --> separators — must use HTML-comment separator pattern
  - HS-R1 [ERR]: agent-workspace/memory/observations/sandwich-architect-S337-phase-d-theme-l-plan.md — multi-entry file (5 headings, 240 lines) has 0 <!-- ENTRY_END --> separators — must use HTML-comment separator pattern
  - HS-R1 [ERR]: agent-workspace/memory/observations/sandwich-architect-S364-phase-e2-sentiment-plan.md — multi-entry file (12 headings, 247 lines) has 0 <!-- ENTRY_END --> separators — must use HTML-comment separator pattern
  - HS-R1 [ERR]: agent-workspace/memory/observations/sandwich-dev-S320-plan015-S319a-batch-BDC.md — multi-entry file (10 headings, 242 lines) has 0 <!-- ENTRY_END --> separators — must use HTML-comment separator pattern
  - HS-R1 [ERR]: agent-workspace/memory/observations/sandwich-dev-S321-plan015-remediation.md — multi-entry file (12 headings, 256 lines) has 0 <!-- ENTRY_END --> separators — must use HTML-comment separator pattern
  - HS-R1 [ERR]: agent-workspace/memory/observations/sandwich-dev-S399-g3-claude-vision-adapter-impl.md — multi-entry file (8 headings, 224 lines) has 0 <!-- ENTRY_END --> separators — must use HTML-comment separator pattern
  - HS-R1 [ERR]: agent-workspace/memory/observations/sandwich-verifier-S243-D054-ratification.md — multi-entry file (14 headings, 287 lines) has 0 <!-- ENTRY_END --> separators — must use HTML-comment separator pattern
  - HS-R1 [ERR]: agent-workspace/memory/observations/sandwich-verifier-S64-BC-6.md — multi-entry file (7 headings, 266 lines) has 0 <!-- ENTRY_END --> separators — must use HTML-comment separator pattern
  - HS-R1 [ERR]: agent-workspace/memory/post-mortems/2026-05-05-phase-2.5-empirical-firing-gap.md — multi-entry file (11 headings, 284 lines) has 0 <!-- ENTRY_END --> separators — must use HTML-comment separator pattern

## Fix guidance
- HS-R1: Add "<!-- ENTRY_END -->" separator between entries in append-only memory files
  Exact format: two blank lines, then <!-- ENTRY_END -->, then two blank lines
- HS-R2: Fix malformed separator: must be exactly <!-- ENTRY_END --> (with spaces)
- HS-R3: Remove naive ASCII separators (---/***) between entries; use <!-- ENTRY_END -->

See ADR: agent-workspace/memory/decisions/063-html-comment-separator-doctrine.md

Rationale: HTML comments are forgery-proof (LLM prose cannot emit them) and
invisible to markdown renderers. Source: TradingAgents memory.py:13-14.
