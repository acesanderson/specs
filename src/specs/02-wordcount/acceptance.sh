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
        echo "  expected: $expected"
        echo "  actual:   $actual"
        fail=$((fail + 1))
    fi
}

run() { uv run "$SOLUTION" "$@"; }

# --- happy path: full word count on lorem.txt ---

out=$(run "$FIXTURES/lorem.txt" 2>/dev/null)

# parse and probe with python
count_the=$(python3 -c "import json,sys; d=json.loads('''$out'''); print(d.get('the', 0))")
count_fox=$(python3 -c "import json,sys; d=json.loads('''$out'''); print(d.get('fox', 0))")
count_dog=$(python3 -c "import json,sys; d=json.loads('''$out'''); print(d.get('dog', 0))")
count_quick=$(python3 -c "import json,sys; d=json.loads('''$out'''); print(d.get('quick', 0))")
count_a=$(python3 -c "import json,sys; d=json.loads('''$out'''); print(d.get('a', 0))")

assert_eq "count of 'the'"   "5" "$count_the"
assert_eq "count of 'fox'"   "4" "$count_fox"
assert_eq "count of 'dog'"   "3" "$count_dog"
assert_eq "count of 'quick'" "3" "$count_quick"
assert_eq "count of 'a'"     "2" "$count_a"

# key order: descending count, then ascending word
first_three_keys=$(python3 -c "import json,sys; d=json.loads('''$out'''); print(','.join(list(d.keys())[:3]))")
assert_eq "first three keys (sorted by count desc, then alpha)" "the,fox,dog" "$first_three_keys"

# tiebreak check: 'a' must come before 'brown', 'is', 'lazy' (all count=2)
tie_keys=$(python3 -c "
import json
d = json.loads('''$out''')
keys = [k for k,v in d.items() if v == 2]
print(','.join(keys))
")
assert_eq "tiebreak ordering at count=2" "a,brown,is,lazy" "$tie_keys"

# --- --top N flag ---

out_top3=$(run "$FIXTURES/lorem.txt" --top 3 2>/dev/null)
top3_keys=$(python3 -c "import json,sys; d=json.loads('''$out_top3'''); print(','.join(d.keys()))")
top3_len=$(python3 -c "import json,sys; d=json.loads('''$out_top3'''); print(len(d))")
assert_eq "--top 3 returns 3 keys"  "3"           "$top3_len"
assert_eq "--top 3 returns top 3"   "the,fox,dog" "$top3_keys"

# --top larger than vocab returns all
total_keys=$(python3 -c "import json,sys; d=json.loads('''$out'''); print(len(d))")
out_top999=$(run "$FIXTURES/lorem.txt" --top 999 2>/dev/null)
top999_len=$(python3 -c "import json,sys; d=json.loads('''$out_top999'''); print(len(d))")
assert_eq "--top 999 returns all words" "$total_keys" "$top999_len"

# --- empty file ---

: > "$TMP/empty.txt"
out_empty=$(run "$TMP/empty.txt" 2>/dev/null)
assert_eq "empty file -> {}" "{}" "$out_empty"

# --- tokenization edge cases ---

cat > "$TMP/contractions.txt" <<EOF
Don't stop. It's true. I'm here.
EOF
out_c=$(run "$TMP/contractions.txt" 2>/dev/null)
# Don't -> "don" + "t"; It's -> "it" + "s"; I'm -> "i" + "m"
count_t=$(python3 -c "import json,sys; d=json.loads('''$out_c'''); print(d.get('t', 0))")
count_don=$(python3 -c "import json,sys; d=json.loads('''$out_c'''); print(d.get('don', 0))")
assert_eq "apostrophe splits: 'don' from \"don't\"" "1" "$count_don"
assert_eq "apostrophe splits: 't' from \"don't\""   "1" "$count_t"

# --- error paths ---

actual_exit=0
run "$TMP/does-not-exist.txt" >/dev/null 2>&1 || actual_exit=$?
[ "$actual_exit" -ne 0 ] && echo "PASS: rejects missing file (exit $actual_exit)" && pass=$((pass + 1)) || { echo "FAIL: should reject missing file"; fail=$((fail + 1)); }

actual_exit=0
run >/dev/null 2>&1 || actual_exit=$?
[ "$actual_exit" -ne 0 ] && echo "PASS: rejects no args (exit $actual_exit)" && pass=$((pass + 1)) || { echo "FAIL: should reject no args"; fail=$((fail + 1)); }

# --- silent stderr on happy path ---

err=$(run "$FIXTURES/lorem.txt" 2>&1 >/dev/null)
assert_eq "no stderr on happy path" "" "$err"

echo
echo "Summary: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
