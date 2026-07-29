package main

/* Small deterministic Odin framebuffer parity fixtures. */

import smgui "../../../smgui"
import image_backend "../../../smgui/image"
import "core:fmt"
import "core:os"

main :: proc() {
	if len(os.args) != 3 {
		fmt.eprintf("usage: %s CASE OUTPUT.png\n", os.args[0])
		os.exit(2)
	}

	forms: []smgui.Form
	switch os.args[1] {
	case "empty":
		forms = nil
	case:
		fmt.eprintf("unknown parity case: %s\n", os.args[1])
		os.exit(2)
	}

	texts := []string{"Parity fixture"}
	image_state: image_backend.State
	ctx: smgui.Context
	if error := smgui.init(
		&ctx,
		image_backend.create(&image_state, os.args[2]),
		texts,
		64,
		48,
	); error != .None {
		fmt.eprintf("init failed: %v\n", error)
		os.exit(1)
	}
	defer {
		if error := smgui.deinit(&ctx); error != .None {
			fmt.eprintf("deinit failed: %v\n", error)
		}
	}

	for {
		_, state, error := smgui.poll_event(&ctx, forms)
		if error != .None {
			fmt.eprintf("poll failed: %v\n", error)
			os.exit(1)
		}
		if state == .Closed {
			break
		}
	}
	if !image_state.succeeded {
		fmt.eprintf("failed to write %s\n", os.args[2])
		os.exit(1)
	}
}
