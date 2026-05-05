---
status: ACCEPTED (ratified S43c via D-019; frontmatter sync S43f)
proposed_at: 2026-04-29
proposed_by: Claude Opus 4.7 (S16 IMPL — Track 7 ratification)
source_evidence:
  - agent-notes.md § L-S11-1 (Phase 0 hook portability)
  - session-plans/pending/003-S15-track-7-constitution-amendments.md § 2 + § 4.2
  - scripts/hooks/bash-hook-lint.sh § Check 1 L-S11-1 (deterministic enforcement shipped S16)
target_constitution_path: agent-workspace/constitution/financial-data-protocol.md
target_section: NEW § "Phase Boundaries — Hook Portability"
move_when: user explicit approve; insertion point = after "## When This Protocol Conflicts With Convenience" section
---

# Financial Data Protocol Amendment — Phase Boundaries Hook Portability

> **Status**: PROPOSAL pending user approval. Codifies the existing L-S11-1 doctrine (Phase 0 hooks must be bash + POSIX only) as a financial-data-protocol clause because hook portability is a precondition for the data-integrity rules in Rules 1-10.

## Append to `financial-data-protocol.md` (NEW section)

---

## Rule 11 — Hook Portability Per Phase

The data-integrity hooks in `scripts/hooks/` (telemetry, drift signals, learning-data sweepers, citation grep) enforce Rules 1-10. They must remain portable across phase boundaries so a fresh project clone reproduces the same enforcement without external toolchain installation.

### Phase 0 (Harness Bootstrap) — bash + POSIX only

During Phase 0, hooks MUST use bash + POSIX utilities only. Forbidden: `python`/`python3`, `jq`/`yq`, `pip`/`npm`/`pnpm`. Reason: a fresh user cloning the repo at Phase 0 has not yet provisioned a Python venv or jq install; hook failures at SessionStart create a worse first impression than no hook.

**Enforcement**: `scripts/hooks/bash-hook-lint.sh § Check 1 L-S11-1` scans `scripts/hooks/*.sh` and soft-warns on any non-Phase-0-portable invocation.

### Phase 1+ (Data Pipeline Active) — Python + jq accepted

Once Phase 1 ships the Python venv + data dependencies (`pyproject.toml` provisioned), hooks may invoke Python and jq. The bash-hook-lint check downgrades L-S11-1 to informational severity at phase boundary (config flag: `STOCKFORGE_HOOK_PORTABILITY_TIER=1`).

### Why This Matters for Financial Data Integrity

A Phase 0 hook that depends on jq for JSON parsing fails silently when jq is missing. Silent hook failure = drift signal not firing = data-integrity violation goes undetected. The portability rule is upstream of every Rule 1-10 enforcement.

**Concrete example**: D9 drift signal (runtime-path-leak into `learning-data/(events|archive)/`) is critical for Rule 6 (LLM Output Provenance) — if D9 hook fails to run because of a missing dependency, runtime code can silently load write-only telemetry into reasoning context, polluting decisions with non-runtime data.

## End of amendment
