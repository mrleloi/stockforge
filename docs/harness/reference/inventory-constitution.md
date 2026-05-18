# Reference — Constitution Inventory

> **Audited**: 2026-05-19
> **Source**: `agent-workspace/constitution/*.md` (17 files)
> **Maintainer**: Run `/harness-docs sync constitution` to regenerate

All edits to constitution files are denied to agent in `.claude/settings.json`. Modification requires the [proposal → cool-down → ratification](../en/04-constitution.md#46--amendment-process) cycle.

See [Chapter 4 — The Constitution](../en/04-constitution.md) for full reference.

---

## Files

| File | Status | Tier | Purpose |
|---|---|---|---|
| `architecture.md` | CHARTER | 1 | Layer boundaries, 9 BC rules |
| `autonomous-protocol.md` | CHARTER | 1 | Autonomous-mode rules (Rules 1-10) |
| `boundaries.md` | CHARTER | 1 | Hard (B-1..B-14) + soft (SB-N) boundaries |
| `coding-principles.md` | CHARTER | 1 | Code-level style + structure |
| `decision-discipline.md` | CHARTER | 1 | ADR 12-field schema + confidence thresholds |
| `drift-signals.md` | CHARTER | 1 | DR1-DR12 + DR-A / DR-S signals |
| `financial-data-protocol.md` | CHARTER | 1 | 16 stock-domain data integrity rules |
| `harness-health-protocol.md` | CHARTER | 1 | HH-1..HH-12 self-scan signal catalog |
| `invariants.md` | CHARTER | 1 | General invariants (I-1..I-54) |
| `invariants-stockforge.md` | CHARTER | 1 | Stock-domain invariants (I-S1..I-S65) |
| `karpathy-principles.md` | CHARTER | 1 | P1-P4 principles |
| `memory-routing-tree.md` | CHARTER | 1 | Where to put what memory artifact |
| `memory-tiers.md` | CHARTER | 1 | Tier 1 ≤8K; Tier 2 JIT; Tier 3 explicit |
| `portability.md` | PROPOSAL | 1 | Cross-platform rules (awaiting Cluster C ratification) |
| `session-budgets.md` | CHARTER | 1 | Per-session-type token budgets |
| `severity-schema.md` | CHARTER | 1 | CRITICAL/HIGH/MEDIUM/LOW classifications (D-058) |
| `vbw-protocol.md` | CHARTER | 1 | Verify-Before-Write 4 checkpoints |

---

## Charter Principles (PROJECT_CHARTER.md — separate file)

| # | Principle |
|---|---|
| 1 | Evidence grounding |
| 2 | Structured output over narrative |
| 3 | Adversarial by design |
| 4 | Proprietary data moat |
| 5 | Pattern transfer + local adaptation |
| 6 | Human-in-loop is the product |
| 7 | Dogfood mandatory |
| 8 | Calibration over confidence |
| 9 | **No LLM math** |
| 10 | **Position sizing & risk management are deterministic** |
| 11 | **Harness must self-verify firing, not self-attest existence** |

Principles 9, 10, 11 are the harness load-bearers.

---

## Karpathy Principles

| ID | Principle | Prevents |
|---|---|---|
| P1 | Think Before Coding | Silent picking, hidden confusion |
| P2 | Simplicity First | Overengineering, speculative flexibility |
| P3 | Surgical Changes | Drive-by refactoring, style drift |
| P4 | Goal-Driven Execution | Unclear "done" state |

---

## Hard Boundaries (B-1..B-14)

| ID | Boundary |
|---|---|
| B-1 | Never modify PROJECT_CHARTER.md |
| B-2 | Never modify agent-workspace/constitution/* |
| B-3 | Never write to obsidian-vault/raw/ |
| B-4 | Never commit without explicit user request *(superseded 2026-05-15 by D-060)* |
| B-5 | Never perform destructive operations without same-session approval |
| B-6 | Never deploy to production without approval |
| B-7 | Never disable tests or lints to make CI pass |
| B-8 | Never install new dependencies without review |
| B-9 | Never hardcode secrets, credentials, API keys |
| B-10 | Never override safety mechanisms |
| B-11 | Never override position sizing or risk rules |
| B-12 | Never claim confidence without calibration data |
| B-13 | Never modify past thesis-log entries |
| B-14 | Never modify eval-sets/baseline-results/ |

---

## Most-Cited Stock Invariants

| ID | Rule |
|---|---|
| I-S1 | No LLM math |
| I-S1-1 | Numeric-field discipline (D-065 amendment) |
| I-S2 | Every claim cites source + as-of date |
| I-S7 | Confidence claims must cite calibration data |
| I-S10 | Thesis must include bear case (≥3 specific points) |
| I-S35 | Frame as research aid; never "buy/sell/recommendation" |
| I-S55..I-S65 | VN-specific (T+2.5, room ngoại, sàn-tier, FX VND-USD) |

---

## Drift Signal Catalog

See [Chapter 9 § Drift Signals](../en/09-quality-system.md#93--drift-signals-dr1-dr12) for full catalog.

---

## Harness Health Catalog (HH-1..HH-12)

See [Chapter 9 § Harness Health](../en/09-quality-system.md#94--harness-health-signals-hh-1hh-12) for full catalog.

---

## Severity Schema

| Level | Action |
|---|---|
| CRITICAL | `.autonomous-BLOCKED` + URGENT + Telegram |
| HIGH | URGENT + UserPromptSubmit context + Telegram |
| MEDIUM | Weekly digest |
| LOW | Log only |

---

## Confidence Thresholds (Decision Discipline)

| Tier | Threshold | Path |
|---|---|---|
| CHARTER | 0.99 | Always AskUserQuestion + human ratify |
| SCOPE | 0.90 | AskUserQuestion if <0.90 |
| ARCH | 0.80 | Self-decide if ≥0.80 |
| IMPL | 0.50 | Self-decide if ≥0.50 |

---

## Amendment Process

```
PROPOSAL (proposals/<slug>.md)
  ↓ COOL-DOWN (48h)
RATIFICATION (AskUserQuestion bundle + ADR)
  ↓ MV-TO-CONSTITUTION (one-time deny-lift)
CROSS-REFERENCE UPDATE
```

See [Chapter 4 § 4.6](../en/04-constitution.md#46--amendment-process) for details.

---

## See Also

- [Chapter 4 — The Constitution](../en/04-constitution.md) (full reference)
- [PROJECT_CHARTER.md](../../../PROJECT_CHARTER.md)
- [CLAUDE.md](../../../CLAUDE.md)
