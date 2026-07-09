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

# --- happy path: flags ---

assert_eq "single flag --name"     "name=Alice"              "$(run --name Alice 2>/dev/null)"
assert_eq "single flag --count"    "count=5"                 "$(run --count 5 2>/dev/null)"
assert_eq "two flags"              "name=Bob count=3"        "$(run --name Bob --count 3 2>/dev/null)"

# --- happy path: positionals ---

assert_eq "two positionals"        "positional: hello world" "$(run hello world 2>/dev/null)"
assert_eq "single positional"      "positional: foo"         "$(run foo 2>/dev/null)"

# --- mixed flags and positionals ---

assert_eq "flag then positional"   "name=Alice positional: hello" "$(run --name Alice hello 2>/dev/null)"

# --- -- separator ---

assert_eq "-- separator"           "positional: unknown"     "$(run -- unknown 2>/dev/null)"
assert_eq "-- with multiple"       "positional: a b c"       "$(run -- a b c 2>/dev/null)"

# --- no args ---

assert_eq "no args"                ""                        "$(run 2>/dev/null)"

# --- error paths ---

actual_exit=0
run --name >/dev/null 2>&1 || actual_exit=$?
assert_exit "flag without value" 2 "$actual_exit"

actual_exit=0
run --bogus >/dev/null 2>&1 || actual_exit=$?
assert_exit "unknown flag" 2 "$actual_exit"

# --- silent stderr on happy path ---

err=$(run --name Alice 2>&1 >/dev/null)
assert_eq "no stderr on happy path" "" "$err"

echo
echo "Summary: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
