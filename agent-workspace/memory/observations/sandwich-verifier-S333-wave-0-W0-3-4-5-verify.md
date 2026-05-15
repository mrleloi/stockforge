---
observation_id: sandwich-verifier-S333-wave-0-W0-3-4-5-verify
type: sandwich-verifier-output
plan: agent-workspace/session-plans/pending/018-S331-wave-0-W0-3-4-5-bundle.md
session: S333
dispatch_agentid: a0fd97df308542f16
dispatch_session: e9b3af12-312b-4a44-8e6a-ff58e518c0eb
dispatch_duration_ms: 1637433
dispatch_tokens: 198273
dispatch_tool_uses: 103
dispatch_model: claude-opus-4-7
dispatch_persona: sandwich-verifier (AP-1 fresh-context Opus)
under_review: 9e81fcb "S332: W0-3+4+5 — atomic-write + html-separator + path-safety hooks + helpers + ADRs (D-062/063/064)"
observed_by: main-session-recovery-write (verifier has Read/Glob/Grep/Bash but NO Write — same procedural-incomplete pattern as S330 verifier per S327-checkpoint)
captured_at: 2026-05-15
---

# S333 sandwich-verifier — W0-3 + W0-4 + W0-5 bundle review

## VERDICT

**PASS-WITH-CONCERNS** — **MERGE-ELIGIBLE: YES**

Substrate ships. Hooks syntactically valid; firing-tests green; ADRs schema-valid; settings.json wired; mypy/ruff/pytest/bash-hook-lint all clean. The 2 Important defects are bookkeeping-accuracy issues (false attestations in ADR `## Live Audit Count` sections), not substrate gaps. Remediation can land as a tight follow-up commit (ADR text edits + optionally W0-3 hook regex widening) without re-opening the plan.

## Critical defects (block merge)

NONE.

## Important defects (merge-eligible, follow-up required)

### I-1. D-062 live audit count is undetectable by the hook itself

`agent-workspace/memory/decisions/062-atomic-write-doctrine.md:188-197` lists 6 production W0-3 violations by file:line. Empirical re-run at HEAD: `bash scripts/hooks/atomic-write-check.sh < /dev/null` → log message `atomic-write-check: OK (0 violations across 346 file(s))`.

**Root cause**: AW-R2 regex requires the audited extension (`.json`/`.md`/`.csv`/etc.) to appear on the SAME LINE as the `.write_text()` call. The 6 cited production files use a 2-line `assign + write` pattern:
- Line N: `path = output_dir / f"...md"` (variable carries the extension)
- Line N+M: `path.write_text(...)` (call site lacks any extension)

`audited_ext_re.search(stripped)` only inspects the call-site line — `path` has no extension on that line, so the hook returns no violation.

**Evidence**:
- `packages/infrastructure/influence/llm_recommendation_extractor.py:466` calls `fname.write_text(payload, encoding="utf-8")` — no `.json` on line 466; assigned at line 457 as `fname = _RAW_RESPONSE_DIR / f"{ts}-{url_hash}.json"`.
- Same pattern in `apps/cli/ingest_fundamentals_vn30.py:199`, `ingest_news_cafef.py:309`, `ingest_vhm.py:138`, `ingest_vn30.py:202`, `validate_thesis.py:153`.

**Impact**: D-062's hand-curated "6 violations" list does not reflect what the hook can detect. The doctrine ships with an unenforceable detector for the documented real-world cases.

**Recommended fix**: track variable→extension flow across lines (file-level analysis) OR widen AW-R2 to fire on any `.write_text()` in production layers and rely on inline marker exemption for legitimate cases. Defer to W0-3.1 cleanup session; surface as L-S333-1 promotion candidate. Evidence: `scripts/hooks/atomic-write-check.sh:104-108` (Python helper R2 logic).

### I-2. D-063 live audit count is dramatically wrong

