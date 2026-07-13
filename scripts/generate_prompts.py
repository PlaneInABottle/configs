#!/usr/bin/env python3
"""Generate and verify global and role-agent prompts."""

from __future__ import annotations

import argparse
import difflib
import fcntl
import json
import os
import tempfile
from contextlib import contextmanager
from pathlib import Path

from render_prompts import RenderError, render


ROOT = Path(__file__).resolve().parent.parent
GLOBAL_DIR = ROOT / "templates/global-instructions"
GLOBAL_METADATA = GLOBAL_DIR / "metadata.json"
GLOBAL_MASTER = GLOBAL_DIR / "master.md"
AGENT_DIR = ROOT / "templates/subagents/master"
AGENT_METADATA = AGENT_DIR / "METADATA.json"
SUPPORTED_AGENT_SYSTEMS = ("copilot", "claude", "opencode")


class GenerationError(RuntimeError):
    pass


@contextmanager
def generation_lock(name: str):
    lock_path = Path(tempfile.gettempdir()) / f"configs-{name}-prompts.lock"
    with lock_path.open("a+", encoding="utf-8") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError as error:
            raise GenerationError(f"Another {name} prompt generator is already running") from error
        yield


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def show_diff(target: Path, expected: str) -> None:
    actual = target.read_text(encoding="utf-8") if target.is_file() else ""
    print(
        "".join(
            difflib.unified_diff(
                actual.splitlines(keepends=True),
                expected.splitlines(keepends=True),
                fromfile=str(target),
                tofile=f"{target} (expected)",
            )
        ),
        end="",
    )


def write_atomic(target: Path, content: str) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary_name = tempfile.mkstemp(
        prefix=f".{target.name}.", dir=target.parent
    )
    temporary = Path(temporary_name)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as output:
            output.write(content)
            output.flush()
            os.fsync(output.fileno())
        mode = target.stat().st_mode & 0o777 if target.exists() else 0o644
        temporary.chmod(mode)
        os.replace(temporary, target)
    finally:
        temporary.unlink(missing_ok=True)


def apply_output(target: Path, content: str, *, check: bool, dry_run: bool) -> bool:
    if dry_run:
        print(f"[DRY RUN] Would update: {target}")
        return True
    if check:
        if not target.is_file() or target.read_text(encoding="utf-8") != content:
            print(f"ERROR: stale or missing output: {target}")
            show_diff(target, content)
            return False
        print(f"OK: {target}")
        return True
    write_atomic(target, content)
    print(f"Updated: {target} ({content.count(chr(10))} lines)")
    return True


def render_global(system: str, metadata: dict) -> tuple[Path, str]:
    config = metadata["systems"][system]
    target = ROOT / config["target_file"]
    rendered = render(GLOBAL_MASTER.read_text(encoding="utf-8"), system, metadata)
    marker = (
        "<!-- sync-test: generated via templates/global-instructions/master.md "
        "+ scripts/update-global-instructions.sh -->"
    )
    if config["requires_header"]:
        header = (GLOBAL_DIR / "headers" / f"{system}.header").read_text(
            encoding="utf-8"
        ).rstrip("\n")
        content = f"{header}\n\n{marker}\n\n{rendered}"
    else:
        content = f"{marker}\n\n{rendered}"
    return target, content


def agent_output_path(agent: str, system: str) -> Path:
    paths = {
        "copilot": ROOT / f"copilot/.copilot/agents/{agent}.agent.md",
        "claude": ROOT / f"claude/.claude/agents/{agent}.md",
        "opencode": ROOT / f"opencode/.config/opencode/agent/{agent}.md",
        "codex": ROOT / f"codex/.codex/agents/{agent}.toml",
    }
    return paths[system]


def agent_header(agent: dict, system: str) -> str:
    name = agent["name"]
    description = json.dumps(agent["description"])
    if system == "copilot":
        return f"---\nname: {name}\ndescription: {description}\n---"
    if system == "claude":
        return f"---\nname: {name}\ndescription: {description}\nmodel: inherit\n---"
    mode = agent.get("mode", "subagent")
    examples = "\n".join(agent.get("examples", []))
    return f"---\ndescription: {description}\nmode: {mode}\nexamples:\n{examples}\n---"


