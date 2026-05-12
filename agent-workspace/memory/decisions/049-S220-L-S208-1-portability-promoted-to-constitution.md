---
decision_id: D-049
title: charter-L-S208-1-settings-portability.md promoted to agent-workspace/constitution/portability.md
status: ratified
created_at: 2026-05-09
created_via: S220 main-session opus47-max bundled deny-lift cycle
ratification_basis:
  - L-S208-1 settings.json hook-portability bug-fix LANDED S212 (production verified; 6 hooks rewritten with bash -c wrapper; HH-1 cache mtime advanced from stuck-at-2026-05-07 to 2026-05-09)
  - HOOK-TIER auto-detect LANDED S213 (settings-inline-env-prefix-detector.sh + 6/6 firing-test PASS)
  - SKILL-TIER LANDED S213 (vbw-check.md § Verify-Settings.json-Hook-Portability subroutine)
  - CHARTER-TIER proposal authored S213 in proposals/charter-L-S208-1-settings-portability.md
  - S220 deny-lift mode A approved (bundled with D-047 charter v1.1 + D-048 T5 protocol)
related_decisions:
  - D-038 (HH-C2 staleness watchdog — observed similar harness-portability gap class)
  - L-S214-1 promotion chain (canonical .session-hooks.log path — companion harness-portability rule)
related_lessons:
  - L-S11-1 Windows portability (umbrella; L-S208-1 is one specific instance)
  - L-S204-1 verify-before-trust (applied 5x across S208-S212 RC chain that surfaced this rule)
artifacts_modified:
  - mv agent-workspace/proposals/charter-L-S208-1-settings-portability.md → agent-workspace/constitution/portability.md (file content unchanged; 7220 bytes)
---

## Why ratified

L-S208-1 root-cause investigation surfaced a catastrophic-class harness regression: 3 SessionStart/UserPromptSubmit hooks silently dormant in real-production for 2 days because `.claude/settings.json` hook entries used bash-inline-env-var-prefix syntax that fails on Claude Code's Windows hook runtime (bash subshell tokenizes `CLAUDE_HOOK_EVENT=SessionStart bash ...` as separate command). HH-1 itself was a victim — the meta-detector for harness regressions could not detect its own dormancy. Bug-fix + hook-tier auto-detect + skill-tier subroutine all LANDED S212-S213; charter-tier proposal pending in proposals/ until S220.

S220 deny-lift cycle bundled this charter promotion with D-047 (Principle 11 ratification) + D-048 (T5 protocol promotion) per L-S43f-1/D-026 precedent (single permission ask = lower churn).

## Mechanism (S220 turn)

- `mv agent-workspace/proposals/charter-L-S208-1-settings-portability.md agent-workspace/constitution/portability.md` — file was untracked in git so plain mv used (will appear as new file in next commit per user's commit decision).
- File content UNCHANGED post-mv.
- `.claude/settings.json` deny block temp-lifted via `_S220_TEMP_LIFTED_` prefix per D-047 mechanism; restored same-turn.

## Empirical close-verify

- `ls -la agent-workspace/constitution/portability.md` = 7220 bytes ✓
- `agent-workspace/proposals/charter-L-S208-1-settings-portability.md` no longer exists ✓
- Companion hook `scripts/hooks/settings-inline-env-prefix-detector.sh` continues to operate (auto-detect anti-pattern at hook-authoring time) ✓
- vbw-check.md skill subroutine continues to reference the rule ✓

## Consequences

- L-S208-1 charter-tier promotion COMPLETE; full 4-tier chain (BUG-FIX → HOOK → SKILL → CHARTER) LANDED.
- Constitution layer now contains `portability.md` as standalone canonical reference for cross-platform hook authoring rules.
- L-S214-1 (canonical .session-hooks.log path; full BUG-FIX → HOOK → SKILL chain at S214-S216) is COMPANION rule under same portability umbrella; consider merging into portability.md content at next L-S214-1 charter cycle (deferred per cheapest-by-RISK).
- L-S11-1 (Windows portability cleanup, ≥150K dedicated session) is the natural follow-on per S220 PRIORITY 4.
- M-S173-1 deny continues to bind for FUTURE constitution writes (one-time bundled deny-lift consumed).
