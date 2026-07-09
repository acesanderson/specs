#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOLUTION="$DIR/solution.py"
TMP="$DIR/tmp"

[ -f "$SOLUTION" ] || { echo "FAIL: solution.py not found in $DIR"; exit 1; }

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

run() { uv run "$SOLUTION" "$@"; }

# --- basic arithmetic ---

assert_eq "simple add"         "7.0000000000"  "$(run '3 + 4' 2>/dev/null)"
assert_eq "simple sub"         "5.0000000000"  "$(run '9 - 4' 2>/dev/null)"
assert_eq "simple mul"         "12.0000000000" "$(run '3 * 4' 2>/dev/null)"
assert_eq "simple div"         "3.3333333333"  "$(run '10 / 3' 2>/dev/null)"

# --- precedence ---

assert_eq "mul before add"     "11.0000000000" "$(run '3 + 2 * 4' 2>/dev/null)"
assert_eq "div before sub"     "4.0000000000"  "$(run '10 - 12 / 2' 2>/dev/null)"
assert_eq "chain: mul+sub"     "4.0000000000"  "$(run '10 - 2 * 3' 2>/dev/null)"
assert_eq "chain: add+mul+sub" "13.0000000000" "$(run '2 + 3 * 4 - 1' 2>/dev/null)"

# --- parentheses ---

assert_eq "parens override"    "24.0000000000" "$(run '(10 - 2) * 3' 2>/dev/null)"
assert_eq "nested parens"      "15.0000000000" "$(run '((2 + 3) * (4 - 1))' 2>/dev/null)"
assert_eq "parens around all"  "7.0000000000"  "$(run '(3 + 4)' 2>/dev/null)"

# --- unary minus ---

assert_eq "leading unary"      "-2.0000000000" "$(run '-5 + 3' 2>/dev/null)"
assert_eq "mid unary"          "-6.0000000000" "$(run '2 * -3' 2>/dev/null)"
assert_eq "unary in parens"    "-3.0000000000" "$(run '-(1 + 2)' 2>/dev/null)"

# --- no spaces ---

assert_eq "no spaces"          "14.0000000000" "$(run '2+3*4' 2>/dev/null)"

# --- error paths ---

actual_exit=0
run '2 +' >/dev/null 2>&1 || actual_exit=$?
assert_exit "incomplete expr" 2 "$actual_exit"

actual_exit=0
run '(2 + 3' >/dev/null 2>&1 || actual_exit=$?
assert_exit "mismatched parens" 2 "$actual_exit"

actual_exit=0
run '2 @ 3' >/dev/null 2>&1 || actual_exit=$?
assert_exit "unknown operator" 2 "$actual_exit"

actual_exit=0
run >/dev/null 2>&1 || actual_exit=$?
assert_exit "no input" 2 "$actual_exit"

# --- silent stderr on happy path ---

err=$(run '3 + 4' 2>&1 >/dev/null)
assert_eq "no stderr on happy path" "" "$err"

echo
echo "Summary: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
