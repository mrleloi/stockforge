"""NLP cross-BC application layer.

Per architecture.md § Ports & Adapters + parent plan-028 DD-7: NLP is a
cross-BC capability (BC-5 News Stream + BC-6 Influence + BC-7 Crowd all
consume tokenized VN text), so the port lives in application/nlp/ (NEW
namespace) accessible across BCs. Concrete adapters live in
packages/infrastructure/nlp/.

Source: agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md
        § DD-7 (cross-BC NLP port location).
"""
