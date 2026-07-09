#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIXTURES="$DIR/fixtures"
TMP="$DIR/tmp"

[ -d "$DIR/src" ] || { echo "FAIL: src/ not found — project not scaffolded"; exit 1; }

rm -rf "$TMP" && mkdir -p "$TMP"

pass=0
fail=0

assert_eq() {
    local label="$1" expected="$2" actual="$3"
    if [ "$expected" = "$actual" ]; then
        echo "PASS: $label"
        pass=$((pass + 1))
    else
        echo "FAIL: $label"
        echo "  expected: $expected"
        echo "  actual:   $actual"
        fail=$((fail + 1))
    fi
}

assert_exit() {
    local label="$1" expected="$2" actual="$3"
    if [ "$expected" -eq "$actual" ]; then
        echo "PASS: $label (exit $actual)"
        pass=$((pass + 1))
    else
        echo "FAIL: $label"
        echo "  expected exit: $expected"
        echo "  actual exit:   $actual"
        fail=$((fail + 1))
    fi
}

run_log() { uv run loganalyzer "$@"; }

# --- full report on app.log ---

out=$(run_log "$FIXTURES/app.log" 2>/dev/null)

total=$(python3 -c "import json,sys; d=json.loads('''$out'''); print(d['total'])")
assert_eq "total valid lines" "11" "$total"

info=$(python3 -c "import json,sys; d=json.loads('''$out'''); print(d['by_level']['INFO'])")
assert_eq "INFO count" "4" "$info"

err=$(python3 -c "import json,sys; d=json.loads('''$out'''); print(d['by_level']['ERROR'])")
assert_eq "ERROR count" "5" "$err"

warn=$(python3 -c "import json,sys; d=json.loads('''$out'''); print(d['by_level']['WARN'])")
assert_eq "WARN count" "1" "$warn"

debug=$(python3 -c "import json,sys; d=json.loads('''$out'''); print(d['by_level']['DEBUG'])")
assert_eq "DEBUG count" "1" "$debug"

# errors list: 5 entries, Connection refused x4, Timeout x1
err_count=$(python3 -c "import json,sys; d=json.loads('''$out'''); print(len(d['errors']))")
assert_eq "error messages count" "2" "$err_count"

top_err_msg=$(python3 -c "import json,sys; d=json.loads('''$out'''); print(d['errors'][0]['message'])")
assert_eq "top error message" "Connection refused" "$top_err_msg"

top_err_cnt=$(python3 -c "import json,sys; d=json.loads('''$out'''); print(d['errors'][0]['count'])")
assert_eq "top error count" "4" "$top_err_cnt"

# hourly
h08=$(python3 -c "import json,sys; d=json.loads('''$out'''); print(d['hourly'].get('08:00', 0))")
assert_eq "08:00 hour count" "5" "$h08"

h09=$(python3 -c "import json,sys; d=json.loads('''$out'''); print(d['hourly'].get('09:00', 0))")
assert_eq "09:00 hour count" "6" "$h09"

# malformed line skipped (11 valid lines, not 12 — one was malformed)
# malformed line skipped (11 valid lines out of 12)

# --- --top flag ---

out_top=$(run_log "$FIXTURES/app.log" --top 1 2>/dev/null)
top_len=$(python3 -c "import json,sys; d=json.loads('''$out_top'''); print(len(d['errors']))")
assert_eq "--top 1 limits errors" "1" "$top_len"

top_msg=$(python3 -c "import json,sys; d=json.loads('''$out_top'''); print(d['errors'][0]['message'])")
assert_eq "--top 1 picks top" "Connection refused" "$top_msg"

# --- empty file ---

out_empty=$(run_log "$FIXTURES/empty.log" 2>/dev/null)
empty_total=$(python3 -c "import json,sys; d=json.loads('''$out_empty'''); print(d['total'])")
assert_eq "empty total" "0" "$empty_total"

empty_errors=$(python3 -c "import json,sys; d=json.loads('''$out_empty'''); print(len(d['errors']))")
assert_eq "empty errors" "0" "$empty_errors"

# --- error paths ---

actual_exit=0
run_log nope.log >/dev/null 2>&1 || actual_exit=$?
assert_exit "missing file" 2 "$actual_exit"

actual_exit=0
run_log >/dev/null 2>&1 || actual_exit=$?
assert_exit "no args" 2 "$actual_exit"

# --- silent stderr on happy path ---

err_out=$(run_log "$FIXTURES/app.log" 2>&1 >/dev/null)
assert_eq "no stderr on happy path" "" "$err_out"

echo
echo "Summary: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
