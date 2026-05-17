"""PersonaRegistry — stdlib dict lookup for RolePromptPack instances.

Per master plan-033 DD-8 + sub-plan 034 DD-2: stdlib dict wrapper with JSON
loader (YAML deferred per AP-7 named revisit trigger — pyyaml not in pyproject
deps; project-owner ratification gates YAML adoption).

Composition root pattern: main.py / CLI entry points create PersonaRegistry +
register all packs (or load_from_json from agent-workspace/role-packs/).

D-064 path-safety 5-invariant compliance on load_from_json(json_path: Path):
1. Path checked for '..' traversal segments (rejection before resolve)
2. Path extension must be .json (case-insensitive suffix check)
3. Path must not be a symlink (real file only; symlinks rejected per D-064)
4. Resolved path must be a regular file
5. If base_dir provided, resolved path must be inside base_dir (traversal guard)

YAML deferred revisit trigger (AP-7): project-owner authors 3+ persona packs in
JSON and reports friction (manual escaping of multi-line system_prompt_template
strings) → add pyyaml dep via separate sub-plan with explicit user ratification.

Source: agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md DD-8
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import cast

from packages.application.analysis.role_prompt_pack import RolePromptPack

__all__ = ["PersonaRegistry", "PersonaRegistryError"]


class PersonaRegistryError(RuntimeError):
    """Raised on registry-level error (duplicate registration, invalid path, etc.)."""


class PersonaRegistry:
    """Stdlib dict[str, RolePromptPack] lookup for BC-8 perspective agents.

    all_role_ids() returns a sorted tuple for determinism (D-059 R2:
    dict insertion order may vary; sorted ensures stable output).
    """

    def __init__(self) -> None:
        self._packs: dict[str, RolePromptPack] = {}

    def register(self, pack: RolePromptPack) -> None:
        """Register a RolePromptPack. Raises PersonaRegistryError on duplicate role_id.

        Fail-fast on duplicate: catches typos in persona-pack content authoring.
        Silent overwrite rejected per Karpathy P3 surgical-changes.
        """
        if pack.role_id in self._packs:
            existing = self._packs[pack.role_id]
            raise PersonaRegistryError(
                f"role_id {pack.role_id!r} already registered "
                f"(existing persona_name={existing.persona_name!r})"
            )
        self._packs[pack.role_id] = pack

    def get(self, role_id: str) -> RolePromptPack:
        """Lookup pack by role_id. Raises KeyError if not registered.

        Error message lists currently registered role_ids for diagnostics.
        """
        if role_id not in self._packs:
            registered = sorted(self._packs.keys())
            raise KeyError(
                f"role_id {role_id!r} not registered "
                f"(registered: {registered})"
            )
        return self._packs[role_id]

    def all_role_ids(self) -> tuple[str, ...]:
        """Return sorted tuple of registered role_ids (deterministic order per D-059)."""
        return tuple(sorted(self._packs.keys()))

    def load_from_json(self, json_path: Path, *, base_dir: Path | None = None) -> None:
        """Load a single role-pack JSON file and register it.

        D-064 path-safety 5-invariant compliance (checked in order):
        1. Reject '..' traversal segments (pre-resolve check)
        2. Extension must be .json (case-insensitive)
        3. Reject symlinks (real file only)
        4. Resolved path must be a regular file
        5. If base_dir provided, resolved path must be inside base_dir

        Raises PersonaRegistryError on any path-safety violation OR malformed JSON.
        Registers the resulting RolePromptPack via self.register() (inherits
        duplicate-role_id guard).
        """
        if not isinstance(json_path, Path):
            raise PersonaRegistryError(
                f"json_path must be pathlib.Path, got {type(json_path).__name__}"
            )
        # Invariant 1: reject traversal segments before resolve()
        if ".." in json_path.parts:
            raise PersonaRegistryError(
                f"json_path {json_path!r} contains '..' traversal segments (D-064)"
            )
        # Invariant 2: extension must be .json
        if json_path.suffix.lower() != ".json":
            raise PersonaRegistryError(
                f"json_path {json_path!r} must have .json extension"
            )
        # Invariant 3: reject symlinks
        if json_path.is_symlink():
            raise PersonaRegistryError(
                f"json_path {json_path!r} is a symlink (rejected per D-064)"
            )
        resolved = json_path.resolve()
        # Invariant 4: resolved path must be a regular file
        if not resolved.is_file():
            raise PersonaRegistryError(
                f"json_path {json_path!r} resolved to {resolved!r} which is not a file"
            )
        # Invariant 5: base_dir confinement
        if base_dir is not None:
            base_resolved = base_dir.resolve()
            try:
                resolved.relative_to(base_resolved)
            except ValueError as exc:
                raise PersonaRegistryError(
                    f"json_path {resolved!r} is outside base_dir {base_resolved!r} (D-064)"
                ) from exc

        try:
            content = resolved.read_text(encoding="utf-8")
            raw: object = json.loads(content)
        except (OSError, json.JSONDecodeError) as exc:
            raise PersonaRegistryError(
                f"failed to read/parse {json_path!r}: {exc}"
            ) from exc

        if not isinstance(raw, dict):
            raise PersonaRegistryError(
                f"json_path {json_path!r} top-level must be a JSON object, "
                f"got {type(raw).__name__}"
            )

        # JSON has no tuple type; convert list → tuple for category_universe
        raw_dict: dict[str, object] = raw
        if "category_universe" in raw_dict and isinstance(raw_dict["category_universe"], list):
            raw_dict = dict(raw_dict)
            raw_dict["category_universe"] = tuple(cast(list[object], raw_dict["category_universe"]))

        try:
            pack = RolePromptPack(**raw_dict)  # type: ignore[arg-type]
        except TypeError as exc:
            raise PersonaRegistryError(
                f"RolePromptPack construction failed for {json_path!r}: {exc}"
            ) from exc

        self.register(pack)
