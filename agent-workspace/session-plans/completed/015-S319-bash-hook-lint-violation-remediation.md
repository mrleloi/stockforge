---
plan_id: 015-S319-bash-hook-lint-violation-remediation
phase: 4 (harness remediation — serves S310 BEHAVIORAL HOLD)
status: pending-execution
authored: 2026-05-14
authored_session: S319 (PLAN session; sandwich-architect)
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent)
executing_agent: sandwich-dev (background dispatch, multi-session — see § Session Sizing)
binding_decisions:
  - S310 BEHAVIORAL HOLD authorizes harness-fix work (this IS harness fix)
  - Charter v1.1 Principle 11 (every hook ships with a green companion firing-test)
predecessor_plan: agent-workspace/session-plans/pending/014-S315-wave-0-W0-2-python-determinism-banned-patterns.md
verifier_input: S318 sandwich-verifier ad4a17c22fa1664f0 PASS-WITH-CONCERNS — IMPORTANT-2 (S317 bash-hook-lint false-green; 33 pre-existing violations) carried forward as S319 PRIORITY 1
mode: FOCUSED_IMPL ×2 (split — see § Session Sizing); optionally a 3rd VERIFY session
estimated_envelope: 100-140K tokens per IMPL sub-session
---

# S319 — bash-hook-lint 33-Violation Remediation (batched by class)

## Goal

Drive `bash scripts/hooks/bash-hook-lint.sh` real-repo scan from **33 violations → 0**
(or 0-plus-N-documented-false-positives, where each surviving N has a lint-side
calibration, not a source rewrite). The S317 checkpoint claimed "bash-hook-lint full
scan: CLEAN (RC=0, 0 warnings)" — a **false-green**: bash-hook-lint is WARN-only
(`exit 0` always; `trap 'exit 0' ERR`), so RC=0 says nothing about violation count.
The S318 verifier (IMPORTANT-2) surfaced the real count: 33 across ~25 hooks.

Each violation class is a *known production-incident root cause* with a documented
fix recipe inline in `scripts/hooks/bash-hook-lint.sh` and in
`human-workspace/notifications/bash-hook-lint-warn.md`. None of the 33 are in the
11 hooks S318 edited.

**Definition of "done" for the whole plan**: lint count is 0, OR every surviving
violation is a deliberately-ratified false-positive whose suppression lives in
`bash-hook-lint.sh` (skip-marker / allow-list / detector calibration) + a companion
firing-test TC — never an inline `# this is fine` comment on the source line (the
ratify-via-comment recipe does NOT silence the lint; it only documents acceptance —
see L-S55-1 and the `promotion-cycle-trigger.sh` / `autonomous-stop-watchdog.sh`
precedent below).

## STEP 0 — Mandatory pre-flight (do this BEFORE touching any hook)

The implementing session MUST run these and write the results into the session log,
because this plan was authored by a subagent that could not run git:

1. **Regenerate the scan** (the notification may be stale):
   ```
   CLAUDE_PROJECT_DIR="$(pwd)" bash scripts/hooks/bash-hook-lint.sh </dev/null >/dev/null 2>&1
   cat human-workspace/notifications/bash-hook-lint-warn.md
   ```
   Confirm the count is still 33 and re-derive the exact file list per class. If the
   count differs, reconcile against the inventory below before proceeding.

2. **Determine clean-vs-dirty for every violation-bearing hook**:
   ```
   git status --short scripts/hooks/
   git diff --stat scripts/hooks/
   ```
   This is load-bearing — see § Mid-Flight-Files Decision. Mark each of the 25 files
   CLEAN or DIRTY in the session log.

3. **Baseline the firing-test suite**:
   ```
   bash scripts/hooks/firing-tests/run-all.sh
   ```
   Must read 103/103 (S318 close state). This is the regression floor — it may NOT
   regress at any batch boundary.

## Violation inventory — BY CLASS

> Counts and file lists below are derived from the S318 scan
> (`human-workspace/notifications/bash-hook-lint-warn.md`, 33 lines). STEP 0 re-derives
> them empirically; if STEP 0 disagrees, STEP 0 wins — update this table in-session.

