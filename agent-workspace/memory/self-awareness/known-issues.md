---
created_at: 2026-04-29 (S19 — Track 9 Phase 0 reduced)
purpose: Append-only failure catalog for self-awareness layer.
schema_source: agent-workspace/memory/self-awareness/jsonl-schema.md § Failure mode codes
related: agent-workspace/memory/mistake-log.md (Track 7 deliverable)
---

# Known Issues

> **Append-only.** New entries land at the bottom with full ISO-8601 timestamp.
> Each entry has: id / detected_at / model × effort / failure_mode_code / symptom /
> root_cause / mitigation / status / refs.

> **Phase 0 status**: 3 SEED entries below populated from existing patterns/sessions
> evidence. Phase 1+ aggregator + telemetry-analyst append from live telemetry.

---

## KI-001 — Self-track token inflation > real-transcript by 1.3-1.5×

- **detected_at**: 2026-04-29 (S2-S18 cumulative; pattern from `agent-workspace/memory/patterns-discovered/SYNTHESIS.md` § Risk R1)
- **model × effort**: claude-opus-4-7 × medium-high
- **failure_mode_code**: T (token-budget-overrun) when self-track triggers premature wind-down despite real-transcript headroom
- **symptom**: Agent reports near-budget-cap based on self-tracked tokens; `.transcript-tokens` shows 1.3-1.5× lower actual usage
- **root_cause**: LLM self-tracking includes verbose tool-result repetition + system reminders that don't accrue identically to real transcript
- **mitigation**: `scripts/hooks/budget-watchdog.sh` watches `.transcript-tokens` (real), NOT self-track; alerts at 1.5× inflation ratio per Risk R1
- **status**: MITIGATED (deterministic substrate; Track 5 ship)
- **refs**: D-002 REV-2 § C R1; CLAUDE.md § Hard Rules ("Context-threshold band per D-004 — Opus 4.7 recalibrated")

---

## KI-002 — Continuous LLM Guardian cost prohibitive

- **detected_at**: 2026-04-29 (UP02 §1.4 user observation)
- **model × effort**: any × any (architectural concern, not specific to single profile)
- **failure_mode_code**: H (harness-misuse) if Phase 1+ accidentally re-introduces continuous LLM aggregator
- **symptom**: Per-event LLM dispatch (anomaly detection on every hook fire) projected ~50K tokens/hour idle
- **root_cause**: Naive Guardian design assumed LLM-on-every-event; cost scales with hook frequency, not signal density
- **mitigation**: REV-2 § B Track 9 REFINE — deterministic-hooks Guardian (bash+awk) + LLM aggregator session-end ONLY
- **status**: MITIGATED via D-008 (Phase 0 ships deterministic aggregator only)
- **refs**: D-002 REV-2 § B Track 9 row "REFINE Self-Awareness Agent..."; D-008 § Decision

---

## KI-003 — Cross-language regex porting silently drops target-locale phrases

- **detected_at**: 2026-04-29 (S18 close — L-S18-1)
- **model × effort**: claude-opus-4-7 × medium (S18 IMPL session)
- **failure_mode_code**: A (assumption-without-verification) — assuming source-repo regex tier covers target locale
- **symptom**: extract-l0.ts FAILURE_PATTERNS = RU+EN; verbatim port to Python would miss VN failure phrases stockforge cares about
- **root_cause**: Source-repo authorship locale (Son Nguyen / Andrey Bursukov RU+EN) differs from stockforge identity (VN-primary per Charter)
- **mitigation**: Cross-locale port checklist applied — 5 VN phrases extended in `packages/observability/extract_l0.py` FAILURE_PATTERNS; tests cover each
- **status**: PROMOTION-PENDING (L-S18-1 → `proposals/architecture-amendment.md` § "When porting from source repos")
- **refs**: D-007 § Decision; agent-workspace/memory/sessions/2026-04-29-session-18.md § L-S18-1

---

---

## KI-S35-1 — VBW protocol skipped on telemetry/handoff scripts → confabulated "missing files" drift report

