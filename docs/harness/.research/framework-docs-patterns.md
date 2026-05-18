# Framework Documentation Patterns — Research Report

**Purpose.** Inform the information architecture for the StockForge harness documentation by extracting proven patterns from eight industry-standard developer-framework doc sites. Synthesize into a recommended TOC blueprint.

**Method.** Live web research via `WebFetch`/`WebSearch` of canonical doc landing pages and Diataxis sub-pages. URLs cited inline. Conducted May 2026.

---

## 1. Diataxis — the meta-framework

**Source:** <https://diataxis.fr/>, <https://diataxis.fr/foundations/>, <https://diataxis.fr/tutorials/>, <https://diataxis.fr/how-to-guides/>, <https://diataxis.fr/reference/>, <https://diataxis.fr/explanation/>

Diataxis is built on two orthogonal axes that together exhaust every documentation user-need without overlap:

| | **Acquisition** (study) | **Application** (work) |
|---|---|---|
| **Action** (doing) | Tutorials | How-to guides |
| **Cognition** (thinking) | Explanation | Reference |

The Diataxis insight is that **the same prose, placed in the wrong quadrant, becomes useless or actively harmful**. A tutorial that pauses for design rationale "breaks the magic spell of learning"; a reference page seeded with opinion stops being trustworthy ("could be literally dangerous" — the food-packaging analogy).

The four types in their authors' own words:

- **Tutorial** — "a lesson, that takes a student by the hand through a learning experience." Skill acquisition through doing. Voice: first-person plural ("we will…"), guiding ("notice that…"), celebratory ("you have built a…"). Exclude alternatives, choices, deep explanation. Cooking analogy: teaching a child to cook — the dish matters less than the discovered pleasure and embedded habits.
- **How-to guide** — "directions that guide the reader through a problem or towards a result." Assumes prior competence. Structure is "If you want X, do Y." Recipe analogy: even a professional chef follows recipes; the recipe does not teach cooking. Title must be explicit ("How to integrate APM" not "APM").
- **Reference** — "the technical description — facts — that a user needs in order to do things correctly: accurate, complete, reliable." Map analogy: "tells you what you need to know about the territory, without having to go out and check the territory for yourself." Structure **must mirror the system being described**. Strict neutrality; consistency over cleverness.
- **Explanation** — "permits reflection." Answers "Can you tell me about…?" Covers "the bigger picture, history, choices, alternatives, possibilities." Non-linear and discursive — "needs to circle around its subject." May contain opinion; this is the only quadrant where opinion is legitimate. McGee's *On Food and Cooking* is the canonical example: it doesn't teach cooking but reframes how a practitioner thinks about it.

**Implication for our harness:** every section we author must self-identify which quadrant it serves, and stay in that quadrant.

---

## 2. Django docs — Diataxis applied at scale

**Source:** <https://docs.djangoproject.com/>

Django is the canonical Diataxis-aligned site. Its famous "How the documentation is organized" page explicitly names the four categories: Tutorials, Topic guides (explanation), Reference, How-to guides.

Top-level TOC (in order): First steps → Getting help → Model layer → View layer → Template layer → Forms → Development process → Admin → Security → I18n → Performance → Geographic → Common web app tools → Other core → The Django open-source project.

Notable structural choices:

- **MTV as primary spine** with horizontal concerns (forms, security, i18n) cutting across.
- **How-to guides are not centralized** — they are interleaved into each layer (`howto/custom-model-fields/` lives inside the model layer, not a separate "how-to hub").
- **Within each layer, conceptual ("topics/") and reference ("ref/") are paired** — e.g., `topics/db/models/` introduces, then `ref/models/fields/` enumerates.
- **Getting Help is the second section, not a footer** — community visibility is a design statement.
- **The 8-part Tutorial** is the gold-standard beginner ramp: Requests → Models+Admin → Views+Templates → Forms+Generic Views → Testing (early!) → Static files → Admin customization → Third-party packages.

---

## 3. Ruby on Rails Guides — narrative-driven framework manual

**Source:** <https://guides.rubyonrails.org/>, <https://guides.rubyonrails.org/getting_started.html>, <https://guides.rubyonrails.org/plugins.html>

Top-level TOC: Start Here → Models → Views → Controllers → Other Components → Digging Deeper → Going to Production → Advanced Active Record → Extending Rails → Contributing → Policies → Release Notes.

Voice is markedly conversational: "Welcome to Ruby on Rails!", "Rails is opinionated software", "Let's try it out." Each Getting Started section pairs imperative ("run the server") with explanatory beat ("Rails will detect this route to `products#index`…"). The guides feel like **a senior engineer walking you through the codebase**, not a spec.

