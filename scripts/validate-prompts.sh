#!/usr/bin/env bash
# Validate prompt templates and every generated output without modifying files.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$SCRIPT_DIR/validate_prompts.py"
