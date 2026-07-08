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

# --- assertions ---

actual_exit=0
actual_out=$(run 2>/dev/null) || actual_exit=$?
assert_exit "runs cleanly" 0 "$actual_exit"
assert_eq "stdout greeting" "Hello, world!" "$actual_out"

echo
echo "Summary: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
