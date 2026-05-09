---
id: D-036-S174-HH-G-portability-close
title: HH-G portability close (general-harness CLAUDE.md template + /attach smoke runner + companion firing-test)
date: 2026-05-07
status: ACCEPTED-AND-SHIPPED
level: SCOPE
author:
  - "Claude Opus 4.7"
source_evidence:
  - path: agent-workspace/memory/checkpoints/latest.md
    quote: "Q4=A user-picked PRIORITY 1: HH-G portability close (FOCUSED_IMPL ~80-120K main)."
  - path: agent-workspace/memory/observations/2026-05-07-S172-phase-audit-reconciliation.md
    section: "§ HH-G — Portability validation: 1/4 DONE; 3 NOT-STARTED or PARTIAL"
  - path: agent-workspace/session-plans/pending/009-S48-harness-hardening-middle-phase.md
    section: "HH-G track (Phase 2.5 residue)"
  - path: .claude/skills/attach/SKILL.md
    section: "§ Layer-separation assertion smoke (S48l HH-G.3 codified)"
  - path: .claude/manifest.yaml
    section: "REV-3 (2026-05-05 S48b HH-A.5)"
intent_classification:
  primary_intent: SCOPE
  affects_charter: false
  affects_scope: true
  urgency: NORMAL
  complexity_score: 35
options_considered:
  - id: A
    summary: |
      Author standalone templates/general-harness/CLAUDE.md (HH-G.1) + scripts/hooks/attach-portability-smoke.sh runner (HH-G.3) + companion firing-test + extend procedures.md HH-G.4 checklist.
    pros:
      - "Closes Phase 2.5 HH-G residue with dedicated artifacts"
      - "Smoke runner is deterministic (Bash + Python; no Skill tool prompts per UP-05)"
      - "Companion firing-test exercises real RED state detection — Phase 3.5 Hard Rule #2 satisfied"
      - "Reusable: smoke runner can be re-invoked on every manifest change"
    cons:
      - "Template duplicates content already in .claude/skills/attach/references/skeleton-templates.md § CLAUDE.md"
      - "Mitigation: skeleton-templates.md is inline-in-skill (used by /attach), templates/ standalone is for /attach to PRODUCE — different consumers"
  - id: B
    summary: |
      Inline-only — leave the CLAUDE.md template as-is in skeleton-templates.md; just add HH-G.4 checklist + smoke runner.
    pros:
      - "Less duplication"
      - "Smaller artifact surface"
    cons:
      - "Phase 2.5 HH-G.1 explicitly requires templates/general-harness/CLAUDE.md as standalone (per S172 audit § HH-G.1: NOT-FOUND)"
      - "Doesn't satisfy the gap surfaced in audit"
  - id: C
    summary: Defer HH-G entirely to Phase 4+ portability-as-product
    pros:
      - "Focuses Phase 3.5 on harness self-verify (T1..T8)"
    cons:
      - "S173 Q4=A user explicitly picked HH-G PRIORITY 1 for S174"
      - "Leaves Phase 2.5 with NOT-STARTED items in tracker indefinitely"
chosen: A
chosen_rationale: |
  User selected A (Recommended) via S173 AskUserQuestion Q4=A "HH-G portability FIRST". This S174 turn is the
  ratified execution of that pick. Standalone template at templates/general-harness/CLAUDE.md serves a different
  consumer than the inline skeleton-templates.md content: the standalone is the artifact /attach copies + that
  ports authors author-once vs. the skeleton-templates.md heredoc which the /attach skill extracts at copy time.
  Smoke runner closes the empirical-firing gap (HH-G.3 NOT-STARTED at S172 audit) with deterministic
  manifest assertions + structural copy verification + dry-run plan counts. Companion firing-test exercises
  fixture-based detection of deliberate violations — proves the runner does what it claims.
approval_chain:
  - actor: agent
    action: PROPOSED + IMPLEMENTED
    at: 2026-05-07
    via: |
      templates/general-harness/CLAUDE.md (HH-G.1)
      + scripts/hooks/attach-portability-smoke.sh (HH-G.3 runner)
      + scripts/hooks/firing-tests/attach-portability-smoke-fire-test.sh (companion)
      + .claude/skills/attach/references/procedures.md § HH-G.4 checklist (S174 Edit)
  - actor: user
    action: ACCEPTED-IN-ADVANCE
    at: 2026-05-07
    via: AskUserQuestion S173 Q4=A "HH-G portability FIRST" (Recommended pick at S173 close; S174 = execution turn)
  - actor: agent
    action: SHIPPED
    at: 2026-05-07
    via: |
      Smoke runner production-firing: state=GREEN 21/21 PASS on real project
      Firing-test: 7/7 PASS (Test 1 GREEN smoke + Test 2 fixture-no-template detection + Test 3 fixture-leak A3 detection + Test 4 ATTACH_SMOKE_TARGET env override + Test 5 exit code semantics)
