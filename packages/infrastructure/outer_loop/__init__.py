"""BC-9 outer-loop infrastructure — Phase 3 scaffolding.

Per master-plan §S55 deliverables:
- editable_asset_registry.py — JSON-backed catalog of mutable pipeline assets
- scalar_metric_recorder.py — sqlite-backed eval_runs persistence
- eval_set_store.py — filesystem-backed eval items with BR-2 holdout/training enforcement

NO LLM imports. NO mutation generation. NO walk-forward eval. Year 2 work.
"""
