---
id: QA-2026-05-01-002
topic: "S41 Track F PLAN — 2 SCOPE-tier user-gates from D-014 § Open Questions"
opened_at: 2026-05-01T20:00:00+07:00
expected_answer_by: 2026-05-08T20:00:00+07:00
priority: high
related_decisions:
  - D-014 (S41 Track F architecture — ACCEPTED with 2 Open Questions pending_user_gate)
status: answered-2026-05-01-via-AskUserQuestion (awaiting user mv to answered/)
mode: file-based-bundle (autonomous-mode-friendly)
question_count: 2
defer_cycle: 0
source_prompt: agent-workspace/memory/decisions/014-track-F-architecture.md § Open Questions
related_artifacts:
  - specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md (Track F binding spec — § B.5 system_prompts + § B.10 cost profile)
  - agent-workspace/session-plans/pending/006-S41-track-F-impl-sub-plan.md (S42 + S43a deliverables matrix)
  - specs/tier2-feature/001-validate-investment-thesis.md § B.10 (Opus vs Sonnet cost trade-off baseline)
  - agent-workspace/memory/personal-risk-profile.md (currently `<USER FILL>` template)
gate_for: S43a (UI + 5-thesis dogfood); S42 IMPL can proceed with Recommended defaults if user defers
---

# S41 Track F — 2 SCOPE-tier User-Gates

> Per Q-B2 doctrine: charter/SCOPE-tier MUST require explicit letter pick (no default acceptance). These 2 questions emerged from D-014 § Open Questions and gate Track F's user-perceived behavior. **S42 IMPL can proceed with Recommended defaults** while these stay pending; both questions only become blocking at **S43a entry** (5-thesis dogfood — the user-facing milestone).

---

## Q1 — QuantAgent model: Opus 4.7 vs Sonnet 4.6?

**Source**: spec 001 § B.10 cost profile + D-014 § Open Questions Q-S41-1 + spec 006 § B.5 QuantAgent system_prompt.

**Context**: The QuantAgent interprets deterministic numbers (P/E, P/B, ROE, drawdown, volatility) computed by `Phase1DataGatherer` from BC-1+BC-2 repositories. It NEVER computes numbers itself (I-S1 enforced via system_prompt). Bear and Bull agents are fixed to Sonnet 4.6 per spec — only QuantAgent's model is open.

**Trade-off** (cost numbers from spec 001 § B.10, NOT LLM-computed):
- **Opus 4.7**: ~$0.70/run · Higher reliability for numeric interpretation + structured output adherence · Recommended in spec 001 § B.10
- **Sonnet 4.6**: ~$0.20/run · Saves ~$0.50/thesis · Adequate for numeric interpretation per S35 promotion notes; risk = lower structured-output adherence under cost pressure

**Cost impact** (per validation):
- Option A (Opus): Bear $0.30 + Bull $0.30 + Quant $0.70 + Synthesizer $0.20 ≈ **$1.50/thesis** (target $2 ✅; hard cap $3 ✅)
- Option B (Sonnet): Bear $0.30 + Bull $0.30 + Quant $0.20 + Synthesizer $0.20 ≈ **$1.00/thesis** (target $2 ✅; further headroom)

**Options**:
- A: **Opus 4.7 for QuantAgent** (Recommended — reliability premium for numeric interpretation; $0.50 surcharge per thesis acceptable within $2 target)
- B: **Sonnet 4.6 for QuantAgent** (cost-optimized; $0.50 saved per thesis; risk = monitor structured-output adherence in S43a dogfood)
- C: Open answer (specify; e.g., "use Opus for first 5 dogfood theses, switch to Sonnet at Phase 2 close once reliability validated")

**Default if user defers past S43a entry**: A (Opus). S42 IMPL builds the LLM port abstractly; switching A↔B is a 1-line config change at S43a.

**User answer**: **C** — Opus 4.7 for first 5 dogfood theses; reassess at Phase 2 close once structured-output adherence validated (resolved 2026-05-01 at S43a entry via AskUserQuestion). Cost re-estimate: ~$1.50/thesis × 5 = ~$7.50 dogfood spend; switch decision becomes Phase 2 close carryover.

---

## Q2 — Personal-risk-profile.md fill timing?

**Source**: D-014 § Risks (HIGH likelihood) + § Open Questions Q-S41-2 + spec 006 § A.7 Risks + master-plan 005 § S41 success criterion #4.

**Context**: `agent-workspace/memory/personal-risk-profile.md` is currently a `<USER FILL>` template (33 placeholders). The thesis pipeline reads this file to enforce owner-personal risk caps (max position size, sector concentration, holding-period preference, drawdown tolerance). Charter floor (no derivatives / no shorting / no insider info) binds regardless of fill.

**What "charter-floor-only" means** (Option A default): Quant agent receives charter-floor risk context — `max_position: 0.15` (15% of portfolio), `max_sector_concentration: 0.30` (30%), `holding_period: medium-term-default`, `max_drawdown: 0.20`. These are the system-default placeholder values the spec already wires; owner-personal preferences are just unenforced (no override above charter floor).

**Risk of Option A**: First 5 dogfood theses run against generic defaults. If user's actual tolerance is more conservative (e.g., max_position 0.05 / max_drawdown 0.10), the dogfood theses will surface positions sized for a more aggressive owner profile than reality. Mitigation: dogfood theses are exemplars, not actionable trades — owner reviews each before any real trade.

**Options**:
- A: **Proceed with charter-floor defaults** (Recommended — non-blocking; S42 + S43a both runnable; user fills profile post-dogfood once seeing concrete examples — "fill informed by exemplars" is often higher-quality than fill-in-vacuum)
- B: **Block S42 entry until user fills profile** (cautious — guarantees first dogfood thesis uses owner-personal caps; risk = blocks S42 indefinitely if user busy)
- C: **AskUserQuestion 1Q at S43a entry** (compromise — S42 IMPL proceeds with defaults; S43a fires `AskUserQuestion` 1Q "fill profile now or proceed with charter-floor for dogfood?")
- D: Open answer

**Default if user defers past S43a entry**: A (proceed charter-floor). 5-thesis dogfood at S43a is exemplar-quality, not action-quality.

**User answer**: **A** — Proceed with charter-floor defaults (max_position 0.15 / sector 0.30 / max_drawdown 0.20). User will fill profile post-dogfood with exemplar context (resolved 2026-05-01 at S43a entry via AskUserQuestion).

---

## How to answer

Either:
1. Inline-edit this file (write your letter pick under each "User answer" line), then `mv` to `human-workspace/q-and-a/answered/`
2. OR drop a `human-workspace/user_prompt/YYYYMMDD_NN_<slug>.txt` with your picks (agent will reconcile next session)

Per `human-workspace/CLAUDE.md` Rule 4: agent does not move this file; user moves it to `answered/` once answered.
