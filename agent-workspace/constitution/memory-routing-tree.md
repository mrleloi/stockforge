---
status: CHARTER
ratified_at: 2026-05-04
ratified_by: Project owner — explicit chat accept "tôi accept toàn bộ q&a recommend của agent và các đề xuất còn đang block" at S43c entry
ratifying_decision: D-024
authored_at: 2026-05-01 (S43b-EVIDENCE harness recovery — HR-4)
author: agent (autonomous draft per agent-workspace/CLAUDE.md Rule 1)
ratification_path: COMPLETE — moved from agent-workspace/proposals/ to agent-workspace/constitution/ at S43c via S38 deny-lift mechanism
source_evidence:
  - agent-workspace/memory/agent-notes.md 2026-05-01 entry "Project-Scoped Lessons Land in agent-notes.md, NOT user-memory dir" (L-S43b-5)
  - agent-workspace/memory/self-awareness/best-practices.md § BP-S43b-5
  - agent-workspace/memory/self-awareness/known-issues.md § KI-S43b-5 (lesson-synthesis Stage 2 dormant; user-memory bypassed project loop)
  - user verbatim 2026-05-01 (S43b-EVIDENCE pivot): "bạn lưu rất nhiều memory, note. chúng khiến hệ thống rất dễ lỗi liên quan đến llm"
  - agent-workspace/memory/checkpoints/latest.md (HR-4 deferred to charter amendment)
companion_artifacts:
  - scripts/hooks/memory-routing-audit.sh (DRAFTED 2026-05-01 — 93 LOC; bash + POSIX; smoke-tested green; UNWIRED pending ratification; on approval add to .claude/settings.json Stop chain after lesson-synthesis-watchdog)
relates_to:
  - agent-workspace/constitution/memory-tiers.md (sibling charter — defines Tier 1/2/3 within project memory tree; does NOT cover project-vs-user-memory routing)
sibling_proposals_in_dir:
  - architecture-amendment.md
  - drift-signals-amendment-DR-INTENT.md
  - financial-data-protocol-amendment.md
  - financial-data-protocol-amendment-VN.md
  - invariants-amendment-VN.md
  - provenance-protocol.md
  - session-budgets-amendment.md
---

# Memory Routing Tree — CHARTER

> **Status**: CHARTER (ratified 2026-05-04 at S43c via D-024). Edits require explicit user prompt + Q&A per `agent-workspace/CLAUDE.md` constitution-amendment process.

## Purpose

Make explicit where each kind of learned memory lands. Without this routing tree, the agent silently bypasses the project lesson-loop by writing project-scoped lessons into the user-memory directory — a failure mode user-detected at S43b-EVIDENCE (KI-S43b-5: 12+ entries accumulated as user-memory when they should have been `agent-notes.md`). Bypass starves the deterministic Stop-hook lesson-synthesis chain (HR-1 watchdog only inspects project memory tree), so patterns get re-discovered each session.

This proposal complements `memory-tiers.md` (which defines Tier 1/2/3 *within* the project memory tree) by adding **horizontal** scope routing across two surfaces:

- **Project memory** = `agent-workspace/memory/` (version-controlled with the repo; deterministic hooks consume; promotion candidates flow to skills/charters)
- **User memory** = `C:\Users\PC\.ccs\instances\nathanleewindy\projects\C--htdocs-stockforge\memory\` (machine-local; cross-project / user-role; auto-loaded by harness; NOT version-controlled with repo)

## Routing Decision Tree

When the agent learns something worth remembering, route via this tree (top-down; first match wins):

```
Q1: Is this lesson specific to stockforge code, patterns, sessions, or substrate?
    YES → agent-workspace/memory/agent-notes.md (project memory; canonical)
    NO  → continue to Q2

Q2: Is this about user (role / language / preferences) or cross-project (machine
    paths / general Claude Code conventions / external service auth)?
    YES → user-memory dir (e.g., user.md, language.md, machine_paths.md)
    NO  → continue to Q3

