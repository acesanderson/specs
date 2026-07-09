# Run Interface Specification

## Input Interface

### Required Inputs
- `spec_name`: String identifier (e.g., "00-hello-world")
- `timestamp`: ISO 8601 timestamp of run initiation
- `duration`: Run duration in seconds
- `model_info`: Information about the model used (from `~/.custom_functions`)

### Optional Inputs
- `spec_bundle`: References to spec files (SPEC.md + acceptance.sh locations)
- `session_logs`: JSONL session logs from pi agent
- `execution_output`: stdout/stderr from execution

## Output Interface

### Successful Run Output
- `solution_file`: Generated `solution.py` file
- `run_metadata`: Run statistics and info
- `log_files`: References to log artifacts (session logs, execution logs)
- `test_results`: Acceptance test outcomes
- `status`: "success"

### Failed Run Output  
- `error_details`: Error information and stack trace
- `log_files`: References to log artifacts
- `run_metadata`: Run statistics and info
- `status`: "failed"

## Data Structure Example

```json
{
  "input": {
    "spec_name": "00-hello-world",
    "timestamp": "2026-07-08T18:13:51.436Z",
    "duration": 2.5,
    "model_info": "alphablue",
    "spec_bundle": {
      "spec_md_path": "src/specs/00-hello-world/SPEC.md",
      "acceptance_sh_path": "src/specs/00-hello-world/acceptance.sh"
    }
  },
  "output": {
    "solution_file": "solution.py",
    "run_metadata": {
      "iterations": 1,
      "exit_code": 0
    },
    "log_files": [
      "~/.pi/agent/sessions/--path--/session.jsonl",
      "runs/00-hello-world-20260708T181351/pi_output.log"
    ],
    "test_results": {
      "passed": 2,
      "failed": 0
    },
    "status": "success"
  }
}
```