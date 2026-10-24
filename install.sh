#!/usr/bin/env bash
# Symlink this repo's agents into ~/.claude/agents and its skills into ~/.claude/skills
# (alternative to installing the plugin).
# Usage: ./install.sh [--uninstall]
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link_all() { # <source glob dir> <dest dir> <pattern>
  local src="$1" dest="$2" pattern="$3"
  mkdir -p "$dest"
  # Prune dead links into this repo (agents/skills since renamed or deleted).
  for target in "$dest"/*; do
    if [[ -L "$target" && ! -e "$target" && "$(readlink "$target")" == "$src"/* ]]; then
      rm "$target" && echo "pruned $target"
    fi
  done
  for f in "$src"/$pattern; do
    [[ -e "$f" ]] || continue
    target="$dest/$(basename "$f")"
    if [[ "${UNINSTALL:-}" == 1 ]]; then
      # Only remove links that point into this repo.
      if [[ -L "$target" && "$(readlink "$target")" == "$f" ]]; then
        rm "$target" && echo "removed $target"
      fi
      continue
    fi
    # Don't clobber a real file or directory the user put there themselves.
    if [[ -e "$target" && ! -L "$target" ]]; then
      echo "skip   $target (exists and is not a symlink)"
      continue
    fi
    ln -sfn "$f" "$target"
    echo "linked $target -> $f"
  done
}

[[ "${1:-}" == "--uninstall" ]] && UNINSTALL=1
link_all "$root/agents" "$HOME/.claude/agents" '*.md'
link_all "$root/skills" "$HOME/.claude/skills" '*'