| Class | Lint check | Count | Files |
|---|---|---|---|
| **L-S11-1** portability | Check 1 | **10** | attach-portability-smoke, autonomous-stop-watchdog, firing-test-spawn-context-lint, harness-health-self-scan, post-dev-dispatch-attestation-check, qa-pending-stale-mover, redact-secrets, session-export-raw, subagent-stop-logger, vendor-api-probe |
| **L-S43b-9** printf-dash | Check 4 | **2** | autonomous-block-enforcer, escalation-engine |
| **L-S108-1** session-id-fallback | Check 6b | **6** | idle-escape-detector, idle-state-advisory, phase-status-coherence, project-md-adr-staleness, sub-plan-completion-coherence |
| **L-S48d-1** pipefail-bare-grep | Check 7 | **5** | adr-empirical-close-verify-spot-check, bootstrap-summary-renderer, escalation-engine, harness-health-self-scan, severity-classifier |
| **L-S53-2** unanchored-grep | Check 8 | **5** | autonomous-stop-watchdog, promotion-cycle-trigger, session-start-bootstrap, stale-prompt-detector, sync-grilling-call |
| **L-S80-2** grep-c-capture-trap | Check 7 (Check 10) | **7** | attach-portability-smoke, daily-backup, harness-health-self-scan, idle-escape-detector, idle-state-advisory, phase-status-coherence, sync-grilling-call (NOTE: notification body lists only 6 — STEP 0 re-derive; the 33-total + per-class sum implies a 7th) |

**Total: 33** (10 + 2 + 6 + 5 + 5 + 7 = 35 raw, minus 2 because `harness-health-self-scan`
and `escalation-engine` each appear in 2 classes — the lint counts per-violation, and
the unique-file count is ~25; STEP 0 reconciles exactly).

## Violation inventory — BY FILE (with clean-vs-dirty status)

> Dirty/clean derived from documented evidence (S318 session log + S318 checkpoint).
> **STEP 0 `git status` is authoritative** — this column is the architect's best
> static estimate and MUST be replaced with the real `git status` output in-session.

| File | Classes (count) | Dirty? (evidence) | Notes |
|---|---|---|---|
| `escalation-engine.sh` | L-S43b-9, L-S48d-1 (2) | **DIRTY** — S317 block-subsystem rebuild | MID-FLIGHT. Defer per § decision. |
| `severity-classifier.sh` | L-S48d-1 (1) | **DIRTY** — "2 unattributed changes, no session log" (checkpoint PRIORITY 2) | MID-FLIGHT. Defer per § decision. |
| `autonomous-block-enforcer.sh` | L-S43b-9 (1) | **DIRTY** — S317 block-subsystem rebuild | MID-FLIGHT. Defer per § decision. |
| `adr-empirical-close-verify-spot-check.sh` | L-S48d-1 (1) | **DIRTY** — "2 unattributed changes, no session log" (checkpoint PRIORITY 2) | MID-FLIGHT. Defer per § decision. |
| `attach-portability-smoke.sh` | L-S11-1, L-S80-2 (2) | likely CLEAN | L-S11-1 = REAL (hard python dep). |
| `autonomous-stop-watchdog.sh` | L-S11-1, L-S53-2 (2) | likely CLEAN | BOTH likely FALSE-POSITIVE (see triage). |
| `harness-health-self-scan.sh` | L-S11-1, L-S48d-1, L-S80-2 (3) | likely CLEAN | L-S11-1 = FALSE-POSITIVE (python3 is date-math fallback). |
| `redact-secrets.sh` | L-S11-1 (1) | likely CLEAN | L-S11-1 = AMBIGUOUS (python3 primary, sed fallback). |
| `firing-test-spawn-context-lint.sh` | L-S11-1 (1) | likely CLEAN | triage in-session. |
| `post-dev-dispatch-attestation-check.sh` | L-S11-1 (1) | likely CLEAN | triage in-session. |
| `qa-pending-stale-mover.sh` | L-S11-1 (1) | likely CLEAN | triage in-session. |
| `session-export-raw.sh` | L-S11-1 (1) | likely CLEAN | triage in-session. |
| `subagent-stop-logger.sh` | L-S11-1 (1) | likely CLEAN | triage in-session. |
| `vendor-api-probe.sh` | L-S11-1 (1) | likely CLEAN | triage in-session (probe likely needs the tool). |
| `idle-escape-detector.sh` | L-S108-1, L-S80-2 (2) | likely CLEAN | L-S80-2 hit has `set +o pipefail` above it — partial FP, but apply if/then/fi recipe anyway. |
| `idle-state-advisory.sh` | L-S108-1, L-S80-2 (2) | likely CLEAN | — |
| `phase-status-coherence.sh` | L-S108-1, L-S80-2 (2) | likely CLEAN | — |
| `project-md-adr-staleness.sh` | L-S108-1 (1) | likely CLEAN | — |
| `sub-plan-completion-coherence.sh` | L-S108-1 (1) | likely CLEAN | — |
| `bootstrap-summary-renderer.sh` | L-S48d-1 (1) | likely CLEAN | — |
| `promotion-cycle-trigger.sh` | L-S53-2 (1) | likely CLEAN | L-S53-2 = DOCUMENTED FALSE-POSITIVE (lines 38-46 ratify it). |
| `session-start-bootstrap.sh` | L-S53-2 (1) | likely CLEAN | triage in-session. |
| `stale-prompt-detector.sh` | L-S53-2 (1) | likely CLEAN | triage in-session. |
| `sync-grilling-call.sh` | L-S53-2, L-S80-2 (2) | likely CLEAN | triage in-session. |
| `daily-backup.sh` | L-S80-2 (1) | likely CLEAN (committed 39e4c75/770c101 — R3 mass-deletion prevention) | L-S80-2 hit is `tar | grep -c || echo 0` — recipe needs adapting (pipeline form). |

