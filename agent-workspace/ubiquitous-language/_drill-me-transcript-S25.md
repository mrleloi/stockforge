# Drill-Me Transcript — S25 PLAN (Synthetic-Elicitation)

> **Source**: composed by sandwich-architect subagent during S25 PLAN session (2026-04-30) per `.claude/skills/ubiquitous-language/SKILL.md` audit-trail requirement.
> **Type**: SYNTHETIC-ELICITATION (no real human dialog; sandwich-architect compose). User-explicit-pick = Q-S25-1 = VHM (Recommended) gated upstream at S25 SessionStart; this transcript captures the term-elicitation reasoning that fed `glossary.md` v1.0.
> **Topic anchor**: "Vietnam stock market value investing with KOL tracking" (per master-plan 004 § S25 Goal).
> **Audience**: future agents doing UL drift audits + S29 verifier checking glossary provenance.

---

## Q1 — Scope anchor

**Q**: For the StockForge Phase 1 thin-slice, which signal tiers are in-scope vs deferred?
**A**: Tier 1 (Hard Data — deterministic prices/volumes/foreign-flow) is in-scope for Phase 1. Tier 2 (Official Narrative), Tier 3 (Influence Network / KOL), Tier 4 (Crowd / Pump) are anchored in glossary BUT marked `Phase scope: 2+`. Rationale: glossary acts as **vocabulary anchor** for Phase 2 work; defer enforcement, don't defer naming. Master-plan 004 § Q-S25-3 default YES on this.

## Q2 — Critical VN-domain mechanics

**Q**: Which Vietnamese trading mechanics MUST be in v1.0 even though Phase 1 ingestion is EOD-only?
**A**: 8 critical terms per main-session brief: T+2.5 (settlement), Room ngoại (foreign-ownership cap), Đội lái (pump operators), Mua chủ động / Bán chủ động (active buy/sell tape), Sàn HOSE/HNX/UPCoM (3 exchange tiers), Phiên ATO/ATC (auction phases), Tỷ giá USD/VND (FX). Some are Phase 2+ enforcement (Đội lái, Mua/Bán chủ động, ATO/ATC) but anchor here for early shared vocabulary.

## Q3 — Source-attribution discipline

**Q**: Each glossary term has `Source` + `As-of`. What sources qualify as authoritative?
**A**: Tiered authority order:
1. Charter / project specs (binding immutable)
2. HOSE/HNX/UPCoM official rulebooks + portals (regulatory authority for trading mechanics)
3. SBV/SSC circulars (regulatory authority for FX, margin, ownership caps)
4. VSD (Vietnam Securities Depository) for settlement + corporate actions
5. vnstock README + TCBS Open API docs (data-layer ground truth for Phase 1 adapter)
6. Vietstock public glossary + CafeF (industry-standard usage)