Extending-Rails pattern (highly relevant to our harness contributors):

1. **Conceptual foundation first** ("What are plugins?") with three distinct purposes laid out.
2. **Decision framework** ("simple utilities → basic plugin; complex → `--full`; self-contained → `--mountable`") rather than a single forced path.
3. **Single running example** (the "ApiBoost" plugin) carried throughout for cognitive continuity.
4. **Just-in-time concept introduction** — Railties are explained only when the example needs them.
5. **Tests-as-documentation** demonstrate expected behavior.

This is the model we want for "extending the harness with a new skill / hook / subagent."

---

## 4. Spring Framework Reference — formal layered reference

**Source:** <https://docs.spring.io/spring-framework/reference/index.html>

Chapter list: Overview → Core → Testing → Data Access → Web Servlet → Web Reactive → Integration → Languages → Appendix.

Patterns to borrow:

- **Strict pedagogical ordering inside chapters.** Core opens with IoC Container → Beans → Dependencies → Scopes, and only then proceeds to AOP, because AOP requires understanding bean lifecycle.
- **"Understanding X" precedes "Configuring X" precedes "X API."** Three-tier rhythm inside every concept: motivation → mechanism → reference.
- **Cross-cutting concerns get their own chapter at peer level** rather than being nested. Testing is a first-class citizen, not a sub-chapter of Core.
- **Languages chapter sits as a sibling** to other concept chapters — language-specific guidance is consolidated, not fragmented.
- **Section titles use API names verbatim** (`@Autowired`, `@Transactional`, `ProxyFactoryBean`) — reference sections are searchable by the literal token developers will type.

Voice is formal, authoritative, and reference-flavored throughout. There is little narrative; it reads like a technical specification.

---

## 5. Next.js — dual-track concept + reference

**Source:** <https://nextjs.org/docs>

Top-level: Getting Started (linear tutorial-ish) → Guides (recipe library) → API Reference → Architecture → Community. Two parallel router tracks (App Router / Pages Router) exist as siblings because two audiences need them.

The **linear "Getting Started" path** (Installation → Project Structure → Layouts → Linking → Server/Client Components → Fetching → Mutating → Caching → Revalidating → Error → CSS/Images → Metadata → Route Handlers → Deploying → Upgrading) is the modern gold standard for a 15-step onboarding ramp. Each step is short enough to consume in ~5 min and each ends with the next link.

API Reference is partitioned into **Directives / Components / File-system conventions / Functions / Configuration / CLI / Adapters**. This is a clean separation of "things you type" (CLI, directives), "things you place at a path" (file conventions), and "things you import" (functions, components).

**Migrating** lives under Guides, not its own chapter — version migrations are treated as a recurring task, not a special topic.

---

## 6. Kubernetes docs — many subsystems, deep concept tree

**Source:** <https://kubernetes.io/docs/home/>

Top-level: Concepts → Tasks → Tutorials → Reference → Contribute. The cleanest Diataxis-aligned site for a system with many subsystems.

The Concepts section is sub-organized into **~13 functional domains**: Overview, Cluster Architecture, Containers, Workloads, Services-Networking, Storage, Configuration, Security, Policies, Scheduling, Cluster Administration, Windows, Extending. This is the pattern we want for a complex multi-component system like our harness.

Tasks vs. Tutorials separation is crisp:

- **Tutorials = guided learning** ("Hello Minikube", "WordPress with MySQL"). Build a complete thing.
- **Tasks = discrete how-tos** organized by administrative domain. "Install Tools", "Administer a Cluster", "Configure Pods", "Debugging", "Manage Secrets", etc.

Reference partition: API Reference (by resource type) / CLI Reference (kubectl) / Configuration APIs (file schemas) / Component Tools (kube-apiserver, kubelet) / Access Control / Instrumentation / Setup Tools. This **8-way reference split** is a clear demonstration that "Reference" is often itself a tree, not a flat section.

---

## 7. HashiCorp Terraform — IaC primitives at scale

**Source:** <https://developer.hashicorp.com/terraform/docs>

Top-level: Introduction → Manage Infrastructure (Configuration Language + CLI) → Collaborate (HCP/Enterprise) → Develop and Share (Plugins, Modules, Registry) → Resources (Tutorials, Certifications, Community).

Two patterns worth borrowing:

- **"Phases of Terraform adoption"** treats scaling as a documented lifecycle — small team adoption, multi-team, enterprise. Our harness has analogous adoption phases (solo dev → small autonomous loop → multi-agent orchestration).
- **"Terraform vs. Alternatives"** placed early lets a prospective user compare *before* committing. We should consider an early "Why use this harness vs. raw Claude Code / other agent frameworks?" section.

