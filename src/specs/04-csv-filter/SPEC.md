# 04-csv-filter

## Goal

A CLI that reads a CSV file, filters rows where a given column matches a value, and writes the result to stdout. Tests CSV parsing, header handling, structured I/O, and edge cases.

## Artifact

- Filename: `solution.py`
- Format: single Python file using `# /// script` uv inline script metadata for any deps
- Invocation: `uv run solution.py <file> --col <name> --eq <value>`

## CLI Surface

| Invocation | Behavior |
|---|---|
| `uv run solution.py data.csv --col city --eq Portland` | Prints CSV (with header) where `city` column equals `Portland` |
| `uv run solution.py data.csv --col age --eq 30` | Prints rows where `age` column equals `30` (string comparison) |
| `uv run solution.py data.csv --col city --eq Nowhere` | Prints header only (no matches); exits 0 |
| `uv run solution.py empty.csv --col x --eq y` | Prints header only (empty file has just a header); exits 0 |
| `uv run solution.py data.csv --col missing --eq foo` | Error to stderr (column not found); exits non-zero |
| `uv run solution.py nope.csv --col x --eq y` | Error to stderr (file not found); exits non-zero |
| `uv run solution.py data.csv` | Error to stderr (missing required flags); exits non-zero |

## Acceptance Criteria

- The first line of the CSV is always a header. All subsequent lines are data rows.
- Filtering is exact string equality: the cell value (trimmed of surrounding whitespace) must exactly match the `--eq` value.
- Output preserves the original CSV format: header line first, then matching rows, in original order.
- If no rows match, only the header is printed.
- `--col` names a column from the header. If the column doesn't exist, exit non-zero with an error on stderr.
- Missing file: exit non-zero with error on stderr.
- Missing `--col` or `--eq` (or both): exit non-zero with error on stderr.
- The output goes to stdout. Nothing is printed to stderr on the happy path.
- The output must not have a trailing blank line after the last row.

## Out of Scope

- No quoting rules (fields won't contain commas or newlines).
- No numeric comparison (age=30 is a string match, not numeric).
- No multiple filter conditions. One `--col`/`--eq` pair only.
- No modifying the input file. Read-only.
- No `csv` module requirement (but stdlib `csv` is fine).

## How to Run Tests

```bash
cd 04-csv-filter
bash acceptance.sh
```
