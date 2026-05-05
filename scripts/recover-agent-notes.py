"""One-shot recovery of agent-notes.md from cached CCS transcripts.

Provenance:
  - Lines 1..314: 31a5f363-a178-41f8-b688-67b1b4cb7e41.jsonl:L33 (largest cached Read)
  - Lines 455..470: agent-abee75e2518d36e62.jsonl:L67 (S45 subagent partial Read at offset=455)
  - Lines 315..454: UNRECOVERABLE (gap marker inserted; no fabrication per Charter)
"""
import json, re, io, sys
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

P1 = r'C:\Users\PC\.ccs\instances\nathanleewindy\projects\C--htdocs-stockforge\31a5f363-a178-41f8-b688-67b1b4cb7e41.jsonl'
P2 = r'C:\Users\PC\.ccs\instances\nathanleewindy\projects\C--htdocs-stockforge\44d99ce2-11d1-4298-baca-270a7454afa2\subagents\agent-abee75e2518d36e62.jsonl'
TARGET = r'C:\htdocs\stockforge\agent-workspace\memory\agent-notes.md'

def extract_text(path, line_idx_zero):
    with open(path, 'r', encoding='utf-8') as f:
        ev = json.loads(f.readlines()[line_idx_zero])
    c = ev['message']['content'][0]['content']
    if isinstance(c, list):
        c = next(s['text'] for s in c if s.get('type') == 'text')
    return c

def strip_lineno(s):
    out = []
    for line in s.split('\n'):
        m = re.match(r'^\s*\d+\t(.*)$', line)
        out.append(m.group(1) if m else line)
    return '\n'.join(out)

HEAD = strip_lineno(extract_text(P1, 32)).rstrip('\n')
TAIL = strip_lineno(extract_text(P2, 66)).rstrip('\n')

GAP = """

<!-- ===========================================================================
     RECOVERY GAP MARKER -- lines 315..454 of original agent-notes.md
     ===========================================================================
     The original agent-notes.md (~470 LOC, 48 dated entries) was destructively
     overwritten by the S45 sandwich-architect subagent (agent abee75e2518d36e62)
     on 2026-05-05 ~07:47 +07:00 via Write-instead-of-Edit. See L-S45-1 + L-S45-2
     entries appended below.

     RECOVERY SOURCES used (verifiable from cached LLM transcripts):
       * Lines 1..314 -- restored verbatim from
         31a5f363-a178-41f8-b688-67b1b4cb7e41.jsonl:L33 (largest cached Read of
         the original file; covers Phase 0 Track 5.5d era end)
       * Lines 455..470 -- restored verbatim from
         agent-abee75e2518d36e62.jsonl:L67 (S45 subagent partial Read at
         offset=455 BEFORE the destructive Write at L72/L84)

     RECOVERY GAP -- lines 315..454 (~140 lines / ~30K chars) NOT IN ANY
     CACHED TRANSCRIPT located 2026-05-05. Per Charter "every claim has source
     + as-of date" + no-fabrication rule, gap content is NOT reconstructed by
     inference. The following lesson IDs are KNOWN to have lived in this gap
     (cited in checkpoints/sessions/current-execution.md) but their FULL BODY
     TEXT is unrecoverable from cache:
       L-S15-1 (inline-document IMPL deviations doctrine)
       L-S17-1 (SQLite portability binding)
       L-S19-1 (deterministic Stop-hook aggregator)
       L-S20-1 (Bash permission-matcher pattern)
       L-S25-1 / L-S26-1 / L-S28-1 (Phase 1 lessons cluster)
       L-S30-1 (VBW pre-flight Glob-before-Read)
       L-S32-1 (empirical-probe-first; promoted to skill at S43e cont 3)
       L-S34-1 / L-S35-N cluster (Track C + META_LOOP_RECOVERY)
       L-S43b-1..10 cluster (harness-recovery + LLM substrate boundary patterns;
                              promoted to charter at S43f via D-026)
       L-S43c-N cluster (rule-application discipline; partially promoted)
       L-S43d-1 (sonnet timeout cascade @ concurrency>=5)
       L-S43d-2 ($0-marginal substrate revalidation)
       L-S43e-1 (VF-5 emptiness root-cause taxonomy: Path A substrate-not-bug)

     For forensic reconstruction of any specific lesson body, primary sources
     in priority order:
       (1) checkpoints/latest.md -- has narrative summaries citing each L-S*
       (2) memory/sessions/2026-05-0*-session-43*.md -- session logs of S43b..f
       (3) memory/observations/{vf5-calibration-S43e,promote-rule-S43c,
           defer-s43b-status-S43e,S43f-user-gate-bundle-closure}.md
       (4) memory/decisions/026-S43e-charter-promote-bundle-C1-C2.md
           -- D-026 ratifies BP-S43b-1/2/3 + KI-S43b-1/2/3 with full text
       (5) constitution/architecture.md sec "LLM Substrate Boundary"
           -- D-026 codifies what L-S43b cluster taught
       (6) constitution/decision-discipline.md sec Rule 4b
           -- D-026 codifies what L-S43b-7 / KI-S35-5 / BP-S35-1 taught

     DO NOT silently re-author lesson body text without citing the
     forensic source. If a lesson must be re-derived, mark it with
     "// RECONSTRUCTED 2026-05-05 from <source>" header.
     =========================================================================== -->

"""

