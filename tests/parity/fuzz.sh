#!/usr/bin/env sh
set -eu

seed=${1:-1}
count=${2:-20}

case "$seed" in
    ''|*[!0-9]*) echo "FUZZ_SEED must be an integer from 1 to 2147483646" >&2; exit 2 ;;
esac
case "$count" in
    ''|*[!0-9]*) echo "FUZZ_CASES must be an integer from 1 to 1000" >&2; exit 2 ;;
esac
if [ "$seed" -lt 1 ] || [ "$seed" -gt 2147483646 ]; then
    echo "FUZZ_SEED must be an integer from 1 to 2147483646" >&2
    exit 2
fi
if [ "$count" -lt 1 ] || [ "$count" -gt 1000 ]; then
    echo "FUZZ_CASES must be an integer from 1 to 1000" >&2
    exit 2
fi

# Park-Miller LCG. Arithmetic stays below 2^53 so awk evaluates every integer
# exactly. Width and height remain small enough to keep fuzz runs inexpensive.
awk -v seed="$seed" -v count="$count" '
function next_random() {
    seed = seed * 48271
    seed = seed - int(seed / 2147483647) * 2147483647
    return seed
}
BEGIN {
    fixtures[0] = "empty"
    fixtures[1] = "label-normal"
    fixtures[2] = "button-normal"
    fixtures[3] = "button-explicit-size"
    fixtures[4] = "button-hover"
    fixture_count = 5
    for (case_number = 1; case_number <= count; case_number++) {
        width = 32 + next_random() % 225
        height = 24 + next_random() % 169
        fixture = fixtures[next_random() % fixture_count]
        printf "%d %s %d %d\n", case_number, fixture, width, height
    }
}
'
