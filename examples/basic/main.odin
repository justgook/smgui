package main

/*
Reference: reference-c/examples/helloworld.c

Purpose:
  First visual and manual test of the Odin migration.

Status:
  [x] Raylib window opens through `make run`
  [x] Built-in PSF2 font renders labels
  [x] A label and button exercise basic layout/rendering
  [ ] Button interaction mutates application state
  [ ] Backend can be selected through `BACKEND=<name>`

Definition of done:
  - `make run` opens and closes cleanly
  - Visual output has a reviewed reference-C screenshot
  - The example contains no backend-specific UI state
*/

import psf2 "../../psf2"
import smgui "../../smgui"
import raylib_backend "../../smgui/raylib"
import "core:fmt"
import "core:os"

main :: proc() {
	texts := []string{"SMGUI Odin migration", "Hello from state-mode UI", "Button"}
	forms := []smgui.Form {
		{
			kind = .Label,
			horizontal_alignment = .Center,
			x = smgui.percent(50),
			y = smgui.absolute(100),
			label = 1,
		},
		{
			kind = .Button,
			horizontal_alignment = .Center,
			x = smgui.percent(50),
			y = smgui.absolute(145),
			label = 2,
		},
	}

	backend_state: raylib_backend.State
	ctx: smgui.Context
	if error := smgui.init(&ctx, raylib_backend.create(&backend_state), texts, 640, 480);
	   error != .None {
		fail("initializing SMGUI", error)
	}
	defer {
		if error := smgui.deinit(&ctx); error != .None {
			fmt.eprintln("SMGUI shutdown failed:", error)
		}
	}

	font, error := psf2.default_font()
	if error != .None {
		fail("loading the built-in PSF2 font", error)
	}
	if error = psf2.configure(&ctx, &font); error != .None {
		fail("configuring the PSF2 font", error)
	}

	for {
		_, state, poll_error := smgui.poll_event(&ctx, forms)
		if poll_error != .None {
			fail("polling SMGUI", poll_error)
		}
		if state == .Closed {
			break
		}
	}
}

@(private = "file")
fail :: proc(operation: string, error: smgui.Error) -> ! {
	fmt.eprintf("Error %s: %v\n", operation, error)
	os.exit(1)
}
