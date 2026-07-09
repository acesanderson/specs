# Simplified NAS Storage Structure

## Directory Layout
```
$NAS/specs/<UUID>/
├── metadata.json
├── code/
│   └── solution.py
└── logs/
    └── session.log
```

## UUID Format
The UUID is constructed as: `<spec_name>_<model_name>_<timestamp>`
Example: `00-hello-world_alphablue_2026-07-08T18:13:51.436Z`

## File Descriptions

### Core Files
- `metadata.json` - Structured metadata including all input and output information
- `code/solution.py` - The generated Python solution file
- `logs/session.log` - Session transcript from the pi agent execution

This simplified structure provides exactly what was requested:
1. Run directories labeled with UUID combining spec name, model, and timestamp
2. metadata.json with all structured data
3. Code in a code/ subdirectory 
4. Session transcript in logs/ directory