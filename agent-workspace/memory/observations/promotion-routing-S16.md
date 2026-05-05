---
observation_id: promotion-routing-S16
type: promotion-routing-summary
created_at: 2026-04-29
session: S16 (FOCUSED_IMPL — Track 7 IMPL ratification)
predecessor: agent-workspace/session-plans/pending/003-S15-track-7-constitution-amendments.md § 2 + § 4
related_decisions: [D-003 REV-4, D-005 REV-1]
---

# Promotion Routing — S16 IMPL Outcomes

> Per Q-E3 (closed S15 Batch 1): hook FIRST, skill SECOND, charter LAST. This file documents how the 10 L-S* lessons + S15-close user correction got routed in S16 IMPL.

## Summary

| Lesson | Title | Routed To | Artifact | Status |
|---|---|---|---|---|
| **L-S11-1** | Phase 0 hook portability (bash + POSIX only) | HOOK + CHARTER (proposal) | `scripts/hooks/bash-hook-lint.sh` § Check 1 + `proposals/financial-data-protocol-amendment.md` Rule 11 | ✅ shipped |
| **L-S11-2** | IMPL-tier-resolution-doctrine | CHARTER (proposal) | `proposals/decision-discipline.md` Rule 2 | ✅ shipped |
| **L-S12-1** | Metric-function-required for self-learning claims | HOOK + SKILL + (charter optional, deferred) | `scripts/hooks/learning-loop-metric-check.sh` (shipped S13, **wired S16**) + `try-n-approaches/SKILL.md` § Validation Pre-Conditions | ✅ shipped (charter deferred per Plan § 6) |
| **L-S12-2** | Research-scanner output discipline | HOOK + (charter optional, deferred) | `scripts/hooks/research-scanner-output-validator.sh` (shipped S13, **wired S16**) | ✅ shipped |
| **L-S13-1** | Producer-consumer log path mismatch | HOOK | `scripts/hooks/bash-hook-lint.sh` § Check 2 (orphan-log-var detection) | ✅ shipped |
| **L-S13-2** | Cumulative vs windowed metric distinction | SKILL | `try-n-approaches/SKILL.md` § Best Practices (NEW section, +21 LOC; final LOC=136 ≤150) | ✅ shipped |
| **L-S14-1** | Progressive-disclosure first-draft compression reserve | SKILL | `write-a-skill/references/best-practices.md` (NEW companion file, no D1 ceiling) | ✅ shipped |
| **L-S14-2** | Skill-vs-command duplication multiplier | SKILL + CHARTER (proposal) | `write-a-skill/references/best-practices.md` § L-S14-2 + `proposals/architecture-amendment.md` § Slash Command vs Skill | ✅ shipped |
| **L-S14-3** | Wildcard permissions land in settings.local.json | MEMORY | `~/.ccs/.../harness_bootstrap_permission_override.md` § L-S14-3 amendment | ✅ shipped |
| **L-S14-4** | autonomous_mode + Mode A/B/C/D coverage | CHARTER (proposal) | `proposals/autonomous-protocol.md` Rule 2 + `proposals/session-budgets-amendment.md` § Mode A/B/C/D dispatch | ✅ shipped |
| **S15-close user correction** | Full autonomous = ONLY mode (no SUPERVISED) | CHARTER (proposal) + DRIFT SIGNAL | `proposals/autonomous-protocol.md` Rule 1 + `bash-hook-lint.sh` § Check 3 (D-IDENTITY) | ✅ shipped |

## Routing principle observed

**Hook FIRST**: 4 lessons routed primarily via hook (L-S11-1, L-S12-1, L-S12-2, L-S13-1). Plus S15-close user correction got a drift signal D-IDENTITY in `bash-hook-lint.sh` § Check 3.

**Skill SECOND**: 3 lessons routed primarily via skill (L-S13-2, L-S14-1, L-S14-2). All in `references/<topic>.md` companions or amended SKILL.md sections.

**Charter LAST**: 4 lessons routed via constitution proposals (L-S11-2, L-S14-2, L-S14-4, S15-close correction). All in `agent-workspace/proposals/` pending user explicit approve before move to `constitution/`.

This matches Q-E3's "cheapest first" doctrine: hook = deterministic check (zero LLM cost); skill = procedural discipline (small LLM context cost); charter = identity/invariant (heaviest lift, requires user approve).

## D1 baseline (pre-S16 = 16)

S16 D1 baseline post-IMPL = **16 violations** (unchanged):
- 5 skills (227 spec-to-wiki, 226 crawler-reliability, 225 fastapi-module, 210 ubiquitous-language, 163 write-a-skill)
- 10 commands (217 drill-me, 209 drift-check, 201 master-plan, 200 ul-audit, 199 session-start, 198 grill-me, 192 vbw-check, 183 session-end, 163 spec-author, 146 budget-check)
- 1 agent (235 drift-detector)

write-a-skill amendment did NOT touch SKILL.md (already at 163 = D1); created `references/best-practices.md` companion instead. try-n-approaches amendment landed at 136 LOC (≤150).

## Carry-over to S17+

- Track 6 secondary closure: 16 D1 violators above. S17 dedicated session (or absorbed mid-S17 if budget allows).
- L-S12-1 + L-S12-2 charter amendments: optional per Plan § 6; only if user requests after seeing hook+skill suffice.
- promote-rule subagent run: now that S16 ships routing artifacts, `promote-rule` skill should run on accumulated agent-notes for any rules not yet promoted (S17 candidate).
- L-S15-1 promotion candidate (AskUserQuestion multi-batch packing 4+3+2): deferred — amend `grill-maximization/SKILL.md` § Multi-batch composition. S17+ candidate.
- D9 pre-existing finding: `metric-failure-mode-rate.sh` references `learning-data/(events|archive)/` but isn't in `LEARNING_WRITE_HOOKS` whitelist of `drift-signals-D1-D9.sh`. Add to whitelist next session OR justify why it's a non-whitelist read (it's a metric script that *reads* events for counting, so should perhaps be added to whitelist with justification).

## Provenance log

Every routing entry above traces to:
- Source lesson in `agent-workspace/memory/agent-notes.md` (L-S11-1 .. L-S14-4 entries with dates 2026-04-29)
- Plan `agent-workspace/session-plans/pending/003-S15-track-7-constitution-amendments.md` § 2 (routing table) + § 4 (deliverables)
- Closed queued-grill items in `agent-workspace/memory/observations/queued-grill-master.md` (Q-B2/E2/E3/D3/C2/C3/2.1/E1/E4 — all status=closed)
- S15 close user correction documented in `agent-workspace/memory/checkpoints/latest.md` § Critical context for S16
- Plan compression reserve from L-S14-1 (write-a-skill) per S14 carry-over checkpoint

S16 success criteria 1-10 all PASS (see `agent-workspace/memory/sessions/2026-04-29-session-16.md` for verification table).