## Mid-Flight-Files Decision

**Four violation-bearing hooks are working-tree-modified and uncommitted**:
`escalation-engine.sh`, `severity-classifier.sh`, `autonomous-block-enforcer.sh`,
`adr-empirical-close-verify-spot-check.sh` — carrying **~5 of the 33 violations**
(escalation-engine L-S43b-9 + L-S48d-1; severity-classifier L-S48d-1;
autonomous-block-enforcer L-S43b-9; adr-empirical-close-verify-spot-check L-S48d-1).
They are dirty from S317 (block/unblock rebuild — no session log) + 2 fully
unattributed changes (no session log, not in any deliverable summary — checkpoint
PRIORITY 2).

**DECISION: DEFER the 4 dirty hooks to a post-commit-boundary batch (Batch E).**

Rationale:
1. **Tangling risk** — editing a hook that already has uncommitted S317/unattributed
   work means the eventual `git commit` cannot cleanly separate "S317 block rebuild"
   / "the 2 unattributed changes" / "S319 lint fix". The checkpoint's PRIORITY 2 is
   *explicitly* asking the user to create a commit boundary so S317/S318 are
   separable. S319 mixing a third concern in deepens that exact problem.
2. **The agent cannot commit** (CLAUDE.md hard rule) — so S319 cannot itself create
   the boundary. It can only avoid making the tangle worse.
3. **Provenance gap** — the 2 unattributed changes have *no session log*. Editing
   those files before someone establishes what those changes are = editing on top of
   an unaudited diff. P3 (surgical changes) demands knowing the baseline.
4. **Low cost of deferral** — only ~5 of 33 violations are affected; the other ~28
   are in clean files and can be fixed immediately with zero tangling.

**Sequencing**: Batches A-D (clean files, ~28 violations) run first and are
standalone-committable. Batch E (the 4 dirty hooks, ~5 violations) is gated on a
**human commit boundary** — the implementing session, at the start of Batch E, must
either (a) confirm via `git status` that the 4 files are now clean (user committed
S317 + investigated the 2 unattributed), or (b) if still dirty, STOP and emit a
notification asking the user to commit the boundary, then leave Batch E for a later
session. Do NOT fix-anyway on a dirty file.

This also feeds checkpoint PRIORITY 2 cleanly: "fix the clean ones now, the dirty
ones become trivially fixable once you commit."

## Real-vs-False-Positive Triage — L-S11-1 (Check 1)

Check 1 flags `python3?|jq|yq|pip|pip3|npm|pnpm` as a command token in a non-comment
line. **`node` is NOT in the Check 1 banned set** — node-based JSON parsing is not a
portability violation per this lint, so node-using hooks are not in scope.

The doctrine (L-S117-1 / L-S255-2 — "calibrate the Guardian, don't mass-fix source"):
when a hook *legitimately* needs the tool and degrades gracefully without it, the fix
is a lint-side skip-marker or detector refinement, NOT a bash rewrite. The
implementing session MUST classify each of the 10 L-S11-1 hits as REAL / FALSE-POSITIVE
/ AMBIGUOUS by reading the actual invocation:

