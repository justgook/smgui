package main

/*
Reference: reference-c/examples/helloworld.c and docs/screen1.png

Purpose:
  Growing production-readiness showcase for every migrated SMGUI feature.

Status:
  [x] Raylib window opens through `make run`
  [x] Built-in PSF2 font renders labels
  [x] Buttons, checkboxes, and radio buttons render
  [x] Active controls mutate application state
  [x] Disabled controls are visually distinct and inert
  [ ] Remaining built-in controls represented
  [ ] Optional font and widget modules represented
  [ ] Backend can be selected through `BACKEND=<name>`

Definition of done:
  - `make run` opens and closes cleanly
  - Every production module has an interactive visual example
  - Reviewed screenshots exist for every supported backend
  - The example contains no backend-specific UI state
*/

import psf2 "../../psf2"
import smgui "../../smgui"
import raylib_backend "../../smgui/raylib"
import "core:fmt"
import "core:os"

main :: proc() {
	texts := []string {
		"SMGUI Odin migration",
		"SMGUI widget showcase",
		"Active controls",
		"Enable shadows",
		"Easy",
		"Hard",
		"Apply",
		"Disabled controls",
		"Unavailable",
		"Close the window to exit",
	}

	shadows_enabled := true
	difficulty := 0
	apply_requested := false
	forms := []smgui.Form {
		{
			kind = .Label,
			horizontal_alignment = .Center,
			x = smgui.percent(50),
			y = smgui.absolute(45),
			label = 1,
		},
		{kind = .Label, x = smgui.absolute(50), y = smgui.absolute(100), label = 2},
		{
			kind = .Checkbox,
			x = smgui.absolute(70),
			y = smgui.absolute(130),
			label = 3,
			binding = smgui.bind(&shadows_enabled),
		},
		{
			kind = .Radio,
			x = smgui.absolute(70),
			y = smgui.absolute(165),
			label = 4,
			binding = smgui.bind(&difficulty),
			value = 0,
		},
		{
			kind = .Radio,
			x = smgui.absolute(145),
			y = smgui.absolute(165),
			label = 5,
			binding = smgui.bind(&difficulty),
			value = 1,
		},
		{
			kind = .Button,
			x = smgui.absolute(70),
			y = smgui.absolute(205),
			label = 6,
			binding = smgui.bind(&apply_requested),
		},
		{kind = .Label, x = smgui.absolute(50), y = smgui.absolute(275), label = 7},
		{
			kind = .Checkbox,
			flags = {.Disabled},
			x = smgui.absolute(70),
			y = smgui.absolute(305),
			label = 8,
			binding = smgui.bind(&shadows_enabled),
		},
		{
			kind = .Button,
			flags = {.Disabled},
			x = smgui.absolute(70),
			y = smgui.absolute(340),
			label = 6,
		},
		{
			kind = .Label,
			horizontal_alignment = .Center,
			x = smgui.percent(50),
			y = smgui.absolute(430),
			label = 9,
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
		if apply_requested {
			fmt.printf("Applied settings: shadows=%v difficulty=%d\n", shadows_enabled, difficulty)
			apply_requested = false
			if refresh_error := smgui.refresh(&ctx); refresh_error != .None {
				fail("refreshing SMGUI", refresh_error)
			}
		}
	}
}

@(private = "file")
fail :: proc(operation: string, error: smgui.Error) -> ! {
	fmt.eprintf("Error %s: %v\n", operation, error)
	os.exit(1)
}
