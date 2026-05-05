# Domain Mapping — UL term → code location

> Where does each canonical term actually live in code?
> Update when a term's home BC changes.

---

## Mapping table

| UL term | Kind | Home BC | Code location (expected) |
|---|---|---|---|
| `Ticker` | VO | shared | `packages/shared/stockforge_shared/ticker.py` |
| `Thesis` | Aggregate | BC-4 | `packages/domain/stockforge_domain/thesis/thesis.py` |
| `BearCase` | Entity | BC-4 | `packages/domain/stockforge_domain/thesis/bear_case.py` |
| `SignalTier` | Enum | shared | `packages/shared/stockforge_shared/signal_tier.py` |
| `Kol` | Aggregate | BC-6 | `packages/domain/stockforge_domain/influence/kol.py` |
| `Recommendation` | Entity | BC-6 | `packages/domain/stockforge_domain/influence/recommendation.py` |
| `PumpPhase` | Enum | BC-7 | `packages/domain/stockforge_domain/crowd/pump_phase.py` |
| `Calibration` | VO | BC-8 | `packages/domain/stockforge_domain/calibration/calibration.py` |
| `Pattern` | Entity | BC-9 | `packages/domain/stockforge_domain/pattern/pattern.py` |

> Paths are expected-convention; actual structure settled during Phase 1 skeleton work.

---

## Rules

- Every UL term in `glossary.md` should have a row here once it has a code home.
- If a term is "concept only" (no code yet), mark `Home BC` and leave `Code location` as `—`.
- When a term moves BC (rare), update here + note in `drift-log.md`.
