---
observation_id: sandwich-verifier-S320-plan015-S319-verify
plan: agent-workspace/session-plans/pending/015-S319-bash-hook-lint-violation-remediation.md
session: S320 (executing S319-verify scope)
authored: 2026-05-14
agent: sandwich-verifier (Claude Opus 4.7, fresh context)
verifies: sandwich-dev-S320-plan015-S319a-batch-BDC + sandwich-dev-S320-plan015-S319b-batch-L
verdict: PASS-WITH-CONCERNS
merge_eligible: NO -- fix IMPORTANT-1 + IMPORTANT-2 before this remediation is done
---

# S319-verify -- Adversarial Verification of S319a+S319b bash-hook-lint Remediation

## Overall Verdict: PASS-WITH-CONCERNS

- Lint 33 -> 6 confirmed; the 6 are EXACTLY the Batch E gated items. Monotonic drop holds.
- run-all.sh 103/103 confirmed (elapsed 300s). bash-hook-lint-fire-test.sh 45/45 confirmed (38->45, +7 TCs).
- 20 files staged; all 5 Batch E files (escalation-engine, severity-classifier, autonomous-block-enforcer, adr-empirical-close-verify-spot-check + untracked idle-state-advisory) confirmed UNTOUCHED -- zero staged changes.
- bash -n clean on all 20 staged files.
- 2 IMPORTANT defects + 3 MINOR defects found. Headline: a real daily-backup.sh functional regression (ghost-green) that silences L-S80-2 but breaks the backup content-verify on large archives.

## Baseline Re-Verification (independent)

- Lint count 6 (was 33): CONFIRMED -- re-ran lint; notification shows 6.
- 6 remaining = Batch E (autonomous-block-enforcer L-S43b-9, escalation-engine L-S43b-9+L-S48d-1, adr-empirical-close-verify-spot-check L-S48d-1, severity-classifier L-S48d-1, idle-state-advisory L-S80-2): CONFIRMED -- exact match.
- run-all.sh 103/103: CONFIRMED -- background run, exit 0, "103/103 PASS".
- bash-hook-lint-fire-test 38->45 TCs: CONFIRMED -- ran directly, 45/45 PASS.
- 20 files staged + Batch E untouched: CONFIRMED -- git diff --cached --stat = 20 files; Batch E unstaged/untracked, 0 staged.

## Per-Concern Verdict Table (the 7 main-session-flagged)

| # | Concern | Verdict | Evidence |
|---|---|---|---|
| 1 | session-export-raw clean_text python->awk rewrite | DEFECT (IMPORTANT-2) | Behavioral divergence CONFIRMED empirically + Principle 11 gap (no clean_text TC) |
| 2 | attach-portability-smoke skip-marker | PASS | Rationale ACCURATE -- hard YAML dep |
| 3 | Check 7 inline-comment skip heuristic | DEFECT (MINOR-1) | Adversarial case CONFIRMED skips a genuine grep |
| 4 | Check 1/8 skip-markers per-FILE | PASS (accepted tradeoff) | matches Check 1/8 per-file reporting granularity |
| 5 | Check 6b SESSION_ID regex gap | DEFECT (MINOR-2) | dollar-brace-SESSION_ID IS missed; currently latent |
| 6 | All 14 skip-marker rationales | PASS | All 14 verified accurate against actual code |
| 7 | bash-hook-lint.sh S318+S319b co-staged | PASS | S318 emit section unchanged by S319b; S319b checks demarcated |

### Concern 1 -- session-export-raw clean_text python->awk rewrite: DEFECT (IMPORTANT-2)

EMPIRICAL TEST (fed identical input to python re.sub reference and the new awk state machine). Divergences CONFIRMED -- awk LOSES content python preserves:
- (a) Same-line text before opening / after closing multi-line tag is LOST. Input "line before <system-reminder>" ... "</system-reminder> line after" -> python keeps "line before [stripped] line after"; awk outputs only "[stripped]" (the words before/after the tag are GONE -- awk replaces the whole opening line and the whole closing line).
- (b) A line with a complete single-line tag AND an opening multi-line tag loses the inline strip AND the surrounding text. Input "mixed <command-name>x</command-name> then <system-reminder>" -> python keeps "mixed [stripped] then [stripped]"; awk suppresses the line entirely (enters in_tag via the open-multi-line-tag loop, next, never runs strip_inline).
- (c) Unclosed multi-line tag suppresses to EOF. Input "unclosed <task-notification>" + N following lines -> python keeps the line + all following lines; awk prints nothing after the opening line -- total content loss to EOF.