`agent-workspace/memory/decisions/063-html-comment-separator-doctrine.md:194-197` and the session log claim "Total: 2 files" lacking separator (mistake-log.md + agent-notes.md). Empirical re-run at HEAD: `bash scripts/hooks/html-separator-check.sh < /dev/null` → **57 HS-R1 emissions across 29 unique files**.

**Examples observed**: `thesis-log/2026-05-01-FPT`, `2026-05-09-BID`, `2026-05-10-CTG`, `2026-05-10-GAS`, ...; `observations/2026-05-05-harness-alignment-audit`, `observations/2026-05-05-root-cause-3-axes`, `observations/2026-05-07-S172`, `observations/sandwich-verifier-S243`, `sandwich-verifier-S64`; `post-mortems/2026-05-05-phase-2.5`; etc.

**Impact**: dev's DC-AGG-12 attestation off by an order of magnitude. W0-4.1 cleanup scope is now ~29 files, not 2. Plan-018 RM10 (count-shock) explicit rule: "If any count >10, recommend separate cleanup session per W0-2 → W0-2.1 precedent."

**Recommended fix**: rewrite D-063 § "Live Audit Count" with the empirically-observed 29-file list; flag W0-4.1 scope expansion in current-execution.md. Evidence: `agent-workspace/memory/.session-hooks.log` after fresh run; 29 unique files via `grep "HS-R" ... | grep -oE "file=[^ ]+" | sort -u | wc -l`.

## Minor defects (track + defer)

### M-1. `run-all.sh` semantic miscount in dev handoff note 5
Dev claims "run-all.sh should show 148+ TC (103 baseline + 15 + 12 + 18)". Actual: `bash scripts/hooks/firing-tests/run-all.sh` → `firing-test suite: 107/107 PASS (elapsed 355s)`. Orchestrator counts FILES not TCs. Baseline at HEAD~1 was 104 fire-test files, HEAD = 107 (+3 new). Suite reports 107/107 PASS files. Internal TC totals (15/12/18 = 45 new) visible only per-fire-test. No regression; conceptual misframe in handoff note.

### M-2. Basename allow-list `*_test.py` overly permissive
`scripts/hooks/atomic-write-check.sh:216-218` + `scripts/hooks/path-safety-check.sh:230-232` both use `case "$rel_basename" in test_*.py|*_test.py)`. Files matching `*_test.py` (suffix) are completely exempt. A future `path_test.py` utility module would be silently skipped. No current production match. Plan recipe (§ Allow-list zones, line 278) only mandated `**/test_*.py` (prefix). Defer to L-S333-3.

### M-3. Stop-chain ordering inherited issue
`.claude/settings.json:420` puts `severity-classifier.sh` BEFORE `python-determinism-check.sh` (428) and the 3 new hooks (432/436/440). Plan-018 said "severity-classifier MUST run AFTER both deterministic detectors". Actual wiring runs classifier first → classifier classifies last-turn's emissions, not this-turn's. **Inherited from W0-2 ordering** (not introduced by S332). Defer.

### M-4. `_rejects_unc` does not detect URL schemes
`packages/_shared/path_safety.py:45-61` checks only `\\` and `//` prefixes — `file://`, `http://` bypass. Faithful to Vibe-Trading upstream (`agent/src/tools/path_utils.py:27-30`). Plan-018 § Out-of-scope item 10 explicitly punts `\\?\C:\...` and similar edges; extending to URL schemes is consistent with this deferral.

## What PASSES empirically (verification log)

