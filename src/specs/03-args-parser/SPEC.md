# 03-args-parser

## Goal

A CLI that parses command-line arguments by hand (no `argparse`, no `click`, no third-party parsers). Accepts flags with values, positional arguments, and the `--` separator. Tests string parsing, state machines, and error handling.

## Artifact

- Filename: `solution.py`
- Format: single Python file using `# /// script` uv inline script metadata for any deps
- Invocation: `uv run solution.py [args]`

## CLI Surface

| Invocation | Behavior |
|---|---|
| `uv run solution.py --name Alice` | Prints `name=Alice`; exits 0 |
| `uv run solution.py --count 5` | Prints `count=5`; exits 0 |
| `uv run solution.py --name Bob --count 3` | Prints `name=Bob count=3`; exits 0 |
| `uv run solution.py hello world` | Prints `positional: hello world`; exits 0 |
| `uv run solution.py --name Alice hello` | Prints `name=Alice positional: hello`; exits 0 |
| `uv run solution.py -- unknown` | Prints `positional: unknown`; exits 0 (everything after `--` is positional) |
| `uv run solution.py --name` | Error to stderr (flag `--name` requires a value); exits non-zero |
| `uv run solution.py --bogus` | Error to stderr (unknown flag); exits non-zero |
| `uv run solution.py` | Prints nothing; exits 0 (no args is valid) |

## Acceptance Criteria

- Flags `--name` and `--count` are recognized. All other `--` flags are rejected as unknown.
- A flag that appears without a following value (e.g. `--name` at end of args) is an error.
- Positional arguments (no preceding `--`) are collected in order.
- `--` terminates flag parsing; everything after it is positional.
- Output format for recognized flags: `key=value` pairs joined by spaces, in the order they appeared.
- Output format for positional args: `positional: ` followed by positional args joined by spaces.
- When both flags and positionals are present, print flags first, then positionals, separated by a space.
- Nothing is printed to stderr on the happy path.

## Out of Scope

- No `argparse`, `click`, `typer`, or any third-party argument parsing library.
- No `--help` flag (not required, but if present it should just be rejected as unknown).
- No short flags (`-n`). Long flags only (`--name`).
- No flag value types (everything is a string).
- No subcommands.

## How to Run Tests

```bash
cd 03-args-parser
bash acceptance.sh
```
