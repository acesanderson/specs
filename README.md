# specs-project

A ladder of bounded, self-graded coding challenges for evaluating coding agents. Each spec is a small CLI problem with a binary pass/fail acceptance test. A coding agent writes `solution.py`, and `acceptance.sh` grades it.

## Prerequisites

| Dependency | Version | Install |
|---|---|---|
| bash | any modern | `apt install bash` |
| Python | 3.11+ | [python.org](https://python.org) |
| uv | any | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| pi | any | `curl -fsSL https://pi.dev/install.sh \| sh` |

## Quick Start

```bash
git clone <this-repo>
cd specs-project

# Run a spec
./ralph run 00-hello-world
```

## How It Works

Each spec is a directory under `src/specs/`:

```
00-hello-world/          (single-file spec)
├── SPEC.md
├── acceptance.sh
└── fixtures/            (optional)

08-json-api/             (project spec)
├── SPEC.md
├── acceptance.sh
├── fixtures/            (optional)
└── scaffold/            (optional — makes it a project spec)
    ├── pyproject.toml
    ├── src/
    │   └── jsonapi/
    │       └── __init__.py
    └── tests/
```

**Single-file specs** (no `scaffold/`): pi writes `solution.py`, a single Python file.

**Project specs** (has `scaffold/`): pi fills in the project skeleton — modifying `pyproject.toml`, adding source files, writing tests, etc.

When you run `ralph`:

1. Copies the spec into a temporary working directory
2. Sends SPEC.md + acceptance.sh to **pi** (the coding agent)
3. pi writes `solution.py`
4. ralph runs `bash acceptance.sh` to grade it
5. If it fails, the failure output is fed back to pi and it tries again
6. Up to 5 iterations (configurable)

On **pass** or **fail**, artifacts are saved to NAS at `/mnt/nas/specs/<uuid>/` and the temp directory is cleaned up.

## CLI

```
./ralph run <spec-name> [options]

Options:
  --max-iterations N   Max attempts (default: 5)
  --spec-dir PATH      Override specs directory (default: src/specs/)
  -h, --help           Show help
```

Examples:

```bash
./ralph run 00-hello-world
./ralph run 01-temp-converter --max-iterations 3
./ralph run 02-wordcount --spec-dir ~/my-specs
```

## Run Storage

Both successful and failed spec runs are saved to NAS storage at `/mnt/nas/specs/<UUID>/` where UUID is formatted as `<spec_name>_<model_name>_<timestamp>`.

Each run includes:
- `metadata.json` - Structured run metadata
- `code/solution.py` - Generated Python solution file
- `logs/session.log` - Complete JSONL session transcript from the AI agent

Failed runs additionally include:
- `logs/acceptance.log` - The final acceptance test output
- `<spec>_<model>_<ts>_failed.json` - Failure manifest with context

## Available Specs

| Spec | Type | Difficulty | Tests |
|---|---|---|---|
| `00-hello-world` | single-file | Trivial | Pipeline heartbeat — prints "Hello, world!" |
| `01-temp-converter` | single-file | Easy | Arg parsing, arithmetic, error handling |
| `02-wordcount` | single-file | Medium | File I/O, JSON output, sorting, tokenization |
| `03-args-parser` | single-file | Medium | Hand-rolled CLI parser, flags, positionals, `--` separator |
| `04-csv-filter` | single-file | Medium | CSV parsing, filtering, structured I/O |
| `05-expression-eval` | single-file | Hard | Arithmetic parser, precedence, parens, unary minus |
| `06-todo-manager` | project | Hard | Subcommands, persistent JSON state, file I/O across invocations |
| `07-log-analyzer` | project | Hard | Log parsing, time-bucket aggregation, structured JSON report |

## Global Install (optional)

```bash
ln -s "$(pwd)/ralph" ~/.local/bin/ralph
ralph run 00-hello-world
```

## Project Structure

```
specs-project/
├── src/specs/       # the spec ladder
├── ralph            # the CLI runner
└── README.md
```

## Creating New Specs

See the meta-spec in `src/specs/` (or the Dark Factory - Test Specs document) for the full contract. The short version:

1. Create `src/specs/NN-name/` with `SPEC.md` and `acceptance.sh`
2. Write a reference implementation, run `acceptance.sh` until it passes
3. Delete the implementation before handoff
4. For **project specs**: add a `scaffold/` directory with the project skeleton. Copy the scaffold contents (not the `scaffold/` directory itself) into your working dir and verify acceptance.sh works before deleting the implementation.

The difficulty ladder has five knobs: assertion count, CLI surface complexity, statefulness, I/O format, and algorithmic content. Each new spec should differ from its neighbors on at least one knob.
