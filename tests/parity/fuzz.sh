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
    fixtures[23] = "progress-midpoint"
    fixtures[24] = "progress-maximum"
    fixtures[25] = "progress-disabled"
    fixtures[26] = "decimal-normal"
    fixtures[27] = "decimal-negative"
    fixtures[28] = "decimal-explicit-size"
    fixtures[29] = "decimal-disabled"
    fixtures[30] = "hex-normal"
    fixtures[31] = "hex-zero"
    fixtures[32] = "hex-explicit-size"
    fixtures[33] = "hex-disabled"
    fixtures[34] = "float-normal"
    fixtures[35] = "float-magnitude"
    fixtures[36] = "float-explicit-size"
    fixtures[37] = "float-disabled"
    fixtures[38] = "text-input-normal"
    fixtures[39] = "text-input-empty"
    fixtures[40] = "text-input-explicit-size"
    fixtures[41] = "text-input-edit"
    fixtures[42] = "text-input-disabled"
    fixtures[43] = "numeric-input-normal"
    fixtures[44] = "numeric-input-explicit-size"
    fixtures[45] = "numeric-input-decrement"
    fixtures[46] = "numeric-input-increment"
    fixtures[47] = "numeric-input-disabled"
    fixtures[48] = "select-normal"
    fixtures[49] = "select-explicit-size"
    fixtures[50] = "select-pressed"
    fixtures[51] = "select-open"
    fixtures[52] = "select-choice"
    fixtures[53] = "select-disabled"
    fixtures[54] = "option-normal"
    fixtures[55] = "option-explicit-size"
    fixtures[56] = "option-decrement"
    fixtures[57] = "option-increment"
    fixtures[58] = "option-disabled"
    fixtures[59] = "popup-normal"
    fixtures[60] = "popup-intrinsic"
    fixtures[61] = "popup-no-border"
    fixtures[62] = "popup-no-shadow"
    fixtures[63] = "popup-title"
    fixtures[64] = "popup-draggable"
    fixtures[65] = "popup-resizable"
    fixtures[66] = "popup-hidden"
    fixtures[67] = "popup-close"
    fixtures[68] = "menu-closed"
    fixtures[69] = "menu-open"
    fixtures[70] = "menu-intrinsic"
    fixtures[71] = "menu-hover"
    fixtures[72] = "menu-disabled"
    fixtures[73] = "menu-choice"
    fixtures[74] = "menu-outside-close"
    fixtures[75] = "menu-escape-close"
    fixtures[76] = "menu-anchored"
    fixtures[77] = "menu-button-closed"
    fixtures[78] = "menu-button-open"
    fixtures[79] = "division-intrinsic"
    fixtures[80] = "division-percentage"
    fixtures[81] = "popup-chrome"
    fixtures[82] = "popup-drag"
    fixtures[83] = "popup-resize"
    fixtures[84] = "text-input-overflow-edit"
    fixture_count = 85
    for (case_number = 1; case_number <= count; case_number++) {
        width = 32 + next_random() % 225
        height = 24 + next_random() % 169
        fixture = fixtures[next_random() % fixture_count]
        # Keep the increment arrow inside the framebuffer so the public pointer
        # event can reach it while still varying widths from 64 through 256.
        if ((fixture == "numeric-input-increment" || fixture == "option-decrement" ||
             fixture == "option-increment" || fixture == "popup-close" ||
             fixture == "text-input-overflow-edit" ||
             fixture ~ /^menu-(open|button-open|intrinsic|anchored|hover|disabled|choice|outside-close|escape-close)$/) && width < 64) width = 64
        if (fixture ~ /^division-/ && width < 64) width = 64
        if (fixture ~ /^division-/ && height < 48) height = 48
        if (fixture == "popup-drag" || fixture == "popup-resize") {
            if (width < 96) width = 96
            if (height < 72) height = 72
        }
        if ((fixture == "popup-close" ||
             fixture ~ /^menu-(open|button-open|intrinsic|anchored|hover|disabled|choice|outside-close|escape-close)$/) && height < 48) height = 48
        printf "%d %s %d %d\n", case_number, fixture, width, height
    }
}
'
