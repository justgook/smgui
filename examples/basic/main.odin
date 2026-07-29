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
  [x] Division containers use automatic flow layout
  [x] Integer display, slider, and progress bar represented
  [x] Editable UTF-8 text input represented
  [x] Integer and floating-point inputs represented
  [x] Active and disabled select/option controls represented
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
		"Volume",
		"Progress",
		"Player name",
		"Target value",
		"Scale",
		"Language",
	}

	shadows_enabled := true
	difficulty := 0
	volume := 42
	target_value := 26
	scale: f32 = 3.141
	language := 0
	languages := []string{"Odin", "C", "Assembly"}
	apply_requested := false
	player_name: smgui.Text_Buffer
	if error := smgui.text_buffer_init(&player_name, "Player One", 32); error != .None {
		fail("initializing player-name buffer", error)
	}
	defer smgui.text_buffer_deinit(&player_name)
	active_controls := []smgui.Form {
		{kind = .Label, label = 2},
		{kind = .Label, flags = {.No_Break}, label = 15},
		{
			kind = .Select,
			flags = {.No_Break},
			width = 120,
			binding = smgui.bind(&language),
			options = languages,
		},
		{kind = .Option, width = 140, binding = smgui.bind(&language), options = languages},
		{kind = .Checkbox, label = 3, binding = smgui.bind(&shadows_enabled)},
		{
			kind = .Radio,
			flags = {.No_Break},
			label = 4,
			binding = smgui.bind(&difficulty),
			value = 0,
		},
		{kind = .Radio, label = 5, binding = smgui.bind(&difficulty), value = 1},
		{kind = .Label, flags = {.No_Break}, label = 10},
		{kind = .Decimal_64, flags = {.No_Break}, binding = smgui.bind(&volume)},
		{kind = .Slider, binding = smgui.bind(&volume), minimum = 0, maximum = 100},
		{kind = .Label, flags = {.No_Break}, label = 11},
		{kind = .Progress_Bar, binding = smgui.bind(&volume), minimum = 0, maximum = 100},
		{kind = .Label, flags = {.No_Break}, label = 12},
		{kind = .Text_Input, width = 220, binding = smgui.bind(&player_name), max_length = 32},
		{kind = .Label, flags = {.No_Break}, label = 13},
		{
			kind = .Integer_64,
			binding = smgui.bind(&target_value),
			minimum = 0,
			maximum = 100,
			increment = 1,
		},
		{kind = .Label, flags = {.No_Break}, label = 14},
		{
			kind = .Float_Input,
			binding = smgui.bind(&scale),
			float_minimum = 0,
			float_maximum = 10,
			float_increment = 0.1,
		},
		{kind = .Button, label = 6, binding = smgui.bind(&apply_requested)},
	}
	inactive_controls := []smgui.Form {
		{kind = .Label, flags = {.Disabled}, label = 7},
		{
			kind = .Checkbox,
			flags = {.Disabled, .No_Break},
			label = 8,
			binding = smgui.bind(&shadows_enabled),
		},
		{kind = .Button, flags = {.Disabled}, label = 6},
		{
			kind = .Select,
			flags = {.Disabled, .No_Break},
			width = 120,
			binding = smgui.bind(&language),
			options = languages,
		},
		{
			kind = .Option,
			flags = {.Disabled},
			width = 140,
			binding = smgui.bind(&language),
			options = languages,
		},
	}
	forms := []smgui.Form {
		{
			kind = .Label,
			horizontal_alignment = .Center,
			x = smgui.percent(50),
			y = smgui.absolute(45),
			label = 1,
		},
		{
			kind = .Division,
			x = smgui.absolute(50),
			y = smgui.absolute(85),
			width = 620,
			height = 335,
			margin = 16,
			children = active_controls,
		},
		{
			kind = .Division,
			x = smgui.absolute(50),
			y = smgui.absolute(445),
			width = 620,
			height = 130,
			margin = 16,
			children = inactive_controls,
		},
		{
			kind = .Label,
			horizontal_alignment = .Center,
			x = smgui.percent(50),
			y = smgui.absolute(600),
			label = 9,
		},
	}

	backend_state: raylib_backend.State
	ctx: smgui.Context
	if error := smgui.init(&ctx, raylib_backend.create(&backend_state), texts, 720, 650);
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
			fmt.printf(
				"Applied settings: shadows=%v difficulty=%d volume=%d player=%s target=%d scale=%g language=%s\n",
				shadows_enabled,
				difficulty,
				volume,
				smgui.text_buffer_string(&player_name),
				target_value,
				scale,
				languages[language],
			)
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
