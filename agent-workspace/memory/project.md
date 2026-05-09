# Project Memory — StockForge

> Updated: 2026-05-08 (S189 — FOCUSED_IMPL-DONE-PENDING-PRODUCTION-VERIFICATION: D-045 HH-H.1 stale-checkpoint guard threshold relaxation 300s→1800s SHIPPED + D-044 H-c REJECTED at S189 1st production observation. **Trigger**: User prompt "sao không autonomous run tiếp. lỗi harness à. fix" at 14:55:44 — autonomous loop silently dead 26+ hours since S188 close 2026-05-07T12:25:23. **Root cause**: `.auto-reboot-BLOCKED-stale-checkpoint` marker from S188 Stop fire — `scripts/session-self-reboot.sh:32` HH-H.1 guard hardcoded `if CHECKPOINT_AGE > 300; then BLOCK`. S188 wrote latest.md at 12:14 then continued IMPL work; Stop fired 12:25:23 with mtime ~660s old > 300s → BLOCKED. Systematically too aggressive for 10-25min FOCUSED_IMPL turn duration. **D-045 fix**: scripts/session-self-reboot.sh +10 LOC (lines 15-44 modified): replaced hardcoded `300` with `HH_H1_THRESHOLD_S="${STOCKFORGE_HH_H1_THRESHOLD_S:-1800}"` (30min default + env override); updated condition + BLOCKED marker text + comment with S189 root-cause rationale. Defense-in-depth via HH-H.4 outer fence 7200s preserved. NO companion firing-test added (skip rationale: not-a-hook; sibling auto-reboot-handoff-verify-fire-test.sh covers same threshold-vs-mtime pattern; keystroke-sender resists safe testing). Verification: bash -n PASS + grep verification PASS + checkpoint freshness 81s post-write PASS; production validation DEFERRED to next auto-reboot fire. Recovery: rm BLOCKED marker + write fresh latest.md. **D-044 H-c REJECTED at S189 1st production verification**: chain at 14:55:44 INJECTED reach 5/9 (#1+#2+#4+#5 direct + #3 expected-silent); hooks #7 (.idle-escape.log MISSING) + #8 (.phase-coherence.log MISSING) + #9 (.harness-health.log last 12:16:38 yesterday firing-test SID) ALL SILENT — D-044 stdout JSON fix at hook #5 did NOT advance past #5/#6. **M-S189-1 NEW HIGH** (recurrence-class M-S171-1 + M-S176-1: harness design-time threshold tuning bites repeatedly). **S190 NEXT** = H-a test (non-destructive variant: redirect hook #5 stderr from `>&2` to APPEND `.hook-firing-counter-stderr.log`; preserves alert content while testing if stderr emission specifically triggers chain truncation). Predecessor S188 — D-044 SHIPPED unit-level. Predecessor S186/S187 — D-043 SHIPPED + chain advance #1→#5 PARTIAL-CONFIRMED.
> Update cadence: After phase boundaries, after significant decisions, weekly at minimum.
> Audit references: `agent-workspace/memory/observations/2026-05-07-S172-phase-audit-reconciliation.md` + `agent-workspace/memory/sessions/2026-05-07-session-173.md`.

## Current Phase

**Phase 3.5 — Harness Deepening (Empirical-Firing Discipline)** — IN PROGRESS PARTIAL-S173 (entered S50 2026-05-05; **T1+T2+T3+T4+T5+T6+T7 SHIPPED; T8 PROPOSED-cool-down 2026-05-09**). T5 protocol lives at `proposals/harness-health-protocol.md` pending mv→constitution per M-S173-1 deny-lift gap. T6 hook empirically firing on UserPromptSubmit + SessionStart with 12-signal HH-1..HH-12 catalog; production smoke detected RED-2 state on real project (HH-2 + HH-6 HIGH + HH-10 MEDIUM). T8 charter v1.0→v1.1 Principle 11 cool-down active. Plan: `agent-workspace/session-plans/pending/010-S50-phase-3.5-harness-deepening-master-plan.md`.

**Phase 3 — Tier 3+4 KOL + pump + outer-loop**: Track G+H DONE (S46/S47 per D-027); **Track I PAUSED** awaiting Phase 3.5 close; **Tracks J+K (BC-7 sentiment+pump per D-032 S65) PAUSED** awaiting Phase 3.5 close (sub-plan 009-S51 in pending).

**Phase 2.5 — Harness Hardening**: RITUAL-CLOSED 8/8 GREEN at S49a; empirically failed → ADDRESSED via Phase 3.5 firing-test discipline. 26/32 mandatory deliverables empirically DONE; 5 charter-aligned amendments/deferrals (HH-D.3/HH-E.3 optional + HH-F.1/HH-F.4 S48k+S48l Charter-Principle-8 deferrals); 2 NOT-STARTED (HH-G.1 + HH-G.3 portability gap — S173+ residue).

Goals (Phase 3.5 IN PROGRESS):
- T5 (NOT-STARTED): Author `agent-workspace/constitution/harness-health-protocol.md` (NEW constitution) — AskUserQuestion gate
- T6 (NOT-STARTED): `scripts/hooks/harness-health-self-scan.sh` continuous hook — depends T5
- T8 (NOT-STARTED): Charter ratify "Harness must self-verify firing" — AskUserQuestion gate
- HH-G residue (2): general-harness CLAUDE.md template + /attach smoke test
- M-S171-1 prevention hooks (2 NEW): `scripts/hooks/idle-escape-detector.sh` + `scripts/hooks/phase-status-coherence.sh`

autonomous_mode = true (RE-ENABLED 2026-05-05 S48; RESTORED 2026-05-06 S100). Charter Phase 3.5 user-gate items WAITING.

Plan files: `agent-workspace/session-plans/pending/010-S50-phase-3.5-harness-deepening-master-plan.md` (Phase 3.5 master); `agent-workspace/session-plans/pending/009-S51-track-J-K-impl-sub-plan.md` (Phase 3 BC-7 IMPL pending Phase 3.5 close); `agent-workspace/session-plans/pending/009-S48-harness-hardening-middle-phase.md` (Phase 2.5 HH-A..HH-H; closed S49a). Companion observations: `2026-05-05-harness-alignment-audit.md`, `2026-05-05-root-cause-3-axes.md`, `2026-05-07-S172-phase-audit-reconciliation.md`.

---

## Phase Goals Tracker

| Phase | Target | Status | Started | Completed |
|---|---|---|---|---|
| 0 — Harness Bootstrap | Workspace dualism, provenance, Confidence Score, Self-Awareness, port from orch | DONE | 2026-04-29 | 2026-04-30 (S22) |
| 1 — Foundation VHM Thin-Slice | Day 1 + UL glossary 42 VN terms + monorepo 9 BCs + first entities BC-1+BC-9 + Tier 1 ingestion + 248 VHM bars + thesis template + VHM exemplar | DONE | 2026-04-30 (S23) | 2026-04-30 (S30) |
| 2 — Foundation Tier 1+2 | VN30 rollout ~30 tickers; BC-2 Fundamental + BC-5 News; R2 closure via SSI direct httpx; Track F thesis pipeline 3-perspective; 9 charter promote bundles | DONE | 2026-04-30 (S31) | 2026-05-04 (S43e/S43f) |
| 2.5 — Harness Hardening | 8 tracks HH-A..HH-H: foundation / telemetry / ritual / Mode-E charter / Q&A escalation / self-knowledge bootstrap / portability / auto-reboot safety | DONE (28/32 mandatory empirically DONE; 4 charter-aligned amendments/deferrals — HH-D.3/HH-E.3 optional + HH-F.1/HH-F.4 S48k+S48l Charter-Principle-8 deferrals; HH-G.1+HH-G.3 closed S174 per Q4=A user-pick) | 2026-05-05 (S48) | 2026-05-07 (S174 HH-G close; S49a ritual + S73 T7 retro-fix + S174 HH-G portability) |
| 3 — Tier 3+4 KOL + pump + outer-loop | BC-6 Influence Network (Track G+H DONE S46/S47 per D-027; Track I PAUSED) + BC-7 sentiment/pump (D-032 S65 architecture; Tracks J+K sub-plan 009-S51 PAUSED awaiting 3.5 close) + BC-9 outer-loop | PAUSED awaiting Phase 3.5 close | 2026-05-05 (S44) | - |
| 3.5 — Harness Deepening (Empirical-Firing Discipline) | 8 tracks T1..T8: post-mortem / Stop→UserPromptSubmit migration / promote-rule backlog / charter L-S49b-4 / harness-health-protocol / harness-health hook / firing-tests retrofit / charter ratify | IN PROGRESS PARTIAL-S173 (T1+T2+T3+T4+T5+T6+T7 SHIPPED; T8 PROPOSED-cool-down ≥2026-05-09; M-S173-1 deny-lift gap on T5 mv→constitution) | 2026-05-05 (S50) | - (close pending T8 charter edit ≥S180) |
| 4 — Multi-perspective | Adversarial agents, thesis system maturation | NOT STARTED | - | - |
| 5 — Compounding | Karpathy outer loop, calibration drives weights | NOT STARTED | - | - |

---

## Recent Architectural Decisions (last 5)

> Newest first. Keep only last 5. Full ADRs in `agent-workspace/memory/decisions/`.

### 2026-05-08 — D-045 — S189 HH-H.1 stale-checkpoint guard threshold relaxation 300s→1800s — autonomous-loop revival after S188 close BLOCKED 26+ hours (FOCUSED_IMPL; ACCEPTED-AND-SHIPPED)
**Source**: User prompt "sao không autonomous run tiếp. lỗi harness à. fix" 2026-05-08T14:55:44 + `.auto-reboot-BLOCKED-stale-checkpoint` marker from S188 12:25:23 yesterday + scripts/session-self-reboot.sh:32 HH-H.1 hardcoded 300s threshold + S188 turn timeline reconstruction (12:03 UPS → 12:14 latest.md write → 12:24 last edit → 12:25:23 Stop with mtime ~660s > 300s → BLOCKED) + harness_priority_one + autonomous_continue_no_self_pause + Charter Principle 8 (cheapest-first probe).
**Picks**: A (relax 300s→1800s with env override `STOCKFORGE_HH_H1_THRESHOLD_S`; defense-in-depth HH-H.4 7200s outer fence preserved). Alternatives rejected: B=auto-touch-latest-at-Stop (R2 false-fresh signal — decouples mtime from content updates, exactly what HH-H.1 was designed to prevent); C=content-based-session-ID-check (~30+ LOC parser + tests; scope creep + format fragility); D=hybrid-relax-plus-LLM-reminder (LLM-instruction non-deterministic per CLAUDE.md doctrine); E=eliminate-HH-H.1-rely-on-HH-H.4 (loses near-reboot freshness check); F=defer-with-FORCE_REBOOT-manual (AP-7 vacuous defer; user explicitly requested fix).
**Impact**: scripts/session-self-reboot.sh +10 LOC (HH-H.1 guard parameterized + env override + comment expansion with S189 D-045 rationale + BLOCKED marker text references runtime-formatted threshold not hardcoded 300s). NO companion firing-test added (Step 2 skip rationale: session-self-reboot.sh is invoked-script not Claude Code event hook; sibling auto-reboot-handoff-verify-fire-test.sh covers same threshold-vs-mtime pattern at HH-H.4 outer fence; keystroke-sender at lines 61-99 resists safe automated testing without env-gate pollution; empirical at next auto-reboot fire is more authentic than mock). Verification: bash -n PASS + grep HH_H1_THRESHOLD_S declaration + condition + BLOCKED marker runtime-format PASS + checkpoint freshness 81s age post-write PASS. Recovery: rm `.auto-reboot-BLOCKED-stale-checkpoint` marker + write fresh latest.md. M-S189-1 NEW HIGH (recurrence-class M-S171-1 + M-S176-1; promotion candidate L-S189+-1 IF 2nd instance of harness-guard-too-strict surfaces). Production validation deferred to next auto-reboot fire when current S189 session crosses WIND_DOWN/CLIFF threshold. **Sibling finding (S189 same turn)**: D-044 H-c REJECTED at 1st production verification 14:55:44 — hooks #7/#8/#9 ALL silent; S190 PRIORITY 1 = H-a test (non-destructive stderr-redirect variant).
**Status**: ACCEPTED-AND-SHIPPED.

### 2026-05-07 — D-044 — S188 chain-stop discrimination at #5/#6 boundary — H-c additive stdout JSON fix to hook-firing-counter.sh (FOCUSED_IMPL; SHIPPED-REJECTED-AT-PRODUCTION-VERIFICATION-S189)
**Source**: S187 checkpoint NEXT ACTION PRIORITY 1 (root cause discrimination at NEW chain-stop boundary #5/#6 with 3 candidate hypotheses H-a/H-b/H-c) + observation 2026-05-07-S188-userprompt-chain-stop-discrimination.md 6-fold evidence (S187 chain-advance reproduction at 12:03:01 + H-b passive timing 1.391s standalone + 1.746s cumulative #1+#4+#5 + Option B-vs-A discrimination design + H-c fix shipped + 4-fold unit verification PASS) + Charter Principle 8 (cheapest-first probe by RISK not LOC) + harness_priority_one + L-S176-1 BINDING + Phase 3.5 Hard Rule #2 + AP-23 1st-instance refinement-of-cheapest-test doctrine.
**Picks**: B (H-c additive stdout JSON emit; non-destructive, preserves silent-hook stderr alert, equally informative as H-a comment-out, +5 LOC vs +2 LOC commented). Alternatives rejected: A=H-a-comment-out-stderr (DESTRUCTIVE — disables silent-hook alert during test window 1+ trivial-prompt event); C=H-a+H-c-combined-fix (loses discrimination value; inherits A's destructive cost); D=H-b-grep-load-refactor (~30 LOC blast radius before H-b confirmed; passive timing INCONCLUSIVE at marginal boundary); E=diagnostic-only-log-line (S188 PRIORITY 1 = ROOT-CAUSE DISCRIMINATION not just observation); F=defer-S188-PRIORITY-1 (violates harness_priority_one + AP-7 vacuous defer pattern).
**Impact**: scripts/hooks/hook-firing-counter.sh +5 LOC tail stdout JSON emission preserving both branches (silent>0 + all-fired) unified envelope `{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":""}}`. Companion firing-test +69 LOC (TC4 NEW H-c contract on all-fired path + TC5 NEW H-c contract on silent>0 path; file-based fixture pattern per L-S176-1+S186 refinement; 109→178 LOC; 3-TC→5-TC). Verification stack 4-fold: (1) smoke-test JSON shape exact match contract + log entry preserved + stderr alert preserved; (2) individual firing-test 5/5 PASS; (3) full firing-test suite 82/82 PASS elapsed 224s zero regression vs S184/S186 baseline; (4) H-b passive timing measurement 1.391s standalone INCONCLUSIVE at marginal 2s boundary. Working-memory budget RESTORED: latest.md 12140B → ~3.5KB; bulk archived to checkpoints/2026-05-07-S187-archive.md (~140 LOC). Production validation pending S189+ at next real /clear+trivial-prompt event for hooks #7/#8/#9 standalone .log emission. Counter-factual recovery if H-c CONFIRMED: hooks #6-#9 emission rate 0% → ~100% (worst case iterative S189+ retro-fit ~50 LOC × 4 = ~200 LOC if multi-segment chain). Phase 3.5 §HH-G empirical-firing-exemplar contract for UserPromptSubmit cadence: 4/9 → expected 5+/9 post-S188 (if H-c CONFIRMED), target 9/9 post-S189+ retro-fit. Refinement-of-cheapest-test doctrine (LOC-vs-RISK trade-off in Option A vs B selection) captured in observation but NOT promoted per AP-23 1st-instance rule; promotion candidate L-S188+-1 IF 2nd instance surfaces.
**Status**: SHIPPED-PENDING-PRODUCTION-VERIFICATION.

### 2026-05-07 — D-043 — S186 UserPromptSubmit hook chain truncation Option D empirical-test fix — minimal stdout JSON on SKIP path (FOCUSED_IMPL; ACCEPTED-AND-SHIPPED)
**Source**: S185 checkpoint NEXT ACTION PRIORITY 1 (Option D empirical test — modify userprompt-invariants-injector trivial path emit minimal hookSpecificOutput JSON; observe chain advances to #2 on subsequent trivial prompt) + observation 2026-05-07-S185-userprompt-chain-truncation-rc.md 5-fold evidence catalog (chain emission counts hook #1=157/157 / hook #2=29/157 / hooks #4-#9=0/157; hook #1 path bifurcation 128 SKIP no-stdout vs 29 INJECTED stdout-JSON; stale-prompt-detector emissions 1:1 match with INJECTED-path fires; manual chain run all 9 hooks rc=0 ~3s wall time → not bash issue; S185 real-time confirmation) + Charter Principle 8 (cheapest-first probe before committing to full retro-fit) + harness_priority_one + L-S176-1 BINDING + Phase 3.5 Hard Rule #2.
**Picks**: D (single-hook empirical test; modify only userprompt-invariants-injector.sh SKIP path; FOCUSED_IMPL ~30-50K main; falsifiable in single observation). Alternatives rejected: A=full-retro-fit-immediately (~450 LOC blast radius before hypothesis confirmed); B=disable-trivial-SKIP-entirely (regresses context-budget conservation; +30K tokens per ~50 trivial prompts in autonomous loop); C=chain-keepalive-sidecar-hook (doubles chain length; hypothesis says EACH hook needs to emit, sidecar does not solve); E=tier-1-only-partial-retrofit (~80-120K main; still leaves 6 hooks truncation-prone); F=file-tail-monitor (diagnostic-only, does NOT fix root cause).
**Impact**: scripts/hooks/userprompt-invariants-injector.sh +5 LOC trivial-path JSON emission preserving log entry + INJECTED path behavior (TC4+TC6 verify INJECTED unchanged). Companion firing-test +130 LOC (TC1-TC3 assertion rewrite from field-absence to JSON-shape-with-empty-value via file-based parse + TC7 NEW S186 chain-continuation contract; assert_skip_path_json helper introduced). Verification stack 4-fold: (1) smoke-test JSON shape exact match contract; (2) SKIP-log entry preserved unchanged; (3) individual firing-test 7/7 PASS; (4) full firing-test suite 82/82 PASS elapsed 223-224s zero regression vs S184 baseline. Production validation pending next real `/clear` event for `stale-prompt-detector: clean (no stale refs)` line in `.session-hooks.log`. If hypothesis CONFIRMED in S187+ → queue Option A full retro-fit ~50 LOC × 8 = ~400 LOC for remaining 8 UserPromptSubmit chain hooks (in-flight-subagent-watcher / hook-firing-counter / effort-escalation-detector / idle-escape-detector / phase-status-coherence / harness-health-self-scan + emit-on-clean-state for stale-prompt-detector + correction-rate-tracker). Test fixture-delivery-mechanism shell-escape trap caught + fixed in TDD loop (refinement of L-S176-1 fixture-real-state, NOT 2nd-instance promotion per AP-23 1st-instance rule; same class as L-S181-1 fixture-vs-regex-quantifier).
**Status**: ACCEPTED-AND-SHIPPED.

### 2026-05-07 — D-042 — S184 continue-injector spawn extraction restores SessionStart hook chain on Windows (FOCUSED_IMPL; ACCEPTED-AND-SHIPPED)
**Source**: S183 checkpoint NEXT ACTION PRIORITY 1 (Option A fix — extract spawn into separate hook AFTER harness-health-self-scan in chain order) + observation 2026-05-07-S183-harness-health-non-emission.md 5-fold evidence + scripts/hooks/session-start-bootstrap.sh:174-198 spawn block + .claude/settings.json:138-211 chain ordering + agent-notes.md L-S176-1 BINDING + Phase 3.5 Hard Rule #2 (companion firing-test mandatory).
**Picks**: A (Extract + reorder LAST; companion firing-test). Alternatives rejected: B=move-to-PowerShell-watcher (over-engineering; daemon lifetime ambiguity); C=sync-blocking SendKeys (Windows lacks native xdotool equivalent); D=disable-injector-entirely (regresses S8 user-validated autonomous-loop primary contract); E=defer-and-bundle-with-UserPromptSubmit-fix (AP-7 vacuous defer; counter-factual 60+ missed self-scan emissions per ~12-hour window grows linearly).
**Impact**: NEW `scripts/hooks/continue-injector-spawn.sh` (+105 LOC) extracts spawn block verbatim — preserves SOURCE parsing + autonomous_mode gate + STOCKFORGE_FORCE_CONTINUE_ON_CLEAR override + platform branches (MINGW/Darwin/Linux) + .session-hooks.log emission. Bootstrap.sh -68 LOC (204→136). Settings.json +5 LOC (1 chain entry appended LAST). NEW companion firing-test +210 LOC / 9 TCs covering source-gating × autonomous-gate × override-env × skip-paths × missing-exec-file × empty-payload. Full firing-test suite 82/82 PASS (was 81; zero regression). Empirically verified spawn truncation no longer harms downstream chain hooks (no downstream targets exist after spawn). Production validation pending next real `/clear` event observable in `.session-hooks.log`.
**Status**: ACCEPTED-AND-SHIPPED.

### 2026-05-07 — D-041 — S181 HH-6 dispatch-pending sidecar sweep + HH-10 6 companion firing-tests batch ship (MULTI-TASK IMPL; ACCEPTED-AND-SHIPPED)
**Source**: S180 checkpoint NEXT ACTION PRIORITY 1 (HH-6 stale=6 + HH-10 orphans=6 cleanup) + S178 audit § HH-10 orphan refinement + scripts/hooks/harness-health-self-scan.sh:122-218 (HH-6 + HH-10 watchdog logic) + scripts/hooks/dispatch-jsonl-recorder.sh per-session sidecar contract + dispatch-jsonl-backfill.sh one-shot CLI (Plan 011 D2).
**Picks**: C (run-backfill-then-clean-sweep + full 6 firing-tests). Task A: backfill preserves 18-row recovery dataset via `.backfill-backup-20260507101244` (59635B) before deleting all 26 sidecars (HH-6 stale=0 post). Task B: 6 firing-tests REAL-STATE-DERIVED per L-S176-1, sandboxed per L-S174-1 — 35 NEW TCs across 6 files (HH-10 orphans=0 post). Alternatives rejected: A=conservative-6-only leaves 20 legacy rot + HH-10=3 still MEDIUM; B=delete-without-backfill loses recovery permanently; D=move-stashes-to-diagnostics requires dir restructure.
**Impact**: 26 sidecars deleted + 18 dispatch.jsonl rows recovered (10% rate) + 6 NEW companion firing-tests + .claude/settings.json verified all 6 orphans NOT-WIRED (utilities/CLIs/diagnostics, not active hooks); full firing-test suite 75→81 PASS elapsed 231s zero regression; harness-health-self-scan smoke state RED-2 → RED-1 (HH-6 + HH-10 both eliminated; remaining HH-2 + HH-9 pre-existing carry-overs); test fixture-vs-regex-quantifier mismatch caught + fixed within TDD loop (TC1 anthropic ≥80-char + TC3 google exactly-35-char) — doctrine application (L-S176-1 fixture-real-state extension), not new lesson.
**Status**: ACCEPTED-AND-SHIPPED.

### 2026-05-07 — D-040 — S180 boot-summary renderer trim + file-pattern-hook-pre-flight-lint hook ship (MULTI-TASK IMPL; ACCEPTED-AND-SHIPPED)
**Source**: SessionStart working-memory-budget-OVER notification (25226B / 20480B; OVER 23%) + S179 checkpoint NEXT ACTION PRIORITY 1 (file-pattern-lint hook ship per L-S176-1 promote-rule candidate) + observations/2026-05-07-S178-file-pattern-hook-compliance-audit.md § Promote-Rule Candidate spec + harness_priority_one doctrine.
**Picks**: C (combined ship of both Task A renderer trim + Task B lint hook). Task A: 2 truncation knobs in bootstrap-summary-renderer.sh (MAX_HEADER_LEN=250 / MAX_MISTAKE_LEN=250) + ASCII marker `...(truncated; see <source>)`. Task B: NEW `scripts/hooks/file-pattern-hook-pre-flight-lint.sh` ~190 LOC Stop hook with hour-bucket idempotency; 2 detection patterns (find-name glob + markdown-anchor regex `*#|>`); empirical eval via 9-name variable resolution table; `# pattern-lint-skip:` override; 12-TC REAL-STATE-DERIVED firing-test per L-S176-1.
**Impact**: Boot-summary 10343B → 2437B (saved 7906B / 76%); Tier-1 routine load 25226B → 17320B (under 20480 ceiling by 3160B / 15% headroom). Lint hook scans 80 hooks; production smoke v3 = 0 violations after 1 true positive resolved (sync-tracker dual-glob D-*.md backward-compat skip-comment). Detector regex bug surfaced + fixed within firing-test TDD loop (TC4 caught `find[[:space:]]+\$` missing `find "$VAR"` form). Renderer firing-test 13/13 PASS; lint firing-test 12/12 PASS; full firing-test suite 75/75 PASS (was 74; +1 new test file; zero regression; elapsed 214s).
**Status**: ACCEPTED-AND-SHIPPED.

### 2026-05-07 — D-037 — S175 M-S171-1 prevention hooks (idle-escape-detector + phase-status-coherence + 2 companion firing-tests + settings.json wiring)
**Source**: M-S171-1 mistake-log prevention rules #1+#2 verbatim + S174 checkpoint NEXT ACTION PRIORITY 1 + Phase 3.5 Hard Rule #2 every hook ships with firing-test.
**Picks**: A (2 dedicated UserPromptSubmit + SessionStart hooks vs B single-hook extension of harness-health-self-scan). Two-hook architecture maps to M-S171-1 prevention rules verbatim; per-prompt cadence catches drift before LLM composes 4th idle session response.
**Impact**: 4 NEW artifacts (idle-escape-detector ~170 LOC + phase-status-coherence ~200 LOC + 2 firing-tests ~190+~210 LOC) + .claude/settings.json wired UserPromptSubmit + SessionStart chains; companion firing-tests 31/31 PASS combined; production smoke real-state both GREEN; full-suite regression 74/74 PASS. M-S171-1 prevention rules #1+#2 closed (rule #3 escape doctrine encoded in severity matrix). Counter-factual: had hooks been wired at S148, the 22-session × ~100K-wasted-main slip converts to 1-session reconcile.
**Status**: ACCEPTED-AND-SHIPPED.

### 2026-05-07 — D-036 — S174 HH-G portability close (general-harness CLAUDE.md template + /attach smoke runner + companion firing-test + HH-G.4 procedures.md checklist)
**Source**: AskUserQuestion S173 Q4=A "HH-G portability FIRST" + Phase 2.5 audit S172 § HH-G NOT-STARTED + Phase 3.5 Hard Rule #2 every hook ships with firing-test.
**Picks**: A (4 NEW artifacts: HH-G.1 standalone template at templates/general-harness/CLAUDE.md ~207 LOC / ~2.7K tokens portable + HH-G.3 deterministic 3-check smoke runner ~280 LOC / 21 assertions + companion firing-test ~210 LOC / 5 test scenarios + HH-G.4 portability checklist +60 LOC).
**Impact**: Phase 2.5 HH-G residue closed; Phase 2.5 mandatory deliverables empirical-DONE 28/32 (up from 26/32). Smoke 21/21 PASS state=GREEN; firing-test 7/7 PASS. Mid-dev fixes captured: Git Bash path conversion + Windows CRLF strip + ERR-trap-on-rc1 (L-S174-1).
**Status**: ACCEPTED-AND-SHIPPED.

### 2026-05-07 — D-035 — S173 T6 harness-health-self-scan.sh hook (continuous UserPromptSubmit+SessionStart self-scan; 12-signal impl; firing-test 7/7 PASS; production smoke RED-2)
**Source**: AskUserQuestion S173 Q3=A "Approve as designed" + Phase 3.5 plan §T6 + D-033 protocol contract + Phase 3.5 Hard Rule #2 (every hook ships with firing-test).
**Picks**: A (UserPromptSubmit + SessionStart triggers; <2s perf; system-reminder/stderr emission; cheap-first ordering; 5-min cache TTL; KI-S49b-1 suppression).
**Impact**: scripts/hooks/harness-health-self-scan.sh ~280 LOC + companion firing-test ~270 LOC + .claude/settings.json wired + production smoke RED-2 detection (HH-2 + HH-6 HIGH + HH-10 MEDIUM) — empirical-firing evidence captured.
**Status**: ACCEPTED-AND-SHIPPED.

### 2026-05-07 — D-034 — S173 T8 Charter Revision v1.1 PROPOSAL (Principle 11 — Harness Self-Verify Firing) — Cool-down 48hr Active
**Source**: AskUserQuestion S173 Q2=A "Approve verbatim + cool-down" + Phase 3.5 plan §T8 + PROJECT_CHARTER.md § Revision Protocol (48hr cool-down mandatory).
**Picks**: A (verbatim wording + version bump v1.0→v1.1 + cool-down honored). Earliest charter file edit ≥2026-05-09 (post-cool-down).
**Impact**: agent-workspace/proposals/charter-revision-v1.1-harness-self-verify-firing.md ~250 LOC; charter file edit deferred ≥S180; HH-8 charter md5 signal monitors stability during cool-down.
**Status**: PROPOSED (cool-down 2026-05-07 → 2026-05-09 active).

### 2026-05-07 — D-033 — S173 T5 Harness Health Protocol charter-tier authoring (12-signal catalog HH-1..HH-12)
**Source**: AskUserQuestion S173 Q1=A "Approve as drafted (12 signals)" + Phase 3.5 plan §T5 + M-S49b-1 + Phase 2.5 surfaces + 22-session ROUTINE-IDLE pattern (M-S171-1).
**Picks**: A (12-signal catalog; binding contract for T6 hook; charter-tier deny-lift for amendments).
**Impact**: agent-workspace/proposals/harness-health-protocol.md v1.0 ~700 LOC. Mv→constitution BLOCKED by M-S173-1 deny-lift gap (settings.json path-based deny intercepts Bash filesystem ops despite defaultMode:bypassPermissions). Functional impact zero (T6 hook implements signals inline; protocol = reference doc).
**Status**: ACCEPTED (file at proposals/ pending mv workaround).

### 2026-05-06 — D-032 — S65 BC-7 Crowd Sentiment + Pump Detection architecture (Tracks J+K; SQLite extension; PostAggregator Protocol; deterministic 7-state NarrativePhaseClassifier + 5-state PumpPhaseClassifier; LLM bear-points grounded in 3 sources for counter-narrative)
**Source**: spec 003 crowd-sentiment-pump-detection + Phase 3 master-plan 007 § Track Catalog J/K + D-027 (BC-6 mirror schema) + S65 sandwich-architect dispatch (M-S65-1 collision-fix renumbered 028→032).
**Picks**: A1 SQLite continuity + B1 shared Protocol + 3 concretes (F319/FB/CafeF-Vietstock) + C1 domain aggregates + D1 D-026 LLM Substrate Boundary verbatim + E1/F1 deterministic phase classifiers + G1 LLM bear-points grounded + H1 3-feature coordination ensemble threshold ≥0.8 + I1 precision >0.5 recall >0.3 backtest gate.
**Impact**: ~290 LOC ADR. Sub-plan 009-S51 in pending/. Tracks J+K PAUSED awaiting Phase 3.5 T8 charter close (≥S180+).
**Status**: ACCEPTED via ARCH-tier (sandwich-architect S65).

### 2026-05-05 — D-031 — S48h HH-E.2 charter-promote agent-workspace/CLAUDE.md 4-condition Auto-mv rule (Q&A lifecycle contract revision)
**Source**: HH-E.1 qa-stale-urgent-escalator smoke (3/4 stale bundles surfaced) + S48g HH-E.2 proposal + S48h 1-Q AskUserQuestion Q-S48g-1=ACCEPT.
**Picks**: Auto-mv allowed IFF 4 conditions hold (frontmatter status starts with answered-/closed-/resolved- + no wait_until: future + no .auto-mv-paused kill switch + qa-pending-auto-mover.sh hook performs mv — direct manual mv still forbidden).
**Impact**: agent-workspace/CLAUDE.md § Connection to human-workspace/ extended; companion qa-pending-auto-mover.sh + qa-answered-detector.sh hooks active. 4 stale bundles drained subsequently; q-and-a/pending/ now empty.
**Status**: ACCEPTED via CHARTER-tier user-gate.

### 2026-05-05 — D-030 — S48f HH-D.2 charter-promote autonomous-protocol.md Rule 10 (Autonomous-Mode Defection Forbidden — Mode-E habit-pattern hardening)
**Source**: HH-D.1 proposals/autonomous-protocol-amendment-mode-E.md draft (S48e) + Mode-E cluster L-S44/M-S47-1 4-recurrence pattern (vocabulary game vs hook regex; Tier-3 escalation hook→skill→charter) + S48f 1-Q AskUserQuestion Q-S48e-1=ACCEPT.
**Picks**: Rule 10 verbatim 4-layer defense-in-depth (charter prompt-level rule + hook regex + skill semantic check + post-hook telemetry).
**Impact**: autonomous-protocol.md Rule 10 ratified prompt-level. Subsequent sessions: 0 self-pause family hits S48f→S171 confirmed (validates Tier-3 charter promotion thesis from root-cause-3-axes.md DRC-2).
**Status**: ACCEPTED via CHARTER-tier user-gate.

### 2026-05-05 — D-029 — S48d charter-promote drift-signals reconciliation (Tiered Coverage Map; DR1-DR12 ↔ D1-D9)
**Source**: S48c HH-B.4 audit observation + S48d 4-Q AskUserQuestion bundle Q2=ACCEPT.
**Impact**: drift-signals.md +40 LOC "Tiered Coverage Map" subsection (Tier-A/B/C); D9 zero-residue verified.
**Status**: ACCEPTED via CHARTER-tier deny-lift.

### 2026-05-05 — D-028 — S48d HH-C.4 CLAUDE.md § Session End ritual extension (5 → 9 steps)
**Source**: Phase 2.5 HH-C ritual codification + DRC-1 audit + S48d 4-Q AskUserQuestion bundle Q1=ACCEPT.
**Impact**: CLAUDE.md +50 tok always-loaded Tier 1. 4 NEW steps (#6 mistake-log update / #7 staleness verify / #8 auto profile-template / #9 auto promote-rule). Companion hooks HH-C.1/2/3 shipped same session.
**Status**: ACCEPTED via CHARTER-tier user-gate.

### Archived (pre-D-029, see `agent-workspace/memory/decisions/` for full ADR text)

D-028 (S48d HH-C.4 CLAUDE.md § Session End ritual extension 5→9 steps) / D-027 (S45 BC-6 Influence Network architecture) / D-026 (S43e Charter promote bundle C1+C2: LLM Substrate Boundary + Rule 4b) / D-025 (S43d Phase 2 envelope amendment +50-65%) / D-024 (S43c HR-4 memory-routing-tree CHARTER promotion) / D-018..D-023 (S43c Bundle 2 charter promote 7 amendments batch).

### Pre-S48 history (archived)

D-011/010/009/006/S16 — see `agent-workspace/memory/decisions/` for full ADR text.

### 2026-04-30 — D-011 — Phase 2 entry: Tier 1+2 VN30 rollout (SCOPE-tier user-gated)
**Source**: master-plan 004 § S30 + S30 AskUserQuestion 1Q + Charter § Month 6 success criteria + spec-T1-001 § B.2 + S29 verifier verdict PASS-WITH-RESIDUE.
**Picks**: Option A (Recommended) — Enter Phase 2 — chosen over B (Pause for dogfood week; user judged Phase 2 momentum more valuable) and C (User-approve 9 proposals first; runs in parallel, not a gate per D-011 § Option C analysis).
**Impact**: Phase 1 = COMPLETE 2026-04-30 (S25-S30 all DONE). Phase 2 entry approved SCOPE-tier; binding_phase: 2; Phase 2 PLAN next session (S31). Phase 2 expected scope: VN30 universe (~30 tickers) + BC-2 Fundamental + BC-5 News (CafeF/NDH/VietnamBiz) + R2 TCBS closure or pivot; ~600-900K envelope (similar to Phase 1).
**Status**: ACCEPTED via SCOPE-tier user-gate; Q-B2 doctrine satisfied (charter/SCOPE-tier explicit letter pick).

### 2026-04-30 — D-010 — VN-domain constitution amendment proposals (Rules 12-15 + I-S55-I-S65 + personal-risk-profile template)
**Source**: master-plan 004 § S26 + glossary v1.0 (S25; 42 VN terms) + spec 000 § B + Charter § First Sub-Scope + Day 1 § A.4 + § B.5.
**Picks**: Option B (separate proposal files for VN-domain Rules 12-15 vs S16 Hook Portability Rule 11) chosen over A (fold; conflates orthogonal concerns) and C (defer Phase 2; drifts master-plan).
**Impact**: 3 deliverables — financial-data-protocol-amendment-VN.md (116 LOC; Rules 12-15: T+2.5 / Room ngoại / Sàn-tier / FX VND-USD) + invariants-amendment-VN.md (108 LOC; I-S55-I-S65 = 11 NEW VN-specific invariants) + personal-risk-profile.md (110 LOC; 33 USER FILL placeholders across 7 sections per Day 1 § B.5). 9 proposals net post-S26 (master-plan said 8 via fold; documented as drift item).
**Status**: ACCEPTED-as-PROPOSAL via IMPL-tier (autonomous_mode=true). PENDING user explicit-approve to move proposals → constitution/. S27-S29 reference existing constitution Rules 1-10 + I-S1-I-S54 only.

### 2026-04-30 — D-009 — VHM as Phase 1 thin-slice exemplar
**Source**: PROJECT_CHARTER.md § First Sub-Scope + master-plan 004 § Thin-Slice Definition + S25 Q-S25-1 SCOPE-tier user-gate.
**Picks**: A (VHM Recommended) chosen over B (VIC; conglomerate complexity) and C (VPB; needs banking BC-2 maturity). User explicit-pick via AskUserQuestion 1Q.
**Impact**: locks S25-S30 thin-slice scope to VHM exemplar; ~250 daily Bars at S28; 1 exemplar thesis at S30; spec 000 frontmatter exemplar_stock=VHM.
**Status**: ACCEPTED via SCOPE-tier user-gate.

### 2026-04-29 — D-006 — Track 8a Confidence Score System (bash+TSV substrate per IMPL-S17-1)
**Source**: D-002 § Track 8 + REV-2 § A + Q&A A4/A5/A6 + L-S11-1 + Charter Principle 8.
**Picks**: IMPL-tier self-decide; Option B (bash+TSV) over SQLite+python and defer.
**Impact**: 5 categories scoring + asymmetric weights + 4 thresholds + reversal protocol + must_grill counter; sync-tracker layer + 2 hooks + sync-pull skill. Phase 1+ migration to SQLite when Track 8b lands python+sqlite3.
**Status**: ACCEPTED via IMPL-tier; SHIPPED S17 with smoke test PASS.

### 2026-04-29 — S16 — Track 7 IMPL — Constitution Port Ratification (D-003 REV-4 + D-005 REV-1)
**Source**: S15 PLAN file 003-... § 2 + § 4 + 9 closed queued-grill items + 10 L-S* lessons.
**Deliverables**: D-003+D-005 amendments; bash-hook-lint.sh + 3 hook wire-ins; 6 proposals + 1 pre-existing = 7 batch; try-n-approaches/SKILL.md +21; write-a-skill/references/best-practices.md NEW; harness_bootstrap_permission_override.md +L-S14-3.
**Status**: SHIPPED. 9 proposals pending user explicit approve post-S26.

---

## Active TODOs (top 10)

> Phase 0/1/2 DONE. Phase 2.5 RITUAL-CLOSED-S49a + EMPIRICAL-DEFERRED-Phase-3.5. Phase 3 Tracks G+H DONE; Track I+J+K PAUSED awaiting Phase 3.5 close. **Phase 3.5 IN PROGRESS PARTIAL-S79**.

### Phase 3.5 — Harness Deepening (PARTIAL-S173)
- [x] **T1 (S51)** — Phase 2.5 post-mortem: post-mortems/2026-05-05-phase-2.5-empirical-firing-gap.md SHIPPED
- [x] **T2 (S52)** — Stop→UserPromptSubmit migration: settings.json UserPromptSubmit chain
- [x] **T3 (S53)** — Promote-rule cycle backlog dispatch: observations/promote-rule-S52.md
- [x] **T4 (S54)** — Charter promote L-S49b-4 + 3 checkpoint hooks (checkpoint-write-marker + checkpoint-write-end-turn-watchdog + checkpoint-marker-cleanup-resume)
- [x] **T5 (S173)** — Harness Health Protocol authored at `agent-workspace/proposals/harness-health-protocol.md` v1.0; D-033 ratified Q1=A; mv→constitution PENDING M-S173-1 deny-lift workaround
- [x] **T6 (S173)** — `scripts/hooks/harness-health-self-scan.sh` SHIPPED + firing-test 7/7 PASS + production smoke RED-2; D-035; .claude/settings.json wired
- [x] **T7 (S73→S79)** — Phase 2.5 retro-fix firing-tests: 4 HH-* hooks + 11 charter-coverage backlog hooks; 63/63 PASS at S79; L-S49b-4 backlog DRAINED
- [ ] **T8 PROPOSED-cool-down ≥S180** — Charter v1.0→v1.1 Principle 11 PROPOSAL written agent-workspace/proposals/charter-revision-v1.1-harness-self-verify-firing.md; D-034; cool-down 2026-05-09; charter file edit deferred

### Phase 2.5 residue (HH-G portability — DONE-S174 per Q4=A)
- [x] **HH-G.1 (S174)** — `templates/general-harness/CLAUDE.md` SHIPPED ~207 LOC / ~2.7K tokens portable
- [x] **HH-G.3 (S174)** — `scripts/hooks/attach-portability-smoke.sh` SHIPPED + companion firing-test 7/7 PASS + production smoke 21/21 PASS state=GREEN
- [x] **HH-G.4 (S174)** — `.claude/skills/attach/references/procedures.md` extended +60 LOC portability checklist

### S171 prevention hooks (M-S171-1 prevention rule 3; DONE-S175 per D-037)
- [x] **prevention-hook-1 (S175)** — `scripts/hooks/idle-escape-detector.sh` SHIPPED ~170 LOC + companion firing-test 15/15 PASS + production smoke GREEN; emits system-reminder on ≥3 consecutive ROUTINE-IDLE / META-CADENCE blocks
- [x] **prevention-hook-2 (S175)** — `scripts/hooks/phase-status-coherence.sh` SHIPPED ~200 LOC + companion firing-test 16/16 PASS + production smoke GREEN; per-prompt cadence enhancement of HH-12 + HH-C.2 (Stop-only project-md-staleness-check that missed S148-S171 silent advance)

### S173 production-smoke remediation (HH-6+HH-10 DONE-S181 per D-041; HH-2 VERIFY-DONE-S182 = test-context artifact)
- [x] **HH-6 dispatch-pending JSONL cleanup (S181 ACCEPTED-AND-SHIPPED via D-041)** — 26 sidecar files deleted (gitignored; per dispatch-jsonl-recorder per-session contract, all from dead sessions); pre-deletion `.backfill-backup-20260507101244` written (59635B); dispatch-jsonl-backfill.sh recovered 18 of 186 candidates (10% rate; agent_type unknown→real via sidecar cross-ref); HH-6 stale=0 (was 6) ✓
- [x] **HH-10 firing-test orphans (S181 ACCEPTED-AND-SHIPPED via D-041)** — 6 NEW companion firing-tests REAL-STATE-DERIVED per L-S176-1, sandboxed per L-S174-1 RC-pattern: diagnostic-pretooluse-stash 4TC + diagnostic-subagentstop-stash 4TC + redact-secrets 10TC + same-commit-rule 6TC + subagent-budget-classifier 6TC + dispatch-jsonl-backfill 5TC = 35 NEW TCs total; full firing-test suite 75→81 PASS zero regression elapsed 231s; HH-10 orphans=0 (was 6) ✓
- [x] **HH-2 USERPROMPT-NOT-FIRING verify (S182 FOCUSED_AUDIT-DONE)** — VERDICT: TEST-CONTEXT ARTIFACT confirmed. Empirical proof 4-fold: (1) ALL 9 prior HH-2 emissions correlate 1:1 with synthesized SIDs (`firing-test-smoke-*` or `unknown`); (2) real-session UserPromptSubmit fires correctly (10:32:19 in `.session-hooks.log`); (3) manual run with realistic env at 10:34:45 → state=GREEN, HH-2 NOT in failure log; (4) detection logic at `harness-health-self-scan.sh:69-79` is sound — false-positive only when invoked outside production hook chain. Observation file `agent-workspace/memory/observations/2026-05-07-S182-HH-2-verify.md`. Recommended remediation deferred S183+ (Option A: skip HH-2 when SID matches synthesized pattern — preferred) OR (Option E: status quo — acceptable since real-prod=GREEN).

### S182 secondary anomaly → S183 ROOT CAUSE IDENTIFIED + S184 PRIORITY 1 fix queued
- [x] **S183 INVESTIGATION-DONE — harness-health-self-scan non-emission ROOT CAUSE**: Continue-injector spawn at `scripts/hooks/session-start-bootstrap.sh:178-181` (powershell.exe Start-Process via `& disown` for MINGW*|MSYS*|CYGWIN*) truncates Claude Code SessionStart hook chain on Windows after session-start-bootstrap completes, preventing remaining 13 chain hooks (vendor-api-probe through harness-health-self-scan) from firing. 60/60 source=clear+autonomous=true SessionStart events on 2026-05-07 fail to emit harness-health-self-scan; 1/1 source=empty event (no spawn) emits all 17 chain hooks. Pure-bash manual chain run = 5.7s ⇒ NOT chain timeout. Production-fire rate = 0.47% vs intended ~100%. Counter-factual: had Option A been in place since S173, ~60+ state summaries would have emitted by S183 vs actual 1. Severity HIGH; D-035 12-signal continuous self-scan effectively never runs in production. Observation `2026-05-07-S183-harness-health-non-emission.md`.
- [x] **S184 PRIORITY 1 ACCEPTED-AND-SHIPPED via D-042** — Option A fix: extracted continue-injector spawn from `session-start-bootstrap.sh:127-201` into NEW hook `continue-injector-spawn.sh` (+105 LOC) preserving SOURCE parse + autonomous_mode gate + override env + platform branches verbatim; bootstrap.sh -68 LOC; reordered `.claude/settings.json` SessionStart chain so spawn is 18th and LAST hook (after harness-health-self-scan); companion firing-test `continue-injector-spawn-fire-test.sh` +210 LOC / 9 TCs (source-gating × autonomous-gate × override-env × skip-paths × missing-exec-file × empty-payload) 9/9 PASS individually; full firing-test suite 82/82 PASS elapsed 223s (was 81; +1 NEW; zero regression); bootstrap smoke-test confirms additionalContext + .session-ready still emit cleanly with NO spawn; standalone spawn-hook smoke-test confirms FIRED log emits correct FIRE_REASON. Production verification (real-session harness-health-self-scan emission post-fix) DEFERRED — observable at next real `/clear` event in `.session-hooks.log`.
- [x] **S185 FOCUSED_AUDIT-DONE — UserPromptSubmit chain truncation HYPOTHESIS IDENTIFIED** — 5-fold empirical evidence catalog confirms: hook #1 SKIP path (no stdout) chain stops at #1 (128/157=81.5%); hook #1 INJECTED path (stdout JSON) chain reaches #2 reliably (29/157=18.5%); hook #2 emits stdout JSON conditionally only on stale-detected predicting chain stop at #2 when clean; manual chain run all 9 hooks rc=0 ~3s wall time confirms NOT bash issue. **Hypothesis: stdout JSON output enables Windows chain continuation; hooks without stdout cause truncation** (same Claude-Code-Windows class as S183 SessionStart spawn truncation; verified hypothesis pending S186 IMPL test). Observation `2026-05-07-S185-userprompt-chain-truncation-rc.md`.
- [x] **S186 IMPL-DONE — Option D empirical-test fix SHIPPED via D-043** (FOCUSED_IMPL ~30-40K main): modified `userprompt-invariants-injector.sh` trivial-path SKIP block (+5 LOC inserting `node -e "process.stdout.write(JSON.stringify({hookSpecificOutput:{hookEventName:'UserPromptSubmit',additionalContext:''}}))" 2>/dev/null || true` before exit 0); companion firing-test +130 LOC (TC1-TC3 assertion rewrite from field-absence to JSON-shape-with-empty-value via file-based parse + TC7 NEW S186 chain-continuation contract; assert_skip_path_json helper). Verification 4-fold: smoke-test JSON shape exact + SKIP-log entry preserved + individual firing-test 7/7 PASS + full firing-test suite 82/82 PASS elapsed 223-224s zero regression vs S184 baseline.
- [x] **S187 VERIFICATION-PARTIAL-CONFIRMED — D-043 production observation 1st trial** (within same agent turn as S186; ~5-10K verification append): User submitted trivial "continue" prompt at 11:50:22 — empirical cross-log inspection confirmed chain advance restored. Hooks #4 (in-flight-subagent-watcher) + #5 (hook-firing-counter) BOTH emitted at 11:50:21 (was 0/154 pre-fix; now 1/1 post-fix). Hooks #6-#9 still NO emission — chain truncation moved from #1/#2 to NEW #5/#6 boundary. Original S185 single-rule hypothesis "stdout JSON required at every hook" REJECTED-AS-INCOMPLETE (hook #5 has no stdout JSON yet chain advanced through it). Verification protocol refinement: original target `stale-prompt-detector: clean` line was INCORRECT (that hook silent-exits on trivial prompts); correct verification target = hook #4/#5 standalone .log files. D-043 status updated DEFERRED → PARTIAL-CONFIRMED in ADR.
- [ ] **S188 PRIORITY 1 — Root cause discrimination at NEW #5/#6 boundary** (FOCUSED_AUDIT ~30-50K main): test 3 candidate hypotheses: H-a (stderr-write triggers truncation; hook #5 emits to >&2 stderr conditionally) / H-b (execution time exceeds chain executor soft-timeout; hook #5 does ~71 grep × 1.3MB = ~700-3500ms) / H-c (segment-boundary stdout-JSON re-emission required). Discrimination: (a) reproduce S187 chain-advance in 1-2 additional trivial-prompt events; (b) test H-a (cheapest) by suppressing stderr at hook #5; (c) if H-a fails test H-b by timing hook #5 standalone; (d) if H-b fails test H-c by adding stdout JSON emission at hook #5. Document outcome as D-044 + observation file `2026-05-XX-S188-userprompt-chain-stop-discrimination.md`.
- [ ] **S188 PRIORITY 2 (after #5/#6 boundary fixed)** — Modify remaining 4 hooks (#6-#9) per discriminated mechanism. Targets: effort-escalation-detector / idle-escape-detector / phase-status-coherence / harness-health-self-scan. ~50 LOC × 4 = ~200 LOC + 4 firing-test updates. MULTI-TASK IMPL ~80-150K main. Counter-factual recovery post-fix: hooks #6-#9 UserPromptSubmit emission rate 0% → ~100% per turn.
- [ ] **S188+ PRIORITY 3 (L-S80-2 retro-fit)** — 4 production hooks violate `VAR=$(grep -c ... || echo N)` capture trap pattern surfaced via bash-hook-lint S185 smoke: attach-portability-smoke.sh + harness-health-self-scan.sh + idle-escape-detector.sh + phase-status-coherence.sh. Fix: replace with `if grep -qE ...; then VAR=1; else VAR=0; fi` clean integer pattern. ~10 LOC × 4 = ~40 LOC FOCUSED_IMPL.

### HH-C.2 staleness watchdog misfire fix (D-038 ACCEPTED-AND-SHIPPED-S177 Option E)
- [x] **D-038 IMPL (S177)** — `git mv` hook + firing-test (NNN-*.md naming) DONE; Check A dropped; Check B glob fixed `[0-9][0-9][0-9]-*.md` + `D-*.md` backward-compat; companion firing-test 7 TCs / 18 assertions / 18/18 PASS; full-suite regression 75/75 PASS; production smoke GREEN delta_hours=0.0 newest_adr=038-S176-...md; .claude/settings.json + CLAUDE.md line 57 updated
- [x] **L-S176-1 retro-fit scope (S178)** — file-pattern-hook compliance audit DONE; observation `2026-05-07-S178-file-pattern-hook-compliance-audit.md`; **5 bugs CONFIRMED** same recurrence-class as M-S176-1 (1 HIGH + 4 MEDIUM); 2 already-doc LOW graceful fallback; HH-10 orphan refined 4→6; D-039 batch-fix PROPOSAL + `file-pattern-hook-pre-flight-lint.sh` promote-rule candidate spec queued for S179 IMPL

### S178 audit findings — D-039 batch-fix DONE-S179 + lint hook queued (S180 PRIORITY 1)
- [x] **D-039 IMPL (S179)** — batch-fix DONE-S179 ACCEPTED-AND-SHIPPED: (1 HIGH) sync-tracker-auto-update.sh:61 dual-glob `\( NNN-*.md -o D-*.md \)` shipped (mirrors D-038 Option E); (2 MEDIUM) bootstrap-summary-renderer.sh:44 flexible NEXT ACTION awk shipped; (3 MEDIUM) bootstrap-summary-renderer.sh:56 table-row digest grep `^\| M-S[0-9]+` shipped; (4 MEDIUM) tracking-retention.sh:163-175 AN_LESSONS supplementary check RETIRED (false-premise; LOC cap is primary); (5 MEDIUM) tracking-retention.sh:183-194 ML_MISTAKES supplementary check RETIRED (same); 3 companion firing-tests REWRITTEN REAL-STATE-DERIVED 31/31 PASS (sync=8/8 + bootstrap=11/11 + tracking=12/12); full firing-test suite regression 74/74 PASS zero regression; 3 production smokes EMPIRICALLY VALIDATED.
- [x] **`file-pattern-hook-pre-flight-lint.sh` (S180 ACCEPTED-AND-SHIPPED via D-040)** — Stop hook ~190 LOC; detects 2 high-signal pattern types (Pattern A find-name glob + Pattern B markdown-anchor regex `*#|>`); empirical eval against resolved path/file via 9-name variable resolution table; `# pattern-lint-skip:` override on same line OR within preceding 5 lines; companion firing-test 12 TCs REAL-STATE-DERIVED per L-S176-1; production smoke v3 0 violations / 80 hooks; .claude/settings.json wired Stop chain after bash-hook-lint.sh. Detector regex bug surfaced + fixed within firing-test loop (TC4 D-039 Bug #1 REPRO caught `find[[:space:]]+\$` missing `find "$VAR"` form); 1 true positive resolved via skip-comment on dual-glob backward-compat (sync-tracker:63). Plus harness budget gap closed: bootstrap-summary-renderer.sh per-line truncation knob (MAX_HEADER_LEN=250 / MAX_MISTAKE_LEN=250) — boot-summary 10343B → 2437B (saved 7906B / 76%); Tier-1 routine load 25226B → 17320B under 20480 ceiling 15% headroom. Companion firing-test 13/13 PASS; full firing-test suite 75/75 PASS zero regression elapsed 214s.

### M-S173-1 resolution (out-of-band)
- [ ] **Deny-lift workaround**: user manual mv proposal→constitution OR settings.json amendment OR future deny-lift-prompt session

### Phase 3 (PAUSED awaiting Phase 3.5 close)
- [ ] **Track I** — Bayesian calibration (008-S45 sub-plan; PAUSED at S49)
- [ ] **Track J+K** — BC-7 sentiment+pump IMPL (009-S51 sub-plan PAUSED awaiting Phase 3.5 close)
- [ ] **Track L** — outer-loop (Phase 4 territory per master-plan 007)

---

## Known Issues

(None yet)

---

## Current Invariants (reference)

See `agent-workspace/constitution/invariants.md` for full list.

Highest-priority stock-specific:
- **I-S1**: NO LLM math — every number from code
- **I-S2**: Point-in-time integrity for backtest
- **I-S3**: Survivorship-aware universe construction
- **I-S10**: Thesis must include bear case
- **I-S20**: KOL recommendations tracked to outcome
- **I-S35**: All output framed as research aid, not advice

---

## Key References

- **Charter**: `PROJECT_CHARTER.md`
- **Manual**: `AGENT_OPERATING_MANUAL.md`
- **Spec template**: `SPEC_TEMPLATE.md`
- **Strategic spec**: `specs/tier1-strategic/001-four-tier-signal-architecture.md`
- **Feature specs**: `specs/tier2-feature/001-005-*.md`
- **Routing**: `agent-workspace/memory/current-execution.md`
- **Learned rules**: `agent-workspace/memory/agent-notes.md`
- **Thesis log**: `agent-workspace/memory/thesis-log/`
- **Calibration data**: `agent-workspace/calibration/`

---

## Environment Info

(Fill in after setup)

- **OS**: 
- **Python version**: 
- **Claude Code version**: 
- **Local infra**: docker-compose with Postgres 16 + TimescaleDB + Redis
- **Obsidian**: installed/not installed

---

## Notes for Agent

- When starting a new session, read this file first
- Update this file when: phase changes, architectural decisions made, known issues surface
- Don't embed state that goes stale — link to session logs and current-execution.md instead
- Keep under 2K tokens total — reference other files for detail
- For stock-specific calibration data, link to `agent-workspace/calibration/` files, don't dump here