Q3: Is the lesson ambiguous (could fit either)?
    YES → BOTH surfaces accept, but agent-notes.md is the canonical project copy
          (so deterministic hooks see it; user-memory is the secondary "nice to have")
    NO  → re-classify; this branch is unreachable for well-formed lessons
```

## Hard Rules (BINDING upon ratification)

1. **NEVER write project-substrate lessons to user-memory.** Examples of project-substrate (always project memory):
   - "Stockforge bull sonnet timeout pattern" → `agent-notes.md`
   - "RatioService bank schema requires separate spec" → `agent-notes.md` + `decisions/`
   - "Phase 1 gatherer must wire compute services upstream" → `agent-notes.md` + (eventually) `architecture.md`
   - "TA features wiring gap caused 0-grounded-points dogfood" → `known-issues.md`
2. **NEVER write user-role context to project memory.** Examples of user-role (always user-memory):
   - "User prefers Vietnamese for chat, English for code"
   - "User uses /effort selectively across modes"
   - "User's machine-local path is `C:\htdocs\...`"
3. **When ambiguous, project memory wins as canonical.** Reason: deterministic hooks (lesson-synthesis-watchdog, drift-rollup-daily, harness-recovery-dod-watchdog) only see project memory; user-memory writes are invisible to the harness self-upgrade loop.
4. **Companion deterministic enforcement**: DRAFTED hook `scripts/hooks/memory-routing-audit.sh` (93 LOC; smoke-tested 2026-05-01) — at Stop, if `git status --short -- packages/ apps/ agent-workspace/` non-empty AND user-memory dir mtime fresh (last 24h) AND no fresh write to `agent-notes.md` → ALERT default / exit 2 strict (gated on `STOCKFORGE_MEMORY_ROUTING_HARDBLOCK=1` OR `STOCKFORGE_HOOK_PROFILE=strict`). UNWIRED pending ratification (file exists but not in `.claude/settings.json` Stop chain). User-memory dir path overridable via `STOCKFORGE_USER_MEMORY_DIR` env var.

## Acceptance Process

1. Human reviews this proposal in-place at `agent-workspace/proposals/memory-routing-tree.md`.
2. If approved verbatim: move file to `agent-workspace/constitution/memory-routing-tree.md` (drop `proposals/` prefix); set frontmatter `status: CHARTER` + `ratified_at: <date>` + `ratified_by: <user explicit>` + `ratifying_decision: D-NNN`. Optionally merge content as new § into `memory-tiers.md` to consolidate.
3. If approved with edits: human edits in `proposals/`; agent applies post-edit move on confirmation.
4. If rejected: file stays in `proposals/` as historical artifact; agent operates by current implicit convention until further guidance.

## Drift / Risk Notes

- This proposal increases governance surface (one more charter file). Mitigation: the rule is short, low-ambiguity, and addresses a user-detected failure mode. Net governance load is positive.
- The companion hook `memory-routing-audit.sh` adds 1 to the Stop hook chain (currently 17 hooks post-HR-3/HR-8). Within tolerance.
- Risk of over-routing: agent might over-classify lessons as project-substrate to satisfy the hook. Mitigation: BP-S43b-5 § "how_to_apply" already says when ambiguous, both surfaces acceptable.

## Self-audit

- Provenance: every claim above traces to a verbatim source (BP-S43b-5, KI-S43b-5, user prompt, agent-notes 2026-05-01).
- I-S2 (every claim has source + as-of): proposal artifact carries `authored_at`; companion citations carry their own as-of via the referenced files.
- I-S1 (no LLM math): no numbers computed; only counted (12+ user-memory entries) and that count is grep-able from the source files.
- Charter immutability: this is a PROPOSAL, written to `agent-workspace/proposals/` per `agent-workspace/CLAUDE.md` Rule 1. Direct-write to `agent-workspace/constitution/*.md` is denied by `.claude/settings.json`. Sibling proposals in this dir (architecture-amendment.md, etc.) follow the same pattern.
