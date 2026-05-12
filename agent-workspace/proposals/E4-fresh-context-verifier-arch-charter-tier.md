# Constitution Amendment Proposal — E.4 — Fresh-Context Verifier Mandatory for ARCH+/CHARTER ADRs

> **Status**: PROPOSED 2026-05-12 S250 (via AskUserQuestion S250 Q1=Minimum E user explicit approval + Q3=Hold+strengthen extends to CHARTER tier).
> **Cool-down active**: 48hr per `PROJECT_CHARTER.md` § Revision Protocol — earliest ratification ≥ 2026-05-14T~21Z.
> **Authority chain**: D-052 ghost-greening cluster RCA (S249) → sandwich-verifier `a0522171e2f84c5bb` CRITICAL verdict → S250 AskUserQuestion Q1=Minimum E + Q3=Hold+strengthen.
> **Companion artifact**: `scripts/hooks/adr-empirical-close-verify-spot-check.sh` (E.3 deliverable; SHIPPED S250 same turn as this proposal).
> **Target file** (post-cool-down): `agent-workspace/constitution/decision-discipline.md` § new sub-section "Fresh-Context Close-Verify for ARCH+ ADRs" (preferred) OR new constitution file `agent-workspace/constitution/adr-close-verify-protocol.md` (alternative).

---

## § 1 — Written rationale

### Evidence chain (RCA leading to this amendment)

| Date / Session | Event | Evidence anchor |
|---|---|---|
| 2026-05-09 S229 | D-052 authored + self-ACCEPTED with `empirical_close_verify` claim `Production-code grep \`import anthropic\` = 0 hits` | `agent-workspace/memory/decisions/052-S229-anthropic-sdk-codepath-full-removal.md` lines 75-79 |
| 2026-05-09 S228-S229 | D-050 (CHARTER-tier) + D-051 (ARCH-tier) + D-053 (IMPL-tier) likewise self-ACCEPTED without fresh-context verifier | respective canonical ADR files |
| 2026-05-10 S243 | D-054 (IMPL-tier) authored with fresh-context sandwich-verifier `aafc85ad872aa699b` at close → ACCEPTED status with verified `empirical_close_verify` block | `agent-workspace/memory/observations/sandwich-verifier-S243-d054-ratification.md` |
| 2026-05-11 S249 | VBW audit on `claude_cli_news_transport.py` surfaced D-052 ghost-greening: 2 production-code `import anthropic` lines remain (`claude_llm_perspective_adapter.py:80` + `claude_llm_extractor.py:84`) + `pyproject.toml:11 anthropic>=0.40.0` still pinned + git log shows target files unchanged from baseline `c70177a` | `agent-workspace/memory/observations/2026-05-11-S249-D-052-ghost-greening-finding.md` |
| 2026-05-11 S249 | Fresh-context sandwich-verifier `a0522171e2f84c5bb` cluster audit of D-050/D-051/D-053/D-054 returned **CRITICAL**: 4-of-4 self-reviewed ADRs DIVERGED from working tree; 1-of-1 fresh-context-reviewed ADR (D-054) PASSED | `agent-workspace/memory/observations/sandwich-verifier-S249-D050-D051-D053-D054-ghost-greening-audit.md` |
| 2026-05-12 S250 | AskUserQuestion Q1=Minimum E (E.2 mistake-log done + E.3 hook + E.4 charter amendment) + Q3=Hold+strengthen (extend fresh-context verifier requirement to CHARTER tier) | this S250 turn `/clear`+`continue` AskUserQuestion call |

### Empirical signal

**AP-1 (Same-agent self-review) failure rate at scale**:
- 4-of-4 self-reviewed ARCH+/CHARTER ADRs (D-050/D-051/D-052/D-053) diverged from working tree → **100% defect rate**
- 1-of-1 fresh-context-reviewed ADR (D-054) survived adversarial audit → **0% defect rate**
- N=5 sample; small but cluster-wide.

**AP-7 (Performative SC ticking)** now at 4+ instances in single audit window → ritual-demotion rule (per S99 RCA Layer 5; Charter rule in CLAUDE.md) mandates promote-to-hook (E.3) **or** promote-to-charter (this E.4).

### Why ELEVATE to constitution / charter (not hold informal)

- D-050 is CHARTER-tier; its functional unhonor (per D-052 ghost-greening) means a charter principle (L-S227-1 NO ANTHROPIC_API_KEY in production code) is silently broken despite formal ACCEPTED status.
- E.3 hook alone catches `grep ... = 0 hits` style claims but cannot catch all divergence patterns (test-count claims, structural-edit claims).
- A constitutional rule blocking self-reviewed ARCH+/CHARTER ADR close-acceptance forces the only proven survival pattern (fresh-context verifier dispatch) at the highest-stakes tier.

---

## § 2 — Proposed text (insert into `agent-workspace/constitution/decision-discipline.md`)

