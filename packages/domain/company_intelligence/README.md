# BC-3: Company Intelligence

> Cross-tier — company profile + ownership + corporate actions; informs all four signal tiers.

**Responsibility**: Company profile, history, leadership, related parties, network relationships.

**Aggregates**: Company, Executive, RelatedParty, OwnershipStructure, CorporateAction

**Storage**: Postgres + graph queries (Neo4j evaluated Phase 3+ if relationship density warrants).

**Sources** (Phase 1):
- HOSE/HNX/UPCoM disclosure portals — corporate actions, governance changes
- Company official filings — ownership, executive changes
- Vietstock public — company profiles

**LLM role**: Extract structured profile from unstructured filings (PDFs, announcements). NEVER generate numbers.

**Cross-BC events emitted**:
- `CompanyProfileUpdated`, `RelatedPartyDiscovered`, `CorporateActionFiled`
