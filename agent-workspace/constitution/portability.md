---
status: PROPOSAL
proposal_id: L-S208-1
created_at: 2026-05-09
created_via: S213 main-session opus47-max (Phase 3.5 L-S208-1 charter-tier promotion)
target_file: agent-workspace/constitution/portability.md (or new section in invariants.md)
ratification_path: USER-GATE via Cluster C charter Q&A bundle (pending; M-S173-1 deny holds)
companion_hooks_already_shipped:
  - scripts/hooks/settings-inline-env-prefix-detector.sh (Stop hook; auto-detect anti-pattern; 6/6 firing-test PASS at S212)
companion_skill_already_shipped:
  - .claude/commands/vbw-check.md § Verify-Settings.json-Hook-Portability subroutine (S213)
related_lessons:
  - L-S11-1 (Windows portability — pairs with this rule as cross-platform doctrine)
  - L-S204-1 (verify-before-trust — applied 5x across S208-S212 chain)
---

# Charter Amendment Proposal — Settings.json Hook Command Portability (L-S208-1)

## Why this proposal exists

The S208-S212 root-cause investigation surfaced a catastrophic-class harness regression: 3 SessionStart/UserPromptSubmit hooks (`harness-health-self-scan`, `idle-escape-detector`, `phase-status-coherence`) were silently dormant in real-production for 2 days (2026-05-07 → 2026-05-09), undetected by the very harness-health emergency-broadcast signal (HH-1) that was supposed to detect such regressions — because HH-1 itself was the dormant hook.

The mechanism: `.claude/settings.json` hook entries used **bash-inline-env-var-prefix syntax** in their `"command":` field — e.g.,
`"command": "CLAUDE_HOOK_EVENT=SessionStart bash \"$CLAUDE_PROJECT_DIR/scripts/hooks/harness-health-self-scan.sh\""`.

This pattern works in a bash subshell (where firing-tests run, giving false confidence) but **silently fails in Claude Code's Windows hook runtime**: the outer process tokenizes the command string and treats `CLAUDE_HOOK_EVENT=SessionStart` as a separate command, raising `CommandNotFoundException` (verified via direct PowerShell repro) and never launching the hook.

**Empirical evidence chain (S208-S212)**:
- S208: 5-fold cross-hook comparison — 3 hooks with inline-env-prefix have ZERO real-production emit lines since 2026-05-07; other hooks (no prefix) emit normally. PowerShell direct repro raises `CommandNotFoundException`. `bash -c '...'` wrapper repro succeeds.
- S209: env-dump diagnostic shipped (no-prefix vs with-prefix vs bashc-wrap variants).
- S210: diagnostic data confirmed `with-prefix` variant DOES NOT execute; `no-prefix` variant DOES; CLAUDE_HOOK_EVENT is NOT natively exported by Claude Code on Windows (falsifies simplest "drop the prefix" fix).
- S211: bashc-wrap variant production-runtime confirmed (CLAUDE_HOOK_EVENT correctly captured) → 6 production entries rewritten with `bash -c '...'` wrapper.
- S212: production verification at next UserPromptSubmit firing — all 3 previously-dormant hooks emitted `state=GREEN` lines; HH-1 cache mtime advanced from stuck-at-2026-05-07 to 2026-05-09. **Bug fully resolved + auto-detect Stop hook landed.**

This bug existed for 2 days because:
1. Firing-tests run in a bash subshell that DOES honor inline-env-prefix → false confidence.
2. HH-1 (the meta-detector for harness regressions) was itself a victim → no emergency broadcast.
3. No charter-tier rule prevented the anti-pattern at authoring time.

## Proposed charter rule

### Rule: Settings.json Hook Command Portability

