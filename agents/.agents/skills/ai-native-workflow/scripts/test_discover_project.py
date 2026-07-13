#!/usr/bin/env python3

import json
import tempfile
import unittest
from pathlib import Path

import yaml

from discover_project import discover, load_profile_fingerprint, to_yaml


class DiscoverProjectTests(unittest.TestCase):
    def make_project(self, directory: str) -> Path:
        root = Path(directory)
        (root / ".git").mkdir()
        (root / ".github" / "workflows").mkdir(parents=True)
        (root / "supabase" / "migrations").mkdir(parents=True)
        (root / "AGENTS.md").write_text("# Project instructions\n", encoding="utf-8")
        (root / "pnpm-lock.yaml").write_text("lockfileVersion: '9.0'\n", encoding="utf-8")
        (root / "package.json").write_text(
            json.dumps(
                {
                    "packageManager": "pnpm@9.1.0",
                    "scripts": {
                        "dev": "vite",
                        "worker": "node worker.js",
                        "test": "vitest run",
                        "lint": "eslint .",
                        "db:reset": "node reset.js",
                    },
                    "dependencies": {"vite": "1", "ws": "1"},
                }
            ),
            encoding="utf-8",
        )
        (root / "compose.yaml").write_text(
            "services:\n  db:\n    image: postgres:16\n  mailpit:\n    image: axllent/mailpit\n",
            encoding="utf-8",
        )
        (root / ".github" / "workflows" / "ci.yml").write_text("name: CI\n", encoding="utf-8")
        (root / "supabase" / "migrations" / "001.sql").write_text("select 1;\n", encoding="utf-8")
        (root / ".env").write_text("SECRET_TOKEN=do-not-read\n", encoding="utf-8")
        return root

    def test_discovers_only_sourced_candidates(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = self.make_project(directory)
            profile = discover(root)
            runtime = {candidate["command"] for candidate in profile["runtime"]["candidates"]}
            verification = {
                candidate["command"] for candidate in profile["verification"]["candidates"]
            }
            self.assertEqual(profile["package_manager"]["selected_candidate"], "pnpm")
            self.assertIn("pnpm dev", runtime)
            self.assertIn("pnpm worker", runtime)
            self.assertIn("pnpm test", verification)
            self.assertIn("supabase/migrations", profile["migrations"])
            self.assertIn("websocket", profile["surfaces"])
            self.assertEqual(profile["datastores"][0]["type"], "postgres")
            self.assertFalse(profile["runtime"]["candidates"][0]["verified"])
            self.assertNotIn("do-not-read", json.dumps(profile))

    def test_fingerprint_changes_with_capability_sources(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = self.make_project(directory)
            before = discover(root)["source_fingerprint"]
            package = json.loads((root / "package.json").read_text(encoding="utf-8"))
            package["scripts"]["build"] = "vite build"
            (root / "package.json").write_text(json.dumps(package), encoding="utf-8")
            after = discover(root)["source_fingerprint"]
            self.assertNotEqual(before, after)

    def test_fingerprint_changes_when_migration_content_changes(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = self.make_project(directory)
            migration = root / "supabase" / "migrations" / "001.sql"
            before = discover(root)["source_fingerprint"]
            migration.write_text("select 2;\n", encoding="utf-8")
            after = discover(root)["source_fingerprint"]
            self.assertNotEqual(before, after)

    def test_reads_json_and_yaml_profile_fingerprints(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            fingerprint = "a" * 64
            json_profile = Path(directory) / "profile.json"
            yaml_profile = Path(directory) / "profile.yaml"
            json_profile.write_text(
                json.dumps({"source_fingerprint": fingerprint}), encoding="utf-8"
            )
            yaml_profile.write_text(
                f'source_fingerprint: "{fingerprint}"\n', encoding="utf-8"
            )
            self.assertEqual(load_profile_fingerprint(json_profile), fingerprint)
            self.assertEqual(load_profile_fingerprint(yaml_profile), fingerprint)

    def test_yaml_output_preserves_candidate_status(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            profile = discover(self.make_project(directory))
            rendered = to_yaml(profile)
            self.assertIn('discovery_mode: "read-only-candidates"', rendered)
            self.assertIn("verified: false", rendered)
            self.assertEqual(yaml.safe_load(rendered)["source_fingerprint"], profile["source_fingerprint"])

    def test_discovers_nested_package_without_leaking_local_root(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = self.make_project(directory)
            app = root / "apps" / "web"
            app.mkdir(parents=True)
            (app / "package.json").write_text(
                json.dumps({"scripts": {"dev": "next dev"}, "dependencies": {"next": "1"}}),
                encoding="utf-8",
            )
            profile = discover(app)
            candidate = next(
                item
                for item in profile["runtime"]["candidates"]
                if item["source"].startswith("apps/web/package.json")
            )
            self.assertEqual(candidate["workdir"], "apps/web")
            self.assertEqual(profile["root"], ".")
            self.assertIn("nextjs", profile["technology"]["frameworks"])

    def test_preserves_same_command_for_each_workspace(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = self.make_project(directory)
            for workspace in ("apps/api", "apps/web"):
                path = root / workspace
                path.mkdir(parents=True)
                (path / "package.json").write_text(
                    json.dumps({"scripts": {"dev": "node server.js"}}),
                    encoding="utf-8",
                )
            profile = discover(root)
            workdirs = {
                item.get("workdir")
                for item in profile["runtime"]["candidates"]
                if item["command"] == "pnpm dev"
            }
            self.assertEqual(workdirs, {None, "apps/api", "apps/web"})

    def test_discovers_nested_non_javascript_services(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / ".git").mkdir()
            python_service = root / "apps" / "api"
            rust_service = root / "services" / "gateway"
            go_service = root / "tools" / "worker"
            python_service.mkdir(parents=True)
            rust_service.mkdir(parents=True)
            go_service.mkdir(parents=True)
            (python_service / "pyproject.toml").write_text(
                '[project]\ndependencies = ["fastapi"]\n', encoding="utf-8"
            )
            (python_service / "Makefile").write_text(
                "dev:\n\tuv run app\n\ntest:\n\tuv run pytest\n", encoding="utf-8"
            )
            (rust_service / "Cargo.toml").write_text(
                '[package]\nname = "gateway"\n[dependencies]\naxum = "0.8"\n',
                encoding="utf-8",
            )
            (go_service / "go.mod").write_text(
                "module example.com/worker\n\ngo 1.24\n", encoding="utf-8"
            )

            profile = discover(python_service)

            self.assertIn("apps/api/pyproject.toml", profile["manifests"])
            self.assertIn("services/gateway/Cargo.toml", profile["manifests"])
            self.assertIn("tools/worker/go.mod", profile["manifests"])
            self.assertEqual(
                profile["technology"]["languages"], ["go", "python", "rust"]
            )
            self.assertIn("fastapi", profile["technology"]["frameworks"])
            self.assertIn("axum", profile["technology"]["frameworks"])
            self.assertIn("http-api", profile["surfaces"])
            self.assertIn(
                {
                    "name": "dev",
                    "command": "make dev",
                    "source": "apps/api/Makefile#dev",
                    "verified": False,
                    "workdir": "apps/api",
                },
                profile["runtime"]["candidates"],
            )
            self.assertNotIn(
                "No canonical application start command was discovered.", profile["warnings"]
            )
            self.assertNotIn(
                "No canonical verification command was discovered.", profile["warnings"]
            )


if __name__ == "__main__":
    unittest.main()
