#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOLUTION="$DIR/solution.py"
FIXTURES="$DIR/fixtures"
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
        echo "  expected: $(echo "$expected" | head -5)"
        echo "  actual:   $(echo "$actual" | head -5)"
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

# --- happy path: filter by city ---

expected="name,age,city
Alice,30,Portland
Carol,30,Portland
Eve,25,Portland"
actual=$(run "$FIXTURES/people.csv" --col city --eq Portland 2>/dev/null)
assert_eq "filter city=Portland" "$expected" "$actual"

# --- filter by age (string match) ---

expected="name,age,city
Alice,30,Portland
Carol,30,Portland"
actual=$(run "$FIXTURES/people.csv" --col age --eq 30 2>/dev/null)
assert_eq "filter age=30" "$expected" "$actual"

# --- no matches: header only ---

expected="name,age,city"
actual=$(run "$FIXTURES/people.csv" --col city --eq Nowhere 2>/dev/null)
assert_eq "no matches -> header only" "$expected" "$actual"

# --- empty file (header only) ---

expected="name,age,city"
actual=$(run "$FIXTURES/empty.csv" --col city --eq Portland 2>/dev/null)
assert_eq "empty file -> header only" "$expected" "$actual"

# --- error: missing column ---

actual_exit=0
run "$FIXTURES/people.csv" --col missing --eq foo >/dev/null 2>&1 || actual_exit=$?
assert_exit "rejects missing column" 2 "$actual_exit"

# --- error: missing file ---

actual_exit=0
run nope.csv --col city --eq Portland >/dev/null 2>&1 || actual_exit=$?
assert_exit "rejects missing file" 2 "$actual_exit"

# --- error: missing flags ---

actual_exit=0
run "$FIXTURES/people.csv" >/dev/null 2>&1 || actual_exit=$?
assert_exit "rejects missing flags" 2 "$actual_exit"

# --- silent stderr on happy path ---

err=$(run "$FIXTURES/people.csv" --col city --eq Portland 2>&1 >/dev/null)
assert_eq "no stderr on happy path" "" "$err"

echo
echo "Summary: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