session-export-raw.sh is transcript-provenance code with a documented prior-incident class (M-S13-pre-1, same file). clean_text runs on EVERY SessionEnd export. Real Claude Code transcript lines DO contain text adjacent to tags, so (a) is a live provenance-loss risk, not a theoretical edge case. (c) is lower-probability but catastrophic when it triggers.

Principle 11 gap (compounding): session-export-raw-fire-test.sh has 7 TCs -- ALL exercise SESSION_N extraction. ZERO TCs exercise clean_text (file:1-198). The dev rewrote a REAL source function and shipped NO companion firing-test TC for the rewrite.

Evidence: scripts/hooks/session-export-raw.sh:67-108 (awk clean_text); scripts/hooks/firing-tests/session-export-raw-fire-test.sh:50-197 (no clean_text coverage).

Severity rationale: IMPORTANT not CRITICAL because (a) the L-S11-1 violation it closed IS genuinely closed, (b) the divergence degrades provenance fidelity but does not crash or block, (c) the most common transcript shape (tag on its own line) IS handled correctly. But it is a real behavioral regression on incident-class code with no test -- must be addressed.

### Concern 2 -- attach-portability-smoke skip-marker: PASS

The dev triage-table phrasing "REAL (accepted false-positive via skip-marker)" is self-contradictory WORDING, but the SUBSTANCE is correct. attach-portability-smoke.sh:66 + :242 use python -c with PyYAML for genuine YAML manifest parsing; line ~97 "[FATAL] python assertion harness failed" + exit 2 confirm it is a hard dependency by design. There is no portable bash YAML parser. The plan offered rewrite-OR-PHASE-1+-guard -- but Check 1 never implemented PHASE-1+ detection (verified: bash-hook-lint.sh Check 1 lines 44-58 have no PHASE-1+ logic, only the new skip-marker). Implementing PHASE-1+ detection would be strictly more complex than the skip-marker for identical effect. The skip-marker rationale (attach-portability-smoke.sh:17) is accurate and specific. Legitimately-ratified exception, NOT a ghost-green.

### Concern 3 -- Check 7 inline-comment skip heuristic: DEFECT (MINOR-1)

ADVERSARIAL PROBE CONFIRMED THE HOLE. Synthetic hook body: set -uo pipefail / trap exit-0 ERR / LOG=/tmp/x / echo "a#b" && VAR=$(grep "pattern" "$LOG"). Ran Check 7 awk against it -> NOT FLAGGED. The grep is a GENUINE unguarded grep under pipefail+ERR-trap, but the heuristic (hash_pos = index(full,hash); grep_pos = index(full,grep); if hash_pos>0 && hash_pos<grep_pos then next) sees the hash inside the quoted string "a#b" (position before grep) and skips the whole line. The heuristic cannot distinguish a hash inside a string from a hash starting a comment.

The dev S319b report (line 240) acknowledges it "would incorrectly skip a line like # comment && grep file" but dismisses it as not occurring in the codebase -- my probe shows the simpler and more common pattern (a hash in ANY string anywhere before a grep on the same line) also trips it. The companion TC TC-C-inline-comment only covers the benign "# grep log" case (grep IN the comment), not the adversarial case (grep AFTER a string-embedded hash).

Evidence: scripts/hooks/bash-hook-lint.sh:292-294 (the heuristic); scripts/hooks/firing-tests/bash-hook-lint-fire-test.sh TC-C-inline-comment (insufficient coverage).

