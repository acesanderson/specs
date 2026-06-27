# 01-temp-converter

## Goal

A CLI that converts temperatures between Celsius and Fahrenheit. Tests argparse-style argument handling, basic arithmetic, output formatting discipline, and error reporting on bad input.

## Artifact

- Filename: `solution.py`
- Format: single Python file using `# /// script` uv inline script metadata for any deps (stdlib only is sufficient)
- Invocation: `uv run solution.py --to <unit> <value>`

## CLI Surface

| Invocation | Behavior |
|---|---|
| `uv run solution.py --to f 100` | Treats `100` as Celsius; prints `212.0`; exits 0 |
| `uv run solution.py --to c 32` | Treats `32` as Fahrenheit; prints `0.0`; exits 0 |
| `uv run solution.py --to f 0` | Prints `32.0`; exits 0 |
| `uv run solution.py --to c 212` | Prints `100.0`; exits 0 |
| `uv run solution.py --to c 98.6` | Prints `37.0`; exits 0 |
| `uv run solution.py --to f -40` | Prints `-40.0`; exits 0 |
| `uv run solution.py --to k 100` | Error to stderr; exits non-zero |
| `uv run solution.py --to f abc` | Error to stderr; exits non-zero |
| `uv run solution.py` | Error to stderr; exits non-zero |

## Acceptance Criteria

- `--to f X` interprets `X` as a Celsius value and prints the Fahrenheit equivalent.
- `--to c X` interprets `X` as a Fahrenheit value and prints the Celsius equivalent.
- The value argument may be any valid float (including negatives and decimals).
- Output is formatted to exactly one decimal place. Examples: `212.0`, `100.5`, `-40.0`. No thousands separators, no trailing whitespace beyond a single newline.
- Output is rounded to one decimal place using Python's standard `round()` (banker's rounding is acceptable).
- Only `c` and `f` are valid units. Any other unit (e.g. `k`, `K`, `kelvin`) is rejected with a non-zero exit code and an error message on stderr.
- A non-numeric value (e.g. `abc`) is rejected with a non-zero exit code and an error message on stderr.
- Missing required args is rejected with a non-zero exit code.
- On the happy path, nothing is printed to stderr.

## Out of Scope

- Kelvin or any unit beyond Celsius and Fahrenheit.
- Reverse direction inference (e.g. an `--from` flag). Only `--to` exists.
- Configurable precision. Always one decimal place.
- Interactive prompts.
- Any third-party CLI framework. `argparse` is fine; so is hand-rolled parsing.

## How to Run Tests

```bash
cd 01-temp-converter
bash acceptance.sh
```
