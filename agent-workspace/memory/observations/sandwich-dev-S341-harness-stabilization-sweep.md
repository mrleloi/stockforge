---
observation_id: sandwich-dev-S341-harness-stabilization-sweep
session: S341
agent: sandwich-dev (background; Claude Sonnet 4.6)
date: 2026-05-16
plan: agent-workspace/session-plans/pending/021-S340-harness-stabilization-sweep.md
budget_used: ~100K (within 100-150K MULTI_TASK_IMPL envelope)
status: COMPLETE-PENDING-S342-VERIFY
---

# S341 — Harness Stabilization Sweep IMPL (observation)

## What I did

Executed all 7 sub-tracks per plan-021 § D decomposition. Summary by sub-track:

### D1 — Escalation-engine HIGH-spam fix (COMPLETE)

Root cause confirmed per architect VBW: all 3 source hooks regenerate their notification
files on every Stop/PostToolUse cycle via unconditional `} > "$NOTIF_FILE"` redirect.
The mtime-touch triggers severity-classifier (age <= 24h filter admits), which classifies
as HIGH via body-grep fallback (no `level:` frontmatter), triggering escalation-engine
UserPromptSubmit emit every cycle.

Fix applied (per plan Option (a)):
- `python-determinism-check.sh`: content-hash dedup (`sha256sum` compare) + `level: WARN` frontmatter added to notification block
- `html-separator-check.sh`: same fix
- `path-safety-check.sh`: same fix

The `level: WARN` frontmatter routes these to MEDIUM/DIGEST via `severity-classifier.sh:196-197`
branch rather than body-grep fallback. Content-hash prevents mtime-touch when violations
unchanged, breaking the per-cycle re-emit chain.

Firing tests:
- NEW `escalation-spam-dedup-fire-test.sh`: 6/6 PASS (all 3 hooks × level:WARN + mtime-dedup)
- Extended `python-determinism-check-fire-test.sh` TC13: 14/14 PASS
- Extended `html-separator-check-fire-test.sh` TC13: 14/14 PASS
- Extended `path-safety-check-fire-test.sh` TC19: 20/20 PASS

### D2 — Stale .tmp orphan cleanup + atomic-write trap EXIT hardening (COMPLETE)

Found 5 orphaned `.severity-state.tsv.tmp.*` files (architect said 6; `.tmp.898` absent on disk).
Removed all 5 via explicit rm -f list.

severity-classifier.sh changes:
- Added `find ... -mmin +60 -delete` janitor BEFORE tmp file creation (removes pre-existing stale orphans)
- Added `trap 'rm -f "$TMP" 2>/dev/null || true' EXIT` (D-062 atomic-write pattern)

Extended `severity-classifier-fire-test.sh` with TC7-TC9: 9/9 PASS.
ADR D-067 NOT drafted (janitor is inline in classifier, not a separate hook file; per plan §D2 criteria).

### D3 — Sandwich-architect dispatch-template PreToolUse hook (COMPLETE)

NEW `scripts/hooks/pre-dispatch-architect-commit-guard.sh`:
- Reads stdin JSON for `tool_name=Agent` + `subagent_type=sandwich-architect` + prompt
- Blocks (RC=2) when prompt contains `git commit|git add|git mv|git push`
- Override: `STOCKFORGE_ALLOW_ARCHITECT_COMMIT=1` env var
- Wired in `.claude/settings.json` PreToolUse AFTER destructive-command-guard.sh

NEW `pre-dispatch-architect-commit-guard-fire-test.sh`: 6/6 PASS.

### D4 — DEFER (AP-23 1st-instance HOLD)

No implementation per plan. Documented in plan-021 § D4. AP-7 revisit trigger: next
parallel-architect-dispatch detection OR Mode-D continue-injector audit.

### D5 — Repo root zero-byte stray cleanup + root cause hunt (PARTIAL)

