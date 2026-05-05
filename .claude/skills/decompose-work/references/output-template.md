# Output Template — decompose-work Result

> Skill output shape. Use this template; fill in actual content per task.

## Template

```markdown
## Decomposition: <task short name>

**Source task**: <verbatim or near-verbatim user task description>
**Decomposition depth**: shallow | deep
**Estimated LLM budget saved by deterministic offload**: ~XK tokens

---

### Deterministic portions (N)

| ID | Sub-task | Tool/Script | Expected output | Verification |
|---|---|---|---|---|
| D-1 | ... | `wc -l <file>` | integer | manual eyeball OR drift hook |
| D-2 | ... | `grep -E '<pattern>' <file>` | match list | regex review pre-run |
| D-3 | ... | `node -e '...'` oneliner | parsed JSON | schema validate after |

---

### LLM-required portions (N)

| ID | Sub-task | Agent/Skill/Inline | Why LLM needed | Calibration cell (capability-map) |
|---|---|---|---|---|
| L-1 | ... | main session (opus, high effort) | synthesis across N sources | model=opus task_class=synthesis |
| L-2 | ... | sandwich-architect subagent | design + naming choice | model=opus task_class=design |
| L-3 | ... | inline (sonnet, low effort) | one-shot communication | model=sonnet task_class=communication |

---

### Hybrid portions (N)

| ID | Sub-task | Gate (deterministic) | Escalation (LLM) | Threshold |
|---|---|---|---|---|
| H-1 | ... | bash regex match | LLM if no exact match | ≥0.8 confidence |
| H-2 | ... | similarity ≥0.7 (script) | LLM judges promotion-worthiness | cluster size ≥3 |

---

### Integration plan

1. **Phase 1 (cheap-first)**: Run all D-N portions in parallel. Cache outputs to `<temp-path>`.
2. **Phase 2 (gate)**: Run all H-N gates against Phase 1 outputs. Tag each: PASS_GATE | ESCALATE.
3. **Phase 3 (LLM)**: Run L-N portions + escalated H-N portions. Pass cached deterministic outputs as context.
4. **Phase 4 (verify)**: Deterministic verification of LLM outputs (schema, provenance, drift signals).

---

### Risks + fallbacks

| Risk | Likelihood | Fallback |
|---|---|---|
| Classification miss (D treated as L or vice versa) | medium | Re-run skill mid-execution if portion takes 2x expected; promote/demote |
| LLM portion exceeds budget | medium | Reduce effort tier (max → high → medium); split task further |
| Deterministic tool unavailable | low | Document missing tool; escalate to L (note as future capability-map entry) |
| Hybrid gate threshold wrong (too tight = wasted LLM) | medium | Tune threshold over N runs; log to capability-map |

---

### Capability-map grounding

- **Cells consulted**: model=<X> effort=<Y> task_class=<Z> → observation "<...>"
- **Gaps**: <task_class not in map> → propose new entry post-run
- **Limits respected**: I-S1 (no LLM math) ✓ | I-S2 (provenance) ✓ | other invariants...

---

### Recommendation

**Default execution path**: Phase 1+2 run NOW (deterministic, cheap). Phase 3 dispatched per integration plan. Phase 4 mandatory before declaring task complete.

**If budget tight**: descope L-<lowest-priority> first. Never descope I-S1/I-S2 verification.
```

---

## Filling Tips

- **Be specific in tool column**: not "bash" — say `grep -cE '<pattern>' <file>`. The next-Claude reading should be able to copy-paste.
- **Verification matters**: every D portion needs an answer to "how do I know it succeeded?". Without that, it's not deterministic — it's blind execution.
- **Capability-map cells use the format**: `model=opus-4.7 effort=high task_class=synthesis`. If task_class is novel, propose adding it post-run.
- **Don't pad**: if 0 hybrid portions, drop the section. Empty tables are noise.
- **Pass cached outputs in Phase 3**: deterministic outputs feed LLM as cheap context — that's the whole point.
- **State invariants checked**: explicit list in Capability-map grounding section. Skipping this is the most common drift.

## Anti-Patterns

- Listing portions without sequencing → integration plan is the deliverable, not optional.
- Vague "use bash" without command → not actionable.
- Skipping verification column → can't tell deterministic from blind execution.
- Capability-map grounding empty when map exists → losing free signal.
- Risks without fallbacks → not a risk register, just a worry list.
