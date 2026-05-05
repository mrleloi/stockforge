"""StockForge domain layer — pure business logic, zero framework dependencies.

9 bounded contexts per agent-workspace/constitution/architecture.md:
- market_data, fundamental, company_intelligence, macro
- news, influence, crowd
- analysis, portfolio

Cross-BC types live in packages/contracts/. Direct cross-BC imports are forbidden.
"""
