---
name: decompose-work
description: Split a non-trivial task into deterministic-vs-LLM portions before execution. Use when planning multi-step work where some sub-tasks are mechanical (file ops, regex, count, schema validation) and others require judgment (synthesis, design, ambiguity resolution). Outputs structured plan that maps each portion to the cheapest competent tool. Pairs with capability-map.md (model × effort × task_class grounding) and try-n-approaches (S9 — Karpathy autoresearch loop).
allowed-tools: [Read, Glob, Grep, Bash]
---

# Skill: decompose-work

## Purpose

Karpathy autoresearch loop foundation: BEFORE doing a task, **classify sub-parts as deterministic (cheap, cacheable, verifiable) vs LLM-required (judgment, ambiguous, generative)**. Mechanical work goes to scripts; LLM cycles go to where judgment is irreducible. Avoids the two failure modes: (a) burning LLM tokens on `wc -l` style work that bash does for free, (b) hand-coding logic that should be a one-paragraph judgment call.

Per UP-06 §3 verbatim: *"cần phải có một skill hoặc agent với khả năng chuyên biệt giúp nó 'bóc tách' được ra thế nào là 'deterministic' và thế nào là 'llm probability'"*.

## When to Use

- Task has ≥3 distinct sub-parts
- Some sub-parts smell mechanical, others smell judgment-heavy
- Estimated context cost ≥30K if done naively LLM-only
- About to dispatch subagent — knowing the deterministic floor saves token budget
- Authoring a new skill or hook — decomposition surfaces what belongs in the script vs prompt

## Pre-Flight Checklist (per L-S30-1; APPLIED 4× S30/S31/S33/S34/S35)

Before authoring any deliverable list (PLAN session) OR before writing files claimed by a master-plan (IMPL session), run VBW pre-flight:

1. **Glob the claimed paths** — every path mentioned in deliverables; surface mismatches.
2. **Read the file** if expected to be modified; do not trust stale master-plan claims about file contents.
3. **`ls` target directories** — surface starter-kit files (e.g., SEED.md, _template.md) that may already satisfy deliverable purpose.
4. **Document mismatch** as IMPL-S{N}-* deviation rather than fabricating; absorb-or-replace decision is IMPL-tier per L-S11-2.

This is NOT optional for PLAN-tier deliverables; master-plans accumulate path-drift between authoring and IMPL. S30 caught `eval-sets/labeled-pumps/seed.md` nonexistent → ratified existing SEED.md instead. S33 caught `value_objects/` directory absence vs master-plan stale claim. S31 master-planner subagent applied this protocol successfully for 9 proposals + `apps/dashboard/` absence verification. The skill is binding when L-S30-1 applies.

## When NOT to Use

- Task is trivial (≤2 steps, single tool call)
- Task is purely deterministic (just run the script directly)
- Task is purely judgment-only with no measurable outputs (e.g., "draft this paragraph" — LLM end-to-end)
- Already mid-execution and re-decomposing would just be ceremonious

## Inputs

| Arg | Required | Purpose |
|---|---|---|
| `task_description` | yes | Free-form text describing the goal |
| `--budget` | no | Approximate token budget (helps prioritize deterministic offload) |
| `--depth` | no | `shallow` (3-5 portions) \| `deep` (full sub-tree). Default shallow. |

## Process

1. **Parse task** — list candidate sub-parts. Quote verbatim phrases from `task_description`. Don't paraphrase yet — paraphrase loses signal.
2. **Read `agent-workspace/memory/capability-map.md`** if exists — note which cells (model × effort × task_class) match this task's flavor. If map empty/missing, proceed without grounding (note in output).
3. **Classify each sub-part** per `references/classification-heuristics.md`:
   - **DETERMINISTIC** if: file-search/glob, line/byte/match count, regex extract, JSON/YAML parse, schema validate, format conversion, deterministic transformation, hash, sort, dedupe, binary diff
   - **LLM-REQUIRED** if: synthesis across sources, design/naming, ambiguity arbitration, free-text generation, judgment under uncertainty, calibration interpretation, multi-perspective adversarial reasoning
   - **HYBRID** if: deterministic skeleton + LLM interpretation step, OR LLM drives deterministic tool use, OR threshold-based escalation (e.g., "auto-classify if confidence ≥0.8 else escalate to LLM")
4. **For each portion, propose the cheapest competent tool**:
   - Deterministic → bash/grep/awk/node oneliner, hook script, or existing tool (Glob, Grep, Bash, Read)
   - LLM → main session, subagent (specify which: opus/sonnet/haiku, fresh-ctx?), or skill
   - Hybrid → deterministic gate + escalation path
5. **Build integration plan** — sequence + data flow + escalation rules. Where does deterministic output feed LLM input? Where does LLM decision drive deterministic action? Where's the failure escape?
6. **Surface risks** — what if classification is wrong? What if LLM portion exceeds budget? What's the fallback if deterministic step fails?
7. **Output structured result** per `references/output-template.md`:
   ```
   ## Decomposition: <task name>
   ### Deterministic portions (N)
   - [D-1] sub-task → tool → expected output
   ### LLM-required portions (N)
   - [L-1] sub-task → agent/skill → why LLM needed
   ### Hybrid portions (N)
   - [H-1] sub-task → gate + escalation
   ### Integration plan
   1. ... 2. ... 3. ...
   ### Risks + fallbacks
   - ...
   ### Capability-map grounding
   - cells consulted: ... | gaps: ...
   ```

## Validation Pre-Conditions

- `task_description` is non-empty + ≥1 sentence
- Skill output has ≥1 deterministic portion (if everything LLM, the skill isn't earning its keep — recommend skipping)
- Integration plan covers ALL portions (no orphan sub-tasks)

## Anti-Patterns

- **Treating "code generation" as fully deterministic** — design naming + interface choice is LLM. Only the resulting build/lint/test step is deterministic.
- **Over-decomposing trivial tasks** — `cat foo` doesn't need this skill.
- **Skipping integration plan** — listing parts without sequencing them is half a deliverable.
- **Ignoring capability-map** — historical cells encode "where LLM has hit limits"; skipping them re-discovers those limits the hard way.
- **Confusing "LLM-required" with "complex"** — a simple-feeling task with ambiguity (e.g., "rename this thing well") is LLM-required even if short.
- **Decomposing AFTER execution** — that's a postmortem, not a decomposer; this skill is pre-execution.

## Smoke Test (S8 first run)

Sample task: *"Author Track 5.5c.6 promote-rule skill that scans agent-notes for clusterable rules and proposes promotion to hook/skill/charter."*

Expected decomposition (target):
- Deterministic: read agent-notes.md (Read), regex-extract rule headers (Grep), token-similarity heuristic (bash + node), output proposal markdown (Write)
- LLM-required: cluster naming, promotion-target choice (hook vs skill vs charter), prevention-rule rephrasing
- Hybrid: similarity threshold gate (deterministic) → if cluster ≥3, LLM evaluates whether promotion is warranted

If smoke test produces this rough shape, skill is functional.

## See Also

- `agent-workspace/memory/capability-map.md` — model × effort × task_class living grounding
- `.claude/skills/promote-rule/SKILL.md` — sibling 5.5c.6 deliverable that consumes decomposition output
- `.claude/skills/try-n-approaches/SKILL.md` — S9 Karpathy autoresearch full
- D-003 § 5.5c.1 — strategic rationale + UP-06 §3 directive
- `references/classification-heuristics.md` — full decision rules
- `references/output-template.md` — structured output shape