| Hook | Architect's read (from file inspection) | Likely verdict |
|---|---|---|
| `attach-portability-smoke.sh` | `python -c "import yaml..."` — **hard dependency**, no fallback; `exit 2` FATAL if python assertion harness fails. Heavy YAML parse. | **REAL** — rewrite to bash/POSIX, OR add a `# PHASE-1+` guard if it is genuinely a Phase-1 tool. Highest-effort fix in the plan. |
| `harness-health-self-scan.sh` | `python3` at line 72 is ONLY a fallback for `date -d` math (`date -d ... \|\| python3 ...`). Graceful. | **FALSE-POSITIVE** — calibrate Check 1 to skip a `python3` that is the alt-branch of a `\|\|` whose primary is a portable command. |
| `autonomous-stop-watchdog.sh` | `jq` at line 32 has an explicit bash-regex fallback (`if command -v jq ...; else BASH_REMATCH ...`). Documented "jq preferred; bash regex fallback for Windows-without-jq". | **FALSE-POSITIVE** — `command -v jq` guarded with a complete fallback path. |
| `redact-secrets.sh` | `python3` is the *primary* path (unicode-safe regex) with `node` 2nd and `sed` 3rd fallback. Degrades but sed branch is "incomplete; only catches simplest patterns". | **AMBIGUOUS** — graceful-degradation chain exists, but python3 is primary not fallback. Recommend skip-marker + a comment that the sed fallback is the Phase-0 floor. Confirm in-session. |
| `firing-test-spawn-context-lint.sh` | inspect in-session | TBD |
| `post-dev-dispatch-attestation-check.sh` | inspect in-session | TBD |
| `qa-pending-stale-mover.sh` | inspect in-session | TBD |
| `session-export-raw.sh` | inspect in-session — M-S13-pre-1 history (head -1 bug); likely real python | TBD |
| `subagent-stop-logger.sh` | inspect in-session | TBD |
| `vendor-api-probe.sh` | inspect in-session — a vendor-API probe almost certainly *needs* the HTTP/JSON tool legitimately | likely **FALSE-POSITIVE** or **REAL-but-Phase-1** |

**Lint-calibration mechanism** (preferred over per-hook skip-markers for a project-wide
rule, per L-S255-2): the cleanest fix for the graceful-fallback false-positives is to
teach Check 1 to recognise the `<portable-cmd> || <banned-cmd>` and
`if command -v <banned>; then ... else <portable-fallback> ...` shapes. If that proves
too broad, fall back to a per-line `# bash-hook-lint:allow L-S11-1 <reason>` skip-marker
that Check 1 honours (the lint must be extended to read such markers — currently it does
not). EITHER mechanism requires editing `bash-hook-lint.sh` itself + a companion
firing-test TC proving the skip works AND that a genuine violation still fires.

## Real-vs-False-Positive Triage — L-S53-2 (Check 8)

**L-S53-2 also needs triage** — it is not a pure "anchor everything" class:

- `promotion-cycle-trigger.sh:50` — **DOCUMENTED FALSE-POSITIVE**. Lines 38-46 are an
  explicit ratify-via-comment block (per L-S55-1 recipe): the grep targets a
  `basename` filename token (`promote-rule-S52.md`) where `S<N>` is mid-string, so
  `^S` would never match. The comment ratifies it but does NOT silence the lint.
- `autonomous-stop-watchdog.sh:68-77` — **DOCUMENTED FALSE-POSITIVE**. The comment
  block explicitly says Check 8's `^` advice is WRONG here: the grep targets
  transcript-tail narration embedded mid-JSON-line, and a P6 firing-test case
  empirically proves anchoring would regress the detector.
- `session-start-bootstrap.sh`, `stale-prompt-detector.sh`, `sync-grilling-call.sh` —
  inspect in-session; some may be genuine unanchored header-greps that SHOULD get `^`.

Because `bash-hook-lint.sh` Check 8 only skips *comment lines*, a ratify-via-comment on
the line above a real grep does nothing. For the 2 confirmed false-positives, the fix
is the same lint-calibration mechanism as L-S11-1: extend Check 8 to honour an
explicit `# bash-hook-lint:allow L-S53-2 <reason>` skip-marker on the grep line, OR
refine Check 8's heuristic to recognise `basename`-token and transcript-tail contexts.
For genuine hits, add the `^` anchor (cheap, safe).

## Batch / Sequencing Strategy

**RECOMMENDATION: batch BY CLASS, not by file.** Rationale:

