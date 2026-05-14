---
session: S314 (verifier)
date: 2026-05-14
type: VERIFY (fresh-context adversarial review)
plan_reviewed: agent-workspace/session-plans/pending/013-S313-wave-0-W0-1b-orphan-reescalate-and-schema-fix.md
dev_session_reviewed: agent-workspace/memory/sessions/2026-05-14-session-313.md
predecessor_verifier: S312 (PASS-WITH-CONCERNS; flagged F1+F2)
agent: sandwich-verifier (claude-opus-4-7)
verdict: PASS
---

# S314 Sandwich Verifier — W0-1b Re-Escalation + col7 Schema

## Verdict: PASS

All 6 acceptance criteria (D1-D6) empirically verified. L-S258-2 ROBUSTLY closed.

## V1 — Acceptance criteria

- D1 re-escalation: PASS — empirical 6-step cycle test confirmed re-emit + cadence + CRITICAL escalation work as specified. Marker SHA-keyed at scripts/hooks/observation-orphan-detector.sh:217-219; atomic noclobber at touch_marker() lines 137-148.
- D2 col7 last_transition_at: PASS — to_tsv_row/from_tsv_row at packages/domain/observation_lifecycle/fsm.py:208-287; is_orphan_candidate uses self.last_transition_at at fsm.py:179-188.
- D3 RECTIFIED comment: PASS — fsm.py:78-81.
- D4 TC12: PASS — empty CLAUDE_SESSION_ID guard at pre-checkpoint-close-verifier.sh:137 prevents inner loop.
- D5 session-311 correction: PASS — appended at session-311.md:133-138.
- D6 DoD: PASS — 58/58 pytest + 12/12 fire-test + mypy --strict clean + ruff clean + no commit.

## V2 — Dev handoff notes

- V2.1 (TC10 SHA cross-platform): PASS — hook + TC10 use identical SHA chain (sha256sum → shasum -a 256 → cksum fallback). On Windows Git Bash, both resolve to sha256sum first and produce identical hash.
- V2.2 (CRITICAL uses col1): PASS — line 225 uses age_days_from_ts col1, matches plan §D1 "after 30 days no resolution → CRITICAL" (total unresolved time, not since last transition).
- V2.3 (6-col upgrade change-triggered): PASS — lines 252-256 only write col7 to TMP_REGISTRY; line 260 only mv if CHANGED > 0. Empirically confirmed in V6.1 (production 5-col rows stayed 5-col).
- V2.4 (TC12 path): PASS — CLOSE_VERIFIER path resolves correctly on Windows; file is readable+executable.

## V3 — Empirical re-emit cycle (THE critical defect)

PASS — full 6-step cycle verified:
1. ORPHANED row + empty severity-state.tsv → STEP 2 emits HIGH + creates marker.
2. Severity-classifier purge simulated.
3. STEP 4 re-run within 6h → NO re-emit (correct cadence).
4. Backdate marker to 7h ago → STEP 6 re-emits HIGH + touches marker mtime to current.

This is the exact cycle that was BROKEN before W0-1b. L-S258-2 single-shot escalation gap is now closed.

## V4 — Charter compliance

- I-S1 NO LLM math: PASS — fsm.py is pure Python dataclass; no LLM calls in hook (bash only).
- DR1 no framework imports in domain: PASS — grep for pydantic/fastapi/streamlit returns nothing in packages/domain/observation_lifecycle/.
- NO commit: PASS — last commit is 378adad (baseline), no W0-1b commit.
- bash + POSIX only: PASS — hook is pure bash.
- Atomic noclobber: PASS — touch_marker uses `(set -C; ... > file)`.
- SPAWN-CONTEXT marker: PASS — present in both hook and fire-test headers.

## V5 — Regression

- pytest: 58/58 PASS
- orphan-detector fire-test: 12/12 PASS
- severity-classifier fire-test: 5/5 PASS
- escalation-engine fire-test: 7/7 PASS
- autonomous-block-enforcer fire-test: 11/11 PASS
- telegram-push fire-test: 3/3 PASS
- mypy --strict --explicit-package-bases packages/domain/observation_lifecycle/: clean
- ruff check packages/domain/observation_lifecycle/: clean

## V6 — Integration smoke

- V6.1 production registry (19 legacy 5-col rows): PASS — no false flags, no rewrite of healthy rows. 5-col rows stay 5-col.
- V6.3 (3 synthesized stale ORPHANED + no markers): PASS — 3 HIGH emitted + 3 markers created.
- V6.4 (re-run within 6h): PASS — 0 new HIGH (cadence respected).
- V6.5 (backdate markers to >6h, re-run): PASS — 3 new HIGH + marker mtimes touched to current.
- V6.6 (>30d-old detected_ts + no markers): PASS — 3 CRITICAL emitted (not HIGH).

## V7 — L-S258-2 closure verdict

ROBUSTLY CLOSED. Both root causes addressed:
1. Single-shot escalation gap (S312 V2.3-b) → fixed via marker-based re-emit cadence (D1).
2. detected_ts age proxy false-flag risk → fixed via col7 last_transition_at (D2).

## Minor observations (defer, do not block)

1. Dev's session log claims "session-313.md itself is not staged" — actually git status shows it IS staged (`A agent-workspace/memory/sessions/2026-05-14-session-313.md`). Minor inaccuracy, no functional impact.
2. The orphan-detector ALWAYS rewrites col7 in TMP_REGISTRY (lines 252-254) but only mv's it if CHANGED > 0. This is correct but subtle. Adding an inline comment "intentionally lossy on quiescent legacy rows" would help future maintainers.
3. The marker filename uses SHA256 of `agent-workspace/memory/.unattested-observations.tsv#<basename>` — if the registry path ever changes (e.g., rename), all existing markers become orphaned themselves. Not blocking; document in W0-2/3/4/5 plans.

## Recommendation

- plan 013 → completed/
- L-S258-2 robustly closed; remove from active mistake-log
- Advance to W0-2/3/4/5 sub-waves per Wave 0 substrate roadmap
