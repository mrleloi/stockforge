---
name: promote-rule
description: Cluster agent-notes.md entries by lexical similarity, propose promotion of recurring rules to deterministic hook (priority 1), skill (priority 2), or charter (priority 3). Use when agent-notes has accumulated ≥10 new rules since last promotion run, or on-demand at phase boundary. Outputs proposal markdown to observations/. Pairs with capability-map.md (writes new task_class entries) and decompose-work (consumes promotion outcomes).
allowed-tools: [Read, Glob, Grep, Bash, Write]
---

# Skill: promote-rule

## Purpose

Per Q-E3 (queued-grill-master closed): when an agent-notes rule recurs across ≥3 entries, it deserves promotion to a more durable artifact. Priority: **hook FIRST** (cheapest enforcement, deterministic guardian), **skill SECOND** (LLM-codified procedure), **charter LAST** (changes invariant, requires explicit human approval).

This skill formalizes that promotion path. Outputs PROPOSALS — never auto-promotes; human review required for charter-tier; agent may auto-implement hook/skill if confidence high.

## When to Use

- After ~10+ new rules added to `agent-workspace/memory/agent-notes.md` since last run
- At phase boundary (Phase 0 → Phase 1, etc.)
- When user explicitly invokes (e.g., end-of-week review)
- After significant drift event where existing rules clearly missed the case

## When NOT to Use

- Fewer than 5 rules accumulated → noise > signal
- Mid-implementation session → distraction; queue for end-of-session
- When charter is mid-revision (revision protocol takes precedence)
- Trivial single-occurrence observations → wait for cluster

## Inputs

| Arg | Required | Purpose |
|---|---|---|
| `--threshold` | no | Jaccard similarity cutoff. Default `0.7`. |
| `--min-cluster-size` | no | Minimum rules per cluster. Default `3`. |
| `--max-clusters-llm` | no | Cap LLM dispatch on top-N clusters by total similarity. Default `5`. |
| `--dry-run` | no | Phases 1-2 only (deterministic); skip LLM phase. |

## Process

1. **Read agent-notes** — `Read agent-workspace/memory/agent-notes.md`. Note last cluster header line.
2. **Extract rule headers** — `Grep -n "^### " agent-notes.md` → list of `(line_no, title)` pairs. Each pair anchors a rule.
3. **Extract rule bodies** — for each header, capture lines until next `###` or EOF. Store as map `{title → body}`.
4. **Tokenize bodies** — split on `/\W+/`, filter tokens length ≥4, lowercase, dedupe. Per `references/jaccard-helper.sh`.
5. **Compute Jaccard similarity matrix** — pairwise `|A∩B|/|A∪B|`. Output as JSON to `<temp>/sim-matrix.json`.
6. **Cluster (deterministic gate)** — connected-components over edges where `sim ≥ threshold`. Filter clusters where `size ≥ min-cluster-size`.
7. **STOP if `--dry-run`** — emit cluster summary + exit. Useful for tuning threshold.
8. **For each cluster (cap at `--max-clusters-llm`)**:
   - **Phase 3a (LLM-name)**: 1-3 word cluster title (sonnet, low effort).
   - **Phase 3b (LLM-target)**: choose promotion target per Q-E3 priority:
     - HOOK — rule encodes deterministic check (regex, count, schema validate)
     - SKILL — rule encodes procedure with judgment
     - CHARTER — rule encodes invariant ("never X under any condition")
   - **Phase 3c (LLM-rephrase)**: synthesize cluster's N rules into 1 prevention statement (preserve meaning, dedupe).
9. **Verify provenance** — every cluster proposal cites: (a) source rule line numbers from Step 2, (b) Q-E3 priority chosen, (c) capability-map cells touched (if any).
10. **Output proposal markdown** — `Write` to `agent-workspace/memory/observations/promotion-proposals-<TS>.md` per `references/proposal-template.md`.
11. **Suggest follow-up** — for HOOK proposals: agent may implement immediately; for SKILL proposals: queue + author next session; for CHARTER proposals: file in `human-workspace/q-and-a/pending/` for explicit human approval.

## Validation Pre-Conditions

- `agent-notes.md` exists + has ≥5 rule headers
- Jaccard threshold in [0.5, 0.95] (sanity bounds)
- Output proposal includes ALL clusters (or explicit `skipped:` annotation if budget-capped)

## Anti-Patterns

- **Promoting a single occurrence** — wait for cluster of ≥3 instances. Single drift events are noise.
- **Skipping HOOK priority** — if the rule is deterministically checkable, that's a HOOK, not a SKILL. Burning skill budget on what bash can guard is anti-pattern (per AP-23).
- **Auto-promoting CHARTER without approval** — charter changes require explicit human revision per `PROJECT_CHARTER.md § Revision Protocol`. Agent NEVER bypasses.
- **Lexical-only similarity then declaring "semantic match"** — Jaccard catches lexical recurrence; semantic clustering needs embeddings (Phase 1+ pgvector). Document threshold caveats in proposal.
- **Rephrase that loses provenance** — synthesis must preserve the WHY (incident, rationale) of source rules; not just the WHAT.
- **Burying the priority** — every proposal explicitly cites Q-E3 priority hook→skill→charter in its decision rationale.

## Smoke Test (S8 / S9)

Sample run on current `agent-notes.md` (17 rules):

Expected output shape:
- ≥3 clusters identified at threshold 0.7 (e.g., "qa-input-channel discipline" / "verification discipline" / "session-bootstrap discipline")
- Each cluster: 1-3 word title + Q-E3 priority + rephrased rule + source line citations
- ≥1 cluster proposes HOOK target (e.g., qa-bundle field validator)
- ≥1 cluster proposes SKILL target (e.g., adversarial-review composer)
- ≥0 cluster proposes CHARTER target (charter-tier rare; expected 0 in current set)

Pass criteria: skill produces proposal markdown matching template; deterministic Phase 1+2 reproducible; LLM Phase 3 outputs human-reviewable.

## Output Schema (proposal-template.md summary)

```markdown
## Promotion Proposals — <TS>
### Cluster <N>: <LLM-named title>
- **Q-E3 priority**: HOOK | SKILL | CHARTER
- **Source rules** (line N..M):
  - `### YYYY-MM-DD: rule-title` (line X)
  - ... (≥3 entries)
- **Synthesized prevention rule**: <1-2 sentences>
- **Rationale**: <why HOOK/SKILL/CHARTER>
- **Capability-map touch**: <task_class>
- **Suggested implementation**: <script path | skill name | charter section>
- **Confidence**: <low | medium | high>
```

## See Also

- `agent-workspace/memory/capability-map.md` — entries written per cluster's task_class
- `agent-workspace/memory/observations/queued-grill-master.md § Q-E3` — promotion priority directive
- `.claude/skills/decompose-work/SKILL.md` — sibling 5.5c.1; pre-execution decomposer
- `.claude/skills/try-n-approaches/SKILL.md` — S9 sibling; consumes promotion outcomes
- D-003 § 5.5c.6 — strategic rationale + UP-06 §3
- `references/jaccard-helper.sh` — deterministic similarity script
- `references/proposal-template.md` — output structure
- `PROJECT_CHARTER.md § Revision Protocol` — CHARTER promotion gate
