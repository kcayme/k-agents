#!/usr/bin/env python3
# Token usage of one Claude Code session, per agent call, read from its transcripts
# (the main thread plus every subagent). Counts include subagents, unlike /usage.
# Usage: scripts/token-report.py [<session id> | <path to session .jsonl>]
#        (no argument: the most recently modified session in ~/.claude/projects)
import json
import sys
from pathlib import Path

PROJECTS = Path.home() / ".claude" / "projects"
FIELDS = ("input_tokens", "cache_creation_input_tokens", "cache_read_input_tokens", "output_tokens")


def find_session(arg):
    if arg and Path(arg).is_file():
        return Path(arg)
    sessions = PROJECTS.glob(f"*/{arg}.jsonl" if arg else "*/*.jsonl")
    found = max(sessions, key=lambda p: p.stat().st_mtime, default=None)
    if not found:
        sys.exit(f"no session transcript found for {arg or 'any project'}")
    return found


def usage(path):
    # Streamed messages are logged once per content block with the same usage; keep one per id.
    turns = {}
    for line in path.open():
        try:
            row = json.loads(line)
        except json.JSONDecodeError:
            continue  # a session still being written can end in a partial line
        msg = row.get("message") or {}
        if row.get("type") == "assistant" and msg.get("usage"):
            turns[msg.get("id") or len(turns)] = msg["usage"]
    turns = list(turns.values())
    totals = {f: sum(u.get(f) or 0 for u in turns) for f in FIELDS}
    # Startup prompt: everything sent on the first turn (system prompt, tools, brief).
    first = turns[0] if turns else {}
    totals["startup"] = sum(first.get(f) or 0 for f in FIELDS[:3])
    totals["turns"] = len(turns)
    return totals


def main():
    session = find_session(sys.argv[1] if len(sys.argv) > 1 else None)
    rows = [("main", "", usage(session))]
    for sub in sorted((session.parent / session.stem / "subagents").glob("agent-*.jsonl")):
        meta_path = sub.with_suffix(".meta.json")
        meta = json.loads(meta_path.read_text()) if meta_path.exists() else {}
        rows.append((meta.get("agentType", sub.stem), meta.get("description", ""), usage(sub)))

    cols = ("turns", "startup", "input_tokens", "cache_creation_input_tokens", "cache_read_input_tokens", "output_tokens")
    heads = ("turns", "startup", "input", "cache write", "cache read", "output")
    print(f"session {session}\n")
    print(f"{'agent':<34} {'description':<34}" + "".join(f"{h:>12}" for h in heads))
    for name, desc, t in rows:
        print(f"{name[:34]:<34} {desc[:34]:<34}" + "".join(f"{t[c]:>12,}" for c in cols))
    total = {c: sum(t[c] for _, _, t in rows) for c in cols}
    print(f"{'total':<69}" + "".join(f"{total[c]:>12,}" for c in cols))


if __name__ == "__main__":
    main()
