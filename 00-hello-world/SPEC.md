# 00-hello-world

## Goal

A Python script that prints a fixed greeting to stdout. This is a heartbeat test for the agent + microvm + ralph loop pipeline. If this spec doesn't pass, nothing else will.

## Artifact

- Filename: `solution.py`
- Format: single Python file using `# /// script` uv inline script metadata for any deps (none required)
- Invocation: `uv run solution.py`

## CLI Surface

| Invocation | Behavior |
|---|---|
| `uv run solution.py` | Prints exactly `Hello, world!` followed by a newline to stdout; exits 0 |

## Acceptance Criteria

- File `solution.py` exists.
- Running `uv run solution.py` exits with code 0.
- Stdout is exactly `Hello, world!` (no extra whitespace, no quotes, no prefix).

## Out of Scope

- No CLI arguments. The script accepts none.
- No flags, no `--help`, no greeting customization.
- No third-party dependencies.
- No stderr output on the happy path.

## How to Run Tests

```bash
cd 00-hello-world
bash acceptance.sh
```