- 3 firing-tests independently: 15/15 + 12/12 + 18/18 PASS
- `bash scripts/hooks/firing-tests/run-all.sh` → 107/107 PASS (elapsed 355s)
- `bash scripts/hooks/bash-hook-lint.sh` → 0 violations
- `python -m pytest packages/ apps/ -q` → 914 passed (dev reported 892 = net add, no regression)
- `python -m pytest packages/_shared/test_path_safety.py -q` → 23/23 PASS
- `python -m mypy --strict --explicit-package-bases packages/_shared/path_safety.py packages/_shared/test_path_safety.py` → clean
- `python -m ruff check packages/_shared/` → All checks passed
- `python -c "import json; json.load(open('.claude/settings.json'))"` → JSON valid
- `bash scripts/hooks/python-determinism-check.sh < /dev/null` → RC=0; W0-2 baseline preserved
- `bash -n` on each new hook → RC=0 × 3
- D-062 source_evidence = 7 cites (target ≥6) ✓
- D-063 source_evidence = 6 cites (target ≥6) ✓
- D-064 source_evidence = 10 cites (target ≥7) ✓
- depends_on chains: all 3 ADRs cite D-059 + D-061 ✓
- License attribution: D-062/D-063 cite Apache-2.0 TradingAgents; D-064 + path_safety.py cite MIT Vibe-Trading ✓
- All 3 ADRs `status: PROPOSED`, `level: IMPL` ✓
- mistake-log.md:31 = M-S332-NONE entry exists ✓ (but see M-S332-1 candidate below)
- TC9 fresh-sandbox isolation works (separate sandboxes for TC9/TC15/TC12/TC18) ✓
- P1b domain filter: only fires in `packages/domain/*` paths ✓
- I-S1 (NO LLM math): all 3 hooks deterministic ✓
- I-S2 (sourced claims): each ADR has 6+ source cites with file:line ✓
- Inline `# atomic-write-ok:` and `# path-safety-ok:` markers correctly line-scoped ✓
- Basename allow-list correctly fires on `packages/infra/test_target/production.py` (directory `test_target` not whitelisted) ✓
- 3 new hook files wired AFTER python-determinism-check in both PostToolUse + Stop chains ✓ (relative order correct; absolute classifier-first issue = M-3 inherited)
- 65 DoD criteria largely met; the 2 Important defects are within DC-AGG-12 sub-item (attestation accuracy)

## Plan-018 mv recommendation

**Move `pending/` → `completed/018-S331-wave-0-W0-3-4-5-bundle.md`.**

Substrate functionally ships. The 2 Important defects are accuracy fixes (ADR `## Live Audit Count` rewrites + optional AW-R2 regex widening), executable as a small follow-up commit. No need to re-open the plan.

## Mistake-log addition (M-S332-1 candidate)

Dev declared `M-S332-NONE` at `mistake-log.md:31`, but DC-AGG-12 attestations in D-062 + D-063 are false:
- D-062 claims "6 violations" — hook reports 0 (regex blind spot on 2-line assign+write pattern; counts came from manual grep).
- D-063 claims "2 files" — hook reports 29 unique files.

**Proposed mistake-log entry**: `M-S332-1 (FOUND-AT-S333) | S332 | medium | DC-AGG-12 live audit attestations in D-062 + D-063 do not match hook output at HEAD. D-062 says 6 violations; hook reports 0 (regex blindspot on 2-line assign+write pattern). D-063 says 2 files; hook reports 29 files. Root cause: dev hand-curated live-audit counts via manual grep instead of running the hook in Stop mode and reading the count from the log. Prevention: live-audit count fields in any future detector ADR MUST be sourced from the hook's own Stop-mode emission (read .session-hooks.log post-run; quote the count + summary line directly). Fix: D-062 + D-063 § "Live Audit Count" sections need rewrite to match hook reality; D-062's 6-file list moves to a "Known patterns the hook regex cannot detect" subsection with a recommendation to widen AW-R2 or augment with file-level analysis.`

## Promotion candidates (HOLD-FOR-PROMOTION; AP-23 1st-instance — promote on 2nd)

### L-S333-1 — Live-audit attestation discipline
Live-audit attestation must be empirically re-run from the ACTUAL hook output, not constructed by ad-hoc developer grep. When a hook ships with its detection regex, the audit count quoted in the companion ADR `## Live Audit Count` section MUST match what the hook itself reports in Stop-mode at HEAD. Mismatch = false attestation. Detection: post-commit hook that re-runs each newly-wired hook in Stop-mode and diffs the reported count against the ADR's quoted count. Promote if 2nd instance appears.

