---
status: ACCEPTED (ratified S43c via D-018; frontmatter sync S43f)
proposed_at: 2026-04-29
proposed_by: Claude Opus 4.7 (S16 IMPL — Track 7 ratification)
source_evidence:
  - agent-notes.md § L-S14-2 (skill-vs-command duplication multiplier)
  - session-plans/pending/003-S15-track-7-constitution-amendments.md § 2 + § 4.2
target_constitution_path: agent-workspace/constitution/architecture.md
target_section: NEW § "Slash Command vs Skill — Responsibility Split"
move_when: user explicit approve; insertion point = after "## Forbidden Patterns" section, before "## Evolution Protocol"
---

# Architecture Amendment — Slash Command vs Skill Responsibility Split

> **Status**: PROPOSAL pending user approval. Per `agent-workspace/CLAUDE.md` rule 1, agents WRITE to `proposals/`; user approve appends this delta to `agent-workspace/constitution/architecture.md`.

## Append to `architecture.md` (NEW section, after Forbidden Patterns)

---

## Slash Command vs Skill — Responsibility Split

Slash commands (`.claude/commands/<name>.md`) and skills (`.claude/skills/<name>/SKILL.md`) overlap in form (both are markdown procedure files) but should NOT overlap in responsibility. Per L-S14-2 (skill-vs-command duplication multiplier), duplicating procedure between a `/foo` command and a `foo` skill multiplies maintenance cost AND creates drift between the two when one updates and the other doesn't.

### Responsibility Split

| Concern | Slash Command | Skill |
|---|---|---|
| **Trigger** | User explicit invocation: `/<name>` | Auto-discovered by Claude Code via `description:` keyword match |
| **Audience** | User-facing workflow (command sequence to execute) | Agent-facing procedure (rules to follow when context matches) |
| **Body shape** | "When user types `/<name>`, do these N steps" — imperative checklist | "When working in context X, follow this discipline" — declarative rules |
| **Reusability** | Single workflow tied to a slash invocation | Reusable across many tasks that match the description |
| **LOC ceiling** | 120 (per drift-signals D1) | 150 (per drift-signals D1) |

### Anti-Pattern: Duplicated Body

If `/<name>` command and `<name>` skill both exist with overlapping body content, the skill MUST be the source of truth and the command body MUST delegate (e.g., the command body says "invokes `<name>` skill via Skill tool" or copy-references the skill's authoritative rules).

**Example (correct)**: `/grill-me` command body is short — describes user-facing trigger; the procedure lives in `grill-maximization` skill, which the command references.

**Example (anti-pattern)**: `/grill-me` command body and `grill-maximization` skill both contain a 80-line "how to bundle questions" procedure. When the bundling rule changes (e.g., 4-question max per AskUserQuestion limit), only one gets updated. The drift signal D-DUPL (TBD) flags >50% line overlap between command + skill of similar name.

### Boundary Heuristics

- If the procedure runs once per user invocation → slash command
- If the procedure runs across many tasks based on context auto-match → skill
- If both apply: skill carries the body; command is the entry point

## When SKILL.md Exceeds Ceiling — Companion-via-References (L-S16-1, applied S20)

Per drift-signals D1, SKILL.md ceiling is 150 LOC. When a skill's procedure genuinely needs more body than fits, split content to `references/<topic>.md` companion files; SKILL.md keeps the high-density rules + delegates detail.

**Pattern**:
- SKILL.md body: rules / when-to-use / anti-patterns (≤150 LOC)
- `references/<topic>.md`: extended templates / examples / sub-rules (no LOC ceiling)

**Examples (Track 6 secondary closure S20)**:
- `spec-to-wiki/SKILL.md` 227 → 67 LOC; companion `references/templates.md` 163 LOC consolidating 5 sub-templates
- `ubiquitous-language/SKILL.md` 210 → 97 LOC; companion `references/templates.md` 120 LOC schema + examples + drift-log
- `write-a-skill/SKILL.md` 163 → 99 LOC; companion `references/templates.md` 88 LOC SKILL skeleton + failure modes

**When NOT to split**: if compression by prose paraphrasing keeps body ≤ ceiling without losing content, prefer compression over split (Phase 0 portability principle: fewer files = less drift surface). Examples shipped self-contained: `crawler-reliability/SKILL.md` 226 → 102, `fastapi-module/SKILL.md` 225 → 122.

**Anti-pattern**: creating `references/` companion file for content that compresses cleanly into prose. Adds file to track without information gain.

## When Porting From Source Repos — Cross-Locale Pattern Extension (L-S18-1, S18 evidence)

When porting a regex-based extractor (or any pattern-matcher whose patterns hard-code language-specific terms) from a source repo to stockforge, the regex set is NOT portable — it is locale-sensitive.

**Pattern**: source repo patterns serve source locale; stockforge user is Vietnamese-speaking. Direct port without locale extension yields false-negative on Vietnamese failure phrases.

**Example (Track 8b S18)**: ported `extract_l0.py` from `C:/htdocs/orch-starter`; English-only `\b(failed|stuck|broken|error)\b` patterns missed Vietnamese. Added 5 NEW patterns: `bị lỗi` / `mắc kẹt` / `không hoạt động` / `thất bại` / `bug` (loanword). Bilingual extractor without requiring NLP model.

**Discipline**: when porting any locale-sensitive pattern set (regex / keyword list / stop-list / sentiment lexicon), pre-flight checklist MUST include:
1. List regex/keywords in source
2. Translate to target locale (Vietnamese for stockforge)
3. Add target-locale patterns alongside source-locale (bilingual; don't replace)
4. Test on locale-specific corpus before declaring port complete

**Anti-pattern**: assuming portability based on language semantics ("regex is language-agnostic"). The SYNTAX is agnostic; the CONTENT isn't.

## Telemetry Rollup Design — Deterministic Aggregator Before LLM Guardian (L-S19-1, S19 evidence)

For session-level telemetry rollup (aggregating per-session metrics across many sessions for self-awareness profile), prefer **deterministic Stop-hook aggregator** over **continuous LLM Guardian** as Phase 0 implementation.

**Pattern**:
- Deterministic aggregator: bash + awk parsing JSONL/TSV at session-end; runs in milliseconds; emits a row to sessions-rollup.tsv. Cost: ~zero LLM tokens; deterministic output; auditable.
- LLM Guardian: continuous polling + analysis subagent. Cost: ~1-5K tokens per poll; non-deterministic; not auditable without persistence.

**Phase 0 verdict (Track 9 S19)**: deterministic aggregator wins for rollup use case. LLM Guardian reserves itself for **end-of-phase analysis** (when accumulated rollup data needs interpretation, not collection).

**Example**: `scripts/hooks/self-awareness-aggregate.sh` 124 LOC bash+awk only. Reads dispatch.jsonl + component-telemetry.jsonl + .transcript-tokens + .session-hooks.log + sessions/*.md → emits 1 row to sessions-rollup.tsv. Smoke-tested S19; PASS.

**Anti-pattern (already AP-23 catalogued)**: "Continuous LLM-Guardian" — running a polling subagent that watches for telemetry events and synthesizes rollup. Wastes tokens; non-deterministic; cost grows with session length. Reserve LLM analysis for batch end-of-phase rollup interpretation, not real-time aggregation.

**Boundary**: aggregator = collection-only (deterministic); LLM analysis = interpretation-only (over deterministic corpus, batch form, when needed).

## End of amendment
