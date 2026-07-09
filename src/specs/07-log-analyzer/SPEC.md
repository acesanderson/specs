# 07-log-analyzer

## Goal

A CLI that parses structured log lines, aggregates statistics, and emits a JSON report. Tests line parsing, time-bucket grouping, aggregation logic, and structured output in a project context.

## Artifact

- A Python project with a CLI entry point
- Invocable via: `uv run loganalyzer <logfile> [--top N]`
- Reads a log file from a path argument

## Log Format

Each line is:

```
YYYY-MM-DD HH:MM:SS  LEVEL  message
```

Example:

```
2025-01-15 08:30:00  INFO   Server started
2025-01-15 08:30:05  ERROR  Connection refused
2025-01-15 08:31:00  WARN   Retry in 5s
```

Fields are separated by two spaces. `LEVEL` is one of: `DEBUG`, `INFO`, `WARN`, `ERROR`.

## CLI Surface

| Invocation | Behavior |
|---|---|
| `uv run loganalyzer app.log` | Prints full JSON report; exits 0 |
| `uv run loganalyzer app.log --top 2` | Prints report with only the top 2 error messages; exits 0 |
| `uv run loganalyzer empty.log` | Prints report with zero counts; exits 0 |
| `uv run loganalyzer nope.log` | Error to stderr (file not found); exits non-zero |
| `uv run loganalyzer` | Error to stderr (no file argument); exits non-zero |

## Acceptance Criteria

- The JSON report has these keys:
  - `total`: total number of log lines (int)
  - `by_level`: object with `DEBUG`, `INFO`, `WARN`, `ERROR` counts (int, 0 if absent)
  - `errors`: array of objects, each with `message` (string) and `count` (int), sorted by count descending then message ascending
  - `hourly`: object keyed by `"HH:00"` (e.g. `"08:00"`), each value is the count of lines in that hour
- `errors` contains only lines with level `ERROR`. The `message` is the text after `ERROR  `, stripped of leading/trailing whitespace.
- `--top N` limits `errors` to the first N entries (post-sort). Without `--top`, all errors are included.
- Empty log file (zero lines): all counts are 0, `errors` is `[]`, `hourly` is `{}`.
- Malformed lines (wrong format, unknown level): skip silently, do not count.
- Missing file: exit non-zero with error on stderr.
- No file argument: exit non-zero with error on stderr.
- Output is compact JSON (`json.dumps(..., indent=2)` with 2-space indent).
- Nothing is printed to stderr on the happy path.

## Out of Scope

- No `click`, `argparse`, or other CLI frameworks. Hand-rolled argument parsing.
- No tail/follow mode. Read once and exit.
- No filtering by time range.
- No colored output or table formatting. JSON only.
- No streaming. Read entire file into memory.

## How to Run Tests

```bash
cd 07-log-analyzer
bash acceptance.sh
```
