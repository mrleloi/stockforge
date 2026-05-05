---
observation_id: decompose-work-smoke-test-S8
type: skill-smoke-test
created_at: 2026-04-29
skill: decompose-work
session: S8
verdict: PASS
---

# Smoke Test — decompose-work skill (S8 first run)

## Decomposition: Author promote-rule skill (Track 5.5c.6)

**Source task**: "Author `.claude/skills/promote-rule/SKILL.md` (or hybrid hook+agent). Reads `agent-notes.md` periodically; clusters similar entries (semantic similarity ≥0.7); cluster of ≥3 similar → propose promotion to skill/hook/constitution. Priority per Q-E3: hook FIRST, skill SECOND, charter LAST. Output: proposal markdown in `agent-workspace/memory/observations/promotion-proposals-<TS>.md`."

**Decomposition depth**: shallow
**Estimated LLM budget saved by deterministic offload**: ~15-25K tokens

---

### Deterministic portions (5)

| ID | Sub-task | Tool/Script | Expected output | Verification |
|---|---|---|---|---|
| D-1 | Read agent-notes.md | `Read agent-workspace/memory/agent-notes.md` | full file text | byte count >0 |
| D-2 | Extract rule headers (regex) | `Grep -n "^### " agent-notes.md` | line list with rule titles | manual eyeball |
| D-3 | Tokenize each rule body (split words ≥4 chars, lowercase) | `node` oneliner: split on /\W+/, filter, lowercase | per-rule token sets | sample 2 rules visually |
| D-4 | Compute pairwise Jaccard similarity | `node` script: nested loop over rules, |A∩B|/|A∪B| | similarity matrix | check diagonal=1.0, symmetric |
| D-5 | Output proposal markdown to observations/ | `Write` | file with frontmatter + cluster table | file exists post-run |

---

### LLM-required portions (3)

| ID | Sub-task | Agent/Skill/Inline | Why LLM needed | Calibration cell (capability-map) |
|---|---|---|---|---|
| L-1 | Name each cluster (1-3 word title) | inline (sonnet, low effort) | linguistic judgment; 2-3 rules → cluster identity | model=sonnet task_class=naming |
| L-2 | Choose promotion target (hook vs skill vs charter) per Q-E3 priority | inline (opus, medium effort) | judgment call: which abstraction layer fits the rule? | model=opus task_class=design |
| L-3 | Rephrase rules into single prevention-rule statement | inline (opus, medium effort) | synthesis under constraint (preserve meaning, dedupe) | model=opus task_class=synthesis |

---

### Hybrid portions (1)

| ID | Sub-task | Gate (deterministic) | Escalation (LLM) | Threshold |
|---|---|---|---|---|
| H-1 | Promotion-worthy cluster? | similarity ≥0.7 AND cluster_size ≥3 (script) | LLM judges: is rule abstract enough to promote? | size ≥3 + sim ≥0.7 → ESCALATE |

---

### Integration plan

1. **Phase 1 (Deterministic, parallel)**: D-1 → D-2 → D-3 → D-4. Cache similarity matrix to `<temp>/sim-matrix.json`.
2. **Phase 2 (Hybrid gate)**: For each cluster from H-1: if size ≥3 AND sim ≥0.7 → tag ESCALATE. Else SKIP.
3. **Phase 3 (LLM)**: For each ESCALATED cluster: L-1 (name) → L-2 (target choice) → L-3 (rephrase). Cap at top-5 clusters by total-pair-similarity to bound LLM cost.
4. **Phase 4 (Verify + write)**: D-5 emits observations/promotion-proposals-<TS>.md with cluster table. Drift check: every cluster cites source rule line numbers from D-2 output.

---

### Risks + fallbacks

| Risk | Likelihood | Fallback |
|---|---|---|
| Jaccard misses semantic similarity (lexical only) | high | accept lexical floor; LLM step refines; future: pgvector embeddings (Phase 1+) |
| Cluster of 3 rules that aren't promotion-worthy | medium | L-2 can return "no-promotion-warranted"; output records it |
| Q-E3 priority hierarchy unclear in edge cases | low | default skill (medium-cost target); cite Q-E3 verbatim in proposal |
| Token-similarity threshold too tight (no clusters) | low | start at 0.7; tune over N runs; log to capability-map |
| LLM dispatch cost > savings | medium | cap LLM at top-5 clusters; rest queued for next run |

---

### Capability-map grounding

- **Cells consulted**: capability-map.md does not yet exist (5.5c.2 deliverable parallel-developing this session). Skill will read it once seeded.
- **Gaps (propose post-run)**: task_class=naming + task_class=clustering not yet in any capability-map. Add post-run.
- **Limits respected**: I-S1 NO-LLM-math ✓ (Jaccard is deterministic). I-S2 provenance ✓ (cluster cites source line numbers). AP-23 deterministic-Guardian ✓ (hook script does the gate; LLM only escalates).

---

### Recommendation

**Default execution path**: Skill runs as on-demand `/promote-rule` (mid-session) initially. Future: hook-triggered via Stop hook every Nth session. Phase 1+2 always run; Phase 3 only when ≥1 ESCALATE cluster exists.

**If budget tight**: cap LLM at top-3 clusters; log skipped clusters for future cycles.

---

## Verdict

**PASS**: decomposition produces the expected rough shape per skill smoke-test target:
- Deterministic: ✓ read agent-notes, regex-extract, similarity matrix, output markdown
- LLM-required: ✓ cluster naming, promotion-target choice, rule rephrasing
- Hybrid: ✓ similarity threshold gate → LLM escalation

Skill is functional as designed. This decomposition feeds directly into Track 5.5c.6 implementation in same S8 session.

## Notes

- Smoke test was performed inline by the agent reading SKILL.md + classification-heuristics.md + output-template.md and applying the process. No subagent dispatch.
- This artifact serves dual purpose: (a) skill smoke-test pass, (b) actual design input for promote-rule.
- Skill auto-discovery confirmed via system-reminder (skill listed in available-skills tool list immediately after SKILL.md write).