def render_agent(name: str, system: str, metadata: dict) -> tuple[Path, str]:
    agent = metadata["subagents"][name]
    master = AGENT_DIR / f"{name}.md"
    if not master.is_file():
        raise GenerationError(f"Missing agent template: {master}")
    rendered = render(master.read_text(encoding="utf-8"), system, metadata, ROOT)
    return agent_output_path(name, system), f"{agent_header(agent, system)}\n\n{rendered}"


def remove_or_reject_stale(target: Path, *, check: bool, dry_run: bool) -> bool:
    if not target.exists():
        return True
    if check:
        print(f"ERROR: stale disabled agent output: {target}")
        return False
    if dry_run:
        print(f"[DRY RUN] Would remove stale output: {target}")
        return True
    target.unlink()
    print(f"Removed stale output: {target}")
    return True


def reconcile_agent_outputs(metadata: dict, *, check: bool, dry_run: bool) -> bool:
    expected = {
        agent_output_path(name, system)
        for name, config in metadata["subagents"].items()
        for system in config.get("enabled_systems", [])
    }
    actual = set((ROOT / "copilot/.copilot/agents").glob("*.agent.md"))
    actual.update((ROOT / "claude/.claude/agents").glob("*.md"))
    actual.update((ROOT / "opencode/.config/opencode/agent").glob("*.md"))

    codex_agents = set((ROOT / "codex/.codex/agents").glob("*.toml"))
    allowed_codex = {
        ROOT / "codex/.codex/agents/explorer.toml",
        ROOT / "codex/.codex/agents/worker.toml",
    }
    unexpected = sorted(actual.difference(expected) | codex_agents.difference(allowed_codex))

    valid = True
    for target in unexpected:
        valid = remove_or_reject_stale(target, check=check, dry_run=dry_run) and valid
    return valid


def generate_globals(args: argparse.Namespace) -> bool:
    metadata = load_json(GLOBAL_METADATA)
    systems = list(metadata["systems"])
    if args.system != "all":
        if args.system not in systems:
            raise GenerationError(f"Unknown global system: {args.system}")
        systems = [args.system]

    valid = True
    with generation_lock("global"):
        for system in systems:
            target, content = render_global(system, metadata)
            valid = (
                apply_output(target, content, check=args.check, dry_run=args.dry_run)
                and valid
            )
    return valid


def generate_agents(args: argparse.Namespace) -> bool:
    metadata = load_json(AGENT_METADATA)
    agents = list(metadata["subagents"])
    configured_systems = {
        system
        for agent in metadata["subagents"].values()
        for system in agent.get("enabled_systems", [])
    }
    unknown_systems = configured_systems.difference(SUPPORTED_AGENT_SYSTEMS)
    if unknown_systems:
        raise GenerationError(
            f"Unsupported enabled_systems values: {', '.join(sorted(unknown_systems))}"
        )
    if args.agent != "all":
        if args.agent not in agents:
            raise GenerationError(f"Unknown agent: {args.agent}")
        agents = [args.agent]

    systems = list(SUPPORTED_AGENT_SYSTEMS)
    if args.system != "all":
        if args.system not in systems:
            raise GenerationError(f"Unknown role-agent system: {args.system}")
        systems = [args.system]

    valid = True
    with generation_lock("role"):
        for name in agents:
            enabled = set(metadata["subagents"][name].get("enabled_systems", []))
            for system in systems:
                target = agent_output_path(name, system)
                if system in enabled:
                    target, content = render_agent(name, system, metadata)
                    valid = (
                        apply_output(
                            target, content, check=args.check, dry_run=args.dry_run
                        )
                        and valid
                    )
                else:
                    valid = (
                        remove_or_reject_stale(
                            target, check=args.check, dry_run=args.dry_run
                        )
                        and valid
                    )
    if args.agent == "all" and args.system == "all":
        valid = reconcile_agent_outputs(
            metadata, check=args.check, dry_run=args.dry_run
        ) and valid
    return valid


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("kind", choices=("global", "agents"))
    parser.add_argument("--system", default="all")
    parser.add_argument("--agent", default="all")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--dry-run", action="store_true")
    mode.add_argument("--check", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        if args.kind == "global" and args.agent != "all":
            raise GenerationError("--agent is valid only for role-agent generation")
        valid = generate_globals(args) if args.kind == "global" else generate_agents(args)
    except (OSError, json.JSONDecodeError, RenderError, GenerationError) as error:
        print(f"ERROR: {error}")
        return 1
    return 0 if valid else 1


if __name__ == "__main__":
    raise SystemExit(main())
