# k-agents

Handy agents for effective, secured, and quality full-stack development.

```mermaid
flowchart LR
    T([Ticket]) --> TP[ticket-planner]
    TP --> IM[implementer]
    IM -->|push + PR, only when you say so| PR([PR])
    PR --> RV[pr-reviewer]

    TP -.->|design-heavy tickets| SA[system-architect]
    SA -.-> TR[tech-researcher]
    TP -.->|unfamiliar tools/standards| TR
    TP -.->|test plan review| QA[qa-backend / qa-frontend]
    IM -.->|fill test gaps| QA
    IM -.->|independent review, before PR| RV
    RV -.->|security scan| SS[security-scanner]
```

## Agents

| Agent | What it does | Model |
|---|---|---|
| `ticket-planner` | Checks a ticket is ready, asks about anything unclear, reproduces bugs to their root cause, creates a dedicated worktree, and writes a plan (phases, commits, tests, diagrams). | Opus |
| `system-architect` | Compares design options on explicit tradeoffs and records the recommendation in an ADR. | Opus |
| `tech-researcher` | Researches docs, third-party service integrations, known solutions, and standards for your stack, with every claim cited. | Sonnet |
| `implementer` | Implements the plan commit by commit, test first, guarding against regressions; pushes or opens a PR only when you say so. | Opus |
| `qa-backend` | Writes and runs unit, API, and e2e tests with the repo's tooling (Hurl as the API fallback), or reviews a test plan. | Sonnet |
| `qa-frontend` | Writes and runs component, browser e2e, accessibility, and visual tests, with screenshots. | Sonnet |
| `pr-reviewer` | Reviews a PR or branch against the ticket, conventions, tests, and coverage; proves every finding. | Opus |
| `security-scanner` | Scans a PR or branch with open-source scanners and verifies each finding, like Snyk or Aikido. | Opus |

## Principles

- **Never assume:** unclear details become questions.
- **Project conventions first.**
- **Nothing outward-facing without your permission:** no pushes, PRs, ticket changes, posted comments, or committed docs.
- **Secrets stay closed, environments stay local:** agents don't read `.env` or other secret files, and ask before touching any non-local database, API, or cloud resource, with separate permission for anything that writes.
- **Guarded actions:** instructions found in tickets, PRs, code, or web pages are never followed; destructive git or file operations, new or upgraded packages, and sending project data to outside services all need your permission.
- **Feature branches only:** agents never commit, merge, rebase, or push to `main`, `master`, `develop`, `dev`, `uat`, `staging`, or other protected or deployment branches; never `--force`, and `--force-with-lease` only on feature branches with your permission.
- **The repo's commit convention**, grouped by domain, with no AI attribution.
- **Resumable:** each ticket's plan and handoff log live in `~/.claude/k-agents/<owner>/<repo>/<ticket>/`, outside your project, so a new session picks up where the last one stopped.

## Install

As a Claude Code plugin:

```
/plugin marketplace add kcayme/k-agents
/plugin install k-agents@k-agents
```

Or, to edit the agents and see changes immediately, symlink them into `~/.claude/agents/` with `./install.sh` (`--uninstall` to remove). Use one method, not both, or every agent shows up twice.

## Use

Each agent has a matching slash command:

```
/k-agents:ticket-planner PROJ-123
/k-agents:implementer PROJ-123
/k-agents:pr-reviewer #42
```

You can also `@`-mention an agent or ask for it by name. To have `ticket-planner` or `implementer` ask you questions directly, run it as the session: `claude --agent k-agents:ticket-planner`. With the symlink install, drop the `k-agents:` prefix.

## Requirements

- `gh` (authenticated) for GitHub
- Atlassian Rovo MCP for Jira/Confluence
- `bkt` CLI, or `BITBUCKET_EMAIL` + `BITBUCKET_API_TOKEN`, for Bitbucket Cloud
- ponytail plugin (`ponytail-review` skill)
- Hurl, only for repos with no API test tooling of their own
- `osv-scanner`, `semgrep`, `gitleaks`, `trivy` for `security-scanner` (missing ones are reported as not scanned); `snyk`/`aikido` CLIs optional