The Develop-and-Share separation (Plugins / Modules / Registry) cleanly distinguishes **extension authoring** from **extension consumption** — a distinction we need for skills/hooks/subagents authoring vs. usage.

---

## 8. Pro Git — book-style deep-dive

**Source:** <https://git-scm.com/book/en/v2>

Ten linear chapters with a clear practical→theoretical arc:

1. Getting Started — concept + install
2. Git Basics — daily operations
3. Git Branching — branches/merge/rebase
4. Git on the Server — hosting
5. Distributed Git — workflows
6. GitHub — platform integration
7. Git Tools — advanced operations
8. Customizing Git — config/hooks/attributes
9. Git and Other Systems — interop
10. Git Internals — plumbing/porcelain, objects, refs, packfiles

Plus three appendices: Other Environments (IDEs/shells) / Embedding Git (libgit2 etc.) / Git Commands reference.

The book voice is **explain-then-show**: each section opens with the "what" and "why" before any command. It is the gold standard for a project that wants its docs read cover-to-cover by a serious adopter. **Internals is the final chapter, not the first** — but it *is* a chapter, treated as essential for true mastery.

For a harness whose contributors will eventually want to understand the lifecycle hook state machine, the memory tier promotion algorithm, and the telemetry aggregator, this "internals as final chapter" placement is exactly right.

---

## Cross-pattern synthesis

Aggregating across all eight:

1. **Every framework uses Diataxis in some form**, whether they cite it (Django, Kubernetes) or arrive at it organically (Rails: Start Here / Guides / Reference / Contributing).
2. **A linear ~10-15-step Getting Started flow is universal.** Next.js, Django Tutorial Part 1-8, Rails Getting Started, Pro Git Chapter 1.
3. **Conceptual chapters are organized by domain**, not by Diataxis category. Diataxis lives inside each domain (Django's topics+ref pairing; Spring's "Understanding X / Using X / X API" rhythm).
4. **Reference is itself a tree** (Kubernetes 8-way split, Next.js 7-way split). Plan for it.
5. **A dedicated "Extending / Contributing / Plugin Authoring" chapter is universal** and follows the Rails pattern: concept foundation → decision tree → running example → tests-as-docs.
6. **Internals/Architecture is late but present.** Pro Git Chapter 10, Spring's AOT subsection, Next.js Architecture section. Required for credibility with serious adopters.
7. **Voice differs by chapter.** Tutorials are warm and first-person plural; references are neutral and complete; explanations are discursive and may opine; how-tos are imperative and assume competence. Mixed voice within a chapter is a smell.
8. **Cross-cutting concerns (security, testing, performance, observability) get peer-level placement**, not nested under feature chapters. This signals their cross-cutting nature.
9. **Migration / upgrading guides are treated as recurring tasks**, not special topics — they live under Guides/How-tos, possibly with version-bucketed sub-pages.
10. **Glossary + Community + Policies/Governance are first-class footer chapters**, not afterthoughts.

---

## Recommended TOC blueprint for the StockForge harness docs

This blueprint takes the best of all eight sources, applied to a meta-framework on Claude Code with skills, commands, subagents, hooks, constitution, ADRs, session/plan lifecycle, multi-tier quality gates, memory systems, drift detection, and self-healing watchdogs.

Every section is tagged with its **Diataxis quadrant** (T=Tutorial, H=How-to, R=Reference, E=Explanation).

### 1. Introduction (E)
- 1.1 What is the harness, and what problem does it solve? (E)
- 1.2 The harness vs. raw Claude Code vs. other agent frameworks (E)
- 1.3 Mental model: skills + commands + subagents + hooks + constitution + memory (E)
- 1.4 When to use the harness, when not to (E)
- 1.5 How this documentation is organized (E) — explicit Diataxis statement

### 2. Getting Started (T)
A linear 10-step tutorial that produces a working harness-driven session.
- 2.1 Install prerequisites
- 2.2 Bootstrap a project with `attach`
- 2.3 Run your first `/session-start`
- 2.4 Use a built-in skill (e.g., `decompose-work`)
- 2.5 Invoke a slash command
- 2.6 Dispatch a subagent
- 2.7 Watch hooks fire (open the telemetry stream)
- 2.8 Close the session and observe memory updates
- 2.9 Review what just happened (post-tutorial debrief)
- 2.10 Where to go next

