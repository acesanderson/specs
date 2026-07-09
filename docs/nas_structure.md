# NAS Storage Structure

## Directory Layout
```
$NAS/specs/<model_uuid>/
├── spec_name.txt
├── timestamp.txt
├── duration.txt
├── model_info.txt
├── solution.py
├── logs/
│   ├── session.jsonl
│   ├── execution.log
│   └── debug.log
├── metadata.json
├── test_results.txt
└── artifacts/
    └── output.txt
```

## File Descriptions

### Core Files
- `spec_name.txt` - The spec identifier (e.g., "00-hello-world")
- `timestamp.txt` - ISO 8601 timestamp of run
- `duration.txt` - Run duration in seconds
- `model_info.txt` - Model identifier used for the run

### Solution & Logs
- `solution.py` - Generated Python solution file
- `logs/session.jsonl` - Full session logs from pi agent
- `logs/execution.log` - stdout/stderr from execution
- `logs/debug.log` - Debug information

### Metadata
- `metadata.json` - Structured metadata about the run
- `test_results.txt` - Acceptance test results summary

### Artifacts
- `artifacts/output.txt` - Any additional output files

This structure allows for easy programmatic access to all run artifacts while keeping the data organized and version-controlled separately from the project source code.