### L-S333-2 — Line-by-line regex blind spot for 2-line assign+write
Banned-pattern detectors operating on Python source line-by-line via regex have a recurring blind spot for 2-line `assign + write` patterns (variable name carries the extension; call site does not). Fixes: (a) expand regex to look back N lines for the binding; (b) widen rule to fire on bare `.write_text(...)` and rely on inline marker exemption. AST-based analysis (ruff plugin) is canonical but out-of-scope per Option B in D-062 § options_considered.

### L-S333-3 — Suffix-pattern allow-list overreach
Basename allow-list patterns like `*_test.py` (suffix) match any filename ending in `_test.py`, including production utility modules whose name happens to end that way. Prefer prefix-only `test_*.py` unless a deliberate suffix-test discovery convention exists in pytest config. Cross-check against `pyproject.toml` or `pytest.ini` testpaths/python_files config before widening.

## Files reviewed (absolute paths)

- Plan: `C:\htdocs\stockforge\agent-workspace\session-plans\pending\018-S331-wave-0-W0-3-4-5-bundle.md`
- Dev observation: `C:\htdocs\stockforge\agent-workspace\memory\observations\sandwich-dev-S332-W0-3-4-5-bundle.md`
- Dev session log: `C:\htdocs\stockforge\agent-workspace\memory\sessions\2026-05-15-session-332.md`
- 3 hooks: `scripts\hooks\atomic-write-check.sh`, `html-separator-check.sh`, `path-safety-check.sh`
- 3 firing tests: `scripts\hooks\firing-tests\atomic-write-check-fire-test.sh`, `html-separator-check-fire-test.sh`, `path-safety-check-fire-test.sh`
- Helper module: `packages\_shared\path_safety.py` + `test_path_safety.py` + `__init__.py`
- 3 ADRs: `agent-workspace\memory\decisions\062-atomic-write-doctrine.md`, `063-html-comment-separator-doctrine.md`, `064-path-safety-5-invariant-contract.md`
- Settings: `.claude\settings.json` (lines 420-590 = Stop + PostToolUse chains)
- D-061: `agent-workspace\memory\decisions\061-wave-1-integration-ratification.md`
- Mistake log: `agent-workspace\memory\mistake-log.md` (line 31 = M-S332-NONE)

## Recommended next action for main (S333-orchestrator)

1. **mv plan-018 pending→completed** (substrate ships PASS-WITH-CONCERNS).
2. **Append M-S332-1 to mistake-log.md** (above text).
3. **Append L-S333-1/2/3 to agent-notes.md digest** (HOLD-FOR-PROMOTION, AP-23 1st instance).
4. **Update current-execution.md**: W0-3/W0-4/W0-5 status → SHIPPED-VERIFIED PASS-WITH-CONCERNS; flag W0-4.1 cleanup scope expansion (29 files, not 2) for future session.
5. **Dispatch S334 sandwich-dev** (background, fresh-context per AP-1) for tight remediation scope:
   - Rewrite D-062 § "Live Audit Count" to reflect hook reality (0 detected) + add "Known patterns the hook regex cannot detect" subsection listing the 6 production cases.
   - Rewrite D-063 § "Live Audit Count" with the empirical 29-file list.
   - **Optional** (architect decides): widen AW-R2 to fire on any `.write_text()` in production layers OR add 2-line binding-aware variant.
6. **Charter Principle 11 firing-test mandate**: NOT triggered for ADR text edits (no new hook); only triggered if AW-R2 widening lands.
7. **After S334 ADR-correction commit**: Wave 0 substrate fully sealed (5 of 5 sub-waves SHIPPED + VERIFIED + clean attestations). Phase B closed. Next master-plan beat = Phase C (S335 Theme G charter/constitution write if confirmed needed per master plan § 6.3).
