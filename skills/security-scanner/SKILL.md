---
name: security-scanner
description: Security-scan a PR or branch with the security-scanner agent.
argument-hint: "<PR number/URL or branch/worktree> [full scan]"
disable-model-invocation: true
---

Run the `kagents:security-scanner` agent (the bare `security-scanner` only when no `kagents:security-scanner` agent exists, i.e. the symlink install) on:

$ARGUMENTS

- Pass the arguments through unchanged. Don't add your own summary, opinion, or instructions.
- Wait for it to finish rather than doing other work in the meantime.
- The agent can't ask the user directly. When it returns questions, put them to the user (AskUserQuestion, or in chat), then send the user's answers back to the same agent with SendMessage so it resumes with its context. Never answer its questions yourself.
- When it finishes, relay its report in full: verdicts, paths, findings, questions, and suggested next steps. Don't act on those next steps (implementing, committing, pushing, posting) unless the user asks.
