package main

import "core:c"
import "core:fmt"
import "core:os"
import "core:strings"
import stbi "vendor:stb/image"

main :: proc() {
	if len(os.args) != 3 {
		fmt.eprintf("usage: %s LEFT.png RIGHT.png\n", os.args[0])
		os.exit(2)
	}

	left_path := strings.clone_to_cstring(os.args[1], context.temp_allocator) or_else nil
	right_path := strings.clone_to_cstring(os.args[2], context.temp_allocator) or_else nil
	if left_path == nil || right_path == nil {
		fmt.eprintln("failed to allocate image paths")
		os.exit(2)
	}

	left_width, left_height, left_channels: c.int
	right_width, right_height, right_channels: c.int
	left := stbi.load(left_path, &left_width, &left_height, &left_channels, 4)
	if left == nil {
		fmt.eprintf("failed to decode %s: %s\n", os.args[1], stbi.failure_reason())
		os.exit(2)
	}
	defer stbi.image_free(left)
	right := stbi.load(right_path, &right_width, &right_height, &right_channels, 4)
	if right == nil {
		fmt.eprintf("failed to decode %s: %s\n", os.args[2], stbi.failure_reason())
		os.exit(2)
	}
	defer stbi.image_free(right)

	if left_width != right_width || left_height != right_height {
		fmt.eprintf(
			"framebuffer dimensions differ: %dx%d != %dx%d\n",
			left_width,
			left_height,
			right_width,
			right_height,
		)
		os.exit(1)
	}

	byte_count := int(left_width) * int(left_height) * 4
	mismatch_count := 0
	first_mismatch := -1
	for index in 0 ..< byte_count {
		if left[index] != right[index] {
			if first_mismatch < 0 {
				first_mismatch = index
			}
			mismatch_count += 1
		}
	}
	if mismatch_count > 0 {
		pixel := first_mismatch / 4
		x := pixel % int(left_width)
		y := pixel / int(left_width)
		fmt.eprintf(
			"framebuffers differ: %d RGBA bytes; first mismatch at (%d,%d) channel %d: %02x != %02x\n",
			mismatch_count,
			x,
			y,
			first_mismatch % 4,
			left[first_mismatch],
			right[first_mismatch],
		)
		os.exit(1)
	}
	fmt.printf("framebuffers match: %dx%d RGBA\n", left_width, left_height)
}
