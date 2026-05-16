---
proposal_id: theme-g-i-s1-1-amendment-2026-05-16
session: S335-C-architect (background sandwich-architect subagent)
authored: 2026-05-16
author: Claude Opus 4.7 (sandwich-architect subagent dispatched from S335 main session)
status: PROPOSED (awaiting human ratification gate)
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md § 6.3 (Phase C)
parent_decision: agent-workspace/memory/decisions/061-wave-1-integration-ratification.md § Decision item 6 + Q-INT-2026-05-6=A (ACCEPTED 2026-05-15T15:30+07:00 blanket-A)
recommended_path: B (CONSTITUTION-WRITE in agent-workspace/constitution/financial-data-protocol.md as new "Rule 16 — Numeric-Field Discipline (I-S1-1)")
alt_paths: A (CHARTER amendment v1.1 → v1.2); C (REJECT — I-S1 already covers); D (RE-ARCHITECT with refined scope)
empirical_evidence_sources: 5
literal_amendment_loc: ~70 LOC (constitution-write target)
out_of_band_gate: human-explicit-approve per CLAUDE.md hard rule "Never modify ... constitution without explicit human approval"
hard_rules_acknowledged:
  - "no production code in this PROPOSAL (sandwich-architect subagent contract — markdown only)"
  - "no direct charter or constitution edits (CLAUDE.md hard rule — Write blocked for PROJECT_CHARTER.md + agent-workspace/constitution/**)"
  - "no commits in this PROPOSAL (sandwich-architect subagent dispatch instructions; no Bash tool granted)"
  - "no human-workspace writes (proposal lives in agent-workspace/proposals/; AskUserQuestion gate fired by main S335)"
  - "every claim in this proposal cites file:line per I-S2"
  - "no LLM math — severity/likelihood claims are categorical (HIGH/MEDIUM/LOW), not LLM-emitted floats"
  - "adversarial framing — each recommended path includes 'what could go wrong' subsection (per § 4 + § 6)"
---

# Theme G — I-S1-1 (Numeric-Output Discipline) Sub-Rule Addition Proposal