verified_by:
  - mechanism: production-firing-evidence
    at: 2026-05-07
    result: PASS
    detail: "Smoke runner ran against real project state — A1..A7 layer assertions GREEN + STRUCTURAL include/exclude checks GREEN + DRY-RUN plan counts GREEN. Total: 21/21 PASS state=GREEN."
  - mechanism: companion-firing-test
    at: 2026-05-07
    result: PASS
    detail: "7/7 PASS: real-project GREEN + fixture-no-template detection + fixture-leak A3 detection + ATTACH_SMOKE_TARGET env override + RC=0 GREEN + RC=1 RED. Phase 3.5 Hard Rule #2 satisfied."
  - mechanism: token-count-budget
    at: 2026-05-07
    result: PASS
    detail: "templates/general-harness/CLAUDE.md = 207 LOC / 10853 chars / ~2713 tokens (4-byte heuristic; tiktoken would yield ~2200-2400). Within <2.5K-3K target band."
affects:
  charter: false
  spec_files: []
  code_paths:
    - templates/general-harness/CLAUDE.md
    - scripts/hooks/attach-portability-smoke.sh
    - scripts/hooks/firing-tests/attach-portability-smoke-fire-test.sh
  config_files:
    - .claude/skills/attach/references/procedures.md
  other_decisions:
    - D-035 (T6 harness-health-self-scan — sister hook; same Phase 3.5 firing-test discipline)
    - D-027 (BC-6 Influence Network — Phase 3 work that resumes once Phase 3.5 closes)
depends_on:
  - "manifest.yaml REV-3 (2026-05-05 S48b HH-A.5) — layer tagging is source-of-truth for smoke assertions"
supersedes: null
superseded_by: null
defer_cycles: 0
re_attempt_prereq: |
  N/A — SHIPPED.
  Future amendments:
  - Adding new harness skill / hook → bump assertion thresholds in attach-portability-smoke.sh (A4 ≥17 → ≥18 etc.)
  - Adding new stockforge biz skill → bump A5 == 5 → == 6 etc.
  - Template content drift → re-run smoke; firing-test will catch any A1-B3 regression
tags: ["phase-2.5", "phase-3.5", "harness", "HH-G", "portability", "template", "smoke-runner", "firing-test-shipped", "production-firing-evidence"]
---

# Decision 036 — HH-G Portability Close

## Context

Phase 2.5 HH-G track shipped 1/4 deliverables (HH-G.2 invariants split DONE-S48l) and left 3 in NOT-STARTED or PARTIAL state per S172 FOCUSED_AUDIT:

| Sub-track | Status pre-S174 | Description |
|---|---|---|
| HH-G.1 | NOT-FOUND | `templates/general-harness/CLAUDE.md` template absent |
| HH-G.2 | DONE-S48l | `invariants-stockforge.md` split from `invariants.md` |
| HH-G.3 | UNCLEAR / NOT-VERIFIED | `/attach` smoke test never run against fresh dir |
| HH-G.4 | PARTIAL | Portability checklist partially in `procedures.md`; smoke-test-result section missing |

S173 AskUserQuestion bundle Q4 asked user to sequence S174's PRIORITY 1. User picked A (Recommended): HH-G portability close FIRST. This S174 turn executes that pick.

## Analysis

### HH-G.1 — Template authoring

The existing `.claude/skills/attach/references/skeleton-templates.md § CLAUDE.md` had a heredoc CLAUDE.md template embedded in skill reference content. That serves /attach's runtime copy mechanism (extract heredoc + write at target). But the Phase 2.5 plan + S172 audit explicitly required a STANDALONE `templates/general-harness/CLAUDE.md` artifact — to live next to other portable templates and be directly inspectable / copyable by ports without going through the skill machinery.

