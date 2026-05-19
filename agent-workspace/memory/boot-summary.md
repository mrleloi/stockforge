---
rendered_at: 2026-05-19T01:30:55+07:00
cache_ttl_hours: 1
purpose: compact-bootstrap-context-for-reboot
fallback: read current-execution.md + checkpoint/latest.md if mtime > 1h or content stale
---

# Boot Summary — auto-rendered (compact reboot context)

> Per L-S65-reboot-cost-reduction. Read FIRST at SessionStart; full chain only if ambiguous.

## Active session/phase/track
## 🚨 INCIDENT + RECOVERY — 2026-05-14 mass-deletion (RESOLVED — archived)

## Recent ADRs (last 5; review for binding context)
```
083-vhm-pdf-dogfood-and-bc2-integration.md
082-pdf-claude-vision-adapter-and-echo-validator.md
081-br-6-cost-cap-empirical-recalibration.md
080-pdf-table-extractor-port-and-library-winner.md
079-pre-commit-pytest-regression-guard.md
```

## Recent mistakes (last 3 M-S<N>-<M>)
```
| M-S147-1 | S147 | medium | Failed to apply Forward Policy for catch-rate=0 ritual demotion. Post S141 PROMOTION (AUTO-MIGRATE hook), agent self-scheduled per-session DOGFOOD-N+1 verification expectation in successive checkpoints S141→S146 (6 carr ...(truncated; see mistake-log.md)
| M-S289-1 (FIX-SHIPPED-S290; L-S289-1 PROMOTED to bash-hook-lint Check 11) | S289 | high-resolved | session-self-reboot.sh HH-H.5a rate-limit TOCTOU recurrence (M-S48e-1 same family): non-atomic `[ -f marker ]` + AGE_S check + regular `>` write at l ...(truncated; see mistake-log.md)
| M-S171-1 (FIX-SHIPPED-S175 / D-037) | S171→S175 | high→resolved | Post-S147-retirement idle-loop heuristic too narrow → 22 consecutive ROUTINE-IDLE/META-CADENCE sessions S148-S170 with zero substantive progress. Heuristic checks user_prompt/  ...(truncated; see mistake-log.md)
```

## In-flight subagent dispatch (M-S64-1 prevention check)
(empty — no in-flight dispatch)

---
**Bootstrap reads remaining** (cheap follow-up):
- routing-config.md (model × effort)
- queued-grill-master.md (deferred Q&A triggers)
- last 1 session log (semantic continuity)

Full chain (if boot-summary stale > 1h or content ambiguous):
- agent-workspace/memory/checkpoints/latest.md
- agent-workspace/memory/current-execution.md (top section only)
- last 3 sessions/* logs