Removed 22 stray zero-byte files at repo root (explicit list; all confirmed zero-byte via
`find -maxdepth 1 -size 0`). AQ-9 met: `find . -maxdepth 1 -size 0` count = 0.

Root cause hunt (30-min budget cap reached — NO ROOT CAUSE FOUND):
- Searched: unquoted redirect targets, missing `set -u`, hooks with unquoted variable expansion
- All hooks have `set -uo pipefail`
- All redirect targets are double-quoted
- The working hypothesis (cwd-relative-write via word-split on unquoted var) could not be
  confirmed in the 30-min window
- AP-7 revisit trigger: next stray file appearance at repo root

### D6 — F3 mypy noise fix (PARTIAL — rate_limiter.py only)

`apps/_shared/crawl/rate_limiter.py`:
- Added `from collections.abc import Callable` import
- Changed `_sleeper: object` → `_sleeper: Callable[[float], None]`
- Removed `# type: ignore[operator]` (now unnecessary)

`cafef_adapter.py`: NOT modified. The `rate_limiter: object`, `robots_manager: object`,
`raw_html_sink: object` fields cannot be given specific types without importing from `apps/`
into `packages/` (architecture violation per constitution layer boundaries). The
`type: ignore[union-attr]` annotations there remain legitimately required.

AQ-7 met: `grep -c "type: ignore" apps/_shared/crawl/rate_limiter.py` = 0.
All 968 tests pass. Ruff clean.

