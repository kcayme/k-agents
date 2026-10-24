# k-agents

Claude Code agents for taking a ticket from plan to merged PR.

| Agent | Does |
|---|---|
| `ticket-planner` | Checks a GitHub/Jira ticket is ready, raises unclear details, creates a worktree, and writes a plan mapping each acceptance criterion to a change, a test, and a conventional commit. |
| `system-architect` | Researches options for a design problem, compares tradeoffs, recommends one, and writes an ADR. |
| `implementer` | Implements a plan in its worktree commit by commit (test first, checks green, local conventional commit), guarding against regressions, then runs QA and self-review. Pushes and opens a PR only with explicit permission. |
| `qa-backend` | Reviews test plans, or writes and runs backend unit, API (Hurl), and e2e tests. |
| `qa-frontend` | Reviews test plans, or writes and runs component, browser e2e, accessibility, and visual regression tests. |
| `pr-reviewer` | Reviews a GitHub/Bitbucket PR against its ticket's AC, conventions, YAGNI/DRY, tests, and coverage, verifying every finding first. |

## Flow

```
ticket-planner ─┬─> system-architect   (design-heavy tickets, before planning)
                └─> qa-backend / qa-frontend   (test plan review)
implementer ──> qa-backend / qa-frontend   (fill test gaps)
            └─> push + PR   (only when you say so)
PR ──> pr-reviewer
```

## Install

Pick one of the two. Installing both gives you every agent twice.

**As a Claude Code plugin** (recommended):

```
/plugin marketplace add kcayme/agents
/plugin install k-agents@k-agents
```

Update later with `/plugin marketplace update k-agents`. To try a local checkout without installing it: `claude --plugin-dir /path/to/agents`.

**As symlinks**, for editing the agents and seeing changes immediately:

```sh
./install.sh              # link agents/*.md into ~/.claude/agents/
./install.sh --uninstall  # remove those links
```

Safe to re-run. Real files with the same name in `~/.claude/agents/` are left alone.

## Use

Run as the main agent so it can delegate to other agents (subagents can't spawn subagents). Installed as a plugin, the agents are namespaced `k-agents:<name>`:

```
claude --agent k-agents:ticket-planner   # plugin; with symlinks: --agent ticket-planner
                                         # then: plan PROJ-123
claude --agent k-agents:pr-reviewer      # then: review #42
```

## Shared rules

- **Never assume.** Anything unclear is asked, unless you say to assume.
- **Follow the project's conventions.** Written rules first, then tooling config, then existing patterns.
- **Read-only on tickets.** Nothing is posted, pushed, or opened as a PR without explicit permission. Only `implementer` commits, and only locally.
- **Conventional Commits**, grouped by logic/domain.
- **Changelog-style PR descriptions:** short summary, then Added / Fixed / Changed / Removed bullets, then Testing and Notes when applicable. Summarized, one line per bullet, no over-explaining.
- **No AI attribution** in commits or PRs (no `Co-Authored-By: Claude`, no "Generated with Claude Code").

## Regression checks

`implementer` measures everything against a baseline:

1. **Baseline:** runs format, lint, type check, all tests, and coverage before changing anything. Pre-existing failures are listed and you're asked whether to proceed.
2. **Impact check:** before each edit, finds callers, API/event consumers, stored formats, and config that depend on the code, and adds their tests to the commit's run.
3. **Per commit:** a test that passed in the baseline and now fails is a regression. The code gets fixed, not the test, unless the plan changes that behavior.
4. **Final comparison:** no new failures, lint/type errors, or coverage drop versus the baseline before you're asked about pushing.

Changes stay backward compatible (APIs, events, migrations, config, stored data) unless the plan says otherwise. `pr-reviewer` independently checks coverage, base vs PR.

## Requirements

- `gh` (authenticated) for GitHub
- Atlassian Rovo MCP for Jira/Confluence
- ponytail plugin (`ponytail-review` skill)
- [Hurl](https://hurl.dev) for backend API tests
- Bitbucket Cloud: the `bkt` CLI (logged in), or `BITBUCKET_EMAIL` and `BITBUCKET_API_TOKEN` env vars as a fallback
