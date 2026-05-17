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

Per-persona content (Buffett / Graham / Taleb) authored by Phase F.2 sub-plan 035.
F.1 (this directory creation, ADR D-074, RolePromptPack dataclass, PersonaRegistry) ships
substrate only — no persona JSON files yet.

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
