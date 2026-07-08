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
00-hello-world/
├── SPEC.md          # what the agent should build
├── acceptance.sh    # the grader (exit 0 = pass)
└── fixtures/        # (optional) input files
```

When you run `ralph`:

1. Copies the spec into a working directory under `runs/`
2. Sends SPEC.md + acceptance.sh to **pi** (the coding agent)
3. pi writes `solution.py`
4. ralph runs `bash acceptance.sh` to grade it
5. If it fails, the failure output is fed back to pi and it tries again
6. Up to 5 iterations (configurable)

On **pass**, the working copy is deleted. On **fail**, it's saved to `runs/failed/` so you can inspect what pi produced.

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

## Available Specs

| Spec | Difficulty | Tests |
|---|---|---|
| `00-hello-world` | Trivial | Pipeline heartbeat — prints "Hello, world!" |
| `01-temp-converter` | Easy | Arg parsing, arithmetic, error handling |
| `02-wordcount` | Medium | File I/O, JSON output, sorting, tokenization |

## Global Install (optional)

```bash
ln -s "$(pwd)/ralph" ~/.local/bin/ralph
ralph run 00-hello-world
```

## Project Structure

```
specs-project/
├── src/specs/       # the spec ladder
├── runs/            # active & failed working copies
├── ralph            # the CLI runner
└── README.md
```

## Creating New Specs

See the meta-spec in `src/specs/` (or the Dark Factory - Test Specs document) for the full contract. The short version:

1. Create `src/specs/NN-name/` with `SPEC.md` and `acceptance.sh`
2. Write a reference `solution.py`, run `acceptance.sh` until it passes
3. Delete `solution.py` before handoff

The difficulty ladder has five knobs: assertion count, CLI surface complexity, statefulness, I/O format, and algorithmic content. Each new spec should differ from its neighbors on at least one knob.