1. **Single recipe per batch** — each class has ONE documented fix recipe. A
   by-class batch lets the dev internalise one transformation and apply it 5-10×;
   a by-file batch context-switches between 2-3 unrelated recipes per file.
2. **Monotonic, legible progress** — "L-S108-1: 6 → 0" is a clean DoD checkpoint.
3. **The two multi-class files** (`harness-health-self-scan.sh`,
   `escalation-engine.sh`) are touched in 2 batches each — acceptable: the edits are
   to *different lines* for *different recipes*, and the file's firing-test is
   re-run at each batch (catches any interaction).
4. **Lint-calibration batches are naturally grouped** — L-S11-1 and L-S53-2 both
   need `bash-hook-lint.sh` itself edited + `bash-hook-lint-fire-test.sh` TCs; doing
   each class as a unit keeps the lint-self-edit coherent.

**Batches** (clean files first, dirty-file batch last + gated):

- **Batch A — L-S43b-9 printf-dash (2 violations)** — BUT both files
  (`autonomous-block-enforcer.sh`, `escalation-engine.sh`) are DIRTY. **Move Batch A
  into Batch E** (the dirty-file batch). Smallest class; trivial recipe
  (`printf '-...'` → `printf -- '-...'`). NOTE: in both files the *obvious*
  `printf --` lines are already correctly sentineled — the dev must `grep -nE
  "printf[[:space:]]+['\"]-"` and find the genuine un-sentineled line; do not assume
  it is the first printf-dash you see.
- **Batch B — L-S108-1 session-id-fallback (6 violations, 5 files, all CLEAN)** —
  recipe: replace `${CLAUDE_SESSION_ID:-WORD}` + `$VAR` marker filename with a date
  hour-bucket marker (`BUCKET="$(date +%Y%m%d-%H)"`) + a stale-bucket cleanup loop.
  `idle-escape-detector.sh` is the reference implementation — it ALREADY does the
  hour-bucket pattern correctly (lines 36-38, 54-61); the Check 6b hit on it is
  because it ALSO still has a `${CLAUDE_SESSION_ID:-unknown}` assignment elsewhere
  (cache filename, line 25/44) that trips the `HAS_FALLBACK` half of the detector.
  Verify whether each hit is a real lockout risk or the detector co-triggering on a
  benign cache-file SID — fix the real ones, and if a hit is benign, it goes through
  L-S11-1-style lint calibration.
- **Batch C — L-S48d-1 pipefail-bare-grep (5 violations; 2 CLEAN, 3 DIRTY)** — CLEAN
  subset: `bootstrap-summary-renderer.sh`, `harness-health-self-scan.sh`. DIRTY
  subset: `adr-empirical-close-verify-spot-check.sh`, `escalation-engine.sh`,
  `severity-classifier.sh` → those 3 move to Batch E. Recipe: wrap each unguarded
  grep with `|| true`, or convert to `if grep ...; then` form. CAUTION: Check 7's
  awk detector has known gaps — `adr-empirical-close-verify-spot-check.sh:86-89`
  appears to already guard with `|| true` inside a `{ }` brace+timeout structure;
  `severity-classifier.sh:143-153` already wraps the pipeline in `( ... ) || true`.
  These may be **detector false-positives** — the dev must read each flagged file
  and decide: real unguarded grep (fix the grep) vs. Check 7 awk gap (refine Check 7
  + add a firing-test TC). Do NOT add a redundant `|| true` to an already-guarded
  pipeline just to silence the lint.
- **Batch D — L-S80-2 grep-c-capture-trap (7 violations; mostly CLEAN)** — recipe:
  replace `VAR=$(grep -c ... || echo N)` with `if grep -qE ...; then VAR=1; else
  VAR=0; fi`. CAUTION on two files:
    - `daily-backup.sh:88` — the trap is `VERIFY_HITS=$(tar -tzf ... | grep -cE ... || echo 0)`
      i.e. grep -c on a *pipeline*, not a standalone file. The simple `if grep -qE`
      recipe must be adapted: `if tar -tzf "$ARCHIVE" 2>/dev/null | grep -qE '...';
      then VERIFY_HITS=1; else VERIFY_HITS=0; fi`. `daily-backup.sh` is committed R3
      mass-deletion-prevention code — keep the fix surgical (P3) and re-run its
      firing-test (`daily-backup-fire-test.sh`).
    - `idle-escape-detector.sh:76` — the `grep -c ... || echo 0` sits AFTER a `set +o
      pipefail` (line 69), so the multi-line `"0\nN"` risk is largely neutralised.
      Still apply the if/then/fi recipe for correctness + to clear the lint, but this
      is low-urgency.
