#!/usr/bin/env bash
set -euo pipefail

kitty_bin=${KITTY_WORKSPACE_KITTY_BIN:-"$HOME/.local/bin/kitty"}
session_file=${KITTY_WORKSPACE_SESSION_FILE:-"$HOME/configs/kitty/.config/kitty/codex-workspace.kitty-session"}
runtime_dir=${XDG_RUNTIME_DIR:-"/tmp"}
lock_file="$runtime_dir/kitty-codex-workspace.lock"

if [[ ! -x $kitty_bin ]]; then
  printf 'Kitty executable is unavailable: %s\n' "$kitty_bin" >&2
  exit 69
fi

if [[ ! -r $session_file ]]; then
  printf 'Kitty workspace session is unavailable: %s\n' "$session_file" >&2
  exit 66
fi

exec 9>"$lock_file"
if ! flock -n 9; then
  exit 0
fi

exec "$kitty_bin" \
  --class codex-workspace \
  --name codex-workspace \
  --session "$session_file"