NEW = """

### 2026-05-05 (S45 -- sandwich-architect data-loss incident): Pre-Staged Sequential Files Require VBW Read-Before-Write

**Context**: At S45 entry both target artifacts (`008-S45-track-G-H-I-impl-sub-plan.md` + `027-S45-BC-6-architecture-influence-network.md`) already existed on-disk pre-staged from a prior dispatch attempt at the same turn (sibling subagent `aa04f00730b40eb55` returned earlier with the same file targets). Initial Glob check on `008-*` returned "No files found" (PowerShell glob mismatch on stem-only pattern); a more specific path probe revealed both files present with comprehensive content already satisfying brief intent. The S45 sandwich-architect then attempted to author L-S45-1 by calling `Write` on `agent-workspace/memory/agent-notes.md` instead of `Edit` -- destructively overwrote ~470 LOC of accumulated learned rules with a ~40 LOC stub.
**Rule**: Before authoring any new sequential ADR (`memory/decisions/NNN-*.md`) or session plan (`session-plans/pending/NNN-*.md`), VBW pre-flight MUST: (1) Glob the exact target slug AND nearby numeric range with multiple patterns; (2) if file exists, Read existing content first; (3) compare to brief intent -- if existing satisfies, leave unchanged + bind via reference; if differs in non-trivial way, supersede with N+1 entry per Contract Rule #2 (sequential numbering never reused; append-mostly + supersession-status); NEVER silently overwrite.
**Why**: Pre-staged duplicate dispatches happen when an autonomous loop dispatches the same architect twice (parallel `continue` triggers, race conditions, or operator-replay). Without VBW the second dispatch destroys the first's output.
**How to apply**: SessionStart hook should scan `agent-workspace/{memory/decisions,session-plans/pending}/` for files created within last 24h matching active-session-id; warn agent of pre-staged artifacts before authoring.
**Anti-example**: Glob `008-*` returns empty -> assume absent -> attempt Write -> safety blocker fires -> re-read reveals 430-LOC pre-existing file. Wasted tool calls + near-miss data loss.
**Correct example**: Glob `008-*` AND `00[0-9]-S45*` AND specific filename path -> Read any hit -> compare to brief intent -> bind-by-reference if sufficient. Document inline as IMPL deviation per L-S15-1.
**Severity**: HIGH (data-loss adjacent; this turn the incident propagated to L-S45-2 which IS data-loss).
**Auto-detect**: PARTIAL -- Read-before-Write enforcement already present as tool-level safety. Add complementary detector: SessionStart hook scanning `agent-workspace/{memory/decisions,session-plans/pending}/` for files created within last 24h matching active-session-id; warn agent of pre-staged artifacts before authoring.
**Provenance**: S45 sandwich-architect dispatch 2026-05-05; existing `agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md` (153 LOC) + `agent-workspace/session-plans/pending/008-S45-track-G-H-I-impl-sub-plan.md` (430 LOC) discovered already-on-disk during VBW phase.
**Lesson candidate ID**: L-S45-1.

### 2026-05-05 (S45 -- sandwich-architect data-loss incident -- ROOT CAUSE): Use Edit Not Write For Append-Only Files

**Context**: Same incident as L-S45-1. The destructive moment was when the subagent -- having decided to add an L-S45-1 lesson per just-ratified Rule 4b -- called `Write(file_path=agent-notes.md, content=<just the new entry>)` instead of `Edit(file_path=agent-notes.md, old_string=<anchor>, new_string=<anchor>+<new entry>)`. `Write` overwrites the entire file; `Edit` performs surgical insertion. The tool-level Read-before-Write safety blocker DOES NOT FIRE if the file was Read earlier in the session (subagent had Read lines 1-40 + offset=455+ at L56/L66/L69 before L72/L84 Writes), so the Write was permitted. Result: ~470 LOC truncated to ~40 LOC. The repo has `git status` = "no commits yet" so `git checkout` recovery is impossible. Recovery achieved by extracting cached Read tool_results from CCS instance JSONL transcripts (verifiable provenance for lines 1..314 + 455..470; lines 315..454 LOST per recovery gap marker above).
**Rule**: For ANY file under `agent-workspace/memory/{agent-notes,project,decisions,observations,sessions,checkpoints,patterns-discovered,drift-logs,post-mortems,thesis-log,sync-tracker,self-awareness,mistake-log}.md` AND `agent-workspace/{constitution,session-plans,quality-reports,ubiquitous-language,calibration,research}/**/*.md`: append/insert via `Edit` ONLY. `Write` is reserved for genuinely new files (existence-check via Glob first). NEVER use `Write` on an existing append-mostly file even when "just adding one entry".
**Why**: `Write` semantics overwrite; `Edit` semantics surgical-replace. The Read-before-Write safety only blocks first-write of unread file; it does NOT prevent loss when the agent has read PARTIAL ranges.
**How to apply**: Default tool choice for any markdown file under `agent-workspace/memory/` or `agent-workspace/constitution/` is `Edit` with `old_string`=last-known-trailing-anchor + `new_string`=anchor+`\\n\\n<new entry>`. Only use `Write` for first-creation (Glob returns empty).
**Anti-example (this turn)**: Subagent dispatched at 2026-05-05 07:40, by 07:47 had truncated agent-notes.md from ~470 LOC to ~40 LOC by calling `Write` with just-the-new-entry-content + a self-authored "RECOVERY NOTICE" assuming git-tracked rollback. Repo had no git commits. Recovery required forensic transcript-mining + accepted ~140-line gap.
**Correct example**: To add L-S45-1, subagent should have: (1) Read full agent-notes.md OR Read tail with explicit offset to capture last anchor; (2) `Edit(old_string=<verbatim last 200 chars>, new_string=<same>+\\n\\n<L-S45-1 entry>)`. No risk of overwrite.
**Severity**: CRITICAL (actual data loss; ~140 LOC of accumulated learned rules permanently unrecoverable from cache; project memory degraded).
**Auto-detect**: HOOK CANDIDATE -- SessionStart or PreToolUse hook on `Write` events targeting `agent-workspace/memory/agent-notes.md` OR any path matching `agent-workspace/memory/**/*.md`: HARD-BLOCK with stderr "Use Edit not Write on append-mostly files; see L-S45-2"; allow only if explicit override flag in tool input. Highest-priority promotion target -- this rule must be MECHANICAL not LLM-judgment.
**Provenance**: S45 sandwich-architect (`agent-abee75e2518d36e62`) tool-event chain L56->L57->L66->L67->L69->L70->L72(WRITE 1570 chars destructive)->L75->L76->L84(WRITE 5131 chars recovery-notice). Recovery sources: `31a5f363-a178-41f8-b688-67b1b4cb7e41.jsonl:L33` (lines 1-314) + `agent-abee75e2518d36e62.jsonl:L67` (lines 455-470). Companion: L-S45-1 (pre-staged file VBW) -- same incident, different facet.
**Lesson candidate ID**: L-S45-2.
"""

OUT = HEAD + GAP + TAIL + NEW
with open(TARGET, 'w', encoding='utf-8') as f:
    f.write(OUT)
print(f'WROTE {TARGET}')
print(f'  chars={len(OUT)} lines={OUT.count(chr(10))}')
print(f'  HEAD lines={HEAD.count(chr(10))} TAIL lines={TAIL.count(chr(10))}')