- **Batch L (lint-calibration) — L-S11-1 (10) + L-S53-2 (5)** — this is the
  triage-heavy batch. Split into two sub-steps:
    - **L.1** — triage all 10 L-S11-1 + all 5 L-S53-2 hits (REAL / FALSE-POSITIVE /
      AMBIGUOUS) per § Triage sections; write the verdict table into the session log.
    - **L.2** — for REAL hits: rewrite to bash/POSIX (L-S11-1) or add `^` anchor
      (L-S53-2). For FALSE-POSITIVE hits: extend `bash-hook-lint.sh` Check 1 / Check 8
      (skip-marker support or heuristic refinement) + add `bash-hook-lint-fire-test.sh`
      TCs proving (a) the false-positive no longer fires AND (b) a genuine violation
      still fires. `bash-hook-lint.sh` is itself a hook with a companion firing-test —
      Principle 11 applies to the lint's own edit.
- **Batch E — dirty-file batch (gated on commit boundary)** — `escalation-engine.sh`
  (L-S43b-9 + L-S48d-1), `severity-classifier.sh` (L-S48d-1),
  `autonomous-block-enforcer.sh` (L-S43b-9), `adr-empirical-close-verify-spot-check.sh`
  (L-S48d-1). GATE: at Batch E start, `git status --short` these 4 files. If CLEAN →
  proceed (apply Batch A + Batch C recipes to them). If still DIRTY → STOP, emit a
  notification asking the user to commit the S317/unattributed boundary, defer Batch E
  to a later session. The ~5 violations here are the only ones that may not close in
  S319.

**Suggested batch order within a session**: B → D → C(clean subset) → L → E.
(B and D are pure-recipe and high-count — fast wins, monotonic count drop. C-clean
is small. L is the slow triage batch. E is gated and may not run.)

## Session Sizing

33 violations across ~25 files + lint-self-calibration + per-batch firing-test
re-runs + a full `run-all.sh` regression at each batch boundary does NOT fit one
FOCUSED_IMPL envelope. **Proposed split: 2 FOCUSED_IMPL sub-sessions + 1 optional
VERIFY.**

- **S319a (FOCUSED_IMPL, ~100-120K)** — STEP 0 pre-flight + Batch B (L-S108-1, 6) +
  Batch D (L-S80-2, 7) + Batch C-clean-subset (L-S48d-1 ×2). ~15 violations closed.
  Pure-recipe work, low triage load. DoD: those classes' counts hit 0/0 for the
  clean files; `run-all.sh` still 103/103.
- **S319b (FOCUSED_IMPL, ~120-140K)** — Batch L (L-S11-1 ×10 + L-S53-2 ×5) — the
  triage-heavy batch incl. editing `bash-hook-lint.sh` itself + firing-test TC
  authoring + the `attach-portability-smoke.sh` python→bash rewrite (the single
  largest fix). ~13 violations closed (some via real fix, some via ratified lint
  calibration). DoD: L-S11-1 + L-S53-2 either 0 or 0-plus-documented-FP; the lint's
  own firing-test green.
- **Batch E** — slot into S319b *if* the commit boundary exists by then; otherwise
  its own short follow-up session S319c after the user commits. ~5 violations.
- **S319-verify (VERIFY, ~30-50K, optional but recommended)** — fresh-context
  sandwich-verifier: re-run the lint, confirm count, adversarially probe that no
  "fix" is a ghost-green (e.g. a redundant `|| true` slapped on an already-guarded
  grep, or a skip-marker hiding a real violation). Per AP-1, the implementing dev
  must NOT self-verify the final count.

**Total estimate: 2 IMPL sessions (~220-260K combined) + 1 optional VERIFY (~40K),
with Batch E possibly spilling to a 3rd short session if the commit boundary lags.**

## Per-Batch Definition of Done

Every batch, without exception:

1. ✅ **Lint count drops monotonically** — re-run
   `CLAUDE_PROJECT_DIR="$(pwd)" bash scripts/hooks/bash-hook-lint.sh </dev/null` and
   read `human-workspace/notifications/bash-hook-lint-warn.md`. The total MUST be
   strictly lower than at batch start (or equal, only if the batch was pure
   lint-calibration that converted N hard-violations into N documented-false-positives
   — in which case the session log must say so explicitly with the N count).