Authored 207 LOC / ~2713 tokens template stripped of:
- StockForge VN-stock invariants (NO LLM math, citations, position sizing, bear case, framing rules)
- Stockforge constitution table entries (`invariants.md` stock-specific, `financial-data-protocol.md`)
- Stockforge-specific session types (THESIS / INGEST kept descriptive note that projects add their own)
- Stockforge-specific anti-patterns (LLM generating numbers, single-perspective thesis, recommending owned stocks)
- DAY_1_CHECKLIST.md pointer (stockforge bootstrap)

Preserved (portable across projects):
- Karpathy 4 principles
- Sandwich pattern (Architect → Dev → Verifier) — distilled into a 3-row table
- Session Protocol (Start + End)
- Memory Tiering (Tier 1 / 2 / 3)
- Q&A Escalation Doctrine (NO Silent Default)
- Constitution table (10 portable harness files; explicit note "stockforge-specific in separate file")
- General Hard Rules (domain layer / cross-BC / VBW / no commit / user-prompt-overrides / context-thresholds / tracking retention / ritual demotion)
- Dispatch Rules + UP-05 skill-tool gating
- Session Types (PLAN / FOCUSED / MULTI-TASK / VERIFY / RECOVERY / POST-MORTEM only — drop THESIS/INGEST as project-specific)
- Quality Gates (Tier 1 / 2 / 3)
- Common Anti-Patterns (general subset only)
- Layer Manifest pointer
- Key References (general)
- "First Interaction" guidance (`/session-start`)
- Project-specific section placeholder (post-/attach population)

### HH-G.3 — Smoke runner design

Per UP-05 doctrine ("Skill calls only in SUPERVISED mode; gate autonomous loops to NOT call skills"), the smoke
runner does NOT invoke /attach. Instead it deterministically validates the same boundaries /attach would
enforce, via three checks:

**Check 1: MANIFEST layer-separation** — runs `python -c "..."` harness mirroring SKILL.md A1-A7 + 4 new
assertions HH-G.1 (template existence + token budget + freedom from stockforge identifiers + structural
content). Plus B1-B3 (default_excludes coverage; harness hooks count). Total 14 manifest-level assertions.

**Check 2: STRUCTURAL smoke** — emulates /attach's cp loop against `mktemp -d` target. Copies a
representative subset of include paths (13 files spanning skills + agents + commands + hooks + manifest +
constitution + HH-G.1 template). Verifies: (a) all 13 include paths land at target, (b) 7 stockforge
exclude paths absent at target, (c) HH-G.1 template content intact post-copy, (d) settings.json contains
STOCKFORGE_ env vars (sed-replace would happen at /attach time).

**Check 3: DRY-RUN plan counts** — parses manifest's attach.default_includes / default_excludes / hybrid.hooks.
Asserts include ≥50 (post-REV-3), exclude ≥20, hybrid ≥1 (drift-signals-D1-D9.sh).

Total: 21 assertions. Real-state run: 21/21 PASS state=GREEN.

### HH-G companion firing-test

Per Phase 3.5 Hard Rule #2 (and T7 retrofit precedent 63/63 PASS at S79), every new hook ships with companion
firing-test. Strategy:

| Test | Synthesis | Asserts |
|---|---|---|
| 1 | real project state | smoke emits state=GREEN |
| 2 | fixture missing HH-G.1 template | smoke detects [FAIL] HH-G.1 |
| 3 | fixture with manifest leak (invariants-stockforge.md in default_includes) | smoke detects [FAIL] A3 |
| 4 | ATTACH_SMOKE_TARGET=$custom env override | smoke uses custom target dir |
| 5 | exit code semantics | RC=0 on GREEN; RC=1 on RED |

Test 5 originally hit ERR-trap-on-rc1 issue (script exited mid-test); fix: replace direct `bash ...` invocation
with `RC=0; bash ... || RC=$?` pattern. Post-fix: 7/7 PASS.

### HH-G.4 checklist extension

Extended `.claude/skills/attach/references/procedures.md` with HH-G.4 portability validation checklist:
- Pre-flight (5 steps including VBW + smoke + firing-test verification)
- During /attach (8 verification points)
- Post-/attach validation (6 target-side checks)
- Known-issues to suppress (3 items: hybrid hook stubs, personal layer empty, needs-refactor skills)
- Re-validation triggers (4 trigger conditions)

## Decision

Ship 4 artifacts closing Phase 2.5 HH-G:

1. `templates/general-harness/CLAUDE.md` (NEW; 207 LOC; ~2713 tokens) — HH-G.1
2. `scripts/hooks/attach-portability-smoke.sh` (NEW; ~280 LOC) — HH-G.3 runner
3. `scripts/hooks/firing-tests/attach-portability-smoke-fire-test.sh` (NEW; ~210 LOC) — companion firing-test
4. `.claude/skills/attach/references/procedures.md` (EDIT; +60 LOC HH-G.4 section) — checklist