- **detected_at**: 2026-05-01T00:00:00Z (S34-extension drift report turn)
- **model × effort**: claude-opus-4-7 × max
- **failure_mode_code**: A (assumption-without-verification)
- **symptom**: Drift report claimed `.transcript-tokens` + `component-telemetry.jsonl` + `dispatch.jsonl` + `session-self-reboot.sh` "missing"; all 4 EXIST at canonical paths verified post-claim. HIGH/CRITICAL recommendations issued on confabulated absence.
- **root_cause**: Searched wrong directory (script names vs file names; `agent-workspace/memory/` vs `scripts/`); accepted drift-detector subagent verdict (DR1-DR12 only) without cross-verifying its scope; no Read of source script before assertion.
- **mitigation**: Pre-flight checklist: every "X is missing" claim MUST be preceded by `Read $exact_path` OR `Glob`/`Bash ls -la $expected_dir`. Drift report template adds `verified_at` + `read_method` per claim.
- **status**: OPEN (rule not yet codified — promotion candidate per S35 D4)
- **refs**: M-S35-1, M-S35-2 in mistake-log.md; post-mortem `2026-05-01-self-awareness-promotion-skip.md` § cognitive failures 1+2

## KI-S35-2 — Self-track token inflation past 250K hard_cap with no auto-handoff

- **detected_at**: 2026-05-01 (S34-extension)
- **model × effort**: claude-opus-4-7 × max × MULTI_TASK_IMPL extension
- **failure_mode_code**: T (token-budget-overrun)
- **symptom**: Self-track ~280K vs declared hard_cap 250K (CLAUDE.md mandatory split). `.cliff-fired` already present from earlier in session blocked re-fire; budget-watchdog Stop-mode-C guard never triggered because real-transcript ≤ wind_down threshold (self-track > real-transcript per KI-001 inflation 1.3-1.5×).
- **root_cause**: Plan-fidelity bias — em finished BC-2 Track C deliverables despite token pressure; no split-trigger fired because `.cliff-fired` already-set short-circuited cliff handoff; stale-marker auto-clear not yet implemented (S35 D7 fix).
- **mitigation**: S35 D7 added stale-marker auto-clear (>1h old + new session_id → clear) to `scripts/hooks/budget-watchdog.sh`. Charter check: when self-track > 250K AND `.cliff-fired` exists older than current session, force write-checkpoint + /clear.
- **status**: MITIGATED (D7 fix shipped this session)
- **refs**: M-S35-3; checkpoint `latest.md` "**self-track ~280K — VƯỢT hard_cap 250K**"; KI-001

## KI-S35-3 — Cross-BC direct import not caught by mypy/ruff/Clean-Architecture-layers contract

- **detected_at**: 2026-04-30 (S34 mid-session refactor)
- **model × effort**: claude-opus-4-7 × max × MULTI_TASK_IMPL
- **failure_mode_code**: B (boundary-violation)
- **symptom**: `peer_service.py` originally imported `VN30_UNIVERSE` from `packages.domain.market_data.value_objects` — Charter cross-BC discipline violation. mypy --strict 0 errors; ruff 0 errors; Clean-Architecture-layers contract pass; only `agent-workspace/CLAUDE.md` cross-BC rule + manual review caught it mid-session.
- **root_cause**: Existing import-linter contracts cover (a) layer ordering interfaces→application→domain→infrastructure (b) framework-forbidden in domain. Neither enforces BC-to-BC independence inside domain layer. `disallow_any_explicit` mypy rule + ruff TID lints have nothing about cross-BC.
- **mitigation**: S35 D6 added new `[[tool.importlinter.contracts]]` of `type = "independence"` covering 9 BCs (market_data + fundamental + news + crowd + influence + macro + portfolio + company_intelligence + analysis). Verified via grimp graph: 0 production violations; 1 test-only violation grandfathered via `ignore_imports`.
- **status**: MITIGATED (D6 shipped this session)
- **refs**: M-S34-1; L-S34-1 in agent-notes; current-execution.md § S34 close note

## KI-S35-4 — Vendor-API surface drift between PLAN and IMPL within same day