> `.claude/settings.json` hook entries' `"command":` field MUST NOT begin with bash-inline-env-var-prefix syntax `VAR=val command` (e.g., `CLAUDE_HOOK_EVENT=SessionStart bash <path>`). This pattern silently fails in Claude Code's Windows hook runtime — the outer process tokenizer does NOT spawn a bash subshell to parse the prefix.
>
> When a hook needs a command-scoped environment variable, wrap the entire command in `bash -c '...'` to force bash subshell parsing. Examples:
>
> **Anti-pattern**:
> ```json
> "command": "CLAUDE_HOOK_EVENT=SessionStart bash \"$CLAUDE_PROJECT_DIR/scripts/hooks/foo.sh\""
> ```
>
> **Correct**:
> ```json
> "command": "bash -c 'CLAUDE_HOOK_EVENT=SessionStart bash \"$CLAUDE_PROJECT_DIR/scripts/hooks/foo.sh\"'"
> ```
>
> Or — if the env var has a sensible default in the hook script — drop the prefix entirely and rely on the hook's `EVENT="${CLAUDE_HOOK_EVENT:-<fallback>}"` self-detection.

### Auto-detection

`scripts/hooks/settings-inline-env-prefix-detector.sh` (Stop hook, shipped S212) greps `.claude/settings.json` at every turn-end for the regex `"command":\s*"[A-Z_][A-Z_0-9]*=` (uppercase-env-prefix anchored at command-string start, deliberately excluding the corrective `bash -c '...'` wrapper which starts with `bash` not an env-name token). State emit: `GREEN` (zero violations) / `WARN-N` (N violations with line-by-line output). Firing-test `scripts/hooks/firing-tests/settings-inline-env-prefix-detector-fire-test.sh` covers 3 scenarios × 6 assertions, currently 6/6 PASS.

### Skill enforcement

`.claude/commands/vbw-check.md` § `Verify-Settings.json-Hook-Portability (L-S208-1 subroutine)` (S213) defines a triple-check protocol applied at any spec/test/code/commit checkpoint touching `.claude/settings.json` hook entries: (1) anti-pattern grep, (2) wrap-if-env-needed, (3) JSON validity, (4) firing-test re-run.

## Pairing with L-S11-1

L-S11-1 codifies general Windows portability for hook scripts (line endings, path separators, shebang). L-S208-1 extends that doctrine specifically to `.claude/settings.json` invocation strings — a layer above hook script source. Both rules belong in the same charter section (`portability.md` or equivalent).

## Scope of binding

- BINDING on all future edits to `.claude/settings.json`.
- BINDING on harness-bootstrap scripts that generate `.claude/settings.json` (e.g., the `attach` skill).
- ADVISORY for non-Windows-deployment forks (the bug is Windows-runtime-specific; Linux/macOS bash-runtime honors inline-env-prefix), but the wrapped form works on all platforms uniformly so universal adoption is preferred.

## Promotion-readiness checklist

- [x] Hook-tier auto-detect shipped (S212; firing-test 6/6 PASS).
- [x] Skill-tier enforcement shipped (S213 vbw-check.md extension).
- [x] Production verification: 3 previously-dormant hooks emitting `GREEN` after fix (S212 12:57:35).
- [x] Empirical evidence chain documented across 5 sessions (S208-S212) with zero false-fix iterations.
- [ ] Charter-tier ratification — gated by Cluster C charter Q&A bundle to user (M-S173-1 deny on direct constitution writes).

## Suggested target file

Either:
- (a) Add new section `## Settings.json Portability` to existing `agent-workspace/constitution/architecture.md` or `invariants.md`, OR
- (b) Create new `agent-workspace/constitution/portability.md` consolidating L-S11-1 + L-S208-1 + future portability rules.

Recommend (b) — clean home for cross-platform doctrine; L-S11-1 currently scattered across agent-notes.

## Schedule into Cluster C charter Q&A mega-bundle

When user signals readiness for next charter Q&A bundle, include this proposal alongside other deferred charter-tier promotions (L-S204-1, L-S207-1, etc.). Single bundle → single decision point → minimum human-in-the-loop friction.

End of proposal.
