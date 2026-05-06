# Invariants

> Things that must never break. Violations are bugs, not features.
>
> **General invariants** (I-N — applicable to any Claude Code project) live in this file.
> **Stock-domain invariants** (I-S* — VN stock-domain specific; finance + LLM real money risk) live in `invariants-stockforge.md`.

## Data Integrity

### I-1: Every claim has source_url
No claim may be stored, returned, or referenced without `source_url` metadata.
Enforcement: Schema constraint + DR2 drift signal + verifier agent.

### I-2: Every extraction has timestamp
`extracted_at` timestamp required on all extracted data (claims, recommendations, sentiment scores).
Enforcement: Schema NOT NULL constraint.

### I-3: Hallucination is a bug
If LLM generates a claim not grounded in provided evidence, that's a defect.
Enforcement: VBW Protocol + verifier agent + eval set regression.

### I-4: Public output has verified data only
Anything surfaced via dashboard or alerts shows `verified=true` data only. Pending verification = "unverified" badge in UI.
Enforcement: View-level filter + application-level check.

### I-5: Data freshness visible
All surfaced data shows "as of [date]" with staleness color coding (green: <24h, yellow: <7d, red: >7d).
Enforcement: UI requirement + mandatory timestamp propagation.

---

## Code Integrity

### I-10: Domain layer has ZERO framework dependency
`packages/domain/**` may not import FastAPI, Pydantic, ORM libraries, or any framework.
Only pure Python: stdlib, dataclasses, enum, typing. Internal domain types only.
Enforcement: DR6 drift signal + import-linter rule.

### I-11: Cross-BC communication via contracts only
Bounded contexts never directly import from each other's domain/application packages.
All cross-BC communication goes through `packages/contracts/`.
Enforcement: DR8 drift signal + import-linter rule.

### I-12: No `Any` type in domain package
`packages/domain/**` cannot contain `: Any` or `cast(Any, ...)`.
Enforcement: mypy --strict + DR6 drift signal.

### I-13: No `print()` in production code
Use structured logger (`structlog`). `print()` allowed only in tests, dev tooling, CLI.
Enforcement: ruff rule + DR-minor drift signal.

---

## Process Integrity

### I-20: Spec before code
No production code written without corresponding spec in `specs/tier2-feature/` or `specs/tier3-task/`.
Enforcement: Code review checklist + PR template.

### I-21: VBW Protocol mandatory before spec/test/code
Agent must verify source before writing. Reading from memory/convention is forbidden.
Enforcement: VBW checkpoints in `vbw-protocol.md` + pre-commit hook (planned).

### I-22: Session handoff always written
Every session ends with written handoff to next session.
Enforcement: Session-end protocol + /session-end command.

### I-23: Constitution never modified by agent
Files in `agent-workspace/constitution/` require explicit human edit.
Enforcement: CLAUDE.md hard rule + human review gate.

### I-24: Eval set regression blocks merge
If eval set performance drops, PR cannot merge without human override.
Enforcement: CI gate + Tier 3 human approval.

### I-25: Deterministic gates must pass
mypy --strict, pytest, ruff must pass before commit.
Enforcement: Pre-commit hook + CI pipeline.

---

## Privacy & Safety

### I-30: User data is private by default
Personal data never leaves local instance unless user explicitly enables sharing.
Enforcement: Schema default + application-level ACL.

### I-31: Raw source material immutable
`obsidian-vault/raw/` never modified by agent. All agent writes go to `wiki/`.
Enforcement: CLAUDE.md hard rule + file system permissions.

### I-32: No PII in logs
Personal information not logged outside designated privacy-controlled paths.
Enforcement: Logger filter + code review.

### I-33: Destructive operations require explicit approval
DELETE FROM, DROP TABLE, `rm -rf`, force push, branch deletion require user confirmation in same session.
Enforcement: CLAUDE.md hard rule + subagent design.

---

## Cost Integrity

### I-40: Budget cap per task validation
No single task validation may exceed the project's per-task LLM budget cap without escalation.
Enforcement: Budget-aware harness + budget-check command.

### I-41: Budget cap per session
No session may exceed the project's per-session LLM budget cap without human approval.
Enforcement: Session-level budget check + escalation.

### I-42: Daily LLM budget cap
Total LLM spend per day capped at configurable amount.
Enforcement: External rate limiter + alert.

---

## Quality Integrity

### I-50: Citation before synthesis
Synthesis agents cannot produce output until claim verifier has confirmed citations.
Enforcement: Pipeline ordering + schema validation.

### I-51: Adversarial review before alerts
No alert fires to user without adversarial critic review (in spec, even if simple rules-based).
Enforcement: Status state machine + Tier 2 probabilistic gate.

### I-52: Multi-criteria not scalar
System never produces single "score". Always multi-dimensional with trade-off surface.
Enforcement: Output schema + spec template + UI design.

---

## Violations Handling

### Severity Levels

**CRITICAL** (I-10, I-11, I-23, I-30, I-33, plus stock-domain CRITICALs in `invariants-stockforge.md`) — agent must stop immediately, escalate to human.

**HIGH** (most invariants in this file plus most I-S* in `invariants-stockforge.md`) — blocks commit/merge/deploy, fix before continuing.

**MEDIUM** — warning, fix in current session or flag for next.

**LOW** — log, address at phase boundary.

(Stock-domain severity-level mapping is detailed in `invariants-stockforge.md` § Severity Levels.)

### When Found

1. Stop current work
2. Log violation in `agent-workspace/memory/drift-logs/`
3. Assess: can fix now, or escalate?
4. If escalate → output escalation message to user
5. If fix → address and re-verify
6. Consider: does this need new drift signal or constitutional amendment?

### Post-Incident

After HIGH or CRITICAL violation:
1. Root cause analysis
2. New rule added to `agent-notes.md`
3. Drift signal added if detectable
4. Related skill or command updated

---

## Amendments

Invariants can be added, but rarely removed. To modify:
1. Document rationale (link to specific incidents)
2. Explicit human approval
3. Version bump on this file
4. Migration plan if removal affects existing enforcement

(Same procedure applies to stock-domain invariants in `invariants-stockforge.md`.)

---

Last modified: 2026-05-05 (S48l HH-G.2 — split out stock-domain I-S* invariants into `invariants-stockforge.md` for portability validation; general invariant content unchanged from v1.0 2026-04-23).
