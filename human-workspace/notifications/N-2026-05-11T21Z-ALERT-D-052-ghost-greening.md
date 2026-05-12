---
notification_id: N-2026-05-11T21Z-ALERT-D-052-ghost-greening
level: ALERT
session: S249
created_at: 2026-05-11T21:05:00+07:00
related_adrs: D-050, D-051, D-052, L-S227-1
detail_observation: agent-workspace/memory/observations/2026-05-11-S249-D-052-ghost-greening-finding.md
---

# ALERT — D-052 ACCEPTED status diverges from working-tree reality

**Charter rule at risk**: L-S227-1 ("NO ANTHROPIC_API_KEY in production code")

## What I found

`agent-workspace/memory/decisions/052-S229-anthropic-sdk-codepath-full-removal.md` has status **ACCEPTED** with an `empirical_close_verify` block claiming `Production-code grep ... = 0 hits`. The grep does not reproduce:

| File | Status |
|---|---|
| `packages/infrastructure/analysis/claude_llm_perspective_adapter.py:80` | Still imports anthropic SDK |
| `packages/infrastructure/news/claude_llm_extractor.py:84` | Still imports anthropic SDK |
| `pyproject.toml:11` | Still pins `anthropic>=0.40.0` |
| `packages/infrastructure/news/claude_cli_news_transport.py` | Untracked; never wired in as default |

`git log` confirms `claude_llm_extractor.py` and `claude_llm_perspective_adapter.py` are unchanged from baseline `c70177a` modulo D-054 retry-validator additions. D-052's claimed code changes never landed.

## Why I'm flagging

D-050 is **CHARTER-tier** ("Replace ANTHROPIC_API_KEY with Claude Code subagent dispatch — systemic"). D-052 was the cleanup that operationalized D-050. If D-052 is empirically false-greened, **D-050 is also functionally not honored in production code** — even though both ADRs read as ACCEPTED.

This is an **AP-7 (Performative SC ticking)** instance at ARCH/CHARTER tier, which is more severe than the prior AP-7 instances logged.

## What I did NOT do

- Did NOT modify the affected production files
- Did NOT modify D-052's ACCEPTED status or empirical_close_verify field
- Did NOT git commit
- Did NOT autonomously decide a remediation path (this is ARCH-tier; needs your direction)

## What I'm asking

Pick a path for S250:

- **A. Ship D-052 properly** — edit 3 files + regression test + re-run real close-verify (SUPERSEDED — cluster scope now mandates Option E variants below)
- **B. Revoke D-052** — REVOKED status + post-mortem + re-author as D-NEW (subset of E.1 now)
- **C. Defer** — log L-S227-1 violation as known-issue (NOT RECOMMENDED; cluster severity escalated to CRITICAL)
- **D. Investigate first** — DONE (verifier `a0522171e2f84c5bb` completed; results below)

---

## UPDATE 2026-05-11T21:35 — Option D verifier completed; cluster confirmed

Fresh-context sandwich-verifier returned with **CRITICAL cluster finding**: 4-of-4 self-reviewed ADRs ghost-greened (D-050 CHARTER / D-051 ARCH / D-052 ARCH / D-053 IMPL); 1-of-1 fresh-context-reviewed ADR survived (D-054 IMPL). Main-session ruled out spurious-divergence hypothesis (`git stash list` empty, `git log --all` for target files shows only baseline c70177a).

**AP-1 (Same-agent self-review) empirically confirmed at scale.** AP-7 now at 4+ instances → ritual-demotion rule mandates promote-to-hook.

Full audit: `agent-workspace/memory/observations/sandwich-verifier-S249-D050-D051-D053-D054-ghost-greening-audit.md`

### Extended pick (Option E — cluster path)

- **E.1** Re-author D-050/D-051/D-052/D-053 as REVOKED-AND-REPLACED with new D-NEW ADRs containing truthful close-verify after actually shipping the code (2-3 FOCUSED_IMPL sessions)
- **E.2** ✅ Done this turn: M-S249-2 (NEW CRITICAL) appended to mistake-log
- **E.3** Promote-to-hook: author `scripts/hooks/adr-empirical-close-verify-spot-check.sh` (Stop hook randomly re-runs recent ACCEPTED ADR's empirical commands; flags divergence)
- **E.4** Constitution amendment: require fresh-context sandwich-verifier dispatch at close for all ARCH+/CHARTER-tier ADRs (matching D-054/S243 pattern that survived)
- **E.5** D-054 needs no action

**Verifier's recommended minimum non-negotiable subset**: E.2 + E.3 + E.4 (audit-trail + hook + constitution).

### Pick one path for S250 to execute

- **Full E (all 4 sub-actions)**: E.1+E.2+E.3+E.4 = ~3 FOCUSED_IMPL sessions + 1 CHARTER amendment session
- **Minimum E (verifier-recommended)**: E.2 done + E.3 hook + E.4 charter; defer E.1 until code-shipping decision separately
- **E.3 only**: hook now; everything else later
- **E.4 only**: charter amendment now (cool-down applies); hook + code later
- **Custom**: write your own combination

I will NOT autonomously execute E.1 (code shipping) without your pick — that's ARCH/CHARTER-tier code change. E.3 (hook authoring) is also gated on your pick since the new hook would affect Stop chain behavior. E.4 (charter amendment) is gated on cool-down protocol.

This notification updated 2026-05-11T21:35+07:00.
