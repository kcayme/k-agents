# k-agents

Claude Code agents for taking a ticket from plan to merged PR.

| Agent | Does |
|---|---|
| `ticket-planner` | Checks a GitHub/Jira ticket is ready, raises unclear details, creates a worktree, and writes a plan mapping each acceptance criterion to a change, a test, and a conventional commit. |
| `system-architect` | Researches options for a design problem, compares tradeoffs, recommends one, and writes an ADR. |
| `qa-backend` | Reviews test plans, or writes and runs backend unit, API, and e2e tests. |
| `qa-frontend` | Reviews test plans, or writes and runs component, browser e2e, accessibility, and visual regression tests. |
| `pr-reviewer` | Reviews a GitHub/Bitbucket PR against its ticket's AC, conventions, YAGNI/DRY, tests, and coverage, verifying every finding first. |

## Flow

```
ticket-planner ─┬─> system-architect   (design-heavy tickets, before planning)
                └─> qa-backend / qa-frontend   (test plan review)
implement ──> qa-backend / qa-frontend   (fill test gaps)
PR ──> pr-reviewer
```

## Install

Agents are symlinked into `~/.claude/agents/` so they work in every repo:

```sh
./install.sh
```

Safe to re-run. Existing symlinks are updated; real files with the same name are left alone.

## Use

Run as the main agent so it can delegate to other agents (subagents can't spawn subagents):

```
claude --agent ticket-planner      # then: plan PROJ-123
claude --agent pr-reviewer         # then: review #42
```

## Shared rules

- **Never assume.** Anything unclear is asked, unless you say to assume.
- **Follow the project's conventions.** Written rules first, then tooling config, then existing patterns.
- **Read-only on tickets.** Nothing is posted, committed, or pushed unless asked.
- **Conventional Commits**, grouped by logic/domain.

## Requirements

- `gh` (authenticated) for GitHub
- Atlassian Rovo MCP for Jira/Confluence
- ponytail plugin (`ponytail-review` skill)
- Bitbucket Cloud: the `bkt` CLI (logged in), or `BITBUCKET_EMAIL` and `BITBUCKET_API_TOKEN` env vars as a fallback
