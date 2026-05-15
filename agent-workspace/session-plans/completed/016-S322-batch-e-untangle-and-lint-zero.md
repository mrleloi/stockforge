---
plan_id: 016-S322-batch-e-untangle-and-lint-zero
phase: 4 (harness remediation — serves S310 BEHAVIORAL HOLD)
status: pending-execution
authored: 2026-05-15
authored_session: S322 (PLAN session; sandwich-architect)
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent)
executing_agent: sandwich-dev (background dispatch — see § Session Sizing) + sandwich-verifier (AP-1)
parent_plan: agent-workspace/session-plans/pending/015-S319-bash-hook-lint-violation-remediation.md
binding_decisions:
  - S310 BEHAVIORAL HOLD authorizes harness-fix work (this IS harness fix; Batch E completes plan 015)
  - D-060 — agent MAY git commit (NOT push); this plan REQUIRES the agent to create commit boundaries
  - Charter v1.1 Principle 11 — every edited hook keeps a green companion firing-test
mode: FOCUSED_IMPL ×2 (S322a inventory+commit-boundary, S322b Batch E lint fix) + 1 VERIFY (S322-verify)
estimated_envelope: 90-130K tokens per IMPL sub-session; ~40K for VERIFY
predecessor_state: commit da02ad0 (S319+S321) shipped — lint 33 → 6; the 6 remaining are all Batch E
---

# S322 — Batch E Untangle + bash-hook-lint 6 → 0

## Goal

Drive `bash scripts/hooks/bash-hook-lint.sh` from **6 violations → 0** (or 0-plus-ratified-FP).
The 6 remaining are exactly the "Batch E" items from parent plan 015 — they live in files
that have UNCOMMITTED working-tree changes (4 tracked-dirty + 1 untracked), so they could
not be cleanly fixed in S319/S320/S321 without first establishing commit boundaries.

D-060 (ratified 2026-05-15) now permits the agent to create those commit boundaries itself
— the prior "Batch E gated on a human git commit" gate in plan 015 § Mid-Flight-Files
Decision is **LIFTED**. This plan does the untangle the parent plan deferred.

**Whole-plan DoD**:
- Lint count `0` (or 0-plus-N-ratified-FP, each with a lint-side suppression + firing-test TC).
- `human-workspace/notifications/bash-hook-lint-warn.md` deleted (the lint auto-`rm`s it at VIOLATIONS==0).
- `run-all.sh` ≥ 103/103 reproduced ≥2×.
- All touched `scripts/` files committed (NOT pushed — D-060).
- Parent plan 015 then eligible to move `pending/` → `completed/`.

## The 6 violations (confirmed from `human-workspace/notifications/bash-hook-lint-warn.md`)

| # | File | Class | Tracked state (per S321 checkpoint) |
|---|---|---|---|
| 1 | `autonomous-block-enforcer.sh` | L-S43b-9 printf-dash | tracked, DIRTY |
| 2 | `escalation-engine.sh` | L-S43b-9 printf-dash | tracked, DIRTY |
| 3 | `escalation-engine.sh` | L-S48d-1 pipefail-bare-grep | tracked, DIRTY |
| 4 | `adr-empirical-close-verify-spot-check.sh` | L-S48d-1 | tracked, DIRTY |
| 5 | `severity-classifier.sh` | L-S48d-1 | tracked, DIRTY |
| 6 | `idle-state-advisory.sh` | L-S80-2 grep-c-capture-trap | **UNTRACKED** |

(escalation-engine carries 2 → 5 unique files, 6 violations.)

## The blocker — uncommitted working-tree tangle (per S321-close checkpoint)

As of `da02ad0` (S321 close), `git status` carries:
- **4 dirty Batch E hooks** (`escalation-engine.sh`, `severity-classifier.sh`,
  `autonomous-block-enforcer.sh`, `adr-empirical-close-verify-spot-check.sh`) — ~140
  insertions / 38 deletions, attributed (per the S318 + S320 checkpoints) to **S318
  idempotent-notification work** plus some changes the S320 checkpoint called "unattributed".
- `idle-state-advisory.sh` — UNTRACKED. Has a companion firing-test
  `idle-state-advisory-fire-test.sh` — **also UNTRACKED**.
