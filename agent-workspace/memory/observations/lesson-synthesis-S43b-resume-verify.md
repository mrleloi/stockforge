session: 2026-05-01-session-43b-evidence-resume-verify.md
arc_sessions: 2026-05-01-session-43b-fresh.md + 2026-05-01-session-43b-bull.md + 2026-05-01-session-43b-evidence-harness-recovery.md + 2026-05-01-session-43b-evidence-resume-verify.md
synthesized_by: lesson-synthesizer subagent (HR-6 first live dispatch; 2026-05-04)
surface: known-issues + best-practices + agent-notes (3 surfaces)
new_entry_id: KI-S43b-8 | BP-S43b-8 | L-S43b-11 (agent-notes 2026-05-01 ghost-work entry)
novelty: novel (not covered by KI-S43b-1..7 or BP-S43b-1..7 or L-S43b-1..10)
severity: MEDIUM (KI-S43b-8: data-integrity risk on ghost-work adoption) | MEDIUM (BP-S43b-8: nominal vs substantive verification)
auto_detect: partial (KI-S43b-8: git status + session log grep) | partial (BP-S43b-8: pre-clear-handoff-guard extension) | partial (L-S43b-11: same as KI-S43b-8)

rationale:
  KI-S43b-8 — Evidence: session-43b-evidence-harness-recovery.md § "Findings on entry" documents
  ta_service.py as "was untracked"; § "Production TRACK" shows it was staged as-found. No
  existing KI entry covers the failure mode of adopting ghost-work without provenance audit.
  Distinct from KI-S43b-4 (TA wiring gap) and L-S43b-3 (gatherer wiring rule).

  BP-S43b-8 — Evidence: checkpoints/latest.md § "Quant grounded points populated ⚠️ unverified"
  confirms the field was left open; session-43b-evidence-resume-verify.md § Part A shows
  HR-5 resolved nominally ("bear case 3→5 grounded points citing TAFeatures ✅") without
  a Read of the actual thesis-log content. Cross-arc pattern: checkpoint ⚠️ markers degraded
  to nominal ticks. No existing BP entry covers the ⚠️-field resolution protocol.

  L-S43b-11 — agent-notes companion to KI-S43b-8 following agent-notes format (Context/Rule/
  Anti-example/Correct example/Severity/Auto-detect). Cross-references KI-S43b-8.
