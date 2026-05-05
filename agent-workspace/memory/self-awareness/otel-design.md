---
artifact_id: otel-design-s13
created_at: 2026-04-29 (S13 — Track 5.5c.4)
status: DESIGN-ONLY (Phase 0); collector docker deferred to Phase 1+ entry
description: |
  Design-only artifact for the OTEL stack referenced in D-003 § 5.5c.4. Implementation deferred
  per Phase 0 portability rule (L-S11-1: bash + node + POSIX only at hook level; Docker is Phase 1+).
  This document captures the architecture so Phase 1+ implementation has a written target.
source_decision: agent-workspace/memory/decisions/003-up06-track-5.5-sync-layer-selfcap.md § 5.5c.4
deferral_basis:
  - "L-S11-1 (Phase 0 portability — bash + node + POSIX only at hook level; no docker)"
  - "D-003 risk register: 'If 5.5c overshoots, descope c.4 OTEL to design-only + defer collector docker to Track 9'"
related_artifacts:
  - agent-workspace/memory/self-awareness/jsonl-schema.md  # current telemetry source-of-truth
  - scripts/hooks/component-telemetry.sh                    # current emitter (JSONL)
  - agent-workspace/memory/decisions/003-up06-track-5.5-sync-layer-selfcap.md
---

# OTEL Stack Design — Phase 1+ Activation Target

> Stockforge currently uses bash + NDJSON for self-awareness telemetry. This document specifies
> the OTEL collector + emitter stack that will replace the per-tool telemetry path once Phase 1+
> Docker deployment exists. Until then: design-only; no docker-compose runs at Phase 0.

## Why OTEL eventually (rationale from D-003)

JSONL alone suffices for current scale (~100-300 events/session, single dev machine). OTEL adds:
- **Standard tooling**: Jaeger / Tempo / Honeycomb consumers exist; team or peer-share trivially.
- **Distributed correlation**: when Phase 2+ adds multi-service pipelines (data ingest + classifier + dashboard), span trees beat flat NDJSON for debugging cross-service flows.
- **Sampling control**: OTEL collector can do head/tail sampling; JSONL is "collect everything or nothing".
- **Vendor-neutral exporters**: can swap Jaeger → Tempo → cloud without rewriting emitters.

Cost: ~200K one-time setup (per D-003 plan estimate). Phase 0 deferral acceptable.

## Phase 0 (current) — bash + NDJSON only

Producer: `scripts/hooks/component-telemetry.sh` (PostToolUse / SubagentStop / SessionStart).
Output: `learning-data/events/<date>.ndjson` (per Stream B in jsonl-schema.md).
Consumers: `learning-index-rebuild.sh` (RAG index), `metric-failure-mode-rate.sh` (deterministic metrics).
No collector, no spans, no docker. **This is sufficient for stockforge Phase 0 single-dev scale.**

## Phase 1+ activation plan

When Docker deployment lands (Phase 1 — `docker-compose.yml` already designed in `docker-compose.yml` at repo root for Postgres + Redis):

### Service: otel-collector (new, ~50 LOC docker-compose section)

```yaml
otel-collector:
  image: otel/opentelemetry-collector-contrib:0.96.0  # pin version; update on release schedule
  command: ["--config=/etc/otel/config.yaml"]
  volumes:
    - ./docker/otel-stack/config.yaml:/etc/otel/config.yaml:ro
    - otel-data:/var/lib/otel  # local file exporter for Phase 1; swap for Jaeger/Tempo later
  ports:
    - "4317:4317"  # OTLP gRPC
    - "4318:4318"  # OTLP HTTP
  restart: unless-stopped
```

### Receiver / processor / exporter pipeline (`docker/otel-stack/config.yaml`)

```yaml
receivers:
  otlp:
    protocols: { grpc: {}, http: {} }
processors:
  batch: {}              # 5s batch window — keep collector overhead bounded
  resource:
    attributes:
      - key: service.name
        value: stockforge
        action: insert
exporters:
  file:
    path: /var/lib/otel/spans.jsonl   # Phase 1 default; swap for jaeger/tempo at Phase 2+
service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch, resource]
      exporters: [file]
```

### Python emitter: `packages/observability/otel_emitter.py`

Phase 1+ emitter (NOT TO BE WRITTEN AT PHASE 0). Wraps `opentelemetry-api` + `opentelemetry-sdk`.
Used from Python services (data ingest, classifier, dashboard) — NOT from bash hooks (hooks stay
on bash + NDJSON; bridge written by collector if hooks ever need OTEL output).

### Bash hook bridge (Phase 1+ optional)

`component-telemetry.sh` could OPTIONALLY POST to `localhost:4318/v1/traces` if collector reachable.
Bridge keeps NDJSON as authoritative + emits parallel OTEL span. Implementation: ~20 LOC bash via curl + node-eval JSON construction. Skipped at Phase 0 (curl isn't on L-S11-1 whitelist).

## Mapping JSONL → OTEL spans (when wired)

Each NDJSON event becomes 1 OTEL span:

| NDJSON field | OTEL span field |
|---|---|
| `ts` | span start_time |
| `duration_ms` | end_time - start_time |
| `component_type`, `component_name` | span name (`<type>:<name>`) |
| `trigger` | span attribute `harness.trigger` |
| `outcome` | span status (ok/error/etc) |
| `tokens_real` | span attribute `harness.tokens_real` |
| `failure_mode` | span attribute `harness.failure_mode` (or null tag) |
| `session_id` | span attribute `harness.session_id` (cross-session trace correlation) |
| `task_id`, `approach_id` (Phase 1+) | trace_id linking back to try-n-approaches frame |
| `metric` (Phase 1+) | span event with metric_name + metric_value |

`approach_id` becomes the trace correlation key — all events emitted while approach X is "active" share trace_id, so a span tree shows the full DEEPEN-or-BROADEN execution arc.

## Open IMPL-tier decisions (deferred to Phase 1+)

- **Sampling rate**: head-sample 100% at small scale (low cost) vs tail-sample at higher volume. Default Phase 1: head 100%.
- **Exporter target**: file (Phase 1) vs Jaeger UI (Phase 2 if peer-share happens) vs Tempo (Phase 3+ if multi-tenant).
- **Bash bridge**: OPT-IN or always-on? Default OPT-IN — collector reachable check + env flag.

## Anti-patterns

- **Wiring OTEL emitter at Phase 0**: docker dependency violates L-S11-1 portability. Defer.
- **Skipping JSONL after OTEL lands**: NDJSON remains authoritative even at Phase 1+. OTEL is a parallel emit, not a replacement. NDJSON is the audit-trail-of-record per D-005 § 5.5d ETL doctrine.
- **LLM-generated span attributes**: same as I-S1 — values come from code; LLM never invents numeric attributes.
- **Mixing harness telemetry with stock-domain telemetry in same trace**: harness traces stay in service.name=stockforge-harness; stock-domain spans (Phase 2+) go to service.name=stockforge-pipeline. Separation is identity-tier (charter principle 1).

## See also

- D-003 § 5.5c.4 (deliverable spec)
- D-003 § Risk register (descope authorization)
- agent-workspace/memory/agent-notes.md § L-S11-1 (Phase 0 portability rule)
- agent-workspace/memory/self-awareness/jsonl-schema.md (sibling — current telemetry source-of-truth)
