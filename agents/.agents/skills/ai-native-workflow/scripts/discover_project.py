#!/usr/bin/env python3
"""Discover repository capabilities without starting services or reading secrets."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


INSTRUCTION_FILES = ("AGENTS.md", "CLAUDE.md", "OPENCODE.md", "GEMINI.md")
COMPOSE_FILES = (
    "compose.yaml",
    "compose.yml",
    "docker-compose.yaml",
    "docker-compose.yml",
)
LOCKFILE_MANAGERS = (
    ("pnpm-lock.yaml", "pnpm"),
    ("yarn.lock", "yarn"),
    ("bun.lock", "bun"),
    ("bun.lockb", "bun"),
    ("package-lock.json", "npm"),
)
EXCLUDED_DIRS = {
    ".git",
    ".next",
    ".nuxt",
    ".turbo",
    ".venv",
    "build",
    "coverage",
    "dist",
    "node_modules",
    "target",
    "vendor",
}
MIGRATION_DIRS = (
    "migrations",
    "db/migrate",
    "db/migrations",
    "prisma/migrations",
    "supabase/migrations",
    "alembic/versions",
)
KNOWN_MANIFESTS = (
    "package.json",
    "pyproject.toml",
    "requirements.txt",
    "uv.lock",
    "Pipfile",
    "poetry.lock",
    "Cargo.toml",
    "go.mod",
    "Gemfile",
    "Makefile",
    "Taskfile.yml",
    "Taskfile.yaml",
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("path", nargs="?", default=".", type=Path)
    parser.add_argument(
        "--format",
        choices=("json", "yaml"),
        default="json",
        help="Output format. Both formats mark discovered commands as unverified candidates.",
    )
    parser.add_argument("--pretty", action="store_true", help="Indent JSON output")
    parser.add_argument(
        "--check-profile",
        type=Path,
        help="Compare the discovered fingerprint with an existing JSON or YAML profile",
    )
    return parser.parse_args()


def find_project_root(start: Path) -> Path:
    current = (start if start.is_dir() else start.parent).resolve()
    for candidate in (current, *current.parents):
        if (candidate / ".git").exists():
            return candidate
    return current


def relative(root: Path, path: Path) -> str:
    try:
        return path.resolve().relative_to(root).as_posix()
    except ValueError:
        return str(path.resolve())


def find_instructions(root: Path, start: Path) -> list[str]:
    current = (start if start.is_dir() else start.parent).resolve()
    directories: list[Path] = []
    while True:
        directories.append(current)
        if current == root or current.parent == current:
            break
        current = current.parent

    found: list[Path] = []
    for directory in directories:
        for name in INSTRUCTION_FILES:
            path = directory / name
            if path.is_file() and path not in found:
                found.append(path)
    copilot = root / ".github" / "copilot-instructions.md"
    if copilot.is_file():
        found.append(copilot)
    return [relative(root, path) for path in found]


def read_json(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeDecodeError, json.JSONDecodeError):
        return {}
    return value if isinstance(value, dict) else {}


def package_manager(root: Path, package: dict[str, Any]) -> tuple[str | None, list[str]]:
    signals: list[str] = []
    declared = package.get("packageManager")
    if isinstance(declared, str) and declared:
        manager = declared.split("@", 1)[0]
        if manager in {"npm", "pnpm", "yarn", "bun"}:
            signals.append(f"package.json#packageManager:{manager}")
    for filename, manager in LOCKFILE_MANAGERS:
        if (root / filename).is_file():
            signals.append(f"{filename}:{manager}")
    chosen = signals[0].rsplit(":", 1)[-1] if signals else None
    return chosen, signals


def script_command(manager: str | None, script: str) -> str:
    if manager == "yarn":
        return f"yarn {script}"
    if manager == "pnpm":
        return f"pnpm {script}"
    if manager == "bun":
        return f"bun run {script}"
    return f"npm run {script}"


def command_candidate(command: str, source: str, name: str) -> dict[str, Any]:
    return {
        "name": name,
        "command": command,
        "source": source,
        "verified": False,
    }


def classify_package_scripts(
    package: dict[str, Any], manager: str | None, source: str = "package.json"
) -> tuple[list[dict[str, Any]], list[dict[str, Any]], list[dict[str, Any]]]:
    scripts = package.get("scripts")
    if not isinstance(scripts, dict):
        return [], [], []

    runtime: list[dict[str, Any]] = []
    verification: list[dict[str, Any]] = []
    destructive: list[dict[str, Any]] = []
    workdir = str(Path(source).parent)
    for name in sorted(str(key) for key in scripts):
        command = script_command(manager, name)
        candidate = command_candidate(command, f"{source}#scripts.{name}", name)
        if workdir != ".":
            candidate["workdir"] = workdir
        lowered = name.lower()
        if lowered in {"dev", "start", "serve", "preview"} or "worker" in lowered:
            runtime.append(candidate)
        if (
            lowered == "build"
            or lowered.startswith(("test", "lint", "typecheck"))
            or lowered in {"check", "verify", "validate"}
        ):
            verification.append(candidate)
        if re.search(r"(^|[:_-])(drop|purge|reset|truncate|destroy|delete-all)($|[:_-])", lowered):
            destructive.append(candidate)
    return runtime, verification, destructive


def repository_manifests(root: Path, max_depth: int = 4, limit: int = 500) -> list[Path]:
    supported_names = set(KNOWN_MANIFESTS)
    supported_names.update(filename for filename, _ in LOCKFILE_MANAGERS)
    found: list[Path] = []
    for current, directories, filenames in os.walk(root):
        directory = Path(current)
        depth = len(directory.relative_to(root).parts)
        directories[:] = sorted(
            name
            for name in directories
            if name not in EXCLUDED_DIRS and not name.startswith(".") and depth < max_depth
        )
        for filename in sorted(supported_names.intersection(filenames)):
            found.append(directory / filename)
            if len(found) >= limit:
                return sorted(found)
    return sorted(found)


def technology_inventory(
    root: Path, manifests: list[Path], packages: list[dict[str, Any]]
) -> dict[str, list[str]]:
    languages: set[str] = set()
    frameworks: set[str] = set()
    toolchains: set[str] = set()

    js_dependencies: set[str] = set()
    for package in packages:
        for key in ("dependencies", "devDependencies"):
            value = package.get(key)
            if isinstance(value, dict):
                js_dependencies.update(str(name) for name in value)
    if packages:
        languages.add("javascript/typescript")
        frameworks.update(
            framework
            for framework, signals in {
                "nextjs": {"next"},
                "react": {"react", "react-dom"},
                "vue": {"vue"},
                "svelte": {"svelte", "@sveltejs/kit"},
                "expo": {"expo"},
                "react-native": {"react-native"},
                "express": {"express"},
                "fastify": {"fastify"},
                "nestjs": {"@nestjs/core"},
            }.items()
            if js_dependencies & signals
        )

    manifest_names = {path.name for path in manifests}
    python_manifests = [
        path
        for path in manifests
        if path.name in {"pyproject.toml", "requirements.txt", "Pipfile"}
    ]
    if python_manifests:
        languages.add("python")
        if "uv.lock" in manifest_names:
            toolchains.add("uv")
        elif "poetry.lock" in manifest_names:
            toolchains.add("poetry")
        else:
            toolchains.add("pip")
        for manifest in python_manifests:
            try:
                python_config = manifest.read_text(encoding="utf-8").lower()
            except (OSError, UnicodeDecodeError):
                continue
            for name in ("django", "fastapi", "flask", "starlette", "celery"):
                if re.search(rf"(^|[^a-z0-9_-]){name}([^a-z0-9_-]|$)", python_config):
                    frameworks.add(name)

    cargo_manifests = [path for path in manifests if path.name == "Cargo.toml"]
    if cargo_manifests:
        languages.add("rust")
        toolchains.add("cargo")
        for manifest in cargo_manifests:
            try:
                cargo_config = manifest.read_text(encoding="utf-8").lower()
            except (OSError, UnicodeDecodeError):
                continue
            for name in ("axum", "actix-web", "rocket"):
                if re.search(rf"^\s*{re.escape(name)}\s*=", cargo_config, re.MULTILINE):
                    frameworks.add(name)

    if "go.mod" in manifest_names:
        languages.add("go")
        toolchains.add("go")
    gemfiles = [path for path in manifests if path.name == "Gemfile"]
    if gemfiles:
        languages.add("ruby")
        toolchains.add("bundler")
        if any((path.parent / "config" / "application.rb").is_file() for path in gemfiles):
            frameworks.add("rails")

    return {
        "languages": sorted(languages),
        "frameworks": sorted(frameworks),
        "toolchains": sorted(toolchains),
    }


def make_targets(path: Path) -> list[str]:
    if not path.is_file():
        return []
    targets: list[str] = []
    try:
        content = path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return []
    for line in content.splitlines():
        match = re.match(r"^([A-Za-z0-9][A-Za-z0-9_.-]*):(?:\s|$)", line)
        if match and "%" not in match.group(1):
            targets.append(match.group(1))
    return sorted(set(targets))


def classify_make_targets(
    root: Path, manifests: list[Path]
) -> tuple[list[dict[str, Any]], list[dict[str, Any]], list[dict[str, Any]]]:
    runtime: list[dict[str, Any]] = []
    verification: list[dict[str, Any]] = []
    destructive: list[dict[str, Any]] = []
    for makefile in (path for path in manifests if path.name == "Makefile"):
        source = relative(root, makefile)
        workdir = relative(root, makefile.parent)
        for name in make_targets(makefile):
            candidate = command_candidate(f"make {name}", f"{source}#{name}", name)
            if workdir != ".":
                candidate["workdir"] = workdir
            lowered = name.lower()
            if lowered in {"dev", "start", "serve", "run", "worker"}:
                runtime.append(candidate)
            if lowered in {
                "test",
                "lint",
                "typecheck",
                "check",
                "build",
                "verify",
                "validate",
            }:
                verification.append(candidate)
            if re.search(r"drop|purge|reset|truncate|destroy|delete", lowered):
                destructive.append(candidate)
    return runtime, verification, destructive


def parse_compose_services(path: Path) -> list[dict[str, str]]:
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except (OSError, UnicodeDecodeError):
        return []
    services_indent: int | None = None
    service_indent: int | None = None
    current: dict[str, str] | None = None
    result: list[dict[str, str]] = []
    for raw in lines:
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        indent = len(raw) - len(raw.lstrip(" "))
        stripped = raw.strip()
        if stripped == "services:":
            services_indent = indent
            service_indent = None
            current = None
            continue
        if services_indent is None:
            continue
        if indent <= services_indent:
            break
        key_match = re.match(r"^([A-Za-z0-9_.-]+):(?:\s*(.*))?$", stripped)
        if not key_match:
            continue
        if service_indent is None:
            service_indent = indent
        if indent == service_indent:
            current = {"name": key_match.group(1)}
            result.append(current)
            continue
        if current is not None and indent > service_indent and key_match.group(1) == "image":
            current["image"] = key_match.group(2).strip(" '\"")
    return result


def compose_inventory(root: Path) -> tuple[list[dict[str, str]], list[str]]:
    services: list[dict[str, str]] = []
    files: list[str] = []
    for name in COMPOSE_FILES:
        path = root / name
        if not path.is_file():
            continue
        files.append(name)
        for service in parse_compose_services(path):
            service["source"] = name
            services.append(service)
    return services, files


def detect_datastores(root: Path, services: list[dict[str, str]]) -> list[dict[str, str]]:
    patterns = {
        "postgres": ("postgres", "postgis", "timescale"),
        "mysql": ("mysql", "mariadb"),
        "mongodb": ("mongo",),
        "redis": ("redis", "valkey"),
    }
    found: list[dict[str, str]] = []
    for service in services:
        haystack = f"{service.get('name', '')} {service.get('image', '')}".lower()
        for datastore, needles in patterns.items():
            if any(needle in haystack for needle in needles):
                found.append(
                    {
                        "type": datastore,
                        "service": service["name"],
                        "source": service["source"],
                        "verified": False,
                    }
                )
                break
    if (root / "supabase").is_dir():
        found.append({"type": "supabase", "source": "supabase/", "verified": False})
    return found


def detect_surfaces(
    root: Path,
    packages: list[dict[str, Any]],
    services: list[dict[str, str]],
    technology: dict[str, list[str]],
) -> list[str]:
    dependencies: dict[str, Any] = {}
    for package in packages:
        for key in ("dependencies", "devDependencies"):
            value = package.get(key)
            if isinstance(value, dict):
                dependencies.update(value)
    names = set(dependencies)
    surfaces: set[str] = set()
    if names & {"next", "react", "react-dom", "vue", "svelte", "vite", "@angular/core"}:
        surfaces.add("web-ui")
    if names & {"expo", "react-native"} or (root / ".maestro").is_dir():
        surfaces.add("mobile-ui")
    if names & {"express", "fastify", "hono", "koa", "@nestjs/core"}:
        surfaces.add("http-api")
    if names & {"ws", "socket.io", "@nestjs/websockets"}:
        surfaces.add("websocket")
    if names & {"bull", "bullmq", "agenda"}:
        surfaces.add("async-worker")
    frameworks = set(technology["frameworks"])
    if frameworks & {
        "django",
        "fastapi",
        "flask",
        "starlette",
        "axum",
        "actix-web",
        "rocket",
        "rails",
    }:
        surfaces.add("http-api")
    if "celery" in frameworks:
        surfaces.add("async-worker")
    if any((root / name).exists() for name in ("openapi.yaml", "openapi.yml", "openapi.json")):
        surfaces.add("http-api")
    if services:
        surfaces.add("containers")
    return sorted(surfaces)


def migration_paths(root: Path) -> list[str]:
    return [path for path in MIGRATION_DIRS if (root / path).is_dir()]


def ci_paths(root: Path) -> list[str]:
    workflows = root / ".github" / "workflows"
    paths: list[Path] = []
    if workflows.is_dir():
        paths.extend(workflows.glob("*.yml"))
        paths.extend(workflows.glob("*.yaml"))
    for name in (".gitlab-ci.yml", "Jenkinsfile", "azure-pipelines.yml"):
        path = root / name
        if path.is_file():
            paths.append(path)
    return sorted(relative(root, path) for path in set(paths))


def fingerprint_files(root: Path, extra_paths: list[str]) -> str:
    candidates = {root / name for name in (*KNOWN_MANIFESTS, *COMPOSE_FILES)}
    candidates.update(root / filename for filename, _ in LOCKFILE_MANAGERS)
    candidates.update(root / path for path in extra_paths)
    digest = hashlib.sha256()
    for path in sorted((path for path in candidates if path.is_file()), key=str):
        digest.update(relative(root, path).encode())
        try:
            digest.update(path.read_bytes())
        except OSError:
            continue
    for migration in migration_paths(root):
        digest.update(migration.encode())
        directory = root / migration
        for path in sorted(item for item in directory.rglob("*") if item.is_file()):
            digest.update(relative(root, path).encode())
            try:
                digest.update(path.read_bytes())
            except OSError:
                continue
    return digest.hexdigest()


def dedupe_candidates(candidates: list[dict[str, Any]]) -> list[dict[str, Any]]:
    seen: set[tuple[str, str]] = set()
    result: list[dict[str, Any]] = []
    for candidate in candidates:
        command = str(candidate["command"])
        key = (command, str(candidate.get("workdir", ".")))
        if key not in seen:
            result.append(candidate)
            seen.add(key)
    return result


def discover(start: Path) -> dict[str, Any]:
    root = find_project_root(start)
    instructions = find_instructions(root, start.resolve())
    manifest_paths = repository_manifests(root)
    package_paths = [path for path in manifest_paths if path.name == "package.json"]
    package_records = [(path, read_json(path)) for path in package_paths]
    root_package = next((data for path, data in package_records if path.parent == root), {})
    manager, manager_signals = package_manager(root, root_package)
    package_runtime: list[dict[str, Any]] = []
    package_verification: list[dict[str, Any]] = []
    package_destructive: list[dict[str, Any]] = []
    for path, package in package_records:
        local_manager, _ = package_manager(path.parent, package)
        runtime, verification, destructive = classify_package_scripts(
            package, local_manager or manager, relative(root, path)
        )
        package_runtime.extend(runtime)
        package_verification.extend(verification)
        package_destructive.extend(destructive)
    make_runtime, make_verification, make_destructive = classify_make_targets(
        root, manifest_paths
    )
    services, compose_files = compose_inventory(root)
    ci = ci_paths(root)
    fingerprint_inputs = [
        *instructions,
        *ci,
        *(relative(root, path) for path in manifest_paths),
    ]
    manifests = [relative(root, path) for path in manifest_paths]
    technology = technology_inventory(
        root, manifest_paths, [package for _, package in package_records]
    )

    warnings: list[str] = []
    if not instructions:
        warnings.append("No project-local agent instruction file was found.")
    if len({signal.rsplit(":", 1)[-1] for signal in manager_signals}) > 1:
        warnings.append("Conflicting JavaScript package-manager signals require review.")
    if not package_runtime and not make_runtime:
        warnings.append("No canonical application start command was discovered.")
    if not package_verification and not make_verification:
        warnings.append("No canonical verification command was discovered.")

    return {
        "schema_version": 1,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "root": ".",
        "source_fingerprint": fingerprint_files(root, fingerprint_inputs),
        "discovery_mode": "read-only-candidates",
        "instructions": instructions,
        "manifests": sorted(set(manifests)),
        "technology": technology,
        "package_manager": {
            "selected_candidate": manager,
            "signals": manager_signals,
            "verified": False,
        },
        "runtime": {
            "candidates": dedupe_candidates([*package_runtime, *make_runtime]),
            "compose_files": compose_files,
            "services": services,
        },
        "verification": {
            "candidates": dedupe_candidates([*package_verification, *make_verification]),
            "ci_workflows": ci,
        },
        "datastores": detect_datastores(root, services),
        "migrations": migration_paths(root),
        "surfaces": detect_surfaces(
            root, [package for _, package in package_records], services, technology
        ),
        "safety": {
            "destructive_command_candidates": dedupe_candidates(
                [*package_destructive, *make_destructive]
            ),
            "production_operations_verified_safe": False,
        },
        "warnings": warnings,
    }


def load_profile_fingerprint(path: Path) -> str | None:
    try:
        content = path.read_text(encoding="utf-8")
    except OSError:
        return None
    try:
        parsed = json.loads(content)
    except json.JSONDecodeError:
        parsed = None
    if isinstance(parsed, dict) and isinstance(parsed.get("source_fingerprint"), str):
        return parsed["source_fingerprint"]
    match = re.search(r"^source_fingerprint:\s*[\"']?([a-f0-9]{64})[\"']?\s*$", content, re.MULTILINE)
    return match.group(1) if match else None


def yaml_scalar(value: Any) -> str:
    if value is None:
        return "null"
    if value is True:
        return "true"
    if value is False:
        return "false"
    if isinstance(value, (int, float)):
        return str(value)
    return json.dumps(str(value), ensure_ascii=False)


def to_yaml(value: Any, indent: int = 0) -> str:
    prefix = " " * indent
    if isinstance(value, dict):
        lines: list[str] = []
        for key, item in value.items():
            if isinstance(item, (dict, list)) and item:
                lines.append(f"{prefix}{key}:")
                lines.append(to_yaml(item, indent + 2))
            elif isinstance(item, (dict, list)):
                lines.append(f"{prefix}{key}: {'{}' if isinstance(item, dict) else '[]'}")
            else:
                lines.append(f"{prefix}{key}: {yaml_scalar(item)}")
        return "\n".join(lines)
    if isinstance(value, list):
        lines = []
        for item in value:
            if isinstance(item, dict):
                if not item:
                    lines.append(f"{prefix}- {{}}")
                    continue
                first_key, first_value = next(iter(item.items()))
                if isinstance(first_value, (dict, list)):
                    lines.append(f"{prefix}- {first_key}:")
                    lines.append(to_yaml(first_value, indent + 4))
                else:
                    lines.append(f"{prefix}- {first_key}: {yaml_scalar(first_value)}")
                remaining = dict(list(item.items())[1:])
                if remaining:
                    lines.append(to_yaml(remaining, indent + 2))
            elif isinstance(item, list):
                lines.append(f"{prefix}-")
                lines.append(to_yaml(item, indent + 2))
            else:
                lines.append(f"{prefix}- {yaml_scalar(item)}")
        return "\n".join(lines)
    return f"{prefix}{yaml_scalar(value)}"


def main() -> int:
    args = parse_args()
    profile = discover(args.path)
    if args.check_profile:
        expected = load_profile_fingerprint(args.check_profile)
        profile["profile_check"] = {
            "path": str(args.check_profile),
            "readable_fingerprint": expected is not None,
            "fresh": expected == profile["source_fingerprint"] if expected else False,
        }
    if args.format == "yaml":
        print(to_yaml(profile))
    else:
        print(json.dumps(profile, indent=2 if args.pretty else None, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