> **Goal**: Decide the canonical home + literal text for the I-S1-1 sub-rule that Phase A
> empirically confirmed as a GENUINE-new operationalization of Charter Principle 9 ("No LLM
> math"). Awaiting human ratification gate (out-of-band) post-S336.
>
> **TL;DR for the human reader (3 lines)**: Phase A's 15 deep-dives surfaced 3 candidate
> repos (ai-hedge-fund + TradingAgents + TradingAgents-CN) where the LLM is explicitly asked
> to EMIT numeric output fields (`confidence: int 0-100`, `price_target: Optional[float]`,
> `entry_price: Optional[float]`, "🚨 强制要求提供具体数值"). Charter Principle 9 + I-S1
> + I-S7 already FORBID this in spirit but lack the schema-level enforcement surface. The
> proposed I-S1-1 rule operationalizes "what counts as numeric output" + "what the LLM is
> permitted to do when a schema field looks numeric" + "the deterministic-pipeline echo
> contract". Recommended path: **constitution write (Path B)** as a new "Rule 16" in
> `financial-data-protocol.md` — faster than charter v1.1 → v1.2 amendment, equally binding
> in practice, no 48-hour cool-down ceremony.

---

## § 1. Empirical Evidence (Phase A findings)

The hypothesis — "LLM emits confidence/price floats without grounding" — was confirmed by
file:line-cited evidence across 5 Phase A deep-dives. Per
`agent-workspace/research/INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md § G.2` 5-row
empirical survey table, the offending surfaces are:

### 1.1 ai-hedge-fund (license: MIT-declared; A-01)

- **`src/agents/warren_buffett.py:13-16`** defines `WarrenBuffettSignal` Pydantic model with
  `confidence: int 0-100`. The LLM is the emitter — `call_llm()` wrapper at
  `src/utils/llm.py:10-80` enforces `with_structured_output(method="json_mode")`. Per
  `agent-workspace/memory/observations/master-planner-A-01-deepdive-ai-hedge-fund.md § 5`
  second-to-last bullet: "Confidence is LLM-self-reported, NOT calibrated to historical
  hit-rate". Confidence rubric at `warren_buffett.py:788-794` describes confidence brackets
  in terms of "evidence quality the LLM perceives" — not posterior hit rate.
- **Anti-pattern flagged at A-01 § 7 R3**: "LLM-self-reported confidence treated as
  ground-truth … emits `confidence: 75` and downstream code uses it as a real number.
  Without back-test calibration, this is a hallucinated metric."

### 1.2 TradingAgents (license: Apache-2.0; A-13)

- **`tradingagents/agents/schemas.py:127`** — `entry_price: Optional[float]` (LLM-fillable
  via structured output).
- **`tradingagents/agents/schemas.py:199`** — `price_target: Optional[float]` (LLM-fillable).
- Per `agent-workspace/memory/observations/master-planner-A-13-deepdive-TradingAgents.md
  § 7.4` (anti-pattern): "structured-output schemas have `entry_price: Optional[float]`
  and `price_target: Optional[float]` which **could** be filled by LLM. StockForge IMPL
  must either (a) ban these fields, or (b) require them to echo a code-computed value (no
  LLM arithmetic). **Audit point.**"
- Partial mitigation visible at `tradingagents/graph/signal_processing.py:240-279` (regex
  extraction of numbers from free text) but the prompt itself still asks the LLM to produce
  a number — the schema is the entry point of the violation.

### 1.3 TradingAgents-CN (license: Apache-2.0 core; A-14)

- **`tradingagents/agents/trader/trader.py:68-80`** — system prompt explicitly mandates:
  "🚨 强制要求提供具体数值" ("Mandatory requirement: provide concrete numeric values") +
  "不允许设置为null或空值" ("null or empty values not permitted") for:
  - 投资建议 (investment recommendation) — buy/hold/sell
  - 目标价位 (target price)
  - 置信度 (0-1) (confidence 0-1)
  - 风险评分 (0-1) (risk score 0-1)
- Per `agent-workspace/memory/observations/master-planner-A-14-deepdive-TradingAgents-CN.md
  § 3.10` + **§ 7.5** (anti-pattern, LITERAL `这是 the most aggressive LLM-number-emit
  pattern`): "This violates StockForge's no-LLM-math hard rule … StockForge MUST refactor:
  the LLM should reason about RANGES, CATALYSTS, SCENARIOS — and a deterministic
  price-derivation step (DCF, P/E multiple from sector median, P/B multiple, etc.) emits
  the final numeric. Anti-pattern to NOT inherit."
- Additional violation at `agents/managers/research_manager.py:44-51` — "📊 目标价格分析…
  您必须提供具体的目标价格 - 不要回复'无法确定'或'需要更多信息'".

### 1.4 FinceptTerminal (license: AGPL-3.0; A-04) — COUNTEREXAMPLE

- **`services/notifications/NotificationService.h:15`** — `NotifLevel { Info, Warning,
  Alert, Critical }` is a bounded ENUM, not a float. Per
  `agent-workspace/memory/observations/master-planner-A-04-deepdive-FinceptTerminal.md
  § 7.3`: counterexample — no LLM-emitted float in the notification severity schema. The
  C++ source uses an enum for the only severity-like signal; the LLM is not asked to
  generate a numeric severity score.
- This is what I-S1-1 wants every confidence-like surface to look like: categorical or
  deterministic-pipeline-derived, never LLM-emitted floats.

### 1.5 Vibe-Trading (license: MIT; A-15) — COUNTEREXAMPLE

- **`agent/src/skills/ashare-pre-st-filter/SKILL.md:138-139`** — explicit
  `confidence=low` enforcement when the mechanical-annualisation block-rule
  (`SKILL.md:264-295` subject-weighted frequency rule) is violated. This is a
  deterministic categorical-confidence assignment, not LLM-emit. Per
  `agent-workspace/memory/observations/master-planner-A-15-deepdive-Vibe-Trading.md § 3 C5`:
  "Mechanical-annualisation block-rule … explicit `confidence=low` enforcement when
  violated. Concept-port as I-S62 sub-rule + decorator on forecasting functions."
- This is the deterministic-rule pattern I-S1-1 should encode at the schema level: where a
  rule fires, the confidence value is fixed by the rule, not by the LLM's perception.

### 1.6 Empirical synthesis (per SUPPLEMENT § G.2 conclusion)

> "The 3 main multi-agent frameworks (ai-hedge-fund + TradingAgents + TradingAgents-CN)
> all have LLM-emitted confidence/price fields. **I-S1-1 is a GENUINE new operationalization,
> not redundant with I-S1.** AP-23 red-flag check: I-S1 says 'no LLM math' generally; I-S1-1
> specializes to 'LLM never emits float confidence/price as output field' — different scope,
> different enforcement surface (schema-level vs computation-level)."

**Verdict (architect re-attestation)**: The Phase A claim is sound. The 3 high-fit
repos (ai-hedge-fund, TradingAgents, TradingAgents-CN) all surface LLM-emitted numeric
fields as Pydantic schema fields or explicit prompt mandates. The 2 counter-examples
(FinceptTerminal enum, Vibe-Trading deterministic categorical) demonstrate the safe
pattern. **Path C (REJECT — already covered by I-S1) is NOT correct**: I-S1's prose ban
on "LLM never returns a number as natural-language output" + I-S7's "Confidence ≠ Hit
Rate" together do not enforce at the **schema definition** layer — the Pydantic field
`confidence: int 0-100` is the violation surface, and neither I-S1 nor I-S7 mention
schema-level constraint enforcement.

---

## § 2. Stockforge Surface Inventory (where I-S1-1 will bite)

The 3rd-party-repo evidence shows the **pattern** to ban. The proposal's enforcement
scope is the stockforge codebase itself. Today's surface:

| Field | Path | Tier | Currently |
|---|---|---|---|
| `KolRecommendationExtracted.confidence_extracted: float` | `agent-workspace/constitution/architecture.md:300` | BC-6 event contract | Semantic comment "how sure LLM is about extraction (NOT recommendation strength)" — but no schema-level constraint preventing LLM from emitting this value |
| `confidence_extracted` (Rule 9 KOL Recommendation Provenance) | `agent-workspace/constitution/financial-data-protocol.md:149` (existing protocol Rule 9; semantically related, where I-S1-1 would slot as Rule 16 not as amendment of Rule 9) | data-integrity rule | Documented as "LLM's stated confidence in the extraction (0-1)" — same semantic gap |
| `KolRecommendationExtracted` general structure | `agent-workspace/constitution/architecture.md:295-302` (dataclass) | event contract | Will need follow-up audit at IMPL time once I-S1-1 is binding |
| Future Theme H IMPL fields (extends `ResearchPlan` / `TraderProposal` / `PortfolioDecision` schemas) | DOES NOT YET EXIST; will be created by Phase F-prime per `INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md § H.4` | BC-8 output schemas | **GATED**: I-S1-1 ratification is a prerequisite for Phase F-prime IMPL (per master plan § 6.3 sequencing note and SUPPLEMENT § G.4 "Theme G is a prerequisite for Theme H IMPL") |

This is the **enforcement surface** I-S1-1 will guard. The 4 inventory rows justify
"GENUINE-new" — they are real schema fields (or planned schema fields) in stockforge's
own codebase + constitution, not just hypothetical anti-patterns in third-party repos.

---

## § 3. Path Decision Matrix (A vs B vs C vs D)

| Property | Path A — Charter v1.1 → v1.2 amendment | Path B — Constitution write (financial-data-protocol.md) | Path C — REJECT (already covered by I-S1) | Path D — RE-ARCHITECT |
|---|---|---|---|---|
| **Where it lands** | `PROJECT_CHARTER.md` § Core Principles (sub-principle under P9, or new P12) | `agent-workspace/constitution/financial-data-protocol.md` (new "Rule 16 — Numeric-Field Discipline (I-S1-1)") + cross-reference in `invariants-stockforge.md` § Stock-Specific Data Integrity (new entry between I-S1 and I-S2) | No file edit | TBD per refined scope |
| **Ceremony** | HIGH — Revision Protocol mandates (a) written rationale, (b) **48-hour cool-down** before commit, (c) explicit version bump v1.1 → v1.2 | MEDIUM — constitution write requires explicit human-approve per CLAUDE.md hard rule, but NO cool-down, NO version bump | NONE — no file edit | HIGH — re-dispatch architect session + re-author proposal |
| **Visibility** | HIGHEST — charter loaded every session per CLAUDE.md always-loaded contract | HIGH — `financial-data-protocol.md` already imported via stockforge CLAUDE.md § Constitution table ("Financial-data-protocol.md … Stock-specific data integrity rules") | N/A | depends on outcome |
| **Precedent** | D-056 (charter v1.0 → v1.1 ratification of Principle 11) shows the 48h cool-down + verbatim-text gate path works | financial-data-protocol.md already has 15 rules (Rules 1-15 + portability Rule 11 + VN-domain Rules 12-15 added by D-021); pattern of "constitution rule add" is well-established | N/A | none — this would be a first |
| **Authoritative weight** | CHARTER tier (highest in stockforge rule hierarchy) | CONSTITUTION tier (binding; one level below charter) | n/a | n/a |
| **Speed to binding** | ≥48h (Revision Protocol cool-down) + human edit window | Same-session human edit window once approved | n/a | re-dispatch + re-architect + re-ratify |
| **Risk of over-amendment** | HIGH — charter is "small/precious" (per CLAUDE.md); over-amendment dilutes signal | LOW — constitution files are operational/granular by design | n/a | n/a |
| **Aligns with D-061 ratification** | NO — D-061 § Decision item 6 explicitly ratified Q-INT-2026-05-6 = A ("constitution write in financial-data-protocol.md") per `qa-2026-05-15-wave-1-bis.md` line 32 | **YES — exact ratified path** | NO — contradicts D-061 § Decision item 5 "I-S1-1 GENUINE-new CONFIRMED" + § Decision item 6 ratification | depends on refined scope |
| **AP-23 promote-or-retire alignment** | Promote satisfied | Promote satisfied | Retire-without-evidence = anti-pattern | depends |
| **What could go wrong (adversarial)** | (a) cool-down ceremony delays Phase F-prime IMPL by ≥48h; (b) charter version-bump record-keeping risk per D-056 precedent of D-047 false-claim; (c) higher cognitive cost for every future agent loading charter | (a) less visible than charter — risk of being missed by future agent; (b) constitution write ALSO needs human-approve per CLAUDE.md hard rule — same gate, but precedent of D-019 Rule 11 + D-021 Rules 12-15 shows the gate works; (c) cross-reference in invariants-stockforge.md needed to maintain coherence — adds 1 small follow-up edit | (a) re-creates the very anti-pattern Phase A documented; (b) Phase F-prime Theme H IMPL has no schema-level guard; (c) AP-23 retire-without-evidence is itself a charter violation (no empirical evidence to retire on) | (a) burns S335 budget for re-PLAN; (b) defer_cycles inflate; (c) Wave-1 critical path blocked |

**Architect recommendation: Path B (constitution write).**

**Rationale chain (4 reasons, all source-cited)**:

1. **D-061 ratification already picked B.** Per
   `agent-workspace/memory/decisions/061-wave-1-integration-ratification.md` § Decision item 6:
   "Theme G recommended path = constitution write in
   `agent-workspace/constitution/financial-data-protocol.md` (path B per master plan
   Q-INT-2026-05-3 option B) — faster than charter v1.1 → v1.2 amendment; requires explicit
   human-approve gate per CLAUDE.md hard rule; AP-23 promote trigger satisfied. **Pending
   user-ratify Q-INT-2026-05-6.**" The Q-INT-2026-05-6 = A pick was delivered at
   2026-05-15T15:30+07:00 per `human-workspace/q-and-a/answered/qa-2026-05-15-wave-1-bis.md`
   line 32. This proposal HONORS the prior ratification — Path A or C would CONTRADICT it.

2. **AP-23 satisfied without invoking charter machinery.** Per CLAUDE.md § Hard Rules:
   "Refinement-of-rule (lesson-about-lesson) is AP-23 RED FLAG: 2nd instance mandates
   promote-or-retire (not inline accumulation)." Per
   `INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md § G.5`: "**SECOND instance of
   rule-about-rule for I-S1** (first was W0-2 D-059 Python determinism contract).
   **PROMOTE-or-retire trigger fires at second instance**; this is the second — promote to
   a dedicated constitution rule, NOT inline accumulation under I-S1." Constitution-tier
   rule promotion satisfies the "promote" outcome without the charter ceremony.

3. **Constitution is the right specificity tier.** The proposed I-S1-1 rule is a
   **schema-enforcement specialization** of an existing charter principle, not a new
   foundational principle. Charter Principle 9 ("No LLM math") is the foundation;
   I-S1-1's role is to define WHAT counts as numeric output at the dataclass/Pydantic-field
   level + WHAT the deterministic-pipeline echo contract requires. This is the same shape
   as `financial-data-protocol.md` Rule 7 (Sentiment Score Calibration) specializing the
   I-S1 principle for sentiment scores — a precedent the project has accepted (D-021).

4. **Time-to-binding matters for Phase F-prime Theme H IMPL.** Per master plan § 6.3
   sequencing note + `INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md § G.4`: "Theme G is a
   prerequisite for Theme H IMPL (BC-8 output schema needs I-S1-1 enforced before
   debate-style synthesis can output structured plans with confidence fields)." The 48h
   cool-down of Path A would delay Phase F-prime IMPL kickoff by at least 2 days; Path B
   binds same-session-on-approval.

**Adversarial alternate kept on shelf**: If the human reviewer concludes that I-S1-1 is
foundational enough to warrant charter-tier placement (an opinion-call about
rule-architecture, not about Phase A evidence), Path A is still legitimate — Phase A
empirical evidence stands either way; the question is WHERE the rule lives, not WHETHER
the rule is needed. This proposal does not foreclose Path A; it only RECOMMENDS Path B
per D-061 prior ratification.

---

## § 4. Literal Amendment Text

**Target file (Path B, recommended)**: `agent-workspace/constitution/financial-data-protocol.md`

**Insertion point**: New "Rule 16 — Numeric-Field Discipline (I-S1-1)" appended after
existing Rule 15 (FX VND-USD Point-in-Time Discipline; D-021), before "Last modified"
footer. Cross-reference row appended to "Quick Reference Table".

**Companion edit**: `agent-workspace/constitution/invariants-stockforge.md` gets a new
short entry between I-S1 and I-S2 (acting as the named invariant alias for Rule 16, the
same way Rule 6 "LLM Output Provenance" is aliased to I-S1 in the existing Quick
Reference Table at `financial-data-protocol.md:269`).

**Note on placement (Path A counterfactual)**: if the human instead picks Path A,
the equivalent insertion is a new sub-principle "9.1 Numeric-Field Discipline" beneath
existing Principle 9 in `PROJECT_CHARTER.md` § Core Principles, with the v1.1 → v1.2
revision-history line. The literal text below is structured to drop into either home
(it is rule-level prose, not file-section-specific).

### 4.1 The proposed I-S1-1 / Rule 16 text (verbatim — to be inserted by human approver)

```markdown
## Rule 16 — Numeric-Field Discipline (I-S1-1) (PROPOSED 2026-05-16; ratified D-NNN)

### The Problem

Charter Principle 9 ("No LLM math") + I-S1 ("No LLM Math") + I-S7 ("Confidence ≠ Hit
Rate") together forbid the LLM from generating numbers, but operate at the prose / output
layer. They do not constrain the **schema** layer: a Pydantic / dataclass field declared
`confidence: float` or `price_target: float | None` is itself an invitation for the LLM
to emit a numeric value, and downstream code that consumes that field will treat the
LLM-emitted number as data.

Phase A's 15 deep-dive observations (Wave-1 research integration, S323-S324) found this
pattern in 3 candidate repos: ai-hedge-fund (`src/agents/warren_buffett.py:13-16` —
`confidence: int 0-100`), TradingAgents (`tradingagents/agents/schemas.py:127, :199` —
`entry_price` + `price_target` Optional[float]), and TradingAgents-CN
(`tradingagents/agents/trader/trader.py:68-80` — explicit "🚨 强制要求提供具体数值"
mandating LLM-emitted confidence + risk score). Each is a violation of the rule this
Rule 16 codifies. Two counter-examples (FinceptTerminal `NotifLevel` bounded enum at
`services/notifications/NotificationService.h:15` + Vibe-Trading deterministic
`confidence=low` enforcement at `SKILL.md:138-139`) show the correct shape.

### The Rule

**An LLM never emits a numeric value as the source-of-truth for an output field.** This
applies to **every** dataclass / Pydantic / TypedDict / event schema field whose type is
`int`, `float`, `Decimal`, `complex`, `numpy.number`, or any container parameterized on a
numeric scalar (e.g. `list[float]`, `dict[str, int]`, `tuple[float, ...]`) — and to any
free-text output that, when parsed, would yield a numeric scalar of these types.

A field whose type is numeric, and whose value originates in or transits through an LLM
call, MUST satisfy at least one of:

1. **Categorical surrogate**: The field is replaced with an `Enum` or `Literal[...]`
   bounded categorical (per the FinceptTerminal `NotifLevel` and Vibe-Trading
   `confidence=low` patterns above; per existing `financial-data-protocol.md` Rule 7
   `STRONGLY_BULLISH | BULLISH | NEUTRAL | BEARISH | STRONGLY_BEARISH`). The LLM picks a
   category; deterministic code converts to a number downstream if/when needed.

2. **Deterministic-pipeline echo**: The field's value is computed by deterministic code
   (a non-LLM Python function operating on verified inputs per Rule 6 LLM Output
   Provenance, Rule 4 Source Attribution, and the source_evidence chain of the calling
   use case). The LLM is permitted only to **echo** that computed value back inside its
   structured output. Echo validation is mandatory: the post-LLM step asserts the
   LLM-echoed value equals (or matches within tolerance) the upstream computed value.
   Mismatch is a HARD ERROR (raise + abort; never silently coerce).

3. **Calibration-database lookup**: For confidence-like fields specifically, the value
   is sourced from `agent-workspace/calibration/` keyed on (`extractor_version`,
   `signal_type`) tuple. The lookup is a deterministic dictionary access on calibration
   data captured per Charter Principle 8 ("Calibration over confidence"). The LLM never
   computes nor estimates this value.

4. **NULL / unknown surrogate**: For fields where neither a categorical nor a
   deterministic pipeline value exists, the field MUST be `Optional[T]` AND the LLM-
   produced output sets it to `None`. Downstream consumers treat `None` as
   "uncomputed", never as "zero" or "unknown-but-implied-low".

### The Enforcement

**At schema definition time** (mypy --strict + ruff custom rule, planned IMPL hook):
- Any new dataclass / TypedDict / Pydantic field with a numeric type, declared in a path
  that participates in an LLM call site (initial scope: `packages/contracts/events/**`,
  `packages/domain/**`, BC-6 + BC-8 schema modules), MUST have one of: (a) a sibling
  `*_source: Literal["categorical", "deterministic", "calibration", "null"]` discriminator
  field; (b) a module-level docstring asserting "no LLM call paths populate this field";
  (c) an explicit `# I-S1-1: deterministic echo of <fn>(...)` inline comment naming the
  upstream computation.
- A dedicated hook at `scripts/hooks/numeric-field-discipline-check.sh` (planned; not
  authored by this proposal) lints these constraints.

**At runtime** (validator + verifier agent):
- Application-layer use cases that invoke an LLM and consume a numeric output field
  validate the LLM-echoed value against the upstream deterministic-pipeline computation.
  The validator is `EchoValidator.validate(llm_value, deterministic_value,
  tolerance=...)`.
- The verifier agent randomly samples 5% of new event records where a numeric field
  participates in an LLM call site, for human review queue (parallels Rule 6's existing
  5%-sampling enforcement).

**At amendment time**:
- Adding a new numeric field to any schema in scope (above) requires the change-author
  to specify which of the 4 satisfaction modes (categorical, deterministic-echo,
  calibration, null) applies, recorded in the field docstring. A constitution
  amendment for this Rule 16 is required to introduce a new satisfaction mode.

### Fields explicitly subject to this rule (initial inventory, non-exhaustive)

- `packages/contracts/events/kol_recommendation_extracted.py`
  `KolRecommendationExtracted.confidence_extracted: float` (existing per
  `agent-workspace/constitution/architecture.md:300`) — satisfies via mode 3 (calibration
  lookup) once BC-6 KOL extractor wires to `agent-workspace/calibration/` per Rule 9 +
  I-S20.
- Future BC-8 output schemas to be created by Phase F-prime (Theme H IMPL per Wave-1
  master plan § 6.4.3): the equivalent of `ResearchPlan` / `TraderProposal` /
  `PortfolioDecision` (TradingAgents source schemas at `tradingagents/agents/schemas.py`)
  — schemas MUST ban `entry_price` + `price_target` LLM-emit per
  `INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md § H.3` mitigation #4, or substitute mode
  2 (deterministic-pipeline echo) via BC-2 DCF / multiple-derivation pipeline once that
  pipeline lands.

### Cross-references

- Charter Principle 9 ("No LLM math") — parent principle this rule operationalizes.
- Charter Principle 8 ("Calibration over confidence") — provides the calibration-database
  satisfaction mode (#3 above).
- I-S1 ("No LLM Math") — sibling general-form invariant in
  `invariants-stockforge.md`.
- I-S7 ("Confidence ≠ Hit Rate") — sibling semantic invariant; Rule 16 enforces I-S7 at
  the schema layer.
- Rule 6 ("LLM Output Provenance") — sibling rule in this same file; Rule 16 extends
  Rule 6 to numeric-field semantics specifically.
- Rule 7 ("Sentiment Score Calibration") — precedent for categorical surrogate
  pattern (mode #1).
- Rule 9 ("KOL Recommendation Provenance") — already requires
  `extraction_confidence` field semantically; Rule 16 enforces the deterministic
  source for that confidence.
```

### 4.2 Companion edit — `invariants-stockforge.md`

Insert after the existing I-S1 block (currently lines 13-27), before I-S2 (line 29):

```markdown
### I-S1-1: Numeric-Field Discipline (sub-rule of I-S1; D-NNN-RATIFIED)
Numeric-typed schema fields (int, float, Decimal, numpy.number, or numeric-parameterized
containers) consumed by LLM call sites must satisfy one of: (1) categorical surrogate via
Enum/Literal, (2) deterministic-pipeline echo with EchoValidator, (3) calibration-database
lookup keyed on (extractor_version, signal_type), or (4) Optional[T] = None surrogate.
LLM-emitted numeric values without satisfaction mode are CRITICAL violations.
Enforcement: `financial-data-protocol.md` Rule 16 (full text) + mypy/ruff/hook (planned).
```

### 4.3 Companion edit — `financial-data-protocol.md` Quick Reference Table (line 261-274)

Append a new row before the "When This Protocol Conflicts" section:

```markdown
| LLM emitting numeric field | I-S1-1, Rule 16 | EchoValidator + schema-discriminator hook |
```

### 4.4 Companion edit — `financial-data-protocol.md` last-modified footer (line 356-357)

Append:

```markdown
Amended 2026-05-NN: Rule 16 (D-NNN I-S1-1 numeric-field discipline; Phase C of Wave-1
research integration; source D-061 § Decision item 6).
```

**Total LOC introduced (estimated)**: ~70 LOC into `financial-data-protocol.md` + ~7
LOC into `invariants-stockforge.md` = **~77 LOC**.

---

## § 5. Cool-Down + Version-Bump Bookkeeping

**Path B (recommended) — no cool-down ceremony required.**

`financial-data-protocol.md` is constitution-tier, not charter-tier. CLAUDE.md hard rule:
"Never modify files in `agent-workspace/constitution/` without explicit human approval."
The gate is human-explicit-approve, NOT the 48-hour Charter Revision Protocol. Precedent:
D-019 (Rule 11 hook portability), D-021 (Rules 12-15 VN-domain additions) — both added
rules to this exact file without invoking charter cool-down.

**Path A counterfactual — cool-down required.**

If the human picks Path A, per `PROJECT_CHARTER.md` Revision Protocol (line 219-224):
- "Written rationale with evidence (linked to specific sessions/post-mortems)" — this
  proposal + § 1 source-citation chain + D-061 § Decision item 5 supplies this.
- "48-hour cool-down before committing change" — clock starts the moment human RATIFIES
  the path (out-of-band gate). If ratified 2026-05-16T08:00 SEAST, the earliest commit
  window is 2026-05-18T08:00 SEAST.
- "Explicit version bump (v1.0 → v2.0)" — note the charter's literal text says v1.0 → v2.0
  but D-056 precedent established v1.0 → v1.1 as acceptable; the version-bump rule is
  flexible. For this amendment, **v1.1 → v1.2** is the natural increment (minor revision,
  not a complete re-baseline).

**Path A version-bump metadata changes (if picked)**:
- `PROJECT_CHARTER.md` line 4: `Immutable v1.1 — changes require explicit charter
  revision.` → `Immutable v1.2 — changes require explicit charter revision.`
- `PROJECT_CHARTER.md` line 5: `Revision history: v1.0 → v1.1 (2026-05-12, D-056): Added
  Principle 11 ...` → append `v1.1 → v1.2 (2026-05-NN, D-NNN): Added Principle 9.1
  (Numeric-Field Discipline; I-S1-1).` (or P12 if the human prefers a top-level
  principle insertion rather than a sub-principle).
- `agent-workspace/memory/.charter-md5-baseline` md5sum re-baseline (mirroring D-056
  process).

**For both paths**: a new ADR (D-065 candidate, next-available number) records the
ratification + acceptance + verification chain, following the D-056 + D-021 templates.

---

## § 6. What could go wrong — risks per path (adversarial framing)

(Per CLAUDE.md "Adversarial by default" — every recommended path has a "what could go
wrong" subsection.)

### Path B — recommended (constitution write)

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Path B is less visible than charter — future agent misses Rule 16 | LOW | MEDIUM (only matters when designing new BC-6/BC-8 schemas) | (a) Companion edit to `invariants-stockforge.md` ensures I-S1-1 appears in the invariant index every agent loads on demand; (b) the hook at `scripts/hooks/numeric-field-discipline-check.sh` (planned, separate IMPL session) becomes the deterministic catch-all even if the rule is forgotten. |
| Constitution write rejected at human gate | LOW | LOW (proposal lingers; no progress lost) | Out-of-band ratification UI per S336 + clear ratification options A/B/C/D in AskUserQuestion |
| Companion edit to `invariants-stockforge.md` forgotten | MEDIUM | LOW | Plan-019 § DoD explicitly lists both edits as required DoD items; sandwich-verifier checklist V4 catches if either is missing |
| Rule 16 conflicts with existing fields (e.g. `confidence_extracted` already exists per architecture.md:300) | LOW (architecture.md is contract, not enforcement) | MEDIUM | Rule 16 § "Fields explicitly subject to this rule" carries explicit transitional row for `KolRecommendationExtracted.confidence_extracted` deferring enforcement until BC-6 wires calibration; no in-flight code breaks |
| `EchoValidator` does not yet exist | HIGH (the validator class is planned, not implemented) | LOW (Rule 16 binds the contract; IMPL is downstream) | Rule 16 is a CONTRACT rule, not an IMPL spec; the validator's first IMPL site is Phase F-prime Theme H (per § 2 inventory row 4) which sequences naturally per master plan § 6.4 |

### Path A — adversarial alternate (charter v1.1 → v1.2)

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| 48h cool-down delays Phase F-prime IMPL | HIGH | MEDIUM (Phase F-prime is mid-Wave-1 critical path per master plan § 6.4.3) | Phase D-K Theme L IMPL can proceed in parallel (no Theme G dependency) — but Phase F-prime Theme H IMPL is blocked |
| D-047-style false-claim risk: charter file says v1.2 but content was not actually inserted (per D-056 § Analysis of D-047) | LOW (the D-056 audit established the verification protocol) | HIGH (charter coherence corruption) | Same temp-deny-lift + md5-rebaseline pattern that D-056 used |
| Cognitive load on every agent loading charter | LOW | LOW | Charter is small (260 lines today); 1 new sub-principle is marginal |
| Wrong specificity tier — over-amendment of a small file dilutes signal | MEDIUM | LOW | Architect counter-recommendation = Path B for this reason; this risk is the strongest argument against Path A |

### Path C — REJECT (architect counter-recommends; do not pick)

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Phase A evidence discarded | CERTAIN | HIGH (anti-pattern per Charter Principle 8 "calibration over confidence" — discards file:line empirical data in favor of opinion) | DO NOT PICK |
| Phase F-prime Theme H IMPL schemas inherit `entry_price` / `price_target` LLM-emit fields with no schema-level guard | CERTAIN | HIGH (direct I-S1 violation surface; Phase A documented anti-pattern goes live) | DO NOT PICK |
| AP-23 retire-without-evidence | CERTAIN | MEDIUM (charter rule violation; rule retired without empirical retire-trigger) | DO NOT PICK |

### Path D — RE-ARCHITECT

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Burns S335 budget for re-PLAN | CERTAIN | MEDIUM | Only pick if the human believes the scope of I-S1-1 is wrong (not just the file home) |
| defer_cycles inflate past R7 threshold | LOW (this would be the first defer cycle for D-061 § Decision item 6) | LOW | Tracked in next ADR |

---

## § 7. Source-Evidence References

Every claim in this proposal traces to one of:

1. `agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md`
   - § 5.2 (Theme G intent + sub-rule hypothesis)
   - § 6.3 (Phase C charter/constitution decision)
   - § 7.8 (AP-23 red-flag refinement-of-rule check)
   - § 8 Q-INT-2026-05-3 (original ratification question)

2. `agent-workspace/memory/decisions/061-wave-1-integration-ratification.md`
   - § Decision item 5 (I-S1-1 GENUINE-new CONFIRMED)
   - § Decision item 6 (Theme G recommended path = constitution write)
   - § Open Questions Q-INT-2026-05-6 (ratification queued)

3. `agent-workspace/research/INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md`
   - § G.1 Theme G intent
   - § G.2 5-row empirical confidence-field survey
   - § G.3 final architectural recommendation (Path B)
   - § G.4 Phase C IMPL slot + Phase F-prime sequencing dependency
   - § G.5 charter-compliance check + AP-23 trigger

4. `agent-workspace/memory/observations/master-planner-A-{01,04,13,14,15}-deepdive-*.md`
   - A-01 (ai-hedge-fund) § 5 + § 7 R3 confidence-self-report anti-pattern
   - A-04 (FinceptTerminal) § 7.3 NotifLevel enum counterexample
   - A-13 (TradingAgents) § 7.4 `entry_price`/`price_target` audit point
   - A-14 (TradingAgents-CN) § 3.10 + § 7.5 "强制要求提供具体数值" anti-pattern
   - A-15 (Vibe-Trading) § 3 C5 deterministic `confidence=low` counterexample

5. `human-workspace/q-and-a/answered/qa-2026-05-15-wave-1-bis.md` (D-061 ratification record)
   - line 32: `Q-INT-2026-05-6: A (constitution write in agent-workspace/constitution/financial-data-protocol.md extension; Phase C S333 PLAN + S334 human-approve gate)`

6. `PROJECT_CHARTER.md`
   - line 73 Principle 9 (parent principle this rule operationalizes)
   - line 71 Principle 8 (parent principle providing the calibration-mode satisfaction)
   - line 219-224 Revision Protocol (Path A cool-down + version-bump source)

7. `agent-workspace/constitution/invariants-stockforge.md`
   - line 13-27 I-S1 (parent invariant for the I-S1-1 alias)
   - line 49-51 I-S7 (sibling semantic invariant)

8. `agent-workspace/constitution/financial-data-protocol.md`
   - line 134-156 Rule 6 LLM Output Provenance (sibling rule extending I-S1)
   - line 168-181 Rule 7 Sentiment Score Calibration (categorical-surrogate precedent)
   - line 208-231 Rule 9 KOL Recommendation Provenance (confidence_extracted field precedent)
   - line 289-305 Rule 11 + line 309+ Rules 12-15 (D-019 + D-021 — precedent for
     "constitution rule add" landing without charter ceremony)

9. `agent-workspace/memory/decisions/056-S253-charter-v1.1-principle-11-ratified.md`
   - frontmatter + § Acceptance Record (charter v1.0 → v1.1 precedent — the only prior
     charter amendment; cited for Path A counterfactual)

10. `agent-workspace/CLAUDE.md`
    - Contract Rule 1 ("Constitution is immutable absent explicit human approval")
    - Reading Priority for Agent + Anti-Patterns Section

11. `CLAUDE.md` (root)
    - § Hard Rules: "Never modify PROJECT_CHARTER.md / constitution without explicit human
      approval" + AP-23 ritual demotion clause

---

## § 8. Compliance Attestation (this proposal)

- ✅ no production code authored (markdown only)
- ✅ no direct charter or constitution edits (proposal lives in
  `agent-workspace/proposals/`; literal text in § 4 is candidate text awaiting
  human-explicit-approve, not applied)
- ✅ no commits (no Bash tool granted to sandwich-architect)
- ✅ no human-workspace writes (proposal lives in `agent-workspace/proposals/`; main
  S335 fires AskUserQuestion for the out-of-band gate)
- ✅ every substantive claim cites file:line per I-S2 (see § 7)
- ✅ adversarial framing — every recommended path has "what could go wrong" subsection (§ 6)
- ✅ no LLM math — severity/likelihood claims are categorical (CRITICAL/HIGH/MEDIUM/LOW),
  not LLM-emitted floats
- ✅ research-aid framing preserved (I-S35) — no "buy/sell/recommendation" language
- ✅ honors D-061 Q-INT-2026-05-6=A ratification (Path B recommended)
- ✅ AP-23 promote-or-retire trigger satisfied via dedicated-rule promotion (Path B
  satisfies "promote"; not inline accumulation)

---

## § 9. Out-of-band Ratification Gate

This proposal is **NOT** self-executing. Per CLAUDE.md hard rule, the constitution
write target (path B) requires explicit human approval before any edit lands in
`agent-workspace/constitution/`. The S335 main session fires an `AskUserQuestion` call
(CHARTER-tier allowed per AskUserQuestion-is-for-SCOPE/CHARTER memory rule) with these
options:

- **A** — CHARTER amendment v1.1 → v1.2 (Path A; ≥48h cool-down)
- **B** — CONSTITUTION write in `financial-data-protocol.md` (Path B; **architect-recommended,
  honors D-061 prior ratification**)
- **C** — REJECT (Path C; architect counter-recommends NOT picking)
- **D** — RE-ARCHITECT with refined scope (Path D)

**On user pick**:
- Pick A → human-only edit to `PROJECT_CHARTER.md` after 48h cool-down (agent cannot
  perform charter edits without same-session temp-deny-lift, per D-056 precedent).
- Pick B → main session dispatches a follow-up FOCUSED_IMPL session to perform the
  literal edit per § 4 text, with same-session temp-deny-lift on `agent-workspace/constitution/`
  (mirroring D-056 process). New ADR D-NNN (next-available number, candidate D-065)
  records ratification + acceptance.
- Pick C → close Phase C as "Theme G unnecessary"; skip to Phase D-K Theme L IMPL. Update
  D-061 § Decision item 5 with the retire-instead-of-promote outcome + supersession note.
- Pick D → main re-dispatches sandwich-architect with refined scope from user comment.

End of `theme-g-i-s1-1-amendment-2026-05-16.md` proposal.