- **detected_at**: 2026-04-30 (S28 — TCBS 404; S32 — vnstock 4.0.2 Quote VCI-only)
- **model × effort**: claude-opus-4-7 × max × FOCUSED_IMPL/MULTI_TASK_IMPL
- **failure_mode_code**: A (assumption-without-verification on external dependencies)
- **symptom**: PLAN (S26) sourced TCBS public REST as primary alternate-source; IMPL (S28, ~6h later) hit 404 across all endpoints. Master-plan 005 (S31) recommended A2 "vnstock alternate-source"; S32 empirical probe rejected A2 (vnstock 4.0.2 deprecated TCBS/DNSE/SSI/FMARKET as Quote sources, MSN ConnectionError) → pivoted A3 SSI iBoard direct.
- **root_cause**: PLAN-time validation = doc/source-evidence reads only. Vendor public APIs change without version bumps. No probe-before-commit doctrine for vendor strategy.
- **mitigation**: L-S28-1 (initial) + L-S32-1 ("Empirical probe before strategy commit") both batched in agent-notes. Promotion candidate per S35 D4: extend `crawler-reliability` skill with vendor-probe checklist; add deterministic hook at PLAN ratification → vendor URL liveness probe sample.
- **status**: PROMOTION-PENDING (L-S28-1 + L-S32-1 lessons not yet codified beyond agent-notes)
- **refs**: M-S28-1; D-012 (Track A R2 closure); L-S28-1, L-S32-1

## KI-S35-5 — Plan-fidelity > meta-loop-fidelity → 4 dead continuous loops

- **detected_at**: 2026-05-01 (S34-extension user audit)
- **model × effort**: claude-opus-4-7 × max × ANY (architectural concern across 15 sessions)
- **failure_mode_code**: H (harness-misuse) + D (deferral)
- **symptom**: 15 sessions S20-S34 — 0 mistake-log entries, 0 KI/BP cards added beyond Phase 0 seeds, 0 promotion-cycle runs, 0 DR-INTENT scans. Master-plan deliverables shipped clean; meta-loops invisible because not in deliverable matrix.
- **root_cause**: 4-layer (a) CLAUDE.md § Session End checklist missing meta-loop steps; (b) "promote at phase boundary" doctrine without N-cap means "never"; (c) Track 9 spec ≠ Session-End ritual gap; (d) one-shot-vs-continuous confusion (Track 9 built S19, treated as "shipped").
- **mitigation**: S35 D1+D2+D3+D4+D5 backfill + ritual codification. Charter amendment proposal in `proposals/drift-signals-amendment-DR-INTENT.md`; CLAUDE.md § Session End extension proposed via D4 promote-rule routing.
- **status**: MITIGATED (this session backfills); RECURRENCE-RISK if ritual not codified into hook by S36
- **refs**: M-S35-4; post-mortem 2026-05-01; all 4 dead-loop artifacts in checkpoint `latest.md`

## KI-S43b-1 — Bull sonnet prompt pairing reproduces 300s subprocess timeout

- **detected_at**: 2026-05-01 (S43b-FRESH run 4 — 2/2 dogfood reproductions)
- **model × effort**: claude-sonnet-4-6 × default × BULL system prompt + SharedContext
- **failure_mode_code**: T (timeout / external dependency)
- **symptom**: claude CLI subprocess hits 300s `_DEFAULT_TIMEOUT_SEC` exclusively for BULL role; bear (sonnet) + quant (opus) both complete <60s on same SharedContext; SubagentSubstrateError raised; partial cost charged.
- **root_cause**: BULL prompt + advocacy stance + Vietnamese-market-aware constraints + verbatim-source-cite rule combine into a slow generation pattern on sonnet specifically. Empirical only — Anthropic doesn't publish role-prompt latency profiles.
- **mitigation**: Per-role model override pattern. `ClaudeLLMPerspectiveAdapter.role_model_overrides: dict[PerspectiveRole, str]` field + 4-tier resolution `model_override → role_model_overrides[role] → _ROLE_TO_MODEL[role] → _DEFAULT_MODEL`. `apps/_shared/use_case_builder.py` sets `BULL → claude-haiku-4-5`. Haiku faster + cheaper + sufficient for evidence-gathering bull task.
- **status**: MITIGATED (S43b-BULL turn 2026-05-01)
- **refs**: checkpoint S43b-BULL; `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` `role_model_overrides` docstring; `packages/infrastructure/analysis/test_adapter.py` 8 tests

---

## KI-S43b-2 — LLM JSON wrapped in prose preamble breaks naive `json.loads`