Severity: MINOR as a detector-precision regression -- Check 7 now has a blind spot it did not have before S319b. It is not currently hiding a known violation in the live tree (the 3 Batch E L-S48d-1 hits still fire), so not an active ghost-green TODAY, but it WILL silently miss future genuine violations of this shape. Should be tightened (strip quoted strings before the hash test, or require the hash to be preceded only by whitespace/semicolon/ampersand).

### Concern 4 -- Check 1/8 skip-markers are per-FILE: PASS (accepted tradeoff)

Confirmed per-file: bash-hook-lint.sh:51 and :327 skip the ENTIRE file when the marker is present. Plan said per-line. HOWEVER: Check 1 and Check 8 both REPORT per-file (one emit per file, not per-line -- verified Check 1 lines 55-57, Check 8 lines 332-334), so a per-file skip-marker matches the detector own granularity. The risk -- a future violation added to a skip-marked file gets permanently hidden -- is real but BOUNDED: (a) only affects the 9 L-S11-1 + 5 L-S53-2 already-ratified files, (b) the skip-marker line carries an explicit rationale a future editor will see, (c) tightening to per-line would require correlating marker-line-number with grep-line-number, materially more complex. Accept as a documented tradeoff.

### Concern 5 -- Check 6b SESSION_ID regex gap: DEFECT (MINOR-2)

CONFIRMED: the narrowed HAS_MARKER regex (suffix -(fired|marker|ran|flag|written|pending)-dollarbrace-(SID|SESSION|SESS|CLAUDE_SESSION_ID)[^A-Z_]) does NOT match a marker of the form dot-foo-fired-dollarbrace-SESSION_ID -- because after SESSION the next char is underscore, which FAILS the [^A-Z_] class. Probe results: SESSION_ID form -> NOT MATCHED; SID form -> matched; bare-dollar-SID-space -> matched. So a hook using the natural SESSION_ID form in a marker filename would be a genuine L-S108-1 violation that Check 6b silently misses.

Mitigating: searched all of scripts/hooks/ -- NO current hook uses dollarbrace-SESSION_ID (or any fired/marker/ran/flag/written/pending suffix variant) in a marker filename. The one SESSION_ID marker-ish usage (post-dev-dispatch-attestation-check.sh:97 .dispatch-pending-SESSION_ID.jsonl) does not match the -(fired|marker|...) token set anyway. AND raw dollar-CLAUDE_SESSION_ID markers are still caught by Check 6 (bash-hook-lint.sh:174). So this is a LATENT precision gap, not an active ghost-green.

Severity: MINOR -- but note the irony: SESSION is in the alternation specifically to catch SESSION-prefixed forms and the [^A-Z_] boundary defeats that exact intent. Fix: change [^A-Z_] to (_ID)?[^A-Z] or drop the trailing boundary for the SESSION arm. Evidence: scripts/hooks/bash-hook-lint.sh:209.

### Concern 6 -- All 14 skip-marker rationales: PASS

Read the ACTUAL flagged code in every skip-marked file and verified each rationale is accurate (the claimed guard/fallback/content-search context genuinely exists, not merely asserted).

L-S11-1 (9): all ACCURATE.
- autonomous-stop-watchdog.sh:13 -- jq at :34-36 inside if-command-v-jq with BASH_REMATCH else-branch (:41-42). OK.
- firing-test-spawn-context-lint.sh:24 -- python3 heredoc at :65 with alt-guard true; empty inventory -> SKIP+exit 0 at :113. OK.
- harness-health-self-scan.sh:8 -- python3 at :74 is the alt-branch of (date -d ... OR python3 ... OR echo empty). OK.
- post-dev-dispatch-attestation-check.sh:11 -- python at :143-144 behind elif-command-v-python. OK.
- qa-pending-stale-mover.sh:7 -- python3 at :32 inside if-command-v-python3 (:31); continue fallback. OK.
- redact-secrets.sh:8 -- confirmed 3-tier command-v-python3 (:15) -> elif-command-v-node (:34) -> else-sed (:53). OK.
- subagent-stop-logger.sh:8 -- jq at :23-25 inside if-command-v-jq (:22) with BASH_REMATCH fallback. OK.
- vendor-api-probe.sh:8 -- line 3 header pre-existing "Phase 1+ relaxes L-S11-1 portability (Python OK)"; python at :40 is importlib probe core. OK.
- attach-portability-smoke.sh:17 -- hard YAML dep, see Concern 2. OK.

