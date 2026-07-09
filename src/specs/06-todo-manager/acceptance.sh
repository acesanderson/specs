#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP="$DIR/tmp"
SOLUTION="uv run todo"

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

assert_contains() {
    local label="$1" needle="$2" haystack="$3"
    if echo "$haystack" | grep -qF "$needle"; then
        echo "PASS: $label"
        pass=$((pass + 1))
    else
        echo "FAIL: $label"
        echo "  expected to contain: $needle"
        echo "  actual: $haystack"
        fail=$((fail + 1))
    fi
}

run_todo() { (cd "$TMP" && $SOLUTION "$@"); }

# --- add tasks ---

out=$(run_todo add "Buy groceries")
assert_contains "add task 1" "Added task 1" "$out"

out=$(run_todo add "Walk the dog")
assert_contains "add task 2" "Added task 2" "$out"

# --- list tasks ---

out=$(run_todo list)
assert_contains "list shows task 1" "1" "$out"
assert_contains "list shows task 2" "2" "$out"
assert_contains "list shows undone" "[ ]" "$out"

# --- mark done ---

out=$(run_todo done 1)
assert_contains "done prints desc" "Buy groceries" "$out"

out=$(run_todo list)
assert_contains "task 1 is done"   "[x]" "$out"
assert_contains "task 2 still undone" "[ ]" "$out"

# --- done on already-done task (no-op) ---

out=$(run_todo done 1)
assert_contains "done again is no-op" "Buy groceries" "$out"

# --- remove task ---

out=$(run_todo remove 1)
assert_contains "remove prints desc" "Buy groceries" "$out"

out=$(run_todo list)
# task 1 should be gone, task 2 should remain
assert_contains "task 2 remains after remove" "Walk the dog" "$out"
if echo "$out" | grep -q "Buy groceries"; then
    echo "FAIL: task 1 should be gone after remove"
    fail=$((fail + 1))
else
    echo "PASS: task 1 gone after remove"
    pass=$((pass + 1))
fi

# --- error paths ---

actual_exit=0
run_todo done 999 >/dev/null 2>&1 || actual_exit=$?
assert_exit "done nonexistent" 2 "$actual_exit"

actual_exit=0
run_todo remove 999 >/dev/null 2>&1 || actual_exit=$?
assert_exit "remove nonexistent" 2 "$actual_exit"

actual_exit=0
run_todo add >/dev/null 2>&1 || actual_exit=$?
assert_exit "add without desc" 2 "$actual_exit"

actual_exit=0
run_todo bogus >/dev/null 2>&1 || actual_exit=$?
assert_exit "unknown command" 2 "$actual_exit"

# --- silent stderr on happy path ---

err=$(run_todo add "Silent test" 2>&1 >/dev/null)
assert_eq "no stderr on happy path" "" "$err"

echo
echo "Summary: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
