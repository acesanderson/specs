#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOLUTION="$DIR/solution.py"

[ -f "$SOLUTION" ] || { echo "FAIL: solution.py not found in $DIR"; exit 1; }

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

run() { uv run "$SOLUTION" "$@"; }

# --- happy path ---

assert_eq "100C to F"      "212.0"  "$(run --to f 100 2>/dev/null)"
assert_eq "32F to C"       "0.0"    "$(run --to c 32 2>/dev/null)"
assert_eq "0C to F"        "32.0"   "$(run --to f 0 2>/dev/null)"
assert_eq "212F to C"      "100.0"  "$(run --to c 212 2>/dev/null)"
assert_eq "98.6F to C"     "37.0"   "$(run --to c 98.6 2>/dev/null)"
assert_eq "-40C to F"      "-40.0"  "$(run --to f -- -40 2>/dev/null)"

# --- error paths ---

actual_exit=0
run --to k 100 >/dev/null 2>&1 || actual_exit=$?
[ "$actual_exit" -ne 0 ] && echo "PASS: rejects unknown unit (exit $actual_exit)" && pass=$((pass + 1)) || { echo "FAIL: should reject --to k"; fail=$((fail + 1)); }

actual_exit=0
run --to f abc >/dev/null 2>&1 || actual_exit=$?
[ "$actual_exit" -ne 0 ] && echo "PASS: rejects non-numeric value (exit $actual_exit)" && pass=$((pass + 1)) || { echo "FAIL: should reject 'abc'"; fail=$((fail + 1)); }

actual_exit=0
run >/dev/null 2>&1 || actual_exit=$?
[ "$actual_exit" -ne 0 ] && echo "PASS: rejects missing args (exit $actual_exit)" && pass=$((pass + 1)) || { echo "FAIL: should reject no args"; fail=$((fail + 1)); }

# --- silent stderr on happy path ---

err=$(run --to f 100 2>&1 >/dev/null)
assert_eq "no stderr on happy path" "" "$err"

echo
echo "Summary: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
