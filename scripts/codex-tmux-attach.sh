#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  printf 'Usage: %s <tmux-session> <working-directory> <codex-session>\n' "$0" >&2
  exit 64
fi

tmux_session=$1
working_directory=$2
codex_session=$3
codex_bin="$HOME/.bun/bin/codex"

if [[ ! $tmux_session =~ ^[A-Za-z0-9._-]+$ ]]; then
  printf 'Invalid tmux session name: %s\n' "$tmux_session" >&2
  exit 64
fi

if [[ ! $codex_session =~ ^[A-Za-z0-9._-]+$ ]]; then
  printf 'Invalid Codex session name: %s\n' "$codex_session" >&2
  exit 64
fi

if [[ ! -d $working_directory ]]; then
  printf 'Working directory does not exist: %s\n' "$working_directory" >&2
  exit 72
fi

if [[ ! -x $codex_bin ]]; then
  printf 'Codex executable is unavailable: %s\n' "$codex_bin" >&2
  exit 69
fi

if ! tmux has-session -t "=$tmux_session" 2>/dev/null; then
  shell_bin=${SHELL:-/usr/bin/zsh}
  if [[ ! -x $shell_bin ]]; then
    shell_bin=/bin/sh
  fi

  printf -v codex_command '%q ' \
    "$codex_bin" \
    resume \
    --dangerously-bypass-approvals-and-sandbox \
    "$codex_session"
  printf -v shell_command '%q -l' "$shell_bin"
  tmux new-session -d -s "$tmux_session" -c "$working_directory" \
    "$codex_command; exec $shell_command"
fi

exec tmux attach-session -t "=$tmux_session"