- **~25 unstaged `scripts/` files total** — mostly S318 idempotent-notification work
  (10 notification-writing hooks converted to fixed-name + 1 consumer + 9 firing-tests +
  others) that was **never committed** (S318 made 0 commits per its own checkpoint).
- **OUT OF SCOPE — do NOT touch**: `.claude/settings.json`, `CLAUDE.md`,
  `agent-workspace/CLAUDE.md` (D-060 commit-policy change — leave them; another concern),
  and the large `agent-workspace/memory/` churn (tracking-file noise — leave it). This plan
  commits ONLY `scripts/` files.

The lint fixes for the 6 violations cannot be cleanly committed while the host files carry
unattributed/uncommitted S318 work — the eventual commit could not separate "S318
idempotent-notification" from "S322 Batch E lint fix". So: **establish commit boundaries
FIRST, THEN the Batch E fixes become clean-file edits.**

---

## STEP 0 — Mandatory pre-flight (S322a, before any edit or commit)

This plan was authored by a subagent that could not run git or the lint. The S322a session
MUST run all of the following and write the results into the session log; STEP 0 output is
**authoritative** — if it diverges from this plan's tables, STEP 0 wins (update the plan
in-session).

1. **Regenerate the lint scan** — confirm the count is still 6 and the file list matches:
   ```
   CLAUDE_PROJECT_DIR="$(pwd)" bash scripts/hooks/bash-hook-lint.sh </dev/null >/dev/null 2>&1
   cat human-workspace/notifications/bash-hook-lint-warn.md
   ```

2. **Baseline the firing-test suite** — must read 103/103 (regression floor; may NOT regress
   at any commit boundary):
   ```
   bash scripts/hooks/firing-tests/run-all.sh
   ```

