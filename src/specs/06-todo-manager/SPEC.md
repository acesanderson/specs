# 06-todo-manager

## Goal

A persistent, JSON-backed task manager CLI. Tasks are stored in a local `todos.json` file. Supports `add`, `list`, `done`, and `remove` subcommands. Tests subcommand routing, file-backed state, JSON serialization, and error handling across multiple invocations.

## Artifact

- A Python project with a CLI entry point
- Invocable via: `uv run todo <command> [args]`
- State file: `todos.json` in the current working directory

## CLI Surface

| Invocation | Behavior |
|---|---|
| `uv run todo add "Buy groceries"` | Adds a task with a unique integer ID; prints `Added task <ID>`; exits 0 |
| `uv run todo add "Walk the dog"` | Adds another task; prints `Added task <ID>`; exits 0 |
| `uv run todo list` | Prints all tasks, one per line: `<ID>  [ ]  <description>`; exits 0 |
| `uv run todo done 1` | Marks task 1 complete; prints `Done: <description>`; exits 0 |
| `uv run todo list` (after done) | Task 1 shows as `<ID>  [x]  <description>` |
| `uv run todo remove 1` | Removes task 1; prints `Removed: <description>`; exits 0 |
| `uv run todo list` (after remove) | Task 1 is gone |
| `uv run todo done 999` | Error to stderr (task not found); exits non-zero |
| `uv run todo remove 999` | Error to stderr (task not found); exits non-zero |
| `uv run todo` | Error to stderr (no command); exits non-zero |
| `uv run todo bogus` | Error to stderr (unknown command); exits non-zero |

## Acceptance Criteria

- State persists across invocations in `todos.json` (JSON array of objects).
- Each task object has: `id` (int, auto-incrementing), `description` (string), `done` (boolean).
- `list` shows tasks in ID order. Each line: `<id>  [ ]  <description>` or `<id>  [x]  <description>`.
- IDs are never reused. Once assigned, an ID is permanent (even after `remove`).
- `done` on an already-done task is a no-op (still prints the description, exits 0).
- `remove` on a nonexistent ID exits non-zero with error on stderr.
- `done` on a nonexistent ID exits non-zero with error on stderr.
- `add` with no description exits non-zero with error on stderr.
- Unknown command exits non-zero with error on stderr.
- `todos.json` is created on first `add` if it doesn't exist.
- Nothing is printed to stderr on the happy path.

## Out of Scope

- No `click`, `argparse`, or other CLI frameworks. Hand-rolled subcommand dispatch.
- No priority, due dates, tags, or other metadata. Just id, description, done.
- No `list --all` or filtering. `list` always shows everything.
- No confirmation prompts.
- No interactive mode.

## How to Run Tests

```bash
cd 06-todo-manager
bash acceptance.sh
```