### 3. Core Concepts (E)
Each sub-section is pure explanation — the "why" of the harness.
- 3.1 Sessions and the session lifecycle
- 3.2 The four agent surfaces: skills, commands, subagents, hooks
- 3.3 The constitution: charter, invariants, boundaries, drift signals
- 3.4 Memory tiers: working / session / project / agent-notes / charter
- 3.5 ADRs and the decision record discipline
- 3.6 Quality gates: deterministic (T1), probabilistic (T2), human (T3)
- 3.7 Calibration, drift, and self-correction
- 3.8 The autonomy spectrum: supervised vs. full-autonomous

### 4. Skills (E + R + H pairing per Django pattern)
- 4.1 Skills concept (E)
- 4.2 Built-in skills catalog (R)
- 4.3 How to write a new skill (H) — using `write-a-skill` as the meta-example
- 4.4 Skill activation triggers and progressive disclosure (E)
- 4.5 Skill reference: `SKILL.md` schema (R)

### 5. Commands (E + R + H)
- 5.1 Commands concept and when to choose a command vs. a skill (E)
- 5.2 Built-in command catalog (R) — `/session-start`, `/master-plan`, `/grill-me`, etc.
- 5.3 How to author a new command (H)
- 5.4 Command file format reference (R)

### 6. Subagents (E + R + H)
- 6.1 Subagent concept — fresh context, scoped tool access, role isolation (E)
- 6.2 Built-in subagent catalog (R)
- 6.3 How to define a new subagent (H)
- 6.4 Dispatching subagents from the main session (H)
- 6.5 Subagent definition reference (R)

### 7. Hooks and the Lifecycle (E + R + H)
- 7.1 Hook event model (E) — SessionStart, UserPromptSubmit, Stop, etc.
- 7.2 Built-in hooks catalog (R)
- 7.3 How to write a new hook (H)
- 7.4 Hook configuration reference: `settings.json` schema (R)
- 7.5 Cross-platform gotchas: Windows env-var passing, PowerShell vs Bash (E)
- 7.6 Diagnosing hook failures (H) — pairs with `hook-diagnostics` skill

### 8. The Constitution (E + R)
- 8.1 What the constitution is and why it exists (E)
- 8.2 Architecture rules (R)
- 8.3 Invariants (R)
- 8.4 VBW protocol (R)
- 8.5 Drift signals DR1-DR12 (R)
- 8.6 Boundaries: what agents cannot do (R)
- 8.7 Charter immutability and revision protocol (E)

### 9. Memory and Self-Awareness (E + R + H)
- 9.1 Memory tier overview (E)
- 9.2 `project.md`, `current-execution.md`, `agent-notes.md`, `mistake-log.md` (R)
- 9.3 Session memory L0/L1 extraction (E + R)
- 9.4 Self-awareness profile cards (E + R)
- 9.5 Rule promotion lifecycle: notes → skill → hook → charter (E)
- 9.6 How to trigger a manual promotion cycle (H)

### 10. Sessions and Planning (E + H)
- 10.1 Session types and budgets (E + R)
- 10.2 The PLAN / IMPL / VERIFY / RECOVERY / THESIS rhythm (E)
- 10.3 How to author a session plan (H)
- 10.4 The `/grill-me` and `/devils-advocate` adversarial cycle (H)
- 10.5 Closing a session correctly (H)

### 11. Quality Gates and Verification (E + H + R)
- 11.1 Three-tier gate model (E)
- 11.2 Deterministic gates: mypy, pytest, ruff, drift-signals (R)
- 11.3 Probabilistic gates: spec alignment, UL consistency, calibration (E + H)
- 11.4 Human gates: charter / ADR / eval-regression sign-off (E)
- 11.5 Verify-Before-Write protocol (R) — pulled out of constitution for prominence

### 12. Operations & Observability (E + H + R)
- 12.1 Telemetry pipeline (E)
- 12.2 The component-telemetry / sessions-rollup feeds (R)
- 12.3 Reading drift signals (H)
- 12.4 Budget watchdog: context-threshold band and auto-reboot (R)
- 12.5 Tracking retention and rotation policies (R)

### 13. Recipes & How-To Library (H)
A Django-style centralized how-to hub for tasks that don't fit cleanly under a single concept chapter.
- 13.1 How to migrate a project from raw Claude Code to the harness
- 13.2 How to add a deny-list permission across the team
- 13.3 How to compose a multi-agent dispatch chain
- 13.4 How to triage a stuck hook
- 13.5 How to author a new ADR and link it to a charter principle
- 13.6 How to delegate to CCS profiles (kimi/glm) safely
- 13.7 How to handle a failed deterministic gate without bypassing
- 13.8 How to recover from a context-cliff session reboot