### What this means concretely

- Future /attach invocations have a deterministic pre-flight smoke + post-/attach verification path
- Manifest changes auto-trigger smoke re-validation (per HH-G.4 § Re-validation triggers)
- Phase 2.5 HH-G residue closed — Phase 3.5 IN-PROGRESS-PARTIAL-S173 status updated to include HH-G done in S174
- Token budget for portable CLAUDE.md ~2.7K (under 3K cap; close to 2.5K target — markdown overhead acceptable)
- Smoke runner is NOT wired in `.claude/settings.json` chains (manual invocation; manifest changes are episodic, not per-prompt)

### What this does NOT change

- StockForge biz layer (5 stockforge skills + 5 stockforge hooks + project-CLAUDE.md + charter) — untouched
- /attach skill execution path — skill still works the same; smoke is complementary verification
- Phase 3.5 T8 charter cool-down — still active until ≥2026-05-09
- Phase 3.5 T5 protocol mv→constitution (M-S173-1 deny-lift gap) — untouched; orthogonal

## Why (Reasons)

1. **Q4=A user-pick discharge**: S173 user explicitly sequenced HH-G as PRIORITY 1 for S174. This decision = the empirical execution of that pick.
2. **Phase 2.5 HH-G residue**: 22 sessions S148-S170 silently advanced past HH-G; S172 audit surfaced 3/4 NOT-STARTED. Q-B2 doctrine + verify_phase_before_next_phase doctrine both demand explicit closure not silent skip.
3. **Phase 3.5 firing-test discipline**: T7 retrofit drained 15→0 backlog at S79. NEW hooks must continue the discipline. This S174 ships smoke runner WITH companion firing-test from day-1.
4. **UP-05 autonomous-mode skill-tool gating**: smoke runner uses Bash + Python only; no Skill prompts. Aligns with autonomous-protocol Mode-A/D requirements.
5. **harness-priority-one user doctrine**: harness/system improvement always > product work. HH-G portability close = pure harness work; closes a known gap.

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Smoke false-positive when manifest legitimately grows (e.g., new harness skill) | medium | Assertion thresholds use `≥` not `==` where appropriate (A4 harness skills ≥17, B3 hooks ≥30); A5 stockforge skills `==5` is intentional (every new biz skill needs explicit Q-B2 gate to bump to ==6) |
| Smoke false-negative if new boundary not assertable (e.g., new layer beyond harness/stockforge/hybrid/personal) | low | Smoke is layered defense; not sole guard. New layer-tag would surface in V1-V7 drift-signal first |
| Template drifts from skeleton-templates.md (two CLAUDE.md baselines) | medium | Smoke A12 spot-checks template structural content (Karpathy 4 + Sandwich + Q&A doctrine present); explicit fragility — note in procedures.md HH-G.4 § Re-validation triggers |
| Smoke perf budget on Windows / Git Bash (Python startup overhead) | low | <3s observed on real project; smoke is manual not per-prompt; perf budget not binding |
| Firing-test fixture path quirks (Git Bash /c/ vs Windows C:/) | low | Resolved via `to_winpath` helper using `cygpath -m` first then `/c/` regex fallback; verified working |
| Future port consumers don't run smoke before /attach | medium | HH-G.4 checklist documents pre-flight as REQUIRED step; future Phase 4+ consumers' onboarding doc points here |

## Open Questions

(none — Q4=A closed)

If the standalone template diverges from skeleton-templates.md heredoc, refactor candidate: collapse heredoc into a single source-of-truth (read templates/general-harness/CLAUDE.md instead of inlining). Defer to future post-S180 cleanup pass.

## Acceptance Record

- **2026-05-07 S173**: ACCEPTED-IN-ADVANCE by user via AskUserQuestion S173 Q4=A "HH-G portability FIRST"
- **2026-05-07 S174**: PROPOSED by Claude Opus 4.7 — design per Phase 2.5 plan §HH-G + S172 audit gaps
- **2026-05-07 S174**: SHIPPED — 4 artifacts written; smoke 21/21 PASS; firing-test 7/7 PASS; production-firing evidence captured
- **VERIFIED-by**: production-firing-evidence (smoke GREEN on real state) + companion-firing-test (7/7 PASS) + token-count-budget (~2.7K within target)