2. ✅ **Firing-test regression holds** — `bash scripts/hooks/firing-tests/run-all.sh`
   ≥ 103/103. If a violation fix required a companion firing-test update (Principle
   11), that update lands IN the same batch and the suite count may rise but never
   fall.
3. ✅ **`bash -n` clean** on every edited hook.
4. ✅ **Each edited hook's own firing-test** runs green individually (not just the
   aggregate) — e.g. after editing `daily-backup.sh`, run
   `bash scripts/hooks/firing-tests/daily-backup-fire-test.sh` directly.
5. ✅ **No ghost-green** — a "fix" that merely silences the lint without addressing
   the root cause (redundant `|| true` on already-guarded grep; skip-marker on a real
   violation) is FORBIDDEN. If a hit is a detector false-positive, the fix is a
   detector refinement + a firing-test TC proving real violations still fire — never
   a no-op source edit.
6. ✅ Batch is **standalone-committable** — the diff touches only the files in that
   batch's scope (P3).

**Whole-plan DoD**:
- ✅ `bash scripts/hooks/bash-hook-lint.sh` → 0 violations, OR 0-plus-N where every
  surviving N is a ratified false-positive with a lint-side suppression + firing-test
  TC, documented in the session log with the N count and per-file reason.
- ✅ `human-workspace/notifications/bash-hook-lint-warn.md` deleted (the lint
  auto-`rm`s it when VIOLATIONS==0 — see `bash-hook-lint.sh` line 461).
- ✅ Full firing-test regression ≥ 103/103 reproduced ≥2× (per S318 verifier rigor).
- ✅ `bash-hook-lint.sh` itself, if edited for calibration, has updated
  `bash-hook-lint-fire-test.sh` coverage and still passes.
- ✅ Session logs for S319a / S319b (/ S319c) per CLAUDE.md Session Protocol.
- ✅ `mistake-log.md` updated OR explicit "no mistakes this session" per session.
- ✅ NO git commit (CLAUDE.md hard rule) — changes staged; the user owns the commit
   boundary (this plan deliberately keeps the dirty-file batch separate to HELP that).

## Risks & Gotchas

1. **Risk — the ratify-via-comment trap (HIGH).** `promotion-cycle-trigger.sh` and
   `autonomous-stop-watchdog.sh` already have inline comments ratifying their L-S53-2
   hits, yet the lint still counts them. A dev who adds *another* comment will not
   move the count. **Mitigation**: the only count-reducing fix for a false-positive
   is a lint-side change (skip-marker support or heuristic refinement) — Batch L.2
   makes this explicit.

2. **Risk — Check 7 / Check 10 detector gaps cause false-positives (MEDIUM).**
   `adr-empirical-close-verify-spot-check.sh` and `severity-classifier.sh` appear to
   already guard their flagged greps (`{ ... || true; }` / `( ... ) || true`). The
   dev must distinguish "real unguarded grep" from "Check 7 awk-detector can't see
   the guard through a brace/subshell/continuation". **Mitigation**: read every
   flagged file; for detector gaps, refine Check 7's awk + add a firing-test TC; never
   add a redundant guard.

3. **Risk — editing dirty hooks tangles the commit history (HIGH).** Four
   violation-bearing hooks carry uncommitted S317 + unattributed work.
   **Mitigation**: § Mid-Flight-Files Decision — Batch E is gated on a `git status`
   re-check; STOP-and-notify if still dirty. Never fix-anyway.

4. **Risk — `attach-portability-smoke.sh` python→bash rewrite is large (MEDIUM).**
   It does non-trivial YAML parsing with no fallback. A full bash/POSIX YAML parse is
   error-prone. **Mitigation**: first decide REAL vs Phase-1-legitimate — if the
   `/attach` smoke genuinely needs YAML and `/attach` is a Phase-1 feature, a
   `# PHASE-1+` guard comment (which Check 1 already exempts per its line-38 comment
   — verify the exemption is actually implemented) may be the correct, minimal fix
   rather than a fragile bash YAML parser. Re-run `attach-portability-smoke-fire-test.sh`
   whichever path is chosen.

5. **Risk — STEP 0 scan disagrees with this inventory (MEDIUM).** This plan was
   authored from a possibly-stale notification by a subagent that could not run git
   or the lint. **Mitigation**: STEP 0 regenerates the scan AND runs `git status`;
   STEP 0 output is authoritative — the dev updates the inventory tables in-session
   if they diverge.

