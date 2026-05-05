---
schema_version: 1
created_at: 2026-04-29
updated_at: 2026-04-29 (S12 — tool-survey task class added provisionally)
description: |
  Living document tracking observed LLM capabilities and limits across model × effort × task_class.
  Read by `decompose-work` skill at decomposition time. Updated via `promote-rule` skill clusters.
  Source-grounded — every cell cites a concrete observation (agent-notes entry, charter invariant,
  drift-log finding, or post-mortem).
source_decision: agent-workspace/memory/decisions/003-up06-track-5.5-sync-layer-selfcap.md
source_intent: human-workspace/user_prompt/20260429_06.txt §3
related_skills:
  - .claude/skills/decompose-work/SKILL.md  (consumer)
  - .claude/skills/promote-rule/SKILL.md     (writer)
  - .claude/skills/try-n-approaches/SKILL.md  (S9 — consumer)
---

# Capability Map

> Sparse cells. Append-only by default; cells may transition state with annotation.
> Per UP-06 §3: "skill hoặc agent với khả năng chuyên biệt giúp 'bóc tách' deterministic vs llm probability".
> This map IS the grounding for that decomposition.

## Dimensions

```yaml
model:      [opus-4.7, sonnet-4.6, haiku-4.5, any]   # "any" = model-agnostic (charter / architectural)
effort:     [low, medium, high, xhigh, max, any]
task_class: <see below; appended as new task types observed>
```

## Task Classes (current vocabulary)

- **math** — numerical computation
- **synthesis** — multi-source narrative summary
- **design** — architecture / interface choice
- **naming** — short identifier creation (variables, files, clusters)
- **extraction** — claim extraction from unstructured text
- **classification** — fuzzy categorization (sentiment, drift severity, intent)
- **calibration** — confidence claim with hit-rate trace
- **adversarial** — bear/critic/devil's-advocate perspective
- **verification** — checking measurable properties against claims
- **qa-composition** — Q&A bundle authoring (incl. charter-tier split)
- **qa-input-channel** — surfacing questions through right surface (ask vs file)
- **intent-classification** — routing user prompts to actions
- **session-bootstrap** — SessionStart hook + first-prompt processing
- **bash-scripting** — shell scripts (hooks, automation)
- **adr-authoring** — decision records with provenance + delta summary
- **thesis-output** — stockforge thesis with bull/bear/calibration
- **data-reconciliation** — multi-source numeric divergence
- **tool-survey** _(provisional, S12 first instance)_ — opensource-repo fitness scan with provenance + adversarial bear case + license capture; produced via `.claude/agents/research-scanner.md` dispatch. Strength/limit rows deferred until ≥3 instances per promotion threshold.

---

## Strengths Observed

| # | model | effort | task_class | observation | source |
|---|---|---|---|---|---|
| 1 | opus-4.7 | high | design | Multi-mechanism ensemble design (4-mechanism sync infra in 1 plan) lands well. Trade-off matrices natural. | agent-notes 2026-04-29 D-003 R1+R2 + sessions/S6+S7 |
| 2 | opus-4.7 | high | adversarial | Bear-case generation per thesis is reliable when prompted explicitly with `≥3 distinct points`. | agent-notes 2026-04-23 § Bear Case Required |
| 3 | opus-4.7 | medium | adr-authoring | 12-field schema ADR with provenance citations consistently produced when template provided. | sessions/S2..S7 D-001..D-004 |
| 4 | sonnet-4.6 | medium | extraction | Vietnamese KOL transcript claim extraction with structured JSON output is reliable when prompt enforces source_url + extracted_at fields. | evidence-extraction skill (planned Phase 2) + charter Tier 3 |
| 5 | sonnet-4.6 | low | intent-classification | Trivial-prompt detection ("ok continue", "yes proceed") cheap + accurate via lite-detect patterns. | agent-notes 2026-04-29 § ok continue idiom + lite-detect-patterns.md |
| 6 | haiku-4.5 | low | naming | Short identifier naming (cluster titles, variable names) acceptable when context narrowly scoped. | inferred — used for promote-rule cluster naming step |
| 7 | any | any | qa-composition | Bundle skeleton with `defer_cycle: 0` field at creation prevents stale-bundle drift. | agent-notes 2026-04-29 § Q&A Bundle Skeleton |

---

## Limits Observed

