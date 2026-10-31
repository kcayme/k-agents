# Scripts

Maintainer tools for measuring what the agents cost. The plugin doesn't use them.

## token-report.py

Token usage of one Claude Code session, per agent: the main thread plus every subagent it started. `/usage` leaves subagents out.

```sh
scripts/token-report.py                  # the most recently modified session
scripts/token-report.py <session id>     # e.g. one started with claude --session-id <uuid>
scripts/token-report.py <path/to/session.jsonl>
```

It reads the transcripts in `~/.claude/projects/`, so it works for a session in any repo and sends nothing anywhere.

| Column | Meaning |
|---|---|
| turns | model calls the agent made |
| startup | tokens in the agent's first call: system prompt, tools, agent file |
| input | uncached input tokens |
| cache write | tokens written to the prompt cache (billed at 1.25× input) |
| cache read | tokens read from the cache (billed at about 0.1× input) |
| output | tokens the agent generated |

When subagents run in parallel, one of them may read a cache another just wrote. Count a subagent's first-call cache read as a write when comparing runs.

## bench-reset.sh

Resets a repo after a benchmark run of a ticket, so the next run starts fresh.

```sh
scripts/bench-reset.sh <repo dir> <ticket key, e.g. gh-1> <archive dir>
```

It:

1. moves the ticket's plan and log folder (`~/.claude/k-agents/<owner>/<repo>/<key>`) to `<archive dir>/ticket`
2. removes the ticket's worktrees (branches ending in `/<key>`)
3. puts the main checkout back on the default branch
4. deletes the ticket's local branches, and warns when a branch was also pushed

It refuses to run when the main checkout has uncommitted changes or the archive folder already exists, so it never discards work. It respects `CLAUDE_CONFIG_DIR`.

It hard-codes the plugin's ticket-folder and branch naming. Update it in the same change if that naming changes.

## A benchmark run

Plan and implement one ticket per session with a fixed set of answers, record each session's tokens, then reset:

```sh
id=$(uuidgen)
claude --session-id "$id" --agent kagents:ticket-planner "plan #1 ..."
scripts/token-report.py "$id" > run1-plan.txt
# the same for kagents:implementer, then:
scripts/bench-reset.sh ~/dev/my-repo gh-1 runs/run1
```

Run each ticket at least 3 times and compare medians: the same ticket varies by about 1.5× between runs.