L-S53-2 (5): all ACCURATE.
- autonomous-stop-watchdog.sh:14 -- grep at :80 is content-search on transcript-tail narration (pattern has S-N-entry-is-next MID-pattern); caret anchor would be semantically wrong. OK.
- promotion-cycle-trigger.sh:10 -- grep at :51 (basename pipe grep-oE S-N) on promote-rule-S52.md token; caret-S never matches. (:28 is separately caret-##-S-N anchored.) OK.
- session-start-bootstrap.sh:13 -- grep at :91 is (awk-scoped Active-Focus-Track section pipe grep-oE Track-N). (:77 separately anchored.) OK.
- stale-prompt-detector.sh:8 -- greps at :95 Track-N and :109 word-boundary-S-N on free-form USER_PROMPT; word-boundary is the correct mechanism. OK.
- sync-grilling-call.sh:43 -- greps at :102-103 on DEC_ID content like sync-grilling-S102; S-N mid-string after prefix. OK.

No skip-marker hides a genuine violation. No inaccurate rationale found.

### Concern 7 -- bash-hook-lint.sh S318+S319b co-staged: PASS

The staged diff shows the S318 Emit-results change (added S318 comment + NOTIF_FILE assignment hoisted out of the if so the else branch can rm -f) -- these appear as added lines because S318 itself was never committed (exactly the brief framing). They are S318 work, NOT S319b. The S319b Check edits (Check 1 skip-marker :39-51, Check 6b narrowing :185-209, Check 7 substr+inline-comment :262-294, Check 8 skip-marker :315-327, Check 9 substr :371-377) are in earlier regions, non-overlapping with the emit section, and every added block carries an explicit "S319b lint-calibration:" demarcation (9 added lines tagged S319b confirmed via grep). S318 region unchanged by S319b. OK.

## Core-DoD Verdict Table (beyond the 7)

- Charter P11 -- every Check calibration has dual-property TC: PARTIAL (MINOR-3). Check 1/6b/8 have full dual TCs (FP-suppressed + genuine-still-fires); Check 7 inline-comment has only the FP-half TC; no TC exercises the backslash-continuation carry path the substr fix actually modified.
- Check 7/9 backslash-EOL -> substr fix correct: PASS. substr logic verified empirically (printf of abc+backslash piped to awk substr -> END-BS); TC-C..TC-C-and-chain 45/45 still fire.
- Check 7 violation-detection TCs still fire: PASS. TC-C (bare grep), TC-C2 (cmd-sub), TC-C3 (pipeline), TC-C-tricky-bare all PASS in the 45/45 run.
- harness-health-self-scan L-S48d-1 :57 + :244-245 genuine fixes: PASS. :57 start_line grep pipeline now has alt-guard true -- genuinely was unguarded under pipefail+trap; :244-245 both greps alt-guard true added -- genuine. :137 (if tail-1 pipe grep-q) correctly NOT flagged (inside if).
- S319a 6 edits genuine recipe fixes: 5 of 6 PASS, 1 DEFECT (IMPORTANT-1). attach-portability-smoke / idle-escape-detector / phase-status-coherence / bootstrap-summary-renderer / harness-health-self-scan(3 sites) -- all genuine + downstream-safe (each count is used only in -gt/-lt/-eq comparisons so binary 0/1 is equivalent). daily-backup.sh -- REGRESSION, see IMPORTANT-1.
- bootstrap-summary-renderer.sh borderline check: PASS. brace-group form { grep ... OR true; } pipe tail-3 pipe awk (bootstrap-summary-renderer.sh:78) puts the alt-guard on grep physical line; semantically identical to the old alt-guard on the awk-closing line; genuine fix, not mere detector-visibility relocation (the alt-guard genuinely guards the grep either way).
- Batch E untouched: PASS. 4 files unstaged-modified + idle-state-advisory untracked; git diff --cached shows ZERO staged changes for all 5.
- bash -n clean: PASS. all 20 staged files clean.
- run-all.sh >= 103/103 reproduced: PASS. 103/103 (this session) + S319a 2x + S319b 2x per dev reports.

## NEW Defects Found (not in the 7)

### IMPORTANT-1 -- daily-backup.sh: ghost-green that BREAKS the hook (SIGPIPE regression)

daily-backup.sh has set -uo pipefail (:18) + trap exit-0 ERR (:19). S319a replaced:
  OLD: VERIFY_HITS=$(tar -tzf ARCHIVE 2>/dev/null | grep -cE PROJECT_CHARTER|CLAUDE|agent-workspace 2>/dev/null OR echo 0) ; if VERIFY_HITS -gt 0 then ARCHIVE_OK=1
  NEW: if tar -tzf ARCHIVE 2>/dev/null | grep -qE PROJECT_CHARTER|CLAUDE|agent-workspace ; then ARCHIVE_OK=1 ; fi
(scripts/hooks/daily-backup.sh:87-92)

EMPIRICAL REPRODUCTION (built a ~1MB / 54-entry .tar.gz, ran under set -uo pipefail): the tar pipe grep-q expression returned RC=141 FAIL. grep -q quits on the FIRST match. When PROJECT_CHARTER.md matches EARLY in the tar stream, tar receives SIGPIPE (RC=141), pipefail propagates it, the if condition is non-zero -> ARCHIVE_OK stays 0 -> daily-backup logs "WARN archive failed content-verify ... not marking done" and exit 0. A GOOD backup is silently treated as FAILED.

This is the EXACT bug the pre-existing comment at daily-backup.sh:83-86 documents and warns against: use grep -c (consumes ALL input) not grep -q (quits early) -- with set -o pipefail, grep -q exiting early on a large tar stream gives tar SIGPIPE, and pipefail then propagates tar failure -> false negative; grep -c avoids this. The dev reintroduced the bug AND left the contradicting comment in place. daily-backup.sh is committed R3 mass-deletion-prevention code -- a silently-non-marking backup defeats the safeguard. daily-backup-fire-test.sh passed 6/6 only because its fixture archive ordering/size does not deterministically hit the early-match SIGPIPE path (coverage gap).

This is a ghost-green: the L-S80-2 lint violation IS silenced, but the fix broke the hook actual function. Plan DoD #5 explicitly forbids this.

FIX (for follow-up dev): keep the grep -c form (which the old comment correctly chose) and apply the L-S80-2-safe recipe properly: set +o pipefail bracket around the tar pipe grep-c, OR VERIFY_HITS=$( ( tar -tzf ... pipe grep -cE ... ) OR echo 0 ) with the subshell + OR-echo-0 so the SIGPIPE-driven non-zero is absorbed and the count is clean. Do NOT use grep -q on the tar pipeline. Then add a daily-backup-fire-test TC with a large archive whose verify-pattern matches an EARLY entry.

### IMPORTANT-2 -- session-export-raw.sh clean_text awk rewrite (detailed under Concern 1)

Behavioral divergence from python re.sub (same-line-adjacent text loss, mixed-line inline-strip loss, unclosed-tag-to-EOF suppression) + ZERO companion firing-test TC for the rewritten function. Transcript-provenance incident-class code (M-S13-pre-1). See Concern 1 for full evidence.

### MINOR-1 -- Check 7 inline-comment heuristic blind spot (detailed under Concern 3)

Tighten the hash-pos < grep-pos heuristic so a hash inside a quoted string does not suppress a real same-line grep. scripts/hooks/bash-hook-lint.sh:292-294.

### MINOR-2 -- Check 6b SESSION_ID missed by narrowed regex (detailed under Concern 5)

The [^A-Z_] boundary defeats the SESSION arm. Latent -- no current hook uses that form. scripts/hooks/bash-hook-lint.sh:209.

### MINOR-3 -- No firing-test TC for the backslash-continuation carry path

The Check 7/9 backslash-EOL -> substr(line,length(line)) fix MODIFIED the multi-line-continuation carry mechanism. Verified: NONE of the TC-C* / TC-E* fixtures in bash-hook-lint-fire-test.sh use a physical backslash-line-continuation (checked all cat-redirect pipefail-*.sh and find-*.sh fixtures). The dev claim that TC-C through TC-C-and-chain still pass is true but those TCs do not exercise the code path the fix changed. Charter P11 dual-property coverage for the carry path is absent. Add a TC with a genuine backslash-continued grep that SHOULD fire and one guarded across a continuation that should NOT -- proving the substr carry still joins correctly. MINOR because the substr fix is independently verified correct by direct awk probe; this is a test-coverage gap, not a code defect. scripts/hooks/firing-tests/bash-hook-lint-fire-test.sh.

## Findings Summary

### IMPORTANT (must address before this remediation is done)
1. daily-backup.sh SIGPIPE regression (ghost-green) -- grep -q on large tar pipeline under pipefail silently fails good backups. scripts/hooks/daily-backup.sh:90. Reintroduces the bug the file own :83-86 comment warns against. Breaks R3 mass-deletion-prevention safeguard.
2. session-export-raw.sh clean_text awk rewrite -- behavioral divergence + no test. awk state machine loses same-line text adjacent to multi-line tags, loses inline strips on mixed lines, suppresses to EOF on unclosed tags; python re.sub preserved all three. ZERO companion firing-test TC for the rewritten function. scripts/hooks/session-export-raw.sh:67-108.

### MINOR (track + defer)
1. Check 7 inline-comment heuristic (hash-pos < grep-pos) skips a genuine grep when a hash appears in a quoted string before it. scripts/hooks/bash-hook-lint.sh:292-294.
2. Check 6b SESSION_ID is missed by the narrowed HAS_MARKER regex ([^A-Z_] boundary defeats the SESSION arm). Latent -- no current hook uses that form. scripts/hooks/bash-hook-lint.sh:209.
3. No firing-test TC exercises the backslash-continuation carry path that the Check 7/9 substr fix modified. scripts/hooks/firing-tests/bash-hook-lint-fire-test.sh.

### Cosmetic (no action required, noted for hygiene)
- S319b dev report triage-table phrasing "REAL (accepted false-positive via skip-marker)" is self-contradictory wording for attach-portability-smoke; substance is correct.

## Recommendation

FIX IMPORTANT FIRST -- then this remediation is merge-eligible.

Specific next action for the follow-up dev session:
1. Revert daily-backup.sh:87-92 to a grep -c-based form with proper L-S80-2 SIGPIPE-safe guarding (subshell + OR-echo-0, or set +o pipefail bracket); remove the now-stale contradicting comment only if the new form genuinely supersedes it; add a large-archive-early-match TC to daily-backup-fire-test.sh. Re-run the lint to confirm L-S80-2 still 0 for daily-backup AND the firing test goes green on the new TC.
2. Fix session-export-raw.sh clean_text awk: handle same-line pre/post-tag text (strip in place, do not replace the whole line), run strip_inline BEFORE the open-multi-line-tag check on mixed lines, and on unclosed-tag-at-EOF either keep the buffered lines or at minimum do not silently drop them. Add a session-export-raw-fire-test.sh TC block exercising clean_text: multi-line tag, single-line tag, mixed line, same-line-adjacent text, unclosed tag.
3. (MINOR, can batch later) tighten Check 7 inline-comment heuristic; widen Check 6b SESSION arm; add the backslash-continuation carry TC.

The 6 remaining lint violations (Batch E) are correctly gated on the human commit boundary and are NOT in scope here -- no action.

## Merge-Eligibility Statement

NOT merge-eligible as-is. The S319a+S319b diff correctly drives the lint 33->6 and keeps run-all.sh at 103/103, and 12 of the 14+ verified items PASS. But IMPORTANT-1 is a genuine functional regression on mass-deletion-prevention code (ghost-green -- exactly what Plan DoD #5 forbids), and IMPORTANT-2 is a behavioral regression on transcript-provenance incident-class code with no test coverage. Both must be fixed (and the relevant firing tests extended) before the S319 remediation can be considered done and the staged diff handed to the user for the commit boundary. The 3 MINOR defects can be tracked and deferred to a follow-up calibration pass.
