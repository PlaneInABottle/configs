#!/usr/bin/env bash
# scaffold.sh — Copy react-native-expo template and initialize project
# Usage: ./scaffold.sh <project-name> [target-directory]

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE_DIR="$SKILL_DIR/assets/template-bare"

PROJECT_NAME="${1:?Usage: scaffold.sh <project-name> [target-directory]}"
TARGET_DIR="${2:-.}"

PROJECT_PATH="$TARGET_DIR/$PROJECT_NAME"

# Validate
if [ -d "$PROJECT_PATH" ]; then
  echo "Error: Directory '$PROJECT_PATH' already exists"
  exit 1
fi

if [ ! -d "$TEMPLATE_DIR" ]; then
  echo "Error: Template not found at $TEMPLATE_DIR"
  exit 1
fi

# Copy template
echo "Scaffolding $PROJECT_NAME..."
cp -r "$TEMPLATE_DIR" "$PROJECT_PATH"

# Update project name in package.json
if command -v python3 &>/dev/null; then
  python3 -c "
import json
with open('$PROJECT_PATH/package.json', 'r') as f:
    pkg = json.load(f)
pkg['name'] = '$PROJECT_NAME'
with open('$PROJECT_PATH/package.json', 'w') as f:
    json.dump(pkg, f, indent=2)
"
fi

# Update app.json name
if command -v python3 &>/dev/null; then
  python3 -c "
import json
with open('$PROJECT_PATH/app.json', 'r') as f:
    cfg = json.load(f)
cfg['expo']['name'] = '$PROJECT_NAME'
cfg['expo']['slug'] = '$PROJECT_NAME'
with open('$PROJECT_PATH/app.json', 'w') as f:
    json.dump(cfg, f, indent=2)
"
fi

# Install dependencies
echo "Installing dependencies..."
cd "$PROJECT_PATH"
npm install

echo ""
echo "Done! Project scaffolded at: $PROJECT_PATH"
echo ""
echo "Next steps:"
echo "  cd $PROJECT_PATH"
echo "  npx expo start"
