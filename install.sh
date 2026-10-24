#!/usr/bin/env bash
# Symlink this repo's agents into ~/.claude/agents (alternative to installing the plugin).
# Usage: ./install.sh [--uninstall]
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/agents"
dest="$HOME/.claude/agents"
mkdir -p "$dest"

for f in "$src"/*.md; do
  target="$dest/$(basename "$f")"
  if [[ "${1:-}" == "--uninstall" ]]; then
    # Only remove links that point into this repo.
    if [[ -L "$target" && "$(readlink "$target")" == "$f" ]]; then
      rm "$target" && echo "removed $target"
    fi
    continue
  fi
  # Don't clobber a real file the user put there themselves.
  if [[ -e "$target" && ! -L "$target" ]]; then
    echo "skip   $target (exists and is not a symlink)"
    continue
  fi
  ln -sfn "$f" "$target"
  echo "linked $target -> $f"
done
