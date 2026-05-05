# Procedures — Bash + Body Templates

> Companion to `qa-escalation/SKILL.md`. Detail extracted to keep SKILL.md ≤150 LOC.

## Step 2 — Filename + frontmatter computation

```bash
TS=$(date -u +%Y-%m-%d)
SEQ=$(ls human-workspace/q-and-a/pending/${TS}-*.md 2>/dev/null | wc -l)
NEXT=$(printf "%03d" $((SEQ+1)))
SLUG="<short-slug>"   # e.g. rust-vs-python-observability
FILE="human-workspace/q-and-a/pending/${TS}-${NEXT}-${SLUG}.md"

OPENED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# expected_answer_by per priority
case "$PRIORITY" in
  URGENT) HOURS=4 ;;
  NORMAL) HOURS=24 ;;
  LOW)    HOURS=72 ;;
esac
EXPECTED=$(date -u -d "+${HOURS} hours" +%Y-%m-%dT%H:%M:%SZ)

# prompt_hash (if classified from a prompt)
HASH=$(echo -n "$PROMPT" | sha256sum | cut -c1-8)
```

## Step 3 — Body template

```markdown
# Q&A Bundle — <topic>

## Headline

<2-3 lines: what decision hinges on this bundle, what defaults apply if unanswered, which Confidence Score categories update.>

## Cluster A — <name>

**Evidence:**
- <path:line or section>
- <path:line or section>

### Q1: <question>
- A: <option>
- B: <option>
- C: <option>
- D: open answer
- **Default**: <letter>

### Q2: <question>
…

## Cluster B — <name>
…

## Answer Section (human fills below)

> Reply inline as "QN: <option-letter>" or free prose. Skip questions to accept defaults.
> When done, MOVE this file to `human-workspace/q-and-a/answered/`.
> File-move is the trigger; do not edit-in-place to confirm.

- Q1: 
- Q2: 
- Q3: 
- …

## Notes from human (free text, optional)

<empty — human can add free text>
```

(Full skeleton in `sample-bundle.md`.)

## Step 4 — URGENT notification template

Path: `human-workspace/notifications/N-<TS>-ALERT-<slug>.md`

```markdown
---
id: N-<TS>-ALERT-<slug>
level: ALERT
created_at: <ISO>
related_bundle: human-workspace/q-and-a/pending/<bundle-file>
expires_at: <expected_answer_by>
---

# ALERT — <topic>

URGENT Q&A bundle opened at <opened_at>. Decision blocking: <reason>.
Default action if not answered by <expected_answer_by>:
- <action>

Bundle: <link>

Sync categories: <list>
```

For NORMAL/LOW, NO notification — file alone is enough (mobile claude.ai shows recent files).

## Reading Answered Bundles — full procedure

When SessionStart hook (Track 5) detects new files in `human-workspace/q-and-a/answered/`:

1. **Read** the bundle.
2. **Parse human's replies**:
   - Look for `Q<N>:` patterns at line start in Answer Section.
   - Optional free-prose reply blocks following `Q<N>:` line.
3. **For each question**:
   - Reply present → record answer.
   - Reply blank → use bundle's documented default (`**Default**: <letter>`).
4. **Update related decision(s)**:
   - Append `approval_chain: actor: user / action: ANSWERED / at: <human's file mtime> / via: <bundle-file>`.
   - For each answer that resolves an option, update `chosen` or amendments.
5. **Update Confidence Score** (Track 8a, when online):
   - For each `sync_category`, register a +1 sync event per `weights.yaml`.
6. **Set status**: edit bundle frontmatter `status: processed` (in `answered/` — but Write-deny prevents agent edits there; resolution: hook does it, OR write sidecar `<bundle>.processed`).
7. **Record observation**: `agent-workspace/memory/observations/qa-answered-<bundle-id>.md`.

## Stale Bundle Handling — full hook example

Track 5 SessionStart hook (`scripts/hooks/qa-pending-stale-mover.sh`):

```bash
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
for f in human-workspace/q-and-a/pending/*.md; do
  [ ! -f "$f" ] && continue
  expected=$(awk '/^expected_answer_by:/ {print $2}' "$f")
  if [[ "$expected" < "$NOW" ]]; then
    mv "$f" human-workspace/q-and-a/stale/
    echo "[stale-mover] moved $f past $expected"
  fi
done
```

When agent finds bundles in `stale/`, it MUST:
1. Apply documented defaults for each question.
2. Increment `defer_cycle` on related decisions.
3. If `defer_cycle > 3`, escalate via notification.

## Edge Cases

See `lifecycle-state-machine.md` for:
- Human edits in `pending/` instead of moving
- Bundle answered after stale move
- Bundle superseded mid-flight
- Hook moves wrong file (timezone bug)