6. **Gotcha — the per-class count sum (35) exceeds 33** because
   `harness-health-self-scan.sh` and `escalation-engine.sh` each carry violations in
   2 classes. The lint counts per-violation; "33" is the violation total, "~25" is
   the unique-file count. STEP 0 reconciles exactly. The L-S80-2 row in the by-class
   table lists 7 files but the notification body shows 6 — STEP 0 must resolve
   whether L-S80-2 is 6 or 7 (and which file is the 7th).

7. **Gotcha — `bash-hook-lint.sh` is itself a hook with a companion firing-test.**
   Any Batch-L calibration edit to it is governed by Charter Principle 11 —
   `bash-hook-lint-fire-test.sh` MUST be extended, not just the lint.

8. **Gotcha — `node` is not an L-S11-1 violation.** Several flagged-adjacent hooks
   use `node` for JSON parsing (`session-start-bootstrap.sh`,
   `bootstrap-summary-renderer.sh`, `idle-escape-detector.sh`); Check 1's banned set
   is `python3?|jq|yq|pip|pip3|npm|pnpm` only. Do not "fix" node usage — it is out of
   scope for L-S11-1.

## Hard Constraints

1. NO git commit (CLAUDE.md hard rule) — stage only; the user owns the commit boundary.
2. NO charter / constitution edits — `bash-hook-lint.sh` lives in `scripts/hooks/`,
   not `constitution/`, so calibrating it is permitted; do NOT touch
   `agent-workspace/constitution/**`.
3. bash + POSIX only for any hook rewrite (L-S11-1 — the very rule under remediation).
4. Charter Principle 11 — every edited hook (incl. `bash-hook-lint.sh` itself) keeps
   a green companion firing-test; `run-all.sh` ≥ 103/103 at every batch boundary.
5. P3 surgical — each batch's diff touches only that batch's files; no drive-by
   refactors of adjacent hook logic.
6. Atomic noclobber for any NEW marker writes (L-S289-1 / bash-hook-lint Check 11) —
   relevant to Batch B's hour-bucket markers if any are created fresh.
7. BEHAVIORAL HOLD (S310) — this plan IS the authorized harness-fix work; no product
   work, no pending-product-plan resumption mixed in.
8. Defer-don't-fix the 4 dirty hooks until a commit boundary exists (§ Mid-Flight
   Decision).

## Provenance

- S318 sandwich-verifier `ad4a17c22fa1664f0` PASS-WITH-CONCERNS — IMPORTANT-2 (S317
  bash-hook-lint false-green; 33 pre-existing violations) → S319 PRIORITY 1.
- S318-close checkpoint `agent-workspace/memory/checkpoints/latest.md` — S319
  NEXT-ACTION PRIORITY 1 (the 33 violations + class breakdown) + PRIORITY 2 (the
  working-tree dirty-file / commit-boundary problem feeding the Mid-Flight Decision).
- `human-workspace/notifications/bash-hook-lint-warn.md` — the 33-violation scan
  output with per-file class + fix recipe.
- `scripts/hooks/bash-hook-lint.sh` — Check 1/4/6b/7/8/10 implementations + inline
  fix recipes per class.
- `mistake-log.md` digest — M-S48d-1 (L-S48d-1 origin), M-S51-1 / M-S53-1 / M-S53-2
  (L-S53-2 lineage), M-S108-1 (L-S108-1 origin + the 7-sister-bug backlog),
  M-S80-1 (L-S80-2 region), M-S117-1 / M-S118-1 (L-S69-1 "calibrate the Guardian,
  don't mass-fix source" doctrine for the L-S11-1 + L-S53-2 false-positive triage).
- `PROJECT_CHARTER.md` Principle 11 — companion firing-test discipline; `run-all.sh`
  103/103 regression floor.
- S318 session log `agent-workspace/memory/sessions/2026-05-14-session-318.md` — the
  11 S318-edited hooks (confirmed none carry the 33 violations) + explicit "0 git
  commits" + the 2-unattributed-changes finding.
- L-S55-1 ratify-via-comment recipe — and the empirical fact (from
  `promotion-cycle-trigger.sh` / `autonomous-stop-watchdog.sh`) that it does NOT
  silence the lint, motivating the lint-calibration mechanism in Batch L.
