#!/usr/bin/env python3
"""
HH-F.2 sync-tracker sample bootstrap ETL (S48j).

Retrospective extract from D-001..D-031 ADRs + 17 M-S* mistakes + 30+ L-S*
lessons + 12 Q-* answered Q&A bundles + phase-boundary milestones into
sync-tracker events.tsv. Recomputes state.tsv per weights.yaml.

Run once: python3 scripts/sync-tracker-bootstrap.py
Idempotency: refuses to run if events.tsv already has >50 rows (sentinel for
post-bootstrap). Manual force via --force.
"""

import sys
from pathlib import Path
from datetime import datetime, timezone

ROOT = Path(__file__).parent.parent
EVENTS = ROOT / "agent-workspace" / "memory" / "sync-tracker" / "events.tsv"
STATE = ROOT / "agent-workspace" / "memory" / "sync-tracker" / "state.tsv"

# Weights from weights.yaml (per D-006 Track 8a)
DELTA = {
    "decision_correctness": 0.5,
    "charter_match": 0.2,
    "q_and_a_resolution": 0.1,
    "drift_signal": -0.3,
    "decision_correction": -2.0,
    "decision_revocation": -3.0,
    "thesis_revocation": -1.0,
}

# (ts, category, event_type, decision_id, source_evidence, reason)
# 30 events per category target. Timestamps approximate original event date;
# distinct sub-second-style HH:MM:SS to keep ordering deterministic.
BOOTSTRAP_EVENTS = [
    # ============ LANGUAGE (30 events: 5 drift, 7 charter, 18 q_and_a) ============
    ("2026-05-01T11:00:00Z", "LANGUAGE", "drift_signal", "M-S35-1",
     "mistake-log.md M-S35-1", "confabulated drift report; VBW protocol violation"),
    ("2026-05-01T13:00:00Z", "LANGUAGE", "drift_signal", "M-S35-5",
     "mistake-log.md M-S35-5", "/schedule defection at S34 close (Mode-E ancestor)"),
    ("2026-05-05T08:30:00Z", "LANGUAGE", "drift_signal", "M-S45-2",
     "mistake-log.md M-S45-2", "Mode-E wait-for-your-call recurrence; regex miss"),
    ("2026-05-05T11:00:00Z", "LANGUAGE", "drift_signal", "M-S47-1",
     "mistake-log.md M-S47-1", "Mode-E Next-continue-enters routing-branch enumeration"),
    ("2026-05-05T14:30:00Z", "LANGUAGE", "drift_signal", "M-S48e-1",
     "mistake-log.md M-S48e-1", "misread garbled //nneeww keystroke as user intent"),
    ("2026-05-04T14:00:30Z", "LANGUAGE", "charter_match", "D-026",
     "decisions/026-S43e-charter-promote-bundle-C1-C2.md", "LLM substrate boundary doctrine codified"),
    ("2026-05-05T13:00:00Z", "LANGUAGE", "charter_match", "D-030",
     "decisions/030-S48f-charter-promote-autonomous-protocol-rule-10-mode-E.md", "autonomous-protocol Rule 10 Mode-E ban"),
    ("2026-05-05T09:00:00Z", "LANGUAGE", "charter_match", "S45-watchdog",
     "scripts/hooks/autonomous-stop-watchdog.sh:64", "SELF_PAUSE regex +6 alternations post M-S45-2"),
    ("2026-05-05T11:30:00Z", "LANGUAGE", "charter_match", "S47-watchdog",
     "scripts/hooks/autonomous-stop-watchdog.sh:64", "SELF_PAUSE regex +4 routing-branch alternations post M-S47-1"),
    ("2026-05-01T11:00:00Z", "LANGUAGE", "charter_match", "prompt-eng-skill",
     ".claude/skills/prompt-engineering/SKILL.md", "prompt-engineering skill ship"),
    ("2026-05-05T12:00:30Z", "LANGUAGE", "charter_match", "D-028",
     "decisions/028-S48d-CLAUDE-md-session-end-ritual-extension.md", "CLAUDE.md session-end ritual language extended (5→9 steps)"),
    ("2026-05-05T13:30:00Z", "LANGUAGE", "charter_match", "D-031",
     "decisions/031-S48h-charter-promote-qa-lifecycle-auto-mv-HH-E.2.md", "agent-workspace/CLAUDE.md auto-mv contract language (D-031)"),
    ("2026-04-29T15:30:00Z", "LANGUAGE", "q_and_a_resolution", "Q-2.1",
     "queued-grill-master.md Q-2.1", "skill autonomous policy: SUPERVISED-only resolution"),
    ("2026-05-05T13:30:00Z", "LANGUAGE", "q_and_a_resolution", "Q-S48c-1",
     "current-execution.md S48d Q-S48c-1", "drift-signals reconciliation Part A doctrine ratify"),
    ("2026-05-05T13:00:00Z", "LANGUAGE", "q_and_a_resolution", "Q-S48e-1",
     "current-execution.md S48f Q-S48e-1", "HH-D.2 Mode-E charter ratify via 1-Q AskUserQuestion=ACCEPT"),
    ("2026-05-05T13:30:00Z", "LANGUAGE", "q_and_a_resolution", "Q-S48g-1",
     "current-execution.md S48h Q-S48g-1", "HH-E.2 auto-mv contract revision ratify=ACCEPT"),
    ("2026-05-01T13:30:00Z", "LANGUAGE", "q_and_a_resolution", "L-S35-N",
     "agent-notes.md L-S35-N", "4 LLM cognitive failure modes catalog codified"),
    ("2026-05-04T08:30:00Z", "LANGUAGE", "q_and_a_resolution", "L-S43b-2",
     "agent-notes.md L-S43b-2", "prose-tolerant JSON BP-S43b-2 (LLM substrate language)"),
    ("2026-05-05T08:30:00Z", "LANGUAGE", "q_and_a_resolution", "L-S44-1",
     "agent-notes.md L-S44-1", "Mode-E self-pause family doctrine codified"),
    ("2026-05-05T09:30:00Z", "LANGUAGE", "q_and_a_resolution", "L-S45-2",
     "agent-notes.md L-S45-2", "Edit-not-Write doctrine for protected paths"),
    ("2026-05-05T10:00:00Z", "LANGUAGE", "q_and_a_resolution", "L-S46-1",
     "agent-notes.md L-S46-1", "ruff auto-fix typing.Any import drift catalog"),
    ("2026-05-05T11:30:00Z", "LANGUAGE", "q_and_a_resolution", "L-S47-1",
     "agent-notes.md L-S47-1", "enumerative routing-branch enumeration ban codified"),
    ("2026-05-05T12:00:00Z", "LANGUAGE", "q_and_a_resolution", "L-S48-1",
     "agent-notes.md L-S48-1", "continue-injector rate-limit + ancestor-walk fix"),
    ("2026-05-05T07:30:00Z", "LANGUAGE", "q_and_a_resolution", "write-vs-edit-guard",
     "scripts/hooks/write-vs-edit-guard.sh", "Write vs Edit tool-semantic guard for memory artifacts"),
    ("2026-05-05T13:00:00Z", "LANGUAGE", "q_and_a_resolution", "HH-B.3",
     "scripts/hooks/component-telemetry.sh", "failure_mode response-text classifier (R/T/H/F/I/N/B)"),
    ("2026-05-05T12:30:00Z", "LANGUAGE", "q_and_a_resolution", "HH-B.1+B.2",
     "scripts/hooks/dispatch-jsonl-recorder.sh REV-3", "FIFO match against dispatch.jsonl + transcript_path tokens extract"),
    ("2026-05-05T07:00:00Z", "LANGUAGE", "q_and_a_resolution", "M-S45-1",
     "mistake-log.md M-S45-1", "Write/Edit tool-semantic slip in subagent (substrate data loss)"),
    ("2026-05-01T11:30:00Z", "LANGUAGE", "q_and_a_resolution", "M-S35-2",
     "mistake-log.md M-S35-2", "echo-chamber subagent acceptance trust slip"),
    ("2026-05-05T09:30:00Z", "LANGUAGE", "q_and_a_resolution", "recover-agent-notes",
     "scripts/recover-agent-notes.py", "transcript-mining recovery script (S45 incident)"),
    ("2026-05-05T15:00:00Z", "LANGUAGE", "q_and_a_resolution", "user-memory-no-self-pause",
     "~/.ccs/.../memory/autonomous_continue_no_self_pause.md", "user-memory autonomous-continue doctrine codified"),
    # ============ DOMAIN_UBIQUITOUS (30 events: 2 drift, 6 corr, 17 charter, 5 q_and_a) ============
    ("2026-04-30T18:00:00Z", "DOMAIN_UBIQUITOUS", "drift_signal", "M-S28-1",
     "mistake-log.md M-S28-1", "vendor-API surface drift: vnstock 4.0 dropped TCBS source"),
    ("2026-04-30T21:00:00Z", "DOMAIN_UBIQUITOUS", "drift_signal", "M-S34-1",
     "mistake-log.md M-S34-1", "cross-BC import peer_service.py BC-3→BC-1 (architectural-boundary violation)"),
    ("2026-05-01T09:00:00Z", "DOMAIN_UBIQUITOUS", "decision_correctness", "D-012",
     "decisions/012-track-A-source-pivot.md", "Track A vnstock→VCI source pivot post vendor drift"),
    ("2026-05-05T08:00:00Z", "DOMAIN_UBIQUITOUS", "decision_correctness", "D-027",
     "decisions/027-S45-BC-6-architecture-influence-network.md", "BC-6 KOL influence_network architecture"),
    ("2026-04-30T22:00:30Z", "DOMAIN_UBIQUITOUS", "decision_correctness", "Phase-1-close",
     "current-execution.md S30 close", "Phase 1 thin-slice VHM: BC-1 market_data + BC-3 fundamental UL applied"),
    ("2026-05-05T09:00:00Z", "DOMAIN_UBIQUITOUS", "decision_correctness", "Phase-3-Track-G",
     "sessions/2026-05-05-session-46.md", "BC-6 KOL adapters S46 (Track G): 14 NEW files + 67 NEW tests"),
    ("2026-05-05T10:00:00Z", "DOMAIN_UBIQUITOUS", "decision_correctness", "Phase-3-Track-H",
     "sessions/2026-05-05-session-47.md", "BC-6 LLM extraction S47 (Track H): 23+21=44 NEW tests"),
    ("2026-04-30T23:00:00Z", "DOMAIN_UBIQUITOUS", "decision_correctness", "BC-3-peer-service",
     "packages/domain/fundamental/services/peer_service.py", "BC-3 peer_service contract-only refactor (post M-S34-1)"),
    ("2026-04-29T13:30:00Z", "DOMAIN_UBIQUITOUS", "charter_match", "invariants-base",
     "agent-workspace/constitution/invariants.md", "invariants.md base ship (I-S1..I-S35)"),
    ("2026-04-29T16:30:00Z", "DOMAIN_UBIQUITOUS", "charter_match", "financial-data-protocol",
     "agent-workspace/constitution/financial-data-protocol.md", "financial-data-protocol.md base ship"),
    ("2026-04-30T09:00:30Z", "DOMAIN_UBIQUITOUS", "charter_match", "D-009",
     "decisions/009-VHM-thin-slice-exemplar.md", "VHM as VN-domain exemplar"),
    ("2026-04-30T10:00:00Z", "DOMAIN_UBIQUITOUS", "charter_match", "D-010",
     "decisions/010-VN-domain-constitution-proposals.md", "VN-domain proposals: 9 BC stockforge architecture"),
    ("2026-05-04T09:30:00Z", "DOMAIN_UBIQUITOUS", "charter_match", "D-019",
     "decisions/019-S43c-charter-promote-financial-data-protocol-rule-11.md", "financial-data-protocol Rule 11 charter promote"),
    ("2026-05-04T10:30:00Z", "DOMAIN_UBIQUITOUS", "charter_match", "D-021",
     "decisions/021-S43c-charter-promote-financial-data-protocol-VN.md", "financial-data-protocol VN-specific charter promote"),
    ("2026-05-04T11:00:00Z", "DOMAIN_UBIQUITOUS", "charter_match", "D-022",
     "decisions/022-S43c-charter-promote-invariants-VN.md", "invariants-VN charter promote (I-S36..I-S65)"),
    ("2026-04-29T20:00:00Z", "DOMAIN_UBIQUITOUS", "charter_match", "drill-me-skill",
     ".claude/skills/drill-me/", "drill-me skill: interactive UL extraction"),
    ("2026-04-29T20:30:00Z", "DOMAIN_UBIQUITOUS", "charter_match", "ubiq-lang-skill",
     ".claude/skills/ubiquitous-language/", "ubiquitous-language skill: DDD glossary extraction"),
    ("2026-04-29T21:00:00Z", "DOMAIN_UBIQUITOUS", "charter_match", "spec-to-wiki-skill",
     ".claude/skills/spec-to-wiki/", "spec-to-wiki skill: raw/wiki Karpathy UL pattern"),
    ("2026-04-29T21:30:00Z", "DOMAIN_UBIQUITOUS", "charter_match", "obsidian-vault-skill",
     ".claude/skills/obsidian-vault/", "obsidian-vault skill: wikilinks + UL navigation"),
    ("2026-04-29T22:00:00Z", "DOMAIN_UBIQUITOUS", "charter_match", "ul-audit-cmd",
     ".claude/commands/ul-audit.md", "/ul-audit command: glossary drift detection"),
    ("2026-04-30T08:00:00Z", "DOMAIN_UBIQUITOUS", "charter_match", "crawler-reliability-skill",
     ".claude/skills/crawler-reliability/", "crawler-reliability skill: VN data sources UL"),
    ("2026-04-30T08:30:00Z", "DOMAIN_UBIQUITOUS", "charter_match", "postgres-pgvector-skill",
     ".claude/skills/postgres-pgvector/", "postgres-pgvector skill: VN text + time-series UL"),
    ("2026-04-30T09:00:00Z", "DOMAIN_UBIQUITOUS", "charter_match", "ddd-tactical-skill",
     ".claude/skills/ddd-tactical-patterns/", "ddd-tactical-patterns skill: stockforge 9 BC vocabulary"),
    ("2026-05-01T09:00:00Z", "DOMAIN_UBIQUITOUS", "charter_match", "evidence-extraction-skill",
     ".claude/skills/evidence-extraction/", "evidence-extraction skill: claim citation integrity"),
    ("2026-04-30T20:00:00Z", "DOMAIN_UBIQUITOUS", "charter_match", "importlinter-config",
     "pyproject.toml [tool.importlinter]", "import-linter BC boundary enforcement"),
    ("2026-04-29T22:30:00Z", "DOMAIN_UBIQUITOUS", "charter_match", "glossary",
     "agent-workspace/ubiquitous-language/glossary.md", "ubiquitous language glossary base ship"),
    ("2026-04-29T15:00:30Z", "DOMAIN_UBIQUITOUS", "q_and_a_resolution", "Q-D2",
     "queued-grill-master.md Q-D2", "Obsidian wiki scaling A=keep raw/wiki Karpathy pattern"),
    ("2026-04-30T18:30:00Z", "DOMAIN_UBIQUITOUS", "q_and_a_resolution", "L-S28-1",
     "agent-notes.md L-S28-1", "vendor-API surface lock-in doctrine"),
    ("2026-05-01T10:30:00Z", "DOMAIN_UBIQUITOUS", "q_and_a_resolution", "L-S34-1",
     "agent-notes.md L-S34-1", "cross-BC import contract-only doctrine"),
    ("2026-05-04T11:30:00Z", "DOMAIN_UBIQUITOUS", "q_and_a_resolution", "Q-S43c-VN",
     "current-execution.md S43c", "VN-domain charter batch ratify (D-019..D-022)"),
    # ============ DESIGN_THINKING (24 events: 3 drift, 4 corr, 14 charter, 3 q_and_a) ============
    ("2026-04-30T14:00:00Z", "DESIGN_THINKING", "drift_signal", "M-S20-1",
     "mistake-log.md M-S20-1", "Bash(*) wildcard matcher contract surprise (design-tier)"),
    ("2026-04-30T17:00:00Z", "DESIGN_THINKING", "drift_signal", "M-S26-1",
     "mistake-log.md M-S26-1", "master-plan internal contradiction (8 vs 9 proposals)"),
    ("2026-05-05T13:30:00Z", "DESIGN_THINKING", "drift_signal", "M-S48d-1",
     "mistake-log.md M-S48d-1", "pipefail+grep silent-fail trap in Stop hooks"),
    ("2026-04-29T12:00:00Z", "DESIGN_THINKING", "decision_correctness", "D-005",
     "decisions/005-up08-track-5.5d-self-learning-pipeline.md", "self-learning pipeline architecture (UP-08 Track 5.5d)"),
    ("2026-04-29T18:00:00Z", "DESIGN_THINKING", "decision_correctness", "D-007",
     "decisions/007-track-8b-memory-l0-l1-extraction.md", "memory L0/L1 extraction architecture"),
    ("2026-04-29T20:00:00Z", "DESIGN_THINKING", "decision_correctness", "D-008",
     "decisions/008-track-9-self-awareness-reduced.md", "self-awareness reduced (Track 9 substrate)"),
    ("2026-05-02T10:00:00Z", "DESIGN_THINKING", "decision_correctness", "D-014",
     "decisions/014-track-F-architecture.md", "Track F architecture (Phase 2 BC-3 fundamental)"),
    ("2026-04-29T08:30:00Z", "DESIGN_THINKING", "charter_match", "karpathy-principles",
     "agent-workspace/constitution/karpathy-principles.md", "Karpathy 4 Principles base ship (P1-P4)"),
    ("2026-04-29T09:30:00Z", "DESIGN_THINKING", "charter_match", "vbw-protocol",
     "agent-workspace/constitution/vbw-protocol.md", "VBW protocol base ship"),
    ("2026-04-29T12:30:00Z", "DESIGN_THINKING", "charter_match", "drift-signals-base",
     "agent-workspace/constitution/drift-signals.md", "drift-signals.md base ship (DR1-DR12)"),
    ("2026-04-29T14:30:00Z", "DESIGN_THINKING", "charter_match", "coding-principles",
     "agent-workspace/constitution/coding-principles.md", "coding-principles.md base ship"),
    ("2026-04-29T15:30:00Z", "DESIGN_THINKING", "charter_match", "architecture-base",
     "agent-workspace/constitution/architecture.md", "architecture.md base ship (9 BC layers)"),
    ("2026-05-03T10:00:00Z", "DESIGN_THINKING", "charter_match", "D-017",
     "decisions/017-S38-charter-promote-memory-tiers.md", "memory-tiers.md charter promote (Tier 1/2/3)"),
    ("2026-05-04T09:00:00Z", "DESIGN_THINKING", "charter_match", "D-018",
     "decisions/018-S43c-charter-promote-architecture-amendment.md", "architecture amendment charter promote"),
    ("2026-05-05T12:01:00Z", "DESIGN_THINKING", "charter_match", "D-029",
     "decisions/029-S48d-charter-promote-drift-signals-reconciliation.md", "drift-signals reconciliation Part A charter promote"),
    ("2026-04-29T19:00:00Z", "DESIGN_THINKING", "charter_match", "write-a-skill",
     ".claude/skills/write-a-skill/", "write-a-skill skill: pattern→skill formalization"),
    ("2026-04-29T19:30:00Z", "DESIGN_THINKING", "charter_match", "spec-dual-layer",
     ".claude/skills/spec-dual-layer/", "spec-dual-layer skill: business+agent contract"),
    ("2026-05-01T10:00:00Z", "DESIGN_THINKING", "charter_match", "empirical-probe-first",
     ".claude/skills/empirical-probe-first/", "empirical-probe-first skill: probe ladder doctrine"),
    ("2026-04-29T22:00:00Z", "DESIGN_THINKING", "charter_match", "drift-signals-D1-D9-base",
     "scripts/hooks/drift-signals-D1-D8.sh", "drift-signals-D1-D8.sh hook ship (S3 Track 5)"),
    ("2026-05-05T13:00:00Z", "DESIGN_THINKING", "charter_match", "drift-signals-D1-D9-S48c",
     "scripts/hooks/drift-signals-D1-D9.sh +DR1/3/6/8", "drift-signals hook extension (HH-B.4)"),
    ("2026-05-05T11:00:00Z", "DESIGN_THINKING", "charter_match", "profile-template-auto",
     "scripts/hooks/profile-template-auto-populate.sh", "profile-template auto-populate Stop hook (HH-C.3)"),
    ("2026-04-29T15:00:00Z", "DESIGN_THINKING", "q_and_a_resolution", "Q-A2",
     "queued-grill-master.md Q-A2", "drift leading indicator A=LOC ceiling primary"),
    ("2026-04-29T17:00:00Z", "DESIGN_THINKING", "q_and_a_resolution", "Q-C2",
     "queued-grill-master.md Q-C2", "auto-context loader hybrid D=auto+LLM-selector"),
    ("2026-04-29T18:00:00Z", "DESIGN_THINKING", "q_and_a_resolution", "Q-D3",
     "queued-grill-master.md Q-D3", "memory-tiers codification A=add memory-tiers.md"),
    # ============ SCOPE (25 events: 7 drift, 5 corr, 12 charter, 1 q_and_a) ============
    ("2026-04-29T13:00:00Z", "SCOPE", "drift_signal", "M-S7-1",
     "mistake-log.md M-S7-1", "stale-prompt UP-07 mismatch post-/clear"),
    ("2026-04-29T17:30:00Z", "SCOPE", "drift_signal", "M-S13-pre-2",
     "mistake-log.md M-S13-pre-2", "project.md staleness 12 sessions / 5 decisions / 1 phase REV"),
    ("2026-04-30T15:00:00Z", "SCOPE", "drift_signal", "M-S21-1",
     "mistake-log.md M-S21-1", "S21 verifier 3 residue items (proposal-count drift)"),
    ("2026-04-30T16:00:00Z", "SCOPE", "drift_signal", "M-S25-1",
     "mistake-log.md M-S25-1", "architect subagent budget overrun ~220K vs 150-180K envelope"),
    ("2026-04-30T19:00:00Z", "SCOPE", "drift_signal", "M-S29-1",
     "mistake-log.md M-S29-1", "Phase 1 verifier 4 residue items (R1-R4 LOC ceilings)"),
    ("2026-04-30T20:00:00Z", "SCOPE", "drift_signal", "M-S31-1",
     "mistake-log.md M-S31-1", "PLAN budget breach: master-plan 005 = 790 LOC vs ≤700 advisory"),
    ("2026-05-01T12:00:00Z", "SCOPE", "drift_signal", "M-S35-3",
     "mistake-log.md M-S35-3", "context band breach to 280K vs 250K hard_cap"),
    ("2026-04-29T23:00:00Z", "SCOPE", "decision_correctness", "Phase-0-close",
     "current-execution.md S22 close", "Phase 0 14-track scope complete S1-S22"),
    ("2026-04-30T22:00:00Z", "SCOPE", "decision_correctness", "Phase-1-close",
     "current-execution.md S30 close", "Phase 1 VHM thin-slice scope complete S23-S30"),
    ("2026-05-04T15:00:00Z", "SCOPE", "decision_correctness", "Phase-2-close",
     "current-execution.md S43e close", "Phase 2 6-track scope complete S31-S43e"),
    ("2026-05-05T12:00:00Z", "SCOPE", "decision_correctness", "Phase-2.5-entry",
     "current-execution.md S48 entry", "Phase 2.5 NEW middle phase entered (8 tracks HH-A..HH-H)"),
    ("2026-05-05T07:00:00Z", "SCOPE", "decision_correctness", "Phase-3-entry",
     "current-execution.md S44 entry", "Phase 3 entered via S44 master-plan main-session author"),
    ("2026-04-29T09:00:00Z", "SCOPE", "charter_match", "D-002",
     "decisions/002-phase-0-harness-bootstrap-design.md", "Phase 0 12-track scope design"),
    ("2026-04-29T10:00:00Z", "SCOPE", "charter_match", "D-003",
     "decisions/003-up06-track-5.5-sync-layer-selfcap.md", "UP-06 Track 5.5 selfcap scope"),
    ("2026-04-29T11:00:30Z", "SCOPE", "charter_match", "D-004",
     "decisions/004-up07-context-threshold-opus47.md", "context-threshold band 180/220/250K (UP-07)"),
    ("2026-04-30T11:00:00Z", "SCOPE", "charter_match", "D-011",
     "decisions/011-phase-2-entry-tier1-tier2-vn30-rollout.md", "Phase 2 entry tier1+tier2 VN30 rollout"),
    ("2026-05-04T10:00:00Z", "SCOPE", "charter_match", "D-020",
     "decisions/020-S43c-charter-promote-session-budgets-mode-abcd.md", "session-budgets mode-abcd charter promote"),
    ("2026-05-04T13:00:00Z", "SCOPE", "charter_match", "D-025",
     "decisions/025-S43d-phase-2-envelope-amendment.md", "Phase 2 envelope amendment (15% above mid-band honest accounting)"),
    ("2026-05-04T14:00:00Z", "SCOPE", "charter_match", "D-026-bundle",
     "decisions/026-S43e-charter-promote-bundle-C1-C2.md", "bundle C1+C2 charter ratify (LLM substrate + lesson-synthesis)"),
    ("2026-04-29T10:30:00Z", "SCOPE", "charter_match", "session-budgets-base",
     "agent-workspace/constitution/session-budgets.md", "session-budgets.md base ship"),
    ("2026-04-29T11:30:00Z", "SCOPE", "charter_match", "boundaries",
     "agent-workspace/constitution/boundaries.md", "boundaries.md base ship"),
    ("2026-04-29T22:30:00Z", "SCOPE", "charter_match", "master-plan-cmd",
     ".claude/commands/master-plan.md", "/master-plan command ship"),
    ("2026-04-29T23:00:00Z", "SCOPE", "charter_match", "session-cmds",
     ".claude/commands/session-start.md + session-end.md", "/session-start + /session-end commands"),
    ("2026-04-30T16:30:00Z", "SCOPE", "charter_match", "L-S25-1",
     "agent-notes.md L-S25-1", "architect budget envelope calibration doctrine"),
    ("2026-04-29T16:00:30Z", "SCOPE", "q_and_a_resolution", "Q-B2",
     "queued-grill-master.md Q-B2", "hard-block charter-tier default A=must require explicit pick"),
    # ============ DECISION_ROUTING (27 events: 4 drift, 5 corr, 11 charter, 6 q_and_a, 1 correction) ============
    ("2026-04-29T17:00:00Z", "DECISION_ROUTING", "drift_signal", "M-S13-pre-1",
     "mistake-log.md M-S13-pre-1", "session-export-raw.sh head-1 grep bug → 10/12 raw transcripts lost"),
    ("2026-05-01T11:30:00Z", "DECISION_ROUTING", "drift_signal", "M-S35-2",
     "mistake-log.md M-S35-2", "echo-chamber subagent acceptance (AP-1 same-class self-review)"),
    ("2026-05-01T12:30:00Z", "DECISION_ROUTING", "drift_signal", "M-S35-4",
     "mistake-log.md M-S35-4", "4 dead meta-loops skipped 15 sessions (plan-fidelity > meta-loop-fidelity)"),
    ("2026-05-05T04:31:45Z", "DECISION_ROUTING", "drift_signal", "S48-day-DR-batch",
     "drift-logs/2026-05-05.log", "75 HIGH-drift events today (S48 batch via auto-detect)"),
    ("2026-05-05T07:00:00Z", "DECISION_ROUTING", "decision_correction", "M-S45-1",
     "mistake-log.md M-S45-1 + write-vs-edit-guard.sh", "substrate Write/Edit error: subagent destroyed agent-notes.md ~140 LOC permanently"),
    ("2026-04-29T08:00:00Z", "DECISION_ROUTING", "decision_correctness", "D-001",
     "decisions/001-orch-vs-cc-native.md", "orch-vs-cc-native: foundational tooling routing decision"),
    ("2026-04-29T11:00:00Z", "DECISION_ROUTING", "decision_correctness", "D-004",
     "decisions/004-up07-context-threshold-opus47.md", "UP-07 context-threshold routing decision (Opus 4.7 recalibrated)"),
    ("2026-04-29T16:00:00Z", "DECISION_ROUTING", "decision_correctness", "D-006",
     "decisions/006-track-8a-confidence-score-system.md", "Track 8a confidence score system (this category itself)"),
    ("2026-05-01T10:00:00Z", "DECISION_ROUTING", "decision_correctness", "D-013",
     "decisions/013-S35-meta-loop-recovery-promote-routing.md", "S35 meta-loop recovery + promote-rule routing"),
    ("2026-05-03T09:00:00Z", "DECISION_ROUTING", "charter_match", "D-015",
     "decisions/015-S38-charter-promote-autonomous-protocol.md", "autonomous-protocol charter promote"),
    ("2026-05-03T09:30:00Z", "DECISION_ROUTING", "charter_match", "D-016",
     "decisions/016-S38-charter-promote-decision-discipline.md", "decision-discipline charter promote"),
    ("2026-05-04T11:30:00Z", "DECISION_ROUTING", "charter_match", "D-023",
     "decisions/023-S43c-charter-amend-autonomous-protocol-cost-substrate.md", "autonomous-protocol cost-substrate amendment"),
    ("2026-05-04T12:00:00Z", "DECISION_ROUTING", "charter_match", "D-024",
     "decisions/024-S43c-HR-4-charter-promote-memory-routing-tree.md", "memory-routing-tree charter promote"),
    ("2026-05-05T12:00:30Z", "DECISION_ROUTING", "charter_match", "D-028-routing",
     "decisions/028-S48d-CLAUDE-md-session-end-ritual-extension.md", "CLAUDE.md session-end ritual extension (4 NEW steps routing)"),
    ("2026-05-05T14:00:00Z", "DECISION_ROUTING", "charter_match", "D-031-routing",
     "decisions/031-S48h-charter-promote-qa-lifecycle-auto-mv-HH-E.2.md", "qa-lifecycle auto-mv HH-E.2 routing"),
    ("2026-05-05T13:00:00Z", "DECISION_ROUTING", "charter_match", "qa-stale-urgent",
     "scripts/hooks/qa-stale-urgent-escalator.sh", "Q&A stale URGENT escalator hook ship (HH-E.1)"),
    ("2026-05-05T14:00:00Z", "DECISION_ROUTING", "charter_match", "qa-pending-auto-mv",
     "scripts/hooks/qa-pending-auto-mover.sh", "Q&A pending auto-mover hook ship (HH-E.2 IMPL)"),
    ("2026-05-05T13:30:00Z", "DECISION_ROUTING", "charter_match", "sync-tracker-auto",
     "scripts/hooks/sync-tracker-auto-update.sh", "sync-tracker auto-update Stop hook ship (HH-B.5)"),
    ("2026-05-05T12:30:00Z", "DECISION_ROUTING", "charter_match", "session-end-linter",
     "scripts/hooks/session-end-checklist-linter.sh", "session-end checklist linter Stop hook (HH-C.1)"),
    ("2026-05-05T12:35:00Z", "DECISION_ROUTING", "charter_match", "project-md-staleness",
     "scripts/hooks/project-md-staleness-check.sh", "project.md staleness check Stop hook (HH-C.2)"),
    ("2026-04-29T15:00:00Z", "DECISION_ROUTING", "q_and_a_resolution", "Q-A2-routing",
     "queued-grill-master.md Q-A2", "drift leading indicator A=LOC ceiling routing rule"),
    ("2026-04-29T19:00:00Z", "DECISION_ROUTING", "q_and_a_resolution", "Q-E1",
     "queued-grill-master.md Q-E1", "self-detect-drift D=defense-in-depth A+B+C combined"),
    ("2026-04-29T19:30:00Z", "DECISION_ROUTING", "q_and_a_resolution", "Q-E2",
     "queued-grill-master.md Q-E2", "agent-notes promotion frequency A=phase-boundary only"),
    ("2026-04-29T20:00:00Z", "DECISION_ROUTING", "q_and_a_resolution", "Q-E3",
     "queued-grill-master.md Q-E3", "promotion target priority D=Hook FIRST → Skill → Charter"),
    ("2026-04-29T20:30:00Z", "DECISION_ROUTING", "q_and_a_resolution", "Q-E4",
     "queued-grill-master.md Q-E4", "drift recovery flow C=open Q&A bundle async"),
    ("2026-05-04T17:30:00Z", "DECISION_ROUTING", "q_and_a_resolution", "L-S43f-1",
     "agent-notes.md L-S43f-1", "bundled deny-lift cycle for sibling charter proposals"),
    ("2026-05-05T10:30:00Z", "DECISION_ROUTING", "q_and_a_resolution", "L-S46-2",
     "agent-notes.md L-S46-2", "post-/clear TaskList loss completion-check before re-dispatch"),
]


