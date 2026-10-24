#!/usr/bin/env bash
# Symlink this repo's agents into ~/.claude/agents so they work in every repo.
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.claude/agents"
dest="$HOME/.claude/agents"
mkdir -p "$dest"

for f in "$src"/*.md; do
  target="$dest/$(basename "$f")"
  # Don't clobber a real file the user put there themselves.
  if [[ -e "$target" && ! -L "$target" ]]; then
    echo "skip   $target (exists and is not a symlink)"
    continue
  fi
  ln -sfn "$f" "$target"
  echo "linked $target -> $f"
done