- **detected_at**: 2026-05-01 (S43b-FRESH bear run failures pre-`_unwrap_fence` extension)
- **model × effort**: claude-sonnet-4-6 × default × structured-output JSON contract
- **failure_mode_code**: P (parse-failure on LLM output)
- **symptom**: Adapter received text like `Here are 4 bear points...\n\`\`\`json\n{...}\n\`\`\`\nNote: ...`; `json.loads` failed on whole-text; bear key_points dropped to 0; bear-retry burned cost.
- **root_cause**: LLM despite "Output JSON matching schema" instruction often emits prose-preamble + fenced JSON + prose-postamble. `_unwrap_fence` initially handled only whole-text-fenced case.
- **mitigation**: 3-tier extractor in `subagent_transport._unwrap_fence`: (1) regex `_INNER_FENCE_RE` finds last fenced block; (2) `_extract_first_json_object` brace-depth scan with string-aware skipping; (3) raw text fallback (downstream parse will fail with diagnostic).
- **status**: MITIGATED (S43b-FRESH this session)
- **refs**: `packages/infrastructure/analysis/subagent_transport.py:55-118`; checkpoint S43b-FRESH

---

## KI-S43b-3 — Windows cp1252 default encoding crashes claude CLI subprocess on UTF-8 bytes

- **detected_at**: 2026-05-01 (early S43b probe — `research/r-2026-05-01-claude-cli-substrate.md`)
- **model × effort**: any × any × Windows OS
- **failure_mode_code**: B (boundary / OS encoding)
- **symptom**: `subprocess.run(...)` with default `text=True` raised UnicodeDecodeError on Vietnamese characters in news excerpts.
- **root_cause**: Windows Python 3.x default codec for subprocess streams is cp1252; claude CLI emits UTF-8 (Vietnamese names, ratio audit comments, etc.).
- **mitigation**: `subprocess.run(..., encoding="utf-8", errors="replace")` pinned in `claude_cli_transport`. Documented as OS-level invariant for any Windows-host substrate.
- **status**: MITIGATED
- **refs**: `packages/infrastructure/analysis/subagent_transport.py:163-167`

---

## KI-S43b-4 — TA features absent from SharedContext breaks quant Rule-7 pathway

- **detected_at**: 2026-05-01 (S43b-FRESH + S43b-BULL — quant returned 0 grounded points 2 runs)
- **model × effort**: claude-opus-4-7 × default × QUANT system prompt
- **failure_mode_code**: D (data-substrate-absent triggering honest "insufficient" Rule-7)
- **symptom**: quant key_points = 0 across 2 dogfood runs; quant prompt says "Output structured: for each ratio in {P/E, P/B, ROE, D/E, MoS}..." but SharedContext only had ratios_ttm — no TA features (RSI/SMA/Bollinger). Quant honestly returned INSUFFICIENT_DATA per Rule 5.
- **root_cause**: Spec § A.10 mentioned ta_features but Phase1DataGatherer never populated them; ta_service.py existed (15 tests) but unwired.
- **mitigation**: S43b-EVIDENCE turn — `Phase1DataGatherer` imports `compute_ta_features`; populates `ctx.ta_features` + `ctx.ta_audit`; gap `ta_insufficient` when quotes absent. Adapter `_context_to_str` already had renderer for `[TA Features]` block (pre-existing).
- **status**: PARTIALLY MITIGATED (this turn 2026-05-01) — VALIDATION FINDING (HR-5): bear case improved 3→5 grounded points heavily citing TAFeatures (SMA_50/SMA_200/RSI_14/pct_off_52w_high/realized_vol_90d_annualized). Quant STILL 0 points: quant Rule 3 demands `sector_avg + 5yr_own_percentile` per ratio; both are "Phase 3" in gatherer code (`peer_comparables=[]; percentiles={}`); quant LLM correctly emits structured-empty rather than degraded GroundedPoint. Bull STILL 0 points (data-availability gap; zero positive 90d news in SharedContext).
- **next-action options for full quant unblock**: (a) accelerate Phase 3 peer_comparables + percentiles into Phase 2 (~80-150K + new BC service), (b) relax quant Rule 3 to allow ratio-only GroundedPoint without sector_avg (prompt amendment), (c) accept quant-empty as honest Phase-2 output (current behavior). Decision is SCOPE-tier; defer to user.
- **refs**: `packages/infrastructure/analysis/phase1_data_gatherer.py:209-219`; `packages/infrastructure/analysis/test_phase1_data_gatherer.py`; checkpoint S43b-BULL § DEFER-S43b-5; thesis-log/2026-05-01-FPT.md run 6 verified

---

## KI-S43b-5 — Self-upgrade loop Stage 2+3 dormant for 9+ sessions

