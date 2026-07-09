# 05-expression-eval

## Goal

A CLI that evaluates arithmetic expressions with correct operator precedence and parentheses. No `eval()` — the agent must implement a parser (recursive descent, shunting-yard, or equivalent). Tests parsing, precedence, recursion, and error handling.

## Artifact

- Filename: `solution.py`
- Format: single Python file using `# /// script` uv inline script metadata for any deps
- Invocation: `uv run solution.py <expression>`

## CLI Surface

| Invocation | Behavior |
|---|---|
| `uv run solution.py "3 + 4"` | Prints `7.0`; exits 0 |
| `uv run solution.py "10 - 2 * 3"` | Prints `4.0`; exits 0 (multiplication first) |
| `uv run solution.py "(10 - 2) * 3"` | Prints `24.0`; exits 0 |
| `uv run solution.py "2 + 3 * 4 - 1"` | Prints `13.0`; exits 0 |
| `uv run solution.py "((2 + 3) * (4 - 1))"` | Prints `15.0`; exits 0 |
| `uv run solution.py "10 / 3"` | Prints `3.3333333333` (10 decimal places); exits 0 |
| `uv run solution.py "-5 + 3"` | Prints `-2.0`; exits 0 (unary minus) |
| `uv run solution.py "2 * -3"` | Prints `-6.0`; exits 0 |
| `uv run solution.py "2 +"` | Error to stderr (incomplete expression); exits non-zero |
| `uv run solution.py "(2 + 3"` | Error to stderr (mismatched parens); exits non-zero |
| `uv run solution.py "2 @ 3"` | Error to stderr (unknown operator); exits non-zero |
| `uv run solution.py` | Error to stderr (no expression); exits non-zero |

## Acceptance Criteria

- Supports operators: `+`, `-`, `*`, `/`
- Operator precedence: `*` and `/` bind tighter than `+` and `-` (standard math rules).
- Parentheses override precedence.
- Unary minus is supported: `-5`, `2 * -3`, `-(1 + 2)`
- Integer division uses true division: `10 / 3` = `3.3333333333` (not `3`).
- Output is a float printed to exactly 10 decimal places (e.g. `7.0000000000`, `3.3333333333`).
- Operators and numbers may be separated by spaces, but spaces are not required: `2+3*4` is valid.
- Error cases: incomplete expression, mismatched parentheses, unknown operator, division by zero, no input. All exit non-zero with error on stderr.
- Nothing is printed to stderr on the happy path.

## Out of Scope

- No `eval()`, `exec()`, or `ast.literal_eval()`.
- No variables or assignment.
- No exponentiation (`**`), modulo (`%`), or other operators.
- No scientific notation (e.g. `1e5`).
- No third-party expression parsing libraries.

## How to Run Tests

```bash
cd 05-expression-eval
bash acceptance.sh
```
