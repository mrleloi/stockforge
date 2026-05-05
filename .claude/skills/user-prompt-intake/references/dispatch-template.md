# Dispatch Template — Intent Classifier Subagent

> Copy-paste prompt for the dispatcher (main session) when invoking `intent-classifier` per `user-prompt-intake/SKILL.md` Step 2.

## Template

```
You are classifying a user prompt for the StockForge project.

PROMPT TO CLASSIFY:
"""
{verbatim prompt text — either the chat content, or the file content if path}
"""

PROMPT SOURCE: {inline-chat | path/to/user_prompt/20260429_NN_slug.txt}
PROMPT MTIME: {ISO timestamp if file, null if inline}

PROJECT CONTEXT (read these as needed):
- agent-workspace/memory/current-execution.md       # active phase + open Q&A
- agent-workspace/memory/decisions/README.md        # decision history index
- PROJECT_CHARTER.md § Identity-Scope (top of file) # what stockforge is/isn't
- agent-workspace/memory/patterns-discovered/SYNTHESIS.md § F (NOT-list)

LATEST AGENT MESSAGE (if relevant):
"""
{last assistant message — for context on whether a "no"/"yes" is reply to a charter-tier question}
"""

INSTRUCTIONS:
1. Classify per your spec (`.claude/agents/intent-classifier.md`).
2. Output a SINGLE YAML block, nothing else.
3. Compute prompt_hash = first 8 hex chars of sha256(prompt text).
4. If `recommended_action ∈ {OPEN_QA_BUNDLE, ESCALATE_HUMAN}`, propose 5-15 grill questions.
5. After YAML, write the observation file `agent-workspace/memory/observations/intent-<UTC-TS>-<hash>.md`.

Return only the YAML.
```

## Notes for dispatcher

- Substitute `{...}` placeholders in the template before sending.
- The dispatcher (main session) holds responsibility for:
  - Computing prompt_hash if subagent can't (Bash sha256).
  - Verifying YAML well-formed.
  - Acting on `recommended_action` (or overriding with documented reason).
- Subagent must NOT decide the action — only recommend.

## Variant: file-based dispatch

If the user dropped a file in `human-workspace/user_prompt/`:

1. Compute hash and timestamp BEFORE dispatch:
   ```bash
   sha256sum human-workspace/user_prompt/<file>.txt | cut -c1-8
   stat -c "%y" human-workspace/user_prompt/<file>.txt
   ```
2. Pass both into the dispatcher template.
3. Subagent will Read the file content fresh.

## Variant: chat-based dispatch

If the user typed in chat:
- `PROMPT SOURCE: inline-chat`
- `PROMPT MTIME: null`
- `prompt_hash`: dispatcher computes from raw chat text (use `Bash` `echo "..." | sha256sum`).

## Failure mode handling

If the subagent returns malformed YAML:
1. ONCE: re-dispatch with "Your previous output was not valid YAML. Output ONLY a single YAML block."
2. If still malformed: log the failure to `agent-workspace/memory/observations/intent-FAIL-<TS>.md` and treat the prompt as `ESCALATE_HUMAN`.