- **detected_at**: 2026-05-01 (user audit S43b-EVIDENCE turn)
- **model × effort**: claude-opus-4-7 × max × ANY (architectural; cross-session)
- **failure_mode_code**: H (harness-misuse) + D (deferral)
- **symptom**: 9 sessions S35-S43b shipped feature work cleanly; 0 KI/BP entries appended; agent-notes.md last 2026-04-30; drift-logs/ stale 3 days; observations/ stagnant since Phase 0; promotion-cycle-trigger.sh never fires. Patterns re-discovered each session (e.g., bull sonnet timeout reproduced run 1, fixed run 2 → no record → next session would have re-discovered). User-memory dir bypass: 12+ entries written there that should have been agent-notes.md.
- **root_cause**: 3-stage loop: (1) Stop hook aggregator counting tokens ✅; (2) lesson-synthesis stage HAS NO AGENT — Track 9 spec listed "telemetry-analyst" but never built; (3) promotion-cycle-trigger.sh exists but never auto-invoked. Plan-fidelity bias (BP-S35-1 pattern recurrence) — feature work crowds out meta-loop.
- **mitigation**: This turn — manual lesson-synthesis (Task B-C) + investigate hooks (Task D-F). NOW DEPLOYED (HR-1): `scripts/hooks/lesson-synthesis-watchdog.sh` (Stop priority 12) — checks `git status --short packages/ apps/` for any production touch + cross-checks `find -mtime -1` on `known-issues.md` / `best-practices.md` / `agent-notes.md`; ALERTs if production touched + zero lesson updates in last 24h. Smoke-tested clean (no false-positive on this turn since 3 lesson files updated). LLM-based synthesis subagent still pending (Phase 3 candidate).
- **status**: MITIGATED — deterministic-watchdog deployed; will surface dormancy to next agent automatically
- **refs**: this turn's checkpoint `latest.md`; user feedback verbatim quoted in checkpoint; KI-S35-5 (precedent); BP-S35-1 (5-session promotion-cycle frequency); `scripts/hooks/lesson-synthesis-watchdog.sh`

---

## KI-S43b-6 — Auto-/clear without handoff loses Q&A and recovery state

- **detected_at**: 2026-05-01 (user reported prior-turn behavior)
- **model × effort**: claude-opus-4-7 × max
- **failure_mode_code**: H (harness-misuse — agent self-cleared)
- **symptom**: User reports: agent listed Q&A options, then "/clear" landed before user could answer → agent resumed in next turn with stale checkpoint or no handoff → next-turn answer wrong / confused. Same pattern after my long audit response — auto-clear with no checkpoint write.
- **root_cause**: No charter rule "checkpoint MUST be written before any /clear". /clear is user-invoked but agent's behavior of listing options + waiting + getting auto-cleared by user impatience or hook = state lost. Also: agent did not pre-emptively write checkpoint at end of turns where Q&A pending.
- **mitigation**: New invariant: at end of EVERY turn that has pending user-decision items (Q&A, recommendations awaiting pick), agent MUST write `checkpoints/latest.md` capturing the pending decision + verbatim options. NOW DEPLOYED (HR-2): `scripts/hooks/pre-clear-handoff-guard.sh` (Stop priority 1, before aggregator) — scans last 2h of session-logs + raw-sessions for pending-decision triggers (`AskUserQuestion`, lettered option menus `(a)`/`(b)`, `SCOPE-tier`, `wind_down`, `q-and-a/pending`); cross-checks `checkpoints/latest.md` mtime; ALERTs if pending+stale. Smoke-tested clean (pending=1, checkpoint_fresh=1 → no alert this turn). Hard-block via JSON deny-decision is Phase 3 candidate.
- **status**: MITIGATED — deterministic guard deployed; advisory-only currently
- **refs**: user verbatim "tương tự lúc tôi yêu cầu q&a, bạn list ra rồi tự clear luôn, nên tôi không thể trả lời. rõ ràng là lỗi hệ thống, fix toàn diện"; `scripts/hooks/pre-clear-handoff-guard.sh`

---

## How to add new entries (Phase 1+)

```
KI-NNN — <one-line symptom title>

- detected_at: <ISO-8601 UTC>
- model × effort: <model> × <effort>
- failure_mode_code: <A|B|C|D|H|P|T>
- symptom: <observable behavior>
- root_cause: <why it happened>
- mitigation: <what was/should be done>
- status: OPEN | MITIGATED | PROMOTION-PENDING | RESOLVED
- refs: <decisions/sessions/skills referenced>
```