def load_existing_events():
    """Read events.tsv and return list of dicts (skip header)."""
    if not EVENTS.exists():
        return []
    rows = []
    for line in EVENTS.read_text(encoding="utf-8").splitlines()[1:]:
        if not line.strip():
            continue
        parts = line.split("\t")
        if len(parts) >= 7:
            rows.append({
                "ts": parts[0], "category": parts[1], "event_type": parts[2],
                "delta": float(parts[3]), "decision_id": parts[4],
                "source_evidence": parts[5], "reason": parts[6],
            })
    return rows


def append_bootstrap_events():
    """Append BOOTSTRAP_EVENTS to events.tsv as new TSV rows."""
    lines = []
    for ts, cat, etype, decision_id, src, reason in BOOTSTRAP_EVENTS:
        delta = DELTA[etype]
        lines.append(f"{ts}\t{cat}\t{etype}\t{delta}\t{decision_id}\t{src}\t{reason}")
    with EVENTS.open("a", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    return len(lines)


def recompute_state():
    """Recompute state.tsv from full events.tsv."""
    events = load_existing_events()
    initial_score = 50.0
    by_cat = {}
    for ev in events:
        cat = ev["category"]
        if cat not in by_cat:
            by_cat[cat] = {"score": initial_score, "count": 0, "last_ts": "", "must_grill": 0}
        by_cat[cat]["score"] += ev["delta"]
        by_cat[cat]["count"] += 1
        if ev["ts"] > by_cat[cat]["last_ts"]:
            by_cat[cat]["last_ts"] = ev["ts"]
        if ev["event_type"] == "decision_revocation":
            by_cat[cat]["must_grill"] = 5

    # Preserve existing must_grill from current state.tsv (since revocation cycles
    # decrement on subsequent correctness events; trust current state).
    if STATE.exists():
        existing = {}
        for line in STATE.read_text(encoding="utf-8").splitlines()[1:]:
            if not line.strip():
                continue
            parts = line.split("\t")
            if len(parts) >= 5:
                existing[parts[0]] = int(parts[4])
        for cat in by_cat:
            if cat in existing:
                by_cat[cat]["must_grill"] = existing[cat]

    # Write new state.tsv
    out = ["category\tcurrent_score\tsample_count\tlast_updated_ts\tmust_grill_remaining"]
    for cat in ["LANGUAGE", "DOMAIN_UBIQUITOUS", "DESIGN_THINKING", "SCOPE", "DECISION_ROUTING"]:
        if cat in by_cat:
            d = by_cat[cat]
            out.append(f"{cat}\t{round(d['score'], 1)}\t{d['count']}\t{d['last_ts']}\t{d['must_grill']}")
    STATE.write_text("\n".join(out) + "\n", encoding="utf-8")
    return by_cat


def main():
    force = "--force" in sys.argv
    existing = load_existing_events()
    if len(existing) > 50 and not force:
        print(f"REFUSE: events.tsv has {len(existing)} rows (>50 sentinel). Use --force to override.")
        return 1

    n_appended = append_bootstrap_events()
    print(f"Appended {n_appended} bootstrap events to {EVENTS.name}")

    state = recompute_state()
    print(f"\nRecomputed state.tsv:")
    for cat in ["LANGUAGE", "DOMAIN_UBIQUITOUS", "DESIGN_THINKING", "SCOPE", "DECISION_ROUTING"]:
        if cat in state:
            d = state[cat]
            tier = ("HIGH" if d["score"] >= 90 else
                    "MED_HIGH" if d["score"] >= 70 else
                    "MED" if d["score"] >= 50 else
                    "MED_LOW" if d["score"] >= 30 else "MUST_GRILL")
            print(f"  {cat}: score={round(d['score'], 1)} count={d['count']} tier={tier}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
