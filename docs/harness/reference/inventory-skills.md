# Reference — Skills Inventory

> **Audited**: 2026-05-19
> **Source**: `.claude/skills/*/SKILL.md` (24 skills total — includes `harness-docs-maintainer` added with this book)
> **Maintainer**: Run `/harness-docs sync skills` to regenerate

Each skill is an auto-discoverable procedure Claude Code invokes when the user's context matches the `description` frontmatter. Files at `.claude/skills/<name>/SKILL.md`.

See [Chapter 5 § Skills](../en/05-skills-commands-agents.md#52--skills) for skill anatomy + conventions.

---

## Family A — Stockforge Business Logic (7 skills)

These enforce stock-domain invariants (I-S1 no-LLM-math, I-S2 citation integrity, etc.).

| Skill | Trigger | Tools | LOC | Notes |
|---|---|---|---|---|
| `crawler-reliability` | Implementing scraper, retry logic | default | — | VBW for scrapers; selector vs live DOM; fallback chain |
| `ddd-tactical-patterns` | New aggregate, repo Protocol, domain event | Read, Glob, Grep, Bash, Edit, Write | — | Enforces zero-framework domain layer; Protocol in domain / impl in infra |
| `evidence-extraction` | Building extractor pipelines | default | — | Enforces I-S1; every claim needs source_url+extracted_at+confidence |
| `fastapi-module` | New HTTP endpoint, router wiring | default | — | Phase 2+ only; explicitly says "not for Phase 1" |
| `obsidian-vault` | Adding KB note, ingesting source | Read, Glob, Grep, Bash, Edit, Write | — | Raw/wiki separation; never writes raw/ |
| `postgres-pgvector` | New migration, schema design | Read, Glob, Grep, Bash, Edit, Write | — | Structured-vs-JSONB rules; I-S2 point-in-time integrity |
| `prompt-engineering` | Authoring new extractor/analysis prompt | Read, Glob, Grep, Bash, Edit, Write | — | Mandatory `no_llm_math: true` frontmatter; prompts in `prompts/`, not inline |

---

## Family B — Harness Self-Loop (10 skills)

Karpathy autoresearch + confidence calibration + harness diagnostics.

| Skill | Trigger | Tools | LOC | Notes |
|---|---|---|---|---|
| `decompose-work` | Multi-part task ≥3 sub-parts | Read, Glob, Grep, Bash | — | Karpathy foundation; pre-flight VBW (L-S30-1); reads capability-map.md |
| `empirical-probe-first` | Plan lists ≥3 strategies for one problem | Read, Glob, Grep, Bash, Write | — | Writes probe matrix JSON; ADR if pick deviates; companion vendor-api-probe.sh |
| `grill-maximization` | Confidence below threshold, multi-decision dependency | Read, Glob, Grep, Write | — | 8-rule doctrine; tags Confidence Score categories; pairs with qa-escalation |
| `hook-diagnostics` | Hook stuck active, aggregator row missing | Read, Glob, Grep, Bash | — | Single-session inspection of packages/observability/ state machine |
| `promote-rule` | ≥10 new rules since last run | Read, Glob, Grep, Bash, Write | — | Jaccard similarity clustering; outputs observations/promotion-proposals-<TS>.md |
| `qa-escalation` | intent-classifier OPEN_QA_BUNDLE / ESCALATE_HUMAN | Read, Glob, Grep, Write, Bash | — | AskUserQuestion is the ONLY effective surface; file bundle is audit trail |
| `session-memory-l0-l1` | Post-SessionEnd ingestion | Read, Glob, Grep, Bash | — | TranscriptCache + cleanText (strip 9 wrapper tags); 15+35 head/tail windowing |
| `sync-pull` | About to commit non-trivial decision | Read, Glob, Grep, Bash | — | Reads sync-tracker/state.tsv + weights.yaml; emits SELF-DECIDE-OK / GRILL / FORCE-GRILL |
| `try-n-approaches` | Open question from drift/dogfood | Read, Glob, Grep, Bash, Write | — | Writes framing artifact to learning-data/loop/; metric-function BLOCKING per L-S12-1 |
| `user-prompt-intake` | Any new user prompt landing | Read, Glob, Grep, Bash, Agent, Write | — | Trivial whitelist incl. Vietnamese; dispatches intent-classifier for non-trivial |

---

## Family C — Knowledge-Base (7 skills)

Generic build-the-build-system meta-skills.

| Skill | Trigger | Tools | LOC | Notes |
|---|---|---|---|---|
| `attach` | New CC project, peer copy, layer-separation check | Read, Glob, Grep, Bash, Write | — | Reads .claude/manifest.yaml; honors layer tags (harness/stockforge/personal); --dry-run |
| `harness-docs-maintainer` | After adding/removing skills/commands/agents/hooks, quarterly cadence, /harness-docs invocation | Read, Glob, Grep, Bash, Write, Edit | 182 | Drift detection + inventory regen for docs/harness/; companion to `harness-docs-auditor` agent + `/harness-docs` command (added 2026-05-19 with this book) |
| `spec-dual-layer` | Tier 2/3 spec authoring | Read, Glob, Grep, Bash, Edit, Write | — | Section content matrix; B.3 no-LLM-math; B.2 multi-criteria-not-single-score |
| `spec-to-wiki` | After /spec-author, spec re-gen | default | — | First-mention linking; never edit raw/; diff-mode preserves human additions |
| `test-pyramid-balance` | New feature test plan, PR review | Read, Glob, Grep, Bash | — | Stock-specific cats (backtest point-in-time, LLM-snapshot, calibration) |
| `ubiquitous-language` | New BC, term emerges | default | — | 6-field schema; passive analysis (paired with /drill-me interactive) |
| `write-a-skill` | Pattern surfaces in 3+ sessions | default | — | L-S14-1 (draft 20% under D1 ceiling); description = discoverability surface |

---

## Cross-Cutting Notes

- **Tools**: skills using "default" tools have no `allowed-tools` frontmatter (older skills). Newer skills declare minimal-grant.
- **Description discipline**: vague description = no auto-fire. Per `write-a-skill` § Description writing rules.
- **D1 ceiling**: 120 LOC first-draft (per L-S14-1); extract to `references/` if grows.
- **Pruning**: quarterly review for skills not triggered in 3 months.

---

## Five Canonical Pipelines

Skills compose into recognizable pipelines:

1. **Sandwich workflow**: session-start → master-plan → architect → dev → verifier → session-end
2. **Knowledge-base**: drill-me → spec-author → spec-to-wiki → ul-audit
3. **Self-upgrade loop**: decompose-work → try-n-approaches → promote-rule → lesson-synthesizer
4. **Calibration / Q&A**: sync-pull → grill-maximization → qa-escalation → AskUserQuestion
5. **Quality gates**: vbw-check + drift-check + devils-advocate + intent-vs-impl-diff

See [Chapter 5 § Pipelines](../en/05-skills-commands-agents.md#55--the-five-canonical-pipelines) for details.

---

## Drift / Open Items (2026-05-19)

- `spec-to-wiki` and `evidence-extraction` lack `allowed-tools` frontmatter (older skills, pre-convention).
- Many skill descriptions reference lesson IDs (L-S12-1, L-S14-1, etc.) — strong provenance but high coupling to memory layer; promote-rule cycle should monitor.
- `fastapi-module` says "Phase 2+ only" while project is at Phase 4; not broken, just dormant.
