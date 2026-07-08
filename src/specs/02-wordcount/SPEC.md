# 02-wordcount

## Goal

A CLI that reads a text file, counts word frequencies, and emits the results as JSON. Tests file I/O, parsing, sorting with tie-breaking, structured output, and error handling on missing files.

## Artifact

- Filename: `solution.py`
- Format: single Python file using `# /// script` uv inline script metadata for any deps (stdlib only is sufficient)
- Invocation: `uv run solution.py <path> [--top N]`

## CLI Surface

| Invocation | Behavior |
|---|---|
| `uv run solution.py fixtures/lorem.txt` | Prints JSON object: every word → count; exits 0 |
| `uv run solution.py fixtures/lorem.txt --top 3` | Prints JSON object with only the top 3 words; exits 0 |
| `uv run solution.py does-not-exist.txt` | Error to stderr; exits non-zero |
| `uv run solution.py` | Error to stderr; exits non-zero |

## Acceptance Criteria

- **Tokenization:** a "word" is a maximal run of ASCII letters `[A-Za-z]`. Apostrophes, digits, and punctuation are word boundaries — not part of the word. So `don't` becomes two tokens: `don` and `t`.
- **Case-insensitive:** all words are lowercased before counting. `The` and `the` are the same word.
- **Output format:** a single JSON object on stdout, terminated by a newline. Keys are words (strings), values are integer counts. No extra whitespace at the top or bottom.
- **Key order in the JSON:** sorted by count **descending**, then by word **ascending** (alphabetical) as a tiebreaker. The JSON is serialized with `json.dumps(obj, ensure_ascii=False)` (i.e. compact form, no indent). Python dicts preserve insertion order, and JSON parsers reading the output should see this ordering when iterating keys. The acceptance test verifies this by inspecting the raw JSON string.
- **`--top N` flag:** if present, only the first `N` entries (post-sort) are included. If `N` exceeds the unique word count, return all.
- **Missing file:** exits non-zero with an error message on stderr.
- **No path arg at all:** exits non-zero with an error message on stderr.
- **Empty file** (zero words): prints `{}` followed by newline; exits 0.
- On the happy path, nothing is printed to stderr.

## Out of Scope

- Stopword filtering.
- Stemming, lemmatization, or any NLP beyond lowercasing.
- Reading from stdin.
- Multiple input files in one invocation.
- Output to a file. Stdout only.
- Pretty-printed JSON (indented). Use the default compact form.

## How to Run Tests

```bash
cd 02-wordcount
bash acceptance.sh
```
