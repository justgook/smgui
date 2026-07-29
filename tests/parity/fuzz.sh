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
    fixtures[5] = "button-pressed"
    fixtures[6] = "button-disabled"
    fixtures[7] = "checkbox-normal"
    fixtures[8] = "checkbox-checked"
    fixtures[9] = "checkbox-hover"
    fixtures[10] = "checkbox-pressed"
    fixtures[11] = "checkbox-disabled"
    fixtures[12] = "radio-normal"
    fixtures[13] = "radio-selected"
    fixtures[14] = "radio-hover"
    fixtures[15] = "radio-pressed"
    fixtures[16] = "radio-disabled"
    fixtures[17] = "slider-minimum"
    fixtures[18] = "slider-midpoint"
    fixtures[19] = "slider-maximum"
    fixtures[20] = "slider-interaction"
    fixtures[21] = "slider-disabled"
    fixtures[22] = "progress-minimum"
    fixture_count = 23
    for (case_number = 1; case_number <= count; case_number++) {
        width = 32 + next_random() % 225
        height = 24 + next_random() % 169
        fixture = fixtures[next_random() % fixture_count]
        printf "%d %s %d %d\n", case_number, fixture, width, height
    }
}
'
