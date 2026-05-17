# role-packs/

Per-persona configuration files for BC-8 perspective agents (StockForge Theme H).

## V0 format (JSON; YAML deferred per ADR D-074 revisit trigger 2)

Each file `<role_id>.json` defines one RolePromptPack:

```json
{
  "role_id": "buffett",
  "persona_name": "Warren Buffett (value + quality + moat)",
  "system_prompt_template": "You are a value investor analyzing {TICKER} as of {AS_OF}...",
  "conviction_guidance": "STRONG = clear moat >= 3 categories; MODERATE = mixed; WEAK = single-category",
  "citation_requirements": "Every claim cites source_url + source_excerpt ≤500 chars verbatim",
  "vietnam_notes": "VHM is VinGroup-affiliated; consider related-party transaction risk...",
  "min_points": 3,
  "min_distinct_categories": 3,
  "category_universe": ["MOAT", "MANAGEMENT", "VALUATION", "ROIC", "BALANCE_SHEET", "GROWTH"],
  "model_id_preference": "claude-sonnet-4-6"
}
```

Loaded by:

```python
from pathlib import Path
from packages.application.analysis.persona_registry import PersonaRegistry

reg = PersonaRegistry()
reg.load_from_json(
    Path("agent-workspace/role-packs/buffett.json"),
    base_dir=Path("agent-workspace/role-packs/"),
)
pack = reg.get("buffett")
```

## V0 content authoring

Per-persona content authored by Phase F.2 sub-plan 035 (S378 IMPL; D-075 PROPOSED).

### Personas authored (F.2)

| File | role_id | Persona | category_universe | model |
|---|---|---|---|---|
| `buffett.json` | buffett | Warren Buffett (value + quality + moat) | MOAT / MANAGEMENT / VALUATION / ROIC / BALANCE_SHEET / GROWTH | claude-sonnet-4-6 |
| `graham.json` | graham | Benjamin Graham (deep value + margin of safety) | EARNINGS_STABILITY / BALANCE_SHEET_STRENGTH / DIVIDEND_RECORD / MARGIN_OF_SAFETY / NCAV / GRAHAM_NUMBER | claude-sonnet-4-6 |
| `taleb.json` | taleb | Nassim Taleb (antifragility + tail risk + convexity) | FRAGILITY / CONVEXITY / SKIN_IN_GAME / TAIL_RISK / VOLATILITY_REGIME / ANTIFRAGILITY | claude-sonnet-4-6 |

Vietnam-relevance notes included in each pack (≥150 chars per persona per DD-6):
- **Buffett**: VinGroup cross-holding moat caveat; Vinamilk/MWG/HPG/VCB moat examples; circle of competence vs. pump stocks
- **Graham**: VN banking NCAV limitations; VN real estate balance-sheet complexity; current ratio relaxation to 1.5; dividend record ≥3y for VN30
- **Taleb**: VN F0 retail >85% tail-risk regime; 'đội lái' pump fragility; USD/VND turkey problem

Pattern source: ai-hedge-fund (MIT; PATTERN inspiration only per A-01 § 6 LICENSE caveat). Zero verbatim copy. See ADR D-075 for pattern-port attestation.

F.1 (this directory creation, ADR D-074, RolePromptPack dataclass, PersonaRegistry) ships
substrate only — persona JSON files added by F.2.

## YAML deferral

YAML format deferred per ADR D-074 revisit trigger 2: project-owner authors 3+ persona packs
in JSON and reports friction (manual escaping of multi-line `system_prompt_template` strings)
→ add `pyyaml` dep via separate sub-plan with explicit user ratification.

## Contract + invariants

See `agent-workspace/memory/decisions/074-bc-8-transport-flip-roleprompt-persona.md`
for full RolePromptPack contract, D-052 compliance attestation, and revisit triggers.

## Path-safety

D-064 path-safety enforced by `PersonaRegistry.load_from_json()`:
- No `..` traversal segments
- `.json` extension only
- No symlinks
- File must exist and be a regular file
- If `base_dir` provided, file must be inside it