Append below `KI-003` with sequential ID. Phase 1+ telemetry-analyst may auto-append from
`component-telemetry.jsonl` rows where failure_mode is non-null.


---

## KI-S43b-7 — Premature-stop after charter-tier recovery pivot

- **detected_at**: 2026-05-01 (3-turn premature-stop chain post-/clear)
- **model × effort**: claude-opus-4-7 × default × ANY
- **failure_mode_code**: H (harness-misuse; meta-loop dormancy)
- **symptom**: User pivoted "fix toàn diện" → agent executed Part 1 (6-task A-F) cleanly + checkpoint write + /clear → resume → over next 3 consecutive turns, agent stopped after each sub-task (resume-verify / HR-3 / HR-7) with tidy 1-2 sentence summary; user had to re-prompt 3× ("continue" / "sao lại dừng lại rồi?" / "vấn đề là harness, chưa fix hết"). HR-3/4/6/7 listed PENDING in current-execution.md throughout but agent treated immediate task-list completion as full recovery completion.
- **root_cause**: 4 structural factors:
  - RC-1: Conflated 6-task immediate list (A-F) with full HR-1..HR-7 recovery DoD
  - RC-2: Tidy-summary tendency reads as "done" signal even with PENDING items in state
  - RC-3: No explicit Definition-of-Done checklist for harness-recovery arc
  - RC-4: Memory rule `stop_offering_routing_branches` misread as "stop after each sub-task" instead of "don't enumerate (a)/(b)/(c)"
- **mitigation**:
  - L-S43b-10 lesson appended to agent-notes.md (rule: stop only when DoD all-terminal)
  - BP-S43b-7 documents harness-recovery DoD checklist convention (✅ DEPLOYED / 🔒 GATED-HUMAN / 🔭 PHASE-N-DEFERRED)
  - HR-8 NEW: `harness-recovery-dod-watchdog.sh` deterministic Stop hook (this turn)
- **status**: PARTIALLY MITIGATED — lesson recorded; watchdog deployed (HR-8 below); awaiting next charter-tier pivot to validate non-recurrence
- **refs**: user verbatim "vấn đề là harness, chưa fix hết hay sao mà lại dừng, tôi cần lí do, tracing, note, update, fix để không lặp lại"; agent-notes 2026-05-01 L-S43b-10; this turn's checkpoint

---

## KI-S43b-8 — Ghost-work pre-flight discovery: authored file untracked across session boundary

- **detected_at**: 2026-05-01 (S43b-EVIDENCE VBW pre-flight — `packages/domain/market_data/services/ta_service.py`)
- **model × effort**: claude-opus-4-7 × default × FOCUSED_IMPL
- **failure_mode_code**: A (assumption-without-verification — provenance of pre-flight discovery not audited)
- **symptom**: VBW pre-flight at S43b-EVIDENCE session start found `packages/domain/market_data/services/ta_service.py` (164 LOC, 15 tests) already authored but untracked in git. Session log says "was untracked — authored prior partial session". Agent used it immediately without: (a) verifying which prior session authored it, (b) checking whether tests were written to match current spec, (c) staging it with explicit provenance note. The file entered production silently via `git add` at an unspecified future point.
- **root_cause**: No protocol for "VBW discovers a complete authored file that has never been staged." The file was treated like discovered spec-aligned code rather than an archaeological artifact needing provenance verification. Prior partial session that authored the file left no session-log entry and no checkpoint reference to the file.
- **mitigation**: When VBW pre-flight discovers untracked authored files (non-test, non-config): (1) `git log --all --full-history -- <path>` to check if it was ever committed; (2) Read the file fully; (3) Run its tests standalone; (4) Document the archaeological find in the current session log under "GHOST-WORK FOUND" heading with path + LOC + test count + session-of-origin if determinable; (5) Stage only after (3) passes. Do NOT silently adopt ghost-work into current session scope without explicit archaeological note.
- **status**: OPEN — no deterministic hook enforces ghost-work audit; manual rule only
- **refs**: session `2026-05-01-session-43b-evidence-harness-recovery.md` § "Findings on entry" + § "Production TRACK"; `packages/domain/market_data/services/ta_service.py`; L-S43b-3 (wiring gap that ghost-work was meant to resolve)