Avoid: KOL channels as glossary source (they're DATA, not authority); Wikipedia (not VN-specialized); private brokers' marketing material.

## Q4 — Bounded context mapping

**Q**: Each term gets a `BC mapping` field. How do you avoid term-explosion across BCs?
**A**: Each term is owned by ONE primary BC. Cross-cutting terms (e.g., `Signal Tier`, `Source Provider`) are tagged "cross-cutting" with a primary owner. Most VN-trading-mechanics terms (Trần, Sàn, Phiên ATO/ATC, Lô lẻ) own to BC-1 Market Data because they describe the market substrate that other BCs query. Tier 3-4 terms (KOL, Đội lái, Pump Pattern) own BC-6/BC-7. Risk/Position terms own BC-9.

## Q5 — Generic-finance vs VN-specific bifurcation

**Q**: Glossary has a section split: "Generic Finance" + "VN-Specific Trading Mechanics" + "Tier 3-4 Vocabulary". Why this taxonomy?
**A**: Two reasons:
1. **Maintenance**: Generic terms (P/E, ROE, Drawdown, Stop-Loss) come from canonical finance sources; rarely change. VN-specific terms drift as VN regulations evolve (e.g., SBV Circular 51/2021 set Room ngoại). Tier 3-4 vocabulary anchors Phase 2 work.
2. **Phase-scope filter**: agents reading glossary at Phase 2 entry can scan `Phase scope: 2+` filter to find terms needing activation; reduces re-scanning the whole file.

## Q6 — Forbidden terms carry-over

**Q**: v0 glossary had a "Forbidden Terms" table (e.g., "buy signal" → use Thesis with grade). Should v1.0 keep this?
**A**: Yes, verbatim carry-over. The forbidden table enforces I-S35 (research-aid framing) and Charter § Honest Boundaries (no price prediction). New v1.0 terms don't conflict with the existing 5 forbidden entries. Future PRs adding terms must check the forbidden table; if a new term overlaps, propose a rename via drift-log.

## Q7 — KOL ecosystem vocabulary depth

**Q**: How much KOL/Influence Network vocabulary should v1.0 carry, given Phase 2+ scope?
**A**: Anchor 5 core terms: KOL, Recommendation (KOL), Narrative Phase, Pump Pattern, Crowd Sentiment, F319/VFP forums. Depth-stop here. Specific narrative-phase enum values (INCUBATION → POST_DUMP) belong in spec 003 (already authored), not glossary. Glossary names the concepts; specs define the mechanics.

## Q8 — Sàn vs Trần collision

**Q**: "Sàn" appears twice — "Sàn HOSE" (exchange) AND "Sàn" (floor price). Conflict?
**A**: Different namespace. "Sàn HOSE / HNX / UPCoM" (with qualifier) = exchange. "Sàn" (alone, in price context) = floor price. Glossary entries kept separate with clear context cues. VN finance press uses both colloquially; agents learn from glossary disambiguation. Add `Not to confuse with` cross-reference if drift detected later.

## Q9 — Bear case enforcement vocabulary

**Q**: "Bear Case" is a Charter-mandatory thesis component. How does glossary signal that mandate?
**A**: Definition explicitly references I-S10 ("≥3 distinct risk factors with specific evidence + source URL + as-of") and Charter Principle 3 (Adversarial by design). Definition uses the verb "MUST" (uppercase emphasis carry-over from invariants.md style). System-refusal-to-render clause is captured in definition body. This makes the glossary entry self-contained for any agent reading it during thesis-template authoring at S30.

## Q10 — Calibration vs Confidence Score distinction

**Q**: Why two separate entries for `Calibration` and `Confidence Score`?
**A**: Different semantic roles:
- `Calibration` = the underlying empirical hit-rate data (BC-6/BC-8 owned; rolling-window metric)
- `Confidence Score` = the rendered output label {HIGH | MEDIUM | LOW} attached to thesis cards (BC-8 owned; categorical UI presentation)

The Charter Principle 8 chain is: Calibration data → Confidence Score label. Splitting clarifies that LLM "feeling confident" is rejected (calibration source mandatory) while still letting thesis cards present a simple categorical signal. Both entries are `Phase scope: 2+` because Phase 1 has zero calibration data yet.

## Q11 — Sector vocabulary depth

**Q**: Should glossary carry sector taxonomy (BĐS / NH / BL / etc.)?
**A**: Defer. Sectors live on `Company` entity (BC-3) which is Phase 2 first-entity. Phase 1 thin-slice is single-stock (VHM = real-estate); doesn't need sector enum yet. When BC-3 ships, sector taxonomy (likely 11 ICB Level-1 sectors mapped to VN equivalents) gets its own glossary section + drift-log entry. v1.0 mentions "real-estate" inline in VHM/D-009 context but does NOT define sector enum.

## Q12 — Personal-risk-profile terminology

**Q**: S26 ships `personal-risk-profile.md` template. What terms must glossary cover for that template?
**A**: Already covered: Position Sizing, Stop-Loss, Drawdown, Margin (Tỷ lệ vay margin). Holding-period vocabulary (1-month-min, 6-24mo preferred) is in Charter § First Sub-Scope; glossary reflects via Position entry implicitly. Sector-exclusion terminology defers to BC-3 Phase 2.

## Q13 — Reconciliation tolerance vocabulary

**Q**: S28 ships reconciliation service with 1% tolerance. Does that need a glossary term?
**A**: No — it's a CONFIG value (`tolerance_pct`), not a domain concept. Glossary covers domain language; configuration thresholds live in code/config + spec A.10 (Data Provenance). However, "Source Provider" (the entity attribute) IS a domain concept and is already glossary-resident.

## Q14 — Phase-scope drift detection

**Q**: How will agents detect when a `Phase scope: 2+` term needs promotion to `Phase scope: 1`?
**A**: Phase 2 PLAN entry (separate session post-S30) does a glossary sweep: for each `Phase scope: 2+` term, check if Phase 2 master plan activates the term's BC. If yes → promote to Phase 1+ (or label `Phase scope: 2`). drift-log.md captures the promotion event. Currently no automated detector; manual sweep is the discipline.

## Q15 — Closure

**Q**: What's the smoke-test for v1.0 glossary completeness?
**A**: 4 checks:
1. `grep -c '^### ' glossary.md` ≥ 30 (term count)
2. `grep -c '^\*\*Source\*\*' glossary.md` matches term count (source field on every entry)
3. All 8 critical VN-domain terms present (T+2.5, Room ngoại, Đội lái, Mua chủ động, Bán chủ động, Sàn HOSE/HNX/UPCoM, Phiên ATO/ATC, Tỷ giá USD/VND)
4. Forbidden table preserved verbatim from v0 (5 rows: buy signal, recommendation, price target, sentiment score, hot stock)

S29 verifier V1 dimension can re-run these checks against the `glossary.md` artifact.

---

## Provenance

- Composed by: sandwich-architect subagent (S25 PLAN session 2026-04-30)
- Driver prompt: "Vietnam stock market value investing with KOL tracking"
- Output target: `agent-workspace/ubiquitous-language/glossary.md` v1.0
- Audit trail: this file
- Drift-log entry: appended to `agent-workspace/ubiquitous-language/drift-log.md` (separate write; out of S25 PLAN scope per main-session brief — 5-deliverable cap)
- Synthetic-elicitation marker: agent-composed; no real human dialog. User input was upstream (Q-S25-1 = VHM exemplar pick); term-elicitation reasoning is the architect's.