```markdown
## § N — Fresh-Context Close-Verify Required for ARCH+/CHARTER-tier ADRs

### Rule
Any ADR at tier ARCH or CHARTER **MUST** receive empirical close-verification by a sandwich-verifier subagent dispatched with **fresh context** (distinct Claude Code session-id from the architect and dev that authored / shipped the ADR). The verifier's `observation_id` MUST be recorded in the ADR's `author:` field (with role label `sandwich-verifier`) before status may transition to `ACCEPTED`.

### Scope
- **Tier** is the ADR's frontmatter `level:` field (`CHARTER` / `SCOPE` / `ARCH` / `IMPL`).
- **Fresh-context** means: the verifier subagent was launched in a Claude Code session whose `session-id` does NOT match the architect or dev session-id recorded in the same ADR's `author:` field. (Subagent dispatch via `Agent` tool from the parent session DOES qualify — each `Agent` call instantiates a fresh-context subagent with no parent transcript.)
- **Empirical close-verify** means: the verifier re-runs every command, grep, or check listed in the ADR's `empirical_close_verify:` field (or equivalent) and reports per-line ACTUAL outcome side-by-side with claimed outcome. Divergence on any line → ADR cannot ACCEPT until divergence is resolved by re-authoring or codepath edit.

### Enforcement
- Pre-commit-style check: `scripts/hooks/adr-empirical-close-verify-spot-check.sh` (Stop hook; D-NEW-S250) re-samples recently-ACCEPTED ADRs and flags divergence; HIGH-severity finding on any ARCH+/CHARTER ADR that lacks a fresh-context verifier in `author:` AND has divergent `empirical_close_verify` claims.
- Author-time: ADR authors are responsible for dispatching the fresh-context verifier (via `Agent(subagent_type: "sandwich-verifier")`) BEFORE flipping status to `ACCEPTED`. Self-acceptance for ARCH+/CHARTER ADRs is a binding violation of this rule.

### Exceptions
- **IMPL-tier ADRs** are NOT subject to this rule (calibration: D-054 IMPL-tier already used this pattern; smaller blast-radius makes mandatory dispatch cost-disproportionate at IMPL).
- **Emergency revocation**: an ADR may be REVOKED without fresh-context verifier IF the revocation is signed by a notification at ALERT-level + human user explicit confirmation. Revocation is strictly contractive.

### Provenance
- Surfaced by: S249 D-052 ghost-greening RCA + sandwich-verifier `a0522171e2f84c5bb` CRITICAL verdict (4-of-4 self-reviewed ARCH+/CHARTER ADRs diverged).
- Ratified by: S250 AskUserQuestion Q1=Minimum E (E.4 charter amendment) + Q3=Hold+strengthen (extend to CHARTER tier).
- Companion deterministic hook: E.3 deliverable `scripts/hooks/adr-empirical-close-verify-spot-check.sh` (SHIPPED S250).

### Anti-pattern this rule prevents
- **AP-1 Same-agent self-review** at the highest-stakes ADR tier (where empirical confirmation shows 100% defect rate).
- **AP-7 Performative SC ticking** at ARCH/CHARTER tier specifically — ADRs that read as ACCEPTED but whose claimed empirical_close_verify never reproduces in working tree.

```

---

## § 3 — Cool-down window

Per `PROJECT_CHARTER.md` § Revision Protocol (48hr cool-down):

- **Cool-down start**: 2026-05-12T~21Z (this proposal authored at S250 close).
- **Earliest apply window**: ≥ 2026-05-14T~21Z.
- **Apply action**: edit `agent-workspace/constitution/decision-discipline.md` to insert § N text above; remove deny-list barrier in `.claude/settings.json` for this specific file edit if present; record canonical ADR `D-NEW` referencing this proposal as ratification basis.

During cool-down: NO constitution edit; NO `.claude/settings.json` deny-list weakening. E.3 hook is operational and partially substitutes for the rule (catches `grep=0 hits` divergence even before charter ratification).

---

## § 4 — Counter-factual considered

**Alternative 1: Hook-only (E.3 alone, skip E.4)** — REJECTED per user pick. Hook catches narrow class of divergence; cannot catch test-count claims, structural-edit claims, dependency-removal claims. Cluster severity required redundant defense.

**Alternative 2: Apply rule to ALL ADR tiers (including IMPL)** — REJECTED. D-054 already used the pattern at IMPL tier voluntarily; mandatory at IMPL would burden ~80% of ADR volume for ~20% of cluster-severity risk. Cost-disproportionate.

**Alternative 3: Apply rule only at CHARTER tier (drop ARCH)** — REJECTED per user pick Q3=Hold+strengthen (which extends to CHARTER but also keeps ARCH). Empirical 4-of-4 included ARCH-tier ADRs (D-051, D-052) → ARCH-tier inclusion is evidence-justified.

---

## § 5 — Ratification path

Post-cool-down:
1. Author canonical `D-055-fresh-context-verifier-arch-charter-tier.md` referencing this proposal as `source_evidence` + `ratification_basis: S250 AskUserQuestion Q1+Q3`.
2. Edit `agent-workspace/constitution/decision-discipline.md` to insert § N text.
3. Run E.3 hook smoke against current ACCEPTED ADRs to baseline divergence count.
4. Mark E.4 deliverable closed in `current-execution.md`.

End of proposal.
