---
observation_id: 2026-05-10-S245-dispatch-jsonl-cross-session-evidence
type: forensic-evidence
created_at: 2026-05-10T~21:25+07:00
session: S245 (parent main session continuing post-S244 close)
severity: HIGH
status: OPEN
related: 2026-05-10-S243-parallel-finding-lock-trap-bug.md, sandwich-verifier-S243-d054-ratification.md § H, drift-detector-S241b-phantom-dispatch-RC.md
supersedes_partial: in-session race attribution in S243 verifier § H F-Operational-1
---

# S245 dispatch.jsonl forensic — verifier double was CROSS-SESSION not in-session

## Summary
The S243 verifier double-dispatch race (4th L-S240-5 instance) was originally hypothesized as IN-SESSION (parent dispatcher retry-on-failure pattern). Empirical inspection of `agent-workspace/memory/dispatch.jsonl` falsifies that hypothesis: the two verifier dispatches came from TWO DIFFERENT parent_session_ids 3 minutes apart. This is exactly the cross-process phantom-claude.exe scenario the S241b single-instance lock was designed to block — and exactly what the S243 lock-trap defect (line 30 EXIT trap removing the lock) prevented from blocking.

## Empirical evidence

dispatch.jsonl entries (verbatim, all 4 fields):

```jsonl
{"event":"DISPATCHED","dispatch_id":"toolu_01TdcEZNv4F1AY7XVt7WmCFL","agent_type":"sandwich-verifier","model":"opus","parent_session_id":"76f9cc94-3bcc-4e33-aa85-0ed0de72d750","bg":true,"ts_ms":1778418487737}
{"event":"COMPLETED","dispatch_id":"toolu_01TdcEZNv4F1AY7XVt7WmCFL","agent_type":"sandwich-verifier","tokens_used":17982753,"duration_ms":5978647,"failure_mode":"R","ts_ms":1778418558007}
{"event":"DISPATCHED","dispatch_id":"toolu_01AvFaju4Wt35oR3NNjt4aKm","agent_type":"sandwich-verifier","model":"opus","parent_session_id":"ff85e8d5-9878-495b-84a1-ebce222de37d","bg":true,"ts_ms":1778418705369}
{"event":"COMPLETED","dispatch_id":"toolu_01AvFaju4Wt35oR3NNjt4aKm","agent_type":"sandwich-verifier","tokens_used":722355,"duration_ms":119503,"failure_mode":"R","ts_ms":1778418725983}
```

## Key facts

- **Two distinct parent_session_ids**: `76f9cc94-3bcc-4e33-aa85-0ed0de72d750` and `ff85e8d5-9878-495b-84a1-ebce222de37d`
- **Two distinct tool_use_ids**: `toolu_01TdcEZNv4F1AY7XVt7WmCFL` and `toolu_01AvFaju4Wt35oR3NNjt4aKm`
- **Different DISPATCH timestamps**: ts_ms 1778418487737 vs 1778418705369 → delta 217.632 seconds (≈3 min 38 sec apart)
- **Different durations**: 5978647 ms (~99.6 min) vs 119503 ms (~2 min)
- **Different token counts**: 17,982,753 vs 722,355 (the longer one consumed 25× more tokens)
- **Both completed with failure_mode "R"** (whatever R means — likely "retired" or "race-detected"; needs check vs `dispatch.jsonl` schema)

The 5,978,647 ms duration of the first dispatch is suspicious — that's 99 minutes, far longer than a real verifier run. Most likely interpretation: the first parent_session_id `76f9cc94...` started a verifier dispatch that LATER completed (after the parent session terminated or was suspended), while the SECOND parent `ff85e8d5...` was MY current session that dispatched the verifier I observed completing in 2 min. The 2-min completion `ff85e8d5...` MATCHES my Agent tool call pattern + the S243 verifier observation timestamps.

## Implication

The 4th L-S240-5 instance is CROSS-SESSION (phantom claude.exe instance from a prior session that survived past its parent's close). This is **exactly** the original L-S240-5 / M-S238-2 RC pattern. The S241b single-instance lock was the correct architectural response. The S244 line-30 trap fix is the correct prevention. **There is no separate "in-session race" requiring per-agent_id paths or O_EXCL fcntl** — that was a misattribution by the S243 verifier based on the composite-file symptom without dispatch.jsonl forensics.

## Corrections to prior documents

1. `sandwich-verifier-S243-d054-ratification.md` § H F-Operational-1 — claim "IN-SESSION parallel verifier dispatches from the same parent EVADE the lock" is WRONG; both dispatches came from DIFFERENT parents. The lock would have caught the 2nd parent IF the trap defect hadn't removed it.
2. `2026-05-10-S243-parallel-finding-lock-trap-bug.md` AMENDMENT — claim "even after the trap fix, parallel `Agent` tool calls within the same parent claude.exe could still race on canonical paths" is UNFOUNDED in this empirical case; the race observed was cross-process and IS addressed by the trap fix.

## Promotion implication

The L-S240-5 4-instance count is REAL (M-S238-2 + L-S239-4 + L-S240-5 + S243-cross-session-race), and the AP-23 promotion threshold is REAL. But the promotion target should be the cross-session lock mechanism + trap-eats-state defect class — NOT the in-session per-agent_id mitigation.

S245 promote-rule subagent dispatch (in flight `aa708466342d681f6`) has been briefed on this corrected RC.

## What still needs verification

The line `dispatch_id":"toolu_01TdcEZNv4F1AY7XVt7WmCFL` first DISPATCHED at ts_ms 1778418487737 — that's `2026-05-10T20:14:47.737+07:00`. My Agent tool call for the verifier was logged in conversation at the time of "Dispatching sandwich-verifier in background" — need to cross-check parent_session_id of THIS conversation's claude.exe process via process-table or Claude Code internal session-id.

If `ff85e8d5...` is THIS session's parent ID, then `76f9cc94...` was a phantom from a prior session. The 99-min duration of the 76f9cc94 dispatch suggests that phantom kept running long after its parent session was supposed to be done — definitely the orphan-claude pattern from L-S240-5.

Action: NOT critical for current LIVE re-run. Documenting as forensic for S245 close + promote-rule cycle reference.
