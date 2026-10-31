#!/usr/bin/env bash
# Reset a repo after a benchmark run of a ticket, so the next run starts fresh:
# archive the ticket's plan/log folder, remove its worktree and local branch,
# and put the main checkout back on the default branch.
# Usage: scripts/bench-reset.sh <repo dir> <ticket key, e.g. gh-1> <archive dir>
set -euo pipefail

[[ $# -eq 3 ]] || { echo "usage: $0 <repo dir> <ticket key> <archive dir>" >&2; exit 2; }
repo="$(cd "$1" && git rev-parse --show-toplevel)"
key="$2"
archive="$3"
cd "$repo"

remote="$(git remote get-url origin)"
slug="$(sed -E 's#(\.git)?/?$##; s#.*[:/]([^/]+/[^/]+)$#\1#' <<<"$remote")"
ticket_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/k-agents/$slug/$key"
default="$(git symbolic-ref --short refs/remotes/origin/HEAD)"
default="${default#origin/}"

# The main checkout may hold the user's own work; never discard it.
if [[ -n "$(git status --porcelain)" ]]; then
  echo "main checkout $repo has uncommitted changes; commit or move them first" >&2
  exit 1
fi
[[ ! -e "$archive" ]] || { echo "archive dir $archive already exists" >&2; exit 1; }

mkdir -p "$archive"
if [[ -d "$ticket_dir" ]]; then
  mv "$ticket_dir" "$archive/ticket" && echo "archived $ticket_dir -> $archive/ticket"
else
  echo "no ticket folder at $ticket_dir"
fi

# Worktrees on the ticket's branch; --force because a run leaves node_modules and build output.
git worktree list --porcelain | awk -v k="$key" '
  /^worktree /{p=substr($0,10)} /^branch /{b=$2; sub("refs/heads/","",b); if (b ~ ("/" k "$")) print p}' |
  while read -r wt; do
    [[ "$wt" == "$repo" ]] && continue
    git worktree remove --force "$wt" && echo "removed worktree $wt"
  done
git worktree prune

current="$(git branch --show-current)"
if [[ "$current" == */"$key" ]]; then
  git switch -q "$default" && echo "main checkout: $current -> $default"
fi

git for-each-ref --format='%(refname:short)' "refs/heads/*/$key" | while read -r branch; do
  if git rev-parse -q --verify "refs/remotes/origin/$branch" >/dev/null; then
    echo "warning: $branch also exists on origin; left there" >&2
  fi
  git branch -q -D "$branch" && echo "deleted branch $branch"
done

git switch -q "$default" 2>/dev/null || true
echo "ready: $repo on $default"
