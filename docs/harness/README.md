# StockForge Harness Framework — Documentation

> The operating manual for the multi-layer agent harness that turns Claude Code
> into a disciplined, self-monitoring engineering team.

This book documents the **StockForge Harness Framework** — the constitution + skills + commands + subagents + hooks + memory + lifecycle + quality system that runs *around* Claude Code in this project.

**Audience**: developers who want to understand, use, extend, or port the harness.

**Languages**: English (authoritative) + Vietnamese (mirror).

---

## Read in English

Recommended path for a first-time reader:

1. [00 — Preface](en/00-preface.md) — what this book is, who it's for
2. [01 — Quickstart](en/01-quickstart.md) — 30-min hands-on tour
3. [02 — Mental Model](en/02-mental-model.md) — the 5 big ideas
4. [03 — Architecture](en/03-architecture.md) — system map
5. [04 — Constitution](en/04-constitution.md) — immutable rules

Then continue with the layer-deep chapters:

6. [05 — Skills, Commands, Subagents](en/05-skills-commands-agents.md)
7. [06 — Hooks](en/06-hooks.md)
8. [07 — Memory System](en/07-memory-system.md)
9. [08 — Lifecycle](en/08-lifecycle.md)
10. [09 — Quality System](en/09-quality-system.md)
11. [10 — Self-Improvement](en/10-self-improvement.md)

Application-focused chapters:

12. [11 — Cookbook](en/11-cookbook.md) — recipes for common tasks
13. [12 — Internals](en/12-internals.md) — design decisions, 23 anti-patterns
14. [13 — Reference](en/13-reference.md) — quick lookup index
15. [14 — Contributing](en/14-contributing.md) — extending the harness
16. [15 — Glossary](en/15-glossary.md) — every term defined

---

## Đọc bằng Tiếng Việt

Đường dẫn được đề xuất cho người đọc lần đầu:

1. [00 — Lời nói đầu](vi/00-loi-noi-dau.md)
2. [01 — Bắt đầu nhanh](vi/01-bat-dau-nhanh.md)
3. [02 — Mô hình tư duy](vi/02-mo-hinh-tu-duy.md)
4. [03 — Kiến trúc](vi/03-kien-truc.md)
5. [04 — Hiến pháp](vi/04-hien-phap.md)
6. [05 — Skills, Commands, Subagents](vi/05-skills-commands-agents.md)
7. [06 — Hooks](vi/06-hooks.md)
8. [07 — Hệ thống bộ nhớ](vi/07-he-thong-bo-nho.md)
9. [08 — Vòng đời](vi/08-vong-doi.md)
10. [09 — Hệ thống chất lượng](vi/09-he-thong-chat-luong.md)
11. [10 — Tự cải thiện](vi/10-tu-cai-thien.md)
12. [11 — Công thức](vi/11-cong-thuc.md)
13. [12 — Nội tại](vi/12-noi-tai.md)
14. [13 — Tham khảo](vi/13-tham-khao.md)
15. [14 — Đóng góp](vi/14-dong-gop.md)
16. [15 — Thuật ngữ](vi/15-thuat-ngu.md)

---

## Reference Inventories

Auto-syncable inventories of every artifact:

- [Skills inventory](reference/inventory-skills.md) — 23 skills
- [Commands inventory](reference/inventory-commands.md) — 16 commands
- [Subagents inventory](reference/inventory-agents.md) — 14 subagents
- [Hooks inventory](reference/inventory-hooks.md) — 118 hooks
- [Constitution inventory](reference/inventory-constitution.md) — 17 files
- [Memory inventory](reference/inventory-memory.md) — memory files + dirs
- [ADRs inventory](reference/inventory-decisions.md) — all D-NNN

---

## Reading Paths by Role

| Reader | Read in this order |
|---|---|
| **First-day contributor** | 00 → 01 → 02 → 03, then skim 05-10 |
| **Building a new feature** | 11 (relevant recipe) → 13 (lookup) |
| **Debugging a harness failure** | 09 → 10 → 12 (anti-patterns) |
| **Extending the framework** | 04 → 08 → 14 |
| **Auditing for drift** | 07 → 09 → relevant constitution files |
| **LLM agent reading to plan work** | 02 → 03 → relevant single chapter |

---

## Keeping the Book in Sync

Run `/harness-docs sync` to regenerate inventories from the live system.

For a full drift audit (book prose vs reality), dispatch the [`harness-docs-auditor`](../../.claude/agents/harness-docs-auditor.md) subagent.

See [Chapter 14 § Keeping the Book in Sync](en/14-contributing.md#keeping-the-book-in-sync) for details.

---

## Versioning

This book documents harness version aligned with **PROJECT_CHARTER.md v1.1** (ratified 2026-05-12, D-056).

Last full audit: **2026-05-19**.

Open issues / drift: see [`agent-workspace/memory/.harness-gaps.md`](../../agent-workspace/memory/.harness-gaps.md) (informal log).

---

## License

Internal documentation for the StockForge project. Adapt freely within the project; for external reuse, contact the project owner.

Borrowed patterns / inspirations:
- [Diataxis](https://diataxis.fr/) — documentation IA
- [Ruby on Rails Guides](https://guides.rubyonrails.org/) — narrative voice
- [Django docs](https://docs.djangoproject.com/) — topics + reference pairing
- [Pro Git book](https://git-scm.com/book) — book-style depth
- [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) — Karpathy P1-P4 principles
