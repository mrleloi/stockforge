"""Infrastructure layer — adapters implementing application ports.

Per architecture.md § Layer Hierarchy: infrastructure imports from
`packages.application` (for ports) and `packages.domain` + `packages.contracts`
(for types). Never imports from interfaces; never gets imported by domain.
"""