| # | model | effort | task_class | observation | source |
|---|---|---|---|---|---|
| L-1 | any | any | math | NO-LLM-math invariant absolute (I-S1). LLM never outputs numbers it computed. | charter principle 9 + agent-notes 2026-04-23 § LLM Never Outputs Numbers |
| L-2 | any | any | calibration | "X% confidence" without n_samples + lookback = drift. Confidence MUST trace to historical hit rate. | charter principle 8 + agent-notes 2026-04-23 § Confidence Requires Calibration Data |
| L-3 | opus-4.7 | high | verification | False self-attestation on measurable properties (LOC, byte count, presence). Must use `wc -l`, `Glob`, `Grep` to verify; never estimate from memory. | agent-notes 2026-04-29 § AP-S2-3 + S2 drift audit |
| L-4 | opus-4.7 | high | adversarial | Same-agent self-review = echo chamber (AP-1). Always dispatch fresh-context Verifier. | patterns-discovered AP-1 + sandwich pattern doctrine |
| L-5 | any | any | qa-input-channel | File-only Q&A with default-after-N-hours = silent absorption. AskUserQuestion is the PRIMARY channel; file = audit only. | UP-04 + UP-06 + agent-notes 2026-04-29 § NO Silent File-Defaults |
| L-6 | any | any | qa-composition | Charter-tier questions in mixed-tier bundles get absorbed via "ok continue" → drift. Charter-tier MUST split into dedicated bundle. | agent-notes 2026-04-29 § Charter-Tier Items + post-audit G1 |
| L-7 | any | any | session-bootstrap | Stale-prompt references (UP-N closed work) without deterministic detection block autonomous flow. Hook-based detection is the only viable Guardian. | agent-notes 2026-04-29 § Stale-Prompt Reference Check + mistake-log M-S7-1 |
| L-8 | opus-4.7 | high | adr-authoring | REV-N with ≥10 amendments OR ≥25% budget delta needs explicit "Delta Summary" headline; otherwise user absorbs without seeing magnitude. | agent-notes 2026-04-29 § Pre-Amendment Delta Summary |
| L-9 | any | any | bash-scripting | `grep -c \|\| echo 0` pattern double-counts zero on no-match. Use `\|\| true` + regex validate instead. | agent-notes 2026-04-29 S3 § grep -c |
| L-10 | any | any | data-reconciliation | Multi-source numeric divergence (vnstock vs FiinPro) silently averaged = drift. Output divergence explicitly with provenance. | agent-notes 2026-04-23 § Source Provider Disagreement |
| L-11 | any | any | thesis-output | Single-perspective thesis = anti-pattern. Bear case ≥3 distinct points mandatory; refuse render without it. | charter principle 3 + agent-notes 2026-04-23 § Bear Case Required |
| L-12 | any | any | session-bootstrap | Continue-injector unconditional in SUPERVISED = race condition with user typing. MUST gate by autonomous_mode flag. | agent-notes 2026-04-29 § Continue-Injector Gated + mistake-log M-S7-1 L2 |

---

## Heuristics for Decompose-Work (consumer)

When `decompose-work` skill classifies a sub-task:

1. **Cite this map**: which strength row supports "do via LLM"? Which limit row forces "do deterministic"?
2. **Default to deterministic on conflict**: if a row is in *both* strengths AND limits → safer to assume LIMIT (under-promise).
3. **Map gap → propose entry**: if task_class is novel (not in vocabulary above), add tentative entry post-execution + flag `provisional: true`.
4. **Effort-tier matters**: a task_class strength at `effort=max` may be a limit at `effort=low`. Default to medium if unsure.

## Promotion Path (writer = promote-rule skill)

When `promote-rule` clusters agent-notes:
- Cluster naming → adds new task_class to vocabulary (if novel)
- Cluster of ≥3 limits with same task_class → likely capability-map limit row
- Cluster of ≥3 strengths with same model+effort+task_class → strength row
- Single-occurrence observations → DO NOT add to map (one-off, may not generalize)

## Update Protocol

- **From agent-notes via promote-rule** (S8+): `promote-rule` skill scans agent-notes; clusters of ≥3 → proposes capability-map entry. Agent reviews + writes.
- **From drift-log**: new limit observed → append to Limits Observed with source citation.
- **From thesis post-mortem** (Phase 1+): observed strength/limit per stock-domain task_class → append.
- **State transition**: if a previously-strength row becomes a limit (regression), mark old row `superseded-by: row-N` and add new row.

## Anti-Patterns

- Adding capability-map entries from speculation, not observation. Every cell cites a source.
- Single-occurrence "X failed once" → not a limit yet. Wait for ≥3 instances.
- Generalizing model-specific findings to `any` → keep model-tagged unless invariant.
- Skipping `effort` dimension → "opus is good at design" without effort tier loses signal.
- Treating limits as permanent → revisit on model upgrade (Opus 4.7 → 4.8 → 5.0 may invalidate).

## Notes

- Counts: 7 strengths + 12 limits = 19 total entries (≥10 S8 target ✓).
- Skill capability claim is a future state — try-n-approaches skill (S9) will explicitly track approach×model×task_class outcomes; that data flows here.
- For stockforge stock-domain task classes (thesis synthesis, KOL extraction, pump detection) — most cells assumed-aligned until Phase 1+ dogfood data accumulates.