**FALSE POSITIVE NOTE for verifier**: `rate_limiter.py:11` docstring contains `datetime.now()`
as comment prose ("uses time.monotonic() not datetime.now()"). python-determinism-check.sh R1
rule flags this as a violation (hook regex doesn't distinguish comment context). Per plan
constraint, R1 regex NOT widened in this session. This is a pre-existing condition surfaced by
architect as a secondary anomaly. AP-7 revisit trigger: next time R1 violations appear with no
actual code violation.

### D7 — Template updates (COMPLETE)

All 3 sandwich-* templates edited per plan:
- `sandwich-dev.md`: STEP 0.10 baseline capture mandate in Phase 1 + OBSERVATION FILE
  mandatory section in Phase 5
- `sandwich-architect.md`: OBSERVATION FILE mandatory bullet in Output + "NO Bash tool"
  + commit constraint in Do NOT
- `sandwich-verifier.md`: verifier-has-no-Write recovery pattern in Phase 9

YAML frontmatter intact on all 3 (verified via `head -7`).

## Obstacles Encountered

1. **html-separator firing test TC03/TC04 initially failed**: setup_htmlsep() created too
   small a file (8 lines). HS-R1 requires `>=2 headings AND >=200 lines`. Fixed by generating
   200+ line test file with proper structure. All tests passing after fix.

2. **D3 TC5 (STOCKFORGE_ALLOW_ARCHITECT_COMMIT override) initially failed**: env var prefix
   `VAR=val printf ... | bash hook` didn't propagate on Windows. Fixed by using `export VAR;
   ... | bash hook; unset VAR` pattern. 6/6 PASS after fix.

3. **D6 cafef_adapter.py**: Cannot type optional DI fields without cross-layer import
   (apps/ → packages/ violates architecture). Only rate_limiter.py fixed. Documented as
   intentional deviation.

4. **D2 orphan count discrepancy**: Architect said 6 orphans; only 5 present on disk.
   No issue — cleaned all 5.

## Handoff Notes for Verifier (S342)

### Critical items to verify

**V1 group (D1)**:
- V1.2: Run each of the 3 source hooks in isolated tmpdir; `head -5` of resulting warn.md
  should show `level: WARN` frontmatter as 2nd line (after `---`)
- V1.3: Synthetic 3-cycle test — run python-determinism-check.sh 3x with same violation;
  check urgent.md has at most 1 new ESCALATION row across 3 runs (mtime unchanged on 2+)
- V1.4: `grep '^MEDIUM' agent-workspace/memory/.severity-state.tsv | grep warn.md`
  should show MEDIUM rows (not HIGH) after running severity-classifier
- V1.5 IMPORTANT: CRITICAL path must remain intact. The fix only adds `level: WARN` to
  notification files (notifications/), NOT to CRITICAL marker files (.autonomous-BLOCKED etc.)

**V2 group (D2)**:
- V2.1: `grep "trap.*EXIT" scripts/hooks/severity-classifier.sh` should return the new line
- V2.2: `ls agent-workspace/memory/.severity-state.tsv.tmp.*` should return 0 files
- V2.3: SIGTERM test may require background kill as done in TC8 of firing-test

**V3 group (D3)**:
- V3.4: Inject `{"tool_name":"Agent","tool_input":{"subagent_type":"sandwich-architect","prompt":"Please git commit the plan"}}` via stdin to hook; verify RC=2
- V3.5: Same with `subagent_type=sandwich-dev`; verify RC=0

**V4 group (D5)**:
- V4.2: Note root cause was NOT found (see D5 above); AP-7 trigger documented in session log

**V5 group (D6 + D7)**:
- V5.1: `grep -c "type: ignore" apps/_shared/crawl/rate_limiter.py` = 0
- V5.2: `grep "_sleeper:" apps/_shared/crawl/rate_limiter.py` shows `Callable[[float], None]`
- V5.3: 968 tests green
- V5.4: Check sandwich-dev.md for "STEP 0.10" and "OBSERVATION FILE" (mandatory text)
- V5.5: Check sandwich-architect.md for "NO Bash" and "OBSERVATION FILE" text

### Known issues / intentional decisions to verify

1. **D6 cafef_adapter.py not touched**: Intentional. Cross-layer typing constraint.
   `type: ignore[union-attr]` on cafef_adapter.py:116,120,129,135,162,170 remain valid.

2. **False positive R1 in rate_limiter.py:11**: `datetime.now()` in docstring comment.
   Hook will flag it as R1 violation. This is pre-existing / not introduced by D6.
   The fix is deferred (R1 regex widening is Phase D-N concern).

3. **D5 root cause not found**: Cleanup complete; no hook identified as the source.

4. **ADR D-067 not drafted**: Inline trap + janitor fix doesn't warrant new ADR per plan
   § D2 criteria ("only if D2.1.B new janitor hook lands as separate file").

### AQ verification grid

| AQ | Expected | Command |
|---|---|---|
| AQ-1 | No new ESCALATION in cycles 2+3 | 3-cycle synthetic test; tail urgent.md |
| AQ-2 | MEDIUM (not HIGH) for 3 warn notifs | `grep '^MEDIUM' .severity-state.tsv \| grep warn` |
| AQ-3 | .tmp.* count = 0 | `ls agent-workspace/memory/.severity-state.tsv.tmp.*` |
| AQ-4 | trap EXIT in severity-classifier.sh | `grep "trap.*EXIT" severity-classifier.sh` |
| AQ-5 | pre-dispatch hook wired + 6/6 pass | `grep -c pre-dispatch .claude/settings.json` |
| AQ-6 | architect has "no Bash" + obs-file | `grep -c "NO Bash\|OBSERVATION FILE" sandwich-architect.md` |
| AQ-7 | type: ignore count = 0 in rate_limiter | `grep -c "type: ignore" apps/_shared/crawl/rate_limiter.py` |
| AQ-8 | dev has STEP 0.10 + OBSERVATION FILE | `grep -c "STEP 0.10\|OBSERVATION FILE" sandwich-dev.md` |
| AQ-9 | zero-byte stray count = 0 | `find . -maxdepth 1 -size 0 -type f \| wc -l` |
| AQ-10 | no charter / no constitution writes | `git diff HEAD --name-only \| grep "PROJECT_CHARTER\|constitution/"` |

<!-- ENTRY_END -->