### 14. Architecture and Internals (E)
Pro Git Chapter 10 placement: late, deep, optional for casual users but essential for serious contributors.
- 14.1 Hook event state machine
- 14.2 Transcript cache and aggregator design
- 14.3 Memory promotion algorithm
- 14.4 Subagent dispatch and context isolation
- 14.5 Telemetry storage and rotation
- 14.6 The harness/business/personal three-layer model and `manifest.yaml`

### 15. Extending the Harness (Rails plugin pattern: T + H)
- 15.1 What extensions look like (E) — three classes: skill, command, hook
- 15.2 Decision tree: should this be a skill, a command, a hook, or a subagent? (E)
- 15.3 Tutorial: build a complete custom "domain-linter" hook end-to-end (T) — single running example, like Rails' ApiBoost
- 15.4 Packaging extensions for reuse across projects (H)
- 15.5 Publishing an extension pack (H)

### 16. Contributing to the Harness (H + E)
- 16.1 Contributor workflow
- 16.2 Code style, test discipline, ADR requirement
- 16.3 Charter-change protocol (human-only)
- 16.4 Release cadence and versioning policy

### Appendices
- A. Glossary (R) — ubiquitous language, alphabetical
- B. Settings reference (R) — every key in `.claude/settings.json`
- C. CLI reference (R) — every command, flag, exit code
- D. Hook event catalog (R) — every event, its payload, its lifecycle position
- E. Skill / Command / Subagent / Hook frontmatter schemas (R)
- F. Default permission policy (R) — allow/deny matrix
- G. Migration notes (H) — version-bucketed upgrade guides
- H. FAQ and Troubleshooting (E + H)
- I. Bibliography and prior art (E) — Diataxis, Karpathy autoresearch, DDD, etc.

---

## Diataxis coverage check

Counting the 16 chapters + appendices against the four quadrants:

- **Tutorial (T):** Ch. 2 Getting Started, Ch. 15.3 Extending tutorial — 2 anchors, sufficient.
- **How-to (H):** Ch. 4-7 author sections, Ch. 9.6, Ch. 10.3-10.5, Ch. 11.3, Ch. 12.3, Ch. 13 (entire), Ch. 15.4-15.5, Ch. 16, App. G — generously distributed.
- **Reference (R):** Ch. 4-9 reference sections, Ch. 8 constitution, Ch. 10.1, Ch. 11.2/11.5, Ch. 12.2/12.4/12.5, Apps A-F — partitioned reference tree mirrors the system.
- **Explanation (E):** Ch. 1 entire, Ch. 3 entire, opening of every concept chapter, Ch. 14 entire, Ch. 15.1-15.2 — discursive material is segregated.

All four quadrants present in every concept chapter where appropriate (Django pattern), with a centralized how-to hub (Ch. 13) for cross-cutting recipes and a centralized internals chapter (Ch. 14) for serious adopters (Pro Git pattern).

---

## Voice guidance per chapter type

| Chapter type | Voice | Example tone |
|---|---|---|
| Introduction / Explanation | Discursive, may opine, uses analogy | "The harness exists because raw Claude Code drifts under long-horizon work…" |
| Getting Started Tutorial | First-person plural, warm, celebratory | "Let's bootstrap your first project. You'll see…" |
| Concept chapter opener | Authoritative but explanatory (Spring style) | "The session lifecycle has five phases. Understanding them is essential before…" |
| How-to section | Imperative, assumes competence (recipe style) | "If you want to add a deny-list permission, edit `.claude/settings.json` and…" |
| Reference page | Neutral, exhaustive, schema-first | "**`SessionStart`**. Fires once per session. Payload: `{session_id, model, …}`." |
| Internals | Technical, layered, may include diagrams | "The hook event state machine has four observable transitions…" |

---

## Sources

- Diataxis framework. <https://diataxis.fr/>, <https://diataxis.fr/foundations/>, <https://diataxis.fr/tutorials/>, <https://diataxis.fr/how-to-guides/>, <https://diataxis.fr/reference/>, <https://diataxis.fr/explanation/>
- Django documentation. <https://docs.djangoproject.com/>
- Ruby on Rails Guides. <https://guides.rubyonrails.org/>, <https://guides.rubyonrails.org/getting_started.html>, <https://guides.rubyonrails.org/plugins.html>
- Spring Framework reference. <https://docs.spring.io/spring-framework/reference/index.html>
- Next.js documentation. <https://nextjs.org/docs>
- Kubernetes documentation. <https://kubernetes.io/docs/home/>
- HashiCorp Terraform documentation. <https://developer.hashicorp.com/terraform/docs>
- Pro Git book (2nd edition, Chacon & Straub). <https://git-scm.com/book/en/v2>