3. **Inventory the uncommitted `scripts/` changes** — this is the load-bearing step:
   ```
   git status --short -- scripts/
   git diff --stat -- scripts/
   git diff -- scripts/hooks/escalation-engine.sh scripts/hooks/severity-classifier.sh \
       scripts/hooks/autonomous-block-enforcer.sh scripts/hooks/adr-empirical-close-verify-spot-check.sh
   ```
   For EVERY unstaged/untracked `scripts/` file, classify it into one of:
   - **(C) Coherent S318 idempotent-notification work** — cross-reference against the S318
     session log (`agent-workspace/memory/sessions/2026-05-14-session-318.md` § "Files
     touched (S318)" — it lists 11 production hooks + 9 firing-tests explicitly) and the S318
     section of `current-execution.md`. A file is class C if it appears in the S318 "Files
     touched" list AND its diff is recognisably the per-fire-timestamp → fixed-name
     conversion (filename string change + clear-on-resolve `rm` in the else branch).
   - **(E) Batch E lint host-file** — one of the 5 Batch E files. These may carry a MIX of
     S318 work + the (S320-flagged) "unattributed" changes — see STEP 0.4.
   - **(U) Genuinely unattributed / orphaned** — a `scripts/` file that is NOT in the S318
     touched-list AND has no other session-log attribution. **If any class-U file exists →
     STOP. Do NOT commit it, do NOT guess. Emit a STOP-and-ask** (see § STOP-and-ask items).

4. **Diff-region attribution within the 4 dirty Batch E hooks** — the S320 checkpoint flagged
   `severity-classifier.sh` and `adr-empirical-close-verify-spot-check.sh` as carrying "2
   unattributed changes, no session log". Read the actual `git diff` of all 4 dirty hooks and
   for each hunk decide: is it S318 idempotent-notification work (then it commits with the
   S318 boundary), or is it the genuinely-unattributed change? **The Batch E lint violations
   do NOT yet exist as diffs** — they are violations in the *current* file content; the lint
   fix is a NEW edit S322b will make. So the question is purely: "what is ALREADY uncommitted
   in these 4 files, and is it all attributable?"
   - If ALL existing uncommitted hunks in the 4 dirty hooks are attributable (S318 or a
     clearly-identifiable change) → proceed to § Commit-Boundary Plan.
   - If ANY hunk in the 4 dirty hooks is genuinely unattributable → **STOP-and-ask** before
     committing those specific files. The other (clean-attribution) files can still proceed.

5. **Confirm out-of-scope files stay untouched** — note in the session log that
   `.claude/settings.json`, `CLAUDE.md`, `agent-workspace/CLAUDE.md`, and
   `agent-workspace/memory/**` will NOT be staged or committed by this plan.

---

## Commit-Boundary Plan (the chosen shape)

> This is the architect's recommended shape. STEP 0.3/0.4 VALIDATE it against the real diff;
> if S318 work and a not-yet-made Batch E fix would land in the same file, see § Ordering note.

**Commit 1 — "S318: notification-spam GENERATION root fix (fixed-name idempotent notifications)"**
Scope: ALL class-C files (the coherent S318 idempotent-notification work) — the 11 S318
production hooks + 9 S318 firing-tests + any other S318-attributable `scripts/` file from
STEP 0.3. This is work that was *completed and verified* at S318 (fresh-context verifier
`ad4a17c22fa1664f0` PASS-WITH-CONCERNS) but never committed. Committing it:
- makes those ~20 files CLEAN,
- and — critically — makes any Batch E host file that was dirty *only* because of S318 work
  become CLEAN, so S322b can edit it as a clean-file edit.
Commit message body should reference the S318 session log + the S318 verifier obs.

**Commit 2 (CONDITIONAL) — the genuinely-unattributed changes.** If STEP 0.4 finds
unattributable hunks in the dirty Batch E hooks, those are NOT committed by the agent —
they go to a STOP-and-ask. Do NOT fold them into Commit 1 (that would mislabel them as S318
work). If STEP 0.4 finds everything attributable, Commit 2 does not exist.

**Commit 3 — "S322 Batch E: bash-hook-lint 6 → 0 (parent plan 015 final batch)"**
Scope: the 6 Batch E lint fixes only — the NEW edits S322b makes to the 5 Batch E host files,
PLUS `git add` of the untracked `idle-state-advisory.sh` and its untracked companion
`idle-state-advisory-fire-test.sh`. By the time S322b runs, Commits 1 (+2 if applicable) have
made the 4 tracked Batch E hooks clean, so this commit is a surgical clean-file diff:
exactly the lint-fix lines + the 2 newly-tracked idle-state-advisory files.

### Ordering note (the one real risk)

The S318 idempotent-notification work edits *notification filename strings + emit/clear
logic*; the Batch E lint violations are in *unrelated regions* (printf format strings,
grep-guard patterns, grep-c capture). STEP 0.4 must CONFIRM this non-overlap by reading the
diffs. **If** a dirty Batch E hook's existing S318 hunk physically overlaps the line a Batch
E lint fix must touch, the plan still holds — Commit 1 lands the S318 hunk first, then S322b
edits the (now-clean) file for the lint fix in Commit 3. Two sequential commits to the same
file is fine and is exactly why the boundary is established first. The only thing that breaks
the plan is an *unattributable* hunk (→ STOP-and-ask), not an overlapping *attributable* one.

### `idle-state-advisory.sh` — untracked, special handling

`idle-state-advisory.sh` is UNTRACKED, so it has no "dirty vs clean" question — there is no
prior uncommitted diff to untangle. It simply needs:
1. STEP 0.3 to confirm it is a legitimate hook (it has a companion firing-test
   `idle-state-advisory-fire-test.sh`, also untracked, and is referenced in plan 015's
   inventory). Confirm it is wired in `.claude/settings.json` OR is a known-pending wire-up;
   note the finding. (Do NOT edit settings.json — just note.)
2. The L-S80-2 lint fix applied (S322b).
3. Both `idle-state-advisory.sh` AND `idle-state-advisory-fire-test.sh` `git add`-ed and
   included in **Commit 3**. A hook must never be committed without its companion firing-test
   (Charter Principle 11) — and the firing-test must be green first.

---

## The Batch E lint fixes (S322b — per-class recipes from parent plan 015)

> Exact violating line numbers are NOT in the lint notification — STEP 0.1's regenerated scan
> + a targeted `grep -nE` in each file derives them. Do NOT assume the first match you see is
> the violation (parent plan 015 § Batch A explicitly warns: the obvious `printf --` lines are
> often already correctly sentineled — `grep -nE "printf[[:space:]]+['\"]-"` and find the
> genuine UN-sentineled one). Read `bash-hook-lint.sh` Check 4 / Check 7 / Check 10 to see
> exactly what each detector matches if a line is ambiguous.

### L-S43b-9 printf-dash — `autonomous-block-enforcer.sh`, `escalation-engine.sh`

Recipe: `printf '-...'` / `printf "-..."` → `printf -- '-...'` (add the `--` sentinel so the
format string is not parsed as an option flag).
- `autonomous-block-enforcer.sh` — a `printf` whose format begins with `-` and lacks `--`.
  Note `:48` already has `printf '--- ...'` which is the THREE-dash form — Check 4 may or may
  not flag that; STEP 0.1 + a `grep -nE "printf[[:space:]]+(--[[:space:]])?['\"]-"` derives
  the genuine offender. Apply `printf -- '...'` to the un-sentineled line.
- `escalation-engine.sh` — note `:139` is already `printf -- '---\n'` (correctly sentineled).
  The flagged line is a DIFFERENT printf-dash; locate it via the targeted grep.

### L-S48d-1 pipefail-bare-grep — `escalation-engine.sh`, `adr-empirical-close-verify-spot-check.sh`, `severity-classifier.sh`

Recipe: under `set -o pipefail` + `trap ... ERR`, a bare/unguarded `grep` can silently
SIGPIPE-fail. Fix = wrap with `|| true`, OR convert to `if grep ...; then` form, OR
`( ... ) || true` subshell — WHICHEVER the surrounding structure makes cleanest and most
surgical (P3).
- **CAUTION — detector false-positive risk (parent plan 015 § Batch C, Risk 2).** Check 7's
  awk detector has known gaps. Several of these files appear to ALREADY guard their greps:
  - `severity-classifier.sh:143-153` wraps the `tail | grep | grep -v | head | while` pipeline
    in `( ... ) || true` with an explicit comment ":142" — this may be a Check 7 awk-gap, not
    a real unguarded grep. Read the flagged line; if it is genuinely already guarded, the fix
    is a **Check 7 detector refinement in `bash-hook-lint.sh` + a companion
    `bash-hook-lint-fire-test.sh` TC** (dual-property: the FP no longer fires AND a genuine
    violation still fires), NOT a redundant `|| true`.
  - `adr-empirical-close-verify-spot-check.sh` — parent plan noted it "appears to already
    guard with `|| true` inside a `{ }` brace+timeout structure". Same triage.
  - `escalation-engine.sh:44` (`grep '^expiry_epoch=' ... | head -1 | sed ... || echo 0`) —
    the `|| echo 0` is on the SED, not visibly on the grep; STEP 0.1 + reading Check 7
    determines whether this is the flagged line and whether it is genuinely unguarded.
  For each L-S48d-1 hit the dev MUST decide REAL (fix the grep) vs DETECTOR-GAP (refine
  Check 7 + add TC). **Do NOT add a redundant `|| true` to an already-guarded pipeline just
  to silence the lint** — that is a ghost-green, forbidden by parent plan 015 DoD #5.
  - NOTE: if a Check 7 refinement is needed, `bash-hook-lint.sh` is ALREADY committed clean
    as of `da02ad0` — editing it for calibration is a clean-file edit and folds into Commit 3
    (with its `bash-hook-lint-fire-test.sh` TC). Charter Principle 11 governs that edit.

### L-S80-2 grep-c-capture-trap — `idle-state-advisory.sh`

Recipe: `VAR=$(grep -c ... || echo N)` produces a multi-line `"0\nN"` capture when grep finds
0 and exits 1 → breaks downstream numeric coercion. Fix = `if grep -qE ...; then VAR=1; else
VAR=0; fi` (clean integer). If the grep -c is on a *pipeline* (not a standalone file) — as in
`daily-backup.sh`'s case — adapt to `if <pipeline> | grep -qE ...; then VAR=1; else VAR=0; fi`
OR the subshell `( ... ) || echo 0` form. Read the actual `idle-state-advisory.sh` flagged
line and pick the form that matches its pipeline shape and keeps the edit surgical.

---

## Session Sequencing

### S322a — FOCUSED_IMPL — Inventory + commit boundaries (~90-110K)

1. STEP 0 (all 5 sub-steps) — write results to session log.
2. If STEP 0.3 found any class-U file OR STEP 0.4 found any unattributable hunk →
   **STOP, emit the STOP-and-ask notification, end S322a here.** Do not proceed to commits.
   S322b waits for the user's answer.
3. Otherwise: stage the class-C files, create **Commit 1** ("S318: notification-spam
   GENERATION root fix ..."). Verify post-commit: `git status -- scripts/` shows the 4 dirty
   Batch E hooks are now CLEAN (or, if one is still dirty, STEP 0.4 mis-attributed — STOP).
4. **Dispatch point**: S322a does NOT do the Batch E lint fixes. It hands off to S322b.
   (S322a may be the same continuous autonomous run if envelope allows, but the lint-fix work
   is a distinct dev unit with its own verification — keep it as S322b.)

DoD for S322a:
- ✅ STEP 0 results in session log (lint=6, run-all 103/103, full `scripts/` inventory table).
- ✅ Commit 1 created (S318 idempotent-notification work) — `scripts/` only, agent-committed,
  NOT pushed.
- ✅ Post-commit `git status -- scripts/` shows the 4 tracked Batch E hooks CLEAN.
- ✅ `idle-state-advisory.sh` + its firing-test still untracked (correct — they join Commit 3).
- ✅ No STOP-and-ask outstanding (or, if one is, S322a stops cleanly here and says so).
- ✅ `run-all.sh` still 103/103 (Commit 1 changed nothing functionally — it committed
  already-present working-tree content).

### S322b — FOCUSED_IMPL — Batch E lint fixes 6 → 0 (~100-130K)

Pre-flight: confirm Commit 1 landed and the 4 tracked Batch E hooks are clean (re-run
`git status -- scripts/`). Re-run the lint — confirm still 6.

Apply the 6 fixes per § The Batch E lint fixes:
1. L-S43b-9 ×2 — `autonomous-block-enforcer.sh`, `escalation-engine.sh`.
2. L-S48d-1 ×3 — `escalation-engine.sh`, `adr-empirical-close-verify-spot-check.sh`,
   `severity-classifier.sh` — with the REAL-vs-detector-gap triage per file.
3. L-S80-2 ×1 — `idle-state-advisory.sh`.
4. If any L-S48d-1 triage concluded "Check 7 detector gap" → refine `bash-hook-lint.sh`
   Check 7 + add a dual-property `bash-hook-lint-fire-test.sh` TC.

Per-fix verification (every fix, no exception):
- `bash -n` clean on the edited file.
- The edited hook's OWN firing-test runs green individually (e.g.
  `escalation-engine-fire-test.sh`, `severity-classifier-fire-test.sh`,
  `adr-empirical-close-verify-spot-check-fire-test.sh`, `autonomous-block-enforcer-fire-test.sh`,
  `idle-state-advisory-fire-test.sh`). If a fix needs a Principle-11 companion TC update, it
  lands in the same change.
- Lint count drops monotonically — re-run the lint after each fix.

Then:
- Full `run-all.sh` ≥ 103/103 reproduced ≥2×.
- Final lint run → **0 violations** (or 0-plus-ratified-FP with the suppression + TC documented
  in the session log).
- Confirm `human-workspace/notifications/bash-hook-lint-warn.md` is auto-deleted by the lint at
  VIOLATIONS==0.
- `git add` the 5 Batch E hosts + (if edited) `bash-hook-lint.sh` + `bash-hook-lint-fire-test.sh`
  + the previously-untracked `idle-state-advisory.sh` + `idle-state-advisory-fire-test.sh`.
- Create **Commit 3** ("S322 Batch E: bash-hook-lint 6 → 0 ..."). `scripts/` only,
  agent-committed, NOT pushed.

DoD for S322b:
- ✅ Lint 6 → 0 (or 0-plus-documented-ratified-FP).
- ✅ `bash-hook-lint-warn.md` deleted.
- ✅ `run-all.sh` ≥ 103/103 ×2.
- ✅ `bash -n` clean on every edited file.
- ✅ Each edited hook's own firing-test green individually.
- ✅ Commit 3 created — `scripts/` only, NOT pushed; untracked idle-state-advisory pair now tracked.
- ✅ No ghost-green — every fix addresses the root cause; any detector-FP fix is a Check
  refinement + TC, never a no-op `|| true` on an already-guarded grep.
- ✅ Session log + `mistake-log.md` entry (or explicit "no mistakes this session").

### S322-verify — VERIFY (AP-1, fresh-context sandwich-verifier, ~40K)

Per AP-1 the S322b dev must NOT self-verify. Dispatch a fresh-context sandwich-verifier with
a brief weighted on:
- Independent lint re-run → confirm 0 (or audit each ratified-FP suppression + its TC).
- Adversarial ghost-green probe — confirm no Batch E "fix" is a redundant `|| true` on an
  already-guarded grep, no skip-marker hiding a real violation (the recurring S319/S320 risk).
- `run-all.sh` ≥ 103/103 independent re-run.
- Commit hygiene audit — `git log` + `git show --stat` on Commit 1 and Commit 3: confirm
  Commit 1 is S318-attributable `scripts/` files ONLY (no Batch E lint fix leaked in, no
  out-of-scope `.claude/`/`CLAUDE.md`/`memory/` files), Commit 3 is the Batch E fixes +
  idle-state-advisory pair ONLY. Confirm nothing was pushed.
- If S322a emitted a STOP-and-ask and the user answered, confirm the answer was honored.
Read-only; reports defects, does not fix. If PASS → parent plan 015 → `completed/`.

---

## STOP-and-ask items (surface to user; do NOT guess)

The plan is designed so the agent can self-execute the common case. STOP and emit a
notification to `human-workspace/notifications/` (and pause that work-unit) ONLY if:

1. **STEP 0.3 finds a class-U file** — an unstaged/untracked `scripts/` file that is NOT in
   the S318 "Files touched" list and has no other session-log attribution. Committing it
   would mislabel its provenance. Ask the user: "what is `<file>` and which commit boundary
   does it belong to?"
2. **STEP 0.4 finds an unattributable hunk** inside one of the 4 dirty Batch E hooks — a diff
   region that is neither recognisable S318 idempotent-notification work nor otherwise
   session-log-attributable. (The S320 checkpoint explicitly flagged `severity-classifier.sh`
   and `adr-empirical-close-verify-spot-check.sh` as carrying "2 unattributed changes, no
   session log" — this is the most likely trigger.) Ask the user to identify those changes
   before they are committed. The other (cleanly-attributable) files may still proceed; only
   the affected files' commit waits.
3. **Post-Commit-1 a Batch E hook is still dirty** with content STEP 0.4 thought it had
   attributed — indicates a mis-attribution; STOP rather than commit-anyway.
4. **A Batch E lint fix cannot be applied without a non-surgical rewrite** (e.g. an L-S48d-1
   hit whose only correct fix is a structural refactor of the host hook) — surface the
   tradeoff rather than ship a ghost-green or an over-broad refactor.

For cases 1-3 the STOP-and-ask is a provenance question (genuinely the user's call —
`human-workspace/` is human authority on what uncommitted changes mean). For case 4 it is a
scope/architecture tradeoff. None of these should be papered over.

---

## Risks & Gotchas

1. **Risk — mis-attributing an unattributed change as S318 work (HIGH).** Folding a class-U
   change into Commit 1 mislabels it permanently. Mitigation: STEP 0.3/0.4 cross-reference
   against the S318 session log's explicit "Files touched" list; anything not on it +
   no other attribution → STOP-and-ask, never assume.
2. **Risk — ghost-green on the L-S48d-1 triage (HIGH).** `severity-classifier.sh` and
   `adr-empirical-close-verify-spot-check.sh` appear to already guard their greps; a
   redundant `|| true` would silence the lint without fixing anything (and the lint count
   would still not be a *genuine* 0). Mitigation: § Batch E fixes mandates REAL-vs-detector-gap
   triage per hit; detector gaps → Check 7 refinement + TC. The S322-verify brief explicitly
   adversarially probes for this — it is the recurring failure mode across S319/S320/S321.
3. **Risk — committing out-of-scope files (MEDIUM).** The working tree also has
   `.claude/settings.json`, `CLAUDE.md`, `agent-workspace/CLAUDE.md`, and a large
   `agent-workspace/memory/` churn. Mitigation: every commit in this plan stages `scripts/`
   paths EXPLICITLY (`git add scripts/hooks/<file> ...`), never `git add -A` / `git add .`.
   The S322-verify commit-hygiene audit confirms it.
4. **Gotcha — the obvious printf-dash line is often already sentineled.** Both
   `escalation-engine.sh:139` and `autonomous-block-enforcer.sh:48` have `--`-form printfs
   that are NOT the violation. `grep -nE` for the genuine un-sentineled line; cross-check
   against what Check 4 actually matches.
5. **Gotcha — `idle-state-advisory.sh` must be committed WITH its firing-test.** Both are
   untracked. Charter Principle 11 — a hook without a green companion firing-test must not
   land. The firing-test goes green BEFORE Commit 3.
6. **Gotcha — `run-all.sh` count stays 103 even if TCs are added.** `run-all.sh` counts
   firing-test *files*, not TCs within files (per S321 dev note). Adding a TC inside an
   existing firing-test does not raise the 103 count — that is correct, not a regression.
7. **Risk — D-004 envelope.** Two FOCUSED_IMPL sub-sessions + a VERIFY. If S322a + S322b are
   run in one continuous autonomous turn, watch the 180K wind-down / 220K cliff. The
   commit-boundary structure makes splitting trivial — each commit is a clean checkpoint.

## Hard Constraints

1. **D-060** — agent MAY `git commit` (this plan REQUIRES it); agent MUST NOT `git push`.
2. **`scripts/` paths only** in every commit — explicit `git add scripts/hooks/<file>`,
   never `git add -A`. Out-of-scope files (`.claude/`, `CLAUDE.md`, `agent-workspace/CLAUDE.md`,
   `agent-workspace/memory/**`) are NOT staged or committed by this plan.
3. **NO charter / constitution edits** — `bash-hook-lint.sh` lives in `scripts/hooks/`, not
   `constitution/`, so calibrating it is permitted; do NOT touch `agent-workspace/constitution/**`.
4. **bash + POSIX only** for any hook edit (L-S11-1 — the rule family under remediation).
5. **Charter Principle 11** — every edited hook (incl. `bash-hook-lint.sh` if calibrated, and
   `idle-state-advisory.sh`) ships/keeps a green companion firing-test; `run-all.sh` ≥ 103/103
   at every commit boundary.
6. **P3 surgical** — each commit's diff touches only that commit's scope; no drive-by refactors.
7. **No ghost-green** (parent plan 015 DoD #5) — a "fix" that silences the lint without
   addressing root cause is FORBIDDEN; detector-FP → Check refinement + TC.
8. **AP-1** — S322b dev does NOT self-verify; fresh-context S322-verify is mandatory.
9. **BEHAVIORAL HOLD (S310)** — this plan IS authorized harness-fix work; no product work mixed in.
10. **STOP-and-ask, don't guess** — provenance ambiguity (§ STOP-and-ask items) goes to the
    user via `human-workspace/notifications/`, never papered over.

## Provenance

- S321-close checkpoint `agent-workspace/memory/checkpoints/latest.md` — S322 PRIORITY 1
  (Batch E untangle is a PLAN job; the 4-dirty + 1-untracked + 25-unstaged state).
- Parent plan `agent-workspace/session-plans/pending/015-S319-bash-hook-lint-violation-remediation.md`
  — § Mid-Flight-Files Decision (Batch E definition + gate, now lifted by D-060), § Batch A/C/D
  (the per-class L-S43b-9 / L-S48d-1 / L-S80-2 fix recipes), § Risks 1-3.
- `human-workspace/notifications/bash-hook-lint-warn.md` — the current 6-violation scan.
- S318 session log `agent-workspace/memory/sessions/2026-05-14-session-318.md` — the explicit
  "Files touched (S318)" list (11 hooks + 9 firing-tests) — the authoritative class-C
  attribution reference.
- `agent-workspace/memory/current-execution.md` § S318 + § S320 — the "unattributed changes"
  flag on `severity-classifier.sh` + `adr-empirical-close-verify-spot-check.sh`.
- S319-verify obs `agent-workspace/memory/observations/sandwich-verifier-S320-plan015-S319-verify.md`
  + S321-verify obs `...-S321-plan015-remediation-verify.md` — confirm the 6 remaining are
  exactly Batch E; the recurring ghost-green failure mode the S322-verify brief must probe.
- D-060 (`agent-workspace/memory/decisions/060-*`) — agent-may-commit-not-push; lifts the
  parent plan's "Batch E gated on human commit" gate.
- Charter Principle 11 — companion firing-test discipline; `run-all.sh` 103/103 floor.
