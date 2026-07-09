# Ralph Run Storage Implementation Spec

## Overview
Modify the Ralph tool to save successful spec run artifacts to NAS storage instead of cleaning up the working directory.

## Implementation Requirements

### 1. Directory Structure
- Create directory: `$NAS/specs/<UUID>/` where UUID = `<spec_name>_<model_name>_<timestamp>`
- Save files in:
  - `$NAS/specs/<UUID>/metadata.json`
  - `$NAS/specs/<UUID>/code/solution.py`
  - `$NAS/specs/<UUID>/logs/session.log`

### 2. UUID Generation
- Format: `<spec_name>_<model_name>_<timestamp>`
- Example: `00-hello-world_alphablue_2026-07-08T18:13:51.436Z`

### 3. Metadata Structure
```json
{
  "spec_name": "00-hello-world",
  "model_name": "alphablue",
  "timestamp": "2026-07-08T18:13:51.436Z",
  "duration_seconds": 2.5,
  "status": "success",
  "iterations": 1,
  "exit_code": 0
}
```

### 4. Implementation Steps
1. Generate UUID on successful run completion
2. Create NAS storage directory
3. Save metadata.json
4. Save solution.py to code/ directory
5. Save session.log to logs/ directory
6. Skip cleanup of working directory for successful runs